/*
# Catalog depth expansion — Mechanical courses 4-7

## Courses in this batch
4. Precision Measurement & Troubleshooting (add 1 module → 3 total)
5. Hydraulics & Pneumatics Basics (add 1 module → 3 total)
6. Gearboxes & Power Transmission (add 2 modules → 4 total)
7. Fans, Blowers & Air Handling Systems (add 2 modules → 4 total)

## Security
No schema or policy changes. Data-only migration.
*/

-- ===================== 4. PRECISION MEASUREMENT & TROUBLESHOOTING =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Precision Measurement & Troubleshooting';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Diagnostics & Tolerance Analysis', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Tolerance Stack-Up & Fit Analysis',
   '## Overview
Tolerance stack-up analysis determines whether the accumulated tolerances of multiple components will still allow the assembly to function. A shaft with a tolerance of +/-0.02 mm and a bearing bore with a tolerance of +/-0.02 mm can produce a fit that ranges from a 0.04 mm clearance to a 0.04 mm interference — the stack-up determines whether the bearing will slide on or require pressing, and whether the running clearance will be correct.

## Key Concepts
- **Clearance fit:** The shaft is always smaller than the bore — the parts slide freely. Used for sliding or rotating assemblies.
- **Interference fit:** The shaft is always larger than the bore — the parts are locked together. Used for bearing mounting on shafts.
- **Transition fit:** The shaft may be larger or smaller than the bore — the fit varies from clearance to interference. Used for locating parts precisely.
- **Tolerance stack-up** is calculated by the worst-case method (sum all tolerances) or the statistical method (root-sum-square). The worst-case method is conservative; the statistical method is realistic for independent tolerances.
- The **ISO tolerance system** (ISO 286) defines tolerance grades (IT5, IT6, IT7, etc.) and fundamental deviations (H, g, k, etc.) that specify the fit type.

## Step-by-Step: Tolerance Stack-Up Calculation
1. List each component and its dimension with the tolerance (e.g., shaft 50 mm +/-0.02, bearing bore 50 mm +0.02/-0.00).
2. Calculate the maximum clearance: largest bore minus smallest shaft.
3. Calculate the minimum clearance (or maximum interference): smallest bore minus largest shaft.
4. Verify the resulting fit range meets the application requirement. If not, tighten the component tolerances or select a different fit class.
5. For a rotating shaft in a bearing, the running clearance (after thermal expansion) must be within the bearing manufacturer specification — typically 0.02-0.05 mm for a journal bearing.

## Common Problems and Fixes
- **Bearing is too tight on the shaft (interference too large):** The shaft is oversized. Machine the shaft to the correct dimension or select a bearing with a larger bore tolerance.
- **Bearing is too loose on the shaft (clearance):** The shaft is undersized or worn. Build up the shaft by welding or thermal spray, or use a retaining compound.
- **Running clearance is too small after thermal expansion:** The interference fit is too tight for the operating temperature. Reduce the interference or select a bearing with higher clearance class.

## Best Practices and Field Tips
- Always measure both the shaft and the bore before assembling a press fit — do not rely on the nominal dimensions.
- For critical fits, use the statistical stack-up method to avoid over-tightening tolerances that increase cost without improving function.
- Document the measured dimensions and the fit calculation for critical assemblies — it provides a baseline for future wear analysis.

