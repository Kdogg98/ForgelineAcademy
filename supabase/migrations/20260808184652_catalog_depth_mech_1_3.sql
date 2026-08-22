/*
# Catalog depth expansion — Mechanical courses 1-3 (Bearings, Pump, Conveyor)

## Overview
Adds new modules to reach 3-5 modules per course, adds lessons to new modules,
and rewrites all existing lesson content with structured text-first format
(Overview, Key Concepts, Procedures, Common Problems, Best Practices, Safety).
Expands all quizzes to 6-10 questions testing real understanding.

## Courses in this batch
1. Bearings, Lubrication & Alignment Fundamentals (add 1 module → 4 total)
2. Pump & Mechanical Seal Maintenance (add 2 modules → 4 total)
3. Conveyor & Drive Systems (add 2 modules → 4 total)

## Security
No schema or policy changes. Data-only migration.
*/

-- ===================== 1. BEARINGS, LUBRICATION & ALIGNMENT =====================
-- Currently 3 modules, 4 lessons. Add 1 new module with 2 lessons → 4 modules, 6 lessons.

DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Bearings, Lubrication & Alignment Fundamentals';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 4
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Alignment & Condition Monitoring', 4) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Thermal Growth & Hot Alignment',
   '## Overview
Thermal growth is the expansion of machine components as they reach operating temperature. A machine aligned cold will shift as it heats, potentially moving out of tolerance. Understanding and compensating for thermal growth is the difference between an alignment that lasts months and one that fails in days.

## Key Concepts
- Steel grows approximately 0.001 mm per 100 mm of length per 10°C rise above ambient.
- A pump operating at 80°C with a center height of 500 mm grows roughly 0.3 mm vertically — enough to misalign the coupling if the motor (at ambient) is not offset.
- The growth is calculated from the coefficient of thermal expansion (12 × 10⁻⁶ /°C for steel), the dimension, and the temperature difference.
- Machines that grow unevenly (e.g., a hot pump and a cool motor) develop both parallel and angular misalignment as they reach operating temperature.

## Step-by-Step: Compensating for Thermal Growth
1. Measure the operating temperature of both machines at the bearing housings and the feet.
2. Calculate the thermal growth for each machine: Δh = α × L × ΔT, where α is the coefficient, L is the center height, and ΔT is the temperature rise.
3. Determine the net difference between the two machines — this is the offset you must build into the cold alignment.
4. Set the cold alignment with the motor shimmed higher (or lower) by the calculated offset so that the machines grow into alignment at operating temperature.
5. Verify the hot alignment by measuring at operating temperature with a laser system designed for hot measurement, or by checking vibration levels after the machine reaches steady state.

## Common Problems and Fixes
- **Alignment will not hold:** If the machine keeps coming out of alignment after a few days of operation, thermal growth is likely the cause. Measure the hot alignment and calculate the required cold offset.
- **Vibration increases after startup:** A machine that runs smooth cold but vibrates after warming up has thermal growth misalignment. The fix is to pre-offset the cold alignment.
- **Only one end grows:** Some machines (e.g., steam turbines) grow more at the hot end. This creates angular thermal growth. The cold alignment must compensate for both the offset and the angularity.

## Best Practices and Field Tips
- Some laser alignment systems have a thermal growth compensation feature that calculates and applies the offset automatically — use it if available.
- Document both the cold and hot alignment values for each machine to build a thermal growth database. The next alignment on the same machine is faster with historical data.
- For machines with large temperature differentials, consider a hot alignment check as part of the commissioning process.
- Pipe strain and thermal growth compound — correct pipe strain first, then compensate for thermal growth.

