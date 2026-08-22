import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import Stripe from 'npm:stripe@17.7.0';
import { createClient } from 'npm:@supabase/supabase-js@2.49.1';

const supabase = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
const stripeSecret = Deno.env.get('STRIPE_SECRET_KEY')!;
const stripe = new Stripe(stripeSecret, {
  appInfo: { name: 'Bolt Integration', version: '1.0.0' },
});

const REFERRAL_COUPON_ID = Deno.env.get('STRIPE_REFERRAL_COUPON_ID') ?? '';
const REFERRALS_FOR_FREE_MONTH = 3;

function corsResponse(body: string | object | null, status = 200) {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': '*',
  };
  if (status === 204) return new Response(null, { status, headers });
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...headers, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req) => {
  try {
    if (req.method === 'OPTIONS') return corsResponse({}, 204);
    if (req.method !== 'POST') return corsResponse({ error: 'Method not allowed' }, 405);

    const { price_id, success_url, cancel_url, mode, promo_code } = await req.json();

    if (!price_id || !success_url || !cancel_url || !mode) {
      return corsResponse({ error: 'Missing required parameters' }, 400);
    }

    const authHeader = req.headers.get('Authorization')!;
    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: getUserError } = await supabase.auth.getUser(token);

    if (getUserError || !user) {
      return corsResponse({ error: 'Failed to authenticate user' }, 401);
    }

    // Get or create Stripe customer
    const { data: customer } = await supabase
      .from('stripe_customers')
      .select('customer_id')
      .eq('user_id', user.id)
      .is('deleted_at', null)
      .maybeSingle();

    let customerId = customer?.customer_id;

    if (!customerId) {
      const newCustomer = await stripe.customers.create({
        email: user.email,
        metadata: { userId: user.id },
      });

      await supabase.from('stripe_customers').insert({
        user_id: user.id,
        customer_id: newCustomer.id,
      });

      if (mode === 'subscription') {
        await supabase.from('stripe_subscriptions').insert({
          customer_id: newCustomer.id,
          status: 'not_started',
        });
      }

      customerId = newCustomer.id;
    }

    // Validate promo/referral code if provided
    let discounts: Stripe.Checkout.SessionCreateParams.Discount[] = [];
    let referralReferrerId: string | null = null;
    let referralCode: string | null = null;
    let promoCodeUsed: string | null = null;

    if (promo_code) {
      const { data: validation } = await supabase.rpc('validate_code', {
        p_code: promo_code,
        p_user_id: user.id,
      });

      const rows = Array.isArray(validation) ? validation : validation ? [validation] : [];
      const result = rows[0] as {
        code_type: string;
        valid: boolean;
        referrer_id: string | null;
        stripe_coupon_id: string | null;
        message: string;
      } | undefined;

      if (!result?.valid) {
        return corsResponse({ error: result?.message ?? 'Invalid code' }, 400);
      }

      if (result.code_type === 'promo' && result.stripe_coupon_id) {
        discounts = [{ coupon: result.stripe_coupon_id }];
        promoCodeUsed = promo_code;
      } else if (result.code_type === 'referral' && result.referrer_id) {
        referralReferrerId = result.referrer_id;
        referralCode = promo_code;
        if (REFERRAL_COUPON_ID) {
          discounts = [{ coupon: REFERRAL_COUPON_ID }];
        }
      }
    }

    // Create checkout session
    const sessionParams: Stripe.Checkout.SessionCreateParams = {
      customer: customerId,
      payment_method_types: ['card'],
      line_items: [{ price: price_id, quantity: 1 }],
      mode,
      success_url,
      cancel_url,
    };

    if (discounts.length > 0) {
      sessionParams.discounts = discounts;
    }

    // Store referral/promo metadata on the session for webhook processing
    if (referralReferrerId || promoCodeUsed) {
      sessionParams.metadata = {};
      if (referralReferrerId) sessionParams.metadata.referral_referrer_id = referralReferrerId;
      if (referralCode) sessionParams.metadata.referral_code = referralCode;
      if (promoCodeUsed) sessionParams.metadata.promo_code = promoCodeUsed;
    }

    const session = await stripe.checkout.sessions.create(sessionParams);

    return corsResponse({ sessionId: session.id, url: session.url });
  } catch (error: any) {
    console.error(`Promo checkout error: ${error.message}`);
    return corsResponse({ error: error.message }, 500);
  }
});
