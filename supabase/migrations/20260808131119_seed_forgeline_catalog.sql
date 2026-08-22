/*
# Seed ForgeLine catalog — courses, modules, lessons

## Overview
Populates the catalog with 19 realistic industrial maintenance courses across
the 4-stage career ladder (Mechanical & Electrical = free; I&E & Engineering = premium).
Each course has 2-3 modules, each module has 2-3 lessons with content, video/pdf flags,
and a knowledge-check quiz (2-3 questions each) where appropriate.

## Courses added
Mechanical (free): Bearings, Lubrication & Alignment; Pump & Mechanical Seal Maintenance;
Conveyor & Drive Systems; Precision Measurement & Troubleshooting; Hydraulics & Pneumatics Basics.
Electrical (free): Industrial Motor Control Circuits; 3-Phase Power Systems & Troubleshooting;
VFD Fundamentals & Parameterization; Motor Testing with Megger & PI; Electrical Safety & Arc Flash Awareness.
I&E (premium): HART Transmitters & Smart Instrumentation; Control Valve Calibration & Diagnostics;
DeltaV / DCS Fundamentals for Technicians; Fieldbus & Industrial Ethernet Troubleshooting; Advanced Loop Tuning.
Engineering (premium): PLC Programming Best Practices; System Architecture & Network Design;
Reliability Engineering & Predictive Maintenance Strategy; Advanced Motion & Safety Systems.

## Security
No policy changes — INSERT is allowed only for service role / SQL execution, which is how
this seed runs. The anon-key frontend never writes catalog rows.

## Notes
1. Uses ON CONFLICT DO NOTHING keyed on (stage, title) so re-running is safe.
2. Lesson content is realistic but concise professional text — not lorem ipsum.
3. Quizzes are JSON arrays: [{question, options:[...], correctIndex:0}].
*/

-- Helper: insert course and return id via CTE, then modules, then lessons.
-- We do this per-course to keep references clean.

-- ===================== MECHANICAL (free) =====================

INSERT INTO courses (title, description, short_description, stage, tier, difficulty, estimated_hours, sort_order)
VALUES
('Bearings, Lubrication & Alignment Fundamentals',
 'Master the fundamentals of rolling-element bearings, proper lubrication practices, and precision shaft alignment. Covers bearing selection, failure modes, lubricant chemistry, and laser alignment techniques used across rotating equipment in modern plants.',
 'Bearing selection, lubrication, and laser alignment for rotating equipment.',
 'mechanical','free','beginner',3,1),
('Pump & Mechanical Seal Maintenance',
 'Hands-on maintenance of centrifugal pumps and mechanical seals. Learn to identify cavitation, replace seals correctly, perform impeller clearance checks, and reduce MTTR on critical process pumps.',
 'Centrifugal pump teardown, seal replacement, and cavitation diagnostics.',
 'mechanical','free','intermediate',3,2),
('Conveyor & Drive Systems',
 'Maintain belt, roller, and chain conveyors plus the gear drives and power transmission components behind them. Covers belt tracking, sprocket wear, gearbox inspection, and tensioning procedures.',
 'Belt tracking, gearbox inspection, and power transmission maintenance.',
 'mechanical','free','intermediate',2.5,3),
('Precision Measurement & Troubleshooting',
 'Use dial indicators, calipers, micrometers, and laser measurement tools to diagnose mechanical problems to thousandths of an inch. Includes runout, concentricity, and soft-foot checks.',
 'Dial indicators, micrometers, runout, and soft-foot diagnostics.',
 'mechanical','free','beginner',2,4),
('Hydraulics & Pneumatics Basics',
 'Understand hydraulic and pneumatic systems from the reservoir to the actuator. Covers pumps, valves, accumulators, cylinders, common failures, and safe lockout practices for fluid power systems.',
 'Fluid power fundamentals: pumps, valves, cylinders, and troubleshooting.',
 'mechanical','free','beginner',2.5,5)
ON CONFLICT DO NOTHING;

-- Bearings course modules + lessons
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Bearings, Lubrication & Alignment Fundamentals';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Bearing Fundamentals', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Bearing Types & Selection',
   'Rolling-element bearings fall into two families: ball bearings (lower friction, higher speed) and roller bearings (higher load capacity). Within these, deep-groove ball bearings handle radial and axial loads in both directions, making them the general-purpose choice for motors and pumps. Cylindrical roller bearings carry heavy radial loads but little axial load, while tapered roller bearings handle combined loads and are common in gearboxes. Selection depends on load magnitude and direction, speed, expected life (L10 rating), and operating environment. Always verify the bearing clearance class (C2/C3/C4) matches the application — C3 is standard for electric motors to accommodate thermal expansion.',
   45, 1,
   '[{"question":"Which bearing type is best suited for heavy radial loads with minimal axial load?","options":["Deep-groove ball bearing","Cylindrical roller bearing","Thrust ball bearing","Self-aligning ball bearing"],"correctIndex":1},{"question":"Why is C3 clearance commonly specified for electric motor bearings?","options":["To reduce noise at high speed","To accommodate thermal expansion during operation","To allow for heavier axial loading","To simplify lubrication"],"correctIndex":1}]'),
  (m_id, 'Failure Modes & Inspection',
   'The majority of bearing failures stem from contamination, improper lubrication, and misalignment — not material fatigue. The four most common failure signatures: (1) Flaking/spalling — fatigue life exhausted or overload; (2) Smearing — skidding damage from inadequate load or lubrication; (3) False brinelling — vibration during standstill; (4) Contamination wear — abrasive particles in the raceway. When inspecting a removed bearing, check the raceways for frosting, spalling, and heat discoloration. Measure internal clearance with a feeler gauge and compare to the original spec. Document findings with photos for the CMMS record.',
   40, 2,
   '[{"question":"What does false brinelling indicate?","options":["Overload during operation","Vibration while the shaft is stationary","Inadequate lubrication at speed","Excessive clearance"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Lubrication', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Lubricant Selection & Application',
   'Grease is selected by base oil viscosity, thickener type, and NLGI grade. Polyurea greases are widely used in electric motors for their long life and high-temperature stability; lithium-complex greases are common for general industrial use. Mixing incompatible thickeners (e.g., polyurea and lithium-complex) can cause softening and oil bleed — always verify compatibility or fully purge the system. Re-lubrication intervals depend on bearing size, speed, and operating temperature. As a baseline, double the interval for every 15°C drop in operating temperature below 70°C, and halve it for every 15°C rise.',
   50, 1,
   '[{"question":"What happens when incompatible grease thickeners are mixed?","options":["Nothing — thickeners are interchangeable","The grease may soften and bleed oil","The viscosity permanently increases","The color changes but performance is unaffected"],"correctIndex":1},{"question":"How does operating temperature affect re-lubrication intervals?","options":["Interval doubles for every 15°C rise","Interval halves for every 15°C rise","Temperature has no effect","Interval triples for every 10°C rise"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Precision Alignment', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Laser Alignment Techniques',
   'Shaft misalignment is a leading cause of premature bearing and seal failure. The two misalignment types are angular (shafts meet at an angle) and parallel offset (shafts are parallel but not collinear). Laser alignment systems measure both simultaneously at the coupling. Always correct angular misalignment first using the vertical feet values, then address horizontal offset. Soft-foot — where a foot does not sit flat on the base — must be detected and corrected before final alignment, as it introduces distortion into the frame when bolts are torqued. Target tolerances for most industrial couplings are 0.05 mm offset and 0.05 mm/100 mm angularity.',
   55, 1,
   '[{"question":"What should be corrected before final laser alignment?","options":["Coupling grease","Soft-foot","Bearing clearance","Lubricant viscosity"],"correctIndex":1},{"question":"Which misalignment type should typically be corrected first?","options":["Parallel offset","Angular misalignment","Both simultaneously is required","Neither — they self-correct"],"correctIndex":1}]');