## Safety Notes
- Never attempt to measure alignment on a machine at operating temperature without appropriate PPE (heat-resistant gloves, face shield). Hot surfaces can cause severe burns.
- Ensure the machine is running at normal operating load before taking hot measurements — a partially loaded machine has a different thermal profile.',
   50, 1,
   '[{"question":"How much does steel grow per 100 mm per 10°C?","options":["0.0001 mm","0.001 mm","0.01 mm","0.1 mm"],"correctIndex":1},{"question":"What is the formula for thermal growth?","options":["Δh = α × L × ΔT","Δh = L × ΔT","Δh = α × ΔT","Δh = α × L"],"correctIndex":0},{"question":"What does it mean if a machine runs smooth cold but vibrates after warming up?","options":["Bearing failure","Thermal growth misalignment — pre-offset the cold alignment","Imbalance","Loose foundation bolts"],"correctIndex":1},{"question":"What should be corrected before compensating for thermal growth?","options":["Bearing clearance","Pipe strain","Lubricant viscosity","Coupling type"],"correctIndex":1},{"question":"Why should you document both cold and hot alignment values?","options":["For regulatory compliance","To build a thermal growth database that speeds up future alignments","To calculate bearing life","To determine motor FLA"],"correctIndex":1},{"question":"What PPE is required for hot alignment measurement?","options":["Safety glasses only","Heat-resistant gloves and face shield","Hard hat only","No special PPE"],"correctIndex":1},{"question":"What causes angular thermal growth?","options":["Misalignment at cold state","Uneven growth between hot and cold ends of a machine","Bearing wear","Pipe strain"],"correctIndex":1}]'::jsonb),
  (m_id, 'Condition Monitoring for Bearings',
   '## Overview
Condition monitoring uses periodic measurements to detect bearing degradation before failure. The goal is to catch a bearing in the early stages of wear and schedule the replacement during a planned outage, not during a breakdown.

## Key Concepts
- Vibration analysis is the primary tool for bearing condition monitoring. Bearing defect frequencies (BPFO, BPFI, BSF, FTF) are calculated from the bearing geometry and the running speed.
- The outer race defect frequency (BPFO) typically appears first because the outer race is stationary and the defect is loaded each time a ball passes.
- The overall vibration trend (velocity in mm/s) is the first alarm; the spectrum identifies the cause.
- Oil analysis complements vibration by detecting wear metals (Fe, Cu, Cr) in the lubricant before the vibration signature develops.
- Ultrasound detects high-frequency friction signals earlier than vibration — a rising ultrasound dB on a bearing that shows no vibration anomaly is an early warning.

## Step-by-Step: Bearing Condition Monitoring Route
1. Identify all critical rotating machines and assign a monitoring interval (monthly for critical, quarterly for less critical).
2. Mark the measurement point on each bearing housing with paint or a stamped dot for repeatability.
3. Collect the overall vibration velocity (mm/s) and the spectrum (FFT) at each point in the radial and axial directions.
4. Compare the overall reading to the ISO 10816 alarm levels (4.5 mm/s warning, 7.1 mm/s danger for most machines).
5. If the overall is elevated, examine the spectrum for bearing defect frequencies. Input the bearing part number into the analyzer to calculate the expected BPFO, BPFI, BSF, and FTF.
6. A bearing defect frequency that doubles in amplitude over two consecutive measurements warrants scheduling a replacement.
7. Take an oil sample quarterly for wear metal analysis and compare to the trend.
8. Perform an ultrasound reading during the route — a 7-8 dB rise above baseline indicates early distress.

## Common Problems and Fixes
- **No trend data:** Without baseline data, you cannot detect a change. Establish baselines on new or recently serviced bearings.
- **Inconsistent measurement location:** A measurement taken at a different point or direction is not comparable. Mark the point and always measure there.
- **Bearing defect frequency appears but overall is normal:** The defect is in its early stage. Schedule a follow-up measurement in 2-4 weeks to confirm the trend.
- **Spectrum is noisy with no clear peaks:** The bearing may be in advanced degradation (the "haystack" pattern). Plan replacement immediately.

## Best Practices and Field Tips
- Use the same sensor, the same mounting, and the same machine operating condition for every measurement.
- A bearing defect frequency with sidebands indicates the defect is spreading from a single point to the entire race.
- Combine vibration, oil analysis, and ultrasound for the most reliable assessment — no single technology catches everything.
- Trend the data in a CMMS or spreadsheet; a rising trend is more significant than any single reading.

## Safety Notes
- Never collect vibration data on a machine that is not running at normal operating load — data at part load is not comparable.
- Be aware of rotating couplings and belts near the measurement point. Do not let the sensor or cable get caught.',
   55, 2,
   '[{"question":"Which bearing defect frequency typically appears first?","options":["BPFI (inner race)","BPFO (outer race)","BSF (ball spin)","FTF (cage)"],"correctIndex":1},{"question":"What is the ISO 10816 warning level for most industrial machines?","options":["2.8 mm/s","4.5 mm/s","7.1 mm/s","11.2 mm/s"],"correctIndex":1},{"question":"What does a 7-8 dB ultrasound rise above baseline indicate?","options":["Normal operation","Early bearing distress","Imminent failure","Lubrication is excessive"],"correctIndex":1},{"question":"What does a bearing defect frequency that doubles over two measurements warrant?","options":["Immediate shutdown","Scheduling a replacement","Re-lubrication only","No action needed"],"correctIndex":1},{"question":"What does a noisy spectrum with no clear peaks (the haystack) indicate?","options":["Normal operation","Early bearing degradation","Advanced bearing degradation — plan replacement immediately","Looseness"],"correctIndex":2},{"question":"Why must the measurement point be marked and consistent?","options":["For appearance","A measurement at a different point is not comparable","To meet ISO standards","For safety"],"correctIndex":1},{"question":"What does a bearing defect frequency with sidebands indicate?","options":["Normal wear","The defect is spreading from a single point to the entire race","Lubrication failure","Misalignment"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons with structured content and expanded quizzes

  -- Lesson: Bearing Types & Selection
  UPDATE lessons SET content =
'## Overview
Rolling-element bearings are the core component of nearly every rotating machine in a plant. Selecting the correct bearing type, clearance class, and lubricant for the application determines whether the machine runs for years or fails in months. This lesson covers the major bearing families, their load and speed characteristics, and the selection criteria that drive the choice.

## Key Concepts
- **Ball bearings** (deep-groove, angular contact) handle combined radial and axial loads at higher speeds. Deep-groove ball bearings are the general-purpose choice for motors and pumps.
- **Roller bearings** (cylindrical, tapered, spherical) carry heavier radial loads but generally lower speeds. Cylindrical rollers handle heavy radial loads with minimal axial capacity. Tapered rollers manage combined loads and are common in gearboxes.
- **Bearing clearance** (C2/C3/C4) is the internal gap between the rolling elements and the raceway. C3 is standard for electric motors to accommodate thermal expansion during operation. A bearing with insufficient clearance will seize as it heats up.
- The **L10 life** is the life that 90% of a population of bearings will reach before fatigue. It is the standard bearing life rating and is used to size bearings for a target service life.
- **Prestressing** (clearance reduction under load) is normal; a bearing that is too loose (excessive clearance) will skid and smear the rollers.

## Step-by-Step: Bearing Selection Procedure
1. Determine the radial and axial load magnitudes and directions from the application (gear mesh forces, belt tension, impeller thrust).
2. Determine the shaft speed (RPM) and the required L10 life (typically 50,000-100,000 hours for industrial equipment).
3. Calculate the equivalent dynamic load (P) using the bearing manufacturer equations, combining radial and axial loads.
4. Calculate the required basic dynamic load rating (C) from C = P × (L10 in millions of revolutions)^(1/3 for ball bearings, or ^(3/10 for roller bearings).
5. Select a bearing from the catalog whose C rating exceeds the calculated value.
6. Verify the clearance class matches the application: C3 for motors, C2 for precision positioning, C4 for high-temperature service.
7. Verify the lubricant is compatible with the bearing speed and operating temperature (refer to the lubrication lesson).

## Common Problems and Fixes
- **Bearing runs hot after replacement:** The most common cause is incorrect clearance class. A C2 bearing in a motor that needs C3 will seize as it heats. Replace with the correct clearance class.
- **Bearing fails prematurely despite correct selection:** Check for misalignment, over-lubrication, or contamination. The bearing may be correctly selected but incorrectly installed or maintained.
- **Skidding damage (smearing on roller surfaces):** The bearing is under-loaded for its capacity, causing the rollers to skid instead of roll. Select a smaller bearing or add a pre-load.

## Best Practices and Field Tips
- Always verify the bearing part number, the clearance class, and the lubricant against the OEM specification before installation.
- A bearing that is correctly selected but incorrectly installed (pressed on the wrong race, hammered on the shaft) will fail regardless of the selection quality.
- Keep bearings in their original packaging until the moment of installation. Exposure to dust and humidity starts the corrosion process.
- When replacing a bearing, document the old bearing part number and the failure mode. This builds a history that reveals recurring selection or application issues.

## Safety Notes
- Never use a torch to heat a bearing for installation without proper training — overheating destroys the metallurgy and the clearance.
- Bearings under load can fail catastrophically; always follow the OEM removal and installation procedures to avoid injury from flying fragments.',
   quiz =
'[{"question":"Which bearing type is the general-purpose choice for electric motors?","options":["Cylindrical roller bearing","Deep-groove ball bearing","Tapered roller bearing","Angular contact ball bearing"],"correctIndex":1},{"question":"Why is C3 clearance specified for electric motor bearings?","options":["To reduce noise","To accommodate thermal expansion during operation","To allow heavier axial loading","To simplify lubrication"],"correctIndex":1},{"question":"What does the L10 life rating represent?","options":["The average life of all bearings","The life that 90% of a population of bearings will reach before fatigue","The maximum life of any bearing","The minimum life guaranteed"],"correctIndex":1},{"question":"What causes skidding damage (smearing) on roller bearings?","options":["Over-lubrication","The bearing is under-loaded for its capacity, causing rollers to skid instead of roll","Excessive speed","Contamination"],"correctIndex":1},{"question":"What should you do if a bearing runs hot immediately after replacement?","options":["Add more grease","Check for incorrect clearance class and replace with the correct class","Increase the cooling","Reduce the load"],"correctIndex":1},{"question":"What is the most common cause of premature bearing failure despite correct selection?","options":["Material defect","Misalignment, over-lubrication, or contamination","Incorrect voltage","Excessive humidity"],"correctIndex":1},{"question":"Why should bearings stay in original packaging until installation?","options":["For inventory tracking","Exposure to dust and humidity starts the corrosion process","To keep them clean for shipping","To maintain warranty"],"correctIndex":1}]'::jsonb
  WHERE title = 'Bearing Types & Selection' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Lesson: Failure Modes & Inspection
  UPDATE lessons SET content =
'## Overview
The majority of bearing failures stem from contamination, improper lubrication, and misalignment — not from material fatigue reaching the end of the L10 life. Recognizing failure signatures on removed bearings tells you what went wrong and how to prevent it on the next installation.

## Key Concepts
- **Flaking/spalling:** Fatigue damage — the contact stress has exceeded the material endurance limit, or the bearing has reached its L10 life. Appears as flakes of metal removed from the raceway.
- **Smearing:** Surface damage from skidding — the rolling elements slide instead of roll. Caused by inadequate load, inadequate lubrication, or excessive speed.
- **False brinelling:** Depressions in the raceway caused by vibration while the shaft is stationary. Common in standby machines or machines transported without rotation.
- **Contamination wear:** Abrasive particles in the lubricant that score the raceway and the rolling elements. The wear pattern follows the particle path through the bearing.
- **Corrosion:** Red-brown or black staining on the raceway from water or corrosive fluid in the lubricant.
- **Electric arc damage:** Pitting (weld marks) on the raceway from current passing through the bearing — common in VFD-driven motors without proper grounding.

## Step-by-Step: Bearing Inspection Procedure
1. Remove the bearing from the machine using a bearing puller or a hydraulic press. Never use a hammer.
2. Clean the bearing with solvent and dry with compressed air.
3. Inspect the raceways visually for flaking, spalling, smearing, false brinelling, corrosion, and electric arc marks.
4. Check the rolling elements for pitting, cracking, and discoloration.
5. Measure the internal clearance with a feeler gauge and compare to the original specification. Excessive clearance indicates wear.
6. Check the cage for wear, cracking, and rivet looseness.
7. If the bearing is being evaluated for reuse (not recommended for critical service), perform a slow-speed rotation test by hand — any roughness, clicking, or catching indicates damage.
8. Document the failure mode with photographs and a written description in the CMMS.

## Common Problems and Fixes
- **Flaking on the outer race only:** The bearing was overloaded in one direction (unbalanced load, misalignment). Correct the load condition before installing the new bearing.
- **False brinelling on a standby pump:** The standby machine vibrates from nearby running equipment. Install vibration isolation or rotate the standby shaft periodically.
- **Corrosion despite grease lubrication:** Water is entering the bearing housing. Check the housing seal and the breather. Consider a sealed bearing or a labyrinth seal.
- **Electric arc damage on VFD-driven motor:** Bearing currents from the VFD PWM output. Install a shaft grounding ring or an insulated bearing on the non-drive end.

## Best Practices and Field Tips
- Always photograph the failure and tag the bearing with the machine number, the date, and the failure mode before sending it for analysis.
- A bearing that fails the same way twice on the same machine has a systemic problem — the bearing is the symptom, not the cause.
- When inspecting a bearing, compare the damaged areas to the load zone — the location of the damage tells you the direction of the excess load.
- Keep a set of reference bearings showing each failure mode for training new technicians.

## Safety Notes
- Used bearings may have sharp edges and metal fragments. Wear cut-resistant gloves during inspection.
- Do not use compressed air to spin a bearing — it can disintegrate and throw fragments at high speed.',
   quiz =
'[{"question":"What is the most common root cause of bearing failures?","options":["Material fatigue","Contamination, improper lubrication, and misalignment","Electric arc damage","Over-speed"],"correctIndex":1},{"question":"What does false brinelling indicate?","options":["Overload during operation","Vibration while the shaft is stationary","Inadequate lubrication at speed","Excessive clearance"],"correctIndex":1},{"question":"What does flaking/spalling on the raceway indicate?","options":["Contamination","Contact stress has exceeded the material endurance limit or L10 life is reached","Misalignment only","Corrosion"],"correctIndex":1},{"question":"What causes electric arc damage on VFD-driven motor bearings?","options":["Over-voltage","Bearing currents from the VFD PWM output without proper grounding","Excessive speed","Incorrect lubricant"],"correctIndex":1},{"question":"What should never be used to remove a bearing?","options":["A bearing puller","A hydraulic press","A hammer","A torch"],"correctIndex":2},{"question":"What does corrosion in a greased bearing indicate?","options":["Wrong grease","Water is entering the bearing housing — check the seal and breather","Excessive temperature","Normal aging"],"correctIndex":1},{"question":"What does a bearing that fails the same way twice on the same machine indicate?","options":["Bad bearing brand","A systemic problem — the bearing is the symptom, not the cause","Normal coincidence","Incorrect installation technique"],"correctIndex":1}]'::jsonb
  WHERE title = 'Failure Modes & Inspection' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Lesson: Lubricant Selection & Application
  UPDATE lessons SET content =
'## Overview
Grease is the most common lubricant for rolling-element bearings in industrial equipment. Selecting the correct grease and applying it at the correct interval is the single most impactful maintenance task for bearing life. A correctly selected and applied bearing can run for its full L10 life; a poorly lubricated one will fail in weeks.

## Key Concepts
- Grease is selected by **base oil viscosity**, **thickener type**, and **NLGI grade** (penetration hardness, 000 to 6).
- **Polyurea** greases are widely used in electric motors for long life and high-temperature stability. **Lithium-complex** greases are common for general industrial use.
- Mixing incompatible thickeners (e.g., polyurea and lithium-complex) causes softening and oil bleed — the grease loses its consistency and runs out of the bearing.
- **Re-lubrication intervals** depend on bearing size, speed, and operating temperature. As a baseline: double the interval for every 15°C drop below 70°C, and halve it for every 15°C rise.
- Over-greasing is as harmful as under-greasing: excess grease builds pressure, blows seals, and the churning heat degrades the lubricant.

## Step-by-Step: Re-Lubrication Procedure
1. Clean the grease fitting and the area around it with a solvent-soaked rag.
2. If using an ultrasound gun, attach the contact probe to the bearing housing and note the dB reading.
3. Pump grease slowly — one shot at a time — while monitoring the ultrasound dB.
4. As lubricant reaches the rolling elements, the dB drops. Stop when the reading stabilizes.
5. If no ultrasound gun is available, pump grease slowly and stop when the bearing housing feels warm to the touch (indicating grease has reached the elements).
6. Run the machine for 10-15 minutes to allow the excess grease to purge.
7. Record the date, the grease type, and the number of pumps in the CMMS.

## Common Problems and Fixes
- **Bearing runs hot after greasing:** Over-greasing. The excess grease is churning and generating heat. Remove the drain plug (if equipped) and let the excess purge, or run the machine until it cools down.
- **Grease leaking from the seal:** The seal was blown by over-greasing. Replace the seal and reduce the grease quantity at the next interval.
- **Bearing fails despite regular greasing:** The grease may be incompatible with the previous charge. Verify the thickener compatibility. If it changed, purge the system with the new grease before resuming the schedule.
- **Bearing noisy despite greasing:** The grease is not reaching the rolling elements. Check for a blocked grease passage or a grease fitting that is plugged.

## Best Practices and Field Tips
- Use an ultrasound gun for acoustic lubrication — it prevents both over and under-greasing by stopping when the dB stabilizes.
- Always use a grease gun with a known output per pump (typically 1-3 grams per stroke) so you can control the quantity.
- Tag each bearing with the grease type and the re-lubrication interval — a bearing greased with the wrong product is worse than one not greased at all.
- For high-speed bearings, consider a centralized automatic lubrication system to deliver small, frequent doses instead of large, infrequent ones.

## Safety Notes
- Never grease a bearing while the machine is running and the coupling is exposed — rotating equipment can catch hands and clothing.
- Use a rag to wipe excess grease — grease on the floor is a slip hazard.',
   quiz =
'[{"question":"What happens when incompatible grease thickeners are mixed?","options":["Nothing — thickeners are interchangeable","The grease may soften and bleed oil","The viscosity permanently increases","The color changes but performance is unaffected"],"correctIndex":1},{"question":"How does operating temperature affect re-lubrication intervals?","options":["Interval doubles for every 15°C rise","Interval halves for every 15°C rise","Temperature has no effect","Interval triples for every 10°C rise"],"correctIndex":1},{"question":"What is the risk of over-greasing a bearing?","options":["No risk — more is better","Builds pressure, blows seals, and churning heat degrades the lubricant","Improves bearing life","Reduces operating temperature"],"correctIndex":1},{"question":"What should you do if a bearing runs hot immediately after greasing?","options":["Add more grease","Remove the drain plug and let excess purge, or run until it cools","Replace the bearing","Reduce the speed"],"correctIndex":1},{"question":"What is the advantage of acoustic lubrication (ultrasound)?","options":["It is faster","It prevents both over and under-greasing by stopping when the dB stabilizes","It is cheaper","It eliminates the need for grease"],"correctIndex":1},{"question":"Why should each bearing be tagged with the grease type?","options":["For inventory tracking","A bearing greased with the wrong product is worse than one not greased at all","For regulatory compliance","For appearance"],"correctIndex":1},{"question":"What does a bearing that is noisy despite greasing indicate?","options":["The bearing is worn out","The grease is not reaching the rolling elements — check for a blocked passage","The grease is the wrong color","The machine is overloaded"],"correctIndex":1}]'::jsonb
  WHERE title = 'Lubricant Selection & Application' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Lesson: Laser Alignment Techniques
  UPDATE lessons SET content =
'## Overview
Shaft misalignment is a leading cause of premature bearing and seal failure. Laser alignment systems measure both angular and parallel misalignment simultaneously at the coupling, enabling precision alignment to tolerances that dial indicators cannot reliably achieve. This lesson covers the alignment procedure, the correction sequence, and the common pitfalls.

## Key Concepts
- **Angular misalignment:** The two shafts meet at an angle — the coupling gap is different on opposite sides.
- **Parallel (offset) misalignment:** The shafts are parallel but not collinear — one is higher or to the side of the other.
- **Soft-foot:** A condition where one or more machine feet do not sit flat on the base. Tightening the bolts distorts the frame and the bearing housings, introducing internal misalignment that no external alignment can correct.
- Target tolerances for most industrial couplings: 0.05 mm offset and 0.05 mm/100 mm angularity.
- Thermal growth (covered in the Advanced Alignment module) must be compensated after the cold alignment is complete.

## Step-by-Step: Laser Alignment Procedure
1. **Check and correct soft-foot first.** Place a dial indicator on each foot, loosen the bolt, and read the lift. Shim any foot that lifts more than 0.05 mm with stainless shims.
2. **Mount the laser units** on each shaft per the manufacturer instructions. The laser heads must face each other and be aligned roughly.
3. **Zero the system** by rotating the shafts to the starting position (usually 12 o''clock) and pressing zero.
4. **Rotate to 3, 6, 9, and 12 o''clock** (or let the system auto-rotate if continuous measurement is available). The system calculates the misalignment from the four positions.
5. **Read the results:** The system displays the vertical and horizontal offset and angularity at the coupling and at the feet.
6. **Correct angular misalignment first** using the vertical feet values. Add or remove shims under the front or back feet to correct the angularity.
7. **Correct parallel (offset) misalignment** by moving the machine horizontally (side to side) and vertically (shimming).
8. **Re-measure** after each correction. Repeat until both angular and parallel misalignment are within tolerance.
9. **Torque the bolts** to the specified torque and re-check. A final check after torquing confirms the alignment holds.

## Common Problems and Fixes
- **Alignment will not come within tolerance:** Check for soft-foot that was not corrected, pipe strain pulling the machine, or a bent base.
- **Alignment changes after torquing the bolts:** The soft-foot was not fully corrected — the frame distorts when the bolts are tightened. Re-check and re-shim.
- **Laser readings are erratic or inconsistent:** The laser heads may be loose on the shaft, or the shaft may have excessive runout. Tighten the mounting and check shaft runout.
- **Results do not match the dial indicator:** The laser may be mis-calibrated or the wrong coupling type was entered. Verify the coupling dimensions in the system.

## Best Practices and Field Tips
- Always correct soft-foot before alignment — this is the most common alignment failure.
- Make small shim changes (0.05-0.1 mm at a time) and re-measure. Large changes overshoot.
- Use pre-cut stainless shims — never use folded sheet metal or makeshift shims.
- Document the final alignment values (before and after) in the machine record for future reference.
- If the machine has a thermal growth offset, enter it into the laser system before the final alignment.

## Safety Notes
- Never rotate the shafts by hand if the coupling guard is removed and the machine is connected to power. Lock out the motor before removing the guard.
- Laser beams can cause eye damage — never look directly into the laser emitter.',
   quiz =
'[{"question":"What should be corrected before final laser alignment?","options":["Coupling grease","Soft-foot","Bearing clearance","Lubricant viscosity"],"correctIndex":1},{"question":"Which misalignment type should typically be corrected first?","options":["Parallel offset","Angular misalignment","Both simultaneously is required","Neither — they self-correct"],"correctIndex":1},{"question":"What are the target alignment tolerances for most industrial couplings?","options":["0.5 mm offset","0.05 mm offset and 0.05 mm/100 mm angularity","0.005 mm offset","1 mm offset"],"correctIndex":1},{"question":"What does it mean if the alignment changes after torquing the bolts?","options":["Normal behavior","Soft-foot was not fully corrected — the frame distorts when bolts are tightened","The laser is faulty","The coupling is worn"],"correctIndex":1},{"question":"What should you do if the laser readings are erratic?","options":["Replace the laser","Check for loose laser heads or excessive shaft runout","Ignore the readings","Re-align by feel"],"correctIndex":1},{"question":"What size shim changes should be made between measurements?","options":["As large as possible to save time","Small: 0.05-0.1 mm at a time","No shims needed","Whatever is available"],"correctIndex":1},{"question":"What safety precaution is needed when the coupling guard is removed?","options":["Wear safety glasses","Lock out the motor before removing the guard","Nothing — just be careful","Remove the coupling"],"correctIndex":1}]'::jsonb
  WHERE title = 'Laser Alignment Techniques' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 2. PUMP & MECHANICAL SEAL MAINTENANCE =====================
-- Currently 2 modules, 3 lessons. Add 2 new modules with 2 lessons each → 4 modules, 7 lessons.

DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Pump & Mechanical Seal Maintenance';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Pump Installation & Commissioning', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Pump Installation, Alignment & Startup',
   '## Overview
A pump that is installed correctly will run for years; one that is installed poorly will fail in weeks. The installation — base preparation, piping, alignment, and startup — determines the foundation of pump reliability. This lesson covers the installation procedure from the base to the first run.

## Key Concepts
- The baseplate must be flat, level, and grouted to prevent vibration and misalignment.
- Piping must be independently supported — the pump casing must not carry pipe weight or thermal expansion forces.
- Suction piping should be short, direct, and one size larger than the suction flange to minimize NPSH loss.
- The pump-to-motor alignment must be checked after piping is connected, as pipe strain can shift the pump.
- A startup procedure that checks rotation, seal flush, and discharge pressure prevents dry-run and cavitation damage on the first start.

## Step-by-Step: Pump Installation and Startup
1. **Prepare the baseplate:** Clean the mounting surface, verify it is flat within 0.1 mm/m and level within 0.5 mm/m. Shim as needed.
2. **Mount the pump and motor:** Place the equipment on the baseplate, install the coupling, and roughly align.
3. **Connect the piping:** Install the suction and discharge piping with independent supports. Do not let the pipe weight rest on the pump casing.
4. **Check for pipe strain:** Mount a dial indicator on the coupling, loosen the pipe flanges, and read the movement. Anything over 0.05 mm requires pipe correction.
5. **Perform the laser alignment:** Correct soft-foot, then align to 0.05 mm offset and 0.05 mm/100 mm angularity.
6. **Grout the baseplate:** Pour the grout under the baseplate to fill voids and lock it in place. Allow the grout to cure before starting.
7. **Startup:** Verify the motor rotation (bump test), open the suction valve fully, open the discharge valve slightly, start the pump, and gradually open the discharge to full flow. Check for cavitation noise, vibration, and seal flush flow.

## Common Problems and Fixes
- **Pump vibrates after piping is connected:** Pipe strain is pulling the pump. Correct the piping and re-check alignment.
- **Pump cavitates on startup:** The suction valve may not be fully open, or the suction strainer is blocked. Open the valve fully and clean the strainer.
- **Seal leaks immediately:** The seal was damaged during installation (dirty faces, misaligned seat) or the pump was run dry before the seal flush was established.
- **Pump overheats with discharge valve closed:** Never run a pump against a closed discharge — the fluid recirculates and heats rapidly. Install a minimum flow bypass.

## Best Practices and Field Tips
- Always verify the suction strainer is clean before startup — construction debris in new piping will clog the strainer and cause cavitation.
- Check the pump direction of rotation before coupling the motor — a pump running backward will not build pressure and may damage the seal.
- Record the baseline vibration, amperage, and discharge pressure at startup for future comparison. A change from baseline is the first sign of a problem.

## Safety Notes
- Never start a pump without verifying the suction valve is open and the discharge valve is cracked — a dry start destroys the seal.
- Hot pumps under pressure can scald — stand clear of the discharge when opening valves.',
   55, 1,
   '[{"question":"What must the baseplate be within for flatness?","options":["0.01 mm/m","0.1 mm/m","1 mm/m","5 mm/m"],"correctIndex":1},{"question":"Why must piping be independently supported?","options":["To save cost","The pump casing must not carry pipe weight or thermal expansion forces","For appearance","It is easier to install"],"correctIndex":1},{"question":"What should suction piping be relative to the suction flange?","options":["Same size","One size larger to minimize NPSH loss","Smaller to save cost","Any size"],"correctIndex":1},{"question":"What indicates pipe strain after piping is connected?","options":["Nothing","Pump vibrates and the coupling shifts when flanges are loosened","The pump runs quietly","The motor amperage is low"],"correctIndex":1},{"question":"What should be done before starting a new pump for the first time?","options":["Nothing — just turn it on","Verify rotation, open suction fully, crack discharge, start, then open discharge gradually","Close all valves and start","Remove the coupling"],"correctIndex":1},{"question":"What should never be done with the discharge valve?","options":["Open it fully","Never run a pump against a closed discharge — fluid recirculates and heats rapidly","Never open it at all","Close it after starting"],"correctIndex":1},{"question":"What should be recorded at pump startup for future comparison?","options":["Only the flow rate","Baseline vibration, amperage, and discharge pressure","Only the motor temperature","Only the seal flush flow"],"correctIndex":1}]'::jsonb),
  (m_id, 'NPSH, Cavitation & System Troubleshooting',
   '## Overview
Net Positive Suction Head (NPSH) is the single most important concept in pump reliability. A pump that does not have adequate NPSH will cavitate, damaging the impeller, the seal, and the bearings. Understanding NPSH and how to diagnose cavitation-related problems is essential for any maintenance technician.

## Key Concepts
- **NPSH_available** is the head at the pump suction, determined by the system: atmospheric pressure minus suction lift (or plus suction head), minus vapor pressure, minus friction losses.
- **NPSH_required** is the head the pump needs to avoid cavitation, determined by the pump design. It is shown on the pump curve and increases with flow.
- For reliable operation, NPSH_available must exceed NPSH_required by at least 0.5-1 m (the NPSH margin).
- Cavitation occurs when the local pressure drops below the vapor pressure of the liquid, forming bubbles that collapse violently against the impeller vanes.
- Suction cavitation (from low NPSH) damages the inlet side of the impeller; discharge cavitation (from running against a closed discharge) damages the outlet.

## Step-by-Step: Diagnosing Cavitation
1. **Listen:** Cavitation sounds like gravel passing through the pump — a crackling, rattling noise that increases with flow.
2. **Check the suction valve:** Ensure it is fully open. A partially closed suction valve reduces NPSH.
3. **Check the suction strainer:** A clogged strainer increases friction loss and reduces NPSH. Clean it.
4. **Check the suction line for air leaks:** An air leak in the suction line reduces the vacuum and causes cavitation. Tighten fittings and check for leaks.
5. **Check the fluid temperature:** Higher temperature means higher vapor pressure, which reduces NPSH_available. Verify the operating temperature against the design.
6. **Check the suction lift:** If the liquid level has dropped, the suction lift has increased, reducing NPSH. Verify the sump level.
7. **If the problem persists:** Consult the pump curve and verify the NPSH_required at the operating flow. If the margin is insufficient, consider reducing the flow (trimming the impeller) or increasing the suction head (lowering the pump, increasing the suction line size).

## Common Problems and Fixes
- **Pump is noisy and the discharge pressure fluctuates:** Classic cavitation. Check NPSH: suction valve, strainer, suction lift, fluid temperature.
- **Impeller shows pitting on the inlet side:** Suction cavitation from inadequate NPSH. Increase the NPSH margin.
- **Impeller shows pitting on the outlet side:** Discharge cavitation from running against a restricted discharge. Verify the discharge valve is open and the discharge line is not blocked.
- **Pump cavitates only at high flow:** The NPSH_required increases with flow. The pump may be operating beyond its design flow. Trim the impeller or reduce the speed.

## Best Practices and Field Tips
- Always calculate the NPSH margin during pump selection — a margin of 0.5-1 m is minimum; 2+ m is preferred for variable-flow applications.
- Trend the discharge pressure and the motor amperage — a gradual decrease in pressure with a rise in amperage indicates wear; a sudden decrease with noise indicates cavitation.
- Install a vacuum gauge on the suction line — a reading that trends higher (more vacuum) indicates a developing suction restriction.
- For high-temperature applications, consider a booster pump to increase the NPSH.

## Safety Notes
- Never open a pump casing that is under pressure or hot. Isolate, depressurize, and cool before opening.
- Cavitation can cause the impeller to disintegrate — always isolate the pump before inspection.',
   55, 2,
   '[{"question":"What is NPSH_available?","options":["The head the pump needs","The head at the pump suction determined by the system","The pump discharge pressure","The impeller diameter"],"correctIndex":1},{"question":"What is the minimum NPSH margin for reliable operation?","options":["0.1 m","0.5-1 m","5 m","10 m"],"correctIndex":1},{"question":"What sound is characteristic of pump cavitation?","options":["A high-pitched whine","Gravel passing through the pump","A steady humming","Metal-on-metal grinding"],"correctIndex":1},{"question":"Where does suction cavitation damage the impeller?","options":["The outlet side","The inlet side","The shaft","The casing wall"],"correctIndex":1},{"question":"What causes discharge cavitation?","options":["Low NPSH","Running against a closed or restricted discharge","High fluid temperature","Air in the suction line"],"correctIndex":1},{"question":"What should you check first if a pump is noisy with fluctuating discharge pressure?","options":["The motor","The NPSH: suction valve, strainer, suction lift, fluid temperature","The coupling","The bearings"],"correctIndex":1},{"question":"What does impeller pitting on the inlet side indicate?","options":["Discharge cavitation","Suction cavitation from inadequate NPSH","Corrosion","Erosion from solids"],"correctIndex":1}]'::jsonb);

  -- New module 4
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Seal Applications', 4) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Dry Gas Seals & Barrier Fluid Systems',
   '## Overview
Dry gas seals and dual-seal barrier fluid systems are used in hazardous, toxic, or high-temperature services where a single seal failure would release dangerous fluid to atmosphere. Understanding these advanced seal configurations is essential for technicians working in refineries, chemical plants, and high-pressure applications.

## Key Concepts
- **Dry gas seals** use a non-contacting gas film (typically nitrogen or clean air) to seal the pump. They are used in light hydrocarbon services where a liquid barrier would contaminate the product.
- **Plan 52 (unpressurized dual seal):** A barrier fluid at lower pressure than the seal chamber. If the primary seal fails, the barrier fluid leaks into the process, not the process fluid to atmosphere.
- **Plan 53 (pressurized dual seal):** The barrier fluid is at higher pressure than the seal chamber. Any leakage is barrier fluid into the process, not process fluid out. Used for toxic services.
- **Barrier fluid selection:** The fluid must be compatible with the process (if it leaks in), stable at the operating temperature, and have adequate lubricity for the seal faces.
- The barrier fluid reservoir level and pressure are the primary indicators of seal health.

## Step-by-Step: Monitoring a Dual Seal System
1. **Check the barrier fluid reservoir level daily.** A falling level indicates the primary seal is leaking barrier fluid into the process. A rising level indicates the process is leaking into the barrier fluid (the primary seal has failed).
2. **Check the barrier fluid pressure.** For a Plan 53, it must be above the seal chamber pressure by the specified margin (typically 0.2-0.5 bar). If the pressure differential is lost, the seal is compromised.
3. **Check the barrier fluid temperature.** A rising temperature indicates the seal faces are running hot — the barrier fluid flow may be insufficient or the seal is degrading.
4. **Sample the barrier fluid quarterly.** Check for process contamination (the sample will show process fluid if the primary seal has failed), viscosity change, and degradation.
5. **Trend the reservoir pressure and level.** A gradual change indicates a slow leak; a sudden change indicates a seal failure.

## Common Problems and Fixes
- **Barrier fluid level dropping:** The primary seal is leaking barrier fluid into the process. Schedule a seal replacement.
- **Barrier fluid level rising:** The process is leaking into the barrier fluid — the primary seal has failed. Isolate the pump and replace the seal.
- **Barrier fluid pressure cannot be maintained:** The barrier fluid reservoir has a leak, or the pressure system (pump or nitrogen blanket) has failed. Check the reservoir and the pressure source.
- **Barrier fluid is discolored or contains particles:** The seal faces are degrading and generating wear particles. Sample the fluid and schedule a seal inspection.

## Best Practices and Field Tips
- Install a level switch and a pressure switch on the barrier fluid reservoir to alarm in the control room — a seal failure detected early prevents a process release.
- Trend the barrier fluid consumption rate (mL per day). A rising rate indicates progressive seal wear.
- For Plan 53 systems, verify the barrier fluid pressure is above the seal chamber pressure at all times — a pressure reversal defeats the dual seal.
- Document the barrier fluid type, the reservoir capacity, and the normal consumption rate for each pump.

## Safety Notes
- Barrier fluid in Plan 52/53 systems may be hazardous if it contacts the process. Verify chemical compatibility before filling.
- A dual seal failure on a toxic service is a process safety incident — follow the plant emergency response procedure.',
   55, 1,
   '[{"question":"What is the difference between Plan 52 and Plan 53 dual seals?","options":["Plan 52 is pressurized; Plan 53 is not","Plan 52 barrier fluid is lower pressure than the seal chamber; Plan 53 is higher pressure","They are the same","Plan 52 uses gas; Plan 53 uses liquid"],"correctIndex":1},{"question":"What does a falling barrier fluid reservoir level indicate?","options":["The reservoir is leaking","The primary seal is leaking barrier fluid into the process","Normal operation","The barrier fluid pump has failed"],"correctIndex":1},{"question":"What does a rising barrier fluid level indicate?","options":["The process is leaking into the barrier fluid — the primary seal has failed","Normal operation","The reservoir is overfilled","The barrier fluid is expanding"],"correctIndex":0},{"question":"What pressure must a Plan 53 barrier fluid maintain?","options":["Equal to the seal chamber pressure","Above the seal chamber pressure by the specified margin","Below the seal chamber pressure","Atmospheric pressure"],"correctIndex":1},{"question":"What should be done if the barrier fluid is discolored or contains particles?","options":["Change the fluid and continue running","Sample the fluid and schedule a seal inspection","Nothing — it is normal","Replace the reservoir"],"correctIndex":1},{"question":"What should be installed on the barrier fluid reservoir for early detection?","options":["A sight glass only","A level switch and a pressure switch to alarm in the control room","A temperature gauge only","Nothing — daily inspection is sufficient"],"correctIndex":1},{"question":"What is a pressure reversal in a Plan 53 system?","options":["Normal operation","The barrier fluid pressure drops below the seal chamber pressure, defeating the dual seal","The barrier fluid is too hot","The barrier fluid is the wrong type"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons
  UPDATE lessons SET content =
'## Overview
A pump curve plots head (vertical axis) against flow (horizontal axis) for a given impeller diameter and speed. The system curve represents the resistance of the piping — static head plus friction losses. Where the two curves intersect is the operating point. Understanding the pump curve is essential for diagnosing whether a pump problem is in the pump or the system.

## Key Concepts
- The **best efficiency point (BEP)** is the flow at which the pump operates at maximum efficiency. Running near BEP minimizes radial loads, seal stress, and cavitation risk.
- Running far to the right of BEP (high flow) causes high radial loads and potential cavitation. Running far left (low flow) risks recirculation cavitation and high temperature.
- The goal of maintenance is to keep the operating point within 70-120% of BEP.
- The **affinity laws** describe how flow, head, and power change with speed and impeller diameter: Flow ∝ speed × D², Head ∝ speed² × D², Power ∝ speed³ × D³ (where D is impeller diameter).
- The system curve shifts with valve position, pipe condition, and tank level — a change in the system curve moves the operating point.

## Step-by-Step: Verifying Pump Performance Against the Curve
1. Obtain the pump curve from the OEM manual or the pump nameplate.
2. Measure the actual flow with a flow meter, or estimate from the motor amperage (amperage is proportional to flow for a centrifugal pump).
3. Measure the discharge pressure and the suction pressure. Calculate the total head: (discharge pressure - suction pressure) / (specific gravity × 9.81).
4. Plot the measured point (flow, head) on the pump curve. If the point is on the curve, the pump is healthy. If below the curve, the pump is worn (impeller clearance, wear rings).
5. Compare the motor amperage to the nameplate FLA. Amperage above FLA at the measured flow indicates the pump is overloaded or the wear ring clearance is excessive.
6. If the operating point is far from BEP, investigate the system: is a valve throttled, is the discharge line restricted, is the tank level different from design?

## Common Problems and Fixes
- **Pump performance is below the curve:** The impeller or wear rings are worn. Check the internal clearances and replace the wear rings.
- **Pump is on the curve but the flow is low:** The system curve has shifted — a valve is closed, a filter is clogged, or the discharge line is restricted. Check the system.
- **Pump is on the curve but the motor is overloaded:** The operating point is too far right (high flow). Throttle the discharge to move the operating point toward BEP.
- **Pump performance drops over time:** Fouling of the impeller or the casing. Open the pump and inspect for scale, erosion, and corrosion.

## Best Practices and Field Tips
- Always keep a copy of the pump curve in the maintenance file — without it, you cannot diagnose pump problems.
- Trend the flow, head, and amperage monthly. A gradual decline indicates wear; a sudden change indicates a system change or a failure.
- Trim the impeller (machine to a smaller diameter) if the pump consistently operates too far right of BEP — this moves the curve down and left.
- Verify the pump speed matches the curve speed — a pump running at a different speed (e.g., a VFD at 50 Hz instead of 60 Hz) has a different curve.

## Safety Notes
- Never measure flow by opening the pump casing — use external instruments (flow meter, pressure gauge, clamp meter).
- Hot or hazardous process fluid can cause burns or exposure — use appropriate PPE when working near the pump.',
   quiz =
'[{"question":"Where is a centrifugal pump most efficient?","options":["At shutoff head","At best efficiency point (BEP)","At maximum flow","At minimum flow"],"correctIndex":1},{"question":"What risk increases when a pump runs far left of BEP?","options":["Seal flush failure","Recirculation cavitation","Motor overload","Impeller erosion from high flow"],"correctIndex":1},{"question":"What is the recommended operating range relative to BEP?","options":["50-80% of BEP","70-120% of BEP","90-110% of BEP","Any range is acceptable"],"correctIndex":1},{"question":"If the measured performance point is below the pump curve, what is the problem?","options":["The system has shifted","The impeller or wear rings are worn — check internal clearances","The motor is undersized","The fluid is too hot"],"correctIndex":1},{"question":"If the pump is on the curve but the flow is low, where is the problem?","options":["The pump is worn","The system curve has shifted — a valve is closed, a filter is clogged, or the discharge line is restricted","The impeller is too small","The speed is wrong"],"correctIndex":1},{"question":"What does the affinity law say about flow and impeller diameter?","options":["Flow is proportional to D","Flow is proportional to D²","Flow is proportional to D³","Flow is independent of D"],"correctIndex":1},{"question":"What should be done if the pump consistently operates too far right of BEP?","options":["Replace the pump","Trim the impeller to a smaller diameter to move the curve down and left","Increase the motor size","Reduce the pipe size"],"correctIndex":1}]'::jsonb
  WHERE title = 'Pump Curves & Operating Point' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Cavitation occurs when the local pressure in the pump drops below the vapor pressure of the liquid, forming vapor bubbles that collapse violently against the impeller vanes. The collapse generates micro-jets that strike the impeller surface at high velocity, eroding the metal. Recognizing and correcting cavitation is one of the most important skills for a pump maintenance technician.

## Key Concepts
- **Suction cavitation:** The pump does not have enough NPSH. The pressure at the impeller inlet drops below the vapor pressure. Damages the inlet side of the impeller.
- **Discharge cavitation:** The pump is running against a restricted discharge. The fluid recirculates inside the pump at high velocity. Damages the outlet side of the impeller.
- The sound of cavitation is distinctive: like gravel passing through the pump, a crackling or rattling noise that varies with flow.
- Cavitation does not always destroy the impeller immediately — it can run for months with mild cavitation, gradually eroding the impeller and reducing performance.
- Air ingestion (air entering the suction) produces similar symptoms but is a different problem — verify whether the noise is cavitation or air.

## Step-by-Step: Cavitation Diagnosis and Correction
1. **Confirm the noise is cavitation, not air ingestion or bearing noise.** Cavitation noise varies with flow; bearing noise is constant; air ingestion produces a crackling that may not vary with flow.
2. **Check the suction valve** — ensure it is fully open.
3. **Check the suction strainer** — clean if clogged.
4. **Check the suction line for air leaks** — tighten fittings, check the gasket.
5. **Check the fluid temperature** — higher temperature means higher vapor pressure, reducing NPSH_available.
6. **Check the suction lift** — if the sump level has dropped, the lift has increased.
7. **If the problem is discharge cavitation:** Check the discharge valve, the discharge filter, and the discharge line for restrictions.
8. **If the problem persists after all checks:** Consult the pump curve and verify the NPSH margin. If insufficient, trim the impeller, reduce the speed, or increase the suction head.

## Common Problems and Fixes
- **Pump sounds like gravel, discharge pressure fluctuates:** Suction cavitation. Check NPSH: suction valve, strainer, suction lift, fluid temperature, air leaks.
- **Impeller pitting on the inlet side:** Suction cavitation confirmed. Increase the NPSH margin (lower the pump, increase the suction line size, reduce the fluid temperature).
- **Impeller pitting on the outlet side:** Discharge cavitation. Open the discharge valve, clear the discharge line, install a minimum flow bypass.
- **Pump is noisy but the impeller is not pitted:** The noise may be air ingestion, not cavitation. Check the suction line for air leaks and the sump for vortexing.

## Best Practices and Field Tips
- Install a vacuum gauge on the suction line — a rising vacuum indicates a developing suction restriction before cavitation starts.
- For variable-flow applications, install a VFD and control the speed to maintain the NPSH margin across the flow range.
- A pump that cavitates only at high flow may be operating beyond its design — trim the impeller to reduce the NPSH_required.
- Trend the discharge pressure and the motor amperage — cavitation causes the pressure to drop and the amperage to fluctuate.

## Safety Notes
- Never operate a cavitating pump for extended periods — the impeller can disintegrate and the casing can rupture.
- Isolate the pump before opening the casing for impeller inspection — trapped pressure can cause burns.',
   quiz =
'[{"question":"What causes cavitation in a centrifugal pump?","options":["Air in the suction line","Local pressure drops below the vapor pressure of the liquid, forming bubbles that collapse against the impeller","Excessive speed","Over-lubrication"],"correctIndex":1},{"question":"What does suction cavitation damage?","options":["The outlet side of the impeller","The inlet side of the impeller","The shaft","The casing wall"],"correctIndex":1},{"question":"What does discharge cavitation damage?","options":["The inlet side of the impeller","The outlet side of the impeller","The seal","The coupling"],"correctIndex":1},{"question":"What is the first step in diagnosing cavitation?","options":["Replace the impeller","Confirm the noise is cavitation, not air ingestion or bearing noise","Rebuild the pump","Increase the speed"],"correctIndex":1},{"question":"What should you check if the pump is noisy but the impeller shows no pitting?","options":["The pump is fine","The noise may be air ingestion — check the suction line for air leaks and the sump for vortexing","The bearing is failing","The coupling is worn"],"correctIndex":1},{"question":"What does a pump that cavitates only at high flow indicate?","options":["Normal operation","The pump is operating beyond its design flow — trim the impeller or reduce the speed","The seal is failing","The motor is undersized"],"correctIndex":1},{"question":"What should be installed on the suction line to detect a developing suction restriction?","options":["A pressure gauge","A vacuum gauge","A flow meter","A thermometer"],"correctIndex":1}]'::jsonb
  WHERE title = 'Cavitation Diagnosis' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Mechanical seals fail most often from heat checking, dry running, and chemical incompatibility — not from wear-out. The seal faces are lapped to within 2-3 helium light bands of flatness; any handling damage, contamination, or misalignment destroys the seal. Understanding the failure modes and the correct installation procedure is essential for reliable pump operation.

## Key Concepts
- **Heat checking:** Radial cracks on the seal faces from thermal shock — the seal ran dry or the flush failed and the faces overheated, then quenched by sudden fluid contact.
- **Dry running:** The seal faces operated without liquid lubrication. The faces weld and tear — the surfaces are scored and discolored.
- **Chemical incompatibility:** The O-rings or the seal faces are attacked by the process fluid. O-rings swell, harden, or dissolve; faces etch or stain.
- **Face flatness:** The faces are lapped to within 0.0006 mm. A fingerprint, a paper towel wipe, or a dropped face can scratch it beyond use.
- **Seal chamber bore and shaft sleeve dimensions** must match the seal drawing — an out-of-spec bore or sleeve causes the seal to bind.

## Step-by-Step: Mechanical Seal Installation
1. **Clean everything.** The seal, the shaft sleeve, the seal chamber bore, and the gland plate must be spotless. Use lint-free wipes and a compatible solvent.
2. **Measure the seal chamber bore and the shaft sleeve.** Verify the dimensions match the seal drawing. An out-of-spec bore or sleeve causes the seal to bind.
3. **Install the stationary face** into the gland bore. Verify it seats flat — a cocked stationary face leaks immediately.
4. **Install the rotary face** on the shaft sleeve. Lubricate the O-rings with a compatible assembly lube or the process fluid — never use grease that hardens.
5. **Set the seal to the correct length** per the seal drawing. Measure the seal chamber depth and the seal length to confirm the spring compression is correct.
6. **Hand-rotate the shaft** to confirm the seal is not binding. A binding seal will fail on the first start.
7. **Open the flush** (if applicable) before starting the pump. The flush must be established before the pump runs to prevent dry running.
8. **Start the pump** and check for leakage. A small weepage that clears in minutes is normal; a steady leak indicates a problem.

## Common Problems and Fixes
- **Seal leaks immediately after installation:** The faces were damaged during installation (dirty faces, misaligned seat) or the seal length was set incorrectly.
- **Seal fails within days:** Heat checking from dry running or flush failure. Verify the flush flow and the seal chamber pressure.
- **Seal O-rings are swollen or hardened:** Chemical incompatibility. Verify the O-ring material is compatible with the process fluid and replace with the correct material.
- **Seal faces are scored with abrasive tracks:** Solids in the process fluid. Install a cyclone separator (API Plan 31) or a flush from a clean source.

## Best Practices and Field Tips
- Never touch the seal faces with bare fingers or wipe with a paper towel — use lint-free wipes and a compatible solvent.
- Always measure the seal chamber depth and the seal length before installation — a seal that is compressed too much or too little will fail.
- Document the seal part number, the flush plan, the barrier fluid (if applicable), and the failure mode of the previous seal for each pump.
- For critical pumps, keep a spare seal in stock — the lead time for a new seal can be weeks.

## Safety Notes
- Never use compressed air to clean a seal — the air pressure can blow the seal faces apart.
- Seal springs are under compression — use eye protection when disassembling a seal, as the spring can release suddenly.',
   quiz =
'[{"question":"What is the most common root cause of mechanical seal failure?","options":["Wear-out from normal service life","Heat checking and dry running","Impeller imbalance","Cavitation at the volute"],"correctIndex":1},{"question":"What should be done immediately after installing a mechanical seal?","options":["Start the pump at full speed","Hand-rotate the shaft to check for binding","Tighten the gland bolts to full torque","Pressurize the seal chamber"],"correctIndex":1},{"question":"What should never be used to lubricate seal faces during installation?","options":["The process fluid","A compatible assembly lube","Grease that hardens","Water"],"correctIndex":2},{"question":"What does heat checking on seal faces indicate?","options":["Over-pressure","The seal ran dry or the flush failed and the faces overheated, then quenched","Chemical incompatibility","Incorrect seal length"],"correctIndex":1},{"question":"What do swollen or hardened O-rings indicate?","options":["Normal aging","Chemical incompatibility — verify the O-ring material and replace with the correct material","Over-temperature","Under-pressure"],"correctIndex":1},{"question":"What should never touch seal faces during installation?","options":["Lint-free wipes","Bare fingers or paper towels","A solvent-soaked rag","Clean gloves"],"correctIndex":1},{"question":"What do scored seal faces with abrasive tracks indicate?","options":["Dry running","Solids in the process fluid — install a cyclone separator or a clean flush","Chemical incompatibility","Over-pressure"],"correctIndex":1}]'::jsonb
  WHERE title = 'Seal Installation & Failure Analysis' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 3. CONVEYOR & DRIVE SYSTEMS =====================
-- Currently 2 modules, 3 lessons. Add 2 new modules with 2 lessons each → 4 modules, 7 lessons.

DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Conveyor & Drive Systems';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Belt Conveyor System Design', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Belt Selection, Splice Types & Capacity',
   '## Overview
Selecting the correct conveyor belt, splice type, and capacity for the application determines whether the conveyor runs reliably or constantly breaks down. This lesson covers the belt selection criteria, splice methods, and capacity calculations that every maintenance technician should understand.

## Key Concepts
- **Belt construction:** Ply rating (number of fabric layers), top cover thickness, bottom cover thickness, and belt width determine the belt capacity and durability.
- **Belt tension rating** is the maximum tension the belt can handle, expressed in PIW (pounds per inch of width) or N/mm. The operating tension should not exceed 10-15% of the rating.
- **Splice types:** Mechanical splices (hinged, bolted) are fast to install and suitable for field repair. Vulcanized splices (hot or cold) are stronger and longer-lasting but require specialized equipment and cure time.
- **Capacity** is determined by belt speed, belt width, load cross-section, and material density. An overloaded belt stretches, slips, and fails prematurely.
- **Trough angle** (20°, 35°, 45°) affects the load cross-section and the belt capacity. A steeper trough angle increases capacity but requires a more flexible belt.

## Step-by-Step: Belt Selection and Replacement
1. **Identify the existing belt:** Record the belt width, ply rating, top cover thickness, and belt type (e.g., Grade 2 oil-resistant, fire-resistant).
2. **Calculate the required belt tension:** Tension = (effective tension) × (drive factor). The drive factor depends on the wrap angle and the lagging type.
3. **Select a belt with a tension rating** at least 10x the calculated operating tension to provide a safety margin.
4. **Select the splice type:** For permanent installations, use vulcanized splices. For emergency repairs or where vulcanizing equipment is not available, use mechanical splices.
5. **Calculate the capacity:** Capacity (tph) = belt speed (m/s) × load cross-section (m²) × material density (t/m³). Verify the conveyor is not overloaded.
6. **Order the belt** with the correct width, length, and specifications. Add 2-3% for the splice overlap.

## Common Problems and Fixes
- **Belt stretches excessively:** The belt is under-tensioned or the ply rating is too low. Increase the take-up tension or upgrade to a higher-ply belt.
- **Belt slips on the drive pulley:** Insufficient tension or worn lagging. Increase the tension or re-lag the pulley.
- **Mechanical splice fails repeatedly:** The splice is not rated for the belt tension, or the splice pins are corroded. Upgrade to a vulcanized splice.
- **Belt edge wear:** The belt is mistracking and rubbing the frame. Correct the tracking before replacing the belt.

## Best Practices and Field Tips
- Always record the belt specifications (width, ply, cover, type) on the conveyor tag for quick reference when ordering replacements.
- For critical conveyors, keep a pre-cut spare belt in stock to minimize downtime.
- When replacing a belt, inspect the pulley lagging and the idlers — a new belt on worn components will fail prematurely.
- Vulcanized splices should be inspected quarterly for separation, cracking, and edge lifting.

## Safety Notes
- Never work on a conveyor belt while it is running — lock out the drive before any belt work.
- Stored energy in a tensioned belt can cause it to snap back when cut. Release the take-up tension before cutting.',
   55, 1,
   '[{"question":"What determines conveyor belt capacity?","options":["Belt width only","Belt speed, belt width, load cross-section, and material density","Ply rating only","Belt length"],"correctIndex":1},{"question":"What is the recommended operating tension as a percentage of the belt tension rating?","options":["50-60%","10-15%","30-40%","80-90%"],"correctIndex":1},{"question":"Which splice type is stronger and longer-lasting?","options":["Mechanical splice","Vulcanized splice","Hinged splice","Bolted splice"],"correctIndex":1},{"question":"What causes a belt to slip on the drive pulley?","options":["Over-tensioning","Insufficient tension or worn lagging","Belt too wide","Pulley too large"],"correctIndex":1},{"question":"What should be done before cutting a tensioned belt?","options":["Nothing special","Release the take-up tension — stored energy can cause the belt to snap back","Cut it quickly","Heat the belt"],"correctIndex":1},{"question":"Why should a new belt installation include inspecting pulleys and idlers?","options":["To save time","A new belt on worn components will fail prematurely","For appearance","It is required by code"],"correctIndex":1},{"question":"What should be recorded on the conveyor tag for quick reference?","options":["Only the belt length","Belt specifications: width, ply, cover, type","Only the belt speed","Only the motor size"],"correctIndex":1}]'::jsonb),
  (m_id, 'Conveyor Safety Systems & Controls',
   '## Overview
Conveyor safety systems protect operators from the inherent hazards of moving belts — pinch points at pulleys, entanglement at idlers, and falling material. Understanding the safety devices and their maintenance is essential for any technician responsible for conveyor reliability.

## Key Concepts
- **Emergency pull-cords (e-stops)** run along the entire length of the conveyor. Pulling the cord stops the drive immediately. The pull-cord must be tested regularly — a stuck or broken cord leaves the operator without a stop.
- **Belt sway switches** detect excessive belt mistracking and shut down the conveyor before the belt damages itself on the frame. Mounted at the edges of the belt.
- **Belt rip switches** detect a torn belt and shut down before the tear propagates. Mounted under the belt after the loading point.
- **Slip switches** detect belt slip on the drive pulley (the pulley turns but the belt does not). Prevents the drive from overheating and starting a fire.
- **Speed switches** verify the belt is moving when the drive is running — a belt that is not moving when the drive is running indicates a slip or a break.

## Step-by-Step: Safety Device Testing
1. **Test the pull-cord** at each station: pull the cord and verify the conveyor stops. Reset the cord and verify the conveyor can restart. Document each station.
2. **Test the belt sway switch:** Manually deflect the switch arm and verify the conveyor stops. Adjust the trip point to the correct belt edge clearance (typically 25-50 mm).
3. **Test the belt rip switch:** Insert a test tool into the switch path and verify the conveyor stops. Verify the switch is positioned at the correct location (after the loading point where a rip is most likely).
4. **Test the slip switch:** Verify the switch detects slip — some switches require a belt speed input from a speed sensor. Verify the speed sensor is reading correctly.
5. **Test the speed switch:** Verify the conveyor control system detects a zero-speed condition when the drive is stopped and a running speed when the drive is on.
6. **Document all tests** with the date, the device, the test result, and any adjustments.

## Common Problems and Fixes
- **Pull-cord does not stop the conveyor:** The cord is stuck, the switch is failed, or the wiring is broken. Inspect the cord path, test the switch, and check the wiring.
- **Belt sway switch trips frequently:** The belt is mistracking. Correct the tracking (adjust the tail pulley or training idlers) before resetting the switch.
- **Belt rip switch does not detect a rip:** The switch is mis-positioned or the sensitivity is too low. Reposition the switch and adjust the sensitivity.
- **Slip switch trips intermittently:** The belt is slipping under heavy load. Increase the take-up tension or re-lag the drive pulley.

## Best Practices and Field Tips
- Test all safety devices monthly and document the results — a safety device that does not work is worse than no device because it gives false confidence.
- Install a conveyor monitoring system that trends the safety device activations — a device that trips frequently indicates a conveyor problem, not a device problem.
- Train all operators on the location and function of each safety device — a pull-cord that no one knows about is useless.
- Inspect the pull-cord cable for fraying and stretching — a stretched cable may not activate the switch when pulled.

## Safety Notes
- Never bypass a safety device to keep the conveyor running — a bypassed safety device is a willful safety violation.
- Test the conveyor with the guards in place — removing a guard to test a safety device creates a new hazard.',
   50, 2,
   '[{"question":"What does a belt sway switch detect?","options":["Belt slip","Excessive belt mistracking — shuts down before the belt damages itself on the frame","Belt rip","Belt speed"],"correctIndex":1},{"question":"Where should a belt rip switch be positioned?","options":["At the tail pulley","After the loading point where a rip is most likely","At the drive pulley","At the take-up"],"correctIndex":1},{"question":"What does a slip switch detect?","options":["Belt mistracking","Belt slip on the drive pulley (the pulley turns but the belt does not)","Belt rip","Belt edge wear"],"correctIndex":1},{"question":"What should be done if a belt sway switch trips frequently?","options":["Disable the switch","Correct the belt tracking (adjust the tail pulley or training idlers) before resetting","Increase the switch sensitivity","Replace the switch"],"correctIndex":1},{"question":"How often should conveyor safety devices be tested?","options":["Annually","Monthly","Weekly","Only after a failure"],"correctIndex":1},{"question":"What should never be done to keep a conveyor running?","options":["Increase the speed","Bypass a safety device — it is a willful safety violation","Reduce the load","Adjust the take-up"],"correctIndex":1},{"question":"What should be inspected on a pull-cord cable?","options":["The color","Fraying and stretching — a stretched cable may not activate the switch","The length","The material"],"correctIndex":1}]'::jsonb);

  -- New module 4
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Drive System Optimization', 4) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Gear Drive Selection & Efficiency',
   '## Overview
