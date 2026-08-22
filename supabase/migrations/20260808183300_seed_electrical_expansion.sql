/*
# Seed ForgeLine catalog — Electrical Maintenance expansion (17 new courses)

## Overview
Adds 17 new free Electrical Maintenance courses to the catalog, expanding the
free Electrical track from 5 to 22 courses. Each course has 2-3 modules with
2-3 lessons, professional plant-floor content, and at least one knowledge-check
quiz per lesson. No existing courses are modified.

## Courses added (sort_order 6-22)
1. Motor Starters, Contactors & Overload Relays (6)
2. Control Transformers & 24V Control Circuits (7)
3. Grounding, Bonding & Equipment Grounding Conductors (8)
4. Conduit, Cable Tray & Industrial Wiring Methods (9)
5. Electrical Troubleshooting Methodology (10)
6. Soft Starters & Reduced Voltage Starting (11)
7. Industrial Panel Building & Layout (12)
8. UPS Systems, Batteries & Backup Power (13)
9. Hazardous Location Electrical Installations (14)
10. Motor Protection & Overcurrent Devices (15)
11. Variable Frequency Drive Installation & Commissioning (16)
12. Electrical Prints, Schematics & Ladder Diagrams (17)
13. Lighting Systems, Ballasts & LED Retrofits (18)
14. Power Quality Basics (19)
15. Temporary Power & Construction Electrical (20)
16. Electrical Safety Programs & NFPA 70E Application (21)
17. Testing & Commissioning of Electrical Equipment (22)

## Security
No schema or policy changes. INSERT is allowed only for service role / SQL execution.

## Notes
1. Uses ON CONFLICT DO NOTHING keyed on (stage, title) so re-running is safe.
2. Each DO $$ block looks up the course by (stage, title) and returns early if not found.
3. Quizzes are JSON arrays: [{question, options:[...], correctIndex:0}].
*/

INSERT INTO courses (title, description, short_description, stage, tier, difficulty, estimated_hours, sort_order)
VALUES
('Motor Starters, Contactors & Overload Relays',
 'Deep dive into motor starters, contactors, and overload relays for industrial applications. Covers NEMA vs IEC contactors, selection criteria, overload class selection, arc suppression, and troubleshooting contactor failures.',
 'NEMA vs IEC contactors, overload classes, and contactor troubleshooting.',
 'electrical','free','beginner',2.5,6),
('Control Transformers & 24V Control Circuits',
 'Design and troubleshoot 24V control circuits powered by step-down transformers. Covers transformer sizing, fuse selection, inrush, voltage drop, and common control circuit faults in industrial panels.',
 'Control transformer sizing, fuse selection, and 24V circuit troubleshooting.',
 'electrical','free','beginner',2,7),
('Grounding, Bonding & Equipment Grounding Conductors',
 'Industrial grounding and bonding per NEC Article 250. Covers grounding electrode systems, equipment grounding conductors, bonding jumpers, ground fault current paths, and testing ground resistance.',
 'NEC 250 grounding, bonding, EGC sizing, and ground resistance testing.',
 'electrical','free','intermediate',2.5,8),
('Conduit, Cable Tray & Industrial Wiring Methods',
 'Industrial wiring methods including rigid conduit, EMT, cable tray, and tray cable. Covers conduit bending, fill calculations, cable tray fill rules, and NEC Chapter 3 requirements for industrial installations.',
 'Conduit bending, fill calculations, cable tray, and NEC Chapter 3 wiring methods.',
 'electrical','free','intermediate',3,9),
('Electrical Troubleshooting Methodology',
 'Systematic approach to electrical troubleshooting in industrial environments. Covers the half-split method, voltage drop testing, current measurement, and building a diagnostic decision tree for fast fault isolation.',
 'Half-split method, voltage drop testing, and systematic fault isolation.',
 'electrical','free','intermediate',2.5,10),
('Soft Starters & Reduced Voltage Starting',
 'Reduced voltage starting methods for large motors. Covers autotransformer, star-delta, and solid-state soft starters, starting torque, current limiting, and selecting the right method for the load.',
 'Autotransformer, star-delta, and solid-state soft starter selection and setup.',
 'electrical','free','intermediate',2.5,11),
('Industrial Panel Building & Layout',
 'Build and wire industrial control panels per NEC and UL 508A. Covers component placement, wire sizing, bundling, labeling, door interlocks, and panel inspection for compliance and maintainability.',
 'UL 508A panel layout, wire sizing, bundling, labeling, and compliance.',
 'electrical','free','intermediate',3,12),
('UPS Systems, Batteries & Backup Power',
 'Maintain uninterruptible power supplies and battery systems for critical industrial loads. Covers UPS topologies, battery types, capacity testing, battery room safety, and preventive maintenance.',
 'UPS topologies, battery testing, capacity planning, and battery room safety.',
 'electrical','free','intermediate',2.5,13),
('Hazardous Location Electrical Installations',
 'Electrical installations in hazardous (classified) locations per NEC Articles 500-504. Covers Class I/II/III, Division/Zone systems, explosionproof equipment, intrinsic safety, and sealing requirements.',
 'NEC 500 hazardous locations, explosionproof equipment, and intrinsic safety.',
 'electrical','free','advanced',3,14),
('Motor Protection & Overcurrent Devices',
 'Motor protection devices including fuses, circuit breakers, MCPs, and electronic motor protection relays. Covers coordination, short-circuit protection, overload protection, and NEC 430 requirements.',
 'Fuses, MCPs, circuit breakers, coordination, and NEC 430 motor protection.',
 'electrical','free','intermediate',2.5,15),
('Variable Frequency Drive Installation & Commissioning',
 'Practical VFD installation and commissioning beyond parameterization. Covers wiring, EMC considerations, motor cable selection, control wiring, startup procedure, and hand-off to operations.',
 'VFD wiring, EMC, motor cable selection, startup, and commissioning hand-off.',
 'electrical','free','intermediate',3,16),
('Electrical Prints, Schematics & Ladder Diagrams',
 'Read and interpret industrial electrical drawings. Covers one-line diagrams, ladder logic schematics, wiring diagrams, terminal block drawings, and cross-referencing between documents for troubleshooting.',
 'One-line diagrams, ladder schematics, wiring diagrams, and cross-referencing.',
 'electrical','free','beginner',2.5,17),
('Lighting Systems, Ballasts & LED Retrofits',
 'Industrial lighting maintenance and LED retrofit. Covers HID, fluorescent, and LED systems, ballast replacement, photometric considerations, and energy savings calculations for retrofit projects.',
 'HID, fluorescent, LED systems, ballast replacement, and retrofit calculations.',
 'electrical','free','beginner',2,18),
('Power Quality Basics',
 'Fundamentals of power quality in industrial facilities. Covers harmonics, voltage sags, swells, flicker, power factor, IEEE 519 limits, and mitigation strategies using filters and correction equipment.',
 'Harmonics, sags, swells, flicker, power factor, and IEEE 519 mitigation.',
 'electrical','free','intermediate',2.5,19),
('Temporary Power & Construction Electrical',
 'Safe temporary power distribution for construction and maintenance. Covers GFCI requirements, temporary wiring rules, generator sizing, spider boxes, and OSHA 1926 Subpart K electrical safety.',
 'Temporary wiring, GFCI, generator sizing, and OSHA 1926 Subpart K safety.',
 'electrical','free','beginner',2,20),
('Electrical Safety Programs & NFPA 70E Application',
 'Building and implementing an electrical safety program per NFPA 70E and OSHA. Covers the safety program elements, job briefings, energized work permits, audit requirements, and incident investigation.',
 'NFPA 70E safety program elements, job briefings, permits, and audits.',
 'electrical','free','intermediate',2.5,21),
('Testing & Commissioning of Electrical Equipment',
 'Acceptance testing and commissioning of electrical equipment. Covers insulation resistance, contact resistance, transformer turns ratio, primary injection, and NETA acceptance testing standards.',
 'Insulation resistance, contact resistance, TTR, and NETA acceptance testing.',
 'electrical','free','advanced',3,22)
