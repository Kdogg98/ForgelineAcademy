import { useCallback, useEffect, useMemo, useState } from 'react';
import { Sparkles, Loader2, RefreshCw, Save, Send, EyeOff, AlertCircle, CheckCircle2, X, Plus, Trash2 } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { fetchCourses } from '@/lib/data';
import type { Company, CompanyDraft, Course } from '@/lib/types';
import {
  brandFromDraft,
  draftFromCompany,
  emptyDraft,
  generateCompanyDraft,
  isHex,
  loadCompanyDraft,
  publishCompanyProfile,
  saveCompanyDraft,
  unpublishCompanyProfile,
} from '@/lib/companyBrand';
import { CompanyOverview } from '@/components/CompanyOverview';

interface CompanyOption {
  id: string;
  name: string;
}

const lines = (v: string[]) => v.join('\n');
const parseLines = (v: string) => v.split('\n').map((s) => s.trim()).filter(Boolean);

/** Master admin: AI-assisted company profile builder (draft -> edit -> save / publish). */
export function CompanyBuilder() {
  const [companies, setCompanies] = useState<CompanyOption[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [companyId, setCompanyId] = useState<string | null>(null);
  const [published, setPublished] = useState(false);
  const [nameInput, setNameInput] = useState('');
  const [domainHint, setDomainHint] = useState('');
  const [draft, setDraft] = useState<CompanyDraft | null>(null);
  const [warnings, setWarnings] = useState<string[]>([]);
  const [busy, setBusy] = useState<null | 'build' | 'save' | 'publish' | 'unpublish' | 'load'>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [addCourseId, setAddCourseId] = useState('');

  const loadCompanies = useCallback(async () => {
    const { data } = await supabase.rpc('get_all_companies_with_stats');
    setCompanies(((data as CompanyOption[]) ?? []).map((c) => ({ id: c.id, name: c.name })));
  }, []);

  useEffect(() => {
    void loadCompanies();
    void fetchCourses().then((cs) => setCourses(cs.filter((c) => !c.is_custom))).catch(() => setCourses([]));
  }, [loadCompanies]);

  useEffect(() => { if (success) { const t = setTimeout(() => setSuccess(null), 5000); return () => clearTimeout(t); } }, [success]);

  const courseById = useMemo(() => new Map(courses.map((c) => [c.id, c])), [courses]);

  function update<K extends keyof CompanyDraft>(key: K, value: CompanyDraft[K]) {
    setDraft((d) => (d ? { ...d, [key]: value } : d));
  }

  async function handleBuild() {
    const name = (draft?.name || nameInput).trim();
    if (!name) return;
    setBusy('build');
    setError(null);
    setWarnings([]);
    try {
      const res = await generateCompanyDraft(name, domainHint.trim() || draft?.domain || undefined);
      setDraft(res.draft);
      setNameInput(res.draft.name);
      setWarnings(res.warnings);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'AI build failed');
      // Still allow manual entry.
      setDraft((d) => d ?? emptyDraft(name));
    } finally {
      setBusy(null);
    }
  }

  async function handleLoadExisting(id: string) {
    if (!id) {
      setCompanyId(null);
      setPublished(false);
      setDraft(null);
      setNameInput('');
      return;
    }
    setBusy('load');
    setError(null);
    try {
      const { data: row, error: rowErr } = await supabase.from('companies').select('*').eq('id', id).maybeSingle();
      if (rowErr) throw rowErr;
      if (!row) throw new Error('Company not found');
      const company = row as Company;
      const saved = await loadCompanyDraft(id);
      const d = saved ?? draftFromCompany(company);
      setCompanyId(id);
      setPublished(Boolean(company.published));
      setDraft(d);
      setNameInput(d.name);
      setDomainHint(d.domain ?? '');
      setWarnings([]);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load company');
    } finally {
      setBusy(null);
    }
  }

  function validate(d: CompanyDraft): string | null {
    if (!d.name.trim()) return 'Company name is required.';
    const bc = d.brand_colors;
    if (!isHex(bc.primary) || !isHex(bc.secondary) || !isHex(bc.accent)) return 'Brand colors must be #RRGGBB.';
    return null;
  }

  async function handleSave(): Promise<string | null> {
    if (!draft) return null;
    const v = validate(draft);
    if (v) { setError(v); return null; }
    setBusy('save');
    setError(null);
    try {
      const id = await saveCompanyDraft(companyId, draft);
      setCompanyId(id);
      setSuccess('Draft saved. Not visible to company members until you publish.');
      await loadCompanies();
      return id;
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to save draft');
      return null;
    } finally {
      setBusy(null);
    }
  }

  async function handlePublish() {
    const id = await handleSave();
    if (!id) return;
    setBusy('publish');
    try {
      await publishCompanyProfile(id);
      setPublished(true);
      setSuccess('Published. Company members now see the branded /company dashboard.');
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to publish');
    } finally {
      setBusy(null);
    }
  }

  async function handleUnpublish() {
    if (!companyId) return;
    setBusy('unpublish');
    try {
      await unpublishCompanyProfile(companyId);
      setPublished(false);
      setSuccess('Unpublished. Branded page hidden from members (premium access unchanged).');
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to unpublish');
    } finally {
      setBusy(null);
    }
  }

  function addTrack() {
    const c = courseById.get(addCourseId);
    if (!c || !draft || draft.suggested_tracks.some((t) => t.course_id === c.id)) return;
    update('suggested_tracks', [...draft.suggested_tracks, { course_id: c.id, title: c.title, stage: c.stage, tier: c.tier, reason: '' }]);
    setAddCourseId('');
  }

  const label = 'block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5';

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-lg font-bold text-white">AI Company Builder</h2>
        <p className="text-sm text-steel-400">
          Type a company name and click Build. Review every field, then Save draft or Publish. Company seats are online memberships; premium is still granted from the Companies tab.
        </p>
      </div>

      {error && (
        <div className="flex items-start gap-3 p-4 rounded-lg bg-error-500/10 border border-error-500/30">
          <AlertCircle className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5" />
          <p className="text-sm text-error-300">{error}</p>
          <button onClick={() => setError(null)} className="ml-auto text-error-400 hover:text-error-300"><X className="w-4 h-4" /></button>
        </div>
      )}
      {success && (
        <div className="flex items-start gap-3 p-4 rounded-lg bg-success-500/10 border border-success-500/30">
          <CheckCircle2 className="w-5 h-5 text-success-400 flex-shrink-0 mt-0.5" />
          <p className="text-sm text-success-300">{success}</p>
        </div>
      )}

      <div className="card p-5 space-y-3">
        <div className="grid sm:grid-cols-3 gap-3">
          <div className="sm:col-span-1">
            <label className={label}>Edit existing</label>
            <select value={companyId ?? ''} onChange={(e) => void handleLoadExisting(e.target.value)} className="input" disabled={busy !== null}>
              <option value="">New company</option>
              {companies.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </div>
          <div>
            <label className={label}>Company name</label>
            <input
              value={nameInput}
              onChange={(e) => setNameInput(e.target.value)}
              onKeyDown={(e) => { if (e.key === 'Enter') void handleBuild(); }}
              placeholder="Acme Paper Mill"
              className="input"
            />
          </div>
          <div>
            <label className={label}>Website (optional)</label>
            <input value={domainHint} onChange={(e) => setDomainHint(e.target.value)} placeholder="acme.com" className="input" />
          </div>
        </div>
        <div className="flex flex-wrap gap-2">
          <button onClick={() => void handleBuild()} disabled={busy !== null || !(nameInput.trim() || draft?.name)} className="btn-primary text-sm">
            {busy === 'build' ? <Loader2 className="w-4 h-4 animate-spin" /> : draft ? <RefreshCw className="w-4 h-4" /> : <Sparkles className="w-4 h-4" />}
            {draft ? 'Regenerate' : 'Build'}
          </button>
          {!draft && (
            <button onClick={() => setDraft(emptyDraft(nameInput.trim()))} className="btn-ghost text-sm">Start blank</button>
          )}
        </div>
        {warnings.length > 0 && (
          <ul className="text-xs text-warning-400 list-disc pl-5">{warnings.map((w) => <li key={w}>{w}</li>)}</ul>
        )}
      </div>

      {draft && (
        <div className="grid lg:grid-cols-2 gap-5 items-start">
          <div className="card p-5 space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-semibold text-steel-300 uppercase tracking-wider">Edit draft</h3>
              <span className={`text-[10px] font-bold uppercase px-2 py-0.5 rounded-full ${published ? 'bg-success-500/15 text-success-400' : 'bg-warning-500/15 text-warning-400'}`}>
                {companyId ? (published ? 'Published' : 'Unpublished') : 'Not saved'}
              </span>
            </div>
            {draft.confidence && (
              <p className="text-xs text-steel-500">
                AI confidence: <span className="text-steel-300">{draft.confidence}</span>. Verify facts before publishing.
                {draft.notes ? ` ${draft.notes}` : ''}
              </p>
            )}
            <div>
              <label className={label}>Name</label>
              <input value={draft.name} onChange={(e) => update('name', e.target.value)} className="input" />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className={label}>Domain</label>
                <input value={draft.domain} onChange={(e) => update('domain', e.target.value.trim().toLowerCase())} className="input" />
              </div>
              <div>
                <label className={label}>Industry</label>
                <input value={draft.industry} onChange={(e) => update('industry', e.target.value)} className="input" />
              </div>
            </div>
            <div>
              <label className={label}>Logo URL</label>
              <input value={draft.logo_url} onChange={(e) => update('logo_url', e.target.value.trim())} placeholder="Blank = favicon from domain" className="input" />
            </div>
            <div>
              <label className={label}>Summary</label>
              <textarea value={draft.summary} onChange={(e) => update('summary', e.target.value)} rows={2} className="input" />
            </div>
            <div className="grid sm:grid-cols-3 gap-3">
              {(['locations', 'equipment', 'processes'] as const).map((k) => (
                <div key={k}>
                  <label className={label}>{k} (one per line)</label>
                  <textarea value={lines(draft[k])} onChange={(e) => update(k, parseLines(e.target.value))} rows={5} className="input text-sm" />
                </div>
              ))}
            </div>
            <div>
              <label className={label}>Brand colors</label>
              <div className="grid grid-cols-3 gap-3">
                {(['primary', 'secondary', 'accent'] as const).map((k) => (
                  <div key={k} className="flex items-center gap-2">
                    <input
                      type="color"
                      value={isHex(draft.brand_colors[k]) ? draft.brand_colors[k] : '#000000'}
                      onChange={(e) => update('brand_colors', { ...draft.brand_colors, [k]: e.target.value.toUpperCase() })}
                      className="w-9 h-9 rounded border border-steel-700 bg-transparent shrink-0"
                      aria-label={`${k} color`}
                    />
                    <input
                      value={draft.brand_colors[k]}
                      onChange={(e) => update('brand_colors', { ...draft.brand_colors, [k]: e.target.value.trim() })}
                      className={`input text-xs px-2 ${isHex(draft.brand_colors[k]) ? '' : 'border-error-500'}`}
                    />
                  </div>
                ))}
              </div>
            </div>
            <div>
              <label className={label}>Training tracks (existing courses only)</label>
              <div className="space-y-2">
                {draft.suggested_tracks.map((t, i) => (
                  <div key={t.course_id} className="p-2 rounded-lg border border-steel-700/50 bg-navy-950/40">
                    <div className="flex items-center gap-2">
                      <span className="flex-1 text-sm text-white truncate">{courseById.get(t.course_id)?.title ?? t.title}</span>
                      <button
                        onClick={() => update('suggested_tracks', draft.suggested_tracks.filter((_, j) => j !== i))}
                        className="p-1 text-steel-400 hover:text-error-400"
                        aria-label="Remove track"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                    <input
                      value={t.reason ?? ''}
                      onChange={(e) => update('suggested_tracks', draft.suggested_tracks.map((x, j) => (j === i ? { ...x, reason: e.target.value } : x)))}
                      placeholder="Why this course"
                      className="input text-xs mt-1.5 py-1.5"
                    />
                  </div>
                ))}
                <div className="flex gap-2">
                  <select value={addCourseId} onChange={(e) => setAddCourseId(e.target.value)} className="input text-sm flex-1">
                    <option value="">Add a course...</option>
                    {courses
                      .filter((c) => !draft.suggested_tracks.some((t) => t.course_id === c.id))
                      .map((c) => <option key={c.id} value={c.id}>{c.title}</option>)}
                  </select>
                  <button onClick={addTrack} disabled={!addCourseId} className="btn-secondary text-sm"><Plus className="w-4 h-4" /></button>
                </div>
              </div>
            </div>
            <div className="flex flex-wrap gap-2 pt-2 border-t border-steel-700/40">
              <button onClick={() => void handleSave()} disabled={busy !== null} className="btn-secondary text-sm">
                {busy === 'save' ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />} Save draft
              </button>
              <button onClick={() => void handlePublish()} disabled={busy !== null} className="btn-primary text-sm">
                {busy === 'publish' ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />} Publish
              </button>
              {companyId && published && (
                <button onClick={() => void handleUnpublish()} disabled={busy !== null} className="btn-ghost text-sm">
                  <EyeOff className="w-4 h-4" /> Unpublish
                </button>
              )}
            </div>
          </div>

          <div className="lg:sticky lg:top-20">
            <h3 className="text-sm font-semibold text-steel-300 uppercase tracking-wider mb-2">Preview</h3>
            <CompanyOverview
              brand={brandFromDraft(draft)}
              badge={published ? null : 'Draft preview'}
              data={{
                name: draft.name,
                logoUrl: draft.logo_url,
                domain: draft.domain,
                industry: draft.industry,
                summary: draft.summary,
                locations: draft.locations,
                equipment: draft.equipment,
                processes: draft.processes,
                tracks: draft.suggested_tracks.map((t) => ({ ...t, title: courseById.get(t.course_id)?.title ?? t.title })),
              }}
            />
          </div>
        </div>
      )}
    </div>
  );
}