END $$;

-- Pump & Mechanical Seal course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Pump & Mechanical Seal Maintenance';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Centrifugal Pump Fundamentals', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Pump Curves & Operating Point',
   'A pump curve plots head (vertical axis) against flow (horizontal axis) for a given impeller diameter and speed. The system curve represents the resistance of the piping — static head plus friction losses. Where the two curves intersect is the operating point. Running a pump far to the right of best efficiency point (BEP) causes high radial loads and seal issues; running far left risks recirculation cavitation. The goal of maintenance is to keep the operating point within 70-120% of BEP. Verify actual flow against the curve during PMs using a flow meter or, as a proxy, motor amperage.',
   50, 1,
   '[{"question":"Where is a centrifugal pump most efficient?","options":["At shutoff head","At best efficiency point (BEP)","At maximum flow","At minimum flow"],"correctIndex":1},{"question":"What risk increases when a pump runs far left of BEP?","options":["Seal flush failure","Recirculation cavitation","Motor overload","Impeller erosion from high flow"],"correctIndex":1}]'),
  (m_id, 'Cavitation Diagnosis',
   'Cavitation occurs when local pressure drops below the vapor pressure of the liquid, forming bubbles that collapse violently against impeller vanes. Symptoms include a sound like gravel passing through the pump, vibration, fluctuating discharge pressure, and pitting on the impeller. The most common cause is a clogged or undersized suction strainer, a high suction lift, or a blocked suction line. Suction cavitation damages the inlet side of the impeller; discharge cavitation (from running against a closed discharge valve) damages the outlet. Correct by opening suction valves fully, cleaning strainers, and reducing suction lift.',
   40, 2,
   '[{"question":"What sound is characteristic of pump cavitation?","options":["A high-pitched whine","Gravel passing through the pump","A steady humming","Metal-on-metal grinding"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Mechanical Seals', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Seal Installation & Failure Analysis',
   'Mechanical seals fail most often from heat checking, dry running, and chemical incompatibility — not from wear-out. When installing a seal, cleanliness is critical: even a fingerprint on the seal faces can cause premature failure. Measure the seal chamber bore and shaft sleeve to confirm dimensions match the seal drawing. Never lubricate the faces with grease that hardens; use a light film of the process fluid or a compatible assembly lube. After installation, always hand-rotate the shaft to confirm the seal is not binding before starting the pump. Common failure signatures: heat-checked faces (insufficient flush), worn faces with abrasive tracks (solids in fluid), and O-ring extrusion (excessive pressure).',
   55, 1,
   '[{"question":"What is the most common root cause of mechanical seal failure?","options":["Wear-out from normal service life","Heat checking and dry running","Impeller imbalance","Cavitation at the volute"],"correctIndex":1},{"question":"What should be done immediately after installing a mechanical seal?","options":["Start the pump at full speed","Hand-rotate the shaft to check for binding","Tighten the gland bolts to full torque","Pressurize the seal chamber"],"correctIndex":1}]');
END $$;

-- Conveyor & Drive Systems course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Conveyor & Drive Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Belt & Chain Conveyors', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Belt Tracking & Tensioning',
   'A mistracking belt causes edge damage, spillage, and premature splice failure. Tracking is adjusted at the tail pulley: move the side the belt is drifting toward slightly forward (in the direction of belt travel). Make small adjustments — 1/4 turn of the take-up bolts at a time — and let the belt run several revolutions before re-evaluating. Tension is set so the belt sags no more than 2% of the center-to-center distance under the heaviest expected load. Over-tensioning loads the bearings and stretches the belt; under-tensioning causes slippage on the drive pulley. Check that the drive pulley lagging is intact — worn lagging is a frequent cause of slip.',
   45, 1,
   '[{"question":"To correct belt drift, which side of the tail pulley should be moved forward?","options":["The side the belt is drifting away from","The side the belt is drifting toward","Both sides equally","Neither — adjust the drive pulley only"],"correctIndex":1}]'),
  (m_id, 'Sprocket & Chain Wear',
   'Chain elongation beyond 2-3% of original pitch indicates replacement is due — beyond this, the chain no longer meshes correctly with the sprocket and accelerates sprocket wear. Measure elongation across a known number of links using a chain gauge. Inspect sprocket teeth for the hooked profile that indicates advanced wear; a worn sprocket will destroy a new chain quickly, so replace both as a set. Lubricate chains at the link joints where pin and bushing contact occurs — not on the outer plate faces. For high-speed or dirty service, use an automatic lubricator set to the manufacturer drip rate.',
   40, 2,
   '[{"question":"At what chain elongation should replacement typically be considered?","options":["0.5%","1%","2-3%","10%"],"correctIndex":2}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Gear Drives', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Gearbox Inspection & Oil Analysis',
   'A gearbox PM starts with an oil sample. Trend wear-metal analysis (Fe, Cu, Cr) and particle count over time — a sudden rise flags active wear before it becomes a failure. Check oil level and condition: milky oil indicates water ingress (often from a breather fault or seal leak), and a burnt smell indicates overheating from overloading or low oil. Inspect the breather — a clogged breather pressurizes the case and forces oil past the seals. Listen for whine (gear mesh issue) and knock (bearing or tooth damage). Record oil temperature; a 15°C rise above baseline warrants investigation.',
   50, 1,
   '[{"question":"What does milky gearbox oil typically indicate?","options":["Overloading","Water ingress","Oxidation","Wrong lubricant grade"],"correctIndex":1},{"question":"What can a clogged gearbox breather cause?","options":["Low oil level","Oil leaks past the seals","Cavitation","Excessive lubrication"],"correctIndex":1}]');
END $$;

