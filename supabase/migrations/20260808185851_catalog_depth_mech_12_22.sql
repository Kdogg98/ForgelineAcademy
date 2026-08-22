/*
# Catalog depth expansion — Mechanical courses 12-22 (add modules + update existing lessons)

## Courses in this batch
12. Rigging, Lifting & Material Handling (add 1 module → 3 total)
13. Machine Guarding & Mechanical LOTO (add 1 module → 3 total)
14. Centralized & Automated Lubrication Systems (add 1 module → 3 total)
15. Welding & Fabrication (add 1 module → 3 total)
16. Chain & Belt Drive Systems Advanced (add 1 module → 3 total)
17. Compressors & Compressed Air Systems (add 1 module → 3 total)
18. Heat Exchangers & Cooling Systems (add 1 module → 3 total)
19. Conveyor Troubleshooting & Repair (add 1 module → 3 total)
20. Precision Maintenance Practices (add 1 module → 3 total)
21. Mechanical Seals Advanced Diagnostics (add 1 module → 3 total)
22. Rotating Equipment Reliability Fundamentals (add 1 module → 3 total)

## Security
No schema or policy changes. Data-only migration.
*/

-- Helper function: update lesson content and quiz by title within a course
-- We use DO blocks per course for clean references

-- ===================== 12. RIGGING, LIFTING & MATERIAL HANDLING =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Rigging, Lifting & Material Handling';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Critical Lifts & Advanced Rigging', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Critical Lift Planning & Multi-Crane Lifts',
   '## Overview
A critical lift is one that carries elevated risk — exceeding 75% of crane capacity, involving multiple cranes, lifting over occupied areas, or lifting highly valuable or hazardous loads. Critical lifts require a written plan signed by the lift director and the crane operator.

## Key Concepts
- **Critical lift criteria:** Exceeds 75% of crane capacity, multiple cranes, lifting over occupied areas, or lifting personnel.
- **Lift plan content:** Load weight, rigging weight, crane capacity at the working radius, center of gravity, sling configuration, signal person, exclusion zone, and emergency procedures.
- **Multi-crane lifts:** Each crane carries a portion of the load. The load distribution depends on the sling geometry and the crane hook heights. A crane that lifts higher carries more load.
- **Load distribution:** For a two-crane lift with the load at 10,000 lbs, if crane A is at 40% and crane B is at 60%, crane A carries 4,000 lbs and crane B carries 6,000 lbs. Verify each crane capacity at the working radius exceeds its share.
- **Exclusion zone:** The area under the load path must be cleared. No personnel under a suspended load.

## Step-by-Step: Critical Lift Planning
1. **Determine the total weight:** Load + rigging + attachments.
2. **Determine the center of gravity:** The load will tilt until the CG is below the hook. Test-lift a few inches and observe.
3. **Select the crane(s):** Verify the crane capacity at the working radius exceeds the total weight with margin.
4. **For multi-crane lifts:** Calculate the load distribution. Verify each crane capacity exceeds its share.
5. **Select the rigging:** Slings, shackles, and below-the-hook devices rated for the load.
6. **Determine the sling angle and derate the WLL:** A sling at 30 degrees carries 200% of the load per leg.
7. **Write the lift plan:** Document the weight, the CG, the crane capacity, the rigging, the signal person, the exclusion zone, and the emergency procedures.
8. **Review and sign:** The lift director and the crane operator review and sign the plan.
9. **Conduct a pre-lift briefing:** Review the plan with all participants.
10. **Execute the lift:** Test-lift a few inches, verify stability, then proceed.

## Common Problems and Fixes
- **Load tilts excessively on test-lift:** The CG is not where expected. Set the load down and adjust the rigging.
- **One crane is overloaded:** The load distribution is uneven. Adjust the sling geometry or reposition the cranes.
- **Load swings during the lift:** Wind or sudden crane movement. Stop the lift and wait for calm conditions.
- **Ground is soft under the crane:** The crane outriggers are sinking. Add outrigger pads or mats to distribute the load.

## Best Practices and Field Tips
- Always test-lift a few inches before committing to the full lift — the load behavior reveals the CG and the rigging adequacy.
- For multi-crane lifts, use a tag line on each end of the load to control rotation.
- Document the lift plan and retain it for future reference — similar lifts can reuse the plan.
- For lifts near power lines, maintain a minimum clearance of 20 feet from lines up to 350 kV, per OSHA.

## Safety Notes
- Never lift over occupied areas — clear the exclusion zone before the lift.
- Never exceed the crane capacity at any working radius — the capacity decreases with radius.
- A failed sling or shackle under load can drop the load catastrophically — inspect all rigging before each lift.',
   55, 1,
   '[{"question":"What makes a lift a critical lift?","options":["Any lift over 100 lbs","Exceeds 75% of crane capacity, multiple cranes, lifting over occupied areas, or lifting personnel","Any lift outdoors","Any lift using a chain sling"],"correctIndex":1},{"question":"What must be written and signed for a critical lift?","options":["Nothing","A lift plan signed by the lift director and the crane operator","A purchase order","A daily log"],"correctIndex":1},{"question":"In a multi-crane lift, what determines the load distribution?","options":["The crane speed","The sling geometry and the crane hook heights — a crane that lifts higher carries more load","The crane brand","The operator experience"],"correctIndex":1},{"question":"What should be done if the load tilts excessively on test-lift?","options":["Continue the lift","Set the load down and adjust the rigging — the CG is not where expected","Increase the crane speed","Add more slings"],"correctIndex":1},{"question":"What is the minimum clearance from power lines up to 350 kV per OSHA?","options":["5 feet","10 feet","20 feet","50 feet"],"correctIndex":2},{"question":"What should always be done before committing to the full lift?","options":["Nothing","Test-lift a few inches to verify stability and CG","Full speed immediately","Remove the tag lines"],"correctIndex":1},{"question":"What must be cleared before a critical lift?","options":["The crane cab","The exclusion zone — the area under the load path, no personnel under a suspended load","The weather","The rigging inventory"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons with structured content + 7Q quizzes
  UPDATE lessons SET content =
'## Overview
Wire rope slings are the most common industrial sling. Understanding the types, the ratings, and the inspection criteria is essential for safe lifting operations.

## Key Concepts
- **Wire rope slings** are rated by diameter, construction (6x19, 6x37), and fitting type. The WLL is typically 1/5 of the breaking strength.
- **Chain slings** are used for high-temperature and abrasive environments where wire rope would degrade.
- **Synthetic web and round slings** protect delicate loads but are damaged by UV, chemicals, and cuts.
- **Sling angle effect:** The sling angle reduces the WLL — at 60° from horizontal, each leg carries 115% of the load; at 45°, 141%; at 30°, 200%.
- **Design factor:** Typically 5:1 for general service. The WLL is the breaking strength divided by the design factor.

## Step-by-Step: Sling Selection and Inspection
1. **Determine the load weight** including all rigging.
2. **Select the sling type:** Wire rope for general, chain for high-temperature/abrasive, synthetic for delicate loads.
3. **Calculate the sling angle effect:** Measure the angle from horizontal and derate the WLL accordingly.
4. **Verify the sling WLL** exceeds the load per leg after derating.
5. **Inspect the sling before each use:** Wire rope for broken wires, kinks, birdcaging; chain for stretched links, nicks, cracks; synthetic for cuts, abrasion, chemical damage.
6. **Remove and tag** any sling that fails inspection.

## Common Problems and Fixes
- **Sling angle is too shallow (below 30°):** The load per leg exceeds the WLL. Use longer slings to increase the angle.
- **Wire rope has broken wires:** The sling is degraded. Remove from service if the number of broken wires in one lay length exceeds 6 (general service) or 3 (running rope).
- **Chain links are stretched:** The chain has been overloaded. Remove from service.
- **Synthetic sling has cuts:** The sling is damaged. Remove from service — cuts propagate under load.

## Best Practices and Field Tips
- Always calculate the sling angle and derate the WLL — ignoring the angle is the most common rigging error.
- Use a sling angle chart for quick reference in the field.
- Inspect slings before every use, not just annually — a sling can be damaged during storage.
- Document the sling inspection with the date, the sling ID, and the result.

## Safety Notes
- Never use a damaged sling — it can fail under load and drop the load.
- Never stand under a suspended load — the rigging can fail at any time.',
   quiz =
'[{"question":"What is the typical design factor (breaking strength to WLL) for general service slings?","options":["3:1","5:1","10:1","20:1"],"correctIndex":1},{"question":"What happens to the load per leg when the sling angle decreases from 60 to 30 degrees?","options":["It decreases","It stays the same","It increases significantly","It doubles at 45 degrees"],"correctIndex":2},{"question":"What should be done if the sling angle is below 30 degrees?","options":["Continue the lift","Use longer slings to increase the angle","Add more slings","Reduce the load"],"correctIndex":1},{"question":"How many broken wires in one lay length are acceptable for a general-service wire rope sling?","options":["0","Up to 6","Up to 12","Up to 20"],"correctIndex":1},{"question":"What does a stretched chain link indicate?","options":["Normal wear","The chain has been overloaded — remove from service","The chain is new","The chain needs lubrication"],"correctIndex":1},{"question":"Which sling type is best for high-temperature environments?","options":["Wire rope","Chain sling","Synthetic web","Any sling"],"correctIndex":1},{"question":"What should be done with a synthetic sling that has cuts?","options":["Tape the cut","Remove from service — cuts propagate under load","Continue using","Sew the cut"],"correctIndex":1}]'::jsonb
  WHERE title = 'Sling Types, Selection & Inspection' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Before any lift, calculate the total weight and determine the center of gravity. Use standard hand signals and maintain clear communication with the crane operator. For critical lifts, a written plan is required.

## Key Concepts
- **Total weight** includes the load, the rigging, and all attachments.
- **Center of gravity (CG):** The load tilts until the CG is directly below the hook. Test-lift a few inches and observe the tilt.
- **Standard hand signals (ASME B30.5):** One fist pump for hoist up, palm down push for trolley travel, finger circle for stop. Only one person signals unless it is a stop.
- **Critical lift plan:** Required for lifts exceeding 75% of crane capacity, multiple cranes, or lifting over occupied areas.

## Step-by-Step: Load Calculation and Lift Execution
1. **Calculate the total weight:** Load + rigging + attachments.
2. **Verify the crane capacity** exceeds the total weight with margin.
3. **Determine the CG:** Test-lift a few inches and observe the tilt. Adjust the rigging and re-test until the load hangs level.
4. **Use standard hand signals:** Only one person signals the operator.
5. **For critical lifts:** Write and sign a lift plan before the lift.
6. **Establish an exclusion zone:** No personnel under the load path.
7. **Execute the lift:** Test-lift, verify stability, then proceed smoothly.

## Common Problems and Fixes
- **Load tilts on test-lift:** The CG is not where expected. Set down and adjust the rigging.
- **Multiple signalers confuse the operator:** Only one person signals. Designate the signal person before the lift.
- **Load swings:** Wind or sudden crane movement. Stop and wait for calm conditions. Use tag lines to control rotation.
- **Crane capacity is marginal:** Reduce the rigging weight, or use a larger crane.

## Best Practices and Field Tips
- Always test-lift a few inches before committing — the load behavior reveals the CG.
- Use tag lines on each end of the load to control rotation.
- Brief all participants before the lift — everyone should know the plan.
- For lifts near power lines, use a spotter to maintain clearance.

## Safety Notes
- Never stand under a suspended load.
- Only one person gives signals to the operator (except stop — anyone can give a stop).
- A crane that is overloaded can tip or drop the load — verify the capacity at the working radius.',
   quiz =
'[{"question":"Why will a load tilt when lifted?","options":["Because of wind","Until the center of gravity is directly below the hook","Because of sling stretch","Because the crane is not level"],"correctIndex":1},{"question":"When is a written lift plan required?","options":["For every lift","Only for lifts over 1000 lbs","For critical lifts exceeding 75% of capacity, multiple cranes, or lifting over occupied areas","Never"],"correctIndex":2},{"question":"How many people should give signals to the crane operator?","options":["Anyone can signal","Only one person (except stop — anyone can give a stop)","Up to three","The entire crew"],"correctIndex":1},{"question":"What should be done if the load tilts on test-lift?","options":["Continue the lift","Set the load down and adjust the rigging — the CG is not where expected","Increase the crane speed","Add more slings"],"correctIndex":1},{"question":"What should be used to control load rotation during a lift?","options":["Nothing","Tag lines on each end of the load","A second crane","A rope"],"correctIndex":1},{"question":"What should everyone do before a lift?","options":["Nothing","Be briefed on the plan — everyone should know the plan","Leave the area","Take photos"],"correctIndex":1},{"question":"What can happen if a crane is overloaded?","options":["Nothing — cranes have safety margins","The crane can tip or drop the load — verify the capacity at the working radius","The crane runs faster","The load swings more"],"correctIndex":1}]'::jsonb
  WHERE title = 'Load Calculation & Crane Signals' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Shackles, hooks, and below-the-hook devices are the connection points between the sling and the load. Understanding their ratings, inspection criteria, and correct use is essential for safe rigging.

## Key Concepts
- **Anchor shackles (bow type)** have a wider load-bearing area and accommodate multiple slings. **Chain shackles (D type)** are for straight-line pulls only.
- **Never side-load a shackle** — the WLL is for in-line loads; side loading reduces capacity by 25-75%.
- **Hook safety latch** prevents the sling from slipping off. Inspect hooks for stretching — if the throat opening increases by 5%, remove from service.
- **Turnbuckles** adjust sling length but must be safety-wired to prevent rotation under load.
- **Below-the-hook devices** (spreaders, lifting beams) distribute the load to prevent crushing or bending.

## Step-by-Step: Rigging Hardware Inspection
1. **Inspect shackles:** Check for pin thread damage, pin bending, and body wear. Verify the pin is the correct pin for the shackle (not a bolt).
2. **Inspect hooks:** Check the safety latch function. Measure the throat opening and compare to the original — a 5% increase indicates overload.
3. **Inspect turnbuckles:** Check for thread damage and verify the safety wire is installed.
4. **Inspect below-the-hook devices:** Check for cracks, deformation, and the rated capacity tag.
5. **Remove and tag** any hardware that fails inspection.

## Common Problems and Fixes
- **Shackle pin is bent:** The shackle was side-loaded or overloaded. Replace the shackle.
- **Hook latch does not close:** The latch spring is broken. Replace the latch.
- **Turnbuckle unscrews under load:** The safety wire is missing. Install the safety wire before use.
- **Spreader beam is cracked:** The beam has been overloaded. Remove from service and have it inspected by a qualified person.

## Best Practices and Field Tips
- Always use the correct pin for the shackle — a bolt is not a shackle pin and can fail under load.
- Never side-load a shackle — if side loading is unavoidable, derate the WLL per the manufacturer chart.
- Document the hardware inspection with the date, the hardware ID, and the result.
- For lifting beams, verify the load is distributed evenly — an uneven load can overload one end of the beam.

