import { Hexagon, ShieldCheck, Factory, GraduationCap, Mail, Phone, MapPin } from 'lucide-react';
import { SITE_CONFIG } from '@/lib/siteConfig';
import { useAuth } from '@/lib/auth';
import type { Route } from '@/components/Nav';
import { PlantFloorLinks } from '@/components/PlantFloorLinks';
import { useCompanyTheme } from '@/lib/theme/useCompanyTheme';
import { CoBrandLogo } from '@/components/brand/CompanyBrand';

export function Footer({ onNavigate }: { onNavigate: (r: Route) => void }) {
  const { user } = useAuth();
  const { company: themeCompany } = useCompanyTheme();
  return (
    <>
      <footer className="mt-20 border-t border-steel-700/60 bg-navy-950/60">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-12">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="md:col-span-2">
              {themeCompany ? (
                <div className="mb-4">
                  <CoBrandLogo company={themeCompany} size="lg" />
                  <p className="mt-3 text-sm text-steel-300 max-w-md">
                    {themeCompany.name} team training, delivered by ForgeLine Academy.
                  </p>
                </div>
              ) : (
                <div className="flex items-center gap-2.5 mb-4">
                  <Hexagon className="w-7 h-7 text-rok-500" strokeWidth={1.6} />
                  <div className="leading-none">
                    <div className="font-display text-lg font-bold text-white">
                      ForgeLine Academy
                    </div>
                    <div className="text-[10px] font-semibold uppercase tracking-[0.18em] text-steel-400">
                      Industrial Training
                    </div>
                  </div>
                </div>
              )}
              <p className="text-sm text-steel-400 leading-relaxed max-w-md">
                Structured, plant-floor-proven training for industrial electricians,
                millwrights, I&amp;E technicians, and maintenance engineers. Built by
                practitioners, aligned to the standards that keep production running.
              </p>
              <div className="flex flex-col gap-1.5 mt-4 text-xs text-steel-500">
                <div className="flex items-center gap-1.5">
                  <Mail className="w-3.5 h-3.5 text-rok-400" />
                  <a href={`mailto:${SITE_CONFIG.supportEmail}`} className="hover:text-rok-400 transition-colors">{SITE_CONFIG.supportEmail}</a>
                </div>
                {SITE_CONFIG.phone ? (
                <div className="flex items-center gap-1.5">
                  <Phone className="w-3.5 h-3.5 text-rok-400" />
                  <span>{SITE_CONFIG.phone}</span>
                </div>
                ) : null}
                <div className="flex items-start gap-1.5 max-w-sm">
                  <MapPin className="w-3.5 h-3.5 text-rok-400 shrink-0 mt-0.5" />
                  <span>{SITE_CONFIG.serviceArea}</span>
                </div>
              </div>
              <div className="flex flex-wrap gap-4 mt-5">
                <div className="flex items-center gap-2 text-xs text-steel-400">
                  <ShieldCheck className="w-4 h-4 text-success-500" />
                  Certificates of completion
                </div>
                <div className="flex items-center gap-2 text-xs text-steel-400">
                  <Factory className="w-4 h-4 text-accent-400" />
                  Plant-floor proven
                </div>
                <div className="flex items-center gap-2 text-xs text-steel-400">
                  <GraduationCap className="w-4 h-4 text-premium-400" />
                  Career-path structured
                </div>
              </div>
            </div>

            <div>
              <h4 className="text-sm font-semibold text-white mb-3">Platform</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <button onClick={() => onNavigate({ name: 'paths' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    Learning Paths
                  </button>
                </li>
                <li>
                  <button onClick={() => onNavigate({ name: 'catalog' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    Course Catalog
                  </button>
                </li>
                <li>
                  <button onClick={() => onNavigate({ name: 'services' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    On-Site &amp; Support
                  </button>
                </li>
                <li>
                  <button onClick={() => onNavigate({ name: 'book' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    For plants
                  </button>
                </li>
                <li>
                  <button onClick={() => onNavigate({ name: 'dashboard' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    My Learning
                  </button>
                </li>
                <li>
                  <button onClick={() => onNavigate({ name: 'certificates' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    Certificates
                  </button>
                </li>
              </ul>
              <h4 className="text-sm font-semibold text-white mb-3 mt-6">Plant-floor topics</h4>
              <PlantFloorLinks compact />
            </div>

            <div>
              <h4 className="text-sm font-semibold text-white mb-3">Access</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <button onClick={() => onNavigate({ name: 'pricing' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    Pricing &amp; Plans
                  </button>
                </li>
                <li>
                  {user ? (
                  <button onClick={() => onNavigate({ name: 'dashboard' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    My Learning
                  </button>
                  ) : (
                  <button onClick={() => onNavigate({ name: 'auth' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    Sign in / Create account
                  </button>
                  )}
                </li>
                <li className="text-steel-500 text-xs pt-1">Free: 44 courses (Mechanical + Electrical)</li>
                <li className="text-steel-500 text-xs">Premium: 78 total, including I&amp;E (18) and Engineering (16)</li>
              </ul>
            </div>

            <div>
              <h4 className="text-sm font-semibold text-white mb-3">Legal</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <button onClick={() => onNavigate({ name: 'legal', doc: 'privacy' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    Privacy Policy
                  </button>
                </li>
                <li>
                  <button onClick={() => onNavigate({ name: 'legal', doc: 'terms' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    Terms of Service
                  </button>
                </li>
                <li>
                  <button onClick={() => onNavigate({ name: 'legal', doc: 'disclaimer' })} className="text-steel-400 hover:text-rok-400 transition-colors">
                    Training Disclaimer
                  </button>
                </li>
                <li>
                  <a href="/contact/" className="text-steel-400 hover:text-rok-400 transition-colors">
                    Contact
                  </a>
                </li>
              </ul>
            </div>
          </div>

          <div className="mt-10 pt-6 border-t border-steel-700/40 flex flex-col sm:flex-row items-center justify-between gap-3">
            <p className="text-xs text-steel-500">
              &copy; {new Date().getFullYear()} ForgeLine Academy. Built for the plant floor.
            </p>
            <p className="text-xs text-steel-500 text-center sm:text-right max-w-md">
              Training content is for educational purposes. Always follow your site&apos;s
              procedures and lockout/tagout policies.
            </p>
          </div>
        </div>
      </footer>
    </>
  );
}