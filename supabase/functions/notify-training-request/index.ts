import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'npm:@supabase/supabase-js@2.49.1';

/**
 * notify-training-request: emails kris@forgelineacademy.com (or NOTIFY_TRAINING_EMAIL)
 * when a company submits a custom training request. Modeled on `notify` (Resend).
 *
 * verify_jwt = true. The caller's JWT is used to READ the request, so RLS proves the
 * caller can see it (owner/admin of that company or platform admin). Nothing is written.
 * Missing RESEND_API_KEY => logs and returns { email_sent: false }; the client never
 * blocks the request on this.
 */
const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};
const json = (b: unknown, s = 200) => new Response(JSON.stringify(b), { status: s, headers: { ...cors, 'Content-Type': 'application/json' } });
const esc = (v: unknown) => String(v ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]!));

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 200, headers: cors });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  try {
    const auth = req.headers.get('Authorization') ?? '';
    const { request_id } = await req.json() as { request_id?: string };
    if (!request_id) return json({ error: 'request_id is required' }, 400);

    const db = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_ANON_KEY') ?? '', {
      global: { headers: { Authorization: auth } },
    });
    const { data: r, error } = await db.from('training_requests')
      .select('id, company_id, topic, topics, details, worker_count, trades, urgency, preferred_format, industries, equipment, research_ok, attachments, source, created_at, companies(name), company_placements(client_name, location)')
      .eq('id', request_id).maybeSingle();
    if (error || !r) return json({ email_sent: false, reason: 'Request not found' }, 404);

    const key = Deno.env.get('RESEND_API_KEY');
    const to = Deno.env.get('NOTIFY_TRAINING_EMAIL') ?? 'kris@forgelineacademy.com';
    // deno-lint-ignore no-explicit-any
    const row = r as any;
    const company = row.companies?.name ?? 'A company';
    const subject = `New custom training request: ${row.topic} (${company})`;
    const line = (k: string, v: unknown) => (v == null || v === '' || (Array.isArray(v) && !v.length) ? '' : `<tr><td style="padding:4px 12px 4px 0;color:#666">${esc(k)}</td><td>${esc(Array.isArray(v) ? v.join(', ') : v)}</td></tr>`);
    const html = `<h2>New custom training request</h2><table>
      ${line('Company', company)}${line('Client / site', row.company_placements ? `${row.company_placements.client_name}${row.company_placements.location ? ' · ' + row.company_placements.location : ''}` : '')}
      ${line('Topic', row.topic)}${line('Topics', row.topics)}${line('Workers', row.worker_count)}${line('Trades / roles', row.trades)}
      ${line('Urgency', row.urgency)}${line('Format', row.preferred_format)}${line('Industry', row.industries)}${line('Equipment', row.equipment)}
      ${line('Research our company', row.research_ok ? 'Yes, ForgeLine should research and tailor' : '')}
      ${line('Attachments', row.attachments?.length ? `${row.attachments.length} file(s) in training-request-files` : '')}${line('Source', row.source)}
      </table><p style="white-space:pre-wrap">${esc(row.details)}</p><p>Open Admin → Training requests to quote or update status.</p>`;

    if (!key) {
      console.log('[notify-training-request] RESEND_API_KEY not set; would send to', to, subject);
      return json({ email_sent: false, reason: 'Email not configured' });
    }
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ from: 'ForgeLine Academy <noreply@forgelineacademy.com>', to: [to], subject, html }),
    });
    if (!res.ok) { console.error('[notify-training-request] Resend error', res.status, await res.text()); return json({ email_sent: false, reason: 'Email provider error' }); }
    return json({ email_sent: true });
  } catch (e) {
    console.error('[notify-training-request]', e);
    return json({ email_sent: false, reason: 'Unexpected error' }, 500);
  }
});