ON CONFLICT DO NOTHING;

-- ===================== Motor Starters, Contactors & Overload Relays =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Motor Starters, Contactors & Overload Relays';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Contactor Selection & Application', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'NEMA vs IEC Contactors',
   'NEMA and IEC contactors serve the same function but differ in sizing philosophy. NEMA contactors are oversized by design — a NEMA Size 1 is rated for 30A continuous and can start a 10HP motor at 460V. They are built for rugged, long-life service and tolerate frequent operation. IEC contactors are sized to the exact motor FLA with a utilization category (AC-3 for squirrel cage motors, AC-4 for plugging and inching). They are smaller, cheaper, but less tolerant of overload and require more careful selection. The key difference: a NEMA contactor can run at its rated current indefinitely; an IEC contactor is rated for its current at a specific duty cycle and operating condition. When replacing a failed contactor, verify the coil voltage, the contact rating (continuous and inrush), the number of auxiliary contacts, and the mechanical interlock if reversing. Always inspect the contacts for pitting and erosion — a contactor with eroded contacts has high resistance, causing motor undervoltage and overheating.',
   50, 1,
   '[{"question":"How is a NEMA contactor sized compared to an IEC contactor?","options":["NEMA is oversized for rugged service; IEC is sized to exact FLA with a utilization category","They are sized identically","NEMA is smaller; IEC is larger","NEMA uses amps; IEC uses horsepower"],"correctIndex":0},{"question":"What does AC-3 utilization category indicate for an IEC contactor?","options":["Resistive loads","Squirrel cage motor starting and running","Plugging and inching","Lighting loads"],"correctIndex":1}]'),
  (m_id, 'Arc Suppression & Contact Life',
   'When a contactor opens under load, the current draws an arc between the contacts. The arc erodes the contact material — each operation removes a small amount. Arc suppressors (RC snubbers for AC, magnetic blowouts for DC) reduce the arc duration and extend contact life. The contact wear is proportional to the current squared times the arc duration — so a contactor opening under full motor current wears much faster than one opening under no load. For motors that start and stop frequently (more than 10 times per hour), select a contactor with a higher current rating or a contactor designed for high operation frequency. Inspect the contacts annually: a contact surface that is smooth and silver-colored is healthy; a pitted, blackened surface is worn and approaching failure. Measure the contact resistance with a low-resistance ohmmeter — more than 50 milliohms across a closed contact indicates wear that warrants replacement. Never file contacts — it removes the silver oxide layer and accelerates wear.',
   45, 2,
   '[{"question":"What should never be done to worn contactor contacts?","options":["Clean with solvent","File them — it removes the silver oxide layer","Measure resistance","Replace them"],"correctIndex":1},{"question":"What indicates a healthy contactor contact surface?","options":["Pitted and blackened","Smooth and silver-colored","Rough and brown","Green and corroded"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Overload Relays', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Overload Class Selection & Troubleshooting',
   'Overload relays protect the motor from sustained overcurrent that would overheat the insulation. The trip class defines how long the overload tolerates a specific overload: Class 10 trips at 6x FLA in 10 seconds (for submersible pumps and hermetic compressors that cannot tolerate heat), Class 20 trips in 20 seconds (standard for general-purpose motors), and Class 30 trips in 30 seconds (for high-inertia loads like fans and centrifuges that have long acceleration times). Bimetallic overloads use a heater element and a bimetallic strip that bends with heat to trip the contact. Electronic overloads measure current directly with a Hall effect sensor and offer adjustable trip class, phase loss protection, and ground fault detection. Phase loss (single-phasing) causes the motor to draw excessive current on the remaining phases — an electronic overload detects this within seconds and trips, saving the motor. When an overload trips, investigate the cause before resetting: check the motor current with a clamp meter, verify the overload is sized to the motor FLA (not the next size up), and check for a phase loss or voltage unbalance. Repeated trips without diagnosis destroy the motor.',
   50, 1,
   '[{"question":"Which overload trip class is used for high-inertia loads like fans?","options":["Class 10","Class 20","Class 30","Class 5"],"correctIndex":2},{"question":"What does an electronic overload detect that a bimetallic overload does not?","options":["Overcurrent","Phase loss and ground fault","Short circuit","Voltage sag"],"correctIndex":1}]');
END $$;

-- ===================== Control Transformers & 24V Control Circuits =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Control Transformers & 24V Control Circuits';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Transformer Sizing & Selection', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Control Transformer Sizing & Inrush',
   'A control transformer steps down the line voltage (typically 480V or 240V) to 24V for the control circuit. Sizing must account for both the continuous load (the sealed VA of all energized coils) and the inrush (the pull-in VA of the largest contactor that starts simultaneously). The transformer must supply the inrush without the secondary voltage dropping below 85% of rated — if it does, the contactor may not pull in or may chatter and weld the contacts. The rule of thumb: size the transformer VA at 2-3 times the sealed VA to handle the inrush, or use the manufacturer inrush/sealed VA charts. A transformer that is too small causes voltage sag on startup; a transformer that is too large has a higher available fault current that can damage the control circuit wiring. Fuse the primary with time-delay fuses (to tolerate the inrush) and the secondary with fast-acting fuses (to protect the control wiring). Verify the primary and secondary voltages with a meter after installation — a mis-wired primary (240V on a 480V tap) produces 12V on the secondary and the controls will not work.',
   50, 1,
   '[{"question":"Why must a control transformer be sized for inrush as well as continuous load?","options":["To save energy","To supply the pull-in VA without the secondary voltage dropping below 85%","To reduce heat","To improve power factor"],"correctIndex":1},{"question":"What type of fuse is used on the primary of a control transformer?","options":["Fast-acting","Time-delay (to tolerate inrush)","No fuse","High-voltage"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Control Circuit Troubleshooting', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Voltage Drop & Ground Fault Diagnosis',
   'A 24V control circuit is susceptible to voltage drop on long wire runs — a 5% drop (1.2V) at the end of a 200-foot run can cause a contactor to chatter. Size the wire for the load and the distance: 14 AWG for runs under 100 feet, 12 AWG for longer runs. A ground fault in the control circuit causes a fuse to blow or a GFCI to trip. To find a ground fault, disconnect the circuit at the transformer and use an insulation tester (megger at 250V for 24V circuits) between each wire and ground. The fault is in the wire or device that reads low resistance to ground. A more practical method: with the power on, measure the voltage from each side of the circuit to ground — on a healthy circuit, one side reads 24V to ground and the other reads 0V. If both sides read some voltage, there is a ground fault. Isolate sections by disconnecting devices until the fault clears, then repair the faulted section. Always replace the fuse with the correct rating — a larger fuse does not fix the problem, it causes a fire.',
   45, 1,
   '[{"question":"What voltage drop on a 24V circuit can cause contactor chatter?","options":["0.1V","1.2V (5%)","5V","10V"],"correctIndex":1},{"question":"On a healthy 24V control circuit, what does each side read to ground?","options":["Both read 12V","One reads 24V, the other reads 0V","Both read 24V","Both read 0V"],"correctIndex":1}]');
END $$;

