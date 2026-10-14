import { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';
import { supabase } from '@/lib/supabase';

/**
 * Master-admin only: edit companies.seat_limit (NULL = unlimited).
 * Direct UPDATE on companies is already admin-only (RLS), and the
 * companies_protect_seat_limit trigger pins the value for everyone else.
 * Degrades to a notice when migration 20261014120000 has not been applied.
 */
export function SeatLimitEditor({ companyId, onSaved }: { companyId: string; onSaved?: (msg: string) => void }) {
  const [loading, setLoading] = useState(true);
  const [missing, setMissing] = useState(false);
  const [unlimited, setUnlimited] = useState(true);
  const [value, setValue] = useState('5');
  const [saved, setSaved] = useState<number | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      const { data, error: err } = await supabase.from('companies').select('seat_limit').eq('id', companyId).maybeSingle();
      if (cancelled) return;
      if (err) {
        setMissing(true);
      } else {
        const lim = (data as { seat_limit: number | null } | null)?.seat_limit ?? null;
        setSaved(lim);
        setUnlimited(lim === null);
        if (lim !== null) setValue(String(lim));
      }
      setLoading(false);
    })();
    return () => { cancelled = true; };
  }, [companyId]);

  async function save() {
    setError(null);
    const next = unlimited ? null : Number.parseInt(value, 10);
    if (next !== null && (!Number.isFinite(next) || next < 0)) { setError('Enter a whole number, 0 or more.'); return; }
    setSaving(true);
    const { error: err } = await supabase.from('companies').update({ seat_limit: next }).eq('id', companyId);
    setSaving(false);
    if (err) { setError(err.message); return; }
    setSaved(next);
    onSaved?.(next === null ? 'Seat limit set to Unlimited.' : `Seat limit set to ${next}.`);
  }

  if (loading) return <Loader2 className="w-3.5 h-3.5 text-steel-500 animate-spin" />;
  if (missing) {
    return <p className="text-[11px] text-steel-500">Seat limit: apply migration 20261014120000 to enable.</p>;
  }
  const dirty = (unlimited ? null : Number.parseInt(value, 10)) !== saved;
  return (
    <div className="flex flex-wrap items-center gap-2 text-xs">
      <span className="text-steel-400 font-medium">Seat limit</span>
      <input
        type="number"
        min={0}
        step={1}
        value={unlimited ? '' : value}
        disabled={unlimited}
        onChange={(e) => setValue(e.target.value)}
        placeholder="—"
        aria-label="Seat limit"
        className="input !py-1 !px-2 w-20 text-xs disabled:opacity-50"
      />
      <label className="flex items-center gap-1.5 text-steel-300 cursor-pointer">
        <input type="checkbox" checked={unlimited} onChange={(e) => setUnlimited(e.target.checked)} />
        Unlimited
      </label>
      <button onClick={() => void save()} disabled={saving || !dirty} className="btn-secondary !py-1 !px-2.5 text-xs disabled:opacity-40">
        {saving ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : 'Save'}
      </button>
      {error && <span className="text-error-400">{error}</span>}
    </div>
  );
}
