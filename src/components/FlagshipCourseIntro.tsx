import { ArrowRight, Mail, Wrench } from 'lucide-react';
import type { Route } from '@/components/Nav';
import { SITE_CONFIG } from '@/lib/siteConfig';
import { isBearingsGamesCourse } from '@/lib/games/bearingsLubricationAlignment';
import type { FlagshipStory } from '@/lib/seo/flagshipStories';

interface Props {
  story: FlagshipStory;
  onNavigate: (r: Route) => void;
}

export function FlagshipCourseIntro({ story, onNavigate }: Props) {
  return (
    <div className="mt-6 max-w-3xl space-y-6">
      <div className="text-steel-300 leading-relaxed space-y-4">
        {story.paragraphs.map((p) => (
          <p key={p.slice(0, 40)}>{p}</p>
        ))}
        {story.bullets.length > 0 && (
          <ul className="list-disc pl-5 space-y-1.5 text-steel-200">
            {story.bullets.map((b) => (
              <li key={b}>{b}</li>
            ))}
          </ul>
        )}
      </div>

      <div className="grid sm:grid-cols-2 gap-4">
        <div className="rounded-lg border border-steel-700/50 bg-navy-950/40 p-4">
          <h2 className="text-sm font-semibold text-white mb-2">Who it is for</h2>
          <p className="text-sm text-steel-400 leading-relaxed">{story.whoFor}</p>
        </div>
        <div className="rounded-lg border border-steel-700/50 bg-navy-950/40 p-4">
          <h2 className="text-sm font-semibold text-white mb-2">Who it is not for</h2>
          <p className="text-sm text-steel-400 leading-relaxed">{story.whoNot}</p>
        </div>
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <button
          type="button"
          onClick={() => onNavigate({ name: 'paths', focusPath: story.ctaPath })}
          className="btn-primary"
        >
          {story.ctaLabel}
          <ArrowRight className="w-4 h-4" />
        </button>
        {story.showGames && isBearingsGamesCourse(story.courseId) && (
          <button
            type="button"
            onClick={() => onNavigate({ name: 'games', courseId: story.courseId })}
            className="btn-outline-rok"
          >
            <Wrench className="w-4 h-4" />
            Shop-floor games
          </button>
        )}
        {story.relatedCourseId && story.relatedLabel && (
          <button
            type="button"
            onClick={() => onNavigate({ name: 'course', courseId: story.relatedCourseId! })}
            className="btn-ghost text-sm"
          >
            {story.relatedLabel}
          </button>
        )}
      </div>

      <p className="text-sm text-steel-500 flex items-center gap-2">
        <Mail className="w-3.5 h-3.5 text-rok-400" />
        <a
          href={`mailto:${SITE_CONFIG.supportEmail}`}
          className="text-steel-400 hover:text-rok-400 transition-colors"
        >
          {SITE_CONFIG.supportEmail}
        </a>
      </p>
    </div>
  );
}
