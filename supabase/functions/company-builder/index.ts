// company-builder: master-admin-only AI draft of a company profile.
//
// POST { companyName: string, domainHint?: string }
//   -> 200 { draft: CompanyDraft, model: string, warnings: string[] }
//   -> 401/403 when the caller is not a signed-in master admin (profiles.is_admin)
//   -> 503 when no OpenAI key is configured, 502 on upstream/parse errors
//
// The OpenAI key is read server-side only, using the SAME lookup the deployed
// ai-tutor and skill-assessment functions use: public.app_config row
// key = 'OPENAI_API_KEY' (service-role only), falling back to the Edge Function
// secret OPENAI_API_KEY. It is never returned or logged.
//
// This function only drafts. It never writes to the database; the admin UI
// saves/publishes through the save_company_draft / publish_company_profile RPCs.
import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'npm:@supabase/supabase-js@2.49.1';

const MODEL = 'gpt-4o-mini';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
);

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

async function getOpenAIKey(): Promise<string> {
  const { data, error } = await supabase
    .from('app_config')
    .select('value')
    .eq('key', 'OPENAI_API_KEY')
    .limit(1)
    .maybeSingle();
  if (!error && data?.value) return data.value;
  return Deno.env.get('OPENAI_API_KEY') ?? '';
}

/** JWT -> user, then DB check (same rule as is_admin(): profiles.is_admin = true). */
async function requireMasterAdmin(req: Request): Promise<{ userId: string } | Response> {
  const token = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '').trim();
  if (!token) return json({ error: 'Sign in required.' }, 401);
  const { data: userData, error: userErr } = await supabase.auth.getUser(token);
  const userId = userData?.user?.id;
  if (userErr || !userId) return json({ error: 'Invalid or expired session.' }, 401);
  const { data: prof, error: profErr } = await supabase
    .from('profiles')
    .select('is_admin')
    .eq('id', userId)
    .maybeSingle();
  if (profErr) return json({ error: 'Could not verify admin access.' }, 500);
  if (!prof?.is_admin) return json({ error: 'Master admin access required.' }, 403);
  return { userId };
}

function normalizeDomain(raw: string | null | undefined): string {
  if (!raw) return '';
  let d = raw.trim().toLowerCase();
  d = d.replace(/^[a-z]+:\/\//, '').replace(/^www\./, '').split(/[/?#\s]/)[0] ?? '';
  return /^[a-z0-9-]+(\.[a-z0-9-]+)+$/.test(d) ? d : '';
}

/** Free, keyless logo sources derived from the domain (no paid API). */
function logoForDomain(domain: string): { logo_url: string; logo_fallbacks: string[] } {
  if (!domain) return { logo_url: '', logo_fallbacks: [] };
  return {
    logo_url: `https://www.google.com/s2/favicons?domain=${encodeURIComponent(domain)}&sz=256`,
    logo_fallbacks: [`https://icons.duckduckgo.com/ip3/${encodeURIComponent(domain)}.ico`],
  };
}

const HEX = /^#[0-9a-fA-F]{6}$/;
const DEFAULT_COLORS = { primary: '#0A1628', secondary: '#16294A', accent: '#EC682B' };

function strList(v: unknown, max = 12): string[] {
  if (!Array.isArray(v)) return [];
  return v
    .filter((x): x is string => typeof x === 'string')
    .map((x) => x.trim())
    .filter(Boolean)
    .slice(0, max);
}

// JSON schema for OpenAI Structured Outputs (strict mode: every property required).
const RESPONSE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: [
    'name', 'domain', 'industry', 'summary', 'locations', 'equipment', 'processes',
    'brand_colors', 'suggested_tracks', 'confidence', 'notes',
  ],
  properties: {
    name: { type: 'string', description: 'Official company name' },
    domain: { type: 'string', description: 'Primary website domain, e.g. example.com. Empty string if unknown.' },
    industry: { type: 'string' },
    summary: { type: 'string', description: '1-2 sentence description of what the company makes/does.' },
    locations: { type: 'array', items: { type: 'string' }, description: 'Known plant/site locations as "City, State/Country". Empty if unknown.' },
    equipment: { type: 'array', items: { type: 'string' }, description: 'Typical plant equipment maintenance techs would work on.' },
    processes: { type: 'array', items: { type: 'string' }, description: 'Typical manufacturing/industrial processes.' },
    brand_colors: {
      type: 'object',
      additionalProperties: false,
      required: ['primary', 'secondary', 'accent'],
      properties: {
        primary: { type: 'string', description: '#RRGGBB' },
        secondary: { type: 'string', description: '#RRGGBB' },
        accent: { type: 'string', description: '#RRGGBB' },
      },
    },
    suggested_tracks: {
      type: 'array',
      description: '4-8 courses chosen ONLY from the provided catalog, by exact course_id.',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['course_id', 'reason'],
        properties: {
          course_id: { type: 'string' },
          reason: { type: 'string', description: 'One short sentence tying the course to their equipment/processes.' },
        },
      },
    },
    confidence: { type: 'string', enum: ['low', 'medium', 'high'] },
    notes: { type: 'string', description: 'What is uncertain / should be verified by a human.' },
  },
} as const;

