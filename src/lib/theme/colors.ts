/**
 * Brand palette engine for sitewide company theming.
 *
 * Tailwind color tokens (navy, steel, accent, rok, crimson, premium) resolve to
 * `rgb(var(--fl-<token>-<shade>) / <alpha-value>)`. Defaults (the ForgeLine
 * palette) live in index.css; a company theme overrides the variables on
 * <html>. All palettes are generated here from three brand hex colors with
 * WCAG contrast checks against the (dark) site surfaces.
 */

export type Rgb = [number, number, number];
export const SHADES = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950] as const;
export type Shade = (typeof SHADES)[number];
export type Scale = Record<Shade, Rgb>;

export interface BrandInput {
  primary: string;
  secondary: string;
  accent: string;
}

const HEX_RE = /^#?([0-9a-f]{6})$/i;

export function isHexColor(v: string | null | undefined): v is string {
  return !!v && HEX_RE.test(v.trim());
}

export function hexToRgb(hex: string): Rgb {
  const m = HEX_RE.exec(hex.trim());
  const n = parseInt(m ? m[1] : '000000', 16);
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
}

export function rgbToHex([r, g, b]: Rgb): string {
  return `#${[r, g, b].map((c) => Math.round(c).toString(16).padStart(2, '0')).join('')}`.toUpperCase();
}

const clamp = (n: number, lo = 0, hi = 255) => Math.min(hi, Math.max(lo, n));

/** Linear mix: t=0 -> a, t=1 -> b. */
export function mix(a: Rgb, b: Rgb, t: number): Rgb {
  return [0, 1, 2].map((i) => clamp(Math.round(a[i] + (b[i] - a[i]) * t))) as Rgb;
}

const WHITE: Rgb = [255, 255, 255];
const BLACK: Rgb = [0, 0, 0];

function channel(c: number) {
  const x = c / 255;
  return x <= 0.03928 ? x / 12.92 : ((x + 0.055) / 1.055) ** 2.4;
}

export function luminance([r, g, b]: Rgb): number {
  return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
}

export function contrast(a: Rgb, b: Rgb): number {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
}

/** Nudge `fg` toward white (or black) until it reaches `min` contrast on `bg`. */
export function ensureContrast(fg: Rgb, bg: Rgb, min: number, toward: 'light' | 'dark' = 'light'): Rgb {
  const target = toward === 'light' ? WHITE : BLACK;
  let out = fg;
  for (let t = 0; t <= 1 && contrast(out, bg) < min; t += 0.04) out = mix(fg, target, t);
  return contrast(out, bg) >= min ? out : target;
}

export function rgbToHsl([r, g, b]: Rgb): [number, number, number] {
  const [R, G, B] = [r / 255, g / 255, b / 255];
  const max = Math.max(R, G, B);
  const min = Math.min(R, G, B);
  const l = (max + min) / 2;
  if (max === min) return [0, 0, l];
  const d = max - min;
  const s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
  let h = max === R ? (G - B) / d + (G < B ? 6 : 0) : max === G ? (B - R) / d + 2 : (R - G) / d + 4;
  h /= 6;
  return [h, s, l];
}

export function hslToRgb([h, s, l]: [number, number, number]): Rgb {
  if (s === 0) return [l * 255, l * 255, l * 255].map(Math.round) as Rgb;
  const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
  const p = 2 * l - q;
  const f = (t: number) => {
    let x = t;
    if (x < 0) x += 1;
    if (x > 1) x -= 1;
    if (x < 1 / 6) return p + (q - p) * 6 * x;
    if (x < 1 / 2) return q;
    if (x < 2 / 3) return p + (q - p) * (2 / 3 - x) * 6;
    return p;
  };
  return [f(h + 1 / 3), f(h), f(h - 1 / 3)].map((v) => Math.round(v * 255)) as Rgb;
}

/** Tailwind-like 50..950 scale with `base` exactly at 500. */
export function scaleFrom(base: Rgb): Scale {
  const light: Record<number, number> = { 50: 0.94, 100: 0.86, 200: 0.7, 300: 0.5, 400: 0.25 };
  const dark: Record<number, number> = { 600: 0.16, 700: 0.32, 800: 0.48, 900: 0.62, 950: 0.76 };
  const out = {} as Scale;
  for (const s of SHADES) {
    out[s] = s === 500 ? base : s < 500 ? mix(base, WHITE, light[s]) : mix(base, BLACK, dark[s]);
  }
  return out;
}