-- ===================== Grounding, Bonding & Equipment Grounding Conductors =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Grounding, Bonding & Equipment Grounding Conductors';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Grounding Fundamentals', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'NEC Article 250 & Grounding Electrode Systems',
   'NEC Article 250 governs grounding and bonding. The grounding electrode system connects the electrical system to earth — it includes ground rods, building steel, water pipes (within 5 feet of the entrance), and concrete-encased electrodes (Ufer grounds). The main bonding jumper connects the grounded conductor (neutral) to the grounding electrode system at the service entrance — this is the only place where the neutral and ground are bonded. Downstream, the neutral and ground are kept separate to prevent ground fault current from flowing on the ground conductor and energizing equipment frames. The equipment grounding conductor (EGC) provides the fault current return path — it must be sized per NEC Table 250.122 based on the overcurrent device rating. A properly sized EGC allows enough fault current to trip the breaker instantly; an undersized EGC has high impedance, the breaker may not trip, and the equipment frame stays energized. The most common grounding defect is an open neutral at the service entrance, which causes the neutral to float and the line-to-neutral voltages to swing wildly.',
   50, 1,
   '[{"question":"Where is the only place the neutral and ground are bonded?","options":["At each subpanel","At the service entrance","At the transformer","At each motor"],"correctIndex":1},{"question":"What is the most common grounding defect at a service entrance?","options":["A ground rod that is too short","An open neutral","A missing GFCI","An oversized EGC"],"correctIndex":1}]'),
  (m_id, 'Equipment Grounding & Bonding Jumpers',
   'Bonding connects non-current-carrying metal parts to place them at the same potential — it eliminates voltage differences that could cause a shock. Bonding jumpers connect metal raceways, cable trays, and equipment enclosures to the EGC. A loose or corroded bonding jumper is a common defect — it creates a high-impedance path that does not clear faults quickly. Inspect bonding jumpers during PMs: verify the connection is clean, tight, and corrosion-free. Use a bonding tester (low-resistance ohmmeter) to verify the impedance is under 0.1 ohm between the equipment frame and the system ground. For motor circuits, the EGC must be run with the circuit conductors in the same raceway — this keeps the impedance low by magnetic coupling. A separate ground path (e.g., through building steel) has higher impedance and may not clear the fault. For VFD circuits, follow the drive manufacturer grounding requirements — many require a flat-braided ground conductor (not round) to reduce high-frequency impedance and prevent bearing current damage to the motor.',
   45, 2,
   '[{"question":"What is the maximum impedance between an equipment frame and system ground?","options":["1 ohm","0.1 ohm","10 ohms","100 ohms"],"correctIndex":1},{"question":"Why must the EGC be run in the same raceway as the circuit conductors?","options":["To save conduit","To keep the impedance low by magnetic coupling","For appearance","It is not required"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Ground Resistance Testing', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Fall-of-Potential & Clamp-On Ground Testing',
   'Ground resistance testing verifies the grounding electrode system is effective. The fall-of-potential method (3-point test) uses two auxiliary electrodes (a current electrode and a potential electrode) driven into the earth at increasing distances from the ground rod under test. A known current is injected, and the voltage is measured at each distance; the resistance is the voltage divided by the current at the plateau of the curve (where the reading stabilizes). The target resistance is under 25 ohms for a single rod (NEC 250.56) and under 5 ohms for a facility ground grid. The clamp-on ground tester is faster — it clamps around the ground conductor and injects a test current without auxiliary rods. It works only on multi-point grounds where the current can return through the soil; it does not work on a single isolated rod. Test during the dry season when the soil resistivity is highest — a test in wet soil gives a falsely low reading. Trend the resistance annually; a rising resistance indicates corrosion or a drying soil condition. Document the test method, the weather, and the reading.',
   50, 1,
   '[{"question":"What is the NEC maximum ground resistance for a single rod?","options":["5 ohms","25 ohms","100 ohms","1 ohm"],"correctIndex":1},{"question":"When should ground resistance be tested for the most conservative reading?","options":["During the wet season","During the dry season when soil resistivity is highest","At night","Any time"],"correctIndex":1}]');
END $$;

-- ===================== Conduit, Cable Tray & Industrial Wiring Methods =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Conduit, Cable Tray & Industrial Wiring Methods';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Conduit Systems', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Rigid, EMT & Conduit Bending',
   'Rigid metal conduit (RMC) provides the most mechanical protection and is used in hazardous locations and areas with physical damage risk. Intermediate metal conduit (IMC) is lighter than RMC with similar protection. EMT (thinwall) is used for indoor, non-hazardous areas where physical damage is not severe — it is the most common conduit in industrial control panels. Liquidtight flexible conduit (LFMC) is used for connections to motors and equipment that vibrate. Conduit fill is limited by NEC Table 1 (Chapter 9): 53% for one conductor, 31% for two, 40% for three or more. Overfill causes heating (the conductors cannot dissipate heat) and makes pulling difficult. When bending conduit, the radius must not be less than the NEC minimum (6x the conduit diameter for RMC, 10x for EMT under 1 inch). A kinked bend damages the conductors during pulling. Use a conduit bender with the correct shoe size and make the bend in one smooth motion. Always ream the conduit ends to remove burrs that can damage conductor insulation during pulling.',
   50, 1,
   '[{"question":"What is the maximum conduit fill for three or more conductors?","options":["31%","40%","53%","60%"],"correctIndex":1},{"question":"What must be done to conduit ends before pulling wire?","options":["Paint them","Ream them to remove burrs","Thread them","Cap them"],"correctIndex":1}]'),
  (m_id, 'Cable Tray & Tray Cable',
   'Cable tray is used for large industrial wiring runs — it is faster to install than conduit for many cables and allows future additions. NEC 392 governs cable tray fill: the fill depends on the tray type (ladder, ventilated, solid bottom) and the cable type. Tray cable (Type TC) is rated for installation in cable trays and is available in power and control configurations. For multi-conductor power cables in a ladder tray, the fill is based on the sum of the cable diameters — the cables must fit in a single layer for the ampacity to apply without derating. For control cables, the fill is by cross-sectional area. Maintain separation between power and control cables in the tray — at least 2 inches or a solid divider to prevent electromagnetic interference (EMI) from the power cables inducing noise on the control wiring. Ground the cable tray per NEC 250 — bond each tray section and connect to the building ground. Inspect cable tray during PMs for broken rungs, loose hardware, and cables that have fallen out of the tray.',
   45, 2,
   '[{"question":"What separation between power and control cables in a cable tray prevents EMI?","options":["0.5 inches","At least 2 inches or a solid divider","No separation needed","6 inches"],"correctIndex":1},{"question":"What type of cable is rated for installation in cable trays?","options":["THHN","Type TC (tray cable)","Romex","UF"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Pulling & NEC Chapter 3', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Conductor Pulling & NEC Chapter 3 Requirements',
   'Pulling conductors into conduit requires planning. Calculate the pulling tension using the conduit length, the number of bends, the conductor weight, and the coefficient of friction. Each 90-degree bend multiplies the pulling tension by approximately 2.2 — a run with three 90s requires 10x the tension of a straight run. If the calculated tension exceeds the cable maximum pulling tension (per the manufacturer), use a larger conduit, reduce the number of bends, or pull from the center. Always use a pulling lubricant compatible with the cable jacket — it reduces friction by 50% and prevents insulation damage. Never exceed the cable minimum bending radius — a sharp bend damages the conductor and insulation. NEC Chapter 3 (Wiring Methods) specifies the approved wiring methods for each application: RMC for hazardous locations, EMT for indoor general use, Type TC for cable trays, and Type MC for exposed runs. Always verify the wiring method is approved for the environment — using the wrong method is a code violation and a safety hazard.',
   45, 1,
   '[{"question":"How much does each 90-degree bend multiply the pulling tension?","options":["1.5x","2.2x","5x","10x"],"correctIndex":1},{"question":"What does pulling lubricant do?","options":["Cools the cable","Reduces friction by 50% and prevents insulation damage","Prevents corrosion","Improves conductivity"],"correctIndex":1}]');
END $$;

