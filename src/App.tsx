import { Suspense, lazy, useCallback, useEffect, useMemo, useState } from 'react';
import { AuthProvider, useAuth } from '@/lib/auth';
import { CompanyThemeProvider } from '@/lib/theme/CompanyThemeProvider';
import { useCourses, fetchAllProgress, fetchCertificates } from '@/lib/data';
import { supabase } from '@/lib/supabase';
import { trackPageView } from '@/lib/analytics';
import { legacyCourseRedirect, pathToRoute, routeToPath } from '@/lib/routing';
import { NotFound } from '@/pages/NotFound';
import type { UserProgress, Certificate } from '@/lib/types';
import { Nav, type Route } from '@/components/Nav';
import { Footer } from '@/components/Footer';
import { SeoHead } from '@/components/SeoHead';
import { Home } from '@/pages/Home';
const Catalog = lazy(() => import('@/pages/Catalog').then((m) => ({ default: m.Catalog })));
const Paths = lazy(() => import('@/pages/Paths').then((m) => ({ default: m.Paths })));
const CourseDetail = lazy(() => import('@/pages/CourseDetail').then((m) => ({ default: m.CourseDetail })));
const CourseGames = lazy(() => import('@/pages/CourseGames').then((m) => ({ default: m.CourseGames })));
const Dashboard = lazy(() => import('@/pages/Dashboard').then((m) => ({ default: m.Dashboard })));
const Certificates = lazy(() => import('@/pages/Certificates').then((m) => ({ default: m.Certificates })));
const Auth = lazy(() => import('@/pages/Auth').then((m) => ({ default: m.Auth })));
const Pricing = lazy(() => import('@/pages/Pricing').then((m) => ({ default: m.Pricing })));
const Admin = lazy(() => import('@/pages/Admin').then((m) => ({ default: m.Admin })));
const Legal = lazy(() => import('@/pages/Legal').then((m) => ({ default: m.Legal })));
const BookMeeting = lazy(() => import('@/pages/BookMeeting').then((m) => ({ default: m.BookMeeting })));
const Services = lazy(() => import('@/pages/Services').then((m) => ({ default: m.Services })));
const CompanyAdmin = lazy(() => import('@/pages/CompanyAdmin').then((m) => ({ default: m.CompanyAdmin })));
const SkillAssessment = lazy(() => import('@/pages/SkillAssessment').then((m) => ({ default: m.SkillAssessment })));
const Announcements = lazy(() => import('@/pages/Announcements').then((m) => ({ default: m.Announcements })));
const ManagerDashboard = lazy(() => import('@/components/manager/ManagerDashboard').then((m) => ({ default: m.ManagerDashboard })));

