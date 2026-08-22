import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import type { Session, User } from '@supabase/supabase-js';
import { supabase } from '@/lib/supabase';
import type { Company } from '@/lib/types';

interface CompanyInfo {
  company: Company | null;
  role: 'owner' | 'admin' | 'member' | null;
}

interface AuthState {
  session: Session | null;
  user: User | null;
  loading: boolean;
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

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [isPremium, setIsPremium] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);
  const [fullName, setFullName] = useState<string | null>(null);
  const [company, setCompany] = useState<Company | null>(null);
  const [companyRole, setCompanyRole] = useState<'owner' | 'admin' | 'member' | null>(null);
  const [assessmentCompleted, setAssessmentCompleted] = useState(true);

  async function loadProfile(uid: string | undefined) {
    if (!uid) {
      setIsPremium(false);
      setIsAdmin(false);
      setFullName(null);
      setCompany(null);
      setCompanyRole(null);
      setAssessmentCompleted(true);
      return;
    }
    const { data } = await supabase
      .from('profiles')
      .select('is_premium, is_admin, full_name, company_id, assessment_completed')
      .eq('id', uid)
      .maybeSingle();
    setIsPremium(Boolean(data?.is_premium));
    setIsAdmin(Boolean(data?.is_admin));
    setFullName(data?.full_name ?? null);
    setAssessmentCompleted(Boolean(data?.assessment_completed));

    // Load company info if user has a company_id
    if (data?.company_id) {
      const { data: companyData } = await supabase
        .from('companies')
        .select('*')
        .eq('id', data.company_id)
        .maybeSingle();
      setCompany(companyData as Company | null);

      const { data: memberData } = await supabase
        .from('company_members')
        .select('role')
        .eq('company_id', data.company_id)
        .eq('user_id', uid)
        .maybeSingle();
      setCompanyRole((memberData?.role as 'owner' | 'admin' | 'member') ?? null);
    } else {
      setCompany(null);
      setCompanyRole(null);
    }
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
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setLoading(false);
      void loadProfile(data.session?.user?.id);
    });

    const { data: sub } = supabase.auth.onAuthStateChange((_event, newSession) => {
      (async () => {
        setSession(newSession);
        setLoading(false);
        await loadProfile(newSession?.user?.id);
      })();
    });

    return () => sub.subscription.unsubscribe();
  }, []);

  async function signIn(email: string, password: string) {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error: error ? error.message : null };
  }

  async function signUp(email: string, password: string, fullName?: string) {
    const { data, error } = await supabase.auth.signUp({ email, password });
    if (error) return { error: error.message };
    if (data.user) {
      await supabase.from('profiles').upsert({
        id: data.user.id,
        email: data.user.email,
        is_premium: false,
        full_name: fullName || null,
      });
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
  }

  return (
    <AuthContext.Provider
      value={{
        session,
        user: session?.user ?? null,
        loading,
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
