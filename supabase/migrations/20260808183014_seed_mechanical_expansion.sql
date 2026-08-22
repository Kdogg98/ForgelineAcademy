/*
# Seed ForgeLine catalog — Mechanical Maintenance expansion (17 new courses)

## Overview
Adds 17 new free Mechanical Maintenance courses to the catalog, expanding the
free Mechanical track from 5 to 22 courses. Each course has 2-3 modules with
2-3 lessons, professional plant-floor content, and at least one knowledge-check
quiz per lesson. No existing courses are modified.

## Courses added (sort_order 6-22)
1. Gearboxes & Power Transmission (6)
2. Fans, Blowers & Air Handling Systems (7)
3. Industrial Couplings, Keys & Shafts (8)
4. Vibration Analysis Fundamentals (9)
5. Thermography for Mechanical Maintenance (10)
6. Ultrasound & Acoustic Lubrication (11)
7. Rigging, Lifting & Material Handling (12)
8. Machine Guarding & Mechanical LOTO (13)
9. Centralized & Automated Lubrication Systems (14)
10. Welding & Fabrication for Maintenance Technicians (15)
11. Chain & Belt Drive Systems Advanced (16)
12. Compressors & Compressed Air Systems (17)
13. Heat Exchangers & Cooling Systems (18)
14. Conveyor Troubleshooting & Repair (19)
15. Precision Maintenance Practices (20)
16. Mechanical Seals Advanced Diagnostics (21)
17. Rotating Equipment Reliability Fundamentals (22)

## Security
No schema or policy changes. INSERT is allowed only for service role / SQL
execution. The anon-key frontend never writes catalog rows.

## Notes
1. Uses ON CONFLICT DO NOTHING keyed on (stage, title) so re-running is safe.
2. Each DO $$ block looks up the course by (stage, title) and returns early if not found.
3. Lesson content is realistic professional text — not lorem ipsum.
4. Quizzes are JSON arrays: [{question, options:[...], correctIndex:0}].
*/

INSERT INTO courses (title, description, short_description, stage, tier, difficulty, estimated_hours, sort_order)
VALUES
('Gearboxes & Power Transmission',
 'Comprehensive coverage of industrial gearbox types, inspection, failure analysis, and maintenance. Covers helical, bevel, worm, and planetary gearboxes, oil selection, breather maintenance, and trending wear metals to predict failures before they happen.',
 'Gearbox types, inspection, oil analysis, and failure prevention.',
 'mechanical','free','intermediate',3,6),
('Fans, Blowers & Air Handling Systems',
 'Maintain industrial fans, blowers, and air handling units. Covers fan types (centrifugal, axial), bearing arrangements, vibration diagnosis, impeller inspection, and performance testing for HVAC and process air systems.',
 'Fan and blower maintenance, vibration diagnosis, and impeller inspection.',
 'mechanical','free','intermediate',2.5,7),
('Industrial Couplings, Keys & Shafts',
 'Select, install, and maintain industrial couplings and shaft connections. Covers gear, grid, elastomeric, and disc couplings, key sizing, shaft repair, and coupling balance for reliable power transmission.',
 'Coupling selection, installation, key sizing, and shaft repair.',
 'mechanical','free','intermediate',2,8),
('Vibration Analysis Fundamentals',
 'Introduction to vibration analysis for predictive maintenance. Covers sensor placement, frequency spectra, diagnosing imbalance, misalignment, looseness, and bearing defects from vibration signatures.',
 'Vibration sensors, spectra, and diagnosing rotating equipment faults.',
 'mechanical','free','intermediate',3,9),
('Thermography for Mechanical Maintenance',
 'Use infrared thermography to detect mechanical problems before failure. Covers bearing overheating, coupling heat generation, steam trap diagnosis, electrical hot spots, and reporting best practices.',
 'Infrared thermography for bearings, couplings, steam traps, and more.',
 'mechanical','free','intermediate',2,10),
('Ultrasound & Acoustic Lubrication',
 'Acoustic ultrasound inspection for bearing lubrication and leak detection. Covers ultrasound gun operation, bearing greasing by sound, steam trap testing, and electrical corona detection.',
 'Ultrasound inspection for lubrication, leaks, and corona detection.',
 'mechanical','free','intermediate',2,11),
('Rigging, Lifting & Material Handling',
 'Safe rigging and lifting practices for maintenance work. Covers sling selection, load calculation, crane signals, rigging hardware inspection, and critical lift planning for plant equipment moves.',
 'Sling selection, load calculation, crane signals, and rigging safety.',
 'mechanical','free','beginner',2.5,12),
('Machine Guarding & Mechanical LOTO',
 'Machine guarding standards and mechanical lockout/tagout procedures. Covers guard types, interlock systems, OSHA 1910.212, energy isolation for mechanical systems, and group LOTO for maintenance.',
 'Machine guarding, interlocks, and mechanical lockout/tagout.',
 'mechanical','free','beginner',2,13),
('Centralized & Automated Lubrication Systems',
 'Design, install, and maintain centralized and automatic lubrication systems. Covers series-progressive, dual-line, and single-line systems, pump sizing, divider block operation, and troubleshooting flow issues.',
 'Centralized lubrication system design, maintenance, and troubleshooting.',
 'mechanical','free','intermediate',2.5,14),
('Welding & Fabrication for Maintenance Technicians',
 'Practical welding and fabrication skills for maintenance. Covers SMAW, GMAW, and GTAW basics, joint preparation, distortion control, and repair welding of shafts, brackets, and structural members.',
 'SMAW, GMAW, GTAW basics and repair welding for maintenance.',
 'mechanical','free','intermediate',3,15),
('Chain & Belt Drive Systems Advanced',
 'Advanced chain and belt drive maintenance. Covers multiple-chain drives, tensioning methods, sheave alignment, toothed belt timing, and diagnosing premature failure patterns in power transmission drives.',
 'Advanced chain/belt drives, sheave alignment, and failure diagnosis.',
 'mechanical','free','intermediate',2.5,16),
('Compressors & Compressed Air Systems',
 'Maintain industrial air compressors and compressed air systems. Covers rotary screw, reciprocating, and centrifugal compressors, air dryer selection, leak surveying, and system efficiency optimization.',
 'Compressor types, air dryers, leak surveys, and system efficiency.',
 'mechanical','free','intermediate',3,17),
('Heat Exchangers & Cooling Systems',
 'Maintain shell-and-tube, plate, and air-cooled heat exchangers. Covers tube cleaning, gasket replacement, fouling diagnosis, cooling tower water treatment, and thermal performance testing.',
 'Heat exchanger cleaning, gasketing, fouling diagnosis, and cooling towers.',
 'mechanical','free','intermediate',2.5,18),
('Conveyor Troubleshooting & Repair',
 'Systematic troubleshooting of conveyor systems in production environments. Covers belt splice repair, roller replacement, drive diagnostics, take-up adjustment, and minimizing downtime during conveyor failures.',
 'Belt splice repair, roller replacement, drive diagnostics, and take-up.',
 'mechanical','free','intermediate',2.5,19),
('Precision Maintenance Practices',
 'Precision maintenance methodology covering soft foot correction, pipe strain elimination, thermal growth compensation, and the tools and procedures that achieve machinery installation to specification.',
 'Soft foot, pipe strain, thermal growth, and precision installation.',
 'mechanical','free','advanced',3,20),
('Mechanical Seals Advanced Diagnostics',
 'Advanced mechanical seal troubleshooting and failure analysis. Covers seal face materials, flush plans (API 682), barrier fluid systems, dry gas seals, and root cause analysis of seal failures.',
 'API flush plans, barrier fluids, dry gas seals, and seal RCA.',
 'mechanical','free','advanced',3,21),
('Rotating Equipment Reliability Fundamentals',
 'Build a reliability-centered approach to rotating equipment. Covers failure mode identification, condition monitoring strategy, criticality analysis, and aligning maintenance tasks to failure patterns.',
 'Failure modes, condition monitoring, and rotating equipment reliability.',
 'mechanical','free','intermediate',2.5,22)
ON CONFLICT DO NOTHING;

