import type { Route } from '@/components/Nav';
import { courseIdToSlug, slugToCourseId } from '@/lib/seo/courseSlugs';

/** /course/<slug> for catalog courses, /course/<id> for custom/unknown ones. */
export function appCoursePath(courseId: string): string {
  const slug = courseIdToSlug(courseId);
  return `/course/${slug ?? encodeURIComponent(courseId)}`;
}
/** /course/<slug-or-id> segment -> course id (old /course/<uuid> links keep working). */
function courseKeyToId(seg: string): string {
  const raw = decodeURIComponent(seg);
  return slugToCourseId(raw) ?? raw;
}
/** App reached at the static SEO path /courses/<slug> (client nav, old links): the app URL for it. */
export function legacyCourseRedirect(pathname: string): string | null {
  const m = pathname.match(/^\/courses\/([^/]+)\/?$/);
  if (!m) return null;
  const id = slugToCourseId(m[1]);
  return id ? appCoursePath(id) : null;
}

export function routeToPath(r: Route): string {
  switch (r.name) {
    case 'home':
      return '/';
    case 'paths':
      if (r.focusPath === 'mechanical') return '/paths/mechanical';
      if (r.focusPath === 'electrical') return '/paths/electrical';
      return '/paths';
    case 'catalog':
      return '/catalog';
    case 'course': {
      // In-app course route is /course/<slug> (reload/share opens the app). /courses/<slug> is the
      // static SEO outline (public/courses/*, _redirects) and stays the canonical URL.
      return appCoursePath(r.courseId);
    }
    case 'games':
      return `${appCoursePath(r.courseId)}/games`;
    case 'dashboard':
      return '/dashboard';
    case 'certificates':
      return '/certificates';
    case 'pricing':
      return '/upgrade';
    case 'auth':
      return '/auth';
    case 'admin':
      return '/admin';
    case 'company':
      return '/company';
    case 'legal':
      return `/legal/${r.doc}`;
    case 'search':
      return `/catalog?q=${encodeURIComponent(r.query)}`;
    case 'book':
      return '/book';
    case 'services':
      return '/request';
    case 'assessment':
      return '/assessment';
    case 'announcements':
      return '/announcements';
    case 'notfound':
      return r.path;
    default:
      return '/';
  }
}

export function pathToRoute(pathname: string, search = ''): Route {
  const p = pathname.replace(/\/+$/, '') || '/';
  if (p === '/' || p === '') return { name: 'home' };
  if (p === '/catalog' || p === '/courses') {
    const q = new URLSearchParams(search).get('q');
    if (q) return { name: 'search', query: q };
    return { name: 'catalog' };
  }
  if (p === '/privacy') return { name: 'legal', doc: 'privacy' };
  if (p === '/terms') return { name: 'legal', doc: 'terms' };
  if (p === '/paths/mechanical') return { name: 'paths', focusPath: 'mechanical' };
  if (p === '/paths/electrical') return { name: 'paths', focusPath: 'electrical' };
  if (p === '/paths') return { name: 'paths' };
  if (p === '/dashboard') return { name: 'dashboard' };
  if (p === '/certificates') return { name: 'certificates' };
  if (p === '/upgrade') return { name: 'pricing' };
  if (p === '/auth') return { name: 'auth' };
  if (p === '/admin') return { name: 'admin' };
  if (p === '/company') return { name: 'company' };
  if (p === '/book') return { name: 'book' };
  if (p === '/request') return { name: 'services' };
  if (p === '/assessment') return { name: 'assessment' };
  if (p === '/announcements') return { name: 'announcements' };
  const games = p.match(/^\/course\/([^/]+)\/games$/);
  if (games) return { name: 'games', courseId: courseKeyToId(games[1]) };
  const course = p.match(/^\/course\/([^/]+)$/);
  if (course) return { name: 'course', courseId: courseKeyToId(course[1]) };
  const prettyCourse = p.match(/^\/courses\/([^/]+)$/);
  if (prettyCourse) {
    const id = slugToCourseId(prettyCourse[1]);
    if (id) return { name: 'course', courseId: id };
  }
  const legal = p.match(/^\/legal\/(privacy|terms|disclaimer)$/);
  if (legal) return { name: 'legal', doc: legal[1] as 'privacy' | 'terms' | 'disclaimer' };
  // Unknown path: a real 404 page instead of silently rendering home/dashboard.
  return { name: 'notfound', path: p };
}
