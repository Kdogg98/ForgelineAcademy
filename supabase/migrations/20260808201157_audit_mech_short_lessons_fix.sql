/*
# Catalog audit — Expand short Mechanical lessons (courses 15-22) + fix 2Q quizzes to 7Q

## Overview
23 lessons across 8 Mechanical courses (Welding, Chain/Belt, Compressors, Heat Exchangers, 
Conveyor Troubleshooting, Precision Maintenance, Mechanical Seals Advanced, Rotating Equipment)
have content under 1800 chars and quizzes with only 2 questions. This migration expands 
all content to 1800-3500+ chars with structured format and expands all quizzes to 7 questions.

## Security
No schema or policy changes. Data-only migration.
*/

-- ===================== WELDING & FABRICATION (3 lessons) =====================
DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Welding & Fabrication for Maintenance Technicians';
  IF NOT FOUND THEN RETURN; END IF;

  UPDATE lessons SET content =
'## Overview
Shielded Metal Arc Welding (SMAW, or stick), Gas Metal Arc Welding (GMAW, or MIG), and Gas Tungsten Arc Welding (GTAW, or TIG) are the three welding processes a maintenance technician uses most. Each has strengths and limitations — knowing when to use which is the foundation of effective repair welding.

## Key Concepts
- **SMAW (stick)** uses a consumable electrode with a flux coating that creates shielding gas and slag. It is the most portable and forgiving process — suitable for outdoor work, dirty metal, and thick sections. The flux coating protects the weld from atmospheric contamination but must be chipped away after welding.
- **GMAW (MIG)** uses a continuous wire feed and a shielding gas (75% Ar / 25% CO2 for steel). It is fast and productive for shop work but sensitive to wind that blows away the shielding gas. Short-circuit transfer is used for thin material; spray transfer for thick material.
- **GTAW (TIG)** uses a non-consumable tungsten electrode and a separate filler rod. It produces the highest quality welds on thin material and exotic metals (stainless, aluminum) but is the slowest process and requires the most skill. The tungsten must not touch the work — contamination ruins the weld.
- **Filler metal selection** must match the base metal: E7018 for mild steel, E308L for stainless, E4043 for aluminum. Using the wrong filler produces a weak or cracked weld.

## Step-by-Step: Selecting and Setting Up a Welding Process
1. **Identify the base metal** — mild steel, stainless, aluminum, or cast iron. This determines the process and the filler.
2. **Identify the environment** — indoor (GMAW or GTAW) or outdoor/windy (SMAW). Wind blows away shielding gas, making GMAW and GTAW unsuitable outdoors without wind screens.
3. **Identify the material thickness** — thin sheet (GTAW or GMAW short-circuit), thick plate (SMAW or GMAW spray), or very thick (SMAW with multiple passes).
4. **Select the filler metal** to match the base metal. Verify the electrode is dry (SMAW) and the wire is clean (GMAW).
5. **Set the amperage** per the electrode diameter: roughly 40 amps per 1/32 inch of electrode diameter for SMAW. Too low amperage gives poor penetration; too high amperage gives undercut and excessive spatter.
6. **Set the gas flow** for GMAW: 20-25 CFH for indoor work, 30-35 CFH for outdoor or drafty conditions. Too low gas flow causes porosity; too high wastes gas and can cause turbulence that draws in air.
7. **Verify the ground clamp** is securely attached to the workpiece — a poor ground causes unstable arc and poor weld quality.

## Common Problems and Fixes
- **Porosity (gas pockets in the weld):** Caused by contaminated base metal, inadequate shielding, or wet electrodes. Clean the metal to bare metal, verify gas flow, and use dry electrodes from a heated oven.
- **Undercut (groove at the weld toe):** Caused by excessive amperage or too-fast travel speed. Reduce the amperage and slow the travel speed.
- **Incomplete fusion:** The weld did not fuse to the base metal. Increase the amperage, slow the travel, and angle the electrode 10-15 degrees in the direction of travel.
- **Cracking:** Caused by hydrogen in the weld (wet electrodes, contaminated metal), rapid cooling, or high residual stress. Use low-hydrogen electrodes (E7018), preheat thick sections, and control the cooling rate.

## Best Practices and Field Tips
- For maintenance repair, SMAW with E7018 is the go-to — it is portable, forgiving, and produces strong ductile welds.
- Keep SMAW electrodes in a heated rod oven (250°F) to prevent moisture absorption. A wet electrode causes hydrogen cracking.
- For GMAW, use a wire feed speed that matches the amperage — too fast wire speed causes a stubbing arc; too slow causes a globular, unstable arc.
- For GTAW, keep the tungsten sharp and clean — a contaminated tungsten causes arc wander and weld contamination.

## Safety Notes
- Never weld without a welding helmet with the correct shade (10-14 for SMAW, 8-12 for GMAW). Even a brief arc flash causes welder''s flash.
- Welding fumes are hazardous — use fume extraction, especially when welding galvanized steel (zinc oxide fume causes metal fume fever) or stainless steel (hexavalent chromium).
- Clear combustibles for 35 feet in all directions and have a fire extinguisher within reach. Welding sparks travel far.',
   quiz =
'[{"question":"Which welding process is most portable and forgiving for outdoor field repairs?","options":["GMAW (MIG)","SMAW (stick)","GTAW (TIG)","FCAW"],"correctIndex":1},{"question":"Which process produces the highest quality welds on thin stainless material?","options":["SMAW","GMAW","GTAW (TIG)","FCAW"],"correctIndex":2},{"question":"What filler metal is recommended for mild steel repair welding?","options":["E308L","E7018 (low-hydrogen)","E4043","E11018"],"correctIndex":1},{"question":"What causes porosity in a weld?","options":["Excessive amperage","Contaminated base metal, inadequate shielding, or wet electrodes","Too-fast travel","Low amperage"],"correctIndex":1},{"question":"Why must SMAW electrodes be kept in a heated rod oven?","options":["To keep them organized","To prevent moisture absorption — wet electrodes cause hydrogen cracking","To improve appearance","To save space"],"correctIndex":1},{"question":"What causes undercut at the weld toe?","options":["Low amperage","Excessive amperage or too-fast travel speed — it is a stress concentration","Contamination","Wrong electrode angle"],"correctIndex":1},{"question":"How far should combustibles be cleared from the welding area?","options":["10 feet","35 feet in all directions","5 feet","100 feet"],"correctIndex":1}]'::jsonb
  WHERE title = 'SMAW, GMAW & GTAW Basics' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
A good weld starts with a clean, properly prepared joint. Distortion — the warping of the workpiece from welding heat — is the biggest challenge in fabrication and repair. Understanding joint preparation and distortion control is essential for producing sound, dimensionally accurate welds.

## Key Concepts
- **Joint preparation:** Remove paint, oil, rust, and moisture from the weld area — contaminants cause porosity and cracking. Bevel thick sections (over 1/4 inch) to 30-37.5 degrees with a 1/16-3/32 inch root face for full penetration.
- **Tack welding:** Tack the joint at intervals to maintain alignment before the final weld. Tacks should be small and evenly spaced — a large tack creates a hard spot that can crack.
- **Distortion causes:** The weld metal shrinks as it cools, pulling the workpiece. The shrinkage force is proportional to the heat input and the weld size.
- **Distortion control methods:** Alternate sides (skip welding), backstep (weld backward from the direction of travel), clamp to a rigid fixture, preheat to reduce the temperature gradient, and sequence the welds to balance the shrinkage forces.
- **Stress relief:** Post-weld heat treatment relieves residual stresses and prevents delayed cracking on thick sections or critical applications.

## Step-by-Step: Joint Preparation and Distortion Control
1. **Clean the joint area** to bare metal — remove at least 2 inches of paint, oil, and rust from the weld zone on both sides of the joint.
2. **Bevel thick sections** (over 1/4 inch) using a grinder or a torch. Verify the bevel angle (30-37.5 degrees) and the root face (1/16-3/32 inch).
3. **Tack weld** the joint at intervals (every 4-6 inches for thin material, every 2-3 inches for thick material). Verify alignment after tacking.
4. **Plan the weld sequence** to balance distortion: alternate sides for a fillet weld, backstep for a long butt weld, and weld the root pass first on thick sections.
5. **Clamp the work** to a rigid fixture or a strongback to resist the shrinkage forces.
6. **Preheat thick or high-carbon sections** to 250-400°F to reduce the temperature gradient and the cooling rate.
7. **Weld in the flat or horizontal position** whenever possible — the weld pool is easier to control and the heat input is more uniform.
8. **Stress relieve** after welding on thick sections (over 1/2 inch) or critical structural members by heating to 1100-1200°F and holding for 1 hour per inch of thickness.

## Common Problems and Fixes
- **Weld cracks during or after welding:** Caused by hydrogen, rapid cooling, or high stress. Use low-hydrogen electrodes (E7018), preheat, and control the cooling rate.
- **Workpiece warps beyond tolerance:** The distortion was not controlled. Use clamping, skip welding, backstepping, and preheat.
- **Root pass has incomplete penetration:** The root gap was too small or the amperage was too low. Open the root gap to 3/32 inch and increase the amperage.
- **Tack welds crack:** The tacks were too large or the base metal was contaminated. Make smaller tacks and clean the metal.

## Best Practices and Field Tips
- For a shaft repair by build-up welding, rotate the shaft continuously and weld in the 1G (flat) position with small passes to keep the heat input uniform and minimize distortion.
- Use a temperature stick (Tempilstik) to verify preheat temperature — guessing by color is unreliable and varies with ambient lighting.
- For aluminum welding, use a stainless steel brush dedicated to aluminum only — a brush used on steel contaminates the aluminum weld.
- Document the weld procedure (process, filler, amperage, preheat, post-heat) for critical welds — it provides a record for future reference.

## Safety Notes
- Grinding for joint preparation produces sparks and dust — wear safety glasses and a dust mask.
- Preheating with a torch creates a fire hazard — clear combustibles and have a fire watch.
- Stress relief temperatures can cause burns — use heat-resistant gloves and post warning signs.',
   quiz =
'[{"question":"Why must paint, oil, and rust be removed before welding?","options":["To improve appearance","They cause porosity and cracking","To save filler metal","To reduce heat input"],"correctIndex":1},{"question":"What causes weld distortion?","options":["Improper filler metal","The weld metal shrinks as it cools, pulling the workpiece","Excessive shielding gas","The wrong welding process"],"correctIndex":1},{"question":"What is the purpose of backstepping?","options":["To speed up welding","To weld backward from the direction of travel to control distortion","To improve appearance","To reduce filler usage"],"correctIndex":1},{"question":"At what thickness should sections be beveled for full penetration?","options":["Over 1/8 inch","Over 1/4 inch","Over 1/2 inch","Over 1 inch"],"correctIndex":1},{"question":"What electrode is recommended for preventing hydrogen cracking?","options":["E6010","E7018 (low-hydrogen)","E308L","E4043"],"correctIndex":1},{"question":"What should be used to verify preheat temperature?","options":["Visual inspection","A temperature stick (Tempilstik) — guessing by color is unreliable","A thermometer","Hand touch"],"correctIndex":1},{"question":"What should be done for a shaft repair by build-up welding?","options":["Weld in one position","Rotate the shaft continuously and weld in the flat position with small passes to minimize distortion","Use high heat input","Weld only one side"],"correctIndex":1}]'::jsonb
  WHERE title = 'Joint Preparation & Distortion Control' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Repair welding restores worn or broken components at a fraction of the replacement cost. For a maintenance technician, the ability to repair a shaft, a bracket, or a structural member saves downtime and procurement cost. Understanding the repair techniques and the metallurgical considerations is essential.

## Key Concepts
- **Shaft repair by build-up:** Machine the worn area clean, build up with compatible filler (E7018 for mild steel) in small overlapping passes with the shaft rotating, then machine to size and check runout. The shaft must be preheated for thick sections to prevent cracking.
- **Crack repair:** Drill a small hole at the crack tip to stop propagation, bevel the crack to full depth, preheat if the material is thick or high-carbon, and weld with a low-hydrogen electrode (E7018). The drilled hole prevents the crack from continuing past the repair.
- **Structural repair:** Verify the original material specification — welding a high-strength steel with a mild steel filler reduces the joint strength. Use matching filler and preheat for thick sections.
- **Cast iron repair:** Cast iron is brittle and crack-sensitive. Use a nickel electrode (ENi-CI) for cold welding, or preheat to 500°F and use a nickel or cast iron electrode. Peen each pass to relieve stress.
- **Post-weld inspection:** Inspect every repair weld with dye penetrant or magnetic particle to confirm no cracks remain. A repair weld that looks good but has a crack will fail again.

## Step-by-Step: Shaft Journal Repair by Build-Up Welding
1. **Machine the worn journal** clean to sound metal, removing all wear, corrosion, and fatigue material. Measure the diameter after machining to calculate the build-up thickness needed.
2. **Preheat the shaft** to 250-400°F (for thick shafts or high-carbon steel) to reduce the thermal gradient and prevent cracking.
3. **Set up the shaft in a rotator** or on rollers so it can be rotated continuously during welding — this ensures uniform heat input and minimizes distortion.
4. **Weld build-up** using E7018 in small, overlapping stringer passes (not weave beads) in the 1G (flat) position. Rotate the shaft so the weld is always at the top.
5. **Peen each pass** lightly with a needle gun or a slag hammer to relieve the shrinkage stress and reduce distortion.
6. **Allow the shaft to cool slowly** — do not quench or place in a draft. Rapid cooling causes cracking.
7. **Machine the journal** to the correct dimension on a lathe.
8. **Check runout** at all bearing journals, the coupling fit, and the impeller fit. The total runout should be under 0.05 mm for general service.
9. **Inspect the weld** with dye penetrant for surface cracks.