The gear drive is the heart of a conveyor power transmission system. Selecting the correct gearbox, maintaining it properly, and optimizing the drive efficiency determines the conveyor reliability and the energy cost. This lesson covers gear drive selection, efficiency, and maintenance from a practical standpoint.

## Key Concepts
- **Gearbox service factor** is the ratio of the gearbox rated power to the motor power. A service factor of 1.0 means the gearbox is sized exactly to the motor; 1.5 provides 50% margin; 2.0+ for shock loads.
- **Gearbox efficiency** ranges from 95-98% for a single-reduction helical gearbox to 50-90% for a worm gear. The efficiency loss is heat — a worm gearbox at 50% efficiency converts half the input power to heat.
- **Thermal capacity** is the maximum power the gearbox can handle without overheating. A gearbox that is within its mechanical rating but above its thermal rating will overheat and fail.
- **Backdrive prevention:** On an inclined conveyor, the load can back-drive the gearbox when the motor stops. A backstop (one-way clutch) prevents reverse rotation.
- **Shaft-mounted vs foot-mounted drives:** Shaft-mounted (quill) drives save space but transmit vibration directly to the gearbox. Foot-mounted drives with a coupling isolate the gearbox from motor vibration.

## Step-by-Step: Gear Drive Selection and Optimization
1. **Determine the conveyor power requirement:** Power (kW) = (belt tension × belt speed) / (1000 × efficiency). Use the chain pull method for chain conveyors.
2. **Select the gearbox ratio:** Ratio = output speed / input speed. Verify the output speed matches the conveyor requirement.
3. **Select the service factor:** 1.0-1.5 for uniform loads, 1.5-2.0 for moderate shock, 2.0-3.0 for heavy shock.
4. **Verify the thermal capacity** is adequate for the operating temperature and the duty cycle. If the thermal capacity is insufficient, select a larger gearbox or add a cooling fan.
5. **Select a backstop** if the conveyor is inclined and the load can back-drive.
6. **Verify the motor** is sized for the starting torque (starting torque can be 2-3x the running torque for a loaded conveyor).

