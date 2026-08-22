-- ============================================================
-- PART 4a: Add new modules + 2 lessons each for courses 6-9
-- ============================================================

-- Course 6: Conduit, Cable Tray & Industrial Wiring Methods — Add Module 3: Industrial Wiring Applications
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Conduit, Cable Tray & Industrial Wiring Methods' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Industrial Wiring Applications') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Industrial Wiring Applications', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Motor Feeders & Branch Circuit Wiring',
      '## Overview

Motor feeder and branch circuit wiring in industrial environments follows specific NEC requirements that differ from general wiring. Motor circuits have unique characteristics: high inrush current, continuous duty, and the need for coordinated protection. Understanding NEC Article 430 requirements for conductor sizing, protection, and routing is essential for any industrial electrician.

## Key Concepts

- **Motor branch circuit vs feeder**: The branch circuit runs from the final overcurrent device to the motor; the feeder runs from the service to the motor disconnect. Each has different sizing rules.
- **NEC 430.22 conductor sizing**: Motor branch circuit conductors must be sized at 125% of the motor full-load current (FLC) from NEC Table 430.250.
- **Continuous duty**: Motors are considered continuous loads, requiring the 125% factor on conductor sizing.
- **Separate motor disconnect**: NEC 430.102 requires a disconnect within sight of the motor (or within 50 feet and lockable).
- **Fused disconnect vs breaker**: Both are acceptable; fused disconnects offer higher interrupting ratings and better coordination.

## Step-by-Step: Sizing and Installing a Motor Branch Circuit

1. **Determine motor FLC**: Look up the motor FLC in NEC Table 430.250 based on HP and voltage — do NOT use the nameplate current for conductor sizing.
2. **Size the conductor**: Multiply FLC by 125% (NEC 430.22). Select a conductor from NEC Table 310.16 based on the ampacity and temperature rating.
3. **Size the short-circuit protection**: Per NEC 430.52, size the fuse or breaker at 125-300% of FLC depending on the type (time-delay fuses allow up to 175%, inverse time breakers up to 250%).
4. **Size the overload protection**: Per NEC 430.32, set the overload at 115-125% of the nameplate FLC (depending on motor service factor).
5. **Select the conduit**: Calculate conduit fill based on conductor size and quantity per NEC Chapter 9, Table 1 and Table 4.
6. **Install the disconnect**: Place a motor disconnect within sight of the motor per NEC 430.102.
7. **Verify coordination**: Ensure the short-circuit device, overload relay, and conductor ampacity are properly coordinated.

## Common Problems

- **Using nameplate current for conductor sizing**: The nameplate current is for overload setting, not conductor sizing. NEC Table 430.250 must be used for conductor and short-circuit sizing.
- **Undersized conductors**: Not applying the 125% factor for continuous duty motors leads to overheating and NEC violations.
- **Missing motor disconnect**: Failing to install a disconnect within sight of the motor violates NEC 430.102 and creates a safety hazard.
- **Incorrect conduit fill**: Overfilling conduit makes pulling difficult and causes overheating.
- **Inadequate short-circuit protection**: Using a breaker or fuse that is too large can damage the motor and conductors during a fault.

## Best Practices

- Always use NEC Table 430.250 (not the nameplate) for conductor and short-circuit device sizing.
- Install a lockable disconnect within sight of every motor.
- Use color-coded conductors: black/red/blue for 3-phase, white for neutral, green for ground.
- Label motor conductors at both ends with wire numbers matching the drawings.
- Perform a coordination study for critical motor circuits to ensure selective coordination.
- Use flexible conduit (Sealtite/FMC) for the final connection to the motor to accommodate vibration.

## Safety

