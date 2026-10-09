/**
 * Company theme state outside React: building, applying and caching themes.
 *
 * Storage (mirrored by the inline boot script in index.html, keep in sync):
 *   localStorage   fl_company_theme:<userId>  last theme of a signed-in member (flash-free reloads)
 *   sessionStorage fl_theme_preview           master-admin "Preview site as <company>"
 */
import type { Company, CompanyDraft, CompanyTrack } from '@/lib/types';
import { brandFromCompany, brandFromDraft, faviconLogo, type BrandColors } from '@/lib/companyBrand';
import { buildPalette, initialsBadgeDataUri, paletteToVars, rgbToHex } from './colors';

export interface ThemeCompany {
  id: string | null;
  name: string;
  logoUrl: string | null;
  domain: string | null;
  industry: string | null;
  summary: string | null;
  locations: string[];
  tracks: CompanyTrack[];
  brand: BrandColors;
  published: boolean;
}

export interface StoredTheme {
  v: 1;
  company: ThemeCompany;
  vars: Record<string, string>;
  favicon: string;
  title: string;
}

export const CACHE_PREFIX = 'fl_company_theme:';
export const PREVIEW_KEY = 'fl_theme_preview';
const DEFAULT_FAVICON = '/favicon.svg';

/** A member's company re-themes the site only when it is published, premium and active. */
export function companyQualifies(c: Company | null | undefined): c is Company {
  return !!c && c.published === true && c.premium === true && c.active === true;
}

export function themeCompanyFromRow(c: Company): ThemeCompany {
  const p = c.profile ?? {};
  return {
    id: c.id,
    name: c.name,
    logoUrl: c.logo_url || null,
    domain: c.domain || null,
    industry: c.industry || null,
    summary: p.summary || null,
    locations: p.locations ?? [],
    tracks: p.suggested_tracks ?? [],
    brand: brandFromCompany(c),
    published: c.published === true,
  };
}

export function themeCompanyFromDraft(d: CompanyDraft, id: string | null, published: boolean): ThemeCompany {
  return {
    id,
    name: d.name || 'Company',
    logoUrl: d.logo_url || null,
    domain: d.domain || null,
    industry: d.industry || null,
    summary: d.summary || null,
    locations: d.locations ?? [],
    tracks: d.suggested_tracks ?? [],
    brand: brandFromDraft(d),
    published,
  };
}

export function academyName(name: string): string {
  const n = name.trim();
  return /\bacademy$/i.test(n) ? n : `${n} Academy`;
}

/** "<Company> Academy | ForgeLine", with an optional page prefix. */
export function brandedTitle(company: Pick<ThemeCompany, 'name'>, page?: string | null): string {
  const base = `${academyName(company.name)} | ForgeLine`;
  return page ? `${page} | ${base}` : base;
}

export function buildStoredTheme(company: ThemeCompany): StoredTheme {
  const palette = buildPalette(company.brand);
  return {
    v: 1,
    company,
    vars: paletteToVars(palette),
    favicon:
      company.logoUrl ||
      faviconLogo(company.domain) ||
      initialsBadgeDataUri(company.name, rgbToHex(palette.rok[500]), rgbToHex(palette.onRok)),
    title: brandedTitle(company),
  };
}

function safeParse(raw: string | null): StoredTheme | null {
  if (!raw) return null;
  try {
    const t = JSON.parse(raw) as StoredTheme;
    return t && t.v === 1 && t.company && t.vars ? t : null;
  } catch {
    return null;
  }
}

function storage(kind: 'local' | 'session'): Storage | null {
  try {
    return kind === 'local' ? window.localStorage : window.sessionStorage;
  } catch {
    return null;
  }
}

