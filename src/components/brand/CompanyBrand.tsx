import { useState } from 'react';
import { Hexagon, MapPin, Factory, GraduationCap, ChevronRight, PlayCircle } from 'lucide-react';
import { faviconLogo } from '@/lib/companyBrand';
import { academyName, type ThemeCompany } from '@/lib/theme/themeStore';
import { initialsOf } from '@/lib/theme/colors';
import type { Route } from '@/components/Nav';
import type { Course } from '@/lib/types';

/** Company logo with graceful fallback: uploaded logo -> domain favicon -> initials badge. */
export function CompanyLogoMark({
  company,
  className = 'h-8 w-8',
  rounded = 'rounded-md',
}: {
  company: Pick<ThemeCompany, 'name' | 'logoUrl' | 'domain'>;
  className?: string;
  rounded?: string;
}) {
  const candidates = [company.logoUrl, faviconLogo(company.domain)].filter((x): x is string => !!x);
  const [idx, setIdx] = useState(0);
  const src = candidates[idx];
  if (!src) {
    return (
      <span
        aria-label={`${company.name} logo`}
        className={`${className} ${rounded} inline-flex shrink-0 items-center justify-center bg-rok-500 text-on-rok font-display font-bold text-[0.8em] leading-none`}
      >
        {initialsOf(company.name)}
      </span>
    );
  }
  return (
    <img
      src={src}
      alt={`${company.name} logo`}
      className={`${className} ${rounded} shrink-0 object-contain bg-white/95 p-0.5`}
      onError={() => setIdx((i) => i + 1)}
    />
  );
}

/** Small "Training by ForgeLine" attribution used next to a company logo. */
export function TrainingByForgeLine({ className = '' }: { className?: string }) {
  return (
    <span className={`inline-flex items-center gap-1 whitespace-nowrap text-[10px] font-semibold uppercase tracking-[0.16em] text-steel-400 ${className}`}>
      Training by
      <Hexagon className="w-3 h-3 text-rok-500" strokeWidth={2} />
      ForgeLine
    </span>
  );
}

/** Co-branded lockup: company logo + name ("<Company> Academy" in the footer) + "Training by ForgeLine". */
export function CoBrandLogo({ company, size = 'default' }: { company: ThemeCompany; size?: 'default' | 'lg' }) {
  return (
    <div className="flex items-center gap-2.5 min-w-0">
      <CompanyLogoMark company={company} className={size === 'lg' ? 'h-10 w-10 text-lg' : 'h-8 w-8 text-base'} />
      <div className="leading-tight min-w-0 text-left">
        <div className={`font-display font-bold text-white tracking-tight truncate ${size === 'lg' ? 'text-lg max-w-[280px]' : 'text-base max-w-[140px]'}`}>
          {size === 'lg' ? academyName(company.name) : company.name}
        </div>
        <TrainingByForgeLine />
      </div>
    </div>
  );
}