## Common Problems and Fixes
- **Shaft bends during build-up:** The heat input was not uniform. Rotate the shaft continuously and use smaller passes. Straighten in a press if minor.
- **Crack reappears after repair:** The crack was not fully removed before welding, or the root cause (stress, fatigue) was not addressed. Grind the crack out completely and address the root cause.
- **Cast iron cracks during or after welding:** The preheat was insufficient or the cooling was too fast. Preheat to 500°F and cool slowly under insulation.
- **Repair weld fails in service:** The filler metal did not match the base metal, or the weld was not inspected. Use the correct filler and inspect with dye penetrant.

## Best Practices and Field Tips
- Always drill a hole at the tip of a crack before welding — it stops the crack from propagating beyond the repair.
- For cast iron, use a nickel electrode (ENi-CI) and peen every pass — cast iron is unforgiving and requires careful technique.
- Document the repair with the material, the filler, the preheat, the post-heat, and the inspection result — it provides a record for future reference.
- For critical repairs (shaft, pressure boundary), have the weld inspected by a certified welding inspector (CWI) or with radiography.

## Safety Notes
- Never weld on a component that has held flammable material without cleaning and purging — residual vapors can explode.
- Hot repair welds can cause burns — allow the weld to cool or use heat-resistant gloves before handling.
- Welding fumes from repair welding on contaminated or painted material are hazardous — remove all coatings before welding.',
   quiz =
'[{"question":"Why drill a hole at the tip of a crack before welding a repair?","options":["To improve weld appearance","To stop the crack from propagating","To reduce heat input","To save filler metal"],"correctIndex":1},{"question":"What electrode is recommended for low-hydrogen welding of mild steel repairs?","options":["E6010","E7018","E308L","E11018"],"correctIndex":1},{"question":"What electrode is used for cast iron repair?","options":["E7018","ENi-CI (nickel electrode)","E308L","E4043"],"correctIndex":1},{"question":"How should a shaft be set up for build-up welding?","options":["Weld in one position","In a rotator so it can be rotated continuously for uniform heat input","On a bench","In a vise"],"correctIndex":1},{"question":"What should be done after welding a shaft journal repair?","options":["Nothing","Machine to size and check runout at all journals and fits","Paint the shaft","Balance only"],"correctIndex":1},{"question":"What should every repair weld be inspected with?","options":["Visual only","Dye penetrant or magnetic particle to confirm no cracks remain","A magnifying glass","No inspection needed"],"correctIndex":1},{"question":"What should be done before welding on a component that held flammable material?","options":["Nothing — just start welding","Clean and purge the component — residual vapors can explode","Weld slowly","Use a lower amperage"],"correctIndex":1}]'::jsonb
  WHERE title = 'Shaft, Bracket & Structural Repair' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== CHAIN & BELT DRIVE SYSTEMS ADVANCED (2 lessons) =====================
DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Chain & Belt Drive Systems Advanced';
  IF NOT FOUND THEN RETURN; END IF;

  UPDATE lessons SET content =
'## Overview
Multiple-strand chains transmit higher torque than a single chain but require precise sprocket alignment. Misalignment between strands causes uneven load sharing and rapid wear of the loaded strand. Understanding the alignment procedure and the selection criteria is essential for reliable multi-strand chain drives.

## Key Concepts
- **Multiple-strand chains** (double, triple) share the load across multiple strands, but a misalignment of even 0.5 mm between strands causes one strand to carry most of the load.
- **Sprocket alignment** uses a straightedge across the machined faces of both sprockets — the straightedge must contact all faces without gaps.
- **Sprocket tooth wear** appears as a hooked profile — a worn tooth destroys a new chain. Always replace sprockets and chains as a set.
- **Connecting link orientation:** The clip open end must trail (away from the direction of chain travel) so it does not catch.
- **Chain selection:** Verify the chain pitch, the number of strands, and the tensile rating match the application torque and speed.

## Step-by-Step: Multiple-Strand Chain Drive Installation
1. **Verify the sprocket alignment** with a straightedge across the machined faces. Correct any misalignment before installing the chain.
2. **Verify the sprocket tooth condition** with a go/no-go gauge — a hooked tooth profile indicates wear that will destroy a new chain.
3. **Install the chain** with the connecting link, not a riveted link, for field assembly. Orient the clip with the open end trailing.
4. **Set the chain tension** per the manufacturer specification — typically 2-3% of the center distance as the slack measurement.
5. **Lubricate the chain** at the pin and bushing joints, not the outer plate faces. Use an automatic lubricator for continuous lubrication.
6. **Run the drive** and check for smooth operation, noise, and heat. Any abnormal noise indicates misalignment or a tight spot.

## Common Problems and Fixes
- **One strand wears faster than the others:** The sprockets are misaligned between strands. Re-align the sprockets.
- **Chain jumps the sprocket teeth:** The chain is elongated beyond the tooth pitch, or the sprocket is worn. Replace both as a set.
- **Chain is noisy:** The chain is too tight, the sprockets are misaligned, or the chain lacks lubrication. Adjust the tension, align, and lubricate.
- **Connecting link clip falls off:** The clip was installed backward. Reinstall with the open end trailing.

## Best Practices and Field Tips
- Always replace sprockets and chains as a set — a worn sprocket destroys a new chain in weeks.
- For multiple-strand drives, use a laser alignment tool for precision — a straightedge is adequate for single-strand but not precise enough for multi-strand.
- Use an automatic chain lubricator that delivers a continuous small dose — manual lubrication at long intervals is worse than continuous low-rate lubrication.
- Trend the chain elongation quarterly — a rising rate indicates increasing wear that warrants investigation.

## Safety Notes
- Never install a chain with the drive running — the rotating sprocket can catch fingers and tools. Lock out the drive.
- A chain under tension stores energy and can whip when disconnected — release the tension before disconnecting.',
   quiz =
'[{"question":"What misalignment between chain strands causes uneven load sharing?","options":["Over 5 mm","Even 0.5 mm","Over 10 mm","Any misalignment is acceptable"],"correctIndex":1},{"question":"How should the connecting link clip be oriented?","options":["Open end leading","Open end trailing (away from direction of travel)","Open end up","Open end down"],"correctIndex":1},{"question":"Why must sprockets and chains be replaced as a set?","options":["They are sold together","A worn sprocket destroys a new chain quickly","It is cheaper","It is required by code"],"correctIndex":1},{"question":"What does a hooked sprocket tooth profile indicate?","options":["Normal wear","Advanced wear — the sprocket must be replaced","The chain is too tight","The sprocket is new"],"correctIndex":1},{"question":"Where should chain lubricant be applied?","options":["The outer plate faces","The pin and bushing joints","The sprocket teeth","The chain tensioner"],"correctIndex":1},{"question":"What causes a chain to jump the sprocket teeth?","options":["Insufficient lubrication","The chain is elongated beyond the tooth pitch, or the sprocket is worn","The chain is too tight","The sprocket is too small"],"correctIndex":1},{"question":"How should chain elongation be trended?","options":["Monthly","Quarterly — a rising rate indicates increasing wear","Only when it fails","Annually"],"correctIndex":1}]'::jsonb
  WHERE title = 'Multiple-Chain Drives & Sprocket Alignment' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
V-belt and timing belt drives require precise sheave alignment and tensioning for reliable operation. Misalignment causes belt wear, reduced efficiency, and premature failure. Understanding the alignment and tensioning procedures is essential for maintaining belt drive systems.

## Key Concepts
- **V-belt drives** transfer power through friction between the belt and the sheave groove. Sheave misalignment of more than 0.5 degrees per foot of center distance causes the belt to ride up the groove wall, wear one side, and shed tension.
- **V-belt tensioning:** Press at mid-span with a specified deflection force; the deflection should be 1/64 of the span length. A belt that squeals on startup is under-tensioned; a belt that runs hot is over-tensioned.
- **Timing (synchronous) belts** transmit power by positive engagement — too loose and the belt ratchets (jumps teeth), too tight and the bearing loads increase. Use a sonic tension meter to set the tension to the specified frequency.
- **Matched belt sets:** Replace V-belts as a matched set — belts from different manufacturing lots have slightly different lengths, causing the shorter belt to carry all the load.
- **Sheave groove wear:** A worn groove (shiny at the bottom, ridged sides) causes the belt to ride too deep. Verify the groove profile with a groove gauge.

## Step-by-Step: Sheave Alignment and Belt Tensioning
1. **Verify sheave alignment** with a straightedge across the machined faces of both sheaves. A gap indicates angular or parallel misalignment — correct by shimming or moving the motor.
2. **Verify the sheave groove condition** with a groove gauge for V-belts — a worn groove must be re-machined or the sheave replaced.
3. **Install the belts** by loosening the motor mounting and sliding the motor to reduce the center distance — never pry the belt over the sheave with a tool.
4. **Set the initial tension** by increasing the center distance until the belt is snug.
5. **For V-belts:** Measure the deflection at mid-span with a specified force. The deflection should be 1/64 of the span length. Adjust the center distance to achieve the correct deflection.
6. **For timing belts:** Use a sonic tension meter — pluck the belt like a guitar string and read the frequency. Adjust the center distance until the frequency matches the manufacturer specification.
7. **Run the drive** for 30 minutes to seat the belts.
8. **Re-check the tension** after the run-in — belts relax slightly. Re-tension if needed.

## Common Problems and Fixes
- **V-belt squeals on startup:** Under-tensioned. Increase the tension.
- **V-belt runs hot and fails quickly:** Over-tensioned or misaligned. Reduce the tension and align the sheaves.
- **Timing belt ratchets (jumps teeth):** Too loose. Increase the tension with the sonic tension meter.
- **Belt wears on one side only:** Sheave misalignment. Align the sheaves with a straightedge.
- **V-belts in a set wear unevenly:** The belts are not a matched set. Replace all belts as a matched set from the same manufacturer.

## Best Practices and Field Tips
- Use a sonic tension meter for timing belts — it is the only accurate method. Deflection methods are not suitable for synchronous belts.
- For V-belt sets, always buy matched belts from the same manufacturer and the same production lot.
- Check the sheave groove profile at every belt replacement — a worn groove destroys a new belt.
- Trend the belt tension quarterly — a falling tension indicates belt stretch or sheave wear.

## Safety Notes
- Never install a belt by prying it over the sheave — the tensile member can be damaged. Loosen the motor and slide it.
- A belt that fails at speed can fling components — install and maintain the belt guard.',
   quiz =
'[{"question":"What causes a V-belt to ride up the groove wall and wear one side?","options":["Over-tensioning","Sheave misalignment of more than 0.5 degrees per foot","Under-tensioning","Wrong belt type"],"correctIndex":1},{"question":"What does a V-belt that squeals on startup indicate?","options":["Over-tensioning","Under-tensioning","Misalignment","Normal operation"],"correctIndex":1},{"question":"How should timing belt tension be measured?","options":["By deflection","With a sonic tension meter — pluck the belt and read the frequency","By feel","By visual inspection"],"correctIndex":1},{"question":"Why should V-belts be replaced as a matched set?","options":["They look better","Belts from different lots have slightly different lengths, causing uneven load sharing","It is cheaper","It is required by OSHA"],"correctIndex":1},{"question":"What should be used to verify the sheave groove profile?","options":["A straightedge","A groove gauge — a worn groove causes the belt to ride too deep","A caliper","A micrometer"],"correctIndex":1},{"question":"What does a timing belt that ratchets (jumps teeth) indicate?","options":["Over-tensioning","The belt is too loose — increase the tension","Normal operation","The sheave is worn"],"correctIndex":1},{"question":"How should a belt be installed?","options":["Pry it over the sheave with a tool","Loosen the motor and slide it to reduce the center distance — never pry","Cut the belt and splice it","Heat the belt"],"correctIndex":1}]'::jsonb
  WHERE title = 'Sheave Alignment, Tensioning & Toothed Belt Timing' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== COMPRESSORS & COMPRESSED AIR SYSTEMS (3 lessons) =====================
DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Compressors & Compressed Air Systems';
  IF NOT FOUND THEN RETURN; END IF;

  UPDATE lessons SET content =
'## Overview
Rotary screw, reciprocating, and centrifugal compressors are the three primary types used in industrial plants. Each has distinct operating characteristics, maintenance requirements, and efficiency profiles. Understanding the differences is essential for selecting, maintaining, and troubleshooting compressed air systems.

## Key Concepts
- **Rotary screw compressors** are the workhorse of modern plants — two intermeshing rotors compress air continuously, producing smooth, pulsation-free flow. They are efficient from 50-100% load and run quietly. The air-end (rotor block) is oil-flooded for lubrication and sealing; the oil is separated in a separator tank.
- **Reciprocating compressors** use pistons and cylinders — efficient at part-load (unloading individual cylinders), handle high pressures, but produce pulsation and are noisy. They are used for high-pressure and low-flow applications.
- **Centrifugal compressors** use an impeller to accelerate air and a diffuser to convert velocity to pressure — very high flow at moderate pressure, used in large plants. Sensitive to surge (flow reversal at low demand) and require anti-surge controls.
- **Compressor sizing:** Size for peak demand plus 10-20% margin. Consider a sequencer for multiple compressors to match output to demand efficiently.
- **Compressed air is the most expensive utility** — it takes 7-8 HP of electrical power to produce 1 HP of pneumatic work.

