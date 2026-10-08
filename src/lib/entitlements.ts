import { supabase } from '@/lib/supabase';

/**
 * Single source of truth for premium access on the client.
 *
 * Premium = personal comp/paid flag (profiles.is_premium)
 *        OR an active Stripe subscription (stripe_subscriptions.status)
 *        OR membership in a company with companies.premium = true.
 *
 * Mirrors the SQL helper public.has_premium(uid). Company seats are online
 * memberships only. Admin bypass stays at the call sites (isPremium || isAdmin).
 */

/** Same set stripe-webhook treats as premium. */
export const ACTIVE_SUBSCRIPTION_STATUSES = ['active', 'trialing'] as const;

export type PremiumSource = 'personal' | 'subscription' | 'company' | null;

export interface EntitlementInput {
  profileIsPremium: boolean | null | undefined;
  subscriptionStatus: string | null | undefined;
  /** companies.premium of the user's company, only if a company_members row exists. */
  companyPremium: boolean | null | undefined;
  isCompanyMember: boolean;
}

export interface Entitlement {
  isPremium: boolean;
  source: PremiumSource;
}

export function isActiveSubscriptionStatus(status: string | null | undefined): boolean {
  return !!status && (ACTIVE_SUBSCRIPTION_STATUSES as readonly string[]).includes(status);
}

export function computeEntitlement(input: EntitlementInput): Entitlement {
  if (input.profileIsPremium) return { isPremium: true, source: 'personal' };
  if (isActiveSubscriptionStatus(input.subscriptionStatus)) return { isPremium: true, source: 'subscription' };
  if (input.isCompanyMember && input.companyPremium) return { isPremium: true, source: 'company' };
  return { isPremium: false, source: null };
}

/** Caller's own Stripe subscription status via the security_invoker view (RLS: own rows only). */
export async function fetchOwnSubscriptionStatus(): Promise<string | null> {
  try {
    const { data, error } = await supabase
      .from('stripe_user_subscriptions')
      .select('subscription_status')
      .maybeSingle();
    if (error) return null;
    return (data?.subscription_status as string | null) ?? null;
  } catch {
    return null;
  }
}