/** Re-hue a reference scale (keeps its lightness ladder so text contrast is preserved). */
function rehue(ref: Partial<Scale>, hue: number, satCap: number): Partial<Scale> {
  const out: Partial<Scale> = {};
  for (const s of SHADES) {
    const r = ref[s];
    if (!r) continue;
    const [, rs, rl] = rgbToHsl(r);
    out[s] = hslToRgb([hue, Math.min(rs, satCap), rl]);
  }
  return out;
}

// ---- ForgeLine defaults (must match the defaults in src/index.css) ----
const hx = (h: string) => hexToRgb(h);
/** Lightness ladders of the ForgeLine dark surfaces / neutrals (tailwind.config.js). */
const FORGELINE_NAVY: Partial<Scale> = {
  500: hx('#2A4D7A'), 600: hx('#1E3A5F'), 700: hx('#16294A'), 800: hx('#0F1F36'), 900: hx('#0A1628'), 950: hx('#070F1C'),
};
const FORGELINE_STEEL: Partial<Scale> = {
  50: hx('#F0F4F8'), 100: hx('#DCE4ED'), 200: hx('#B8C7D9'), 300: hx('#8FA3BC'), 400: hx('#6B82A0'),
  500: hx('#4D6585'), 600: hx('#3A4E6B'), 700: hx('#2A3A52'), 800: hx('#1E2A3D'), 900: hx('#141E2E'),
};

export interface ThemePalette {
  navy: Scale; // dark surfaces -> brand primary hue on the ForgeLine lightness ladder
  steel: Scale; // neutrals/text -> faint brand tint, same lightness
  accent: Scale; // ForgeLine blue (links, info, badges) -> brand primary
  rok: Scale; // ForgeLine orange (CTAs, highlights) -> brand accent
  crimson: Scale; // gradient partner -> brand secondary
  premium: Scale; // premium gold -> brand accent
  rokHover: Rgb;
  accentHover: Rgb;
  onRok: Rgb;
  onAccent: Rgb;
  onPremium: Rgb;
}

/** Pick white or near-black text for a fill; nudge the fill until WCAG AA (4.5:1) holds. */
export function solidWithText(fill: Rgb, darkText: Rgb): { fill: Rgb; on: Rgb } {
  const on = contrast(WHITE, fill) >= contrast(darkText, fill) ? WHITE : darkText;
  let out = fill;
  for (let t = 0.04; t <= 1 && contrast(on, out) < 4.5; t += 0.04) out = mix(fill, on === WHITE ? BLACK : WHITE, t);
  return { fill: out, on };
}

/** A hover shade for a solid fill that keeps AA with the same text color. */
function hoverOf(fill: Rgb, on: Rgb): Rgb {
  const lighter = mix(fill, WHITE, 0.14);
  return contrast(on, lighter) >= 4.5 ? lighter : mix(fill, BLACK, 0.14);
}

/** Fill in the shades a reference scale lacks (light shades from 500, dark from 950). */
function completeScale(partial: Partial<Scale>): Scale {
  const gen = scaleFrom(partial[500] ?? [128, 128, 128]);
  const out = {} as Scale;
  for (const s of SHADES) out[s] = partial[s] ?? gen[s];
  return out;
}

/** Keep a scale strictly ordered (light -> dark) after contrast nudges. */
function keepOrdered(sc: Scale): Scale {
  for (let i = SHADES.indexOf(500) + 1; i < SHADES.length; i++) {
    const [prev, cur] = [sc[SHADES[i - 1]], sc[SHADES[i]]];
    if (luminance(cur) > luminance(prev) * 0.82) sc[SHADES[i]] = mix(prev, BLACK, 0.18);
  }
  for (let i = SHADES.indexOf(500) - 1; i >= 0; i--) {
    const [next, cur] = [sc[SHADES[i + 1]], sc[SHADES[i]]];
    if (luminance(cur) < luminance(next) * 1.12) sc[SHADES[i]] = mix(cur, WHITE, 0.22);
  }
  return sc;
}

/** Hue for tinting surfaces: the first chromatic of primary/secondary; neutral if both are greys. */
function surfaceHue(colors: Rgb[]): { hue: number; sat: number } {
  for (const c of colors) {
    const [h, s, l] = rgbToHsl(c);
    if (s >= 0.15 && l > 0.06 && l < 0.94) return { hue: h, sat: s };
  }
  return { hue: rgbToHsl(colors[0])[0], sat: 0.04 };
}

