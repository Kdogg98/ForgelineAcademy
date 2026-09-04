import { useState, useEffect } from 'react';
import {
  Check,
  X,
  Hexagon,
  Zap,
  Crown,
  ArrowRight,
  AlertCircle,
  Shield,
  Loader2,
  CreditCard,
  Settings,
  Gift,
  Users,
  Copy,
  Tag,
  Wrench,
} from 'lucide-react';
import { useAuth } from '@/lib/auth';
import { track } from '@/lib/analytics';
import { supabase } from '@/lib/supabase';
import { SITE_CONFIG } from '@/lib/siteConfig';
import type { Route } from '@/components/Nav';

const STRIPE_PRICE_ID = import.meta.env.VITE_STRIPE_PRICE_ID as string;

interface SubscriptionInfo {
  subscription_status: string;
  cancel_at_period_end: boolean;
  current_period_end: number | null;
  payment_method_brand: string | null;
  payment_method_last4: string | null;
}

interface PricingProps {
  onNavigate: (r: Route) => void;
}

export function Pricing({ onNavigate }: PricingProps) {
  const { user, isPremium, isAdmin, refreshPremium } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [subscription, setSubscription] = useState<SubscriptionInfo | null>(null);
  const [subLoading, setSubLoading] = useState(true);
  const [promoCode, setPromoCode] = useState('');
  const [promoMessage, setPromoMessage] = useState<string | null>(null);
  const [promoValid, setPromoValid] = useState(false);

  const [validating, setValidating] = useState(false);
  const [referralCode, setReferralCode] = useState<string | null>(null);
  const [referralCount, setReferralCount] = useState(0);
  const [copied, setCopied] = useState(false);
  const [referralLoading, setReferralLoading] = useState(false);
  const [referralError, setReferralError] = useState<string | null>(null);
  const [referralReload, setReferralReload] = useState(0);

  const REFERRALS_NEEDED = 3;

  useEffect(() => {
    if (!user) {
      setReferralCode(null);
      setReferralLoading(false);
      setReferralError(null);
      return;
    }
    let cancelled = false;
    setReferralLoading(true);
    setReferralError(null);
    (async () => {
      try {
        const { data: existing } = await supabase
          .from('referral_codes')
          .select('code, referrals_count')
          .eq('user_id', user.id)
          .maybeSingle();
        if (cancelled) return;
        if (existing?.code) {
          setReferralCode(existing.code as string);
          setReferralCount((existing as { referrals_count: number }).referrals_count ?? 0);
          return;
        }
        const { data, error } = await supabase.rpc('get_or_create_referral_code', { p_user_id: user.id });
        if (cancelled) return;
        const code = typeof data === 'string' ? data : null;
        if (error || !code) {
          setReferralError(error?.message || 'Could not load your referral code.');
          return;
        }
        setReferralCode(code);
        const { data: rc } = await supabase
          .from('referral_codes')
          .select('referrals_count')
          .eq('user_id', user.id)
          .maybeSingle();
        if (!cancelled && rc) setReferralCount((rc as { referrals_count: number }).referrals_count);
      } catch (e) {
        if (!cancelled) setReferralError(e instanceof Error ? e.message : 'Could not load your referral code.');
      } finally {
        if (!cancelled) setReferralLoading(false);
      }
    })();
    return () => { cancelled = true; };
  }, [user, referralReload]);

  useEffect(() => {
    if (!user) {
      setSubscription(null);
      setSubLoading(false);
      return;
    }
    let cancelled = false;
    (async () => {
      setSubLoading(true);
      try {
        const { data } = await supabase
          .from('stripe_user_subscriptions')
          .select('subscription_status, cancel_at_period_end, current_period_end, payment_method_brand, payment_method_last4')
          .maybeSingle();
        if (!cancelled) setSubscription(data as SubscriptionInfo | null);
      } catch {
        if (!cancelled) setSubscription(null);
      } finally {
        if (!cancelled) setSubLoading(false);
      }
    })();
    return () => { cancelled = true; };
  }, [user, isPremium]);

  async function handleValidateCode() {
    if (!user || !promoCode.trim()) return;
    setValidating(true);
    setPromoMessage(null);
    setError(null);
    try {
      const { data, error: rpcErr } = await supabase.rpc('validate_code', {
        p_code: promoCode.trim(),
        p_user_id: user.id,
      });
      if (rpcErr) throw rpcErr;
      const rows = Array.isArray(data) ? data : data ? [data] : [];
      const result = rows[0] as { valid?: boolean; message?: string; code_type?: string } | undefined;
      setPromoValid(Boolean(result?.valid));
      setPromoMessage(result?.message ?? 'Validation failed');
    } catch (e) {
      setPromoValid(false);
      setPromoMessage(e instanceof Error ? e.message : 'Validation failed');
    } finally {
      setValidating(false);
    }
  }

  async function handleCheckout() {
    if (!user) {
      onNavigate({ name: 'auth' });
      return;
    }
    if (!STRIPE_PRICE_ID) {
      setError('Payment configuration is incomplete. Please set VITE_STRIPE_PRICE_ID.');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const origin = window.location.origin;
      const { data, error: fnError } = await supabase.functions.invoke('stripe-promo-checkout', {
        body: {
          price_id: STRIPE_PRICE_ID,
          success_url: `${origin}/upgrade`,
          cancel_url: `${origin}/upgrade`,
          mode: 'subscription',
          promo_code: promoCode.trim() || undefined,
        },
      });

      if (fnError) throw fnError;
      if (data?.url) {
        const listPrice = 19.99;
        const code = promoCode.trim().toUpperCase();
        const discounted = promoValid && code === '75OFF';
        const session = data as { url?: string; session_id?: string; id?: string };
        track('premium_checkout', {
          value: discounted ? +(listPrice * 0.25).toFixed(2) : listPrice,
          currency: 'USD',
          transaction_id: String(session.session_id ?? session.id ?? `${user.id}-${Date.now()}`),
        });
        window.location.href = data.url;
      } else {
        throw new Error('No checkout URL returned');
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to start checkout');
      setLoading(false);
    }
  }

  async function handleManageBilling() {
    setLoading(true);
    setError(null);
    try {
      const origin = window.location.origin;
      const { data, error: fnError } = await supabase.functions.invoke('stripe-portal', {
        body: { return_url: `${origin}/upgrade` },
      });

      if (fnError) throw fnError;
      if (data?.url) {
        window.location.href = data.url;
      } else {
        throw new Error('No portal URL returned');
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to open billing portal');
      setLoading(false);
    }
  }

  const activeSub = subscription?.subscription_status === 'active' || subscription?.subscription_status === 'trialing';
  const cancelledPending = subscription?.cancel_at_period_end && activeSub;
  const periodEnd = subscription?.current_period_end
    ? new Date(subscription.current_period_end * 1000).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
    : null;

  return (
    <div className="pt-16 min-h-screen">
      <div className="border-b border-steel-700/60 bg-navy-950/40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-10 text-center">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-accent-500/10 border border-accent-500/30 text-accent-300 text-xs font-semibold uppercase tracking-wider mb-4">
            <Zap className="w-3.5 h-3.5" />
            Plans &amp; Pricing
          </div>
          <h1 className="font-display text-3xl sm:text-4xl font-bold text-white mb-2">
            Choose Your Access Level
          </h1>
          <p className="text-steel-400 max-w-2xl mx-auto">
            Start free with Mechanical and Electrical fundamentals. Upgrade to Premium
            when you're ready for Instrumentation and Engineering.
          </p>
        </div>
      </div>

      <div className="max-w-5xl mx-auto px-4 sm:px-6 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Free plan */}
          <div className="card p-8 flex flex-col">
            <div className="flex items-center gap-3 mb-5">
              <div className="w-11 h-11 rounded-lg bg-accent-500/15 flex items-center justify-center">
                <Hexagon className="w-5 h-5 text-accent-300" strokeWidth={1.6} />
              </div>
              <div>
                <h2 className="font-display text-xl font-bold text-white">Free</h2>
                <p className="text-xs text-steel-400">Mechanical &amp; Electrical</p>
              </div>
            </div>
            <div className="mb-6">
              <span className="font-display text-4xl font-bold text-white">$0</span>
              <span className="text-steel-400 text-sm ml-1">forever</span>
            </div>
            <ul className="space-y-3 mb-8 flex-1">
              {[
                '44 free courses across Mechanical and Electrical',
                'Full in-depth lesson content and PDF notes',
                'Knowledge checks with 80% pass requirement',
                'Progress tracking across devices',
                'Certificates of Completion',
                'Career ladder dashboard',
              ].map((f) => (
                <li key={f} className="flex items-start gap-2.5 text-sm text-steel-200">
                  <Check className="w-4 h-4 text-success-500 shrink-0 mt-0.5" />
                  {f}
                </li>
              ))}
              {['18 I&E Instrumentation courses', '16 Engineering / Advanced Controls courses', 'AI Course Tutor'].map((f) => (
                <li key={f} className="flex items-start gap-2.5 text-sm text-steel-600">
                  <X className="w-4 h-4 shrink-0 mt-0.5" />
                  {f}
                </li>
              ))}
            </ul>
            {isAdmin ? (
              <div className="flex items-center justify-center gap-2 text-accent-300 font-semibold py-2.5 text-sm border border-accent-500/30 rounded-md bg-accent-500/10">
                <Shield className="w-4 h-4" />
                Admin — All Access
              </div>
            ) : isPremium ? (
              <button
                onClick={handleManageBilling}
                disabled={loading}
                className="btn-secondary w-full"
              >
                {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Settings className="w-4 h-4" />}
                Manage Billing
              </button>
            ) : user ? (
              <div className="btn-secondary w-full cursor-default justify-center">
                Current Plan
              </div>
            ) : (
              <button
                onClick={() => onNavigate({ name: 'auth' })}
                className="btn-secondary w-full"
              >
                Create Free Account
              </button>
            )}
          </div>

          {/* Premium plan */}
          <div className="card p-8 flex flex-col border-premium-500/40 relative overflow-hidden">
            <div className="absolute -right-16 -top-16 w-48 h-48 rounded-full bg-premium-500/10 blur-3xl" />
            <div className="absolute top-4 right-4">
              <span className="badge-premium">Most Popular</span>
            </div>
            <div className="flex items-center gap-3 mb-5">
              <div className="w-11 h-11 rounded-lg bg-premium-500/15 flex items-center justify-center">
                <Crown className="w-5 h-5 text-premium-400" />
              </div>
              <div>
                <h2 className="font-display text-xl font-bold text-white">Premium</h2>
                <p className="text-xs text-steel-400">All four stages unlocked</p>
              </div>
            </div>
            <div className="mb-6">
              <span className="font-display text-4xl font-bold text-white">$19.99</span>
              <span className="text-steel-400 text-sm ml-1">/month</span>
              <p className="mt-2 text-sm text-premium-300">
                Beta: 75% off with code <span className="font-mono font-semibold text-white">75OFF</span>
              </p>
            </div>
            <ul className="space-y-3 mb-8 flex-1">
              {[
                'Everything in Free, plus:',
                'All 78 courses across four stages',
                'AI Course Tutor — ask questions about any lesson and get instant, plant-floor answers from an AI industrial specialist',
                'Custom Courses — get personalized training built specifically for you and your plant',
                'I&E Instrumentation (18 courses): HART, control valves, DCS, Fieldbus, loop tuning',
                'Engineering (16 courses): PLC best practices, network design, reliability engineering',
                'Advanced Motion & Safety Systems (SIL, IEC 62061)',
                'Predictive maintenance strategy & Weibull analysis',
                'Priority certificate verification',
                'Full career ladder progression across all four stages',
              ].map((f, i) => (
                <li
                  key={f}
                  className={`flex items-start gap-2.5 text-sm ${i === 0 ? 'text-steel-400 font-semibold' : 'text-steel-200'}`}
                >
                  <Check className="w-4 h-4 text-premium-400 shrink-0 mt-0.5" />
                  {f}
                </li>
              ))}
            </ul>

            {/* Subscription status info */}
            {isPremium && !subLoading && activeSub && (
              <div className="mb-4 p-3 rounded-lg bg-success-500/10 border border-success-500/20">
                <div className="flex items-center gap-2 text-sm text-success-300 mb-1">
                  <Check className="w-4 h-4" />
                  Premium Active
                </div>
                {cancelledPending && periodEnd && (
                  <p className="text-xs text-warning-400 mt-1">
                    Cancellation scheduled for {periodEnd}. You'll keep access until then.
                  </p>
                )}
                {subscription?.payment_method_brand && (
                  <p className="text-xs text-steel-400 mt-1">
                    {subscription.payment_method_brand.toUpperCase()} ending in {subscription.payment_method_last4}
                  </p>
                )}
              </div>
            )}

            {isAdmin ? (
              <div className="flex items-center justify-center gap-2 text-accent-300 font-semibold py-2.5">
                <Shield className="w-5 h-5" />
                Admin — All Access
              </div>
            ) : isPremium ? (
              <button
                onClick={handleManageBilling}
                disabled={loading}
                className="btn-premium w-full"
              >
                {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Settings className="w-4 h-4" />}
                Manage Subscription
              </button>
            ) : user ? (
              <button
                onClick={handleCheckout}
                disabled={loading}
                className="btn-premium w-full"
              >
                {loading ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" />
                    Redirecting to checkout...
                  </>
                ) : (
                  <>
                    <CreditCard className="w-4 h-4" />
                    Upgrade to Premium
                    <ArrowRight className="w-4 h-4" />
                  </>
                )}
              </button>
            ) : (
              <button
                onClick={() => onNavigate({ name: 'auth' })}
                className="btn-premium w-full"
              >
                Create Account to Upgrade
                <ArrowRight className="w-4 h-4" />
              </button>
            )}
            {user && !isPremium && !isAdmin && (
              <p className="text-xs text-steel-500 text-center mt-3">
                Secure checkout powered by Stripe. Cancel anytime.
              </p>
            )}
          </div>
        </div>

        {error && (
          <div className="mt-6 flex items-center gap-2 p-4 rounded-lg bg-error-500/10 border border-error-500/30 text-error-400 text-sm">
            <AlertCircle className="w-4 h-4 shrink-0" />
            {error}
          </div>
        )}

        {/* Promo / Referral code input */}
        {user && !isPremium && !isAdmin && (
          <div className="mt-6 card p-5">
            <div className="flex items-center gap-2 mb-3">
              <Tag className="w-4 h-4 text-accent-400" />
              <h3 className="text-sm font-semibold text-white">Have a promo or referral code?</h3>
            </div>
            <div className="flex gap-2">
              <input
                type="text"
                value={promoCode}
                onChange={(e) => { setPromoCode(e.target.value.toUpperCase()); setPromoMessage(null); setPromoValid(false); }}
                placeholder="75OFF"
                className="input flex-1 uppercase"
              />
              <button
                onClick={handleValidateCode}
                disabled={validating || !promoCode.trim()}
                className="btn-secondary"
              >
                {validating ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Apply'}
              </button>
            </div>
            {promoMessage && (
              <div className={`mt-2 flex items-center gap-2 text-sm ${promoValid ? 'text-success-400' : 'text-error-400'}`}>
                {promoValid ? <Check className="w-4 h-4" /> : <AlertCircle className="w-4 h-4" />}
                {promoMessage}
              </div>
            )}
          </div>
        )}

        {/* Referral program section */}
        {user && (
          <div className="mt-6 card p-6 border-premium-500/20">
            <div className="flex items-center gap-2 mb-4">
              <Gift className="w-5 h-5 text-premium-400" />
              <h3 className="font-display text-lg font-semibold text-white">Refer & Earn</h3>
            </div>
            <p className="text-sm text-steel-400 mb-4">
              Share your referral code with colleagues. When {REFERRALS_NEEDED} people subscribe to Premium using your code, you get a free month of Premium.
            </p>
            {referralCode ? (
              <div className="space-y-4">
                <div className="flex items-center gap-2">
                  <div className="flex-1 px-4 py-3 rounded-lg bg-navy-950/60 border border-steel-700/60 font-mono text-lg font-bold text-premium-300 tracking-wider">
                    {referralCode}
                  </div>
                  <button
                    onClick={() => {
                      navigator.clipboard.writeText(referralCode);
                      setCopied(true);
                      setTimeout(() => setCopied(false), 2000);
                    }}
                    className="btn-premium"
                  >
                    {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                    {copied ? 'Copied!' : 'Copy'}
                  </button>
                </div>
                <div>
                  <div className="flex items-center justify-between mb-1.5">
                    <span className="text-xs text-steel-400 flex items-center gap-1.5">
                      <Users className="w-3.5 h-3.5" />
                      {referralCount} of {REFERRALS_NEEDED} referrals
                    </span>
                    <span className="text-xs font-medium text-premium-400">
                      {referralCount >= REFERRALS_NEEDED ? 'Free month earned!' : `${REFERRALS_NEEDED - referralCount} more for a free month`}
                    </span>
                  </div>
                  <div className="h-2 rounded-full bg-navy-800 overflow-hidden">
                    <div
                      className="h-full rounded-full bg-premium-500 transition-all duration-500"
                      style={{ width: `${Math.min((referralCount / REFERRALS_NEEDED) * 100, 100)}%` }}
                    />
                  </div>
                </div>
              </div>
            ) : referralLoading ? (
              <div className="flex items-center gap-2 text-sm text-steel-500">
                <Loader2 className="w-4 h-4 animate-spin" /> Loading your referral code...
              </div>
            ) : (
              <div className="space-y-2">
                <p className="text-sm text-steel-400">
                  {referralError || 'Your referral code is not available yet.'}
                </p>
                <button
                  type="button"
                  className="btn-secondary text-sm"
                  onClick={() => setReferralReload((n) => n + 1)}
                >
                  Try again
                </button>
              </div>
            )}
          </div>
        )}


                        {/* Plant seats — online company membership; request via /request?seats= */}
        <div id="online-seats" className="mt-10">
          <h2 className="font-display text-2xl font-bold text-white mb-2">Online plant seats.</h2>
          <div className="mb-3 p-3 rounded-lg bg-accent-500/10 border border-accent-500/30">
            <p className="text-sm font-semibold text-white">
              Company memberships so your crew trains <span className="text-accent-300">ONLINE</span> on ForgeLine.
            </p>
            <p className="text-sm font-semibold text-warning-400 mt-1">
              NOT an on-site visit or plant trip.
            </p>
          </div>
          <div className="mb-5 p-3 rounded-lg bg-navy-800/60 border border-steel-700/60">
            <p className="text-xs text-steel-300">
              <span className="font-semibold text-white">After you request:</span> Kris adds your company and sets up your company page at <span className="font-mono text-accent-300">/company</span> — where your crew members sign up and your seats are managed.
            </p>
          </div>
          <div className="grid sm:grid-cols-2 gap-4">
            <div className="card p-6 flex flex-col border-rok-500/30">
              <p className="text-xs font-semibold uppercase tracking-wider text-rok-300 mb-2">Online · company seats</p>
              <h3 className="font-display text-lg font-bold text-white">Plant 5-seat</h3>
              <p className="mt-2">
                <span className="font-display text-3xl font-bold text-white">$129</span>
                <span className="text-steel-400 text-sm ml-1">/mo</span>
              </p>
              <p className="text-sm text-steel-400 mt-2 mb-5">Five online Premium seats for your crew. Train on ForgeLine from the shop or home — no plant visit included.</p>
              <button
                type="button"
                onClick={() => { window.location.assign('/request?seats=5'); }}
                className="btn-primary w-full mt-auto"
              >
                Request seats for company
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
            <div className="card p-6 flex flex-col border-rok-500/30">
              <p className="text-xs font-semibold uppercase tracking-wider text-rok-300 mb-2">Online · company seats</p>
              <h3 className="font-display text-lg font-bold text-white">Plant 10-seat</h3>
              <p className="mt-2">
                <span className="font-display text-3xl font-bold text-white">$229</span>
                <span className="text-steel-400 text-sm ml-1">/mo</span>
              </p>
              <p className="text-sm text-steel-400 mt-2 mb-5">Ten online Premium seats for your crew. Train on ForgeLine from the shop or home — no plant visit included.</p>
              <button
                type="button"
                onClick={() => { window.location.assign('/request?seats=10'); }}
                className="btn-primary w-full mt-auto"
              >
                Request seats for company
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>

        {/* On-site — separate intake on /request, no seat prices */}
        <div className="mt-6 rounded-xl border border-rok-500/20 bg-gradient-to-br from-navy-800/60 to-navy-950/40 p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-lg bg-rok-500/15 border border-rok-500/30 flex items-center justify-center shrink-0">
              <Wrench className="w-5 h-5 text-rok-400" />
            </div>
            <div>
              <h3 className="text-sm font-semibold text-white">On-site training and plant visits</h3>
              <p className="text-xs text-steel-400 mt-0.5">Quoted by Kris for your facility. Separate from online plant seats — no seat price on this path.</p>
            </div>
          </div>
          <button
            type="button"
            onClick={() => { window.location.assign('/request?intent=onsite'); }}
            className="btn-secondary text-sm shrink-0"
          >
            Request on-site quote
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>

{/* Comparison note */}
        <div className="mt-12 card p-6">
          <h3 className="font-display text-lg font-semibold text-white mb-3">
            Why the ladder?
          </h3>
          <p className="text-sm text-steel-300 leading-relaxed">
            Industrial maintenance is a progression. Mechanical and Electrical
            fundamentals are the bedrock — every tech needs them, so they're free.
            I&amp;E and Engineering build on that foundation with advanced
            instrumentation, control systems, and reliability engineering. Premium
            unlocks those upper stages when you're ready to move up.
          </p>
        </div>
      </div>
    </div>
  );
}
