import { useState } from 'react';
import {
  Wrench,
  Stethoscope,
  ArrowRight,
  CheckCircle2,
  Loader2,
  AlertCircle,
  MapPin,
  Clock,
  Users,
  Zap,
  Phone,
  Mail,
  Building2,
  MessageSquare,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { SITE_CONFIG } from '@/lib/siteConfig';
import { track } from '@/lib/analytics';
import type { Route } from '@/components/Nav';

interface ServicesProps {
  onNavigate: (r: Route) => void;
}

export function Services({ onNavigate }: ServicesProps) {
  const [form, setForm] = useState({
    name: '',
    company: '',
    email: '',
    phone: '',
    service_type: 'both' as 'onsite_training' | 'troubleshooting' | 'both',
    message: '',
  });
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form.name.trim() || !form.email.trim()) return;
    setSubmitting(true);
    setError(null);
    try {
      const { error: insertErr } = await supabase.from('service_requests').insert({
        name: form.name.trim(),
        company: form.company.trim() || null,
        email: form.email.trim(),
        phone: form.phone.trim() || null,
        service_type: form.service_type,
        message: form.message.trim() || null,
      });
      if (insertErr) throw insertErr;
      setSubmitted(true);
      track('plant_lead', { service_type: form.service_type });
      setForm({ name: '', company: '', email: '', phone: '', service_type: 'both', message: '' });
      // Fire-and-forget notification (don't block success on email failure)
      supabase.functions.invoke('notify', {
        body: {
          type: 'service_request',
          name: form.name.trim(),
          company: form.company.trim() || null,
          email: form.email.trim(),
          phone: form.phone.trim() || null,
          service_type: form.service_type,
          message: form.message.trim() || null,
        },
      }).catch(() => {});
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to submit request');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="pt-16 min-h-screen">
      {/* Header */}
      <div className="border-b border-steel-700/60 bg-navy-950/40 relative overflow-hidden">
        <div className="absolute inset-0 bg-grid-steel bg-grid-32 opacity-15" />
        <div className="absolute -right-20 -top-20 w-72 h-72 rounded-full bg-rok-500/10 blur-3xl" />
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 py-12 text-center">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-rok-500/15 border border-rok-500/40 text-rok-300 text-xs font-semibold uppercase tracking-wider mb-4">
            <Wrench className="w-3.5 h-3.5" />
            On-Site & Plant Support
          </div>
          <h1 className="font-display text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-3">
            More Than Online Training
          </h1>
          <p className="text-steel-300 max-w-2xl mx-auto text-lg leading-relaxed">
            ForgeLine brings plant-floor expertise directly to your facility. On-site
            classes, hands-on troubleshooting, and remote diagnostic support for the
            equipment that keeps production running.
          </p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-12">
        {/* Two service cards */}
        <div className="grid md:grid-cols-2 gap-6 mb-12">
          {/* On-Site Training */}
          <div className="card p-7 border-rok-500/20 relative overflow-hidden">
            <div className="absolute -right-16 -top-16 w-40 h-40 rounded-full bg-rok-500/8 blur-3xl" />
            <div className="relative">
              <div className="w-12 h-12 rounded-xl bg-rok-500/15 border border-rok-500/30 flex items-center justify-center mb-5">
                <Wrench className="w-6 h-6 text-rok-400" />
              </div>
              <h2 className="font-display text-xl font-bold text-white mb-2">On-Site Training</h2>
              <p className="text-sm text-steel-400 mb-5 leading-relaxed">
                Practical, hands-on classes delivered at your facility. Built around
                the equipment and processes your team actually works on.
              </p>
              <ul className="space-y-2.5 mb-6">
                {[
                  { icon: Users, text: 'Motor control, VFDs, troubleshooting methods, instrumentation basics' },
                  { icon: Clock, text: 'Half-day, full-day, or multi-day formats' },
                  { icon: MapPin, text: 'Taught on your plant floor with your equipment' },
                  { icon: Zap, text: 'Tailored to your team\'s skill level and processes' },
                ].map((item, i) => {
                  const Icon = item.icon;
                  return (
                    <li key={i} className="flex items-start gap-2.5 text-sm text-steel-200">
                      <Icon className="w-4 h-4 text-rok-400 shrink-0 mt-0.5" />
                      {item.text}
                    </li>
                  );
                })}
              </ul>
              <button
                onClick={() => {
                  document.getElementById('request-form')?.scrollIntoView({ behavior: 'smooth' });
                  setForm((f) => ({ ...f, service_type: 'onsite_training' }));
                }}
                className="btn-primary w-full"
              >
                Request on-site training
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Plant Troubleshooting */}
          <div className="card p-7 border-accent-500/20 relative overflow-hidden">
            <div className="absolute -right-16 -top-16 w-40 h-40 rounded-full bg-accent-500/8 blur-3xl" />
            <div className="relative">
              <div className="w-12 h-12 rounded-xl bg-accent-500/15 border border-accent-500/30 flex items-center justify-center mb-5">
                <Stethoscope className="w-6 h-6 text-accent-400" />
              </div>
              <h2 className="font-display text-xl font-bold text-white mb-2">Plant Troubleshooting Support</h2>
              <p className="text-sm text-steel-400 mb-5 leading-relaxed">
                Remote or on-site diagnostic help when equipment won't run. Practical
                support for electrical, motor control, VFD, and industrial systems issues.
              </p>
              <ul className="space-y-2.5 mb-6">
                {[
                  { icon: Phone, text: 'Remote diagnostic support by phone or video' },
                  { icon: MapPin, text: 'On-site troubleshooting for complex issues' },
                  { icon: Zap, text: 'Electrical, motor control, VFD, and instrumentation diagnostics' },
                  { icon: Clock, text: 'Priority monthly retainers available' },
                ].map((item, i) => {
                  const Icon = item.icon;
                  return (
                    <li key={i} className="flex items-start gap-2.5 text-sm text-steel-200">
                      <Icon className="w-4 h-4 text-accent-400 shrink-0 mt-0.5" />
                      {item.text}
                    </li>
                  );
                })}
              </ul>
              <button
                onClick={() => {
                  document.getElementById('request-form')?.scrollIntoView({ behavior: 'smooth' });
                  setForm((f) => ({ ...f, service_type: 'troubleshooting' }));
                }}
                className="btn-secondary w-full"
              >
                Request troubleshooting help
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>

        {/* Format detail strip */}
        <div className="grid sm:grid-cols-3 gap-4 mb-12">
          {[
            { label: 'Half-Day', desc: 'Focused single-topic session, 3-4 hours', icon: Clock },
            { label: 'Full Day', desc: 'Comprehensive training with hands-on labs', icon: Users },
            { label: 'Multi-Day', desc: 'Deep-dive across multiple skill areas', icon: Wrench },
          ].map((item, i) => {
            const Icon = item.icon;
            return (
              <div key={i} className="rounded-lg border border-steel-700/40 bg-navy-950/30 p-5 text-center">
                <Icon className="w-6 h-6 text-rok-400 mx-auto mb-2" />
                <div className="text-sm font-semibold text-white mb-1">{item.label}</div>
                <div className="text-xs text-steel-500">{item.desc}</div>
              </div>
            );
          })}
        </div>

        {/* Scope / disclaimer */}
        <div className="mb-12 rounded-lg border border-steel-700/40 bg-navy-950/30 p-5">
          <h3 className="text-sm font-semibold text-steel-300 mb-2">Scope &amp; Disclaimer</h3>
          <ul className="space-y-1.5 text-xs text-steel-500 leading-relaxed">
            <li>Training is educational and does not replace required licenses, employer qualifications, or site procedures.</li>
            <li>On-site and troubleshooting support are advisory and performed under the customer&apos;s lockout/tagout, permits, and supervision.</li>
            <li>No guarantee of specific production outcomes.</li>
          </ul>
        </div>

        {/* Proof / trust section */}
        <div className="mb-12">
          <div className="text-center mb-8">
            <h2 className="font-display text-2xl font-bold text-white mb-2">Built for the Plant Floor</h2>
            <p className="text-sm text-steel-400">Real experience, real training, real support.</p>
          </div>
          <div className="grid sm:grid-cols-3 gap-4 mb-8">
            {[
              { icon: Wrench, text: 'Built by working industrial electricians for plant-floor crews' },
              { icon: CheckCircle2, text: 'Certificates of completion for training records' },
              { icon: Zap, text: 'Online training + on-site classes + troubleshooting support' },
            ].map((item, i) => {
              const Icon = item.icon;
              return (
                <div key={i} className="rounded-lg border border-steel-700/40 bg-navy-950/30 p-4 text-center">
                  <Icon className="w-6 h-6 text-rok-400 mx-auto mb-2" />
                  <p className="text-sm text-steel-300 leading-relaxed">{item.text}</p>
                </div>
              );
            })}
          </div>
          <div className="grid sm:grid-cols-3 gap-4">
            {[
              { quote: "The on-site motor control training gave our team the confidence to troubleshoot VFD issues without calling a contractor every time.", role: 'Maintenance Supervisor' },
              { quote: "ForgeLine's troubleshooting support helped us diagnose a recurring ground fault issue that had been shutting down our line for weeks.", role: 'I&E Technician' },
              { quote: "The online courses are well-structured and practical. Our apprentices can work through them at their own pace and actually apply what they learn.", role: 'Plant Maintenance Manager' },
            ].map((t, i) => (
              <div key={i} className="card p-5">
                <p className="text-sm text-steel-300 leading-relaxed mb-4 italic">&ldquo;{t.quote}&rdquo;</p>
                <div className="text-xs text-steel-500 font-medium">{t.role}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Request form */}
        <div id="request-form" className="max-w-2xl mx-auto">
          <div className="card p-7">
            {submitted ? (
              <div className="text-center py-8">
                <div className="w-14 h-14 rounded-full bg-success-500/15 flex items-center justify-center mx-auto mb-4">
                  <CheckCircle2 className="w-7 h-7 text-success-400" />
                </div>
                <h3 className="font-display text-xl font-bold text-white mb-2">Request received</h3>
                <p className="text-sm text-steel-400 mb-6">
                  I'll follow up shortly to discuss your needs and schedule.
                </p>
                <button
                  onClick={() => onNavigate({ name: 'home' })}
                  className="btn-ghost text-sm"
                >
                  Back to Home
                </button>
              </div>
            ) : (
              <>
                <h3 className="font-display text-xl font-bold text-white mb-2">Request a Service</h3>
                <p className="text-sm text-steel-400 mb-5">
                  Tell me what you need. I'll respond directly to coordinate dates, scope, and pricing.
                </p>

                {error && (
                  <div className="mb-4 flex items-start gap-3 p-4 rounded-lg bg-error-500/10 border border-error-500/30">
                    <AlertCircle className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5" />
                    <p className="text-sm text-error-300">{error}</p>
                  </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-4">
                  <div className="grid sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                        Name *
                      </label>
                      <input
                        type="text"
                        value={form.name}
                        onChange={(e) => setForm({ ...form, name: e.target.value })}
                        required
                        className="input"
                        placeholder="Your name"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                        Company
                      </label>
                      <input
                        type="text"
                        value={form.company}
                        onChange={(e) => setForm({ ...form, company: e.target.value })}
                        className="input"
                        placeholder="Company name"
                      />
                    </div>
                  </div>

                  <div className="grid sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                        Email *
                      </label>
                      <input
                        type="email"
                        value={form.email}
                        onChange={(e) => setForm({ ...form, email: e.target.value })}
                        required
                        className="input"
                        placeholder="you@company.com"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                        Phone (optional)
                      </label>
                      <input
                        type="tel"
                        value={form.phone}
                        onChange={(e) => setForm({ ...form, phone: e.target.value })}
                        className="input"
                        placeholder="Plant or cell number"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                      Service Type
                    </label>
                    <div className="grid grid-cols-3 gap-2">
                      {([
                        { value: 'onsite_training', label: 'On-Site Training' },
                        { value: 'troubleshooting', label: 'Troubleshooting' },
                        { value: 'both', label: 'Both' },
                      ] as const).map((opt) => (
                        <button
                          key={opt.value}
                          type="button"
                          onClick={() => setForm({ ...form, service_type: opt.value })}
                          className={`px-3 py-2.5 rounded-lg border text-sm font-medium transition-colors ${
                            form.service_type === opt.value
                              ? 'border-rok-500 bg-rok-500/15 text-white'
                              : 'border-steel-700/40 bg-navy-950/30 text-steel-400 hover:text-steel-200'
                          }`}
                        >
                          {opt.label}
                        </button>
                      ))}
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                      Message
                    </label>
                    <textarea
                      value={form.message}
                      onChange={(e) => setForm({ ...form, message: e.target.value })}
                      rows={4}
                      className="input resize-none"
                      placeholder="Tell me about your facility, team size, preferred dates, location, or the equipment issues you're facing."
                    />
                  </div>

                  <button
                    type="submit"
                    disabled={submitting || !form.name.trim() || !form.email.trim()}
                    className="btn-primary w-full"
                  >
                    {submitting ? (
                      <><Loader2 className="w-4 h-4 animate-spin" /> Submitting...</>
                    ) : (
                      <>Submit Request <ArrowRight className="w-4 h-4" /></>
                    )}
                  </button>
                </form>
              </>
            )}
          </div>
        </div>

        {/* Contact identity */}
        <div className="mt-12 rounded-xl border border-steel-700/40 bg-navy-950/30 p-6">
          <h3 className="font-display text-lg font-bold text-white mb-3">Contact</h3>
          <div className="grid sm:grid-cols-2 gap-4 text-sm">
            <div className="space-y-2">
              <div className="flex items-center gap-2 text-steel-300">
                <Building2 className="w-4 h-4 text-rok-400" />
                <span>{SITE_CONFIG.businessName}</span>
              </div>
              <div className="flex items-center gap-2 text-steel-300">
                <Mail className="w-4 h-4 text-rok-400" />
                <a href={`mailto:${SITE_CONFIG.supportEmail}`} className="hover:text-rok-400 transition-colors">{SITE_CONFIG.supportEmail}</a>
              </div>
              {SITE_CONFIG.phone ? (
              <div className="flex items-center gap-2 text-steel-300">
                <Phone className="w-4 h-4 text-rok-400" />
                <span>{SITE_CONFIG.phone}</span>
              </div>
              ) : null}
            </div>
            <div className="flex items-start gap-2 text-steel-400 text-sm">
              <MapPin className="w-4 h-4 text-rok-400 shrink-0 mt-0.5" />
              <span>{SITE_CONFIG.serviceArea}</span>
            </div>
          </div>
        </div>

        {/* Online training CTA */}
        <div className="mt-12 text-center">
          <p className="text-sm text-steel-500 mb-3">
            Looking for self-paced online training instead?
          </p>
          <button
            onClick={() => onNavigate({ name: 'paths' })}
            className="btn-ghost text-sm"
          >
            Browse Online Courses
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