-- Precision Measurement course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Precision Measurement & Troubleshooting';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Measurement Tools', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Dial Indicators & Runout',
   'A dial indicator measures small linear displacements, typically to 0.01 mm or 0.001 inch. To measure runout, mount the indicator on a fixed base, bring the contact point against the surface, pre-load the stem 0.2-0.5 mm, and zero the dial. Rotate the shaft one full turn; total indicator reading (TIR) is the sum of the highest and lowest deviations. Runout on a shaft journal should typically be under 0.05 mm for general service. Always indicate on a clean surface — dirt under the contact point produces false readings. For coupling alignment, use two indicators in the reverse-indicator method to account for both shafts.',
   40, 1,
   '[{"question":"What does TIR (total indicator reading) represent?","options":["The average of all readings","The sum of highest and lowest deviations in one revolution","The first reading taken","The difference between two shafts"],"correctIndex":1}]'),
  (m_id, 'Micrometers & Calipers',
   'A micrometer reads to 0.01 mm (or 0.001 inch) using a vernier scale and uses a ratchet stop to apply consistent measuring force — never over-tighten by feel. A caliper is faster but less precise (0.02 mm) and is suitable for rougher work. Always zero-check a micrometer against its standard rod before measuring, and clean the anvils. When measuring a journal, take readings at three angular positions and at two axial positions to detect taper and ovality. Record all readings — a single measurement is an assumption, a set of measurements is data.',
   35, 2,
   '[{"question":"Why does a micrometer use a ratchet stop?","options":["To prevent damage to the thread","To apply consistent measuring force","To speed up measurement","To allow one-handed use"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Soft-Foot & Alignment Checks', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Detecting and Correcting Soft-Foot',
   'Soft-foot occurs when one or more feet of a machine do not sit flat on the base, distorting the frame when the hold-down bolts are tightened. To detect it, place a dial indicator against the foot, loosen the bolt, and observe the lift. Anything over 0.05 mm is actionable. Correct by shimming the gap with stainless shims — never by forcing the bolt down, which bends the frame and can distort the bearing housing. After shimming, re-check all four feet before proceeding to laser alignment. Parallel soft-foot (uniform gap) is shimmed directly; angular soft-foot (wedge gap) may indicate a bent foot or distorted base that requires machining.',
   45, 1,
   '[{"question":"What is the correct way to correct a soft-foot gap?","options":["Torque the bolt harder to pull the foot down","Shim the gap with stainless shims","Grind the base flat","Ignore it if under 0.2 mm"],"correctIndex":1}]');
END $$;

-- Hydraulics & Pneumatics course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Hydraulics & Pneumatics Basics';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Hydraulic Systems', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Pumps, Valves & Actuators',
   'A hydraulic system transmits force via pressurized fluid. The pump converts mechanical energy into fluid flow; the directional valve routes that flow; the actuator (cylinder or motor) converts it back to mechanical work. Gear pumps are simple and robust for medium-pressure service; vane pumps run quieter; piston pumps handle the highest pressures. The relief valve protects the system from overpressure and must be set above the maximum working pressure but below the component rating. Always start a hydraulic system with the relief valve backed off, then bring pressure up slowly while watching for leaks and abnormal noise.',
   50, 1,
   '[{"question":"Which pump type handles the highest pressures?","options":["Gear pump","Vane pump","Piston pump","Screw pump"],"correctIndex":2}]'),
  (m_id, 'Common Hydraulic Failures',
   'Most hydraulic failures trace to contamination — water, air, or particulate. A milky reservoir indicates water (often from condensation or a cooler leak). Foaming indicates air entrainment, often from a low reservoir level or a leaking suction line. A slow-acting cylinder with chattering indicates cavitation or a sticking valve. Filter elements should be changed on a schedule based on particle count, not just hours. ISO 4406 cleanliness codes target 20/18/15 for general industrial hydraulics; servo systems require cleaner fluid.',
   45, 2,
   '[{"question":"What does milky hydraulic fluid indicate?","options":["Air entrainment","Water contamination","Wrong viscosity","Overheating"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Pneumatics & Safety', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Pneumatic Circuits & LOTO for Fluid Power',
   'Pneumatic systems use compressed air — safer than hydraulics in terms of fluid spillage, but stored energy in receivers is still dangerous. Before servicing any fluid power system, follow lockout/tagout: isolate the supply, lock the valve, bleed residual pressure to zero, and verify with a gauge. For pneumatic cylinders, confirm both ports are vented — a cylinder can hold trapped air on the rod side even after the supply is off. Never disconnect a pressurized hose; the whip can cause serious injury. Use the three-way bleed-off valve to safely dump trapped energy.',
   40, 1,
   '[{"question":"What must be done before disconnecting a pneumatic hose?","options":["Tighten the fitting","Isolate supply and bleed pressure to zero","Reduce the compressor output","Cycle the cylinder to empty"],"correctIndex":1}]');
END $$;

-- ===================== ELECTRICAL (free) =====================

INSERT INTO courses (title, description, short_description, stage, tier, difficulty, estimated_hours, sort_order)
VALUES
('Industrial Motor Control Circuits',
 'Read and troubleshoot industrial motor control circuits from the line diagram to the starter. Covers NEMA and IEC contactors, overload protection, control transformers, and common control circuit faults.',
 'Line diagrams, contactors, overloads, and control circuit troubleshooting.',
 'electrical','free','beginner',3,1),
('3-Phase Power Systems & Troubleshooting',
 'Understand 3-phase power distribution in the plant, from the service entrance to the motor terminal box. Covers wye/delta, voltage and current unbalance, and phasing checks.',
 '3-phase distribution, voltage unbalance, and phasing diagnostics.',
 'electrical','free','intermediate',2.5,2),
('VFD Fundamentals & Parameterization',
 'Variable frequency drives from the rectifier to the IGBT output. Learn to wire, start up, and parameterize a VFD, and to diagnose the most common drive faults.',
 'VFD wiring, startup, parameterization, and fault diagnosis.',
 'electrical','free','intermediate',3,3),
('Motor Testing with Megger & PI',
 'Insulation resistance testing and polarization index for motors and generators. Covers test voltages, interpretation, and trending for predictive maintenance.',
 'Megger, polarization index, and insulation resistance trending.',
 'electrical','free','intermediate',2,4),
('Electrical Safety & Arc Flash Awareness',
 'NFPA 70E-oriented electrical safety training. Covers energized work permits, PPE categories, approach boundaries, and lockout/tagout for electrical work.',
 'NFPA 70E boundaries, PPE selection, and energized work permits.',
 'electrical','free','beginner',2,5)
ON CONFLICT DO NOTHING;

-- Motor Control Circuits course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Industrial Motor Control Circuits';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Reading Line Diagrams', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Ladder Logic & Control Schematics',
   'A ladder diagram reads like a book: left-to-right, top-to-bottom. The left rail is L1 (hot), the right rail is L2 (neutral). Each rung is one control function. Components are shown in their de-energized state — contacts that are open when the coil is de-energized are NO (normally open), those closed are NC. The numbering convention places line numbers on the left and references the contact locations on the right of each coil. When troubleshooting, start at the coil that is not pulling in and work backward through the series contacts until you find the open one. A voltmeter across an open contact reads full line voltage; across a closed contact reads zero.',
   50, 1,
   '[{"question":"On a ladder diagram, what does a voltmeter read across an open control contact in an energized circuit?","options":["Zero volts","Half line voltage","Full line voltage","Battery voltage"],"correctIndex":2}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Starters & Overloads', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Magnetic Starters & Overload Protection',
   'A magnetic starter combines a contactor (for switching the motor) and an overload relay (for protecting the motor from sustained overcurrent). The contactor coil is energized by the control circuit; the power contacts carry the motor current. The overload relay does not trip instantly — it is designed to tolerate inrush (typically 6x FLA for a few seconds) and trip on sustained overload. Bimetallic overloads use a heater element and a bimetallic strip; electronic overloads measure current directly and offer class 10/20/30 trip curves. Class 10 trips at 6x FLA in 10 seconds — suitable for submersible pumps; class 20 is standard for general motors.',
   55, 1,
   '[{"question":"Why does an overload relay not trip on motor inrush?","options":["It is designed to tolerate short-duration inrush while tripping on sustained overload","It cannot detect inrush","The contactor shorts it out during start","It is bypassed by the start button"],"correctIndex":0},{"question":"Which overload trip class is standard for general-purpose motors?","options":["Class 10","Class 20","Class 30","Class 5"],"correctIndex":1}]'),
  (m_id, 'Control Circuit Troubleshooting',
   'When a motor will not start, divide the problem into power circuit vs control circuit. First, confirm voltage at the load side of the starter — if present, the problem is the motor or its wiring. If absent, the contactor is not pulling in. Check the control fuse, then the coil voltage. If the coil has voltage but does not pull in, the coil is open. If the coil has no voltage, trace the series path: stop button (NC), start button (NO) or holding contact, overload contact (NC), and any limit/float switches. A jumper across each contact in turn isolates the open one — but never jumper the overload to run a motor, as it defeats the protection.',
   45, 2,
   '[{"question":"If the contactor coil has rated voltage applied but does not pull in, what is the likely fault?","options":["The motor is overloaded","The coil is open","The control fuse is blown","The start button is stuck"],"correctIndex":1}]');
