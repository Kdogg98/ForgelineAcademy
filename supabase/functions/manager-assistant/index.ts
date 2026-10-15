import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'npm:@supabase/supabase-js@2.49.1';

/**
 * manager-assistant: the AI Tutor's "Manager Assistant" mode for company
 * owners / admins / supervisors.
 *
 * Security model
 *  - verify_jwt = true. Every company read uses a client built from the CALLER'S
 *    JWT + anon key, so RLS limits data to what this person may already see.
 *  - The caller's company and role are looked up server-side (company_members);
 *    the client-supplied company_id must match it. Roles below supervisor get 403.
 *  - The service-role key is used ONLY to read the OpenAI key from app_config
 *    (same as ai-tutor); never for company data.
 *  - The assistant never writes. It may return `proposals` (course assignments
 *    or a training-request draft); the UI shows them and the MANAGER clicks
 *    Confirm, which calls manager_assign_course / inserts the request with their
 *    own session. No emails are sent from here.
 */
const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};
const json = (b: unknown, s = 200) => new Response(JSON.stringify(b), { status: s, headers: { ...cors, 'Content-Type': 'application/json' } });

const admin = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
async function openAIKey(): Promise<string> {
  const { data } = await admin.from('app_config').select('value').eq('key', 'OPENAI_API_KEY').limit(1).maybeSingle();
  return data?.value ?? Deno.env.get('OPENAI_API_KEY') ?? '';
}

const SYSTEM = `You are ForgeLine Academy's Manager Assistant, helping a company owner/admin/supervisor run training for their skilled-trades team.
You can: summarize team progress and activity, point out who is behind / overdue / has contracts ending soon / recent certificates,
suggest course assignments by trade, role, client placement industry and site equipment, propose assignments, draft a custom training
request for ForgeLine, and answer how-to questions about the ForgeLine manager dashboard.
Rules:
- Use ONLY the team data provided below. Never invent people, numbers, or courses. Course ids must come from the catalog list.
- To assign courses, call propose_assignments. Assignments are NOT made until the manager clicks Confirm; say so.
- To draft a custom training request, call draft_training_request. It is only submitted when the manager reviews and submits it.
- You never send emails or messages.
- Be brief, practical, plain language. Use short bullet lists. Use first names.
Dashboard how-to: Employees tab (filter by trade/role/client/industry, click a person to edit role, trade, placement and contract),
Assign course (single person, everyone, or a whole trade/role), Invites (single or bulk paste/CSV: email, trade, role; pending invites use seats),
Clients & sites (placements: client, industry, location, equipment), Training profile, Request custom training, Export audit CSV / Print.`;

const tools = [
  {
    type: 'function',
    function: {
      name: 'propose_assignments',
      description: 'Propose course assignments for the manager to confirm in the UI. Does not assign anything by itself.',
      parameters: {
        type: 'object',
        properties: {
          items: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                user_id: { type: 'string', description: 'Team member user_id, or "*" for everyone' },
                course_id: { type: 'string' },
                due_date: { type: 'string', description: 'YYYY-MM-DD or empty' },
                reason: { type: 'string' },
              },
              required: ['user_id', 'course_id', 'reason'],
            },
          },
        },
        required: ['items'],
      },
    },
  },
  {
    type: 'function',
    function: {
      name: 'draft_training_request',
      description: 'Draft a custom training request to ForgeLine for the manager to review and submit.',
      parameters: {
        type: 'object',
        properties: {
          topic: { type: 'string' }, details: { type: 'string' }, worker_count: { type: 'integer' },
          trades: { type: 'string' }, urgency: { type: 'string', enum: ['flexible', 'normal', 'soon', 'urgent'] },
          preferred_format: { type: 'string', enum: ['online', 'on_site', 'blend'] },
          placement_id: { type: 'string', description: 'Client placement id if it targets one site' },
        },
        required: ['topic', 'details'],
      },
    },
  },
];