## Common Problems and Fixes
- **Gearbox overheats:** The gearbox is above its thermal rating, the oil is the wrong viscosity, or the cooling is insufficient. Check the oil level, the oil viscosity, and the cooling fan.
- **Gearbox is noisy:** Bearing wear, gear wear, or insufficient oil. Check the oil level and sample for wear metals.
- **Conveyor back-runs on shutdown:** The backstop is failed or missing. Install or replace the backstop.
- **Motor trips on startup:** The starting torque exceeds the motor breakdown torque. Use a soft starter or a VFD to reduce the starting current, or upsize the motor.

## Best Practices and Field Tips
- Trend the gearbox oil temperature — a 15°C rise above baseline warrants investigation.
- Sample the gearbox oil quarterly for wear metals (Fe, Cu, Cr) and water content.
- Replace the gearbox oil at the OEM interval or based on oil analysis — do not extend the interval without oil analysis data.
- For VFD-driven conveyors, verify the gearbox is rated for the variable speed — a gearbox designed for a fixed speed may not have adequate cooling at low speed.

## Safety Notes
- Never open a gearbox breather or oil drain while the gearbox is running — oil can spray under pressure.
- Hot gearbox surfaces can cause burns — allow the gearbox to cool before maintenance.',
   50, 1,
   '[{"question":"What is a gearbox service factor?","options":["The ratio of the gearbox rated power to the motor power","The gearbox efficiency","The oil viscosity","The thermal capacity"],"correctIndex":0},{"question":"What is the efficiency range of a worm gearbox?","options":["95-98%","50-90%","80-85%","90-95%"],"correctIndex":1},{"question":"What is thermal capacity?","options":["The maximum torque","The maximum power the gearbox can handle without overheating","The maximum speed","The oil capacity"],"correctIndex":1},{"question":"What prevents a loaded inclined conveyor from back-running on shutdown?","options":["A brake","A backstop (one-way clutch)","The motor","The coupling"],"correctIndex":1},{"question":"What should be done if a gearbox overheats?","options":["Reduce the load","Check the oil level, the oil viscosity, and the cooling fan","Increase the speed","Replace the gearbox"],"correctIndex":1},{"question":"What does a 15°C rise in gearbox oil temperature above baseline warrant?","options":["Normal operation","Investigation","Oil change","Shutdown"],"correctIndex":1},{"question":"Why must a VFD-driven conveyor gearbox be rated for variable speed?","options":["It does not matter","A gearbox designed for fixed speed may not have adequate cooling at low speed","VFDs require special gearboxes","It is a code requirement"],"correctIndex":1}]'::jsonb),
  (m_id, 'Drive Alignment & Coupling Maintenance',
   '## Overview
The alignment between the motor, the gearbox, and the conveyor drive shaft determines the bearing life and the coupling life. Misalignment is the most common cause of premature bearing and coupling failure on conveyor drives. This lesson covers the alignment procedure and coupling maintenance for conveyor drive systems.

## Key Concepts
- A conveyor drive train typically has three components: motor → coupling → gearbox → coupling → drive shaft. Each coupling must be aligned independently.
- **Coupling types for conveyors:** Gear couplings (high torque, requires lubrication), grid couplings (high torque, dampens shock, requires lubrication), elastomeric couplings (moderate torque, no lubrication, absorbs vibration).
- **Alignment tolerance:** 0.05 mm offset and 0.05 mm/100 mm angularity for most industrial couplings. Precision applications may require tighter.
- **Thermal growth** on the motor (which heats under load) must be compensated — the motor grows vertically, shifting the alignment.
- **Coupling guard** must be in place before the conveyor runs — a rotating coupling is a serious entanglement hazard.

## Step-by-Step: Drive Train Alignment
1. **Rough-align the motor to the gearbox** using a straightedge across the coupling hubs. Get within 0.5 mm.
2. **Check and correct soft-foot** on the motor and the gearbox — a distorted frame will not hold alignment.
3. **Mount the laser alignment system** on the motor-to-gearbox coupling and perform the full alignment procedure (see the Laser Alignment lesson).
4. **Repeat for the gearbox-to-drive-shaft coupling.** Each coupling is aligned independently.
5. **Compensate for thermal growth** if the motor operates at a significantly different temperature than the gearbox.
6. **Torque all bolts** and re-check the alignment. Document the final values.
7. **Install the coupling guards** before returning the conveyor to service.

## Common Problems and Fixes
- **Coupling fails repeatedly:** Misalignment, over-lubrication (for greased couplings), or the coupling is undersized for the torque. Check the alignment and the coupling rating.
- **Gearbox input bearing fails repeatedly:** Misalignment between the motor and the gearbox. Re-check the alignment.
- **Coupling runs hot:** Misalignment generating friction heat, or insufficient lubrication (for greased couplings). Check the alignment and the grease level.
- **Vibration at the coupling frequency:** The coupling is unbalanced or worn. Inspect the coupling for wear and re-balance or replace.

## Best Practices and Field Tips
- Align each coupling in the drive train independently — aligning the motor to the drive shaft in one step does not account for the gearbox in between.
- For greased couplings (gear, grid), establish a greasing schedule based on the coupling manufacturer recommendation — a dry coupling fails rapidly.
- Check the coupling for wear during every gearbox oil change — a worn coupling is easier to replace when the drive is already apart.
- Document the alignment values and the coupling type for each drive train for future reference.

## Safety Notes
- Never rotate the conveyor with the coupling guard removed — the rotating coupling can catch clothing, tools, and fingers.
- Greased couplings can fling grease when rotating — the guard contains the grease and protects personnel.',
   50, 2,
   '[{"question":"How many independent alignments are needed in a motor-gearbox-drive shaft train?","options":["One","Two — each coupling is aligned independently","Three","None"],"correctIndex":1},{"question":"Which coupling type requires no lubrication?","options":["Gear coupling","Grid coupling","Elastomeric coupling","All require lubrication"],"correctIndex":2},{"question":"What is the most common cause of repeated coupling failure?","options":["Oversized coupling","Misalignment, over-lubrication, or undersized coupling","Normal wear","Incorrect color"],"correctIndex":1},{"question":"What should be compensated for on a motor that heats under load?","options":["Nothing","Thermal growth — the motor grows vertically, shifting the alignment","The coupling size","The oil viscosity"],"correctIndex":1},{"question":"What should be installed before returning the conveyor to service?","options":["A new belt","The coupling guards","A speed sensor","A flow meter"],"correctIndex":1},{"question":"What does a coupling that runs hot indicate?","options":["Normal operation","Misalignment generating friction heat, or insufficient lubrication","The coupling is oversized","The ambient temperature is high"],"correctIndex":1},{"question":"When is the best time to check a coupling for wear?","options":["During every gearbox oil change — the drive is already apart","Only when it fails","Never","Annually"],"correctIndex":0}]'::jsonb);

  -- Update existing lessons
  UPDATE lessons SET content =
