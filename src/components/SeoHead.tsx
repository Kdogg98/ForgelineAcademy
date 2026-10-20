import { useEffect } from 'react';
import type { Route } from '@/components/Nav';
import type { Course } from '@/lib/types';
import {
  COURSE_SEO_BY_ID,
  prettyCoursePath,
} from '@/lib/seo/courseSlugs';
import { keywordsForCourse } from '@/lib/seo/courseKeywords';
import { getFlagshipStory } from '@/lib/seo/flagshipStories';
import { useCompanyTheme } from '@/lib/theme/useCompanyTheme';

const SITE = 'https://forgelineacademy.com';
const DEFAULT_TITLE = 'ForgeLine Academy — Industrial Maintenance Training';
const DEFAULT_DESCRIPTION =
  '78 industrial maintenance courses. 44 free (Mechanical + Electrical). Plant-floor bearings, lubrication, and alignment as the Mechanical start. Premium unlocks I&E and Engineering.';

const PATH_LABEL: Record<string, string> = {
  mechanical: 'Mechanical path',
  electrical: 'Electrical path',
  ie: 'I&E path',
  engineering: 'Engineering path',
};

function upsertMeta(attr: 'name' | 'property', key: string, content: string) {
  let el = document.head.querySelector(`meta[${attr}="${key}"]`) as HTMLMetaElement | null;
  if (!el) {
    el = document.createElement('meta');
    el.setAttribute(attr, key);
    document.head.appendChild(el);
  }
  el.setAttribute('content', content);
}

function removeMeta(attr: 'name' | 'property', key: string) {
  document.head.querySelector(`meta[${attr}="${key}"]`)?.remove();
}

function upsertLink(rel: string, href: string) {
  let el = document.head.querySelector(`link[rel="${rel}"]`) as HTMLLinkElement | null;
  if (!el) {
    el = document.createElement('link');
    el.setAttribute('rel', rel);
    document.head.appendChild(el);
  }
  el.setAttribute('href', href);
}

function upsertJsonLd(id: string, data: object | null) {
  const existing = document.getElementById(id);
  if (existing) existing.remove();
  if (!data) return;
  const script = document.createElement('script');
  script.id = id;
  script.type = 'application/ld+json';
  script.text = JSON.stringify(data);
  document.head.appendChild(script);
}

// Public SPA routes: must match the prerendered HTML written by scripts/generate_seo_html.py.
const ROUTE_META: Partial<Record<Route['name'], { path: string; title: string; description: string }>> = {
  home: {
    path: '/',
    title: 'ForgeLine Academy — Industrial Maintenance Training Online & On-Site',
    description:
      '78 plant-floor courses for millwrights, industrial electricians and I&E techs. 44 free Mechanical and Electrical courses; Premium unlocks I&E and Engineering.',
  },
  catalog: {
    path: '/catalog/',
    title: 'Course Catalog — 78 Industrial Maintenance Courses | ForgeLine Academy',
    description:
      'Browse all 78 ForgeLine courses: Mechanical, Electrical, I&E and Engineering. 44 free courses for millwrights and industrial electricians.',
  },
  paths: {
    path: '/paths/',
    title: 'Learning Paths — Mechanical, Electrical, I&E, Engineering | ForgeLine Academy',
    description:
      'Four ForgeLine learning paths from millwright fundamentals to I&E and engineering. Start free with the Mechanical or Electrical path.',
  },
  pricing: {
    path: '/upgrade/',
    title: 'Pricing — Premium $19.99/mo & Plant Seats | ForgeLine Academy',
    description:
      'ForgeLine pricing: 44 free courses, Premium $19.99/month, Plant 5-seat $129/mo, Plant 10-seat $229/mo, and a 30-day free company trial.',
  },
  services: {
    path: '/request/',
    title: 'Request On-Site Training or Plant Support | ForgeLine Academy',
    description:
      'Request on-site industrial maintenance training, plant troubleshooting support, or online plant seats from ForgeLine Academy. Call +1 580 421 5714.',
  },
  book: {
    path: '/book/',
    title: 'Book a Meeting — Plant Training Planning | ForgeLine Academy',
    description:
      'Book a call with ForgeLine Academy to plan crew training, on-site cohorts, or plant seats for your maintenance team.',
  },
  legal: {
    path: '/privacy',
    title: 'Legal — ForgeLine Academy',
    description: 'ForgeLine Academy privacy policy, terms of service and training disclaimer.',
  },
};

