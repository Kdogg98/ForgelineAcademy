import { useState } from 'react';
import { Building2, MapPin, Cog, Factory, GraduationCap, Crown, ChevronRight } from 'lucide-react';
import type { CompanyTrack } from '@/lib/types';
import { brandStyle, faviconLogo, type BrandColors } from '@/lib/companyBrand';

export interface CompanyOverviewData {
  name: string;
  logoUrl?: string | null;
  domain?: string | null;
  industry?: string | null;
  summary?: string | null;
  locations?: string[];
  equipment?: string[];
  processes?: string[];
  tracks?: CompanyTrack[];
  premium?: boolean;
}

interface Props {
  data: CompanyOverviewData;
  brand: BrandColors;
  /** Shown as a ribbon when previewing an unpublished draft. */
  badge?: string | null;
  onOpenCourse?: (courseId: string) => void;
}

function CompanyLogo({ src, domain, name }: { src?: string | null; domain?: string | null; name: string }) {
  const candidates = [src, faviconLogo(domain)].filter((x): x is string => !!x);
  const [idx, setIdx] = useState(0);
  const url = candidates[idx];
  if (!url) return <Building2 className="w-8 h-8" style={{ color: 'var(--brand-on-primary)' }} />;
  return (
    <img
      src={url}
      alt={`${name} logo`}
      className="w-full h-full object-contain p-2"
      onError={() => setIdx((i) => i + 1)}
    />
  );
}

function Chips({ items }: { items: string[] }) {
  return (
    <div className="flex flex-wrap gap-1.5">
      {items.map((it) => (
        <span
          key={it}
          className="text-xs px-2.5 py-1 rounded-full border text-steel-200"
          style={{ borderColor: 'color-mix(in srgb, var(--brand-accent) 45%, transparent)', background: 'color-mix(in srgb, var(--brand-accent) 12%, transparent)' }}
        >
          {it}
        </span>
      ))}
    </div>
  );
}

/** Branded company dashboard body. All colors come from CSS variables set by brandStyle(). */
export function CompanyOverview({ data, brand, badge, onOpenCourse }: Props) {
  const locations = data.locations ?? [];
  const equipment = data.equipment ?? [];
  const processes = data.processes ?? [];
  const tracks = data.tracks ?? [];

  return (
    <div style={brandStyle(brand)} className="space-y-4">
      <div
        className="relative overflow-hidden rounded-2xl border border-steel-700/60 p-6 sm:p-8"
        style={{ background: 'linear-gradient(135deg, var(--brand-primary) 0%, var(--brand-secondary) 70%)', color: 'var(--brand-on-primary)' }}
      >
        <div className="absolute inset-x-0 bottom-0 h-1" style={{ background: 'var(--brand-accent)' }} />
        {badge && (
          <span className="absolute top-3 right-3 text-[10px] font-bold uppercase tracking-wider px-2 py-1 rounded-full bg-warning-500/90 text-navy-900">
            {badge}
          </span>
        )}
        <div className="flex items-center gap-5">
          <div className="w-20 h-20 rounded-xl bg-white/95 flex items-center justify-center overflow-hidden shrink-0 shadow-lg">
            <CompanyLogo key={`${data.logoUrl}|${data.domain}`} src={data.logoUrl} domain={data.domain} name={data.name} />
          </div>
          <div className="min-w-0">
            <h1 className="text-2xl sm:text-3xl font-bold truncate">{data.name || 'Company name'}</h1>
            <div className="flex flex-wrap items-center gap-x-3 gap-y-1 mt-1 text-sm opacity-85">
              {data.industry && <span>{data.industry}</span>}
              {data.domain && <span className="opacity-75">{data.domain}</span>}
              {data.premium && (
                <span className="inline-flex items-center gap-1 font-semibold">
                  <Crown className="w-4 h-4" /> Team Premium
                </span>
              )}
            </div>
          </div>
        </div>
        {data.summary && <p className="mt-4 text-sm sm:text-base max-w-3xl opacity-90">{data.summary}</p>}
        {data.premium && (
          <p className="mt-3 text-xs opacity-80">
            Every team member has full online access to all ForgeLine courses through {data.name || 'your company'}.
          </p>
        )}
      </div>

      <div className="grid md:grid-cols-3 gap-4">
        <div className="card p-5">
          <h2 className="flex items-center gap-2 text-sm font-semibold text-steel-300 uppercase tracking-wider mb-3">
            <MapPin className="w-4 h-4" style={{ color: 'var(--brand-accent)' }} /> Locations
          </h2>
          {locations.length ? (
            <ul className="space-y-1.5 text-sm text-steel-200">
              {locations.map((l) => <li key={l}>{l}</li>)}
            </ul>
          ) : (
            <p className="text-sm text-steel-500">No locations listed.</p>
          )}
        </div>
        <div className="card p-5">
          <h2 className="flex items-center gap-2 text-sm font-semibold text-steel-300 uppercase tracking-wider mb-3">
            <Cog className="w-4 h-4" style={{ color: 'var(--brand-accent)' }} /> Equipment
          </h2>
          {equipment.length ? <Chips items={equipment} /> : <p className="text-sm text-steel-500">No equipment listed.</p>}
        </div>
        <div className="card p-5">
          <h2 className="flex items-center gap-2 text-sm font-semibold text-steel-300 uppercase tracking-wider mb-3">
            <Factory className="w-4 h-4" style={{ color: 'var(--brand-accent)' }} /> Processes
          </h2>
          {processes.length ? <Chips items={processes} /> : <p className="text-sm text-steel-500">No processes listed.</p>}
        </div>
      </div>

      <div className="card p-5">
        <h2 className="flex items-center gap-2 text-sm font-semibold text-steel-300 uppercase tracking-wider mb-3">
          <GraduationCap className="w-4 h-4" style={{ color: 'var(--brand-accent)' }} /> Recommended Training Tracks
        </h2>
        {tracks.length === 0 ? (
          <p className="text-sm text-steel-500">No tracks selected yet.</p>
        ) : (
          <div className="grid sm:grid-cols-2 gap-2">
            {tracks.map((t) => (
              <button
                key={t.course_id}
                type="button"
                disabled={!onOpenCourse}
                onClick={() => onOpenCourse?.(t.course_id)}
                className="text-left p-3 rounded-lg border border-steel-700/50 bg-navy-950/40 hover:bg-navy-800/60 transition-colors flex items-start gap-3 disabled:cursor-default"
              >
                <span className="mt-1 w-1.5 h-8 rounded-full shrink-0" style={{ background: 'var(--brand-accent)' }} />
                <span className="flex-1 min-w-0">
                  <span className="block text-sm font-semibold text-white">{t.title}</span>
                  {t.reason && <span className="block text-xs text-steel-400 mt-0.5">{t.reason}</span>}
                </span>
                {onOpenCourse && <ChevronRight className="w-4 h-4 text-steel-500 mt-1" />}
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