'## Overview
A mistracking belt causes edge damage, spillage, and premature splice failure. Tracking is adjusted at the tail pulley and the training idlers. Understanding the tracking mechanics and the tensioning principles is essential for any technician maintaining belt conveyors.

## Key Concepts
- The belt moves toward the side of the idler or pulley it contacts first. If the tail pulley is cocked (one side ahead of the other), the belt moves toward the ahead side.
- Tracking is adjusted at the tail pulley: move the side the belt is drifting toward slightly forward (in the direction of belt travel).
- Tension is set so the belt sags no more than 2% of the center-to-center distance under the heaviest expected load. Over-tensioning loads the bearings and stretches the belt; under-tensioning causes slippage on the drive pulley.
- The drive pulley lagging (rubber or ceramic coating) provides grip. Worn lagging is a frequent cause of slip.
- Training idlers (adjustable idlers that steer the belt) are used for continuous tracking correction along the conveyor length.

## Step-by-Step: Belt Tracking Correction
1. **Observe the belt** running at normal speed and load. Note which direction the belt drifts and at what location (tail, mid, or head).
2. **Start at the tail pulley.** If the belt drifts to the right, move the right side of the tail pulley slightly forward (in the direction of belt travel) — 1/4 turn of the take-up bolts at a time.
3. **Let the belt run several revolutions** before re-evaluating. Small changes take time to show.
4. **Check the training idlers** along the conveyor. Adjust each one slightly to steer the belt toward center.
5. **Check the idler alignment** — a skewed idler steers the belt off track. Re-align any skewed idlers.
6. **Check the pulley face** for material buildup — a lump on the pulley face pushes the belt off track. Clean the pulley.
7. **If the belt tracks to one side only at the loading point:** Check the loading chute for off-center loading — the load pushes the belt to one side. Adjust the chute.