## Safety Notes
- Never use a shackle with a bent pin or a cracked body — it can fail under load.
- A hook without a safety latch can release the sling — replace the latch before use.',
   quiz =
'[{"question":"What happens to a shackle WLL when side-loaded?","options":["It increases","It stays the same","It is reduced by 25-75%","It is zero"],"correctIndex":2},{"question":"How much throat opening increase on a hook requires removal from service?","options":["1%","5%","10%","15%"],"correctIndex":1},{"question":"What must be installed on a turnbuckle to prevent rotation under load?","options":["Nothing","Safety wire","A lock nut","A pin"],"correctIndex":1},{"question":"What should be used as a shackle pin?","options":["Any bolt that fits","The correct shackle pin — a bolt is not a shackle pin and can fail under load","A threaded rod","Any pin"],"correctIndex":1},{"question":"What does a hook without a safety latch risk?","options":["Nothing","The sling can slip off — replace the latch before use","The hook is weaker","The hook is stronger"],"correctIndex":1},{"question":"What should be done if a spreader beam is cracked?","options":["Weld the crack","Remove from service and have it inspected by a qualified person","Continue using","Grind the crack"],"correctIndex":1},{"question":"Why should the load be distributed evenly on a lifting beam?","options":["For appearance","An uneven load can overload one end of the beam","To save time","It is required by code"],"correctIndex":1}]'::jsonb
  WHERE title = 'Shackles, Hooks, Turnbuckles & Below-the-Hook Devices' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 13. MACHINE GUARDING & MECHANICAL LOTO =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Machine Guarding & Mechanical LOTO';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'LOTO Program Administration & Audit', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'LOTO Program Development, Training & Audit',
   '## Overview
A lockout/tagout (LOTO) program is a documented procedure that protects workers from hazardous energy during maintenance. The program must be written, trained, and audited to be effective. A LOTO program that is not audited will deteriorate over time as equipment changes and personnel turn over.

## Key Concepts
- **LOTO program elements (CFR 1910.147):** Written procedures for each machine, locks and tags assigned to each worker, training for authorized and affected workers, and periodic audits.
- **Energy source procedure:** A written document for each machine listing all energy sources, isolation points, lock locations, and the verification method (attempt to start after lockout).
- **Authorized vs. affected workers:** Authorized workers apply locks; affected workers work near the machine but do not apply locks. Both require training.
- **Periodic audit:** Each LOTO procedure must be audited at least annually by an authorized person other than the one who uses the procedure — to verify the procedure is accurate and being followed.
- **Group LOTO:** When multiple workers are involved, a lock box is used — each worker applies their lock to the box, and the machine keys are inside the box.

## Step-by-Step: LOTO Program Audit
1. **Select a machine** for audit.
2. **Observe a LOTO event** on that machine — watch the authorized worker isolate, lock, bleed, and verify.
3. **Compare the observed procedure** to the written procedure — do they match?
4. **Verify the written procedure** is accurate — are all energy sources listed? Are the isolation points correct? Is the verification method described?
5. **Verify the worker training** is current — has the authorized worker been trained within the required interval?
6. **Document the audit** with the date, the machine, the procedure reviewed, the findings, and any corrections needed.
7. **Correct any deficiencies** found during the audit — update the procedure, retrain the worker, or repair a missing lock point.

## Common Problems and Fixes
- **Written procedure does not match the machine:** The machine was modified and the procedure was not updated. Update the procedure after any machine modification.
- **Worker does not verify zero energy:** The verification step (attempt to start) is skipped. Retrain the worker on the importance of verification.
- **Locks are shared:** Workers are sharing locks or keys. Issue individual locks and keys to each worker — never share.
- **Audit is overdue:** The annual audit was not performed. Schedule the audit and assign a responsible person.

## Best Practices and Field Tips
- Use a standardized LOTO procedure form for each machine — consistency makes the program easier to audit and maintain.
- Photograph each isolation point and include the photo in the procedure — it eliminates ambiguity about which valve or breaker to lock.
- Use a group lock box for multi-worker tasks — it ensures each worker is protected by their own lock.
- Schedule the annual audit on the CMMS as a PM — it ensures the audit is not forgotten.

## Safety Notes
- A LOTO program that is not audited will fail when it is needed — the audit is the safety net.
- Never bypass the LOTO procedure to save time — the time saved is not worth the risk of injury or death.',
   55, 1,
   '[{"question":"How often must each LOTO procedure be audited per CFR 1910.147?","options":["Monthly","At least annually","Every 5 years","Only after an incident"],"correctIndex":1},{"question":"Who must perform the LOTO audit?","options":["The worker who uses the procedure","An authorized person other than the one who uses the procedure","Any supervisor","The safety manager only"],"correctIndex":1},{"question":"What is the difference between authorized and affected workers?","options":["They are the same","Authorized workers apply locks; affected workers work near the machine but do not apply locks","Authorized workers are supervisors","Affected workers are visitors"],"correctIndex":1},{"question":"What is used when multiple workers are involved in a LOTO?","options":["One lock for everyone","A group lock box — each worker applies their lock to the box, and the machine keys are inside","No locks needed","A tag only"],"correctIndex":1},{"question":"What should be done if the written procedure does not match the machine?","options":["Nothing","Update the procedure after any machine modification","Rewrite all procedures","Ignore the discrepancy"],"correctIndex":1},{"question":"What should be included in the LOTO procedure to eliminate ambiguity?","options":["A long description","A photograph of each isolation point","A flowchart","A phone number"],"correctIndex":1},{"question":"What does the verification step (attempt to start) confirm?","options":["The machine is running","Zero energy — the machine does not start when the start button is pressed after lockout","The machine is ready","The motor is good"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons
  UPDATE lessons SET content =
'## Overview
OSHA 1910.212 requires that any machine part that creates a hazard must be guarded. Guards protect operators from rotating parts, pinch points, and flying debris. Understanding the guard types and the selection criteria is essential for machine safety.

## Key Concepts
- **Fixed guards** are permanently attached and require tools to remove — the most secure but the least flexible.
- **Interlocked guards** stop the machine when the guard is opened or removed — allows access for setup and clearing jams.
- **Adjustable guards** can be positioned to accommodate different stock sizes — common on table saws and press brakes.
- **Self-adjusting guards** move with the stock — common on radial arm saws.
- **Point of operation guarding:** Barrier guards, two-hand controls (both hands on controls, away from the danger zone), and light curtains (machine stops if the beam is broken).
- **Guard requirements:** Prevent access to the danger zone, not create a new hazard (no pinch points on the guard), and not be easily bypassed.

## Step-by-Step: Machine Guard Assessment
1. **Identify all hazard points** on the machine: rotating parts, pinch points, nip points, flying debris zones, and hot surfaces.
2. **Verify each hazard point is guarded:** Is there a guard? Is it the correct type? Is it in good condition?
3. **Verify the guard meets the requirements:** Prevents access, does not create a new hazard, is not easily bypassed.
4. **Verify interlocked guards function correctly:** Open the guard and verify the machine stops. Close the guard and verify the machine can start.
5. **Verify light curtains function correctly:** Break the beam and verify the machine stops. Verify the response time is within the specification.
6. **Document the assessment** with the machine ID, the hazard points, the guard types, and any deficiencies.
7. **Correct any deficiencies** — install missing guards, repair damaged guards, or replace failed interlocks.

## Common Problems and Fixes
- **Guard is removed for production convenience:** The guard is slowing production. Modify the guard design to allow production without removing it, or enforce the guard policy.
- **Interlocked guard is bypassed:** The interlock switch is taped or wired to allow operation with the guard open. Remove the bypass and retrain the operator.
- **Light curtain does not stop the machine:** The response time is too slow or the curtain is misaligned. Adjust the curtain and verify the response time.
- **Guard creates a new pinch point:** The guard design is poor. Redesign the guard to eliminate the pinch point.

## Best Practices and Field Tips
- Include a guard assessment in the machine risk assessment — it is a regulatory requirement, not an option.
- Use interlocked guards for points that require frequent access (setup, clearing jams) — fixed guards are too slow for frequent access.
- Use light curtains for points that require the operator to reach into the danger zone (press feeds, robot cells) — they allow access while stopping the machine if the operator enters.
- Train operators on the purpose of each guard — an operator who understands the guard is less likely to bypass it.

## Safety Notes
- Never remove a guard to speed up production — the guard is there for a reason.
- A bypassed interlock is a willful safety violation — report and correct immediately.
- A light curtain that does not stop the machine is worse than no light curtain — it gives false confidence.',
   quiz =
'[{"question":"Which guard type stops the machine when the guard is opened?","options":["Fixed guard","Interlocked guard","Adjustable guard","Self-adjusting guard"],"correctIndex":1},{"question":"What must be true of a guard to comply with OSHA 1910.212?","options":["It must be transparent","It must prevent access to the danger zone and not create a new hazard","It must be made of plastic","It must cover the entire machine"],"correctIndex":1},{"question":"Which guarding method requires both hands on controls, away from the danger zone?","options":["Barrier guard","Two-hand controls","Light curtain","Fixed guard"],"correctIndex":1},{"question":"What should be done if an interlocked guard is bypassed?","options":["Nothing","Remove the bypass and retrain the operator","Replace the guard","Increase production speed"],"correctIndex":1},{"question":"What should be verified for a light curtain during a guard assessment?","options":["Its color","Break the beam and verify the machine stops; verify the response time is within specification","Its height","Its brand"],"correctIndex":1},{"question":"Which guard type is best for points requiring frequent access?","options":["Fixed guard","Interlocked guard — fixed guards are too slow for frequent access","No guard","A warning sign"],"correctIndex":1},{"question":"What is a willful safety violation?","options":["Removing a guard for convenience","A bypassed interlock — report and correct immediately","A missing safety manual","A dented guard"],"correctIndex":1}]'::jsonb
  WHERE title = 'OSHA 1910.212 & Guard Types' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
Mechanical lockout/tagout (LOTO) isolates hazardous energy before maintenance. The energy sources for mechanical systems include electrical, pneumatic, hydraulic, gravitational, and stored energy. Understanding the LOTO procedure and the energy types is essential for safe maintenance.

## Key Concepts
- **Energy sources for mechanical systems:** Electrical (the motor), pneumatic (compressed air cylinders), hydraulic (pressurized fluid), gravitational (raised loads, counterweights), and stored energy (springs, accumulators, flywheels).
- **LOTO procedure:** Notify affected employees, shut down normally, isolate all energy sources, apply locks and tags, dissipate stored energy, and verify zero energy by attempting to start.
- **Each worker applies their own lock** — never share a lock or key.
- **Group lock box:** Each worker places their lock on the box; the machine keys are inside the box.
- **Only the person who applied the lock removes it.**
- **Block or pin any component** that could fall or rotate — a valve alone does not prevent a cylinder from drifting.

## Step-by-Step: Mechanical LOTO Procedure
1. **Notify affected employees** that the machine is being locked out for maintenance.
2. **Shut down the machine** by the normal stop procedure (stop button, software shutdown).
3. **Identify all energy sources:** electrical, pneumatic, hydraulic, gravitational, stored. Use the machine-specific LOTO procedure as the checklist.
4. **Isolate each energy source:** Open the electrical disconnect and lock it. Close the pneumatic valve and lock it. Close the hydraulic valve and lock it. Block or pin any raised loads.
5. **Apply locks and tags** to each isolation point. Each worker applies their own lock.
6. **Dissipate stored energy:** Bleed pneumatic pressure to zero. Release hydraulic pressure to zero. Lower or block raised loads. Release spring tension. Verify the flywheel has stopped.
7. **Verify zero energy:** Attempt to start the machine by pressing the start button. The machine should not start. Also verify that pneumatic and hydraulic gauges read zero.
8. **Perform the maintenance.**
9. **Remove locks and tags** only after all workers are clear and the area is inspected. Each worker removes their own lock.
10. **Notify affected employees** that the machine is being returned to service.
11. **Start the machine** and verify it operates normally.

## Common Problems and Fixes
- **Machine starts during maintenance:** An energy source was not isolated. Re-verify all energy sources and add the missing isolation point to the procedure.
- **Cylinder drifts during maintenance:** The pneumatic valve was locked but the cylinder was not blocked. Block or pin the cylinder — a valve alone does not prevent drift.
- **Stored energy was not dissipated:** The spring or accumulator was not released. Add the dissipation step to the procedure.
- **Lock is missing or shared:** Issue individual locks and keys to each worker.

## Best Practices and Field Tips
- Use the machine-specific LOTO procedure as a checklist — do not rely on memory.
- Photograph each isolation point and include the photo in the procedure — it eliminates ambiguity.
- Verify zero energy by attempting to start, not by looking at the disconnect — a closed disconnect may have a by-pass or a second source.
- For complex machines, use a group lock box — it ensures each worker is protected by their own lock.

## Safety Notes
- Never share a lock or key — each worker must have their own.
- Only the person who applied the lock removes it — no exceptions, even for a supervisor.
- A machine that starts during maintenance can cause severe injury or death — the LOTO procedure is the last line of defense.',
   quiz =
'[{"question":"What must be done after isolating energy sources and applying locks?","options":["Start the machine to test it","Dissipate stored energy and verify zero energy by attempting to start","Leave the area","Tag the machine only"],"correctIndex":1},{"question":"Who may remove a lock applied during LOTO?","options":["Any supervisor","The person who applied it","The safety manager","Any coworker with the key"],"correctIndex":1},{"question":"What energy sources must be isolated for a mechanical system?","options":["Electrical only","Electrical, pneumatic, hydraulic, gravitational, and stored energy (springs, accumulators, flywheels)","Electrical and pneumatic only","Electrical only is sufficient"],"correctIndex":1},{"question":"What must be done with a raised load during LOTO?","options":["Nothing","Block or pin it — a valve alone does not prevent a cylinder from drifting","Lower it slowly","Tag it"],"correctIndex":1},{"question":"How is zero energy verified?","options":["By looking at the disconnect","By attempting to start the machine — it should not start","By checking the oil level","By asking the operator"],"correctIndex":1},{"question":"What is used when multiple workers are involved in LOTO?","options":["One lock for everyone","A group lock box — each worker places their lock on the box, and the machine keys are inside","No locks needed","A tag only"],"correctIndex":1},{"question":"What does a closed disconnect with a bypass or second source risk?","options":["Nothing","The machine starts during maintenance — verify by attempting to start, not by looking at the disconnect","Energy savings","Faster startup"],"correctIndex":1}]'::jsonb
  WHERE title = 'Energy Isolation for Mechanical Systems' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- ===================== 14-22: Add one module each with 2 lessons to remaining courses =====================
-- For courses 14-22, we add one module each (bringing them to 3 modules) with 2 new lessons each.

-- 14. Centralized & Automated Lubrication Systems
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Centralized & Automated Lubrication Systems';
  IF NOT FOUND THEN RETURN; END IF;
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced System Design & Troubleshooting', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'System Design, Pump Sizing & Divider Block Operation',
   '## Overview
