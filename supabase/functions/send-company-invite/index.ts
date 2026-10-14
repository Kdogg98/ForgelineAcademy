// send-company-invite: email a company invite link via Resend.
//
// NOT DEPLOYED. Deploy with `supabase functions deploy send-company-invite`
// after migration 20261014180000 is applied.
//
// POST { invite_id: string }   (Authorization: Bearer <caller's user JWT>)
//   -> 200 { email_sent: true }
//   -> 200 { email_sent: false, reason }  when RESEND_API_KEY is not set or Resend fails
//   -> 401 not signed in, 404 invite not visible to the caller (RLS: only managers
//      of the invite's company can read it), 409 invite no longer pending
//
// Uses the same Resend setup as the deployed `notify` function
// (RESEND_API_KEY secret, from noreply@forgelineacademy.com). The link is built
// server-side from SITE_URL (default https://forgelineacademy.com) and the
// invite's own token; any URL sent by the client is ignored.
import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'npm:@supabase/supabase-js@2.49.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
const esc = (s: string) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 200, headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const auth = req.headers.get('Authorization') ?? '';
  if (!auth.startsWith('Bearer ')) return json({ error: 'Not signed in' }, 401);

  // caller-scoped client: RLS decides whether this invite is visible
  const userClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_ANON_KEY') ?? '', {
    global: { headers: { Authorization: auth } },
  });
  const { data: u } = await userClient.auth.getUser();
  if (!u?.user) return json({ error: 'Not signed in' }, 401);

  let body: { invite_id?: string };
  try { body = await req.json(); } catch { return json({ error: 'Bad request' }, 400); }
  if (!body.invite_id) return json({ error: 'invite_id required' }, 400);

  const { data: inv } = await userClient
    .from('company_invites')
    .select('id, email, token, status, expires_at, company_id, companies(name)')
    .eq('id', body.invite_id)
    .maybeSingle();
  if (!inv) return json({ error: 'Invite not found' }, 404);
  if (inv.status !== 'pending' || new Date(inv.expires_at) <= new Date()) return json({ error: 'Invite is no longer pending' }, 409);

  const resendKey = Deno.env.get('RESEND_API_KEY');
  if (!resendKey) {
    console.log('[send-company-invite] RESEND_API_KEY not configured, skipping email');
    return json({ email_sent: false, reason: 'Automatic invite emails are not configured. Copy the link and send it yourself.' });
  }

  const site = (Deno.env.get('SITE_URL') ?? 'https://forgelineacademy.com').replace(/\/$/, '');
  const link = `${site}/auth?invite=${encodeURIComponent(inv.token)}`;
  // deno-lint-ignore no-explicit-any
  const companyName = ((inv as any).companies?.name as string | undefined) ?? 'your company';
  const expires = new Date(inv.expires_at).toUTCString().slice(0, 16);
  const html = `
    <div style="font-family:sans-serif;font-size:15px;line-height:1.6;color:#111">
      <h2 style="margin:0 0 12px">You're invited to ${esc(companyName)} on ForgeLine Academy</h2>
      <p>Your manager added you to the ${esc(companyName)} team. Sign up or sign in with <b>${esc(inv.email)}</b> and you'll join automatically.</p>
      <p><a href="${esc(link)}" style="display:inline-block;background:#1FA2FF;color:#fff;padding:10px 18px;border-radius:6px;text-decoration:none">Accept invite</a></p>
      <p style="font-size:12px;color:#666">This invite expires ${esc(expires)}. Use the same email address it was sent to. If you weren't expecting it, you can ignore this email.</p>
    </div>`;

  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${resendKey}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        from: 'ForgeLine Academy <noreply@forgelineacademy.com>',
        to: [inv.email],
        subject: `You're invited to join ${companyName} on ForgeLine Academy`,
        html,
      }),
    });
    if (!res.ok) {
      console.error('[send-company-invite] Resend error', res.status, await res.text());
      return json({ email_sent: false, reason: 'The email could not be sent. Copy the link and send it yourself.' });
    }
    return json({ email_sent: true });
  } catch (e) {
    console.error('[send-company-invite] send failed', e);
    return json({ email_sent: false, reason: 'The email could not be sent. Copy the link and send it yourself.' });
  }
});