END $$;

-- 3-Phase Power Systems course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='3-Phase Power Systems & Troubleshooting';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, '3-Phase Fundamentals', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Wye & Delta Systems',
   'In a wye (star) system, the line voltage is sqrt(3) times the phase voltage, and line current equals phase current. The neutral point is where the three windings meet. A 480V wye system provides 277V phase-to-neutral — the common lighting circuit voltage. In a delta system, line voltage equals phase voltage, but line current is sqrt(3) times phase current. Delta has no neutral; a corner-grounded delta grounds one phase. Most industrial distribution is 480V wye. When measuring, always confirm phase-to-phase and phase-to-neutral voltages match the expected configuration before connecting equipment.',
   45, 1,
   '[{"question":"What phase-to-neutral voltage does a 480V wye system provide?","options":["240V","277V","480V","120V"],"correctIndex":1},{"question":"In a delta system, what is the relationship between line voltage and phase voltage?","options":["Line voltage is sqrt(3) times phase voltage","Line voltage equals phase voltage","Line voltage is half phase voltage","Line voltage is double phase voltage"],"correctIndex":1}]'),
  (m_id, 'Voltage Unbalance & Phasing',
   'Voltage unbalance between phases causes excessive heating in 3-phase motors — a 3% unbalance can raise motor temperature by 25%. Calculate unbalance as: 100 x (max deviation from average) / average. NEMA recommends keeping unbalance under 1%. Common causes: unbalanced single-phase loads, loose connections, and transformer tap mismatches. Before paralleling two sources or closing a tie breaker, perform a phasing check: measure voltage across corresponding phases — it should read near zero. A reading near full line voltage indicates opposite rotation or wrong phase sequence and will cause a destructive short if closed.',
   40, 2,
   '[{"question":"What is the maximum recommended voltage unbalance per NEMA?","options":["1%","3%","5%","10%"],"correctIndex":0},{"question":"What should a phasing check read across corresponding phases before closing a tie breaker?","options":["Full line voltage","Half line voltage","Near zero","Rated current"],"correctIndex":2}]');
END $$;

-- VFD Fundamentals course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='VFD Fundamentals & Parameterization';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'VFD Theory', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Rectifier, DC Bus & IGBT Output',
   'A VFD has three stages. The rectifier converts incoming AC to DC using a diode bridge (6-pulse is standard; 12-pulse reduces harmonics). The DC bus smooths the rectified waveform using capacitors and, on larger drives, a DC link inductor. The inverter section uses IGBTs to synthesize a variable-frequency, variable-voltage AC output via pulse-width modulation (PWM). The carrier frequency (typically 2-8 kHz) sets the switching rate — higher carrier reduces motor noise but increases drive heating and reflected-wave voltage stress on the motor insulation. Always observe the drive maximum cable length to avoid reflected-wave damage.',
   50, 1,
   '[{"question":"What does the DC bus in a VFD do?","options":["Converts AC to DC","Smooths the rectified DC waveform","Synthesizes the output AC","Measures motor speed"],"correctIndex":1},{"question":"What is the effect of increasing the VFD carrier frequency?","options":["Reduces motor noise but increases drive heating","Reduces drive heating","Has no effect on motor noise","Eliminates the need for a DC bus"],"correctIndex":0}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Startup & Parameters', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Essential Parameters & Auto-Tune',
   'Before starting a drive, set the motor nameplate data: rated voltage, rated current, rated frequency, rated speed (RPM), and power factor. These let the drive model the motor correctly. Then perform an auto-tune (static or rotating) so the drive measures stator resistance and inductance. A rotating tune is more accurate but requires the motor to be uncoupled. Key operating parameters: min/max frequency, acceleration/deceleration ramps, and control mode (V/Hz for multi-motor or centrifugal loads, sensorless vector for constant torque, flux vector with encoder feedback for precision). Set the decel ramp long enough to prevent DC bus overvoltage trips on decelerating high-inertia loads.',
   55, 1,
   '[{"question":"What must be entered into the drive before auto-tuning?","options":["Motor nameplate data","Only the motor voltage","Only the motor current","The carrier frequency"],"correctIndex":0},{"question":"Which control mode is best for constant-torque loads?","options":["V/Hz","Sensorless vector","Voltage boost only","Slip compensation off"],"correctIndex":1}]'),
  (m_id, 'Common VFD Faults',
   'Overvoltage (OV) trips occur on deceleration when regenerative energy overcharges the DC bus — fix by lengthening the decel ramp or adding a brake resistor. Undervoltage (UV) trips occur on voltage sags; check for loose input connections or undersized supply. Overcurrent (OC) trips on sudden load spikes, output shorts, or ground faults — always megger the motor and cable before resetting repeatedly. Ground fault indicates insulation breakdown in the motor or output cable. Overtemperature trips check the drive heatsink — verify cooling fan operation and clean the heatsink fins. Always record the fault code before resetting; repeated resets without diagnosis destroy the drive.',
   45, 2,
   '[{"question":"What typically causes a DC bus overvoltage trip on deceleration?","options":["Regenerative energy from a high-inertia load","A shorted motor winding","A loose input connection","Excessive carrier frequency"],"correctIndex":0}]');
END $$;