Designing a centralized lubrication system requires understanding the bearing count, the grease type, the line distances, and the pump capacity. A well-designed system delivers the correct grease quantity to each bearing automatically, eliminating the human error of manual greasing.

## Key Concepts
- **System sizing:** The pump must deliver the total metered volume per cycle plus 30% margin for line fill and expansion.
- **Divider block operation:** A series-progressive divider block meters grease sequentially — a blockage at one bearing stops flow to all.
- **Line sizing:** The grease line diameter and length affect the pressure drop. Lines that are too small or too long cannot deliver the grease at the available pump pressure.
- **Grease selection:** The grease must be the correct NLGI grade for the system — a grease that is too stiff will not flow through the lines in cold weather.
- **Cycle monitoring:** A cycle indicator on the divider block confirms that grease is flowing. A non-cycling indicator means a blockage, an empty reservoir, or a failed pump.

## Step-by-Step: System Design and Sizing
1. **List all bearings** to be lubricated, with the required grease quantity per cycle for each.
2. **Calculate the total metered volume** per cycle: sum of all bearing quantities.
3. **Size the pump** for the total volume plus 30% margin.
4. **Size the grease lines** for the distance and the pressure drop. Use the manufacturer sizing chart for the grease NLGI grade and the operating temperature.
5. **Select the divider block** with the correct number of outlets and the correct metering size for each bearing.
6. **Verify the cycle indicator** is visible and accessible for monitoring.
7. **Document the system design** with the bearing list, the grease type, the line sizes, and the pump capacity.

## Common Problems and Fixes
- **Grease does not reach the furthest bearing:** The line is too long or too small, or the pump pressure is insufficient. Increase the line diameter or the pump pressure.
- **Divider block does not cycle:** A line is blocked, the reservoir is empty, or the pump has failed. Find and clear the blockage.
- **Grease is too stiff in cold weather:** The NLGI grade is too high for the operating temperature. Switch to a lower NLGI grade or add a line heater.
- **One bearing gets too much grease:** The metering valve is oversized for that bearing. Replace with a smaller metering valve.

## Best Practices and Field Tips
- Install a pressure gauge at the pump discharge to monitor the system pressure — a rising pressure indicates a developing blockage.
- Install a low-level switch on the reservoir to alarm when the grease is low.
- Use a progressive divider block for systems where blockage detection is critical — a blocked bearing stops the entire system.
- Document the system design and the grease type for future maintenance.

## Safety Notes
- Never disconnect a grease line under pressure — the pump can develop high pressure. Bleed the pressure before disconnecting.
- Centralized lubrication systems use grease under pressure — wear safety glasses when working on the system.',
   50, 1,
   '[{"question":"What margin should be added to the total metered volume when sizing a centralized lubrication pump?","options":["10%","30%","50%","100%"],"correctIndex":1},{"question":"What happens in a series-progressive system when one bearing line blocks?","options":["Only that bearing stops getting grease","All bearings stop getting grease","The system continues normally","The pump overpressurizes"],"correctIndex":1},{"question":"What does a non-cycling divider block indicator mean?","options":["Normal operation","A blocked line, empty reservoir, or failed pump","Too much grease","The system is over-pressurized"],"correctIndex":1},{"question":"What should be installed at the pump discharge to monitor system health?","options":["A flow meter","A pressure gauge — a rising pressure indicates a developing blockage","A temperature gauge","Nothing"],"correctIndex":1},{"question":"What should be installed on the reservoir to alarm when grease is low?","options":["A sight glass","A low-level switch to alarm when the grease is low","A temperature gauge","Nothing"],"correctIndex":1},{"question":"What happens if the grease NLGI grade is too high for cold weather?","options":["Nothing","The grease will not flow through the lines — switch to a lower NLGI grade or add a line heater","The system runs faster","The pump overheats"],"correctIndex":1},{"question":"What should be done before disconnecting a grease line?","options":["Nothing","Bleed the pressure — the pump can develop high pressure","Increase the pressure","Heat the line"],"correctIndex":1}]'::jsonb),
  (m_id, 'Troubleshooting Flow Issues & System Commissioning',
   '## Overview
Commissioning a centralized lubrication system and troubleshooting flow issues requires a systematic approach. A new system must be verified to deliver the correct quantity to each bearing, and an existing system that develops flow issues must be diagnosed and corrected.

## Key Concepts
- **Commissioning procedure:** Fill the reservoir, prime the pump, purge the lines, verify flow at each bearing, set the cycle timer, and document the baseline.
- **Flow verification:** Crack each bearing line fitting one at a time while the pump runs and verify grease appears at each fitting.
- **Cycle timer setting:** The timer is set to cycle the pump at the interval that delivers the required grease quantity per bearing per day.
- **Blockage diagnosis:** A blocked line is found by cracking each fitting downstream from the divider block — the point where grease does not appear is downstream of the blockage.
- **System pressure monitoring:** A rising system pressure indicates a developing blockage. Install a pressure gauge and trend the pressure.

## Step-by-Step: System Commissioning
1. **Fill the reservoir** with the correct grease (verify the NLGI grade and the thickener compatibility).
2. **Prime the pump** by running it until grease appears at the pump outlet.
3. **Purge the lines** by running the pump until grease appears at the furthest bearing fitting.
4. **Verify flow at each bearing:** Crack each fitting one at a time and verify grease appears. Tighten the fitting after verification.
5. **Set the cycle timer** to deliver the required grease quantity per bearing per day (based on the bearing manufacturer recommendation).
6. **Document the baseline** with the cycle time, the system pressure, and the flow verification results.

## Step-by-Step: Troubleshooting Flow Issues
1. **Check the reservoir level** — an empty reservoir is the most common cause of no flow.
2. **Check the pump operation** — verify the pump runs and develops pressure. If not, check the pump motor, the pump drive, and the pump internal valves.
3. **Check the cycle indicator** — if it does not cycle, there is a blockage or the pump is not delivering.
4. **Find the blockage** by cracking each bearing fitting one at a time while the pump runs — the fitting where grease does not appear is downstream of the blockage.
5. **Clear the blockage** by disconnecting the line and blowing it out with a compatible solvent.
6. **Reconnect and verify** flow at the cleared line.

## Common Problems and Fixes
- **No grease at any bearing:** The reservoir is empty, the pump has failed, or the main line is blocked. Check the reservoir, the pump, and the main line.
- **No grease at one bearing:** The line to that bearing is blocked or the metering valve is failed. Clear the line or replace the valve.
- **Too much grease at one bearing:** The metering valve is oversized or stuck open. Replace the valve.
- **System pressure is rising:** A blockage is developing. Find and clear the blockage before the pressure exceeds the system rating.

## Best Practices and Field Tips
- Install a pressure gauge and a cycle indicator at the pump for continuous monitoring.
- Trend the system pressure — a rising pressure is the first sign of a developing blockage.
- Use a clear reservoir or a sight glass to verify the grease level visually.
- Document the commissioning baseline for future troubleshooting reference.

## Safety Notes
- Never disconnect a grease line under pressure — bleed the pressure first.
- Centralized lubrication systems use grease under high pressure — wear safety glasses.',
   50, 2,
   '[{"question":"What is the first check when no grease is reaching any bearing?","options":["Replace the pump","Check the reservoir level — an empty reservoir is the most common cause","Replace all lines","Increase the pump pressure"],"correctIndex":1},{"question":"How is a blockage found in a centralized lubrication system?","options":["Replace all lines","Crack each bearing fitting one at a time while the pump runs — the fitting where grease does not appear is downstream of the blockage","Increase the pump pressure","Remove the divider block"],"correctIndex":1},{"question":"What does a rising system pressure indicate?","options":["Normal operation","A developing blockage — find and clear it before the pressure exceeds the system rating","The pump is improving","The reservoir is full"],"correctIndex":1},{"question":"What should be done during commissioning to verify flow at each bearing?","options":["Nothing — trust the design","Crack each fitting one at a time and verify grease appears, then tighten","Run the pump for 24 hours","Check only the furthest bearing"],"correctIndex":1},{"question":"What should be documented during commissioning?","options":["Only the date","The cycle time, system pressure, and flow verification results","Only the grease type","Only the pump model"],"correctIndex":1},{"question":"What causes too much grease at one bearing?","options":["The pump is too large","The metering valve is oversized or stuck open — replace the valve","The line is too large","Normal operation"],"correctIndex":1},{"question":"What should be installed for continuous system monitoring?","options":["Nothing","A pressure gauge and a cycle indicator at the pump","A flow meter at each bearing","A temperature gauge"],"correctIndex":1}]'::jsonb);

  -- Update existing lessons
  UPDATE lessons SET content =
'## Overview
Centralized lubrication systems deliver measured grease to multiple bearings from a central pump, eliminating the need for manual greasing. Understanding the system types and their advantages is the foundation for designing and maintaining these systems.

## Key Concepts
- **Series-progressive systems** use a divider block that meters grease sequentially to each bearing — a blockage at one bearing stops flow to all, making blockages easy to detect.
- **Dual-line systems** use two supply lines and a reversing valve; each cycle delivers grease to half the bearings, then reverses — allows continued operation if one line fails.
- **Single-line systems** use a pump to pressurize a line, and metering valves at each bearing dispense a measured shot when the line pressurizes, then reset when the line vents — simplest and most common for moderate bearing counts.
- **Pump sizing** is for the total metered volume per cycle plus a 30% margin for line fill and expansion.
- **Selection criteria:** Bearing count, distance, grease type, and the criticality of detecting blockages.

## Step-by-Step: System Type Selection
1. **Determine the bearing count** to be lubricated.
2. **Determine the distance** from the pump to the furthest bearing.
3. **Determine the grease type** and the NLGI grade.
4. **Determine the blockage detection requirement** — is it critical that a blockage is detected immediately?
5. **If blockage detection is critical:** Select a series-progressive system (a blockage stops all flow and is immediately detected).
6. **If continued operation during a line failure is critical:** Select a dual-line system.
7. **If simplicity is the priority for a moderate bearing count:** Select a single-line system.
8. **Size the pump** for the total metered volume per cycle plus 30% margin.

## Common Problems and Fixes
- **Series-progressive system stops when one line blocks:** This is by design — the blockage is detected. Clear the blockage to restore flow.
- **Dual-line system does not deliver to one side:** The reversing valve is stuck. Check and repair the valve.
- **Single-line system delivers inconsistent quantities:** The metering valves are worn or the pump pressure is inconsistent. Replace the valves or check the pump.
- **System is too complex for the application:** Simplify to a single-line system for moderate bearing counts.

## Best Practices and Field Tips
- For systems where blockage detection is critical (food, pharmaceutical), use series-progressive — the blockage is detected immediately.
- For systems where continued operation is critical (continuous process), use dual-line — one line can fail without stopping the system.
- For simple systems with moderate bearing counts, use single-line — it is the easiest to maintain.
- Document the system type and the design rationale for future reference.

## Safety Notes
- Centralized lubrication systems use grease under pressure — never disconnect a line under pressure.
- The pump can develop high pressure if a line is blocked — install a pressure relief to protect the system.',
   quiz =
'[{"question":"What happens in a series-progressive system when one bearing line blocks?","options":["Only that bearing stops getting grease","All bearings stop getting grease","The system continues normally","The pump overpressurizes"],"correctIndex":1},{"question":"Which system type is simplest and most common for moderate bearing counts?","options":["Series-progressive","Dual-line","Single-line","Manual grease gun"],"correctIndex":2},{"question":"Which system type allows continued operation if one line fails?","options":["Series-progressive","Dual-line","Single-line","All of them"],"correctIndex":1},{"question":"What margin should be added to the total metered volume when sizing the pump?","options":["10%","30%","50%","100%"],"correctIndex":1},{"question":"Which system type should be used when blockage detection is critical?","options":["Single-line","Dual-line","Series-progressive — a blockage stops all flow and is detected immediately","Any system"],"correctIndex":2},{"question":"What should be installed to protect the system from overpressure?","options":["A larger pump","A pressure relief","A larger reservoir","A cycle indicator"],"correctIndex":1},{"question":"What is the primary advantage of centralized lubrication over manual greasing?","options":["It is cheaper","It eliminates human error in greasing quantity and interval","It uses less grease","It is faster to install"],"correctIndex":1}]'::jsonb
  WHERE title = 'Series-Progressive, Dual-Line & Single-Line Systems' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content =
'## Overview
A centralized lubrication pump has a reservoir, a motor or pneumatic drive, and a pressure relief. The cycle indicator on the divider block confirms that grease is flowing. Understanding the maintenance and troubleshooting procedures is essential for reliable system operation.

## Key Concepts
- **Reservoir:** Fill with the correct grease — mixing incompatible greases causes the system to fail. Check the level weekly and the low-level alarm function monthly.
- **Cycle indicator:** Confirms grease is flowing. If the indicator does not cycle, check for a blocked line, an empty reservoir, or a failed pump.
- **Blockage diagnosis:** Crack each bearing line fitting one at a time while the pump runs; the point where grease does not appear is downstream of the blockage.
- **Grease compatibility:** Verify the grease is the correct NLGI grade — a grease that is too stiff will not flow through the lines in cold weather.
- **Pump cycle time:** An increasing cycle time indicates line restriction or grease hardening.

## Step-by-Step: Pump Maintenance and Line Troubleshooting
1. **Check the reservoir level** weekly and refill with the correct grease.
2. **Test the low-level alarm** monthly by letting the level drop to the alarm point.
3. **Verify the cycle indicator** is cycling during each pump cycle. If not, diagnose the blockage.
4. **Find a blockage:** Crack each bearing line fitting one at a time while the pump runs. The fitting where grease does not appear is downstream of the blockage.
5. **Clear the blockage:** Disconnect the line and blow it out with a compatible solvent. Reconnect and verify flow.
6. **Check the grease NLGI grade** — a grease that is too stiff will not flow in cold weather.
7. **Trend the pump cycle time** — an increasing cycle time indicates line restriction or grease hardening.

## Common Problems and Fixes
- **Cycle indicator does not cycle:** A blocked line, an empty reservoir, or a failed pump. Check the reservoir, the pump, and the lines.
- **Grease is too stiff in cold weather:** The NLGI grade is too high. Switch to a lower NLGI grade or add a line heater.
- **One bearing gets too much grease:** The metering valve is oversized. Replace with a smaller valve.
- **Pump runs but no grease flows:** The pump is air-locked or the reservoir is empty. Prime the pump or refill the reservoir.

## Best Practices and Field Tips
- Install a pressure gauge at the pump discharge — a rising pressure indicates a developing blockage.
- Use a clear reservoir or a sight glass for visual level verification.
- Trend the pump cycle time — an increasing cycle time is an early warning of line restriction.
- Keep a supply of the correct grease in stock — using the wrong grease in an emergency causes more problems than it solves.

## Safety Notes
- Never disconnect a grease line under pressure — bleed the pressure first.
- Wear safety glasses when working on a pressurized grease system.',
   quiz =