## Step-by-Step: Compressor Type Selection
1. **Determine the required flow (CFM)** at the required pressure (PSIG) from the plant demand profile.
2. **Determine the duty cycle** — continuous, intermittent, or variable. Variable demand benefits from a VSD compressor.
3. **Select the compressor type:** Rotary screw for general industrial (50-500 CFM), reciprocating for high pressure / low flow, centrifugal for very high flow (1000+ CFM).
4. **Verify the part-load efficiency** — a fixed-speed screw compressor that loads and unloads wastes energy at part-load. A VSD compressor saves 15-35% on part-load operation.
5. **Size the receiver** — typically 1 gallon per CFM for general service, more for variable demand. The receiver dampens pulsation and reduces the compressor cycling.
6. **Plan the air treatment** — dryer, filters, and regulator sized for the compressor output and the air quality requirement.

## Common Problems and Fixes
- **Compressor overheats:** The cooler is fouled, the oil level is low, or the oil is degraded. Clean the cooler, check the oil, and change if degraded.
- **Compressor capacity drops:** The inlet filter is clogged, the valves are worn, or the system has leaks. Clean or replace the filter, inspect the valves, and survey for leaks.
- **Compressor runs continuously without unloading:** The unload valve is stuck or the system has a large leak. Check the unload valve and survey for leaks.
- **Centrifugal compressor surges:** The demand is below the surge point. The anti-surge control should open the bypass — verify the anti-surge valve is functioning.

## Best Practices and Field Tips
- For variable demand, use a VSD compressor — it matches motor speed to demand and saves 15-35% on part-load operation.
- Install a flow meter at the compressor discharge to trend the demand and identify waste.
- Trend the compressor operating temperature, the oil analysis, and the separator pressure drop together — they reveal the compressor health.
- Use synthetic compressor oil for longer drain intervals and better high-temperature stability.

## Safety Notes
- Never open a compressor while it is running or pressurized — internal components are under pressure and hot oil can cause burns.
- The receiver is a pressure vessel — it must be inspected per the local pressure vessel code. An uninspected receiver can explode.',
   quiz =
'[{"question":"Which compressor type is the workhorse of modern plants and produces smooth, pulsation-free flow?","options":["Reciprocating","Rotary screw","Centrifugal","Scroll"],"correctIndex":1},{"question":"What are centrifugal compressors sensitive to at low demand?","options":["Overheating","Surge (flow reversal)","Oil leakage","Excessive noise"],"correctIndex":1},{"question":"How much electrical power does it take to produce 1 HP of pneumatic work?","options":["1-2 HP","3-4 HP","7-8 HP","10-12 HP"],"correctIndex":2},{"question":"How much energy does a VSD compressor save on part-load operation?","options":["5-10%","15-35%","50%","80%"],"correctIndex":1},{"question":"What should be done if a compressor overheats?","options":["Increase the speed","Clean the cooler, check the oil level, and change the oil if degraded","Replace the compressor","Reduce the system pressure"],"correctIndex":1},{"question":"What does a compressor that runs continuously without unloading indicate?","options":["Normal operation","The unload valve is stuck or the system has a large leak","The compressor is oversized","The motor is failing"],"correctIndex":1},{"question":"How should the receiver be treated for safety?","options":["It does not need inspection","It must be inspected per the local pressure vessel code — an uninspected receiver can explode","It should be drained daily","It should be painted"],"correctIndex":1}]'::jsonb
  WHERE title = 'Rotary Screw, Reciprocating & Centrifugal Compressors' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Compressed air leaving the compressor contains water, oil, and particulates that must be removed before distribution. Dryers, filters, and leak surveys are the three pillars of air quality management. Without proper air treatment, pneumatic devices fail prematurely and the system wastes energy.

## Key Concepts
- **Refrigerated dryers** cool the air to 35-40°F, condensing moisture. They are the standard for general industrial service (dew point 35-40°F).
- **Desiccant dryers** use activated alumina to achieve a pressure dew point of -40°F for instrument air or outdoor service. They regenerate by switching between two towers.
- **Coalescing filters** remove oil aerosols down to 0.01 ppm. **Particulate filters** capture solid particles. Check the pressure drop monthly — a rising drop indicates a clogged element.
- **Leak cost:** A 1/8 inch leak at 100 PSIG wastes approximately $2,000 per year in electricity. A typical plant loses 20-30% of its compressed air to leaks.
- **Leak survey:** Use an ultrasonic leak detector to find and tag each leak. Estimate the CFM loss and prioritize the largest leaks for repair.

## Step-by-Step: Air Treatment Setup and Leak Survey
1. **Select the dryer type:** Refrigerated for general service (dew point 35-40°F), desiccant for instrument air or outdoor service (dew point -40°F).
2. **Install a coalescing filter** downstream of the dryer to remove oil aerosols. Size the filter for the maximum flow.
3. **Install a particulate filter** downstream of the coalescing filter for final particulate removal.
4. **Check the pressure drop** across each filter monthly — replace the element when the drop exceeds the manufacturer limit (typically 5-7 PSID).
5. **Conduct a leak survey** with an ultrasonic detector: scan the air system while pressurized, tag each leak, estimate the CFM loss, and sum the total.
6. **Calculate the leak percentage:** Total leak CFM / total compressor CFM × 100. Target below 10%.
7. **Repair the largest leaks first** and re-survey after repairs to verify.

## Common Problems and Fixes
- **Air at the point of use is wet:** The dryer is failed or undersized. Check the dryer operation and the dew point.
- **Filter pressure drop is excessive:** The filter element is clogged. Replace the element.
- **Oil in the air system:** The compressor separator element is worn (oil-flooded screw). Replace the separator element.
- **System pressure is low despite adequate compressor capacity:** The system has excessive leaks. Conduct a leak survey and repair.

## Best Practices and Field Tips
- Install a dew point sensor in the air system to monitor the dryer performance — a rising dew point indicates a failing dryer.
- Conduct a leak survey quarterly and trend the total leak CFM — a rising total indicates new leaks are developing.
- Lower the system pressure to the minimum required — every 2 PSI reduction saves 1% of the compressor energy.
- For desiccant dryers, verify the switching valve is not leaking — a leaking valve wastes purge air and reduces the dew point performance.

## Safety Notes
- Never search for air leaks with bare hands — high-pressure air can penetrate skin. Use an ultrasonic detector.
- Desiccant dryer towers can be hot — allow the dryer to cool before servicing.',
   quiz =
'[{"question":"What dew point does a desiccant dryer achieve?","options":["35-40°F","-40°F","0°F","32°F"],"correctIndex":1},{"question":"How much does a 1/8 inch leak at 100 PSIG waste per year?","options":["$200","$2,000","$20,000","$200,000"],"correctIndex":1},{"question":"What percentage of compressed air does a typical plant lose to leaks?","options":["1-5%","20-30%","50-60%","80-90%"],"correctIndex":1},{"question":"When should a filter element be replaced?","options":["Every 5 years","When the pressure drop exceeds the manufacturer limit (typically 5-7 PSID)","Only when it fails","Annually"],"correctIndex":1},{"question":"What does oil in the air system indicate on an oil-flooded screw compressor?","options":["Normal operation","The compressor separator element is worn — replace it","The oil is overfilled","The cooler is fouled"],"correctIndex":1},{"question":"How much energy does every 2 PSI reduction in system pressure save?","options":["0.5%","1%","5%","10%"],"correctIndex":1},{"question":"What should be installed to monitor dryer performance?","options":["A flow meter","A dew point sensor — a rising dew point indicates a failing dryer","A pressure gauge","Nothing"],"correctIndex":1}]'::jsonb
  WHERE title = 'Dryers, Filters & Leak Surveys' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Compressed air is the most expensive utility in a plant. Optimizing the system — reducing leaks, eliminating inappropriate uses, lowering pressure, and recovering waste heat — can reduce the compressed air energy cost by 20-50%. Understanding the optimization strategies is essential for any maintenance technician responsible for the compressed air system.

## Key Concepts
- **System pressure:** Every 2 PSI above the minimum required wastes 1% of the compressor energy. Lower the pressure to the minimum that satisfies all users.
- **Inappropriate uses:** Using compressed air for cleaning, cooling, or liquid pumping is energy-wasteful. A 1/4 inch air blow gun uses 20 CFM — replace with a blower or an electric fan.
- **Energy recovery:** The compressor heat (the hot discharge air) can heat a workshop or warehouse. A 50 HP compressor generates enough heat to warm a 5,000 sq ft workshop.
- **Pressure drop audit:** Measure the pressure at the compressor and at each major point of use. A drop of more than 5 PSI indicates a restriction (undersized pipe, clogged filter, too many fittings).
- **VSD compressors** match motor speed to demand and save 15-35% on part-load operation compared to a fixed-speed compressor that loads and unloads.

## Step-by-Step: Compressed Air System Optimization
1. **Install a power meter** on the compressor and trend the kW.
2. **Conduct a leak survey** and repair the largest leaks first. Target below 10% leak rate.
3. **Lower the system pressure** to the minimum that satisfies all users. Verify no user is starved after the reduction.
4. **Identify inappropriate uses** and replace with alternatives (blower for cleaning, electric fan for cooling, electric pump for liquid).
5. **Measure the pressure profile** from the compressor to the furthest point of use. Identify and correct restrictions with more than 5 PSI drop.
6. **Evaluate energy recovery:** Measure the compressor discharge temperature and calculate the recoverable heat for space heating.
7. **Calculate the annual savings:** (leak CFM + inappropriate use CFM) × 60 × hours per year × $/CFM.

## Common Problems and Fixes
- **System pressure is too high:** Every 2 PSI above minimum wastes 1% energy. Reduce the pressure to the minimum.
- **Leaks are repaired but new ones appear:** Leaks are continuous. Schedule a quarterly leak survey.
- **Pressure at the point of use is too low:** The distribution pipe is undersized or a filter is clogged. Increase the pipe size or clean the filter.
- **Compressor runs continuously:** The system has a large leak or the unload valve is stuck. Survey for leaks and check the valve.

## Best Practices and Field Tips
- Install flow meters at the compressor and at major branches to trend the demand and identify waste.
- For new installations, use a VSD compressor that matches output to demand — it saves 15-35% on part-load.
- Conduct a full system audit annually — the system changes over time as equipment is added and leaks develop.
- Recover the compressor heat for space heating — it is free energy that is otherwise wasted.

## Safety Notes
- Never survey for leaks with bare hands — high-pressure air can penetrate skin. Use an ultrasonic detector.
- The compressor heat recovery system can have hot surfaces — use guards and insulation.',
   quiz =
'[{"question":"How much energy does every 2 PSI above the minimum required pressure waste?","options":["0.5%","1%","5%","10%"],"correctIndex":1},{"question":"What is the target leak rate for a compressed air system?","options":["Below 1%","Below 10%","Below 30%","Below 50%"],"correctIndex":1},{"question":"How much can a compressed air system optimization reduce energy cost?","options":["1-5%","20-50%","80-90%","100%"],"correctIndex":1},{"question":"What is an inappropriate use of compressed air?","options":["Running pneumatic cylinders","Using compressed air for cleaning or cooling — replace with a blower or electric fan","Running air tools","Operating air valves"],"correctIndex":1},{"question":"What does a pressure drop of more than 5 PSI from compressor to point of use indicate?","options":["Normal operation","A restriction — undersized pipe, clogged filter, or too many fittings","The compressor is oversized","The system is efficient"],"correctIndex":1},{"question":"How much heat can a 50 HP compressor recover for space heating?","options":["Enough for a small office","Enough to warm a 5,000 sq ft workshop","No heat can be recovered","Enough for the entire plant"],"correctIndex":1},{"question":"How often should a full compressed air system audit be conducted?","options":["Every 10 years","Annually — the system changes over time","Only at installation","Never"],"correctIndex":1}]'::jsonb
  WHERE title = 'System Efficiency & Energy Recovery' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== HEAT EXCHANGERS & COOLING SYSTEMS (3 lessons) =====================
DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Heat Exchangers & Cooling Systems';
  IF NOT FOUND THEN RETURN; END IF;

  UPDATE lessons SET content =
'## Overview
Shell-and-tube, plate, and air-cooled heat exchangers are the three primary types used in industrial plants. Each has distinct maintenance requirements, cleaning methods, and failure modes. Understanding the types and their characteristics is essential for maintaining cooling and heat transfer systems.

## Key Concepts
- **Shell-and-tube exchangers** are the most common — one fluid flows through tubes inside a shell, the other flows across the tube bundle. They are rugged, handle high pressure, and can be cleaned by rodding or hydro-lancing the tubes.
- **Plate exchangers** use corrugated metal plates bolted together with gaskets — compact and efficient but limited to lower pressures and temperatures. Gaskets must be replaced as a set.
- **Air-cooled exchangers** use fans to blow air across finned tubes — eliminate water usage but are less efficient and larger for the same duty. Fin fouling reduces the heat transfer.
- **Fouling** is the primary maintenance issue: scale, biological growth, and particulate deposition insulate the heat transfer surface and reduce capacity.
- **Approach temperature** (process outlet minus cooling medium inlet) is the key performance indicator — a rising approach indicates fouling.