## Safety Notes
- Pressing a bearing onto a shaft with excessive interference can crack the bearing — always verify the interference is within the bearing manufacturer specification before pressing.',
   50, 1,
   '[{"question":"What is a clearance fit?","options":["The shaft is always larger than the bore","The shaft is always smaller than the bore — parts slide freely","The fit varies from clearance to interference","The parts are locked together"],"correctIndex":1},{"question":"What is an interference fit used for?","options":["Sliding assemblies","Bearing mounting on shafts","Locating parts precisely","Rotating assemblies"],"correctIndex":1},{"question":"How is the worst-case tolerance stack-up calculated?","options":["Root-sum-square of all tolerances","Sum all tolerances","Average all tolerances","Use the largest tolerance only"],"correctIndex":1},{"question":"What is the typical running clearance for a journal bearing after thermal expansion?","options":["0.001-0.005 mm","0.02-0.05 mm","0.1-0.2 mm","1-2 mm"],"correctIndex":1},{"question":"What does a bearing that is too tight on the shaft indicate?","options":["The shaft is undersized","The shaft is oversized — machine to the correct dimension or select a bearing with larger bore tolerance","Normal fit","The bearing is the wrong type"],"correctIndex":1},{"question":"What should be done before assembling a press fit?","options":["Nothing — just press it on","Measure both the shaft and the bore — do not rely on nominal dimensions","Heat the bearing","Apply grease"],"correctIndex":1},{"question":"What can happen if the interference is excessive when pressing a bearing?","options":["Nothing","The bearing can crack — always verify the interference is within the manufacturer specification","It will be a better fit","The shaft will bend"],"correctIndex":1}]'::jsonb),
  (m_id, 'Geometric Dimensioning & Tolerancing (GD&T) Basics',
   '## Overview
Geometric Dimensioning and Tolerancing (GD&T) is a symbolic language for communicating part geometry and allowable variation on engineering drawings. Understanding GD&T is essential for interpreting modern engineering drawings and for precision measurement.

## Key Concepts
- **Feature control frame:** The GD&T symbol block that specifies the geometric characteristic, the tolerance, the datum references, and any material condition modifiers.
- **Datums:** The reference surfaces from which measurements are taken. A primary datum is the first reference; secondary and tertiary datums complete the reference frame.
- **Common geometric characteristics:** Flatness (all points on a surface within a tolerance zone), perpendicularity (a surface perpendicular to a datum within a tolerance zone), concentricity (two axes within a tolerance zone), runout (the surface variation when rotated about a datum axis).
- **Material condition modifiers:** MMC (Maximum Material Condition — the part has the most material, smallest hole or largest shaft) and LMC (Least Material Condition). These modifiers allow bonus tolerance.
- **Runout** is the most common GD&T callout for rotating equipment — it specifies the surface variation when the part is rotated about a datum axis.

## Step-by-Step: Measuring Runout per GD&T
1. Identify the datum axis (typically the bearing journal or the coupling fit).
2. Mount the part on V-blocks or centers that establish the datum axis.
3. Mount a dial indicator on a fixed base with the contact point perpendicular to the surface being measured.
4. Pre-load the indicator 0.2-0.5 mm and zero the dial.
5. Rotate the part one full revolution and record the highest and lowest readings.
6. The total indicator reading (TIR) is the sum of the highest and lowest deviations — this is the runout.
7. Compare the TIR to the GD&T callout on the drawing. If the TIR exceeds the callout, the part is out of tolerance.

## Common Problems and Fixes
- **Runout exceeds the drawing callout:** The part is bent, the surface is worn, or the datum is damaged. Check the datum surface first — a damaged datum produces a false runout reading.
- **Concentricity is out of tolerance:** The two axes are not coincident. This can be from a bent shaft or a machining error. Straighten or re-machine the shaft.
- **Flatness is out of tolerance:** The surface is warped. Machine or lap the surface flat, or replace the part.

## Best Practices and Field Tips
- Always verify the datum surface is clean and undamaged before measuring — a datum with a burr or corrosion produces false readings.
- For runout measurements, use V-blocks that match the shaft diameter — a V-block that is too large or too small does not establish the datum correctly.
- Record the TIR at multiple positions along the shaft to detect a bent shaft (the TIR is consistent at all positions) versus a tapered shaft (the TIR changes along the length).

## Safety Notes
- Rotating a heavy shaft by hand can pinch fingers — use a strap wrench or a rotating fixture, not bare hands.',
   50, 2,
   '[{"question":"What is a datum in GD&T?","options":["The tolerance value","The reference surface from which measurements are taken","The material condition","The feature size"],"correctIndex":1},{"question":"What does runout specify?","options":["The surface variation when the part is rotated about a datum axis","The flatness of a surface","The perpendicularity of a surface","The concentricity of two axes"],"correctIndex":0},{"question":"How is TIR (total indicator reading) calculated?","options":["The average of all readings","The sum of the highest and lowest deviations in one revolution","The first reading taken","The difference between two shafts"],"correctIndex":1},{"question":"What does a runout that exceeds the drawing callout indicate?","options":["Normal tolerance","The part is bent, the surface is worn, or the datum is damaged","The indicator is faulty","The measurement is wrong"],"correctIndex":1},{"question":"What should be verified before measuring runout?","options":["The indicator calibration","The datum surface is clean and undamaged — a damaged datum produces false readings","The ambient temperature","The shaft color"],"correctIndex":1},{"question":"What does a consistent TIR at all positions along a shaft indicate?","options":["A tapered shaft","A bent shaft (the TIR is the same everywhere)","A worn shaft","A straight shaft"],"correctIndex":1},{"question":"What does MMC (Maximum Material Condition) represent?","options":["The part has the least material","The part has the most material — smallest hole or largest shaft","The nominal dimension","The tolerance zone"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons
  UPDATE lessons SET content =
'## Overview
A dial indicator measures small linear displacements, typically to 0.01 mm or 0.001 inch. It is the fundamental tool for precision mechanical measurement — used for runout, alignment, flatness, and concentricity checks. Understanding the correct setup and reading technique is essential for accurate measurements.

## Key Concepts
- A dial indicator has a contact point that moves a stem, which drives a gear train to rotate the needle. The reading is the linear displacement of the stem.
- **Pre-loading:** The stem must be compressed 0.2-0.5 mm before zeroing so the indicator reads in both directions (positive and negative) during rotation.
- **Total Indicator Reading (TIR):** The sum of the highest and lowest deviations in one full revolution. This is the runout.
- **Runout tolerance:** A shaft journal should typically be under 0.05 mm for general service; precision applications may require 0.02 mm or less.
- **Mounting:** The indicator base must be rigid — a magnetic base on a machined surface is standard. A base on a rough or painted surface flexes and produces false readings.
- **Reverse-indicator method:** Uses two indicators to measure both shafts simultaneously for coupling alignment, accounting for both the angular and the parallel misalignment.

## Step-by-Step: Measuring Shaft Runout
1. **Clean the shaft surface** where the indicator will contact — dirt under the contact point produces false readings.
2. **Mount the indicator** on a rigid magnetic base on a machined surface near the shaft.
3. **Position the contact point** perpendicular to the shaft surface at the measurement location.
4. **Pre-load the stem** 0.2-0.5 mm by pressing the indicator toward the shaft until the needle reads 0.2-0.5, then zero the dial.
5. **Rotate the shaft** one full revolution by hand. Record the highest reading (clockwise from zero) and the lowest reading (counterclockwise from zero).
6. **Calculate the TIR:** Add the absolute values of the highest and lowest readings. For example, if the highest is +0.03 and the lowest is -0.01, the TIR is 0.04 mm.
7. **Compare the TIR** to the tolerance. If the TIR exceeds the tolerance, the shaft is bent or the surface is worn.
8. **Repeat at multiple positions** along the shaft to distinguish a bent shaft (consistent TIR) from a tapered shaft (changing TIR).

## Common Problems and Fixes
- **Readings are inconsistent:** The indicator base is not rigid, or the shaft surface is dirty. Clean the surface and re-mount the base on a machined surface.
- **The needle does not return to zero:** The stem is sticky or the gear train is worn. Clean or replace the indicator.
- **TIR is high but the shaft looks straight:** The surface has a burr or corrosion at the measurement point. Stone the surface flat and re-measure.
- **The indicator reads in the wrong direction:** The contact point is on the wrong side of the shaft. Reposition the contact point perpendicular to the surface.

## Best Practices and Field Tips
- Always indicate on a clean, machined surface — rough or painted surfaces produce false readings.
- Verify the indicator is calibrated by checking the stem movement against a gauge block or a known standard.
- For coupling alignment, use two indicators in the reverse-indicator method — one on each shaft, reading the other shaft. This accounts for both shafts and both misalignment types.
- Record the TIR at the bearing journals, the coupling fit, and the impeller fit — a shaft that is straight at the journals but has runout at the coupling fit has a bent end.

## Safety Notes
- Never rotate the shaft with the motor energized — lock out the motor before rotating by hand. A rotating shaft can catch the indicator and fling it.
- Keep fingers away from the contact point — the stem under pre-load can pinch.',
   quiz =
'[{"question":"What does TIR (total indicator reading) represent?","options":["The average of all readings","The sum of the highest and lowest deviations in one revolution","The first reading taken","The difference between two shafts"],"correctIndex":1},{"question":"What is the typical runout tolerance for a general-service shaft journal?","options":["Under 0.5 mm","Under 0.05 mm","Under 0.005 mm","Under 1 mm"],"correctIndex":1},{"question":"How much should the dial indicator stem be pre-loaded before zeroing?","options":["0.01 mm","0.2-0.5 mm","1 mm","No pre-load needed"],"correctIndex":1},{"question":"Why must the indicator base be mounted on a machined surface?","options":["For appearance","A base on a rough or painted surface flexes and produces false readings","It is required by ISO","It is easier to clean"],"correctIndex":1},{"question":"What does a consistent TIR at all positions along a shaft indicate?","options":["A tapered shaft","A bent shaft","A worn shaft","A straight shaft"],"correctIndex":1},{"question":"What does a high TIR on a shaft that looks straight indicate?","options":["The shaft is bent internally","The surface has a burr or corrosion at the measurement point — stone the surface and re-measure","The indicator is faulty","The shaft is too hard"],"correctIndex":1},{"question":"What safety precaution is needed when measuring runout?","options":["Wear gloves","Lock out the motor before rotating by hand — a rotating shaft can catch the indicator","Nothing special","Use a longer indicator stem"],"correctIndex":1}]'::jsonb
  WHERE title = 'Dial Indicators & Runout' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
A micrometer reads to 0.01 mm (or 0.001 inch) using a vernier scale and a ratchet stop for consistent measuring force. A caliper is faster but less precise (0.02 mm). Both are fundamental tools for precision mechanical measurement. Understanding the correct technique and the limitations of each tool is essential for accurate measurements.

## Key Concepts
- **Micrometer:** Uses a screw mechanism to move the anvil toward the spindle. The ratchet stop applies consistent measuring force — never over-tighten by feel, as it distorts the reading.
- **Caliper:** Uses a slide mechanism with a vernier or digital readout. Faster than a micrometer but less precise and less repeatable. Suitable for rougher work.
- **Zero check:** A micrometer must be zero-checked against its standard rod before measuring. A caliper must be zeroed with the jaws closed.
- **Multi-position measurement:** When measuring a journal, take readings at three angular positions (0°, 120°, 240°) and two axial positions (left, right) to detect taper and ovality.
- **Temperature effect:** Holding a micrometer or a caliper by the frame transfers body heat, causing expansion. Hold by the insulating plate, not the frame.

## Step-by-Step: Measuring a Shaft Journal with a Micrometer
1. **Zero-check the micrometer** against its standard rod. The zero line on the vernier must align with the zero on the barrel. If not, adjust the zero or note the offset.
2. **Clean the anvils** and the shaft surface with a lint-free wipe. Dirt between the anvils and the work produces false readings.
3. **Position the micrometer** on the shaft journal with the anvil against one side and the spindle approaching the opposite side.
4. **Turn the ratchet stop** until it clicks 2-3 times — never use the thimble to tighten, as it applies variable force.
5. **Read the micrometer:** The barrel reading is the whole millimeter and the half-millimeter; the vernier line on the thimble gives the hundredths.
6. **Record the reading** and repeat at three angular positions and two axial positions.
7. **Calculate ovality:** The difference between the largest and smallest readings at the same axial position is the ovality.
8. **Calculate taper:** The difference between the readings at the two axial positions is the taper.

## Common Problems and Fixes
- **Micrometer does not zero:** The anvils are dirty or worn. Clean the anvils; if still not zero, adjust the zero or return for calibration.
- **Readings are not repeatable:** The measuring force is inconsistent (using the thimble instead of the ratchet) or the micrometer is not square on the work. Use the ratchet and verify the micrometer is square.
- **Caliper readings drift:** The caliper slide is loose or the jaws are worn. Check the slide and re-zero.
- **Micrometer reads large when held:** Body heat is expanding the frame. Hold by the insulating plate and allow the micrometer to equalize to the work temperature.

## Best Practices and Field Tips
- Always zero-check a micrometer before measuring — a micrometer that is not zeroed produces a systematic error on every reading.
- A single measurement is an assumption; a set of measurements is data. Always take multiple readings and record them.
- For digital calipers, verify the battery is fresh — a low battery causes erratic readings.
- Store micrometers and calipers in their cases with the jaws slightly open — closed jaws can seize from corrosion.

## Safety Notes
- Never use a micrometer as a C-clamp or a pry tool — the precision screw and anvils will be damaged.
- The ratchet stop spring is under tension — do not disassemble the micrometer without training.',
   quiz =
'[{"question":"Why does a micrometer use a ratchet stop?","options":["To prevent damage to the thread","To apply consistent measuring force","To speed up measurement","To allow one-handed use"],"correctIndex":1},{"question":"What is the precision of a typical caliper compared to a micrometer?","options":["Same precision","Caliper is 0.02 mm, micrometer is 0.01 mm","Caliper is 0.001 mm, micrometer is 0.01 mm","Caliper is more precise"],"correctIndex":1},{"question":"What should be done before measuring with a micrometer?","options":["Nothing","Zero-check against the standard rod and clean the anvils","Heat the micrometer","Oil the screw"],"correctIndex":1},{"question":"How should ovality be measured on a shaft journal?","options":["Take one reading","Take readings at three angular positions and calculate the difference between largest and smallest","Measure the diameter only","Use a caliper"],"correctIndex":1},{"question":"Why should a micrometer be held by the insulating plate, not the frame?","options":["For comfort","Holding the frame transfers body heat, causing expansion","It is required by the manufacturer","It is safer"],"correctIndex":1},{"question":"What does a set of measurements at multiple positions provide that a single measurement does not?","options":["Nothing different","Data — a single measurement is an assumption","Faster results","Better precision"],"correctIndex":1},{"question":"What causes a digital caliper to give erratic readings?","options":["Dirt on the slide","A low battery","Over-tightening","Temperature changes"],"correctIndex":1}]'::jsonb
  WHERE title = 'Micrometers & Calipers' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Soft-foot occurs when one or more feet of a machine do not sit flat on the base, distorting the frame when the hold-down bolts are tightened. This distortion bends the bearing housings, introducing internal misalignment that no external alignment can correct. Detecting and correcting soft-foot is the first step in any precision alignment procedure.

## Key Concepts
- **Parallel soft-foot:** A uniform gap between the foot and the base. Corrected by shimming with stainless shims.
- **Angular soft-foot:** A wedge-shaped gap — the foot or the base is bent. May require machining.
- **Induced soft-foot:** Caused by pipe strain or coupling strain pulling the machine. Fix the pipe or the coupling, not the foot.
- The threshold for action is 0.05 mm — any foot that lifts more than this when the bolt is loosened requires correction.
- Never force a bolt down to close a gap — it bends the frame and distorts the bearing housing. Always shim the gap.

## Step-by-Step: Detecting and Correcting Soft-Foot
1. **Mount a dial indicator** on the machine frame with the contact point on the top of one foot.
2. **Loosen the bolt** on that foot and observe the indicator reading — the lift is the soft-foot amount.
3. **Record the reading** and re-tighten the bolt.
4. **Repeat for all four feet.** Record each reading.
5. **Shim any foot** that lifts more than 0.05 mm with stainless shims. Use the minimum number of shims (never more than 3) to fill the gap.
6. **Re-check all four feet** after shimming. A correction on one foot can change the readings on the others.
7. **If the soft-foot is angular (wedge gap):** The foot or the base is bent. Check for a bent foot (straightedge) and consider machining the base or the foot.
8. **If the soft-foot is induced (pipe strain):** Check the piping. Loosen the pipe flanges and re-check the soft-foot. If it changes, correct the pipe strain first.

## Common Problems and Fixes
- **Soft-foot returns after shimming:** The shim is too thin (compresses under torque) or too many shims are stacked (act like a spring). Use fewer, thicker shims.
- **All four feet have soft-foot:** The base is warped. Machine the base flat or grout the machine to the base.
- **Soft-foot is corrected but alignment still will not hold:** Pipe strain is the cause. Check and correct the pipe strain.
- **Foot is cracked or bent:** Replace the foot or machine it flat. A bent foot cannot be shimmed correctly.

## Best Practices and Field Tips
- Always check soft-foot before any alignment — it is the most common cause of alignment failure.
- Use stainless shims, not carbon steel — carbon steel shims rust and change thickness.
- Never stack more than 3 shims under a foot — they compress under torque and the soft-foot returns.
- Document the soft-foot readings and the shims installed for each foot for future reference.

## Safety Notes
- Never put a finger under a machine foot while loosening bolts — the machine can shift and pinch.
- Torque the bolts after shimming — loose bolts allow the machine to shift during operation.',
   quiz =
'[{"question":"What is the correct way to correct a soft-foot gap?","options":["Torque the bolt harder to pull the foot down","Shim the gap with stainless shims","Grind the base flat","Ignore it if under 0.2 mm"],"correctIndex":1},{"question":"What is the threshold for soft-foot correction?","options":["0.01 mm","0.05 mm","0.5 mm","1 mm"],"correctIndex":1},{"question":"What is induced soft-foot caused by?","options":["A bent foot","Pipe strain or coupling strain pulling the machine","A warped base","Overtightening the bolts"],"correctIndex":1},{"question":"Why should never more than 3 shims be stacked under a foot?","options":["It is too expensive","They act like a spring and compress under torque","It is hard to install","It is a code requirement"],"correctIndex":1},{"question":"What should be done if soft-foot returns after shimming?","options":["Add more shims","The shim is too thin or too many are stacked — use fewer, thicker shims","Replace the machine","Ignore it"],"correctIndex":1},{"question":"What should be checked if soft-foot is corrected but alignment still will not hold?","options":["The laser system","Pipe strain — check and correct the pipe strain","The coupling","The bearings"],"correctIndex":1},{"question":"What type of shims should be used?","options":["Carbon steel","Stainless steel — carbon steel rusts and changes thickness","Aluminum","Copper"],"correctIndex":1}]'::jsonb
  WHERE title = 'Detecting and Correcting Soft-Foot' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 5. HYDRAULICS & PNEUMATICS BASICS =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Hydraulics & Pneumatics Basics';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Fluid Power System Troubleshooting & Safety', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Hydraulic System Troubleshooting',
   '## Overview
Hydraulic system troubleshooting requires a systematic approach because the symptoms (slow operation, noise, heat) can have multiple causes. A methodical diagnostic process isolates the problem to the pump, the valve, the actuator, or the fluid, preventing unnecessary parts replacement.

## Key Concepts
- **Slow operation** can be caused by: low pump output (worn pump, low speed), internal leakage (worn valve spools, worn cylinder seals), restricted flow (clogged filter, restricted line), or low fluid level.
- **Noise** can be caused by: cavitation (clogged suction strainer, high suction lift), air in the fluid (foaming), aeration (air entering the suction line), or a failing pump (worn gears or vanes).
- **Heat** can be caused by: internal leakage (fluid bypassing through worn components), restricted flow (fluid shearing through small clearances), low fluid level (insufficient cooling), or a failed cooler.
- **Pressure drop** across a component indicates internal leakage or a restriction. Measure the pressure upstream and downstream to isolate the faulty component.
- A **flow meter** in the return line verifies the pump output and the system leakage.

## Step-by-Step: Hydraulic System Diagnosis
1. **Check the fluid level and condition:** Low fluid causes cavitation and heat. Milky fluid indicates water. Burnt fluid indicates overheating. Foamy fluid indicates air entrainment.
2. **Check the suction strainer:** A clogged strainer causes cavitation. Clean or replace.
3. **Check the pump output:** Install a flow meter in the pump discharge and compare to the pump rating. Low output indicates a worn pump.
4. **Check the relief valve:** Verify the relief valve setting by deadheading the pump (briefly) and reading the maximum pressure. A low relief setting causes low system pressure.
5. **Check the directional valve:** Measure the pressure drop across the valve. A high pressure drop indicates internal leakage or a worn spool.
6. **Check the cylinder:** Measure the cylinder speed and compare to the specification. Slow speed with full pressure indicates internal leakage (worn piston seal). Install a blanking plate at the cylinder port and pressurize — if the cylinder drifts, the piston seal is leaking.
7. **Check the return filter:** A clogged filter restricts the return flow and causes backpressure. Replace the filter.

## Common Problems and Fixes
- **Cylinder drifts under load:** The piston seal is leaking internally. Replace the cylinder seal or the cylinder.
- **Pump is noisy and the fluid is foamy:** Air is entering the suction line. Check the suction line for loose fittings and the reservoir for a low fluid level (the suction port is pulling air).
- **System overheats:** Internal leakage or a failed cooler. Check the cooler flow and the component leakage. Change the fluid if it is degraded.
- **Pressure is low but the pump is good:** The relief valve is set too low or is leaking. Adjust or replace the relief valve.

## Best Practices and Field Tips
- Install pressure gauges at the pump discharge, the valve inlet, and the cylinder inlet — the pressure profile across the system isolates the problem.
- Trend the fluid temperature — a rising temperature indicates increasing internal leakage.
- Change the fluid and the filter at the OEM interval — degraded fluid accelerates wear on every component.
- Keep the reservoir clean — debris in the reservoir enters the pump and damages every downstream component.

## Safety Notes
- Never deadhead a pump for more than a few seconds — the fluid overheats rapidly and the pump can be damaged.
- Hydraulic fluid under pressure can penetrate skin — never search for a leak with bare hands. Use a piece of cardboard or wood.',
   55, 1,
   '[{"question":"What are the common causes of slow hydraulic operation?","options":["Only low fluid level","Low pump output, internal leakage, restricted flow, or low fluid level","Only a worn pump","Only a clogged filter"],"correctIndex":1},{"question":"What does milky hydraulic fluid indicate?","options":["Air entrainment","Water contamination","Wrong viscosity","Overheating"],"correctIndex":1},{"question":"How do you test if a cylinder piston seal is leaking internally?","options":["Replace the cylinder","Install a blanking plate at the cylinder port and pressurize — if the cylinder drifts, the seal is leaking","Increase the pressure","Listen for noise"],"correctIndex":1},{"question":"What causes a hydraulic system to overheat?","options":["Only low fluid level","Internal leakage, restricted flow, low fluid level, or a failed cooler","Only a failed cooler","Only a clogged filter"],"correctIndex":1},{"question":"What should never be done to search for a hydraulic leak?","options":["Use a flashlight","Use bare hands — fluid under pressure can penetrate skin","Use a mirror","Use leak detector fluid"],"correctIndex":1},{"question":"What should be installed at the pump discharge, valve inlet, and cylinder inlet?","options":["Flow meters only","Pressure gauges — the pressure profile isolates the problem","Temperature gauges only","Nothing"],"correctIndex":1},{"question":"What does a clogged return filter cause?","options":["Nothing","Backpressure in the return line","Faster operation","Lower temperature"],"correctIndex":1}]'::jsonb),
  (m_id, 'Pneumatic System Maintenance & LOTO for Fluid Power',
   '## Overview
Pneumatic systems use compressed air — safer than hydraulics in terms of fluid spillage, but the stored energy in receivers and actuators is still dangerous. Proper maintenance and lockout/tagout procedures are essential for safe operation.

## Key Concepts
- **FRL (Filter, Regulator, Lubricator):** The standard air preparation unit at the inlet of a pneumatic system. The filter removes moisture and particulates; the regulator sets the system pressure; the lubricator adds oil mist for valve and cylinder lubrication.
- **Air consumption** is measured in SCFM (standard cubic feet per minute). Size the compressor for the total consumption plus a 20% margin for leakage.
- **Moisture** in the air condenses in the lines and washes the lubricant off the valves and cylinders, causing wear. The FRL filter must be drained regularly.
- **Stored energy** in a receiver, an accumulator, or a cylinder is dangerous — it must be released before servicing.
- **LOTO for fluid power:** Isolate the supply, lock the valve, bleed the residual pressure to zero, and verify with a gauge. For pneumatic cylinders, confirm both ports are vented.

## Step-by-Step: Pneumatic System PM
1. **Drain the FRL filter bowl** of accumulated water and oil. If the bowl fills in less than a week, the air dryer is failing.
2. **Check the regulator setting** — verify the system pressure matches the design (typically 80-100 PSI). A drifting regulator causes inconsistent operation.
3. **Check the lubricator oil level** and refill if low. Verify the drip rate is set per the manufacturer (typically 1-2 drops per cycle for cylinders, less for valves).
4. **Inspect the air lines for leaks** — listen for hissing, or use an ultrasonic leak detector. Tag and repair leaks.
5. **Check the compressor** — verify the oil level, the discharge pressure, and the unloader operation. Drain the receiver of condensate.
6. **Inspect the cylinder seals** for leaks — a leaking cylinder seal wastes air and causes slow operation.

## Step-by-Step: LOTO for Fluid Power Systems
1. **Identify all energy sources:** the compressed air supply, the receiver (stored energy), any accumulators, and any spring-loaded or gravity-loaded actuators.
2. **Isolate the supply:** Close the main air valve and lock it with a lock and a tag.
3. **Bleed the residual pressure:** Open the bleed valve at the end of the line and verify the pressure drops to zero on the gauge.
4. **Verify both cylinder ports are vented:** A cylinder can hold trapped air on the rod side even after the supply is off. Cycle the valve manually to release any trapped air.
5. **Block or pin any load** that could fall or move when the pressure is released — a gravity-loaded cylinder will drop when the pressure is removed.
6. **Verify zero energy:** Attempt to operate the cylinder — it should not move. If it does, there is a residual energy source that was not isolated.

## Common Problems and Fixes
- **Water in the air lines:** The FRL filter is not draining or the air dryer is failed. Drain the filter and check the dryer.
- **Cylinder is slow:** The seal is leaking, the air pressure is low, or the flow control is restricted. Check the seal, the pressure, and the flow control valve.
- **Valve sticks:** The lubricator is not providing oil, or the valve spool is contaminated. Refill the lubricator and clean or replace the valve.
- **Compressor runs continuously:** The system has a large leak, or the compressor unloader is failed. Find and repair leaks; check the unloader.

## Best Practices and Field Tips
- Install a pressure gauge at the inlet of each pneumatic device — a pressure drop across the system indicates a restriction.
- Trend the compressor run time — increasing run time with constant demand indicates growing leaks.
- Use a ultrasonic leak detector for quarterly leak surveys — a 1/8 inch air leak at 100 PSI wastes approximately $2,000 per year in electricity.
- For modern systems with sealed bearings and pre-lubricated valves, remove the lubricator — oil in the air damages modern seals and washes out pre-lubricated grease.

## Safety Notes
- Never disconnect a pressurized hose — the whip can cause serious injury. Always bleed the pressure before disconnecting.
- A receiver is a pressure vessel — it must be inspected per the local pressure vessel code. An uninspected receiver can explode.',
   55, 2,
   '[{"question":"What does FRL stand for in pneumatic systems?","options":["Flow, Regulator, Lubricator","Filter, Regulator, Lubricator","Filter, Relief, Lubricator","Flow, Relief, Lock"],"correctIndex":1},{"question":"What must be done before disconnecting a pneumatic hose?","options":["Tighten the fitting","Isolate supply and bleed pressure to zero","Reduce the compressor output","Cycle the cylinder to empty"],"correctIndex":1},{"question":"Why must both cylinder ports be vented during LOTO?","options":["For convenience","A cylinder can hold trapped air on the rod side even after the supply is off","It is required by code","To save air"],"correctIndex":1},{"question":"What causes water in pneumatic air lines?","options":["High humidity only","The FRL filter is not draining or the air dryer is failed","The compressor is too large","The regulator is set too high"],"correctIndex":1},{"question":"What does a 1/8 inch air leak at 100 PSI waste per year?","options":["$200","$2,000","$20,000","$200,000"],"correctIndex":1},{"question":"What should be done for modern systems with sealed bearings and pre-lubricated valves?","options":["Add more lubrication","Remove the lubricator — oil damages modern seals and washes out pre-lubricated grease","Nothing","Replace the FRL"],"correctIndex":1},{"question":"What must be done with a load that could fall when pressure is released during LOTO?","options":["Nothing","Block or pin the load — a gravity-loaded cylinder will drop when pressure is removed","Increase the pressure","Remove the load"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons
  UPDATE lessons SET content =
'## Overview
A hydraulic system transmits force via pressurized fluid. The pump converts mechanical energy into fluid flow; the directional valve routes that flow; the actuator (cylinder or motor) converts it back to mechanical work. Understanding the function of each component and how they interact is the foundation of hydraulic system maintenance.

## Key Concepts
- **Gear pumps** are simple and robust for medium-pressure service (up to 250 bar). **Vane pumps** run quieter and handle medium pressure (up to 210 bar). **Piston pumps** handle the highest pressures (up to 400+ bar) and are used in high-performance applications.
- **The relief valve** protects the system from overpressure and must be set above the maximum working pressure but below the component rating. It is the safety device of the system.
- **Directional valves** route the flow to the extend or retract port of the cylinder. They are classified by the number of positions and the number of ports (e.g., 4-way, 3-position).
- **Pressure-compensated flow control** maintains a constant flow regardless of the load pressure, ensuring consistent cylinder speed.
- **Accumulators** store hydraulic energy for peak demand, absorb pulsations, and provide emergency power. They are pre-charged with nitrogen gas.

## Step-by-Step: Hydraulic System Startup
1. **Verify the fluid level** in the reservoir — low fluid causes cavitation and heat.
2. **Verify all valves are in the neutral or centered position** — starting with a valve shifted can cause an unexpected movement.
3. **Start the pump with the relief valve backed off** (at minimum pressure) to prevent overpressure on startup.
4. **Bring the pressure up slowly** while watching for leaks and abnormal noise.
5. **Set the relief valve** to the system working pressure (typically 10% above the maximum load pressure).
6. **Cycle each function** (extend and retract each cylinder) to bleed air from the lines. Air in the system causes spongy operation and noise.
7. **Verify the system pressure** at each actuator — a pressure drop between the pump and the actuator indicates a restriction or internal leakage.

## Common Problems and Fixes
- **Pump is noisy on startup:** Cavitation from a clogged suction strainer or low fluid level. Clean the strainer and check the fluid.
- **Cylinder is spongy:** Air in the system. Bleed the air by cycling the cylinder fully several times.
- **Pressure cannot be maintained:** The relief valve is leaking or the pump is worn. Check the relief valve and the pump output.
- **System runs hot:** Internal leakage or a failed cooler. Check the cooler and the component leakage.

## Best Practices and Field Tips
- Always start a hydraulic system with the relief valve at minimum pressure — a sudden full-pressure start can damage components.
- Install a pressure gauge at the pump discharge and at each major valve — the pressure profile tells you where the loss is.
- Trend the fluid temperature and the filter pressure drop — both indicate the system health.
- Keep the reservoir clean and covered — contamination is the leading cause of hydraulic component failure.

## Safety Notes
- Never start a hydraulic system with a valve shifted — an unexpected cylinder movement can cause injury or equipment damage.
- Accumulators store energy under pressure — never open a fitting without bleeding the accumulator pressure first.',
   quiz =
'[{"question":"Which pump type handles the highest pressures?","options":["Gear pump","Vane pump","Piston pump","Screw pump"],"correctIndex":2},{"question":"What does the relief valve do?","options":["Measures flow","Protects the system from overpressure — must be set above working pressure but below component rating","Sets the process pressure","Controls the pump speed"],"correctIndex":1},{"question":"How should a hydraulic system be started?","options":["At full pressure","With the relief valve backed off at minimum pressure, then bring pressure up slowly","With all valves shifted","With the pump at maximum speed"],"correctIndex":1},{"question":"What causes a spongy cylinder?","options":["Worn seals","Air in the system — bleed by cycling the cylinder fully several times","Low fluid level","High temperature"],"correctIndex":1},{"question":"What is the leading cause of hydraulic component failure?","options":["Overpressure","Contamination","Electrical faults","Vibration"],"correctIndex":1},{"question":"What must be done before opening a hydraulic fitting near an accumulator?","options":["Nothing","Bleed the accumulator pressure first — accumulators store energy under pressure","Increase the system pressure","Close the reservoir"],"correctIndex":1},{"question":"Why should a pressure gauge be installed at the pump discharge and at each major valve?","options":["For appearance","The pressure profile tells you where the loss is","It is required by code","To measure temperature"],"correctIndex":1}]'::jsonb
  WHERE title = 'Pumps, Valves & Actuators' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Most hydraulic failures trace to contamination — water, air, or particulate. Understanding the types of contamination, their symptoms, and the corrective actions is essential for maintaining reliable hydraulic systems.

## Key Concepts
- **Water contamination** appears as milky fluid. Sources: condensation in the reservoir (from humid air drawn in through the breather), a cooler leak (water-to-oil cooler), or a seal leak on a water-cooled cylinder.
- **Air contamination** appears as foamy fluid. Sources: a low reservoir level (the suction port draws air), a loose suction fitting, or a leaking pump shaft seal.
- **Particulate contamination** is the most damaging — abrasive particles score the valve spools and the cylinder bores. Sources: wear debris, built-in contamination from manufacturing, and dirty fluid added during top-off.
- **ISO 4406 cleanliness codes** target 20/18/15 for general industrial hydraulics; servo systems require cleaner fluid (18/16/13 or better).
- **Filter elements** should be changed on a schedule based on particle count, not just hours. A clogged filter bypasses and sends unfiltered fluid to the system.

## Step-by-Step: Hydraulic Fluid Contamination Diagnosis
1. **Observe the fluid in the reservoir:** Milky = water, foamy = air, dark/burnt = overheating, gritty = particles.
2. **If milky (water):** Check the breather desiccant, the cooler for internal leaks, and the cylinder seals on water-cooled cylinders. Change the fluid.
3. **If foamy (air):** Check the reservoir level (is the suction port above the fluid?), the suction fittings for leaks, and the pump shaft seal. Top off the fluid and tighten the fittings.
4. **If gritty (particles):** Sample the fluid for particle count. Check the filter bypass indicator. Change the filter and the fluid if the count exceeds the target.
5. **If dark/burnt:** Check the system temperature. Overheating degrades the fluid. Find and fix the heat source (internal leakage, restricted flow, failed cooler) and change the fluid.

## Common Problems and Fixes
- **Fluid is milky but no cooler leak found:** The source is condensation from humid air. Install or replace the breather desiccant. Change the fluid.
- **Fluid is clean but the valve still sticks:** The valve spool is scored from previous contamination. The valve must be replaced — clean fluid prevents future damage but does not repair existing damage.
- **Filter bypasses frequently:** The system has a high particle ingress rate. Check for a worn cylinder seal (cylinder drift introduces particles), a damaged breather, or dirty top-off fluid.
- **Fluid degrades quickly after change:** The system is running too hot. Find and fix the heat source before changing the fluid again.

## Best Practices and Field Tips
- Use a portable oil purifier (filter cart) to polish the fluid periodically — it removes water and particles without a full fluid change.
- Sample the fluid quarterly for particle count, water content, and viscosity. Trend the results.
- When adding fluid, use a filter transfer pump — pouring fluid from a drum introduces particles.
- Keep the reservoir breather clean and desiccated — it is the primary entry point for moisture and dust.

## Safety Notes
- Hydraulic fluid is slippery — clean up spills immediately.
- Some hydraulic fluids are biodegradable or fire-resistant — verify the type before disposal. Disposal of used hydraulic fluid is regulated.',
   quiz =
'[{"question":"What does milky hydraulic fluid indicate?","options":["Air entrainment","Water contamination","Wrong viscosity","Overheating"],"correctIndex":1},{"question":"What does foamy hydraulic fluid indicate?","options":["Water contamination","Air entrainment — often from a low reservoir level or a leaking suction line","Overheating","Wrong viscosity"],"correctIndex":1},{"question":"What is the ISO 4406 cleanliness target for general industrial hydraulics?","options":["22/20/17","20/18/15","18/16/13","14/12/11"],"correctIndex":1},{"question":"When should hydraulic filter elements be changed?","options":["Only when they fail","On a schedule based on particle count, not just hours","Annually","Every 5 years"],"correctIndex":1},{"question":"What is the most damaging type of hydraulic contamination?","options":["Water","Air","Particulate — abrasive particles score valve spools and cylinder bores","Heat"],"correctIndex":2},{"question":"What should be used when adding hydraulic fluid to the system?","options":["Pour directly from the drum","A filter transfer pump — pouring from a drum introduces particles","A funnel","Any container"],"correctIndex":1},{"question":"What is the primary entry point for moisture and dust in a hydraulic system?","options":["The pump seal","The reservoir breather","The relief valve","The cylinder seal"],"correctIndex":1}]'::jsonb
  WHERE title = 'Common Hydraulic Failures' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Pneumatic systems use compressed air — safer than hydraulics in terms of fluid spillage, but stored energy in receivers is still dangerous. Before servicing any fluid power system, lockout/tagout is mandatory. Understanding the LOTO procedure for fluid power is essential for safe maintenance.

## Key Concepts
- **Stored energy in pneumatic systems** includes: the receiver (a pressure vessel with stored compressed air), the lines (pressurized air in the distribution piping), and the cylinders (trapped air on both sides of the piston).
- **LOTO procedure for fluid power:** Isolate the supply, lock the valve, bleed the residual pressure to zero, and verify with a gauge. For pneumatic cylinders, confirm both ports are vented.
- **Never disconnect a pressurized hose** — the whip can cause serious injury. Always bleed the pressure first.
- **Three-way bleed-off valve:** A valve that safely dumps trapped energy from the system to atmosphere.
- **Gravity-loaded cylinders** will drop when the pressure is removed — block or pin the load before bleeding.

## Step-by-Step: LOTO for a Pneumatic System
1. **Identify all energy sources:** the compressed air supply, the receiver, any accumulators, and any spring-loaded or gravity-loaded actuators.
2. **Notify affected personnel** that the system is being isolated for maintenance.
3. **Isolate the supply:** Close the main air valve and apply a lock and a tag.
4. **Bleed the residual pressure:** Open the bleed valve at the end of the line and verify the pressure drops to zero on the gauge.
5. **Verify both cylinder ports are vented:** A cylinder can hold trapped air on the rod side even after the supply is off. Cycle the directional valve manually to release any trapped air.
6. **Block or pin any load** that could fall or move when the pressure is released — a gravity-loaded cylinder will drop.
7. **Verify zero energy:** Attempt to operate the cylinder — it should not move. If it does, there is a residual energy source that was not isolated.
8. **Apply locks to all isolation points** — each worker applies their own lock. Never share a lock.

## Common Problems and Fixes
- **Cylinder moves after LOTO:** Residual air is trapped in the cylinder. Re-bleed the cylinder ports by cycling the valve.
- **Pressure gauge reads zero but the line is still pressurized:** The gauge is faulty. Verify with a second gauge or by cracking a fitting (with PPE).
- **Load drops after bleeding:** The load was not blocked before bleeding. Block the load first, then bleed.
- **Receiver does not depressurize:** The receiver isolation valve is leaking through. Isolate the receiver separately and verify it does not re-pressurize.

## Best Practices and Field Tips
- Install a bleed valve at the end of every pneumatic line — it allows safe depressurization without disconnecting fittings.
- Use a lockout valve with a built-in bleed and a lock attachment — it combines isolation and verification in one device.
- Train all workers on the LOTO procedure for fluid power — fluid power LOTO is different from electrical LOTO and is often overlooked.
- Verify the receiver is depressurized before any maintenance — the receiver stores enough energy to be lethal.

## Safety Notes
- Never disconnect a pressurized hose — the whip can cause serious injury.
- A receiver is a pressure vessel — it must be inspected per the local pressure vessel code. An uninspected receiver can explode.
- Stored spring energy in a valve or an actuator can release suddenly — wear eye protection when disassembling.',
   quiz =
'[{"question":"What must be done before disconnecting a pneumatic hose?","options":["Tighten the fitting","Isolate supply and bleed pressure to zero","Reduce the compressor output","Cycle the cylinder to empty"],"correctIndex":1},{"question":"Why must both cylinder ports be vented during LOTO?","options":["For convenience","A cylinder can hold trapped air on the rod side even after the supply is off","It is required by code","To save air"],"correctIndex":1},{"question":"What must be done with a gravity-loaded cylinder before bleeding pressure?","options":["Nothing","Block or pin the load — it will drop when pressure is removed","Increase the pressure","Remove the load"],"correctIndex":1},{"question":"What should be done if a cylinder moves after LOTO?","options":["Re-bleed the cylinder ports by cycling the valve","Ignore it","Increase the lock pressure","Replace the cylinder"],"correctIndex":0},{"question":"Why is a receiver especially dangerous during maintenance?","options":["It is heavy","It stores enough energy to be lethal","It is hot","It contains oil"],"correctIndex":1},{"question":"What should be installed at the end of every pneumatic line for safe depressurization?","options":["A pressure gauge","A bleed valve","A flow meter","A filter"],"correctIndex":1},{"question":"How is fluid power LOTO different from electrical LOTO?","options":["It is the same","Fluid power requires bleeding stored energy from receivers, lines, and cylinders — not just isolating the source","Fluid power LOTO is simpler","Fluid power does not require LOTO"],"correctIndex":1}]'::jsonb
  WHERE title = 'Pneumatic Circuits & LOTO for Fluid Power' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 6. GEARBOXES & POWER TRANSMISSION =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Gearboxes & Power Transmission';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Gearbox Troubleshooting & Failure Prevention', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Noise, Vibration & Temperature Diagnosis',
   '## Overview
Gearbox noise, vibration, and temperature are the three primary indicators of gearbox health. Each symptom points to specific failure modes, and learning to interpret them is the core skill of gearbox troubleshooting.

## Key Concepts
- **Whine** (high-pitched, constant): Gear mesh issue — typically from gear wear, pitting, or incorrect backlash. The frequency matches the gear mesh frequency (number of teeth × RPM).
- **Knock** (irregular, heavy): Bearing damage or a broken tooth. A broken tooth produces a knock once per revolution.
- **Rumble** (broadband, rough): General wear across multiple gears and bearings. The gearbox is near end of life.
- **Temperature rise:** A 15°C rise above baseline warrants investigation. Causes include overloading, low oil, wrong oil viscosity, or a failing cooling system.
- **Vibration spectrum:** 1x RPM indicates imbalance (rare on gearboxes), 2x indicates misalignment (between the motor and the gearbox input), gear mesh frequency indicates gear wear, and bearing defect frequencies indicate bearing degradation.

## Step-by-Step: Gearbox Noise and Vibration Diagnosis
1. **Listen to the gearbox** while it is running at normal load. Characterize the noise: whine, knock, rumble, or a combination.
2. **If whine:** Check the gear mesh frequency in the vibration spectrum. A high amplitude at the mesh frequency with sidebands indicates gear wear. Check the backlash if accessible.
3. **If knock:** Check for a broken tooth by inspecting through the inspection cover (if equipped) or by performing a tooth contact check with bluing.
4. **If rumble:** The gearbox has general wear. Sample the oil for wear metals — high iron confirms general wear. Plan a gearbox rebuild or replacement.
5. **Measure the temperature** at the housing and compare to baseline. A 15°C rise warrants investigation.
6. **Take a vibration spectrum** at the bearing housings in the radial and axial directions. Compare to the previous spectrum to identify new peaks.

## Common Problems and Fixes
- **Gearbox whines after oil change:** The wrong oil viscosity was used. Check the OEM specification and replace with the correct grade.
- **Gearbox overheats after installation:** The oil level is too high (churning) or too low (insufficient cooling). Check the level.
- **Gearbox knocks under load but not at idle:** A gear tooth is cracked or chipped. Inspect the gears at the next opportunity.
- **Vibration increases over time:** Bearing wear or gear wear. Trend the vibration and the oil analysis to plan the repair before failure.

## Best Practices and Field Tips
- Record the baseline noise and vibration at commissioning — you cannot diagnose a change without a baseline.
- Trend the oil temperature, the vibration overall, and the wear metals together — a change in all three confirms a developing problem.
- Install a vibration sensor on critical gearboxes for continuous monitoring — a rising trend alerts the maintenance team before failure.
- For gearboxes without inspection covers, the oil analysis is the only internal health indicator — sample quarterly.

## Safety Notes
- Never open an inspection cover while the gearbox is running — rotating gears can catch hands and tools.
- Hot gearbox oil can cause burns — allow the gearbox to cool before opening any cover.',
   50, 1,
   '[{"question":"What does a gearbox whine typically indicate?","options":["Bearing damage","Gear mesh issue — gear wear, pitting, or incorrect backlash","Low oil","Overload"],"correctIndex":1},{"question":"What does a gearbox knock (irregular, heavy) indicate?","options":["Gear mesh issue","Bearing damage or a broken tooth","Low oil","Normal operation"],"correctIndex":1},{"question":"What temperature rise above baseline warrants investigation?","options":["5°C","15°C","30°C","50°C"],"correctIndex":1},{"question":"What does a gearbox whine after an oil change indicate?","options":["Normal — the new oil is different","The wrong oil viscosity was used — check the OEM specification","The oil level is too high","The gearbox is wearing in"],"correctIndex":1},{"question":"What does a rumble (broadband, rough noise) indicate?","options":["Early gear wear","General wear across multiple gears and bearings — the gearbox is near end of life","Bearing damage only","Normal operation"],"correctIndex":1},{"question":"What should be recorded at commissioning for future diagnosis?","options":["Only the oil type","The baseline noise and vibration — you cannot diagnose a change without a baseline","Only the temperature","Only the oil level"],"correctIndex":1},{"question":"What should be trended together for the most reliable gearbox health assessment?","options":["Only vibration","Oil temperature, vibration overall, and wear metals together","Only oil analysis","Only temperature"],"correctIndex":1}]'::jsonb),
  (m_id, 'Gearbox Repair, Rebuild & Commissioning',
   '## Overview
When a gearbox fails or reaches the end of its service life, a repair or rebuild is required. Understanding the rebuild procedure, the critical measurements, and the commissioning steps ensures the rebuilt gearbox performs as well as a new one.

## Key Concepts
- **Backlash** is the clearance between mating gear teeth. Excessive backlash causes impact loading and noise; insufficient backlash causes binding and overheating. The correct backlash is specified by the OEM and is typically 0.05-0.15 mm for industrial gearboxes.
- **Tooth contact pattern** is checked with bluing — a centered, even pattern across 75-90% of the tooth face indicates correct meshing. A pattern biased to one end or to the root/toe indicates misalignment.
- **Bearing pre-load** must be set correctly — too much pre-load overheats the bearing; too little allows the gear to float, causing uneven tooth contact.
- **Run-in procedure:** A rebuilt gearbox should be run at no-load for 1-2 hours, then at 50% load for 2-4 hours, then at full load. Check the temperature, the noise, and the oil condition at each stage.

## Step-by-Step: Gearbox Rebuild and Commissioning
1. **Disassemble the gearbox** in a clean environment. Tag each gear and bearing with its position.
2. **Inspect each component:** Check gears for pitting, spalling, and cracking. Check bearings for wear, corrosion, and cage damage. Check the shafts for runout and journal wear.
3. **Replace all bearings** — do not reuse bearings from a failed gearbox, even if they look good.
4. **Reassemble with the correct backlash:** Measure the backlash with a dial indicator on the gear tooth. Adjust the bearing position with shims to achieve the specified backlash.
5. **Check the tooth contact pattern** with bluing: apply bluing to the teeth, rotate the gears, and inspect the contact pattern. Adjust the shims if the pattern is off.
6. **Fill with the correct oil** and verify the level.
7. **Run-in:** Run at no-load for 1-2 hours, then 50% load for 2-4 hours, then full load. Monitor the temperature, noise, and oil condition at each stage. The temperature should stabilize within 10°C of baseline.
8. **Document the rebuild** with the components replaced, the backlash measurements, the contact pattern photo, and the run-in results.

## Common Problems and Fixes
- **Rebuilt gearbox overheats during run-in:** Bearing pre-load is too high, or the backlash is too tight. Re-check the pre-load and the backlash.
- **Rebuilt gearbox is noisy:** The backlash is incorrect, or the tooth contact pattern is off. Re-check the contact pattern and adjust the shims.
- **Oil leaks after rebuild:** The seals were damaged during installation, or the breather is clogged. Replace the seals and the breather.
- **Gearbox fails shortly after rebuild:** A bearing was installed incorrectly (wrong orientation, pressed on the wrong race), or the backlash was not set correctly.

## Best Practices and Field Tips
- Always replace all bearings during a rebuild — reusing bearings is the most common cause of premature rebuild failure.
- Document the backlash and the contact pattern with photos — it provides a baseline for the next rebuild.
- Use the OEM oil or a verified equivalent — the wrong oil viscosity is a common cause of rebuild failure.
- If the gearbox has a forced lubrication system (oil pump), verify the pump output and the oil pressure at the furthest bearing before starting the gearbox.

## Safety Notes
- Never assemble a gearbox with the wrong tools — a hammer or a pry bar damages the components. Use bearing heaters, pullers, and torque wrenches.
- A gearbox under test can fail catastrophically — stand clear of the coupling and the inspection covers during the run-in.',
   55, 2,
   '[{"question":"What is the typical backlash for an industrial gearbox?","options":["0.005-0.015 mm","0.05-0.15 mm","0.5-1.5 mm","5-15 mm"],"correctIndex":1},{"question":"What does a tooth contact pattern biased to one end indicate?","options":["Normal wear","Misalignment — adjust the shims","Overload","Insufficient lubrication"],"correctIndex":1},{"question":"Why should all bearings be replaced during a gearbox rebuild?","options":["They are cheap","Reusing bearings is the most common cause of premature rebuild failure","It is required by code","They are difficult to inspect"],"correctIndex":1},{"question":"What is the run-in procedure for a rebuilt gearbox?","options":["Full load immediately","No-load 1-2 hours, 50% load 2-4 hours, then full load","No run-in needed","Run at full speed for 10 minutes"],"correctIndex":1},{"question":"What does a rebuilt gearbox that overheats during run-in indicate?","options":["Normal break-in","Bearing pre-load is too high, or the backlash is too tight","The oil is the wrong color","The ambient temperature is high"],"correctIndex":1},{"question":"What should be documented during a gearbox rebuild?","options":["Only the oil type","Components replaced, backlash measurements, contact pattern photo, and run-in results","Only the date","Only the serial number"],"correctIndex":1},{"question":"What should be verified before starting a gearbox with forced lubrication?","options":["Nothing","The pump output and the oil pressure at the furthest bearing","Only the oil level","Only the oil type"],"correctIndex":1}]'::jsonb);

  -- New module 4
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Variable Speed Drives & Power Transmission Efficiency', 4) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'VFD-Driven Gearbox Considerations',
   '## Overview
