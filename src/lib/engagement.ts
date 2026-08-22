import { useCallback, useEffect, useRef, useState } from 'react';
import { supabase } from '@/lib/supabase';

export interface EngagementState {
  seconds_viewed: number;
  required_seconds: number;
  content_opened: boolean;
  quiz_unlocked: boolean;
  engaged: boolean;
  relock_refresh_seconds: number;
}

const DEFAULT_STATE: EngagementState = {
  seconds_viewed: 0,
  required_seconds: 60,
  content_opened: false,
  quiz_unlocked: false,
  engaged: false,
  relock_refresh_seconds: 0,
};

const HEARTBEAT_INTERVAL_MS = 12000; // 12 seconds
const VISIBILITY_CHECK_INTERVAL_MS = 1000;

/**
 * Tracks lesson engagement via heartbeat pings to the server.
 * Increments seconds_viewed only while the content is visible and the tab is active.
 */
export function useLessonEngagement(
  lessonId: string | null,
  contentVisible: boolean,
  enabled: boolean,
) {
  const [engagement, setEngagement] = useState<EngagementState>(DEFAULT_STATE);
  const [loading, setLoading] = useState(true);
  const secondsAccumulator = useRef(0);
  const lastTickRef = useRef<number | null>(null);
  const tabVisibleRef = useRef(true);

  // Fetch initial engagement state
  const fetchEngagement = useCallback(async (lid: string) => {
    setLoading(true);
    try {
      const { data, error } = await supabase.rpc('get_lesson_engagement', {
        p_lesson_id: lid,
      });
      if (error) throw error;
      if (data) {
        setEngagement(data as EngagementState);
      } else {
        setEngagement(DEFAULT_STATE);
      }
    } catch {
      setEngagement(DEFAULT_STATE);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (lessonId && enabled) {
      void fetchEngagement(lessonId);
      secondsAccumulator.current = 0;
      lastTickRef.current = null;
    } else {
      setEngagement(DEFAULT_STATE);
      setLoading(false);
    }
  }, [lessonId, enabled, fetchEngagement]);

  // Track tab visibility
  useEffect(() => {
    function onVisibilityChange() {
      tabVisibleRef.current = !document.hidden;
      if (document.hidden) {
        lastTickRef.current = null; // pause timer when hidden
      }
    }
    document.addEventListener('visibilitychange', onVisibilityChange);
    return () => document.removeEventListener('visibilitychange', onVisibilityChange);
  }, []);

  // Heartbeat: accumulate seconds and ping server
  useEffect(() => {
    if (!lessonId || !enabled || !contentVisible) {
      lastTickRef.current = null;
      return;
    }

    const tickInterval = setInterval(() => {
      if (!tabVisibleRef.current || !contentVisible) {
        lastTickRef.current = null;
        return;
      }

      const now = Date.now();
      if (lastTickRef.current !== null) {
        const delta = Math.round((now - lastTickRef.current) / 1000);
        if (delta > 0 && delta < 30) {
          secondsAccumulator.current += delta;
        }
      }
      lastTickRef.current = now;
    }, VISIBILITY_CHECK_INTERVAL_MS);

    const heartbeatInterval = setInterval(async () => {
      if (!tabVisibleRef.current || !contentVisible) return;
      const toAdd = secondsAccumulator.current;
      if (toAdd <= 0) return;
      secondsAccumulator.current = 0;

      try {
        const { data, error } = await supabase.rpc('upsert_lesson_engagement', {
          p_lesson_id: lessonId,
          p_content_opened: true,
          p_seconds_to_add: toAdd,
        });
        if (error) return;
        if (data) {
          setEngagement(data as EngagementState);
        }
      } catch {
        // silently ignore — will retry next heartbeat
      }
    }, HEARTBEAT_INTERVAL_MS);

    return () => {
      clearInterval(tickInterval);
      clearInterval(heartbeatInterval);
    };
  }, [lessonId, enabled, contentVisible]);

  // Mark content as opened (immediate ping when content section becomes visible)
  const markContentOpened = useCallback(async (lid: string) => {
    try {
      const { data, error } = await supabase.rpc('upsert_lesson_engagement', {
        p_lesson_id: lid,
        p_content_opened: true,
        p_seconds_to_add: 0,
      });
      if (error) return;
      if (data) {
        setEngagement(data as EngagementState);
      }
    } catch {
      // ignore
    }
  }, []);

  // Re-lock quiz after a fail (client-side trigger)
  const relockQuiz = useCallback(async (lid: string) => {
    try {
      await supabase.rpc('relock_lesson_quiz', { p_lesson_id: lid });
      // Refresh engagement state
      await fetchEngagement(lid);
    } catch {
      // ignore
    }
  }, [fetchEngagement]);

  return { engagement, loading, markContentOpened, relockQuiz, fetchEngagement };
}