-- ===================== Electrical Troubleshooting Methodology =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Electrical Troubleshooting Methodology';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Systematic Troubleshooting Methods', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'The Half-Split Method & Decision Trees',
   'The half-split method is the most efficient troubleshooting technique for a series circuit or a sequential process. Instead of checking each component from one end, start in the middle. If the signal is present at the midpoint, the fault is downstream; if absent, the fault is upstream. This halves the number of checks for each step — a circuit with 8 components is diagnosed in 3 checks instead of 8. For a motor control circuit that does not start, first check the control voltage at the transformer (the midpoint of the control circuit). If the voltage is correct, the transformer and the upstream power are good — the fault is downstream. Then check the coil voltage at the starter — if absent, the fault is between the transformer and the coil (a fuse, a stop button, an overload contact). Build a diagnostic decision tree for each common failure: the tree starts with the symptom (motor will not start), branches at each test point (control voltage present? coil voltage present?), and ends at the component (blown fuse, open coil, tripped overload). A decision tree turns a 2-hour troubleshooting session into a 15-minute diagnosis.',
   50, 1,
   '[{"question":"How many checks does the half-split method require for a circuit with 8 components?","options":["8","4","3","1"],"correctIndex":2},{"question":"What is the first check in the half-split method for a motor control circuit?","options":["The motor","The control voltage at the transformer","The start button","The overload relay"],"correctIndex":1}]'),
  (m_id, 'Voltage Drop & Current Measurement',
   'Voltage drop testing finds high-resistance connections that a visual inspection misses. Measure the voltage across each connection in the circuit while the circuit is under load — a healthy connection reads less than 0.1V; a loose or corroded connection reads 0.5V or more. The voltage drop is proportional to the current and the resistance (V=IR); a small resistance at full load current produces a measurable voltage drop. Test the three-phase voltage at the motor terminals under load — a significant drop from the source to the motor indicates undersized wire, a loose connection, or a bad contact. Current measurement with a clamp meter verifies the motor is drawing the expected current. Compare the measured current to the nameplate FLA — a motor drawing more than FLA is overloaded or has a mechanical problem. A motor drawing significantly less than FLA is unloaded or has an open winding. Measure all three phases — a current unbalance greater than 10% indicates a voltage unbalance, a bad winding, or a loose connection on one phase.',
   45, 2,
   '[{"question":"What voltage drop across a loaded connection indicates a problem?","options":["Less than 0.1V","0.5V or more","1V","5V"],"correctIndex":1},{"question":"What does a current unbalance greater than 10% between phases indicate?","options":["Normal operation","Voltage unbalance, bad winding, or loose connection","Undersized motor","Overload"],"correctIndex":2}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Documentation & Root Cause', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Root Cause Analysis & Documentation',
   'After a repair, the job is not complete until the root cause is identified and documented. A root cause analysis asks why the failure occurred, not just what failed. A contactor that welded closed may have welded because the coil voltage was too low (the contactor chattered and the arc welded the contacts) — replacing the contactor fixes the symptom but not the root cause (the low coil voltage). The 5-Whys method asks why repeatedly until the root cause is found: the contactor welded (why?) because it chattered (why?) because the coil voltage was low (why?) because the control transformer was undersized (why?) because the original design did not account for the inrush of the added contactor. The fix is to upsize the transformer, not just replace the contactor. Document the failure, the root cause, and the corrective action in the CMMS. Trend the failure history — a component that fails repeatedly has a systemic root cause that requires a design change, not another replacement.',
   40, 1,
   '[{"question":"What does root cause analysis seek to find?","options":["What failed","Why the failure occurred, not just what failed","Who is responsible","How much it cost"],"correctIndex":1},{"question":"What does a component that fails repeatedly indicate?","options":["Bad luck","A systemic root cause requiring a design change","Normal wear","Poor maintenance"],"correctIndex":1}]');
END $$;

-- ===================== Soft Starters & Reduced Voltage Starting =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Soft Starters & Reduced Voltage Starting';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Reduced Voltage Starting Methods', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Autotransformer, Star-Delta & Solid-State Soft Starters',
   'Large motors (typically over 50HP) draw 6x FLA on a full-voltage (DOL) start, which can dim the lights, trip the breaker, or damage the motor. Reduced voltage starting limits the inrush. An autotransformer starter taps the transformer at 50%, 65%, or 80% — the motor starts at the reduced voltage, drawing current proportional to the voltage squared (50% voltage = 25% current). A star-delta (wye-delta) starter connects the motor in wye for starting (the phase voltage is 58% of the line voltage) and switches to delta for running. It requires a motor with all six leads brought out and is suitable for loads that can start at low torque (50-60% of full-load torque). A solid-state soft starter uses thyristors to ramp the voltage from 0 to 100% over a set time (typically 5-30 seconds). It provides the smoothest start, adjustable current limit, and a soft-stop feature. Select the method based on the load torque requirement, the allowable inrush, and the motor lead configuration. For loads that require high starting torque (conveyors, crushers), a soft starter may not provide enough torque — a VFD is the better choice.',
   50, 1,
   '[{"question":"How much current does a motor draw at 50% voltage on an autotransformer starter?","options":["50% of DOL","25% of DOL","10% of DOL","100% of DOL"],"correctIndex":1},{"question":"Which starting method provides the smoothest start with adjustable current limit?","options":["Autotransformer","Star-delta","Solid-state soft starter","Direct online"],"correctIndex":2}]'),
  (m_id, 'Starting Torque & Load Considerations',
   'The starting torque of a motor is proportional to the square of the voltage — at 65% voltage, the motor produces 42% of its full-voltage starting torque. The load must be able to accelerate at this reduced torque, or the motor will stall and overheat. Low-inertia loads (pumps, fans) start easily at reduced torque. High-inertia loads (centrifuges, loaded conveyors, crushers) may require 80-100% starting torque and cannot use aggressive reduced voltage starting. The acceleration time is also critical — a motor that takes 20 seconds to reach full speed draws 6x FLA for 20 seconds, which may exceed the thermal capacity of the motor and the starter. Set the soft starter ramp time to the minimum that accelerates the load without tripping on current limit. For a star-delta starter, the transition from star to delta causes a brief current spike and torque dip — ensure the load can tolerate this transient. For loads that must start under load (a loaded conveyor), a VFD that provides 100% torque at zero speed is the correct choice; a soft starter cannot.',
   45, 2,
   '[{"question":"At 65% voltage, what percentage of full-voltage starting torque does a motor produce?","options":["65%","42%","25%","100%"],"correctIndex":1},{"question":"Which starting device can provide 100% torque at zero speed for a loaded conveyor?","options":["Autotransformer starter","Star-delta starter","Solid-state soft starter","VFD"],"correctIndex":3}]');
END $$;

-- ===================== Industrial Panel Building & Layout =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Industrial Panel Building & Layout';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Panel Layout & Component Placement', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'UL 508A Layout Requirements',
   'UL 508A is the standard for industrial control panels in North America. The layout must separate power and control components: power (contactors, breakers, VFDs) in the upper or lower section, control (relays, terminals, PLC) in the opposite section, with a physical divider between them. Minimum clearances per the component manufacturer must be maintained for heat dissipation — a VFD typically requires 4 inches above and below. The main disconnect must be at the entrance of the panel and must be operable without opening the door (or the door must have an interlock). The power circuit conductors must be sized per NEC Table 310.16 for the ampacity and the temperature rating of the terminals. Control circuit conductors are typically 14 or 16 AWG. Label every wire with a unique number at both ends and label every device with its tag (e.g., M1 for motor starter 1). The panel must have a nameplate with the short-circuit current rating (SCCR), the voltage, and the FLA. The SCCR is determined by the lowest-rated component in the power circuit — a panel with a 65kAIC main breaker and a 5kAIC terminal block has a 5kA SCCR.',
   55, 1,
   '[{"question":"What determines the panel SCCR (short-circuit current rating)?","options":["The main breaker rating","The lowest-rated component in the power circuit","The wire size","The panel size"],"correctIndex":1},{"question":"What clearance does a VFD typically require above and below?","options":["1 inch","4 inches","6 inches","12 inches"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Wiring, Bundling & Labeling', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Wire Sizing, Bundling & Labeling Standards',
   'Wire sizing in a control panel follows NEC ampacity tables for power circuits and standard practice for control circuits (14 AWG for control, 16 AWG for signal). The wire must be rated for the panel temperature — 75C or 90C THHN is standard. Bundling wires neatly with zip ties at 6-inch intervals creates a professional appearance and aids troubleshooting — but bundling power and control wires together induces noise on the control wiring. Keep power and control in separate bundles with at least 1 inch separation, or use shielded control cable with the shield grounded at one end only. Label every wire with a unique number using a permanent marker or a printed label — the number corresponds to the schematic. Use ferrule terminals on stranded wire connections to terminal blocks — a ferrule prevents the strands from splaying and creating a loose connection. Torque every terminal to the manufacturer specification — a torque wrench is required, not a screwdriver by feel. Untorqued connections heat up, oxidize, and fail. Document the torque values and the date on a torque log. After wiring is complete, perform a continuity check on every wire against the schematic before energizing.',
   50, 1,
   '[{"question":"What is used on stranded wire connections to terminal blocks to prevent splaying?","options":["Electrical tape","Ferrule terminals","Solder","Heat shrink"],"correctIndex":1},{"question":"What is required for every terminal connection, not just by feel?","options":["A torque wrench to the manufacturer specification","A screwdriver","Pliers","Finger-tight is sufficient"],"correctIndex":0}]');
