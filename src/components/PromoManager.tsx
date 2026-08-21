import { useCallback, useEffect, useState } from 'react';
import {
  Plus,
  Trash2,
  Tag,
  Loader2,
  CheckCircle2,
  X,
  Percent,
  DollarSign,
  Users,
  TrendingUp,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';

interface PromoCode {
  id: string;
  code: string;
  stripe_coupon_id: string;
  description: string | null;
  discount_percent: number | null;
  discount_amount_cents: number | null;
  max_redemptions: number | null;
  redemptions_count: number;
  active: boolean;
  expires_at: string | null;
  created_at: string;
}

interface ReferralRow {
  code: string;
  referrals_count: number;
  free_months_earned: number;
  user_email: string | null;
}

export function PromoManager() {
  const [promos, setPromos] = useState<PromoCode[]>([]);
  const [referrals, setReferrals] = useState<ReferralRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const [newCode, setNewCode] = useState('');
  const [newCouponId, setNewCouponId] = useState('');
  const [newDescription, setNewDescription] = useState('');
  const [discountType, setDiscountType] = useState<'percent' | 'amount'>('percent');
  const [discountValue, setDiscountValue] = useState('');
  const [maxRedemptions, setMaxRedemptions] = useState('');
  const [creating, setCreating] = useState(false);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const { data: promoData, error: promoErr } = await supabase
        .from('promo_codes')
        .select('*')
        .order('created_at', { ascending: false });
      if (promoErr) throw promoErr;
      setPromos((promoData ?? []) as unknown as PromoCode[]);

      const { data: refData } = await supabase
        .from('referral_codes')
        .select('code, referrals_count, free_months_earned, user_id')
        .order('referrals_count', { ascending: false });
      if (refData && refData.length > 0) {
        const enriched = await Promise.all(
          (refData as unknown as { code: string; referrals_count: number; free_months_earned: number; user_id: string }[]).map(
            async (r) => {
              const { data: prof } = await supabase
                .rpc('list_users_for_admin')
                .then(({ data }) => ({ data }));
              const users = (data as unknown as { id: string; email: string }[]) ?? [];
              const email = users.find((u) => u.id === r.user_id)?.email ?? null;
              return { ...r, user_email: email } as ReferralRow;
            },
          ),
        );
        setReferrals(enriched);
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load data');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  useEffect(() => {
    if (error) {
      const t = setTimeout(() => setError(null), 5000);
      return () => clearTimeout(t);
    }
  }, [error]);

  useEffect(() => {
    if (success) {
      const t = setTimeout(() => setSuccess(null), 5000);
      return () => clearTimeout(t);
    }
  }, [success]);

  async function handleCreate() {
    setError(null);
    if (!newCode.trim() || !newCouponId.trim()) {
      setError('Code and Stripe Coupon ID are required.');
      return;
    }
    setCreating(true);
    try {
      const { error: insertErr } = await supabase.from('promo_codes').insert({
        code: newCode.trim().toUpperCase(),
        stripe_coupon_id: newCouponId.trim(),
        description: newDescription.trim() || null,
        discount_percent: discountType === 'percent' ? parseInt(discountValue) || null : null,
        discount_amount_cents: discountType === 'amount' ? Math.round(parseFloat(discountValue) * 100) || null : null,
        max_redemptions: maxRedemptions ? parseInt(maxRedemptions) : null,
        created_by: (await supabase.auth.getUser()).data.user?.id,
      });
      if (insertErr) throw insertErr;

      setSuccess(`Promo code "${newCode.trim().toUpperCase()}" created.`);
      setNewCode('');
      setNewCouponId('');
      setNewDescription('');
      setDiscountValue('');
      setMaxRedemptions('');
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to create promo code');
    } finally {
      setCreating(false);
    }
  }

  async function handleToggle(promoId: string, currentActive: boolean) {
    const { error: updateErr } = await supabase
      .from('promo_codes')
      .update({ active: !currentActive })
      .eq('id', promoId);
    if (updateErr) {
      setError(updateErr.message);
      return;
    }
    await loadData();
  }

  async function handleDelete(promoId: string, code: string) {
    if (!confirm(`Delete promo code "${code}"?`)) return;
    const { error: delErr } = await supabase.from('promo_codes').delete().eq('id', promoId);
    if (delErr) {
      setError(delErr.message);
      return;
    }
    setSuccess(`Promo code "${code}" deleted.`);
    await loadData();
  }

  return (
    <div className="space-y-8">
      {/* Promo codes list */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <Tag className="w-5 h-5 text-accent-400" />
          <h2 className="text-lg font-semibold text-white">Promo Codes</h2>
        </div>

        {loading ? (
          <div className="flex items-center gap-2 text-sm text-steel-400 py-4">
            <Loader2 className="w-4 h-4 animate-spin" /> Loading...
          </div>
        ) : promos.length === 0 ? (
          <div className="card p-6 text-center">
            <Tag className="w-8 h-8 text-steel-600 mx-auto mb-2" />
            <p className="text-sm text-steel-400">No promo codes yet. Create one below.</p>
          </div>
        ) : (
          <div className="space-y-2">
            {promos.map((p) => (
              <div key={p.id} className="card p-4 flex items-center justify-between">
                <div className="min-w-0">
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-sm font-bold text-white">{p.code}</span>
                    <span className={`text-[10px] px-1.5 py-0.5 rounded-full font-medium ${p.active ? 'bg-success-500/15 text-success-400 border border-success-500/30' : 'bg-steel-800 text-steel-500 border border-steel-700'}`}>
                      {p.active ? 'Active' : 'Inactive'}
                    </span>
                  </div>
                  <div className="flex items-center gap-3 mt-1">
                    {p.discount_percent != null && (
                      <span className="text-xs text-accent-300 flex items-center gap-1">
                        <Percent className="w-3 h-3" /> {p.discount_percent}% off
                      </span>
                    )}
                    {p.discount_amount_cents != null && (
                      <span className="text-xs text-accent-300 flex items-center gap-1">
                        <DollarSign className="w-3 h-3" /> ${(p.discount_amount_cents / 100).toFixed(2)} off
                      </span>
                    )}
                    <span className="text-xs text-steel-500">
                      {p.redemptions_count}{p.max_redemptions ? ` / ${p.max_redemptions}` : ''} used
                    </span>
                    {p.expires_at && (
                      <span className="text-xs text-steel-600">
                        expires {new Date(p.expires_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                      </span>
                    )}
                  </div>
                  {p.description && <p className="text-xs text-steel-500 mt-1">{p.description}</p>}
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  <button
                    onClick={() => handleToggle(p.id, p.active)}
                    className="px-2.5 py-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-accent-300 hover:border-accent-500/40 transition-colors text-xs font-medium"
                  >
                    {p.active ? 'Deactivate' : 'Activate'}
                  </button>
                  <button
                    onClick={() => handleDelete(p.id, p.code)}
                    className="p-1.5 rounded-lg text-steel-400 hover:text-error-400 hover:bg-error-500/10 transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* Create new promo code */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <Plus className="w-5 h-5 text-premium-400" />
          <h2 className="text-lg font-semibold text-white">Create New Promo Code</h2>
        </div>

        <div className="card p-6 space-y-4">
          <p className="text-xs text-steel-500">
            First create a coupon in your Stripe Dashboard, then enter the Coupon ID below to link it to a promo code users can enter at checkout.
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Promo Code (what users type)</label>
              <input
                value={newCode}
                onChange={(e) => setNewCode(e.target.value.toUpperCase())}
                placeholder="e.g. SUMMER25"
                className="input uppercase"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Stripe Coupon ID</label>
              <input
                value={newCouponId}
                onChange={(e) => setNewCouponId(e.target.value)}
                placeholder="e.g. coupon_abc123"
                className="input"
              />
            </div>
            <div className="md:col-span-2">
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Description (optional)</label>
              <input
                value={newDescription}
                onChange={(e) => setNewDescription(e.target.value)}
                placeholder="e.g. Summer 25% off promotion"
                className="input"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Discount Type</label>
              <select
                value={discountType}
                onChange={(e) => setDiscountType(e.target.value as 'percent' | 'amount')}
                className="input"
              >
                <option value="percent">Percentage</option>
                <option value="amount">Fixed Amount ($)</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Discount Value</label>
              <input
                type="number"
                value={discountValue}
                onChange={(e) => setDiscountValue(e.target.value)}
                placeholder={discountType === 'percent' ? '25' : '5.00'}
                className="input"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Max Redemptions (optional)</label>
              <input
                type="number"
                value={maxRedemptions}
                onChange={(e) => setMaxRedemptions(e.target.value)}
                placeholder="Unlimited"
                className="input"
              />
            </div>
          </div>

          {error && (
            <div className="flex items-start gap-3 p-3 rounded-lg bg-error-950/50 border border-error-700/50">
              <X className="w-4 h-4 text-error-400 flex-shrink-0 mt-0.5 cursor-pointer" onClick={() => setError(null)} />
              <p className="text-sm text-error-200">{error}</p>
            </div>
          )}
          {success && (
            <div className="flex items-start gap-3 p-3 rounded-lg bg-success-950/50 border border-success-700/50">
              <CheckCircle2 className="w-4 h-4 text-success-400 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-success-200">{success}</p>
            </div>
          )}

          <div className="flex items-center justify-end">
            <button onClick={handleCreate} disabled={creating} className="btn-premium">
              {creating ? <Loader2 className="w-4 h-4 animate-spin" /> : <Plus className="w-4 h-4" />}
              {creating ? 'Creating...' : 'Create Promo Code'}
            </button>
          </div>
        </div>
      </section>

      {/* Referral activity */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <Users className="w-5 h-5 text-accent-400" />
          <h2 className="text-lg font-semibold text-white">Referral Activity</h2>
        </div>

        {loading ? (
          <div className="flex items-center gap-2 text-sm text-steel-400 py-4">
            <Loader2 className="w-4 h-4 animate-spin" /> Loading...
          </div>
        ) : referrals.length === 0 ? (
          <div className="card p-6 text-center">
            <Users className="w-8 h-8 text-steel-600 mx-auto mb-2" />
            <p className="text-sm text-steel-400">No referral activity yet.</p>
          </div>
        ) : (
          <div className="space-y-2">
            {referrals.map((r) => (
              <div key={r.code} className="card p-4 flex items-center justify-between">
                <div className="min-w-0">
                  <span className="font-mono text-sm font-bold text-white">{r.code}</span>
                  {r.user_email && <span className="text-xs text-steel-500 ml-2">{r.user_email}</span>}
                </div>
                <div className="flex items-center gap-4 shrink-0">
                  <div className="flex items-center gap-1.5 text-xs text-steel-400">
                    <TrendingUp className="w-3.5 h-3.5" />
                    {r.referrals_count} referrals
                  </div>
                  <div className="flex items-center gap-1.5 text-xs text-premium-400">
                    <CheckCircle2 className="w-3.5 h-3.5" />
                    {r.free_months_earned} free months
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
