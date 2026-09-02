import { useCallback, useEffect, useState } from 'react';
import {
  Upload,
  Trash2,
  Video,
  ChevronDown,
  ChevronRight,
  Search,
  ShieldAlert,
  Loader2,
  CheckCircle2,
  Film,
  X,
  Link2,
  Eye,
  EyeOff,
  FileText,
  Layers,
  Tag,
  Calendar,
  Building2,
  Wrench,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/lib/auth';
import { fetchCourses } from '@/lib/data';
import type { Course, Stage } from '@/lib/types';
import { STAGE_LABEL } from '@/lib/types';
import { CustomCourseBuilder } from '@/components/CustomCourseBuilder';
import { PromoManager } from '@/components/PromoManager';
import { BookingsManager } from '@/components/BookingsManager';
import { CompanyManager } from '@/components/CompanyManager';
import { ServiceRequestsManager } from '@/components/ServiceRequestsManager';
import type { Route } from '@/components/Nav';

interface LessonWithVideo {
  id: string;
  module_id: string;
  title: string;
  sort_order: number;
  video_url: string | null;
  video_filename: string | null;
  video_uploaded_at: string | null;
}

interface ModuleWithCourse {
  id: string;
  course_id: string;
  title: string;
  sort_order: number;
  course_title: string;
  course_stage: Stage;
  lessons: LessonWithVideo[];
}

export function Admin({ onNavigate }: { onNavigate: (r: { name: string }) => void }) {
  const { user, isAdmin, loading: authLoading } = useAuth();
  const [activeTab, setActiveTab] = useState<'videos' | 'custom' | 'promos' | 'bookings' | 'companies' | 'services'>('videos');
  const [courses, setCourses] = useState<Course[]>([]);
  const [modules, setModules] = useState<ModuleWithCourse[]>([]);
  const [loading, setLoading] = useState(true);
  const [expandedStage, setExpandedStage] = useState<Stage | null>(null);
  const [expandedCourse, setExpandedCourse] = useState<string | null>(null);
  const [expandedModule, setExpandedModule] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [uploadingLessonId, setUploadingLessonId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const courseData = await fetchCourses();
      setCourses(courseData);

      const { data: modData, error: modErr } = await supabase
        .from('modules')
        .select('id, course_id, title, sort_order, courses!inner(title, stage)')
        .order('sort_order', { ascending: true });

      if (modErr) throw modErr;

      const { data: lessonData, error: lessonErr } = await supabase
        .from('lessons')
        .select('id, module_id, title, sort_order, video_url, video_filename, video_uploaded_at')
        .order('sort_order', { ascending: true });

      if (lessonErr) throw lessonErr;

      const lessonsByModule: Record<string, LessonWithVideo[]> = {};
      for (const row of lessonData ?? []) {
        const r = row as unknown as LessonWithVideo;
        if (!lessonsByModule[r.module_id]) lessonsByModule[r.module_id] = [];
        lessonsByModule[r.module_id].push(r);
      }

      const mapped: ModuleWithCourse[] = (modData ?? []).map((row) => {
        const r = row as unknown as {
          id: string;
          course_id: string;
          title: string;
          sort_order: number;
          courses: { title: string; stage: Stage };
        };
        return {
          id: r.id,
          course_id: r.course_id,
          title: r.title,
          sort_order: r.sort_order,
          course_title: r.courses.title,
          course_stage: r.courses.stage,
          lessons: lessonsByModule[r.id] ?? [],
        };
      });

      setModules(mapped);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load data');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  useEffect(() => {
    if (error) {
      const t = setTimeout(() => setError(null), 5000);
      return () => clearTimeout(t);
    }
  }, [error]);

  useEffect(() => {
    if (success) {
      const t = setTimeout(() => setSuccess(null), 5000);
      return () => clearTimeout(t);
    }
  }, [success]);

  async function handleUpload(lessonId: string, file: File) {
    setUploadingLessonId(lessonId);
    setError(null);
    try {
      const ext = file.name.split('.').pop()?.toLowerCase() ?? 'mp4';
      const filePath = `${lessonId}/video.${ext}`;

      const { error: upErr } = await supabase.storage
        .from('module-videos')
        .upload(filePath, file, {
          upsert: true,
          contentType: file.type || 'video/mp4',
        });

      if (upErr) throw upErr;

      const { data: urlData } = supabase.storage
        .from('module-videos')
        .getPublicUrl(filePath);

      const { data: upData, error: dbErr } = await supabase
        .from('lessons')
        .update({
          video_url: urlData.publicUrl,
          video_filename: file.name,
          video_uploaded_at: new Date().toISOString(),
        })
        .eq('id', lessonId)
        .select();

      if (dbErr) throw dbErr;
      if (!upData || upData.length === 0) {
        throw new Error('Update was blocked by security rules. Make sure you are signed in as an admin.');
      }

      setSuccess(`Video "${file.name}" uploaded successfully.`);
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Upload failed');
    } finally {
      setUploadingLessonId(null);
    }
  }

  async function handleDeleteVideo(lessonId: string, videoUrl: string) {
    setError(null);
    try {
      if (videoUrl.includes('module-videos')) {
        const url = new URL(videoUrl);
        const path = url.pathname.split('/module-videos/')[1];
        if (path) {
          await supabase.storage.from('module-videos').remove([path]);
        }
      }

      const { data: delData, error: dbErr } = await supabase
        .from('lessons')
        .update({
          video_url: null,
          video_filename: null,
          video_uploaded_at: null,
        })
        .eq('id', lessonId)
        .select();

      if (dbErr) throw dbErr;
      if (!delData || delData.length === 0) {
        throw new Error('Update was blocked by security rules. Make sure you are signed in as an admin.');
      }

      setSuccess('Video removed.');
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Delete failed');
    }
  }

  async function handleEmbedUrl(lessonId: string, url: string) {
    setError(null);
    try {
      const { data, error: dbErr } = await supabase
        .from('lessons')
        .update({
          video_url: url,
          video_filename: url,
          video_uploaded_at: new Date().toISOString(),
        })
        .eq('id', lessonId)
        .select();

      if (dbErr) throw dbErr;
      if (!data || data.length === 0) {
        throw new Error('Update was blocked by security rules. Make sure you are signed in as an admin.');
      }

      setSuccess('Video URL saved.');
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to save URL');
    }
  }

  if (authLoading) {
    return (
      <div className="pt-24 min-h-screen flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-accent-500 animate-spin" />
      </div>
    );
  }

  if (!user || !isAdmin) {
    return (
      <div className="pt-24 min-h-screen flex items-center justify-center px-4">
        <div className="max-w-md text-center">
          <ShieldAlert className="w-12 h-12 text-error-400 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-white mb-2">Admin Access Required</h1>
          <p className="text-steel-400 mb-6">
            You need an administrator account to access this page.
          </p>
          <button
            onClick={() => onNavigate({ name: 'auth' })}
            className="btn-primary"
          >
            Sign in
          </button>
        </div>
      </div>
    );
  }

  const stages: Stage[] = ['mechanical', 'electrical', 'ie', 'engineering'];

  const filteredModules = modules.filter((m) => {
    if (!searchQuery) return true;
    const q = searchQuery.toLowerCase();
    return (
      m.title.toLowerCase().includes(q) ||
      m.course_title.toLowerCase().includes(q) ||
      m.lessons.some((l) => l.title.toLowerCase().includes(q))
    );
  });

  const modulesByStage = (stage: Stage) =>
    filteredModules.filter((m) => m.course_stage === stage);

  const modulesByCourse = (courseId: string) =>
    filteredModules.filter((m) => m.course_id === courseId);

  return (
    <div className="pt-20 pb-16 min-h-screen">
      <div className="max-w-7xl mx-auto px-4 sm:px-6">
        <div className="mb-6">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 rounded-lg bg-accent-500/20 flex items-center justify-center">
              <Film className="w-5 h-5 text-accent-300" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-white">Admin Dashboard</h1>
              <p className="text-sm text-steel-400">
                Manage training content and custom courses.
              </p>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex items-center gap-1 mb-6 border-b border-steel-700/60">
          <button
            onClick={() => setActiveTab('videos')}
            className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors border-b-2 -mb-px ${
              activeTab === 'videos'
                ? 'text-white border-accent-500'
                : 'text-steel-400 border-transparent hover:text-steel-200'
            }`}
          >
            <Film className="w-4 h-4" />
            Video Manager
          </button>
          <button
            onClick={() => setActiveTab('custom')}
            className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors border-b-2 -mb-px ${
              activeTab === 'custom'
                ? 'text-white border-accent-500'
                : 'text-steel-400 border-transparent hover:text-steel-200'
            }`}
          >
            <Layers className="w-4 h-4" />
            Custom Courses
          </button>
          <button
            onClick={() => setActiveTab('promos')}
            className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors border-b-2 -mb-px ${
              activeTab === 'promos'
                ? 'text-white border-accent-500'
                : 'text-steel-400 border-transparent hover:text-steel-200'
            }`}
          >
            <Tag className="w-4 h-4" />
            Promos & Referrals
          </button>
          <button
            onClick={() => setActiveTab('bookings')}
            className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors border-b-2 -mb-px ${
              activeTab === 'bookings'
                ? 'text-white border-accent-500'
                : 'text-steel-400 border-transparent hover:text-steel-200'
            }`}
          >
            <Calendar className="w-4 h-4" />
            Bookings
          </button>
          <button
            onClick={() => setActiveTab('companies')}
            className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors border-b-2 -mb-px ${
              activeTab === 'companies'
                ? 'text-white border-accent-500'
                : 'text-steel-400 border-transparent hover:text-steel-200'
            }`}
          >
            <Building2 className="w-4 h-4" />
            Companies
          </button>
          <button
            onClick={() => setActiveTab('services')}
            className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors border-b-2 -mb-px ${
              activeTab === 'services'
                ? 'text-white border-accent-500'
                : 'text-steel-400 border-transparent hover:text-steel-200'
            }`}
          >
            <Wrench className="w-4 h-4" />
            Service Requests
          </button>
        </div>

        {activeTab === 'custom' ? (
          <CustomCourseBuilder />
        ) : activeTab === 'promos' ? (
          <PromoManager />
        ) : activeTab === 'bookings' ? (
          <BookingsManager />
        ) : activeTab === 'companies' ? (
          <CompanyManager onNavigate={onNavigate as (r: Route) => void} />
        ) : activeTab === 'services' ? (
          <ServiceRequestsManager />
        ) : (
          <>
        {error && (
          <div className="mb-4 flex items-start gap-3 p-4 rounded-lg bg-error-950/50 border border-error-700/50">
            <X
              className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5 cursor-pointer"
              onClick={() => setError(null)}
            />
            <p className="text-sm text-error-200">{error}</p>
          </div>
        )}
        {success && (
          <div className="mb-4 flex items-start gap-3 p-4 rounded-lg bg-success-950/50 border border-success-700/50">
            <CheckCircle2 className="w-5 h-5 text-success-400 flex-shrink-0 mt-0.5" />
            <p className="text-sm text-success-200">{success}</p>
          </div>
        )}

        <div className="mb-6">
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-steel-500" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search lessons, modules, or courses..."
              className="w-full pl-9 pr-3 py-2.5 text-sm bg-navy-950/60 border border-steel-700 rounded-lg text-steel-100 placeholder-steel-500 focus:outline-none focus:border-accent-500 transition-colors"
            />
          </div>
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-20">
            <Loader2 className="w-8 h-8 text-accent-500 animate-spin" />
          </div>
        ) : (
          <div className="space-y-3">
            {stages.map((stage) => {
              const stageModules = modulesByStage(stage);
              if (stageModules.length === 0) return null;

              const stageCourses = courses.filter(
                (c) => c.stage === stage && stageModules.some((m) => m.course_id === c.id),
              );
              const stageExpanded = expandedStage === stage;
              const allLessons = stageModules.flatMap((m) => m.lessons);
              const withVideos = allLessons.filter((l) => l.video_url).length;

              return (
                <div
                  key={stage}
                  className="rounded-xl border border-steel-700/60 bg-navy-800/40 overflow-hidden"
                >
                  <button
                    onClick={() => setExpandedStage(stageExpanded ? null : stage)}
                    className="w-full flex items-center justify-between p-4 hover:bg-navy-800/60 transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      {stageExpanded ? (
                        <ChevronDown className="w-5 h-5 text-steel-400" />
                      ) : (
                        <ChevronRight className="w-5 h-5 text-steel-400" />
                      )}
                      <span className="text-lg font-semibold text-white">
                        {STAGE_LABEL[stage]}
                      </span>
                      <span className="text-sm text-steel-500">
                        {stageCourses.length} courses · {allLessons.length} lessons
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs px-2 py-1 rounded-full bg-accent-500/10 text-accent-300 border border-accent-500/20">
                        {withVideos} with video
                      </span>
                      <span className="text-xs px-2 py-1 rounded-full bg-navy-700/50 text-steel-400 border border-steel-700/50">
                        {allLessons.length - withVideos} without
                      </span>
                    </div>
                  </button>

                  {stageExpanded && (
                    <div className="border-t border-steel-700/40">
                      {stageCourses.map((course) => {
                        const courseModules = modulesByCourse(course.id);
                        if (courseModules.length === 0) return null;

                        const courseExpanded = expandedCourse === course.id;
                        const courseLessons = courseModules.flatMap((m) => m.lessons);
                        const courseWithVideos = courseLessons.filter((l) => l.video_url).length;

                        return (
                          <div key={course.id}>
                            <button
                              onClick={() =>
                                setExpandedCourse(courseExpanded ? null : course.id)
                              }
                              className="w-full flex items-center justify-between px-6 py-3 hover:bg-navy-800/40 transition-colors"
                            >
                              <div className="flex items-center gap-3">
                                {courseExpanded ? (
                                  <ChevronDown className="w-4 h-4 text-steel-500" />
                                ) : (
                                  <ChevronRight className="w-4 h-4 text-steel-500" />
                                )}
                                <span className="text-sm font-medium text-steel-200">
                                  {course.title}
                                </span>
                              </div>
                              <span className="text-xs text-steel-500">
                                {courseWithVideos}/{courseLessons.length} videos
                              </span>
                            </button>

                            {courseExpanded && (
                              <div className="px-6 pb-4">
                                <div className="space-y-2">
                                  {courseModules.map((mod) => {
                                    const moduleExpanded = expandedModule === mod.id;
                                    const modWithVideos = mod.lessons.filter((l) => l.video_url).length;

                                    return (
                                      <div key={mod.id} className="rounded-lg border border-steel-800/40 bg-navy-950/20 overflow-hidden">
                                        <button
                                          onClick={() => setExpandedModule(moduleExpanded ? null : mod.id)}
                                          className="w-full flex items-center justify-between px-4 py-2.5 hover:bg-navy-900/40 transition-colors"
                                        >
                                          <div className="flex items-center gap-2.5">
                                            {moduleExpanded ? (
                                              <ChevronDown className="w-4 h-4 text-steel-500" />
                                            ) : (
                                              <ChevronRight className="w-4 h-4 text-steel-500" />
                                            )}
                                            <span className="text-xs font-medium text-steel-300">{mod.title}</span>
                                            <span className="text-[10px] text-steel-600">
                                              {mod.lessons.length} lessons
                                            </span>
                                          </div>
                                          <span className="text-[10px] text-steel-600">
                                            {modWithVideos}/{mod.lessons.length} videos
                                          </span>
                                        </button>

                                        {moduleExpanded && (
                                          <div className="px-3 pb-3 space-y-1.5">
                                            {mod.lessons.length === 0 ? (
                                              <p className="text-xs text-steel-600 px-3 py-2">No lessons in this module.</p>
                                            ) : (
                                              mod.lessons.map((lesson) => (
                                                <LessonVideoRow
                                                  key={lesson.id}
                                                  lesson={lesson}
                                                  uploading={uploadingLessonId === lesson.id}
                                                  onUpload={(file) => handleUpload(lesson.id, file)}
                                                  onEmbedUrl={(url) => handleEmbedUrl(lesson.id, url)}
                                                  onDelete={() => lesson.video_url && handleDeleteVideo(lesson.id, lesson.video_url)}
                                                />
                                              ))
                                            )}
                                          </div>
                                        )}
                                      </div>
                                    );
                                  })}
                                </div>
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
          </>
        )}
      </div>
    </div>
  );
}

function extractEmbedUrl(input: string): string | null {
  const trimmed = input.trim();
  if (!trimmed) return null;
  try {
    new URL(trimmed);
    return trimmed;
  } catch {
    const srcMatch = trimmed.match(/src=["']([^"']+)["']/i);
    if (srcMatch) return srcMatch[1];
    return null;
  }
}

function getEmbedUrl(url: string): { type: 'iframe' | 'video'; src: string } | null {
  try {
    const u = new URL(url.trim());
    const host = u.hostname.replace(/^www\./, '');

    // YouTube (all common formats)
    if (host === 'youtube.com' || host === 'm.youtube.com' || host === 'youtube-nocookie.com' || host === 'youtu.be') {
      let videoId: string | null = null;

      if (host === 'youtu.be') {
        videoId = u.pathname.slice(1).split('/')[0].split('?')[0] || null;
      } else {
        videoId = u.searchParams.get('v');
        if (!videoId) {
          const embedMatch = u.pathname.match(/\/embed\/([^/?]+)/);
          if (embedMatch) videoId = embedMatch[1];
        }
        if (!videoId) {
          const shortsMatch = u.pathname.match(/\/shorts\/([^/?]+)/);
          if (shortsMatch) videoId = shortsMatch[1];
        }
        if (!videoId) {
          const liveMatch = u.pathname.match(/\/live\/([^/?]+)/);
          if (liveMatch) videoId = liveMatch[1];
        }
      }

      if (videoId) {
        return {
          type: 'iframe',
          src: `https://www.youtube.com/embed/${videoId}?rel=0&modestbranding=1`,
        };
      }
    }

    // Vimeo
    if (host === 'vimeo.com' || host === 'player.vimeo.com') {
      const parts = u.pathname.split('/').filter(Boolean);
      const videoId = parts[0] === 'video' ? parts[1] : parts[0];
      if (videoId) {
        return { type: 'iframe', src: `https://player.vimeo.com/video/${videoId}` };
      }
    }

    // Loom
    if (host === 'loom.com' || host === 'www.loom.com') {
      const parts = u.pathname.split('/');
      const shareIdx = parts.indexOf('share');
      const embedIdx = parts.indexOf('embed');
      if (shareIdx >= 0 && parts[shareIdx + 1]) {
        return { type: 'iframe', src: `https://www.loom.com/embed/${parts[shareIdx + 1]}` };
      }
      if (embedIdx >= 0 && parts[embedIdx + 1]) {
        return { type: 'iframe', src: `https://www.loom.com/embed/${parts[embedIdx + 1]}` };
      }
    }

    // Direct video files or Supabase storage
    if (/\.(mp4|webm|ogg|mov|m4v)(\?|$)/i.test(u.pathname) || url.includes('module-videos')) {
      return { type: 'video', src: url };
    }

    return null;
  } catch {
    return null;
  }
}

function LessonVideoRow({
  lesson,
  uploading,
  onUpload,
  onEmbedUrl,
  onDelete,
}: {
  lesson: LessonWithVideo;
  uploading: boolean;
  onUpload: (file: File) => void;
  onEmbedUrl: (url: string) => void;
  onDelete: () => void;
}) {
  const [dragOver, setDragOver] = useState(false);
  const [showEmbed, setShowEmbed] = useState(false);
  const [embedInput, setEmbedInput] = useState('');
  const [previewExpanded, setPreviewExpanded] = useState(false);

  function handleDrop(e: React.DragEvent) {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer.files[0];
    if (file && file.type.startsWith('video/')) onUpload(file);
  }

  function handleFileSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) onUpload(file);
    e.target.value = '';
  }

  function handleEmbedSubmit() {
    const trimmed = embedInput.trim();
    if (!trimmed) return;
    const extracted = extractEmbedUrl(trimmed);
    if (!extracted) return;
    onEmbedUrl(extracted);
    setEmbedInput('');
    setShowEmbed(false);
  }

  const hasVideo = Boolean(lesson.video_url);
  const uploadedDate = lesson.video_uploaded_at
    ? new Date(lesson.video_uploaded_at).toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
      })
    : null;

  const embedInfo = lesson.video_url ? getEmbedUrl(lesson.video_url) : null;

  return (
    <div
      className={`rounded-lg border transition-colors ${
        hasVideo
          ? 'bg-navy-900/40 border-steel-700/40'
          : dragOver
            ? 'bg-accent-500/10 border-accent-500/40'
            : 'bg-navy-950/30 border-steel-800/40'
      }`}
      onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
      onDragLeave={() => setDragOver(false)}
      onDrop={handleDrop}
    >
      <div className="flex items-center gap-3 p-2.5">
        <div className={`flex-shrink-0 w-8 h-8 rounded-lg flex items-center justify-center ${hasVideo ? 'bg-accent-500/15' : 'bg-navy-800/60'}`}>
          {uploading ? (
            <Loader2 className="w-4 h-4 text-accent-400 animate-spin" />
          ) : hasVideo ? (
            <Video className="w-4 h-4 text-accent-400" />
          ) : (
            <FileText className="w-4 h-4 text-steel-500" />
          )}
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <span className="text-xs font-medium text-steel-200 truncate">{lesson.title}</span>
          </div>
          {hasVideo ? (
            <div className="flex items-center gap-2 mt-0.5">
              <span className="text-[10px] text-accent-400 truncate max-w-[200px]">{lesson.video_filename}</span>
              {uploadedDate && <span className="text-[10px] text-steel-600">· {uploadedDate}</span>}
            </div>
          ) : (
            <p className="text-[10px] text-steel-600 mt-0.5">No video — upload or embed a URL</p>
          )}
        </div>

        <div className="flex items-center gap-1.5 flex-shrink-0">
          {uploading ? (
            <span className="text-[10px] text-accent-400">Uploading...</span>
          ) : hasVideo ? (
            <>
              <button
                onClick={() => setPreviewExpanded(!previewExpanded)}
                className="flex items-center gap-1 px-2 py-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-accent-300 hover:border-accent-500/40 transition-colors text-[10px] font-medium"
                title={previewExpanded ? 'Hide preview' : 'Show preview'}
              >
                {previewExpanded ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                {previewExpanded ? 'Hide' : 'Preview'}
              </button>
              <label className="p-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-accent-300 hover:border-accent-500/40 transition-colors cursor-pointer" title="Replace video">
                <Upload className="w-3.5 h-3.5" />
                <input type="file" accept="video/*" className="hidden" onChange={handleFileSelect} />
              </label>
              <button
                onClick={onDelete}
                className="p-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-error-400 hover:border-error-500/40 transition-colors"
                title="Remove video"
              >
                <Trash2 className="w-3.5 h-3.5" />
              </button>
            </>
          ) : (
            <>
              <label className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-accent-500/10 border border-accent-500/30 text-accent-300 hover:bg-accent-500/20 hover:border-accent-500/50 transition-colors cursor-pointer text-[10px] font-medium">
                <Upload className="w-3.5 h-3.5" />
                Upload
                <input type="file" accept="video/*" className="hidden" onChange={handleFileSelect} />
              </label>
              <button
                onClick={() => setShowEmbed(!showEmbed)}
                className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-300 hover:text-accent-300 hover:border-accent-500/40 transition-colors text-[10px] font-medium"
                title="Embed a video URL"
              >
                <Link2 className="w-3.5 h-3.5" />
                Embed URL
              </button>
            </>
          )}
        </div>
      </div>

      {showEmbed && !hasVideo && (
        <div className="px-2.5 pb-2.5">
          <div className="flex items-center gap-2">
            <input
              type="url"
              value={embedInput}
              onChange={(e) => setEmbedInput(e.target.value)}
              onKeyDown={(e) => { if (e.key === 'Enter') handleEmbedSubmit(); }}
              placeholder="Paste YouTube, Vimeo, Loom, or direct video URL..."
              className="flex-1 px-2.5 py-1.5 text-xs bg-navy-950/60 border border-steel-700 rounded-lg text-steel-100 placeholder-steel-500 focus:outline-none focus:border-accent-500 transition-colors"
              autoFocus
            />
            <button onClick={handleEmbedSubmit} className="px-2.5 py-1.5 rounded-lg bg-accent-500/20 border border-accent-500/40 text-accent-300 hover:bg-accent-500/30 transition-colors text-xs font-medium">
              Save
            </button>
            <button onClick={() => { setShowEmbed(false); setEmbedInput(''); }} className="px-2.5 py-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-steel-200 transition-colors text-xs">
              Cancel
            </button>
          </div>
        </div>
      )}

      {hasVideo && previewExpanded && (
        <div className="px-2.5 pb-2.5">
          <div className="relative w-full rounded-lg overflow-hidden bg-black border border-steel-700/40" style={{ aspectRatio: '16 / 9' }}>
            {embedInfo?.type === 'iframe' ? (
              <iframe
                src={embedInfo.src}
                className="absolute inset-0 w-full h-full border-0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowFullScreen
                title={lesson.title}
              />
            ) : embedInfo?.type === 'video' ? (
              <video src={embedInfo.src} className="absolute inset-0 w-full h-full" controls preload="metadata" />
            ) : (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-3">
                <Video className="w-8 h-8 text-steel-600" />
                <p className="text-sm text-steel-500 text-center px-4">
                  Could not embed this URL format.
                  <br />
                  <a href={lesson.video_url!} target="_blank" rel="noopener noreferrer" className="text-accent-400 hover:text-accent-300 underline">
                    Open in new tab
                  </a>
                </p>
              </div>
            )}
          </div>
          <p className="text-[10px] text-steel-500 mt-1 break-all">src: {embedInfo.src}</p>
        </div>
      )}
    </div>
  );
}
