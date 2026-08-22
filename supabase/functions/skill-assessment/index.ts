import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'npm:@supabase/supabase-js@2.49.1';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
);

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

interface MCQuestion {
  question: string;
  options: string[];
  correctIndex: number;
  area: 'mechanical' | 'electrical' | 'ie' | 'engineering';
  topic: string;
}

interface AnswerRecord {
  questionIndex: number;
  selectedIndex: number;
  correct: boolean;
}

const QUESTION_PLAN = `Generate exactly 20 multiple-choice questions covering ALL FOUR industrial maintenance areas. Follow this distribution strictly — 5 questions per area:

- Mechanical (5 questions): 3 topics — bearings/lubrication, pumps/seals/alignment, hydraulics/pneumatics
- Electrical (5 questions): 3 topics — motor control/starters/overloads, VFDs/3-phase, motor testing/schematics
- I&E (5 questions): 3 topics — 4-20mA/transmitters/HART, control valves/loop checks/calibration, Fieldbus/DCS basics
- Engineering (5 questions): 3 topics — troubleshooting method/reliability, PLC-controls awareness, documentation/maintainability

For EACH question:
- "question": clear, practical plant-floor question
- "options": array of EXACTLY 6 strings — 1 correct, 5 plausible wrong answers (common mistakes, not jokes)
- "correctIndex": 0-5, the index of the correct answer in options
- "area": "mechanical" | "electrical" | "ie" | "engineering"
- "topic": short topic label (e.g. "bearings", "vfd", "transmitters")

Mix difficulty: some entry-level, some intermediate, some advanced. Make wrong answers realistic plant-floor distractors.

Return ONLY a JSON object: { "questions": [ ... ] }`;

const EVAL_PROMPT = `You are evaluating a student's skill assessment. You receive their score and per-area breakdown.

Produce a JSON object with EXACTLY these fields:
{
  "level": "novice" | "intermediate" | "advanced" | "expert",
  "summary": "2-3 sentence plain-English summary of strengths, gaps, and overall profile",
  "recommendations": "Which stages/paths to start with and why, across all four areas",
  "recommended_stage": "mechanical" | "electrical" | "ie" | "engineering",
  "areas": {
    "mechanical": { "level": "novice"|"intermediate"|"advanced"|"expert", "note": "1 sentence" },
    "electrical": { "level": "novice"|"intermediate"|"advanced"|"expert", "note": "1 sentence" },
    "ie": { "level": "novice"|"intermediate"|"advanced"|"expert", "note": "1 sentence" },
    "engineering": { "level": "novice"|"intermediate"|"advanced"|"expert", "note": "1 sentence" }
  }
}

Level criteria:
- novice: 0-33% correct. Little to no hands-on experience.
- intermediate: 34-66% correct. Some experience, gaps in several areas.
- advanced: 67-83% correct. Strong across multiple disciplines.
- expert: 84-100% correct. Deep cross-disciplinary expertise.

Per-area level: use the same criteria applied to that area's questions only.
"recommended_stage": the area where they should START — typically their weakest area that has free courses (mechanical or electrical), or next logical step up.

Return ONLY valid JSON. No markdown, no commentary.`;