## Step-by-Step: Heat Exchanger Inspection
1. **Isolate the exchanger** — close the inlet and outlet valves on both sides. Verify zero pressure before opening.
2. **Open the inspection cover** (shell-and-tube) or disassemble the plate pack (plate exchanger).
3. **Inspect the tubes or plates** for fouling (scale, biological, particulate), corrosion, and erosion.
4. **Inspect the gaskets** (plate exchanger) for hardening, cracking, or chemical attack. Replace all gaskets as a set if any are degraded.
5. **Inspect the tubes** (shell-and-tube) for wall thinning using an eddy current tester — a tube with greater than 50% wall loss should be plugged or replaced.
6. **Clean the heat transfer surfaces** by mechanical rodding, hydro-lancing, or chemical descaling.
7. **Reassemble** with new gaskets (plate exchanger) or new shell gasket (shell-and-tube). Torque the bolts in a cross pattern to the specified dimension (plate) or torque (shell-and-tube).
8. **Pressure-test** before returning to service — a leak under pressure is a safety hazard and a process contamination risk.

## Common Problems and Fixes
- **Approach temperature is rising:** Fouling is present. Clean the exchanger.
- **Plate exchanger leaks between plates:** A gasket is failed. Replace all gaskets as a set.
- **Shell-and-tube tube leak:** A tube is corroded or eroded. Plug the leaking tube or replace the tube bundle.
- **Air-cooled exchanger capacity drops:** The fins are fouled. Clean the fins with a brush or compressed air.

## Best Practices and Field Tips
- Trend the approach temperature monthly — a 1°F per month rise indicates a fouling rate that warrants cleaning within 3-6 months.
- For shell-and-tube exchangers, clean the tube side more frequently than the shell side — the tube side is where most fouling occurs.
- After cleaning, verify the approach returns to the design value — if it does not, the cleaning was incomplete.
- For plate exchangers, keep a spare gasket set in stock — the lead time for gaskets can be weeks.

## Safety Notes
- Never open a heat exchanger while it is pressurized or hot — isolate, depressurize, and cool before opening.
- Chemical cleaning agents (acids, descalers) are hazardous — use PPE and follow the manufacturer safety instructions.',
   quiz =
'[{"question":"What is the most common industrial heat exchanger type?","options":["Plate exchanger","Shell-and-tube exchanger","Air-cooled exchanger","Double-pipe exchanger"],"correctIndex":1},{"question":"What is the primary maintenance issue for heat exchangers?","options":["Corrosion","Fouling (scale, biological growth, particulate deposition)","Leaking gaskets","Cracked tubes"],"correctIndex":1},{"question":"What does a rising approach temperature indicate?","options":["Improved heat transfer","Fouling on the heat transfer surface","Increased flow rate","Lower ambient temperature"],"correctIndex":1},{"question":"At what wall loss should a heat exchanger tube be plugged or replaced?","options":["10%","25%","50%","75%"],"correctIndex":2},{"question":"How are plate exchanger bolts tightened?","options":["To a specified torque value","To a specified tightening dimension","By feel","To full tightness"],"correctIndex":1},{"question":"What should be done after cleaning a heat exchanger?","options":["Nothing","Verify the approach returns to the design value — if it does not, the cleaning was incomplete","Replace the exchanger","Increase the flow rate"],"correctIndex":1},{"question":"What must be done before opening a heat exchanger?","options":["Nothing","Isolate, depressurize, and cool before opening","Drain the process side only","Remove the bolts only"],"correctIndex":1}]'::jsonb
  WHERE title = 'Shell-and-Tube, Plate & Air-Cooled Exchangers' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Shell-and-tube tubes are cleaned by mechanical rodding, hydro-lancing, or chemical descaling. Plate exchanger gaskets must be replaced as a set — never mix old and new gaskets. Understanding the cleaning and gasket replacement procedures is essential for maintaining heat exchanger performance.

## Key Concepts
- **Mechanical rodding** uses a rotating brush or a scraper rod pushed through each tube — effective for soft deposits.
- **Hydro-lancing** uses high-pressure water (5,000-20,000 PSI) to blast hard scale from the tube interior — effective but requires specialized equipment and safety precautions.
- **Chemical cleaning** circulates a descaling solution (dilute acid with a corrosion inhibitor) through the exchanger — effective for scale that cannot be reached mechanically.
- **Plate exchanger gaskets** must be replaced as a set — mixing old and new gaskets creates uneven compression and leaks.
- **Plate tightening dimension:** Plate exchangers are tightened to a specified dimension (not a torque value) per the manufacturer drawing.
- **Pressure test** after reassembly verifies the integrity before returning to service.

## Step-by-Step: Tube Cleaning and Gasket Replacement
1. **Isolate and drain the exchanger.** Verify zero pressure before opening.
2. **For shell-and-tube cleaning:** Remove the channel cover or the bonnet. Inspect the tube ends for blockage and the tube sheet for corrosion.
3. **Rod each tube** with a rotating brush or a scraper rod. Verify the rod passes through — a blocked tube must be cleared with a high-pressure water jet.
4. **For hard scale:** Hydro-lance the tubes with high-pressure water. Use a lance with a rotating nozzle and work from both ends.
5. **For chemical cleaning:** Circulate a descaling solution through the exchanger. Monitor the acid concentration and the iron content — when the iron stops rising, the cleaning is complete. Neutralize and flush thoroughly.
6. **For plate exchanger gasket replacement:** Remove all plates, remove all old gaskets, clean the gasket grooves, install new gaskets (all from the same set), reassemble the plate pack, and tighten to the specified dimension.
7. **Pressure-test** the exchanger at 1.5x the design pressure before returning to service.

## Common Problems and Fixes
- **Tubes are blocked and cannot be rodded:** Use hydro-lancing from both ends. If still blocked, the tube must be plugged.
- **Chemical cleaning is ineffective:** The scale is not acid-soluble (silica, sulfate). Use a different chemical or mechanical cleaning.
- **Plate exchanger leaks after gasket replacement:** The gaskets are not seated correctly or the tightening dimension is wrong. Disassemble, verify the gasket seating, and re-tighten to the correct dimension.
- **Tube sheet corrosion:** The tube sheet is pitted or corroded. Repair by weld build-up and re-machine, or replace the tube sheet.

## Best Practices and Field Tips
- For shell-and-tube exchangers, keep a spare set of channel gaskets and tube plugs — they are needed during every cleaning.
- For plate exchangers, keep a spare gasket set — the lead time for gaskets can be weeks.
- After hydro-lancing, inspect the tube interior with a borescope to verify the cleaning is complete.
- Document the cleaning with the date, the method, the before and after approach temperature, and any tubes that were plugged.

## Safety Notes
- Hydro-lancing at high pressure can cut skin and cause injection injuries — use a lance with a safety trigger and a back-out prevention device.
- Chemical cleaning acids are hazardous — use PPE (face shield, acid-resistant gloves, apron) and have an eyewash station nearby.
- Never open an exchanger under pressure — verify zero pressure with a gauge before opening.',
   quiz =
'[{"question":"How are plate exchanger bolts tightened?","options":["To a specified torque value","To a specified tightening dimension per the manufacturer drawing","By feel","To full tightness"],"correctIndex":1},{"question":"What must plate exchanger gaskets be replaced as?","options":["Individual replacement as needed","A complete set — mixing old and new gaskets creates uneven compression and leaks","Only the leaking gasket","Any order"],"correctIndex":1},{"question":"What pressure is used for hydro-lancing hard scale?","options":["100-500 PSI","5,000-20,000 PSI","100-200 PSI","50,000+ PSI"],"correctIndex":1},{"question":"How do you know chemical cleaning is complete?","options":["When the time is up","When the acid concentration stops dropping and the iron content stops rising","When the solution changes color","After 1 hour"],"correctIndex":1},{"question":"What should be done after reassembly before returning to service?","options":["Nothing","Pressure-test at 1.5x the design pressure","Run at half pressure","Visual inspection only"],"correctIndex":1},{"question":"What should be used to verify tube cleaning is complete?","options":["Visual inspection from the end","A borescope to inspect the tube interior","Nothing","A flashlight"],"correctIndex":1},{"question":"What safety hazard is unique to hydro-lancing?","options":["Electric shock","High-pressure water can cut skin and cause injection injuries","Fume inhalation","Noise"],"correctIndex":1}]'::jsonb
  WHERE title = 'Tube Cleaning & Gasket Replacement' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Cooling towers expose water to air, evaporating a portion to reject heat. This concentrates dissolved solids and creates an environment for biological growth, including Legionella. Water treatment controls scale, corrosion, and biological growth. Understanding the treatment program and the tower maintenance is essential for reliable cooling system operation.

## Key Concepts
- **Cycles of concentration** are the ratio of dissolved solids in the tower water to the makeup water — controlled by adjusting the blowdown (the continuous drain of concentrated water).
- **Scale control** is maintained by keeping the cycles below the saturation point of calcium carbonate, and by adding scale inhibitors (phosphonates, polymers).
- **Corrosion control** is maintained by adding corrosion inhibitors (phosphate, azole) that form a protective film on the metal surface. Monitored by corrosion coupons.
- **Biological control** is maintained by adding biocides (chlorine, bromine, isothiazolin). Critical for Legionella prevention — a cooling tower is a known Legionella source.
- **White rust** on galvanized steel indicates aggressive water chemistry (high pH, high chloride) — requires immediate treatment adjustment.

## Step-by-Step: Cooling Tower Maintenance and Water Treatment
1. **Inspect the tower monthly:** Check the fill for scale and biological growth, the drift eliminators for damage, the distribution nozzles for clogging, and the sump for sediment.
2. **Clean the sump annually** — remove sediment and debris that harbor bacteria.
3. **Test the water weekly:** pH (7.5-9.0), conductivity (for cycles), biocide residual (1-3 ppm chlorine), and turbidity.
4. **Adjust the blowdown** to maintain the target cycles of concentration (typically 3-5 for soft water, 2-3 for hard water).
5. **Add scale inhibitor, corrosion inhibitor, and biocide** based on the water test results.
6. **Remove and inspect the corrosion coupons** quarterly to measure the corrosion rate. Above 3 MPY indicates inadequate corrosion control.
7. **Trend the pH, the conductivity, the biocide residual, and the corrosion rate** monthly.

## Common Problems and Fixes
- **Scale deposits in the fill:** The cycles are too high or the scale inhibitor is underfed. Reduce the cycles or increase the inhibitor.
- **Corrosion rate is above 3 MPY:** The corrosion inhibitor is underfed or the pH is too low. Increase the inhibitor and adjust the pH.
- **Biological growth (slime, algae):** The biocide is underfed. Increase the biocide dose and clean the affected surfaces.
- **White rust on galvanized steel:** Aggressive water chemistry (high pH, high chloride). Adjust the pH and add a zinc-compatible inhibitor.
- **Legionella risk:** The biocide program is inadequate. Maintain a continuous biocide residual and inspect the tower for biofilm monthly.

## Best Practices and Field Tips
- Install a continuous conductivity controller that automates the blowdown — it maintains the cycles without manual adjustment.
- Use corrosion coupons to measure the actual corrosion rate — the inhibitor dosage cannot be optimized without coupon data.
- For Legionella prevention, maintain a continuous biocide residual and inspect the drift eliminators for biofilm.
- Document the water treatment program with the chemical list, the dosages, the test results, and the coupon rates.

## Safety Notes
- Cooling tower drift can carry Legionella bacteria — maintain the biocide program and inspect the drift eliminators.
- Water treatment chemicals (acids, biocides, scale inhibitors) are hazardous — use PPE and follow the SDS.
- The cooling tower fan can cause severe injury — lock out the fan before any internal tower work.',
   quiz =
'[{"question":"What do cycles of concentration represent in a cooling tower?","options":["The number of times the water cycles per hour","The ratio of dissolved solids in tower water to makeup water","The number of biocide additions per day","The fan speed setting"],"correctIndex":1},{"question":"What is the maximum acceptable corrosion rate?","options":["1 MPY","3 MPY (mils per year)","10 MPY","50 MPY"],"correctIndex":1},{"question":"What does white rust on galvanized steel indicate?","options":["Normal aging","Aggressive water chemistry (high pH, high chloride) — adjust the pH and add a zinc-compatible inhibitor","Excessive biocide","Low water temperature"],"correctIndex":1},{"question":"How often should cooling tower water be tested?","options":["Monthly","Weekly","Daily","Annually"],"correctIndex":1},{"question":"How often should the sump be cleaned?","options":["Monthly","Annually","Every 5 years","Never"],"correctIndex":1},{"question":"What should be done for Legionella prevention?","options":["Nothing","Maintain a continuous biocide residual and inspect the tower for biofilm monthly","Increase the fan speed","Reduce the water temperature"],"correctIndex":1},{"question":"How is the actual corrosion rate measured?","options":["By testing the pH","By using corrosion coupons — the inhibitor dosage cannot be optimized without coupon data","By testing the conductivity","By visual inspection"],"correctIndex":1}]'::jsonb
  WHERE title = 'Cooling Tower Maintenance & Water Treatment' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== CONVEYOR TROUBLESHOOTING & REPAIR (3 lessons) =====================
DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Conveyor Troubleshooting & Repair';
  IF NOT FOUND THEN RETURN; END IF;

  UPDATE lessons SET content =
'## Overview
Belt splices are the weakest point on a conveyor belt. Mechanical splices are fast to install; vulcanized splices are stronger but require specialized equipment. Tracking correction keeps the belt centered and prevents edge damage. Understanding splice repair and tracking correction is essential for maintaining conveyor reliability.

