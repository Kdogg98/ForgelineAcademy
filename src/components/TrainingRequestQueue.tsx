import { useCallback, useEffect, useState } from 'react';
import { GraduationCap, Loader2, Paperclip } from 'lucide-react';
import {
  REQUEST_STATUSES, STATUS_TEXT, supabaseAccountsData, type AccountsDataSource, type RequestStatus, type TrainingRequest,
} from '@/lib/accountsData';
import { RequestStatusPill } from '@/components/manager/AccountsPanels';

/** Master admin queue of custom training requests from every company. */
export function TrainingRequestQueue({ ds = supabaseAccountsData }: { ds?: AccountsDataSource }) {
  const [rows, setRows] = useState<TrainingRequest[] | undefined | null>(null);
  const [filter, setFilter] = useState<RequestStatus | ''>('');
  const [notes, setNotes] = useState<Record<string, string>>({});
  const [msg, setMsg] = useState<string | null>(null);
  const load = useCallback(async () => { setRows(await ds.loadRequests(null)); }, [ds]);
  useEffect(() => { void load(); }, [load]);
  async function setStatus(r: TrainingRequest, status: RequestStatus) {
    const x = await ds.updateRequestStatus(r.id, status, notes[r.id] ?? r.admin_notes);
    setMsg(x.ok ? `“${r.topic}” → ${STATUS_TEXT[status]}` : x.error);
    void load();
  }
  if (rows === null) return <div className="py-10 flex justify-center"><Loader2 className="w-6 h-6 animate-spin text-accent-400" /></div>;
  if (rows === undefined) return <p className="text-sm text-steel-400">Training requests need migration 20261015120000.</p>;
  const shown = rows.filter((r) => !filter || r.status === filter);
  return (
    <div>
      <div className="flex flex-wrap items-center gap-2 mb-4">
        <h2 className="font-display text-xl font-bold text-white flex items-center gap-2"><GraduationCap className="w-5 h-5 text-accent-400" /> Custom training requests</h2>
        <div className="flex-1" />
        {(['', ...REQUEST_STATUSES] as const).map((s) => (
          <button key={s || 'all'} onClick={() => setFilter(s)} className={`text-xs px-2.5 py-1 rounded-full border ${filter === s ? 'border-accent-500 text-white bg-accent-500/15' : 'border-steel-600 text-steel-300'}`}>
            {s ? STATUS_TEXT[s] : 'All'} <span className="text-steel-500">{s ? rows.filter((r) => r.status === s).length : rows.length}</span>
          </button>
        ))}
      </div>
      {msg && <p className="mb-3 text-xs text-success-400">{msg}</p>}
      {shown.length === 0 ? <p className="text-sm text-steel-500 py-8 text-center">No requests.</p> : (
        <div className="space-y-3">
          {shown.map((r) => (
            <div key={r.id} className="rounded-xl border border-steel-700/60 bg-navy-800/40 p-4">
              <div className="flex flex-wrap items-start gap-2">
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-semibold text-white">{r.topic} <span className="text-steel-400 font-normal">· {r.companies?.name ?? 'Company'}</span></div>
                  <div className="text-[11px] text-steel-500">{new Date(r.created_at).toLocaleString()} · {r.worker_count ?? '?'} workers · {r.trades || 'any trade'} · {r.urgency} · {r.preferred_format.replace('_', '-')}{r.source === 'assistant' ? ' · drafted by AI assistant' : ''}</div>
                </div>
                <RequestStatusPill status={r.status} />
              </div>
              {r.details && <p className="mt-2 text-sm text-steel-300 whitespace-pre-wrap">{r.details}</p>}
              <div className="mt-2 flex flex-wrap gap-1">
                {[...r.topics, ...r.industries].map((t) => <span key={t} className="text-[10px] px-1.5 py-0.5 rounded bg-accent-500/10 text-accent-300">{t}</span>)}
                {r.equipment.map((t) => <span key={t} className="text-[10px] px-1.5 py-0.5 rounded bg-navy-800 text-steel-300">{t}</span>)}
                {r.research_ok && <span className="text-[10px] px-1.5 py-0.5 rounded bg-premium-500/10 text-premium-400">Research their company</span>}
              </div>
              {r.attachments.length > 0 && (
                <div className="mt-2 flex flex-wrap gap-2 text-xs">{r.attachments.map((a) => (
                  <button key={a} onClick={async () => { const u = await ds.fileUrl(a); if (u) window.open(u, '_blank', 'noopener'); }} className="flex items-center gap-1 text-accent-300"><Paperclip className="w-3 h-3" />{a.split('/').pop()}</button>
                ))}</div>
              )}
              <div className="mt-3 flex flex-col sm:flex-row gap-2">
                <input className="input flex-1 text-xs" placeholder="Kris notes (visible to ForgeLine only)" value={notes[r.id] ?? r.admin_notes ?? ''} onChange={(e) => setNotes({ ...notes, [r.id]: e.target.value })} />
                <select aria-label="Status" className="input text-xs" value={r.status} onChange={(e) => void setStatus(r, e.target.value as RequestStatus)}>
                  {REQUEST_STATUSES.map((s) => <option key={s} value={s}>{STATUS_TEXT[s]}</option>)}
                </select>
                <button onClick={() => void setStatus(r, r.status)} className="btn-secondary text-xs px-3">Save notes</button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
