import { useMemo, useState } from 'react';
import { Search, SlidersHorizontal, X } from 'lucide-react';
import type { Course, Stage, Tier, Difficulty } from '@/lib/types';
import { STAGES } from '@/lib/types';
import { CourseCard } from '@/components/CourseCard';
import { useAuth } from '@/lib/auth';
import type { Route } from '@/components/Nav';
import { PlantFloorLinks } from '@/components/PlantFloorLinks';

interface CatalogProps {
  courses: Course[];
  loading: boolean;
  progressMap: Record<string, number>;
  certCourseIds: Set<string>;
  onNavigate: (r: Route) => void;
  initialQuery?: string;
}

type StageFilter = Stage | 'all';
type TierFilter = Tier | 'all';
type DiffFilter = Difficulty | 'all';

export function Catalog({
  courses,
  loading,
  progressMap,
  certCourseIds,
  onNavigate,
  initialQuery = '',
}: CatalogProps) {
  const { isPremium, isAdmin } = useAuth();
  const [query, setQuery] = useState(initialQuery);
  const [stageFilter, setStageFilter] = useState<StageFilter>('all');
  const [tierFilter, setTierFilter] = useState<TierFilter>('all');
  const [diffFilter, setDiffFilter] = useState<DiffFilter>('all');

  const filtered = useMemo(() => {
    return courses.filter((c) => {
      if (stageFilter !== 'all' && c.stage !== stageFilter) return false;
      if (tierFilter !== 'all' && c.tier !== tierFilter) return false;
      if (diffFilter !== 'all' && c.difficulty !== diffFilter) return false;
      if (query) {
        const q = query.toLowerCase();
        if (
          !c.title.toLowerCase().includes(q) &&
          !c.short_description.toLowerCase().includes(q) &&
          !c.description.toLowerCase().includes(q)
        )
          return false;
      }
      return true;
    });
  }, [courses, stageFilter, tierFilter, diffFilter, query]);

  const activeFilters =
    (stageFilter !== 'all' ? 1 : 0) +
    (tierFilter !== 'all' ? 1 : 0) +
    (diffFilter !== 'all' ? 1 : 0);

  function reset() {
    setStageFilter('all');
    setTierFilter('all');
    setDiffFilter('all');
    setQuery('');
  }

  return (
    <div className="pt-16 min-h-screen">
      {/* Header */}
      <div className="border-b border-steel-700/60 bg-navy-950/40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-10">
          <h1 className="font-display text-3xl sm:text-4xl font-bold text-white mb-2">
            Course Catalog
          </h1>
          <p className="text-steel-400 max-w-2xl">
            {courses.length || 78} courses across the four-stage ladder. Mechanical 22 free
            · Electrical 22 free · I&amp;E 18 · Engineering 16.
          </p>
          <div className="mt-6 max-w-3xl">
            <PlantFloorLinks />
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8">
        {/* Search + filters */}
        <div className="flex flex-col lg:flex-row gap-4 mb-8">
          <div className="relative flex-1">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-steel-500" />
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search by title or keyword..."
              className="input pl-10"
            />
          </div>
          <div className="flex flex-wrap gap-2">
            <FilterSelect
              label="Stage"
              value={stageFilter}
              onChange={(v) => setStageFilter(v as StageFilter)}
              options={[
                { value: 'all', label: 'All Stages' },
                ...STAGES.map((s) => ({ value: s.key, label: s.label })),
              ]}
            />
            <FilterSelect
              label="Access"
              value={tierFilter}
              onChange={(v) => setTierFilter(v as TierFilter)}
              options={[
                { value: 'all', label: 'All Access' },
                { value: 'free', label: 'Free' },
                { value: 'premium', label: 'Premium' },
              ]}
            />
            <FilterSelect
              label="Level"
              value={diffFilter}
              onChange={(v) => setDiffFilter(v as DiffFilter)}
              options={[
                { value: 'all', label: 'All Levels' },
                { value: 'beginner', label: 'Beginner' },
                { value: 'intermediate', label: 'Intermediate' },
                { value: 'advanced', label: 'Advanced' },
              ]}
            />
            {activeFilters > 0 && (
              <button
                onClick={reset}
                className="btn-ghost flex items-center gap-1.5"
              >
                <X className="w-4 h-4" />
                Clear ({activeFilters})
              </button>
            )}
          </div>
        </div>

        {/* Stage quick-filter chips */}
        <div className="flex flex-wrap gap-2 mb-6">
          <button
            onClick={() => setStageFilter('all')}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold border transition-colors ${
              stageFilter === 'all'
                ? 'bg-accent-500 text-white border-accent-500'
                : 'bg-navy-800 text-steel-300 border-steel-700 hover:border-accent-500/50'
            }`}
          >
            All Stages
          </button>
          {STAGES.map((s) => (
            <button
              key={s.key}
              onClick={() => setStageFilter(s.key)}
              className={`px-3 py-1.5 rounded-full text-xs font-semibold border transition-colors ${
                stageFilter === s.key
                  ? 'bg-accent-500 text-white border-accent-500'
                  : 'bg-navy-800 text-steel-300 border-steel-700 hover:border-accent-500/50'
              }`}
            >
              {s.key === 'mechanical' && 'Mechanical 22 free'}
              {s.key === 'electrical' && 'Electrical 22 free'}
              {s.key === 'ie' && 'I&E 18'}
              {s.key === 'engineering' && 'Engineering 16'}
            </button>
          ))}
        </div>

        {/* Results count */}
        <div className="flex items-center gap-2 text-sm text-steel-400 mb-6">
          <SlidersHorizontal className="w-4 h-4" />
          {filtered.length} {filtered.length === 1 ? 'course' : 'courses'} found
        </div>

        {/* Grid */}
        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {Array.from({ length: 8 }).map((_, i) => (
              <div
                key={i}
                className="rounded-xl overflow-hidden border border-steel-700/60"
              >
                <div className="skeleton h-28 w-full" />
                <div className="p-4 space-y-3">
                  <div className="skeleton h-3 w-20" />
                  <div className="skeleton h-4 w-full" />
                  <div className="skeleton h-3 w-full" />
                  <div className="skeleton h-3 w-2/3" />
                </div>
              </div>
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-center">
            <div className="w-16 h-16 rounded-full bg-navy-800 border border-steel-700 flex items-center justify-center mb-4">
              <Search className="w-7 h-7 text-steel-500" />
            </div>
            <h3 className="text-lg font-semibold text-white mb-1">No courses found</h3>
            <p className="text-steel-400 mb-4">
              Try adjusting your filters or search terms.
            </p>
            <button onClick={reset} className="btn-secondary">
              Reset filters
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {filtered.map((c) => (
              <CourseCard
                key={c.id}
                course={c}
                progress={progressMap[c.id] ?? 0}
                hasCertificate={certCourseIds.has(c.id)}
                locked={c.tier === 'premium' && !isPremium && !isAdmin}
                onClick={() => onNavigate({ name: 'course', courseId: c.id })}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function FilterSelect({
  label,
  value,
  onChange,
  options,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  options: { value: string; label: string }[];
}) {
  return (
    <div className="relative">
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="appearance-none pl-4 pr-10 py-2.5 text-sm bg-navy-950/60 border border-steel-700 rounded-md text-steel-100 focus:outline-none focus:border-accent-500 cursor-pointer"
        aria-label={label}
      >
        {options.map((o) => (
          <option key={o.value} value={o.value} className="bg-navy-800">
            {o.label}
          </option>
        ))}
      </select>
      <svg
        className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-steel-400 pointer-events-none"
        viewBox="0 0 20 20"
        fill="currentColor"
      >
        <path
          fillRule="evenodd"
          d="M5.23 7.21a.75.75 0 011.06.02L10 11.06l3.71-3.83a.75.75 0 111.08 1.04l-4.25 4.39a.75.75 0 01-1.08 0L5.21 8.27a.75.75 0 01.02-1.06z"
          clipRule="evenodd"
        />
      </svg>
    </div>
  );
}
