import type { Route } from '@/components/Nav';
import { prettyCoursePath, slugToCourseId } from '@/lib/seo/courseSlugs';

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
      const pretty = prettyCoursePath(r.courseId);
      return pretty ?? `/course/${encodeURIComponent(r.courseId)}`;
    }
    case 'games':
      return `/course/${encodeURIComponent(r.courseId)}/games`;
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
  if (games) return { name: 'games', courseId: decodeURIComponent(games[1]) };
  const course = p.match(/^\/course\/([^/]+)$/);
  if (course) return { name: 'course', courseId: decodeURIComponent(course[1]) };
  const prettyCourse = p.match(/^\/courses\/([^/]+)$/);
  if (prettyCourse) {
    const id = slugToCourseId(prettyCourse[1]);
    if (id) return { name: 'course', courseId: id };
  }
  const legal = p.match(/^\/legal\/(privacy|terms|disclaimer)$/);
  if (legal) return { name: 'legal', doc: legal[1] as 'privacy' | 'terms' | 'disclaimer' };
  return { name: 'home' };
}