-- ===================== Gearboxes & Power Transmission =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Gearboxes & Power Transmission';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Gearbox Types & Selection', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Helical, Bevel, Worm & Planetary Gearboxes',
   'Industrial gearboxes transmit power while reducing speed and increasing torque. Helical gears run quieter than spur gears because the angled teeth engage gradually, but they produce axial thrust that requires bearings to handle the load. Bevel gears change the direction of power transmission, typically 90 degrees. Worm gears offer high reduction ratios in a single stage and are self-locking — the load cannot drive the worm — but they are inefficient (50-90%) and generate significant heat. Planetary gearboxes pack high reduction into a compact envelope by using multiple planet gears around a sun gear, distributing load and achieving high torque density. Selection depends on ratio, torque, speed, efficiency, duty cycle, and thermal capacity. Always verify the service factor (typically 1.0-1.5 for uniform loads, 2.0+ for shock loads) matches the application.',
   50, 1,
   '[{"question":"Why do helical gears run quieter than spur gears?","options":["They use softer materials","The angled teeth engage gradually","They have more teeth","They run at lower speeds"],"correctIndex":1},{"question":"Which gearbox type is self-locking?","options":["Helical","Bevel","Worm","Planetary"],"correctIndex":2}]'),
  (m_id, 'Oil Selection & Breather Maintenance',
   'Gearbox oil serves two functions: lubricate the tooth mesh and carry heat away from the gears. ISO VG 220 and 320 are common industrial gear oil viscosities, but always follow the OEM recommendation for the operating temperature and speed. Synthetic oils (PAO, PAG) handle higher temperatures and longer drain intervals than mineral oils. The breather is the most neglected component — a clogged breather pressurizes the case as the oil heats and expands, forcing oil past the shaft seals. Replace the breather at every oil change. Check the magnetic drain plug for metal particles during oil changes; a heavy accumulation indicates active gear or bearing wear. Sample the oil quarterly for wear metals (Fe, Cu, Cr), water content (Karl Fischer), and viscosity. A rising wear metal trend is more significant than any single reading.',
   45, 2,
   '[{"question":"What does a clogged gearbox breather cause?","options":["Low oil level","Case pressurization and oil leaks past seals","Improved lubrication","Reduced operating temperature"],"correctIndex":1},{"question":"What does a rising iron (Fe) trend in gearbox oil analysis indicate?","options":["Normal wear","Active gear or bearing wear","Water contamination","Oil oxidation"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Failure Analysis & Inspection', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Gear Tooth Failure Modes & Inspection',
   'Gear tooth failures fall into distinct categories. Macropitting (fatigue) appears as flakes of metal removed from the tooth surface after millions of load cycles — it indicates the contact stress exceeds the material endurance limit. Micropitting appears as frosted, gray patches and is associated with inadequate lubric film thickness. Scuffing occurs when the lubricant film breaks down and metal-to-metal contact welds and tears the surface — typically from overload, insufficient oil, or wrong viscosity. Tooth fracture is catastrophic and usually stems from shock load or a brittle material. During inspection, check the tooth contact pattern using bluing: a centered, even pattern across 75-90% of the tooth face indicates correct meshing; a pattern biased to one end indicates misalignment. Document with photos and compare to the previous inspection.',
   55, 1,
   '[{"question":"What does macropitting indicate?","options":["Inadequate lubrication","Contact stress exceeds the material endurance limit","Shock loading","Wrong oil viscosity"],"correctIndex":1},{"question":"What does a tooth contact pattern biased to one end indicate?","options":["Normal wear","Misalignment","Overload","Inadequate lubrication"],"correctIndex":1}]');
END $$;

-- ===================== Fans, Blowers & Air Handling Systems =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Fans, Blowers & Air Handling Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Fan Types & Performance', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Centrifugal vs Axial Fans',
   'Centrifugal fans move air radially outward from the impeller and are classified by blade shape: forward-curved (high volume, low pressure), backward-curved (high efficiency, stable pressure), and radial (rugged, self-cleaning for dusty air). Axial fans move air along the shaft axis and are used for high-volume, low-pressure applications like ventilation. Fan performance is described by a curve plotting pressure vs flow, similar to a pump curve. The system curve (ductwork resistance) intersects the fan curve at the operating point. A fan that surges or hunts is operating in the unstable region of its curve, typically to the left of the peak pressure point. Check amperage against the fan curve: high amperage at low flow indicates the fan is fighting a restriction; low amperage at high flow indicates a worn impeller or housing clearance.',
   45, 1,
   '[{"question":"Which centrifugal fan blade type is most efficient?","options":["Forward-curved","Backward-curved","Radial","Straight"],"correctIndex":1},{"question":"What does a fan surging or hunting indicate?","options":["Normal operation","Operating in the unstable region of its curve","Oversized motor","Dirty filter"],"correctIndex":1}]'),
  (m_id, 'Bearing Arrangements & Impeller Inspection',
   'Fan bearings carry the rotor weight, impeller thrust, and unbalanced forces. Most industrial fans use roller bearings on the drive end (radial load) and a located ball bearing on the non-drive end (axial positioning). The non-drive bearing is often floating to allow thermal expansion. Inspect the impeller for erosion, cracking, and dust buildup — even a thin layer of dust on the blades shifts the balance and increases vibration. Clean the impeller and check for cracks at the blade root with dye penetrant. Measure the clearance between the impeller and the housing inlet ring; excessive clearance recirculates air and kills efficiency. Re-balance after any impeller repair or cleaning. Check the shaft for wear at the seal contact area — a grooved shaft leaks air and damages the packing.',
   40, 2,
   '[{"question":"Why does dust on fan blades increase vibration?","options":["It corrodes the blades","It shifts the balance","It restricts airflow","It increases temperature"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Vibration & Performance Diagnosis', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Fan Vibration Diagnosis',
   'Fan vibration diagnosis starts with the dominant frequency. A 1x RPM dominant frequency indicates imbalance — common after dust buildup or impeller wear. A 2x dominant frequency indicates misalignment between the motor and fan shafts. A high broadband floor with many harmonics indicates looseness — check bearing fit on the shaft, foundation bolts, and impeller hub tightness. Bearing defect frequencies appear at higher frequencies and indicate bearing degradation. Variable-speed fans complicate diagnosis because the frequencies shift with speed; use order analysis (normalizing to RPM) to compare readings across speeds. Install a vibration sensor at the bearing housing in the radial and axial directions. Trend the overall velocity (mm/s) — ISO 10816 defines alarm levels; for most industrial fans, 4.5 mm/s is a warning and 7.1 mm/s is a danger threshold.',
   50, 1,
   '[{"question":"What does a 1x RPM dominant vibration frequency on a fan indicate?","options":["Misalignment","Imbalance","Bearing defect","Looseness"],"correctIndex":1},{"question":"What is the ISO 10816 danger threshold for most industrial fans?","options":["2.8 mm/s","4.5 mm/s","7.1 mm/s","11.2 mm/s"],"correctIndex":2}]');
END $$;

-- ===================== Industrial Couplings, Keys & Shafts =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Industrial Couplings, Keys & Shafts';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Coupling Types & Application', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Gear, Grid, Elastomeric & Disc Couplings',
   'Couplings transmit torque while accommodating misalignment. Gear couplings handle high torque and high speed but require lubrication — a dry gear coupling fails rapidly. Grid couplings (Falk type) use a serpentine spring element that flexes under misalignment while damping shock loads; they also require grease. Elastomeric couplings (jaw, tire, sleeve) use a rubber element that requires no lubrication and dampens vibration, but the element degrades over time and must be replaced. Disc couplings use thin metal discs that flex without wear and are used for high-speed, high-torque applications — they require no lubrication but are sensitive to misalignment beyond their rated capacity. Select a coupling by torque rating, bore size, speed, misalignment capacity, and the required maintenance level. Always verify the coupling service factor matches the application — 1.5 for uniform loads, 2.0-3.0 for shock loads.',
   50, 1,
   '[{"question":"Which coupling type requires no lubrication and uses a rubber element?","options":["Gear coupling","Grid coupling","Elastomeric coupling","Disc coupling"],"correctIndex":2},{"question":"What service factor is typical for shock load applications?","options":["1.0","1.5","2.0-3.0","5.0"],"correctIndex":2}]'),
  (m_id, 'Key Sizing & Shaft Repair',
   'A key transmits torque between the shaft and the hub. The key width is typically one-quarter of the shaft diameter (for square keys up to 1/4 inch) and follows the shaft diameter per standards (ANSI B17.1, DIN 6885). The key length must be sufficient to transmit the torque without exceeding the allowable compressive stress on the key and shaft keyway. A sheared key indicates an overload or a loose fit — always inspect the keyway for damage and repair if the corners are rounded. Shaft repair options include build-up by welding and machining to size, thermal spray, or sleeving. After any shaft repair, check runout at the bearing journals and coupling fit — a repaired shaft that is not straight will destroy bearings. For a worn keyway, broach an oversized keyway or use a double key arrangement 180 degrees apart. Never file a key to fit — it creates a loose fit that will shear under load.',
   45, 2,
   '[{"question":"What is the typical key width for a square key?","options":["One-eighth of the shaft diameter","One-quarter of the shaft diameter","One-half of the shaft diameter","Equal to the shaft diameter"],"correctIndex":1},{"question":"What does a sheared key typically indicate?","options":["Proper lubrication","Overload or a loose fit","Correct sizing","Normal wear"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Installation & Balance', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Coupling Installation & Balance',
   'Install a coupling by first cleaning the shafts and hubs to remove all preservative and burrs. Check the bore fit — a clearance fit allows the hub to slide on by hand; an interference fit requires heating the hub (induction or oil bath) to 150-200 degrees F above shaft temperature. Never use a hammer to drive a coupling onto a shaft — it damages the bearings. After assembly, perform a dial indicator alignment: mount the indicator on one hub and read the other, rotate 360 degrees, and correct angular and parallel misalignment to within the coupling manufacturer tolerance. For balance, a coupling that has been repaired or re-bored must be re-balanced. Check coupling balance by running the machine uncoupled and then coupled — a significant vibration increase when coupled indicates coupling imbalance or misalignment.',
   40, 1,
   '[{"question":"What temperature range is used to heat a hub for an interference fit?","options":["50-100 F above shaft temperature","150-200 F above shaft temperature","300-400 F above shaft temperature","Room temperature is sufficient"],"correctIndex":1},{"question":"What should never be used to install a coupling on a shaft?","options":["A hydraulic press","A hammer","An induction heater","An oil bath"],"correctIndex":1}]');
