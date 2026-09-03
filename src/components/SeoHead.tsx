import { useEffect } from 'react';
import type { Route } from '@/components/Nav';
import type { Course } from '@/lib/types';
import {
  COURSE_SEO_BY_ID,
  prettyCoursePath,
} from '@/lib/seo/courseSlugs';
import { keywordsForCourse } from '@/lib/seo/courseKeywords';
import { getFlagshipStory } from '@/lib/seo/flagshipStories';

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

function clipMetaDescription(text: string, max = 155): string {
  const clean = (text || '').replace(/\s+/g, ' ').trim();
  if (clean.length <= max) return clean;
  const cut = clean.slice(0, max);
  const sp = cut.lastIndexOf(' ');
  return `${(sp > 80 ? cut.slice(0, sp) : cut).trimEnd()}…`;
}

export function SeoHead({ route, courses = [] }: { route: Route; courses?: Course[] }) {
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
      const canonical = `${SITE}${slugPath}`;
      const pageTitle = flagship?.metaTitle ?? (title ? `${title} | ForgeLine` : DEFAULT_TITLE);
      const pageDesc = flagship?.metaDescription ? flagship.metaDescription : (clipMetaDescription(description) || DEFAULT_DESCRIPTION);
      const kws = keywordsForCourse(route.courseId);

      document.title = pageTitle;
      upsertMeta('name', 'description', pageDesc);
      upsertMeta('property', 'og:title', pageTitle);
      upsertMeta('property', 'og:description', pageDesc);
      upsertMeta('property', 'og:url', canonical);
      upsertLink('canonical', canonical);
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
          url: SITE,
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

    document.title = DEFAULT_TITLE;
    upsertMeta('name', 'description', DEFAULT_DESCRIPTION);
    upsertMeta('property', 'og:title', DEFAULT_TITLE);
    upsertMeta('property', 'og:description', DEFAULT_DESCRIPTION);
    upsertMeta('property', 'og:url', SITE);
    upsertLink('canonical', `${SITE}/`);
    removeMeta('name', 'keywords');
    upsertJsonLd('seo-jsonld-course', null);
  }, [route, courses]);

  return null;
}
