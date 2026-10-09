import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { Eye, X } from 'lucide-react';
import { useAuth } from '@/lib/auth';
import {
  applyTheme,
  bootTheme,
  brandedTitle,
  buildStoredTheme,
  clearAllCachedThemes,
  clearCachedTheme,
  clearPreview,
  companyQualifies,
  persistedSessionUserId,
  readCachedTheme,
  themeCompanyFromRow,
  verifyFavicon,
  writeCachedTheme,
  writePreview,
  type StoredTheme,
  type ThemeCompany,
} from './themeStore';
import { debugTheme } from './debugTheme';
import { CompanyThemeContext, type ThemeSource } from './useCompanyTheme';

/**
 * Single owner of the sitewide company theme. Sets --fl-* CSS variables on <html>
 * (Tailwind brand tokens read them), the favicon and data-company-theme.
 *
 * Who gets themed:
 *  - signed-in members (company_members) of a published + premium + active company
 *  - master admins previewing a company (sessionStorage, any publish state)
 *  - everyone else keeps the default ForgeLine palette.
 */
export function CompanyThemeProvider({ children }: { children: ReactNode }) {
  const { user, loading, profileReady, isAdmin, company, companyRole } = useAuth();
  const [debug] = useState<StoredTheme | null>(() => debugTheme());
  const [boot] = useState(() => bootTheme());
  const [bootUserId] = useState(() => persistedSessionUserId());
  const [preview, setPreview] = useState<StoredTheme | null>(() => (boot?.source === 'preview' ? boot.theme : null));
  const lastUserId = useRef<string | null>(null);
  /** Boot theme is only for the first auth resolution; later sign-ins must not reuse it. */
  const [settled, setSettled] = useState(false);

  const resolved = !loading && (!user || profileReady);
  const userId = user?.id ?? null;
  useEffect(() => {
    if (resolved) setSettled(true);
  }, [resolved]);

  // While a (new) user's profile loads: only that user's own cached theme, never another user's.
  const pendingTheme = useMemo(() => {
    if (resolved) return null;
    if (!settled && boot && (boot.source === 'preview' || !userId || userId === bootUserId)) return boot;
    if (user && isAdmin && preview) return { theme: preview, source: 'preview' as const };
    const cached = userId ? readCachedTheme(userId) : null;
    return cached ? { theme: cached, source: 'member' as const } : null;
  }, [resolved, settled, boot, bootUserId, userId, user, isAdmin, preview]);

  const memberTheme = useMemo(() => {
    if (!user || !companyRole || !companyQualifies(company)) return null;
    return buildStoredTheme(themeCompanyFromRow(company));
  }, [user, companyRole, company]);

  let active: StoredTheme | null;
  let source: ThemeSource | null;
  if (debug) {
    [active, source] = [debug, 'debug'];
  } else if (!resolved) {
    // Auth/profile still loading: keep the boot / cached theme of this same user (no flash).
    [active, source] = pendingTheme ? [pendingTheme.theme, pendingTheme.source] : [null, null];
  } else if (user && isAdmin && preview) {
    [active, source] = [preview, 'preview'];
  } else if (memberTheme) {
    [active, source] = [memberTheme, 'member'];
  } else {
    [active, source] = [null, null];
  }

  // Housekeeping once auth has settled: cache for the member, clear on logout / non-admin preview.
  useEffect(() => {
    if (!resolved || debug) return;
    if (user) {
      lastUserId.current = user.id;
      if (memberTheme) writeCachedTheme(user.id, memberTheme);
      else clearCachedTheme(user.id);
      if (preview && !isAdmin) {
        clearPreview();
        setPreview(null);
      }
    } else {
      // Signed out: drop every cached member theme (boot script must not re-apply it).
      clearAllCachedThemes();
      lastUserId.current = null;
      if (preview) {
        clearPreview();
        setPreview(null);
      }
    }
  }, [resolved, debug, user, memberTheme, preview, isAdmin]);

  const activeKey = active ? JSON.stringify(active.vars) + active.favicon : '';
  useEffect(() => {
    applyTheme(active);
    if (active) verifyFavicon(active);
    // activeKey captures every visual input of `active`
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeKey]);

  const startPreview = useCallback((c: ThemeCompany) => {
    const t = buildStoredTheme(c);
    writePreview(t);
    setPreview(t);
    window.scrollTo({ top: 0 });
  }, []);

  const exitPreview = useCallback(() => {
    clearPreview();
    setPreview(null);
  }, []);

  const themeCompany = active?.company ?? null;
  const titleFor = useCallback(
    (defaultTitle: string, page?: string | null) => (themeCompany ? brandedTitle(themeCompany, page) : defaultTitle),
    [themeCompany],
  );

  const value = useMemo(
    () => ({ company: themeCompany, source, titleFor, startPreview, exitPreview }),
    [themeCompany, source, titleFor, startPreview, exitPreview],
  );

  return (
    <CompanyThemeContext.Provider value={value}>
      {children}
      {source === 'preview' && themeCompany && (
        <PreviewBar company={themeCompany} onExit={exitPreview} />
      )}
    </CompanyThemeContext.Provider>
  );
}

function PreviewBar({ company, onExit }: { company: ThemeCompany; onExit: () => void }) {
  return (
    <div
      role="status"
      className="fixed bottom-4 left-1/2 -translate-x-1/2 z-[80] flex items-center gap-3 rounded-full border border-rok-500/50 bg-navy-950/95 px-4 py-2 text-sm text-steel-100 shadow-rok-lg backdrop-blur"
    >
      <Eye className="w-4 h-4 text-rok-400 shrink-0" />
      <span className="truncate max-w-[60vw]">
        Previewing site as <strong className="text-white">{company.name}</strong>
        {!company.published && <span className="ml-2 badge bg-premium-500/15 text-premium-400 border border-premium-500/30">Unpublished</span>}
      </span>
      <button onClick={onExit} className="btn-primary px-3 py-1 rounded-full text-xs">
        <X className="w-3.5 h-3.5" />
        Exit preview
      </button>
    </div>
  );
}
