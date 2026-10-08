/**
 * Test harness hook for screenshots/QA. Compiled in ONLY when the build sets
 * VITE_THEME_DEBUG=1 (production builds drop it as dead code).
 *
 *   /?fl_theme=0B3D91,1B2A4A,F2A900&fl_theme_name=Acme%20Aerospace
 *
 * The theme sticks for the tab (sessionStorage) so you can click around;
 * /?fl_theme=off clears it.
 */
import { isHexColor } from './colors';
import { buildStoredTheme, type StoredTheme } from './themeStore';

const KEY = 'fl_theme_debug';

export function debugTheme(): StoredTheme | null {
  if (import.meta.env.VITE_THEME_DEBUG !== '1') return null;
  try {
    const params = new URLSearchParams(window.location.search);
    const raw = params.get('fl_theme');
    if (raw === 'off') {
      sessionStorage.removeItem(KEY);
      return null;
    }
    if (raw) {
      const [primary, secondary, accent] = raw.split(',').map((h) => `#${h.replace(/^#/, '')}`);
      if (![primary, secondary, accent].every(isHexColor)) return null;
      const name = params.get('fl_theme_name') || 'Sample Manufacturing Co.';
      const theme = buildStoredTheme({
        id: 'debug',
        name,
        logoUrl: params.get('fl_theme_logo'),
        domain: params.get('fl_theme_domain'),
        industry: 'Aerospace components manufacturing',
        summary: `${name} builds precision components across three plants.`,
        locations: ['Wichita, KS', 'Tulsa, OK', 'Fort Worth, TX'],
        tracks: [
          { course_id: '', title: 'Mechanical Fundamentals', reason: 'CNC and press maintenance' },
          { course_id: '', title: 'Electrical Safety & NFPA 70E', reason: 'Plant-wide requirement' },
          { course_id: '', title: 'PLC Troubleshooting', reason: 'Automated cells' },
        ],
        brand: { primary, secondary, accent },
        published: true,
      });
      sessionStorage.setItem(KEY, JSON.stringify(theme));
      return theme;
    }
    const stored = sessionStorage.getItem(KEY);
    return stored ? (JSON.parse(stored) as StoredTheme) : null;
  } catch {
    return null;
  }
}
