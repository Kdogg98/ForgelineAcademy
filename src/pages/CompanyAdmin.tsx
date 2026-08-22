import { useCallback, useEffect, useState } from 'react';
import {
  Building2,
  Upload,
  Trash2,
  UserPlus,
  X,
  Loader2,
  CheckCircle2,
  AlertCircle,
  Users,
  Crown,
  Shield,
  ChevronDown,
  ArrowLeft,
  Settings,
  BarChart3,
  BookOpen,
  Award,
  Clock,
  ChevronRight,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/lib/auth';
import type { Company, RetakeRequest, MemberQuizAttempt } from '@/lib/types';
import type { Route } from '@/components/Nav';

interface MemberRow {
  member_id: string;
  user_id: string;
  role: 'owner' | 'admin' | 'member';
  created_at: string;
  email: string | null;
  full_name: string | null;
}

interface ProgressRow {
  user_id: string;
  email: string | null;
  full_name: string | null;
  role: 'owner' | 'admin' | 'member';
  lessons_completed: number;
  courses_started: number;
  certificates_count: number;
  last_activity: string | null;
}

interface LessonProgressRow {
  progress_id: string;
  lesson_id: string;
  course_id: string;
  course_title: string | null;
  lesson_title: string | null;
  completed: boolean;
  quiz_score: number | null;
  completed_at: string | null;
}

interface CompanyAdminProps {
  onNavigate: (r: Route) => void;
  companyId?: string;
}

export function CompanyAdmin({ onNavigate, companyId }: CompanyAdminProps) {
  const { user, company: userCompany, companyRole, isCompanyAdmin, isAdmin, refreshPremium } = useAuth();
  const [activeTab, setActiveTab] = useState<'settings' | 'members' | 'progress' | 'retakes'>('settings');
  const [selectedCompany, setSelectedCompany] = useState<Company | null>(null);
  const [allCompanies, setAllCompanies] = useState<Company[]>([]);
  const [members, setMembers] = useState<MemberRow[]>([]);
  const [progressData, setProgressData] = useState<ProgressRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const [showAddMember, setShowAddMember] = useState(false);
  const [newMemberEmail, setNewMemberEmail] = useState('');
  const [newMemberRole, setNewMemberRole] = useState<'member' | 'admin' | 'owner'>('member');
  const [editingName, setEditingName] = useState(false);
  const [companyName, setCompanyName] = useState('');
  const [expandedMember, setExpandedMember] = useState<string | null>(null);
  const [memberDetail, setMemberDetail] = useState<LessonProgressRow[] | null>(null);
  const [memberDetailLoading, setMemberDetailLoading] = useState(false);
  const [detailMemberInfo, setDetailMemberInfo] = useState<ProgressRow | null>(null);
  const [retakeRequests, setRetakeRequests] = useState<RetakeRequest[]>([]);
  const [retakeLoading, setRetakeLoading] = useState(false);
  const [memberQuizAttempts, setMemberQuizAttempts] = useState<MemberQuizAttempt[]>([]);

  // Determine which company we're managing
  const managingCompany = selectedCompany ?? userCompany;
  const canManage = isCompanyAdmin || isAdmin;

  // Super-admin company selection
  useEffect(() => {
    if (!isAdmin) return;
    if (companyId) {
      // Load specific company
      void (async () => {
        const { data } = await supabase.from('companies').select('*').eq('id', companyId).maybeSingle();
        if (data) setSelectedCompany(data as Company);
      })();
    } else if (userCompany) {
      setSelectedCompany(userCompany);
    } else {
      // Load all companies for super-admin to pick
      void (async () => {
        const { data, error: rpcErr } = await supabase.rpc('get_all_companies_with_stats');
        if (rpcErr) {
          // Fallback: direct query (super-admin can read all via RLS)
          const { data: direct } = await supabase.from('companies').select('*').order('created_at', { ascending: false });
          setAllCompanies((direct ?? []) as Company[]);
        } else {
          setAllCompanies((data as Company[]) ?? []);
        }
      })();
    }
  }, [isAdmin, companyId, userCompany]);

  const loadMembers = useCallback(async () => {
    if (!managingCompany?.id || !canManage) {
      setLoading(false);
      return;
    }
    setLoading(true);
    try {
      const { data, error: rpcErr } = await supabase.rpc('get_company_members_details', {
        target_company_id: managingCompany.id,
      });
      if (rpcErr) throw rpcErr;
      setMembers((data as MemberRow[]) ?? []);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load members');
    } finally {
      setLoading(false);
    }
  }, [managingCompany?.id, canManage]);

  const loadProgress = useCallback(async () => {
    if (!managingCompany?.id || !canManage) return;
    try {
      const { data, error: rpcErr } = await supabase.rpc('get_company_member_progress', {
        target_company_id: managingCompany.id,
      });
      if (rpcErr) throw rpcErr;
      setProgressData((data as ProgressRow[]) ?? []);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load progress');
    }
  }, [managingCompany?.id, canManage]);

  useEffect(() => {
    void loadMembers();
  }, [loadMembers]);

  useEffect(() => {
    if (activeTab === 'progress') void loadProgress();
    if (activeTab === 'retakes') void loadRetakes();
  }, [activeTab, loadProgress]);

  const loadRetakes = useCallback(async () => {
    if (!managingCompany?.id || !canManage) return;
    setRetakeLoading(true);
    try {
      const { data, error: rpcErr } = await supabase.rpc('get_company_retake_requests', { target_company_id: managingCompany.id });
      if (rpcErr) throw rpcErr;
      setRetakeRequests((data as RetakeRequest[]) ?? []);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load retake requests');
    } finally {
      setRetakeLoading(false);
    }
  }, [managingCompany?.id, canManage]);

  async function handleApproveRetake(requestId: string, approved: boolean) {
    setError(null);
    try {
      const req = retakeRequests.find((r) => r.id === requestId);
      const { error: rpcErr } = await supabase.rpc('approve_retake_request', {
        p_request_id: requestId,
        p_approved: approved,
      });
      if (rpcErr) throw rpcErr;
      setSuccess(approved ? 'Retake approved. Member can retry the quiz.' : 'Retake request denied.');
      // Fire-and-forget notification to member on approval
      if (approved && req) {
        supabase.functions.invoke('notify', {
          body: {
            type: 'retake_approved',
            member_name: req.member_name ?? req.member_email ?? 'Team member',
            member_email: req.member_email,
            lesson_title: req.lesson_title ?? 'this lesson',
          },
        }).catch(() => {});
      }
      await loadRetakes();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to process request');
    }
  }

  useEffect(() => {
    if (managingCompany) setCompanyName(managingCompany.name);
  }, [managingCompany]);

  useEffect(() => {
    if (error) { const t = setTimeout(() => setError(null), 5000); return () => clearTimeout(t); }
  }, [error]);
  useEffect(() => {
    if (success) { const t = setTimeout(() => setSuccess(null), 5000); return () => clearTimeout(t); }
  }, [success]);

  async function handleLogoUpload(file: File) {
    if (!managingCompany) return;
    setUploading(true);
    setError(null);
    try {
      if (!file.type.startsWith('image/')) throw new Error('Please upload an image file (PNG, JPG, SVG, etc.)');
      if (file.size > 2 * 1024 * 1024) throw new Error('Logo must be under 2MB');
      const ext = file.name.split('.').pop()?.toLowerCase() ?? 'png';
      const filePath = `${managingCompany.id}/logo.${ext}`;
      const { error: upErr } = await supabase.storage.from('company-logos').upload(filePath, file, { upsert: true, contentType: file.type });
      if (upErr) throw upErr;
      const { data: urlData } = supabase.storage.from('company-logos').getPublicUrl(filePath);
      const { error: rpcErr } = await supabase.rpc('update_company_logo', { target_company_id: managingCompany.id, new_logo_url: urlData.publicUrl });
      if (rpcErr) throw rpcErr;
      setSuccess('Logo updated successfully.');
      setSelectedCompany({ ...managingCompany, logo_url: urlData.publicUrl });
      await refreshPremium();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Upload failed');
    } finally {
      setUploading(false);
    }
  }

  async function handleRemoveLogo() {
    if (!managingCompany?.logo_url) return;
    setError(null);
    try {
      const url = new URL(managingCompany.logo_url);
      const path = url.pathname.split('/company-logos/')[1];
      if (path) await supabase.storage.from('company-logos').remove([path]);
      const { error: rpcErr } = await supabase.rpc('update_company_logo', { target_company_id: managingCompany.id, new_logo_url: null });
      if (rpcErr) throw rpcErr;
      setSuccess('Logo removed.');
      setSelectedCompany({ ...managingCompany, logo_url: null });
      await refreshPremium();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to remove logo');
    }
  }

  async function handleSaveName() {
    if (!managingCompany || !companyName.trim()) return;
    setError(null);
    try {
      const { error: rpcErr } = await supabase.rpc('update_company_name', { target_company_id: managingCompany.id, new_name: companyName.trim() });
      if (rpcErr) throw rpcErr;
      setSuccess('Company name updated.');
      setEditingName(false);
      setSelectedCompany({ ...managingCompany, name: companyName.trim() });
      await refreshPremium();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to update name');
    }
  }

  async function handleAddMember() {
    if (!managingCompany || !newMemberEmail.trim()) return;
    setError(null);
    try {
      const { data, error: rpcErr } = await supabase.rpc('add_company_member_by_email', {
        target_company_id: managingCompany.id,
        member_email: newMemberEmail.trim(),
        member_role: newMemberRole,
      });
      if (rpcErr) throw rpcErr;
      const result = data as { success: boolean; error?: string };
      if (!result?.success) { setError(result?.error ?? 'Failed to add member'); return; }
      setSuccess('Member added successfully.');
      setNewMemberEmail('');
      setNewMemberRole('member');
      setShowAddMember(false);
      await loadMembers();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to add member');
    }
  }

  async function handleRemoveMember(memberUserId: string) {
    if (!managingCompany) return;
    setError(null);
    try {
      const { error: rpcErr } = await supabase.rpc('remove_company_member', { target_company_id: managingCompany.id, target_user_id: memberUserId });
      if (rpcErr) throw rpcErr;
      setSuccess('Member removed.');
      setExpandedMember(null);
      await loadMembers();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to remove member');
    }
  }

  async function handleUpdateRole(memberUserId: string, newRole: 'member' | 'admin' | 'owner') {
    if (!managingCompany) return;
    setError(null);
    try {
      const { error: rpcErr } = await supabase.rpc('update_company_member_role', { target_company_id: managingCompany.id, target_user_id: memberUserId, new_role: newRole });
      if (rpcErr) throw rpcErr;
      setSuccess('Role updated.');
      setExpandedMember(null);
      await loadMembers();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to update role');
    }
  }

  async function handleViewMemberDetail(member: ProgressRow) {
    if (!managingCompany) return;
    setDetailMemberInfo(member);
    setMemberDetail(null);
    setMemberQuizAttempts([]);
    setMemberDetailLoading(true);
    try {
      const [lessonRes, quizRes] = await Promise.all([
        supabase.rpc('get_member_lesson_progress', { target_company_id: managingCompany.id, target_user_id: member.user_id }),
        supabase.rpc('get_member_quiz_attempts', { target_company_id: managingCompany.id, target_user_id: member.user_id }),
      ]);
      if (lessonRes.error) throw lessonRes.error;
      if (quizRes.error) throw quizRes.error;
      setMemberDetail((lessonRes.data as LessonProgressRow[]) ?? []);
      setMemberQuizAttempts((quizRes.data as MemberQuizAttempt[]) ?? []);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load member detail');
    } finally {
      setMemberDetailLoading(false);
    }
  }

  if (!user) {
    return (
      <div className="pt-24 min-h-screen flex items-center justify-center px-4">
        <div className="max-w-md text-center">
          <Building2 className="w-12 h-12 text-steel-600 mx-auto mb-4" />
          <h1 className="text-xl font-bold text-white mb-2">Sign in to access your company</h1>
          <button onClick={() => onNavigate({ name: 'auth' })} className="btn-primary">Sign in</button>
        </div>
      </div>
    );
  }

  if (!canManage) {
    return (
      <div className="pt-24 min-h-screen flex items-center justify-center px-4">
        <div className="max-w-md text-center">
          <Building2 className="w-12 h-12 text-steel-600 mx-auto mb-4" />
          <h1 className="text-xl font-bold text-white mb-2">No Company Access</h1>
          <p className="text-steel-400 mb-5">You need to be a company owner or admin to access this page.</p>
          <button onClick={() => onNavigate({ name: 'dashboard' })} className="btn-primary">Back to Dashboard</button>
        </div>
      </div>
    );
  }

  // Super-admin without a company: show company picker
  if (isAdmin && !managingCompany && allCompanies.length >= 0) {
    if (!managingCompany) {
      return (
        <div className="pt-20 pb-16 min-h-screen">
          <div className="max-w-4xl mx-auto px-4 sm:px-6">
            <div className="mb-6">
              <div className="flex items-center gap-3 mb-2">
                <div className="w-10 h-10 rounded-lg bg-rok-500/20 flex items-center justify-center">
                  <Building2 className="w-5 h-5 text-rok-400" />
                </div>
                <div>
                  <h1 className="text-2xl font-bold text-white">Company Management</h1>
                  <p className="text-sm text-steel-400">Select a company to manage, or create one in the Admin panel.</p>
                </div>
              </div>
            </div>

            {error && (
              <div className="mb-4 flex items-start gap-3 p-4 rounded-lg bg-error-500/10 border border-error-500/30">
                <AlertCircle className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5" />
                <p className="text-sm text-error-300">{error}</p>
                <button onClick={() => setError(null)} className="ml-auto text-error-400 hover:text-error-300"><X className="w-4 h-4" /></button>
              </div>
            )}

            {allCompanies.length === 0 ? (
              <div className="card p-8 text-center">
                <Building2 className="w-10 h-10 text-steel-600 mx-auto mb-3" />
                <p className="text-sm text-steel-500 mb-4">No companies yet. Create one from the Admin Companies tab.</p>
                <button onClick={() => onNavigate({ name: 'admin' })} className="btn-primary">Go to Admin</button>
              </div>
            ) : (
              <div className="space-y-3">
                {allCompanies.map((c) => (
                  <button
                    key={c.id}
                    onClick={() => setSelectedCompany(c)}
                    className="w-full card p-4 flex items-center gap-4 hover:border-rok-500/40 transition-colors text-left"
                  >
                    <div className="w-12 h-12 rounded-lg border border-steel-700/60 bg-navy-950/60 flex items-center justify-center overflow-hidden shrink-0">
                      {c.logo_url ? <img src={c.logo_url} alt={c.name} className="w-full h-full object-contain p-1" /> : <Building2 className="w-5 h-5 text-steel-600" />}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-semibold text-white">{c.name}</span>
                        {c.premium && <Crown className="w-3.5 h-3.5 text-premium-400" />}
                      </div>
                    </div>
                    <ChevronRight className="w-5 h-5 text-steel-500" />
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      );
    }
  }

  if (!managingCompany) {
    return (
      <div className="pt-24 min-h-screen flex items-center justify-center px-4">
        <div className="max-w-md text-center">
          <Building2 className="w-12 h-12 text-steel-600 mx-auto mb-4" />
          <h1 className="text-xl font-bold text-white mb-2">No Company Assigned</h1>
          <p className="text-steel-400 mb-5">You don't have a company assigned yet.</p>
          <button onClick={() => onNavigate({ name: 'dashboard' })} className="btn-primary">Back to Dashboard</button>
        </div>
      </div>
    );
  }

  const roleIcon = (role: string) => {
    if (role === 'owner') return <Crown className="w-3.5 h-3.5 text-premium-400" />;
    if (role === 'admin') return <Shield className="w-3.5 h-3.5 text-accent-400" />;
    return <Users className="w-3.5 h-3.5 text-steel-500" />;
  };
  const roleLabel = (role: string) => role === 'owner' ? 'Owner' : role === 'admin' ? 'Admin' : 'Member';

  return (
    <div className="pt-20 pb-16 min-h-screen">
      <div className="max-w-5xl mx-auto px-4 sm:px-6">
        <div className="mb-6">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 rounded-lg bg-rok-500/20 flex items-center justify-center">
              <Building2 className="w-5 h-5 text-rok-400" />
            </div>
            <div className="flex-1">
              <h1 className="text-2xl font-bold text-white">{managingCompany.name}</h1>
              <p className="text-sm text-steel-400">Company & Team Management</p>
            </div>
            {isAdmin && selectedCompany && userCompany?.id !== selectedCompany.id && (
              <button onClick={() => { setSelectedCompany(null); }} className="btn-ghost text-sm">
                <ArrowLeft className="w-4 h-4" /> Back to list
              </button>
            )}
          </div>
        </div>

        {/* Tabs */}
        <div className="flex gap-1 mb-6 border-b border-steel-700/60">
          {([
            { key: 'settings', label: 'Settings', icon: Settings },
            { key: 'members', label: 'Members', icon: Users },
            { key: 'progress', label: 'Progress', icon: BarChart3 },
            { key: 'retakes', label: 'Retakes', icon: Clock },
          ] as const).map((tab) => {
            const Icon = tab.icon;
            const pendingCount = retakeRequests.filter((r) => r.status === 'pending').length;
            return (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors border-b-2 -mb-px ${
                  activeTab === tab.key ? 'text-white border-rok-500' : 'text-steel-400 border-transparent hover:text-steel-200'
                }`}
              >
                <Icon className="w-4 h-4" />
                {tab.label}
                {tab.key === 'retakes' && pendingCount > 0 && (
                  <span className="ml-0.5 px-1.5 py-0.5 rounded-full bg-warning-500/20 border border-warning-500/40 text-warning-400 text-[10px] font-bold">
                    {pendingCount}
                  </span>
                )}
              </button>
            );
          })}
        </div>

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

        {/* Settings tab */}
        {activeTab === 'settings' && (
          <div className="card p-6">
            <h2 className="text-sm font-semibold text-steel-300 uppercase tracking-wider mb-4">Company Info</h2>
            <div className="flex items-center gap-5 mb-5">
              <div className="w-20 h-20 rounded-xl border border-steel-700/60 bg-navy-950/60 flex items-center justify-center overflow-hidden shrink-0">
                {managingCompany.logo_url ? (
                  <img src={managingCompany.logo_url} alt={managingCompany.name} className="w-full h-full object-contain p-2" />
                ) : (
                  <Building2 className="w-8 h-8 text-steel-600" />
                )}
              </div>
              <div className="flex-1">
                <div className="flex flex-wrap gap-2">
                  <label className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-rok-500/10 border border-rok-500/30 text-rok-300 hover:bg-rok-500/20 transition-colors cursor-pointer text-xs font-medium">
                    {uploading ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Upload className="w-3.5 h-3.5" />}
                    {uploading ? 'Uploading...' : 'Upload Logo'}
                    <input type="file" accept="image/*" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) void handleLogoUpload(f); e.target.value = ''; }} />
                  </label>
                  {managingCompany.logo_url && (
                    <button onClick={handleRemoveLogo} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-error-400 hover:border-error-500/40 transition-colors text-xs font-medium">
                      <Trash2 className="w-3.5 h-3.5" /> Remove
                    </button>
                  )}
                </div>
                <p className="text-[11px] text-steel-500 mt-2">PNG, JPG, or SVG. Max 2MB. Shown in the nav bar next to ForgeLine branding.</p>
              </div>
            </div>
            <div>
              <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">Company Name</label>
              {editingName ? (
                <div className="flex gap-2">
                  <input value={companyName} onChange={(e) => setCompanyName(e.target.value)} className="input flex-1" autoFocus />
                  <button onClick={handleSaveName} className="btn-primary text-sm px-4">Save</button>
                  <button onClick={() => { setEditingName(false); setCompanyName(managingCompany.name); }} className="btn-ghost text-sm">Cancel</button>
                </div>
              ) : (
                <div className="flex items-center justify-between">
                  <span className="text-lg font-semibold text-white">{managingCompany.name}</span>
                  <button onClick={() => setEditingName(true)} className="text-sm text-steel-400 hover:text-accent-400 transition-colors">Edit</button>
                </div>
              )}
            </div>
            <div className="mt-5 pt-5 border-t border-steel-700/40 flex items-center gap-6 text-sm">
              <div className="flex items-center gap-2 text-steel-400">
                <Users className="w-4 h-4 text-steel-500" />
                <span>{members.length} members</span>
              </div>
              {managingCompany.premium && (
                <div className="flex items-center gap-2 text-premium-400">
                  <Crown className="w-4 h-4" />
                  <span>Premium active</span>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Members tab */}
        {activeTab === 'members' && (
          <div className="card p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-sm font-semibold text-steel-300 uppercase tracking-wider">Team Members ({members.length})</h2>
              <button onClick={() => setShowAddMember(!showAddMember)} className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-rok-500/10 border border-rok-500/30 text-rok-300 hover:bg-rok-500/20 transition-colors text-xs font-medium">
                <UserPlus className="w-3.5 h-3.5" /> Add Member
              </button>
            </div>

            {showAddMember && (
              <div className="mb-4 p-4 rounded-lg bg-navy-950/40 border border-steel-700/40">
                <div className="flex flex-col sm:flex-row gap-2">
                  <input type="email" value={newMemberEmail} onChange={(e) => setNewMemberEmail(e.target.value)} placeholder="member@company.com" className="input flex-1" autoFocus />
                  <select value={newMemberRole} onChange={(e) => setNewMemberRole(e.target.value as 'member' | 'admin' | 'owner')} className="input sm:w-32">
                    <option value="member">Member</option>
                    <option value="admin">Admin</option>
                    <option value="owner">Owner</option>
                  </select>
                  <button onClick={handleAddMember} className="btn-primary text-sm px-4">Add</button>
                  <button onClick={() => { setShowAddMember(false); setNewMemberEmail(''); }} className="btn-ghost text-sm">Cancel</button>
                </div>
                <p className="text-[11px] text-steel-500 mt-2">The person must already have a ForgeLine account with that email. They'll be linked to your company automatically.</p>
              </div>
            )}

            {loading ? (
              <div className="flex items-center justify-center py-10"><Loader2 className="w-6 h-6 text-rok-400 animate-spin" /></div>
            ) : members.length === 0 ? (
              <div className="text-center py-10">
                <Users className="w-10 h-10 text-steel-600 mx-auto mb-3" />
                <p className="text-sm text-steel-500">No members yet. Add team members by email after they create an account.</p>
              </div>
            ) : (
              <div className="space-y-1.5">
                {members.map((m) => (
                  <div key={m.member_id} className="rounded-lg border border-steel-700/40 bg-navy-950/30 overflow-hidden">
                    <div className="flex items-center gap-3 p-3">
                      <div className="w-9 h-9 rounded-full bg-gradient-to-br from-steel-600 to-steel-700 flex items-center justify-center text-white text-sm font-bold shrink-0">
                        {(m.email?.[0] ?? m.full_name?.[0] ?? '?').toUpperCase()}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <span className="text-sm font-medium text-white truncate">{m.full_name || m.email || 'Unknown'}</span>
                          <span className="flex items-center gap-1 text-[10px] px-1.5 py-0.5 rounded-full bg-navy-700/60 border border-steel-700/40 text-steel-400">
                            {roleIcon(m.role)} {roleLabel(m.role)}
                          </span>
                        </div>
                        {m.email && <p className="text-xs text-steel-500 truncate">{m.email}</p>}
                      </div>
                      {m.user_id !== user.id && (
                        <button onClick={() => setExpandedMember(expandedMember === m.member_id ? null : m.member_id)} className="p-1.5 rounded-lg text-steel-400 hover:text-white hover:bg-navy-700/60 transition-colors">
                          <ChevronDown className={`w-4 h-4 transition-transform ${expandedMember === m.member_id ? 'rotate-180' : ''}`} />
                        </button>
                      )}
                    </div>
                    {expandedMember === m.member_id && (
                      <div className="px-3 pb-3 border-t border-steel-700/30 pt-3 space-y-2">
                        <div className="flex items-center gap-2">
                          <span className="text-xs text-steel-400">Role:</span>
                          <select value={m.role} onChange={(e) => handleUpdateRole(m.user_id, e.target.value as 'member' | 'admin' | 'owner')} className="input text-xs py-1 px-2 w-32">
                            <option value="member">Member</option>
                            <option value="admin">Admin</option>
                            <option value="owner">Owner</option>
                          </select>
                        </div>
                        <button onClick={() => handleRemoveMember(m.user_id)} className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-error-500/10 border border-error-500/30 text-error-400 hover:bg-error-500/20 transition-colors text-xs font-medium">
                          <Trash2 className="w-3.5 h-3.5" /> Remove from company
                        </button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Progress tab */}
        {activeTab === 'progress' && (
          <div className="space-y-4">
            {detailMemberInfo ? (
              <div className="card p-6">
                <div className="flex items-center gap-3 mb-4">
                  <button onClick={() => { setDetailMemberInfo(null); setMemberDetail(null); }} className="btn-ghost text-sm">
                    <ArrowLeft className="w-4 h-4" /> Back
                  </button>
                  <div>
                    <h2 className="text-lg font-bold text-white">{detailMemberInfo.full_name || detailMemberInfo.email || 'Member'}</h2>
                    <p className="text-xs text-steel-500">{detailMemberInfo.email}</p>
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-3 mb-5">
                  <div className="rounded-lg bg-navy-950/40 border border-steel-700/40 p-3 text-center">
                    <BookOpen className="w-5 h-5 text-rok-400 mx-auto mb-1" />
                    <div className="text-xl font-bold text-white">{detailMemberInfo.lessons_completed}</div>
                    <div className="text-[10px] text-steel-500 uppercase tracking-wider">Lessons</div>
                  </div>
                  <div className="rounded-lg bg-navy-950/40 border border-steel-700/40 p-3 text-center">
                    <BarChart3 className="w-5 h-5 text-accent-400 mx-auto mb-1" />
                    <div className="text-xl font-bold text-white">{detailMemberInfo.courses_started}</div>
                    <div className="text-[10px] text-steel-500 uppercase tracking-wider">Courses Started</div>
                  </div>
                  <div className="rounded-lg bg-navy-950/40 border border-steel-700/40 p-3 text-center">
                    <Award className="w-5 h-5 text-premium-400 mx-auto mb-1" />
                    <div className="text-xl font-bold text-white">{detailMemberInfo.certificates_count}</div>
                    <div className="text-[10px] text-steel-500 uppercase tracking-wider">Certificates</div>
                  </div>
                </div>

                <h3 className="text-sm font-semibold text-steel-300 uppercase tracking-wider mb-3">Lesson Progress</h3>
                {memberDetailLoading ? (
                  <div className="flex items-center justify-center py-8"><Loader2 className="w-6 h-6 text-rok-400 animate-spin" /></div>
                ) : !memberDetail || memberDetail.length === 0 ? (
                  <p className="text-sm text-steel-500 text-center py-8">No lesson progress yet.</p>
                ) : (
                  <div className="space-y-1.5">
                    {memberDetail.map((lp) => (
                      <div key={lp.progress_id} className="flex items-center gap-3 p-3 rounded-lg border border-steel-700/40 bg-navy-950/30">
                        <div className="flex-1 min-w-0">
                          <div className="text-sm font-medium text-white truncate">{lp.lesson_title ?? 'Unknown lesson'}</div>
                          <div className="text-xs text-steel-500 truncate">{lp.course_title ?? 'Unknown course'}</div>
                        </div>
                        {lp.completed ? (
                          <span className="flex items-center gap-1 text-xs text-success-400 font-medium">
                            <CheckCircle2 className="w-3.5 h-3.5" /> Completed
                          </span>
                        ) : (
                          <span className="text-xs text-steel-500">In progress</span>
                        )}
                        {lp.quiz_score != null && (
                          <span className="text-xs text-steel-400">{lp.quiz_score}%</span>
                        )}
                      </div>
                    ))}
                  </div>
                )}

                {/* Quiz attempt stats */}
                <h3 className="text-sm font-semibold text-steel-300 uppercase tracking-wider mb-3 mt-6">Quiz Attempts</h3>
                {memberDetailLoading ? (
                  <div className="flex items-center justify-center py-4"><Loader2 className="w-5 h-5 text-rok-400 animate-spin" /></div>
                ) : memberQuizAttempts.length === 0 ? (
                  <p className="text-sm text-steel-500 text-center py-4">No quiz attempts yet.</p>
                ) : (
                  <div className="space-y-1.5">
                    {memberQuizAttempts.map((qa) => (
                      <div key={qa.lesson_id} className="flex items-center gap-3 p-3 rounded-lg border border-steel-700/40 bg-navy-950/30">
                        <div className="flex-1 min-w-0">
                          <div className="text-sm font-medium text-white truncate">{qa.lesson_title ?? 'Unknown lesson'}</div>
                          <div className="text-xs text-steel-500 truncate">{qa.course_title ?? 'Unknown course'}</div>
                        </div>
                        <div className="flex items-center gap-3 shrink-0 text-xs">
                          <span className="text-steel-400">{qa.total_attempts} taken</span>
                          {qa.failed_count > 0 && <span className="text-error-400">{qa.failed_count} failed</span>}
                          {qa.best_score != null && <span className="text-steel-400">Best: {qa.best_score}%</span>}
                          {qa.lock_status && (
                            <span className="px-1.5 py-0.5 rounded-full bg-warning-500/15 border border-warning-500/30 text-warning-400 text-[10px] font-semibold">Locked</span>
                          )}
                          {qa.passed && !qa.lock_status && (
                            <span className="flex items-center gap-0.5 text-success-400"><CheckCircle2 className="w-3 h-3" /> Passed</span>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            ) : (
              <div className="card p-6">
                <h2 className="text-sm font-semibold text-steel-300 uppercase tracking-wider mb-4">Team Progress</h2>
                {progressData.length === 0 ? (
                  <div className="text-center py-10">
                    <BarChart3 className="w-10 h-10 text-steel-600 mx-auto mb-3" />
                    <p className="text-sm text-steel-500">Members haven't started training yet.</p>
                  </div>
                ) : (
                  <div className="space-y-1.5">
                    <div className="hidden sm:grid grid-cols-4 gap-3 px-3 pb-2 text-[10px] font-semibold text-steel-500 uppercase tracking-wider">
                      <div>Member</div>
                      <div className="text-center">Lessons</div>
                      <div className="text-center">Courses</div>
                      <div className="text-center">Certificates</div>
                    </div>
                    {progressData.map((p) => (
                      <button
                        key={p.user_id}
                        onClick={() => handleViewMemberDetail(p)}
                        className="w-full flex items-center gap-3 p-3 rounded-lg border border-steel-700/40 bg-navy-950/30 hover:border-rok-500/40 hover:bg-navy-800/40 transition-colors text-left"
                      >
                        <div className="w-9 h-9 rounded-full bg-gradient-to-br from-steel-600 to-steel-700 flex items-center justify-center text-white text-sm font-bold shrink-0">
                          {(p.email?.[0] ?? p.full_name?.[0] ?? '?').toUpperCase()}
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2">
                            <span className="text-sm font-medium text-white truncate">{p.full_name || p.email || 'Unknown'}</span>
                            {roleIcon(p.role)}
                          </div>
                          {p.last_activity && (
                            <p className="text-[10px] text-steel-500">Last active: {new Date(p.last_activity).toLocaleDateString()}</p>
                          )}
                        </div>
                        <div className="flex items-center gap-4 sm:gap-6 shrink-0">
                          <div className="text-center">
                            <div className="text-sm font-bold text-white sm:hidden">{p.lessons_completed}</div>
                            <div className="text-lg font-bold text-rok-400 hidden sm:block">{p.lessons_completed}</div>
                          </div>
                          <div className="text-center">
                            <div className="text-sm font-bold text-white sm:hidden">{p.courses_started}</div>
                            <div className="text-lg font-bold text-accent-400 hidden sm:block">{p.courses_started}</div>
                          </div>
                          <div className="text-center">
                            <div className="text-sm font-bold text-white sm:hidden">{p.certificates_count}</div>
                            <div className="text-lg font-bold text-premium-400 hidden sm:block">{p.certificates_count}</div>
                          </div>
                          <ChevronRight className="w-4 h-4 text-steel-500" />
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        {/* Retakes tab */}
        {activeTab === 'retakes' && (
          <div className="card p-6">
            <h2 className="text-sm font-semibold text-steel-300 uppercase tracking-wider mb-4">Retake Approval Requests</h2>
            {retakeLoading ? (
              <div className="flex items-center justify-center py-10"><Loader2 className="w-6 h-6 text-rok-400 animate-spin" /></div>
            ) : retakeRequests.length === 0 ? (
              <div className="text-center py-10">
                <Clock className="w-10 h-10 text-steel-600 mx-auto mb-3" />
                <p className="text-sm text-steel-500">No retake requests. They'll appear here when a member fails 3 times.</p>
              </div>
            ) : (
              <div className="space-y-3">
                {retakeRequests.map((req) => (
                  <div key={req.id} className={`rounded-lg border p-4 ${
                    req.status === 'pending' ? 'border-warning-500/30 bg-warning-500/5' :
                    req.status === 'approved' ? 'border-success-500/30 bg-success-500/5' :
                    'border-steel-700/40 bg-navy-950/30'
                  }`}>
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-sm font-semibold text-white">{req.member_name || req.member_email || 'Unknown'}</span>
                          <span className={`text-[10px] px-1.5 py-0.5 rounded-full font-semibold ${
                            req.status === 'pending' ? 'bg-warning-500/15 text-warning-400 border border-warning-500/30' :
                            req.status === 'approved' ? 'bg-success-500/15 text-success-400 border border-success-500/30' :
                            'bg-error-500/15 text-error-400 border border-error-500/30'
                          }`}>
                            {req.status.charAt(0).toUpperCase() + req.status.slice(1)}
                          </span>
                        </div>
                        <div className="text-xs text-steel-500 mb-2">
                          {req.course_title ?? 'Unknown course'} — {req.lesson_title ?? 'Unknown lesson'}
                        </div>
                        <div className="flex flex-wrap gap-4 text-xs text-steel-400">
                          <span>Total attempts: <strong className="text-white">{req.total_attempts}</strong></span>
                          <span>Failed in cycle: <strong className="text-error-400">{req.failed_attempt_count}</strong></span>
                          {req.last_score != null && <span>Last score: <strong className="text-white">{req.last_score}%</strong></span>}
                          <span>Requested: {new Date(req.requested_at).toLocaleDateString()}</span>
                        </div>
                        {req.note && <p className="text-xs text-steel-500 mt-2">Note: {req.note}</p>}
                      </div>
                      {req.status === 'pending' && (
                        <div className="flex gap-2 shrink-0">
                          <button onClick={() => handleApproveRetake(req.id, true)} className="btn-primary text-xs px-3 py-1.5">
                            <CheckCircle2 className="w-3.5 h-3.5" /> Approve
                          </button>
                          <button onClick={() => handleApproveRetake(req.id, false)} className="btn-secondary text-xs px-3 py-1.5">
                            Deny
                          </button>
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
