import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import type {
  Course,
  LessonWithModule,
  UserProgress,
  Certificate,
  QuizQuestion,
} from '@/lib/types';

export async function fetchCourses(): Promise<Course[]> {
  const { data, error } = await supabase
    .from('courses')
    .select('*')
    .order('stage', { ascending: true })
    .order('sort_order', { ascending: true });
  if (error) throw error;
  return data ?? [];
}

export async function fetchCourse(id: string): Promise<Course | null> {
  const { data, error } = await supabase
    .from('courses')
    .select('*')
    .eq('id', id)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function fetchLessons(courseId: string): Promise<LessonWithModule[]> {
  const { data: modules, error: modErr } = await supabase
    .from('modules')
    .select('id, title, sort_order')
    .eq('course_id', courseId)
    .order('sort_order', { ascending: true });
  if (modErr) throw modErr;
  const mods = modules ?? [];
  if (mods.length === 0) return [];
  const ids = mods.map((m) => m.id);
  const { data, error } = await supabase
    .from('lessons')
    .select('id, module_id, title, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order, video_url, video_filename, video_uploaded_at')
    .in('module_id', ids)
    .order('sort_order', { ascending: true });
  if (error) throw error;
  const byId = new Map(mods.map((m) => [m.id, m]));
  return (data ?? []).map((r) => {
    const mod = byId.get(r.module_id);
    return {
      id: r.id,
      module_id: r.module_id,
      title: r.title,
      content: null,
      estimated_minutes: r.estimated_minutes,
      has_video: r.has_video,
      has_pdf: r.has_pdf,
      quiz: (r.quiz as QuizQuestion[] | null) ?? [],
      pass_threshold: r.pass_threshold,
      sort_order: r.sort_order,
      video_url: r.video_url,
      video_filename: r.video_filename,
      video_uploaded_at: r.video_uploaded_at,
      module_title: mod?.title ?? '',
      module_sort_order: mod?.sort_order ?? 0,
    };
  });
}

export async function fetchLessonContent(lessonId: string): Promise<string | null> {
  const { data, error } = await supabase
    .from('lessons')
    .select('content')
    .eq('id', lessonId)
    .maybeSingle();
  if (error) throw error;
  return (data?.content as string | null) ?? null;
}

export async function fetchProgress(courseId: string): Promise<UserProgress[]> {
  const { data, error } = await supabase
    .from('user_progress')
    .select('*')
    .eq('course_id', courseId);
  if (error) throw error;
  return data ?? [];
}

export async function fetchAllProgress(): Promise<UserProgress[]> {
  const { data, error } = await supabase.from('user_progress').select('*');
  if (error) throw error;
  return data ?? [];
}

export async function upsertProgress(
  p: Partial<UserProgress> & { lesson_id: string; course_id: string },
): Promise<UserProgress | null> {
  const { data, error } = await supabase
    .from('user_progress')
    .upsert(
      {
        lesson_id: p.lesson_id,
        course_id: p.course_id,
        quiz_score: p.quiz_score ?? null,
        completed: p.completed ?? false,
        completed_at: p.completed ? new Date().toISOString() : null,
      },
      { onConflict: 'user_id,lesson_id' },
    )
    .select()
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function fetchCertificates(): Promise<Certificate[]> {
  const { data, error } = await supabase
    .from('certificates')
    .select('*, course:courses(*)')
    .order('issued_at', { ascending: false });
  if (error) throw error;
  return data ?? [];
}

export async function issueCertificate(
  courseId: string,
): Promise<Certificate | null> {
  const { data, error } = await supabase
    .from('certificates')
    .upsert({ course_id: courseId }, { onConflict: 'user_id,course_id' })
    .select('*, course:courses(*)')
    .maybeSingle();
  if (error) throw error;
  return data;
}

export function useCourses() {
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const reload = useCallback(async () => {
    setLoading(true);
    try {
      setCourses(await fetchCourses());
      setError(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load courses');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void reload();
  }, [reload]);

  return { courses, loading, error, reload };
}

export function computeCourseProgress(
  totalLessons: number,
  progress: UserProgress[],
): number {
  if (totalLessons === 0) return 0;
  const completed = progress.filter((p) => p.completed).length;
  return Math.round((completed / totalLessons) * 100);
}
