import { useState } from 'react';
import { Hexagon, Mail, Lock, AlertCircle, CheckCircle2, ArrowRight, User, Zap, Wrench } from 'lucide-react';
import { useAuth } from '@/lib/auth';
import { track } from '@/lib/analytics';
import type { Route } from '@/components/Nav';

interface AuthProps {
  onNavigate: (r: Route) => void;
  initialMode?: 'signin' | 'signup';
  initialPath?: 'electrical' | 'mechanical';
}

export function Auth({ onNavigate, initialMode, initialPath }: AuthProps) {
  const { signIn, signUp } = useAuth();
  const [mode, setMode] = useState<'signin' | 'signup'>(initialMode ?? 'signin');
  const [selectedPath, setSelectedPath] = useState<'electrical' | 'mechanical'>(initialPath ?? 'electrical');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    setLoading(true);
    try {
      if (mode === 'signup') {
        const { error } = await signUp(email, password, fullName.trim());
        if (error) setError(error);
        else {
          track('signup_free', { path: selectedPath });
          setSuccess('Account created. Starting your free training...');
          setTimeout(() => onNavigate({ name: 'paths', focusPath: selectedPath, showWelcome: true }), 800);
        }
      } else {
        const { error } = await signIn(email, password);
        if (error) setError(error);
        else {
          onNavigate({ name: 'home' });
        }
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="pt-16 min-h-screen flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="flex items-center justify-center gap-2.5 mb-4">
            <Hexagon className="w-9 h-9 text-accent-500" strokeWidth={1.6} />
            <div className="leading-none text-left">
              <div className="font-display text-xl font-bold text-white">ForgeLine</div>
              <div className="text-[10px] font-semibold uppercase tracking-[0.18em] text-steel-400">
                Academy
              </div>
            </div>
          </div>
          <h1 className="font-display text-2xl font-bold text-white">
            {mode === 'signin' ? 'Welcome back' : 'Create your account'}
          </h1>
          <p className="text-sm text-steel-400 mt-1">
            {mode === 'signin'
              ? 'Sign in to continue your training'
              : 'Free account — access Mechanical and Electrical courses instantly'}
          </p>
        </div>

        <div className="card p-6">
          {mode === 'signup' && (
            <div className="mb-5">
              <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-2">
                Choose your starting path
              </label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => setSelectedPath('electrical')}
                  className={`flex items-center gap-2.5 p-3 rounded-xl border transition-all ${
                    selectedPath === 'electrical'
                      ? 'border-accent-500/50 bg-accent-500/10 ring-1 ring-accent-500/30'
                      : 'border-steel-700/50 bg-navy-950/40 hover:border-steel-600'
                  }`}
                >
                  <Zap className={`w-5 h-5 ${selectedPath === 'electrical' ? 'text-accent-400' : 'text-steel-500'}`} />
                  <div className="text-left">
                    <div className={`text-sm font-semibold ${selectedPath === 'electrical' ? 'text-white' : 'text-steel-300'}`}>
                      Electrical
                    </div>
                    <div className="text-[10px] text-steel-500">Motor control, VFDs, safety</div>
                  </div>
                </button>
                <button
                  type="button"
                  onClick={() => setSelectedPath('mechanical')}
                  className={`flex items-center gap-2.5 p-3 rounded-xl border transition-all ${
                    selectedPath === 'mechanical'
                      ? 'border-premium-500/50 bg-premium-500/10 ring-1 ring-premium-500/30'
                      : 'border-steel-700/50 bg-navy-950/40 hover:border-steel-600'
                  }`}
                >
                  <Wrench className={`w-5 h-5 ${selectedPath === 'mechanical' ? 'text-premium-400' : 'text-steel-500'}`} />
                  <div className="text-left">
                    <div className={`text-sm font-semibold ${selectedPath === 'mechanical' ? 'text-white' : 'text-steel-300'}`}>
                      Mechanical
                    </div>
                    <div className="text-[10px] text-steel-500">Pumps, drives, hydraulics</div>
                  </div>
                </button>
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            {mode === 'signup' && (
              <div>
                <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                  Full Name
                </label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-steel-500" />
                  <input
                    type="text"
                    required
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    placeholder="John Smith"
                    className="input pl-10"
                  />
                </div>
                <p className="text-[11px] text-steel-500 mt-1.5">Required. Shown on your certificates of completion.</p>
              </div>
            )}
            <div>
              <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                Email
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-steel-500" />
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="you@plant.com"
                  className="input pl-10"
                />
              </div>
            </div>
            <div>
              <label className="block text-xs font-semibold text-steel-300 uppercase tracking-wider mb-1.5">
                Password
              </label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-steel-500" />
                <input
                  type="password"
                  required
                  minLength={6}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="At least 6 characters"
                  className="input pl-10"
                />
              </div>
            </div>

            {error && (
              <div className="flex items-start gap-2 p-3 rounded-lg bg-error-500/10 border border-error-500/30 text-error-400 text-sm">
                <AlertCircle className="w-4 h-4 shrink-0 mt-0.5" />
                {error}
              </div>
            )}
            {success && (
              <div className="flex items-start gap-2 p-3 rounded-lg bg-success-500/10 border border-success-500/30 text-success-400 text-sm">
                <CheckCircle2 className="w-4 h-4 shrink-0 mt-0.5" />
                {success}
              </div>
            )}

            <button type="submit" disabled={loading} className="btn-primary w-full">
              {loading ? (
                'Please wait...'
              ) : (
                <>
                  {mode === 'signin' ? 'Sign in' : 'Create account'}
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </form>

          <div className="mt-5 pt-5 border-t border-steel-700/60 text-center">
            <button
              onClick={() => {
                setMode(mode === 'signin' ? 'signup' : 'signin');
                setError(null);
                setSuccess(null);
              }}
              className="text-sm text-steel-400 hover:text-accent-400 transition-colors"
            >
              {mode === 'signin'
                ? "Don't have an account? Sign up free"
                : 'Already have an account? Sign in'}
            </button>
          </div>
        </div>

        <div className="mt-6 text-center">
          <button
            onClick={() => onNavigate({ name: 'home' })}
            className="text-xs text-steel-500 hover:text-steel-300 transition-colors"
          >
            Back to home
          </button>
        </div>

        <p className="mt-6 text-xs text-steel-500 text-center leading-relaxed">
          Free accounts get full access to Mechanical and Electrical stages. Upgrade
          anytime to unlock I&amp;E and Engineering.
        </p>
      </div>
    </div>
  );
}