-- Motor Testing with Megger & PI course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Motor Testing with Megger & PI';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Insulation Resistance Testing', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Megger Test Procedure & Interpretation',
   'Insulation resistance (IR) testing applies a DC voltage to the motor winding and measures leakage current. Use 500V for motors under 600V rating, 1000V for medium voltage. Test phase-to-ground and phase-to-phase (on the other two phases tied to ground). Minimum acceptable IR per IEEE 43 is 1 megohm plus 1 megohm per kV of rated voltage — but modern epoxy-mica windings should read hundreds of megohms. Always disconnect the drive electronics before testing — a megger will destroy VFD output transistors. Discharge the winding after testing by grounding it for the same duration as the test; stored charge can be lethal.',
   50, 1,
   '[{"question":"What test voltage is used for a 4160V motor?","options":["250V","500V","1000V","5000V"],"correctIndex":2},{"question":"What must be done before meggering a motor driven by a VFD?","options":["Nothing — the drive is isolated by design","Disconnect the drive electronics","Set the drive to zero speed","Ground the DC bus"],"correctIndex":1}]'),
  (m_id, 'Polarization Index & Dielectric Absorption',
   'The polarization index (PI) is the ratio of insulation resistance at 10 minutes to the resistance at 1 minute, under the same test voltage. A PI of 2.0 or greater indicates good insulation; below 1.0 indicates moisture or contamination. The dielectric absorption ratio (DAR, 60s/30s) is a shorter variant. PI trends over time reveal insulation aging — a falling PI is more significant than the absolute megohm value. If the IR is very high (above 5 gigohms), PI is less meaningful and the test can be shortened. Always test with the motor at the same temperature for comparable trends, or correct to 40°C using the IEEE 43 formula.',
   45, 2,
   '[{"question":"What PI value indicates good insulation?","options":["0.5 or greater","1.0 or greater","2.0 or greater","5.0 or greater"],"correctIndex":2},{"question":"What does a PI below 1.0 typically indicate?","options":["Healthy new insulation","Moisture or contamination","Excessive test voltage","A shorted winding"],"correctIndex":1}]');
END $$;

-- Electrical Safety & Arc Flash course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Electrical Safety & Arc Flash Awareness';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'NFPA 70E Boundaries & PPE', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Approach Boundaries',
   'NFPA 70E defines three boundaries around energized equipment. The limited approach boundary is the closest distance an unqualified person may approach. The restricted approach boundary is the closest a qualified person may approach without PPE — crossing it requires arc-rated PPE and an energized work permit. The arc flash boundary is the distance at which incident energy equals 1.2 cal/cm² (the threshold for a second-degree burn). All three are determined from the system voltage and the available fault current and clearing time. The arc flash boundary is often larger than the shock boundaries, which is why arc-rated PPE is required even when the shock hazard seems manageable.',
   50, 1,
   '[{"question":"At what incident energy level is the arc flash boundary defined?","options":["0.5 cal/cm²","1.2 cal/cm²","5 cal/cm²","40 cal/cm²"],"correctIndex":1},{"question":"What is required to cross the restricted approach boundary?","options":["Safety glasses only","Arc-rated PPE and an energized work permit","A hard hat","Insulated gloves only"],"correctIndex":1}]'),
  (m_id, 'PPE Category Selection',
   'Arc-rated PPE is categorized by the arc thermal performance value (ATPV) in cal/cm². Category 1 (4 cal/cm²) requires arc-rated shirt and pants; Category 2 (8 cal/cm²) adds a face shield and balaclava; Category 4 (40 cal/cm²) requires a full arc flash suit. Above 40 cal/cm², work is generally prohibited while energized. PPE must cover all ignitable clothing — non-arc-rated undergarments can melt and cause burns. Insulated gloves are rated for shock protection and must be tested every six months. Leather protectors cover the outer surface of the rubber gloves. Never use gloves past their test date.',
   45, 2,
   '[{"question":"What PPE category corresponds to an incident energy of 8 cal/cm²?","options":["Category 1","Category 2","Category 3","Category 4"],"correctIndex":1},{"question":"How often must insulated rubber gloves be dielectrically tested?","options":["Annually","Every six months","Every two years","Only after an incident"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Energized Work & LOTO', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Energized Work Permits & Lockout/Tagout',
   'Energized work is the exception, not the rule. NFPA 70E requires an energized work permit when a qualified person must work on exposed energized parts, unless the task is minor (voltage testing, thermography). The permit documents the justification, the hazard analysis, the required PPE, and the signatures of the worker and the supervisor. For de-energized work, follow lockout/tagout: identify all energy sources, isolate them, apply locks and tags, verify zero voltage, and release stored energy (capacitors, springs). Each worker applies their own lock — never share. A group lock box is used when multiple workers are involved. The person who applied the lock is the only one who may remove it.',
   40, 1,
   '[{"question":"When is an energized work permit required?","options":["Only for major repairs","When a qualified person must work on exposed energized parts, with minor exceptions","Never — energized work is prohibited","Only above 480V"],"correctIndex":1},{"question":"Who may remove a lock applied during LOTO?","options":["Any supervisor","The person who applied it","The safety manager","Anyone with the key"],"correctIndex":1}]');
END $$;

-- ===================== I&E (premium) =====================

INSERT INTO courses (title, description, short_description, stage, tier, difficulty, estimated_hours, sort_order)
VALUES
('HART Transmitters & Smart Instrumentation',
 'Configure and troubleshoot HART smart transmitters using a handheld communicator. Covers loop integration, device calibration, and digital signal diagnostics for modern process instrumentation.',
 'HART configuration, calibration, and smart transmitter diagnostics.',
 'ie','premium','intermediate',3,1),
('Control Valve Calibration & Diagnostics',
 'Calibrate and diagnose control valves and their positioners. Covers stroke calibration, bench set, valve signature, and diagnosing stiction and hysteresis in service.',
 'Valve stroke calibration, positioner setup, and stiction diagnostics.',
 'ie','premium','intermediate',3,2),
('DeltaV / DCS Fundamentals for Technicians',
 'Navigate a modern distributed control system from the technician perspective. Covers module hierarchy, control strategies, alarms, and troubleshooting on a DeltaV-style system.',
 'DCS module hierarchy, control strategies, and technician-level troubleshooting.',
 'ie','premium','advanced',4,3),
('Fieldbus & Industrial Ethernet Troubleshooting',
 'Troubleshoot Foundation Fieldbus H1 segments and industrial Ethernet networks. Covers segment sizing, terminators, MAC address issues, and managed switch diagnostics.',
 'Fieldbus segment diagnostics and industrial Ethernet troubleshooting.',
 'ie','premium','advanced',3,4),
('Advanced Loop Tuning',
 'Tune process control loops using proven methods. Covers Ziegler-Nichols, lambda tuning, and diagnosing common loop pathologies like stiction and integrator windup.',
 'Ziegler-Nichols, lambda tuning, and diagnosing loop pathologies.',
 'ie','premium','advanced',3,5)
ON CONFLICT DO NOTHING;