async function callOpenAI(openaiKey: string, messages: Array<{ role: string; content: string }>, jsonMode: boolean, maxTokens: number): Promise<string> {
  const payload: Record<string, unknown> = {
    model: 'gpt-4o-mini',
    messages,
    temperature: 0.7,
    max_tokens: maxTokens,
  };
  if (jsonMode) {
    payload.response_format = { type: 'json_object' };
    payload.temperature = 0.3;
  }

  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${openaiKey}` },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    let detail = '';
    try { const errBody = await res.json(); detail = errBody?.error?.message ?? ''; } catch { /* ignore */ }
    throw new Error(detail || `OpenAI request failed (${res.status})`);
  }

  const data = await res.json();
  const content = data?.choices?.[0]?.message?.content;
  if (!content) throw new Error('No response from OpenAI.');
  return content;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: corsHeaders });
  }
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  try {
    const body = await req.json() as {
      action: 'generate' | 'evaluate';
      questions?: MCQuestion[];
      answers?: AnswerRecord[];
    };

    if (!body.action) {
      return new Response(JSON.stringify({ error: 'Action is required (generate or evaluate).' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const openaiKey = await getOpenAIKey();
    if (!openaiKey) {
      return new Response(JSON.stringify({ error: 'OpenAI API key is not configured.' }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (body.action === 'generate') {
      const content = await callOpenAI(
        openaiKey,
        [
          { role: 'system', content: 'You are an industrial maintenance assessment generator. Return only valid JSON.' },
          { role: 'user', content: QUESTION_PLAN },
        ],
        true,
        6000,
      );

      let parsed: { questions?: MCQuestion[] };
      try {
        parsed = JSON.parse(content);
      } catch {
        return new Response(JSON.stringify({ error: 'Failed to parse generated questions.' }), {
          status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      const questions = parsed.questions;
      if (!questions || !Array.isArray(questions) || questions.length === 0) {
        return new Response(JSON.stringify({ error: 'No questions generated.' }), {
          status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      // Validate: each question must have 6 options and correctIndex 0-5
      const validated = questions.filter((q) =>
        q.question && Array.isArray(q.options) && q.options.length === 6 &&
        typeof q.correctIndex === 'number' && q.correctIndex >= 0 && q.correctIndex <= 5 &&
        q.area
      );

      if (validated.length === 0) {
        return new Response(JSON.stringify({ error: 'Generated questions failed validation.' }), {
          status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      return new Response(JSON.stringify({ questions: validated }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (body.action === 'evaluate') {
      const questions = body.questions ?? [];
      const answers = body.answers ?? [];

      if (questions.length === 0 || answers.length === 0) {
        return new Response(JSON.stringify({ error: 'Questions and answers are required for evaluation.' }), {
          status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      // Score locally
      let correctCount = 0;
      const areaStats: Record<string, { correct: number; total: number }> = {
        mechanical: { correct: 0, total: 0 },
        electrical: { correct: 0, total: 0 },
        ie: { correct: 0, total: 0 },
        engineering: { correct: 0, total: 0 },
      };

      for (const ans of answers) {
        const q = questions[ans.questionIndex];
        if (!q) continue;
        const isCorrect = ans.selectedIndex === q.correctIndex;
        if (isCorrect) correctCount++;
        if (areaStats[q.area]) {
          areaStats[q.area].total++;
          if (isCorrect) areaStats[q.area].correct++;
        }
      }

      const totalQuestions = questions.length;
      const scorePct = Math.round((correctCount / totalQuestions) * 100);

      // Build evaluation prompt with score data
      const evalInput = `Score: ${correctCount}/${totalQuestions} (${scorePct}%)

Per-area breakdown:
- Mechanical: ${areaStats.mechanical.correct}/${areaStats.mechanical.total} correct
- Electrical: ${areaStats.electrical.correct}/${areaStats.electrical.total} correct
- I&E: ${areaStats.ie.correct}/${areaStats.ie.total} correct
- Engineering: ${areaStats.engineering.correct}/${areaStats.engineering.total} correct

Evaluate and return the JSON object.`;

      const content = await callOpenAI(
        openaiKey,
        [
          { role: 'system', content: EVAL_PROMPT },
          { role: 'user', content: evalInput },
        ],
        true,
        800,
      );

      let evaluation;
      try {
        evaluation = JSON.parse(content);
      } catch {
        return new Response(JSON.stringify({ error: 'Failed to parse evaluation.' }), {
          status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      return new Response(JSON.stringify({
        evaluation,
        score: correctCount,
        totalQuestions,
        areaStats,
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({ error: 'Unknown action.' }), {
      status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
