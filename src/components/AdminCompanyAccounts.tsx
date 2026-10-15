import { useCallback, useEffect, useState } from 'react';
import { ChevronDown, ChevronRight, Factory, Loader2, MapPin } from 'lucide-react';
import {
  ROLE_LABEL, normRole, supabaseAccountsData, type AccountsDataSource, type BaseRole, type CompanyRole, type Placement,
  type TeamMember, type TrainingProfile,
} from '@/lib/accountsData';
import { EmployeeEditPanel, memberName } from '@/components/manager/AccountsPanels';

/** Master admin: a company's people (roles, trades, placements) + training profile. */
export function AdminCompanyAccounts({ companyId, ds = supabaseAccountsData, defaultOpen = false, onMessage }: {
  companyId: string; ds?: AccountsDataSource; defaultOpen?: boolean; onMessage?: (ok: boolean, m: string) => void;
}) {
  const [open, setOpen] = useState(defaultOpen);
  const [team, setTeam] = useState<TeamMember[] | undefined | null>(null);
  const [roles, setRoles] = useState<CompanyRole[]>([]);
  const [placements, setPlacements] = useState<Placement[]>([]);
  const [profile, setProfile] = useState<TrainingProfile | null>(null);
  const [edit, setEdit] = useState<string | null>(null);
  const load = useCallback(async () => {
    const t = await ds.loadTeam(companyId).catch(() => undefined);
    setTeam(t);
    if (t) {
      const [r, p, pr] = await Promise.all([ds.loadRoles(companyId), ds.loadPlacements(companyId), ds.loadProfile(companyId)]);
      setRoles(r ?? []); setPlacements(p ?? []); setProfile(pr ?? null);
    }
  }, [companyId, ds]);
  useEffect(() => { if (open) void load(); }, [open, load]);
  const pl = new Map(placements.map((p) => [p.id, p]));
  const em = edit && team ? team.find((m) => m.user_id === edit) : null;
  return (
    <div className="mt-3 pt-3 border-t border-steel-700/40">
      <button onClick={() => setOpen((v) => !v)} className="flex items-center gap-1.5 text-xs font-semibold text-accent-300">
        {open ? <ChevronDown className="w-3.5 h-3.5" /> : <ChevronRight className="w-3.5 h-3.5" />} People, roles, placements & training profile
      </button>
      {open && (team === null ? <Loader2 className="w-4 h-4 mt-2 animate-spin text-accent-400" /> : team === undefined ? (
        <p className="mt-2 text-xs text-steel-500">Company accounts v3 migration not applied yet.</p>
      ) : (
        <div className="mt-3 grid lg:grid-cols-[1fr_18rem] gap-4">
          <div className="space-y-1">
            {team.map((m) => (
              <div key={m.user_id} className="flex flex-wrap items-center gap-2 rounded border border-steel-700/40 bg-navy-950/30 px-2.5 py-1.5 text-xs">
                <span className="flex-1 min-w-[10rem] text-white truncate">{memberName(m)} <span className="text-steel-500">{m.email}</span></span>
                <select aria-label={`Role for ${memberName(m)}`} className="input text-xs py-1" value={normRole(m.role)}
                  onChange={async (e) => { const r = await ds.setRole(companyId, m.user_id, e.target.value as BaseRole, null); onMessage?.(r.ok, r.ok ? 'Role updated.' : r.error); void load(); }}>
                  {(['owner', 'admin', 'supervisor', 'employee'] as BaseRole[]).map((r) => <option key={r} value={r}>{ROLE_LABEL[r]}</option>)}
                </select>
                <span className="text-steel-300 w-24 truncate">{m.custom_role ?? ''} {m.details?.trade ?? ''}</span>
                <span className="text-steel-400 w-32 truncate">{pl.get(m.details?.placement_id ?? '')?.client_name ?? '—'}</span>
                <button onClick={() => setEdit(m.user_id)} className="text-accent-300">Edit</button>
              </div>
            ))}
          </div>
          <div className="space-y-3 text-xs">
            <div className="rounded border border-steel-700/50 p-3">
              <div className="font-semibold text-white flex items-center gap-1.5 mb-1"><Factory className="w-3.5 h-3.5 text-accent-400" /> Training profile</div>
              {profile ? (<>
                <div className="text-steel-300">Industry: {profile.industries.join(', ') || '—'}</div>
                <div className="text-steel-300">Equipment: {[...profile.equipment, profile.equipment_notes].filter(Boolean).join(', ') || '—'}</div>
                {profile.plant_details && <div className="text-steel-400 mt-1 whitespace-pre-wrap">{profile.plant_details}</div>}
                {profile.research_ok && <div className="mt-1 text-premium-400 font-semibold">Wants ForgeLine to research and tailor</div>}
              </>) : <div className="text-steel-500">Not filled in.</div>}
            </div>
            <div className="rounded border border-steel-700/50 p-3">
              <div className="font-semibold text-white flex items-center gap-1.5 mb-1"><MapPin className="w-3.5 h-3.5 text-accent-400" /> Client sites ({placements.length})</div>
              {placements.map((p) => <div key={p.id} className="text-steel-300">{p.client_name} <span className="text-steel-500">· {p.industry.join(', ')}{p.research_ok ? ' · research' : ''}</span></div>)}
            </div>
          </div>
        </div>
      ))}
      {em && team && (
        <EmployeeEditPanel member={em} team={team} placements={placements} roles={roles} trades={[]} currentUserId="" callerRole="owner" isPlatformAdmin
          onClose={() => setEdit(null)}
          onSaveRole={async (r, c) => { const x = await ds.setRole(companyId, em.user_id, r, c); onMessage?.(x.ok, x.ok ? 'Role updated.' : x.error); await load(); return x.ok; }}
          onSaveDetails={async (d) => { const x = await ds.saveDetails(companyId, em.user_id, d); onMessage?.(x.ok, x.ok ? 'Saved.' : x.error); await load(); return x.ok; }} />
      )}
    </div>
  );
}