-- HART Transmitters course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='HART Transmitters & Smart Instrumentation';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'HART Protocol Basics', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'HART Communication & Loop Integration',
   'HART (Highway Addressable Remote Transducer) overlays a low-frequency digital signal on top of the 4-20 mA analog loop. The digital signal does not interfere with the analog reading because it is a low-level AC signal centered on the 4 mA DC baseline. A HART loop requires a minimum loop resistance of 250 ohms for the communicator to couple to the signal — often provided by the DCS input card or a separate resistor. If the communicator cannot communicate, first check loop resistance, then check that the loop is not grounded at both ends (which shunts the digital signal). The handheld communicator polls for devices at the loop address; the default is address 0 for a single-device loop.',
   50, 1,
   '[{"question":"What minimum loop resistance is required for HART communication?","options":["100 ohms","250 ohms","500 ohms","1000 ohms"],"correctIndex":1},{"question":"Why does the HART digital signal not interfere with the 4-20 mA analog reading?","options":["It is on a separate wire pair","It is a low-level AC signal centered on the 4 mA DC baseline","It uses a different frequency band above 1 kHz","It is filtered by the DCS"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Configuration & Diagnostics', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Calibration & Digital Diagnostics',
   'A HART transmitter stores its sensor limits, range, and trim values. Range setting (URV/LRV) sets the 4 and 20 mA points; sensor trim corrects the transmitter reading against a known standard. The two are distinct — re-ranging does not fix a sensor drift. Use the handheld to verify the loop current matches the process variable and to read the self-diagnostics: most smart transmitters report sensor failure, electronics failure, and out-of-range conditions. Trend the digital process variable alongside the analog current — a discrepancy between the two points to a loop wiring problem, not a transmitter fault. Always document the pre- and post-calibration values in the calibration record.',
   55, 1,
   '[{"question":"What is the difference between range setting and sensor trim?","options":["They are the same operation","Range sets the 4/20 mA points; trim corrects the reading against a standard","Range sets the sensor limits; trim sets the output","There is no difference in practice"],"correctIndex":1}]');
END $$;

-- Control Valve Calibration course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Control Valve Calibration & Diagnostics';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Positioner Setup', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Stroke Calibration & Bench Set',
   'A control valve positioner compares the instrument signal (4-20 mA or 3-15 psi) to the actual valve position and adjusts the actuator pressure to eliminate error. To calibrate, first set the bench set — the actuator spring range that balances the process at the valve seat. Then perform an auto-stroke: the positioner drives the valve from 0 to 100% and learns the open and closed endpoints. Verify the valve travels fully and that the feedback linkage is not binding. A valve that does not reach 0% or 100% has a mechanical stop issue or an undersized actuator. Record the valve signature — the plot of travel vs signal — for future comparison.',
   50, 1,
   '[{"question":"What does a valve positioner do?","options":["Measures flow through the valve","Compares the instrument signal to actual valve position and adjusts actuator pressure","Sets the process pressure","Controls the pump speed"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Valve Diagnostics', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Stiction & Hysteresis Diagnosis',
   'Stiction (static friction) causes a valve to stick until the signal change exceeds the breakaway friction, then jump — producing a limit cycle in the loop. Hysteresis is the difference in travel for the same signal approached from opposite directions, caused by linkage backlash. Both degrade loop performance and are often misdiagnosed as a tuning problem. A valve signature (step response) reveals stiction as a flat region followed by a jump; hysteresis appears as a gap between the upstroke and downstroke curves. Correct stiction by repacking the gland (over-tightened packing is a common cause) or replacing the diaphragm; correct hysteresis by tightening linkage or replacing worn pins.',
   55, 1,
   '[{"question":"What symptom in the loop does valve stiction typically produce?","options":["A slow response","A limit cycle","A steady offset","No effect on the loop"],"correctIndex":1},{"question":"What is a common mechanical cause of stiction?","options":["Undersized actuator","Over-tightened packing","Wrong positioner type","Short signal cable"],"correctIndex":1}]');
END $$;

-- DeltaV / DCS course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='DeltaV / DCS Fundamentals for Technicians';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'DCS Architecture', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Module Hierarchy & Control Strategies',
   'A DCS organizes control into a hierarchy: the control module is the basic unit, containing the function blocks (AI, AO, PID, logic) that implement a single loop or strategy. Modules are assigned to controllers, which scan them at a configured rate. A module references its I/O channels by name, decoupling the logic from the physical wiring. When troubleshooting, first confirm the module is in the correct mode (Auto, Cascade, Manual) — a module in Manual will not respond to its setpoint. Check the block status for Bad, Out of Service, or Uncertain tags, which propagate up the hierarchy and suppress control action.',
   60, 1,
   '[{"question":"What is the basic unit of control in a DCS?","options":["The controller","The function block","The control module","The I/O card"],"correctIndex":2},{"question":"What happens if a module is in Manual mode?","options":["It follows its setpoint","It does not respond to its setpoint","It alarms","It shuts down the controller"],"correctIndex":1}]'),
  (m_id, 'Alarms & Operator Interface',
   'A well-configured DCS alarm system shows only meaningful alarms. Alarm rationalization assigns priority and suppression logic so that during an upset the operator is not flooded. A common pathology is alarm flooding — hundreds of low-priority alarms masking the one that matters. As a technician, learn to read the alarm summary chronologically and to use the trend display to correlate events. When a field device alarms, verify the field value against the DCS reading before acting — a wiring fault can make a healthy device appear failed on the HMI. Never silence an alarm without understanding its cause; silenced alarms are routinely missed.',
   50, 2,
   '[{"question":"What is alarm flooding?","options":["Too many high-priority alarms","Hundreds of low-priority alarms masking the meaningful one","An alarm that repeats every second","An alarm with no cause"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Troubleshooting', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Field-to-DCS Troubleshooting',
   'When a loop misbehaves, divide the problem into field, I/O, and logic. First, confirm the field device: stroke the valve or drive the transmitter signal from the field and observe the DCS response. If the DCS does not see the change, the problem is in the I/O channel or wiring — check the channel assignment, the fuse, and the loop power. If the DCS sees the field value but the output does not respond, the problem is in the control strategy — verify the module mode and the cascade path. Use the DCS built-in diagnostic tools to read channel-level health. Document the fault and the corrective action in the CMMS for trend analysis.',
   55, 1,
   '[{"question":"What is the first step in field-to-DCS troubleshooting?","options":["Reboot the controller","Confirm the field device by driving its signal from the field","Check the control logic","Replace the I/O card"],"correctIndex":1}]');
END $$;

-- Fieldbus & Industrial Ethernet course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Fieldbus & Industrial Ethernet Troubleshooting';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Foundation Fieldbus H1', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Segment Sizing & Terminators',
   'A Foundation Fieldbus H1 segment is a digital bus running at 31.25 kbit/s over the same twisted-pair cable that once carried 4-20 mA. Each segment requires exactly two terminators — one at each end — to prevent signal reflection. A missing or extra terminator is the most common segment fault. The segment power supply must provide a steady DC voltage (typically 24V) with the digital signal riding on top; a conditioned power supply with a terminator built in is standard. Segment sizing is limited by voltage drop (each device draws 10-20 mA) and by the MAC address count — a segment supports up to 16 devices in spur topology, more in tree. Always draw the segment layout including cable length and device current before commissioning.',
   55, 1,
   '[{"question":"How many terminators does a Fieldbus H1 segment require?","options":["One","Exactly two","Four","One per device"],"correctIndex":1},{"question":"What is the most common Fieldbus segment fault?","options":["A shorted cable","A missing or extra terminator","Too much signal voltage","An incorrect MAC address"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Industrial Ethernet', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Managed Switch Diagnostics',
   'Industrial Ethernet uses managed switches that report port-level diagnostics. When a device drops off the network, first check the switch port status: link, speed, duplex. A duplex mismatch (one side full, the other half) produces intermittent errors and slow throughput — always force both ends to the same setting or rely on auto-negotiation on both. Use the switch management interface to view error counters: FCS errors indicate cable or connector issues, alignment errors indicate speed mismatch, and late collisions indicate a duplex problem. For redundancy, use the Rapid Spanning Tree Protocol (RSTP) and verify the configured root bridge. A misconfigured root bridge can cause traffic to take a suboptimal path and saturate a link.',
   50, 1,
   '[{"question":"What do FCS errors on a switch port typically indicate?","options":["A duplex mismatch","A cable or connector issue","A speed mismatch","A MAC address conflict"],"correctIndex":1},{"question":"What does a duplex mismatch produce?","options":["Total link failure","Intermittent errors and slow throughput","A network loop","Spanning tree reconvergence"],"correctIndex":1}]');