## Key Concepts
- **Mechanical splices** (hinged, bolted, riveted) are fast to install and suitable for field repair. They are weaker than the belt itself and can catch on idlers.
- **Vulcanized splices** (hot or cold) are stronger and longer-lasting but require specialized equipment and hours to cure. They are the standard for permanent installations.
- **Tracking rule:** The belt moves toward the side of the idler or pulley it contacts first. Adjust the tail pulley or training idlers in small increments (1/4 turn).
- **Never adjust the drive pulley for tracking** — it affects the entire belt length.
- **Belt edge wear** from mistracking causes splice failure and spillage. Correct tracking before replacing the belt.

## Step-by-Step: Belt Splice Repair
1. **Lock out the conveyor drive** before any belt work.
2. **Inspect the failed splice** and the belt ends for damage. Cut back to sound belt if the end is torn.
3. **Cut the belt square** using a carpenter square and a utility knife — a square cut is essential for a straight splice.
4. **For a mechanical splice:** Install the splice per the manufacturer instructions. Verify the splice is rated for the belt tension. Verify the splice does not catch on the idlers.
5. **For a vulcanized splice:** Prepare the belt ends per the splice procedure (step-back, skiving). Apply the splice material and cure per the time and temperature specification.
6. **Test the splice** by running the belt empty and then loaded. Inspect for any separation or catching.

## Step-by-Step: Belt Tracking Correction
1. **Observe the belt** running at normal speed and load. Note which direction the belt drifts and at what location.
2. **Start at the tail pulley.** If the belt drifts to the right, move the right side of the tail pulley slightly forward (in the direction of belt travel) — 1/4 turn at a time.
3. **Let the belt run several revolutions** before re-evaluating. Small changes take time to show.
4. **Check the training idlers** along the conveyor. Adjust each one slightly to steer the belt toward center.
5. **Check the idler alignment** — a skewed idler steers the belt off track. Re-align any skewed idlers.
6. **Check the pulley face** for material buildup — a lump pushes the belt off track. Clean the pulley.
7. **If the belt tracks to one side only at the loading point:** Check the loading chute for off-center loading. Adjust the chute.

## Common Problems and Fixes
- **Belt tracks to one side consistently:** The tail pulley is cocked or a training idler is misaligned. Adjust the tail pulley or the idler.
- **Belt wanders back and forth:** The belt tension is too low or the load is off-center. Increase the tension or adjust the loading chute.
- **Mechanical splice fails repeatedly:** The splice is not rated for the belt tension or the splice pins are corroded. Upgrade to a vulcanized splice.
- **Belt edge wear:** The belt is mistracking and rubbing the frame. Correct the tracking before replacing the belt.

## Best Practices and Field Tips
- Make small adjustments (1/4 turn at a time) and wait — large adjustments overshoot and chase the belt from side to side.
- Mark the take-up bolt positions so you can return to the original setting if an adjustment makes things worse.
- Clean the pulley faces and the idlers during every tracking correction — material buildup is a hidden cause of mistracking.
- For a new belt, check the tracking empty and loaded — a belt that tracks empty but drifts loaded has an off-center load problem.

## Safety Notes
- Never adjust tracking while the conveyor is running with the guards removed — lock out the conveyor, make the adjustment, re-install the guard, and observe.
- A mistracking belt can rub the frame and create a friction fire — correct tracking promptly.',
   quiz =
'[{"question":"Which splice type is stronger and longer-lasting but requires specialized equipment?","options":["Mechanical splice","Vulcanized splice","Hinged splice","Bolted splice"],"correctIndex":1},{"question":"Which direction does a belt move relative to the idler it contacts first?","options":["Away from it","Toward it","Perpendicular to it","It does not move"],"correctIndex":1},{"question":"Which pulley should never be adjusted for tracking?","options":["The tail pulley","The drive pulley — it affects the entire belt length","The take-up pulley","The snub pulley"],"correctIndex":1},{"question":"How much should the take-up bolts be adjusted at a time for tracking correction?","options":["1 full turn","1/4 turn","1/2 turn","As much as needed"],"correctIndex":1},{"question":"What should be done if the belt tracks fine empty but drifts under load?","options":["Increase the tension","Adjust the loading chute to center the load","Replace the belt","Adjust the tail pulley"],"correctIndex":1},{"question":"What is a hidden cause of mistracking that should be checked during tracking correction?","options":["Belt tension","Material buildup on pulley faces and idlers","Motor amperage","Belt speed"],"correctIndex":1},{"question":"What safety hazard can a mistracking belt create?","options":["Belt breakage","The belt can rub the frame and create a friction fire","Motor overload","Bearing failure"],"correctIndex":1}]'::jsonb
  WHERE title = 'Belt Splice Repair & Tracking Correction' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Worn or seized rollers cause belt damage and increased motor load. Drive diagnostics — amperage, noise, and vibration — reveal developing problems before they become failures. Understanding the roller replacement and drive diagnostic procedures is essential for conveyor reliability.

## Key Concepts
- **Seized rollers** cause the belt to slide instead of roll, generating heat and belt damage. A seized roller can shred a belt in hours.
- **Roller identification:** Walk the conveyor while it is running and listen for grinding or watch for rollers that do not turn. Tag the seized rollers for replacement.
- **Motor amperage** is proportional to the conveyor load: a rising amperage with no change in belt speed indicates increased friction from seized rollers, a tight belt, or a failing gearbox.
- **Slipping drive** (belt slows under load but motor speed does not change) indicates insufficient belt tension, worn lagging, or an overloaded conveyor.
- **Gearbox noise:** Whine = gear mesh issue, knock = bearing or tooth damage, rumble = general wear. Sample the oil for wear metals.

## Step-by-Step: Roller Replacement and Drive Diagnostics
1. **Lock out the conveyor drive** before any work.
2. **Identify seized rollers** by walking the conveyor and listening for grinding or watching for non-rotating rollers. Tag them.
3. **Remove the seized roller:** Remove the retention clip or bolt, slide the old roller out, and install the new one with the same bearing arrangement.
4. **Check adjacent rollers** for wear — a seized roller often damages its neighbors.
5. **Check the motor amperage** with a clamp meter under load. Compare to the nameplate FLA and to the baseline. A rising amperage indicates increasing system friction.
6. **Check the drive for slip:** Observe the belt speed under load. If the belt slows but the motor speed does not change, the drive is slipping — check the belt tension and the pulley lagging.
7. **Check the gearbox oil** for metal and water. Listen for bearing noise at the drive end.
8. **Re-install all guards** before returning the conveyor to service.

## Common Problems and Fixes
- **Seized rollers recur in the same area:** The area has a heat source (a hot process) or a contamination source (dust, water). Address the environmental cause.
- **Motor amperage is rising:** Increased system friction from seized rollers, a tight belt, or a failing gearbox. Identify and fix the source of the friction.
- **Drive slips under load:** Insufficient belt tension, worn lagging, or overload. Increase the tension, re-lag the pulley, or reduce the load.
- **Gearbox is noisy:** Bearing wear, gear wear, or insufficient oil. Check the oil level and sample for wear metals.

## Best Practices and Field Tips
- Walk the conveyor weekly and listen for seized rollers — early detection prevents belt damage.
- Trend the motor amperage — a rising trend with constant load indicates increasing system friction.
- Keep a stock of common roller sizes — the lead time for a special roller can be weeks.
- After replacing rollers, verify the belt tracks correctly — a new roller can change the tracking slightly.

## Safety Notes
- Never replace a roller with the conveyor running — lock out the drive.
- Seized rollers can be hot from friction — allow them to cool or use gloves before handling.',
   quiz =
'[{"question":"What does a rising motor amperage with no change in belt speed indicate?","options":["A slipping drive","Increased friction from seized rollers, tight belt, or failing gearbox","Normal operation","Undersized motor"],"correctIndex":1},{"question":"What does a slipping drive (belt slows but motor speed unchanged) indicate?","options":["Insufficient belt tension, worn lagging, or overload","Motor failure","Gearbox oil leak","Normal operation"],"correctIndex":0},{"question":"How should seized rollers be identified?","options":["By measuring the belt speed","Walk the conveyor and listen for grinding or watch for non-rotating rollers","By checking the motor amperage","By visual inspection only"],"correctIndex":1},{"question":"What should be checked when replacing a seized roller?","options":["Nothing","Adjacent rollers for wear — a seized roller often damages its neighbors","The belt tension","The motor speed"],"correctIndex":1},{"question":"What does a gearbox whine typically indicate?","options":["Bearing damage","Gear mesh issue — check the gear contact pattern or backlash","Low oil","Overload"],"correctIndex":1},{"question":"What should be done after replacing rollers?","options":["Nothing","Verify the belt tracks correctly — a new roller can change the tracking slightly","Replace the belt","Increase the speed"],"correctIndex":1},{"question":"How often should the conveyor be walked to check for seized rollers?","options":["Monthly","Weekly — early detection prevents belt damage","Annually","Only when a problem is reported"],"correctIndex":1}]'::jsonb
  WHERE title = 'Roller Replacement & Drive Diagnostics' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
The take-up maintains belt tension as the belt stretches over time. Proper take-up adjustment and system optimization — setting the belt speed, centering the load, and trending the amperage — keep the conveyor running efficiently and reliably.

## Key Concepts
- **Screw take-up:** Manual — tighten the tail pulley bolts evenly to maintain the specified sag (2% of center distance).
- **Gravity take-up:** Uses a weighted pulley that self-adjusts — check that the weight moves freely and the travel is not at its limit.
- **If the take-up is at its limit:** The belt has stretched beyond the take-up capacity and must be shortened by cutting and re-splicing.
- **Belt speed optimization:** Set the belt speed to the minimum that meets production — reduces wear and energy.
- **Load centering:** Load the belt at the center to prevent tracking drift and edge wear.
- **Motor amperage trend:** A gradual rise indicates increasing system friction that warrants investigation before it becomes a failure.

## Step-by-Step: Take-Up Adjustment and System Optimization
1. **Check the take-up type:** Screw, gravity, or hydraulic. Verify the travel is not at its limit.
2. **For a screw take-up:** Measure the belt sag at the center of the conveyor. The sag should be 2% of the center distance under the heaviest load. Tighten or loosen the tail pulley bolts to adjust.
3. **For a gravity take-up:** Verify the weight moves freely. If the travel is at the bottom limit, the belt has stretched — shorten by cutting and re-splicing.
4. **Verify the belt speed** is the minimum that meets production. If the speed can be reduced, install a VFD to match the speed to the demand.
5. **Verify the load is centered** at the loading point. An off-center load causes tracking drift and edge wear. Adjust the loading chute.
6. **Trend the motor amperage** monthly. A gradual rise with constant throughput indicates increasing system friction.
7. **Install a belt scale** to trend the throughput and verify the conveyor is meeting production without overloading.

## Common Problems and Fixes
- **Take-up is at its limit:** The belt has stretched beyond the take-up capacity. Shorten the belt by cutting and re-splicing.
- **Belt sags too much:** The take-up tension is too low. Tighten the take-up.
- **Conveyor uses too much energy:** The belt speed is higher than needed. Install a VFD and reduce the speed to match the demand.
- **Belt edge wear from off-center loading:** The load is not centered. Adjust the loading chute to center the load.
- **Motor amperage is rising:** Increasing system friction from seized rollers or a tight belt. Investigate and fix the source of the friction.

## Best Practices and Field Tips
- Install a VFD on conveyors that do not run at full capacity — the energy savings typically pay for the VFD in 1-2 years.
- Trend the motor amperage, the gearbox oil temperature, and the belt thickness together — they reveal the conveyor health.
- For a new belt, verify the take-up has enough travel for the expected stretch — a take-up that runs out of travel requires a belt shorten within months.
- Use a conveyor monitoring system that tracks the power, the speed, the belt thickness, and the safety device activations.

## Safety Notes
- Never adjust a screw take-up with the conveyor running — the tail pulley can shift suddenly and pinch fingers. Lock out the drive.
- A gravity take-up weight is heavy — never stand under it during maintenance. The weight can fall if the belt breaks.',
   quiz =
'[{"question":"What does it mean when the take-up is at its limit?","options":["The take-up is oversized","The belt has stretched beyond the take-up capacity and must be shortened","The belt is too short","Normal operation"],"correctIndex":1},{"question":"What is the recommended belt sag under the heaviest load?","options":["1% of center distance","2% of center distance","5% of center distance","10% of center distance"],"correctIndex":1},{"question":"What does a gradual rise in motor amperage trend indicate?","options":["Improved efficiency","Increasing system friction warranting investigation","Normal belt stretch","Reduced load"],"correctIndex":1},{"question":"What should be done if the conveyor uses too much energy?","options":["Replace the motor","Install a VFD and reduce the belt speed to match the demand","Increase the belt tension","Reduce the load"],"correctIndex":1},{"question":"What causes belt edge wear from off-center loading?","options":["The belt is too tight","The load is not centered at the loading point — adjust the chute","The belt speed is too high","The take-up is at its limit"],"correctIndex":1},{"question":"What should be trended together to reveal conveyor health?","options":["Only the belt tension","Motor amperage, gearbox oil temperature, and belt thickness","Only the speed","Only the safety device trips"],"correctIndex":1},{"question":"What should be verified for a new belt regarding the take-up?","options":["Nothing","The take-up has enough travel for the expected stretch","The belt color","The belt weight"],"correctIndex":1}]'::jsonb
  WHERE title = 'Take-Up Adjustment & System Optimization' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== PRECISION MAINTENANCE PRACTICES (3 lessons) =====================
DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Precision Maintenance Practices';
  IF NOT FOUND THEN RETURN; END IF;

  UPDATE lessons SET content =
'## Overview
Soft foot distorts the machine frame when the hold-down bolts are tightened, causing bearing misalignment and vibration that no external alignment can correct. Detecting and correcting soft foot is the first step in any precision alignment procedure.

## Key Concepts
- **Parallel soft foot:** A uniform gap under the foot — shim with stainless shims.
- **Angular soft foot:** A wedge-shaped gap — the foot or base is bent, may require machining.
- **Induced soft foot:** Caused by pipe strain or coupling strain pulling the machine — fix the pipe or coupling, not the foot.
- **Threshold:** Anything over 0.05 mm is actionable. Never force a bolt down to close a gap — it bends the frame and distorts the bearing housing.
- **Never stack more than 3 shims** under a foot — they act like a spring and compress under torque.

## Step-by-Step: Detecting and Correcting Soft Foot
1. **Mount a dial indicator** on the machine frame with the contact point on the top of one foot.
2. **Loosen the bolt** on that foot and observe the indicator reading — the lift is the soft foot amount.
3. **Record the reading** and re-tighten the bolt.
4. **Repeat for all four feet.** Record each reading.
5. **Shim any foot** that lifts more than 0.05 mm with stainless shims. Use the minimum number of shims (never more than 3).
6. **Re-check all four feet** after shimming — a correction on one foot can change the readings on the others.
7. **If the soft foot is angular (wedge gap):** The foot or base is bent. Check for a bent foot and consider machining.
8. **If the soft foot is induced (pipe strain):** Check the piping. Loosen the pipe flanges and re-check. If it changes, correct the pipe strain first.

## Common Problems and Fixes
- **Soft foot returns after shimming:** The shim is too thin (compresses under torque) or too many shims are stacked. Use fewer, thicker shims.
- **All four feet have soft foot:** The base is warped. Machine the base flat or grout the machine to the base.
- **Soft foot is corrected but alignment still will not hold:** Pipe strain is the cause. Check and correct the pipe strain.
- **Foot is cracked or bent:** Replace the foot or machine it flat. A bent foot cannot be shimmed correctly.

## Best Practices and Field Tips
- Always check soft foot before any alignment — it is the most common cause of alignment failure.
- Use stainless shims, not carbon steel — carbon steel shims rust and change thickness.
- Document the soft foot readings and the shims installed for each foot for future reference.
- For a machine with all four feet showing soft foot, suspect a warped base or a poor grout job.

## Safety Notes
- Never put a finger under a machine foot while loosening bolts — the machine can shift and pinch.
- Torque the bolts after shimming — loose bolts allow the machine to shift during operation.',
   quiz =
'[{"question":"What is the correct way to correct a soft foot gap?","options":["Torque the bolt harder to pull the foot down","Shim the gap with stainless shims","Grind the base flat","Ignore it if under 0.2 mm"],"correctIndex":1},{"question":"What is the threshold for soft foot correction?","options":["0.01 mm","0.05 mm","0.5 mm","1 mm"],"correctIndex":1},{"question":"What is induced soft foot caused by?","options":["A bent foot","Pipe strain or coupling strain pulling the machine","A warped base","Overtightening the bolts"],"correctIndex":1},{"question":"Why should never more than 3 shims be stacked under a foot?","options":["It is too expensive","They act like a spring and compress under torque","It is hard to install","It is a code requirement"],"correctIndex":1},{"question":"What should be done if soft foot returns after shimming?","options":["Add more shims","The shim is too thin or too many are stacked — use fewer, thicker shims","Replace the machine","Ignore it"],"correctIndex":1},{"question":"What should be checked if soft foot is corrected but alignment still will not hold?","options":["The laser system","Pipe strain — check and correct the pipe strain","The coupling","The bearings"],"correctIndex":1},{"question":"What type of shims should be used?","options":["Carbon steel","Stainless steel — carbon steel rusts and changes thickness","Aluminum","Copper"],"correctIndex":1}]'::jsonb
  WHERE title = 'Soft Foot Diagnosis & Correction' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Pipe strain occurs when the piping connected to a pump or compressor pulls the machine off its alignment when the flange bolts are tightened. It is a hidden cause of recurring bearing failures and alignment problems. Understanding how to detect and eliminate pipe strain is essential for precision maintenance.

## Key Concepts
- **Pipe strain symptoms:** The machine alignment shifts when the pipe flanges are tightened, or the machine vibrates differently when the piping is connected versus disconnected.
- **Detection method:** Mount dial indicators on the coupling, loosen the pipe flange bolts, and read the movement. Anything over 0.05 mm indicates pipe strain.
- **Causes:** Misaligned piping, inadequate pipe supports, thermal expansion of the piping, or a pipe that was forced into position during installation.
- **Correction:** Re-support the pipe close to the machine, cut and re-weld the pipe to remove the strain, or use flexible connectors (expansion joints) that absorb the movement.
- **Never use the machine as a pipe support** — the pipe weight and thermal expansion forces distort the machine casing, causing internal rubbing and bearing failure.

## Step-by-Step: Pipe Strain Diagnosis and Elimination
1. **Mount dial indicators** on the coupling in the horizontal and vertical planes.
2. **Loosen the pipe flange bolts** on the suction and discharge piping.
3. **Read the movement** on the dial indicators — any movement over 0.05 mm indicates pipe strain.
4. **If movement is detected:** Re-support the pipe close to the machine (within 5 pipe diameters of the flange). The pipe support should carry the pipe weight independently of the machine.
5. **Re-check after re-supporting:** Loosen the flanges again and verify the movement is under 0.05 mm.
6. **If the movement persists:** Cut and re-weld the pipe to remove the strain, or install a flexible connector (expansion joint) that absorbs the movement.
7. **After correcting pipe strain:** Re-check the coupling alignment and the soft foot. A machine free of pipe strain and soft foot will maintain its alignment and bearing life for years.

## Common Problems and Fixes
- **Alignment shifts when piping is connected:** Pipe strain is pulling the machine. Correct the piping and re-align.
- **Machine vibrates differently with piping connected versus disconnected:** Pipe strain is changing the internal alignment. Correct the piping.
- **Bearing fails repeatedly despite correct alignment:** Pipe strain is distorting the casing. Check for pipe strain at every bearing failure.
- **Expansion joint installed but strain persists:** The expansion joint is installed incorrectly or is too stiff. Verify the expansion joint is rated for the movement and installed per the manufacturer.

## Best Practices and Field Tips
- Check pipe strain at every alignment and at every bearing failure — it is the most commonly overlooked cause.
- Install pipe supports within 5 pipe diameters of the machine flange — the pipe weight must not rest on the machine.
- For hot piping, verify the pipe supports allow thermal expansion — a rigid support transmits the expansion force to the machine.
- Document the pipe strain readings (before and after correction) for future reference.

## Safety Notes
- Never loosen a pipe flange on a hot or hazardous process without isolating and verifying zero pressure — hot or toxic fluid can spray.
- Pipe supports that are corroded or loose can fail suddenly — inspect them during every machine PM.',
   quiz =
'[{"question":"How do you diagnose pipe strain on a pump?","options":["By listening to the pump","By mounting dial indicators on the coupling and loosening the pipe flange bolts","By checking the oil","By measuring the flow rate"],"correctIndex":1},{"question":"What movement on the dial indicator indicates pipe strain?","options":["Anything over 0.5 mm","Anything over 0.05 mm","Anything over 1 mm","Any movement at all"],"correctIndex":1},{"question":"What should never be used as a pipe support?","options":["A pipe rack","The machine itself","A wall","A floor stand"],"correctIndex":1},{"question":"Where should pipe supports be installed relative to the machine flange?","options":["Within 5 pipe diameters of the flange","10 pipe diameters away","Anywhere is fine","No support needed"],"correctIndex":0},{"question":"What should be done if pipe strain persists after re-supporting?","options":["Ignore it","Cut and re-weld the pipe or install a flexible connector (expansion joint)","Replace the machine","Increase the bolt torque"],"correctIndex":1},{"question":"When should pipe strain be checked?","options":["Only at installation","At every alignment and at every bearing failure — it is the most commonly overlooked cause","Only when the pump fails","Never"],"correctIndex":1},{"question":"What must be done before loosening a pipe flange on a hot or hazardous process?","options":["Nothing","Isolate and verify zero pressure — hot or toxic fluid can spray","Wear gloves","Close the nearest valve"],"correctIndex":1}]'::jsonb
  WHERE title = 'Pipe Strain Elimination' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
A machine grows as it heats up — a steel shaft grows approximately 0.001 mm per 100 mm of length per 10°C rise. This growth shifts the alignment at operating temperature. Understanding and compensating for thermal growth is the difference between an alignment that lasts months and one that fails in days.

## Key Concepts
- **Thermal growth formula:** Δh = α × L × ΔT, where α is the coefficient of thermal expansion (12 × 10⁻⁶ /°C for steel), L is the center height, and ΔT is the temperature rise.
- **Example:** A pump operating at 80°C with a center height of 500 mm grows approximately 0.3 mm vertically — enough to misalign the coupling if the motor (at ambient) is not offset.
- **Cold alignment offset:** Set the cold alignment with the motor shimmed higher (or lower) by the calculated offset so the machines grow into alignment at operating temperature.
- **Hot alignment verification:** Measure the coupling alignment at operating temperature with a laser system designed for hot measurement.
- **Thermal growth database:** Document the cold and hot alignment values for each machine to build a database for future alignments.

## Step-by-Step: Thermal Growth Compensation
1. **Measure the operating temperature** of both machines at the bearing housings and the feet.
2. **Calculate the thermal growth** for each machine: Δh = α × L × ΔT. Use the center height (L) and the temperature rise (ΔT) from ambient to operating.
3. **Determine the net difference** between the two machines — this is the offset to build into the cold alignment.
4. **Set the cold alignment** with the motor shimmed by the calculated offset so the machines grow into alignment at operating temperature.
5. **Verify the hot alignment** by measuring at operating temperature with a laser system, or by checking vibration levels after the machine reaches steady state.
6. **Document both the cold and hot alignment values** for each machine to build a thermal growth database.

## Common Problems and Fixes
- **Alignment will not hold:** If the machine keeps coming out of alignment after a few days, thermal growth is likely the cause. Measure the hot alignment and calculate the required cold offset.
- **Vibration increases after startup:** A machine that runs smooth cold but vibrates after warming up has thermal growth misalignment. Pre-offset the cold alignment.
- **Only one end grows:** Some machines (e.g., steam turbines) grow more at the hot end. This creates angular thermal growth — the cold alignment must compensate for both the offset and the angularity.
- **Thermal growth calculation is wrong:** The measured center height or the temperature was incorrect. Re-measure and recalculate.

## Best Practices and Field Tips
- Some laser alignment systems have a thermal growth compensation feature that calculates and applies the offset automatically — use it if available.
- Document both the cold and hot alignment values for each machine — the next alignment on the same machine is faster with historical data.
- For machines with large temperature differentials, consider a hot alignment check as part of the commissioning process.
- Pipe strain and thermal growth compound — correct pipe strain first, then compensate for thermal growth.

## Safety Notes
- Never attempt to measure alignment on a machine at operating temperature without appropriate PPE (heat-resistant gloves, face shield). Hot surfaces can cause severe burns.
- Ensure the machine is running at normal operating load before taking hot measurements — a partially loaded machine has a different thermal profile.',
   quiz =
'[{"question":"How much does steel grow per 100 mm per 10°C?","options":["0.0001 mm","0.001 mm","0.01 mm","0.1 mm"],"correctIndex":1},{"question":"What is the formula for thermal growth?","options":["Δh = α × L × ΔT","Δh = L × ΔT","Δh = α × ΔT","Δh = α × L"],"correctIndex":0},{"question":"What does it mean if a machine runs smooth cold but vibrates after warming up?","options":["Bearing failure","Thermal growth misalignment — pre-offset the cold alignment","Imbalance","Loose foundation bolts"],"correctIndex":1},{"question":"What should be corrected before compensating for thermal growth?","options":["Bearing clearance","Pipe strain","Lubricant viscosity","Coupling type"],"correctIndex":1},{"question":"Why should you document both cold and hot alignment values?","options":["For regulatory compliance","To build a thermal growth database that speeds up future alignments","To calculate bearing life","To determine motor FLA"],"correctIndex":1},{"question":"What PPE is required for hot alignment measurement?","options":["Safety glasses only","Heat-resistant gloves and face shield","Hard hat only","No special PPE"],"correctIndex":1},{"question":"What causes angular thermal growth?","options":["Misalignment at cold state","Uneven growth between hot and cold ends of a machine","Bearing wear","Pipe strain"],"correctIndex":1}]'::jsonb
  WHERE title = 'Thermal Growth Compensation' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== MECHANICAL SEALS ADVANCED DIAGNOSTICS (3 lessons) =====================
DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Mechanical Seals Advanced Diagnostics';
  IF NOT FOUND THEN RETURN; END IF;

  UPDATE lessons SET content =
'## Overview
Seal faces are the heart of a mechanical seal — one face is typically soft (carbon) and the other is hard (silicon carbide, tungsten carbide, or ceramic). Understanding the material properties and the selection criteria is essential for reliable seal operation in challenging applications.

