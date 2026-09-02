/** Fault-cluster phrases for meta keywords / JSON-LD. No invented long copy. */

export const COURSE_KEYWORDS: Record<string, string[]> = {
  // Electrical flagships / clusters
  'd944e6dd-5c67-4196-9943-8c3b18d962f7': ['motor megger', 'motor polarization index'],
  '79f10708-c531-41d9-813a-6e166836a274': ['VFD ground fault', 'VFD overcurrent vs ground fault'],
  'c6adddfe-deb2-489d-9b23-a3e15631cf44': ['VFD ground fault'],
  '3bbff1c9-5685-4e62-b8cb-4c6193dd0d02': ['chattering motor starter'],
  '5d8324bd-3f8c-4f5b-b841-9c7a5dcfe76f': ['industrial motor control troubleshooting'],
  '93213ae9-c1d8-46d2-b8d7-a14bc35c85a8': ['electrical prints', 'ladder diagrams'],

  // I&E premium — phrases only, not hero copy
  '9bc05085-a6e2-40ef-9056-afa3f273b2f4': ["control valve won't stroke"],
  '4f752341-8433-4d0f-bd90-fb3c4c9872b4': ['4-20 mA loop', '3.8 mA fail-low'],
  '3190e6c5-4dd9-49d5-b939-169f7b6cb34f': ['4-20 mA loop', '3.8 mA fail-low'],
  'db57e4a5-c723-4184-ba3c-9f1b59ddb3df': ['4-20 mA loop', '3.8 mA fail-low'],
  'cc2fd161-3adb-418a-8d19-6527c13205f5': ['4-20 mA loop', '3.8 mA fail-low'],
};

export function keywordsForCourse(courseId: string): string[] {
  return COURSE_KEYWORDS[(courseId || '').trim()] ?? [];
}
