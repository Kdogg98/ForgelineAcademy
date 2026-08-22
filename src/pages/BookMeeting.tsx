import { useCallback, useEffect, useState } from 'react';
import { Calendar, Clock, Video, CheckCircle2, Loader2, X, ArrowRight, Mail } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { SITE_CONFIG } from '@/lib/siteConfig';
import { track } from '@/lib/analytics';
import type { AvailabilitySlot } from '@/lib/types';
import type { Route } from '@/components/Nav';

interface BookMeetingProps {
  onNavigate: (r: Route) => void;
}

export function BookMeeting({ onNavigate }: BookMeetingProps) {
  const [slots, setSlots] = useState<AvailabilitySlot[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedSlot, setSelectedSlot] = useState<AvailabilitySlot | null>(null);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [topic, setTopic] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [bookedSlot, setBookedSlot] = useState<AvailabilitySlot | null>(null);
  const [fallbackSent, setFallbackSent] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadSlots = useCallback(async () => {
    setLoading(true);
    try {
      const now = new Date().toISOString();
      const { data, error: err } = await supabase
        .from('availability_slots')
        .select('*')
        .gte('start_time', now)
        .order('start_time', { ascending: true });

      if (err) throw err;
      setSlots((data ?? []) as AvailabilitySlot[]);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load available times');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadSlots();
  }, [loadSlots]);

  async function handleBooking(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedSlot) return;
    setSubmitting(true);
    setError(null);
    try {
      const { error: bookErr } = await supabase.from('bookings').insert({
        slot_id: selectedSlot.id,
        name: name.trim(),
        email: email.trim(),
        topic: topic.trim(),
        status: 'pending',
      });

      if (bookErr) throw bookErr;

      const { error: slotErr } = await supabase
        .from('availability_slots')
        .update({ is_booked: true })
        .eq('id', selectedSlot.id);

      if (slotErr) throw slotErr;

      setBookedSlot(selectedSlot);
      setSelectedSlot(null);
      setName('');
      setEmail('');
      setTopic('');
      await loadSlots();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Booking failed. Please try again.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleFallbackSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !email.trim()) return;
    setSubmitting(true);
    setError(null);
    try {
      const { error: insertErr } = await supabase.from('service_requests').insert({
        name: name.trim(),
        email: email.trim(),
        service_type: 'onsite_training',
        message: topic.trim() || 'Requested a meeting; no calendar slots were available.',
      });
      if (insertErr) throw insertErr;
      track('plant_lead');
      setFallbackSent(true);
      supabase.functions.invoke('notify', {
        body: {
          type: 'service_request',
          name: name.trim(),
          email: email.trim(),
          service_type: 'onsite_training',
          message: topic.trim() || 'Requested a meeting; no calendar slots were available.',
        },
      }).catch(() => {});
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to send request. Use the email link below.');
    } finally {
      setSubmitting(false);
    }
  }

  function fallbackMailto(): string {
    const subject = encodeURIComponent('Meeting / on-site training request');
    const body = encodeURIComponent(
      `Name: ${name.trim() || '(add your name)'}\nEmail: ${email.trim() || '(add your email)'}\nTopic: ${topic.trim() || '(what you need)'}`,
    );
    return `mailto:${SITE_CONFIG.supportEmail}?subject=${subject}&body=${body}`;
  }

  function formatDate(iso: string): string {
    return new Date(iso).toLocaleDateString('en-US', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
    });
  }

  function formatTime(iso: string): string {
    return new Date(iso).toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
    });
  }

  function groupSlotsByDate(slots: AvailabilitySlot[]): Record<string, AvailabilitySlot[]> {
    const groups: Record<string, AvailabilitySlot[]> = {};
    for (const slot of slots) {
      const dateKey = formatDate(slot.start_time);
      if (!groups[dateKey]) groups[dateKey] = [];
      groups[dateKey].push(slot);
    }
    return groups;
  }

  if (bookedSlot) {
    return (
      <div className="pt-24 pb-16 min-h-screen">
        <div className="max-w-2xl mx-auto px-4 sm:px-6">
          <div className="card p-8 text-center">
            <div className="w-16 h-16 rounded-full bg-success-500/15 flex items-center justify-center mx-auto mb-5">
              <CheckCircle2 className="w-8 h-8 text-success-400" />
            </div>
            <h1 className="text-2xl font-bold text-white mb-3">Booking Request Sent!</h1>
            <p className="text-steel-300 mb-6">
              You requested a meeting on <span className="font-semibold text-white">{formatDate(bookedSlot.start_time)}</span> from{' '}
              <span className="font-semibold text-white">{formatTime(bookedSlot.start_time)}</span> to{' '}
              <span className="font-semibold text-white">{formatTime(bookedSlot.end_time)}</span>.
              You'll receive a confirmation email with a Google Meet link once it's approved.
            </p>
            <div className="flex gap-3 justify-center">
              <button onClick={() => setBookedSlot(null)} className="btn-secondary">
                Book Another
              </button>
              <button onClick={() => onNavigate({ name: 'home' })} className="btn-ghost">
                Back to Home
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  const grouped = groupSlotsByDate(slots.filter((s) => !s.is_booked));

  return (
    <div className="pt-24 pb-16 min-h-screen">
      <div className="max-w-5xl mx-auto px-4 sm:px-6">
        <div className="mb-8 text-center">
          <div className="w-14 h-14 rounded-xl bg-rok-500/15 flex items-center justify-center mx-auto mb-4">
            <Video className="w-7 h-7 text-rok-400" />
          </div>
          <h1 className="text-3xl font-bold text-white mb-2">Book a Meeting</h1>
          <p className="text-steel-400 max-w-xl mx-auto">
            Schedule a 1-on-1 video call via Google Meet. Pick an available time below and tell me what you'd like to discuss.
          </p>
        </div>

        {error && (
          <div className="mb-6 flex items-start gap-3 p-4 rounded-lg bg-error-950/50 border border-error-700/50">
            <X className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5 cursor-pointer" onClick={() => setError(null)} />
            <p className="text-sm text-error-200">{error}</p>
          </div>
        )}

        {loading ? (
          <div className="flex items-center justify-center py-20">
            <Loader2 className="w-8 h-8 text-rok-500 animate-spin" />
          </div>
        ) : Object.keys(grouped).length === 0 ? (
          <div className="card p-8 max-w-xl mx-auto">
            <Calendar className="w-12 h-12 text-steel-600 mx-auto mb-4" />
            <h2 className="text-lg font-semibold text-white mb-2 text-center">No times available right now</h2>
            <p className="text-steel-400 text-center mb-6">
              Leave your details and we will follow up on training, troubleshooting, or a meeting. Plants should never be left without a next step.
            </p>
            {fallbackSent ? (
              <div className="text-center py-4">
                <div className="w-14 h-14 rounded-full bg-success-500/15 flex items-center justify-center mx-auto mb-4">
                  <CheckCircle2 className="w-7 h-7 text-success-400" />
                </div>
                <h3 className="font-display text-xl font-bold text-white mb-2">Request received</h3>
                <p className="text-sm text-steel-400 mb-4">
                  We will follow up shortly. If you need to add anything, email is always open.
                </p>
                <a href={fallbackMailto()} className="btn-secondary inline-flex items-center gap-2">
                  <Mail className="w-4 h-4" /> Email {SITE_CONFIG.supportEmail}
                </a>
              </div>
            ) : (
              <form onSubmit={handleFallbackSubmit} className="space-y-4 text-left">
                <div>
                  <label className="block text-xs font-medium text-steel-300 mb-1.5">Full Name</label>
                  <input
                    type="text"
                    required
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="input"
                    placeholder="Your name"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-steel-300 mb-1.5">Email</label>
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="input"
                    placeholder="you@plant.com"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-steel-300 mb-1.5">Topic</label>
                  <textarea
                    value={topic}
                    onChange={(e) => setTopic(e.target.value)}
                    rows={3}
                    className="input resize-none"
                    placeholder="On-site training, VFD issue, crew skill gap..."
                  />
                </div>
                <button type="submit" disabled={submitting} className="btn-primary w-full">
                  {submitting ? (
                    <><Loader2 className="w-4 h-4 animate-spin" /> Sending...</>
                  ) : (
                    <>Send request</>
                  )}
                </button>
                <p className="text-xs text-steel-500 text-center">
                  Prefer email?{' '}
                  <a href={fallbackMailto()} className="text-rok-400 hover:text-rok-300">
                    {SITE_CONFIG.supportEmail}
                  </a>
                </p>
              </form>
            )}
          </div>
        ) : (
          <div className="grid gap-6 lg:grid-cols-[1fr_400px]">
            {/* Slot selection */}
            <div>
              <h2 className="text-lg font-semibold text-white mb-4">Available Times</h2>
              <div className="space-y-5">
                {Object.entries(grouped).map(([date, daySlots]) => (
                  <div key={date}>
                    <div className="flex items-center gap-2 mb-2.5">
                      <Calendar className="w-4 h-4 text-rok-400" />
                      <span className="text-sm font-semibold text-steel-200">{date}</span>
                    </div>
                    <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                      {daySlots.map((slot) => {
                        const isSelected = selectedSlot?.id === slot.id;
                        return (
                          <button
                            key={slot.id}
                            onClick={() => setSelectedSlot(slot)}
                            className={`flex items-center gap-2 px-3 py-2.5 rounded-lg border text-sm font-medium transition-all ${
                              isSelected
                                ? 'bg-rok-500/20 border-rok-500 text-white'
                                : 'bg-navy-800/60 border-steel-700/60 text-steel-200 hover:border-rok-500/40 hover:bg-navy-700/60'
                            }`}
                          >
                            <Clock className="w-3.5 h-3.5 text-rok-400" />
                            {formatTime(slot.start_time)}
                          </button>
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Booking form */}
            <div>
              {selectedSlot ? (
                <form onSubmit={handleBooking} className="card p-6 lg:sticky lg:top-28">
                  <h2 className="text-lg font-semibold text-white mb-1">Your Details</h2>
                  <div className="flex items-center gap-2 text-sm text-rok-400 mb-5">
                    <Calendar className="w-4 h-4" />
                    <span>{formatDate(selectedSlot.start_time)}</span>
                    <ArrowRight className="w-3.5 h-3.5" />
                    <span>{formatTime(selectedSlot.start_time)} – {formatTime(selectedSlot.end_time)}</span>
                  </div>

                  <div className="space-y-4">
                    <div>
                      <label className="block text-xs font-medium text-steel-300 mb-1.5">Full Name</label>
                      <input
                        type="text"
                        required
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                        className="input"
                        placeholder="John Smith"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-medium text-steel-300 mb-1.5">Email</label>
                      <input
                        type="email"
                        required
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        className="input"
                        placeholder="you@example.com"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-medium text-steel-300 mb-1.5">What would you like to discuss?</label>
                      <textarea
                        required
                        value={topic}
                        onChange={(e) => setTopic(e.target.value)}
                        rows={3}
                        className="input resize-none"
                        placeholder="Career questions, training guidance, technical help..."
                      />
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={submitting}
                    className="btn-primary w-full mt-5"
                  >
                    {submitting ? (
                      <>
                        <Loader2 className="w-4 h-4 animate-spin" /> Requesting...
                      </>
                    ) : (
                      <>
                        <Video className="w-4 h-4" /> Request Meeting
                      </>
                    )}
                  </button>
                  <p className="text-xs text-steel-500 mt-3 text-center">
                    You'll get a Google Meet link by email once confirmed.
                  </p>
                </form>
              ) : (
                <div className="card p-8 text-center">
                  <Clock className="w-10 h-10 text-steel-600 mx-auto mb-3" />
                  <p className="text-steel-400 text-sm">
                    Select an available time from the left to book your meeting.
                  </p>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
