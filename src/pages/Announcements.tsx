import { useCallback, useEffect, useState } from 'react';
import {
  Megaphone,
  Loader2,
  AlertCircle,
  CheckCircle2,
  Send,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/lib/auth';
import type { Route } from '@/components/Nav';

interface Announcement {
  id: string;
  title: string | null;
  body: string;
  author_id: string;
  author_name: string;
  created_at: string;
  updated_at: string;
}

interface AnnouncementsProps {
  onNavigate: (r: Route) => void;
}

function formatTs(iso: string) {
  try {
    return new Date(iso).toLocaleString('en-US', {
      timeZone: 'America/Chicago',
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
    });
  } catch {
    return iso;
  }
}

export function Announcements({ onNavigate: _onNavigate }: AnnouncementsProps) {
  const { user, isAdmin, fullName } = useAuth();
  const [items, setItems] = useState<Announcement[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [posted, setPosted] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const { data, error: qErr } = await supabase
        .from('announcements')
        .select('id, title, body, author_id, author_name, created_at, updated_at')
        .order('created_at', { ascending: false });
      if (qErr) throw qErr;
      setItems((data as Announcement[]) ?? []);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load announcements');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  async function handlePost(e: React.FormEvent) {
    e.preventDefault();
    if (!isAdmin || !user || !body.trim()) return;
    setSubmitting(true);
    setError(null);
    setPosted(false);
    try {
      const { error: insertErr } = await supabase.from('announcements').insert({
        title: title.trim() || null,
        body: body.trim(),
        author_id: user.id,
        author_name: (fullName && fullName.trim()) || 'Admin',
      });
      if (insertErr) throw insertErr;
      setTitle('');
      setBody('');
      setPosted(true);
      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to post announcement');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="pt-16 min-h-screen">
      <div className="border-b border-steel-700/60 bg-navy-950/40 relative overflow-hidden">
        <div className="absolute inset-0 bg-grid-steel bg-grid-32 opacity-15" />
        <div className="absolute -right-20 -top-20 w-72 h-72 rounded-full bg-accent-500/10 blur-3xl" />
        <div className="relative max-w-3xl mx-auto px-4 sm:px-6 py-12 text-center">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-accent-500/15 border border-accent-500/40 text-accent-300 text-xs font-semibold uppercase tracking-wider mb-4">
            <Megaphone className="w-3.5 h-3.5" />
            Message Board
          </div>
          <h1 className="font-display text-3xl sm:text-4xl font-bold text-white mb-3">
            Announcements
          </h1>
          <p className="text-steel-400 max-w-xl mx-auto">
            Updates from ForgeLine Academy. Anyone can read — admins post here.
          </p>
        </div>
      </div>

      <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8 space-y-8">
        {isAdmin && (
          <section className="card p-6 border-accent-500/20">
            <h2 className="text-lg font-semibold text-white mb-4">Post an announcement</h2>
            <form onSubmit={handlePost} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                  Title <span className="text-steel-500 normal-case font-normal">(optional)</span>
                </label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="input"
                  placeholder="Short headline"
                  maxLength={200}
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                  Body
                </label>
                <textarea
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  rows={5}
                  className="input resize-none"
                  placeholder="What should everyone know?"
                  required
                />
              </div>
              {error && (
                <div className="flex items-start gap-2 text-sm text-error-400">
                  <AlertCircle className="w-4 h-4 shrink-0 mt-0.5" />
                  <span>{error}</span>
                </div>
              )}
              {posted && !error && (
                <div className="flex items-center gap-2 text-sm text-emerald-400">
                  <CheckCircle2 className="w-4 h-4" />
                  Posted
                </div>
              )}
              <button
                type="submit"
                disabled={submitting || !body.trim()}
                className="btn-primary"
              >
                {submitting ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" /> Posting...
                  </>
                ) : (
                  <>
                    <Send className="w-4 h-4" /> Post announcement
                  </>
                )}
              </button>
            </form>
          </section>
        )}

        <section className="space-y-4">
          <h2 className="section-title">All announcements</h2>
          {loading ? (
            <div className="flex items-center justify-center py-16 text-steel-400 gap-2">
              <Loader2 className="w-5 h-5 animate-spin" />
              Loading...
            </div>
          ) : error && items.length === 0 ? (
            <div className="card p-8 text-center">
              <AlertCircle className="w-10 h-10 text-error-400 mx-auto mb-3" />
              <p className="text-steel-300">{error}</p>
            </div>
          ) : items.length === 0 ? (
            <div className="card p-8 text-center">
              <Megaphone className="w-10 h-10 text-steel-500 mx-auto mb-3" />
              <p className="text-steel-400">No announcements yet.</p>
            </div>
          ) : (
            items.map((a) => (
              <article key={a.id} className="card p-5 sm:p-6">
                {a.title ? (
                  <h3 className="text-lg font-semibold text-white mb-2">{a.title}</h3>
                ) : null}
                <p className="text-steel-200 whitespace-pre-wrap leading-relaxed">{a.body}</p>
                <div className="mt-4 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-steel-500">
                  <span className="font-medium text-steel-400">{a.author_name || 'Admin'}</span>
                  <span aria-hidden>·</span>
                  <time dateTime={a.created_at}>{formatTs(a.created_at)}</time>
                </div>
              </article>
            ))
          )}
        </section>
      </div>
    </div>
  );
}