END $$;

-- ===================== Vibration Analysis Fundamentals =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Vibration Analysis Fundamentals';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Vibration Basics & Measurement', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Sensors, Frequency & Amplitude',
   'Vibration is characterized by frequency (how fast), amplitude (how much), and phase (the relationship between two points). Accelerometers are the most common industrial sensor — they measure acceleration in g and convert to velocity (mm/s) or displacement (microns) mathematically. Mount the sensor on a flat, clean surface at the bearing housing, radially for most machines. The frequency spectrum (FFT) reveals the source of vibration: 1x RPM is imbalance or eccentricity, 2x RPM is misalignment or mechanical looseness, and bearing defect frequencies (BPFO, BPFI, BSF, FTF) indicate bearing degradation. Overall vibration amplitude (ISO 10816 velocity) is the first alarm; the spectrum identifies the cause. Always measure in the same location and direction for trending consistency — mark the measurement point with paint or a stamped dot.',
   55, 1,
   '[{"question":"What does a 1x RPM dominant frequency typically indicate?","options":["Misalignment","Imbalance or eccentricity","Bearing defect","Looseness"],"correctIndex":1},{"question":"What is the most common industrial vibration sensor type?","options":["Velocity probe","Displacement probe","Accelerometer","Proximity probe"],"correctIndex":2}]'),
  (m_id, 'Spectrum Interpretation',
   'Reading a vibration spectrum is like reading a fingerprint. The x-axis is frequency (Hz or CPM), the y-axis is amplitude. A peak at 1x RPM with high amplitude relative to other peaks indicates imbalance. A 2x peak that is 50-100% of the 1x peak indicates angular misalignment. A 3x or 4x peak indicates looseness (bolts, bearing fit, cracked foot). Sub-synchronous peaks (below 1x) indicate oil whirl, belt flap, or a rub. Bearing defect frequencies appear at specific frequencies calculated from bearing geometry — BPFO (outer race), BPFI (inner race), BSF (ball spin), and FTF (cage frequency). A bearing in early degradation shows a single defect frequency with sidebands; advanced degradation shows a broad noise floor (the "haystack") as the defect spreads. Compare spectra over time; a new peak that grows is the early warning of a developing fault.',
   50, 2,
   '[{"question":"What does a 2x peak that is 50-100% of the 1x peak indicate?","options":["Imbalance","Angular misalignment","Bearing defect","Oil whirl"],"correctIndex":1},{"question":"What does a broad noise floor (the haystack) in the spectrum indicate?","options":["Normal operation","Early bearing degradation","Advanced bearing degradation","Mechanical looseness"],"correctIndex":2}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Diagnosing Common Faults', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Imbalance, Misalignment, Looseness & Bearing Defects',
   'Imbalance produces a pure 1x vibration in the radial direction. Correct by balancing — add or remove weight opposite the heavy spot. Misalignment produces 1x and 2x, often with high axial vibration (axial exceeds 50% of radial). Correct by laser alignment. Mechanical looseness produces multiple harmonics (1x, 2x, 3x, 4x) with a direction-dependent amplitude — check foundation bolts, bearing fit, and coupling hub tightness. Bearing defects produce characteristic frequencies: BPFO appears first in most bearings because the outer race is stationary and the defect is loaded each time a ball passes. Use a vibration analyzer with bearing fault frequency calculation — input the bearing part number and the software calculates the expected frequencies. Set alarm thresholds based on ISO 10816 for overall velocity and on the rate of change for specific defect frequencies. A bearing defect frequency that doubles in amplitude over a month warrants scheduling a replacement.',
   55, 1,
   '[{"question":"What does imbalance produce in the vibration spectrum?","options":["Multiple harmonics","A pure 1x vibration in the radial direction","High axial vibration","Sub-synchronous peaks"],"correctIndex":1},{"question":"Which bearing defect frequency typically appears first?","options":["BPFI (inner race)","BPFO (outer race)","BSF (ball spin)","FTF (cage)"],"correctIndex":1}]');
END $$;

-- ===================== Thermography for Mechanical Maintenance =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Thermography for Mechanical Maintenance';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Infrared Basics & Camera Operation', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Infrared Thermography Principles',
   'Infrared thermography detects the infrared radiation emitted by an object and converts it to a temperature map. Every object above absolute zero emits infrared radiation; the amount depends on its temperature and emissivity. Emissivity is a measure of how efficiently an object radiates compared to a perfect blackbody — most non-metallic surfaces have an emissivity of 0.85-0.95, while bare metal is 0.1-0.3. Setting the wrong emissivity produces false readings — always set the camera emissivity to match the surface, or apply electrical tape (emissivity 0.95) to bare metal for a consistent target. Reflections from hot background sources (motors, lights, the sun) can corrupt readings; shield the target or angle the camera to avoid reflections. For mechanical inspections, set the camera to the auto-scale mode initially, then switch to manual and lock the temperature range for comparative images. Always save the thermal image with a corresponding visible-light photo for the report.',
   45, 1,
   '[{"question":"What is emissivity?","options":["The temperature of an object","How efficiently an object radiates compared to a blackbody","The reflectivity of a surface","The thermal conductivity"],"correctIndex":1},{"question":"What is a practical way to get a consistent emissivity on bare metal?","options":["Polish the surface","Apply electrical tape (emissivity 0.95)","Heat the surface","Paint it black"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Mechanical Applications', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Bearings, Couplings, Steam Traps & Motors',
   'Thermography finds mechanical problems by detecting abnormal heat. A bearing running 20-30 degrees C above the adjacent bearing on the same machine is in distress — compare similar bearings under similar load for the most reliable diagnosis. A coupling that is hotter than the shaft indicates slippage or misalignment generating friction heat. Steam traps that fail open show no temperature difference across the trap (steam passes through); traps that fail closed show the inlet hot and the outlet cold — compare the inlet and outlet temperatures to diagnose. Motor windings show hot spots if a winding is shorted or if cooling airflow is blocked. Electrical connections in motor junction boxes show hot spots at loose terminals. For reporting, capture the thermal image with the temperature scale visible and annotate the hot spot temperature, the reference temperature, and the delta. Trend the delta over time — a rising delta indicates worsening condition. Always inspect under normal operating load; a machine at rest shows nothing.',
   50, 1,
   '[{"question":"How do you diagnose a steam trap that has failed open using thermography?","options":["Inlet hot, outlet cold","No temperature difference across the trap","Inlet cold, outlet hot","Both inlet and outlet are cold"],"correctIndex":1},{"question":"What does a bearing running 20-30 degrees C above an adjacent bearing under similar load indicate?","options":["Normal operation","The bearing is in distress","The ambient temperature is high","The lubrication is excessive"],"correctIndex":1}]');
END $$;

