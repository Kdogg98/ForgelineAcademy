import { Award, Download, Hexagon, AlertCircle, Shield, Building2 } from 'lucide-react';
import type { Certificate } from '@/lib/types';
import { useAuth } from '@/lib/auth';
import type { Route } from '@/components/Nav';

interface CertificatesProps {
  onNavigate: (r: Route) => void;
  certificates: Certificate[];
}

export function Certificates({ onNavigate, certificates }: CertificatesProps) {
  const { user, fullName, company } = useAuth();
  const certs = certificates;

  if (!user) {
    return (
      <div className="pt-16 min-h-screen flex items-center justify-center">
        <div className="card p-8 max-w-md text-center">
          <Award className="w-12 h-12 text-premium-400 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-white mb-2">Sign in to view certificates</h2>
          <p className="text-steel-400 mb-5">
            Your certificates are stored with your account. Sign in to view and download them.
          </p>
          <button onClick={() => onNavigate({ name: 'auth' })} className="btn-primary">
            Sign in / Create account
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="pt-16 min-h-screen">
      <div className="border-b border-steel-700/60 bg-navy-950/40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8">
          <h1 className="font-display text-3xl font-bold text-white mb-1">
            My Certificates
          </h1>
          <p className="text-steel-400">
            Official Certificates of Completion from ForgeLine Academy. Download or
            print for your records.
          </p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8">
        {certs.length === 0 ? (
          <div className="card p-12 text-center">
            <Award className="w-12 h-12 text-steel-600 mx-auto mb-4" />
            <h2 className="text-xl font-semibold text-white mb-2">No certificates yet</h2>
            <p className="text-steel-400 mb-5 max-w-md mx-auto">
              Complete all lessons in a course (passing each knowledge check at 80% or
              higher) to earn your Certificate of Completion.
            </p>
            <button onClick={() => onNavigate({ name: 'catalog' })} className="btn-primary">
              Browse Courses
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {certs.map((cert) => (
              <CertificateCard key={cert.id} cert={cert} userName={fullName || user?.email || 'Technician'} companyName={company?.name ?? null} companyLogo={company?.logo_url ?? null} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function CertificateCard({
  cert,
  userName,
  companyName,
  companyLogo,
}: {
  cert: Certificate;
  userName: string;
  companyName: string | null;
  companyLogo: string | null;
}) {
  const issuedDate = new Date(cert.issued_at).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  function handleDownload() {
    const certEl = document.getElementById(`cert-${cert.id}`);
    if (!certEl) return;
    const win = window.open('', '_blank', 'width=1000,height=700');
    if (!win) return;
    win.document.write(`<!DOCTYPE html>
<html><head><title>ForgeLine Certificate - ${cert.certificate_number}</title>
<style>
  @page { size: landscape; margin: 0; }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #e8e8e8; font-family: 'Georgia', 'Times New Roman', serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 30px; }
  .cert {
    width: 980px; height: 680px; background: #0A1628; position: relative;
    padding: 50px 70px; color: #fff; overflow: hidden;
  }
  .cert::before {
    content: ''; position: absolute; inset: 14px;
    border: 2px solid #2A4D7A; border-radius: 4px;
  }
  .cert::after {
    content: ''; position: absolute; inset: 22px;
    border: 1px solid #1a3a5a; border-radius: 2px;
  }
  .corner { position: absolute; width: 40px; height: 40px; border: 3px solid #3B82F6; }
  .corner.tl { top: 14px; left: 14px; border-right: none; border-bottom: none; }
  .corner.tr { top: 14px; right: 14px; border-left: none; border-bottom: none; }
  .corner.bl { bottom: 14px; left: 14px; border-right: none; border-top: none; }
  .corner.br { bottom: 14px; right: 14px; border-left: none; border-top: none; }
  .brand { display: flex; align-items: center; justify-content: center; gap: 10px; margin-bottom: 6px; }
  .brand-hex { width: 28px; height: 28px; }
  .brand-text { font-size: 13px; letter-spacing: 5px; color: #60A5FA; font-weight: bold; text-transform: uppercase; }
  .doc-type { text-align: center; font-size: 11px; letter-spacing: 4px; color: #64748B; text-transform: uppercase; margin-bottom: 30px; }
  .title { text-align: center; font-size: 38px; font-weight: bold; color: #fff; margin-bottom: 8px; letter-spacing: 1px; }
  .subtitle { text-align: center; font-size: 14px; color: #94A3B8; margin-bottom: 35px; }
  .name { text-align: center; font-size: 30px; font-weight: bold; color: #60A5FA; border-bottom: 1px solid #334155; display: inline-block; padding: 0 50px 6px; margin: 0 auto 20px; }
  .name-wrap { text-align: center; margin-bottom: 18px; }
  .completed-text { text-align: center; font-size: 14px; color: #94A3B8; margin-bottom: 12px; }
  .course { text-align: center; font-size: 22px; font-style: italic; color: #CBD5E1; max-width: 600px; margin: 0 auto; line-height: 1.4; }
  .footer { position: absolute; bottom: 60px; left: 70px; right: 70px; display: flex; justify-content: space-between; align-items: flex-end; }
  .sig-block { text-align: center; }
  .sig-line { border-top: 1px solid #475569; width: 180px; margin-bottom: 6px; }
  .sig-label { font-size: 11px; color: #64748B; text-transform: uppercase; letter-spacing: 2px; }
  .sig-value { font-size: 13px; color: #94A3B8; margin-top: 2px; }
  .cert-no { position: absolute; bottom: 30px; left: 0; right: 0; text-align: center; font-size: 10px; color: #475569; letter-spacing: 2px; font-family: monospace; }
  .seal { position: absolute; bottom: 110px; right: 80px; width: 70px; height: 70px; border: 2px solid #3B82F6; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 9px; color: #60A5FA; text-transform: uppercase; letter-spacing: 1px; font-weight: bold; transform: rotate(-12deg); }
</style></head><body>
<div class="cert">
  <div class="corner tl"></div><div class="corner tr"></div>
  <div class="corner bl"></div><div class="corner br"></div>
  <div class="brand">
    <svg class="brand-hex" viewBox="0 0 24 24" fill="none" stroke="#60A5FA" stroke-width="1.6"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>
    <span class="brand-text">ForgeLine Academy</span>
  </div>
  <div class="doc-type">Certificate of Completion</div>
  <div class="title">Certificate of Completion</div>
  <div class="subtitle">This is to certify that</div>
  <div class="name-wrap"><span class="name">${userName}</span></div>
  <div class="completed-text">has successfully completed all required lessons and knowledge checks for</div>
  <div class="course">${cert.course?.title ?? 'Industrial Maintenance Course'}</div>
  <div class="seal">Verified</div>
  <div class="footer">
    <div class="sig-block">
      <div class="sig-line"></div>
      <div class="sig-label">Date Issued</div>
      <div class="sig-value">${issuedDate}</div>
    </div>
    <div class="sig-block">
      <div class="sig-line"></div>
      <div class="sig-label">Authorized By</div>
      <div class="sig-value">ForgeLine Academy</div>
    </div>
  </div>
  <div class="cert-no">Certificate No: ${cert.certificate_number}</div>
</div>
</body></html>`);
    win.document.close();
    setTimeout(() => {
      win.focus();
      win.print();
    }, 400);
  }

  return (
    <div className="card overflow-hidden">
      {/* Certificate visual — industrial dark navy */}
      <div
        id={`cert-${cert.id}`}
        className="relative p-6 sm:p-8 bg-gradient-to-br from-navy-900 via-navy-950 to-black border-b border-steel-700/60"
      >
        {/* Decorative corner accents */}
        <div className="absolute top-3 left-3 w-8 h-8 border-l-2 border-t-2 border-accent-500/50 rounded-tl" />
        <div className="absolute top-3 right-3 w-8 h-8 border-r-2 border-t-2 border-accent-500/50 rounded-tr" />
        <div className="absolute bottom-3 left-3 w-8 h-8 border-l-2 border-b-2 border-accent-500/50 rounded-bl" />
        <div className="absolute bottom-3 right-3 w-8 h-8 border-r-2 border-b-2 border-accent-500/50 rounded-br" />

        {/* Inner border */}
        <div className="absolute inset-5 border border-steel-600/30 rounded-lg pointer-events-none" />

        <div className="relative text-center py-6">
          {/* Brand */}
          <div className="flex items-center justify-center gap-2 mb-5">
            <Hexagon className="w-7 h-7 text-accent-500" strokeWidth={1.6} />
            <div className="text-xs font-bold tracking-[0.3em] text-accent-300 uppercase">
              ForgeLine Academy
            </div>
            {companyName && (
              <>
                <div className="w-px h-4 bg-steel-600/50" />
                {companyLogo ? (
                  <img src={companyLogo} alt={companyName} className="h-6 w-auto max-w-[80px] object-contain opacity-80" />
                ) : (
                  <span className="text-[10px] text-steel-400 font-semibold uppercase tracking-wider">{companyName}</span>
                )}
              </>
            )}
          </div>

          {/* Document type */}
          <div className="text-[10px] uppercase tracking-[0.3em] text-steel-500 mb-1">
            Official Document
          </div>
          <div className="text-xl font-display font-bold text-white mb-1">
            Certificate of Completion
          </div>
          <div className="w-16 h-px bg-accent-500/40 mx-auto mb-6" />

          {/* Recipient */}
          <div className="text-xs uppercase tracking-widest text-steel-400 mb-3">
            This is to certify that
          </div>
          <div className="text-2xl font-display font-bold text-accent-300 border-b border-steel-600/50 inline-block px-10 pb-2 mb-5">
            {userName}
          </div>
          <div className="text-sm text-steel-400 mb-3">
            has successfully completed all required lessons and knowledge checks for
          </div>
          <div className="text-lg font-display font-semibold text-white italic max-w-md mx-auto leading-snug">
            {cert.course?.title ?? 'Industrial Maintenance Course'}
          </div>

          {/* Seal */}
          <div className="flex justify-center mt-5">
            <div className="w-16 h-16 rounded-full border-2 border-accent-500/40 flex items-center justify-center -rotate-12">
              <div className="text-center">
                <Shield className="w-5 h-5 text-accent-400/60 mx-auto" strokeWidth={1.5} />
                <div className="text-[7px] font-bold uppercase tracking-wider text-accent-300/70 mt-0.5">
                  Verified
                </div>
              </div>
            </div>
          </div>

          {/* Footer: date + cert number */}
          <div className="flex items-center justify-center gap-8 mt-6 pt-5 border-t border-steel-700/40 text-xs text-steel-500">
            <div>
              <div className="text-steel-300 font-medium">
                {issuedDate}
              </div>
              <div className="text-[10px] uppercase tracking-wider mt-0.5">Date Issued</div>
            </div>
            <div className="w-px h-8 bg-steel-700/40" />
            <div>
              <div className="text-steel-300 font-medium font-mono">{cert.certificate_number}</div>
              <div className="text-[10px] uppercase tracking-wider mt-0.5">Certificate No.</div>
            </div>
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="p-4 flex items-center justify-between">
        <div className="flex items-center gap-2 text-sm text-steel-400">
          <Award className="w-4 h-4 text-premium-400" />
          Verified completion
        </div>
        <button onClick={handleDownload} className="btn-secondary text-sm">
          <Download className="w-4 h-4" />
          Download / Print
        </button>
      </div>
    </div>
  );
}
