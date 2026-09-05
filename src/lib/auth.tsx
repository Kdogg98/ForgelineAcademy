import { createContext, useContext, useEffect, useRef, useState, type ReactNode } from 'react';
import type { Session, User } from '@supabase/supabase-js';
import { supabase } from '@/lib/supabase';
import type { Company } from '@/lib/types';

interface AuthState {
  session: Session | null;
  user: User | null;
  loading: boolean;
  /** False until the first profiles row fetch for this session finishes (success or fail). */
  profileReady: boolean;
  isPremium: boolean;
  isAdmin: boolean;
  fullName: string | null;
  company: Company | null;
  companyRole: 'owner' | 'admin' | 'member' | null;
  isCompanyAdmin: boolean;
  assessmentCompleted: boolean;
  refreshPremium: () => Promise<void>;
  updateFullName: (name: string) => Promise<{ error: string | null }>;
  signIn: (email: string, password: string) => Promise<{ error: string | null }>;
  signUp: (email: string, password: string, fullName?: string) => Promise<{ error: string | null }>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthState | undefined>(undefined);

type ProfileRow = {
  is_premium: boolean | null;
  is_admin: boolean | null;
  full_name: string | null;
  company_id: string | null;
  assessment_completed: boolean | null;
};

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [profileReady, setProfileReady] = useState(false);
  const [isPremium, setIsPremium] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);
  const [fullName, setFullName] = useState<string | null>(null);
  const [company, setCompany] = useState<Company | null>(null);
  const [companyRole, setCompanyRole] = useState<'owner' | 'admin' | 'member' | null>(null);
  const [assessmentCompleted, setAssessmentCompleted] = useState(true);
  const loadGen = useRef(0);

  async function fetchProfileRow(uid: string): Promise<ProfileRow | null> {
    const { data, error } = await supabase
      .from('profiles')
      .select('is_premium, is_admin, full_name, company_id, assessment_completed')
      .eq('id', uid)
      .maybeSingle();
    if (error) throw error;
    return data as ProfileRow | null;
  }

  async function loadProfile(uid: string | undefined) {
    const gen = ++loadGen.current;
    if (!uid) {
      setIsPremium(false);
      setIsAdmin(false);
      setFullName(null);
      setCompany(null);
      setCompanyRole(null);
      setAssessmentCompleted(true);
      setProfileReady(true);
      return;
    }

    setProfileReady(false);

    let data: ProfileRow | null = null;
    try {
      data = await fetchProfileRow(uid);
      // RLS can look like "no row" if the JWT isn't attached yet — retry once.
      if (!data) {
        await new Promise((r) => setTimeout(r, 300));
        if (gen !== loadGen.current) return;
        data = await fetchProfileRow(uid);
      }
    } catch {
      await new Promise((r) => setTimeout(r, 300));
      if (gen !== loadGen.current) return;
      try {
        data = await fetchProfileRow(uid);
      } catch {
        data = null;
      }
    }

    if (gen !== loadGen.current) return;

    setIsPremium(Boolean(data?.is_premium));
    setIsAdmin(Boolean(data?.is_admin));
    setFullName(data?.full_name ?? null);
    setAssessmentCompleted(Boolean(data?.assessment_completed));

    if (data?.company_id) {
      const { data: companyData } = await supabase
        .from('companies')
        .select('*')
        .eq('id', data.company_id)
        .maybeSingle();
      if (gen !== loadGen.current) return;
      setCompany(companyData as Company | null);

      const { data: memberData } = await supabase
        .from('company_members')
        .select('role')
        .eq('company_id', data.company_id)
        .eq('user_id', uid)
        .maybeSingle();
      if (gen !== loadGen.current) return;
      setCompanyRole((memberData?.role as 'owner' | 'admin' | 'member') ?? null);
    } else {
      setCompany(null);
      setCompanyRole(null);
    }

    setProfileReady(true);
  }

  async function updateFullName(name: string) {
    if (!session?.user?.id) return { error: 'Not signed in' };
    const { error } = await supabase
      .from('profiles')
      .update({ full_name: name })
      .eq('id', session.user.id);
    if (error) return { error: error.message };
    setFullName(name);
    return { error: null };
  }

  async function refreshPremium() {
    await loadProfile(session?.user?.id);
  }

  useEffect(() => {
    let cancelled = false;

    // Prefer onAuthStateChange (fires INITIAL_SESSION) so the client JWT is attached
    // before we hit profiles. Avoid racing getSession().then(loadProfile).
    const { data: sub } = supabase.auth.onAuthStateChange((_event, newSession) => {
      void (async () => {
        setSession(newSession);
        await loadProfile(newSession?.user?.id);
        if (!cancelled) setLoading(false);
      })();
    });

    return () => {
      cancelled = true;
      sub.subscription.unsubscribe();
    };
  }, []);

  async function signIn(email: string, password: string) {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error: error ? error.message : null };
  }

  async function signUp(email: string, password: string, fullName?: string) {
    const { data, error } = await supabase.auth.signUp({ email, password });
    if (error) return { error: error.message };
    if (data.user) {
      // Do NOT send is_premium:false — that clobbers complimentary grants on upsert.
      // handle_new_user trigger inserts defaults; we only set identity fields.
      await supabase.from('profiles').upsert({
        id: data.user.id,
        email: data.user.email,
        full_name: fullName || null,
      });
      try {
        await supabase.rpc('get_or_create_referral_code', { p_user_id: data.user.id });
      } catch {
        // ignore — signup still succeeds
      }
      await supabase.rpc('claim_admin_if_first');
      await loadProfile(data.user.id);
    }
    return { error: null };
  }

  async function signOut() {
    await supabase.auth.signOut();
    setIsPremium(false);
    setIsAdmin(false);
    setFullName(null);
    setCompany(null);
    setCompanyRole(null);
    setAssessmentCompleted(true);
    setProfileReady(true);
  }

  return (
    <AuthContext.Provider
      value={{
        session,
        user: session?.user ?? null,
        loading,
        profileReady,
        isPremium: isPremium || (company?.premium ?? false),
        isAdmin,
        fullName,
        company,
        companyRole,
        isCompanyAdmin: companyRole === 'owner' || companyRole === 'admin',
        assessmentCompleted,
        refreshPremium,
        updateFullName,
        signIn,
        signUp,
        signOut,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