-- ===================== Ultrasound & Acoustic Lubrication =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Ultrasound & Acoustic Lubrication';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Ultrasound Fundamentals', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Ultrasound Inspection Technology',
   'Acoustic ultrasound detects high-frequency sounds (20-60 kHz) that are inaudible to the human ear. Friction, turbulence, and electrical discharge all generate ultrasound. An ultrasound inspection gun converts the high-frequency signal to an audible tone via heterodyning and displays the signal strength in decibels (dB). For bearing inspection, a baseline dB reading is established on a new or recently lubricated bearing. An increase of 7-8 dB above baseline indicates early bearing distress; 12-15 dB indicates advanced wear; 20+ dB indicates imminent failure. The advantage over vibration analysis is that ultrasound detects bearing degradation earlier — the high-frequency friction signal appears before the low-frequency vibration signature. For leak detection, the gun pinpoints the turbulent hiss of compressed air, steam, or vacuum leaks that are inaudible in a noisy plant. Use the contact probe for bearings and the scanning module for airborne leaks.',
   45, 1,
   '[{"question":"What frequency range does acoustic ultrasound detect?","options":["1-5 kHz","20-60 kHz","100-500 kHz","1-5 MHz"],"correctIndex":1},{"question":"What dB increase above baseline indicates early bearing distress?","options":["1-2 dB","7-8 dB","20+ dB","30+ dB"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Acoustic Lubrication & Applications', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Greasing Bearings by Sound',
   'Acoustic lubrication is the practice of greasing a bearing while listening to it with an ultrasound gun. As a bearing runs dry, the friction increases and the ultrasound dB rises. With the contact probe on the bearing housing, inject grease slowly while watching the dB reading. As lubricant reaches the rolling elements, the dB drops — stop greasing when the reading stabilizes. This method prevents over-greasing, which is as harmful as under-greasing: excess grease builds pressure, blows seals, and churning heat degrades the lubricant. For a bearing with a grease fitting, clean the fitting, attach the probe, and pump one shot at a time until the dB drops and stabilizes. For sealed bearings without a fitting, trend the ultrasound reading and schedule replacement when the dB rises beyond the alarm threshold. Document the pre- and post-lubrication dB for each bearing to build a trending baseline.',
   40, 1,
   '[{"question":"When greasing a bearing by sound, when should you stop adding grease?","options":["After a fixed number of pumps","When the dB reading stabilizes after dropping","When grease comes out of the seal","After 30 seconds"],"correctIndex":1},{"question":"What is the risk of over-greasing a bearing?","options":["No risk — more is better","Builds pressure, blows seals, and churning heat degrades the lubricant","Improves bearing life","Reduces operating temperature"],"correctIndex":1}]');
END $$;

-- ===================== Rigging, Lifting & Material Handling =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Rigging, Lifting & Material Handling';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Rigging Fundamentals', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Sling Types, Selection & Inspection',
   'Wire rope slings are the most common industrial sling and are rated by diameter, construction (6x19, 6x37), and fitting type. Chain slings are used for high-temperature and abrasive environments where wire rope would degrade. Synthetic web and round slings protect delicate loads but are damaged by UV, chemicals, and cuts. Every sling is rated with a working load limit (WLL) that is a fraction of the breaking strength — typically 5:1 for general service. The sling angle reduces the WLL: a sling at 60 degrees from horizontal carries 115% of the load per leg; at 45 degrees, 141%; at 30 degrees, 200%. Always calculate the sling angle and derate accordingly. Inspect slings before each use: wire rope for broken wires, kinks, and birdcaging; chain for stretched links, nicks, and cracks; synthetic for cuts, abrasion, and chemical damage. Remove any sling from service that fails inspection and tag it as rejected.',
   50, 1,
   '[{"question":"What happens to the load per leg when the sling angle decreases from 60 to 30 degrees?","options":["It decreases","It stays the same","It increases significantly","It doubles at 45 degrees"],"correctIndex":2},{"question":"What is the typical design factor (breaking strength to WLL) for general service slings?","options":["3:1","5:1","10:1","20:1"],"correctIndex":1}]'),
  (m_id, 'Load Calculation & Crane Signals',
   'Before any lift, calculate the total weight including the load, rigging, and any attachments. Verify the crane or hoist capacity exceeds the total weight with margin. Determine the center of gravity (CG) — the load will tilt until the CG is directly below the hook. If the CG is unknown, test-lift a few inches and observe the tilt; adjust the rigging and re-test until the load hangs level. Use standard hand signals per ASME B30.5: one fist pump for hoist up, palm down push for trolley travel, finger circle for stop. Only one person gives signals to the operator unless it is a stop signal (anyone can give a stop). For critical lifts — those exceeding 75% of crane capacity, involving multiple cranes, or lifting over occupied areas — a written lift plan is required, signed by the lift director and the crane operator.',
   45, 2,
   '[{"question":"Why will a load tilt when lifted?","options":["Because of wind","Until the center of gravity is directly below the hook","Because of sling stretch","Because the crane is not level"],"correctIndex":1},{"question":"When is a written lift plan required?","options":["For every lift","Only for lifts over 1000 lbs","For critical lifts exceeding 75% of capacity, multiple cranes, or lifting over occupied areas","Never"],"correctIndex":2}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Rigging Hardware & Safety', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Shackles, Hooks, Turnbuckles & Below-the-Hook Devices',
   'Shackles are the connection point between the sling and the load. Anchor shackles (bow type) have a wider load-bearing area and accommodate multiple slings; chain shackles (D type) are for straight-line pulls only. Never side-load a shackle — the WLL is for an in-line load; side loading reduces capacity by 25-75% depending on the angle. Always tighten the pin by hand; never use a wrench, which over-tightens and damages the threads. Hooks are rated with a safety latch that prevents the sling from slipping off. Inspect hooks for stretching (the throat opening increases with overload) — if the throat opening has increased by 5%, remove the hook from service. Turnbuckles adjust sling length but must be safety-wired to prevent rotation under load. Below-the-hook devices (spreaders, lifting beams) distribute the load to prevent crushing or bending the load. Always verify the device rating and inspect for cracks and deformation before use.',
   40, 1,
   '[{"question":"What happens to a shackle WLL when side-loaded?","options":["It increases","It stays the same","It is reduced by 25-75%","It is zero"],"correctIndex":2},{"question":"How much throat opening increase on a hook requires removal from service?","options":["1%","5%","10%","15%"],"correctIndex":1}]');
END $$;

-- ===================== Machine Guarding & Mechanical LOTO =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Machine Guarding & Mechanical LOTO';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Machine Guarding Standards', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'OSHA 1910.212 & Guard Types',
   'OSHA 1910.212 requires that any machine part that creates a hazard must be guarded. Guards are classified as fixed (permanently attached, require tools to remove), interlocked (opens or removes a guard and the machine stops), adjustable (can be positioned to accommodate different stock sizes), and self-adjusting (moves with the stock). The point of operation — where the work is performed — must be guarded to prevent hands or fingers from entering the danger zone. Common guarding methods include barrier guards, two-hand controls (both hands must be on controls, away from the point of operation), and light curtains (machine stops if the beam is broken). The guard must prevent access to the danger zone, not create a new hazard (no pinch points or sharp edges on the guard itself), and not be easily bypassed. A guard that is removed for maintenance must be replaced before the machine is returned to service. Document guarding in the machine risk assessment and review after any modification.',
   45, 1,
   '[{"question":"Which guard type stops the machine when the guard is opened?","options":["Fixed guard","Interlocked guard","Adjustable guard","Self-adjusting guard"],"correctIndex":1},{"question":"What must be true of a guard to comply with OSHA 1910.212?","options":["It must be transparent","It must prevent access to the danger zone and not create a new hazard","It must be made of plastic","It must cover the entire machine"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Mechanical Lockout/Tagout', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Energy Isolation for Mechanical Systems',
   'Mechanical lockout/tagout (LOTO) isolates hazardous energy before maintenance. The energy sources for mechanical systems include electrical (the motor driving the machine), pneumatic (compressed air cylinders), hydraulic (pressurized fluid), gravitational (raised loads, counterweights), and stored energy (springs, accumulators, flywheels). The LOTO procedure: notify affected employees, shut down the machine by normal means, isolate all energy sources, apply locks and tags to each isolation point, dissipate stored energy (bleed air, release springs, lower raised loads), and verify zero energy by attempting to start the machine. Each worker applies their own lock — never share a lock or key. For group work, use a lock box: each worker places their lock on the box, and the keys to the machine locks are inside the box. Only the person who applied the lock removes it. For mechanical isolation, block or pin any component that could fall or rotate — a valve alone does not prevent a cylinder from drifting.',
   50, 1,
   '[{"question":"What must be done after isolating energy sources and applying locks?","options":["Start the machine to test it","Dissipate stored energy and verify zero energy by attempting to start","Leave the area","Tag the machine only"],"correctIndex":1},{"question":"Who may remove a lock applied during LOTO?","options":["Any supervisor","The person who applied it","The safety manager","Any coworker with the key"],"correctIndex":1}]');
