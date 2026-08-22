import { useCallback, useEffect, useState } from 'react';
import {
  CalendarPlus,
  Trash2,
  Loader2,
  CheckCircle2,
  X,
  Clock,
  Calendar,
  Video,
  Link2,
  Users,
  Check,
  XCircle,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';
import type { AvailabilitySlot, Booking } from '@/lib/types';

interface SlotWithBooking extends AvailabilitySlot {
  booking?: Booking | null;
}

export function BookingsManager() {
  const [slots, setSlots] = useState<SlotWithBooking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);

  // Bulk slot form
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [dayWindowStart, setDayWindowStart] = useState('09:00');
  const [dayWindowEnd, setDayWindowEnd] = useState('17:00');
  const [slotMinutes, setSlotMinutes] = useState('30');
  const [breakMinutes, setBreakMinutes] = useState('0');
  const [weekdays, setWeekdays] = useState<Record<number, boolean>>({ 0: true, 1: true, 2: true, 3: true, 4: true, 5: false, 6: false });
  const [adding, setAdding] = useState(false);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const { data, error: err } = await supabase
        .from('availability_slots')
        .select(`
          *,
          bookings (*)
        `)
        .order('start_time', { ascending: true });

      if (err) throw err;

      const mapped = (data ?? []).map((row) => {
        const r = row as unknown as AvailabilitySlot & { bookings: Booking[] | null };
        return {
          ...r,
          booking: r.bookings && r.bookings.length > 0 ? r.bookings[0] : null,
        };
      });
      setSlots(mapped);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load bookings');
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

  async function handleAddSlots(e: React.FormEvent) {
    e.preventDefault();
    if (!startDate || !endDate || !dayWindowStart || !dayWindowEnd) return;
    setAdding(true);
    setError(null);
    try {
      const dur = parseInt(slotMinutes, 10);
      const gap = parseInt(breakMinutes, 10);
      if (!dur || dur < 5) throw new Error('Slot duration must be at least 5 minutes');

      const [wh, wm] = dayWindowStart.split(':').map(Number);
      const [eh, em] = dayWindowEnd.split(':').map(Number);
      if (eh * 60 + em <= wh * 60 + wm) throw new Error('Daily window end must be after start');

      const start = new Date(`${startDate}T00:00:00`);
      const end = new Date(`${endDate}T23:59:59`);
      if (end < start) throw new Error('End date must be after start date');

      const rows: { start_time: string; end_time: string; is_booked: boolean }[] = [];
      const cursor = new Date(start);
      while (cursor <= end) {
        const dow = cursor.getDay();
        if (weekdays[dow]) {
          const slotStart = new Date(cursor);
          slotStart.setHours(wh, wm, 0, 0);
          const windowEnd = new Date(cursor);
          windowEnd.setHours(eh, em, 0, 0);
          while (slotStart.getTime() + dur * 60000 <= windowEnd.getTime()) {
            const slotEnd = new Date(slotStart.getTime() + dur * 60000);
            rows.push({
              start_time: slotStart.toISOString(),
              end_time: slotEnd.toISOString(),
              is_booked: false,
            });
            slotStart.setTime(slotEnd.getTime() + gap * 60000);
          }
        }
        cursor.setDate(cursor.getDate() + 1);
      }

      if (rows.length === 0) throw new Error('No slots generated. Check your date range and selected days.');

      const { error: err } = await supabase.from('availability_slots').insert(rows);
      if (err) throw err;

      setSuccess(`${rows.length} time slot${rows.length === 1 ? '' : 's'} added.`);
      setShowAddForm(false);
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to add slots');
    } finally {
      setAdding(false);
    }
  }

  async function handleDeleteSlot(slotId: string) {
    setError(null);
    try {
      const { error: err } = await supabase.from('availability_slots').delete().eq('id', slotId);
      if (err) throw err;
      setSuccess('Slot removed.');
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to delete slot');
    }
  }

  async function handleUpdateMeetLink(bookingId: string, link: string) {
    setError(null);
    try {
      const { error: err } = await supabase
        .from('bookings')
        .update({ meet_link: link.trim() || null })
        .eq('id', bookingId);
      if (err) throw err;
      setSuccess('Google Meet link saved.');
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to save link');
    }
  }

  async function handleConfirmBooking(bookingId: string) {
    setError(null);
    try {
      const { error: err } = await supabase
        .from('bookings')
        .update({ status: 'confirmed' })
        .eq('id', bookingId);
      if (err) throw err;
      setSuccess('Booking confirmed.');
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to confirm booking');
    }
  }

  async function handleCancelBooking(bookingId: string, slotId: string) {
    setError(null);
    try {
      const { error: err } = await supabase
        .from('bookings')
        .update({ status: 'cancelled' })
        .eq('id', bookingId);
      if (err) throw err;

      const { error: slotErr } = await supabase
        .from('availability_slots')
        .update({ is_booked: false })
        .eq('id', slotId);
      if (slotErr) throw slotErr;

      setSuccess('Booking cancelled and slot reopened.');
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to cancel booking');
    }
  }

  function formatDate(iso: string): string {
    return new Date(iso).toLocaleDateString('en-US', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  }

  function formatTime(iso: string): string {
    return new Date(iso).toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
    });
  }

  const upcomingSlots = slots.filter((s) => new Date(s.start_time) >= new Date());
  const pastSlots = slots.filter((s) => new Date(s.start_time) < new Date());
  const pendingCount = slots.filter((s) => s.booking?.status === 'pending').length;

  return (
    <div className="space-y-6">
      {error && (
        <div className="flex items-start gap-3 p-4 rounded-lg bg-error-950/50 border border-error-700/50">
          <X className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5 cursor-pointer" onClick={() => setError(null)} />
          <p className="text-sm text-error-200">{error}</p>
        </div>
      )}
      {success && (
        <div className="flex items-start gap-3 p-4 rounded-lg bg-success-950/50 border border-success-700/50">
          <CheckCircle2 className="w-5 h-5 text-success-400 flex-shrink-0 mt-0.5" />
          <p className="text-sm text-success-200">{success}</p>
        </div>
      )}

      {/* Stats + Add button */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex flex-wrap gap-3">
          <div className="card px-4 py-3 flex items-center gap-3">
            <Calendar className="w-5 h-5 text-accent-400" />
            <div>
              <p className="text-xs text-steel-400">Upcoming slots</p>
              <p className="text-lg font-bold text-white">{upcomingSlots.length}</p>
            </div>
          </div>
          <div className="card px-4 py-3 flex items-center gap-3">
            <Users className="w-5 h-5 text-rok-400" />
            <div>
              <p className="text-xs text-steel-400">Pending requests</p>
              <p className="text-lg font-bold text-white">{pendingCount}</p>
            </div>
          </div>
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="btn-primary"
        >
          <CalendarPlus className="w-4 h-4" />
          {showAddForm ? 'Cancel' : 'Add Time Slot'}
        </button>
      </div>

      {/* Add slots form */}
      {showAddForm && (
        <form onSubmit={handleAddSlots} className="card p-5">
          <h3 className="text-sm font-semibold text-white mb-1">Create availability in bulk</h3>
          <p className="text-xs text-steel-400 mb-4">Generate multiple time slots across a date range at once.</p>

          <div className="grid gap-4 sm:grid-cols-2 mb-4">
            <div>
              <label className="block text-xs font-medium text-steel-300 mb-1.5">From date</label>
              <input type="date" required value={startDate} onChange={(e) => setStartDate(e.target.value)} className="input" />
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-300 mb-1.5">To date</label>
              <input type="date" required value={endDate} onChange={(e) => setEndDate(e.target.value)} className="input" />
            </div>
          </div>

          <div className="mb-4">
            <label className="block text-xs font-medium text-steel-300 mb-1.5">Days of the week</label>
            <div className="flex flex-wrap gap-2">
              {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d, i) => (
                <button
                  key={d}
                  type="button"
                  onClick={() => setWeekdays((prev) => ({ ...prev, [i]: !prev[i] }))}
                  className={`px-3 py-1.5 rounded-lg text-xs font-medium border transition-colors ${
                    weekdays[i]
                      ? 'bg-accent-500/20 border-accent-500/50 text-accent-200'
                      : 'bg-navy-800/60 border-steel-700/60 text-steel-500 hover:text-steel-300'
                  }`}
                >
                  {d}
                </button>
              ))}
            </div>
          </div>

          <div className="grid gap-4 sm:grid-cols-2 mb-4">
            <div>
              <label className="block text-xs font-medium text-steel-300 mb-1.5">Daily window start</label>
              <input type="time" required value={dayWindowStart} onChange={(e) => setDayWindowStart(e.target.value)} className="input" />
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-300 mb-1.5">Daily window end</label>
              <input type="time" required value={dayWindowEnd} onChange={(e) => setDayWindowEnd(e.target.value)} className="input" />
            </div>
          </div>

          <div className="grid gap-4 sm:grid-cols-2 mb-4">
            <div>
              <label className="block text-xs font-medium text-steel-300 mb-1.5">Slot duration (minutes)</label>
              <input type="number" min="5" step="5" required value={slotMinutes} onChange={(e) => setSlotMinutes(e.target.value)} className="input" />
            </div>
            <div>
              <label className="block text-xs font-medium text-steel-300 mb-1.5">Break between slots (minutes)</label>
              <input type="number" min="0" step="5" value={breakMinutes} onChange={(e) => setBreakMinutes(e.target.value)} className="input" />
            </div>
          </div>

          <button type="submit" disabled={adding} className="btn-primary">
            {adding ? <Loader2 className="w-4 h-4 animate-spin" /> : <CalendarPlus className="w-4 h-4" />}
            {adding ? 'Creating...' : 'Generate Slots'}
          </button>
        </form>
      )}

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <Loader2 className="w-8 h-8 text-accent-500 animate-spin" />
        </div>
      ) : upcomingSlots.length === 0 ? (
        <div className="card p-12 text-center">
          <Calendar className="w-12 h-12 text-steel-600 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-white mb-2">No upcoming slots</h3>
          <p className="text-steel-400">Click "Add Time Slot" to create availability for users to book.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {upcomingSlots.map((slot) => (
            <SlotRow
              key={slot.id}
              slot={slot}
              formatDate={formatDate}
              formatTime={formatTime}
              onDelete={() => handleDeleteSlot(slot.id)}
              onUpdateMeetLink={(link) => slot.booking && handleUpdateMeetLink(slot.booking.id, link)}
              onConfirm={() => slot.booking && handleConfirmBooking(slot.booking.id)}
              onCancel={() => slot.booking && handleCancelBooking(slot.booking.id, slot.id)}
            />
          ))}
        </div>
      )}

      {pastSlots.length > 0 && (
        <div>
          <h3 className="text-sm font-semibold text-steel-400 mb-3">Past Slots</h3>
          <div className="space-y-2">
            {pastSlots.slice(-5).map((slot) => (
              <div key={slot.id} className="card p-3 flex items-center gap-3 opacity-60">
                <Clock className="w-4 h-4 text-steel-500" />
                <span className="text-sm text-steel-300">{formatDate(slot.start_time)} · {formatTime(slot.start_time)}</span>
                {slot.booking && (
                  <span className="text-xs text-steel-500">— {slot.booking.name}</span>
                )}
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

function SlotRow({
  slot,
  formatDate,
  formatTime,
  onDelete,
  onUpdateMeetLink,
  onConfirm,
  onCancel,
}: {
  slot: SlotWithBooking;
  formatDate: (iso: string) => string;
  formatTime: (iso: string) => string;
  onDelete: () => void;
  onUpdateMeetLink: (link: string) => void;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  const [showLinkInput, setShowLinkInput] = useState(false);
  const [linkValue, setLinkValue] = useState(slot.booking?.meet_link ?? '');

  function handleLinkSubmit() {
    onUpdateMeetLink(linkValue);
    setShowLinkInput(false);
  }

  const booking = slot.booking;
  const isPending = booking?.status === 'pending';
  const isConfirmed = booking?.status === 'confirmed';
  const isCancelled = booking?.status === 'cancelled';

  return (
    <div className={`card p-4 ${isPending ? 'border-rok-500/40' : ''}`}>
      <div className="flex items-start justify-between gap-4">
        {/* Time info */}
        <div className="flex items-start gap-3 flex-1 min-w-0">
          <div className={`w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0 ${
            booking ? 'bg-rok-500/15' : 'bg-navy-700/60'
          }`}>
            <Calendar className={`w-5 h-5 ${booking ? 'text-rok-400' : 'text-steel-400'}`} />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold text-white">{formatDate(slot.start_time)}</p>
            <p className="text-xs text-steel-400 flex items-center gap-1.5">
              <Clock className="w-3 h-3" />
              {formatTime(slot.start_time)} – {formatTime(slot.end_time)}
            </p>
          </div>
        </div>

        {/* Status badge */}
        <div className="flex-shrink-0">
          {booking ? (
            <span className={`badge ${
              isPending ? 'bg-rok-500/15 text-rok-400 border border-rok-500/30' :
              isConfirmed ? 'bg-success-500/15 text-success-400 border border-success-500/30' :
              'bg-error-500/15 text-error-400 border border-error-500/30'
            }`}>
              {isPending ? 'Pending' : isConfirmed ? 'Confirmed' : 'Cancelled'}
            </span>
          ) : (
            <span className="badge bg-navy-700/50 text-steel-400 border border-steel-600/50">
              Available
            </span>
          )}
        </div>
      </div>

      {/* Booking details */}
      {booking && (
        <div className="mt-3 pt-3 border-t border-steel-700/40 space-y-2.5">
          <div className="grid gap-2 sm:grid-cols-2">
            <div>
              <p className="text-[10px] uppercase tracking-wide text-steel-500 mb-0.5">Name</p>
              <p className="text-sm text-steel-200">{booking.name}</p>
            </div>
            <div>
              <p className="text-[10px] uppercase tracking-wide text-steel-500 mb-0.5">Email</p>
              <p className="text-sm text-steel-200 truncate">{booking.email}</p>
            </div>
          </div>
          <div>
            <p className="text-[10px] uppercase tracking-wide text-steel-500 mb-0.5">Topic</p>
            <p className="text-sm text-steel-200">{booking.topic}</p>
          </div>

          {/* Meet link */}
          {booking.meet_link && !showLinkInput && (
            <div className="flex items-center gap-2">
              <Video className="w-4 h-4 text-accent-400 flex-shrink-0" />
              <a
                href={booking.meet_link}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-accent-300 hover:text-accent-200 underline truncate"
              >
                {booking.meet_link}
              </a>
            </div>
          )}

          {showLinkInput ? (
            <div className="flex items-center gap-2">
              <input
                type="url"
                value={linkValue}
                onChange={(e) => setLinkValue(e.target.value)}
                placeholder="https://meet.google.com/xxx-xxxx-xxx"
                className="flex-1 px-3 py-1.5 text-sm bg-navy-950/60 border border-steel-700 rounded-lg text-steel-100 placeholder-steel-500 focus:outline-none focus:border-accent-500 transition-colors"
                autoFocus
              />
              <button onClick={handleLinkSubmit} className="px-3 py-1.5 rounded-lg bg-accent-500/20 border border-accent-500/40 text-accent-300 hover:bg-accent-500/30 transition-colors text-xs font-medium">
                Save
              </button>
              <button onClick={() => { setShowLinkInput(false); setLinkValue(booking.meet_link ?? ''); }} className="px-3 py-1.5 rounded-lg bg-navy-800/60 border border-steel-700/40 text-steel-400 hover:text-steel-200 transition-colors text-xs">
                Cancel
              </button>
            </div>
          ) : (
            <button
              onClick={() => setShowLinkInput(true)}
              className="flex items-center gap-1.5 text-xs text-accent-300 hover:text-accent-200 transition-colors"
            >
              <Link2 className="w-3.5 h-3.5" />
              {booking.meet_link ? 'Edit Google Meet link' : 'Add Google Meet link'}
            </button>
          )}

          {/* Actions */}
          <div className="flex flex-wrap gap-2 pt-1">
            {isPending && (
              <button onClick={onConfirm} className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-success-500/15 border border-success-500/30 text-success-400 hover:bg-success-500/25 transition-colors text-xs font-medium">
                <Check className="w-3.5 h-3.5" /> Confirm
              </button>
            )}
            {!isCancelled && (
              <button onClick={onCancel} className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-error-500/10 border border-error-500/30 text-error-400 hover:bg-error-500/20 transition-colors text-xs font-medium">
                <XCircle className="w-3.5 h-3.5" /> Cancel
              </button>
            )}
          </div>
        </div>
      )}

      {/* Delete slot (only if not booked) */}
      {!booking && (
        <div className="mt-3 pt-3 border-t border-steel-700/40">
          <button
            onClick={onDelete}
            className="flex items-center gap-1.5 text-xs text-steel-500 hover:text-error-400 transition-colors"
          >
            <Trash2 className="w-3.5 h-3.5" /> Remove slot
          </button>
        </div>
      )}
    </div>
  );
}