END $$;

-- ===================== UPS Systems, Batteries & Backup Power =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='UPS Systems, Batteries & Backup Power';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'UPS Topologies & Sizing', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Online, Line-Interactive & Standby UPS',
   'A standby (offline) UPS passes utility power directly to the load and switches to battery on a power failure — the transfer takes 4-10 ms, which is acceptable for most computers but may drop sensitive loads. A line-interactive UPS adds a voltage regulator that corrects sags and swells without switching to battery, extending battery life. An online (double-conversion) UPS continuously converts AC to DC and back to AC — the output is a clean sine wave with no transfer time, and the battery is always in the circuit. Online UPS is used for critical industrial loads (PLC systems, DCS, instrumentation) where any power interruption causes a process upset. Size the UPS by the load VA (not watts — the power factor matters) and the runtime requirement. A UPS sized at 100% of the load with 15 minutes of runtime is typical for industrial control systems — enough to ride through a short outage or to initiate a controlled shutdown. Add 20-30% margin for future expansion. For loads that cannot tolerate any downtime, add a redundant UPS module (N+1) and an automatic transfer switch to a generator.',
   50, 1,
   '[{"question":"Which UPS topology has zero transfer time and a clean sine wave output?","options":["Standby","Line-interactive","Online (double-conversion)","All of them"],"correctIndex":2},{"question":"What is the typical runtime for an industrial control system UPS?","options":["1 minute","15 minutes","1 hour","8 hours"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Battery Maintenance & Safety', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'VRLA & Flooded Battery Testing',
   'Valve-regulated lead-acid (VRLA, or sealed) batteries are the most common UPS battery — they are maintenance-free but have a 3-5 year service life and fail without warning. Flooded (wet) batteries last 10-15 years but require regular watering and specific gravity testing. The most reliable battery test is a capacity (discharge) test: the battery is discharged at a constant current to the end-of-discharge voltage, and the actual runtime is compared to the rated runtime. A battery that delivers less than 80% of rated capacity should be replaced. Between capacity tests (every 1-2 years), perform an impedance or conductance test monthly — a rising impedance indicates internal degradation. Measure the float voltage at each cell — a VRLA cell should read 2.25-2.30V per cell at 25 degrees C. A cell reading low (below 2.15V) is failing and should be replaced. Check the battery temperature — a battery operating at 35 degrees C has half the life of one at 25 degrees C. In the battery room, ensure ventilation (lead-acid batteries emit hydrogen during charging), post no-smoking signs, and provide eye wash and acid spill kits.',
   50, 1,
   '[{"question":"What is the most reliable battery test?","options":["Voltage check","Capacity (discharge) test","Visual inspection","Impedance test"],"correctIndex":1},{"question":"At what capacity should a UPS battery be replaced?","options":["Below 50% of rated","Below 80% of rated","Below 100% of rated","Below 95% of rated"],"correctIndex":1}]');
END $$;

-- ===================== Hazardous Location Electrical Installations =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Hazardous Location Electrical Installations';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Classification & Equipment Selection', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'NEC 500 Class I, II, III & Division/Zone Systems',
   'NEC Article 500 classifies hazardous locations by the type of hazard: Class I (flammable gases or vapors), Class II (combustible dust), and Class III (ignitable fibers). Each class is divided into Division 1 (the hazard is present during normal operation) and Division 2 (the hazard is present only during abnormal operation, like a leak). The Zone system (IEC) is an alternative: Zone 0 (continuous), Zone 1 (likely), Zone 2 (unlikely). Equipment must be rated for the classification. Explosionproof equipment (Class I, Division 1) is designed to contain an internal explosion and prevent it from igniting the surrounding atmosphere — the joints are precisely machined to cool escaping gases. Dust-ignitionproof (Class II, Division 1) equipment is sealed to prevent dust from entering and has a surface temperature below the dust ignition temperature. Intrinsically safe equipment (any class) limits the electrical energy to a level that cannot ignite the hazard — it requires a barrier device that limits the voltage and current to the field device. Selecting the wrong equipment for the classification is a fire and explosion hazard and a code violation.',
   55, 1,
   '[{"question":"What does explosionproof equipment do?","options":["Prevents explosions from occurring","Contains an internal explosion and prevents it from igniting the surrounding atmosphere","Is completely sealed","Is intrinsically safe"],"correctIndex":1},{"question":"What does intrinsically safe equipment limit?","options":["The physical size of the equipment","The electrical energy to a level that cannot ignite the hazard","The operating temperature","The voltage only"],"correctIndex":1}]'),
  (m_id, 'Sealing & Installation Requirements',
   'Sealing fittings (conduit seals) prevent flammable gases from traveling through the conduit from one area to another. A seal is required within 18 inches of the enclosure in Division 1 locations and at the boundary between Division 1 and Division 2 or unclassified areas. The seal is made with a poured sealing compound (Chico) that fills the conduit around the conductors. The conductors must be separated in the seal fitting so the compound fills the voids — a seal with bundled conductors does not seal properly. Factory-sealed devices eliminate the need for a separate seal fitting. For cable installations, the cable must be sealed at the enclosure entry with an explosionproof cable gland. Verify the temperature rating (T-code) of the equipment does not exceed the ignition temperature of the hazardous material — a T3B rating (165C max surface temperature) is required for hydrogen, while a T6 rating (85C max) is safe for most materials. Document the classification, the equipment ratings, and the seal locations on the installation drawings.',
   50, 2,
   '[{"question":"How far from the enclosure must a conduit seal be installed in Division 1?","options":["6 inches","18 inches","36 inches","72 inches"],"correctIndex":1},{"question":"What must be done with conductors in a seal fitting?","options":["Bundle them tightly","Separate them so the sealing compound fills the voids","Use only one conductor per seal","No special requirement"],"correctIndex":1}]');
END $$;

