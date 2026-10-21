export type ConversionEvent = 'signup_free' | 'premium_checkout' | 'plant_lead' | 'page_view';

declare global {
  interface Window {
    dataLayer?: unknown[];
    gtag?: (...args: unknown[]) => void;
  }
}

const GOOGLE_ADS_ID = 'AW-614658774';
const SIGNUP_SEND_TO = 'AW-614658774/z_l2CJjE9OYcENbli6UC';
const PURCHASE_SEND_TO = 'AW-614658774/lXc9CJXE9OYcENbli6UC';

function dl(): unknown[] {
  window.dataLayer = window.dataLayer ?? [];
  return window.dataLayer;
}

function ensureGtag() {
  if (typeof window.gtag === 'function') return;
  window.gtag = function gtag(...args: unknown[]) {
    dl().push(args);
  };
}

function loadGtagScript(id: string) {
  if (document.querySelector(`script[src*="googletagmanager.com/gtag/js?id=${id}"]`)) return;
  const s = document.createElement('script');
  s.async = true;
  s.src = `https://www.googletagmanager.com/gtag/js?id=${encodeURIComponent(id)}`;
  document.head.appendChild(s);
}

function fireConversion(sendTo: string, extra?: Record<string, string | number>) {
  if (typeof window.gtag !== 'function') return;
  window.gtag('event', 'conversion', { send_to: sendTo, ...(extra ?? {}) });
}

export function initAnalytics() {
  try {
    dl();
    ensureGtag();
    const gaId = (import.meta.env.VITE_GA_MEASUREMENT_ID as string | undefined)?.trim();
    loadGtagScript(GOOGLE_ADS_ID);
    window.gtag!('js', new Date());
    window.gtag!('config', GOOGLE_ADS_ID, { anonymize_ip: true, send_page_view: false });
    if (gaId && gaId !== GOOGLE_ADS_ID) {
      window.gtag!('config', gaId, { anonymize_ip: true, send_page_view: false });
    }
  } catch {
    // never throw from analytics
  }
}

export function track(event: ConversionEvent, props?: Record<string, string | number>) {
  const payload = { event, ...(props ?? {}), ts: Date.now() };
  try {
    dl().push(payload);
    if (typeof window.gtag === 'function') window.gtag('event', event, props ?? {});
    if (event === 'signup_free') {
      fireConversion(SIGNUP_SEND_TO);
    }
    if (event === 'premium_checkout') {
      const valueRaw = props?.value;
      const value = typeof valueRaw === 'number' ? valueRaw : Number(valueRaw);
      fireConversion(PURCHASE_SEND_TO, {
        value: Number.isFinite(value) ? value : 19.99,
        currency: String(props?.currency ?? 'USD'),
        transaction_id: String(props?.transaction_id ?? `ck-${Date.now()}`),
      });
    }
  } catch {
    // never throw from analytics
  }
}

export const GA_MEASUREMENT_ID = 'G-22N6KP9BVR';

// The gtag.js snippet in every HTML entry already sends the initial page_view
// (send_page_view: true), so the first SPA location is skipped to avoid a double count.
let lastPageLocation: string | null = null;

export function trackPageView(_page?: string) {
  try {
    const href = window.location.href;
    if (lastPageLocation === null) {
      lastPageLocation = href;
      return;
    }
    if (href === lastPageLocation) return;
    lastPageLocation = href;
    if (typeof window.gtag !== 'function') return;
    window.gtag('event', 'page_view', {
      send_to: GA_MEASUREMENT_ID,
      page_path: window.location.pathname + window.location.search,
      page_location: href, // full URL incl. query string (UTM params)
      page_title: document.title,
    });
  } catch {
    // never throw from analytics
  }
}

/** GA4 recommended event: account created via email/password (Supabase signUp). */
export function trackSignUp() {
  try {
    if (typeof window.gtag === 'function') window.gtag('event', 'sign_up', { method: 'email' });
  } catch {
    // never throw from analytics
  }
}

/** GA4 recommended event: /request training form submitted successfully. */
export function trackGenerateLead(props?: Record<string, string | number>) {
  try {
    if (typeof window.gtag === 'function') window.gtag('event', 'generate_lead', props ?? {});
  } catch {
    // never throw from analytics
  }
}

/**
 * GA4 recommended event: purchase. Fired once per Stripe Checkout session when the
 * user lands back on the success URL. Deduped via sessionStorage + localStorage keyed
 * by transaction id so reloading the success page does not double count.
 * Does not touch the existing Google Ads PURCHASE_SEND_TO conversion.
 */
export function trackPurchase(params: {
  transaction_id: string;
  item_name: string;
  value?: number;
  currency?: string;
}): boolean {
  try {
    if (!params.transaction_id) return false;
    const key = `ga4_purchase_${params.transaction_id}`;
    try {
      if (window.sessionStorage.getItem(key) || window.localStorage.getItem(key)) return false;
    } catch {
      // storage unavailable: still fire once for this page load
    }
    if (typeof window.gtag !== 'function') return false;
    const payload: Record<string, unknown> = {
      transaction_id: params.transaction_id,
      currency: params.currency ?? 'USD',
      items: [{ item_name: params.item_name }],
    };
    if (typeof params.value === 'number' && Number.isFinite(params.value)) payload.value = params.value;
    window.gtag('event', 'purchase', payload);
    try {
      window.sessionStorage.setItem(key, '1');
      window.localStorage.setItem(key, '1');
    } catch {
      // ignore
    }
    return true;
  } catch {
    return false;
  }
}