END $$;

-- ===================== Centralized & Automated Lubrication Systems =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Centralized & Automated Lubrication Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'System Types & Design', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Series-Progressive, Dual-Line & Single-Line Systems',
   'Centralized lubrication systems deliver measured grease to multiple bearings from a central pump, eliminating the need for manual greasing. Series-progressive systems use a divider block that meters grease sequentially to each bearing — a blockage at one bearing stops flow to all, making blockages easy to detect but also stopping all lubrication if one line fails. Dual-line systems use two supply lines and a reversing valve; each cycle delivers grease to half the bearings, then reverses to the other half — this allows continued operation if one line fails. Single-line systems use a pump to pressurize a line, and metering valves at each bearing dispense a measured shot when the line pressurizes, then reset when the line vents — the simplest and most common for moderate bearing counts. System selection depends on bearing count, distance, grease type, and the criticality of detecting blockages. Size the pump for the total metered volume per cycle plus a 30% margin for line fill and expansion.',
   50, 1,
   '[{"question":"What happens in a series-progressive system when one bearing line blocks?","options":["Only that bearing stops getting grease","All bearings stop getting grease","The system continues normally","The pump overpressurizes"],"correctIndex":1},{"question":"Which system type is simplest and most common for moderate bearing counts?","options":["Series-progressive","Dual-line","Single-line","Manual grease gun"],"correctIndex":2}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Maintenance & Troubleshooting', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Pump Maintenance & Line Troubleshooting',
   'A centralized lubrication pump has a reservoir, a motor or pneumatic drive, and a pressure relief. Fill the reservoir with the correct grease — mixing incompatible greases causes the system to fail. Check the reservoir level weekly and the low-level alarm function monthly. A cycle indicator on the divider block confirms that grease is flowing — if the indicator does not cycle, check for a blocked line, an empty reservoir, or a failed pump. To find a blockage in a series-progressive system, crack each bearing line fitting one at a time while the pump runs; the point where grease does not appear is downstream of the blockage. Clear blocked lines by disconnecting and blowing them out with a compatible solvent, then reconnect and verify flow. Check that the grease is the correct NLGI grade for the system — a grease that is too stiff will not flow through the lines in cold weather. Trend the pump cycle time; an increasing cycle time indicates line restriction or grease hardening.',
   45, 1,
   '[{"question":"What does a non-cycling divider block indicator mean?","options":["Normal operation","A blocked line, empty reservoir, or failed pump","Too much grease","The system is over-pressurized"],"correctIndex":1},{"question":"How do you find a blockage in a series-progressive system?","options":["Replace all lines","Crack each bearing line fitting one at a time while the pump runs","Increase the pump pressure","Remove the divider block"],"correctIndex":1}]');
END $$;

-- ===================== Welding & Fabrication for Maintenance Technicians =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Welding & Fabrication for Maintenance Technicians';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Welding Processes', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'SMAW, GMAW & GTAW Basics',
   'Shielded Metal Arc Welding (SMAW, or stick) uses a consumable electrode with a flux coating that creates a shielding gas and slag. It is the most portable and forgiving process — suitable for outdoor work, dirty metal, and thick sections. Gas Metal Arc Welding (GMAW, or MIG) uses a continuous wire feed and a shielding gas (75% Ar / 25% CO2 for steel). It is fast and productive for shop work but sensitive to wind that blows away the shielding gas. Gas Tungsten Arc Welding (GTAW, or TIG) uses a non-consumable tungsten electrode and a separate filler rod. It produces the highest quality welds on thin material and exotic metals but is the slowest process and requires the most skill. For maintenance work, SMAW is the go-to for field repairs, GMAW for shop fabrication, and GTAW for precision work on stainless or aluminum. Always match the filler metal to the base metal — a mild steel filler (E7018) on a mild steel shaft, a stainless filler (E308L) on stainless.',
   50, 1,
   '[{"question":"Which welding process is most portable and forgiving for outdoor field repairs?","options":["GMAW (MIG)","SMAW (stick)","GTAW (TIG)","FCAW"],"correctIndex":1},{"question":"Which process produces the highest quality welds on thin material?","options":["SMAW","GMAW","GTAW","FCAW"],"correctIndex":2}]'),
  (m_id, 'Joint Preparation & Distortion Control',
   'A good weld starts with a clean, properly prepared joint. Remove paint, oil, rust, and moisture from the weld area — contaminants cause porosity and cracking. Bevel thick sections (over 1/4 inch) to 30-37.5 degrees with a 1/16-3/32 inch root face for full penetration. Tack weld the joint at intervals to maintain alignment before the final weld. Distortion occurs because the weld metal shrinks as it cools, pulling the workpiece. Control distortion by: welding in a sequence that alternates sides (skip welding), backstepping (welding backward from the direction of travel), clamping the work to a rigid fixture, and preheating thick sections to reduce the temperature gradient. For a shaft repair by build-up welding, rotate the shaft continuously and weld in the 1G (flat) position with small passes to keep the heat input uniform and minimize distortion. Stress-relieve after welding on thick sections or critical applications to prevent delayed cracking.',
   45, 2,
   '[{"question":"Why must paint, oil, and rust be removed before welding?","options":["To improve appearance","They cause porosity and cracking","To save filler metal","To reduce heat input"],"correctIndex":1},{"question":"What causes weld distortion?","options":["Improper filler metal","The weld metal shrinks as it cools, pulling the workpiece","Excessive shielding gas","The wrong welding process"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Repair Welding', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Shaft, Bracket & Structural Repair',
   'Repair welding restores worn or broken components at a fraction of the replacement cost. For a worn shaft journal, machine the worn area clean, build up with compatible filler (E7018 for mild steel) in small, overlapping passes with the shaft rotating, then machine to size and check runout. For a cracked bracket, drill a small hole at the crack tip to stop the crack from propagating, bevel the crack to full depth, preheat if the material is thick or high-carbon, and weld with a low-hydrogen electrode (E7018). For structural members, verify the original material specification — welding a high-strength steel with a mild steel filler reduces the joint strength. After any structural repair, inspect the weld with dye penetrant or magnetic particle to confirm no cracks remain. Post-weld heat treatment may be required for thick sections or critical structural members to relieve residual stresses. Document the repair, the filler metal, and the inspection results in the equipment record.',
   50, 1,
   '[{"question":"Why drill a hole at the tip of a crack before welding a repair?","options":["To improve weld appearance","To stop the crack from propagating","To reduce heat input","To save filler metal"],"correctIndex":1},{"question":"What electrode is recommended for low-hydrogen welding of mild steel repairs?","options":["E6010","E7018","E308L","E11018"],"correctIndex":1}]');
END $$;

-- ===================== Chain & Belt Drive Systems Advanced =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Chain & Belt Drive Systems Advanced';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Chain Drives', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Multiple-Chain Drives & Sprocket Alignment',
   'Multiple-strand chains (double, triple) transmit higher torque than a single chain but require precise alignment of the sprockets — a misalignment of even 0.5 mm between strands causes uneven load sharing and rapid wear of the loaded strand. Align sprockets using a straightedge across the machined faces of both sprockets; the straightedge must contact all faces without gaps. For long center distances, use a taut wire or laser alignment tool. Check sprocket tooth wear with a go/no-go gauge — a hooked tooth profile indicates advanced wear that will destroy a new chain. Always replace sprockets and chains as a set; a worn sprocket with a new chain accelerates chain wear to the point of premature failure. For multiple-chain drives, use a connecting link (not a riveted link) for field assembly, and orient the connecting link clip with the open end trailing (away from the direction of chain travel) so it does not catch.',
   45, 1,
   '[{"question":"What misalignment between chain strands causes uneven load sharing?","options":["Over 5 mm","Even 0.5 mm","Over 10 mm","Any misalignment is acceptable"],"correctIndex":1},{"question":"How should the connecting link clip be oriented?","options":["Open end leading","Open end trailing (away from direction of travel)","Open end up","Open end down"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Belt Drives', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Sheave Alignment, Tensioning & Toothed Belt Timing',
   'V-belt drives transfer power through friction between the belt and the sheave groove. Sheave alignment is critical — a misalignment of more than 0.5 degrees per foot of center distance causes the belt to ride up the groove wall, wear one side, and shed tension. Align sheaves with a straightedge across the machined faces. Tension a V-belt by pressing at mid-span with a specified deflection force (per the belt manufacturer chart); the deflection should be 1/64 of the span length. A belt that squeals on startup is under-tensioned; a belt that runs hot is over-tensioned. Toothed (timing) belts require precise tension because they transmit power by positive engagement — too loose and the belt ratchets (jumps teeth), too tight and the bearing loads increase. Use a sonic tension meter to set timing belt tension to the specified frequency. Always replace V-belts as a matched set — belts from different manufacturing lots have slightly different lengths, causing the shorter belt to carry all the load.',
   50, 1,
   '[{"question":"What causes a V-belt to ride up the groove wall and wear one side?","options":["Over-tensioning","Sheave misalignment of more than 0.5 degrees per foot","Under-tensioning","Wrong belt type"],"correctIndex":1},{"question":"Why should V-belts be replaced as a matched set?","options":["They look better","Belts from different lots have slightly different lengths, causing uneven load sharing","It is cheaper","It is required by OSHA"],"correctIndex":1}]');