When a gearbox is driven by a VFD instead of a fixed-speed motor, the operating conditions change significantly. The gearbox may operate at lower speeds (reducing cooling and lubrication effectiveness) or at higher speeds (increasing loads). Understanding these considerations is essential for reliable VFD-driven gearbox operation.

## Key Concepts
- **Cooling at low speed:** A gearbox with a splash lubrication system may not splash enough oil at low speed, causing the gears and bearings to run dry. Below 50% of rated speed, consider a forced lubrication system (oil pump).
- **Over-speed risk:** Running a gearbox above its rated speed increases the gear mesh forces, the bearing loads, and the oil churning heat. Verify the gearbox is rated for the maximum speed the VFD will command.
- **Breakaway torque:** A VFD can deliver 100% torque at zero speed, which can be higher than the gearbox is designed for. Verify the gearbox torque rating exceeds the VFD maximum torque.
- **Resonance:** A VFD-driven gearbox may pass through a structural resonance at a specific speed, causing high vibration. Identify the resonant speed and program the VFD to skip that frequency.
- **Motor bearing currents:** VFD PWM output can cause bearing currents that damage the motor bearings and, through the coupling, the gearbox bearings. Use a shaft grounding ring and insulated bearings.

## Step-by-Step: Evaluating a Gearbox for VFD Operation
1. **Verify the gearbox speed range** is compatible with the VFD output range. Check the minimum speed for lubrication and the maximum speed for gear and bearing loads.
2. **Check the lubrication system:** If the gearbox uses splash lubrication, verify it will function at the minimum operating speed. If not, install a forced lubrication system.
3. **Verify the torque rating:** The gearbox torque rating must exceed the VFD maximum torque (which can be 100% at zero speed).
4. **Check for resonance:** Run the gearbox through the speed range with no load and measure the vibration. Identify any resonant speeds and program the VFD to skip them.
5. **Install VFD-rated motor bearings:** Use insulated bearings on the non-drive end and a shaft grounding ring to prevent bearing current damage to the motor and the gearbox.