## Common Problems and Fixes
- **Belt tracks to one side consistently:** The tail pulley is cocked or a training idler is misaligned. Adjust the tail pulley or the idler.
- **Belt wanders back and forth:** The belt tension is too low (the belt is loose and wanders), or the load is off-center. Increase the tension or adjust the loading chute.
- **Belt tracks fine empty but drifts under load:** The load is off-center. Adjust the loading chute to center the load.
- **New belt tracks poorly:** The belt is not broken in or has a manufacturing defect (curved belt). Run the belt empty for several hours to break it in; if it still tracks poorly, contact the manufacturer.

## Best Practices and Field Tips
- Make small adjustments (1/4 turn at a time) and wait — large adjustments overshoot and chase the belt from side to side.
- Mark the take-up bolt positions so you can return to the original setting if an adjustment makes things worse.
- Clean the pulley faces and the idlers during every tracking correction — material buildup is a hidden cause of mistracking.
- For a new belt, check the tracking empty and loaded — a belt that tracks empty but drifts loaded has an off-center load problem.

## Safety Notes
- Never adjust tracking while the conveyor is running and the guards are removed — the rotating pulley can catch hands. Lock out the conveyor, make the adjustment, re-install the guard, and observe.
- A mistracking belt can rub the frame and create a friction fire — correct tracking promptly.',
   quiz =