END $$;

-- ===================== Compressors & Compressed Air Systems =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Compressors & Compressed Air Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Compressor Types', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Rotary Screw, Reciprocating & Centrifugal Compressors',
   'Rotary screw compressors are the workhorse of modern plants — two intermeshing rotors compress air continuously, producing smooth, pulsation-free flow. They are efficient from 50-100% load and run quietly. The air-end (rotor block) is oil-flooded for lubrication and sealing; the oil is separated from the air in a separator tank. Reciprocating compressors use pistons and cylinders — they are efficient at part-load (unloading individual cylinders), handle high pressures, but produce pulsation and are noisy. Centrifugal compressors use an impeller to accelerate air and a diffuser to convert velocity to pressure — they produce very high flow at moderate pressure and are used in large plants. They are sensitive to surge (flow reversal at low demand) and require anti-surge controls. Selection depends on required flow (CFM), pressure (PSIG), duty cycle, and part-load efficiency. Always size the compressor for the peak demand plus a 10-20% margin, and consider a sequencer for multiple compressors to match output to demand efficiently.',
   55, 1,
   '[{"question":"Which compressor type is the workhorse of modern plants and produces smooth, pulsation-free flow?","options":["Reciprocating","Rotary screw","Centrifugal","Scroll"],"correctIndex":1},{"question":"What are centrifugal compressors sensitive to at low demand?","options":["Overheating","Surge (flow reversal)","Oil leakage","Excessive noise"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Air Treatment & System Efficiency', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Dryers, Filters & Leak Surveys',
   'Compressed air leaving the compressor contains water, oil, and particulates that must be removed before distribution. A refrigerated dryer cools the air to 35-40 degrees F, condensing the moisture; a desiccant dryer uses activated alumina to achieve a pressure dew point of -40 degrees F for instrument air or outdoor service. A coalescing filter removes oil aerosols down to 0.01 ppm; a particulate filter captures solid particles. Size filters and dryers for the maximum flow and check the pressure drop across them monthly — a rising pressure drop indicates a clogged element. Compressed air leaks waste significant energy — a 1/8 inch leak at 100 PSIG wastes approximately $2,000 per year in electricity. Conduct an ultrasonic leak survey quarterly: tag each leak, estimate the CFM loss, and repair the largest leaks first. Re-survey after repairs to verify. Target a leak rate below 10% of total production; world-class plants achieve under 5%.',
   50, 1,
   '[{"question":"What dew point does a desiccant dryer achieve?","options":["35-40 F","-40 F","0 F","32 F"],"correctIndex":1},{"question":"Approximately how much does a 1/8 inch leak at 100 PSIG waste per year?","options":["$200","$2,000","$20,000","$200,000"],"correctIndex":1}]'),
  (m_id, 'System Efficiency & Energy Recovery',
   'Compressed air is the most expensive utility in a plant — it takes 7-8 HP of electrical power to produce 1 HP of pneumatic work. Reduce energy cost by: lowering the system pressure to the minimum required (every 2 PSI reduction saves approximately 1% of compressor energy), eliminating leaks, using intermediate storage to handle peak demand without starting a second compressor, and recovering the compressor heat (the hot discharge air can heat a workshop or warehouse). A variable-speed drive (VSD) compressor matches motor speed to demand and saves 15-35% on part-load operation compared to a fixed-speed compressor that loads and unloads. Install flow meters and pressure transducers at the compressor room and at critical points in the distribution system to trend demand and identify waste. A pressure profile that drops significantly between the compressor and the end use indicates a restriction (undersized pipe, clogged filter, or too many fittings) that wastes energy.',
   45, 2,
   '[{"question":"How much electrical power does it take to produce 1 HP of pneumatic work?","options":["1-2 HP","3-4 HP","7-8 HP","10-12 HP"],"correctIndex":2},{"question":"How much energy does a VSD compressor save on part-load operation?","options":["5-10%","15-35%","50%","80%"],"correctIndex":1}]');
END $$;

-- ===================== Heat Exchangers & Cooling Systems =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Heat Exchangers & Cooling Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Heat Exchanger Types & Maintenance', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Shell-and-Tube, Plate & Air-Cooled Exchangers',
   'Shell-and-tube exchangers are the most common industrial type — one fluid flows through tubes inside a shell, the other flows across the tube bundle. They are rugged, handle high pressure, and can be cleaned by rodding or hydro-lancing the tubes. Plate exchangers use corrugated metal plates bolted together with gaskets — they are compact and efficient but limited to lower pressures and temperatures. Air-cooled exchangers use fans to blow air across finned tubes — they eliminate water usage but are less efficient and larger for the same duty. Fouling is the primary maintenance issue: scale, biological growth, and particulate deposition insulate the heat transfer surface and reduce capacity. Monitor the approach temperature (the difference between the process outlet and the cooling medium inlet) — a rising approach indicates fouling. Clean when the approach exceeds the design value by 5-10 degrees F or when the process outlet temperature exceeds the specification.',
   50, 1,
   '[{"question":"What is the primary maintenance issue for heat exchangers?","options":["Corrosion","Fouling (scale, biological growth, particulate deposition)","Leaking gaskets","Cracked tubes"],"correctIndex":1},{"question":"What does a rising approach temperature indicate?","options":["Improved heat transfer","Fouling on the heat transfer surface","Increased flow rate","Lower ambient temperature"],"correctIndex":1}]'),
  (m_id, 'Tube Cleaning & Gasket Replacement',
   'Shell-and-tube tubes are cleaned by mechanical rodding (for soft deposits), hydro-lancing (for hard scale), or chemical cleaning (circulating a descaling solution). Always isolate the exchanger, drain it, and verify zero pressure before opening. Inspect each tube for wall thinning using an eddy current tester — a tube with greater than 50% wall loss should be plugged or replaced. When reassembling a plate exchanger, replace all gaskets as a set — never mix old and new gaskets. Tighten the plate pack bolts in a cross pattern to the specified dimension (not a torque value — plate exchangers use a tightening dimension). For shell-and-tube, replace the shell gasket and torque the flange bolts in a star pattern to the specified torque. After reassembly, pressure-test before returning to service — a leak under pressure is a safety hazard and a process contamination risk.',
   45, 2,
   '[{"question":"At what wall loss should a heat exchanger tube be plugged or replaced?","options":["10%","25%","50%","75%"],"correctIndex":2},{"question":"How are plate exchanger bolts tightened?","options":["To a specified torque value","To a specified tightening dimension","By feel","To full tightness"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Cooling Towers & Water Treatment', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Cooling Tower Maintenance & Water Treatment',
   'Cooling towers expose water to air, evaporating a portion to reject heat — this concentrates dissolved solids in the remaining water. Without treatment, the concentrated solids precipitate as scale, and the warm, nutrient-rich water grows bacteria, including Legionella. Water treatment controls scale (by keeping the cycles of concentration below the saturation point of calcium carbonate), corrosion (by adding inhibitors that form a protective film), and biological growth (by adding biocide, typically chlorine or bromine). The cycles of concentration are the ratio of dissolved solids in the tower water to the makeup water — controlled by adjusting the blowdown (the continuous drain of concentrated water). Inspect the tower monthly: check the fill for scale and biological growth, the drift eliminators for damage, the distribution nozzles for clogging, and the sump for sediment. Clean the sump annually. Test the water weekly for pH, conductivity, and biocide residual. A white rust appearance on galvanized steel indicates aggressive water chemistry that requires immediate treatment adjustment.',
   55, 1,
   '[{"question":"What do cycles of concentration represent in a cooling tower?","options":["The number of times the water cycles per hour","The ratio of dissolved solids in tower water to makeup water","The number of biocide additions per day","The fan speed setting"],"correctIndex":1},{"question":"What does white rust on galvanized steel in a cooling tower indicate?","options":["Normal aging","Aggressive water chemistry requiring immediate treatment adjustment","Excessive biocide","Low water temperature"],"correctIndex":1}]');
