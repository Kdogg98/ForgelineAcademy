import { useEffect, useState } from 'react';
import { Search, Menu, X, User, LogOut, LayoutDashboard, Award, Shield, Building2 } from 'lucide-react';
import { Logo } from '@/components/ui/Logo';
import { useAuth } from '@/lib/auth';

export type Route =
  | { name: 'home' }
  | { name: 'paths'; focusPath?: 'electrical' | 'mechanical'; showWelcome?: boolean }
  | { name: 'catalog' }
  | { name: 'course'; courseId: string }
  | { name: 'games'; courseId: string }
  | { name: 'dashboard' }
  | { name: 'certificates' }
  | { name: 'pricing' }
  | { name: 'auth'; mode?: 'signin' | 'signup'; path?: 'electrical' | 'mechanical' }
  | { name: 'admin' }
  | { name: 'company'; companyId?: string }
  | { name: 'legal'; doc: 'privacy' | 'terms' | 'disclaimer' }
  | { name: 'search'; query: string }
  | { name: 'book' }
  | { name: 'services' }
  | { name: 'assessment' }
  | { name: 'announcements' };

interface NavProps {
  route: Route;
  onNavigate: (r: Route) => void;
}

const NAV_LINKS: { label: string; route: Route }[] = [
  { label: 'Learning Paths', route: { name: 'paths' } },
  { label: 'Course Catalog', route: { name: 'catalog' } },
  { label: 'My Learning', route: { name: 'dashboard' } },
  { label: 'Certificates', route: { name: 'certificates' } },
  { label: 'Book a Meeting', route: { name: 'book' } },
  { label: 'Services', route: { name: 'services' } },
  { label: 'Message Board', route: { name: 'announcements' } },
];