- De-energize and lock out the circuit before working on motor wiring.
- Verify the absence of voltage with a rated tester before touching conductors.
- Motor terminals may retain voltage from back-EMF — discharge large motors before touching terminals.
- Ensure the equipment grounding conductor is properly connected to the motor frame — a missing ground is a shock hazard.
- Tighten all terminations to manufacturer torque specifications — loose connections cause overheating and fires.',
      45, true, true,
      '[
        {"question":"What NEC table is used to determine motor FLC for conductor sizing?","options":["Table 310.16","Table 430.250","Table 430.32","Table 400.4"],"correctIndex":1},
        {"question":"What percentage of motor FLC must branch circuit conductors be sized for per NEC 430.22?","options":["100%","115%","125%","200%"],"correctIndex":2},
        {"question":"What is the NEC 430.102 requirement for motor disconnects?","options":["No disconnect required","A disconnect within sight of the motor, or within 50 feet and lockable","A disconnect at the panel only","A disconnect at the motor only"],"correctIndex":1},
        {"question":"Why should the nameplate current NOT be used for conductor sizing?","options":["It is too high","The nameplate is for overload setting; NEC Table 430.250 provides standardized FLC for conductor sizing","It is too low","It is inaccurate"],"correctIndex":1},
        {"question":"What is the maximum time-delay fuse size per NEC 430.52 for a motor branch circuit?","options":["100% of FLC","175% of FLC","300% of FLC","500% of FLC"],"correctIndex":1},
        {"question":"What type of conduit is recommended for the final connection to a motor?","options":["Rigid metal conduit","Flexible metal conduit (FMC/Sealtite) to accommodate vibration","EMT","PVC"],"correctIndex":1},
        {"question":"What is the purpose of the equipment grounding conductor on a motor?","options":["To carry load current","To provide a fault path that clears the overcurrent device and protect against shock","To improve power factor","To reduce harmonics"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Hazardous Area Wiring & Sealing Practices',
      '## Overview

Wiring in hazardous (classified) locations requires specialized knowledge of NEC Articles 500-506 and the selection of appropriate wiring methods, seals, and fittings. Unlike general industrial wiring, hazardous area wiring must prevent flammable gases, vapors, dust, or fibers from being ignited by electrical equipment or wiring. Understanding the classification system and installation requirements is critical for safety and compliance.

## Key Concepts

- **Classification system**: NEC 500 classifies hazards by Class (I-gas, II-dust, III-fibers), Division (1-normal, 2-abnormal), and Group (A-acetylene, B-hydrogen, C-ethylene, D-propane, E-metal dust, F-coal dust, G-grain dust).
- **Approved wiring methods**: RMC, IMC, and Type MI cable are permitted in Division 1. EMT, RMC, IMC, and FMC (with restrictions) are permitted in Division 2.
- **Seal fittings**: Required to prevent gases from traveling through conduit between classified and unclassified areas. Must be installed within 18 inches of the enclosure in Division 1.
- **Explosionproof enclosures**: Designed to contain an internal explosion and prevent it from igniting the surrounding atmosphere.
- **Temperature classification (T-code)**: Equipment surface temperature must not exceed 80% of the auto-ignition temperature of the hazardous gas or dust.

## Step-by-Step: Installing Wiring in a Class I, Division 1 Location

1. **Verify the classification**: Confirm the Class, Division, and Group from the area classification drawing. Select equipment rated for the specific classification.
2. **Select the wiring method**: Use RMC or IMC with threaded connections (5 full threads engaged) or Type MI cable. EMT is NOT permitted in Division 1.
3. **Install explosionproof enclosures**: Use NEMA 7 (Class I) enclosures with threaded hubs. Ensure all covers and fittings are properly rated.
4. **Install seal fittings**: Install seals within 18 inches of each enclosure in Division 1. Separate conductors in the seal fitting so compound fills all voids.
5. **Pour the sealing compound**: Mix and pour the factory-approved sealing compound. Allow it to cure fully before energizing.
6. **Verify thread engagement**: Ensure at least 5 full threads are engaged on all threaded connections. Use listed sealing washers on hub connections.
7. **Install breather and drain fittings**: Where required, install listed breathers and drains to allow pressure equalization while preventing flame passage.
8. **Test and inspect**: Verify all seals are properly poured, all threads are engaged, and all equipment is rated for the classification.

## Common Problems

- **Wrong wiring method in Division 1**: Using EMT or non-approved cable in Division 1 is a serious code violation and safety hazard.
- **Improper seal installation**: Bundling conductors in the seal fitting prevents compound penetration, making the seal ineffective.
- **Insufficient thread engagement**: Fewer than 5 engaged threads compromises the flame path and violates code.
- **Wrong T-code**: Equipment with a surface temperature above the ignition temperature of the gas is a serious hazard.
- **Missing seals at boundaries**: Failing to seal at the classified/unclassified boundary allows gases to migrate through conduit.

## Best Practices

- Always verify the area classification before selecting wiring methods or equipment.
- Use only listed and labeled equipment for the specific Class, Division, and Group.
- Keep seal fitting records showing date, compound type, and installer.
- Install seals at all boundary points and at each enclosure in Division 1.
- Use anti-seize compound on threaded connections to prevent galling and ensure proper engagement.
- Perform a final inspection with a checklist verifying all requirements before energizing.

## Safety

- Never energize classified area wiring until all seals are cured and inspected.
- Use only explosionproof tools (non-sparking) when working in classified areas during energized conditions.
- Verify the area is gas-free with a calibrated gas detector before performing any work in a classified area.
- Explosionproof enclosures must not be opened while energized in a classified atmosphere.
- All threaded connections must be wrench-tight — loose connections compromise the flame path and can allow flame escape.',
      50, true, true,
      '[
        {"question":"What wiring methods are permitted in Class I, Division 1?","options":["EMT and PVC","RMC, IMC, and Type MI cable with threaded connections","Romex","Any metal conduit"],"correctIndex":1},
        {"question":"How far from the enclosure must a conduit seal be installed in Division 1?","options":["6 inches","18 inches","36 inches","72 inches"],"correctIndex":1},
        {"question":"What is the minimum thread engagement required for threaded connections in hazardous locations?","options":["2 full threads","5 full threads","10 full threads","No minimum"],"correctIndex":1},
        {"question":"What does the T-code (temperature classification) indicate?","options":["The ambient temperature rating","The maximum surface temperature of the equipment, which must not exceed 80% of the auto-ignition temperature of the hazardous gas","The operating temperature","The storage temperature"],"correctIndex":1},
        {"question":"What must be done with conductors in a seal fitting?","options":["Bundle them tightly","Separate them so the sealing compound fills all voids","Use only one conductor per seal","No special requirement"],"correctIndex":1},
        {"question":"What is the purpose of a breather fitting?","options":["To seal the conduit","To allow pressure equalization in explosionproof enclosures while preventing flame passage","To drain condensation","To ground the enclosure"],"correctIndex":1},
        {"question":"What should be verified before performing work in a classified area?","options":["Nothing","The area is gas-free, verified with a calibrated gas detector","The area is clean","The area is dry"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 7: Control Transformers & 24V Control Circuits — Add Module 3: Advanced Control Circuit Design
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Control Transformers & 24V Control Circuits' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Advanced Control Circuit Design') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Control Circuit Design', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Two-Wire vs Three-Wire Control Circuits',
      '## Overview

Control circuits are the brains of every industrial motor system. The two most fundamental control circuit designs are two-wire and three-wire control. Understanding the difference, when to use each, and how to troubleshoot them is essential for any industrial electrician. These circuits determine whether a motor restarts automatically after a power interruption or requires manual intervention.

## Key Concepts

- **Two-wire control**: Uses a maintained contact (float switch, pressure switch, thermostat) to control the motor. If power is lost and restored, the motor restarts automatically if the control contact is still closed. This is desirable for unattended operations like sump pumps.
- **Three-wire control**: Uses a momentary start button, a stop button, and a holding (seal-in) contact from the motor starter. If power is lost, the motor stops and will NOT restart automatically — a safety feature for most industrial machinery.
- **Seal-in (holding) circuit**: In three-wire control, a normally open auxiliary contact from the motor starter is wired in parallel with the start button to maintain the circuit after the start button is released.
- **Undervoltage release vs undervoltage protection**: Two-wire control provides undervoltage release (auto-restart); three-wire control provides undervoltage protection (no auto-restart).
- **Control circuit voltage**: 24V AC/DC is the modern standard for safety and convenience. 120V is common in older installations.

## Step-by-Step: Designing a Three-Wire Control Circuit

1. **Draw the power circuit**: L1 through the fuse/disconnect, through the contactor contacts, through the overload relay, to the motor, to L2/L3.
2. **Draw the control circuit**: From the control transformer secondary, through a control fuse, to the stop button (normally closed, in series).
3. **Add the start button**: Wire the start button (normally open) in parallel with the seal-in contact, after the stop button.
4. **Add the seal-in contact**: Wire a normally open auxiliary contact from the motor contactor in parallel with the start button.
5. **Add the overload contact**: Wire the normally closed overload relay contact in series, after the start/stop/seal-in section.
6. **Connect the coil**: Wire from the overload contact to the motor contactor coil, then to the other side of the control transformer.
7. **Add indicators (optional)**: Wire pilot lights (run light, stop light, fault light) using auxiliary contacts.
8. **Verify operation**: When start is pressed, the coil energizes, the seal-in contact closes, and the motor runs. When stop is pressed (or overload trips), the circuit opens and the motor stops.

## Common Problems

- **Seal-in contact failure**: If the seal-in (holding) contact is dirty or misadjusted, the motor will start when the button is pressed but stop when released.
- **Wrong control type for application**: Using two-wire control on machinery that requires three-wire (no auto-restart) creates a safety hazard.
- **Voltage drop on long control runs**: 24V control circuits are susceptible to voltage drop on long wire runs, causing contactor chatter.
- **Missing control fuse**: Omitting the control circuit fuse allows a short in the control circuit to damage the transformer or wiring.
- **Overload contact wiring**: Wiring the normally closed overload contact incorrectly (in parallel instead of series) prevents the overload from stopping the motor.

## Best Practices

- Use three-wire control for all machinery where automatic restart after a power loss would be dangerous.
- Use two-wire control only for unattended operations where automatic restart is desired (sump pumps, remote monitoring).
- Always include a control circuit fuse on both primary and secondary of the control transformer.
- Use 24V AC or DC for control circuits to reduce shock hazard per NFPA 79 and NEC 504A.
- Wire the stop button in series and the start button in parallel with the seal-in contact — this is the standard convention.
- Include a motor running light (green) and a fault/tripped light (red) for easy status identification.

## Safety

- Three-wire control is a safety feature — do not bypass the seal-in circuit or convert to two-wire without engineering review.
- Always de-energize and lock out before modifying control circuits.
- Verify the control circuit voltage is appropriate for the environment — 120V control in wet or confined areas may require GFCI or reduced to 24V.
- Never bypass the overload contact — it is the motor''s thermal protection.
- Test the stop button and emergency stop after any control circuit modification.',
      45, true, true,
      '[
        {"question":"What is the key difference between two-wire and three-wire control?","options":["Two-wire uses 2 wires, three-wire uses 3","Two-wire auto-restarts after power loss; three-wire does not auto-restart (requires manual restart)","Two-wire is for DC, three-wire is for AC","Three-wire is more efficient"],"correctIndex":1},
        {"question":"What is the purpose of the seal-in (holding) contact in a three-wire control circuit?","options":["To seal the enclosure","To maintain the circuit after the start button is released, keeping the motor running","To stop the motor","To protect against overload"],"correctIndex":1},
        {"question":"Which control type is safer for machinery that should not auto-restart after a power loss?","options":["Two-wire control","Three-wire control","Either is equally safe","Neither"],"correctIndex":1},
        {"question":"How is the stop button wired in a three-wire control circuit?","options":["In parallel with the start button","In series with the control circuit (normally closed)","In parallel with the coil","Not connected"],"correctIndex":1},
        {"question":"What is a common symptom of a failed seal-in contact?","options":["The motor will not start","The motor starts when the button is pressed but stops when released","The motor runs continuously","The overload trips"],"correctIndex":1},
        {"question":"What voltage is the modern standard for industrial control circuits?","options":["480V","120V","24V AC or DC","12V"],"correctIndex":2},
        {"question":"What happens if the normally closed overload contact is wired in parallel instead of series?","options":["The motor runs faster","The overload relay cannot stop the motor when it trips","The motor will not start","The fuse blows"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Timer & Relay Logic in Control Circuits',
      '## Overview

Timer and relay logic form the foundation of sequential industrial control before PLCs became ubiquitous. Even in PLC-controlled systems, understanding timer and relay logic is essential for troubleshooting, designing backup circuits, and understanding the underlying control philosophy. On-delay, off-delay, and pulse timers, combined with control relays, can implement complex sequences.

## Key Concepts

- **On-delay timer (TON)**: The timed contact changes state after the timer is energized for the preset time. Used for sequencing, anti-short-cycling, and startup delays.
- **Off-delay timer (TOF)**: The timed contact changes state after the timer is de-energized for the preset time. Used for shutdown sequencing, purge timing, and keep-alive circuits.
- **One-shot (pulse) timer**: Produces a fixed-duration pulse when triggered. Used for signaling and latching.
- **Control relay**: An electromechanical switch with multiple contacts (NO and NC) used to implement logic, interlocking, and signal multiplication.
- **Interlocking**: Using relay contacts to prevent two operations from occurring simultaneously (e.g., preventing forward and reverse contactors from being energized at the same time).

## Step-by-Step: Designing a Sequenced Motor Start Circuit

1. **Define the sequence**: Motor 1 must start, then 5 seconds later Motor 2 starts, then 5 seconds later Motor 3 starts. This prevents simultaneous inrush.
2. **Start Motor 1**: The start button energizes Motor 1 contactor (M1) and an on-delay timer (T1) set for 5 seconds.
3. **Start Motor 2**: After T1 times out, its NO contact closes and energizes Motor 2 contactor (M2) and on-delay timer (T2) set for 5 seconds.
4. **Start Motor 3**: After T2 times out, its NO contact closes and energizes Motor 3 contactor (M3).
5. **Stop sequence**: The stop button de-energizes all contactors and timers simultaneously (all motors stop). For a sequenced stop, use off-delay timers.
6. **Add interlocks**: Use NC auxiliary contacts from M1 in the M2 circuit, and M2 in the M3 circuit, to ensure motors cannot start out of sequence.
7. **Add fault logic**: If any motor overload trips, all motors stop (wire all overload NC contacts in series in the control circuit).
8. **Add indicators**: Green lights for running, amber for starting sequence, red for fault.

## Common Problems

- **Timer failure**: Mechanical timers drift or fail to time accurately. Solid-state timers are more reliable but can fail due to voltage transients.
- **Contact bounce**: Relay contacts may bounce on closure, causing intermittent operation. Use debounce timers for critical circuits.
- **Race conditions**: In relay logic, multiple relays changing state simultaneously can create unintended operation. Use interposing timers to sequence events.
- **Missing interlocks**: Without proper interlocks, two conflicting operations can occur simultaneously, causing damage or danger.
- **Control power interruption**: A momentary power dip can de-energize timers and relays, disrupting the sequence. Use relays with delay-dropout or UPS backup for critical sequences.

## Best Practices

- Use solid-state timers for accuracy and reliability over mechanical timers.
- Always include mechanical and electrical interlocks for conflicting operations.
- Draw the logic on a ladder diagram before building — it is easier to find logic errors on paper than in the field.
- Use a master control relay (MCR) to de-energize all outputs in case of emergency stop or fault.
- Label all timers and relays with unique identifiers and document their function in the drawing notes.
- Include a "first scan" or "initialization" timer to ensure all outputs are in a known state on power-up.

## Safety

- Never rely solely on electrical interlocks for safety — use mechanical interlocks (contactors with mechanical interlock bars) for reversing circuits.
- Emergency stop circuits must be hardwired, fail-safe, and not dependent on timer or relay logic.
- All timers and relays must be in a control panel, not exposed to the environment.
- Test the complete sequence after any modification to verify no unintended operation occurs.
- Document all timer settings and relay logic — undocumented changes create serious troubleshooting challenges.',
      50, true, true,
      '[
        {"question":"What does an on-delay timer (TON) do?","options":["Changes state immediately when energized","Changes state after the timer has been energized for the preset time","Changes state when de-energized","Produces a pulse"],"correctIndex":1},
        {"question":"What does an off-delay timer (TOF) do?","options":["Changes state when energized","Changes state after the timer has been de-energized for the preset time","Produces a continuous pulse","Stops the motor immediately"],"correctIndex":1},
        {"question":"What is the purpose of interlocking in control circuits?","options":["To save wire","To prevent two conflicting operations from occurring simultaneously","To improve efficiency","To reduce voltage"],"correctIndex":1},
        {"question":"What is a master control relay (MCR)?","options":["The main contactor","A relay that de-energizes all outputs in case of emergency stop or fault","A timer","A type of overload relay"],"correctIndex":1},
        {"question":"What is a race condition in relay logic?","options":["A fast relay","When multiple relays change state simultaneously, causing unintended operation","A short circuit","A ground fault"],"correctIndex":1},
        {"question":"Why should emergency stop circuits not depend on timer or relay logic?","options":["They are too slow","They must be hardwired and fail-safe, not dependent on logic that could fail","They are too expensive","They are not needed"],"correctIndex":1},
        {"question":"What type of timer is more reliable and accurate?","options":["Mechanical (pneumatic) timers","Solid-state timers","Spring-wound timers","Clock timers"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 8: Electrical Prints, Schematics & Ladder Diagrams — Add Module 3: Advanced Diagram Reading & Field Applications
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Electrical Prints, Schematics & Ladder Diagrams' AND stage = 'electrical';
  IF c_ID IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Advanced Diagram Reading & Field Applications') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Diagram Reading & Field Applications', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Reading Motor Control & PLC Schematics',
      '## Overview

Motor control and PLC schematics combine traditional ladder logic with PLC I/O diagrams. Being able to read these hybrid drawings is essential for troubleshooting modern industrial control systems. The schematic tells you what the system does, how the components are connected, and where to test when something goes wrong.

## Key Concepts

- **PLC I/O diagrams**: Show the physical wiring to PLC input and output modules. Each I/O point has an address (e.g., I:1/0 for input, O:2/1 for output in Allen-Bradley notation).
- **Internal relay logic**: The PLC program uses internal (virtual) relays, timers, and counters that do not appear on the wiring diagram but are shown in the PLC ladder logic printout.
- **Interposing relays**: Physical relays between the PLC output and the field device, used for isolation, current amplification, or voltage conversion.
- **Wire numbers and terminal IDs**: Each wire has a unique number; each terminal has a unique identifier. These are the key to tracing circuits from the drawing to the panel.
- **External vs internal contacts**: Physical contacts (limit switches, push buttons) appear on the I/O diagram; internal PLC contacts appear only in the PLC ladder logic.

## Step-by-Step: Tracing a Fault Using Motor Control & PLC Schematics

1. **Identify the symptom**: The motor is not running. Determine if the PLC is commanding the output.
2. **Check the PLC output**: On the I/O diagram, find the output module and the specific output address. Check if the output LED is lit on the PLC module.
3. **If the output LED is off**: The problem is in the PLC program or inputs. Go to the PLC ladder logic and trace the rung that controls this output.
4. **If the output LED is on**: The problem is between the PLC output and the motor. Follow the wire from the output terminal through the interposing relay to the motor contactor.
5. **Check the interposing relay**: If used, verify the relay coil is energized (LED on relay is lit) and the contact is closing.
6. **Check the motor contactor**: Verify the contactor coil is energized. If not, trace the control circuit from the relay contact through the overload relay to the contactor coil.
7. **Check the overload relay**: If the overload is tripped, the NC contact will be open. Reset and investigate the cause.
8. **Check the power circuit**: If the contactor is energized but the motor does not run, check the power circuit: fuses, breaker, contactor contacts, and motor terminals.

## Common Problems

- **Mismatched drawings**: The as-built drawings do not match the actual wiring. Always verify with a meter, not just the drawing.
- **PLC program changes**: The PLC program was modified but the drawings were not updated. The output may not behave as the drawing suggests.
- **Wrong I/O address**: Confusing input and output addresses, or decimal and octal addressing, leads to testing the wrong point.
- **Missing interposing relay on drawing**: An interposing relay was added in the field but not documented, making troubleshooting difficult.
- **Internal vs external confusion**: Looking for a physical limit switch when the contact is actually an internal PLC contact controlled by program logic.

## Best Practices

- Always keep as-built drawings updated — any field change must be documented on the drawings.
- Use consistent wire numbering and terminal identification schemes throughout the facility.
- Keep a copy of the PLC program with the most recent comments alongside the electrical drawings.
- Mark interposing relays and their function on the I/O diagram.
- Use color-coded wire markers that match the drawing wire numbers.
- Create a "troubleshooting guide" document that maps common symptoms to the relevant drawing pages and test points.

## Safety

- Always de-energize and lock out before touching any wiring, even when following the drawing.
- Verify the drawing matches the actual wiring before relying on it for troubleshooting.
- PLC outputs can energize without warning — do not assume an output is off just because the motor is not running.
- Use a rated voltage tester to verify absence of voltage before touching terminals.
- When testing energized circuits, wear appropriate PPE and use properly rated test instruments.',
      45, true, true,
      '[
        {"question":"What does a PLC I/O diagram show?","options":["The PLC program logic","The physical wiring to PLC input and output modules with addresses","The motor power circuit","The panel layout"],"correctIndex":1},
        {"question":"What is an interposing relay?","options":["A relay inside the PLC","A physical relay between the PLC output and field device, used for isolation or current amplification","A type of timer","A type of overload relay"],"correctIndex":1},
        {"question":"If the PLC output LED is on but the motor is not running, where is the problem likely located?","options":["In the PLC program","Between the PLC output and the motor (interposing relay, contactor, or overload)","In the PLC power supply","In the input wiring"],"correctIndex":1},
        {"question":"What is the difference between internal and external PLC contacts?","options":["There is no difference","External contacts are physical (limit switches, buttons); internal contacts are virtual, existing only in the PLC program","Internal contacts are more reliable","External contacts are faster"],"correctIndex":1},
        {"question":"What should you do if the as-built drawing does not match the actual wiring?","options":["Ignore the drawing","Update the drawing to match the actual wiring and verify the change is correct","Remove the wiring","Replace the drawing entirely"],"correctIndex":1},
        {"question":"What is a common cause of PLC program behavior not matching the drawings?","options":["Voltage drops","The PLC program was modified but the drawings were not updated","The PLC is too old","The motor is oversized"],"correctIndex":1},
        {"question":"What must be done before touching any wiring during troubleshooting?","options":["Nothing — the drawing tells you it is safe","De-energize and lock out, then verify absence of voltage with a rated tester","Just check the drawing","Turn off the PLC"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Creating & Maintaining As-Built Documentation',
      '## Overview

As-built documentation is the record of how a system was actually installed, including all field modifications. It is the single most important reference for troubleshooting, maintenance, and future modifications. Without accurate as-built drawings, troubleshooting becomes guesswork, and modifications risk creating safety hazards. Maintaining as-built documentation is a professional responsibility.

## Key Concepts

- **As-built vs design drawings**: Design drawings show the intended installation; as-built drawings show the actual installation, including all field changes.
- **Red-line markup**: Marking up design drawings in the field with changes, then transferring them to the final as-built drawings.
- **Wire lists and terminal schedules**: Tabular documents that list every wire number, its source, destination, and terminal assignment.
- **BOM (Bill of Materials)**: A complete list of all components, including spare parts and substitutions made in the field.
- **Digital documentation**: Modern as-built documentation includes CAD files, scanned red-lines, photos, and digital wire lists.

## Step-by-Step: Creating As-Built Documentation from a Field Installation

1. **Start with the design drawings**: Use the design drawings as the base. Mark any changes in red (red-line) as they occur during installation.
2. **Document wire changes**: If a wire number, routing, or destination changes, mark it on the drawing and update the wire list.
3. **Document component substitutions**: If a component was substituted (different manufacturer, different model), note it on the drawing and update the BOM.
4. **Document terminal changes**: If wires were moved to different terminals, update the terminal schedule.
5. **Photograph the installation**: Take photos of the panel interior, terminal blocks, and field devices before closing panels.
6. **Update the CAD files**: Transfer all red-line changes to the CAD drawings to create the final as-built set.
7. **Create a wire list**: Generate a tabular wire list from the as-built drawing showing every wire, its number, source, and destination.
8. **Review and verify**: Have a second person verify the as-built drawings against the actual installation.
9. **Store and distribute**: Store the as-built drawings in a controlled location and distribute copies to maintenance and operations.

## Common Problems

- **No as-built drawings**: The most common problem. Drawings were never created or updated after installation changes.
- **Outdated drawings**: Drawings exist but do not reflect recent modifications. This is worse than no drawings because it creates false confidence.
- **Unreadable red-lines**: Field red-lines are illegible or incomplete, making it impossible to create accurate as-builts.
- **Missing wire lists**: Drawings show the schematic but not the wire routing, making it difficult to trace wires in the field.
- **No version control**: Multiple copies of drawings exist, and no one knows which is current.

## Best Practices

- Red-line drawings in the field as changes are made — do not wait until the project is over.
- Transfer red-lines to CAD drawings within one week of the change.
- Use a document control system with revision numbers and dates.
- Include photos of panel interiors and field installations with the as-built package.
- Generate and maintain a wire list and terminal schedule alongside the drawings.
- Conduct an annual drawing audit to verify as-builts match the actual installation.
- Keep both electronic and hard copies of as-built drawings in a known, accessible location.

## Safety

- Inaccurate drawings can lead to energizing the wrong circuit — always verify with a meter before working.
- Never modify wiring without updating the drawings — undocumented changes create hazards for the next technician.
- Store drawings in a fireproof location — losing the only copy of as-built drawings can cripple maintenance.
- Mark de-energized and energized circuits clearly on the drawings during maintenance.
- Include safety notes on drawings: arc flash labels, voltage warnings, and LOTO points.',
      40, true, true,
      '[
        {"question":"What is the difference between design drawings and as-built drawings?","options":["There is no difference","Design drawings show the intended installation; as-built drawings show the actual installation including all field changes","As-built drawings are simpler","Design drawings are more accurate"],"correctIndex":1},
        {"question":"What is red-line markup?","options":["A type of wire","Marking up design drawings in the field with changes, to be transferred to final as-built drawings","A type of terminal block","A type of fuse"],"correctIndex":1},
        {"question":"What is a wire list?","options":["A list of wire manufacturers","A tabular document listing every wire number, source, destination, and terminal assignment","A list of wire colors","A list of wire gauges"],"correctIndex":1},
        {"question":"What is the most common documentation problem in industrial facilities?","options":["Too many drawings","No as-built drawings or outdated drawings that do not reflect modifications","Drawings are too detailed","Drawings are in the wrong format"],"correctIndex":1},
        {"question":"When should red-line changes be transferred to CAD drawings?","options":["Never","Within one week of the change","Once a year","Only at project completion"],"correctIndex":1},
        {"question":"What should be included with the as-built drawing package?","options":["Only the drawings","Photos of panel interiors, wire lists, terminal schedules, and BOM","Only the BOM","Only the wire list"],"correctIndex":1},
        {"question":"Why is it dangerous to modify wiring without updating the drawings?","options":["It is not dangerous","Undocumented changes create hazards for the next technician who relies on the drawings","It violates NEC","It voids the warranty"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 9: Electrical Safety Programs & NFPA 70E Application — Add Module 3: Audits, Training & Continuous Improvement
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Electrical Safety Programs & NFPA 70E Application' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Audits, Training & Continuous Improvement') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Audits, Training & Continuous Improvement', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Conducting Electrical Safety Audits',
      '## Overview

An electrical safety audit is a systematic evaluation of an organization''s electrical safety program, procedures, and field practices. NFPA 70E requires audits at least every 3 years, but effective programs conduct more frequent field audits. The audit identifies gaps between the written program and actual practice, ensuring that the program is not just paper compliance but real protection for workers.

## Key Concepts

- **Program audit vs field audit**: Program audits review the written program, procedures, and training records. Field audits observe workers performing tasks and verify compliance with procedures.
- **Audit frequency**: NFPA 70E requires program audits every 3 years. Field audits should be conducted at least annually, with informal observations continuously.
- **Audit scope**: Covers hazard analysis, PPE program, LOTO procedures, energized work permits, training records, and field compliance.
- **Audit team**: Should include a qualified person, a safety professional, and ideally an outside auditor for objectivity.
- **Corrective action tracking**: Every audit finding must have a documented corrective action with a responsible person and due date.

## Step-by-Step: Conducting an Electrical Safety Audit

1. **Plan the audit**: Define the scope, schedule, and audit team. Notify affected departments but do not give so much notice that practices are temporarily improved.
2. **Review the written program**: Compare the program to NFPA 70E current edition requirements. Identify any gaps or outdated references.
3. **Review training records**: Verify all qualified workers have current training (within 3 years). Check for documentation of training content, dates, and attendees.
4. **Review incident and near-miss records**: Analyze trends in electrical incidents and near-misses. Identify systemic issues.
5. **Review energized work permits**: Sample recent permits for completeness, justification, and proper authorization.
6. **Conduct field observations**: Observe workers performing electrical tasks. Verify PPE is worn correctly, LOTO is performed properly, and safe work practices are followed.
7. **Inspect PPE**: Check arc-rated clothing, gloves, face shields, and other PPE for condition, cleanliness, and current inspection dates.
8. **Interview workers**: Ask qualified workers about hazards, PPE selection, LOTO procedures, and emergency response. Assess their understanding.
9. **Document findings**: Record all findings with severity levels (critical, major, minor). Assign corrective actions with responsible persons and due dates.
10. **Report and follow up**: Present findings to management. Track corrective actions to completion. Verify effectiveness of corrections.

## Common Problems

- **Paper compliance only**: The program looks good on paper but is not followed in the field. The audit must verify field practice, not just documentation.
- **No corrective action follow-through**: Findings are documented but never corrected. This is worse than not auditing because it creates a false sense of safety.
- **Auditor lacks qualifications**: An auditor who is not a qualified person cannot effectively evaluate electrical safety practices.
- **No field observations**: Auditing only documents and not observing workers misses the most important aspect — actual practice.
- **Infrequent audits**: A 3-year audit cycle is the minimum. Programs deteriorate quickly without more frequent field observations.

## Best Practices

- Conduct informal field observations monthly and formal field audits annually.
- Use a standardized audit checklist based on NFPA 70E requirements.
- Include both program review and field observation in every audit.
- Track every finding to closure with a documented corrective action.
- Share audit results with all qualified workers, not just management.
- Use audit trends to identify systemic issues and prioritize program improvements.
- Engage an outside auditor periodically for an objective perspective.

## Safety

- Auditors observing energized work must wear appropriate PPE and maintain safe approach distances.
- Do not interrupt a worker performing a critical task for the audit — wait until the task is complete.
- Audit findings about unsafe practices must be addressed immediately, not just documented for later correction.
- Protect the confidentiality of individual workers — the audit is about improving the program, not punishing individuals.
- Ensure the audit itself does not create a distraction that leads to an incident.',
      45, true, true,
      '[
        {"question":"How often does NFPA 70E require a program audit?","options":["Annually","At least every 3 years","Every 5 years","Only after an incident"],"correctIndex":1},
        {"question":"What is the difference between a program audit and a field audit?","options":["There is no difference","Program audits review the written program and records; field audits observe workers performing tasks","Program audits are longer","Field audits are more thorough"],"correctIndex":1},
        {"question":"What must every audit finding have?","options":["A fine","A documented corrective action with a responsible person and due date","A manager signature","A training session"],"correctIndex":1},
        {"question":"Who should be on the audit team?","options":["Anyone","A qualified person, a safety professional, and ideally an outside auditor","Only management","Only the safety officer"],"correctIndex":1},
        {"question":"What is the most important part of the audit?","options":["Reviewing documents","Field observation of workers performing tasks to verify actual compliance","Reviewing training records","Interviewing management"],"correctIndex":1},
        {"question":"What is a common audit failure?","options":["Findings are too detailed","Findings are documented but never corrected (no follow-through)","Audits are too frequent","Auditors are too qualified"],"correctIndex":1},
        {"question":"What should be done with audit results?","options":["Keep them confidential to management","Share them with all qualified workers to improve the program","File them and forget them","Only report critical findings"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Training Programs & Competency Assessment',
      '## Overview

Training is the bridge between the written safety program and actual field practice. NFPA 70E requires that qualified persons receive training on safe work practices, hazard recognition, emergency procedures, and PPE selection, with refresher training at least every 3 years. But effective training goes beyond meeting the minimum — it ensures workers can actually perform tasks safely and correctly.

## Key Concepts

- **Qualified person definition**: One who has received training in and has demonstrated skills and knowledge in the construction and operation of electric equipment and installations and the hazards involved (NFPA 70E).
- **Training frequency**: Initial training for new workers, refresher training at least every 3 years, and additional training when new equipment, procedures, or hazards are introduced.
- **Competency assessment**: Verifying that workers can apply their training in the field, not just pass a written test. Includes practical demonstration.
- **Training methods**: Classroom instruction, hands-on practice, computer-based training, and on-the-job mentoring. A mix is most effective.
- **Training documentation**: Records must include content, date, instructor, attendees, and assessment results.

## Step-by-Step: Developing an Electrical Safety Training Program

1. **Assess training needs**: Identify the tasks qualified workers perform and the hazards they face. Determine the knowledge and skills required.
2. **Define learning objectives**: For each topic, write specific, measurable objectives (e.g., "Given a motor control circuit, the worker will perform LOTO correctly 100% of the time").
3. **Develop training content**: Create or purchase training materials that cover NFPA 70E requirements, facility-specific procedures, and hands-on skills.
4. **Deliver initial training**: Provide classroom instruction followed by hands-on practice. Use real equipment or simulators for practical exercises.
5. **Assess competency**: Administer a written test for knowledge and a practical demonstration for skills. Require a minimum score (typically 80%) to pass.
6. **Provide on-the-job mentoring**: Pair new workers with experienced qualified workers for a defined period (e.g., 90 days) before allowing independent work.
7. **Deliver refresher training**: Provide refresher training at least every 3 years, or when new equipment, procedures, or hazards are introduced.
8. **Document all training**: Maintain records of all training, including content, date, instructor, attendees, assessment results, and competency verification.
9. **Evaluate effectiveness**: Monitor incident rates, near-miss reports, and field audit results to assess whether training is effective.
10. **Continuously improve**: Update training content based on incident lessons, audit findings, and changes in standards or equipment.

## Common Problems

- **Training as a checkbox**: Training is conducted to meet a requirement but does not actually prepare workers for field conditions.
- **No competency assessment**: Workers attend training but are not tested on their ability to apply it. A certificate of attendance is not proof of competency.
- **Outdated training materials**: Training content references old editions of NFPA 70E or equipment no longer in use.
- **No hands-on component**: Training is entirely classroom-based with no practical exercises. Workers cannot apply what they learned.
- **No mentoring period**: New workers are expected to perform independently immediately after training, without supervised practice.

## Best Practices

- Use a blended approach: classroom, hands-on, computer-based, and on-the-job mentoring.
- Require both a written test and a practical demonstration for competency assessment.
- Update training materials whenever NFPA 70E is revised (every 3 years) or when facility equipment changes.
- Include scenario-based training: present real-world situations and have workers describe or demonstrate the correct response.
- Use experienced workers as mentors and trainers — they bring real-world knowledge that textbooks cannot.
- Track training effectiveness by correlating training dates with incident and near-miss rates.
- Make training interactive, not just lecture — workers retain more when they participate.

## Safety

- Training itself must be safe — do not create hazardous situations during practical exercises.
- Use de-energized equipment or simulators for hands-on practice.
- Ensure trainers are qualified and experienced in the topics they teach.
- Never certify a worker as qualified if they have not demonstrated competency — this creates a false sense of safety.
- Training on energized work must emphasize that de-energization is always the preferred option.',
      45, true, true,
      '[
        {"question":"How often must refresher training be provided per NFPA 70E?","options":["Annually","At least every 3 years","Every 5 years","Only after an incident"],"correctIndex":1},
        {"question":"What is the NFPA 70E definition of a qualified person?","options":["An electrician","One who has received training and demonstrated skills and knowledge in electrical equipment and hazards","Anyone who works with electricity","A licensed engineer"],"correctIndex":1},
        {"question":"What must competency assessment include?","options":["Only a written test","Both a written test for knowledge and a practical demonstration for skills","Only attendance","A supervisor recommendation"],"correctIndex":1},
        {"question":"What is a common training failure?","options":["Training is too long","Training is a checkbox exercise that does not prepare workers for field conditions","Training is too hands-on","Training is too frequent"],"correctIndex":1},
        {"question":"What should be done with new workers after initial training?","options":["Immediately assign independent work","Pair them with experienced workers for a defined mentoring period (e.g., 90 days)","Give them a manual to read","Have them observe only"],"correctIndex":1},
        {"question":"What must training records include?","options":["Only the date","Content, date, instructor, attendees, assessment results, and competency verification","Only the attendee names","Only the training location"],"correctIndex":1},
        {"question":"When should training materials be updated?","options":["Never","Whenever NFPA 70E is revised or facility equipment changes","Every 10 years","Only after an incident"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;
