export type ConversionEvent = 'signup_free' | 'premium_checkout' | 'plant_lead' | 'page_view';

declare global {
  interface Window {
    dataLayer?: unknown[];
    gtag?: (...args: unknown[]) => void;
  }
}

function dl(): unknown[] {
  window.dataLayer = window.dataLayer ?? [];
  return window.dataLayer;
}

export function initAnalytics() {
  try {
    dl();
    const id = (import.meta.env.VITE_GA_MEASUREMENT_ID as string | undefined)?.trim();
    if (!id) return;
    if (document.querySelector(`script[src*="googletagmanager.com/gtag/js?id=${id}"]`)) return;
    const s = document.createElement('script');
    s.async = true;
    s.src = `https://www.googletagmanager.com/gtag/js?id=${encodeURIComponent(id)}`;
    document.head.appendChild(s);
    window.gtag = function gtag(...args: unknown[]) {
      dl().push(args);
    };
    window.gtag('js', new Date());
    window.gtag('config', id, { anonymize_ip: true, send_page_view: false });
  } catch {
    // never throw from analytics
  }
}

export function track(event: ConversionEvent, props?: Record<string, string>) {
  const payload = { event, ...(props ?? {}), ts: Date.now() };
  try {
    dl().push(payload);
    if (typeof window.gtag === 'function') window.gtag('event', event, props ?? {});
  } catch {
    // never throw from analytics
  }
}

export function trackPageView(page: string) {
  track('page_view', { page });
}
