import { useEffect, useState } from 'react';
import { Briefcase } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { TRADE_PRESETS, type MemberDetails, type Placement } from '@/lib/accountsData';

/** Learner view: the employee's own trade, placement and contract (read-only, trade editable if the company allows). */
export function MyPlacement({ userId, companyId }: { userId?: string; companyId?: string | null }) {
  const [d, setD] = useState<MemberDetails | null>(null);
  const [p, setP] = useState<Placement | null>(null);
  const [allow, setAllow] = useState(false);
  const [trade, setTrade] = useState('');
  const [saved, setSaved] = useState(false);
  useEffect(() => {
    if (!userId || !companyId) return;
    void (async () => {
      const [det, co] = await Promise.all([
        supabase.from('company_member_details').select('*').eq('user_id', userId).eq('company_id', companyId).maybeSingle(),
        supabase.from('companies').select('allow_employee_self_trade').eq('id', companyId).maybeSingle(),
      ]);
      if (det.error) return; // migration not applied
      const row = det.data as (MemberDetails | null);
      setD(row); setTrade(row?.trade ?? '');
      setAllow(!!(co.data as { allow_employee_self_trade?: boolean } | null)?.allow_employee_self_trade);
      if (row?.placement_id) {
        const pl = await supabase.from('company_placements').select('*').eq('id', row.placement_id).maybeSingle();
        setP((pl.data as Placement | null) ?? null);
      }
    })();
  }, [userId, companyId]);
  if (!d && !allow) return null;
  const fmt = (x: string | null) => (x ? new Date(x + 'T12:00:00').toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' }) : '—');
  return (
    <div className="card p-4 mb-6">
      <h2 className="font-display text-base font-semibold text-white flex items-center gap-2 mb-2"><Briefcase className="w-4 h-4 text-accent-400" /> My placement</h2>
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm">
        <div><div className="text-[10px] uppercase text-steel-500">Trade</div>
          {allow ? (
            <div className="flex gap-1"><select className="input text-xs py-1" value={trade} onChange={(e) => { setTrade(e.target.value); setSaved(false); }}><option value="">Not set</option>{TRADE_PRESETS.concat(trade && !TRADE_PRESETS.includes(trade) ? [trade] : []).map((t) => <option key={t}>{t}</option>)}</select>
              <button className="text-xs text-accent-300" onClick={async () => { const { error } = await supabase.rpc('set_my_trade', { p_trade: trade }); setSaved(!error); }}>{saved ? 'Saved' : 'Save'}</button></div>
          ) : <div className="text-white">{d?.trade ?? '—'}</div>}
        </div>
        <div><div className="text-[10px] uppercase text-steel-500">Client / site</div><div className="text-white">{p?.client_name ?? '—'}</div><div className="text-[11px] text-steel-400">{d?.site_location || p?.location || ''}</div></div>
        <div><div className="text-[10px] uppercase text-steel-500">Contract</div><div className="text-white">{d?.contract_name ?? '—'}</div><div className="text-[11px] text-steel-400">{d?.contract_number ?? ''}</div></div>
        <div><div className="text-[10px] uppercase text-steel-500">Dates · shift</div><div className="text-white">{fmt(d?.contract_start ?? null)} – {fmt(d?.contract_end ?? null)}</div><div className="text-[11px] text-steel-400">{d?.shift ?? ''}{d?.supervisor_name ? ` · Supervisor: ${d.supervisor_name}` : ''}</div></div>
      </div>
    </div>
  );
}