-- ===================== Motor Protection & Overcurrent Devices =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Motor Protection & Overcurrent Devices';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Overcurrent Protection Fundamentals', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Fuses, Breakers & Motor Circuit Protectors',
   'Motor branch-circuit protection per NEC 430 has three components: short-circuit and ground-fault protection (the fuse or breaker), the disconnect, and the overload protection (the overload relay). The short-circuit device must be sized to carry the motor inrush (6x FLA) without tripping, but trip on a short circuit. Fuses (time-delay, Class RK5 or J) and motor circuit protectors (MCPs, magnetic-only breakers) are common. A time-delay fuse holds 500% of rated current for 10 seconds — enough to ride through the motor inrush. An MCP is adjustable — set the magnetic trip to 10-13x the motor FLA. A standard thermal-magnetic breaker is not ideal for motors because the thermal trip may nuisance-trip on a long acceleration. The disconnect must be within sight of the motor and rated for the motor FLA. The overload relay provides the running overload protection and is set to the motor FLA. Coordination between the short-circuit device and the overload is critical — the overload trips first on a sustained overload, and the short-circuit device trips first on a short circuit. A lack of coordination causes the main breaker to trip on a motor fault, taking down the entire panel.',
   50, 1,
   '[{"question":"What must the short-circuit device be sized to carry without tripping?","options":["The motor FLA","The motor inrush (6x FLA)","10x FLA","The locked rotor current"],"correctIndex":1},{"question":"What is the consequence of poor coordination between the short-circuit device and the overload?","options":["The motor runs faster","The main breaker trips on a motor fault, taking down the entire panel","The overload trips too slowly","No consequence"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Coordination & NEC 430', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Selective Coordination & NEC 430 Requirements',
   'Selective coordination means only the device closest to the fault trips — the upstream devices stay closed, keeping the rest of the system running. For a motor fault, only the motor branch breaker should trip, not the feeder breaker or the main. Coordination is achieved by selecting devices with different trip curves: the downstream device trips faster than the upstream device for the same fault current. NEC 430.62 requires the motor short-circuit device to be sized no larger than necessary to carry the motor inrush — oversized devices do not coordinate with the upstream feeder protection. The NEC 430 requirements: the branch-circuit conductors are sized at 125% of the motor FLA (430.22), the short-circuit device is sized per Table 430.52 (up to 300% for fuses, up to 800% for breakers, with the next size up allowed if the calculated size is not available), and the overload is set at the motor FLA. Verify the coordination with a time-current curve overlay — if the curves cross, the devices do not coordinate. For critical processes, specify fully rated (not series-rated) equipment so that the downstream device can clear the fault without relying on the upstream device.',
   50, 1,
   '[{"question":"What does selective coordination ensure?","options":["All breakers trip together","Only the device closest to the fault trips","The main breaker always trips","No breakers trip"],"correctIndex":1},{"question":"At what percentage of motor FLA are branch-circuit conductors sized per NEC 430.22?","options":["100%","115%","125%","150%"],"correctIndex":2}]');
END $$;

-- ===================== Variable Frequency Drive Installation & Commissioning =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Variable Frequency Drive Installation & Commissioning';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Installation & EMC', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'VFD Wiring, EMC & Motor Cable Selection',
   'VFD installation requires attention to electromagnetic compatibility (EMC) because the PWM output generates high-frequency noise. Use shielded motor cable (copper braid or foil shield with a drain wire) and ground the shield at both ends with 360-degree termination (EMC cable glands) — a pigtail ground connection is ineffective at high frequency and radiates noise. Route the motor cable at least 12 inches from control and signal wiring; if they must cross, cross at 90 degrees. Keep the VFD input power wiring separate from the output wiring to prevent the PWM from coupling back to the line. The motor cable length must not exceed the drive specification — long cables cause reflected-wave voltage spikes that damage motor insulation. For cables over 50 meters (150 feet), use a load reactor or dV/dt filter at the drive output. For cables over 100 meters, use a sine-wave filter. The drive must be grounded to the building ground with a flat-braided conductor (not round) — the flat braid has lower high-frequency impedance. Install the drive in an enclosure with adequate cooling — a VFD dissipates 2-3% of its rated power as heat, and an undersized enclosure causes thermal derating or failure.',
   55, 1,
   '[{"question":"What type of motor cable is required for VFD installations?","options":["Unshielded THHN","Shielded cable with 360-degree termination","Romex","Any cable"],"correctIndex":1},{"question":"What should be used for motor cables over 50 meters on a VFD?","options":["Nothing","A load reactor or dV/dt filter","A larger motor","A smaller drive"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Startup & Hand-off', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Startup Procedure & Commissioning Hand-off',
   'Before energizing a VFD, verify the installation: check the input voltage matches the drive rating, the motor nameplate data is entered, the motor leads are connected and the rotation is correct (uncoupled), the control wiring is correct, and all safety covers are installed. Perform a bump test (momentary start) to confirm rotation. Perform an auto-tune (static or rotating) so the drive models the motor. Set the operating parameters: min/max frequency, accel/decel ramps, control mode, and current limit. Run the motor at 10, 20, 50, and 100% speed and verify the motor current, vibration, and temperature are normal. Document all parameter settings on a commissioning sheet. For the hand-off to operations, provide a startup report with the motor nameplate data, the drive parameters, the test results, and the fault history. Train the operator on the basic drive operations: start/stop, speed reference, fault reset, and the meaning of common fault codes. Schedule a 30-day follow-up to verify the drive is running correctly and to address any tuning or parameter adjustments. A drive that is handed off without documentation and training will be misoperated and will fail prematurely.',
   50, 1,
   '[{"question":"What should be done before the first full-speed run of a VFD?","options":["Nothing — just start it","A bump test to confirm rotation, then auto-tune","Full load test","Only check the voltage"],"correctIndex":1},{"question":"What should be provided at hand-off to operations?","options":["Nothing","A startup report with nameplate data, parameters, test results, and fault history","The drive manual only","A phone number"],"correctIndex":1}]');
END $$;

-- ===================== Electrical Prints, Schematics & Ladder Diagrams =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Electrical Prints, Schematics & Ladder Diagrams';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Drawing Types & Interpretation', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'One-Line, Ladder & Wiring Diagrams',
   'Three types of electrical drawings serve different purposes. A one-line diagram shows the power distribution from the service entrance to the loads in a single-line format — it is used for system planning and fault studies. A ladder (schematic) diagram shows the control logic in a ladder format with line numbers, reference numbers, and component tags — it is the primary tool for troubleshooting. A wiring diagram shows the physical layout of wires and components — it is used for installation and panel building. To troubleshoot, start with the ladder diagram: find the coil that is not energizing, trace the series contacts backward to the open one, then use the wiring diagram to find the physical location of the open contact. Cross-referencing between drawings is essential: the ladder diagram shows a contact as "CR-3" (control relay, contact 3); the wiring diagram shows where CR-3 is physically located and what wire numbers connect to it. The one-line diagram shows the power path to the control transformer that feeds the control circuit. Learn to move between all three drawings quickly — a technician who can only read one type is limited to one phase of the job.',
   50, 1,
   '[{"question":"Which drawing is the primary tool for troubleshooting control circuits?","options":["One-line diagram","Ladder (schematic) diagram","Wiring diagram","Panel layout"],"correctIndex":1},{"question":"What does a wiring diagram show that a ladder diagram does not?","options":["The control logic","The physical layout of wires and components","The power distribution","The line numbers"],"correctIndex":1}]'),
  (m_id, 'Terminal Blocks & Cross-Referencing',
   'Terminal blocks connect internal panel wiring to external field wiring. Each terminal has a number that appears on the wiring diagram and the ladder diagram. When troubleshooting, the terminal block is the interface between the panel and the field — measuring at the terminal block isolates the problem to either the panel or the field wiring. A voltage reading at the terminal that matches the expected value means the panel is correct and the problem is in the field; a missing or incorrect reading means the problem is in the panel. Cross-referencing uses the terminal number, the wire number, and the component tag to trace a signal across multiple drawings. For example, wire number 413 starts at the start button (line 12 of the ladder), goes through terminal block TB-12, and ends at the contactor coil M1 (line 15). A break in wire 413 anywhere along this path prevents M1 from energizing. Use the cross-reference to systematically check each point: the start button, TB-12, and the coil terminal. Document any wiring changes on the as-built drawings — a drawing that does not match the installation is worse than no drawing.',
   45, 2,
   '[{"question":"What does the terminal block represent in troubleshooting?","options":["The control logic","The interface between panel and field wiring","The power source","The motor connection"],"correctIndex":1},{"question":"What must be done when wiring is changed during a repair?","options":["Nothing","Document the changes on the as-built drawings","Replace the drawings entirely","Note it in the CMMS only"],"correctIndex":1}]');