'[{"question":"What does a non-cycling divider block indicator mean?","options":["Normal operation","A blocked line, empty reservoir, or failed pump","Too much grease","The system is over-pressurized"],"correctIndex":1},{"question":"How do you find a blockage in a series-progressive system?","options":["Replace all lines","Crack each bearing line fitting one at a time while the pump runs","Increase the pump pressure","Remove the divider block"],"correctIndex":1},{"question":"What does an increasing pump cycle time indicate?","options":["Normal operation","Line restriction or grease hardening","The pump is improving","The reservoir is full"],"correctIndex":1},{"question":"What should be checked weekly on a centralized lubrication system?","options":["The pump motor","The reservoir level","The cycle timer","The divider block"],"correctIndex":1},{"question":"What should be installed at the pump discharge to detect developing blockages?","options":["A flow meter","A pressure gauge — a rising pressure indicates a developing blockage","A temperature gauge","Nothing"],"correctIndex":1},{"question":"What causes a pump to run but deliver no grease?","options":["The pump is air-locked or the reservoir is empty — prime the pump or refill","The motor is failing","The lines are too large","Normal operation"],"correctIndex":0},{"question":"What should be done before disconnecting a grease line?","options":["Nothing","Bleed the pressure — the pump can develop high pressure","Increase the pressure","Heat the line"],"correctIndex":1}]'::jsonb
  WHERE title = 'Pump Maintenance & Line Troubleshooting' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

-- 15-22: Add one module each to remaining courses (structured content + 7Q quizzes for all new lessons)
-- We batch these to keep the migration manageable

-- 15. Welding & Fabrication
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Welding & Fabrication for Maintenance Technicians';
  IF NOT FOUND THEN RETURN; END IF;
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Welding Safety & Quality Control', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Welding Safety, Fume Control & Fire Prevention',
   '## Overview
Welding safety encompasses eye protection from arc flash, fume inhalation, fire prevention from sparks, and electrical safety from welding equipment. Understanding the hazards and the controls is essential for any maintenance welder.

## Key Concepts
- **Arc flash (UV radiation):** The welding arc emits intense UV and IR radiation that causes welder''s flash (sunburn of the eye). Wear a welding helmet with the correct shade (shade 10-14 for SMAW, 8-12 for GMAW).
- **Fume inhalation:** Welding fumes contain metal oxides and decomposition products. Galvanized steel produces zinc oxide fume that causes metal fume fever. Stainless steel produces hexavalent chromium. Use fume extraction and a respirator for confined spaces.
- **Fire prevention:** Sparks travel 35 feet or more. Clear all combustibles from the area, or use fire blankets. Have a fire extinguisher (Class ABC) within reach.
- **Electrical safety:** Welding equipment uses high current. Verify the ground clamp is securely attached to the workpiece. Never weld in wet conditions — the moisture conducts electricity.
- **Confined space:** Welding in a tank, vessel, or pipe requires confined space entry procedures: atmospheric testing, ventilation, a standby person, and a retrieval system.

## Step-by-Step: Welding Safety Setup
1. **Inspect the area:** Clear combustibles for 35 feet in all directions. Use fire blankets for immovable combustibles.
2. **Set up the welding machine:** Verify the ground clamp is securely attached to the workpiece. Verify the cables are not damaged.
3. **Set up fume extraction:** Position the extraction nozzle within 6 inches of the weld zone. Verify the extraction is functioning.
4. **Don PPE:** Welding helmet with the correct shade, leather gloves, flame-resistant clothing, and safety glasses under the helmet.
5. **Position the fire extinguisher** within reach of the welder.
6. **For confined space:** Test the atmosphere, set up ventilation, station a standby person, and verify the retrieval system.

## Common Problems and Fixes
- **Welder''s flash (eye pain and watering):** UV exposure from inadequate eye protection. Wear the correct shade and never remove the helmet during welding.
- **Metal fume fever (chills, fever):** Welding galvanized steel without fume extraction. Use fume extraction and a respirator for galvanized steel.
- **Fire from sparks:** Combustibles were not cleared. Clear the area and have a fire watch during and after welding.
- **Electric shock:** Welding in wet conditions or with damaged cables. Dry the area and replace damaged cables.

## Best Practices and Field Tips
- Use a fire watch during and for 30 minutes after welding — smoldering fires can start after the welder leaves.
- For galvanized steel, grind the zinc coating off the weld area before welding to reduce fume exposure.
- Keep the welding helmet shade chart at the welding station for quick reference.
- For confined space welding, use a supplied-air respirator, not a cartridge respirator — the fume concentration can overwhelm a cartridge.

## Safety Notes
- Never weld on a container that has held flammable material without cleaning and purging — residual vapors can explode.
- Never look at a welding arc without the correct shade — even a brief exposure causes welder''s flash.
- Always have a fire extinguisher within reach — welding fires are common and fast-spreading.',
   50, 1,
   '[{"question":"What shade range is recommended for SMAW (stick) welding?","options":["Shade 4-6","Shade 10-14","Shade 2-4","Shade 6-8"],"correctIndex":1},{"question":"What does welding galvanized steel produce that causes metal fume fever?","options":["Carbon monoxide","Zinc oxide fume","Hexavalent chromium","Nitrogen dioxide"],"correctIndex":1},{"question":"How far can welding sparks travel?","options":["10 feet","35 feet or more","5 feet","100 feet"],"correctIndex":1},{"question":"What should be done during and after welding for fire prevention?","options":["Nothing","Use a fire watch during and for 30 minutes after welding","Wet the area","Remove the fire extinguisher"],"correctIndex":1},{"question":"What should be done before welding on a container that held flammable material?","options":["Nothing — just start welding","Clean and purge the container — residual vapors can explode","Weld slowly","Use a lower amperage"],"correctIndex":1},{"question":"What should be used for confined space welding respirator?","options":["A cartridge respirator","A supplied-air respirator — the fume concentration can overwhelm a cartridge","No respirator","A dust mask"],"correctIndex":1},{"question":"What causes welder''s flash (eye pain and watering)?","options":["Inadequate ventilation","UV exposure from inadequate eye protection — wear the correct shade","Fume inhalation","Electric shock"],"correctIndex":1}]'::jsonb),
  (m_id, 'Weld Quality Inspection & Defect Prevention',
   '## Overview
A good weld is more than just visually appealing — it must have adequate penetration, no cracks, no porosity, and proper fusion. Understanding the common weld defects, their causes, and how to prevent them is essential for a maintenance welder.

## Key Concepts
- **Porosity (gas pockets in the weld):** Caused by contaminated base metal (oil, rust, moisture), inadequate shielding (GMAW/GTAW), or wet electrodes (SMAW). Prevent by cleaning the metal and using dry electrodes and correct gas flow.
- **Cracking:** Caused by hydrogen in the weld (wet electrodes, contaminated metal), rapid cooling (high carbon steel), or high residual stress. Prevent by using low-hydrogen electrodes (E7018), preheating thick sections, and controlling the cooling rate.
- **Incomplete penetration:** The weld did not reach the root of the joint. Caused by insufficient amperage, incorrect joint preparation, or too-fast travel speed. Prevent by using the correct amperage and joint preparation.
- **Undercut (a groove at the weld toe):** Caused by excessive amperage or too-fast travel speed. The undercut is a stress concentration that initiates fatigue cracks. Prevent by using the correct amperage and travel speed.
- **Slag inclusion (SMAW):** Slag trapped in the weld from inadequate cleaning between passes. Prevent by cleaning each pass with a chipping hammer and a wire brush.

## Step-by-Step: Weld Quality Inspection
1. **Visual inspection:** Examine the weld for cracks, porosity, undercut, spatter, and the bead profile. A uniform, slightly convex bead is good; a concave bead or an irregular bead is suspect.
2. **Check penetration:** If the back side is accessible, verify the weld reached through the full thickness. If not accessible, use a dye penetrant or a radiograph.
3. **Check for cracks:** Use dye penetrant (for surface cracks) or magnetic particle (for ferromagnetic materials). Cracks are the most serious defect — they propagate under load.
4. **Check for undercut:** Run a finger across the weld toe — a groove you can feel is undercut that must be repaired.
5. **Check for slag inclusion (SMAW):** If the weld has a rough surface or visible slag at the toe, it may have inclusions. Clean and re-weld if inclusions are found.
6. **Document the inspection** with the weld location, the defect type, and the corrective action.

## Common Problems and Fixes
- **Porosity in the weld:** Clean the base metal (remove oil, rust, moisture), use dry electrodes, and verify the gas flow (GMAW/GTAW).
- **Cracks in the weld:** Use low-hydrogen electrodes (E7018), preheat thick or high-carbon sections, and control the cooling rate.
- **Incomplete penetration:** Increase the amperage, prepare the joint correctly (bevel for thick sections), and slow the travel speed.
- **Undercut at the weld toe:** Reduce the amperage and slow the travel speed. Repair by adding a pass to fill the undercut.

## Best Practices and Field Tips
- Clean the base metal to bare metal before welding — paint, oil, and rust cause porosity and cracking.
- Use low-hydrogen electrodes (E7018) for all repair welding — they are stored in a heated oven and are the standard for critical welds.
- For thick sections (over 1/4 inch), bevel the joint and use multiple passes — a single pass on thick material will have incomplete penetration.
- Inspect every repair weld with dye penetrant — a crack in a repair weld will cause the component to fail again.

## Safety Notes
- Never inspect a weld that is still hot — the weld and the surrounding metal can cause burns.
- Grinding a weld for inspection produces sparks and dust — wear safety glasses and a dust mask.',
   50, 2,
   '[{"question":"What causes porosity in a weld?","options":["Excessive amperage","Contaminated base metal (oil, rust, moisture), inadequate shielding, or wet electrodes","Too-fast travel","Low amperage"],"correctIndex":1},{"question":"What is the most serious weld defect that propagates under load?","options":["Porosity","Cracks","Spatter","Undercut"],"correctIndex":1},{"question":"What causes undercut at the weld toe?","options":["Low amperage","Excessive amperage or too-fast travel speed — it is a stress concentration that initiates fatigue cracks","Contamination","Wrong electrode"],"correctIndex":1},{"question":"What electrodes should be used for repair welding to prevent cracking?","options":["E6010","Low-hydrogen electrodes (E7018) — stored in a heated oven","E308L","Any electrode"],"correctIndex":1},{"question":"What should be done to prevent incomplete penetration on thick sections?","options":["Use higher amperage only","Bevel the joint and use multiple passes","Weld faster","Use a larger electrode"],"correctIndex":1},{"question":"What should be done before welding to prevent porosity and cracking?","options":["Nothing","Clean the base metal to bare metal — paint, oil, and rust cause porosity and cracking","Preheat the metal","Use a higher amperage"],"correctIndex":1},{"question":"How should every repair weld be inspected?","options":["Visual only","With dye penetrant — a crack in a repair weld will cause the component to fail again","With a magnifying glass","No inspection needed"],"correctIndex":1}]'::jsonb);
END $$;

-- 16. Chain & Belt Drive Systems Advanced
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Chain & Belt Drive Systems Advanced';
  IF NOT FOUND THEN RETURN; END IF;
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Drive System Optimization & Troubleshooting', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Premature Failure Analysis & Drive Optimization',
   '## Overview
Premature chain or belt failure is rarely the component''s fault — it is usually a symptom of misalignment, incorrect tension, environmental contamination, or an oversized load. Understanding the failure patterns and the optimization strategies is essential for reliable drive systems.

## Key Concepts
- **Chain failure patterns:** Pin wear (insufficient lubrication), bushing wear (contamination), side plate wear (misalignment), and fatigue failure (overload or shock). Each pattern points to a specific root cause.
- **Belt failure patterns:** Tensile failure (over-tensioning or shock load), edge wear (misalignment), underside cracking (heat or ozone degradation), and glazing (slip generating heat).
- **Drive optimization:** Correct tension, correct alignment, correct lubrication (chain), correct environment (protect belts from heat and oil), and correct sizing (neither oversized nor undersized).
- **Environmental factors:** Temperature (chains and belts degrade above their temperature limits), contamination (dust, abrasive particles), and chemical exposure (oil on belts, corrosive atmosphere on chains).
- **Sprocket and sheave wear:** Worn sprockets destroy new chains; worn sheaves destroy new belts. Always replace both as a set.

## Step-by-Step: Premature Failure Analysis
1. **Examine the failed component:** For chains, inspect the pins, bushings, and side plates. For belts, inspect the tensile members, the underside, and the edges.
2. **Identify the failure pattern:** Pin wear = lubrication issue; bushing wear = contamination; side plate wear = misalignment; tensile failure = over-tensioning or shock; edge wear = misalignment; glazing = slip.
3. **Check the alignment:** Use a straightedge across the sprocket or sheave faces. Misalignment causes uneven wear and premature failure.
4. **Check the tension:** Verify the tension matches the manufacturer specification. Over-tensioning loads bearings and stretches the component; under-tensioning causes slip and heat.
5. **Check the environment:** Verify the temperature is within the component rating, the area is free of contamination, and belts are not exposed to oil.
6. **Check the sprocket/sheave wear:** A worn sprocket or sheave will destroy a new component. Replace both as a set.
7. **Document the failure analysis** with the failure pattern, the root cause, and the corrective action.

## Common Problems and Fixes
- **Chain fails in weeks despite lubrication:** The lubrication is not reaching the pin and bushing joints. Verify the lubricator is delivering to the joints, not just the outer plates.
- **Belt fails in weeks despite correct tension:** The sheaves are worn. Replace the sheaves and the belts as a set.
- **Chain elongates rapidly:** The chain is overloaded or contaminated. Verify the load and the environment.
- **Belt glazes and slips:** The belt is under-tensioned or the sheave lagging is worn. Increase the tension or replace the sheaves.

## Best Practices and Field Tips
- Always replace chains and sprockets (or belts and sheaves) as a set — a worn component destroys a new one.
- For chains, use an automatic lubricator that delivers a continuous small dose rather than a large infrequent dose.
- For belts, verify the sheave groove profile with a groove gauge — a worn groove causes the belt to ride too deep or too shallow.
- Trend the chain elongation or the belt tension — a rapid change indicates a developing problem.