export const readCachedTheme = (userId: string) => safeParse(storage('local')?.getItem(CACHE_PREFIX + userId) ?? null);
export const writeCachedTheme = (userId: string, t: StoredTheme) => storage('local')?.setItem(CACHE_PREFIX + userId, JSON.stringify(t));
export const clearCachedTheme = (userId: string) => storage('local')?.removeItem(CACHE_PREFIX + userId);
/** Remove every cached member theme (sign-out: no user's company should survive). */
export function clearAllCachedThemes() {
  const ls = storage('local');
  if (!ls) return;
  const keys: string[] = [];
  for (let i = 0; i < ls.length; i++) {
    const key = ls.key(i);
    if (key?.startsWith(CACHE_PREFIX)) keys.push(key);
  }
  keys.forEach((k) => ls.removeItem(k));
}
export const readPreview = () => safeParse(storage('session')?.getItem(PREVIEW_KEY) ?? null);
export const writePreview = (t: StoredTheme) => storage('session')?.setItem(PREVIEW_KEY, JSON.stringify(t));
export const clearPreview = () => storage('session')?.removeItem(PREVIEW_KEY);

/** User id of the persisted Supabase session, read synchronously (same logic as the boot script). */
export function persistedSessionUserId(): string | null {
  const ls = storage('local');
  if (!ls) return null;
  for (let i = 0; i < ls.length; i++) {
    const key = ls.key(i);
    if (!key || !/^sb-.+-auth-token$/.test(key)) continue;
    try {
      const id = JSON.parse(ls.getItem(key) ?? 'null')?.user?.id;
      if (typeof id === 'string') return id;
    } catch {
      /* ignore */
    }
  }
  return null;
}

/** Theme the boot script would have applied before React mounted (keeps first render consistent). */
export function bootTheme(): { theme: StoredTheme; source: 'preview' | 'member' } | null {
  const preview = readPreview();
  if (preview) return { theme: preview, source: 'preview' };
  const uid = persistedSessionUserId();
  const cached = uid ? readCachedTheme(uid) : null;
  return cached ? { theme: cached, source: 'member' } : null;
}

function setFavicon(href: string) {
  const link = document.head.querySelector<HTMLLinkElement>('link[rel="icon"]');
  if (!link) return;
  if (!link.dataset.defaultHref) link.dataset.defaultHref = link.getAttribute('href') ?? DEFAULT_FAVICON;
  const type = href.startsWith('data:image/svg') || href.endsWith('.svg') ? 'image/svg+xml' : '';
  if (type) link.setAttribute('type', type);
  else link.removeAttribute('type');
  link.setAttribute('href', href);
}

/** Apply (or with null, remove) a theme on <html>. Idempotent. */
export function applyTheme(theme: StoredTheme | null) {
  const root = document.documentElement;
  const stale: string[] = [];
  for (let i = 0; i < root.style.length; i++) {
    const prop = root.style.item(i);
    if (prop.startsWith('--fl-')) stale.push(prop);
  }
  stale.forEach((p) => root.style.removeProperty(p));

  if (!theme) {
    delete root.dataset.companyTheme;
    const link = document.head.querySelector<HTMLLinkElement>('link[rel="icon"]');
    if (link?.dataset.defaultHref) {
      link.setAttribute('href', link.dataset.defaultHref);
      link.setAttribute('type', 'image/svg+xml');
    }
    // Restore a meta theme-color if anything themed it (data-default-content marks the original).
    const meta = document.head.querySelector<HTMLMetaElement>('meta[name="theme-color"]');
    if (meta?.dataset.defaultContent !== undefined) {
      if (meta.dataset.defaultContent) meta.setAttribute('content', meta.dataset.defaultContent);
      else meta.remove();
      delete meta.dataset.defaultContent;
    }
    return;
  }
  for (const [k, val] of Object.entries(theme.vars)) root.style.setProperty(k, val);
  root.dataset.companyTheme = theme.company.id ?? 'preview';
  setFavicon(theme.favicon);
}

/** If the stored favicon (company logo) fails to load, fall back to the initials badge. */
export function verifyFavicon(theme: StoredTheme) {
  if (theme.favicon.startsWith('data:')) return;
  const img = new Image();
  img.onerror = () => {
    const vars = theme.vars;
    const toHex = (v?: string) => rgbToHex((v ?? '0 0 0').split(' ').map(Number) as [number, number, number]);
    const href = initialsBadgeDataUri(theme.company.name, toHex(vars['--fl-rok-500']), toHex(vars['--fl-on-rok']));
    if (document.documentElement.dataset.companyTheme) setFavicon(href);
  };
  img.src = theme.favicon;
}