/** Branded "Welcome to <Company> Training" hero for members (home + dashboard). */
export function CompanyWelcomeHero({
  company,
  onNavigate,
  compact = false,
}: {
  company: ThemeCompany;
  onNavigate: (r: Route) => void;
  compact?: boolean;
}) {
  const tracks = company.tracks.slice(0, compact ? 3 : 4);
  return (
    <section className="relative overflow-hidden border-b border-steel-700/60 bg-gradient-to-br from-navy-800 via-navy-900 to-navy-950">
      <div className="absolute inset-0 brand-pattern pointer-events-none" />
      <div className="absolute -right-24 top-0 h-full w-1/2 bg-gradient-to-l from-rok-500/20 via-crimson-500/10 to-transparent skew-x-[-12deg] origin-top pointer-events-none" />
      <div className={`relative max-w-7xl mx-auto px-4 sm:px-6 ${compact ? 'py-8' : 'py-10 sm:py-14'}`}>
        <div className="flex flex-col lg:flex-row lg:items-center gap-8">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-3 mb-4">
              <CompanyLogoMark company={company} className="h-12 w-12 text-xl" rounded="rounded-xl" />
              <TrainingByForgeLine />
            </div>
            <h1 className={`font-display font-bold text-white tracking-tight ${compact ? 'text-2xl sm:text-3xl' : 'text-3xl sm:text-4xl'}`}>
              Welcome to {company.name} Training
            </h1>
            <div className="rok-bar mt-3" />
            {company.summary && !compact && <p className="mt-4 max-w-2xl text-steel-300 leading-relaxed">{company.summary}</p>}
            <div className="mt-4 flex flex-wrap gap-x-5 gap-y-2 text-sm text-steel-300">
              {company.industry && (
                <span className="inline-flex items-center gap-1.5">
                  <Factory className="w-4 h-4 text-rok-400" />
                  {company.industry}
                </span>
              )}
              {company.locations.length > 0 && (
                <span className="inline-flex items-center gap-1.5">
                  <MapPin className="w-4 h-4 text-rok-400" />
                  {company.locations.slice(0, 4).join(' · ')}
                  {company.locations.length > 4 && ` +${company.locations.length - 4}`}
                </span>
              )}
            </div>
          </div>

          {tracks.length > 0 && (
            <div className="lg:w-[420px] shrink-0">
              <div className="text-xs font-semibold uppercase tracking-[0.18em] text-rok-400 mb-2 flex items-center gap-1.5">
                <GraduationCap className="w-4 h-4" />
                Suggested tracks for your team
              </div>
              <ul className="space-y-2">
                {tracks.map((t) => {
                  const clickable = !!t.course_id;
                  return (
                    <li key={`${t.course_id}-${t.title}`}>
                      <button
                        type="button"
                        disabled={!clickable}
                        onClick={() => clickable && onNavigate({ name: 'course', courseId: t.course_id })}
                        className="w-full card px-4 py-2.5 flex items-center gap-3 text-left transition-colors enabled:hover:border-rok-500/50 enabled:hover:bg-navy-700/80 disabled:cursor-default"
                      >
                        <span className="h-2 w-2 rounded-full bg-rok-500 shrink-0" />
                        <span className="flex-1 min-w-0">
                          <span className="block text-sm font-medium text-white truncate">{t.title}</span>
                          {t.reason && <span className="block text-xs text-steel-400 truncate">{t.reason}</span>}
                        </span>
                        {clickable && <ChevronRight className="w-4 h-4 text-steel-400" />}
                      </button>
                    </li>
                  );
                })}
              </ul>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}

/** "Continue learning" panel for company members: in-progress courses first, then suggested tracks. */
export function ContinueLearningPanel({
  company,
  courses,
  progressMap,
  certCourseIds,
  onNavigate,
}: {
  company: ThemeCompany;
  courses: Course[];
  progressMap: Record<string, number>;
  certCourseIds: Set<string>;
  onNavigate: (r: Route) => void;
}) {
  const byId = new Map(courses.map((c) => [c.id, c]));
  const inProgress = courses
    .filter((c) => (progressMap[c.id] ?? 0) > 0 && (progressMap[c.id] ?? 0) < 100 && !certCourseIds.has(c.id))
    .sort((a, b) => (progressMap[b.id] ?? 0) - (progressMap[a.id] ?? 0))
    .slice(0, 3);
  const upNext = company.tracks
    .map((t) => (t.course_id ? byId.get(t.course_id) : undefined))
    .filter((c): c is Course => !!c && !inProgress.some((p) => p.id === c.id) && (progressMap[c.id] ?? 0) < 100)
    .slice(0, Math.max(0, 4 - inProgress.length));
  const items = [...inProgress, ...upNext];

  return (
    <section className="max-w-7xl mx-auto px-4 sm:px-6 pt-10">
      <div className="card p-6 sm:p-8">
        <div className="flex flex-wrap items-end justify-between gap-3 mb-5">
          <div>
            <div className="rok-bar mb-3" />
            <h2 className="section-title flex items-center gap-2">
              <PlayCircle className="w-5 h-5 text-rok-400" />
              Continue learning
            </h2>
            <p className="text-sm text-steel-400 mt-1">
              {inProgress.length > 0 ? 'Pick up where you left off.' : `Start with a track picked for ${company.name}.`}
            </p>
          </div>
          <div className="flex gap-2">
            <button onClick={() => onNavigate({ name: 'dashboard' })} className="btn-secondary text-sm">
              My Learning
            </button>
            <button onClick={() => onNavigate({ name: 'catalog' })} className="btn-ghost text-sm">
              Full catalog
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
        {items.length === 0 ? (
          <p className="text-sm text-steel-400">
            Your company has Premium access to all 78 courses. Browse the catalog or follow a learning path to get started.
          </p>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
            {items.map((c) => {
              const pct = Math.round(progressMap[c.id] ?? 0);
              return (
                <button
                  key={c.id}
                  onClick={() => onNavigate({ name: 'course', courseId: c.id })}
                  className="card card-hover p-4 text-left flex flex-col gap-2"
                >
                  <span className="text-[10px] font-semibold uppercase tracking-wider text-rok-400">
                    {pct > 0 ? 'In progress' : 'Suggested track'}
                  </span>
                  <span className="text-sm font-semibold text-white line-clamp-2">{c.title}</span>
                  <span className="mt-auto h-1.5 rounded-full bg-navy-950/70 overflow-hidden">
                    <span className="block h-full rounded-full bg-rok-500" style={{ width: `${pct}%` }} />
                  </span>
                  <span className="text-xs text-steel-400">{pct > 0 ? `${pct}% complete` : 'Not started'}</span>
                </button>
              );
            })}
          </div>
        )}
      </div>
    </section>
  );
}
