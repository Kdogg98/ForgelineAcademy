import { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { supabaseAccountsData, type AssignmentProposal, type TeamMember } from '@/lib/accountsData';
import { supabaseManagerData } from '@/lib/managerData';
import { ManagerAssistant } from '@/components/manager/AccountsPanels';

export const TRAINING_DRAFT_KEY = 'fl-training-draft';

/** Manager Assistant inside the AI Tutor panel (owners/admins/supervisors). */
export function ManagerAssistantLoader({ companyId, onOpenRequest }: { companyId: string; onOpenRequest?: () => void }) {
  const [team, setTeam] = useState<TeamMember[] | null | undefined>(null);
  const [titles, setTitles] = useState<Record<string, string>>({});
  const [msg, setMsg] = useState<{ ok: boolean; text: string } | null>(null);
  useEffect(() => {
    void (async () => {
      const [t, c] = await Promise.all([supabaseAccountsData.loadTeam(companyId).catch(() => undefined), supabase.from('courses').select('id, title')]);
      setTitles(Object.fromEntries(((c.data ?? []) as { id: string; title: string }[]).map((x) => [x.id, x.title])));
      setTeam(t);
    })();
  }, [companyId]);
  async function confirm(ps: AssignmentProposal[]) {
    for (const p of ps) {
      const r = await supabaseManagerData.assignCourse(companyId, p.course_id, p.user_id, p.due_date);
      if (!r.ok) { setMsg({ ok: false, text: r.error }); return false; }
    }
    setMsg({ ok: true, text: `Assigned ${ps.length} course${ps.length === 1 ? '' : 's'}.` });
    return true;
  }
  if (team === null) return <div className="p-6 flex justify-center"><Loader2 className="w-5 h-5 animate-spin text-accent-400" /></div>;
  if (team === undefined) return <p className="p-4 text-sm text-steel-400">The Manager Assistant is not switched on yet.</p>;
  return (
    <div className="flex flex-col flex-1 min-h-0">
      {msg && <p role="status" className={`mb-2 text-xs ${msg.ok ? 'text-success-400' : 'text-error-400'}`}>{msg.text}</p>}
      <ManagerAssistant embedded ds={supabaseAccountsData} companyId={companyId} team={team} courseTitles={titles} onConfirmAssignments={confirm}
        onUseDraft={(d) => {
          // Hand the draft to the dashboard's Custom training form (was a dead end: text only).
          try { sessionStorage.setItem(TRAINING_DRAFT_KEY, JSON.stringify(d)); } catch { /* private mode */ }
          if (onOpenRequest) onOpenRequest(); else window.location.assign('/dashboard?tab=training');
        }} />
    </div>
  );
}
