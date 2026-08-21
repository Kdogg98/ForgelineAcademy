import { useCallback, useEffect, useState } from 'react';
import {
  Building2,
  Plus,
  X,
  Loader2,
  CheckCircle2,
  AlertCircle,
  Crown,
  Users,
  Trash2,
  Settings,
  UserPlus,
  ChevronRight,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';
import type { Company } from '@/lib/types';
import type { Route } from '@/components/Nav';

interface CompanyStat extends Company {
  member_count?: number;
  owner_email?: string | null;
}

interface CompanyManagerProps {
  onNavigate: (r: Route) => void;
}

export function CompanyManager({ onNavigate }: CompanyManagerProps) {
  const [companies, setCompanies] = useState<CompanyStat[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [newName, setNewName] = useState('');
  const [newOwnerEmail, setNewOwnerEmail] = useState('');
  const [creating, setCreating] = useState(false);
  // Per-company add member state
  const [addMemberForCompany, setAddMemberForCompany] = useState<string | null>(null);
  const [memberEmail, setMemberEmail] = useState('');
  const [memberRole, setMemberRole] = useState<'member' | 'admin' | 'owner'>('member');
  const [addingMember, setAddingMember] = useState(false);

  const loadCompanies = useCallback(async () => {
    setLoading(true);
    try {
      const { data, error: rpcErr } = await supabase.rpc('get_all_companies_with_stats');
      if (rpcErr) throw rpcErr;
      setCompanies((data as CompanyStat[]) ?? []);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load companies');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { void loadCompanies(); }, [loadCompanies]);
  useEffect(() => { if (error) { const t = setTimeout(() => setError(null), 5000); return () => clearTimeout(t); } }, [error]);
  useEffect(() => { if (success) { const t = setTimeout(() => setSuccess(null), 5000); return () => clearTimeout(t); } }, [success]);

  async function handleCreate() {
    if (!newName.trim()) return;
    setCreating(true);
    setError(null);
    try {
      const { data, error: rpcErr } = await supabase.rpc('create_company_with_owner', {
        company_name: newName.trim(),
        owner_email: newOwnerEmail.trim() || null,
      });
      if (rpcErr) throw rpcErr;
      const result = data as { success: boolean; company_id?: string; error?: string };
      if (!result?.success) { setError(result?.error ?? 'Failed to create company'); return; }
      setSuccess(`Company "${newName.trim()}" created.`);
      setNewName('');
      setNewOwnerEmail('');
      setShowCreate(false);
      await loadCompanies();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to create company');
    } finally {
      setCreating(false);
    }
  }

  async function handleTogglePremium(companyId: string, currentPremium: boolean) {
    setError(null);
    try {
      const { error: updateErr } = await supabase.from('companies').update({ premium: !currentPremium }).eq('id', companyId);
      if (updateErr) throw updateErr;
      setSuccess(`Premium ${!currentPremium ? 'enabled' : 'disabled'} for company.`);
      await loadCompanies();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to update company');
    }
  }

  async function handleDelete(companyId: string, companyName: string) {
    if (!confirm(`Delete company "${companyName}"? This will remove all member associations.`)) return;
    setError(null);
    try {
      const { error: delErr } = await supabase.from('companies').delete().eq('id', companyId);
      if (delErr) throw delErr;
      setSuccess('Company deleted.');
      await loadCompanies();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to delete company');
    }
  }

  async function handleAddMember(companyId: string) {
    if (!memberEmail.trim()) return;
    setAddingMember(true);
    setError(null);
    try {
      const { data, error: rpcErr } = await supabase.rpc('add_company_member_by_email', {
        target_company_id: companyId,
        member_email: memberEmail.trim(),
        member_role: memberRole,
      });
      if (rpcErr) throw rpcErr;
      const result = data as { success: boolean; error?: string };
      if (!result?.success) { setError(result?.error ?? 'Failed to add member'); return; }
      setSuccess(`Member added to company.`);
      setMemberEmail('');
      setMemberRole('member');
      setAddMemberForCompany(null);
      await loadCompanies();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to add member');
    } finally {
      setAddingMember(false);
    }
  }

  return (
    <div>
      {error && (
        <div className="mb-4 flex items-start gap-3 p-4 rounded-lg bg-error-500/10 border border-error-500/30">
          <AlertCircle className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5" />
          <p className="text-sm text-error-300">{error}</p>
          <button onClick={() => setError(null)} className="ml-auto text-error-400 hover:text-error-300"><X className="w-4 h-4" /></button>
        </div>
      )}
      {success && (
        <div className="mb-4 flex items-start gap-3 p-4 rounded-lg bg-success-500/10 border border-success-500/30">
          <CheckCircle2 className="w-5 h-5 text-success-400 flex-shrink-0 mt-0.5" />
          <p className="text-sm text-success-300">{success}</p>
        </div>
      )}

      <div className="flex items-center justify-between mb-4">
        <div>
          <h2 className="text-lg font-bold text-white">Companies & Teams</h2>
          <p className="text-sm text-steel-400">Create companies, assign owners, add members, and track progress.</p>
        </div>
        <button onClick={() => setShowCreate(!showCreate)} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-accent-500/10 border border-accent-500/30 text-accent-300 hover:bg-accent-500/20 transition-colors text-sm font-medium">
          <Plus className="w-4 h-4" /> New Company
        </button>
      </div>

      {showCreate && (
        <div className="mb-4 p-4 rounded-lg bg-navy-950/40 border border-steel-700/40">
          <div className="space-y-3">
            <div>
              <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">Company Name</label>
              <input value={newName} onChange={(e) => setNewName(e.target.value)} placeholder="Acme Industrial Co." className="input" autoFocus />
            </div>
            <div>
              <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">Owner Email (optional)</label>
              <input type="email" value={newOwnerEmail} onChange={(e) => setNewOwnerEmail(e.target.value)} placeholder="owner@acme.com" className="input" />
              <p className="text-[11px] text-steel-500 mt-1.5">The owner must already have a ForgeLine account. They'll be made company owner automatically.</p>
            </div>
            <div className="flex gap-2">
              <button onClick={handleCreate} disabled={creating} className="btn-primary text-sm px-4">
                {creating ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Create Company'}
              </button>
              <button onClick={() => { setShowCreate(false); setNewName(''); setNewOwnerEmail(''); }} className="btn-ghost text-sm">Cancel</button>
            </div>
          </div>
        </div>
      )}

      {loading ? (
        <div className="flex items-center justify-center py-10"><Loader2 className="w-6 h-6 text-accent-400 animate-spin" /></div>
      ) : companies.length === 0 ? (
        <div className="text-center py-10">
          <Building2 className="w-10 h-10 text-steel-600 mx-auto mb-3" />
          <p className="text-sm text-steel-500">No companies yet. Create one to get started.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {companies.map((c) => (
            <div key={c.id} className="rounded-xl border border-steel-700/60 bg-navy-800/40 p-4">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-lg border border-steel-700/60 bg-navy-950/60 flex items-center justify-center overflow-hidden shrink-0">
                  {c.logo_url ? <img src={c.logo_url} alt={c.name} className="w-full h-full object-contain p-1" /> : <Building2 className="w-5 h-5 text-steel-600" />}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="text-sm font-semibold text-white">{c.name}</span>
                    {c.premium && (
                      <span className="flex items-center gap-1 text-[10px] px-1.5 py-0.5 rounded-full bg-premium-500/15 border border-premium-500/30 text-premium-400 font-semibold">
                        <Crown className="w-3 h-3" /> Premium
                      </span>
                    )}
                    {!c.active && (
                      <span className="text-[10px] px-1.5 py-0.5 rounded-full bg-error-500/15 border border-error-500/30 text-error-400 font-semibold">Inactive</span>
                    )}
                  </div>
                  <div className="flex items-center gap-4 mt-1 text-xs text-steel-500">
                    <span className="flex items-center gap-1"><Users className="w-3 h-3" />{c.member_count ?? 0} members</span>
                    {c.owner_email && <span className="truncate">Owner: {c.owner_email}</span>}
                  </div>
                </div>
                <div className="flex items-center gap-1.5 shrink-0">
                  <button
                    onClick={() => onNavigate({ name: 'company', companyId: c.id })}
                    className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-rok-500/10 border border-rok-500/30 text-rok-300 hover:bg-rok-500/20 transition-colors text-xs font-medium"
                  >
                    <Settings className="w-3.5 h-3.5" /> Manage
                  </button>
                  <button
                    onClick={() => setAddMemberForCompany(addMemberForCompany === c.id ? null : c.id)}
                    className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-accent-400 hover:border-accent-500/40 transition-colors text-xs font-medium"
                  >
                    <UserPlus className="w-3.5 h-3.5" /> Add
                  </button>
                  <button
                    onClick={() => handleTogglePremium(c.id, c.premium)}
                    className={`px-2.5 py-1.5 rounded-lg text-xs font-medium border transition-colors ${
                      c.premium ? 'bg-premium-500/10 border-premium-500/30 text-premium-400 hover:bg-premium-500/20'
                      : 'bg-navy-800/60 border-steel-700/40 text-steel-400 hover:text-premium-400 hover:border-premium-500/40'
                    }`}
                  >
                    {c.premium ? 'Revoke' : 'Grant Premium'}
                  </button>
                  <button onClick={() => handleDelete(c.id, c.name)} className="p-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-error-400 hover:border-error-500/40 transition-colors" title="Delete company">
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>

              {addMemberForCompany === c.id && (
                <div className="mt-3 pt-3 border-t border-steel-700/40">
                  <div className="flex flex-col sm:flex-row gap-2">
                    <input type="email" value={memberEmail} onChange={(e) => setMemberEmail(e.target.value)} placeholder="employee@company.com" className="input flex-1" autoFocus />
                    <select value={memberRole} onChange={(e) => setMemberRole(e.target.value as 'member' | 'admin' | 'owner')} className="input sm:w-32">
                      <option value="member">Member</option>
                      <option value="admin">Admin</option>
                      <option value="owner">Owner</option>
                    </select>
                    <button onClick={() => handleAddMember(c.id)} disabled={addingMember} className="btn-primary text-sm px-4">
                      {addingMember ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Add Member'}
                    </button>
                    <button onClick={() => { setAddMemberForCompany(null); setMemberEmail(''); }} className="btn-ghost text-sm">Cancel</button>
                  </div>
                  <p className="text-[11px] text-steel-500 mt-2">The person must already have a ForgeLine account with that email.</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