## Key Concepts
- **Carbon vs silicon carbide** is the standard combination for water and general service — it is self-lubricating and tolerates marginal lubrication.
- **Tungsten carbide faces** are used for abrasive service because both faces are hard and resist wear from solids.
- **High-temperature service:** Carbon oxidizes above 300°C — replace with hard faces (SiC vs WC) for high-temperature applications.
- **Corrosive service:** Metal components (springs, bellows) must be a compatible alloy — Hastelloy for aggressive chemicals, titanium for chlorine.
- **Face flatness:** The faces are lapped to within 2-3 helium light bands (0.0006 mm). Any handling that touches the faces (even wiping with a paper towel) can scratch them and cause leakage.
- **Flatness inspection:** Inspect removed faces with an optical flat and a monochromatic light — a face with more than 3 bands of distortion must be re-lapped or replaced.

## Step-by-Step: Seal Face Material Selection
1. **Identify the process fluid** — water, hydrocarbon, chemical, abrasive slurry, or high-temperature service.
2. **Select the face combination:** Carbon vs SiC for general service, SiC vs WC for abrasive, SiC vs WC (both hard) for high temperature.
3. **Select the elastomers:** Viton for general, EPDM for hot water, FFKM for extreme temperature, PTFE for chemical.
4. **Select the metal components:** 316 SS for general, Hastelloy for aggressive chemicals, titanium for chlorine.
5. **Verify the face flatness** on a new seal — inspect with an optical flat and a monochromatic light before installation.
6. **Document the material selection** for each seal to support future replacement decisions.

## Common Problems and Fixes
- **Carbon face oxidizes at high temperature:** Replace with a hard face (SiC vs WC) for high-temperature service.
- **Seal faces wear rapidly in abrasive service:** Use hard faces (SiC vs WC) and a cyclone separator flush (API Plan 31).
- **O-rings swell or harden:** Chemical incompatibility. Verify the O-ring material is compatible with the process fluid and replace with the correct material.
- **Face flatness is distorted after handling:** The face was touched or dropped. Re-lap or replace the face — do not install a distorted face.

## Best Practices and Field Tips
- Never touch the seal faces with bare fingers or wipe with a paper towel — use lint-free wipes and a compatible solvent.
- For corrosive services, consult the seal manufacturer for material compatibility — a wrong material fails rapidly.
- Keep a set of reference faces showing each failure mode for training new technicians.
- Document the face materials and the failure mode for each seal to build a selection database.

## Safety Notes
- Never use compressed air to clean a seal — the air pressure can blow the seal faces apart.
- Seal springs are under compression — use eye protection when disassembling a seal, as the spring can release suddenly.',
   quiz =
'[{"question":"Which face material combination is standard for water and general service?","options":["Silicon carbide vs tungsten carbide","Carbon vs silicon carbide","Tungsten carbide vs tungsten carbide","Ceramic vs ceramic"],"correctIndex":1},{"question":"Why are both faces hard (SiC vs WC) for high-temperature service?","options":["For better heat transfer","Carbon oxidizes above 300°C","Hard faces are cheaper","Hard faces are easier to install"],"correctIndex":1},{"question":"What face materials are used for abrasive service?","options":["Carbon vs SiC","SiC vs WC (both hard to resist abrasive wear)","Carbon vs carbon","Any materials"],"correctIndex":1},{"question":"What is the face flatness specification for mechanical seals?","options":["0.006 mm","2-3 helium light bands (0.0006 mm)","0.1 mm","0.05 mm"],"correctIndex":1},{"question":"What should never touch seal faces during installation?","options":["Lint-free wipes","Bare fingers or paper towels","A solvent-soaked rag","Clean gloves"],"correctIndex":1},{"question":"How is face flatness inspected on a removed seal?","options":["Visual inspection","With an optical flat and a monochromatic light — more than 3 bands of distortion requires re-lapping or replacement","With a dial indicator","With a micrometer"],"correctIndex":1},{"question":"What should never be used to clean a seal?","options":["A lint-free wipe","Compressed air — the pressure can blow the seal faces apart","A solvent","A soft brush"],"correctIndex":1}]'::jsonb
  WHERE title = 'Seal Face Material Selection' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
API 682 defines standard flush plans that manage the seal environment. Selecting the correct flush plan is essential for reliable seal operation in challenging applications — high temperature, abrasive service, toxic service, or variable operating conditions.

## Key Concepts
- **Plan 11** (process fluid from discharge to seal): The most common flush — flushes the seal with clean process fluid.
- **Plan 21** (flush with cooler): Cools the flush for high-temperature service.
- **Plan 31** (flush through a cyclone separator): Removes solids from the flush for abrasive service.
- **Plan 52** (dual seal with unpressurized barrier fluid): For hazardous services where leakage to atmosphere is unacceptable.
- **Plan 53** (dual seal with pressurized barrier fluid): For toxic services — the barrier fluid pressure is above the seal chamber pressure, so any leakage is barrier fluid into the process, not process fluid out.
- **Flush flow verification:** A flush flow of 3-5 L/min is typical for a standard seal. Verify with a flow meter.

## Step-by-Step: API 682 Flush Plan Selection
1. **Identify the process conditions:** Temperature, solids content, volatility, and toxicity.
2. **For clean, cool process fluid:** Select Plan 11 (flush from discharge to seal).
3. **For high-temperature service:** Select Plan 21 (flush with cooler) or Plan 23 (closed-loop cooling).
4. **For abrasive service (solids in the fluid):** Select Plan 31 (cyclone separator) or Plan 32 (clean external flush).
5. **For hazardous service (leakage to atmosphere unacceptable):** Select Plan 52 (unpressurized dual seal).
6. **For toxic service:** Select Plan 53 (pressurized dual seal — barrier fluid pressure above seal chamber pressure).
7. **Verify the flush flow rate** with a flow meter — 3-5 L/min is typical. A low flow causes the seal to run hot.
8. **Document the flush plan selection** for each pump to support future maintenance.

## Common Problems and Fixes
- **Seal runs hot (above 80°C at the faces):** The flush flow is insufficient or the orifice is blocked. Check the flush flow and the orifice.
- **Cyclone separator clogs:** The solids loading is too high or the separator is undersized. Clean the separator and verify the sizing.
- **Plan 53 barrier fluid pressure is lost:** The barrier fluid system has a leak or the pressure source has failed. Check the reservoir and the pressure source.
- **Flush flow is zero:** The flush line is blocked or the orifice plate is installed incorrectly. Check the line and the orifice.

## Best Practices and Field Tips
- Install a flow meter on the flush line to verify the flow continuously — a low flow alarm prevents seal damage from overheating.
- For Plan 53 systems, install a pressure differential alarm — a loss of pressure differential means the dual seal is compromised.
- Document the flush plan, the orifice size, and the flush flow for each pump — it supports future troubleshooting.
- For cyclone separators, trend the flush pressure drop — a rising drop indicates the separator is clogging.

## Safety Notes
- Plan 52/53 barrier fluid may be hazardous if it contacts the process — verify chemical compatibility.
- A dual seal failure on a toxic service is a process safety incident — follow the plant emergency response procedure.',
   quiz =
'[{"question":"Which API 682 flush plan is most common for clean process fluid?","options":["Plan 11","Plan 21","Plan 31","Plan 53"],"correctIndex":0},{"question":"What does a Plan 53 dual seal with pressurized barrier fluid ensure?","options":["Process fluid leaks to atmosphere","Barrier fluid leaks into the process, not process fluid out","No leakage at all","Cooling of the seal faces"],"correctIndex":1},{"question":"Which flush plan is used for abrasive service?","options":["Plan 11","Plan 21","Plan 31 (cyclone separator)","Plan 52"],"correctIndex":2},{"question":"What is the typical flush flow rate for a standard seal?","options":["0.5-1 L/min","3-5 L/min","10-15 L/min","50+ L/min"],"correctIndex":1},{"question":"What does a seal running hot (above 80°C at the faces) indicate?","options":["Normal operation","The flush flow is insufficient or the orifice is blocked","The seal is oversized","The process is too cold"],"correctIndex":1},{"question":"What should be installed on the flush line for continuous monitoring?","options":["A pressure gauge","A flow meter — a low flow alarm prevents seal damage from overheating","A temperature gauge","Nothing"],"correctIndex":1},{"question":"What should be installed on a Plan 53 system for early detection?","options":["A sight glass","A pressure differential alarm — a loss of pressure differential means the dual seal is compromised","A temperature gauge","Nothing"],"correctIndex":1}]'::jsonb
  WHERE title = 'API 682 Flush Plans' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Seal failure analysis starts with the faces and works outward. Each failure mode tells a specific story about what went wrong. Understanding the failure modes and their root causes is essential for preventing recurring seal failures and improving the mean time between seal failures (MTBSF).

## Key Concepts
- **Heat checking (radial cracks on the face):** The seal ran dry or the flush failed and the faces overheated, then quenched by sudden fluid contact.
- **Blistering on the carbon face:** Small raised bubbles from thermal stress — common on hot applications that are started and stopped frequently.
- **Wear track wider than the face width:** Misalignment or shaft runout — check the shaft for runout and the coupling for alignment.
- **Erosion on faces or metal components:** Cavitation or solids in the flush — check the pump NPSH margin and the flush filtration.
- **O-ring extrusion (pinched and deformed):** Over-pressure or over-temperature — verify the seal pressure and temperature ratings.
- **Spring clogging (packed with solids):** Inadequate flush or a dirty process — improve the flush or use a seal design that shields the springs.

## Step-by-Step: Root Cause Analysis of Seal Failures
1. **Remove the seal** and inspect each component — faces, O-rings, springs, metal parts.
2. **Inspect the faces** for heat checking, blistering, wear track width, erosion, and cracking. Each pattern points to a specific root cause.
3. **Inspect the O-rings** for extrusion, swelling, hardening, or chemical attack. Each condition indicates a specific problem.
4. **Inspect the springs** for clogging, corrosion, or breakage. Each condition indicates a specific environmental problem.
5. **Identify the failure mode** and map it to the root cause: heat checking = dry running/flush failure; erosion = cavitation/solids; O-ring extrusion = over-pressure; spring clogging = dirty process.
6. **Address the root cause** — not just the symptom. Replacing the seal without fixing the root cause guarantees a repeat failure.
7. **Document the failure mode, the root cause, and the corrective action** in the CMMS for trend analysis.
8. **Trend the MTBSF** per pump — a falling MTBSF indicates a systemic issue that warrants a design review.

## Common Problems and Fixes
- **Heat checking on the faces:** The seal ran dry or the flush failed. Verify the flush flow and the seal chamber pressure. Install a low-flow alarm.
- **Wear track wider than the face width:** Shaft runout or misalignment. Check the shaft runout and the coupling alignment.
- **Erosion on the faces:** Cavitation or solids in the flush. Check the pump NPSH margin and the flush filtration. Install a cyclone separator.
- **O-ring extrusion:** Over-pressure or over-temperature. Verify the seal pressure and temperature ratings. Upgrade the seal to a higher rating.
- **Spring clogging:** Solids in the process. Improve the flush or use a seal design that shields the springs from the process.

## Best Practices and Field Tips
- For every seal failure, document the failure mode, the root cause, and the corrective action — a failure that is not root-caused will recur.
- Trend the MTBSF per pump — a falling MTBSF indicates a systemic issue, not a seal quality issue.
- Benchmark the MTBSF against industry data — a refinery typically achieves 24-36 months; a chemical plant 12-24 months.
- Share the failure data with operations — a low MTBSF may be caused by operational upsets (cavitation from low level, dry running from starting without opening the suction valve).

## Safety Notes
- A seal failure on a toxic or flammable service is a process safety incident — follow the plant emergency response procedure.
- Used seal components may be contaminated with hazardous process fluid — use PPE when handling removed seals.',
   quiz =
'[{"question":"What does heat checking (radial cracks) on seal faces indicate?","options":["Over-pressure","The seal ran dry or the flush failed","Cavitation","O-ring extrusion"],"correctIndex":1},{"question":"What does a wear track wider than the face width indicate?","options":["Normal wear","Misalignment or shaft runout","Over-pressure","Inadequate flush"],"correctIndex":1},{"question":"What does O-ring extrusion (pinched and deformed) indicate?","options":["Normal aging","Over-pressure or over-temperature — verify the seal ratings","Chemical incompatibility","Dry running"],"correctIndex":1},{"question":"What does erosion on seal faces indicate?","options":["Dry running","Cavitation or solids in the flush — check the NPSH margin and flush filtration","Over-pressure","Misalignment"],"correctIndex":1},{"question":"What should be done after identifying a seal failure mode?","options":["Replace the seal","Address the root cause — replacing the seal without fixing the root cause guarantees a repeat failure","Increase the flush flow","Replace the pump"],"correctIndex":1},{"question":"What does a falling MTBSF (mean time between seal failures) indicate?","options":["Normal wear","A systemic issue that warrants a design review","The seal brand is bad","The operator is at fault"],"correctIndex":1},{"question":"What should be done with seal failure data?","options":["File it away","Share with operations — a low MTBSF may be caused by operational upsets","Keep it confidential","Discard it"],"correctIndex":1}]'::jsonb
  WHERE title = 'Root Cause Analysis of Seal Failures' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== ROTATING EQUIPMENT RELIABILITY FUNDAMENTALS (3 lessons) =====================
DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Rotating Equipment Reliability Fundamentals';
  IF NOT FOUND THEN RETURN; END IF;

  UPDATE lessons SET content =
