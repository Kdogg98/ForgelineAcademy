import { createContext, useContext, useEffect, useRef, useState, type ReactNode } from 'react';
import type { Session, User } from '@supabase/supabase-js';
import { supabase } from '@/lib/supabase';
import type { Company } from '@/lib/types';
import { computeEntitlement, fetchOwnSubscriptionStatus, type PremiumSource } from '@/lib/entitlements';

interface AuthState {
  session: Session | null;
  user: User | null;
  loading: boolean;
  /** False until the first profiles row fetch for this session finishes (success or fail). */
  profileReady: boolean;
  /** Central entitlement (see lib/entitlements): personal OR active Stripe sub OR premium + active company. */
  isPremium: boolean;
  premiumSource: PremiumSource;
  isAdmin: boolean;
  fullName: string | null;
  company: Company | null;
  companyRole: 'owner' | 'admin' | 'member' | null;
  /** Company owner/admin ("manager"): can see their own company's team progress. */
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
  const [premiumSource, setPremiumSource] = useState<PremiumSource>(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [fullName, setFullName] = useState<string | null>(null);
  const [company, setCompany] = useState<Company | null>(null);
  const [companyRole, setCompanyRole] = useState<'owner' | 'admin' | 'member' | null>(null);
  const [assessmentCompleted, setAssessmentCompleted] = useState(true);
  const loadGen = useRef(0);
  /** User id of the latest auth event; profile loads for any other user are stale. */
  const authUserId = useRef<string | null>(null);
  /** User whose profile is currently loaded (later loads for them refresh silently). */
  const loadedFor = useRef<string | null>(null);
  /** Last load got no profile row (e.g. JWT not attached yet): retry on the next auth event. */
  const profileMissing = useRef(false);
  const [reloadKey, setReloadKey] = useState(0);
  const userId = session?.user?.id ?? null;

  async function fetchProfileRow(uid: string): Promise<ProfileRow | null> {
    const { data, error } = await supabase
      .from('profiles')
      .select('is_premium, is_admin, full_name, company_id, assessment_completed')
      .eq('id', uid)
      .maybeSingle();
    if (error) throw error;
    return data as ProfileRow | null;
  }

  function resetProfileState() {
    loadedFor.current = null;
    profileMissing.current = false;
    setIsPremium(false);
    setPremiumSource(null);
    setIsAdmin(false);
    setFullName(null);
    setCompany(null);
    setCompanyRole(null);
    setAssessmentCompleted(true);
    setProfileReady(true);
  }

  /** silent: refresh the already-loaded user without flipping profileReady (no theme flicker). */
  async function loadProfile(uid: string | undefined | null, silent = false) {
    const gen = ++loadGen.current;
    if (!uid) {
      resetProfileState();
      return;
    }

    if (!silent) setProfileReady(false);

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
    profileMissing.current = !data;

    setIsAdmin(Boolean(data?.is_admin));
    setFullName(data?.full_name ?? null);
    setAssessmentCompleted(Boolean(data?.assessment_completed));

    let loadedCompany: Company | null = null;
    let loadedRole: 'owner' | 'admin' | 'member' | null = null;
    if (data?.company_id) {
      const { data: companyData } = await supabase
        .from('companies')
        .select('*')
        .eq('id', data.company_id)
        .maybeSingle();
      if (gen !== loadGen.current) return;
      loadedCompany = (companyData as Company | null) ?? null;
      setCompany(loadedCompany);

      const { data: memberData } = await supabase
        .from('company_members')
        .select('role')
        .eq('company_id', data.company_id)
        .eq('user_id', uid)
        .maybeSingle();
      if (gen !== loadGen.current) return;
      loadedRole = (memberData?.role as 'owner' | 'admin' | 'member') ?? null;
      setCompanyRole(loadedRole);
    } else {
      setCompany(null);
      setCompanyRole(null);
    }

    const subscriptionStatus = await fetchOwnSubscriptionStatus();
    if (gen !== loadGen.current) return;
    const ent = computeEntitlement({
      profileIsPremium: data?.is_premium,
      subscriptionStatus,
      companyPremium: loadedCompany?.premium,
      companyActive: loadedCompany?.active,
      // Trust company_members (admin-managed), not the user-editable profiles.company_id.
      isCompanyMember: loadedRole !== null,
    });
    setIsPremium(ent.isPremium);
    setPremiumSource(ent.source);

    loadedFor.current = uid;
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

  // Auth events only update React state. No Supabase queries in this callback: supabase-js
  // awaits it while holding its auth state, so querying here can deadlock or run before the
  // new JWT is used. Profile/company/entitlement loading is driven by the effect below.
  useEffect(() => {
    const { data: sub } = supabase.auth.onAuthStateChange((event, newSession) => {
      const nextId = newSession?.user?.id ?? null;
      const userChanged = nextId !== authUserId.current;
      authUserId.current = nextId;
      setSession(newSession);

      if (!nextId) {
        // SIGNED_OUT (or INITIAL_SESSION without a session): drop in-flight loads, back to defaults.
        loadGen.current++;
        resetProfileState();
        setLoading(false);
        return;
      }
      if (userChanged) {
        // SIGNED_IN / INITIAL_SESSION for a new user: hide the previous user's company and
        // entitlement in this same render so the wrong company never flashes.
        loadGen.current++;
        loadedFor.current = null;
        setProfileReady(false);
        setIsPremium(false);
        setPremiumSource(null);
        setIsAdmin(false);
        setCompany(null);
        setCompanyRole(null);
      } else if (event === 'USER_UPDATED' || profileMissing.current) {
        // Same user: refresh on USER_UPDATED, or retry SIGNED_IN / TOKEN_REFRESHED when the
        // last load got no profile row.
        setReloadKey((k) => k + 1);
      }
    });

    return () => sub.subscription.unsubscribe();
  }, []);

  // (Re)load profile, company and entitlement whenever the signed-in user changes, deferred
  // out of the auth callback. Stale loads are ignored via loadGen / authUserId.
  useEffect(() => {
    if (!userId) return;
    let cancelled = false;
    const timer = setTimeout(() => {
      void loadProfile(userId, loadedFor.current === userId).finally(() => {
        if (!cancelled && authUserId.current === userId) setLoading(false);
      });
    }, 0);
    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
    // loadProfile only reads refs and setters
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [userId, reloadKey]);

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
    loadGen.current++;
    resetProfileState();
  }

  return (
    <AuthContext.Provider
      value={{
        session,
        user: session?.user ?? null,
        loading,
        profileReady,
        isPremium,
        premiumSource,
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
