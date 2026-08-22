import { useCallback, useEffect, useState } from 'react';
import {
  Plus,
  Trash2,
  ChevronDown,
  ChevronRight,
  Loader2,
  CheckCircle2,
  Users,
  BookOpen,
  Layers,
  GripVertical,
  Save,
  X,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';
import type { Stage, Difficulty } from '@/lib/types';
import { STAGE_LABEL } from '@/lib/types';

interface ModuleDraft {
  title: string;
  lessons: LessonDraft[];
}

interface LessonDraft {
  title: string;
  content: string;
  estimated_minutes: number;
}

interface CustomCourse {
  id: string;
  title: string;
  short_description: string;
  stage: Stage;
  assigned_user_id: string | null;
  created_at: string;
  assigned_email?: string | null;
}

interface ProfileRow {
  id: string;
  email: string;
  is_premium: boolean;
}

export function CustomCourseBuilder() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [shortDesc, setShortDesc] = useState('');
  const [stage, setStage] = useState<Stage>('mechanical');
  const [difficulty, setDifficulty] = useState<Difficulty>('intermediate');
  const [estimatedHours, setEstimatedHours] = useState(2);
  const [assignedUserId, setAssignedUserId] = useState('');
  const [profiles, setProfiles] = useState<ProfileRow[]>([]);
  const [modules, setModules] = useState<ModuleDraft[]>([{ title: '', lessons: [{ title: '', content: '', estimated_minutes: 30 }] }]);
  const [expandedModules, setExpandedModules] = useState<Set<number>>(new Set([0]));
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [customCourses, setCustomCourses] = useState<CustomCourse[]>([]);
  const [loadingCourses, setLoadingCourses] = useState(true);

  const loadProfiles = useCallback(async () => {
    const { data, error } = await supabase.rpc('list_users_for_admin');
    if (error) {
      console.error('Failed to load users:', error.message);
      return;
    }
    if (data) setProfiles(data as unknown as ProfileRow[]);
  }, []);

  const loadCustomCourses = useCallback(async () => {
    setLoadingCourses(true);
    const { data } = await supabase
      .from('courses')
      .select('id, title, short_description, stage, assigned_user_id, created_at')
      .eq('is_custom', true)
      .order('created_at', { ascending: false });
    if (data) {
      const courses = data as unknown as CustomCourse[];
      const { data: allUsers } = await supabase.rpc('list_users_for_admin');
      const userMap = new Map<string, string>();
      for (const u of (allUsers as unknown as ProfileRow[]) ?? []) {
        userMap.set(u.id, u.email);
      }
      const enriched = courses.map((c) => ({
        ...c,
        assigned_email: c.assigned_user_id ? (userMap.get(c.assigned_user_id) ?? null) : null,
      }));
      setCustomCourses(enriched);
    }
    setLoadingCourses(false);
  }, []);

  useEffect(() => {
    void loadProfiles();
    void loadCustomCourses();
  }, [loadProfiles, loadCustomCourses]);

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

  function addModule() {
    setModules([...modules, { title: '', lessons: [{ title: '', content: '', estimated_minutes: 30 }] }]);
    setExpandedModules(new Set([...expandedModules, modules.length]));
  }

  function removeModule(idx: number) {
    setModules(modules.filter((_, i) => i !== idx));
  }

  function updateModuleTitle(idx: number, val: string) {
    const updated = [...modules];
    updated[idx].title = val;
    setModules(updated);
  }

  function addLesson(modIdx: number) {
    const updated = [...modules];
    updated[modIdx].lessons.push({ title: '', content: '', estimated_minutes: 30 });
    setModules(updated);
  }

  function removeLesson(modIdx: number, lessonIdx: number) {
    const updated = [...modules];
    updated[modIdx].lessons.splice(lessonIdx, 1);
    setModules(updated);
  }

  function updateLesson(modIdx: number, lessonIdx: number, field: keyof LessonDraft, val: string | number) {
    const updated = [...modules];
    (updated[modIdx].lessons[lessonIdx] as unknown as Record<string, string | number>)[field] = val;
    setModules(updated);
  }

  function toggleModule(idx: number) {
    const next = new Set(expandedModules);
    if (next.has(idx)) next.delete(idx);
    else next.add(idx);
    setExpandedModules(next);
  }

  async function handleCreate() {
    setError(null);
    setSuccess(null);

    if (!title.trim()) {
      setError('Course title is required.');
      return;
    }
    if (!shortDesc.trim()) {
      setError('Short description is required.');
      return;
    }
    if (!description.trim()) {
      setError('Full description is required.');
      return;
    }
    if (!assignedUserId) {
      setError('You must assign this course to a user.');
      return;
    }
    const validModules = modules.filter((m) => m.title.trim());
    if (validModules.length === 0) {
      setError('At least one module with a title is required.');
      return;
    }

    setSaving(true);
    try {
      const modulesJson = validModules.map((m, i) => ({
        title: m.title.trim(),
        sort_order: i,
        lessons: m.lessons
          .filter((l) => l.title.trim())
          .map((l, j) => ({
            title: l.title.trim(),
            content: l.content.trim(),
            estimated_minutes: l.estimated_minutes,
            has_video: false,
            has_pdf: false,
            quiz: [],
            pass_threshold: 80,
            sort_order: j,
          })),
      }));

      const { data, error: rpcErr } = await supabase.rpc('create_custom_course', {
        p_title: title.trim(),
        p_description: description.trim(),
        p_short_description: shortDesc.trim(),
        p_stage: stage,
        p_difficulty: difficulty,
        p_estimated_hours: estimatedHours,
        p_assigned_user_id: assignedUserId,
        p_modules: modulesJson,
      });

      if (rpcErr) throw rpcErr;

      setSuccess(`Custom course "${title.trim()}" created and assigned successfully.`);
      setTitle('');
      setDescription('');
      setShortDesc('');
      setStage('mechanical');
      setDifficulty('intermediate');
      setEstimatedHours(2);
      setAssignedUserId('');
      setModules([{ title: '', lessons: [{ title: '', content: '', estimated_minutes: 30 }] }]);
      await loadCustomCourses();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to create custom course');
    } finally {
      setSaving(false);
    }
  }

  async function handleDeleteCustomCourse(courseId: string, courseTitle: string) {
    if (!confirm(`Delete "${courseTitle}"? This will remove all modules and lessons in it. This cannot be undone.`)) return;
    setError(null);
    try {
      const { error: delErr } = await supabase.from('courses').delete().eq('id', courseId);
      if (delErr) throw delErr;
      setSuccess(`Custom course "${courseTitle}" deleted.`);
      await loadCustomCourses();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to delete course');
    }
  }

  return (
    <div className="space-y-8">
      {/* Existing custom courses */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <Layers className="w-5 h-5 text-accent-400" />
          <h2 className="text-lg font-semibold text-white">Existing Custom Courses</h2>
        </div>
        {loadingCourses ? (
          <div className="flex items-center gap-2 text-sm text-steel-400 py-4">
            <Loader2 className="w-4 h-4 animate-spin" /> Loading...
          </div>
        ) : customCourses.length === 0 ? (
          <div className="card p-6 text-center">
            <BookOpen className="w-8 h-8 text-steel-600 mx-auto mb-2" />
            <p className="text-sm text-steel-400">No custom courses yet. Use the form below to create one.</p>
          </div>
        ) : (
          <div className="space-y-2">
            {customCourses.map((c) => (
              <div key={c.id} className="card p-4 flex items-center justify-between">
                <div className="min-w-0">
                  <h3 className="text-sm font-medium text-white truncate">{c.title}</h3>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-xs px-2 py-0.5 rounded-full bg-accent-500/10 text-accent-300 border border-accent-500/20">
                      {STAGE_LABEL[c.stage]}
                    </span>
                    <span className="text-xs text-steel-400 flex items-center gap-1">
                      <Users className="w-3 h-3" />
                      {c.assigned_email ?? 'Unassigned'}
                    </span>
                    <span className="text-xs text-steel-600">
                      {new Date(c.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                    </span>
                  </div>
                </div>
                <button
                  onClick={() => handleDeleteCustomCourse(c.id, c.title)}
                  className="p-2 rounded-lg text-steel-400 hover:text-error-400 hover:bg-error-500/10 transition-colors shrink-0"
                  title="Delete custom course"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* Create new custom course */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <Plus className="w-5 h-5 text-premium-400" />
          <h2 className="text-lg font-semibold text-white">Create New Custom Course</h2>
        </div>

        <div className="card p-6 space-y-5">
          {/* Course metadata */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Course Title</label>
              <input
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. Plant-Specific Pump Maintenance for Acme Corp"
                className="input"
              />
            </div>
            <div className="md:col-span-2">
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Short Description (shown on cards)</label>
              <input
                value={shortDesc}
                onChange={(e) => setShortDesc(e.target.value)}
                placeholder="Brief one-line summary"
                className="input"
              />
            </div>
            <div className="md:col-span-2">
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Full Description</label>
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Detailed course description..."
                rows={3}
                className="input resize-none"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Stage</label>
              <select
                value={stage}
                onChange={(e) => setStage(e.target.value as Stage)}
                className="input"
              >
                <option value="mechanical">Mechanical</option>
                <option value="electrical">Electrical</option>
                <option value="ie">I&E</option>
                <option value="engineering">Engineering</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Difficulty</label>
              <select
                value={difficulty}
                onChange={(e) => setDifficulty(e.target.value as Difficulty)}
                className="input"
              >
                <option value="beginner">Beginner</option>
                <option value="intermediate">Intermediate</option>
                <option value="advanced">Advanced</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Estimated Hours</label>
              <input
                type="number"
                min={0.5}
                step={0.5}
                value={estimatedHours}
                onChange={(e) => setEstimatedHours(parseFloat(e.target.value) || 2)}
                className="input"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-400 mb-1.5">Assign to User</label>
              <select
                value={assignedUserId}
                onChange={(e) => setAssignedUserId(e.target.value)}
                className="input"
              >
                <option value="">Select a user...</option>
                {profiles.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.email}{p.is_premium ? ' (Premium)' : ''}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Modules builder */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <label className="text-xs font-medium text-steel-400">Modules &amp; Lessons</label>
              <button
                onClick={addModule}
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-accent-500/10 border border-accent-500/30 text-accent-300 hover:bg-accent-500/20 transition-colors text-xs font-medium"
              >
                <Plus className="w-3.5 h-3.5" />
                Add Module
              </button>
            </div>

            <div className="space-y-2">
              {modules.map((mod, modIdx) => (
                <div key={modIdx} className="rounded-lg border border-steel-700/60 bg-navy-950/40 overflow-hidden">
                  <div className="flex items-center gap-2 p-3">
                    <button
                      onClick={() => toggleModule(modIdx)}
                      className="text-steel-400 hover:text-white transition-colors"
                    >
                      {expandedModules.has(modIdx) ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                    </button>
                    <GripVertical className="w-4 h-4 text-steel-600" />
                    <input
                      value={mod.title}
                      onChange={(e) => updateModuleTitle(modIdx, e.target.value)}
                      placeholder={`Module ${modIdx + 1} title...`}
                      className="flex-1 bg-transparent text-sm text-white placeholder-steel-500 focus:outline-none border-b border-transparent focus:border-accent-500/50 transition-colors"
                    />
                    <span className="text-xs text-steel-600 shrink-0">{mod.lessons.length} lessons</span>
                    <button
                      onClick={() => removeModule(modIdx)}
                      className="p-1.5 rounded-lg text-steel-500 hover:text-error-400 hover:bg-error-500/10 transition-colors shrink-0"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>

                  {expandedModules.has(modIdx) && (
                    <div className="px-3 pb-3 space-y-2">
                      {mod.lessons.map((lesson, lessonIdx) => (
                        <div key={lessonIdx} className="rounded-lg border border-steel-800/50 bg-navy-900/40 p-3 space-y-2">
                          <div className="flex items-center gap-2">
                            <input
                              value={lesson.title}
                              onChange={(e) => updateLesson(modIdx, lessonIdx, 'title', e.target.value)}
                              placeholder={`Lesson ${lessonIdx + 1} title...`}
                              className="flex-1 bg-navy-950/60 text-sm text-white placeholder-steel-500 rounded-lg border border-steel-700/50 px-3 py-2 focus:outline-none focus:border-accent-500/50 transition-colors"
                            />
                            <input
                              type="number"
                              min={5}
                              step={5}
                              value={lesson.estimated_minutes}
                              onChange={(e) => updateLesson(modIdx, lessonIdx, 'estimated_minutes', parseInt(e.target.value) || 30)}
                              className="w-20 bg-navy-950/60 text-sm text-white rounded-lg border border-steel-700/50 px-2 py-2 focus:outline-none focus:border-accent-500/50 transition-colors text-center"
                              title="Estimated minutes"
                            />
                            <span className="text-xs text-steel-600">min</span>
                            <button
                              onClick={() => removeLesson(modIdx, lessonIdx)}
                              className="p-1.5 rounded-lg text-steel-500 hover:text-error-400 hover:bg-error-500/10 transition-colors shrink-0"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </div>
                          <textarea
                            value={lesson.content}
                            onChange={(e) => updateLesson(modIdx, lessonIdx, 'content', e.target.value)}
                            placeholder="Lesson content (supports plain text)..."
                            rows={3}
                            className="w-full bg-navy-950/60 text-sm text-steel-200 placeholder-steel-500 rounded-lg border border-steel-700/50 px-3 py-2 focus:outline-none focus:border-accent-500/50 transition-colors resize-none"
                          />
                        </div>
                      ))}
                      <button
                        onClick={() => addLesson(modIdx)}
                        className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-accent-300 hover:border-accent-500/40 transition-colors text-xs font-medium"
                      >
                        <Plus className="w-3.5 h-3.5" />
                        Add Lesson
                      </button>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* Error / Success */}
          {error && (
            <div className="flex items-start gap-3 p-3 rounded-lg bg-error-950/50 border border-error-700/50">
              <X className="w-4 h-4 text-error-400 flex-shrink-0 mt-0.5 cursor-pointer" onClick={() => setError(null)} />
              <p className="text-sm text-error-200">{error}</p>
            </div>
          )}
          {success && (
            <div className="flex items-start gap-3 p-3 rounded-lg bg-success-950/50 border border-success-700/50">
              <CheckCircle2 className="w-4 h-4 text-success-400 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-success-200">{success}</p>
            </div>
          )}

          {/* Submit */}
          <div className="flex items-center justify-end gap-3 pt-2">
            <button
              onClick={handleCreate}
              disabled={saving}
              className="btn-premium"
            >
              {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
              {saving ? 'Creating...' : 'Create Custom Course'}
            </button>
          </div>
        </div>
      </section>
    </div>
  );
}