## Safety Notes
- Never inspect a running chain or belt — the pinch point can amputate fingers. Lock out the drive.
- A chain or belt that fails under tension can whip and cause serious injury — stand to the side when tensioning.',
   50, 1,
   '[{"question":"What does chain pin wear indicate?","options":["Overload","Insufficient lubrication","Misalignment","Contamination"],"correctIndex":1},{"question":"What does belt glazing indicate?","options":["Over-tensioning","Slip generating heat from under-tensioning or worn lagging","Contamination","Overload"],"correctIndex":1},{"question":"What does chain side plate wear indicate?","options":["Insufficient lubrication","Misalignment","Overload","Contamination"],"correctIndex":1},{"question":"What should always be replaced as a set?","options":["Only the chain or belt","Chains and sprockets, or belts and sheaves — a worn component destroys a new one","Only the sprockets or sheaves","Nothing needs to be replaced as a set"],"correctIndex":1},{"question":"What should be verified with a groove gauge for belt drives?","options":["The belt length","The sheave groove profile — a worn groove causes the belt to ride too deep or too shallow","The belt tension","The sheave diameter"],"correctIndex":1},{"question":"What does a chain that elongates rapidly indicate?","options":["Normal wear","The chain is overloaded or contaminated — verify the load and the environment","Insufficient lubrication","The chain is new"],"correctIndex":1},{"question":"What should be used for chain lubrication to maximize life?","options":["Manual greasing","An automatic lubricator that delivers a continuous small dose","Oil bath","No lubrication"],"correctIndex":1}]'::jsonb),
  (m_id, 'Synchronous Belt Drives & High-Torque Applications',
   '## Overview
Synchronous (timing) belts transmit power by positive engagement of the belt teeth with the sprocket grooves, eliminating slip. They are used for applications requiring precise timing, high torque, or high speed. Understanding their selection, installation, and maintenance is essential for reliable synchronous belt drives.

## Key Concepts
- **Synchronous belt advantages:** No slip (positive engagement), high speed capability (up to 10,000+ RPM), high torque capacity, and precise positioning (no backlash).
- **Synchronous belt disadvantages:** No shock absorption (the teeth transmit shock directly to the sprocket), noise at high speed, and higher cost than V-belts.
- **Tension measurement:** Use a sonic tension meter to set the tension to the specified frequency — too loose and the belt ratchets (jumps teeth), too tight and the bearing loads increase.
- **Sprocket alignment:** Critical for synchronous belts — misalignment causes the belt to wear on one side and can cause ratcheting. Align to within 0.5 degrees.
- **HTD vs. timing belt:** HTD (high torque drive) belts have a curved tooth profile that handles higher torque and runs quieter than standard trapezoidal timing belts.

## Step-by-Step: Synchronous Belt Installation and Tensioning
1. **Verify the sprocket alignment** with a straightedge — misalignment must be within 0.5 degrees.
2. **Install the belt** by loosening the tension and sliding the belt over the sprockets — never pry or force the belt over the sprockets with a tool.
3. **Set the initial tension** by adjusting the center distance until the belt is snug.
4. **Measure the tension** with a sonic tension meter: pluck the belt like a guitar string and read the frequency. Adjust the center distance until the frequency matches the manufacturer specification.
5. **Run the drive** for 30 minutes at low speed to seat the belt.
6. **Re-check the tension** after the run-in — the belt may relax slightly. Re-tension if needed.
7. **Document the tension** and the alignment for future reference.

## Common Problems and Fixes
- **Belt ratchets (jumps teeth):** The tension is too low. Increase the tension with the sonic tension meter.
- **Belt wears on one side:** The sprockets are misaligned. Re-align to within 0.5 degrees.
- **Belt is noisy at high speed:** The belt speed exceeds the rating, or the sprockets are worn. Select a belt rated for the speed or replace the sprockets.
- **Sprocket teeth wear rapidly:** The belt tension is too high or the environment is contaminated. Reduce the tension or protect the drive.

## Best Practices and Field Tips
- Use a sonic tension meter for synchronous belt tensioning — it is the only accurate method. Deflection methods are not suitable for synchronous belts.
- For high-torque applications, use HTD belts — they handle more torque and run quieter than standard timing belts.
- Always align sprockets to within 0.5 degrees — synchronous belts are more sensitive to misalignment than V-belts.
- Keep a spare belt for critical drives — synchronous belts are not as commonly stocked as V-belts.

## Safety Notes
- Never install a synchronous belt by prying it over the sprockets — the tensile member can be damaged. Loosen the tension and slide it on.
- A synchronous belt that fails at speed can fling components — install and maintain the guard.',
   50, 2,
   '[{"question":"What is the advantage of a synchronous (timing) belt over a V-belt?","options":["It is cheaper","No slip — positive engagement of belt teeth with sprocket grooves","It is quieter","It does not need tensioning"],"correctIndex":1},{"question":"What happens if a synchronous belt is too loose?","options":["Nothing","The belt ratchets (jumps teeth)","The belt overheats","The belt stretches"],"correctIndex":1},{"question":"How should synchronous belt tension be measured?","options":["By deflection","With a sonic tension meter — pluck the belt and read the frequency","By feel","By visual inspection"],"correctIndex":1},{"question":"What is the maximum sprocket misalignment for synchronous belts?","options":["2 degrees","0.5 degrees","5 degrees","1 degree"],"correctIndex":1},{"question":"What type of synchronous belt handles higher torque and runs quieter?","options":["Standard trapezoidal timing belt","HTD (high torque drive) belt with curved tooth profile","V-belt","Any synchronous belt"],"correctIndex":1},{"question":"How should a synchronous belt be installed?","options":["Pry it over the sprockets with a tool","Loosen the tension and slide it over the sprockets — never pry or force it","Cut the belt and splice it","Heat the belt"],"correctIndex":1},{"question":"What should be done after the initial run-in of a synchronous belt?","options":["Nothing","Re-check the tension — the belt may relax slightly, re-tension if needed","Replace the belt","Increase the speed"],"correctIndex":1}]'::jsonb);
END $$;

-- 17-22: Add one module each with 2 lessons (abbreviated for migration size)
-- Each new module has structured content with Overview, Key Concepts, Procedures, Common Problems, Best Practices, Safety + 7Q quiz

-- 17. Compressors & Compressed Air Systems
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Compressors & Compressed Air Systems';
  IF NOT FOUND THEN RETURN; END IF;
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Compressor Maintenance & System Optimization', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Compressor PM, Oil Analysis & Air Quality Management',
   '## Overview
Compressor preventive maintenance and air quality management are essential for reliable compressed air supply. A well-maintained compressor runs for years; a neglected one fails frequently and contaminates the entire air system.

## Key Concepts
- **Compressor PM schedule:** Daily (check oil level, drain moisture), weekly (check air filter, check belts), monthly (check for leaks, check operating temperature), quarterly (sample oil, check separator element), annually (change oil, change filters, inspect valves).
- **Oil analysis** for compressors detects wear metals (Fe, Cu, Cr), oil degradation (viscosity, acid number), and contamination (water, particulates). A compressor with a rising wear metal trend has a failing bearing or rotor.
- **Air quality** is defined by ISO 8573: Particulates (size and count), water (pressure dew point), and oil (residual content). Different applications require different air quality classes.
- **Separator element** (oil-flooded screw compressors): Separates oil from the compressed air. A clogged separator increases the oil carryover and the pressure drop. Replace at the OEM interval.
- **Air filter** (inlet): A clogged inlet filter reduces the compressor capacity and increases the energy consumption. Replace at the OEM interval or when the pressure drop exceeds the limit.

## Step-by-Step: Compressor PM
1. **Daily:** Check the oil level, drain the moisture from the aftercooler and the receiver, and listen for abnormal noise.
2. **Weekly:** Check the inlet air filter (clean or replace if dirty), check the belt tension (if belt-driven), and check for air leaks.
3. **Monthly:** Check the operating temperature (trend it), check the separator pressure drop (if equipped), and verify the unload/load cycle is correct.
4. **Quarterly:** Sample the oil for analysis, check the separator element for oil carryover, and inspect the cooler for fouling.
5. **Annually:** Change the oil, change the oil filter, change the air filter, change the separator element, inspect the inlet and discharge valves, and verify the safety valve.

## Common Problems and Fixes
- **Compressor overheats:** The cooler is fouled, the oil level is low, or the oil is degraded. Clean the cooler, check the oil, and change if degraded.
- **Oil carryover (oil in the air system):** The separator element is worn or clogged. Replace the separator element.
- **Compressor capacity drops:** The inlet filter is clogged, the valves are worn, or the system has leaks. Clean or replace the filter, inspect the valves, and survey for leaks.
- **Compressor runs continuously without unloading:** The unload valve is stuck or the system has a large leak. Check the unload valve and survey for leaks.

## Best Practices and Field Tips
- Trend the compressor operating temperature, the oil analysis, and the separator pressure drop — together they reveal the compressor health.
- Use synthetic compressor oil for longer drain intervals and better high-temperature stability.
- Install a dew point sensor in the air system to monitor the dryer performance — a rising dew point indicates a failing dryer.
- For oil-injected compressors, trend the oil carryover with an oil content sensor — a rising carryover indicates a failing separator.

## Safety Notes
- Never open a compressor while it is running or pressurized — the internal components are under pressure and can cause burns from hot oil.
- The receiver is a pressure vessel — it must be inspected per the local pressure vessel code.',
   55, 1,
   '[{"question":"What should be checked daily on a compressor?","options":["Nothing","Oil level, drain moisture, and listen for abnormal noise","The valves","The separator"],"correctIndex":1},{"question":"What does a rising wear metal trend in compressor oil indicate?","options":["Normal wear","A failing bearing or rotor","The oil is the wrong grade","The filter is clogged"],"correctIndex":1},{"question":"What does oil carryover (oil in the air system) indicate?","options":["Normal operation","The separator element is worn or clogged — replace it","The oil is overfilled","The cooler is fouled"],"correctIndex":1},{"question":"What causes a compressor to overheat?","options":["Over-speed","The cooler is fouled, the oil level is low, or the oil is degraded","The inlet filter is too clean","The belts are too tight"],"correctIndex":1},{"question":"What should be done if the compressor capacity drops?","options":["Increase the speed","Clean or replace the inlet filter, inspect the valves, and survey for leaks","Replace the compressor","Reduce the system pressure"],"correctIndex":1},{"question":"What does a rising dew point in the air system indicate?","options":["Improved air quality","The dryer is failing","The compressor is overheating","Normal operation"],"correctIndex":1},{"question":"What should be trended together to reveal compressor health?","options":["Only the temperature","Operating temperature, oil analysis, and separator pressure drop","Only the oil level","Only the capacity"],"correctIndex":1}]'::jsonb),
  (m_id, 'System Audit, Leak Management & Energy Recovery',
   '## Overview
A compressed air system audit identifies the waste — leaks, inappropriate uses, and pressure drops — and quantifies the energy savings. A system audit can reduce the compressed air energy cost by 20-50%.

## Key Concepts
- **Leak cost:** A 1/8 inch leak at 100 PSIG wastes approximately $2,000 per year in electricity. A typical plant has 20-30% of its compressed air lost to leaks.
- **Leak survey:** Use an ultrasonic leak detector to find and tag each leak. Estimate the CFM loss from the dB reading and the system pressure. Prioritize the largest leaks for repair.
- **Pressure drop audit:** Measure the pressure at the compressor and at each major point of use. A pressure drop of more than 5 PSI indicates a restriction (undersized pipe, clogged filter, too many fittings).
- **Inappropriate uses:** Using compressed air for cleaning, cooling, or liquid pumping is energy-wasteful. A 1/4 inch air blow gun uses 20 CFM — replace with a blower or an electric fan.
- **Energy recovery:** The compressor heat (the hot discharge air) can heat a workshop or warehouse. A 50 HP compressor generates enough heat to warm a 5,000 sq ft workshop.

## Step-by-Step: Compressed Air System Audit
1. **Measure the compressor power** (kW) and the output flow (CFM) to establish the baseline efficiency (CFM per kW).
2. **Conduct a leak survey** with an ultrasonic detector. Tag each leak, estimate the CFM loss, and sum the total.
3. **Calculate the leak percentage:** Total leak CFM / total compressor CFM × 100. Target below 10%.
4. **Measure the pressure profile:** Pressure at the compressor, at the dryer, at the filter, at the main distribution, and at the furthest point of use. Identify restrictions with more than 5 PSI drop.
5. **Identify inappropriate uses:** List all air uses and evaluate alternatives (blower for cleaning, electric fan for cooling, electric pump for liquid).
6. **Evaluate energy recovery:** Measure the compressor discharge temperature and calculate the recoverable heat.
7. **Calculate the potential savings:** (leak CFM + inappropriate use CFM) × 60 × hours per year × $/CFM.
8. **Prioritize the actions:** Repair the largest leaks first, eliminate inappropriate uses, and reduce the pressure drop.

## Common Problems and Fixes
- **System pressure is too high:** Every 2 PSI above the minimum required wastes 1% of the compressor energy. Reduce the pressure to the minimum that satisfies all users.
- **Leaks are repaired but new ones appear:** Leaks are a continuous problem. Schedule a quarterly leak survey.
- **Pressure at the point of use is too low:** The distribution pipe is undersized or a filter is clogged. Increase the pipe size or clean the filter.
- **Compressor runs continuously:** The system has a large leak or the compressor unload valve is stuck. Survey for leaks and check the unload valve.

## Best Practices and Field Tips
- Conduct a leak survey quarterly and trend the total leak CFM — a rising total indicates new leaks are developing faster than repairs.
- Install flow meters at the compressor and at major branches to trend the demand and identify waste.
- Lower the system pressure to the minimum required — every 2 PSI reduction saves 1% of the compressor energy.
- For new installations, use a VSD compressor that matches the output to the demand — it saves 15-35% on part-load operation.

## Safety Notes
- Never survey for leaks with bare hands — the high-pressure air can penetrate skin. Use an ultrasonic detector.
- The compressor heat recovery system can have hot surfaces — use guards and insulation.',
   55, 2,
   '[{"question":"How much does a 1/8 inch leak at 100 PSIG waste per year?","options":["$200","$2,000","$20,000","$200,000"],"correctIndex":1},{"question":"What percentage of compressed air does a typical plant lose to leaks?","options":["1-5%","20-30%","50-60%","80-90%"],"correctIndex":1},{"question":"How much energy does every 2 PSI above the minimum required pressure waste?","options":["0.5%","1%","5%","10%"],"correctIndex":1},{"question":"What should be used to find compressed air leaks?","options":["Soap solution","An ultrasonic leak detector","Visual inspection","A stethoscope"],"correctIndex":1},{"question":"How often should a leak survey be conducted?","options":["Every 5 years","Quarterly","Annually","Only at installation"],"correctIndex":1},{"question":"What is a VSD compressor''s energy saving on part-load operation?","options":["5-10%","15-35%","50%","80%"],"correctIndex":1},{"question":"What is the target leak rate for a compressed air system?","options":["Below 1%","Below 10%","Below 30%","Below 50%"],"correctIndex":1}]'::jsonb);
END $$;

-- 18-22: Add one module each with 2 lessons (structured content + 7Q quizzes)
-- Due to migration size limits, we process courses 18-22 in a single block with abbreviated but structured content

-- 18. Heat Exchangers & Cooling Systems
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Heat Exchangers & Cooling Systems';
  IF NOT FOUND THEN RETURN; END IF;
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Thermal Performance & Fouling Management', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Thermal Performance Monitoring & Cleaning Strategies',
   '## Overview
Heat exchanger thermal performance degrades over time due to fouling — the accumulation of scale, biological growth, or particulate deposits on the heat transfer surfaces. Monitoring the performance and selecting the correct cleaning strategy is essential for maintaining heat exchanger efficiency.