## Common Problems and Fixes
- **Gearbox overheats at low speed:** The splash lubrication is insufficient at low speed. Install a forced lubrication system or raise the minimum speed.
- **Gearbox vibration at a specific speed:** Structural resonance. Program the VFD to skip the resonant speed.
- **Motor bearing failure on a VFD-driven gearbox:** Bearing currents from the VFD PWM. Install a shaft grounding ring and insulated bearings.
- **Gearbox seal leaks after VFD installation:** The VFD changed the operating speed and temperature profile, causing the seal to operate outside its design. Replace the seal with one rated for the new conditions.

## Best Practices and Field Tips
- Always verify the gearbox is rated for the full VFD speed range before commissioning — a gearbox designed for fixed speed may not survive variable speed operation.
- Monitor the gearbox temperature across the speed range — the temperature profile may be different from the fixed-speed operation.
- For VFD-driven gearboxes that operate at very low speed, consider an oil heater to maintain the oil viscosity at startup.

## Safety Notes
- A VFD can start the motor at full torque from zero speed — ensure the coupling is secure and the load is safe to move before starting.',
   50, 1,
   '[{"question":"What happens to splash lubrication at low VFD speed?","options":["It improves","It may not splash enough oil, causing gears and bearings to run dry","Nothing changes","The oil foams"],"correctIndex":1},{"question":"At what speed should forced lubrication be considered for a splash-lubricated gearbox?","options":["Below 90% of rated speed","Below 50% of rated speed","Below 10% of rated speed","Never"],"correctIndex":1},{"question":"What can a VFD deliver at zero speed that may exceed the gearbox design?","options":["100% torque","200% torque","Zero torque","50% torque"],"correctIndex":0},{"question":"What should be done if a gearbox vibrates at a specific VFD speed?","options":["Replace the gearbox","Program the VFD to skip the resonant speed","Increase the speed","Reduce the load"],"correctIndex":1},{"question":"What causes motor bearing failure on a VFD-driven gearbox?","options":["Overload","Bearing currents from the VFD PWM output","Insufficient lubrication","Over-speed"],"correctIndex":1},{"question":"What should be installed to prevent bearing current damage?","options":["A larger motor","A shaft grounding ring and insulated bearings","A larger coupling","A cooler"],"correctIndex":1},{"question":"What should be verified before commissioning a VFD-driven gearbox?","options":["Nothing — VFDs are compatible with all gearboxes","The gearbox is rated for the full VFD speed range — a fixed-speed gearbox may not survive variable speed","The motor voltage","The oil color"],"correctIndex":1}]'::jsonb),
  (m_id, 'Power Transmission Efficiency & Energy Loss',
   '## Overview
Every power transmission component — gearbox, coupling, belt, chain — loses some energy to heat. Understanding where the losses occur and how to minimize them reduces the energy cost and the operating temperature, extending the equipment life.

## Key Concepts
- **Gearbox efficiency:** Helical gearbox 95-98% per reduction, worm gearbox 50-90% (depending on ratio), planetary gearbox 95-97% per reduction. A double-reduction gearbox multiplies the per-stage loss.
- **Coupling loss:** Minimal for gear and grid couplings (friction in the element), but elastomeric couplings have hysteresis loss in the rubber element that generates heat.
- **Belt drive loss:** V-belt 95-98% (friction slip), timing belt 97-99% (positive engagement). A slipping V-belt loses energy and generates heat.
- **Chain drive loss:** 97-99% (friction at the pin and bushing). A worn chain with elongated pins loses more energy.
- **Total system efficiency** is the product of all component efficiencies: motor × coupling × gearbox × coupling × driven equipment. A 95% motor × 98% coupling × 95% gearbox × 98% coupling = 86.5% total.

## Step-by-Step: Energy Loss Audit
1. **List all power transmission components** in the drive train: motor, couplings, gearbox, belts or chains, driven equipment.
2. **Estimate the efficiency** of each component from the OEM data or from standard tables.
3. **Calculate the total system efficiency** as the product of all component efficiencies.
4. **Identify the largest loss:** The component with the lowest efficiency is the largest energy user. For a worm gearbox system, the gearbox is the largest loss.
5. **Evaluate upgrade options:** Replace a worm gearbox with a helical gearbox (saves 20-40% of the gearbox loss), replace a V-belt with a timing belt (saves 2-3%), or replace a worn chain (saves 2-3%).
6. **Calculate the annual energy savings:** (loss reduction in kW) × (operating hours per year) × (electricity rate). For a 10 kW loss reduction at 8000 hours and $0.10/kWh, the savings is $8,000 per year.

## Common Problems and Fixes
- **Worm gearbox overheats:** The worm gearbox is inherently inefficient (50-90%). Add a cooling fan or replace with a helical gearbox.
- **V-belt slips and generates heat:** The belt is under-tensioned or the lagging is worn. Increase the tension or re-lag the pulley.
- **Chain drive loses energy:** The chain is worn (elongated). Replace the chain and the sprocket.
- **System efficiency is lower than calculated:** A component is degraded (worn gearbox, slipping belt, worn bearing). Measure the actual power input and output to find the degraded component.

## Best Practices and Field Tips
- Calculate the total system efficiency during the design phase — a 10% loss in a 50 kW system costs $4,000 per year.
- Trend the motor amperage — a rising amperage with constant output indicates increasing system loss.
- For high-efficiency upgrades, prioritize the component with the lowest efficiency — the worm gearbox is usually the biggest opportunity.
- An infrared camera can find the hottest component, which is the largest energy loss point.

## Safety Notes
- An overheating gearbox or coupling can be a fire hazard — investigate any temperature above 80°C at the housing.',
   50, 2,
   '[{"question":"What is the efficiency range of a worm gearbox?","options":["95-98%","50-90%","80-85%","90-95%"],"correctIndex":1},{"question":"How is total system efficiency calculated?","options":["Sum of all component efficiencies","Product of all component efficiencies","Average of all component efficiencies","The lowest component efficiency"],"correctIndex":1},{"question":"Which component is usually the biggest efficiency improvement opportunity?","options":["The motor","The worm gearbox","The coupling","The chain"],"correctIndex":1},{"question":"What does a rising motor amperage with constant output indicate?","options":["Improved efficiency","Increasing system loss — a component is degraded","Normal operation","The motor is oversized"],"correctIndex":1},{"question":"What can an infrared camera identify in a power transmission system?","options":["The speed","The hottest component, which is the largest energy loss point","The voltage","The torque"],"correctIndex":1},{"question":"What is the efficiency of a V-belt drive?","options":["50-60%","95-98%","80-85%","90-95%"],"correctIndex":1},{"question":"How much energy does a 10 kW loss reduction save per year at 8000 hours and $0.10/kWh?","options":["$800","$8,000","$80,000","$800,000"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons with structured content and expanded quizzes
  UPDATE lessons SET content =
'## Overview
Industrial gearboxes transmit power while reducing speed and increasing torque. Selecting the correct gearbox type for the application determines the efficiency, the reliability, and the maintenance requirements. This lesson covers the major gearbox families and the selection criteria.

## Key Concepts
- **Helical gears** run quieter than spur gears because the angled teeth engage gradually, but they produce axial thrust that requires bearings to handle the load.
- **Bevel gears** change the direction of power transmission, typically 90 degrees. Spiral bevel gears run quieter and carry more load than straight bevel gears.
- **Worm gears** offer high reduction ratios in a single stage and are self-locking — the load cannot drive the worm. But they are inefficient (50-90%) and generate significant heat.
- **Planetary gearboxes** pack high reduction into a compact envelope by using multiple planet gears around a sun gear, distributing load and achieving high torque density.
- **Service factor** (typically 1.0-1.5 for uniform loads, 2.0+ for shock loads) must match the application. An undersized service factor leads to premature failure.

## Step-by-Step: Gearbox Selection
1. **Determine the required ratio** (input speed / output speed) and the required output torque.
2. **Select the gearbox type** based on the ratio, the efficiency requirement, and the space constraint: helical for general purpose, worm for high ratio in one stage, planetary for compact high-torque.
3. **Calculate the required input power:** Power = (output torque × output speed) / (efficiency × 9550).
4. **Select the service factor** based on the load type: 1.0-1.5 for uniform, 1.5-2.0 for moderate shock, 2.0-3.0 for heavy shock.
5. **Verify the thermal capacity** is adequate for the operating temperature and the duty cycle. A gearbox within its mechanical rating but above its thermal rating will overheat.
6. **Select the lubricant** per the OEM specification for the operating temperature and speed.

## Common Problems and Fixes
- **Gearbox overheats despite correct oil level:** The service factor is too low for the actual load, or the gearbox is above its thermal rating. Select a larger gearbox or add cooling.
- **Worm gearbox is too hot:** Worm gearboxes are inherently inefficient. Add a cooling fan or select a helical gearbox instead.
- **Planetary gearbox is noisy:** The planet carrier bearing is worn, or the planet gears are worn. Inspect and replace the bearings or the gears.

## Best Practices and Field Tips
- Always verify the service factor matches the actual load — a gearbox selected with a low service factor for a shock load will fail prematurely.
- For applications with limited space, a planetary gearbox provides the highest torque density.
- For high-ratio applications (50:1 or more), a worm gearbox is the simplest choice but consider a two-stage helical for better efficiency.
- Document the selection criteria (ratio, torque, service factor, thermal capacity) for each gearbox to support future replacement decisions.

## Safety Notes
- Never operate a gearbox above its rated speed or torque — the gears can fail catastrophically.
- Hot gearbox surfaces can cause burns — install guards on accessible surfaces.',
   quiz =
'[{"question":"Why do helical gears run quieter than spur gears?","options":["They use softer materials","The angled teeth engage gradually","They have more teeth","They run at lower speeds"],"correctIndex":1},{"question":"Which gearbox type is self-locking?","options":["Helical","Bevel","Worm","Planetary"],"correctIndex":2},{"question":"What is the efficiency range of a worm gearbox?","options":["95-98%","50-90%","80-85%","90-95%"],"correctIndex":1},{"question":"What service factor is typical for heavy shock loads?","options":["1.0","1.5","2.0-3.0","5.0"],"correctIndex":2},{"question":"What happens if a gearbox is within its mechanical rating but above its thermal rating?","options":["It runs fine","It overheats and fails","It runs quieter","Nothing"],"correctIndex":1},{"question":"Which gearbox type provides the highest torque density in a compact envelope?","options":["Helical","Worm","Planetary","Bevel"],"correctIndex":2},{"question":"What should be verified during gearbox selection for a shock load application?","options":["Only the ratio","The service factor matches the actual load — a low service factor leads to premature failure","The color","The brand"],"correctIndex":1}]'::jsonb
  WHERE title = 'Helical, Bevel, Worm & Planetary Gearboxes' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Gearbox oil serves two functions: lubricate the tooth mesh and carry heat away from the gears. The breather allows the gearbox to breathe as the oil heats and cools. Both are critical to gearbox reliability, and both are frequently neglected.

## Key Concepts
- **ISO VG 220 and 320** are common industrial gear oil viscosities, but always follow the OEM recommendation for the operating temperature and speed.
- **Synthetic oils** (PAO, PAG) handle higher temperatures and longer drain intervals than mineral oils. They also have better low-temperature fluidity.
- **The breather** is the most neglected component — a clogged breather pressurizes the case as the oil heats and expands, forcing oil past the shaft seals.
- **The magnetic drain plug** captures ferrous wear particles. A heavy accumulation indicates active gear or bearing wear.
- **Oil analysis** (wear metals, water, viscosity) is the most effective gearbox health monitoring tool — it detects problems months before vibration develops.

## Step-by-Step: Gearbox Oil and Breather Maintenance
1. **Check the oil level** with the dipstick or sight glass. Low oil indicates a leak; overfull indicates the wrong oil was added or water has entered.
2. **Check the oil condition** visually: milky = water, burnt = overheating, gritty = particles. Smell the oil — a burnt smell confirms overheating.
3. **Inspect the breather** — clean or replace if clogged. A clogged breather is the most common cause of gearbox oil leaks.
4. **Check the magnetic drain plug** for metal particles. A heavy accumulation indicates active wear.
5. **Sample the oil** for lab analysis: wear metals (Fe, Cu, Cr), water content (Karl Fischer), viscosity, and particle count.
6. **Change the oil** at the OEM interval or based on oil analysis. Replace the breather at every oil change.

## Common Problems and Fixes
- **Oil leaks from the shaft seals:** The breather is clogged, pressurizing the case. Replace the breather and check the seals.
- **Oil is milky:** Water ingress from a breather fault, a seal leak, or a cooler leak. Replace the breather, check the seals, and change the oil.
- **Oil is burnt:** Overheating from overloading or low oil. Check the load, the oil level, and the cooling. Change the oil.
- **Iron (Fe) is rising in the oil analysis:** Gear or bearing wear. Schedule a gearbox inspection at the next outage.

## Best Practices and Field Tips
- Sample the oil quarterly and trend the results — a single sample is data; a trend is information.
- Replace the breather at every oil change — it is the cheapest and most neglected maintenance item.
- Use the OEM oil or a verified equivalent — the wrong oil viscosity is a common cause of gearbox failure.
- For gearboxes in dirty environments, use a desiccant breather to prevent moisture and dust ingress.

## Safety Notes
- Hot gearbox oil can cause burns — allow the gearbox to cool before opening the drain or the inspection cover.
- Used oil is an environmental hazard — dispose of it through an approved waste oil service.',
   quiz =
'[{"question":"What are the two functions of gearbox oil?","options":["Cooling and cleaning","Lubricate the tooth mesh and carry heat away from the gears","Sealing and noise reduction","Corrosion prevention only"],"correctIndex":1},{"question":"What does a clogged gearbox breather cause?","options":["Low oil level","Case pressurization and oil leaks past the seals","Improved lubrication","Reduced operating temperature"],"correctIndex":1},{"question":"What does milky gearbox oil indicate?","options":["Overloading","Water ingress","Oxidation","Wrong lubricant grade"],"correctIndex":1},{"question":"What does a rising iron (Fe) trend in gearbox oil analysis indicate?","options":["Normal wear","Active gear or bearing wear","Water contamination","Oil oxidation"],"correctIndex":1},{"question":"When should the breather be replaced?","options":["Every 5 years","At every oil change","Only when it fails","Never"],"correctIndex":1},{"question":"What type of breather should be used in dirty environments?","options":["A standard breather","A desiccant breather to prevent moisture and dust ingress","No breather","A larger breather"],"correctIndex":1},{"question":"What does a heavy accumulation on the magnetic drain plug indicate?","options":["Normal wear","Active gear or bearing wear","Water contamination","The oil is the wrong grade"],"correctIndex":1}]'::jsonb
  WHERE title = 'Oil Selection & Breather Maintenance' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Gear tooth failures fall into distinct categories, each with a characteristic appearance and a specific root cause. Recognizing the failure mode on a removed gear tells you what went wrong and how to prevent it on the replacement.

## Key Concepts
- **Macropitting (fatigue):** Flakes of metal removed from the tooth surface after millions of load cycles — the contact stress exceeds the material endurance limit.
- **Micropitting:** Frosted, gray patches from inadequate lubricant film thickness — the oil film is too thin for the load and speed.
- **Scuffing:** The lubricant film breaks down and metal-to-metal contact welds and tears the surface — from overload, insufficient oil, or wrong viscosity.
- **Tooth fracture:** Catastrophic, from shock load or a brittle material. The tooth breaks at the root where the stress is highest.
- **Tooth contact pattern** is checked with bluing: a centered, even pattern across 75-90% of the tooth face indicates correct meshing; a biased pattern indicates misalignment.

## Step-by-Step: Gear Tooth Inspection
1. **Remove the inspection cover** (if equipped) or disassemble the gearbox.
2. **Clean the gear teeth** with solvent and a brush to expose the surface.
3. **Inspect each tooth** for macropitting, micropitting, scuffing, and cracking. Use a magnifying glass or a borescope for small gears.
4. **Check the tooth contact pattern** with bluing: apply bluing to 3-4 teeth, rotate the gear, and inspect the transferred pattern on the mating gear.
5. **Measure the backlash** with a dial indicator on the tooth face. Compare to the OEM specification.
6. **Document the failure mode** with photographs and a written description.

## Common Problems and Fixes
- **Macropitting on one gear only:** The gear material is below spec, or the load is unevenly distributed (misalignment). Check the contact pattern and the material spec.
- **Scuffing after oil change:** The new oil has insufficient film strength for the load. Use the OEM-specified oil with the correct viscosity.
- **Tooth fracture at the root:** Shock load or material defect. Investigate the load condition (was there a jam?) and the material spec.
- **Micropitting across all teeth:** The oil film is too thin for the operating conditions. Use a higher-viscosity oil or a synthetic with higher film strength.

## Best Practices and Field Tips
- Photograph every gear failure and keep a reference set for training — a picture is worth a thousand words in failure analysis.
- The location of the damage tells you the direction of the excess load: pitting at the toe (small end) indicates misalignment; pitting at the pitch line indicates normal fatigue.
- Compare the backlash to the previous measurement — increasing backlash indicates gear wear.
- If the contact pattern cannot be checked (no inspection cover), the oil analysis is the primary health indicator.

## Safety Notes
- Never rotate a gear by hand with another person''s fingers in the mesh — the gear can pinch and amputate.
- Wear cut-resistant gloves when handling gears — the tooth tips are sharp.',
   quiz =
'[{"question":"What does macropitting indicate?","options":["Inadequate lubrication","Contact stress exceeds the material endurance limit","Shock loading","Wrong oil viscosity"],"correctIndex":1},{"question":"What does scuffing indicate?","options":["Normal wear","The lubricant film broke down and metal-to-metal contact welded and tore the surface","Over-speed","Corrosion"],"correctIndex":1},{"question":"What does a tooth contact pattern biased to one end indicate?","options":["Normal wear","Misalignment","Overload","Inadequate lubrication"],"correctIndex":1},{"question":"What percentage of tooth face should the contact pattern cover for correct meshing?","options":["25-50%","50-75%","75-90%","100%"],"correctIndex":2},{"question":"What does micropitting (frosted gray patches) indicate?","options":["Overload","Inadequate lubricant film thickness for the load and speed","Corrosion","Material defect"],"correctIndex":1},{"question":"What does tooth fracture at the root typically indicate?","options":["Normal fatigue","Shock load or a brittle material","Inadequate lubrication","Over-speed"],"correctIndex":1},{"question":"What should be done if scuffing appears after an oil change?","options":["Break in the gears","The new oil has insufficient film strength — use the OEM-specified oil with the correct viscosity","Reduce the load","Increase the speed"],"correctIndex":1}]'::jsonb
  WHERE title = 'Gear Tooth Failure Modes & Inspection' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 7. FANS, BLOWERS & AIR HANDLING SYSTEMS =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Fans, Blowers & Air Handling Systems';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Fan System Troubleshooting & Performance', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Fan Performance Testing & System Effects',
   '## Overview
Fan performance testing verifies that the fan is delivering the required flow and pressure. A fan that is on the curve but the system is not getting enough air has a system effect problem — the ductwork, the filters, or the dampers are restricting the flow. Understanding how to test fan performance and diagnose system effects is essential for maintaining air-handling systems.

## Key Concepts
- **Fan performance** is measured by the flow (CFM) and the static pressure (in. w.c.) at the fan inlet and outlet. The operating point is where the fan curve intersects the system curve.
- **System effects** are performance penalties from non-ideal ductwork: a sharp elbow at the fan outlet, a missing inlet cone, or a restricted intake. A system effect reduces the effective fan capacity by 10-30%.
- **Amperage** is proportional to the fan load: high amperage at low flow indicates the fan is fighting a restriction; low amperage at high flow indicates a worn impeller or housing clearance.
- **Static pressure measurement** at the fan inlet and outlet tells you the fan is developing the required pressure. A low static pressure with high flow indicates the system has less resistance than designed (a duct is disconnected or a damper is open).

## Step-by-Step: Fan Performance Test
1. **Measure the flow** at a straight duct section using a Pitot tube traverse or an anemometer. Take readings at multiple points across the duct and average them.
2. **Measure the static pressure** at the fan inlet and outlet using a manometer. The difference is the fan static pressure.
3. **Measure the motor amperage** with a clamp meter and compare to the nameplate FLA.
4. **Plot the operating point** (flow, static pressure) on the fan curve. If the point is on the curve, the fan is healthy. If below the curve, the fan is worn or the system effect is reducing capacity.
5. **Check the system effects:** Inspect the ductwork for sharp elbows near the fan, missing inlet cones, and restricted intakes. Correct any system effect issues.
6. **Compare the actual flow to the design requirement** — if the flow is adequate, the system is fine; if not, investigate the system resistance (filters, dampers, duct leaks).

## Common Problems and Fixes
- **Fan is on the curve but the system is not getting enough air:** A system effect (sharp elbow, missing inlet cone) is reducing the effective capacity. Correct the ductwork.
- **Fan is below the curve:** The impeller or housing is worn (increased clearance), or the fan is running backward (wrong rotation). Check the rotation and the impeller.
- **Fan amperage is high but the flow is low:** The fan is fighting a restriction (clogged filter, closed damper). Check the system.
- **Fan amperage is low but the flow is high:** The system resistance is lower than designed (disconnected duct, open damper). Check the system.

## Best Practices and Field Tips
- Install a static pressure tap at the fan inlet and outlet for permanent monitoring — a trend reveals developing restrictions.
- Install a differential pressure sensor across the filter and trend it — a rising pressure drop indicates a clogging filter.
- For VFD-driven fans, verify the fan curve at the actual operating speed — the curve shifts with speed per the affinity laws.
- Clean the impeller and housing during every PM — even a thin dust layer reduces the fan efficiency and shifts the balance.

## Safety Notes
- Never measure flow at a fan inlet without a guard — the suction can pull in tools, clothing, and hair.
- High-speed fans can throw a broken impeller blade — never stand in the plane of rotation during testing.',
   55, 1,
   '[{"question":"What are system effects in fan installations?","options":["Electrical interference","Performance penalties from non-ideal ductwork — sharp elbows, missing inlet cones, restricted intakes","Fan vibration","Motor overload"],"correctIndex":1},{"question":"How much can a system effect reduce effective fan capacity?","options":["1-5%","10-30%","50-80%","100%"],"correctIndex":1},{"question":"What does high motor amperage at low flow indicate?","options":["Normal operation","The fan is fighting a restriction (clogged filter, closed damper)","The fan is oversized","The motor is failing"],"correctIndex":1},{"question":"What does a fan operating below the curve indicate?","options":["Normal wear","The impeller or housing is worn (increased clearance), or the fan is running backward","The system is fine","The motor is oversized"],"correctIndex":1},{"question":"Where should static pressure taps be installed for permanent monitoring?","options":["At the motor","At the fan inlet and outlet","At the filter only","At the damper"],"correctIndex":1},{"question":"What does a rising differential pressure across a filter indicate?","options":["The filter is clean","The filter is clogging","The fan is failing","Normal operation"],"correctIndex":1},{"question":"Why should the impeller be cleaned during every PM?","options":["For appearance","Even a thin dust layer reduces fan efficiency and shifts the balance","To reduce noise","It is required by code"],"correctIndex":1}]'::jsonb),
  (m_id, 'Bearing Failure & Belt Drive Maintenance for Fans',
   '## Overview
Fan bearings and belt drives are the two most common failure points on industrial fans. Understanding the failure modes and the maintenance procedures for each is essential for keeping air-handling systems running reliably.

## Key Concepts
- **Fan bearing types:** Roller bearings on the drive end (radial load), ball bearing on the non-drive end (axial positioning). The non-drive bearing is often floating to allow thermal expansion.
- **Bearing failure modes:** Over-lubrication (blows seals, churning heat), under-lubrication (dry running, wear), contamination (dust ingress), and misalignment (uneven loading).
- **V-belt drives on fans:** The belt transmits power from the motor to the fan shaft. Common issues: under-tensioning (slip), over-tensioning (bearing overload), misalignment (belt wear), and worn sheaves (belt riding up the groove).
- **Belt replacement:** Always replace belts as a matched set — belts from different manufacturing lots have slightly different lengths, causing the shorter belt to carry all the load.
- **Sheave alignment:** Misalignment of more than 0.5 degrees per foot of center distance causes the belt to ride up the groove wall, wear one side, and shed tension.

## Step-by-Step: Fan Bearing and Belt Drive PM
1. **Listen to the bearings** while the fan is running: smooth hum = healthy, rumble = wear, squeal = dry running.
2. **Check the bearing temperature** with an infrared gun — a bearing running 20-30°C above the adjacent bearing is in distress.
3. **Grease the bearing** using the acoustic lubrication method (ultrasound gun) — stop when the dB stabilizes.
4. **Check the belt tension** by pressing at mid-span with a specified deflection force — the deflection should be 1/64 of the span length.
5. **Check the sheave alignment** with a straightedge across the machined faces — a gap indicates misalignment.
6. **Inspect the belts for wear** — cracked edges, glazing, or fraying indicate the belts need replacement.
7. **Inspect the sheaves for wear** — a worn groove (shiny at the bottom, ridged sides) indicates the sheave needs replacement.

## Common Problems and Fixes
- **Bearing runs hot after greasing:** Over-greasing. Remove the drain plug and let the excess purge, or run the fan until it cools.
- **Belt squeals on startup:** Under-tensioning. Increase the belt tension.
- **Belt runs hot and fails quickly:** Over-tensioning or misalignment. Reduce the tension and align the sheaves.
- **Belt wears on one side only:** Sheave misalignment. Align the sheaves with a straightedge.
- **Bearing fails repeatedly:** Check the fan balance (a vibrating fan loads the bearings), the alignment (misalignment loads the bearings), and the lubrication (over or under-greasing).

## Best Practices and Field Tips
- Use an acoustic lubrication gun for fan bearings — it prevents over-greasing, which is the most common cause of fan bearing failure.
- Replace belts as a matched set and from the same manufacturer — mixed belts have different lengths and load sharing.
- Trend the bearing temperature and the belt tension — a rising temperature or a falling tension indicates developing wear.
- For fans with multiple belts, use a belt tension meter for consistent tension across all belts.

## Safety Notes
- Never grease a bearing or adjust a belt while the fan is running — the rotating components can catch hands and clothing. Lock out the fan.
- A broken belt can fling from the sheave at high speed — install and maintain the belt guard.',
   50, 2,
   '[{"question":"What are the two most common failure points on industrial fans?","options":["Motor and bearings","Bearings and belt drives","Impeller and housing","Frame and base"],"correctIndex":1},{"question":"What is the most common cause of fan bearing failure?","options":["Over-lubrication — blows seals and churning heat degrades the grease","Under-lubrication","Contamination","Misalignment"],"correctIndex":0},{"question":"Why should V-belts be replaced as a matched set?","options":["They look better","Belts from different manufacturing lots have slightly different lengths, causing uneven load sharing","It is cheaper","It is required by OSHA"],"correctIndex":1},{"question":"What does a belt that squeals on startup indicate?","options":["Over-tensioning","Under-tensioning","Misalignment","Normal operation"],"correctIndex":1},{"question":"What does a belt that wears on one side only indicate?","options":["Normal wear","Sheave misalignment — align with a straightedge","Over-tensioning","The belt is the wrong size"],"correctIndex":1},{"question":"What does a bearing running 20-30°C above an adjacent bearing indicate?","options":["Normal operation","The bearing is in distress","The ambient temperature is high","The lubrication is excessive"],"correctIndex":1},{"question":"What should be used to prevent over-greasing fan bearings?","options":["More grease","An acoustic lubrication gun — it stops when the dB stabilizes","A larger grease gun","No grease"],"correctIndex":1}]'::jsonb);

  -- New module 4
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Air Handling Units & HVAC Maintenance', 4) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'AHU Components, Filters & Coils',
   '## Overview