END $$;

-- ===================== Lighting Systems, Ballasts & LED Retrofits =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Lighting Systems, Ballasts & LED Retrofits';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Industrial Lighting Systems', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'HID, Fluorescent & LED Systems',
   'High-intensity discharge (HID) lamps — metal halide, high-pressure sodium, and mercury vapor — have been the standard for high-bay industrial lighting for decades. They produce high lumen output but have long restrike times (5-15 minutes after a power interruption) and degrade in output over life (a metal halide lamp at end of life produces 60-70% of initial lumens). Fluorescent (T5, T8) systems are used for lower-bay and task lighting and offer instant-on with good color rendering. LED systems are now the standard for new installations and retrofits — they produce high lumen output with 50-70% energy savings, instant-on, no restrike time, and 50,000-100,000 hour life. The lumen maintenance (L70 — the hours to 70% of initial lumens) is the key LED life metric. For a retrofit, calculate the existing lighting power density (watts per square foot), the target illuminance (footcandles per IES standards), and the LED replacement that meets the target with the lowest power. A photometric layout confirms the LED fixtures provide uniform illumination without dark spots.',
   45, 1,
   '[{"question":"What is the main disadvantage of HID lighting in industrial settings?","options":["High energy use","Long restrike time (5-15 minutes) after a power interruption","Poor color rendering","Short life"],"correctIndex":1},{"question":"What does L70 represent for an LED fixture?","options":["70% energy savings","The hours to 70% of initial lumens","70 watts","70,000 hours of life"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'LED Retrofits & Energy Savings', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Retrofit Planning & Energy Calculations',
   'An LED retrofit project starts with a lighting audit: count the existing fixtures, record the type and wattage, measure the illuminance at floor level, and note the hours of operation. Calculate the annual energy cost: total watts x hours per year x electricity rate. For a 400W metal halide high-bay running 24/7 at $0.10/kWh, the annual cost is $3,504 per fixture. The LED replacement (a 150W LED high-bay producing equivalent lumens) costs $1,314 per year — a savings of $2,190 per fixture per year. With a fixture cost of $300-500, the payback is 2-3 months. For a plant with 100 fixtures, the annual savings is $219,000. Add the maintenance savings: HID lamps are replaced every 2-3 years at $50-100 per lamp plus labor; LED fixtures last 10+ years. Verify the LED fixture is rated for the environment — damp/wet location, vibration (near rotating equipment), and ambient temperature. Use fixtures with a surge protector for outdoor installations. Install in phases to spread the capital cost and to verify the LED performance before committing to the full retrofit.',
   45, 1,
   '[{"question":"What is the typical payback period for an LED high-bay retrofit?","options":["5-10 years","2-3 months","1-2 years","10+ years"],"correctIndex":1},{"question":"What must be verified for an LED fixture in an industrial environment?","options":["Color only","Damp/wet rating, vibration rating, and ambient temperature rating","Price","Brand name"],"correctIndex":1}]');
END $$;

-- ===================== Power Quality Basics =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Power Quality Basics';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Harmonics & IEEE 519', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Harmonic Sources & IEEE 519 Limits',
   'Harmonics are integer multiples of the fundamental frequency (60 Hz) that distort the sine wave. Nonlinear loads — VFDs, UPS, LED drivers, computers — draw current in pulses, generating harmonics. The 5th and 7th harmonics are the most common from 6-pulse VFD rectifiers. Harmonics cause overheating in transformers and neutral conductors (the 3rd harmonic adds in the neutral, potentially carrying 1.7x the phase current), nuisance breaker trips, and capacitor fuse failures. IEEE 519 sets the limits: the total demand distortion (TDD) at the point of common coupling (PCC) must not exceed 5% for general facilities, with individual harmonics limited to 4%. Measure harmonics with a power quality analyzer at the PCC (the point where the utility and the customer share the bus). If the TDD exceeds 5%, mitigation options include: harmonic filters (tuned LC filters that trap specific harmonics), 12-pulse or 18-pulse rectifiers (that cancel low-order harmonics), and active harmonic filters (that inject counter-harmonics). The most cost-effective mitigation is often to distribute the nonlinear loads across multiple transformers to reduce the concentration at any one point.',
   50, 1,
   '[{"question":"Which harmonics are most common from 6-pulse VFD rectifiers?","options":["2nd and 3rd","5th and 7th","11th and 13th","1st and 2nd"],"correctIndex":1},{"question":"What is the IEEE 519 TDD limit at the point of common coupling for general facilities?","options":["1%","5%","10%","15%"],"correctIndex":1}]'),
  (m_id, 'Voltage Sags, Swells & Flicker',
   'Voltage sags (dips) are the most common power quality disturbance and the most costly — a 20% sag for 10 cycles can drop a VFD, reset a PLC, and scrap a production batch. Sags are caused by motor starting (6x FLA for a few seconds), fault clearing (a fuse or breaker operating), and utility switching. Mitigation: reduce the motor inrush (soft starter or VFD), add a UPS for critical loads, and ensure the source impedance is low enough that the sag stays above 80%. Swells (overvoltage) are less common but can damage equipment — caused by capacitor switching and load shedding. Flicker is the perception of light intensity variation caused by rapid voltage changes (a large load cycling on and off). Flicker is measured with a flicker meter per IEC 61000-4-15 and is limited by the utility at the PCC. Power factor correction capacitors can cause resonance with the system inductance, amplifying harmonics — detune the capacitor with a series reactor. Measure power quality over at least a week to capture the full range of operating conditions and identify the source of disturbances.',
   45, 2,
   '[{"question":"What is the most common and most costly power quality disturbance?","options":["Harmonics","Voltage sags","Flicker","Swells"],"correctIndex":1},{"question":"What can a 20% voltage sag for 10 cycles do?","options":["Nothing noticeable","Drop a VFD, reset a PLC, and scrap a production batch","Dim the lights slightly","Improve motor performance"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Power Factor & Correction', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Power Factor Correction & Mitigation',
   'Power factor (PF) is the ratio of real power (kW) to apparent power (kVA). A PF of 1.0 means all the current does useful work; a PF of 0.7 means 30% of the current is reactive (magnetizing current for motors and transformers) that heats the conductors and transformers without doing work. Utilities charge for low power factor (below 0.9) because the reactive current occupies system capacity. Correct by installing power factor correction capacitors that supply the reactive current locally, reducing the current drawn from the utility. Size the capacitor to correct the PF to 0.95, not 1.0 — overcorrection causes high voltage on capacitor switching and can damage equipment. Install capacitors at the motor terminals (distributed correction) or at the main switchgear (centralized correction). Distributed correction is more effective because it reduces the current in the motor feeders. For VFD-fed motors, do not install capacitors at the drive output — the drive already corrects the PF at its input, and a capacitor at the output causes instability and damage. Trend the PF monthly; a falling PF indicates added motors or transformers without correction.',
   45, 1,
   '[{"question":"To what power factor should correction capacitors be sized?","options":["0.70","0.90","0.95","1.00"],"correctIndex":2},{"question":"Where should power factor correction capacitors NOT be installed?","options":["At the motor terminals","At the main switchgear","At the VFD output","At the motor control center"],"correctIndex":2}]');
END $$;

