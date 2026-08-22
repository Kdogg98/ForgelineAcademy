import { useCallback, useEffect, useState } from 'react';
import {
  Loader2,
  Mail,
  Phone,
  Building2,
  AlertCircle,
  Clock,
  X,
  CheckCircle2,
  ChevronRight,
  StickyNote,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';

interface ServiceRequest {
  id: string;
  name: string;
  company: string | null;
  email: string;
  phone: string | null;
  service_type: 'onsite_training' | 'troubleshooting' | 'both';
  message: string | null;
  status: 'new' | 'contacted' | 'quoted' | 'booked' | 'closed';
  admin_notes: string | null;
  created_at: string;
  updated_at: string;
}

const SERVICE_LABELS: Record<string, string> = {
  onsite_training: 'On-Site Training',
  troubleshooting: 'Troubleshooting',
  both: 'Both',
};

const STATUS_OPTIONS: { value: ServiceRequest['status']; label: string }[] = [
  { value: 'new', label: 'New' },
  { value: 'contacted', label: 'Contacted' },
  { value: 'quoted', label: 'Quoted' },
  { value: 'booked', label: 'Booked' },
  { value: 'closed', label: 'Closed' },
];

const STATUS_COLORS: Record<string, string> = {
  new: 'bg-warning-500/15 text-warning-400 border-warning-500/30',
  contacted: 'bg-accent-500/15 text-accent-400 border-accent-500/30',
  quoted: 'bg-rok-500/15 text-rok-400 border-rok-500/30',
  booked: 'bg-premium-500/15 text-premium-400 border-premium-500/30',
  closed: 'bg-success-500/15 text-success-400 border-success-500/30',
};

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

export function ServiceRequestsManager() {
  const [requests, setRequests] = useState<ServiceRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<'all' | ServiceRequest['status']>('all');
  const [selected, setSelected] = useState<ServiceRequest | null>(null);
  const [notesInput, setNotesInput] = useState('');
  const [updating, setUpdating] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const { data, error: queryErr } = await supabase
        .from('service_requests')
        .select('*')
        .order('created_at', { ascending: false });
      if (queryErr) throw queryErr;
      setRequests((data as ServiceRequest[]) ?? []);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load requests');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { void load(); }, [load]);

  function openDetail(req: ServiceRequest) {
    setSelected(req);
    setNotesInput(req.admin_notes ?? '');
  }

  async function saveStatusAndNotes(reqId: string, newStatus: ServiceRequest['status'], notes: string) {
    setUpdating(true);
    setError(null);
    try {
      const { error: updateErr } = await supabase
        .from('service_requests')
        .update({ status: newStatus, admin_notes: notes.trim() || null })
        .eq('id', reqId);
      if (updateErr) throw updateErr;
      await load();
      setSelected(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to update');
    } finally {
      setUpdating(false);
    }
  }

  async function quickStatus(reqId: string, newStatus: ServiceRequest['status']) {
    setError(null);
    try {
      const { error: updateErr } = await supabase
        .from('service_requests')
        .update({ status: newStatus })
        .eq('id', reqId);
      if (updateErr) throw updateErr;
      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to update');
    }
  }

  const filtered = filter === 'all' ? requests : requests.filter((r) => r.status === filter);
  const counts: Record<string, number> = { all: requests.length };
  for (const s of STATUS_OPTIONS) {
    counts[s.value] = requests.filter((r) => r.status === s.value).length;
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-10">
        <Loader2 className="w-6 h-6 text-rok-400 animate-spin" />
      </div>
    );
  }

  if (error && !selected) {
    return (
      <div className="flex items-start gap-3 p-4 rounded-lg bg-error-500/10 border border-error-500/30">
        <AlertCircle className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5" />
        <p className="text-sm text-error-300">{error}</p>
      </div>
    );
  }

  if (requests.length === 0) {
    return (
      <div className="text-center py-10">
        <Mail className="w-10 h-10 text-steel-600 mx-auto mb-3" />
        <p className="text-sm text-steel-500">No service requests yet.</p>
      </div>
    );
  }

  // Detail view
  if (selected) {
    return (
      <div className="space-y-4">
        <button
          onClick={() => setSelected(null)}
          className="flex items-center gap-1.5 text-sm text-steel-400 hover:text-white transition-colors"
        >
          <X className="w-4 h-4" /> Back to list
        </button>

        {error && (
          <div className="flex items-start gap-3 p-4 rounded-lg bg-error-500/10 border border-error-500/30">
            <AlertCircle className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5" />
            <p className="text-sm text-error-300">{error}</p>
          </div>
        )}

        <div className="card p-6">
          <div className="flex items-start justify-between gap-4 mb-5">
            <div>
              <h3 className="font-display text-xl font-bold text-white mb-1">{selected.name}</h3>
              <div className="flex flex-wrap gap-x-4 gap-y-1 text-sm text-steel-500">
                <span className="flex items-center gap-1"><Mail className="w-3.5 h-3.5" />{selected.email}</span>
                {selected.phone && <span className="flex items-center gap-1"><Phone className="w-3.5 h-3.5" />{selected.phone}</span>}
                {selected.company && <span className="flex items-center gap-1"><Building2 className="w-3.5 h-3.5" />{selected.company}</span>}
                <span className="flex items-center gap-1"><Clock className="w-3.5 h-3.5" />{formatDate(selected.created_at)}</span>
              </div>
            </div>
            <span className={`text-xs px-2 py-1 rounded-full border font-semibold ${STATUS_COLORS[selected.status]}`}>
              {selected.status.charAt(0).toUpperCase() + selected.status.slice(1)}
            </span>
          </div>

          <div className="mb-5">
            <div className="text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">Service Type</div>
            <p className="text-sm text-steel-200">{SERVICE_LABELS[selected.service_type] ?? selected.service_type}</p>
          </div>

          {selected.message && (
            <div className="mb-5">
              <div className="text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">Message</div>
              <div className="rounded-lg border border-steel-700/40 bg-navy-950/30 p-4 text-sm text-steel-200 leading-relaxed whitespace-pre-line">
                {selected.message}
              </div>
            </div>
          )}

          <div className="mb-5">
            <label className="flex items-center gap-1.5 text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
              <StickyNote className="w-3.5 h-3.5" /> Internal Notes
            </label>
            <textarea
              value={notesInput}
              onChange={(e) => setNotesInput(e.target.value)}
              rows={3}
              className="input resize-none"
              placeholder="Add internal notes (not visible to requester)..."
            />
          </div>

          <div className="mb-5">
            <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">Update Status</label>
            <div className="flex flex-wrap gap-2">
              {STATUS_OPTIONS.map((opt) => (
                <button
                  key={opt.value}
                  onClick={() => setSelected({ ...selected, status: opt.value })}
                  className={`px-3 py-1.5 rounded-lg text-xs font-medium border transition-colors ${
                    selected.status === opt.value
                      ? 'border-rok-500 bg-rok-500/15 text-white'
                      : 'border-steel-700/40 bg-navy-950/30 text-steel-400 hover:text-steel-200'
                  }`}
                >
                  {opt.label}
                </button>
              ))}
            </div>
          </div>

          <button
            onClick={() => saveStatusAndNotes(selected.id, selected.status, notesInput)}
            disabled={updating}
            className="btn-primary text-sm"
          >
            {updating ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle2 className="w-4 h-4" />}
            Save Changes
          </button>
        </div>
      </div>
    );
  }

  // List view
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between mb-2">
        <h2 className="text-lg font-bold text-white">Service Requests</h2>
        <span className="text-xs text-steel-500">{requests.length} total</span>
      </div>

      {error && (
        <div className="flex items-start gap-3 p-4 rounded-lg bg-error-500/10 border border-error-500/30">
          <AlertCircle className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5" />
          <p className="text-sm text-error-300">{error}</p>
        </div>
      )}

      {/* Filter tabs */}
      <div className="flex flex-wrap gap-1.5">
        <button
          onClick={() => setFilter('all')}
          className={`px-3 py-1.5 rounded-lg text-xs font-medium border transition-colors ${
            filter === 'all' ? 'border-rok-500 bg-rok-500/15 text-white' : 'border-steel-700/40 bg-navy-950/30 text-steel-400 hover:text-steel-200'
          }`}
        >
          All ({counts.all})
        </button>
        {STATUS_OPTIONS.map((opt) => (
          <button
            key={opt.value}
            onClick={() => setFilter(opt.value)}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium border transition-colors ${
              filter === opt.value ? 'border-rok-500 bg-rok-500/15 text-white' : 'border-steel-700/40 bg-navy-950/30 text-steel-400 hover:text-steel-200'
            }`}
          >
            {opt.label} ({counts[opt.value] ?? 0})
          </button>
        ))}
      </div>

      {filtered.length === 0 ? (
        <p className="text-sm text-steel-500 text-center py-8">No requests with this status.</p>
      ) : (
        <div className="space-y-2">
          {filtered.map((req) => (
            <div
              key={req.id}
              className="rounded-xl border border-steel-700/60 bg-navy-800/40 p-4 hover:border-steel-600/60 transition-colors"
            >
              <div className="flex items-start justify-between gap-4">
                <button
                  onClick={() => openDetail(req)}
                  className="flex-1 min-w-0 text-left"
                >
                  <div className="flex items-center gap-2 mb-1 flex-wrap">
                    <span className="text-sm font-semibold text-white">{req.name}</span>
                    <span className={`text-[10px] px-1.5 py-0.5 rounded-full border font-semibold ${STATUS_COLORS[req.status]}`}>
                      {req.status.charAt(0).toUpperCase() + req.status.slice(1)}
                    </span>
                    <span className="text-[10px] px-1.5 py-0.5 rounded-full bg-navy-700/60 border border-steel-700/40 text-steel-400 font-semibold">
                      {SERVICE_LABELS[req.service_type] ?? req.service_type}
                    </span>
                  </div>
                  <div className="flex flex-wrap gap-x-4 gap-y-1 text-xs text-steel-500">
                    <span className="flex items-center gap-1"><Mail className="w-3 h-3" />{req.email}</span>
                    {req.phone && <span className="flex items-center gap-1"><Phone className="w-3 h-3" />{req.phone}</span>}
                    {req.company && <span className="flex items-center gap-1"><Building2 className="w-3 h-3" />{req.company}</span>}
                    <span className="flex items-center gap-1"><Clock className="w-3 h-3" />{formatDate(req.created_at)}</span>
                  </div>
                  {req.message && (
                    <p className="text-xs text-steel-500 mt-1.5 line-clamp-1">{req.message}</p>
                  )}
                  {req.admin_notes && (
                    <p className="text-xs text-accent-400/70 mt-1 flex items-center gap-1">
                      <StickyNote className="w-3 h-3" /> Has notes
                    </p>
                  )}
                </button>
                <div className="flex items-center gap-1.5 shrink-0">
                  <select
                    value={req.status}
                    onChange={(e) => quickStatus(req.id, e.target.value as ServiceRequest['status'])}
                    className="input text-xs py-1 px-2 w-28"
                  >
                    {STATUS_OPTIONS.map((opt) => (
                      <option key={opt.value} value={opt.value}>{opt.label}</option>
                    ))}
                  </select>
                  <button
                    onClick={() => openDetail(req)}
                    className="p-1.5 rounded-lg text-steel-400 hover:text-white hover:bg-navy-700/60 transition-colors"
                  >
                    <ChevronRight className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