END $$;

-- Advanced Loop Tuning course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Advanced Loop Tuning';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Tuning Methods', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Ziegler-Nichols & Lambda Tuning',
   'Ziegler-Nichols tuning puts the controller in manual, increases gain until the loop oscillates steadily, then records the ultimate gain (Ku) and the oscillation period (Pu). The PID settings are then Kp=0.6Ku, Ti=Pu/2, Td=Pu/8. ZN gives aggressive response and 1/4 wave decay — good for startup but often too aggressive for steady-state. Lambda tuning targets a closed-loop time constant (lambda) as a multiple of the open-loop time constant. A lambda of 3x gives a smooth, robust response suitable for flow and pressure loops; a lambda of 1x is faster but less robust to gain changes. Always verify the model by bump-testing the process before applying any tuning.',
   60, 1,
   '[{"question":"In Ziegler-Nichols tuning, what is Ku?","options":["The process gain","The ultimate gain at which the loop oscillates steadily","The integral time","The derivative time"],"correctIndex":1},{"question":"What does a lambda of 3x the open-loop time constant give?","options":["Aggressive response","A smooth, robust response","Oscillatory response","No response"],"correctIndex":1}]'),
  (m_id, 'Loop Pathologies',
   'A loop that oscillates is not always poorly tuned. Before re-tuning, check for stiction (the valve sticks and jumps — the oscillation has a flat-top square wave shape), hysteresis (the oscillation amplitude changes with direction), and integrator windup (the integral saturates after a setpoint change and overshoots). Stiction is a mechanical problem — no amount of tuning fixes it; repack or replace the valve. Integrator windup is addressed by enabling anti-windup or by reducing integral action. A loop that is sluggish may be over-tuned (gain too low) or the process may have changed — re-identify the model. Trend the PV, SP, and output together to diagnose.',
   50, 2,
   '[{"question":"What shape does a stiction-induced oscillation typically have?","options":["A smooth sine wave","A flat-top square wave","A decaying exponential","A step response"],"correctIndex":1},{"question":"What is the correct fix for valve stiction?","options":["Increase the controller gain","Decrease the integral time","Repack or replace the valve — tuning will not fix it","Add a filter to the measurement"],"correctIndex":2}]');
END $$;

-- ===================== ENGINEERING (premium) =====================

INSERT INTO courses (title, description, short_description, stage, tier, difficulty, estimated_hours, sort_order)
VALUES
('PLC Programming Best Practices (Logix-style)',
 'Structured, maintainable PLC programming in a Logix-style environment. Covers tag naming, program organization, AOIs, and safety routines for industrial control.',
 'Tag naming, AOIs, program structure, and maintainable PLC code.',
 'engineering','premium','advanced',4,1),
('System Architecture & Network Design',
 'Design robust industrial control system architectures. Covers controller selection, network segmentation, redundancy, and the Purdue model for OT security.',
 'Controller selection, network segmentation, redundancy, OT security.',
 'engineering','premium','advanced',3.5,2),
('Reliability Engineering & Predictive Maintenance Strategy',
 'Build a reliability program from failure modes to predictive maintenance. Covers FMEA, Weibull analysis, condition monitoring, and KPIs like MTBF and OEE.',
 'FMEA, Weibull analysis, condition monitoring, and reliability KPIs.',
 'engineering','premium','advanced',4,3),
('Advanced Motion & Safety Systems',
 'Integrated motion control and functional safety. Covers coordinated motion, safety PLCs, SIL determination, and safety function design to IEC 62061 / ISO 13849.',
 'Coordinated motion, safety PLCs, SIL determination, safety function design.',
 'engineering','premium','advanced',3.5,4)
ON CONFLICT DO NOTHING;

-- PLC Programming Best Practices course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='PLC Programming Best Practices (Logix-style)';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Program Structure', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Tag Naming & Program Organization',
   'A maintainable PLC program starts with a consistent tag naming convention. A common scheme is Area_Subsystem_Device_Attribute, e.g., FILL_TANK101_PUMP_START. Use base tags for physical I/O and aliases or user-defined types (UDTs) for equipment modules. Organize the program into tasks: the main task for continuous control, periodic tasks for fast logic, and event tasks for fault response. Within each task, group routines by equipment area, and use a routine for each functional unit (a pump, a valve, a station). Keep safety logic in a dedicated, safety-certified routine that cannot be bypassed by the main program. Document each routine with a header comment stating its purpose and the last revision.',
   55, 1,
   '[{"question":"What is a common tag naming convention for PLC programs?","options":["Random short names","Area_Subsystem_Device_Attribute","Sequential numbers only","Single-letter prefixes"],"correctIndex":1},{"question":"Where should safety logic reside in a PLC program?","options":["Inline with the main logic","In a dedicated, safety-certified routine","In the HMI","In a periodic task"],"correctIndex":1}]'),
  (m_id, 'Add-On Instructions (AOIs)',
   'An Add-On Instruction encapsulates a reusable block of logic with defined inputs, outputs, and local tags. AOIs promote consistency — every instance of a motor start/stop block behaves identically. Define the AOI signature carefully: inputs and outputs become the interface; local tags are private to each instance. Use enable-in and enable-out pins to allow logic to short-circuit when upstream logic is false. Provide a logic routine and an optional faceplate for the HMI. Version AOIs and document changes; a change to the AOI definition propagates to every instance, so test thoroughly before releasing. Avoid AOIs for one-off logic — they add overhead without reuse benefit.',
   50, 2,
   '[{"question":"What is the primary benefit of Add-On Instructions?","options":["They run faster than inline logic","They promote consistency across every instance","They eliminate the need for tags","They bypass safety logic"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Safety Routines & Fault Handling', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Fault Handling & Recovery',
   'A robust PLC program detects faults, places the equipment in a safe state, and provides the operator with actionable diagnostics. Implement a fault routine that latches each fault, drives a common fault bit, and de-energizes the outputs for the affected zone. Use a first-scan bit to initialize outputs to a known state on power-up. Provide an operator reset that clears latched faults only after the fault condition has cleared (permissive-based reset). Never auto-reset a fault — require an operator action so the fault is acknowledged. Log faults to the HMI with a timestamp and a descriptive message; trend fault frequency to identify recurring issues that warrant a design change.',
   55, 1,
   '[{"question":"What should a fault routine do first?","options":["Log the fault","Latch the fault and drive the equipment to a safe state","Reset the PLC","Notify maintenance by email"],"correctIndex":1},{"question":"Why should faults require an operator action to reset?","options":["To slow down the process","To ensure the fault is acknowledged","To reduce PLC scan time","To clear the log automatically"],"correctIndex":1}]');
END $$;