export function buildPalette(brand: BrandInput): ThemePalette {
  const primary = hexToRgb(brand.primary);
  const secondary = hexToRgb(brand.secondary);
  const accent = hexToRgb(brand.accent);
  const { hue, sat } = surfaceHue([primary, secondary]);

  // Surfaces keep the ForgeLine dark lightness ladder (so all existing text stays legible),
  // re-hued toward the brand. Saturation is capped so large areas stay calm.
  const navy = completeScale(rehue(FORGELINE_NAVY, hue, Math.min(0.45, sat * 0.7)));
  const steel = completeScale(rehue(FORGELINE_STEEL, hue, Math.min(0.2, sat * 0.35)));
  const surface = navy[900];
  const card = navy[800];
  const darkText = navy[950];

  // Most-used text colors stay AA on cards/surfaces.
  for (const s of [100, 200, 300] as const) steel[s] = ensureContrast(steel[s], card, 4.5);
  steel[400] = ensureContrast(steel[400], surface, 4.5);

  const brandScale = (raw: Rgb) => {
    // Solid brand fills must stand out from the dark page (WCAG 1.4.11 non-text 3:1).
    const sc = scaleFrom(ensureContrast(raw, surface, 3));
    const solid = solidWithText(sc[500], darkText);
    sc[500] = solid.fill;
    // 100-400 are text colors on dark surfaces: AA on navy-800.
    for (const s of [100, 200, 300, 400] as const) sc[s] = ensureContrast(sc[s], card, 4.5);
    // 600-700 sit under white text (promo bar, gradients).
    for (const s of [600, 700] as const) sc[s] = ensureContrast(sc[s], WHITE, 4.5, 'dark');
    return { sc: keepOrdered(sc), on: solid.on, hover: hoverOf(sc[500], solid.on) };
  };

  const rok = brandScale(accent);
  const acc = brandScale(primary);
  const crimson = scaleFrom(ensureContrast(secondary, surface, 2));
  for (const s of [600, 700] as const) crimson[s] = ensureContrast(crimson[s], WHITE, 3, 'dark');
  crimson[400] = ensureContrast(crimson[400], card, 3);

  return {
    navy,
    steel,
    accent: acc.sc,
    rok: rok.sc,
    crimson: keepOrdered(crimson),
    premium: rok.sc,
    rokHover: rok.hover,
    accentHover: acc.hover,
    onRok: rok.on,
    onAccent: acc.on,
    onPremium: rok.on,
  };
}

const triplet = ([r, g, b]: Rgb) => `${r} ${g} ${b}`;

/** CSS custom properties for a palette (values are "r g b" triplets for Tailwind alpha). */
export function paletteToVars(p: ThemePalette): Record<string, string> {
  const vars: Record<string, string> = {};
  (['navy', 'steel', 'accent', 'rok', 'crimson', 'premium'] as const).forEach((name) => {
    for (const s of SHADES) vars[`--fl-${name}-${s}`] = triplet(p[name][s]);
  });
  vars['--fl-rok-hover'] = triplet(p.rokHover);
  vars['--fl-premium-hover'] = triplet(p.rokHover);
  vars['--fl-accent-hover'] = triplet(p.accentHover);
  vars['--fl-on-rok'] = triplet(p.onRok);
  vars['--fl-on-accent'] = triplet(p.onAccent);
  vars['--fl-on-premium'] = triplet(p.onPremium);
  return vars;
}

export function initialsOf(name: string): string {
  const words = name.replace(/[^\p{L}\p{N}\s&]/gu, ' ').split(/\s+/).filter((w) => w && !/^(inc|llc|co|corp|ltd|the|&)$/i.test(w));
  return (words.slice(0, 2).map((w) => w[0]).join('') || name.slice(0, 2)).toUpperCase();
}

/** Small SVG data-URI badge with company initials (favicon + logo fallback). */
export function initialsBadgeDataUri(name: string, bgHex: string, fgHex: string): string {
  const text = initialsOf(name).slice(0, 2).replace(/[<>&"']/g, '');
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" rx="14" fill="${bgHex}"/><text x="32" y="41" font-family="Inter,Arial,sans-serif" font-size="26" font-weight="700" text-anchor="middle" fill="${fgHex}">${text}</text></svg>`;
  return `data:image/svg+xml,${encodeURIComponent(svg)}`;
}