interface CatalogCourse {
  id: string;
  title: string;
  stage: string;
  tier: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 200, headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  try {
    const auth = await requireMasterAdmin(req);
    if (auth instanceof Response) return auth;

    let body: { companyName?: string; domainHint?: string };
    try {
      body = await req.json();
    } catch {
      return json({ error: 'Invalid JSON body.' }, 400);
    }
    const companyName = (body.companyName ?? '').trim().slice(0, 120);
    if (!companyName) return json({ error: 'companyName is required.' }, 400);
    const domainHint = normalizeDomain(body.domainHint);

    const openaiKey = await getOpenAIKey();
    if (!openaiKey) {
      return json({ error: 'AI builder is not configured (OPENAI_API_KEY missing). You can still fill the draft manually.' }, 503);
    }

    // Existing public catalog only (no custom/assigned courses). Never invents courses.
    const { data: courseRows, error: courseErr } = await supabase
      .from('courses')
      .select('id, title, stage, tier')
      .eq('is_custom', false)
      .order('stage', { ascending: true })
      .order('sort_order', { ascending: true });
    if (courseErr) return json({ error: 'Could not load course catalog.' }, 500);
    const catalog = (courseRows ?? []) as CatalogCourse[];
    const byId = new Map(catalog.map((c) => [c.id, c]));
    const catalogText = catalog.map((c) => `${c.id} | ${c.title} | ${c.stage}`).join('\n');

    const system = [
      'You build draft company profiles for ForgeLine Academy, an ONLINE industrial maintenance training platform.',
      'Use only widely known public facts. If unsure about a fact (domain, locations, colors), give your best guess and say so in notes; use an empty string/array rather than inventing specifics.',
      'Brand colors must be #RRGGBB hex values approximating the company brand.',
      'suggested_tracks must reference course_id values copied EXACTLY from the catalog below. Do not invent courses.',
      'Company training is delivered as online memberships only; do not mention on-site training.',
      '',
      'CATALOG (course_id | title | stage):',
      catalogText,
    ].join('\n');

    const user = `Company: ${companyName}${domainHint ? `\nKnown website: ${domainHint}` : ''}`;

    const res = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${openaiKey}` },
      body: JSON.stringify({
        model: MODEL,
        temperature: 0.3,
        max_tokens: 1500,
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: user },
        ],
        response_format: {
          type: 'json_schema',
          json_schema: { name: 'company_profile', strict: true, schema: RESPONSE_SCHEMA },
        },
      }),
    });

    if (!res.ok) {
      let detail = '';
      try {
        const errBody = await res.json();
        detail = errBody?.error?.message ?? '';
      } catch {
        // ignore
      }
      return json({ error: detail || `OpenAI request failed (${res.status})` }, 502);
    }

    const completion = await res.json();
    const message = completion?.choices?.[0]?.message;
    if (message?.refusal) return json({ error: `AI declined: ${message.refusal}` }, 502);
    let raw: Record<string, unknown>;
    try {
      raw = JSON.parse(message?.content ?? '');
    } catch {
      return json({ error: 'AI returned an unreadable draft. Try Regenerate.' }, 502);
    }

    const warnings: string[] = [];
    const domain = domainHint || normalizeDomain(raw.domain as string);
    if (!domain) warnings.push('No reliable domain found; add one to get a logo.');

    const colorsIn = (raw.brand_colors ?? {}) as Record<string, string>;
    const brand_colors = {
      primary: HEX.test(colorsIn.primary ?? '') ? colorsIn.primary : DEFAULT_COLORS.primary,
      secondary: HEX.test(colorsIn.secondary ?? '') ? colorsIn.secondary : DEFAULT_COLORS.secondary,
      accent: HEX.test(colorsIn.accent ?? '') ? colorsIn.accent : DEFAULT_COLORS.accent,
    };

    const tracksIn = Array.isArray(raw.suggested_tracks) ? raw.suggested_tracks : [];
    const seen = new Set<string>();
    const suggested_tracks = tracksIn
      .map((t) => t as { course_id?: string; reason?: string })
      .filter((t) => t.course_id && byId.has(t.course_id) && !seen.has(t.course_id) && seen.add(t.course_id))
      .slice(0, 8)
      .map((t) => {
        const c = byId.get(t.course_id!)!;
        return { course_id: c.id, title: c.title, stage: c.stage, tier: c.tier, reason: (t.reason ?? '').trim() };
      });
    if (suggested_tracks.length < tracksIn.length) warnings.push('Dropped AI track suggestions that did not match an existing course.');

    const draft = {
      name: (typeof raw.name === 'string' && raw.name.trim()) || companyName,
      domain,
      ...logoForDomain(domain),
      industry: typeof raw.industry === 'string' ? raw.industry.trim() : '',
      summary: typeof raw.summary === 'string' ? raw.summary.trim() : '',
      locations: strList(raw.locations),
      equipment: strList(raw.equipment, 20),
      processes: strList(raw.processes, 20),
      brand_colors,
      suggested_tracks,
      confidence: ['low', 'medium', 'high'].includes(raw.confidence as string) ? raw.confidence : 'low',
      notes: typeof raw.notes === 'string' ? raw.notes.trim() : '',
    };

    return json({ draft, model: MODEL, warnings });
  } catch (error) {
    const msg = error instanceof Error ? error.message : 'Unexpected error';
    return json({ error: msg }, 500);
  }
});
