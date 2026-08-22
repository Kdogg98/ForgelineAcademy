/*
# Catalog depth expansion — Mechanical courses 8-11

## Courses in this batch
8. Industrial Couplings, Keys & Shafts (add 2 modules → 4 total)
9. Vibration Analysis Fundamentals (add 1 module → 3 total)
10. Thermography for Mechanical Maintenance (add 1 module → 3 total)
11. Ultrasound & Acoustic Lubrication (add 1 module → 3 total)

## Security
No schema or policy changes. Data-only migration.
*/

-- ===================== 8. INDUSTRIAL COUPLINGS, KEYS & SHAFTS =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Industrial Couplings, Keys & Shafts';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Coupling Troubleshooting & Failure Analysis', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Coupling Failure Modes & Diagnosis',
   '## Overview
Coupling failures are rarely the coupling''s fault — they are usually symptoms of misalignment, over-lubrication, overload, or torsional vibration. Understanding the failure modes and how to diagnose them prevents repeated failures and unnecessary coupling replacement.

## Key Concepts
- **Gear coupling tooth wear:** From inadequate lubrication or misalignment. The teeth wear unevenly, causing backlash and eventually tooth breakage.
- **Grid coupling spring breakage:** From shock loads or fatigue. The serpentine spring fractures at the bend points.
- **Elastomeric element degradation:** The rubber element hardens, cracks, or swells from chemical exposure or heat. A degraded element transmits vibration and eventually fails.
- **Disc coupling disc fracture:** From misalignment beyond the coupling capacity or torsional vibration. The thin discs crack at the clamping points.
- **Coupling overheating:** From misalignment generating friction heat, or from over-lubrication (greased couplings). A hot coupling is a warning of imminent failure.

## Step-by-Step: Coupling Failure Analysis
1. **Remove the coupling** and inspect each component.
2. **For gear couplings:** Check the teeth for wear, pitting, and breakage. Check the grease for contamination (water, metal particles). Measure the backlash — excessive backlash indicates tooth wear.
3. **For grid couplings:** Inspect the spring grid for cracks at the bend points. Check the grease for contamination.
4. **For elastomeric couplings:** Inspect the rubber element for hardening, cracking, swelling, or chemical attack. Replace the element if any degradation is found.
5. **For disc couplings:** Inspect the discs for cracks at the clamping points. Check the disc stack for fretting (rust-colored dust between the discs).
6. **Check the coupling alignment** — a failed coupling from misalignment will fail again if the alignment is not corrected.
7. **Document the failure mode** and the corrective action (replace the coupling, correct the alignment, change the lubrication schedule).

## Common Problems and Fixes
- **Coupling fails repeatedly:** Misalignment or overload. Correct the alignment and verify the load is within the coupling rating.
- **Gear coupling runs hot:** Misalignment or over-lubrication. Check the alignment and reduce the grease quantity.
- **Elastomeric element fails quickly:** Chemical exposure or high temperature. Verify the element material is compatible with the environment.
- **Disc coupling discs crack:** Misalignment beyond the coupling capacity or torsional vibration. Correct the alignment or select a coupling with more misalignment capacity.

## Best Practices and Field Tips
- Always correct the root cause before replacing a failed coupling — a new coupling on a misaligned shaft will fail again.
- For greased couplings, use the OEM-specified grease and the OEM-specified quantity — over-greasing is as harmful as under-greasing.
- Trend the coupling temperature with an infrared gun — a rising temperature indicates developing misalignment or lubrication failure.
- Keep a spare coupling for critical equipment — the lead time for a new coupling can be weeks.

## Safety Notes
- Never remove a coupling guard while the equipment is running — the rotating coupling can catch clothing and fingers.
- A failed coupling can fling components at high speed — always install the guard before restarting.',
   50, 1,
   '[{"question":"What is the most common root cause of coupling failure?","options":["Material defect","Misalignment, over-lubrication, or overload","Normal wear","Incorrect color"],"correctIndex":1},{"question":"What does a hot coupling indicate?","options":["Normal operation","Misalignment generating friction heat, or over-lubrication","The coupling is oversized","The ambient temperature is high"],"correctIndex":1},{"question":"What causes gear coupling tooth wear?","options":["Over-speed","Inadequate lubrication or misalignment","Overload only","Normal aging"],"correctIndex":1},{"question":"What should be done before replacing a failed coupling?","options":["Nothing — just replace it","Correct the root cause — a new coupling on a misaligned shaft will fail again","Replace the motor","Replace the shaft"],"correctIndex":1},{"question":"What causes elastomeric coupling element degradation?","options":["Normal aging","Chemical exposure or heat — verify the element material is compatible","Over-torque","Under-speed"],"correctIndex":1},{"question":"What causes disc coupling disc fracture?","options":["Over-lubrication","Misalignment beyond the coupling capacity or torsional vibration","Normal wear","Corrosion"],"correctIndex":1},{"question":"What should be trended with an infrared gun to detect coupling problems?","options":["The motor temperature","The coupling temperature — a rising temperature indicates developing misalignment or lubrication failure","The shaft temperature","The ambient temperature"],"correctIndex":1}]'::jsonb),
  (m_id, 'Coupling Selection for Special Applications',
   '## Overview
Some applications require special coupling selection — high-speed, high-temperature, high-shock, or limited-space applications. Understanding the special requirements and the coupling options ensures reliable power transmission in challenging conditions.

## Key Concepts
- **High-speed applications:** Require a balanced coupling (the coupling balance grade affects the vibration at high speed). Disc couplings are the standard for high-speed because they have no moving parts to wear and are inherently balanced.
- **High-temperature applications:** Elastomeric couplings degrade above 80-100°C. Use a metal coupling (gear, grid, or disc) for high-temperature service.
- **High-shock applications:** Grid couplings dampen shock loads better than gear couplings. Elastomeric couplings also dampen shock but have lower torque capacity.
- **Limited-space applications:** Shaft-mounted (quill) couplings save space but transmit vibration directly. Disc couplings are the most compact for a given torque.
- **Explosion-proof or hazardous areas:** Spark-free couplings (non-sparking materials) are required in hazardous areas where a spark could ignite the atmosphere.

## Step-by-Step: Special Application Coupling Selection
1. **Identify the special requirement:** High speed, high temperature, high shock, limited space, or hazardous area.
2. **For high speed:** Select a disc coupling with a balance grade that meets the speed requirement. Verify the coupling is rated for the maximum speed.
3. **For high temperature:** Select a metal coupling (gear, grid, or disc) with high-temperature grease. Verify the coupling material is rated for the operating temperature.
4. **For high shock:** Select a grid coupling with a service factor of 2.0-3.0. Verify the coupling torque rating exceeds the peak shock torque.
5. **For limited space:** Select a shaft-mounted (quill) coupling or a disc coupling. Verify the coupling fits within the available space.
6. **For hazardous areas:** Select a spark-free coupling with non-sparking materials. Verify the coupling meets the area classification.

## Common Problems and Fixes
- **Coupling vibrates at high speed:** The coupling is not balanced for the speed. Select a coupling with a higher balance grade.
- **Elastomeric coupling fails in high temperature:** The element degrades above its temperature limit. Select a metal coupling.
- **Grid coupling fails under shock:** The service factor is too low. Increase the service factor or select a larger coupling.
- **Coupling does not fit in the space:** Select a more compact coupling type (disc or quill).

## Best Practices and Field Tips
- Always verify the coupling speed rating exceeds the maximum operating speed — a coupling that is not rated for the speed will vibrate and fail.
- For high-speed couplings, verify the balance grade and the residual imbalance — a poorly balanced coupling causes vibration that damages the bearings.
- In hazardous areas, document the coupling material and the area classification for compliance.
- For high-temperature couplings, use a high-temperature grease and increase the greasing frequency.

## Safety Notes
- In hazardous areas, a sparking coupling can ignite the atmosphere — always verify the coupling is spark-free for the area classification.
- High-speed couplings can disintegrate if they fail — the coupling guard must be rated for the containment of a failed coupling at the operating speed.',
   50, 2,
   '[{"question":"Which coupling type is standard for high-speed applications?","options":["Gear coupling","Grid coupling","Disc coupling — no moving parts to wear, inherently balanced","Elastomeric coupling"],"correctIndex":2},{"question":"What happens to elastomeric couplings above 80-100°C?","options":["They improve","The element degrades","Nothing","They run quieter"],"correctIndex":1},{"question":"Which coupling type dampens shock loads best?","options":["Gear coupling","Grid coupling","Disc coupling","Rigid coupling"],"correctIndex":1},{"question":"What service factor is recommended for high-shock applications?","options":["1.0","1.5","2.0-3.0","5.0"],"correctIndex":2},{"question":"What type of coupling is needed in hazardous areas?","options":["Any coupling","A spark-free coupling with non-sparking materials","A gear coupling","An elastomeric coupling"],"correctIndex":1},{"question":"What causes a coupling to vibrate at high speed?","options":["Overload","The coupling is not balanced for the speed — select a higher balance grade","Misalignment","Over-lubrication"],"correctIndex":1},{"question":"What must the coupling guard be rated for at high speed?","options":["Nothing special","Containment of a failed coupling at the operating speed","Noise reduction","Heat resistance"],"correctIndex":1}]'::jsonb);

  -- New module 4
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Shaft Repair & Maintenance', 4) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Shaft Repair Methods & Straightening',
   '## Overview
A bent or worn shaft can often be repaired rather than replaced, saving cost and downtime. Understanding the repair options — build-up welding, thermal spray, sleeving, and straightening — and their limitations is essential for a maintenance technician.

## Key Concepts
- **Build-up welding:** Weld material is deposited on the worn journal and machined to size. Suitable for worn journals but can distort the shaft from welding heat.
- **Thermal spray (HVOF or plasma):** A wear-resistant coating is sprayed onto the journal and machined to size. Lower heat input than welding, less distortion.
- **Sleeving:** A thin sleeve is shrink-fit over the worn journal to restore the dimension. Quick and inexpensive but the sleeve can slip under high torque.
- **Straightening:** A bent shaft is pressed back to straight in a hydraulic press. Risky — the shaft can crack or fatigue. Only suitable for minor bends on non-critical shafts.
- **Runout check after repair:** Any shaft repair must be verified with a dial indicator for runout at the bearing journals, the coupling fit, and the impeller fit.

## Step-by-Step: Shaft Repair by Build-Up Welding
1. **Measure the shaft** at the worn journal: record the diameter, the taper, and the runout.
2. **Pre-heat the shaft** to reduce the thermal gradient and minimize distortion (typically 150-200°C for steel shafts).
3. **Weld build-up** using a compatible filler (E7018 for mild steel) in small, overlapping passes with the shaft rotating.
4. **Stress-relieve** after welding to reduce residual stresses (typically 600°C for 1 hour per inch of thickness).
5. **Machine the journal** to the correct dimension on a lathe.
6. **Check runout** at all bearing journals, the coupling fit, and the impeller fit. The total runout should be under 0.05 mm for general service.
7. **If the runout is excessive:** The welding heat distorted the shaft. Straighten in a press (if minor) or scrap the shaft (if major).
8. **Document the repair** with the pre- and post-repair measurements.

