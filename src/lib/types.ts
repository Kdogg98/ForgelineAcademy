export type Stage = 'mechanical' | 'electrical' | 'ie' | 'engineering';
export type Tier = 'free' | 'premium';
export type Difficulty = 'beginner' | 'intermediate' | 'advanced';

export interface Course {
  id: string;
  title: string;
  description: string;
  short_description: string;
  stage: Stage;
  tier: Tier;
  difficulty: Difficulty;
  estimated_hours: number;
  sort_order: number;
  created_at: string;
  is_custom?: boolean;
  assigned_user_id?: string | null;
}

export interface Module {
  id: string;
  course_id: string;
  title: string;
  sort_order: number;
  video_url: string | null;
  video_filename: string | null;
  video_uploaded_at: string | null;
}

export interface QuizQuestion {
  question: string;
  options: string[];
  correctIndex: number;
}

export interface Lesson {
  id: string;
  module_id: string;
  title: string;
  content: string | null;
  estimated_minutes: number;
  has_video: boolean;
  has_pdf: boolean;
  quiz: QuizQuestion[];
  pass_threshold: number;
  sort_order: number;
  video_url: string | null;
  video_filename: string | null;
  video_uploaded_at: string | null;
}

export interface LessonWithModule extends Lesson {
  module_title: string;
  module_sort_order: number;
}

export interface UserProgress {
  id: string;
  user_id: string;
  lesson_id: string;
  course_id: string;
  quiz_score: number | null;
  completed: boolean;
  completed_at: string | null;
}

export interface Certificate {
  id: string;
  user_id: string;
  course_id: string;
  certificate_number: string;
  issued_at: string;
  course?: Course;
}

export interface StageInfo {
  key: Stage;
  label: string;
  tier: Tier;
  tagline: string;
  description: string;
}

export const STAGES: StageInfo[] = [
  {
    key: 'mechanical',
    label: 'Mechanical Maintenance',
    tier: 'free',
    tagline: 'Rotating equipment, fluid power, precision measurement',
    description: 'Foundations every maintenance tech needs: bearings, pumps, drives, hydraulics, and alignment.',
  },
  {
    key: 'electrical',
    label: 'Electrical Maintenance',
    tier: 'free',
    tagline: 'Motor control, power systems, VFDs, safety',
    description: 'Industrial electrical from line diagrams to arc flash — the core of plant electrical work.',
  },
  {
    key: 'ie',
    label: 'I&E — Instrumentation & Electrical',
    tier: 'premium',
    tagline: 'Smart instrumentation, control valves, DCS, loop tuning',
    description: 'The bridge between electrical and process control: transmitters, valves, DCS, and advanced tuning.',
  },
  {
    key: 'engineering',
    label: 'Engineering / Advanced Controls',
    tier: 'premium',
    tagline: 'PLC architecture, reliability, motion, functional safety',
    description: 'Systems-level engineering: PLC best practices, network design, reliability strategy, and safety.',
  },
];

export const STAGE_LABEL: Record<Stage, string> = {
  mechanical: 'Mechanical',
  electrical: 'Electrical',
  ie: 'I&E',
  engineering: 'Engineering',
};

export function stageLabel(s: Stage): string {
  return STAGE_LABEL[s] ?? s;
}

export function difficultyLabel(d: Difficulty): string {
  return d.charAt(0).toUpperCase() + d.slice(1);
}

export interface Company {
  id: string;
  name: string;
  logo_url: string | null;
  premium: boolean;
  active: boolean;
  created_by: string | null;
  created_at: string;
}

export interface CompanyMember {
  id: string;
  company_id: string;
  user_id: string;
  role: 'owner' | 'admin' | 'member';
  created_at: string;
  email?: string;
  full_name?: string | null;
}

export interface QuizLockState {
  failed_in_cycle: number;
  locked: boolean;
  updated_at: string;
}

export interface EngagementState {
  seconds_viewed: number;
  required_seconds: number;
  content_opened: boolean;
  quiz_unlocked: boolean;
  engaged: boolean;
  relock_refresh_seconds: number;
}

export interface RetakeRequest {
  id: string;
  user_id: string;
  lesson_id: string;
  course_id: string;
  status: 'pending' | 'approved' | 'denied';
  failed_attempt_count: number;
  requested_at: string;
  reviewed_at: string | null;
  note: string | null;
  member_email: string | null;
  member_name: string | null;
  lesson_title: string | null;
  course_title: string | null;
  total_attempts: number;
  last_score: number | null;
}

export interface MemberQuizAttempt {
  lesson_id: string;
  course_id: string;
  lesson_title: string | null;
  course_title: string | null;
  total_attempts: number;
  failed_count: number;
  passed: boolean;
  best_score: number | null;
  latest_score: number | null;
  last_attempt_at: string | null;
  lock_status: boolean;
  failed_in_cycle: number;
}

export interface AvailabilitySlot {
  id: string;
  start_time: string;
  end_time: string;
  is_booked: boolean;
  created_at: string;
}

export interface Booking {
  id: string;
  slot_id: string;
  name: string;
  email: string;
  topic: string;
  meet_link: string | null;
  status: 'pending' | 'confirmed' | 'cancelled';
  created_at: string;
  slot?: AvailabilitySlot;
}