function setRobots(index: boolean) {
  if (index) removeMeta('name', 'robots');
  else upsertMeta('name', 'robots', 'noindex, follow');
}

function clipMetaDescription(text: string, max = 155): string {
  const clean = (text || '').replace(/\s+/g, ' ').trim();
  if (clean.length <= max) return clean;
  const cut = clean.slice(0, max);
  const sp = cut.lastIndexOf(' ');
  return `${(sp > 80 ? cut.slice(0, sp) : cut).trimEnd()}…`;
}

export function SeoHead({ route, courses = [] }: { route: Route; courses?: Course[] }) {
  // Members of a themed company see "<page> | <Company> Academy | ForgeLine" (meta/og tags stay ForgeLine).
  const { titleFor } = useCompanyTheme();
  useEffect(() => {
    if (route.name === 'course') {
      const live = courses.find((c) => c.id === route.courseId);
      const seo = COURSE_SEO_BY_ID[route.courseId];
      const flagship = getFlagshipStory(route.courseId);
      const title = live?.title ?? seo?.title;
      const description = live?.description ?? seo?.description ?? '';
      const stage = live?.stage ?? seo?.stage;
      const tier = live?.tier ?? seo?.tier;
      const slugPath = prettyCoursePath(route.courseId) ?? `/course/${route.courseId}`;
      // Static /courses/<slug>/ pages are served at the trailing-slash URL (host 301s the bare path).
      const canonical = slugPath.startsWith('/courses/') ? `${SITE}${slugPath}/` : `${SITE}${slugPath}`;
      const pageTitle = flagship?.metaTitle ?? (title ? `${title} | ForgeLine` : DEFAULT_TITLE);
      const pageDesc = flagship?.metaDescription ? flagship.metaDescription : (clipMetaDescription(description) || DEFAULT_DESCRIPTION);
      const kws = keywordsForCourse(route.courseId);

      document.title = titleFor(pageTitle, title);
      upsertMeta('name', 'description', pageDesc);
      upsertMeta('property', 'og:title', pageTitle);
      upsertMeta('property', 'og:description', pageDesc);
      upsertMeta('property', 'og:url', canonical);
      upsertLink('canonical', canonical);
      setRobots(true);
      if (kws.length) upsertMeta('name', 'keywords', kws.join(', '));
      else removeMeta('name', 'keywords');

      const jsonLd: Record<string, unknown> = {
        '@context': 'https://schema.org',
        '@type': 'Course',
        name: title ?? flagship?.metaTitle ?? 'ForgeLine course',
        description: flagship?.jsonLdDescription ?? description,
        url: canonical,
        isAccessibleForFree: tier === 'free',
        provider: {
          '@type': 'Organization',
          name: 'ForgeLine Academy',
          url: `${SITE}/`,
        },
      };
      if (stage) {
        jsonLd.isPartOf = {
          '@type': 'Course',
          name: flagship?.pathLabel ?? PATH_LABEL[stage] ?? 'ForgeLine path',
          url: `${SITE}/paths`,
        };
      }
      if (kws.length) {
        jsonLd.keywords = kws.join(', ');
        jsonLd.about = kws.map((name) => ({ '@type': 'Thing', name }));
      }
      upsertJsonLd('seo-jsonld-course', jsonLd);
      return () => {
        upsertJsonLd('seo-jsonld-course', null);
      };
    }

    const meta = ROUTE_META[route.name];
    const title = meta?.title ?? DEFAULT_TITLE;
    const desc = meta?.description ?? DEFAULT_DESCRIPTION;
    // Legal pages keep their own path; app areas (dashboard, admin, company, auth, search, 404) are noindex.
    const path = route.name === 'legal' ? (route.doc === 'disclaimer' ? '/legal/disclaimer' : `/${route.doc}`) : meta?.path;
    const url = path ? (path === '/' ? `${SITE}/` : `${SITE}${path}`) : null;
    document.title = titleFor(title);
    upsertMeta('name', 'description', desc);
    upsertMeta('property', 'og:title', title);
    upsertMeta('property', 'og:description', desc);
    if (url) {
      upsertMeta('property', 'og:url', url);
      upsertLink('canonical', url);
    } else {
      document.head.querySelector('link[rel="canonical"]')?.remove();
    }
    setRobots(Boolean(url));
    removeMeta('name', 'keywords');
    upsertJsonLd('seo-jsonld-course', null);
  }, [route, courses, titleFor]);

  return null;
}
