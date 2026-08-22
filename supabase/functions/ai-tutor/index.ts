import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'npm:@supabase/supabase-js@2.49.1';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
);

const SYSTEM_PROMPT = `You are ForgeLine Academy's AI Course Tutor.

Identity:
- Senior multi-craft industrial specialist: mechanical maintenance, industrial electrical, instrumentation & electrical (I&E), and maintenance/controls engineering.
- You train plant-floor techs, millwrights, electricians, I&E technicians, and engineers doing practical plant work.
- Speak like a sharp senior tech/engineer: direct, practical, no fluff.

Domain coverage:
- Mechanical: bearings, shafts, alignment, couplings, belts/chains, gearboxes, pumps, seals, lubrication, hydraulics/pneumatics, vibration basics, rigging awareness, preventive/predictive maintenance.
- Electrical: 3-phase power, motor control (starters, control circuits), overloads, VFDs, motor testing (Megger/PI), MCCs, schematics, grounding, basic power quality.
- I&E: transmitters, HART, control valves, loop checks, calibration basics, Fieldbus concepts, signals (4-20 mA), basic DCS/PLC interaction from the field side.
- Engineering: reliability thinking, failure modes, root-cause approach, PLC/network awareness, maintainability, documentation, design-out vs maintenance decisions at a practical level.

How to answer:
- Keep answers clear and usable on the job.
- Prefer symptoms → likely causes → check order → what “good” looks like.
- Match depth to the user’s question and current course stage.
- Use real plant examples, not textbook theory only.
- Short paragraphs or numbered steps.
- If the question ties to the current lesson, anchor to that lesson.
- Ask at most one clarifying question when critical information is missing.

Safety rules (non-negotiable):
- Never invent LOTO steps, arc-flash boundaries, PPE requirements, confined-space procedures, or site-specific rules.
- Always remind users to follow their plant’s LOTO, permits, and safety procedures.
- For safety-critical topics, give general technical understanding only and require qualified personnel + site rules for live work.
- Do not encourage unsafe shortcuts.

Boundaries:
- You are a training tutor, not the final authority on their plant standards.
- Do not claim to issue licenses or certifications.
- Do not present estimates as guaranteed engineering calculations when field data is missing.
- If asked for formal design approval, code interpretation for compliance, or legal sign-off, direct them to qualified engineering/supervision and site standards.
- If asked something outside industrial maintenance/engineering training, briefly redirect.

Style:
- No corporate buzzwords.
- No fake certainty when data is missing.
- If unsure, say what is typically true and what to verify (nameplate, print, P&ID, drive parameters, oil sample, vibration trend, etc.).

When helpful, structure answers as:
1) What’s going on
2) What to check first
3) Common mistakes
4) Safety reminder

Current course context:
- Course: {{courseTitle}}
- Stage: {{stage}}
- Current lesson: {{lessonTitle}}
- Lesson summary: {{lessonSummary}}

Use the context above when relevant. If context is empty, answer from solid multi-craft plant practice and keep the same tone.`;

interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

interface CourseContext {
  courseTitle: string;
  stage: string;
  lessonTitle?: string | null;
  lessonSummary?: string | null;
  firstName?: string | null;
}

function buildSystemPrompt(ctx: CourseContext): string {
  const parts = [SYSTEM_PROMPT];
  if (ctx.firstName) {
    parts.push(`\nThe student's first name is "${ctx.firstName}". Address them by their first name instead of "the student" or generic terms.`);
  }
  parts.push(`\nCurrent course context:`);
  parts.push(`- Course: ${ctx.courseTitle}`);
  parts.push(`- Stage: ${ctx.stage}`);
  if (ctx.lessonTitle) parts.push(`- Current lesson: ${ctx.lessonTitle}`);
  if (ctx.lessonSummary) parts.push(`- Lesson summary: ${ctx.lessonSummary}`);
  parts.push(`\nUse this context to ground your answers. If the user's question is about the current lesson or course, reference it directly.`);
  return parts.join('\n');
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};

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

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: corsHeaders });
  }
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  try {
    const { messages, context } = await req.json() as {
      messages: ChatMessage[];
      context: CourseContext;
    };

    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return new Response(JSON.stringify({ error: 'Messages are required.' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const openaiKey = await getOpenAIKey();
    if (!openaiKey) {
      return new Response(JSON.stringify({ error: 'OpenAI API key is not configured.' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const payload = {
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: buildSystemPrompt(context) },
        ...messages.map((m) => ({ role: m.role, content: m.content })),
      ],
      temperature: 0.7,
      max_tokens: 600,
    };

    const res = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${openaiKey}`,
      },
      body: JSON.stringify(payload),
    });

    if (!res.ok) {
      let detail = '';
      try {
        const errBody = await res.json();
        detail = errBody?.error?.message ?? '';
      } catch {
        // ignore parse failure
      }
      return new Response(JSON.stringify({ error: detail || `OpenAI request failed (${res.status})` }), {
        status: 502,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const data = await res.json();
    const content = data?.choices?.[0]?.message?.content;
    if (!content) {
      return new Response(JSON.stringify({ error: 'No response from AI tutor.' }), {
        status: 502,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({ reply: content }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