'[{"question":"To correct belt drift, which side of the tail pulley should be moved forward?","options":["The side the belt is drifting away from","The side the belt is drifting toward","Both sides equally","Neither — adjust the drive pulley only"],"correctIndex":1},{"question":"What is the maximum recommended belt sag under the heaviest expected load?","options":["1% of center distance","2% of center distance","5% of center distance","10% of center distance"],"correctIndex":1},{"question":"What is a frequent cause of belt slip on the drive pulley?","options":["Worn lagging","Excessive tension","Belt too wide","Pulley too large"],"correctIndex":0},{"question":"How much should the take-up bolts be adjusted at a time?","options":["1 full turn","1/4 turn","1/2 turn","As much as needed"],"correctIndex":1},{"question":"What should be done if the belt tracks fine empty but drifts under load?","options":["Increase the tension","Adjust the loading chute to center the load","Replace the belt","Adjust the tail pulley"],"correctIndex":1},{"question":"What is a hidden cause of mistracking that should be checked during every tracking correction?","options":["Belt tension","Material buildup on pulley faces and idlers","Belt speed","Motor amperage"],"correctIndex":1},{"question":"What safety hazard can a mistracking belt create?","options":["Belt breakage","The belt can rub the frame and create a friction fire","Motor overload","Bearing failure"],"correctIndex":1}]'::jsonb
  WHERE title = 'Belt Tracking & Tensioning' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Chain elongation beyond 2-3% of original pitch indicates replacement is due — beyond this, the chain no longer meshes correctly with the sprocket and accelerates sprocket wear. Measuring chain wear and inspecting sprocket teeth are essential skills for maintaining chain drive systems.