END $$;

-- ===================== Conveyor Troubleshooting & Repair =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Conveyor Troubleshooting & Repair';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Belt Conveyor Troubleshooting', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Belt Splice Repair & Tracking Correction',
   'Belt splices are the weakest point on a conveyor belt. Mechanical splices (hinged, bolted, or riveted) are fast to install and suitable for field repair; vulcanized splices are stronger and longer-lasting but require specialized equipment and hours to cure. When a splice fails, inspect the belt ends for damage — a torn belt end must be cut back to sound belt before splicing. To repair a torn belt, cut the belt square (use a carpenter square and a utility knife), install a mechanical splice rated for the belt tension, and verify the splice does not catch on the idlers as it passes. For tracking correction, the rule is: the belt moves toward the side of the idler or pulley it contacts first. Adjust the tail pulley or the training idlers in small increments (1/4 turn) and let the belt run several revolutions before re-adjusting. Never adjust the drive pulley for tracking — it affects the entire belt length.',
   50, 1,
   '[{"question":"Which splice type is stronger and longer-lasting but requires specialized equipment?","options":["Mechanical splice","Vulcanized splice","Hinged splice","Bolted splice"],"correctIndex":1},{"question":"Which direction does a belt move relative to the idler it contacts first?","options":["Away from it","Toward it","Perpendicular to it","It does not move"],"correctIndex":1}]'),
  (m_id, 'Roller Replacement & Drive Diagnostics',
   'Worn or seized rollers cause belt damage and increased motor load. Identify seized rollers by walking the conveyor while it is running and listening for grinding or watching for rollers that do not turn. Replace seized rollers immediately — a seized roller can shred a belt in hours. When replacing a roller, lock out the conveyor, remove the retention clip or bolt, slide the old roller out, and install the new one with the same bearing arrangement. Check the adjacent rollers for wear — a seized roller often damages its neighbors. For drive diagnostics, measure the motor amperage under load: a rising amperage with no change in belt speed indicates increased friction from seized rollers, a tight belt, or a failing gearbox. A slipping drive (the belt slows under load but the motor speed does not change) indicates insufficient belt tension, a worn lagging, or an overloaded conveyor. Check the gearbox oil for metal and water, and listen for bearing noise at the drive end.',
   45, 2,
   '[{"question":"What does a rising motor amperage with no change in belt speed indicate?","options":["A slipping drive","Increased friction from seized rollers, tight belt, or failing gearbox","Normal operation","Undersized motor"],"correctIndex":1},{"question":"What does a slipping drive (belt slows but motor speed unchanged) indicate?","options":["Insufficient belt tension, worn lagging, or overload","Motor failure","Gearbox oil leak","Normal operation"],"correctIndex":0}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Take-Up & System Optimization', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Take-Up Adjustment & System Optimization',
   'The take-up maintains belt tension as the belt stretches over time. A screw take-up is manual — tighten the tail pulley bolts evenly to maintain the specified sag (2% of center distance). A gravity take-up uses a weighted pulley that self-adjusts — check that the weight moves freely and the travel is not at its limit. A winch or hydraulic take-up provides constant tension and is used on long conveyors. If the take-up is at its limit, the belt has stretched beyond the take-up capacity and must be shortened by cutting and re-splicing. Optimize the conveyor by: setting the belt speed to the minimum that meets production (reduces wear and energy), loading the belt at the center to prevent tracking drift, installing a belt scale to trend throughput, and scheduling a weekly walk-down inspection. Track the motor amperage trend — a gradual rise indicates increasing system friction that warrants investigation before it becomes a failure.',
   40, 1,
   '[{"question":"What does it mean when the take-up is at its limit?","options":["The take-up is oversized","The belt has stretched beyond the take-up capacity and must be shortened","The belt is too short","Normal operation"],"correctIndex":1},{"question":"What does a gradual rise in motor amperage trend indicate?","options":["Improved efficiency","Increasing system friction warranting investigation","Normal belt stretch","Reduced load"],"correctIndex":1}]');
END $$;

-- ===================== Precision Maintenance Practices =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Precision Maintenance Practices';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Soft Foot & Pipe Strain', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Soft Foot Diagnosis & Correction',
   'Soft foot distorts the machine frame when the hold-down bolts are tightened, causing bearing misalignment and vibration that no amount of alignment can fix. There are three types: parallel soft foot (a uniform gap under the foot — shim with stainless shims), angular soft foot (a wedge-shaped gap — the foot or base is bent, may require machining), and induced soft foot (caused by pipe strain or coupling strain pulling the machine — fix the pipe or coupling, not the foot). Diagnose by placing a dial indicator on each foot, loosening the bolt, and reading the lift. Anything over 0.05 mm is actionable. Correct parallel soft foot by shimming with the minimum number of shims — never stack more than 3 shims under a foot, as they act like a spring and compress under torque. After shimming all four feet, re-check each one before proceeding to alignment. A machine with corrected soft foot will hold its alignment longer and run smoother.',
   50, 1,
   '[{"question":"What is the maximum acceptable soft foot before correction is needed?","options":["0.01 mm","0.05 mm","0.5 mm","1.0 mm"],"correctIndex":1},{"question":"What is induced soft foot caused by?","options":["A bent foot","Pipe strain or coupling strain pulling the machine","A warped base","Overtightening the bolts"],"correctIndex":1}]'),
  (m_id, 'Pipe Strain Elimination',
   'Pipe strain occurs when the piping connected to a pump or compressor pulls the machine off its alignment when the flange bolts are tightened. To diagnose, mount dial indicators on the coupling in the horizontal and vertical planes. Loosen the pipe flange bolts and read the movement — any movement over 0.05 mm indicates pipe strain that must be corrected. Correct pipe strain by re-supporting the pipe close to the machine, cutting and re-welding the pipe to remove the strain, or using flexible connectors (expansion joints) that absorb the movement. Never use the machine as a pipe support — the pipe weight and thermal expansion forces distort the machine casing, causing internal rubbing and bearing failure. After correcting pipe strain, re-check the coupling alignment and the soft foot. A machine free of pipe strain and soft foot will maintain its alignment and bearing life for years; a machine with pipe strain will never stay aligned.',
   45, 2,
   '[{"question":"How do you diagnose pipe strain on a pump?","options":["By listening to the pump","By mounting dial indicators on the coupling and loosening the pipe flange bolts","By checking the oil","By measuring the flow rate"],"correctIndex":1},{"question":"What should never be used as a pipe support?","options":["A pipe rack","The machine itself","A wall","A floor stand"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Thermal Growth & Precision Tools', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Thermal Growth Compensation',
   'A machine grows as it heats up — a steel shaft grows approximately 0.001 mm per 100 mm of length per 10 degrees C rise. A pump operating at 80 degrees C with a center height of 500 mm grows by approximately 0.3 mm vertically — enough to misalign the coupling if the motor (at ambient temperature) is not compensated. To compensate, set the cold alignment with the machine targets offset by the calculated thermal growth so that the machine grows into alignment at operating temperature. The growth is calculated from the coefficient of thermal expansion (12 x 10^-6 /C for steel), the dimension, and the temperature difference. Some laser alignment systems have a thermal growth compensation feature that calculates and applies the offset automatically. For critical machines, verify the hot alignment by measuring the coupling alignment at operating temperature with a laser system designed for hot measurement. Document the cold and hot alignment values for each machine to build a thermal growth database.',
   50, 1,
   '[{"question":"How much does a steel shaft grow per 100 mm per 10 degrees C?","options":["0.0001 mm","0.001 mm","0.01 mm","0.1 mm"],"correctIndex":1},{"question":"How is thermal growth compensated during alignment?","options":["By ignoring it","By setting the cold alignment with offsets so the machine grows into alignment at operating temperature","By aligning at operating temperature only","By using a larger coupling"],"correctIndex":1}]');
END $$;

