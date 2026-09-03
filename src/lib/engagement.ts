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
const MAX_SECONDS_PER_HEARTBEAT = 10;

/**
 * Tracks lesson engagement via heartbeat pings to the server.
 * Increments time while the lesson is active and the browser tab is visible.
 * UI seconds_viewed is optimistic: server seconds + unsynced local accumulator.
 * Unlock still comes from upsert_lesson_engagement on the server.
 */
export function useLessonEngagement(
  lessonId: string | null,
  contentVisible: boolean,
  enabled: boolean,
) {
  const [engagement, setEngagement] = useState<EngagementState>(DEFAULT_STATE);
  const [loading, setLoading] = useState(true);
  const secondsAccumulator = useRef(0);
  const serverSecondsRef = useRef(0);
  const lastTickRef = useRef<number | null>(null);
  const tabVisibleRef = useRef(typeof document !== 'undefined' ? !document.hidden : true);

  const applyServerState = useCallback((data: EngagementState) => {
    serverSecondsRef.current = data.seconds_viewed;
    setEngagement({
      ...data,
      seconds_viewed: data.seconds_viewed + secondsAccumulator.current,
    });
  }, []);

  // Fetch initial engagement state
  const fetchEngagement = useCallback(async (lid: string) => {
    setLoading(true);
    try {
      const { data, error } = await supabase.rpc('get_lesson_engagement', {
        p_lesson_id: lid,
      });
      if (error) throw error;
      if (data) {
        applyServerState(data as EngagementState);
      } else {
        serverSecondsRef.current = 0;
        setEngagement(DEFAULT_STATE);
      }
    } catch {
      serverSecondsRef.current = 0;
      setEngagement(DEFAULT_STATE);
    } finally {
      setLoading(false);
    }
  }, [applyServerState]);

  useEffect(() => {
    if (lessonId && enabled) {
      void fetchEngagement(lessonId);
      secondsAccumulator.current = 0;
      lastTickRef.current = null;
    } else {
      setEngagement(DEFAULT_STATE);
      setLoading(false);
      secondsAccumulator.current = 0;
      serverSecondsRef.current = 0;
      lastTickRef.current = null;
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
    tabVisibleRef.current = !document.hidden;
    document.addEventListener('visibilitychange', onVisibilityChange);
    return () => document.removeEventListener('visibilitychange', onVisibilityChange);
  }, []);

  // Heartbeat: accumulate seconds while enabled + tab visible, ping server
  useEffect(() => {
    if (!lessonId || !enabled || !contentVisible) {
      lastTickRef.current = null;
      return;
    }

    const tickInterval = setInterval(() => {
      if (!tabVisibleRef.current) {
        lastTickRef.current = null;
        return;
      }

      const now = Date.now();
      if (lastTickRef.current !== null) {
        const delta = Math.round((now - lastTickRef.current) / 1000);
        if (delta > 0 && delta < 30) {
          secondsAccumulator.current += delta;
          setEngagement((prev) => ({
            ...prev,
            seconds_viewed: serverSecondsRef.current + secondsAccumulator.current,
          }));
        }
      }
      lastTickRef.current = now;
    }, VISIBILITY_CHECK_INTERVAL_MS);

    const heartbeatInterval = setInterval(async () => {
      if (!tabVisibleRef.current) return;
      const toAdd = Math.min(secondsAccumulator.current, MAX_SECONDS_PER_HEARTBEAT);
      if (toAdd <= 0) return;
      secondsAccumulator.current -= toAdd;

      try {
        const { data, error } = await supabase.rpc('upsert_lesson_engagement', {
          p_lesson_id: lessonId,
          p_content_opened: true,
          p_seconds_to_add: toAdd,
        });
        if (error) {
          secondsAccumulator.current += toAdd;
          return;
        }
        if (data) {
          applyServerState(data as EngagementState);
        }
      } catch {
        secondsAccumulator.current += toAdd;
        // silently ignore — will retry next heartbeat
      }
    }, HEARTBEAT_INTERVAL_MS);

    return () => {
      clearInterval(tickInterval);
      clearInterval(heartbeatInterval);
    };
  }, [lessonId, enabled, contentVisible, applyServerState]);

  // Mark content as opened (immediate ping when a lesson is selected)
  const markContentOpened = useCallback(async (lid: string) => {
    try {
      const { data, error } = await supabase.rpc('upsert_lesson_engagement', {
        p_lesson_id: lid,
        p_content_opened: true,
        p_seconds_to_add: 0,
      });
      if (error) return;
      if (data) {
        applyServerState(data as EngagementState);
      }
    } catch {
      // ignore
    }
  }, [applyServerState]);

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
