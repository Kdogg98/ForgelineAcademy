import { Clock, Lock, CheckCircle2, ChevronRight, BookOpen } from 'lucide-react';
import type { Course } from '@/lib/types';
import { STAGE_LABEL } from '@/lib/types';
import { TierBadge, DifficultyBadge } from '@/components/ui/Badge';
import { ProgressBar } from '@/components/ui/ProgressBar';

interface CourseCardProps {
  course: Course;
  progress?: number;
  hasCertificate?: boolean;
  locked?: boolean;
  onClick?: () => void;
}

/** Stage-matched industrial background photos (Unsplash — free to use) */
const STAGE_COVER: Record<Course['stage'], string> = {
  mechanical:
    'https://images.unsplash.com/photo-1524514587686-e2909d726e9b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8aW5kdXN0cmlhbCUyMG1lY2hhbmljc3xlbnwwfHwwfHx8MA%3D%3D',
  // pumps / rotating equipment floor
  electrical:
    'https://images.unsplash.com/photo-1635335874521-7987db781153?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  // industrial electrical panels / switchgear
  ie:
    'https://images.unsplash.com/photo-1652785723146-ca1a6daf5ecc?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cHJlc3N1cmUlMjB0cmFuc2R1Y2VyfGVufDB8fDB8fHww',
  // instrumentation / control room
  engineering:
    'https://media.istockphoto.com/id/2260705463/photo/engineer-monitoring-industrial-process-control-system.webp?a=1&b=1&s=612x612&w=0&k=20&c=99-T8gUXPH9ITOcs9ep6lN-NYjee_5FzfzY3Mg0kWh0=',
  // engineering / plant overview
};

const STAGE_OVERLAY: Record<Course['stage'], string> = {
  mechanical: 'from-premium-900/85 via-navy-950/70 to-navy-950/90',
  electrical: 'from-premium-950/80 via-navy-950/70 to-navy-950/90',
  ie: 'from-premium-950/75 via-navy-950/70 to-navy-950/90',
  engineering: 'from-premium-1000/85 via-navy-950/75 to-navy-950/90',
};

export function CourseCard({
  course,
  progress = 0,
  hasCertificate = false,
  locked = false,
  onClick,
}: CourseCardProps) {
  const cover = STAGE_COVER[course.stage];
  const overlay = STAGE_OVERLAY[course.stage];

  return (
    <button
      onClick={onClick}
      className="group relative flex flex-col text-left card card-hover w-[300px] shrink-0 overflow-hidden"
    >
      {/* Header with matching background photo */}
      <div className="relative h-28 overflow-hidden bg-navy-950">
        <img
          src={cover}
          alt=""
          className="absolute inset-0 h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
          loading="lazy"
        />
        <div className={`absolute inset-0 bg-gradient-to-t ${overlay}`} />
        <div className="absolute inset-0 bg-grid-steel bg-grid-32 opacity-20" />

        {/* Fallback icon if image fails */}
        <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
          <BookOpen className="w-10 h-10 text-steel-400/25" strokeWidth={1.2} />
        </div>

        {locked && (
          <div className="absolute inset-0 flex items-center justify-center bg-navy-950/75 backdrop-blur-sm">
            <div className="flex flex-col items-center gap-1.5">
              <Lock className="w-6 h-6 text-premium-400" />
              <span className="text-xs font-semibold text-premium-400 uppercase tracking-wide">
                Premium
              </span>
            </div>
          </div>
        )}

        <div className="absolute top-3 left-3 flex gap-1.5">
          <TierBadge tier={course.tier} />
        </div>

        {hasCertificate && (
          <div className="absolute top-3 right-3">
            <CheckCircle2 className="w-5 h-5 text-premium-400 drop-shadow" />
          </div>
        )}
      </div>

      {/* Body */}
      <div className="flex flex-col flex-1 p-4">
        <div className="text-[11px] font-semibold uppercase tracking-wider text-steel-400 mb-1.5">
          {STAGE_LABEL[course.stage]} Stage
        </div>

        <h3 className="font-display text-base font-semibold text-white leading-snug mb-2 line-clamp-2">
          {course.title}
        </h3>

        <p className="text-sm text-steel-400 leading-relaxed line-clamp-2 mb-3 flex-1">
          {course.short_description}
        </p>

        <div className="flex items-center gap-3 text-xs text-steel-400 mb-3">
          <span className="inline-flex items-center gap-1">
            <Clock className="w-3.5 h-3.5" />
            {course.estimated_hours}h
          </span>
          <DifficultyBadge difficulty={course.difficulty} />
        </div>

        {progress > 0 && (
          <div className="mb-3">
            <ProgressBar value={progress} size="sm" />
            <div className="mt-1 text-[11px] font-medium text-steel-400">
              {progress}% complete
            </div>
          </div>
        )}

        <div className="flex items-center justify-between pt-3 border-t border-steel-700/40">
          <span className="text-xs font-medium text-steel-400">
            {progress === 100
              ? 'Completed'
              : progress > 0
                ? 'In progress'
                : 'Start course'}
          </span>
          <ChevronRight className="w-4 h-4 text-steel-500 group-hover:text-accent-400 group-hover:translate-x-0.5 transition-all" />
        </div>
      </div>
    </button>
  );
}