export function Nav({ route, onNavigate }: NavProps) {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [userMenu, setUserMenu] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [searchValue, setSearchValue] = useState('');

  const { user, isPremium, isAdmin, signOut, company, isCompanyAdmin } = useAuth();
  const showCompanyChip = Boolean(company && !/^test$/i.test((company.name || '').trim()));

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 12);
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  function isActive(r: Route) {
    return r.name === route.name;
  }

  function submitSearch(e: React.FormEvent) {
    e.preventDefault();
    if (searchValue.trim()) {
      onNavigate({ name: 'search', query: searchValue.trim() });
      setSearchOpen(false);
      setMobileOpen(false);
    }
  }

  return (
    <div className="fixed inset-x-0 top-0 z-[60]">
      <header
        className={`transition-all duration-300 bg-navy-900 border-b border-steel-700/60 ${
          scrolled ? 'shadow-lg shadow-navy-950/50' : ''
        }`}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-8">
              <button onClick={() => onNavigate({ name: 'home' })} aria-label="Home">
                <Logo />
              </button>
              {showCompanyChip && company?.logo_url && (
                <>
                  <div className="hidden sm:block w-px h-8 bg-steel-700/60" />
                  <div className="hidden sm:flex items-center gap-2 max-w-[140px]">
                    <img
                      src={company.logo_url}
                      alt={company.name}
                      className="h-8 w-auto max-w-[100px] object-contain opacity-80"
                    />
                    <span className="text-[10px] text-steel-500 truncate hidden lg:inline">{company.name}</span>
                  </div>
                </>
              )}
              <nav className="hidden lg:flex items-center gap-0.5">
                {NAV_LINKS.map((link) => (
                  <button
                    key={link.label}
                    onClick={() => { setUserMenu(false); onNavigate(link.route); }}
                    className={`px-3.5 py-2 rounded-md text-sm font-medium transition-colors ${
                      isActive(link.route)
                        ? 'text-white bg-navy-700/80'
                        : 'text-steel-300 hover:text-white hover:bg-navy-800/60'
                    }`}
                  >
                    {link.label}
                  </button>
                ))}
              </nav>
            </div>

            <div className="flex items-center gap-2">
              <div className="relative hidden sm:block">
                {searchOpen ? (
                  <form onSubmit={submitSearch} className="flex items-center">
                    <input
                      autoFocus
                      value={searchValue}
                      onChange={(e) => setSearchValue(e.target.value)}
                      placeholder="Search courses..."
                      className="w-52 lg:w-64 input py-1.5 text-sm pr-8"
                    />
                    <button
                      type="button"
                      onClick={() => setSearchOpen(false)}
                      className="absolute right-2 top-1/2 -translate-y-1/2 text-steel-400 hover:text-white"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </form>
                ) : (
                  <button
                    onClick={() => setSearchOpen(true)}
                    className="p-2 rounded-md text-steel-300 hover:text-white hover:bg-navy-700"
                    aria-label="Search"
                  >
                    <Search className="w-5 h-5" />
                  </button>
                )}
              </div>

              {user ? (
                <div className="relative">
                  <button
                    onClick={() => setUserMenu(!userMenu)}
                    className="flex items-center gap-2 p-1.5 rounded-md hover:bg-navy-700 transition-colors"
                  >
                    <div className="w-8 h-8 rounded-full bg-gradient-to-br from-rok-500 to-crimson-600 flex items-center justify-center text-white text-sm font-bold">
                      {user.email?.[0]?.toUpperCase() ?? 'U'}
                    </div>
                    {isPremium && (
                      <span className="hidden md:inline text-[10px] font-bold uppercase tracking-wider text-premium-400 bg-premium-500/15 border border-premium-500/30 px-1.5 py-0.5 rounded">
                        Premium
                      </span>
                    )}
                  </button>
                  {userMenu && (
                    <>
                      <div className="fixed inset-x-0 top-16 bottom-0 z-40" onClick={() => setUserMenu(false)} />
                      <div className="absolute right-0 mt-2 w-56 card border-steel-600 shadow-xl z-50 py-1.5 animate-fade-in">
                        <div className="px-3 py-2 border-b border-steel-700/60">
                          <p className="text-xs text-steel-400 truncate">{user.email}</p>
                        </div>
                        <button
                          onClick={() => { onNavigate({ name: 'dashboard' }); setUserMenu(false); }}
                          className="w-full flex items-center gap-2.5 px-3 py-2 text-sm text-steel-200 hover:bg-navy-700 hover:text-white"
                        >
                          <LayoutDashboard className="w-4 h-4" /> My Learning
                        </button>
                        <button
                          onClick={() => { onNavigate({ name: 'certificates' }); setUserMenu(false); }}
                          className="w-full flex items-center gap-2.5 px-3 py-2 text-sm text-steel-200 hover:bg-navy-700 hover:text-white"
                        >
                          <Award className="w-4 h-4" /> Certificates
                        </button>
                        {!isPremium && (
                          <button
                            onClick={() => { onNavigate({ name: 'pricing' }); setUserMenu(false); }}
                            className="w-full flex items-center gap-2.5 px-3 py-2 text-sm text-premium-400 hover:bg-navy-700"
                          >
                            Upgrade to Premium
                          </button>
                        )}
                        {isAdmin && (
                          <button
                            onClick={() => { onNavigate({ name: 'admin' }); setUserMenu(false); }}
                            className="w-full flex items-center gap-2.5 px-3 py-2 text-sm text-accent-300 hover:bg-navy-700"
                          >
                            <Shield className="w-4 h-4" /> Admin
                          </button>
                        )}
                        {isCompanyAdmin && (
                          <button
                            onClick={() => { onNavigate({ name: 'company' }); setUserMenu(false); }}
                            className="w-full flex items-center gap-2.5 px-3 py-2 text-sm text-steel-200 hover:bg-navy-700 hover:text-white"
                          >
                            <Building2 className="w-4 h-4" /> Company
                          </button>
                        )}
                        <div className="border-t border-steel-700/60 mt-1 pt-1">
                          <button
                            onClick={() => { void signOut(); setUserMenu(false); onNavigate({ name: 'home' }); }}
                            className="w-full flex items-center gap-2.5 px-3 py-2 text-sm text-steel-400 hover:bg-navy-700 hover:text-error-400"
                          >
                            <LogOut className="w-4 h-4" /> Sign out
                          </button>
                        </div>
                      </div>
                    </>
                  )}
                </div>
              ) : (
                <div className="hidden sm:flex items-center gap-2">
                  <button
                    onClick={() => onNavigate({ name: 'auth' })}
                    className="btn-ghost text-sm"
                  >
                    Sign in
                  </button>
                  <button
                    onClick={() => onNavigate({ name: 'auth', mode: 'signup', path: 'electrical' })}
                    className="btn-primary text-sm px-4"
                  >
                    Start Free
                  </button>
                </div>
              )}

              <button
                onClick={() => setMobileOpen(!mobileOpen)}
                className="lg:hidden p-2 rounded-md text-steel-300 hover:text-white hover:bg-navy-700"
                aria-label="Menu"
              >
                {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
              </button>
            </div>
          </div>
        </div>

        {mobileOpen && (
          <div className="lg:hidden border-t border-steel-700/60 bg-navy-900/98 backdrop-blur-md">
            <div className="max-w-7xl mx-auto px-4 py-4 space-y-1">
              <form onSubmit={submitSearch} className="mb-3">
                <input
                  value={searchValue}
                  onChange={(e) => setSearchValue(e.target.value)}
                  placeholder="Search courses..."
                  className="input text-sm"
                />
              </form>
              {NAV_LINKS.map((link) => (
                <button
                  key={link.label}
                  onClick={() => { onNavigate(link.route); setMobileOpen(false); }}
                  className={`w-full text-left px-3 py-2.5 rounded-md text-sm font-medium ${
                    isActive(link.route) ? 'bg-navy-700 text-white' : 'text-steel-300 hover:bg-navy-800'
                  }`}
                >
                  {link.label}
                </button>
              ))}
              {!user && (
                <div className="pt-3 flex gap-2">
                  <button onClick={() => { onNavigate({ name: 'auth' }); setMobileOpen(false); }} className="btn-secondary flex-1">
                    Sign in
                  </button>
                  <button onClick={() => { onNavigate({ name: 'auth', mode: 'signup', path: 'electrical' }); setMobileOpen(false); }} className="btn-primary flex-1">
                    Start Free
                  </button>
                </div>
              )}
              {isCompanyAdmin && (
                <button
                  onClick={() => { onNavigate({ name: 'company' }); setMobileOpen(false); }}
                  className="w-full text-left px-3 py-2.5 rounded-md text-sm font-medium text-steel-300 hover:bg-navy-800 flex items-center gap-2"
                >
                  <Building2 className="w-4 h-4" /> Company
                </button>
              )}
            </div>
          </div>
        )}
      </header>
    </div>
  );
}