Air Handling Units (AHUs) are the heart of industrial HVAC systems, conditioning and circulating air throughout a facility. Understanding the components — filters, coils, dampers, and the fan — and their maintenance is essential for maintaining indoor air quality and process air systems.

## Key Concepts
- **Filters** remove particulates from the air. The filter efficiency (MERV rating) and the pressure drop determine the air quality and the fan load. A clogged filter increases the pressure drop and reduces the airflow.
- **Cooling coils** remove heat and moisture from the air. A fouled coil (dirt on the fins) reduces the heat transfer and increases the pressure drop. Coils must be cleaned regularly.
- **Heating coils** add heat to the air. Steam coils are susceptible to freeze damage if the condensate freezes in the tubes. Hot water coils are less susceptible but must be drained in winter if the system is off.
- **Dampers** control the airflow. A stuck damper (actuator failure, linkage binding) restricts or diverts the airflow. Dampers must be exercised regularly.
- **The fan** moves the air through the AHU. The fan performance (flow and static pressure) determines whether the system can maintain the design conditions.

## Step-by-Step: AHU PM Procedure
1. **Check and replace the filters** based on the pressure drop — replace when the pressure drop exceeds the manufacturer limit (typically 1.0 in. w.c. above clean).
2. **Inspect and clean the coils** — use a coil cleaner and a pressure washer (low pressure, wide angle) to remove dirt from the fins. Verify the airflow path is clear.
3. **Inspect the drain pan** — a clogged drain pan overflows and causes water damage. Clean the drain and the trap.
4. **Exercise the dampers** — cycle each damper through its full range and verify it moves freely. Lubricate the linkage if it binds.
5. **Check the fan bearings** and the belt drive per the fan bearing PM procedure.
6. **Measure the airflow** at the supply and return — verify the system is delivering the design airflow. A low airflow indicates a restriction (filter, coil, damper) or a fan problem.
7. **Check the coil for freeze damage** on steam coils — look for bent fins and water leaks from cracked tubes.