'## Overview
Rotating equipment — pumps, motors, fans, compressors, gearboxes — shares a common set of failure modes. Understanding these failure modes and matching the maintenance strategy to each one is the foundation of a reliability-centered maintenance program.

## Key Concepts
- **Bearing failure** is the most common, accounting for 40-50% of all rotating equipment failures. Causes: contamination, misalignment, imbalance, over-lubrication, under-lubrication, incorrect bearing selection.
- **Seal failure** is the second most common — caused by dry running, cavitation, chemical incompatibility, and installation error.
- **Vibration-related failures** (imbalance, misalignment, looseness) account for the remainder.
- **Maintenance strategy matching:** Failure modes with a clear wear-out pattern (bearing fatigue) benefit from condition monitoring. Failure modes that are random (seal failure from cavitation) benefit from design changes, not more frequent PMs.
- **Root cause analysis:** Use the equipment failure history to identify the dominant failure mode and address the root cause, not the symptom.

## Step-by-Step: Failure Mode Identification
1. **List the equipment** and its failure history from the CMMS.
2. **Categorize each failure** by mode: bearing, seal, vibration, electrical, or other.
3. **Identify the dominant failure mode** — the mode that accounts for the most failures.
4. **For bearing failures:** Check the lubrication, the alignment, the contamination control, and the bearing selection.
5. **For seal failures:** Check the flush flow, the NPSH margin, the chemical compatibility, and the installation procedure.
6. **For vibration failures:** Check the balance, the alignment, and the foundation.
7. **Match the maintenance strategy** to the failure mode: condition monitoring for wear-out, design change for random, time-based for age-related.
8. **Document the failure mode analysis** and the recommended strategy for each asset.

## Common Problems and Fixes
- **Bearing failures dominate:** Check the lubrication program (acoustic lubrication), the alignment program (laser alignment), and the contamination control (breathers, seals).
- **Seal failures dominate:** Check the flush flow, the NPSH margin, and the installation procedure. Consider a seal upgrade or a different flush plan.
- **Vibration failures dominate:** Check the balance program, the alignment program, and the foundation condition.
- **No clear dominant mode:** The failures are random. Focus on design changes and operating procedure improvements.

## Best Practices and Field Tips
- Use the failure history to identify the dominant mode — fixing the dominant mode reduces the total failures by 50% or more.
- Match the maintenance strategy to the failure pattern — a random failure does not benefit from more frequent PMs.
- Share the failure analysis with operations — operational upsets (dry running, cavitation) cause many failures.
- Re-evaluate the failure modes annually — the dominant mode changes as the equipment ages and the maintenance program improves.

## Safety Notes
- A machine that fails repeatedly is a safety risk — emergency repairs are more dangerous than planned repairs.
- Document all failure modes for process safety management — a failure on a toxic or flammable service is a process safety incident.',
   quiz =
'[{"question":"What percentage of rotating equipment failures are bearing-related?","options":["10-20%","40-50%","70-80%","90%"],"correctIndex":1},{"question":"What maintenance strategy fits a bearing fatigue wear-out pattern?","options":["Run to failure","Condition monitoring (vibration, oil analysis) that detects degradation before failure","Time-based replacement only","No maintenance"],"correctIndex":1},{"question":"What maintenance strategy fits a random failure pattern like seal failure from cavitation?","options":["More frequent PMs","A design change — better flush, higher NPSH margin","Time-based replacement","Run to failure"],"correctIndex":1},{"question":"What is the first step in failure mode identification?","options":["Replace the equipment","List the equipment and its failure history from the CMMS","Increase the PM frequency","Replace all bearings"],"correctIndex":1},{"question":"What should be done if bearing failures dominate?","options":["Replace all bearings","Check the lubrication program, the alignment program, and the contamination control","Replace the equipment","Increase the speed"],"correctIndex":1},{"question":"What should be done if no clear dominant failure mode is identified?","options":["Nothing","Focus on design changes and operating procedure improvements — the failures are random","Replace all equipment","Increase PM frequency"],"correctIndex":1},{"question":"Why should failure analysis be shared with operations?","options":["For compliance","Operational upsets (dry running, cavitation) cause many failures","To assign blame","For documentation only"],"correctIndex":1}]'::jsonb
  WHERE title = 'Failure Mode Identification for Rotating Equipment' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Criticality analysis ranks equipment by the consequence of failure — safety, environmental, production, and cost. The criticality rating determines the maintenance strategy and the resource allocation. Understanding criticality analysis is essential for building a defensible maintenance program.

## Key Concepts
- **Criticality rating (A, B, C):** A = critical (failure shuts down the plant or causes a safety/environmental incident). B = important (failure reduces production or causes a minor incident). C = non-critical (failure causes an inconvenience, spare on the shelf).
- **A-critical strategy:** Predictive maintenance (vibration, oil analysis, thermography) at a defined interval, a spare parts strategy, and a documented failure response plan.
- **B-critical strategy:** Predictive maintenance at a longer interval and a reactive spare strategy.
- **C-critical strategy:** Run to failure with a spare on the shelf.
- **Maintenance strategy mix:** The combination of PM (time-based), PdM (condition-based), and RTF (run to failure). The goal is to maximize the ratio of PdM to PM.
- **Goal:** Maximize PdM to PM ratio — PdM finds problems early and schedules the repair, while PM does work regardless of condition, wasting labor on healthy equipment.

## Step-by-Step: Criticality Analysis
1. **List all rotating equipment** in the plant.
2. **For each asset, evaluate the consequence of failure:** Safety (could someone be injured?), Environmental (could there be a release?), Production (what is the downtime cost?), Cost (what is the repair cost?).
3. **Assign a criticality rating:** A if safety/environmental or high production impact, B if moderate production impact, C if minor impact.
4. **Define the maintenance strategy** for each rating: A = PdM monthly + spare parts + failure response plan. B = PdM quarterly + reactive spares. C = RTF + spare on shelf.
5. **Document the criticality analysis** and the maintenance strategy for each asset.
6. **Review annually** — the criticality changes as the plant modifies equipment and production priorities.

## Common Problems and Fixes
- **All equipment is rated A-critical:** The analysis was not rigorous. Re-evaluate with realistic consequence assessments — not everything is critical.
- **C-critical equipment fails and causes a production outage:** The criticality was wrong. Re-evaluate the consequence of failure.
- **A-critical equipment has no PdM:** The strategy was not implemented. Implement the PdM program for all A-critical equipment.
- **The maintenance strategy is all PM, no PdM:** The strategy was not optimized. Replace time-based PM with condition-based PdM where the failure mode allows.

## Best Practices and Field Tips
- Use a cross-functional team (maintenance, operations, engineering) for the criticality analysis — a single perspective misses consequences.
- Document the criticality rationale for each asset — it supports future reviews and audits.
- Target the A-critical equipment first for the PdM program — it provides the most risk reduction for the least effort.
- Trend the maintenance cost by criticality — A-critical equipment should have a higher PdM cost and a lower repair cost; C-critical should have a low PdM cost and a higher repair cost.

## Safety Notes
- A-critical equipment that fails can cause safety incidents — the PdM program is a safety control, not just a maintenance tool.
- Re-evaluate the criticality after any plant modification — a new production line can change the consequence of failure for existing equipment.',
   quiz =
'[{"question":"What is the difference between PM and PdM?","options":["PM is time-based; PdM is condition-based","PM is condition-based; PdM is time-based","They are the same","PM is for critical equipment; PdM is for non-critical"],"correctIndex":0},{"question":"What is the goal of the maintenance strategy mix?","options":["Maximize PM over PdM","Maximize the ratio of PdM to PM","Eliminate all PM","Only use run to failure"],"correctIndex":1},{"question":"What strategy is used for A-critical equipment?","options":["Run to failure","PdM monthly + spare parts + documented failure response plan","PM only","No maintenance"],"correctIndex":1},{"question":"What strategy is used for C-critical equipment?","options":["PdM monthly","Run to failure with a spare on the shelf","PdM quarterly","PM monthly"],"correctIndex":1},{"question":"Who should participate in the criticality analysis?","options":["Maintenance only","A cross-functional team (maintenance, operations, engineering)","Operations only","Engineering only"],"correctIndex":1},{"question":"How often should the criticality analysis be reviewed?","options":["Every 10 years","Annually — criticality changes as the plant modifies equipment and production priorities","Monthly","Never"],"correctIndex":1},{"question":"What should the maintenance cost trend look like for A-critical vs C-critical?","options":["Both should have the same cost","A-critical: higher PdM cost, lower repair cost; C-critical: low PdM cost, higher repair cost","A-critical: low PdM cost; C-critical: high PdM cost","Both should have high PdM cost"],"correctIndex":1}]'::jsonb
  WHERE title = 'Criticality Analysis & Maintenance Strategy' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
A condition monitoring program uses periodic measurements to detect equipment degradation before failure. The three pillars are vibration analysis, oil analysis, and thermography. Building and maintaining the program is the responsibility of the reliability team and is the most cost-effective maintenance strategy for rotating equipment.

## Key Concepts
- **Vibration analysis** is the primary tool — bearing defect frequencies (BPFO, BPFI, BSF, FTF) are calculated from the bearing geometry and the running speed.
- **Oil analysis** detects wear metals (Fe, Cu, Cr) in the lubricant before the vibration signature develops.
- **Thermography** detects abnormal heat from friction, restricted flow, or energy loss.
- **Ultrasound** detects high-frequency friction signals earlier than vibration — a rising ultrasound dB on a bearing that shows no vibration anomaly is an early warning.
- **Alarm thresholds:** Based on ISO 10816 for overall velocity (4.5 mm/s warning, 7.1 mm/s danger) and on the rate of change for specific defect frequencies.
- **Program payback:** The program pays for itself by catching failures early, allowing planned repairs instead of emergency breakdowns, and by eliminating unnecessary PMs on healthy equipment.

## Step-by-Step: Building a Condition Monitoring Program
1. **List all critical rotating machines** and assign a monitoring interval (monthly for A-critical, quarterly for B-critical).
2. **Define the measurement points** on each bearing housing and mark them with paint or a stamped dot for repeatability.
3. **Collect the overall vibration velocity** and the spectrum (FFT) at each point in the radial and axial directions.
4. **Compare the overall** to the ISO 10816 alarm levels (4.5 mm/s warning, 7.1 mm/s danger).
5. **If the overall is elevated, examine the spectrum** for bearing defect frequencies. Input the bearing part number to calculate the expected BPFO, BPFI, BSF, and FTF.
6. **Take an oil sample** quarterly for wear metal analysis and compare to the trend.
7. **Perform an ultrasound reading** during the route — a 7-8 dB rise above baseline indicates early distress.
8. **Perform a thermography scan** during the route — a bearing 20-30°C above an adjacent bearing is in distress.
9. **Trend the data** in a CMMS or database and generate monthly reports listing the machines in alarm and the recommended actions.

## Common Problems and Fixes
- **No trend data:** Without baseline data, you cannot detect a change. Establish baselines on new or recently serviced equipment.
- **Inconsistent measurement location:** A measurement at a different point is not comparable. Mark the point and always measure there.
- **Alarms are ignored:** The program is not integrated with the CMMS. Generate CMMS work orders from the condition monitoring alarms.
- **Program loses momentum:** The reports are not reviewed with the maintenance team. Schedule a monthly review meeting.

## Best Practices and Field Tips
- Start with the A-critical machines and expand as the program matures — do not try to monitor every machine from day one.
- Use the same sensor, the same mounting, and the same machine operating condition for every measurement.
- Combine vibration, oil analysis, thermography, and ultrasound for the most reliable assessment — no single technology catches everything.
- A bearing defect frequency that doubles in amplitude over two consecutive measurements warrants scheduling a replacement.

## Safety Notes
- Never collect vibration data on a machine with the coupling guard removed — the sensor cable can catch in the rotating coupling.
- Be aware of high-vibration machines during data collection — be prepared to shut down if the vibration increases rapidly.',
   quiz =
'[{"question":"What are the three pillars of condition monitoring?","options":["Vibration, oil analysis, and thermography","PM, PdM, and RTF","Visual, audible, and tactile","Temperature, pressure, and flow"],"correctIndex":0},{"question":"What is the ISO 10816 warning level for most industrial machines?","options":["2.8 mm/s","4.5 mm/s","7.1 mm/s","11.2 mm/s"],"correctIndex":1},{"question":"What does a 7-8 dB ultrasound rise above baseline indicate?","options":["Normal operation","Early bearing distress","Imminent failure","Lubrication is excessive"],"correctIndex":1},{"question":"What does a bearing defect frequency that doubles over two measurements warrant?","options":["Immediate shutdown","Scheduling a replacement","Re-lubrication only","No action"],"correctIndex":1},{"question":"How should the condition monitoring program be integrated with maintenance workflow?","options":["It should not be","Generate CMMS work orders from the condition monitoring alarms","Through email only","Through paper reports"],"correctIndex":1},{"question":"What is more significant than the absolute alarm value in condition monitoring?","options":["The equipment age","The rate of change — a reading that doubles over two consecutive measurements","The ambient temperature","The equipment criticality"],"correctIndex":1},{"question":"What should be done to ensure consistent data between monitoring routes?","options":["Use different sensors each time","Mark the measurement points and collect at the same machine operating condition","Collect at random locations","Collect at different loads"],"correctIndex":1}]'::jsonb
  WHERE title = 'Building a Condition Monitoring Program' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;
