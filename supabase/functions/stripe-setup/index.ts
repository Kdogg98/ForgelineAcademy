import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import Stripe from 'npm:stripe@17.7.0';

const stripeSecret = Deno.env.get('STRIPE_SECRET_KEY')!;
const stripe = new Stripe(stripeSecret, {
  appInfo: { name: 'Bolt Integration', version: '1.0.0' },
});

Deno.serve(async (req) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': '*',
    'Content-Type': 'application/json',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers });
  }

  try {
    const { data: products } = await stripe.products.list({ limit: 100 });
    let product = products.find((p) => p.name === 'ForgeLine Academy Premium');

    if (!product) {
      product = await stripe.products.create({
        name: 'ForgeLine Academy Premium',
        description: 'Full access to all four stages: Mechanical, Electrical, I&E Instrumentation, and Engineering.',
      });
    }

    const { data: prices } = await stripe.prices.list({ product: product.id, limit: 10 });
    let price = prices.find((p) => p.recurring?.interval === 'month' && p.unit_amount === 1999);

    if (!price) {
      price = await stripe.prices.create({
        product: product.id,
        unit_amount: 1999,
        currency: 'usd',
        recurring: { interval: 'month' },
      });
    }

    return new Response(JSON.stringify({ price_id: price.id, product_id: product.id }), { status: 200, headers });
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500, headers });
  }
});