function AppContent() {
  const { user, loading: authLoading, profileReady, isCompanyManager, company, companyRole } = useAuth();
  // Owner/admin of an active company: landing + Dashboard become the Company Manager Dashboard.
  const managerView = Boolean(user && isCompanyManager && company && (companyRole === 'owner' || companyRole === 'admin' || companyRole === 'supervisor'));
  // Signed-in user whose profile/company is still loading: don't flash the learner view at a manager.
  const awaitingRole = Boolean(user && !profileReady);
  const { courses, loading: coursesLoading } = useCourses();
  const [route, setRoute] = useState<Route>(() => pathToRoute(window.location.pathname, window.location.search));
  const [progress, setProgress] = useState<UserProgress[]>([]);
  const [certs, setCerts] = useState<Certificate[]>([]);
  const [progressTick, setProgressTick] = useState(0);
  const [showWelcome, setShowWelcome] = useState(false);

  const loadUserData = useCallback(async () => {
    if (!user) {
      setProgress([]);
      setCerts([]);
      return;
    }
    try {
      const [p, c] = await Promise.all([fetchAllProgress(), fetchCertificates()]);
      setProgress(p);
      setCerts(c);
    } catch {
      // silent — dashboard will show empty state
    }
  }, [user]);

  useEffect(() => {
    void loadUserData();
  }, [loadUserData, progressTick]);

  useEffect(() => {
    trackPageView(route.name);
  }, [route.name]);

  // Old in-app links landed on /courses/<slug> (the static SEO page path): move the app to /course/<slug>.
  useEffect(() => {
    const to = legacyCourseRedirect(window.location.pathname);
    if (to) window.history.replaceState(window.history.state, '', to + window.location.search + window.location.hash);
  }, [route]);

  useEffect(() => {
    const onPop = () => setRoute(pathToRoute(window.location.pathname, window.location.search));
    window.addEventListener('popstate', onPop);
    return () => window.removeEventListener('popstate', onPop);
  }, []);

  function navigate(r: Route) {
    setRoute(r);
    const path = routeToPath(r);
    const next = window.location.pathname === path ? path + window.location.search : path;
    const cur = `${window.location.pathname}${window.location.search}`;
    if (cur !== next) window.history.pushState(null, '', next);
    if (r.name === 'paths' && (r.focusPath || r.showWelcome)) {
      setShowWelcome(true);
    }
    window.scrollTo({ top: 0, behavior: 'instant' });
  }

  function onProgressChanged() {
    setProgressTick((t) => t + 1);
  }

  // Fetch lesson counts per course for accurate progress. Fetch once courses load.
  const [lessonCounts, setLessonCounts] = useState<Record<string, number>>({});
  useEffect(() => {
    if (courses.length === 0) return;
    let cancelled = false;
    (async () => {
      const { data } = await supabase
        .from('lessons')
        .select('module_id, modules!inner(course_id)');
      if (cancelled || !data) return;
      const counts: Record<string, number> = {};
      for (const row of data as unknown as { modules: { course_id: string } }[]) {
        const cid = row.modules.course_id;
        counts[cid] = (counts[cid] ?? 0) + 1;
      }
      setLessonCounts(counts);
    })();
    return () => {
      cancelled = true;
    };
  }, [courses]);

  const courseProgressMap = useMemo(() => {
    const m: Record<string, number> = {};
    for (const c of courses) {
      const total = lessonCounts[c.id] ?? 0;
      const completed = progress.filter(
        (p) => p.course_id === c.id && p.completed,
      ).length;
      m[c.id] = total > 0 ? Math.round((completed / total) * 100) : 0;
    }
    return m;
  }, [courses, progress, lessonCounts]);

  const certCourseIds = useMemo(
    () => new Set(certs.map((c) => c.course_id)),
    [certs],
  );

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-navy-900">
        <div className="flex flex-col items-center gap-3">
          <div className="w-10 h-10 rounded-full border-2 border-accent-500/30 border-t-accent-500 animate-spin" />
          <p className="text-sm text-steel-400">Loading ForgeLine Academy...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col bg-navy-900">
      <SeoHead route={route} courses={courses} />
      <Nav route={route} onNavigate={navigate} />
      <main className="flex-1">
      <Suspense fallback={<div className="min-h-screen" aria-busy="true" />}>
        {(route.name === 'home' || route.name === 'dashboard') && awaitingRole && (
          <div className="pt-32 flex justify-center"><div className="w-8 h-8 rounded-full border-2 border-accent-500/30 border-t-accent-500 animate-spin" /></div>
        )}
        {(route.name === 'home' || route.name === 'dashboard') && !awaitingRole && managerView && company && user && (
          <ManagerDashboard
            company={company}
            currentUserId={user.id}
            currentRole={companyRole === 'owner' ? 'owner' : companyRole === 'supervisor' ? 'supervisor' : 'admin'}
            onNavigate={navigate}
          />
        )}
        {route.name === 'home' && !awaitingRole && !managerView && (
          <Home
            courses={courses}
            loading={coursesLoading}
            progressMap={courseProgressMap}
            certCourseIds={certCourseIds}
            onNavigate={navigate}
          />
        )}
        {route.name === 'catalog' && (
          <Catalog
            courses={courses}
            loading={coursesLoading}
            progressMap={courseProgressMap}
            certCourseIds={certCourseIds}
            onNavigate={navigate}
            managerView={managerView}
          />
        )}
        {route.name === 'paths' && (
          <Paths
            courses={courses}
            progressMap={courseProgressMap}
            onNavigate={navigate}
            focusPath={route.focusPath}
            showWelcome={showWelcome}
          />
        )}
        {route.name === 'course' && (
          <CourseDetail
            courseId={route.courseId}
            preloadedCourse={courses.find((c) => c.id === route.courseId) ?? null}
            onNavigate={navigate}
            onProgressChanged={onProgressChanged}
          />
        )}
        {route.name === 'games' && (
          <CourseGames courseId={route.courseId} onNavigate={navigate} />
        )}
        {route.name === 'dashboard' && !awaitingRole && !managerView && (
          <Dashboard courses={courses} onNavigate={navigate} progressMap={courseProgressMap} certs={certs} />
        )}
        {route.name === 'certificates' && <Certificates onNavigate={navigate} certificates={certs} />}
        {route.name === 'auth' && <Auth onNavigate={navigate} initialMode={route.mode} initialPath={route.path} />}
        {route.name === 'pricing' && <Pricing onNavigate={navigate} />}
        {route.name === 'admin' && <Admin onNavigate={navigate} />}
        {route.name === 'company' && <CompanyAdmin onNavigate={navigate} companyId={route.companyId} />}
        {route.name === 'legal' && (
          <Legal doc={route.doc} onNavigate={navigate} />
        )}
        {route.name === 'book' && <BookMeeting onNavigate={navigate} />}
        {route.name === 'services' && <Services onNavigate={navigate} />}
        {route.name === 'assessment' && (
          <SkillAssessment
            onComplete={() => {
              navigate({ name: 'home' });
            }}
            onNavigate={navigate}
          />
        )}
        {route.name === 'announcements' && <Announcements onNavigate={navigate} />}
        {route.name === 'notfound' && <NotFound path={route.path} onNavigate={navigate} />}
        {route.name === 'search' && (
          <Catalog
            courses={courses}
            loading={coursesLoading}
            progressMap={courseProgressMap}
            certCourseIds={certCourseIds}
            onNavigate={navigate}
            initialQuery={route.query}
            managerView={managerView}
          />
        )}
      </Suspense>
      </main>
      <Footer onNavigate={navigate} />
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <CompanyThemeProvider>
        <AppContent />
      </CompanyThemeProvider>
    </AuthProvider>
  );
}