## Common Problems and Fixes
- **Airflow is low despite clean filters:** The coil is fouled. Clean the coil with a coil cleaner.
- **Water leaks from the AHU:** The drain pan is clogged. Clean the drain and the trap.
- **Damper does not move:** The actuator is failed or the linkage is binding. Check the actuator and the linkage.
- **Coil freezes in winter:** The steam trap is failed or the freeze protection thermostat is not set correctly. Check the trap and the thermostat.

## Best Practices and Field Tips
- Trend the filter pressure drop — a rising trend indicates the filter is clogging and needs replacement.
- Install a differential pressure sensor across the filter for remote monitoring — it alerts before the filter causes a problem.
- Clean the coils quarterly in dusty environments — a fouled coil reduces the heat transfer and increases the fan energy.
- Exercise the dampers monthly — a damper that does not move for months seizes and fails when it is needed.

## Safety Notes
- Never reach into an AHU while the fan is running — the rotating fan can cause severe injury. Lock out the fan before any internal work.
- Coil cleaning chemicals can be hazardous — use PPE (gloves, goggles) and follow the manufacturer safety instructions.',
   50, 1,
   '[{"question":"What does a clogged AHU filter cause?","options":["Improved air quality","Increased pressure drop and reduced airflow","No effect","Lower energy use"],"correctIndex":1},{"question":"When should AHU filters be replaced?","options":["Every 5 years","When the pressure drop exceeds the manufacturer limit (typically 1.0 in. w.c. above clean)","Only when they look dirty","Every month"],"correctIndex":1},{"question":"What does a fouled cooling coil cause?","options":["Improved heat transfer","Reduced heat transfer and increased pressure drop","No effect","Lower temperature"],"correctIndex":1},{"question":"What causes a steam coil to freeze?","options":["High airflow","The condensate freezes in the tubes — check the steam trap and freeze protection thermostat","Over-pressure","Low temperature"],"correctIndex":1},{"question":"Why should dampers be exercised regularly?","options":["For appearance","A damper that does not move for months seizes and fails when needed","To save energy","It is required by code"],"correctIndex":1},{"question":"What does a low airflow despite clean filters indicate?","options":["The fan is oversized","The coil is fouled — clean the coil with a coil cleaner","The system is fine","The dampers are too open"],"correctIndex":1},{"question":"What should be trended to monitor filter condition remotely?","options":["The filter color","The differential pressure across the filter","The filter size","The filter brand"],"correctIndex":1}]'::jsonb),
  (m_id, 'Balancing, Duct Leakage & System Optimization',
   '## Overview
Air system balancing ensures that each zone receives the correct airflow. Duct leakage wastes energy and can cause comfort and process problems. Understanding how to balance a system and find and repair leaks is essential for efficient air-handling operation.

## Key Concepts
- **Air balancing** adjusts the dampers in each duct branch to deliver the design airflow to each zone. The balance is performed with all dampers open, then each branch is throttled to the design flow.
- **Duct leakage** is the air that escapes through gaps in the ductwork. A 10% leakage in a system means 10% of the fan energy is wasted. Leakage is found by pressurizing the duct and measuring the flow, or by visual inspection of accessible joints.
- **Static pressure reset** is a control strategy that reduces the fan speed to maintain the minimum static pressure required — it saves energy by matching the fan output to the system demand.
- **System effect** (covered in the Fan Performance lesson) reduces the effective fan capacity — correcting the ductwork at the fan inlet and outlet improves the system performance without changing the fan.

## Step-by-Step: Air System Balancing
1. **Open all dampers** to the full open position.
2. **Measure the airflow** at each supply register with an anemometer or a flow hood.
3. **Compare to the design airflow** for each register. If all are low, the fan is undersized or the system has a major restriction. If some are high and some low, the system needs balancing.
4. **Start at the furthest register** from the fan and throttle the damper to the design flow. Work backward toward the fan, adjusting each damper.
5. **Re-measure all registers** after the initial balance — adjusting one damper affects all downstream flows.
6. **Fine-tune** the dampers through 2-3 iterations until all registers are within 10% of the design flow.
7. **Mark the damper positions** and record the balance report with the design flow, the actual flow, and the damper position for each register.

## Common Problems and Fixes
- **All registers are low despite a correctly sized fan:** Duct leakage or a system effect. Check for duct leaks and correct the ductwork at the fan inlet and outlet.
- **One zone is always too hot/cold:** The airflow to that zone is incorrect. Re-balance the dampers for that zone.
- **System uses too much energy:** The fan is running at full speed to overcome a restriction. Clean the filters and coils, or reduce the static pressure setpoint.
- **Duct leakage is suspected:** Pressurize the duct and measure the flow at the fan versus the flow at the registers — the difference is the leakage. Seal the accessible joints with duct sealer.

## Best Practices and Field Tips
- Perform a balance check annually — the balance drifts as filters load and dampers move.
- Install a flow station at each main branch for permanent monitoring — a trend reveals developing restrictions.
- For VFD-driven fans, use static pressure reset to save energy — the fan speed adjusts to maintain the minimum required static pressure.
- Seal all accessible duct joints with mastic, not duct tape — duct tape dries out and fails within months.

## Safety Notes
- Never reach into a duct while the fan is running — the airflow can pull in tools and materials.
- Duct interiors can contain dust and debris — wear a dust mask when inspecting or sealing ducts.',
   50, 2,
   '[{"question":"What is the purpose of air system balancing?","options":["To reduce noise","To adjust dampers to deliver the design airflow to each zone","To increase the fan speed","To clean the filters"],"correctIndex":1},{"question":"In what order should dampers be adjusted during balancing?","options":["From the fan outward","From the furthest register backward toward the fan","Random order","All at once"],"correctIndex":1},{"question":"What does a 10% duct leakage mean?","options":["10% of the air is clean","10% of the fan energy is wasted","10% of the ducts are damaged","Nothing significant"],"correctIndex":1},{"question":"What tolerance should all registers be within after balancing?","options":["1% of design","10% of design","25% of design","50% of design"],"correctIndex":1},{"question":"What should be used to seal duct joints, not duct tape?","options":["Silicone","Mastic — duct tape dries out and fails within months"," screws","Welding"],"correctIndex":1},{"question":"What is static pressure reset for VFD-driven fans?","options":["A safety feature","A control strategy that reduces fan speed to maintain minimum required static pressure, saving energy","A way to increase airflow","A type of filter"],"correctIndex":1},{"question":"How often should a balance check be performed?","options":["Every 10 years","Annually — the balance drifts as filters load and dampers move","Monthly","Only at installation"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons
  UPDATE lessons SET content =
'## Overview
Industrial fans move air for ventilation, process cooling, combustion air, and material handling. Selecting the correct fan type and understanding the performance curve is the foundation of reliable fan operation. This lesson covers the major fan types, their characteristics, and the selection criteria.

## Key Concepts
- **Centrifugal fans** move air radially outward from the impeller. Classified by blade shape: forward-curved (high volume, low pressure), backward-curved (high efficiency, stable pressure), and radial (rugged, self-cleaning for dusty air).
- **Axial fans** move air along the shaft axis. Used for high-volume, low-pressure applications like ventilation. They are compact but less efficient than centrifugal fans for high-pressure applications.
- **Fan curve** plots pressure vs flow, similar to a pump curve. The system curve (ductwork resistance) intersects the fan curve at the operating point.
- **Surge or hunting** occurs when the fan operates in the unstable region of its curve, typically to the left of the peak pressure point. The fan oscillates in flow and pressure.
- **Amperage** is proportional to the fan load: high amperage at low flow indicates a restriction; low amperage at high flow indicates a worn impeller or housing clearance.

## Step-by-Step: Fan Selection
1. **Determine the required flow (CFM)** and the static pressure (in. w.c.) from the system design.
2. **Select the fan type:** Centrifugal for high pressure, axial for high volume and low pressure, radial for dusty or particulate-laden air.
3. **Select the blade type:** Forward-curved for high volume at low pressure, backward-curved for high efficiency, radial for rugged/dirty service.
4. **Verify the operating point** is on the fan curve at 70-120% of the best efficiency point.
5. **Verify the motor** is sized for the fan brake horsepower at the operating point, with a 1.15 service factor.
6. **Check the system effects:** Ensure the ductwork at the fan inlet and outlet does not create a system effect that reduces the effective capacity.

## Common Problems and Fixes
- **Fan surges or hunts:** Operating in the unstable region. Adjust the system resistance (open a damper, reduce a restriction) to move the operating point to the right of the peak pressure.
- **Fan delivers less than design:** The system effect is reducing the capacity, or the fan is worn. Correct the ductwork or replace the fan.
- **Fan is noisy:** High tip speed (select a larger fan for lower speed), or the fan is operating in surge. Reduce the speed or correct the operating point.
- **Fan motor trips on overload:** The operating point is too far right (high flow, high horsepower). Throttle the discharge or reduce the fan speed.

## Best Practices and Field Tips
- Always keep a copy of the fan curve in the maintenance file — without it, you cannot diagnose fan problems.
- For dusty applications, select a radial-blade fan with a self-cleaning design — forward-curved blades clog with dust.
- For high-efficiency applications, select a backward-curved fan with an airfoil blade — it offers the highest efficiency.
- Verify the fan rotation matches the arrow on the housing — a fan running backward delivers less than 50% of the design flow.

## Safety Notes
- Never operate a fan with the inlet or outlet guard removed — the rotating impeller can cause severe injury.
- A fan that is operating in surge can structurally fail — shut down and correct the operating point before restarting.',
   quiz =
'[{"question":"Which centrifugal fan blade type is most efficient?","options":["Forward-curved","Backward-curved","Radial","Straight"],"correctIndex":1},{"question":"What does a fan surging or hunting indicate?","options":["Normal operation","Operating in the unstable region of its curve","Oversized motor","Dirty filter"],"correctIndex":1},{"question":"Which fan type is best for dusty, particulate-laden air?","options":["Forward-curved centrifugal","Radial-blade centrifugal (self-cleaning)","Axial","Backward-curved centrifugal"],"correctIndex":1},{"question":"What does high motor amperage at low flow indicate?","options":["Normal operation","The fan is fighting a restriction","The fan is oversized","The motor is failing"],"correctIndex":1},{"question":"What is the recommended operating range relative to the best efficiency point?","options":["50-80% of BEP","70-120% of BEP","90-110% of BEP","Any range"],"correctIndex":1},{"question":"What happens if a fan runs backward (wrong rotation)?","options":["It runs fine","It delivers less than 50% of the design flow","It delivers more flow","It overheats"],"correctIndex":1},{"question":"What should be kept in the maintenance file for fan diagnosis?","options":["Only the motor manual","The fan curve — without it, you cannot diagnose fan problems","Only the belt size","Only the filter size"],"correctIndex":1}]'::jsonb
  WHERE title = 'Centrifugal vs Axial Fans' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Fan bearings carry the rotor weight, the impeller thrust, and the unbalanced forces. The impeller is the component that moves the air, and any wear or damage to the impeller directly affects the fan performance and the vibration. Understanding the bearing arrangements and the impeller inspection procedure is essential for fan maintenance.

## Key Concepts
- **Bearing arrangement:** Most industrial fans use roller bearings on the drive end (radial load) and a located ball bearing on the non-drive end (axial positioning). The non-drive bearing is often floating to allow thermal expansion.
- **Impeller inspection:** Check for erosion, cracking, and dust buildup. Even a thin layer of dust on the blades shifts the balance and increases vibration.
- **Dye penetrant inspection:** For critical fans, inspect the blade root for cracks with dye penetrant — a cracked blade root is a catastrophic failure waiting to happen.
- **Inlet ring clearance:** The clearance between the impeller and the housing inlet ring affects the fan efficiency. Excessive clearance recirculates air and kills efficiency.
- **Shaft wear at the seal:** A grooved shaft leaks air and damages the packing. Check the shaft for wear at the seal contact area.

## Step-by-Step: Fan Bearing and Impeller Inspection
1. **Lock out the fan motor** and remove the guards.
2. **Check the bearing condition:** Rotate the shaft by hand — any roughness, catching, or noise indicates bearing wear. Check the bearing temperature with an infrared gun (if recently running).
3. **Inspect the impeller for dust buildup:** Clean the impeller with a brush or a pressure washer. Even a thin layer of dust shifts the balance.
4. **Inspect the impeller for erosion and cracking:** Look for thinned blade tips, eroded leading edges, and cracks at the blade root. Use dye penetrant on the blade root for critical fans.
5. **Measure the inlet ring clearance:** Check the clearance between the impeller and the housing inlet ring. Excessive clearance reduces efficiency.
6. **Check the shaft for wear at the seal:** A grooved shaft needs sleeving or replacement.
7. **Re-balance the impeller** after any cleaning or repair — even a small weight change from cleaning shifts the balance.
8. **Re-install the guards** before returning the fan to service.

## Common Problems and Fixes
- **Fan vibrates after cleaning the impeller:** The cleaning removed dust unevenly, shifting the balance. Re-balance the impeller.
- **Bearing runs hot:** Over-greasing, under-greasing, or misalignment. Check the grease and the alignment.
- **Impeller cracks at the blade root:** Fatigue from vibration or a manufacturing defect. Replace the impeller and investigate the vibration source.
- **Fan efficiency drops over time:** The inlet ring clearance has increased from wear. Replace the inlet ring or the impeller.

## Best Practices and Field Tips
- Clean the impeller at every PM — dust buildup is the most common cause of fan vibration.
- After cleaning, always re-balance — the dust removal changes the weight distribution.
- For critical fans, perform a dye penetrant inspection of the blade root annually — a cracked root is a catastrophic failure.
- Trend the bearing temperature and the vibration — a rising trend indicates developing wear.

## Safety Notes
- Never inspect a fan with the guard removed and the motor energized — the rotating impeller can cause severe injury. Lock out the motor.
- A cracked impeller can fail catastrophically during operation — shut down immediately if a crack is found.',
   quiz =
'[{"question":"Why does dust on fan blades increase vibration?","options":["It corrodes the blades","It shifts the balance","It restricts airflow","It increases temperature"],"correctIndex":1},{"question":"What should be done after cleaning a fan impeller?","options":["Nothing","Re-balance the impeller — the dust removal changes the weight distribution","Increase the speed","Replace the bearings"],"correctIndex":1},{"question":"What inspection should be performed on critical fan blade roots annually?","options":["Visual only","Dye penetrant inspection — a cracked root is a catastrophic failure","Paint inspection","Ultrasonic thickness"],"correctIndex":1},{"question":"What does excessive inlet ring clearance cause?","options":["Improved efficiency","Recirculation of air and reduced efficiency","Increased noise","Higher temperature"],"correctIndex":1},{"question":"What does a grooved shaft at the seal contact area cause?","options":["Nothing","Air leaks and packing damage","Improved sealing","Higher efficiency"],"correctIndex":1},{"question":"What is the most common cause of fan vibration?","options":["Bearing wear","Dust buildup on the impeller","Misalignment","Loose foundation bolts"],"correctIndex":1},{"question":"What should be done if a crack is found in a fan impeller blade root?","options":["Monitor it","Shut down immediately — a cracked impeller can fail catastrophically","Reduce the speed","Weld the crack"],"correctIndex":1}]'::jsonb
  WHERE title = 'Bearing Arrangements & Impeller Inspection' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Fan vibration diagnosis starts with the dominant frequency. Each frequency points to a specific cause, and learning to read the spectrum is the core skill of fan vibration troubleshooting. This lesson covers the diagnostic procedure and the ISO alarm levels for industrial fans.

## Key Concepts
- **1x RPM dominant frequency:** Imbalance — common after dust buildup or impeller wear. Correct by balancing.
- **2x dominant frequency:** Misalignment between the motor and fan shafts. Correct by laser alignment.
- **High broadband floor with many harmonics:** Looseness — check bearing fit, foundation bolts, and impeller hub tightness.
- **Bearing defect frequencies:** Appear at higher frequencies and indicate bearing degradation. Use a vibration analyzer with bearing fault frequency calculation.
- **ISO 10816 alarm levels:** For most industrial fans, 4.5 mm/s is a warning and 7.1 mm/s is a danger threshold. Measure the overall velocity at the bearing housing in the radial and axial directions.

## Step-by-Step: Fan Vibration Diagnosis
1. **Mount the vibration sensor** at the bearing housing in the radial and axial directions. Mark the measurement point for repeatability.
2. **Measure the overall velocity (mm/s)** and compare to the ISO 10816 alarm levels (4.5 warning, 7.1 danger).
3. **If the overall is elevated, examine the spectrum (FFT):** Identify the dominant frequency — 1x (imbalance), 2x (misalignment), broadband (looseness), or bearing defect frequencies.
4. **If 1x RPM is dominant:** Check for dust buildup on the impeller (clean and re-balance), impeller wear, or a missing balance weight.
5. **If 2x RPM is dominant:** Check the coupling alignment. Perform a laser alignment.
6. **If broadband with many harmonics:** Check the bearing fit on the shaft, the foundation bolts, and the impeller hub tightness. Tighten any loose components.
7. **If bearing defect frequencies are present:** Input the bearing part number into the analyzer to calculate the expected BPFO, BPFI, BSF, and FTF. A defect frequency that doubles over two measurements warrants scheduling a bearing replacement.
8. **For variable-speed fans:** Use order analysis (normalizing to RPM) to compare readings across speeds, since the frequencies shift with speed.

## Common Problems and Fixes
- **Fan vibrates after cleaning:** The cleaning removed dust unevenly, shifting the balance. Re-balance the impeller.
- **Fan vibrates at a specific speed:** Structural resonance at that speed. Identify the resonant speed and program the VFD to skip it, or stiffen the structure to shift the resonance.
- **Fan vibration increases over time:** Bearing wear or impeller wear. Trend the vibration and the oil analysis (if applicable) to plan the repair.
- **Vibration is high in the axial direction:** Misalignment (angular) or a thrust bearing problem. Check the alignment and the bearing.

## Best Practices and Field Tips
- Mark the measurement point on each bearing housing with paint or a stamped dot for repeatability — a measurement at a different point is not comparable.
- Trend the overall velocity monthly — a rising trend indicates developing wear before the alarm level is reached.
- Install a vibration sensor on critical fans for continuous monitoring — it alerts the maintenance team before failure.
- For variable-speed fans, collect data at the normal operating speed for consistent trending.

## Safety Notes
- Never collect vibration data on a fan with the coupling guard removed — the rotating coupling can catch the sensor cable.
- A fan with high vibration can fail catastrophically — shut down if the vibration exceeds the danger threshold.',
   quiz =
'[{"question":"What does a 1x RPM dominant vibration frequency on a fan indicate?","options":["Misalignment","Imbalance","Bearing defect","Looseness"],"correctIndex":1},{"question":"What does a 2x dominant vibration frequency indicate?","options":["Imbalance","Misalignment between the motor and fan shafts","Bearing defect","Looseness"],"correctIndex":1},{"question":"What is the ISO 10816 danger threshold for most industrial fans?","options":["2.8 mm/s","4.5 mm/s","7.1 mm/s","11.2 mm/s"],"correctIndex":2},{"question":"What does a high broadband floor with many harmonics indicate?","options":["Imbalance","Misalignment","Looseness — check bearing fit, foundation bolts, and impeller hub tightness","Bearing defect"],"correctIndex":2},{"question":"What should be done if a fan vibrates at a specific speed?","options":["Replace the fan","Identify the resonant speed and program the VFD to skip it, or stiffen the structure","Increase the speed","Reduce the load"],"correctIndex":1},{"question":"Why should the measurement point be marked on the bearing housing?","options":["For appearance","For repeatability — a measurement at a different point is not comparable","For safety","It is required by ISO"],"correctIndex":1},{"question":"What should be done for variable-speed fans to compare vibration readings across speeds?","options":["Use a different sensor","Use order analysis (normalizing to RPM)","Measure at different points","Nothing can be done"],"correctIndex":1}]'::jsonb
  WHERE title = 'Fan Vibration Diagnosis' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;
