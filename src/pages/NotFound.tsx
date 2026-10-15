import { Compass } from 'lucide-react';
import type { Route } from '@/components/Nav';

export function NotFound({ path, onNavigate }: { path: string; onNavigate: (r: Route) => void }) {
  return (
    <div className="pt-32 pb-24 px-4 min-h-[70vh] flex items-start justify-center">
      <div className="card p-8 max-w-md w-full text-center">
        <Compass className="w-10 h-10 text-accent-400 mx-auto mb-3" />
        <h1 className="font-display text-2xl font-bold text-white mb-2">Page not found</h1>
        <p className="text-sm text-steel-400 mb-6 break-words">There's nothing at <code className="text-steel-200">{path}</code>.</p>
        <div className="flex flex-wrap justify-center gap-2">
          <button onClick={() => onNavigate({ name: 'dashboard' })} className="btn-primary text-sm">Go to my dashboard</button>
          <button onClick={() => onNavigate({ name: 'catalog' })} className="btn-secondary text-sm">Browse courses</button>
        </div>
      </div>
    </div>
  );
}