-- System Architecture & Network Design course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='System Architecture & Network Design';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Architecture & Segmentation', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'The Purdue Model & OT Security',
   'The Purdue model segments an industrial network into levels: Level 0 (field devices), Level 1 (basic control — PLCs), Level 2 (supervisory — SCADA/DCS), Level 3 (site operations), Level 3.5 (industrial DMZ), and Levels 4-5 (enterprise IT and internet). The industrial DMZ is the critical boundary: no direct traffic flows between enterprise and plant floor. A firewall at Level 3.5 brokers controlled access — historians, jump hosts, and patch servers live here. Never place a direct route from the enterprise to a PLC. This segmentation contains a breach in IT from reaching OT, and vice versa. Map every connection across the boundary and justify it against the business need.',
   60, 1,
   '[{"question":"What is the purpose of the industrial DMZ (Level 3.5)?","options":["To speed up enterprise access to PLCs","To broker controlled access between enterprise and plant floor with no direct route","To replace the PLC network","To host the ERP system"],"correctIndex":1}]'),
  (m_id, 'Redundancy & Controller Selection',
   'Redundancy is justified by the cost of downtime, not by default. A redundant controller pair uses a high-speed sync module to mirror the primary program; on primary failure, the secondary takes over within a scan. Redundancy adds complexity — the sync link, the redundancy logic, and the switchover diagnostics all require maintenance. For networks, redundant rings (Device Level Ring, DLR) recover in under 3 ms for 50 nodes. Select a controller by I/O count, scan time requirement, memory, and communication ports — not by the next size up "just in case." Over-specification inflates cost and spare parts inventory. Document the redundancy strategy and the expected failover behavior so operators know what to expect during a switchover.',
   55, 2,
   '[{"question":"What justifies the cost of controller redundancy?","options":["The cost of downtime","The size of the plant","The number of operators","The age of the equipment"],"correctIndex":0}]');
END $$;

-- Reliability Engineering course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Reliability Engineering & Predictive Maintenance Strategy';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Failure Analysis', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'FMEA & Failure Modes',
   'A Failure Modes and Effects Analysis (FMEA) systematically lists each component, its failure modes, the effects of each failure, and the severity, occurrence, and detection ratings. The risk priority number (RPN = severity x occurrence x detection) ranks the actions. A high-severity, low-occurrence failure (e.g., a burst pressure vessel) may have a low RPN but still demand action — severity alone can drive the work. The FMEA is a living document: update it after every failure investigation. Use it to drive the PM strategy: high-occurrence modes get preventive maintenance, high-severity modes get predictive monitoring or redesign.',
   55, 1,
   '[{"question":"What is the RPN in an FMEA?","options":["Risk Priority Number = severity x occurrence x detection","Reliability Performance Number","Remaining Part Number","Random Probability Number"],"correctIndex":0},{"question":"What should drive action even when the RPN is low?","options":["Nothing — RPN is the only metric","High severity alone","Low detection rating","High occurrence"],"correctIndex":1}]'),
  (m_id, 'Weibull Analysis',
   'Weibull analysis fits a statistical distribution to failure data to predict future failures. The shape parameter (beta) reveals the failure pattern: beta < 1 indicates infant mortality (decreasing failure rate), beta = 1 indicates random failure (constant rate), beta > 1 indicates wear-out (increasing rate). A wear-out pattern (beta > 1) justifies time-based replacement; a random pattern (beta = 1) argues against scheduled replacement and for condition monitoring. Weibull requires enough failure data points — at least 5-10 — to be meaningful. For low-volume equipment, combine data from similar assets. Always plot the fit and check the correlation; a poor fit means the assumed distribution is wrong.',
   50, 2,
   '[{"question":"What does a Weibull beta greater than 1 indicate?","options":["Infant mortality","Random failure","Wear-out (increasing failure rate)","No failures"],"correctIndex":2},{"question":"What maintenance strategy fits a random failure pattern (beta = 1)?","options":["Time-based replacement","Condition monitoring","Run to failure only","Increased PM frequency"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Predictive Maintenance & KPIs', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Condition Monitoring & KPIs',
   'Condition monitoring uses sensors (vibration, oil analysis, thermography, ultrasound) to detect degradation before failure. Vibration analysis is the workhorse for rotating equipment — trend the overall velocity and the spectrum; a rising 1x component indicates imbalance, 2x indicates misalignment, and bearing-frequency components indicate bearing wear. Oil analysis trends wear metals and contaminants. Thermography finds hot connections and blocked cooling. KPIs: MTBF (mean time between failures) measures reliability; MTTR (mean time to repair) measures maintainability; OEE (overall equipment effectiveness = availability x performance x quality) measures production effectiveness. Trend these monthly; a falling MTBF or rising MTTR signals a reliability problem before it becomes a downtime event.',
   55, 1,
   '[{"question":"What does a rising 2x vibration component typically indicate?","options":["Imbalance","Misalignment","Bearing wear","Loose foundation"],"correctIndex":1},{"question":"What three factors make up OEE?","options":["Availability x performance x quality","MTBF x MTTR x downtime","Speed x load x efficiency","Cost x time x labor"],"correctIndex":0}]');
END $$;

-- Advanced Motion & Safety Systems course
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Advanced Motion & Safety Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Integrated Motion', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Coordinated Motion & Camming',
   'Coordinated motion synchronizes multiple axes to a master reference. In electronic gearing, a slave axis follows a master at a fixed ratio; in camming, the slave follows a non-linear position profile defined by a cam table. Camming replaces mechanical cams with software, allowing on-the-fly profile changes. When commissioning, first tune each axis individually, then enable the master and verify the slave tracks without following error. A high following error during the move indicates a tuning or load problem; a high error at the transition points indicates a discontinuity in the cam profile. Use a motion analyzer to plot the velocity and acceleration and confirm they stay within the machine limits.',
   55, 1,
   '[{"question":"What does electronic gearing do?","options":["Synchronizes a slave axis to a master at a fixed ratio","Replaces the motor","Measures following error","Tunes the servo loop"],"correctIndex":0},{"question":"What does a high following error at cam transition points indicate?","options":["A tuning problem","A discontinuity in the cam profile","An oversized motor","A loose coupling"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Functional Safety', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'SIL Determination & Safety Functions',
   'Functional safety is the active reduction of risk using safety-rated systems. A safety function is the combination of sensor, logic solver, and final element that brings the machine to a safe state on demand. The Safety Integrity Level (SIL 1-4) is the required risk reduction; SIL determination methods (risk graph, LOPA) assign the SIL based on the severity, frequency, and avoidance of the hazard. A safety PLC executes the safety logic with redundant, monitored hardware and a certified operating system. The achieved SIL of the function is limited by its weakest element — a SIL 3 logic solver with a SIL 1 relay achieves SIL 1. Verify the proof test interval for each element; an overdue proof test invalidates the SIL claim.',
   60, 1,
   '[{"question":"What limits the achieved SIL of a safety function?","options":["The logic solver alone","The weakest element in the function","The number of sensors","The software version"],"correctIndex":1},{"question":"What invalidates a SIL claim?","options":["A software update","An overdue proof test","A new risk assessment","Adding more sensors"],"correctIndex":1}]');
END $$;