## Common Problems and Fixes
- **Shaft is bent after welding:** Welding heat distortion. Pre-heat to reduce the gradient, use smaller passes, and stress-relieve after welding.
- **Sleeve slips under torque:** The interference fit is insufficient. Use a larger interference or add a key to the sleeve.
- **Shaft cracks during straightening:** The shaft material is brittle or the bend is too severe. Do not attempt to straighten a shaft with a bend greater than 0.5 mm/m.
- **Runout is still excessive after machining:** The shaft was not supported correctly in the lathe. Re-machine with the shaft supported at the bearing journals.

## Best Practices and Field Tips
- For critical shafts (turbine rotors, high-speed pump shafts), do not attempt repair — replace the shaft. The risk of failure is too high.
- For non-critical shafts (conveyor rollers, fan shafts), repair is cost-effective if the runout is verified after repair.
- Always measure the runout before and after any shaft repair — a repair that does not restore the runout is not a repair.
- Keep a spare shaft for critical equipment — the lead time for a new shaft can be weeks.

## Safety Notes
- Welding on a shaft produces fumes and UV radiation — use welding PPE (helmet, gloves, fume extraction).
- A shaft under pressure in a hydraulic press can fracture and fly — use a press guard and stand to the side.',
   55, 1,
   '[{"question":"What are the shaft repair methods?","options":["Replace only","Build-up welding, thermal spray, sleeving, and straightening","Grinding only","Painting"],"correctIndex":1},{"question":"What must be done after any shaft repair?","options":["Nothing","Verify runout with a dial indicator at all journals and fits","Paint the shaft","Balance the coupling"],"correctIndex":1},{"question":"What is the risk of build-up welding on a shaft?","options":["No risk","Welding heat can distort the shaft","The shaft becomes stronger","The shaft becomes lighter"],"correctIndex":1},{"question":"What is the maximum runout for general service after repair?","options":["Under 0.005 mm","Under 0.05 mm","Under 0.5 mm","Under 1 mm"],"correctIndex":1},{"question":"When should a bent shaft NOT be straightened?","options":["Never","If the bend is greater than 0.5 mm/m or the shaft is critical","If the bend is minor","Always straighten"],"correctIndex":1},{"question":"What should be done for critical shafts (turbine rotors, high-speed pump shafts)?","options":["Repair them","Replace them — the risk of failure is too high for repair","Weld them","Straighten them"],"correctIndex":1},{"question":"What can happen to a shaft under pressure in a hydraulic press?","options":["Nothing","It can fracture and fly — use a press guard and stand to the side","It becomes straight","It becomes stronger"],"correctIndex":1}]'::jsonb),
  (m_id, 'Shaft Materials, Heat Treatment & Surface Hardening',
   '## Overview
The shaft material and its heat treatment determine the strength, the fatigue resistance, and the wear resistance. Understanding the common shaft materials and the surface hardening methods helps select the right shaft for the application and the right repair method.

## Key Concepts
- **Common shaft materials:** 1045 (medium carbon steel, general purpose), 4140 (chromium-molybdenum alloy, high strength), 316 stainless (corrosion resistance), 17-4 PH (high strength + corrosion resistance).
- **Heat treatment:** Quenching and tempering increases the strength and the hardness. Through-hardening treats the entire cross-section; induction hardening hardens only the surface (the journal).
- **Surface hardening methods:** Induction hardening (hardens the journal surface to 55-60 HRC while the core remains tough), nitriding (hardens the surface by nitrogen diffusion, no quenching), carburizing (hardens the surface by carbon diffusion).
- **Fatigue resistance:** A shaft that fails repeatedly at the same point has a fatigue problem — the stress concentration at a keyway, a shoulder, or a cross-hole is the root cause. Use a larger radius at the shoulder to reduce the stress concentration.
- **Surface finish:** A polished journal surface reduces the stress concentration and improves the bearing life. A rough surface initiates fatigue cracks.

## Step-by-Step: Shaft Material Selection
1. **Determine the load type:** Bending (most shafts), torsional (drive shafts), or combined.
2. **Determine the environment:** Corrosive (select stainless), high temperature (select alloy steel), or normal (select carbon steel).
3. **Determine the wear requirement:** If the journal wears, select a surface-hardened material (induction hardened 1045 or nitrided 4140).
4. **Determine the fatigue requirement:** If the shaft fails from fatigue, select a higher-strength material (4140) and increase the shoulder radius.
5. **Verify the material availability** and the cost — 1045 is the cheapest, 17-4 PH is the most expensive.

## Common Problems and Fixes
- **Shaft fails from fatigue at the keyway:** The keyway creates a stress concentration. Use a larger keyway radius or a sled-runner keyway, or eliminate the keyway with a shrink-fit coupling.
- **Journal wears rapidly:** The shaft material is too soft for the bearing. Use induction hardening on the journal surface.
- **Shaft corrodes in a wet environment:** The material is carbon steel. Switch to 316 stainless or apply a corrosion-resistant coating.
- **Shaft cracks at the shoulder:** The shoulder radius is too small, creating a stress concentration. Increase the radius or use a undercut shoulder.

## Best Practices and Field Tips
- For shafts that fail repeatedly from fatigue, investigate the stress concentration — the root cause is usually a design feature (sharp shoulder, cross-hole, keyway), not the material.
- Document the shaft material and the heat treatment for each critical shaft — it supports future replacement and repair decisions.
- For surface-hardened shafts, verify the hardening depth — a shallow case wears through and the journal fails rapidly.
- A polished journal surface (Ra 0.4 or better) extends the bearing life — a rough surface tears the bearing.

## Safety Notes
- Induction hardening equipment uses high-frequency electricity and high heat — only trained personnel should operate it.
- A shaft that fails from fatigue can fracture suddenly — shut down immediately if a crack is found.',
   50, 2,
   '[{"question":"What is the most common general-purpose shaft material?","options":["1045 medium carbon steel","4140 alloy steel","316 stainless","17-4 PH stainless"],"correctIndex":0},{"question":"What does induction hardening do to a shaft journal?","options":["Hardens the entire cross-section","Hardens the journal surface to 55-60 HRC while the core remains tough","Softens the journal","Does nothing"],"correctIndex":1},{"question":"What is the most common cause of shaft fatigue failure at the keyway?","options":["Wrong material","The keyway creates a stress concentration — use a larger radius or a sled-runner keyway","Over-torque","Corrosion"],"correctIndex":1},{"question":"What surface finish (Ra) is recommended for a journal bearing surface?","options":["Ra 3.2 or better","Ra 0.4 or better","Ra 12.5 or better","Any finish"],"correctIndex":1},{"question":"What should be done for a shaft that fails repeatedly from fatigue?","options":["Replace with the same material","Investigate the stress concentration — the root cause is usually a design feature","Increase the shaft diameter","Change the bearing"],"correctIndex":1},{"question":"What material should be selected for a shaft in a corrosive environment?","options":["1045 carbon steel","316 stainless steel","4140 alloy steel","Any steel"],"correctIndex":1},{"question":"What does a shallow induction hardening case cause?","options":["Better wear resistance","The case wears through and the journal fails rapidly","No effect","Stronger shaft"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons with structured content and expanded quizzes
  UPDATE lessons SET content =
'## Overview
Couplings transmit torque while accommodating misalignment. Selecting the correct coupling type for the application determines the reliability of the power transmission system. This lesson covers the major coupling types, their characteristics, and the selection criteria.

## Key Concepts
- **Gear couplings** handle high torque and high speed but require lubrication — a dry gear coupling fails rapidly.
- **Grid couplings** use a serpentine spring element that flexes under misalignment while damping shock loads; they also require grease.
- **Elastomeric couplings** (jaw, tire, sleeve) use a rubber element that requires no lubrication and dampens vibration, but the element degrades over time.
- **Disc couplings** use thin metal discs that flex without wear and are used for high-speed, high-torque applications — they require no lubrication but are sensitive to misalignment beyond their rated capacity.
- **Service factor:** 1.5 for uniform loads, 2.0-3.0 for shock loads. Always verify the coupling service factor matches the application.

## Step-by-Step: Coupling Selection
1. **Determine the torque** from the motor horsepower and the speed: Torque (Nm) = (HP × 9550) / RPM.
2. **Determine the bore size** from the shaft diameter at the coupling location.
3. **Determine the misalignment capacity** required — the expected angular and parallel misalignment.
4. **Determine the speed** — high-speed applications require a balanced coupling.
5. **Determine the maintenance requirement** — can the coupling be greased, or is it maintenance-free?
6. **Select a coupling** with a torque rating, bore size, misalignment capacity, and speed rating that meet the application requirements.
7. **Apply the service factor** — multiply the calculated torque by the service factor and verify the coupling rating exceeds it.

## Common Problems and Fixes
- **Coupling fails from lubrication neglect:** Greased couplings (gear, grid) must be greased at the OEM interval. A dry coupling fails rapidly. Establish a greasing schedule.
- **Coupling is oversized for the application:** An oversized coupling has a larger bore and higher inertia, which loads the motor and the bearings. Select the correct size.
- **Coupling cannot accommodate the misalignment:** Select a coupling with more misalignment capacity, or correct the alignment.
- **Elastomeric element degrades in the environment:** Chemical exposure or high temperature. Select a compatible element material or switch to a metal coupling.

## Best Practices and Field Tips
- For applications where lubrication is difficult (remote, high, or hazardous locations), select a maintenance-free coupling (elastomeric or disc).
- For high-torque applications, gear or grid couplings are the standard — they handle more torque per unit size than elastomeric couplings.
- Document the coupling type, size, and service factor for each drive — it supports future replacement decisions.
- Always verify the coupling bore matches the shaft diameter — a coupling bored to the wrong size cannot be installed.

## Safety Notes
- Never install a coupling without the coupling guard — the rotating coupling is a serious entanglement hazard.
- A coupling that fails at speed can fling components — the guard must contain the coupling.',
   quiz =
'[{"question":"Which coupling type requires no lubrication and uses a rubber element?","options":["Gear coupling","Grid coupling","Elastomeric coupling","Disc coupling"],"correctIndex":2},{"question":"What service factor is typical for shock load applications?","options":["1.0","1.5","2.0-3.0","5.0"],"correctIndex":2},{"question":"Which coupling type is used for high-speed, high-torque applications with no lubrication?","options":["Gear coupling","Grid coupling","Elastomeric coupling","Disc coupling"],"correctIndex":3},{"question":"What happens to a gear coupling without lubrication?","options":["It runs fine","It fails rapidly","It runs quieter","It overheats but does not fail"],"correctIndex":1},{"question":"How is the coupling torque calculated from motor horsepower?","options":["Torque = HP × RPM","Torque = (HP × 9550) / RPM","Torque = HP / 9550","Torque = RPM / HP"],"correctIndex":1},{"question":"What should be selected for applications where lubrication is difficult?","options":["A gear coupling","A maintenance-free coupling (elastomeric or disc)","A grid coupling","Any coupling"],"correctIndex":1},{"question":"What must be installed before operating equipment with a coupling?","options":["Nothing","The coupling guard — the rotating coupling is a serious entanglement hazard","A speed sensor","A torque sensor"],"correctIndex":1}]'::jsonb
  WHERE title = 'Gear, Grid, Elastomeric & Disc Couplings' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
A key transmits torque between the shaft and the hub. The key width, length, and material must be sufficient to transmit the torque without exceeding the allowable compressive stress. Understanding key sizing and shaft repair is essential for maintaining power transmission systems.

## Key Concepts
- **Key width** is typically one-quarter of the shaft diameter (for square keys up to 1/4 inch) and follows the shaft diameter per standards (ANSI B17.1, DIN 6885).
- **Key length** must be sufficient to transmit the torque without exceeding the allowable compressive stress on the key and the shaft keyway.
- **A sheared key** indicates an overload or a loose fit — always inspect the keyway for damage and repair if the corners are rounded.
- **Shaft repair options:** Build-up by welding and machining, thermal spray, or sleeving. After any repair, check runout at the bearing journals and the coupling fit.
- **Never file a key to fit** — it creates a loose fit that will shear under load.

## Step-by-Step: Key Sizing and Shaft Keyway Repair
1. **Determine the key size** from the shaft diameter per the standard (ANSI B17.1 or DIN 6885). The key width is typically 1/4 of the shaft diameter.
2. **Calculate the minimum key length:** Length = (Torque × safety factor) / (key width × shaft radius × allowable stress). Use a safety factor of 2-3.
3. **Verify the key material** is compatible with the shaft and the hub — a key that is harder than the shaft will wear the shaft keyway.
4. **For a worn keyway:** Broach an oversized keyway or use a double key arrangement 180 degrees apart.
5. **For a worn shaft journal:** Build up by welding, thermal spray, or sleeving. Machine to size and check runout.
6. **After any shaft repair:** Check runout at the bearing journals, the coupling fit, and the impeller fit. A repaired shaft that is not straight will destroy bearings.

## Common Problems and Fixes
- **Key shears repeatedly:** Overload or a loose fit. Verify the torque does not exceed the key capacity, and verify the key fit is not loose (no filing).
- **Keyway is damaged (rounded corners):** The key was loose and hammered the keyway. Broach an oversized keyway and use an oversized key.
- **Shaft is worn at the journal:** Build up by welding or thermal spray, machine to size, and check runout.
- **Shaft is bent:** Straighten in a press (if minor) or replace (if major). A bend greater than 0.5 mm/m should not be straightened.

## Best Practices and Field Tips
- Always use a key cut to the correct size — never file a key to fit, as it creates a loose fit that will shear.
- For high-torque applications, use a double key 180 degrees apart to share the load and reduce the stress on each key.
- After any shaft repair, document the pre- and post-repair measurements for future reference.
- For critical shafts, keep a spare — the lead time for a new shaft can be weeks.

## Safety Notes
- Never file a key with bare hands near rotating equipment — a key can catch and pull in the hand.
- A shaft being pressed can fracture — use a press guard and stand to the side.',
   quiz =
'[{"question":"What is the typical key width for a square key?","options":["One-eighth of the shaft diameter","One-quarter of the shaft diameter","One-half of the shaft diameter","Equal to the shaft diameter"],"correctIndex":1},{"question":"What does a sheared key typically indicate?","options":["Proper lubrication","Overload or a loose fit","Correct sizing","Normal wear"],"correctIndex":1},{"question":"What should never be done to make a key fit?","options":["Use a larger key","File it to fit — it creates a loose fit that will shear under load","Use a press","Use a hammer"],"correctIndex":1},{"question":"What should be done for a worn keyway?","options":["Ignore it","Broach an oversized keyway or use a double key arrangement 180 degrees apart","Replace the shaft","Use a smaller key"],"correctIndex":1},{"question":"What must be checked after any shaft repair?","options":["Nothing","Runout at the bearing journals, coupling fit, and impeller fit","The key size","The coupling color"],"correctIndex":1},{"question":"What is used for high-torque applications to reduce stress on each key?","options":["A larger key","A double key 180 degrees apart to share the load","A longer key","A harder key"],"correctIndex":1},{"question":"What bend should not be straightened?","options":["Any bend","A bend greater than 0.5 mm/m","A bend less than 0.1 mm/m","All bends should be straightened"],"correctIndex":1}]'::jsonb
  WHERE title = 'Key Sizing & Shaft Repair' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Install a coupling by first cleaning the shafts and hubs, checking the bore fit, and performing the alignment. A coupling that is installed correctly and aligned to specification will run for years; one that is hammered on and misaligned will fail in weeks.

## Key Concepts
- **Bore fit:** A clearance fit allows the hub to slide on by hand; an interference fit requires heating the hub (induction or oil bath) to 150-200°F above shaft temperature.
- **Never use a hammer** to drive a coupling onto a shaft — it damages the bearings and the coupling.
- **Dial indicator alignment:** Mount the indicator on one hub and read the other, rotate 360°, and correct angular and parallel misalignment to within the coupling manufacturer tolerance.
- **Coupling balance:** A coupling that has been repaired or re-bored must be re-balanced. Check by running the machine uncoupled and then coupled — a significant vibration increase when coupled indicates coupling imbalance or misalignment.
- **Coupling guard:** Must be installed before the machine runs.

## Step-by-Step: Coupling Installation and Alignment
1. **Clean the shafts and the coupling hubs** to remove all preservative and burrs.
2. **Check the bore fit:** If interference, heat the hub with an induction heater or an oil bath to 150-200°F above the shaft temperature. If clearance, slide the hub on by hand.
3. **Install the coupling halves** on each shaft and tighten the set screws or the clamping bolts.
4. **Rough-align** using a straightedge across the coupling hub faces. Get within 0.5 mm.
5. **Check and correct soft-foot** on both machines before the precision alignment.
6. **Mount the dial indicator** (or laser system) and perform the full alignment procedure. Correct angular misalignment first, then parallel.
7. **Torque all bolts** and re-check the alignment. Document the final values.
8. **Install the coupling guard** before returning the machine to service.
9. **Run the machine** and verify the vibration is within tolerance — a high vibration when coupled indicates coupling imbalance or residual misalignment.

## Common Problems and Fixes
- **Coupling will not slide on the shaft:** The bore is too small (interference fit). Heat the hub or verify the bore is correct.
- **Coupling vibrates after installation:** The coupling is unbalanced (re-bored or repaired) or the alignment is not within tolerance. Re-balance or re-align.
- **Coupling overheats:** Misalignment generating friction heat. Re-check the alignment.
- **Set screws back out:** The set screws were not tightened properly or the shaft has a flat for the set screw that is not correctly positioned. Use a new set screw and tighten to the specified torque.

## Best Practices and Field Tips
- Always use an induction heater for interference-fit couplings — an open flame (torch) can overheat the hub and destroy the metallurgy.
- After installing a coupling that was repaired or re-bored, verify the balance by running the machine uncoupled and then coupled.
- Document the alignment values, the coupling type, and the bore size for each drive train for future reference.
- Use a torque wrench on all coupling bolts — a bolt tightened by feel can back out or be over-tightened.

## Safety Notes
- Never use a hammer to install a coupling — it damages the bearings and can cause the coupling to crack.
- Never rotate the shafts with the coupling guard removed and the motor energized — lock out the motor first.
- An induction heater can heat the hub to skin-burning temperatures — use heat-resistant gloves.',
   quiz =
'[{"question":"What temperature range is used to heat a hub for an interference fit?","options":["50-100°F above shaft temperature","150-200°F above shaft temperature","300-400°F above shaft temperature","Room temperature is sufficient"],"correctIndex":1},{"question":"What should never be used to install a coupling on a shaft?","options":["A hydraulic press","A hammer","An induction heater","An oil bath"],"correctIndex":1},{"question":"What should be corrected before precision alignment?","options":["The coupling grease","Soft-foot on both machines","The bearing clearance","The lubricant viscosity"],"correctIndex":1},{"question":"What does a significant vibration increase when the machine is coupled (vs uncoupled) indicate?","options":["Normal operation","Coupling imbalance or misalignment","The motor is oversized","The bearing is worn"],"correctIndex":1},{"question":"What should be installed before returning the machine to service?","options":["A new motor","The coupling guard","A vibration sensor","A flow meter"],"correctIndex":1},{"question":"What should be used to heat a hub for interference fit, not an open flame?","options":["A hammer","An induction heater — an open flame can overheat the hub and destroy the metallurgy","A torch","Steam"],"correctIndex":1},{"question":"What should be used on all coupling bolts?","options":["A wrench by feel","A torque wrench — a bolt tightened by feel can back out or be over-tightened","An impact wrench","Nothing"],"correctIndex":1}]'::jsonb
  WHERE title = 'Coupling Installation & Balance' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 9. VIBRATION ANALYSIS FUNDAMENTALS =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Vibration Analysis Fundamentals';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Vibration Diagnosis & Program Building', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Advanced Spectrum Analysis & Time Waveform',
   '## Overview
The frequency spectrum (FFT) is the primary diagnostic tool, but the time waveform provides additional information that the spectrum cannot. Understanding both and when to use each is the mark of an experienced vibration analyst.

## Key Concepts
- **Time waveform** shows the actual vibration signal over time — it reveals impacts, beats, and modulation that the FFT averages out.
- **FFT spectrum** shows the frequency content — it identifies the source (imbalance, misalignment, bearing defect) by the frequency.
- **Order analysis** normalizes the frequency to the running speed (1x, 2x, 3x) so readings at different speeds are comparable — essential for variable-speed machines.
- **Envelope analysis** (demodulation) extracts the high-frequency impact signals (bearing defects) from the low-frequency background — it amplifies the bearing defect signal.
- **Phase analysis** measures the relationship between two points — it distinguishes imbalance (phase is consistent across the machine) from misalignment (phase shifts across the coupling) and looseness (phase shifts 90° or 180° across the loose component).

## Step-by-Step: Advanced Vibration Diagnosis
1. **Collect the time waveform and the FFT spectrum** at each bearing housing in the radial and axial directions.
2. **Examine the FFT spectrum first:** Identify the dominant frequency — 1x (imbalance), 2x (misalignment), broadband (looseness), or bearing defect frequencies.
3. **If the FFT is inconclusive, examine the time waveform:** Look for impacts (sharp spikes), beats (amplitude modulation), and truncation (clipping of the waveform).
4. **For bearing diagnosis:** Use envelope analysis to extract the bearing defect frequencies from the background noise. Compare the envelope spectrum to the calculated BPFO, BPFI, BSF, and FTF.
5. **For phase analysis:** Mount two sensors on opposite sides of the coupling and measure the phase difference. A phase shift of 180° across the coupling indicates misalignment; a phase shift of 90° or 180° across a component indicates looseness.
6. **For variable-speed machines:** Use order analysis — normalize the frequencies to 1x, 2x, 3x so the readings are comparable across the speed range.

## Common Problems and Fixes
- **FFT shows no clear peaks but the machine vibrates:** The vibration is non-periodic (impacts, rubs). Examine the time waveform for impact patterns.
- **Bearing defect frequency is not visible in the FFT:** The defect is in its early stage. Use envelope analysis to extract the high-frequency impact signal.
- **Vibration is different at different speeds:** Structural resonance at a specific speed. Identify the resonant speed with a bump test and program the VFD to skip it.
- **Phase analysis is inconsistent:** The sensor mounting is not repeatable, or the machine has multiple vibration sources. Verify the mounting and collect at the same operating condition.

## Best Practices and Field Tips
- Always collect both the FFT and the time waveform — the FFT identifies the frequency, the waveform reveals the nature (impact, beat, modulation).
- Use envelope analysis for early bearing diagnosis — it detects defects months before the standard FFT.
- Perform a bump test to identify structural resonances — a machine that vibrates at a specific speed is likely at a resonance.
- Document the spectra and the diagnosis for each machine — it builds a reference library for future comparisons.

## Safety Notes
- Never collect vibration data on a machine with the coupling guard removed — the sensor cable can catch in the rotating coupling.
- High-vibration machines can fail during data collection — be prepared to shut down if the vibration increases rapidly.',
   55, 1,
   '[{"question":"What does the time waveform reveal that the FFT spectrum does not?","options":["The frequency content","Impacts, beats, and modulation that the FFT averages out","The amplitude only","The phase"],"correctIndex":1},{"question":"What does envelope analysis do?","options":["Measures the overall vibration","Extracts high-frequency impact signals (bearing defects) from the low-frequency background","Measures the temperature","Measures the speed"],"correctIndex":1},{"question":"What does a phase shift of 180° across a coupling indicate?","options":["Imbalance","Misalignment","Looseness","Bearing defect"],"correctIndex":1},{"question":"What should be done if the FFT shows no clear peaks but the machine vibrates?","options":["Replace the FFT analyzer","Examine the time waveform for non-periodic impacts, rubs, or modulation","Ignore it","Increase the resolution"],"correctIndex":1},{"question":"How is a structural resonance identified?","options":["From the FFT","With a bump test — a machine that vibrates at a specific speed is likely at a resonance","From the time waveform","From the phase"],"correctIndex":1},{"question":"What is order analysis used for?","options":["For fixed-speed machines only","For variable-speed machines — normalizes frequencies to 1x, 2x, 3x so readings are comparable across speeds","For bearing diagnosis","For temperature measurement"],"correctIndex":1},{"question":"What does a bearing defect frequency that is not visible in the standard FFT indicate?","options":["No bearing defect","The defect is in its early stage — use envelope analysis to extract it","The bearing is healthy","The FFT is faulty"],"correctIndex":1}]'::jsonb),
  (m_id, 'Building a Vibration Monitoring Program',
   '## Overview
A vibration monitoring program is the systematic collection and analysis of vibration data on all critical rotating equipment. The program catches failures early, schedules repairs during planned outages, and eliminates unnecessary PMs on healthy equipment. Building and maintaining the program is the responsibility of the reliability team.

## Key Concepts
- **Route-based monitoring:** A technician walks a predefined route with a portable data collector, collecting data at marked points on each machine at a set interval (monthly for critical, quarterly for less critical).
- **Continuous monitoring:** Permanently installed sensors on critical machines that transmit data to a central system — provides real-time alerts and trend data without a route.
- **Alarm thresholds:** Based on ISO 10816 for overall velocity (4.5 mm/s warning, 7.1 mm/s danger for most machines) and on the rate of change for specific defect frequencies.
- **Database management:** The vibration data is stored in a database that trends the overall, the spectrum, and the specific defect frequencies over time for each machine.
- **Reporting:** The program generates a report listing the machines in alarm, the diagnosis, and the recommended action (monitor, schedule repair, immediate repair).

## Step-by-Step: Building a Vibration Monitoring Program
1. **List all critical rotating machines** and assign a criticality rating (A, B, or C).
2. **Define the measurement points** on each machine (usually the bearing housings in the radial and axial directions). Mark each point with paint or a stamped dot.
3. **Define the monitoring interval:** Monthly for A-critical, quarterly for B-critical, semi-annually for C-critical.
4. **Set the alarm thresholds:** ISO 10816 for overall velocity, and a rate-of-change alarm for specific defect frequencies (a frequency that doubles over two measurements triggers an alarm).
5. **Build the route** in the data collector: the machine list, the measurement points, the sensor type, and the measurement parameters (frequency range, resolution).
6. **Collect the baseline data** on each machine at normal operating load.
7. **Analyze the baseline** and document the reference spectrum for each machine.
8. **Generate the first report** and review with the maintenance team.
9. **Trend the data** over time and generate monthly reports listing the machines in alarm and the recommended actions.

## Common Problems and Fixes
- **Data is not consistent between routes:** The measurement point is not marked, or the machine operating condition varies. Mark the points and collect at the same load.
- **Alarms are ignored:** The program is not integrated with the CMMS. Generate CMMS work orders from the vibration alarms.
- **Too many alarms:** The alarm thresholds are too low. Adjust the thresholds based on the baseline data and the machine history.
- **Program loses momentum:** The reports are not reviewed with the maintenance team. Schedule a monthly review meeting to discuss the findings and the actions.

## Best Practices and Field Tips
- Start with the A-critical machines and expand to B and C as the program matures — do not try to monitor every machine from day one.
- Integrate the vibration program with the CMMS — a vibration alarm generates a work order automatically.
- Train the technicians to collect consistent data — the same sensor, the same mounting, the same machine operating condition.
- The program pays for itself by catching failures early and eliminating unnecessary PMs on healthy equipment.

## Safety Notes
- Never collect data on a machine with the coupling guard removed — the sensor cable can catch in the rotating coupling.
- Be aware of high-vibration machines during data collection — be prepared to shut down if the vibration increases rapidly.',
   55, 2,
   '[{"question":"What is the difference between route-based and continuous monitoring?","options":["They are the same","Route-based uses a portable collector at set intervals; continuous uses permanent sensors with real-time alerts","Route-based is more accurate","Continuous is cheaper"],"correctIndex":1},{"question":"What are the ISO 10816 alarm levels for most industrial machines?","options":["2.8 mm/s warning, 4.5 mm/s danger","4.5 mm/s warning, 7.1 mm/s danger","7.1 mm/s warning, 11.2 mm/s danger","1 mm/s warning, 2 mm/s danger"],"correctIndex":1},{"question":"What triggers a rate-of-change alarm for a specific defect frequency?","options":["Any presence of the frequency","A frequency that doubles over two consecutive measurements","A frequency that appears once","Any frequency above 1x"],"correctIndex":1},{"question":"How should the program be started?","options":["Monitor every machine from day one","Start with A-critical machines and expand as the program matures","Start with C-critical machines","Start with all machines simultaneously"],"correctIndex":1},{"question":"How should the vibration program be integrated with maintenance workflow?","options":["It should not be integrated","Integrate with the CMMS — a vibration alarm generates a work order automatically","Through email only","Through paper reports only"],"correctIndex":1},{"question":"What should be done to ensure consistent data between routes?","options":["Use different sensors each time","Mark the measurement points and collect at the same machine operating condition","Collect at random locations","Collect at different loads"],"correctIndex":1},{"question":"What is the primary benefit of a vibration monitoring program?","options":["It replaces all PMs","It catches failures early, schedules repairs during planned outages, and eliminates unnecessary PMs on healthy equipment","It is required by law","It reduces the motor size"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons with structured content and expanded quizzes
  UPDATE lessons SET content =
'## Overview
Vibration is characterized by frequency (how fast), amplitude (how much), and phase (the relationship between two points). Understanding these three parameters and how to measure them is the foundation of vibration analysis for predictive maintenance.

## Key Concepts
- **Accelerometers** are the most common industrial sensor — they measure acceleration in g and convert to velocity (mm/s) or displacement (microns) mathematically.
- **Mounting:** Mount the sensor on a flat, clean surface at the bearing housing, radially for most machines. The mounting method (stud, magnet, handheld) affects the frequency range.
- **Frequency spectrum (FFT):** The x-axis is frequency (Hz or CPM), the y-axis is amplitude. Peaks at specific frequencies identify the source of vibration.
- **Overall vibration amplitude (ISO 10816 velocity):** The first alarm — a single number that indicates the total vibration level. The spectrum then identifies the cause.
- **Phase:** The relationship between two vibration points. Phase analysis distinguishes imbalance, misalignment, and looseness.

## Step-by-Step: Vibration Data Collection
1. **Identify the measurement point** on the bearing housing and mark it with paint or a stamped dot for repeatability.
2. **Clean the mounting surface** — dirt or paint under the sensor affects the high-frequency response.
3. **Mount the sensor** with a stud (best), a magnet (good), or a handheld probe (acceptable for low frequency only).
4. **Set the analyzer parameters:** frequency range (typically 0-1000 Hz for general machines, 0-5000 Hz for high-speed or gearboxes), resolution (800 lines for general, 1600+ for detailed analysis).
5. **Collect the overall velocity** and compare to the ISO 10816 alarm levels (4.5 mm/s warning, 7.1 mm/s danger).
6. **Collect the FFT spectrum** and identify the dominant frequency.
7. **Record the data** in the database with the machine ID, the measurement point, the date, and the operating condition (speed, load).

## Common Problems and Fixes
- **Data is not repeatable:** The measurement point is not marked, or the sensor mounting varies. Mark the point and use the same mounting method.
- **High-frequency data is missing:** The sensor mounting is inadequate (handheld probe or dirty surface). Use a stud or a magnet mount and clean the surface.
- **Overall is normal but the machine has a problem:** The overall is dominated by a low-frequency component (imbalance) that masks a high-frequency component (bearing defect). Examine the spectrum, not just the overall.
- **Data is different at different loads:** The machine operating condition affects the vibration. Always collect at the same load and speed.

## Best Practices and Field Tips
- Always measure in the same location and direction for trending consistency — mark the measurement point.
- Use a stud mount for high-frequency analysis (bearing diagnostics) — a magnet or handheld mount attenuates the high frequencies.
- Collect data at the normal operating load — data at part load is not comparable to data at full load.
- Record the machine operating condition (speed, load, temperature) with every measurement — it provides context for the data.

## Safety Notes
- Never collect vibration data on a machine with the coupling guard removed — the sensor cable can catch in the rotating coupling.
- Be aware of hot surfaces on machines at operating temperature — use heat-resistant gloves if needed.',
   quiz =
'[{"question":"What are the three parameters that characterize vibration?","options":["Speed, torque, power","Frequency, amplitude, and phase","Voltage, current, resistance","Pressure, flow, temperature"],"correctIndex":1},{"question":"What is the most common industrial vibration sensor type?","options":["Velocity probe","Displacement probe","Accelerometer","Proximity probe"],"correctIndex":2},{"question":"Where should the vibration sensor be mounted?","options":["On the motor frame","On a flat, clean surface at the bearing housing, radially","On the coupling guard","On the baseplate"],"correctIndex":1},{"question":"What are the ISO 10816 alarm levels for most industrial machines?","options":["2.8 mm/s warning, 4.5 mm/s danger","4.5 mm/s warning, 7.1 mm/s danger","7.1 mm/s warning, 11.2 mm/s danger","1 mm/s warning, 2 mm/s danger"],"correctIndex":1},{"question":"Why should the measurement point be marked?","options":["For appearance","For trending consistency — a measurement at a different point is not comparable","For safety","It is required by ISO"],"correctIndex":1},{"question":"What should be used for high-frequency bearing diagnostics?","options":["A handheld probe","A magnet mount","A stud mount — magnet or handheld attenuates high frequencies","Any mounting method"],"correctIndex":2},{"question":"Why should data be collected at the normal operating load?","options":["For convenience","Data at part load is not comparable to data at full load","For safety","It is faster"],"correctIndex":1}]'::jsonb
  WHERE title = 'Sensors, Frequency & Amplitude' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Reading a vibration spectrum is like reading a fingerprint. Each vibration source produces a characteristic frequency pattern. Learning to identify these patterns is the core skill of vibration analysis — it turns a vibration reading into a diagnosis.

## Key Concepts
- **1x RPM peak:** Imbalance or eccentricity. The amplitude is proportional to the imbalance and the speed squared.
- **2x RPM peak:** Angular misalignment or mechanical looseness. A 2x peak that is 50-100% of the 1x peak indicates angular misalignment.
- **3x or 4x peaks:** Mechanical looseness (bolts, bearing fit, cracked foot). Multiple harmonics of 1x indicate looseness.
- **Sub-synchronous peaks (below 1x):** Oil whirl, belt flap, or a rub. A peak at 0.43x-0.48x indicates oil whirl in a sleeve bearing.
- **Bearing defect frequencies:** BPFO (outer race), BPFI (inner race), BSF (ball spin), and FTF (cage frequency). Calculated from the bearing geometry and the running speed.
- **Broad noise floor (the haystack):** Advanced bearing degradation — the defect has spread from a single point to the entire race.

## Step-by-Step: Spectrum Interpretation
1. **Identify the running speed** (1x frequency) from the spectrum — it is the first major peak. Verify it matches the actual RPM.
2. **Examine the 1x peak:** If it is the dominant peak, the machine has imbalance. The amplitude indicates the severity.
3. **Examine the 2x peak:** If it is 50-100% of the 1x peak, the machine has angular misalignment. If it is much smaller, misalignment is not the issue.
4. **Examine for harmonics (3x, 4x, 5x):** Multiple harmonics indicate mechanical looseness. Check foundation bolts, bearing fit, and impeller hub tightness.
5. **Examine the sub-synchronous region:** Peaks below 1x indicate oil whirl, belt flap, or a rub.
6. **Calculate the bearing defect frequencies** using the bearing part number and the running speed. Look for peaks at these frequencies.
7. **A bearing defect frequency with sidebands** indicates the defect is spreading from a single point to the entire race.
8. **Compare to the previous spectrum** — a new peak that grows is the early warning of a developing fault.

## Common Problems and Fixes
- **Spectrum is dominated by 1x but the machine was recently balanced:** Check for eccentricity (a pulley or a coupling that is not concentric) or a bent shaft.
- **2x peak is present but the alignment is within tolerance:** Check for a loose coupling hub or a loose bearing fit — these produce 2x peaks similar to misalignment.
- **Bearing defect frequency appears but the overall is normal:** The defect is in its early stage. Schedule a follow-up measurement in 2-4 weeks.
- **Spectrum has many peaks and is difficult to interpret:** The machine may have multiple vibration sources. Use phase analysis to isolate each source.

## Best Practices and Field Tips
- Always verify the 1x frequency matches the actual RPM — a spectrum where the 1x does not match the speed has a different reference.
- Compare spectra over time — a new peak that grows is more significant than a peak that has been stable for months.
- Use a bearing fault frequency calculator (built into most analyzers) — input the bearing part number and the speed.
- For gearboxes, examine the gear mesh frequency (number of teeth × RPM) and its sidebands — sidebands indicate gear wear.

## Safety Notes
- Never open an inspection cover on a running machine to inspect a suspected bearing defect — the rotating components can cause injury.
- A machine with a rapidly growing bearing defect frequency can fail at any time — schedule the repair immediately.',
   quiz =
'[{"question":"What does a 1x RPM dominant peak typically indicate?","options":["Misalignment","Imbalance or eccentricity","Bearing defect","Looseness"],"correctIndex":1},{"question":"What does a 2x peak that is 50-100% of the 1x peak indicate?","options":["Imbalance","Angular misalignment","Bearing defect","Oil whirl"],"correctIndex":1},{"question":"What do multiple harmonics (3x, 4x, 5x) indicate?","options":["Imbalance","Misalignment","Mechanical looseness — check bolts, bearing fit, and impeller hub","Bearing defect"],"correctIndex":2},{"question":"What does a broad noise floor (the haystack) in the spectrum indicate?","options":["Normal operation","Early bearing degradation","Advanced bearing degradation — the defect has spread","Looseness"],"correctIndex":2},{"question":"What do bearing defect frequencies with sidebands indicate?","options":["Normal wear","The defect is spreading from a single point to the entire race","The bearing is healthy","The bearing is new"],"correctIndex":1},{"question":"What does a peak at 0.43x-0.48x indicate?","options":["Imbalance","Oil whirl in a sleeve bearing","Bearing defect","Looseness"],"correctIndex":1},{"question":"What should be done when a bearing defect frequency appears but the overall vibration is normal?","options":["Ignore it","Schedule a follow-up measurement in 2-4 weeks — the defect is in its early stage","Shut down immediately","Replace the bearing"],"correctIndex":1}]'::jsonb
  WHERE title = 'Spectrum Interpretation' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Each common rotating equipment fault produces a characteristic vibration signature. Recognizing these signatures and knowing the corrective action is the practical application of vibration analysis — it turns a diagnosis into a repair plan.

## Key Concepts
- **Imbalance:** Pure 1x vibration in the radial direction. Correct by balancing — add or remove weight opposite the heavy spot. The amplitude is proportional to the imbalance and the speed squared.
- **Misalignment:** 1x and 2x peaks, often with high axial vibration (axial exceeds 50% of radial). Correct by laser alignment.
- **Mechanical looseness:** Multiple harmonics (1x, 2x, 3x, 4x) with direction-dependent amplitude. Check foundation bolts, bearing fit, and coupling hub tightness.
- **Bearing defects:** Characteristic frequencies (BPFO, BPFI, BSF, FTF). BPFO appears first in most bearings. A doubling in amplitude over two measurements warrants scheduling a replacement.
- **Belt issues:** 1x and 2x of the belt frequency (not the RPM) indicate belt problems. Sub-synchronous peaks indicate belt flap.

## Step-by-Step: Fault Diagnosis and Correction
1. **Collect the vibration data** at each bearing housing in the radial and axial directions.
2. **Examine the FFT spectrum** and identify the dominant frequency.
3. **If 1x is dominant (imbalance):** Schedule a balance job. Verify the impeller is clean (dust buildup causes imbalance). After balancing, the 1x amplitude should drop by 80% or more.
4. **If 2x is 50-100% of 1x (misalignment):** Schedule a laser alignment. Check and correct soft-foot first. After alignment, the 2x amplitude should drop significantly.
5. **If multiple harmonics (looseness):** Check all foundation bolts, bearing fit, and coupling hub. Tighten any loose components. After tightening, the harmonics should reduce.
6. **If bearing defect frequencies are present:** Calculate the expected frequencies from the bearing part number. If the amplitude doubles over two measurements, schedule a bearing replacement.
7. **If sub-synchronous peaks are present:** Check for oil whirl (sleeve bearings), belt flap (belt drives), or a rub.
8. **Document the diagnosis and the corrective action** in the CMMS for trend analysis.

## Common Problems and Fixes
- **Imbalance correction does not reduce the vibration:** The imbalance is not the only problem — check for misalignment or looseness (which also produce 1x).
- **Misalignment correction does not reduce the 2x peak:** The 2x is from a loose coupling hub or a loose bearing fit, not misalignment. Tighten the hub or the bearing.
- **Bearing replacement does not reduce the bearing defect frequency:** The defect frequency was from a different bearing (e.g., the non-drive end bearing, not the drive end). Verify which bearing is defective.
- **Vibration is high but the spectrum shows no clear peaks:** The vibration may be from an external source (a nearby machine). Check if the vibration is present when the machine is off.

## Best Practices and Field Tips
- Always verify the diagnosis by comparing the spectrum before and after the corrective action — the amplitude of the identified frequency should drop.
- For imbalance, the balance job should reduce the 1x by 80% or more — if it does not, the diagnosis was wrong or the balance job was incomplete.
- For bearing defects, use envelope analysis for early detection — it catches defects months before the standard FFT.
- Trend the data and set alarm thresholds based on the rate of change — a frequency that doubles over two measurements is more significant than the absolute value.

## Safety Notes
- Never perform a balance job with the coupling guard removed and the machine running — use a portable balancer that does not require removing the guard.
- A machine with a rapidly growing bearing defect can fail at any time — schedule the repair immediately and monitor continuously.',
   quiz =
'[{"question":"What does imbalance produce in the vibration spectrum?","options":["Multiple harmonics","A pure 1x vibration in the radial direction","High axial vibration","Sub-synchronous peaks"],"correctIndex":1},{"question":"What does misalignment produce?","options":["A pure 1x peak","1x and 2x peaks, often with high axial vibration (axial exceeds 50% of radial)","Sub-synchronous peaks","A broad noise floor"],"correctIndex":1},{"question":"What does mechanical looseness produce?","options":["A single 1x peak","Multiple harmonics (1x, 2x, 3x, 4x) with direction-dependent amplitude","A 2x peak only","Sub-synchronous peaks"],"correctIndex":1},{"question":"Which bearing defect frequency typically appears first?","options":["BPFI (inner race)","BPFO (outer race)","BSF (ball spin)","FTF (cage)"],"correctIndex":1},{"question":"What should a bearing defect frequency that doubles over two measurements warrant?","options":["Immediate shutdown","Scheduling a bearing replacement","Re-lubrication only","No action"],"correctIndex":1},{"question":"What should happen to the 1x amplitude after a successful balance job?","options":["It stays the same","It should drop by 80% or more","It increases","It drops by 10%"],"correctIndex":1},{"question":"What should be checked if vibration is high but the spectrum shows no clear peaks?","options":["Replace the FFT analyzer","The vibration may be from an external source — check if it is present when the machine is off","Replace the bearing","Re-balance"],"correctIndex":1}]'::jsonb
  WHERE title = 'Imbalance, Misalignment, Looseness & Bearing Defects' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 10. THERMOGRAPHY FOR MECHANICAL MAINTENANCE =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Thermography for Mechanical Maintenance';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Thermography Program Management & Reporting', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Building a Thermography Inspection Program',
   '## Overview
A thermography inspection program uses periodic infrared surveys to detect mechanical and electrical problems before they cause failures. Building and maintaining the program requires planning, consistent data collection, and effective reporting.

## Key Concepts
- **Inspection route:** A predefined list of equipment to inspect, with marked measurement points and reference images for comparison.
- **Inspection interval:** Quarterly for critical equipment, semi-annually for less critical. The interval may be adjusted based on findings.
- **Baseline images:** A thermal image of each component in good condition for comparison — a change from the baseline is the first sign of a problem.
- **Delta temperature:** The difference between the component temperature and a reference point (an adjacent bearing, the ambient). The delta is more meaningful than the absolute temperature because it compensates for ambient changes.
- **Reporting:** Each inspection generates a report with the thermal image, the visible photo, the hot spot temperature, the reference temperature, the delta, and the recommended action.

## Step-by-Step: Building a Thermography Program
1. **List all critical mechanical and electrical equipment** and assign a priority (A, B, or C).
2. **Define the inspection points** on each machine (bearings, couplings, motors, electrical connections). Mark each point for repeatability.
3. **Collect baseline images** of each point in good condition. Store them in the database for comparison.
4. **Define the inspection interval:** Quarterly for A-priority, semi-annually for B, annually for C.
5. **Set alarm thresholds:** A delta of 15°C above a similar component under similar load is a warning; 30°C is a danger.
6. **Build the route** in the camera or the software: the equipment list, the inspection points, and the reference images.
7. **Perform the first inspection** and generate the report.
8. **Review the report** with the maintenance team and generate work orders for the findings.
9. **Trend the delta temperatures** over time — a rising delta indicates worsening condition.

## Common Problems and Fixes
- **Thermal images are not comparable between inspections:** The camera settings (emissivity, temperature range) are different. Standardize the settings and save them with each image.
- **Program loses momentum:** The reports are not reviewed with the maintenance team. Schedule a monthly review meeting.
- **Too many findings:** The alarm thresholds are too low. Adjust based on the baseline data and the equipment history.
- **Findings are not acted on:** The program is not integrated with the CMMS. Generate CMMS work orders from the thermography findings.

## Best Practices and Field Tips
- Inspect under normal operating load — a machine at rest shows nothing.
- Save the thermal image with the temperature scale visible and annotate the hot spot, the reference, and the delta.
- Use the same camera settings (emissivity, range) for every inspection of the same component.
- Combine thermography with vibration and oil analysis for the most comprehensive condition assessment.

## Safety Notes
- Never inspect energized electrical equipment without the appropriate PPE and training — thermography of electrical panels requires arc-flash PPE.
- Hot surfaces can cause burns — maintain a safe distance or use a telephoto lens.',
   50, 1,
   '[{"question":"What is the recommended inspection interval for A-priority equipment?","options":["Monthly","Quarterly","Annually","Every 5 years"],"correctIndex":1},{"question":"What is more meaningful than the absolute temperature in thermography?","options":["The ambient temperature","The delta temperature — the difference between the component and a reference point","The camera settings","The emissivity"],"correctIndex":1},{"question":"What delta temperature is a warning threshold?","options":["5°C above a similar component","15°C above a similar component under similar load","50°C above ambient","100°C above ambient"],"correctIndex":1},{"question":"Why are thermal images sometimes not comparable between inspections?","options":["The camera is different","The camera settings (emissivity, temperature range) are different — standardize and save them","The weather is different","The equipment changed"],"correctIndex":1},{"question":"How should the thermography program be integrated with maintenance workflow?","options":["It should not be","Generate CMMS work orders from the thermography findings","Through email only","Through paper reports"],"correctIndex":1},{"question":"What should be done to ensure comparable thermal images?","options":["Use different cameras","Use the same camera settings (emissivity, range) for every inspection of the same component","Inspect at different loads","Inspect at different times of day"],"correctIndex":1},{"question":"Under what condition must the equipment be for a meaningful thermography inspection?","options":["At rest","Under normal operating load — a machine at rest shows nothing","Cold","Disconnected"],"correctIndex":1}]'::jsonb),
  (m_id, 'Reporting, Documentation & Trend Analysis',
   '## Overview
A thermography finding is only valuable if it is documented, reported, and acted on. Effective reporting and trend analysis turn a thermal image into a maintenance action and a reliability improvement.

## Key Concepts
- **Report content:** Each finding includes the thermal image, the visible photo, the equipment tag, the hot spot temperature, the reference temperature, the delta, the diagnosis, and the recommended action.
- **Severity classification:** Low (delta < 15°C, monitor at next inspection), Medium (delta 15-30°C, schedule repair at next opportunity), High (delta > 30°C, repair immediately).
- **Trend analysis:** The delta temperature for each component is trended over time. A rising delta indicates worsening condition and helps predict the time to failure.
- **Before-and-after comparison:** After a repair, a new thermal image verifies the fix — the delta should return to the baseline.
- **Database management:** All thermal images, reports, and trends are stored in a database for historical comparison and audit.

## Step-by-Step: Thermography Reporting
1. **Capture the thermal image** with the temperature scale visible and the hot spot marked.
2. **Capture a visible-light photo** of the same component for identification.
3. **Measure the hot spot temperature** and the reference temperature (an adjacent bearing or the ambient).
4. **Calculate the delta** (hot spot minus reference).
5. **Classify the severity:** Low (< 15°C), Medium (15-30°C), High (> 30°C).
6. **Write the diagnosis** — what the thermal pattern indicates (bearing distress, loose connection, restricted flow, etc.).
7. **Write the recommended action** — monitor, schedule repair, or repair immediately.
8. **Generate the report** in the software or on a standard form.
9. **Submit the report** to the maintenance team and generate a CMMS work order for Medium and High findings.
10. **After the repair, take a new thermal image** and compare to the baseline to verify the fix.

## Common Problems and Fixes
- **Report is not acted on:** The report is not integrated with the CMMS. Generate work orders directly from the findings.
- **Trend data is lost:** The images are stored on the camera, not in a database. Download the images to the database after each inspection.
- **Findings are inconsistent:** The camera settings or the inspection conditions vary. Standardize the settings and inspect at the same load.
- **Before-and-after shows no improvement:** The repair did not address the root cause. Re-investigate and re-repair.

## Best Practices and Field Tips
- Use a standard report template for consistency — every report has the same fields in the same order.
- Include the baseline image alongside the current image in the report for immediate visual comparison.
- Trend the delta for each component on a simple chart — a rising trend is more convincing than a single reading.
- Review the reports monthly with the maintenance team to ensure findings are acted on.

## Safety Notes
- Thermography reports are quality records — store them securely and control access.
- When performing before-and-after verification, the same safety precautions apply as during the initial inspection.',
   50, 2,
   '[{"question":"What is the severity classification for a delta of 20°C?","options":["Low (monitor)","Medium (schedule repair at next opportunity)","High (repair immediately)","No action"],"correctIndex":1},{"question":"What is the severity classification for a delta of 35°C?","options":["Low","Medium","High (repair immediately)","No action"],"correctIndex":2},{"question":"What should be done after a repair to verify the fix?","options":["Nothing","Take a new thermal image and compare to the baseline — the delta should return to baseline","Replace the camera","Re-balance the machine"],"correctIndex":1},{"question":"What does a rising delta temperature trend indicate?","options":["Improved condition","Worsening condition — helps predict time to failure","Normal operation","The ambient temperature is rising"],"correctIndex":1},{"question":"What should every thermography report include?","options":["Only the thermal image","The thermal image, visible photo, equipment tag, hot spot and reference temperatures, delta, diagnosis, and recommended action","Only the temperature","Only the equipment tag"],"correctIndex":1},{"question":"How should Medium and High findings be handled?","options":["Filed away","Generate a CMMS work order","Ignored","Monitored only"],"correctIndex":1},{"question":"What does a before-and-after comparison that shows no improvement indicate?","options":["The camera is faulty","The repair did not address the root cause — re-investigate and re-repair","The baseline is wrong","Normal"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons
  UPDATE lessons SET content =
'## Overview
Infrared thermography detects the infrared radiation emitted by an object and converts it to a temperature map. Every object above absolute zero emits infrared radiation; the amount depends on its temperature and emissivity. Understanding the physics and the camera operation is the foundation of effective thermography.

## Key Concepts
- **Emissivity** is a measure of how efficiently an object radiates compared to a perfect blackbody — most non-metallic surfaces have an emissivity of 0.85-0.95, while bare metal is 0.1-0.3.
- **Setting the wrong emissivity** produces false readings — always set the camera emissivity to match the surface, or apply electrical tape (emissivity 0.95) to bare metal for a consistent target.
- **Reflections** from hot background sources (motors, lights, the sun) can corrupt readings — shield the target or angle the camera to avoid reflections.
- **Camera operation:** Set to auto-scale initially, then switch to manual and lock the temperature range for comparative images.
- **Saving images:** Always save the thermal image with a corresponding visible-light photo for the report.

## Step-by-Step: Camera Setup and Operation
1. **Turn on the camera** and let it warm up for 5-10 minutes (the internal detector must reach thermal equilibrium for stable readings).
2. **Set the emissivity** to match the target surface: 0.95 for non-metallic (paint, tape, plastic), 0.85-0.90 for oxidized metal, 0.1-0.3 for bare metal.
3. **Set the temperature range** to auto initially, then switch to manual and lock the range for comparative images.
4. **Set the distance** to the approximate distance to the target (affects the spot size and the accuracy).
5. **Frame the target** and focus the image — an out-of-focus image produces inaccurate temperature readings.
6. **Capture the image** with the temperature scale visible. Annotate the hot spot and the reference point.
7. **Capture a visible-light photo** of the same component for identification.
8. **Save both images** to the camera storage for download to the report.

## Common Problems and Fixes
- **Temperature readings are inaccurate on bare metal:** The emissivity is set too high. Apply electrical tape (0.95) to the metal and set the emissivity to 0.95, or set the emissivity to the correct value for bare metal.
- **Readings are affected by reflections:** The hot background (a motor, a light) is reflecting off the target. Shield the target or change the camera angle.
- **Images are not comparable between inspections:** The camera settings (emissivity, range, distance) are different. Standardize the settings and save them with each image.
- **Camera does not focus:** The lens is dirty or the target is too close. Clean the lens and verify the minimum focus distance.

## Best Practices and Field Tips
- Always save the thermal image with the temperature scale visible — an image without the scale is just a picture, not data.
- Apply electrical tape to bare metal for a consistent emissivity target — it eliminates the emissivity variable.
- For comparative images (before and after, or between similar components), lock the temperature range so the color map is the same.
- Let the camera warm up before use — the internal detector temperature affects the calibration.

## Safety Notes
- Never look at the sun through an infrared camera — the focused infrared can damage the detector.
- Hot surfaces can cause burns — maintain a safe distance or use a telephoto lens.',
   quiz =
'[{"question":"What is emissivity?","options":["The temperature of an object","How efficiently an object radiates compared to a blackbody","The reflectivity of a surface","The thermal conductivity"],"correctIndex":1},{"question":"What is a practical way to get a consistent emissivity on bare metal?","options":["Polish the surface","Apply electrical tape (emissivity 0.95)","Heat the surface","Paint it black"],"correctIndex":1},{"question":"Why should the camera warm up before use?","options":["For comfort","The internal detector must reach thermal equilibrium for stable readings","To charge the battery","It is required by the manufacturer"],"correctIndex":1},{"question":"What can corrupt temperature readings on a target?","options":["Dust","Reflections from hot background sources (motors, lights, the sun)","The camera angle","The ambient humidity"],"correctIndex":1},{"question":"What should always be saved with a thermal image?","options":["Nothing","A corresponding visible-light photo for identification","The camera settings","The weather conditions"],"correctIndex":1},{"question":"What should be done if temperature readings are inaccurate on bare metal?","options":["Ignore the readings","Apply electrical tape and set emissivity to 0.95, or set the correct emissivity for bare metal","Polish the metal","Use a different camera"],"correctIndex":1},{"question":"Why should the temperature range be locked for comparative images?","options":["For safety","So the color map is the same and images are visually comparable","To save battery","It is required by ISO"],"correctIndex":1}]'::jsonb
  WHERE title = 'Infrared Thermography Principles' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Thermography finds mechanical problems by detecting abnormal heat. Friction, restricted flow, and energy loss all produce thermal signatures that an infrared camera can detect before the component fails. Understanding the applications and the diagnostic patterns is the practical skill of mechanical thermography.

## Key Concepts
- **Bearings:** A bearing running 20-30°C above the adjacent bearing on the same machine is in distress. Compare similar bearings under similar load for the most reliable diagnosis.
- **Couplings:** A coupling that is hotter than the shaft indicates slippage or misalignment generating friction heat.
- **Steam traps:** A trap that fails open shows no temperature difference across the trap (steam passes through). A trap that fails closed shows the inlet hot and the outlet cold.
- **Motors:** Hot spots on the windings indicate a shorted winding or blocked cooling. Hot bearing housings indicate bearing distress.
- **Pipes and ducts:** A cold spot on a hot pipe indicates a blockage or a restriction. A hot spot on a cold pipe indicates an external heat source or a leak.

## Step-by-Step: Mechanical Thermography Inspection
1. **Inspect the equipment under normal operating load** — a machine at rest shows nothing.
2. **For bearings:** Compare the temperature of each bearing to the adjacent bearing on the same machine. A delta of 20-30°C indicates distress.
3. **For couplings:** Compare the coupling temperature to the shaft temperature. A hot coupling indicates slippage or misalignment.
4. **For steam traps:** Compare the inlet and outlet temperatures. No difference = failed open; inlet hot, outlet cold = failed closed.
5. **For motors:** Scan the motor housing and the junction box. Hot spots on the housing indicate winding or bearing problems; hot spots in the junction box indicate loose connections.
6. **For pipes and ducts:** Scan along the length. A cold spot on a hot pipe indicates a blockage; a hot spot on a cold pipe indicates a leak or an external heat source.
7. **Capture and annotate** each finding with the hot spot temperature, the reference temperature, and the delta.
8. **Classify the severity** and write the recommended action.

## Common Problems and Fixes
- **Bearing is hot but the vibration is normal:** The bearing may be over-greased (check the grease), or the cooling is restricted (check the fan). The heat precedes the vibration by weeks.
- **Coupling is hot but the alignment is within tolerance:** The coupling may be slipping (check the coupling bolt torque) or the coupling may be undersized for the torque.
- **Steam trap shows no temperature difference:** The trap has failed open. Replace the trap.
- **Motor junction box is hot:** A loose connection. Tighten the connection and re-check.

## Best Practices and Field Tips
- Always compare similar components under similar load — a bearing on a heavily loaded side will run hotter than one on a lightly loaded side, even if both are healthy.
- Trend the delta temperature for each component — a rising delta indicates worsening condition.
- Inspect during the summer or at peak load — the thermal signatures are strongest when the machine is working hardest.
- Combine thermography with vibration and oil analysis for the most comprehensive condition assessment.

## Safety Notes
- Never inspect a machine with the guards removed — the rotating components can cause injury.
- Hot surfaces can cause burns — maintain a safe distance or use a telephoto lens.',
   quiz =
'[{"question":"How do you diagnose a steam trap that has failed open using thermography?","options":["Inlet hot, outlet cold","No temperature difference across the trap — steam passes through","Inlet cold, outlet hot","Both inlet and outlet are cold"],"correctIndex":1},{"question":"What does a bearing running 20-30°C above an adjacent bearing under similar load indicate?","options":["Normal operation","The bearing is in distress","The ambient temperature is high","The lubrication is excessive"],"correctIndex":1},{"question":"What does a coupling that is hotter than the shaft indicate?","options":["Normal operation","Slippage or misalignment generating friction heat","The coupling is oversized","The ambient temperature is high"],"correctIndex":1},{"question":"What does a cold spot on a hot pipe indicate?","options":["Normal operation","A blockage or a restriction","A leak","An external heat source"],"correctIndex":1},{"question":"What does a hot motor junction box indicate?","options":["Normal operation","A loose connection — tighten and re-check","Over-voltage","The motor is oversized"],"correctIndex":1},{"question":"Under what condition must equipment be for a meaningful thermography inspection?","options":["At rest","Under normal operating load — a machine at rest shows nothing","Cold","Disconnected"],"correctIndex":1},{"question":"What does a bearing that is hot but has normal vibration indicate?","options":["The bearing is fine","The bearing may be over-greased or cooling is restricted — the heat precedes the vibration by weeks","The sensor is faulty","Normal operation"],"correctIndex":1}]'::jsonb
  WHERE title = 'Bearings, Couplings, Steam Traps & Motors' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 11. ULTRASOUND & ACOUSTIC LUBRICATION =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Ultrasound & Acoustic Lubrication';
  IF NOT FOUND THEN RETURN; END IF;

  -- New module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Ultrasound Applications & Program Integration', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Steam Trap Testing, Valve Leak Detection & Electrical Inspection',
   '## Overview
Ultrasound inspection extends beyond bearing lubrication — it is a versatile tool for detecting steam trap failures, valve leaks, and electrical corona or tracking. Understanding these applications makes the ultrasound gun a multi-purpose diagnostic tool.

## Key Concepts
- **Steam trap testing:** A properly functioning trap has a distinct turbulent sound at the outlet as the condensate passes through. A trap that fails open sounds like a steady high-flow hiss (steam passing through). A trap that fails closed is silent at the outlet.
- **Valve leak detection:** A leaking valve produces a turbulent hiss on the downstream side even when the valve is closed. The ultrasound gun pinpoints the leak by the signal strength.
- **Electrical corona and tracking:** High-voltage equipment produces ultrasound when the air ionizes (corona) or tracks across an insulator. The ultrasound gun detects the ionization before it becomes visible or causes a failure.
- **Compressed air leak detection:** The turbulent hiss of a compressed air leak is inaudible in a noisy plant but clearly detected by the ultrasound gun. Each leak can be tagged and quantified for repair.
- **Heat exchanger tube leak:** A tube leak in a heat exchanger produces a turbulent sound on the leaking tube. The gun can identify the leaking tube without opening the exchanger.

## Step-by-Step: Steam Trap Testing with Ultrasound
1. **Identify the trap type** (float, thermodynamic, thermostatic) and the expected sound for a functioning trap.
2. **Touch the contact probe to the trap inlet** and listen: the inlet should have a steady flow sound (condensate approaching the trap).
3. **Touch the contact probe to the trap outlet** and listen: a functioning trap has an intermittent turbulent sound (condensate discharging). A failed-open trap has a steady high-flow hiss (steam passing through). A failed-closed trap is silent at the outlet.
4. **Record the dB reading** at the inlet and the outlet. A functioning trap has a higher inlet reading and a lower, intermittent outlet reading. A failed-open trap has similar readings at both.
5. **Tag the trap** with the test result and the date. Schedule replacement for failed traps.

## Step-by-Step: Compressed Air Leak Survey
1. **Scan the air system with the airborne module** while the system is pressurized.
2. **Move the gun slowly** along the air lines, fittings, valves, and connectors. A leak produces a rising hiss in the headphones.
3. **Pinpoint the leak** by moving toward the loudest signal. Mark the location with a tag.
4. **Estimate the leak size** from the dB reading and the system pressure (use the manufacturer chart to convert dB to CFM loss).
5. **Calculate the annual cost** of each leak: CFM × 60 × hours per year × $/CFM. Prioritize the largest leaks for repair.
6. **Re-survey after repairs** to verify the leaks are fixed and to find any new leaks.

## Common Problems and Fixes
- **Steam trap test is inconclusive:** The trap type is not understood (different trap types have different sounds). Learn the expected sound for each trap type.
- **Leak is detected but cannot be pinpointed:** The leak is in a recessed or covered location. Use a flexible waveguide extension to reach the location.
- **Electrical inspection is inconclusive:** The voltage is too low for corona (corona occurs above 4 kV). Verify the voltage level before testing.
- **Air leak survey misses leaks:** The system pressure is too low. Survey at the normal operating pressure (100 PSI minimum).

## Best Practices and Field Tips
- Combine ultrasound with thermography for steam trap testing — the ultrasound detects the sound, the thermography detects the temperature difference. Both together provide a reliable diagnosis.
- For air leak surveys, tag each leak with a numbered tag and photograph the location — the repair team can find and fix the leaks efficiently.
- Trend the total air leak CFM — a rising total indicates new leaks are developing faster than repairs are being made.
- For electrical inspection, use a parabolic dish attachment to scan from a safe distance — high-voltage equipment requires arc-flash PPE and a safe approach distance.

## Safety Notes
- Never approach high-voltage equipment without arc-flash PPE and training — ultrasound does not protect from arc flash.
- Pressurized leaks can blow debris — wear safety glasses when inspecting compressed air systems.',
   55, 1,
   '[{"question":"What sound does a properly functioning steam trap produce at the outlet?","options":["Silence","A steady high-flow hiss","An intermittent turbulent sound (condensate discharging)","A low rumble"],"correctIndex":2},{"question":"What sound does a steam trap that has failed open produce?","options":["Silence","A steady high-flow hiss (steam passing through)","An intermittent turbulent sound","A low rumble"],"correctIndex":1},{"question":"At what voltage does corona typically occur?","options":["Above 120V","Above 480V","Above 4 kV","Above 100 kV"],"correctIndex":2},{"question":"How is a compressed air leak quantified?","options":["By the sound pitch","By the dB reading and the system pressure — use the manufacturer chart to convert to CFM loss","By the temperature","By the visual inspection"],"correctIndex":1},{"question":"What should be done after an air leak survey?","options":["Nothing","Re-survey after repairs to verify the leaks are fixed and find any new leaks","Replace all air lines","Increase the compressor size"],"correctIndex":1},{"question":"What should be used to scan high-voltage equipment from a safe distance?","options":["A contact probe","A parabolic dish attachment","A stethoscope","Nothing — do not scan high-voltage equipment"],"correctIndex":1},{"question":"What does a leaking valve produce on the downstream side when the valve is closed?","options":["Silence","A turbulent hiss detectable by the ultrasound gun","A steady flow","Nothing detectable"],"correctIndex":1}]'::jsonb),
  (m_id, 'Integrating Ultrasound with Vibration & Oil Analysis',
   '## Overview
Ultrasound is not a standalone technology — it is most effective when integrated with vibration analysis and oil analysis in a comprehensive condition monitoring program. Each technology detects different failure modes at different stages, and together they provide the most complete picture of equipment health.

## Key Concepts
- **Ultrasound detects earliest:** The high-frequency friction signal appears before the low-frequency vibration signature. A bearing detected by ultrasound may not show in vibration for months.
- **Vibration identifies the source:** The frequency spectrum pinpoints the specific fault (imbalance, misalignment, bearing defect) with diagnostic precision.
- **Oil analysis confirms the root cause:** Wear metals in the oil confirm the bearing degradation and identify the specific wear mechanism (abrasive wear, corrosive wear, fatigue).
- **Integration sequence:** Ultrasound detects the early stage → vibration confirms the developing fault → oil analysis confirms the wear mechanism → thermography confirms the heat generation. Together, they provide a full-stage picture from early detection to imminent failure.
- **CMMS integration:** Each technology generates alerts and work orders in the CMMS, creating a complete maintenance history for each asset.

## Step-by-Step: Integrated Condition Monitoring
1. **Establish the monitoring program** with all three technologies: ultrasound (monthly route), vibration (monthly route), oil analysis (quarterly sample).
2. **When ultrasound detects a rising dB on a bearing:** Increase the vibration monitoring frequency on that bearing from monthly to weekly. Take an oil sample to confirm the wear.
3. **When vibration confirms a bearing defect frequency:** Schedule the bearing replacement based on the rate of change. Continue ultrasound and vibration monitoring to track the progression.
4. **When oil analysis confirms high wear metals:** Cross-reference with the ultrasound and vibration data to confirm the diagnosis and estimate the remaining life.
5. **When thermography confirms a hot bearing:** The bearing is in advanced degradation. Schedule the replacement immediately.
6. **Document the integrated diagnosis** in the CMMS: the ultrasound finding, the vibration spectrum, the oil analysis result, and the thermography image. This multi-technology record is the most comprehensive evidence for the maintenance decision.

## Common Problems and Fixes
- **Ultrasound detects a problem but vibration does not confirm it:** The bearing is in the very early stage. Continue ultrasound monitoring and increase the vibration frequency.
- **Vibration detects a problem but oil analysis does not confirm it:** The fault may not be bearing-related (misalignment, imbalance, looseness). Oil analysis only detects wear, not alignment or balance problems.
- **All three technologies detect a problem but the maintenance team does not act:** The program is not integrated with the CMMS. Generate work orders automatically from the alerts.
- **Technologies give conflicting diagnoses:** Each technology has a different sensitivity and a different detection stage. Use the integration sequence to interpret: ultrasound is earliest, vibration is diagnostic, oil analysis is confirmatory.

## Best Practices and Field Tips
- Use a single CMMS to integrate all three technologies — a bearing alert from any technology generates a work order and links to the other technologies'' data for the same asset.
- Train the technicians on all three technologies — a technician who can only use one technology is limited to one perspective.
- The integration sequence (ultrasound → vibration → oil → thermography) is the key to interpreting the data — each technology has a different detection stage.
- Trend the data from all three technologies on a single chart for each asset — the convergence of multiple technologies is the strongest evidence for a maintenance decision.

## Safety Notes
- Combining multiple technologies requires multiple data collection trips to the same machine — ensure the machine is safe to approach at each trip.
- The integration does not change the safety requirements of each individual technology.',
   55, 2,
   '[{"question":"Which condition monitoring technology detects bearing degradation earliest?","options":["Vibration analysis","Oil analysis","Ultrasound — the high-frequency friction signal appears before the vibration signature","Thermography"],"correctIndex":2},{"question":"What is the integration sequence for condition monitoring technologies?","options":["Vibration → ultrasound → oil → thermography","Ultrasound → vibration → oil → thermography","Oil → vibration → ultrasound → thermography","Thermography → all others"],"correctIndex":1},{"question":"What does it mean when ultrasound detects a problem but vibration does not confirm it?","options":["False alarm","The bearing is in the very early stage — continue ultrasound monitoring and increase the vibration frequency","The ultrasound gun is faulty","The bearing is healthy"],"correctIndex":1},{"question":"What does it mean when vibration detects a problem but oil analysis does not confirm it?","options":["The vibration is wrong","The fault may not be bearing-related (misalignment, imbalance, looseness) — oil analysis only detects wear","The oil sample was taken wrong","The bearing is healthy"],"correctIndex":1},{"question":"How should the condition monitoring program be integrated with the CMMS?","options":["It should not be","A bearing alert from any technology generates a work order and links to the other technologies data","Through email only","Through paper reports"],"correctIndex":1},{"question":"Why should technicians be trained on all three technologies?","options":["For cross-training","A technician who can only use one technology is limited to one perspective","To save labor cost","It is required by ISO"],"correctIndex":1},{"question":"What is the strongest evidence for a maintenance decision?","options":["A single technology reading","The convergence of multiple technologies on a single chart for the same asset","The highest reading","The most recent reading"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons
  UPDATE lessons SET content =
'## Overview
Acoustic ultrasound detects high-frequency sounds (20-60 kHz) that are inaudible to the human ear. Friction, turbulence, and electrical discharge all generate ultrasound. Understanding the technology and the inspection gun operation is the foundation of ultrasound-based condition monitoring.

## Key Concepts
- **Friction** (dry bearings, rubbing), **turbulence** (leaks, steam traps), and **electrical discharge** (corona, tracking) all generate ultrasound.
- **Heterodyning:** The ultrasound gun converts the high-frequency signal to an audible tone via heterodyning and displays the signal strength in decibels (dB).
- **Contact probe:** Used for bearing inspection (the probe touches the bearing housing and transmits the structure-borne ultrasound).
- **Scanning module:** Used for airborne leak detection (a directional microphone that picks up the turbulent hiss of a leak).
- **Baseline dB:** A reading on a new or recently serviced bearing. An increase of 7-8 dB above baseline indicates early distress; 12-15 dB indicates advanced wear; 20+ dB indicates imminent failure.

## Step-by-Step: Ultrasound Gun Operation
1. **Select the module:** Contact probe for bearings, scanning module for airborne leaks.
2. **Attach the headphones** and adjust the volume to a comfortable level.
3. **Set the frequency** to 38-40 kHz (the standard for most industrial inspections).
4. **For bearing inspection:** Touch the contact probe to the bearing housing and read the dB. Record the reading.
5. **For leak detection:** Point the scanning module at the suspected leak area and move toward the loudest signal.
6. **Adjust the sensitivity** so the reading is in the mid-range of the display (not pegged high or at zero).
7. **Record the dB reading** and the location for trending.

## Common Problems and Fixes
- **Readings are erratic:** The probe is not making good contact (dirty surface, paint on the housing). Clean the surface and re-measure.
- **Headphones have no sound:** The battery is dead or the headphone jack is loose. Check the battery and the jack.
- **Readings are not repeatable:** The probe is placed at a different point each time. Mark the measurement point for consistency.
- **The gun picks up everything as loud:** The sensitivity is set too high. Reduce the sensitivity and re-scan.

## Best Practices and Field Tips
- Establish a baseline dB on every new or recently serviced bearing — without a baseline, you cannot detect a change.
- Mark the measurement point on each bearing housing for repeatability.
- Use the contact probe with a magnetic mount for hands-free operation on vertical surfaces.
- The advantage over vibration is that ultrasound detects bearing degradation earlier — the high-frequency friction signal appears before the low-frequency vibration signature.

## Safety Notes
- Never use the contact probe on a running machine with the coupling guard removed — the probe or the cable can catch in the rotating coupling.
- The headphones reduce ambient noise awareness — be aware of your surroundings when wearing them in a plant.',
   quiz =
'[{"question":"What frequency range does acoustic ultrasound detect?","options":["1-5 kHz","20-60 kHz","100-500 kHz","1-5 MHz"],"correctIndex":1},{"question":"What does a 7-8 dB increase above baseline on a bearing indicate?","options":["Normal operation","Early bearing distress","Advanced wear","Imminent failure"],"correctIndex":1},{"question":"What does a 20+ dB increase above baseline indicate?","options":["Early distress","Advanced wear","Imminent failure","Normal operation"],"correctIndex":2},{"question":"Which module is used for bearing inspection?","options":["The scanning module","The contact probe","The parabolic dish","The airborne module"],"correctIndex":1},{"question":"What is the advantage of ultrasound over vibration analysis for bearing monitoring?","options":["It is cheaper","It detects bearing degradation earlier — the high-frequency friction signal appears before the vibration signature","It is more accurate","It does not require a baseline"],"correctIndex":1},{"question":"What should be established on every new or recently serviced bearing?","options":["A vibration baseline","A baseline dB — without it, you cannot detect a change","A temperature baseline","An oil analysis baseline"],"correctIndex":1},{"question":"What causes erratic ultrasound readings on a bearing?","options":["A faulty gun","The probe is not making good contact — dirty surface or paint on the housing","The bearing is healthy","The ambient temperature is high"],"correctIndex":1}]'::jsonb
  WHERE title = 'Ultrasound Inspection Technology' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Acoustic lubrication is the practice of greasing a bearing while listening to it with an ultrasound gun. As a bearing runs dry, the friction increases and the ultrasound dB rises. By monitoring the dB while greasing, you add exactly the right amount — no more, no less. This method eliminates both over-greasing and under-greasing, the two most common causes of bearing failure.

## Key Concepts
- **Over-greasing** is as harmful as under-greasing: excess grease builds pressure, blows seals, and churning heat degrades the lubricant.
- **Acoustic lubrication method:** With the contact probe on the bearing housing, inject grease slowly while watching the dB reading. As lubricant reaches the rolling elements, the dB drops — stop when the reading stabilizes.
- **Sealed bearings** without a fitting cannot be greased — trend the ultrasound reading and schedule replacement when the dB rises beyond the alarm threshold.
- **Grease gun output:** Know the output per pump of your grease gun (typically 1-3 grams per stroke) so you can control the quantity.
- **Post-grease purge:** Run the machine for 10-15 minutes to allow excess grease to purge. If the bearing housing has a drain plug, open it during the purge.

## Step-by-Step: Acoustic Lubrication Procedure
1. **Clean the grease fitting** and the area around it with a solvent-soaked rag.
2. **Attach the ultrasound contact probe** to the bearing housing and note the dB reading (the baseline).
3. **Pump grease slowly** — one shot at a time — while monitoring the dB.
4. **As the dB drops** (indicating the lubricant is reaching the rolling elements), slow down to one pump every 5-10 seconds.
5. **Stop when the dB stabilizes** — the reading will drop and then plateau. The plateau means the bearing has enough grease.
6. **If the dB does not drop after 3-4 pumps:** The grease may not be reaching the bearing (blocked passage, wrong fitting). Stop and investigate.
7. **Run the machine for 10-15 minutes** to purge excess grease. If the housing has a drain plug, open it during the purge.
8. **Record the pre- and post-lubrication dB** and the number of pumps in the CMMS for trending.

## Common Problems and Fixes
- **Bearing runs hot after acoustic lubrication:** The bearing was over-greased before the method was applied (the dB was already low). Remove the drain plug and purge the excess.
- **dB does not drop when greasing:** The grease is not reaching the bearing (blocked passage, wrong fitting type). Investigate the grease path.
- **dB drops but then rises again quickly:** The bearing has a seal leak and the grease is escaping. Replace the seal.
- **Sealed bearing has a rising dB:** The bearing is degrading internally. Schedule replacement — sealed bearings cannot be re-greased.

## Best Practices and Field Tips
- Use an ultrasound gun with a dB display (not just headphones) — the display allows objective trending, while headphones are subjective.
- Tag each bearing with the grease type, the baseline dB, and the last lubrication date.
- For bearings with no grease fitting (sealed), trend the ultrasound dB and schedule replacement when the dB exceeds the alarm threshold (typically 7-8 dB above baseline).
- The acoustic lubrication method prevents the most common cause of bearing failure — over-greasing — which no time-based schedule can prevent.

## Safety Notes
- Never grease a bearing while the machine is running and the coupling is exposed — lock out the machine or use a remote grease line.
- Grease guns can develop high pressure — never point the nozzle at yourself or others.',
   quiz =
'[{"question":"When greasing a bearing by sound, when should you stop adding grease?","options":["After a fixed number of pumps","When the dB reading stabilizes after dropping","When grease comes out of the seal","After 30 seconds"],"correctIndex":1},{"question":"What is the risk of over-greasing a bearing?","options":["No risk — more is better","Builds pressure, blows seals, and churning heat degrades the lubricant","Improves bearing life","Reduces operating temperature"],"correctIndex":1},{"question":"What should be done if the dB does not drop after 3-4 pumps of grease?","options":["Keep pumping","Stop and investigate — the grease may not be reaching the bearing (blocked passage, wrong fitting)","Remove the bearing","Increase the grease pressure"],"correctIndex":1},{"question":"What should be done for a sealed bearing with a rising ultrasound dB?","options":["Grease it anyway","Schedule replacement — sealed bearings cannot be re-greased","Ignore it","Drill and tap a grease fitting"],"correctIndex":1},{"question":"What should be recorded for each bearing after acoustic lubrication?","options":["Only the grease type","Pre- and post-lubrication dB and the number of pumps","Only the date","Only the bearing tag"],"correctIndex":1},{"question":"What does the acoustic lubrication method prevent that no time-based schedule can?","options":["Imbalance","Over-greasing — the most common cause of bearing failure","Misalignment","Bearing defects"],"correctIndex":1},{"question":"What should be done after greasing to allow excess grease to purge?","options":["Nothing","Run the machine for 10-15 minutes; open the drain plug if equipped","Shut down immediately","Remove the bearing"],"correctIndex":1}]'::jsonb
  WHERE title = 'Greasing Bearings by Sound' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;