// deno-lint-ignore no-explicit-any
type Any = any;

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 200, headers: cors });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  try {
    const auth = req.headers.get('Authorization') ?? '';
    const db = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_ANON_KEY') ?? '', { global: { headers: { Authorization: auth } } });
    const { data: u } = await db.auth.getUser(auth.replace(/^Bearer\s+/i, ''));
    const user = u?.user;
    if (!user) return json({ error: 'Sign in to use the Manager Assistant.' }, 401);

    const body = await req.json() as { company_id?: string; mode?: 'chat' | 'daily_summary'; messages?: { role: 'user' | 'assistant'; content: string }[] };
    const { data: me } = await db.from('company_members').select('company_id, role').eq('user_id', user.id).maybeSingle();
    if (!me || !['owner', 'admin', 'supervisor'].includes(me.role)) return json({ error: 'The Manager Assistant is for company owners, admins and supervisors.' }, 403);
    if (body.company_id && body.company_id !== me.company_id) return json({ error: 'Wrong company.' }, 403);
    const companyId = me.company_id as string;

    // ---- team data, all through RLS with the caller's JWT ----
    const [team, co, asg, courses] = await Promise.all([
      db.rpc('get_company_team', { p_company_id: companyId }),
      db.from('companies').select('name').eq('id', companyId).maybeSingle(),
      db.from('course_assignments').select('user_id, course_id, due_date').eq('company_id', companyId),
      db.from('courses').select('id, title, stage').limit(300),
    ]);
    if (team.error) return json({ error: 'Could not load your team.' }, 500);
    const members = (team.data as Any[]) ?? [];
    const ids = members.map((m) => m.user_id);
    const [roll, certs, placements] = await Promise.all([
      db.from('company_member_course_progress').select('user_id, course_id, lessons_completed, avg_quiz_score, last_activity').in('user_id', ids),
      db.from('certificates').select('user_id, course_id, issued_at').in('user_id', ids),
      db.from('company_placements').select('id, client_name, industry, location, equipment, research_ok').eq('company_id', companyId),
    ]);
    const title: Record<string, string> = Object.fromEntries(((courses.data as Any[]) ?? []).map((c) => [c.id, c.title]));
    const pl: Record<string, Any> = Object.fromEntries(((placements.data as Any[]) ?? []).map((p) => [p.id, p]));
    const today = new Date().toISOString().slice(0, 10);
    const done = new Set(((certs.data as Any[]) ?? []).map((c) => `${c.user_id}:${c.course_id}`));
    const ctx = {
      today, company: co.data?.name, caller_role: me.role,
      team: members.map((m) => {
        const d = m.details ?? {};
        const p = d.placement_id ? pl[d.placement_id] : null;
        return {
          user_id: m.user_id, name: m.full_name || m.email, role: m.custom_role || m.role, trade: d.trade ?? null,
          placement: p ? { id: p.id, client: p.client_name, industry: p.industry, location: d.site_location || p.location, equipment: p.equipment } : null,
          contract_end: d.contract_end ?? null,
          courses: ((roll.data as Any[]) ?? []).filter((r) => r.user_id === m.user_id).map((r) => ({ course: title[r.course_id] ?? r.course_id, lessons_done: r.lessons_completed, avg_quiz: r.avg_quiz_score, last: r.last_activity })),
          assignments: ((asg.data as Any[]) ?? []).filter((a) => a.user_id === m.user_id).map((a) => ({ course: title[a.course_id] ?? a.course_id, due: a.due_date, done: done.has(`${m.user_id}:${a.course_id}`), overdue: !!a.due_date && a.due_date < today && !done.has(`${m.user_id}:${a.course_id}`) })),
          certificates: ((certs.data as Any[]) ?? []).filter((c) => c.user_id === m.user_id).map((c) => ({ course: title[c.course_id], issued: c.issued_at })),
        };
      }),
      placements: Object.values(pl),
      catalog: ((courses.data as Any[]) ?? []).map((c) => ({ id: c.id, title: c.title, stage: c.stage })),
    };

    const key = await openAIKey();
    if (!key) return json({ error: 'The AI key is not configured.' }, 500);
    const userMsgs = body.mode === 'daily_summary'
      ? [{ role: 'user', content: 'Give me today\'s daily summary: activity in the last 24h/7d, who is behind or overdue, contracts ending in the next 30 days, new certificates, and 1-3 suggested next actions. If a course assignment clearly makes sense, propose it.' }]
      : (body.messages ?? []).slice(-12).map((m) => ({ role: m.role === 'assistant' ? 'assistant' : 'user', content: String(m.content).slice(0, 4000) }));
    if (!userMsgs.length) return json({ error: 'Message required.' }, 400);

    const res = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${key}` },
      body: JSON.stringify({
        model: 'gpt-4o-mini', temperature: 0.3, max_tokens: 900, tools,
        messages: [{ role: 'system', content: SYSTEM }, { role: 'system', content: 'TEAM DATA (JSON):\n' + JSON.stringify(ctx).slice(0, 60000) }, ...userMsgs],
      }),
    });
    if (!res.ok) return json({ error: `AI request failed (${res.status})` }, 502);
    const out = await res.json();
    const msg = out?.choices?.[0]?.message ?? {};
    const memberIds = new Set(ids);
    const courseIds = new Set(Object.keys(title));
    const proposals: Any[] = [];
    let draft: Any = null;
    for (const tc of msg.tool_calls ?? []) {
      let args: Any = {};
      try { args = JSON.parse(tc.function?.arguments ?? '{}'); } catch { continue; }
      if (tc.function?.name === 'propose_assignments') {
        for (const it of args.items ?? []) {
          // drop anything that isn't a real member/course of this company
          if (!courseIds.has(it.course_id) || !(it.user_id === '*' || memberIds.has(it.user_id))) continue;
          proposals.push({ user_id: it.user_id === '*' ? null : it.user_id, course_id: it.course_id, due_date: /^\d{4}-\d{2}-\d{2}$/.test(it.due_date ?? '') ? it.due_date : null, reason: String(it.reason ?? '').slice(0, 300) });
        }
      } else if (tc.function?.name === 'draft_training_request') {
        draft = { ...args, placement_id: args.placement_id && pl[args.placement_id] ? args.placement_id : null };
      }
    }
    const reply = msg.content || (proposals.length ? 'Here are suggested assignments. Nothing is assigned until you click Confirm.' : draft ? 'I drafted a custom training request. Review it, then submit.' : '');
    return json({ reply, proposals, draft });
  } catch (e) {
    console.error('[manager-assistant]', e);
    return json({ error: 'Unexpected error' }, 500);
  }
});
