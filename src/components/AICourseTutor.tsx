import { useEffect, useRef, useState } from 'react';
import {
  Sparkles,
  X,
  Send,
  Trash2,
  Lock,
  Loader2,
  MessageCircle,
} from 'lucide-react';
import { useAuth } from '@/lib/auth';
import { chatWithTutor, type ChatMessage, type CourseContext } from '@/lib/openai';
import type { Stage } from '@/lib/types';
import { STAGE_LABEL } from '@/lib/types';

interface AICourseTutorProps {
  courseTitle: string;
  stage: Stage;
  lessonTitle?: string | null;
  lessonContent?: string | null;
  onUpgrade?: () => void;
}

export function AICourseTutor({
  courseTitle,
  stage,
  lessonTitle,
  lessonContent,
  onUpgrade,
}: AICourseTutorProps) {
  const { isPremium, isAdmin, fullName } = useAuth();
  const canUseTutor = isPremium || isAdmin;
  const firstName = fullName?.split(' ')[0] ?? null;

  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);

  const lessonSummary =
    lessonContent && lessonContent.length > 0
      ? lessonContent.slice(0, 800)
      : null;

  const context: CourseContext = {
    courseTitle,
    stage: STAGE_LABEL[stage],
    lessonTitle: lessonTitle ?? null,
    lessonSummary,
    firstName,
  };

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages, loading]);

  useEffect(() => {
    if (open && canUseTutor) {
      setTimeout(() => inputRef.current?.focus(), 200);
    }
  }, [open, canUseTutor]);

  async function handleSend() {
    const text = input.trim();
    if (!text || loading || !canUseTutor) return;

    const userMsg: ChatMessage = { role: 'user', content: text };
    const newMessages = [...messages, userMsg];
    setMessages(newMessages);
    setInput('');
    setLoading(true);
    setError(null);

    try {
      const reply = await chatWithTutor(newMessages, context);
      setMessages([...newMessages, { role: 'assistant', content: reply }]);
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Failed to get a response.';
      setError(msg);
    } finally {
      setLoading(false);
    }
  }

  function handleClearChat() {
    setMessages([]);
    setError(null);
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLTextAreaElement>) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      void handleSend();
    }
  }

  return (
    <>
      {/* Floating button */}
      <button
        onClick={() => setOpen(true)}
        className={`fixed bottom-6 right-6 z-40 flex items-center gap-2 px-4 py-3 rounded-full bg-rok-500 text-white font-semibold shadow-rok-lg hover:bg-rok-400 transition-all duration-300 hover:scale-105 animate-pulse-rok ${
          open ? 'opacity-0 pointer-events-none' : 'opacity-100'
        }`}
        aria-label="Open AI Course Tutor"
      >
        <Sparkles className="w-5 h-5" />
        <span className="hidden sm:inline text-sm">AI Tutor</span>
      </button>

      {/* Slide-over panel */}
      {open && (
        <div className="fixed inset-0 z-[70] flex justify-end">
          {/* Backdrop */}
          <div
            className="absolute inset-0 bg-black/50 backdrop-blur-sm animate-fade-in"
            onClick={() => setOpen(false)}
          />

          {/* Panel */}
          <div className="relative w-full max-w-md h-full bg-navy-900 border-l border-steel-700/60 shadow-2xl flex flex-col animate-slide-in">
            {/* Header */}
            <div className="flex items-center justify-between gap-2 px-4 py-3.5 border-b border-steel-700/60 bg-navy-800/60">
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-9 h-9 rounded-lg bg-rok-500/20 flex items-center justify-center shrink-0">
                  <Sparkles className="w-5 h-5 text-rok-400" />
                </div>
                <div className="min-w-0">
                  <h3 className="font-display text-sm font-bold text-white">
                    AI Course Tutor
                  </h3>
                  <p className="text-[10px] text-steel-400 truncate">
                    {courseTitle}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-1 shrink-0">
                {canUseTutor && messages.length > 0 && (
                  <button
                    onClick={handleClearChat}
                    className="flex items-center gap-1.5 px-2.5 py-2 rounded-lg text-xs text-steel-400 hover:text-error-400 hover:bg-error-500/10 transition-colors"
                    title="Clear chat"
                  >
                    <Trash2 className="w-4 h-4" />
                    <span className="hidden sm:inline">Clear</span>
                  </button>
                )}
                <button
                  onClick={() => setOpen(false)}
                  className="flex items-center gap-1.5 px-3.5 py-2 rounded-lg text-sm font-bold text-white bg-rok-500 hover:bg-rok-400 transition-colors min-w-[48px] justify-center shadow-rok"
                  aria-label="Close tutor"
                >
                  <X className="w-5 h-5" />
                  <span>Done</span>
                </button>
              </div>
            </div>

            {/* Body */}
            {canUseTutor ? (
              <>
                {/* Context strip */}
                <div className="px-4 py-2.5 border-b border-steel-800/50 bg-navy-950/40">
                  <div className="flex flex-wrap items-center gap-1.5 text-[10px]">
                    <span className="px-2 py-0.5 rounded-full bg-rok-500/10 text-rok-300 border border-rok-500/20">
                      {STAGE_LABEL[stage]}
                    </span>
                    {lessonTitle && (
                      <span className="px-2 py-0.5 rounded-full bg-accent-500/10 text-accent-300 border border-accent-500/20 truncate max-w-[200px]">
                        {lessonTitle}
                      </span>
                    )}
                  </div>
                </div>

                {/* Messages */}
                <div
                  ref={scrollRef}
                  className="flex-1 overflow-y-auto px-4 py-4 space-y-3"
                >
                  {messages.length === 0 && (
                    <div className="flex flex-col items-center text-center py-10">
                      <div className="w-14 h-14 rounded-full bg-rok-500/15 flex items-center justify-center mb-4">
                        <MessageCircle className="w-7 h-7 text-rok-400" />
                      </div>
                      <p className="text-sm text-steel-300 font-medium mb-1">
                        Ask the AI Tutor anything
                      </p>
                      <p className="text-xs text-steel-500 max-w-[260px]">
                        I'm trained on this course's material. Ask about concepts,
                        troubleshooting, safety, or real-world applications.
                      </p>
                      <div className="mt-5 flex flex-col gap-2 w-full max-w-[280px]">
                        {[
                          `Explain the key concepts in "${lessonTitle ?? 'this lesson'}"`,
                          'What are common plant-floor mistakes here?',
                          'Give me a practical troubleshooting example',
                        ].map((s) => (
                          <button
                            key={s}
                            onClick={() => setInput(s)}
                            className="text-left text-xs text-steel-300 px-3 py-2 rounded-lg bg-navy-800/60 border border-steel-700/40 hover:border-rok-500/40 hover:text-rok-300 transition-colors"
                          >
                            {s}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}

                  {messages.map((msg, i) => (
                    <div
                      key={i}
                      className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
                    >
                      <div
                        className={`max-w-[85%] px-3.5 py-2.5 rounded-2xl text-sm leading-relaxed whitespace-pre-line ${
                          msg.role === 'user'
                            ? 'bg-rok-500/20 text-rok-50 border border-rok-500/30 rounded-br-md'
                            : 'bg-navy-800/80 text-steel-100 border border-steel-700/40 rounded-bl-md'
                        }`}
                      >
                        {msg.content}
                      </div>
                    </div>
                  ))}

                  {loading && (
                    <div className="flex justify-start">
                      <div className="bg-navy-800/80 border border-steel-700/40 rounded-2xl rounded-bl-md px-4 py-3">
                        <div className="flex items-center gap-1.5">
                          <span className="w-2 h-2 rounded-full bg-rok-400 animate-bounce" style={{ animationDelay: '0ms' }} />
                          <span className="w-2 h-2 rounded-full bg-rok-400 animate-bounce" style={{ animationDelay: '150ms' }} />
                          <span className="w-2 h-2 rounded-full bg-rok-400 animate-bounce" style={{ animationDelay: '300ms' }} />
                        </div>
                      </div>
                    </div>
                  )}

                  {error && (
                    <div className="text-xs text-error-400 bg-error-500/10 border border-error-500/30 rounded-lg px-3 py-2">
                      {error}
                    </div>
                  )}
                </div>

                {/* Input */}
                <div className="px-4 py-3 border-t border-steel-700/60 bg-navy-800/40">
                  <div className="flex items-end gap-2">
                    <textarea
                      ref={inputRef}
                      value={input}
                      onChange={(e) => setInput(e.target.value)}
                      onKeyDown={handleKeyDown}
                      placeholder="Ask about this lesson..."
                      rows={1}
                      className="flex-1 resize-none px-3.5 py-2.5 text-sm bg-navy-950/60 border border-steel-700 rounded-xl text-steel-100 placeholder-steel-500 focus:outline-none focus:border-rok-500 transition-colors max-h-32"
                      disabled={loading}
                    />
                    <button
                      onClick={handleSend}
                      disabled={!input.trim() || loading}
                      className="p-2.5 rounded-xl bg-rok-500 text-white hover:bg-rok-400 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                      aria-label="Send message"
                    >
                      <Send className="w-4 h-4" />
                    </button>
                  </div>
                  <p className="text-[10px] text-steel-600 mt-2 text-center">
                    AI can make mistakes. Always follow your site's safety procedures.
                  </p>
                  <button
                    onClick={() => setOpen(false)}
                    className="w-full mt-3 py-2.5 rounded-xl text-sm font-bold text-white bg-rok-500 hover:bg-rok-400 transition-colors shadow-rok"
                  >
                    Done
                  </button>
                </div>
              </>
            ) : (
              /* Locked state */
              <div className="flex-1 flex items-center justify-center px-6">
                <div className="text-center max-w-xs">
                  <div className="w-16 h-16 rounded-full bg-premium-500/15 flex items-center justify-center mx-auto mb-5">
                    <Lock className="w-8 h-8 text-premium-400" />
                  </div>
                  <h3 className="font-display text-lg font-bold text-white mb-2">
                    Premium Feature
                  </h3>
                  <p className="text-sm text-steel-400 mb-6">
                    Upgrade to Premium to unlock the AI Course Tutor — get instant,
                    plant-floor answers about any lesson from an experienced
                    industrial specialist.
                  </p>
                  <button
                    onClick={onUpgrade}
                    className="btn-premium w-full"
                  >
                    Upgrade to Premium
                  </button>
                  <button
                    onClick={() => setOpen(false)}
                    className="w-full mt-3 py-2.5 rounded-xl text-sm font-semibold text-steel-300 bg-navy-700/60 hover:bg-navy-700 hover:text-white transition-colors"
                  >
                    Maybe later
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </>
  );
}