## Key Concepts
- **Approach temperature:** The difference between the process outlet and the cooling medium inlet. A rising approach indicates fouling.
- **Fouling types:** Scaling (calcium carbonate, magnesium), biological (algae, slime), particulate (sediment, corrosion products), and chemical (polymerization, oxidation).
- **Cleaning methods:** Mechanical (rodding, hydro-lancing, brushing), chemical (acid descaling, biocide treatment), and preventive (anti-fouling treatment, filtration).
- **Fouling monitoring:** Trend the approach temperature, the pressure drop, and the heat transfer coefficient. A rising approach with a rising pressure drop confirms fouling.
- **Cleaning trigger:** Clean when the approach exceeds the design value by 5-10°F, or when the process outlet temperature exceeds the specification.

## Step-by-Step: Heat Exchanger Performance Monitoring
1. **Measure the process inlet and outlet temperatures** and the cooling medium inlet and outlet temperatures.
2. **Calculate the approach temperature** (process outlet minus cooling medium inlet).
3. **Compare to the design approach** — if the actual exceeds the design by 5-10°F, fouling is present.
4. **Measure the pressure drop** across the exchanger — a rising pressure drop confirms fouling.
5. **Calculate the heat transfer coefficient** (U) from the temperatures and the flow rates — a falling U indicates fouling.
6. **Trend the approach, the pressure drop, and the U** monthly to detect fouling early.
7. **Schedule cleaning** when the approach or the pressure drop exceeds the trigger.

## Common Problems and Fixes
- **Scale deposits (hard, white):** Calcium and magnesium from hard water. Chemical cleaning with a descaling acid (dilute hydrochloric or sulfamic acid).
- **Biological fouling (slimy, green):** Algae or bacteria. Biocide treatment (chlorine, bromine) and mechanical brushing.
- **Particulate deposits (mud, silt):** Suspended solids in the water. Backwash or mechanical cleaning, and install a filter on the cooling water supply.
- **Oil or hydrocarbon fouling:** Process fluid leaking into the cooling water. Find and repair the leak, then chemical cleaning with a degreaser.

## Best Practices and Field Tips
- Install temperature sensors at all four connections (process in, process out, cooling in, cooling out) for continuous approach monitoring.
- Trend the approach temperature monthly — a 1°F per month rise indicates a fouling rate that warrants cleaning within 3-6 months.
- For shell-and-tube exchangers, clean the tube side (the inside of the tubes) more frequently than the shell side — the tube side is where most fouling occurs.
- After cleaning, verify the approach returns to the design value — if it does not, the cleaning was incomplete.

## Safety Notes
- Never open a heat exchanger while it is pressurized or hot — isolate, depressurize, and cool before opening.
- Chemical cleaning agents (acids, biocides) are hazardous — use PPE and follow the manufacturer safety instructions.',
   50, 1,
   '[{"question":"What is the approach temperature?","options":["The process inlet temperature","The difference between the process outlet and the cooling medium inlet","The cooling water temperature","The ambient temperature"],"correctIndex":1},{"question":"What does a rising approach temperature indicate?","options":["Improved heat transfer","Fouling on the heat transfer surface","Increased flow rate","Lower ambient temperature"],"correctIndex":1},{"question":"When should a heat exchanger be cleaned?","options":["Every 5 years","When the approach exceeds the design value by 5-10°F or the process outlet exceeds the specification","Only when it fails","Annually"],"correctIndex":1},{"question":"What causes scale deposits in a heat exchanger?","options":["Bacteria","Calcium and magnesium from hard water","Suspended solids","Oil leaks"],"correctIndex":1},{"question":"What should be installed for continuous approach monitoring?","options":["A flow meter","Temperature sensors at all four connections","A pressure gauge","Nothing"],"correctIndex":1},{"question":"What should be verified after cleaning a heat exchanger?","options":["Nothing","The approach returns to the design value — if it does not, the cleaning was incomplete","The pressure drop","The flow rate"],"correctIndex":1},{"question":"What does a 1°F per month rise in approach indicate?","options":["Normal operation","A fouling rate that warrants cleaning within 3-6 months","The exchanger is new","The cooling water is too cold"],"correctIndex":1}]'::jsonb),
  (m_id, 'Cooling Water Treatment & Corrosion Control',
   '## Overview
Cooling water treatment controls scale, corrosion, and biological growth in heat exchangers and cooling towers. Without treatment, the cooling water system degrades rapidly — scale insulates the heat transfer surfaces, corrosion leaks the tubes, and biological growth transmits Legionella. Understanding the treatment program is essential for reliable cooling system operation.

## Key Concepts
- **Scale control:** Maintained by keeping the cycles of concentration below the saturation point of calcium carbonate. Controlled by blowdown (draining concentrated water) and scale inhibitors (phosphonates, polymers).
- **Corrosion control:** Maintained by corrosion inhibitors (phosphate, azole, molybdate) that form a protective film on the metal surface. Monitored by corrosion coupons.
- **Biological control:** Maintained by biocides (chlorine, bromine, isothiazolin) that kill bacteria and algae. Monitored by dip-slide or ATP testing.
- **Cycles of concentration:** The ratio of dissolved solids in the cooling water to the makeup water. Higher cycles save water but increase the scaling and corrosion risk.
- **Corrosion coupons:** Small metal strips installed in the cooling water system and removed periodically to measure the corrosion rate. A rate above 3 MPY (mils per year) indicates inadequate corrosion control.

## Step-by-Step: Cooling Water Treatment Program
1. **Test the cooling water weekly:** pH (7.5-9.0), conductivity (for cycles), biocide residual (1-3 ppm chlorine), and turbidity.
2. **Adjust the blowdown** to maintain the target cycles of concentration (typically 3-5 for soft water, 2-3 for hard water).
3. **Add scale inhibitor** based on the water hardness and the cycles.
4. **Add corrosion inhibitor** based on the corrosion coupon rate.
5. **Add biocide** based on the biological test results (dip-slide or ATP).
6. **Remove and inspect the corrosion coupons** quarterly to measure the corrosion rate.
7. **Trend the pH, the conductivity, the biocide residual, and the corrosion rate** monthly.

## Common Problems and Fixes
- **Scale deposits in the exchanger:** The cycles are too high or the scale inhibitor is underfed. Reduce the cycles or increase the inhibitor.
- **Corrosion rate is above 3 MPY:** The corrosion inhibitor is underfed or the pH is too low. Increase the inhibitor and adjust the pH.
- **Biological growth (slime, algae):** The biocide is underfed or the biocide type is wrong for the organism. Increase the biocide or switch to a different type.
- **White rust on galvanized steel:** The water chemistry is aggressive (high pH, high chloride). Adjust the pH and add a zinc-compatible inhibitor.

## Best Practices and Field Tips
- Install a continuous conductivity controller that automates the blowdown — it maintains the cycles without manual adjustment.
- Use corrosion coupons to measure the actual corrosion rate — the inhibitor dosage cannot be optimized without coupon data.
- For Legionella prevention, maintain a continuous biocide residual and inspect the tower for biofilm monthly.
- Document the water treatment program with the chemical list, the dosages, the test results, and the coupon rates.

## Safety Notes
- Water treatment chemicals (acids, biocides, scale inhibitors) are hazardous — use PPE and follow the SDS.
- Legionella bacteria can be inhaled from cooling tower drift — maintain the biocide program and inspect the drift eliminators.',
   50, 2,
   '[{"question":"What do cycles of concentration represent?","options":["The number of times the water cycles per hour","The ratio of dissolved solids in the cooling water to the makeup water","The number of biocide additions per day","The fan speed setting"],"correctIndex":1},{"question":"What is the maximum acceptable corrosion rate?","options":["1 MPY","3 MPY (mils per year)","10 MPY","50 MPY"],"correctIndex":1},{"question":"What does white rust on galvanized steel indicate?","options":["Normal aging","Aggressive water chemistry (high pH, high chloride) — adjust the pH and add a zinc-compatible inhibitor","Excessive biocide","Low water temperature"],"correctIndex":1},{"question":"What should be done if scale deposits appear in the exchanger?","options":["Increase the cycles","Reduce the cycles or increase the scale inhibitor","Replace the exchanger","Increase the pH"],"correctIndex":1},{"question":"How should the blowdown be controlled for consistent cycles?","options":["Manually","With a continuous conductivity controller that automates the blowdown","By turning off the blowdown","By increasing the fan speed"],"correctIndex":1},{"question":"What should be done for Legionella prevention?","options":["Nothing","Maintain a continuous biocide residual and inspect the tower for biofilm monthly","Increase the temperature","Reduce the water flow"],"correctIndex":1},{"question":"How is the actual corrosion rate measured?","options":["By testing the pH","By using corrosion coupons — the inhibitor dosage cannot be optimized without coupon data","By testing the conductivity","By visual inspection"],"correctIndex":1}]'::jsonb);
END $$;

-- 19-22: Add one module each with 2 lessons (structured content + 7Q quizzes)
-- 19. Conveyor Troubleshooting & Repair
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Conveyor Troubleshooting & Repair';
  IF NOT FOUND THEN RETURN; END IF;
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Conveyor System Reliability & Optimization', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Conveyor Reliability, PM & Condition Monitoring',
   '## Overview
Conveyor reliability is achieved through a systematic PM program, condition monitoring, and root cause analysis of failures. A well-maintained conveyor runs for years; a neglected one fails frequently and disrupts production.

## Key Concepts
- **Conveyor PM schedule:** Daily (visual inspection, listen for abnormal noise), weekly (check belt tension, check idlers, check for spillage), monthly (check drive alignment, check gearbox oil, check safety devices), quarterly (vibration analysis on drive bearings, belt thickness measurement).
- **Condition monitoring:** Vibration analysis on the drive bearings and the gearbox, oil analysis on the gearbox, and belt thickness measurement to predict belt replacement.
- **Root cause analysis:** A conveyor that fails repeatedly has a systemic problem — the root cause is usually a design issue (undersized drive, inadequate take-up), an environmental issue (dusty environment, wet belt), or a maintenance issue (neglected PM).
- **Belt thickness measurement:** Trend the belt cover thickness — a belt that has lost 50% of its cover thickness needs replacement.
- **Motor amperage trend:** A rising amperage with constant load indicates increasing system friction (seized rollers, tight belt, failing gearbox).

## Step-by-Step: Conveyor PM
1. **Daily:** Walk the conveyor and listen for abnormal noise (seized rollers, rubbing belt). Check for spillage at the loading point.
2. **Weekly:** Check the belt tension (sag should be 2% of center distance). Check the idlers for free rotation. Check the drive for oil leaks.
3. **Monthly:** Check the drive alignment (motor to gearbox, gearbox to drive shaft). Check the gearbox oil level and condition. Test all safety devices (pull-cord, sway, slip, rip, speed).
4. **Quarterly:** Perform vibration analysis on the drive bearings and the gearbox. Measure the belt cover thickness. Sample the gearbox oil.
5. **Annually:** Change the gearbox oil. Replace worn idlers. Inspect the pulley lagging. Check the belt splice.

## Common Problems and Fixes
- **Conveyor fails repeatedly:** Root cause analysis — the root cause is usually a design issue, an environmental issue, or a maintenance issue. Fix the root cause, not the symptom.
- **Belt wears rapidly:** The belt is mistracking (edge wear), the load is abrasive (cover wear), or the idlers are seized (friction wear). Correct the tracking, the loading, or the idlers.
- **Gearbox fails repeatedly:** The gearbox is undersized for the load, or the PM is neglected. Verify the service factor and the PM schedule.
- **Safety devices trip frequently:** The conveyor has a tracking problem or a slip problem. Correct the root cause, not the safety device.

## Best Practices and Field Tips
- Trend the motor amperage, the gearbox oil temperature, and the belt thickness — together they reveal the conveyor health.
- Use a CMMS to schedule and track the PM — a conveyor without a PM schedule will be neglected.
- For critical conveyors, install a belt thickness monitoring system that measures the cover continuously.
- Root cause every conveyor failure — a failure that is not root-caused will recur.

## Safety Notes
- Never perform PM on a running conveyor — lock out the drive before any work.
- A conveyor that fails under load can whip the belt — stand clear during lockout.',
   50, 1,
   '[{"question":"What does a rising motor amperage with constant load indicate?","options":["Improved efficiency","Increasing system friction — seized rollers, tight belt, or failing gearbox","Normal operation","The motor is oversized"],"correctIndex":1},{"question":"When should a belt be replaced based on cover thickness?","options":["When 10% of cover is lost","When 50% of cover thickness is lost","When 100% is lost","Never"],"correctIndex":1},{"question":"What is the first step when a conveyor fails repeatedly?","options":["Replace the conveyor","Root cause analysis — the root cause is usually a design, environmental, or maintenance issue","Increase the PM frequency","Replace the belt"],"correctIndex":1},{"question":"How often should vibration analysis be performed on conveyor drive bearings?","options":["Daily","Quarterly","Annually","Every 5 years"],"correctIndex":1},{"question":"What should be done for a conveyor failure that is not root-caused?","options":["Nothing","It will recur — root cause every conveyor failure","Replace the conveyor","Increase the speed"],"correctIndex":1},{"question":"What should be trended together to reveal conveyor health?","options":["Only the belt tension","Motor amperage, gearbox oil temperature, and belt thickness","Only the speed","Only the safety device trips"],"correctIndex":1},{"question":"What should be used to schedule and track conveyor PM?","options":["Memory","A CMMS — a conveyor without a PM schedule will be neglected","A calendar","A whiteboard"],"correctIndex":1}]'::jsonb),
  (m_id, 'Conveyor System Optimization & Energy Efficiency',
   '## Overview
Conveyor system optimization reduces energy consumption, improves throughput, and extends equipment life. Understanding the optimization strategies — from belt selection to VFD control — is essential for modern conveyor maintenance.

## Key Concepts
- **VFD control:** A VFD on the conveyor drive matches the speed to the production demand, saving energy when the conveyor does not need to run at full speed. A VFD also provides soft starting, reducing the mechanical stress on the belt and the gearbox.
- **Belt selection:** A lower-rolling-resistance belt reduces the motor power requirement by 5-10%.
- **Idler optimization:** Replacing seized idlers with low-friction idlers reduces the system friction and the motor amperage.
- **Load optimization:** Centering the load on the belt reduces the belt tracking force and the edge wear, extending the belt life.
- **Energy monitoring:** A power meter on the conveyor drive, trended over time, reveals the system health — a rising power consumption with constant throughput indicates increasing friction.

## Step-by-Step: Conveyor Energy Optimization
1. **Install a power meter** on the conveyor drive and trend the kW.
2. **Install a VFD** and control the speed to match the production demand — reduce the speed when the conveyor is not fully loaded.
3. **Replace seized idlers** — each seized idler adds friction and increases the motor power. A seized idler can add 0.5-1 kW to a 10 kW conveyor.
4. **Center the load** at the loading point — an off-center load increases the tracking force and the edge wear.
5. **Select a low-rolling-resistance belt** at the next belt replacement — it reduces the motor power by 5-10%.
6. **Calculate the energy savings:** (old kW - new kW) × hours per year × $/kWh.

## Common Problems and Fixes
- **VFD does not save energy:** The conveyor runs at full speed all the time. Adjust the control to reduce the speed when the demand is low.
- **Power consumption is rising:** Seized idlers or a tight belt are increasing the friction. Replace the seized idlers and adjust the belt tension.
- **Belt life is short:** The load is off-center or the belt is mistracking. Center the load and correct the tracking.
- **Motor trips on startup:** The starting torque exceeds the motor capacity. Use a VFD with soft start, or upsize the motor.

## Best Practices and Field Tips
- Install a VFD on every conveyor that does not run at full capacity all the time — the energy savings typically pay for the VFD in 1-2 years.
- Trend the conveyor power consumption — a rising trend with constant throughput is the first sign of increasing friction.
- At each belt replacement, evaluate the belt type — a low-rolling-resistance belt or a lighter belt may be adequate and save energy.
- Use a conveyor monitoring system that tracks the power, the speed, the belt thickness, and the safety device activations — it provides a complete picture of the conveyor health.

## Safety Notes
- A VFD can start the conveyor at full torque from zero speed — ensure the coupling is secure and the area is clear before starting.
- Never optimize a conveyor by removing safety devices — the safety devices are not the problem, the root cause is.',
   50, 2,
   '[{"question":"How much energy does a VFD save on a conveyor that does not run at full capacity?","options":["1-5%","The savings typically pay for the VFD in 1-2 years","50%","80%"],"correctIndex":1},{"question":"How much power does a seized idler add to a 10 kW conveyor?","options":["0.01 kW","0.5-1 kW","5 kW","10 kW"],"correctIndex":1},{"question":"How much energy does a low-rolling-resistance belt save?","options":["1-2%","5-10%","30%","50%"],"correctIndex":1},{"question":"What does a rising power consumption with constant throughput indicate?","options":["Improved efficiency","Increasing friction — seized idlers or a tight belt","Normal operation","The motor is oversized"],"correctIndex":1},{"question":"What should be installed to trend conveyor energy consumption?","options":["A flow meter","A power meter on the conveyor drive","A temperature gauge","Nothing"],"correctIndex":1},{"question":"What does centering the load on the belt reduce?","options":["The belt speed","The tracking force and edge wear, extending belt life","The motor size","The belt tension"],"correctIndex":1},{"question":"What should be used for conveyor startup to reduce mechanical stress?","options":["Direct online starting","A VFD with soft start","A star-delta starter","Nothing"],"correctIndex":1}]'::jsonb);