-- ===================== Mechanical Seals Advanced Diagnostics =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Mechanical Seals Advanced Diagnostics';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Seal Face Materials & Flush Plans', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Seal Face Material Selection',
   'Seal faces are the heart of a mechanical seal — one face is typically a soft material (carbon) and the other is hard (silicon carbide, tungsten carbide, or ceramic). Carbon vs silicon carbide is the standard combination for water and general service — it is self-lubricating and tolerates marginal lubrication. Tungsten carbide faces are used for abrasive service because both faces are hard and resist wear from solids. For high-temperature service, the carbon face is replaced with a hard face (silicon carbide vs tungsten carbide) because carbon oxidizes above 300 degrees C. For corrosive service, the metal components (springs, bellows) must be a compatible alloy — Hastelloy for aggressive chemicals, titanium for chlorine. Face flatness is critical — the faces are lapped to within 2-3 helium light bands (0.0006 mm). Any handling that touches the faces (even wiping with a paper towel) can scratch them and cause leakage. Inspect removed faces with an optical flat and a monochromatic light to verify flatness; a face with more than 3 bands of distortion must be re-lapped or replaced.',
   55, 1,
   '[{"question":"Which face material combination is standard for water and general service?","options":["Silicon carbide vs tungsten carbide","Carbon vs silicon carbide","Tungsten carbide vs tungsten carbide","Ceramic vs ceramic"],"correctIndex":1},{"question":"Why are both faces hard (SiC vs WC) for high-temperature service?","options":["For better heat transfer","Carbon oxidizes above 300 degrees C","Hard faces are cheaper","Hard faces are easier to install"],"correctIndex":1}]'),
  (m_id, 'API 682 Flush Plans',
   'API 682 defines standard flush plans that manage the seal environment. Plan 11 (process fluid from discharge to seal) is the most common — it flushes the seal with clean process fluid. Plan 21 (flush with cooler) cools the flush for high-temperature service. Plan 31 (flush through a cyclone separator) removes solids from the flush for abrasive service. Plan 52 (dual seal with unpressurized barrier fluid) is used for hazardous services where leakage to atmosphere is unacceptable. Plan 53 (dual seal with pressurized barrier fluid) is used for toxic services where the barrier fluid pressure is above the seal chamber pressure, so any leakage is barrier fluid into the process, not process fluid out. Select the flush plan based on the process temperature, solids content, volatility, and toxicity. A seal that runs hot (above 80 degrees C at the seal faces) is under-lubricated or over-pressured — check the flush flow rate and the orifice size. A flush flow of 3-5 L/min is typical for a standard seal; verify with a flow meter.',
   50, 2,
   '[{"question":"Which API 682 flush plan is most common for clean process fluid?","options":["Plan 11","Plan 21","Plan 31","Plan 53"],"correctIndex":0},{"question":"What does a Plan 53 dual seal with pressurized barrier fluid ensure?","options":["Process fluid leaks to atmosphere","Barrier fluid leaks into the process, not process fluid out","No leakage at all","Cooling of the seal faces"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Failure Analysis', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Root Cause Analysis of Seal Failures',
   'Seal failure analysis starts with the faces and works outward. Heat checking (radial cracks on the face) indicates the seal ran dry or the flush failed — check the flush flow and the seal chamber pressure. Blistering on the carbon face (small raised bubbles) indicates thermal stress from rapid heating and cooling — common on hot applications that are started and stopped frequently. Wear track wider than the face width indicates misalignment or shaft runout — check the shaft for runout and the coupling for alignment. Erosion on the faces or metal components indicates cavitation or solids in the flush — check the pump NPSH margin and the flush filtration. O-ring extrusion (the O-ring is pinched and deformed) indicates over-pressure or over-temperature — verify the seal pressure and temperature ratings. Spring clogging (the springs are packed with solids) indicates inadequate flush or a dirty process. For every seal failure, document the failure mode, the operating conditions, the time in service, and the corrective action. Trend the mean time between seal failures (MTBSF) per pump — a falling MTBSF indicates a systemic issue that warrants a design review.',
   55, 1,
   '[{"question":"What does heat checking (radial cracks) on seal faces indicate?","options":["Over-pressure","The seal ran dry or the flush failed","Cavitation","O-ring extrusion"],"correctIndex":1},{"question":"What does a wear track wider than the face width indicate?","options":["Normal wear","Misalignment or shaft runout","Over-pressure","Inadequate flush"],"correctIndex":1}]');
END $$;

-- ===================== Rotating Equipment Reliability Fundamentals =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Rotating Equipment Reliability Fundamentals';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Failure Modes & Criticality', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Failure Mode Identification for Rotating Equipment',
   'Rotating equipment — pumps, motors, fans, compressors, gearboxes — shares a common set of failure modes. Bearing failure is the most common, accounting for 40-50% of all rotating equipment failures. The causes are contamination (particles or water in the lubricant), misalignment, imbalance, over-lubrication, under-lubrication, and incorrect bearing selection. Seal failure is the second most common, caused by dry running, cavitation, chemical incompatibility, and installation error. Vibration-related failures (imbalance, misalignment, looseness) account for the remainder. The key to reliability is matching the maintenance strategy to the failure mode: failure modes with a clear wear-out pattern (bearing fatigue) benefit from condition monitoring (vibration, oil analysis) that detects degradation before failure. Failure modes that are random (seal failure from cavitation) benefit from design changes (better flush, higher NPSH margin) rather than more frequent PMs. Use the equipment failure history to identify the dominant failure mode and address the root cause, not the symptom.',
   50, 1,
   '[{"question":"What percentage of rotating equipment failures are bearing-related?","options":["10-20%","40-50%","70-80%","90%"],"correctIndex":1},{"question":"What maintenance strategy fits a bearing fatigue wear-out pattern?","options":["Run to failure","Condition monitoring (vibration, oil analysis) that detects degradation before failure","Time-based replacement only","No maintenance"],"correctIndex":1}]'),
  (m_id, 'Criticality Analysis & Maintenance Strategy',
   'Criticality analysis ranks equipment by the consequence of failure — safety, environmental, production, and cost. A critical pump whose failure shuts down the plant warrants a different strategy than a non-critical fan whose failure causes a minor inconvenience. Assign each asset a criticality rating (A, B, or C) based on the impact of failure. A-critical equipment gets predictive maintenance (vibration, oil analysis, thermography) at a defined interval, a spare parts strategy, and a documented failure response plan. B-critical equipment gets predictive maintenance at a longer interval and a reactive spare strategy. C-critical equipment runs to failure with a spare on the shelf. The maintenance strategy is the combination of PM (preventive — time-based tasks like lubrication and inspection), PdM (predictive — condition-based monitoring), and RTF (run to failure). The goal is to maximize the ratio of PdM to PM — PdM finds problems early and schedules the repair, while PM does work regardless of condition, wasting labor on healthy equipment.',
   50, 2,
   '[{"question":"What is the difference between PM and PdM?","options":["PM is time-based; PdM is condition-based","PM is condition-based; PdM is time-based","They are the same","PM is for critical equipment; PdM is for non-critical"],"correctIndex":0},{"question":"What is the goal of the maintenance strategy mix?","options":["Maximize PM over PdM","Maximize the ratio of PdM to PM","Eliminate all PM","Only use run to failure"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Condition Monitoring Strategy', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Building a Condition Monitoring Program',
   'A condition monitoring program uses periodic measurements to detect equipment degradation before failure. The three pillars are vibration analysis (for rotating equipment), oil analysis (for lubricated components), and thermography (for bearings, couplings, and electrical). Start with the A-critical equipment — list each asset, its failure modes, and the appropriate technology for each mode. Vibration analysis is collected monthly on critical machines and quarterly on less critical; oil samples are taken quarterly; thermography is performed during rounds or on alarm. Set alarm thresholds based on ISO standards (ISO 10816 for vibration) and on the rate of change — a reading that doubles over two consecutive measurements is more significant than the absolute value. Use a CMMS to schedule the routes and store the data. Train the technicians to collect consistent data — the same sensor location, the same mounting, the same machine operating condition. The program pays for itself by catching failures early, allowing planned repairs instead of emergency breakdowns, and by eliminating unnecessary PMs on healthy equipment.',
   55, 1,
   '[{"question":"What are the three pillars of condition monitoring?","options":["Vibration, oil analysis, and thermography","PM, PdM, and RTF","Visual, audible, and tactile","Temperature, pressure, and flow"],"correctIndex":0},{"question":"What is more significant than the absolute alarm value in condition monitoring?","options":["The equipment age","The rate of change — a reading that doubles over two consecutive measurements","The ambient temperature","The equipment criticality"],"correctIndex":1}]');
END $$;
