import { useCallback, useEffect, useMemo, useState } from 'react';
import { AuthProvider, useAuth } from '@/lib/auth';
import { useCourses, fetchAllProgress, fetchCertificates } from '@/lib/data';
import { supabase } from '@/lib/supabase';
import { trackPageView } from '@/lib/analytics';
import { pathToRoute, routeToPath } from '@/lib/routing';
import type { UserProgress, Certificate } from '@/lib/types';
import { Nav, type Route } from '@/components/Nav';
import { Footer } from '@/components/Footer';
import { Home } from '@/pages/Home';
import { Catalog } from '@/pages/Catalog';
import { Paths } from '@/pages/Paths';
import { CourseDetail } from '@/pages/CourseDetail';
import { CourseGames } from '@/pages/CourseGames';
import { Dashboard } from '@/pages/Dashboard';
import { Certificates } from '@/pages/Certificates';
import { Auth } from '@/pages/Auth';
import { Pricing } from '@/pages/Pricing';
import { Admin } from '@/pages/Admin';
import { Legal } from '@/pages/Legal';
import { BookMeeting } from '@/pages/BookMeeting';
import { Services } from '@/pages/Services';
import { CompanyAdmin } from '@/pages/CompanyAdmin';
import { SkillAssessment } from '@/pages/SkillAssessment';

function AppContent() {
  const { user, loading: authLoading } = useAuth();
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

  useEffect(() => {
    const onPop = () => setRoute(pathToRoute(window.location.pathname, window.location.search));
    window.addEventListener('popstate', onPop);
    return () => window.removeEventListener('popstate', onPop);
  }, []);

  function navigate(r: Route) {
    setRoute(r);
    const next = routeToPath(r);
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
      <Nav route={route} onNavigate={navigate} />
      <main className="flex-1">
        {route.name === 'home' && (
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
        {route.name === 'dashboard' && (
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
        {route.name === 'search' && (
          <Catalog
            courses={courses}
            loading={coursesLoading}
            progressMap={courseProgressMap}
            certCourseIds={certCourseIds}
            onNavigate={navigate}
            initialQuery={route.query}
          />
        )}
      </main>
      <Footer onNavigate={navigate} />
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}
