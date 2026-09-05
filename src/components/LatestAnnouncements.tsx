import { useEffect, useState } from 'react';
import { Megaphone, ArrowRight, Loader2 } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import type { Route } from '@/components/Nav';

interface Preview {
  id: string;
  title: string | null;
  body: string;
  author_name: string;
  created_at: string;
}

interface LatestAnnouncementsProps {
  onNavigate: (r: Route) => void;
}

function formatShort(iso: string) {
  try {
    return new Date(iso).toLocaleDateString('en-US', {
      timeZone: 'America/Chicago',
      month: 'short',
      day: 'numeric',
    });
  } catch {
    return '';
  }
}

function previewBody(body: string, max = 120) {
  const clean = (body || '').replace(/\s+/g, ' ').trim();
  if (clean.length <= max) return clean;
  return `${clean.slice(0, max).trimEnd()}…`;
}

export function LatestAnnouncements({ onNavigate }: LatestAnnouncementsProps) {
  const [items, setItems] = useState<Preview[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const { data } = await supabase
          .from('announcements')
          .select('id, title, body, author_name, created_at')
          .order('created_at', { ascending: false })
          .limit(3);
        if (!cancelled) setItems((data as Preview[]) ?? []);
      } catch {
        if (!cancelled) setItems([]);
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  if (loading) {
    return (
      <div className="card p-5 flex items-center gap-2 text-steel-400 text-sm">
        <Loader2 className="w-4 h-4 animate-spin" />
        Loading announcements...
      </div>
    );
  }

  if (items.length === 0) return null;

  return (
    <section className="card p-5 sm:p-6 border-accent-500/20">
      <div className="flex items-center justify-between gap-3 mb-4">
        <div className="flex items-center gap-2">
          <div className="w-9 h-9 rounded-lg bg-accent-500/15 flex items-center justify-center shrink-0">
            <Megaphone className="w-4 h-4 text-accent-300" />
          </div>
          <h2 className="text-base sm:text-lg font-semibold text-white">Latest announcements</h2>
        </div>
        <button
          onClick={() => onNavigate({ name: 'announcements' })}
          className="text-sm text-accent-300 hover:text-accent-200 inline-flex items-center gap-1 shrink-0"
        >
          View all
          <ArrowRight className="w-3.5 h-3.5" />
        </button>
      </div>
      <ul className="space-y-3">
        {items.map((a) => (
          <li key={a.id} className="border-t border-steel-700/50 pt-3 first:border-0 first:pt-0">
            <button
              type="button"
              onClick={() => onNavigate({ name: 'announcements' })}
              className="w-full text-left group"
            >
              {a.title ? (
                <p className="text-sm font-medium text-white group-hover:text-accent-200 mb-0.5">
                  {a.title}
                </p>
              ) : null}
              <p className="text-sm text-steel-400 leading-snug">{previewBody(a.body)}</p>
              <p className="mt-1 text-[11px] text-steel-500">
                {a.author_name || 'Admin'} · {formatShort(a.created_at)}
              </p>
            </button>
          </li>
        ))}
      </ul>
    </section>
  );
}