END $$;

-- 20-22: Add one module each with 2 lessons (structured content + 7Q quizzes)
-- 20. Precision Maintenance Practices
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Precision Maintenance Practices';
  IF NOT FOUND THEN RETURN; END IF;
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Precision Tools & Measurement Standards', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Precision Tool Selection, Calibration & Measurement Standards',
   '## Overview
Precision maintenance requires precision tools — dial indicators, micrometers, laser alignment systems, torque wrenches, and vibration analyzers. Understanding the tool selection, the calibration requirements, and the measurement standards is essential for achieving precision in maintenance.

## Key Concepts
- **Tool calibration:** Every precision tool must be calibrated against a traceable standard at a defined interval. A tool that is not calibrated produces measurements that are not trustworthy.
- **Measurement uncertainty:** Every measurement has an uncertainty — the tool resolution, the repeatability, and the environmental factors (temperature, vibration) all contribute. Report measurements with the uncertainty (e.g., 50.00 mm +/- 0.02 mm).
- **Tool selection:** Match the tool precision to the measurement requirement — a 0.02 mm caliper for a 0.05 mm tolerance is adequate; a 0.02 mm caliper for a 0.005 mm tolerance is not.
- **Temperature effect:** Metal expands and contracts with temperature. A 1°C change on a 100 mm steel shaft changes the dimension by 0.0012 mm. Measure at the same temperature for comparable results.
- **Torque wrenches:** A torque wrench must be calibrated annually and set to the correct torque before each use. A torque wrench that is not calibrated produces incorrect torque on every bolt.

## Step-by-Step: Precision Tool Calibration Program
1. **List all precision tools** with their calibration interval and the traceable standard.
2. **Calibrate each tool** at the defined interval: dial indicators (annual), micrometers (annual), laser alignment systems (per manufacturer), torque wrenches (annual), vibration analyzers (per manufacturer).
3. **Document the calibration** with the tool ID, the date, the standard, the result, and the next due date.
4. **Verify the tool is within calibration** before each use — check the calibration sticker or the database.
5. **Store tools properly** — in cases, in a temperature-controlled environment, with the measuring surfaces protected.
6. **Remove tools from service** that are out of calibration — tag them and send for recalibration.

## Common Problems and Fixes
- **Measurements are not repeatable:** The tool is out of calibration or the measurement technique is inconsistent. Recalibrate the tool and standardize the technique.
- **Torque wrench does not click at the set torque:** The wrench is out of calibration. Recalibrate or replace the wrench.
- **Laser alignment system gives inconsistent readings:** The laser heads are loose or the system is out of calibration. Tighten the mounting and recalibrate.
- **Micrometer does not zero:** The anvils are dirty or worn. Clean the anvils and recalibrate.

## Best Practices and Field Tips
- Use a calibration database (or a CMMS) to track the calibration status of every precision tool — a tool that is out of calibration is worse than no tool because it gives false confidence.
- Store precision tools in their cases with the measuring surfaces protected — a dropped or dirty tool is out of calibration.
- Measure at the same temperature for comparable results — document the temperature with the measurement.
- For critical measurements, use the statistical method (take multiple readings and average) to reduce the measurement uncertainty.

## Safety Notes
- A torque wrench that is out of calibration can over-torque a bolt and cause it to fail — verify the calibration before each use.
- Precision tools can have sharp points and edges — handle with care to avoid cuts.',
   50, 1,
   '[{"question":"How often should a torque wrench be calibrated?","options":["Monthly","Annually","Every 5 years","Never"],"correctIndex":1},{"question":"What is the measurement uncertainty?","options":["The tool price","The estimated range of error from tool resolution, repeatability, and environmental factors","The calibration date","The tool brand"],"correctIndex":1},{"question":"How much does a 1°C change affect a 100 mm steel shaft?","options":["0.0001 mm","0.0012 mm","0.01 mm","0.1 mm"],"correctIndex":1},{"question":"What should be done if a precision tool is out of calibration?","options":["Continue using it","Tag it and send for recalibration — remove from service","Use it for rough measurements","Discard it"],"correctIndex":1},{"question":"How should the calibration status of precision tools be tracked?","options":["By memory","With a calibration database or CMMS","By a sticker on the tool only","Not tracked"],"correctIndex":1},{"question":"Why is a tool that is out of calibration worse than no tool?","options":["It is more expensive","It gives false confidence — measurements are not trustworthy","It is heavier","It is slower"],"correctIndex":1},{"question":"What should precision tools be matched to?","options":["The operator preference","The measurement requirement — match tool precision to the tolerance","The budget","The brand"],"correctIndex":1}]'::jsonb),
  (m_id, 'Documentation, Standards & Continuous Improvement',
   '## Overview
Precision maintenance is not just about tools and measurements — it is about documenting the results, maintaining standards, and continuously improving the process. A precision maintenance program that is not documented and continuously improved will deteriorate over time.

## Key Concepts
- **Documentation:** Every alignment, every measurement, and every repair must be documented with the before and after values, the tool used, the date, and the technician. This documentation is the baseline for future work and the evidence of quality.
- **Standards:** Every machine has a precision standard — the alignment tolerance, the vibration limit, the torque specification. The standard is the target; the measurement is the result. Without a standard, the measurement has no meaning.
- **Continuous improvement:** After each alignment or repair, review the results — did the machine hold its alignment longer than last time? If not, what was different? This feedback loop drives continuous improvement.
- **Root cause analysis:** When a machine fails to hold its alignment, the root cause is usually soft-foot, pipe strain, thermal growth, or foundation movement. Identifying and correcting the root cause prevents recurrence.
- **Benchmarking:** Compare the precision of your work to industry standards (ISO 10816 for vibration, ISO 21940 for balance) to verify your work meets the standard.

## Step-by-Step: Precision Maintenance Documentation
1. **For each alignment:** Document the before values, the soft-foot readings, the shims installed, the after values, and the tolerance achieved.
2. **For each measurement:** Document the tool, the measurement, the tolerance, the pass/fail, and the technician.
3. **For each repair:** Document the failure mode, the root cause, the corrective action, and the post-repair measurement.
4. **Store the documentation** in the machine file or the CMMS — it is the baseline for future work.
5. **Review the documentation** at the next alignment — did the machine hold its alignment? If not, investigate the root cause.
6. **Feed the findings** back into the procedure — if the thermal growth was different from the last calculation, update the offset.

## Common Problems and Fixes
- **Machine does not hold its alignment:** The root cause is usually soft-foot, pipe strain, thermal growth, or foundation movement. Identify and correct the root cause.
- **Documentation is lost:** The documentation is on paper, not in the CMMS. Digitize the documentation and store it in the CMMS.
- **Standards are not maintained:** The tolerance is not specified, or it is not verified after the work. Specify the tolerance and verify it with a measurement.
- **Continuous improvement is not happening:** The results are not reviewed after each job. Schedule a review meeting to discuss the findings and the improvements.

## Best Practices and Field Tips
- Use a standard alignment report form for every alignment — consistency makes the documentation useful for trending and comparison.
- Benchmark your precision against industry standards — if your alignment tolerance is 0.1 mm and the industry standard is 0.05 mm, your standard is too loose.
- After each alignment, verify the machine holds its alignment for 30 days — if it does, the precision is good; if it does not, the root cause is not corrected.
- Feed the documentation into the CMMS for trending — a machine that needs alignment every 3 months has a root cause that warrants investigation.

## Safety Notes
- Precision maintenance documentation is a quality record — store it securely and control access.
- The continuous improvement process does not change the safety requirements of the maintenance work.',
   50, 2,
   '[{"question":"What must be documented for every alignment?","options":["Nothing","Before values, soft-foot readings, shims installed, after values, and tolerance achieved","Only the after values","Only the date"],"correctIndex":1},{"question":"What is the usual root cause when a machine does not hold its alignment?","options":["Bad luck","Soft-foot, pipe strain, thermal growth, or foundation movement","The alignment tool","The technician"],"correctIndex":1},{"question":"What is the purpose of benchmarking against industry standards?","options":["To compare brands","To verify your work meets the standard — if your tolerance is looser than the industry standard, your standard is too loose","To save money","To impress management"],"correctIndex":1},{"question":"What should be done if a machine needs alignment every 3 months?","options":["Nothing — just keep aligning","Investigate the root cause — a machine that needs alignment frequently has a systemic problem","Replace the machine","Increase the alignment frequency to monthly"],"correctIndex":1},{"question":"Where should precision maintenance documentation be stored?","options":["On paper in a filing cabinet","In the machine file or CMMS — it is the baseline for future work","On the machine","In the technician''s notebook"],"correctIndex":1},{"question":"What should be verified 30 days after an alignment?","options":["Nothing","Whether the machine held its alignment — if it did, the precision is good; if not, the root cause is not corrected","The alignment tool","The technician''s training"],"correctIndex":1},{"question":"What drives continuous improvement in precision maintenance?","options":["New tools","The feedback loop — reviewing results after each job and feeding findings back into the procedure","Management directives","New software"],"correctIndex":1}]'::jsonb);
END $$;

-- 21. Mechanical Seals Advanced Diagnostics
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Mechanical Seals Advanced Diagnostics';
  IF NOT FOUND THEN RETURN; END IF;
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Seal Selection, API Plans & Application Engineering', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Seal Selection for Challenging Applications',
   '## Overview
Selecting a mechanical seal for challenging applications — high temperature, high pressure, abrasive service, toxic service, or variable operating conditions — requires understanding the seal design options and the flush plans that manage the seal environment. This lesson covers the selection process for challenging applications.

## Key Concepts
- **High temperature (above 200°C):** Standard elastomers (Viton, EPDM) degrade above 200°C. Use metal bellows seals (no elastomers) or high-temperature perfluoroelastomer (FFKM) O-rings. Use a cooled flush (API Plan 21 or 23) to reduce the seal chamber temperature.
- **High pressure (above 50 bar):** Balanced seals reduce the hydraulic opening force to prevent face overload. Use a high-pressure seal design with a metal retainer and high-pressure O-rings.
- **Abrasive service (solids in the fluid):** Use a cyclone separator (API Plan 31) to remove solids from the flush, or a clean external flush (API Plan 32). Use hard faces (SiC vs WC) to resist abrasive wear.
- **Toxic or hazardous service:** Use a dual seal with a pressurized barrier fluid (API Plan 53) so any leakage is barrier fluid into the process, not process fluid out. Use a gas seal (dry gas) for zero-emission service.
- **Variable operating conditions (cycling temperature, pressure, or flow):** Use a seal design with a wide operating range, and a flush plan that maintains the seal environment across the cycle. Monitor the seal environment continuously.

## Step-by-Step: Seal Selection for Challenging Applications
1. **Define the operating conditions:** Temperature, pressure, fluid type, solids content, toxicity, and any cycling.
2. **Select the seal design:** Standard for normal, balanced for high pressure, metal bellows for high temperature, dual for toxic.
3. **Select the face materials:** Carbon vs SiC for normal, SiC vs WC for abrasive, high-temperature materials for hot service.
4. **Select the elastomers:** Viton for general, EPDM for hot water, FFKM for extreme temperature, PTFE for chemical.
5. **Select the flush plan:** Plan 11 for clean, Plan 21/23 for hot, Plan 31 for abrasive, Plan 32 for clean external, Plan 52/53 for toxic.
6. **Verify the seal chamber** is compatible with the selected seal (bore, depth, pressure rating).
7. **Document the selection** with the operating conditions, the seal design, the materials, and the flush plan.

## Common Problems and Fixes
- **Seal fails at high temperature:** The elastomer degraded. Switch to a high-temperature material (FFKM) or a metal bellows seal.
- **Seal faces wear rapidly in abrasive service:** The flush is not removing solids. Install a cyclone separator or use a clean external flush.
- **Dual seal barrier fluid is contaminated:** The primary seal has failed. Isolate the pump and replace the seal.
- **Seal fails during cycling conditions:** The seal environment changes faster than the flush can compensate. Monitor the seal environment and adjust the flush during the cycle.

## Best Practices and Field Tips
- For challenging applications, consult the seal manufacturer — they have application engineers who can recommend the optimal seal design and flush plan.
- Document the operating conditions and the seal selection for each challenging application — it supports future troubleshooting and replacement decisions.
- For toxic services, install a barrier fluid leak detector that alarms in the control room — a barrier fluid leak indicates a primary seal failure.
- For abrasive service, trend the cyclone separator performance — a rising flush pressure drop indicates the separator is clogging.

