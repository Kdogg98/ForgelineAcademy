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

export function trackPageView(page: string) {
  track('page_view', { page });
}