## Key Concepts
- **Chain elongation** is the permanent stretch of the chain due to wear at the pin and bushing joints. It is measured with a chain wear gauge across a known number of links.
- **Sprocket tooth wear** appears as a hooked profile — the tooth tip curls in the direction of chain pull. A worn sprocket will destroy a new chain quickly; always replace both as a set.
- **Lubrication** must reach the link joints (pin and bushing contact), not the outer plate faces. For high-speed or dirty service, use an automatic lubricator.
- **Chain types:** Roller chain (standard, double-pitch, silent), leaf chain (for lifting), and engineering steel chain (for heavy-duty conveying).
- **Multiple-strand chains** require precise sprocket alignment — a misalignment of even 0.5 mm causes uneven load sharing.

## Step-by-Step: Chain Wear Measurement and Sprocket Inspection
1. **Clean the chain** with a brush and solvent to expose the link surfaces.
2. **Measure the chain elongation** using a chain wear gauge. Place the gauge on the chain over the specified number of links (typically 10-12). If the gauge indicates elongation beyond 2-3%, replace the chain.
3. **Inspect the sprocket teeth** for the hooked profile. Use a go/no-go sprocket gauge if available, or visually compare to a new sprocket. If the teeth are hooked, replace the sprocket.
4. **Inspect the chain for stiff links** by flexing the chain sideways. A stiff link (one that does not articulate freely) indicates pin or bushing damage and requires chain replacement.
5. **Check the lubrication** by inspecting the link joints for lubricant presence. A dry joint is a failing joint.
6. **Document the elongation measurement** and compare to the previous measurement to trend the wear rate.

## Common Problems and Fixes
- **Chain jumps the sprocket teeth:** The chain is elongated beyond the sprocket tooth pitch, or the sprocket is worn. Replace both as a set.
- **Chain is stiff (does not articulate freely):** The pin or bushing is corroded or damaged. Replace the chain; do not attempt to free it with force.
- **Sprocket teeth wear rapidly:** The chain is worn and acting like a file on the teeth, or the chain is misaligned. Replace the chain and check the sprocket alignment.
- **Chain snaps:** Overload, shock load, or a worn chain at the pin. Investigate the load condition and the chain wear history.

## Best Practices and Field Tips
- Always replace the chain and sprocket as a set — a worn sprocket destroys a new chain in weeks.
- For critical chain drives, keep a spare chain and sprocket set in stock.
- Trend the chain elongation measurement quarterly — a rising rate indicates increasing wear that warrants investigation of the load condition or the lubrication.
- Use an automatic chain lubricator for hard-to-reach or high-speed chains — manual lubrication at long intervals is worse than continuous lubrication at a low rate.

## Safety Notes
- Never handle a running chain — the pinch point between the chain and the sprocket can amputate fingers. Lock out the drive before inspection.
- A chain under tension stores energy and can whip when released — release the tension before disconnecting.',
   quiz =
'[{"question":"At what chain elongation should replacement typically be considered?","options":["0.5%","1%","2-3%","10%"],"correctIndex":2},{"question":"What does a hooked sprocket tooth profile indicate?","options":["Normal wear","Advanced wear — the sprocket must be replaced","The chain is too tight","The sprocket is new"],"correctIndex":1},{"question":"Why must the chain and sprocket be replaced as a set?","options":["They are sold together","A worn sprocket will destroy a new chain quickly","It is cheaper","It is required by code"],"correctIndex":1},{"question":"Where should chain lubricant be applied?","options":["The outer plate faces","The link joints (pin and bushing contact)","The sprocket teeth","The chain tensioner"],"correctIndex":1},{"question":"What does a stiff link (one that does not articulate freely) indicate?","options":["Normal wear","Pin or bushing damage — replace the chain","The chain is too tight","The lubrication is excessive"],"correctIndex":1},{"question":"What causes a chain to jump the sprocket teeth?","options":["Insufficient lubrication","The chain is elongated beyond the sprocket tooth pitch, or the sprocket is worn","The chain is too tight","The sprocket is too small"],"correctIndex":1},{"question":"How should chain elongation be trended?","options":["Monthly","Quarterly — a rising rate indicates increasing wear warranting investigation","Only when it fails","Annually"],"correctIndex":1}]'::jsonb
  WHERE title = 'Sprocket & Chain Wear' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
A gearbox PM starts with an oil sample and ends with a listening check. The oil tells you what is happening inside the gearbox; the noise tells you where. Trending both over time catches problems before they become failures.

## Key Concepts
- **Wear metal analysis** (Fe, Cu, Cr) in the oil detects active wear before vibration develops. A sudden rise in iron (Fe) flags gear or bearing wear; copper (Cu) flags bearing cage or bushing wear; chromium (Cr) flags hard surface wear.
- **Particle count** (ISO 4406) tracks the cleanliness of the oil. A rising particle count indicates the filter is bypassing or the breather is not filtering.
- **Water in oil** appears as milky oil — from a breather fault, a seal leak, or a cooler leak. Water causes corrosion and reduces the oil film strength.
- **Burnt oil** indicates overheating from overloading or low oil level. The oil oxidizes and forms varnish on the gears and bearings.
- **Breather function:** A clogged breather pressurizes the case and forces oil past the shaft seals. The breather must be replaced at every oil change.

## Step-by-Step: Gearbox PM Procedure
1. **Sample the oil** while the gearbox is running and warm (particles are in suspension). Use a clean sample bottle and fill to the line.
2. **Check the oil level** with the dipstick or sight glass. Low oil indicates a leak; overfull indicates the wrong oil was added or water has entered.
3. **Check the oil condition** visually: milky = water, burnt = overheating, gritty = particles. Smell the oil — a burnt smell confirms overheating.
4. **Inspect the breather** — clean or replace if clogged. A clogged breather is the most common cause of gearbox oil leaks.
5. **Listen to the gearbox** while it is running: whine = gear mesh issue, knock = bearing or tooth damage, rumble = general wear.
6. **Record the oil temperature** — a 15°C rise above baseline warrants investigation.
7. **Send the oil sample** to the lab for analysis and trend the results when the report returns.

## Common Problems and Fixes
- **Oil is milky:** Water ingress from a breather fault, a seal leak, or a cooler leak. Replace the breather, check the seals, and change the oil.
- **Oil is burnt:** Overheating from overloading or low oil. Check the load, the oil level, and the cooling. Change the oil.
- **Iron (Fe) is rising in the oil analysis:** Gear or bearing wear. Schedule a gearbox inspection at the next outage.
- **Gearbox is whining:** Gear mesh issue — check the gear contact pattern (if accessible) or the backlash. May indicate gear wear or misalignment.
- **Oil is leaking from the seals:** The breather is clogged, pressurizing the case. Replace the breather and check the seals.

## Best Practices and Field Tips
- Sample the oil at the same interval, from the same point, while the gearbox is running — consistency makes the trend meaningful.
- Keep a log of the oil analysis results for each gearbox — a single sample is data; a trend is information.
- Replace the oil at the OEM interval or based on oil analysis — do not extend the interval without analysis data.
- For gearboxes with no oil analysis program, at minimum check the oil level, the breather, and the temperature monthly.

## Safety Notes
- Hot gearbox oil can cause burns — allow the gearbox to cool before opening the drain or the inspection cover.
- Gearbox oil is slippery — clean up any spills immediately to prevent slip hazards.',
   quiz =
'[{"question":"What does milky gearbox oil typically indicate?","options":["Overloading","Water ingress","Oxidation","Wrong lubricant grade"],"correctIndex":1},{"question":"What can a clogged gearbox breather cause?","options":["Low oil level","Oil leaks past the seals","Cavitation","Excessive lubrication"],"correctIndex":1},{"question":"What does a sudden rise in iron (Fe) in gearbox oil analysis flag?","options":["Normal wear","Gear or bearing wear","Water contamination","Oil oxidation"],"correctIndex":1},{"question":"What does a gearbox whine typically indicate?","options":["Bearing damage","Gear mesh issue","Low oil","Overload"],"correctIndex":1},{"question":"What does a 15°C rise in gearbox oil temperature above baseline warrant?","options":["Normal operation","Investigation","Immediate shutdown","Oil change"],"correctIndex":1},{"question":"Why should oil samples be taken while the gearbox is running and warm?","options":["For convenience","Particles are in suspension, giving an accurate sample","It is safer","It is required by the lab"],"correctIndex":1},{"question":"What does a burnt smell in gearbox oil confirm?","options":["Normal aging","Overheating from overloading or low oil","Water ingress","Wrong oil grade"],"correctIndex":1}]'::jsonb
  WHERE title = 'Gearbox Inspection & Oil Analysis' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;