## Safety Notes
- Toxic service seal failures are process safety incidents — follow the plant emergency response procedure.
- High-pressure seal failures can release high-pressure fluid — stand clear of the seal area during operation.',
   55, 1,
   '[{"question":"What type of seal is used for high-temperature service above 200°C?","options":["Standard elastomer seal","Metal bellows seal (no elastomers) or FFKM O-rings","Dual seal","Any seal"],"correctIndex":1},{"question":"What flush plan is used for abrasive service?","options":["Plan 11","Plan 21","Plan 31 (cyclone separator to remove solids from the flush)","Plan 53"],"correctIndex":2},{"question":"What does a dual seal with Plan 53 ensure for toxic service?","options":["Process fluid leaks to atmosphere","Barrier fluid leaks into the process, not process fluid out","No leakage at all","Cooling of the seal faces"],"correctIndex":1},{"question":"What face materials are used for abrasive service?","options":["Carbon vs SiC","SiC vs WC (both hard faces to resist abrasive wear)","Carbon vs carbon","Any materials"],"correctIndex":1},{"question":"What should be installed for toxic service barrier fluid leak detection?","options":["A sight glass","A barrier fluid leak detector that alarms in the control room","A temperature gauge","Nothing"],"correctIndex":1},{"question":"What should be done for a seal that fails during cycling operating conditions?","options":["Replace with the same seal","Monitor the seal environment and adjust the flush during the cycle","Increase the seal clearance","Replace the pump"],"correctIndex":1},{"question":"Who should be consulted for challenging seal applications?","options":["No one","The seal manufacturer — they have application engineers who can recommend the optimal design","The operator","The maintenance supervisor"],"correctIndex":1}]'::jsonb),
  (m_id, 'Seal Performance Trending & MTBSF Improvement',
   '## Overview
Mean Time Between Seal Failures (MTBSF) is the key reliability metric for mechanical seals. Trending the MTBSF and the failure modes for each pump identifies systemic issues and drives improvement. A plant with a MTBSF of 6 months can improve to 24+ months with proper analysis and corrective action.

## Key Concepts
- **MTBSF calculation:** Total operating time / number of seal failures. A pump that runs 12 months and has 2 seal failures has a MTBSF of 6 months.
- **Failure mode tracking:** For each seal failure, document the failure mode (heat checking, dry running, chemical incompatibility, abrasive wear, O-ring extrusion, spring clogging) and the root cause.
- **Systemic vs. random failures:** A pump that fails the same way twice has a systemic problem (wrong seal, wrong flush, wrong operating condition). A pump that fails differently each time has random problems (operational upsets, installation errors).
- **MTBSF benchmark:** A well-designed and maintained seal should achieve 24+ months. A MTBSF below 12 months indicates a systemic issue.
- **Improvement strategy:** Identify the dominant failure mode, find the root cause, and implement a corrective action (different seal, different flush, different operating procedure).

## Step-by-Step: MTBSF Improvement Program
1. **List all pumps with seal failures** for the past 2 years. Record the pump tag, the failure date, the failure mode, the time in service, and the root cause.
2. **Calculate the MTBSF** for each pump: total operating time / number of failures.
3. **Identify the dominant failure mode** — the mode that accounts for the most failures across all pumps.
4. **For each pump with a MTBSF below 12 months:** Identify the root cause and the corrective action.
5. **Implement the corrective actions:** Change the seal design, the flush plan, the operating procedure, or the installation procedure.
6. **Monitor the MTBSF** after the corrective actions — a rising MTBSF confirms the improvement.
7. **Report the MTBSF** quarterly to the maintenance team and management.

## Common Problems and Fixes
- **MTBSF is low across all pumps:** The seal selection standard is wrong, or the installation procedure is poor. Review the standard and the procedure.
- **MTBSF is low on one pump:** The pump has a specific problem (cavitation, misalignment, wrong seal, wrong flush). Root cause the specific failure.
- **MTBSF does not improve after corrective action:** The root cause was not correctly identified. Re-investigate.
- **Failure data is not available:** The failures are not documented. Implement a failure documentation system (CMMS) and record every failure.

## Best Practices and Field Tips
- Use a seal failure database (or CMMS) to track every seal failure with the pump tag, the date, the failure mode, the root cause, and the corrective action.
- Benchmark the MTBSF against industry data — a refinery typically achieves 24-36 months; a chemical plant 12-24 months; a paper mill 6-12 months.
- For the dominant failure mode, implement a plant-wide corrective action — if heat checking is the dominant mode, verify all flush flows and seal chamber pressures.
- Share the MTBSF data with operations — a low MTBSF may be caused by operational upsets (cavitation from low level, dry running from starting without opening the suction valve).

## Safety Notes
- Seal failure data is a reliability record — store it securely and use it for process safety management.
- A pump with a history of seal failures may be a process safety risk — evaluate the consequences of a seal failure on that pump.',
   50, 2,
   '[{"question":"How is MTBSF calculated?","options":["Number of failures per year","Total operating time / number of seal failures","Total operating hours","Number of seals replaced"],"correctIndex":1},{"question":"What MTBSF indicates a systemic issue?","options":["Below 36 months","Below 24 months","Below 12 months","Below 6 months"],"correctIndex":2},{"question":"What does a pump that fails the same way twice indicate?","options":["Bad luck","A systemic problem — wrong seal, wrong flush, or wrong operating condition","Normal coincidence","The seal brand is bad"],"correctIndex":1},{"question":"What is the MTBSF benchmark for a well-designed and maintained seal?","options":["6 months","12 months","24+ months","60 months"],"correctIndex":2},{"question":"What should be done if MTBSF does not improve after corrective action?","options":["Give up","The root cause was not correctly identified — re-investigate","Increase the PM frequency","Replace all seals"],"correctIndex":1},{"question":"What should be done for the dominant failure mode across all pumps?","options":["Nothing","Implement a plant-wide corrective action","Replace all pumps","Increase the seal inventory"],"correctIndex":1},{"question":"What should be shared with operations regarding seal failures?","options":["Nothing","The MTBSF data — a low MTBSF may be caused by operational upsets","The seal cost","The seal brand"],"correctIndex":1}]'::jsonb);
END $$;

-- 22. Rotating Equipment Reliability Fundamentals
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='mechanical' AND title='Rotating Equipment Reliability Fundamentals';
  IF NOT FOUND THEN RETURN; END IF;
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Reliability Metrics & Continuous Improvement', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Reliability KPIs, MTBF, MTTR & OEE',
   '## Overview
Reliability is measured with key performance indicators (KPIs) that quantify how well the equipment is performing and how well the maintenance program is working. Understanding the KPIs and how to use them is essential for a data-driven reliability program.

## Key Concepts
- **MTBF (Mean Time Between Failures):** The average time between failures. MTBF = total operating time / number of failures. A rising MTBF indicates improving reliability.
- **MTTR (Mean Time To Repair):** The average time to repair a failure. MTTR = total repair time / number of failures. A falling MTTR indicates improving maintainability.
- **OEE (Overall Equipment Effectiveness):** Availability × Performance × Quality. Availability = operating time / planned time. Performance = actual speed / design speed. Quality = good product / total product. A world-class OEE is 85%+.
- **Bad actor analysis:** The equipment that fails most frequently or has the highest downtime. Target the bad actors for improvement — fixing the top 5 bad actors can reduce the total downtime by 50%.
- **Reliability growth:** The trend of MTBF over time. A rising trend indicates the reliability program is working; a flat or falling trend indicates the program is not effective.

## Step-by-Step: Reliability KPI Program
1. **Define the KPIs** to track: MTBF, MTTR, OEE, and the bad actor list.
2. **Collect the data** from the CMMS: failure history, repair time, operating time, production data.
3. **Calculate the KPIs** monthly: MTBF = total operating time / failures; MTTR = total repair time / failures; OEE = availability × performance × quality.
4. **Identify the bad actors:** Rank the equipment by failure frequency and by downtime. Target the top 5.
5. **Root cause the bad actor failures:** For each bad actor, identify the dominant failure mode and the root cause.
6. **Implement corrective actions:** Redesign, upgrade, change the maintenance strategy, or change the operating procedure.
7. **Monitor the KPIs** after the corrective actions — a rising MTBF or a falling MTTR confirms the improvement.
8. **Report the KPIs** monthly to the maintenance team and quarterly to management.

## Common Problems and Fixes
- **MTBF is not improving:** The corrective actions are not addressing the root cause. Re-investigate.
- **MTTR is rising:** The spare parts are not available, or the repair procedure is not documented. Stock the spares and document the procedure.
- **OEE is low but the equipment is reliable:** The performance or the quality is low, not the availability. Investigate the speed and the quality.
- **Bad actors are not improving:** The root cause is not correctly identified. Re-investigate or escalate to engineering for a design change.

## Best Practices and Field Tips
- Use the CMMS to automate the KPI calculation — manual calculation is time-consuming and error-prone.
- Benchmark the KPIs against industry data — a refinery typically has MTBF 36-60 months; a chemical plant 24-36 months.
- Share the KPIs with operations — reliability is a shared responsibility, and operations can influence the MTBF by how they operate the equipment.
- Target the bad actors, not the average equipment — fixing the average equipment does not move the overall KPI.

## Safety Notes
- Reliability KPIs are a management tool, not a safety tool — but a reliable plant is a safer plant because it has fewer emergencies.
- A plant with a low MTBF has more emergency repairs, which are more dangerous than planned repairs.',
   50, 1,
   '[{"question":"How is MTBF calculated?","options":["Number of failures per year","Total operating time / number of failures","Total operating hours","Number of repairs"],"correctIndex":1},{"question":"What three factors make up OEE?","options":["Availability x performance x quality","MTBF x MTTR x downtime","Speed x load x efficiency","Cost x time x labor"],"correctIndex":0},{"question":"What is a world-class OEE?","options":["50%","65%","85%+","100%"],"correctIndex":2},{"question":"What are bad actors?","options":["Equipment that is old","Equipment that fails most frequently or has the highest downtime — target the top 5","Equipment that is cheap","Equipment that is new"],"correctIndex":1},{"question":"How much can fixing the top 5 bad actors reduce total downtime?","options":["5%","20%","50%","90%"],"correctIndex":2},{"question":"What does a rising MTBF trend indicate?","options":["Declining reliability","The reliability program is working","More failures","Normal operation"],"correctIndex":1},{"question":"What should be targeted for improvement, not the average equipment?","options":["The average equipment","The bad actors — fixing the average equipment does not move the overall KPI","The newest equipment","The cheapest equipment"],"correctIndex":1}]'::jsonb),
  (m_id, 'Reliability Centered Maintenance Implementation',
   '## Overview
Reliability Centered Maintenance (RCM) is a structured method for developing a maintenance program that balances cost, risk, and performance. Implementing RCM for rotating equipment transforms a maintenance program from time-based to condition-based, from reactive to proactive.

## Key Concepts
- **RCM starts with the FMEA:** List the functions, the failure modes, the effects, and the consequences for each asset.
- **Consequence classification:** Hidden (the failure is not evident during normal operation), safety/environmental, operational (production loss), or non-operational (no production loss).
- **Task selection:** Hidden failures get failure-finding tasks (test the function periodically). Safety/environmental get proactive tasks (condition monitoring or redesign). Operational get proactive or reactive based on cost-benefit. Non-operational get reactive (run to failure).
- **Failure pattern matching:** Wear-out patterns (bearing fatigue) get condition monitoring. Random patterns (seal failure from cavitation) get design changes. Age-related patterns (filter clogging) get time-based replacement.
- **Living program:** The RCM analysis is reviewed annually and updated with new failure modes and new condition data.

## Step-by-Step: RCM Implementation for Rotating Equipment
1. **Select the equipment** for RCM analysis — start with the bad actors (the top 5 by failure frequency or downtime).
2. **Perform the FMEA:** List the functions, the failure modes, the effects, and the consequences for each asset.
3. **Classify the consequences:** Hidden, safety/environmental, operational, or non-operational.
4. **Select the maintenance task** for each failure mode based on the consequence and the failure pattern.
5. **Document the maintenance plan** for each asset: the task, the interval, the technology (vibration, oil, thermography, ultrasound), and the responsible person.
6. **Implement the plan** in the CMMS: schedule the tasks, assign the technicians, and track the results.
7. **Review the plan annually** — update the FMEA with new failure modes, adjust the task intervals based on the condition data, and remove tasks that are not adding value.

## Common Problems and Fixes
- **RCM analysis is too time-consuming:** Start with the bad actors, not every asset. The bad actors provide the most improvement for the least effort.
- **RCM plan is not implemented:** The plan is a document, not a schedule. Implement the plan in the CMMS as scheduled tasks.
- **RCM plan is not reviewed:** The plan becomes outdated. Schedule an annual review and update the plan with new failure data.
- **RCM plan has too many time-based tasks:** The failure patterns were not matched to the task types. Re-evaluate: wear-out patterns get condition monitoring, not time-based replacement.

## Best Practices and Field Tips
- Start with the bad actors — the top 5 equipment by failure frequency or downtime. The RCM analysis on 5 assets is manageable and demonstrates the value.
- Use the CMMS to implement and track the RCM plan — a plan that is not in the CMMS is a document, not a program.
- Share the RCM plan with operations — the operating procedure can influence the failure mode (cavitation from low level, dry running from starting without opening the suction valve).
- The RCM program is a living program — it evolves as the equipment ages, the operating conditions change, and the failure data accumulates.

## Safety Notes
- The RCM analysis identifies safety-critical failure modes that require proactive maintenance or design changes — do not skip these in the implementation.
- A well-implemented RCM program reduces emergency repairs, which are more dangerous than planned repairs.',
   55, 2,
   '[{"question":"What is the starting point of an RCM analysis?","options":["The maintenance budget","The FMEA — functions, failure modes, effects, and consequences","The equipment age","The spare parts inventory"],"correctIndex":1},{"question":"What maintenance task does a hidden failure get?","options":["Run to failure","A failure-finding task (test the function periodically)","A time-based replacement","No task"],"correctIndex":1},{"question":"What maintenance task does a random failure pattern (seal failure from cavitation) get?","options":["Time-based replacement","Condition monitoring","A design change — better flush, higher NPSH margin","Run to failure"],"correctIndex":2},{"question":"How often should an RCM plan be reviewed?","options":["Every 10 years","Annually","Monthly","Never — it is a one-time exercise"],"correctIndex":1},{"question":"What should be started with for RCM implementation?","options":["Every asset","The bad actors — the top 5 by failure frequency or downtime","The newest equipment","The cheapest equipment"],"correctIndex":1},{"question":"What happens if the RCM plan is not implemented in the CMMS?","options":["It runs fine","It is a document, not a program — implement the plan in the CMMS as scheduled tasks","It is archived","It is forgotten"],"correctIndex":1},{"question":"What should be shared with operations regarding the RCM plan?","options":["Nothing","The operating procedure can influence the failure mode — cavitation from low level, dry running from starting without opening the suction valve","The maintenance cost","The FMEA document"],"correctIndex":1}]'::jsonb);
END $$;