-- ===================== Temporary Power & Construction Electrical =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Temporary Power & Construction Electrical';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Temporary Power Distribution', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'GFCI, Spider Boxes & Generator Sizing',
   'OSHA 1926.404 requires GFCI protection on all 120V, 15A and 20A receptacles used for construction and maintenance. A GFCI trips when it detects a current imbalance (5 mA) between the hot and neutral — the missing current is going to ground through a person. Test the GFCI with the built-in test button before each use; a GFCI that does not trip on test is defective and must be replaced. Spider boxes (portable power distribution boxes) distribute temporary power from a generator or shore power to multiple receptacles with GFCI protection. Size the generator for the total load plus 25% margin for motor starting. A generator that is too small sags in voltage on motor start, causing the motor to draw excessive current and stall. For a construction site with 5 tools drawing 15A each, the load is 75A (9kW at 120V) — a 12kW generator provides adequate margin. Use SOOW cable (oil-resistant, water-resistant, weather-resistant) for temporary power runs. Support cables above walkways and protect them from vehicle traffic with cable ramps. Never use damaged cable — a cut jacket exposes the conductors and is a shock and fire hazard.',
   45, 1,
   '[{"question":"At what current imbalance does a GFCI trip?","options":["1 mA","5 mA","15 mA","100 mA"],"correctIndex":1},{"question":"What margin should be added to the total load when sizing a generator?","options":["10%","25%","50%","100%"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'OSHA 1926 Subpart K Safety', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'OSHA 1926 Subpart K & Temporary Wiring Rules',
   'OSHA 1926 Subpart K governs electrical safety on construction sites. Temporary wiring must be installed by a qualified person and must not create a hazard. The rules: all receptacles must be GFCI-protected or on an assured equipment grounding conductor program (a written program that tests each cord set daily). Extension cords must be 3-wire (with ground) and rated for the load. Cords must not be run through doors or windows unless protected, and must not be fastened with staples or hung by the conductors. Lamps must be protected from contact by a guard or fixture — bare bulbs are a fire and breakage hazard. Temporary lighting must be at least 5 watts per square foot for general illumination and 10 watts per square foot for stairs and exits. The disconnect for temporary power must be labeled and accessible. Inspect all temporary wiring daily for damage, and remove damaged cord sets from service immediately. Document the daily inspection. The most common OSHA citation on construction sites is a missing or non-functional GFCI — verify the GFCI test function before each shift.',
   40, 1,
   '[{"question":"What is the most common OSHA electrical citation on construction sites?","options":["Exposed wires","A missing or non-functional GFCI","No hard hats","Missing labels"],"correctIndex":1},{"question":"How often must temporary wiring be inspected?","options":["Monthly","Daily","Weekly","Annually"],"correctIndex":1}]');
END $$;

-- ===================== Electrical Safety Programs & NFPA 70E Application =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Electrical Safety Programs & NFPA 70E Application';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Safety Program Elements', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Building an NFPA 70E Safety Program',
   'An electrical safety program per NFPA 70E has eight elements: (1) policy and procedures, (2) training (qualified and unqualified persons), (3) hazard identification and risk assessment, (4) job briefings before each task, (5) energized work permits, (6) LOTO procedures, (7) PPE selection and maintenance, and (8) incident investigation. The program must be audited at least every 3 years to verify compliance. The policy statement, signed by management, establishes that electrical safety is a priority and that de-energization is the default. Training: qualified persons are trained in the hazards of energized work, the use of test equipment, and the application of LOTO; unqualified persons are trained to recognize and avoid electrical hazards. The job briefing is conducted before each task and documents the hazards, the PPE, the LOTO, and the emergency response. The energized work permit is required for any work on exposed energized parts (with minor exceptions like voltage testing and thermography). The program is a living document — update it after every incident investigation and every standard revision.',
   50, 1,
   '[{"question":"How often must an NFPA 70E electrical safety program be audited?","options":["Annually","At least every 3 years","Every 5 years","Only after an incident"],"correctIndex":1},{"question":"What is the default approach to electrical work per NFPA 70E?","options":["Work energized by default","De-energization is the default","Always use insulated tools","Work without a permit"],"correctIndex":1}]'),
  (m_id, 'Job Briefings & Incident Investigation',
   'A job briefing is a short meeting before each electrical task that covers: the task description, the hazards (shock and arc flash), the PPE required, the LOTO procedure, the emergency response, and any special conditions. The briefing is documented on a form signed by the worker and the supervisor. For routine tasks, a brief verbal briefing is sufficient; for complex or high-risk tasks, a written briefing is required. An incident investigation after an electrical incident (shock, arc flash, near miss) identifies the root cause and the corrective action to prevent recurrence. The investigation documents the sequence of events, the contributing factors, the root cause, and the corrective actions. Share the findings with all qualified workers — the same hazard exists for everyone, and the corrective action protects everyone. Track the corrective actions to completion and verify they are effective. A near miss is an incident without injury — investigate it with the same rigor as an injury, because the next time the same hazard occurs, the outcome may be worse. Trend the incident rate and the near-miss rate to measure the program effectiveness.',
   45, 2,
   '[{"question":"What must a job briefing cover before each electrical task?","options":["Only the task description","The task, hazards, PPE, LOTO, emergency response, and special conditions","Only the PPE","Only the LOTO procedure"],"correctIndex":1},{"question":"How should a near miss be investigated?","options":["It does not need investigation","With the same rigor as an injury","Only if it involves management","Only if equipment is damaged"],"correctIndex":1}]');
END $$;

-- ===================== Testing & Commissioning of Electrical Equipment =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Testing & Commissioning of Electrical Equipment';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Acceptance Testing Standards', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'NETA Acceptance Testing Overview',
   'NETA (InterNational Electrical Testing Association) defines acceptance testing standards for new and modified electrical installations. The tests verify the equipment is installed correctly, operates as designed, and is safe to energize. The standard tests: insulation resistance (megger) for cables, transformers, and switchgear; contact resistance (DLRO) for breakers, contactors, and bus connections; transformer turns ratio (TTR) for transformers; primary injection for overcurrent relays and breakers; and power factor (Doble) testing for transformer and cable insulation. Each test has a pass/fail criterion defined by NETA. For example, insulation resistance must be greater than 1 gigohm for 480V equipment; contact resistance must be within 10% of the manufacturer value or the previous test; TTR must be within 0.5% of the nameplate ratio. Document all test results on a test report with the equipment identification, the test date, the instrument used, the test values, and the pass/fail determination. The test report is the baseline for future maintenance testing — a deviation from the baseline indicates degradation. Always calibrate the test instruments before use and record the calibration date on the report.',
   55, 1,
   '[{"question":"What is the minimum insulation resistance for 480V equipment per NETA?","options":["1 megohm","1 gigohm","100 megohms","500 megohms"],"correctIndex":1},{"question":"Within what percentage of the nameplate ratio must the TTR be?","options":["1%","0.5%","5%","10%"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Specific Tests & Interpretation', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Contact Resistance, TTR & Primary Injection',
   'Contact resistance testing (DLRO — digital low-resistance ohmmeter) measures the resistance across a closed contact or a bus joint. A high resistance connection heats up under load and fails. The pass criterion: the resistance must be within 10% of similar connections (compare phase-to-phase on a 3-phase breaker) and within the manufacturer specification. A breaker with 50 microhms on phase A and 200 microhms on phase B has a problem on phase B — the contact is worn or the linkage is binding. Transformer turns ratio (TTR) testing verifies the transformer windings are correct — the ratio of the primary to secondary voltage must match the nameplate. A TTR that is off by more than 0.5% indicates a shorted turn, which will cause the transformer to fail under load. Primary injection testing injects a high current (100-1000A) through the breaker and the overcurrent relay to verify the trip curve. The breaker must trip within the time specified by the curve at the test current. A breaker that does not trip at the correct time has a worn mechanism or a misadjusted trip unit and must be repaired or replaced. Always perform the tests in the correct sequence: insulation resistance first (to verify the equipment is safe to test), then contact resistance, then primary injection.',
   50, 1,
   '[{"question":"What does a TTR that is off by more than 0.5% indicate?","options":["Normal tolerance","A shorted turn that will cause the transformer to fail under load","A wrong tap setting","A calibration error"],"correctIndex":1},{"question":"In what sequence should acceptance tests be performed?","options":["Primary injection, contact resistance, insulation resistance","Insulation resistance, contact resistance, primary injection","Contact resistance, insulation resistance, primary injection","Any order is acceptable"],"correctIndex":1}]');
END $$;
