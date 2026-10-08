const SHADES = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950];
const v = (name) => `rgb(var(${name}) / <alpha-value>)`;
const themed = (token, shades = SHADES) => Object.fromEntries(shades.map((s) => [s, v(`--fl-${token}-${s}`)]));

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        // Brand tokens resolve to CSS variables (defaults in src/index.css) so a
        // company theme can re-skin the whole site. See src/lib/theme/colors.ts.
        navy: themed('navy'),
        steel: themed('steel'),
        accent: { ...themed('accent'), hover: v('--fl-accent-hover') },
        rok: { ...themed('rok'), hover: v('--fl-rok-hover') },
        crimson: themed('crimson'),
        'on-rok': v('--fl-on-rok'),
        'on-accent': v('--fl-on-accent'),
        'on-premium': v('--fl-on-premium'),
        success: {
          400: '#4ADE80',
          500: '#22C55E',
          600: '#16A34A',
          700: '#15803D',
        },
        warning: {
          400: '#FBBF24',
          500: '#F59E0B',
          600: '#D97706',
        },
        error: {
          400: '#F87171',
          500: '#EF4444',
          600: '#DC2626',
        },
        // premium keeps its original 400-700 classes: premium-200/300/900/950 are used in
        // CourseCard/others but were never defined, and enabling them would change the default look.
        premium: { ...themed('premium', [400, 500, 600, 700]), hover: v('--fl-premium-hover') },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['"Space Grotesk"', 'Inter', 'system-ui', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'ui-monospace', 'monospace'],
      },
      backgroundImage: {
        'grid-steel': 'linear-gradient(to right, rgb(var(--fl-steel-400) / 0.06) 1px, transparent 1px), linear-gradient(to bottom, rgb(var(--fl-steel-400) / 0.06) 1px, transparent 1px)',
        'radial-navy': 'radial-gradient(ellipse at top, rgb(var(--fl-navy-700)) 0%, rgb(var(--fl-navy-900)) 55%, rgb(var(--fl-navy-950)) 100%)',
        'hero-rok': 'linear-gradient(135deg, rgb(var(--fl-rok-500)) 0%, rgb(var(--fl-crimson-500)) 45%, rgb(var(--fl-navy-900)) 100%)',
        'geometric-rok': 'linear-gradient(120deg, rgb(var(--fl-rok-500)) 0%, rgb(var(--fl-rok-600)) 25%, rgb(var(--fl-crimson-500)) 50%, rgb(var(--fl-navy-800)) 75%, rgb(var(--fl-navy-900)) 100%)',
      },
      backgroundSize: {
        'grid-32': '32px 32px',
      },
      boxShadow: {
        'rok': '0 10px 40px -10px rgb(var(--fl-rok-500) / 0.45)',
        'rok-lg': '0 20px 50px -12px rgb(var(--fl-rok-500) / 0.55)',
        'card-lift': '0 20px 40px -15px rgba(0, 0, 0, 0.5)',
      },
      keyframes: {
        'fade-in': {
          '0%': { opacity: '0', transform: 'translateY(8px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        'slide-in': {
          '0%': { opacity: '0', transform: 'translateX(24px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        shimmer: {
          '0%': { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0' },
        },
        'pulse-rok': {
          '0%, 100%': { boxShadow: '0 0 0 0 rgb(var(--fl-rok-500) / 0.4)' },
          '50%': { boxShadow: '0 0 0 12px rgb(var(--fl-rok-500) / 0)' },
        },
      },
      animation: {
        'fade-in': 'fade-in 0.5s ease-out both',
        'slide-in': 'slide-in 0.4s ease-out both',
        shimmer: 'shimmer 1.6s linear infinite',
        'pulse-rok': 'pulse-rok 2.5s ease-in-out infinite',
      },
    },
  },
  plugins: [],
};