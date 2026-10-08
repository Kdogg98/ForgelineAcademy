import type { CSSProperties } from 'react';
import { supabase } from '@/lib/supabase';
import type { Company, CompanyDraft } from '@/lib/types';

/** ForgeLine defaults (tailwind navy-900 / navy-700 / rok-500). */
export const DEFAULT_BRAND = { primary: '#0A1628', secondary: '#16294A', accent: '#EC682B' };

const HEX = /^#[0-9a-fA-F]{6}$/;
export const isHex = (v: string | null | undefined): v is string => !!v && HEX.test(v);

/** Black or white text, whichever reads better on the given hex background. */
export function readableOn(hex: string): string {
  const n = parseInt(hex.slice(1), 16);
  const [r, g, b] = [(n >> 16) & 255, (n >> 8) & 255, n & 255].map((c) => {
    const x = c / 255;
    return x <= 0.03928 ? x / 12.92 : ((x + 0.055) / 1.055) ** 2.4;
  });
  const lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  return lum > 0.4 ? '#0A1628' : '#FFFFFF';
}

export interface BrandColors {
  primary: string;
  secondary: string;
  accent: string;
}

export function brandFromCompany(c: Pick<Company, 'brand_primary' | 'brand_secondary' | 'brand_accent'> | null | undefined): BrandColors {
  return {
    primary: isHex(c?.brand_primary) ? c!.brand_primary! : DEFAULT_BRAND.primary,
    secondary: isHex(c?.brand_secondary) ? c!.brand_secondary! : DEFAULT_BRAND.secondary,
    accent: isHex(c?.brand_accent) ? c!.brand_accent! : DEFAULT_BRAND.accent,
  };
}

export function brandFromDraft(d: Pick<CompanyDraft, 'brand_colors'> | null | undefined): BrandColors {
  return {
    primary: isHex(d?.brand_colors?.primary) ? d!.brand_colors.primary : DEFAULT_BRAND.primary,
    secondary: isHex(d?.brand_colors?.secondary) ? d!.brand_colors.secondary : DEFAULT_BRAND.secondary,
    accent: isHex(d?.brand_colors?.accent) ? d!.brand_colors.accent : DEFAULT_BRAND.accent,
  };
}

/** CSS custom properties used by the branded /company page (var(--brand-*)). */
export function brandStyle(b: BrandColors): CSSProperties {
  return {
    '--brand-primary': b.primary,
    '--brand-secondary': b.secondary,
    '--brand-accent': b.accent,
    '--brand-on-primary': readableOn(b.primary),
    '--brand-on-accent': readableOn(b.accent),
  } as CSSProperties;
}

/** Keyless favicon-based logo for a domain (fallback when no uploaded logo). */
export function faviconLogo(domain: string | null | undefined): string {
  const d = (domain ?? '').trim();
  return d ? `https://www.google.com/s2/favicons?domain=${encodeURIComponent(d)}&sz=256` : '';
}

export function emptyDraft(name = ''): CompanyDraft {
  return {
    name,
    domain: '',
    logo_url: '',
    industry: '',
    summary: '',
    locations: [],
    equipment: [],
    processes: [],
    brand_colors: { ...DEFAULT_BRAND },
    suggested_tracks: [],
    notes: '',
  };
}

/** Build an editable draft from an already-published company row. */
export function draftFromCompany(c: Company): CompanyDraft {
  const p = c.profile ?? {};
  return {
    name: c.name,
    domain: c.domain ?? '',
    logo_url: c.logo_url ?? '',
    industry: c.industry ?? '',
    summary: p.summary ?? '',
    locations: p.locations ?? [],
    equipment: p.equipment ?? [],
    processes: p.processes ?? [],
    brand_colors: brandFromCompany(c),
    suggested_tracks: p.suggested_tracks ?? [],
    notes: '',
  };
}

async function readFunctionError(error: unknown, data: unknown): Promise<string> {
  let msg = (data as { error?: string } | null)?.error;
  if (!msg) {
    const ctx = (error as { context?: Response }).context;
    if (ctx && typeof ctx.json === 'function') {
      try {
        msg = (await ctx.json())?.error;
      } catch {
        // not JSON
      }
    }
  }
  return msg || (error instanceof Error ? error.message : 'Request failed');
}

/** Calls the master-admin-only company-builder edge function (OpenAI runs server-side). */
export async function generateCompanyDraft(
  companyName: string,
  domainHint?: string,
): Promise<{ draft: CompanyDraft; warnings: string[] }> {
  const { data, error } = await supabase.functions.invoke('company-builder', {
    body: { companyName, domainHint: domainHint || undefined },
  });
  if (error) throw new Error(await readFunctionError(error, data));
  const draft = (data as { draft?: CompanyDraft })?.draft;
  if (!draft) throw new Error((data as { error?: string })?.error || 'No draft returned.');
  return { draft, warnings: (data as { warnings?: string[] }).warnings ?? [] };
}

export async function saveCompanyDraft(companyId: string | null, draft: CompanyDraft): Promise<string> {
  const { data, error } = await supabase.rpc('save_company_draft', {
    p_company_id: companyId,
    p_name: draft.name.trim(),
    p_draft: draft,
  });
  if (error) throw error;
  return data as string;
}

export async function publishCompanyProfile(companyId: string): Promise<void> {
  const { error } = await supabase.rpc('publish_company_profile', { p_company_id: companyId });
  if (error) throw error;
}

export async function unpublishCompanyProfile(companyId: string): Promise<void> {
  const { error } = await supabase.rpc('unpublish_company_profile', { p_company_id: companyId });
  if (error) throw error;
}

export async function loadCompanyDraft(companyId: string): Promise<CompanyDraft | null> {
  const { data, error } = await supabase
    .from('company_drafts')
    .select('draft')
    .eq('company_id', companyId)
    .maybeSingle();
  if (error) throw error;
  return (data?.draft as CompanyDraft | undefined) ?? null;
}
