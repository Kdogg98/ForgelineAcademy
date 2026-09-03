import {
  FLAGSHIP_BEARINGS_COURSE_ID,
  FLAGSHIP_ELECTRICAL_COURSE_ID,
} from '@/lib/seo/courseSlugs';

export const FLAGSHIP_VFD_FUNDAMENTALS_COURSE_ID = '79f10708-c531-41d9-813a-6e166836a274';
export const FLAGSHIP_STARTERS_COURSE_ID = '3bbff1c9-5685-4e62-b8cb-4c6193dd0d02';
export const VFD_INSTALL_COURSE_ID = 'c6adddfe-deb2-489d-9b23-a3e15631cf44';

export type FlagshipPath = 'mechanical' | 'electrical';

export type FlagshipStory = {
  courseId: string;
  eyebrow: string;
  dek: string;
  paragraphs: string[];
  bullets: string[];
  whoFor: string;
  whoNot: string;
  ctaPath: FlagshipPath;
  ctaLabel: string;
  metaTitle: string;
  metaDescription: string;
  jsonLdDescription: string;
  pathLabel: string;
  relatedCourseId?: string;
  relatedLabel?: string;
  showGames?: boolean;
};

export const FLAGSHIP_STORIES: Record<string, FlagshipStory> = {
  [FLAGSHIP_BEARINGS_COURSE_ID]: {
    courseId: FLAGSHIP_BEARINGS_COURSE_ID,
    eyebrow: 'Mechanical · Free · Plant-floor lesson',
    dek: 'Most “bearing failures” on the plant floor are lubrication or alignment. This is the procedure millwrights actually run before they pull a housing.',
    paragraphs: [
      'The motor runs hot. The pump eats seals. The fan walks the base. The work order still says “bad bearing.”',
      'Most of the time the steel is telling you something else: lubrication did not match the duty, or the shafts were never aligned well enough to leave alone. This is the procedure millwrights actually run before they pull a housing — not an SKF catalog, not VR, not an apprenticeship. First step on the Mechanical path. Free.',
    ],
    bullets: [
      'What the bearing is telling you',
      'Lubrication matching the bearing',
      'Alignment you can defend',
      'Millwright vs electrical — who owns which call',
    ],
    whoFor: 'Millwrights, maintenance mechanics, and techs who get “replace the bearing” jobs and want the plant-floor sequence first.',
    whoNot: 'Anyone looking for a license, an ISA or NFPA 70E qualification, a catalog dump, or VR. Certificates of completion after quizzes go in the file. They are not a license.',
    ctaPath: 'mechanical',
    ctaLabel: 'Start the free Mechanical path',
    metaTitle: 'Bearings, Lubrication & Alignment | ForgeLine',
    metaDescription:
      'Plant-floor bearings, lubrication, and shaft alignment. First free Mechanical course for millwrights and maintenance techs. Not generic theory.',
    jsonLdDescription:
      'Plant-floor bearings, lubrication, and shaft alignment. First free Mechanical course for millwrights and maintenance techs. Not generic theory.',
    pathLabel: 'Mechanical path',
    showGames: true,
  },
  [FLAGSHIP_ELECTRICAL_COURSE_ID]: {
    courseId: FLAGSHIP_ELECTRICAL_COURSE_ID,
    eyebrow: 'Electrical · Free · Plant-floor lesson',
    dek: 'A one-minute megger reading is how plants fake a pass. This is the test we actually run, and the log that holds up in a meeting.',
    paragraphs: [
      'Most “the motor meggered fine” notes are a 15-second poke at 500 V with wet leads. That is not a Polarization Index.',
      'This is the test industrial electricians actually run — not an NFPA 70E credential, not a megger sales pitch. First step on the Electrical path. Free.',
    ],
    bullets: [
      'MΩ at 500 / 1000 / 5000 V',
      'PI: the 10-minute vs 1-minute lie',
      'Discharge, connections, humidity, hot winding',
      'Honest plant pass/fail',
      'What to write on the job',
    ],
    whoFor: 'Industrial electricians, I&E techs, and supervisors who have to read the log.',
    whoNot: 'Residential work, HVAC, or job listings. Certificates of completion after quizzes go in the file. They are not a license.',
    ctaPath: 'electrical',
    ctaLabel: 'Start the free Electrical path',
    metaTitle: 'Motor Megger & PI Testing | ForgeLine',
    metaDescription:
      'Plant-floor megger and polarization index. The test, the voltages, the log. Free Electrical course. Not a 15-second poke.',
    jsonLdDescription:
      'Plant-floor megger and polarization index. The test, the voltages, the log. Free Electrical course. Not a 15-second poke.',
    pathLabel: 'Electrical path',
  },
  [FLAGSHIP_VFD_FUNDAMENTALS_COURSE_ID]: {
    courseId: FLAGSHIP_VFD_FUNDAMENTALS_COURSE_ID,
    eyebrow: 'Electrical · Free · Plant-floor lesson',
    dek: 'An overcurrent trip and a ground fault are not the same problem. The drive will lie to you if you treat them like they are.',
    paragraphs: [
      'OC is usually mechanical or a short ramp. GF is insulation, cable, or a wet motor. Reset-and-hope takes a feeder.',
    ],
    bullets: [
      'What the drive measures: OC vs GF',
      'Motor data, accel, bind',
      'Insulation, cable, wet winding',
      'Parameterization for THIS motor',
    ],
    whoFor: 'Electricians and techs when the VFD is flashing.',
    whoNot: 'HVAC drive sales, or “VFD jobs near me.” Certificates of completion after quizzes go in the file. They are not a license.',
    ctaPath: 'electrical',
    ctaLabel: 'Start the free Electrical path',
    metaTitle: 'VFD Ground Fault vs Overcurrent | ForgeLine',
    metaDescription:
      'OC trip is not a ground fault. Plant-floor VFD fundamentals and parameterization. Free Electrical course.',
    jsonLdDescription:
      'OC trip is not a ground fault. Plant-floor VFD fundamentals and parameterization. Free Electrical course.',
    pathLabel: 'Electrical path',
    relatedCourseId: VFD_INSTALL_COURSE_ID,
    relatedLabel: 'Cable, dV/dt, and long leads: VFD Installation & Commissioning',
  },
  [FLAGSHIP_STARTERS_COURSE_ID]: {
    courseId: FLAGSHIP_STARTERS_COURSE_ID,
    eyebrow: 'Electrical · Free · Plant-floor lesson',
    dek: 'A chattering starter is a coil, an overlay, or voltage. It is not “replace the bucket and hope.”',
    paragraphs: [
      'Chatter is the magnet pulling in and out. It is not a welded contact.',
    ],
    bullets: [
      'Chatter vs welded',
      'Coil voltage under load',
      'Overlay / seal-in bounce',
      'Loose CPT, 24 V, dirty interlock',
      'Heater class / overload after lunch',
      'When it is mechanical, hand it to the millwright',
    ],
    whoFor: 'Industrial electricians working MCC buckets.',
    whoNot: 'Residential work, HVAC capacitors, or job listings. Certificates of completion after quizzes go in the file. They are not a license.',
    ctaPath: 'electrical',
    ctaLabel: 'Start the free Electrical path',
    metaTitle: 'Chattering Motor Starter | ForgeLine',
    metaDescription:
      'Coil, overlay, or voltage. Plant-floor starters, contactors, and overloads. Free Electrical course.',
    jsonLdDescription:
      'Coil, overlay, or voltage. Plant-floor starters, contactors, and overloads. Free Electrical course.',
    pathLabel: 'Electrical path',
  },
};

export function getFlagshipStory(courseId: string): FlagshipStory | undefined {
  return FLAGSHIP_STORIES[(courseId || '').trim()];
}
