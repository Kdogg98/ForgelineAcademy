import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface NotifyPayload {
  type: 'service_request' | 'retake_request' | 'retake_approved';
  // service_request
  name?: string;
  company?: string | null;
  email?: string;
  phone?: string | null;
  service_type?: string;
  message?: string | null;
  // retake_request
  member_name?: string;
  member_email?: string | null;
  course_title?: string;
  lesson_title?: string;
  failed_attempts?: number;
  // retake_approved
  // (uses member_name, member_email, lesson_title)
  // admin recipients (for retake_request)
  admin_emails?: string[];
}

async function sendEmail(to: string[], subject: string, html: string): Promise<boolean> {
  const resendKey = Deno.env.get('RESEND_API_KEY');
  if (!resendKey) {
    console.log('[notify] RESEND_API_KEY not configured — skipping email send. Would send to:', to.join(', '));
    console.log('[notify] Subject:', subject);
    return false;
  }

  const notifyEmail = Deno.env.get('NOTIFY_EMAIL') ?? to[0] ?? 'support@forgeline.academy';

  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'ForgeLine Academy <noreply@forgeline.academy>',
        to: to.length > 0 ? to : [notifyEmail],
        subject,
        html,
      }),
    });

    if (!res.ok) {
      const errText = await res.text();
      console.error('[notify] Resend API error:', res.status, errText);
      return false;
    }
    console.log('[notify] Email sent successfully to:', to.join(', '));
    return true;
  } catch (e) {
    console.error('[notify] Failed to send email:', e);
    return false;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const payload: NotifyPayload = await req.json();
    const notifyEmail = Deno.env.get('NOTIFY_EMAIL') ?? 'support@forgeline.academy';
    let subject = '';
    let html = '';
    let recipients: string[] = [];

    switch (payload.type) {
      case 'service_request': {
        const serviceLabel: Record<string, string> = {
          onsite_training: 'On-Site Training',
          troubleshooting: 'Troubleshooting',
          both: 'On-Site Training & Troubleshooting',
        };
        const label = serviceLabel[payload.service_type ?? ''] ?? payload.service_type ?? 'Service';
        subject = `New ForgeLine service request — ${label}`;
        recipients = [notifyEmail];
        html = `
          <h2>New Service Request</h2>
          <table style="font-family:sans-serif;font-size:14px;line-height:1.6;">
            <tr><td><strong>Name:</strong></td><td>${payload.name ?? ''}</td></tr>
            <tr><td><strong>Company:</strong></td><td>${payload.company ?? '—'}</td></tr>
            <tr><td><strong>Email:</strong></td><td>${payload.email ?? ''}</td></tr>
            <tr><td><strong>Phone:</strong></td><td>${payload.phone ?? '—'}</td></tr>
            <tr><td><strong>Service Type:</strong></td><td>${label}</td></tr>
            <tr><td><strong>Submitted:</strong></td><td>${new Date().toLocaleString()}</td></tr>
          </table>
          <h3>Message</h3>
          <p style="white-space:pre-wrap;font-family:sans-serif;font-size:14px;">${payload.message ?? 'No message provided'}</p>
          <hr>
          <p style="font-size:12px;color:#666;">Review in the ForgeLine Admin dashboard under Service Requests.</p>
        `;
        break;
      }

      case 'retake_request': {
        subject = `Retake approval needed — ${payload.member_name ?? 'Team member'}`;
        recipients = (payload.admin_emails ?? []).filter(Boolean);
        if (recipients.length === 0) recipients = [notifyEmail];
        html = `
          <h2>Quiz Retake Approval Request</h2>
          <p>A team member has reached 3 failed quiz attempts and is requesting a retake.</p>
          <table style="font-family:sans-serif;font-size:14px;line-height:1.6;">
            <tr><td><strong>Member:</strong></td><td>${payload.member_name ?? 'Unknown'}</td></tr>
            <tr><td><strong>Email:</strong></td><td>${payload.member_email ?? '—'}</td></tr>
            <tr><td><strong>Course:</strong></td><td>${payload.course_title ?? 'Unknown'}</td></tr>
            <tr><td><strong>Lesson:</strong></td><td>${payload.lesson_title ?? 'Unknown'}</td></tr>
            <tr><td><strong>Failed Attempts:</strong></td><td>${payload.failed_attempts ?? 3}</td></tr>
          </table>
          <hr>
          <p style="font-family:sans-serif;font-size:14px;">
            Review and approve this request in the Company Admin dashboard under the Retakes tab.
          </p>
        `;
        break;
      }

      case 'retake_approved': {
        subject = `Your quiz retake has been approved — ${payload.lesson_title ?? 'Lesson'}`;
        recipients = [payload.member_email ?? notifyEmail].filter(Boolean) as string[];
        html = `
          <h2>Retake Approved</h2>
          <p>Hi ${payload.member_name ?? ''},</p>
          <p>Your request to retake the quiz for <strong>${payload.lesson_title ?? 'this lesson'}</strong> has been approved by your company admin.</p>
          <p>You can now return to the course and attempt the knowledge check again.</p>
          <hr>
          <p style="font-size:12px;color:#666;">Log in to ForgeLine Academy to continue your training.</p>
        `;
        break;
      }

      default:
        return new Response(JSON.stringify({ error: 'Unknown notification type' }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
    }

    const sent = await sendEmail(recipients, subject, html);

    return new Response(JSON.stringify({ success: true, email_sent: sent }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    console.error('[notify] Error:', e);
    return new Response(JSON.stringify({ success: false, error: 'Internal error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
