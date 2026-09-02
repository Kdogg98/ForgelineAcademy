/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        navy: {
          950: '#070F1C',
          900: '#0A1628',
          800: '#0F1F36',
          700: '#16294A',
          600: '#1E3A5F',
          500: '#2A4D7A',
        },
        steel: {
          50: '#F0F4F8',
          100: '#DCE4ED',
          200: '#B8C7D9',
          300: '#8FA3BC',
          400: '#6B82A0',
          500: '#4D6585',
          600: '#3A4E6B',
          700: '#2A3A52',
          800: '#1E2A3D',
          900: '#141E2E',
        },
        accent: {
          50: '#EAF4FF',
          100: '#D1E7FF',
          200: '#A3CFFF',
          300: '#6FB2FF',
          400: '#3A93F5',
          500: '#1A73D4',
          600: '#0E57A8',
          700: '#0B4480',
          800: '#093466',
          900: '#07284E',
        },
        rok: {
          50: '#FFF5F0',
          100: '#FFE6D9',
          200: '#FFC9B0',
          300: '#FFA07A',
          400: '#FF7A45',
          500: '#EC682B',
          600: '#D4551A',
          700: '#B34414',
          800: '#8F3610',
          900: '#6B290C',
        },
        crimson: {
          400: '#F0435D',
          500: '#CD173F',
          600: '#A91233',
          700: '#850E28',
        },
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
        premium: {
          400: '#FCD34D',
          500: '#F59E0B',
          600: '#D97706',
          700: '#B45309',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['"Space Grotesk"', 'Inter', 'system-ui', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'ui-monospace', 'monospace'],
      },
      backgroundImage: {
        'grid-steel': "linear-gradient(to right, rgba(106,130,160,0.06) 1px, transparent 1px), linear-gradient(to bottom, rgba(106,130,160,0.06) 1px, transparent 1px)",
        'radial-navy': 'radial-gradient(ellipse at top, #16294A 0%, #0A1628 55%, #070F1C 100%)',
        'hero-rok': 'linear-gradient(135deg, #EC682B 0%, #CD173F 45%, #0A1628 100%)',
        'geometric-rok': 'linear-gradient(120deg, #EC682B 0%, #D4551A 25%, #CD173F 50%, #0F1F36 75%, #0A1628 100%)',
      },
      backgroundSize: {
        'grid-32': '32px 32px',
      },
      boxShadow: {
        'rok': '0 10px 40px -10px rgba(236, 104, 43, 0.45)',
        'rok-lg': '0 20px 50px -12px rgba(236, 104, 43, 0.55)',
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
          '0%, 100%': { boxShadow: '0 0 0 0 rgba(236, 104, 43, 0.4)' },
          '50%': { boxShadow: '0 0 0 12px rgba(236, 104, 43, 0)' },
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