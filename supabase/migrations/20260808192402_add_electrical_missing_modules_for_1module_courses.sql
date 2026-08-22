-- ============================================================
-- PART 5: Add missing second modules for courses that originally had only 1 module
-- These courses need 2 modules to reach 3 total
-- ============================================================

-- 3-Phase Power Systems & Troubleshooting — Add Module 2: Power Factor & System Efficiency
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = '3-Phase Power Systems & Troubleshooting' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Power Factor & System Efficiency') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Power Factor & System Efficiency', 2) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Power Factor in 3-Phase Systems',
      '## Overview

Power factor is a critical concept in 3-phase power systems. Low power factor wastes system capacity, increases energy costs, and can trigger utility penalties. Understanding power factor in the context of 3-phase industrial systems — how to measure it, correct it, and avoid the pitfalls of correction — is essential for efficient and reliable power distribution.

## Key Concepts

- **Power factor definition**: The ratio of real power (kW) to apparent power (kVA). A PF of 1.0 means all power is real; a PF of 0.7 means 30% of the apparent power is reactive.
- **Reactive power (kVAR)**: The power that oscillates between the source and the load without doing useful work. Inductive loads (motors, transformers) consume reactive power.
- **Displacement vs true power factor**: Displacement PF is the cosine of the angle between voltage and current. True PF includes the effect of harmonics. VFDs and nonlinear loads have a true PF lower than their displacement PF.
- **Power factor correction**: Adding capacitors to supply reactive power locally, reducing the reactive power drawn from the source and improving the PF.
- **Utility penalties**: Many utilities charge for low PF (below 0.9 or 0.95) based on kVAR demand or kVA demand. Correcting PF can eliminate these charges.

## Step-by-Step: Measuring and Correcting Power Factor

1. **Measure the power factor**: Use a power quality analyzer or power meter to measure the PF, kW, kVAR, and kVA at the main service entrance.
2. **Identify the loads**: Determine which loads are causing the low PF (typically motors running unloaded or lightly loaded).
3. **Calculate the required correction**: Use the formula Qc = P × (tan(acos(PF1)) - tan(acos(PF2))), where Qc is the required capacitor kVAR, P is the real power, PF1 is the current PF, and PF2 is the target PF.
4. **Select the correction method**: Fixed capacitors for constant loads, automatic switched capacitors for variable loads, or synchronous condensers for large installations.
5. **Verify no resonance with harmonics**: If VFDs or other nonlinear loads are present, check for resonance between the capacitors and system inductance. Use detuned capacitor banks if necessary.
6. **Install the capacitors**: Install at the main service entrance (bulk correction) or at individual motors (local correction). Follow NEC 460 requirements.
7. **Verify the correction**: After installation, re-measure the PF to confirm it meets the target. Verify no overcorrection (leading PF).
8. **Document the installation**: Record the capacitor sizes, locations, and before/after PF readings.

## Common Problems

- **Overcorrection**: Adding too much capacitance creates a leading PF, which can cause overvoltage and equipment damage.
- **Resonance with harmonics**: Capacitors can resonate with system inductance, amplifying harmonics and damaging capacitors.
- **Capacitor failure**: Capacitors degrade over time, losing capacitance. Regular inspection and testing is required.
- **Switching transients**: Switching capacitors creates transients that can damage sensitive equipment. Use pre-insertion resistors or zero-crossing switches.
- **Motor self-excitation**: Local correction at a motor can cause self-excitation when the motor is disconnected, generating dangerous overvoltage. Use a contactor to disconnect the capacitor with the motor.

## Best Practices

- Correct PF to 0.95, not 1.0 — overcorrection is dangerous and provides no benefit.
- Use detuned capacitor banks (with series reactors) in systems with VFDs or other harmonic sources.
- Install automatic PF controllers for variable loads to maintain a constant PF.
- Inspect capacitors annually for swelling, leaking, or capacitance loss.
- Install capacitors at the main service for bulk correction, and at large individual motors for local correction.
- Monitor PF continuously with a power meter and alarm on low PF.

## Safety

- Capacitors store energy after disconnection — short the terminals before handling.
- Never touch capacitor terminals without verifying they are discharged.
- Motor self-excitation can generate dangerous voltages — always disconnect the capacitor with the motor.
- Switching capacitors creates transients — ensure surge protection is installed on sensitive equipment.
- Follow NEC 460 for capacitor installation requirements, including disconnecting means and overcurrent protection.',
      45, true, true,
      '[
        {"question":"What is power factor?","options":["The ratio of voltage to current","The ratio of real power (kW) to apparent power (kVA)","The efficiency of the motor","The angle between phases"],"correctIndex":1},
        {"question":"What is the recommended target PF for correction?","options":["1.0","0.95 (not 1.0 to avoid overcorrection)","0.80","0.50"],"correctIndex":1},
        {"question":"What problem can occur when adding capacitors to a system with VFDs?","options":["Nothing","Resonance between capacitors and system inductance that amplifies harmonics","Improved PF","Reduced harmonics"],"correctIndex":1},
        {"question":"How can resonance with harmonics be prevented?","options":["Remove the capacitors","Use detuned capacitor banks with series reactors","Add more capacitors","Use smaller capacitors"],"correctIndex":1},
        {"question":"What is motor self-excitation?","options":["Motor overcurrent","Local capacitors at a motor can cause self-excitation when disconnected, generating dangerous overvoltage","Motor overspeed","Motor stall"],"correctIndex":1},
        {"question":"How should motor self-excitation be prevented?","options":["Remove the capacitor","Use a contactor to disconnect the capacitor with the motor","Use a larger motor","Add a brake"],"correctIndex":1},
        {"question":"What must be done before handling capacitors?","options":["Nothing","Short the terminals to discharge stored energy","Test the voltage","Remove the capacitor"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, '3-Phase System Efficiency & Energy Management',
      '## Overview

Managing energy efficiency in 3-phase industrial systems goes beyond power factor correction. It includes load balancing, transformer loading, conductor sizing, and motor efficiency. A holistic approach to system efficiency reduces energy costs, extends equipment life, and improves system reliability.

## Key Concepts

- **Load balancing**: Unbalanced loads cause voltage unbalance, increased losses, and reduced motor life. Balancing loads across the three phases minimizes these effects.
- **Transformer loading**: Transformers are most efficient at 50-70% loading. Overloading causes overheating and reduced life; underloading wastes the core losses (no-load losses).
- **Conductor losses**: Undersized conductors cause I²R losses (heat). Proper conductor sizing per NEC tables minimizes these losses.
- **Motor efficiency**: Premium efficiency (IE3/NEMA Premium) motors are 2-8% more efficient than standard motors. For motors running continuously, the payback is typically 1-3 years.
- **Energy monitoring**: Installing energy meters on major loads enables tracking, identifying waste, and verifying efficiency improvements.

## Step-by-Step: Conducting a 3-Phase System Energy Audit

1. **Install energy meters**: Install meters at the main service entrance and on major feeders and loads.
2. **Measure load balance**: Measure current on each phase at the main panel and major subpanels. Identify unbalanced loads and redistribute them.
3. **Check transformer loading**: Measure transformer loading over time. If below 30%, consider consolidating loads or replacing with a smaller transformer. If above 80%, consider adding capacity.
4. **Inspect conductors**: Check for undersized or long conductor runs that cause excessive voltage drop and I²R losses. Upsize if necessary.
5. **Evaluate motor efficiency**: Inventory all motors. Identify motors running continuously that could be upgraded to premium efficiency. Calculate payback for each.
6. **Check for idle loads**: Identify motors or equipment running when not needed. Install controls (VFDs, timers, interlocks) to shut them off.
7. **Analyze energy data**: Review the energy meter data to identify patterns, waste, and savings opportunities. Compare to production output to calculate energy intensity.
8. **Implement improvements**: Prioritize improvements by payback period. Implement the most cost-effective measures first.
9. **Verify savings**: After implementing improvements, re-measure energy consumption to verify the savings match projections.

## Common Problems

- **Unbalanced loads**: One phase carries significantly more current than the others, causing voltage unbalance and increased losses.
- **Oversized motors**: Motors oversized for their loads operate at low efficiency. Replace with correctly sized motors or add VFDs.
- **Idle equipment**: Motors or equipment running when not in use waste energy. Install controls to shut them off.
- **Undersized conductors**: Long runs with undersized conductors cause voltage drop and I²R losses.
- **No energy monitoring**: Without energy meters, it is impossible to identify waste or verify savings.

## Best Practices

- Balance loads across all three phases to within 5% of average.
- Use premium efficiency motors for all new installations and motor replacements.
- Install energy meters on major loads and trend the data.
- Size conductors to minimize voltage drop (below 3% for feeders, below 5% total).
- Load transformers to 50-70% for maximum efficiency.
- Conduct an energy audit annually to identify new savings opportunities.
- Use VFDs on variable-torque loads (pumps, fans) for energy savings.

## Safety

- Energy meter installation requires working on energized equipment — use qualified personnel and appropriate PPE.
- Load balancing may require re-terminating conductors — de-energize and lock out before working.
- Motor replacement requires mechanical and electrical work — follow all safety procedures.
- When adding energy meters, ensure CTs are properly rated and installed per the manufacturer''s instructions.
- Never open a CT secondary circuit while energized — dangerous voltages can develop.',
      40, true, true,
      '[
        {"question":"What is the most efficient transformer loading range?","options":["10-20%","50-70%","90-100%","Any loading"],"correctIndex":1},
        {"question":"What is the maximum recommended load unbalance across three phases?","options":["1%","5% of average","20%","50%"],"correctIndex":1},
        {"question":"What is the typical payback for replacing a continuously running standard motor with a premium efficiency motor?","options":["10-20 years","1-3 years","Never pays back","6 months"],"correctIndex":1},
        {"question":"What is the maximum recommended voltage drop for a feeder?","options":["1%","3%","5%","10%"],"correctIndex":1},
        {"question":"What should be done with motors running when not needed?","options":["Nothing","Install controls (VFDs, timers, interlocks) to shut them off","Replace the motor","Reduce the voltage"],"correctIndex":1},
        {"question":"What is the purpose of energy monitoring in an energy management program?","options":["To satisfy regulatory requirements","To track consumption, identify waste, and verify savings","To improve power factor","To balance loads"],"correctIndex":1},
        {"question":"What should be done after implementing energy efficiency improvements?","options":["Nothing","Re-measure energy consumption to verify savings match projections","Replace all equipment","Conduct another audit"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Electrical Prints, Schematics & Ladder Diagrams — Add Module 2: Control Logic & Device Identification
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Electrical Prints, Schematics & Ladder Diagrams' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Control Logic & Device Identification') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Control Logic & Device Identification', 2) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Reading Control Logic & Boolean Operations',
      '## Overview

Control logic is the foundation of every industrial control circuit. Whether implemented with relays, timers, or a PLC, the underlying logic is the same: AND, OR, NOT, and memory (latching) operations. Being able to read a ladder diagram and translate it into Boolean logic — and vice versa — is an essential skill for troubleshooting and designing control circuits.

## Key Concepts

- **AND logic**: A series circuit — all contacts must be closed for the output to energize. In ladder logic, components in series on a rung represent an AND function.
- **OR logic**: A parallel circuit — any one of multiple contacts can energize the output. In ladder logic, parallel branches on a rung represent an OR function.
- **NOT logic**: A normally closed contact — the output is energized when the input is NOT present. In ladder logic, a NC contact represents a NOT function.
- **Memory (latching/seal-in)**: A self-holding circuit where a momentary input energizes the output and a contact from the output maintains it. The output stays on until a separate (stop) input breaks the circuit.
- **Truth tables**: A tabular representation of logic showing all input combinations and the resulting output. Useful for verifying logic before implementation.

## Step-by-Step: Translating a Ladder Diagram to Boolean Logic

1. **Identify the output**: Find the coil or output device on the right side of the ladder rung. This is the output of the logic.
2. **Identify the inputs**: Find all contacts (switches, sensors, auxiliary contacts) on the left side of the rung. These are the inputs.
3. **Determine series contacts (AND)**: Contacts in series on the same branch must ALL be closed for the output to energize. This is an AND function: Output = A AND B AND C.
4. **Determine parallel branches (OR)**: Contacts on parallel branches can energize the output independently. This is an OR function: Output = (A AND B) OR (C AND D).
5. **Identify normally closed contacts (NOT)**: A NC contact means the output is energized when the input is NOT present. This is a NOT function.
6. **Write the Boolean equation**: Combine the AND, OR, and NOT operations into a single equation. For example: Output = (Start OR Seal-in) AND NOT Stop AND NOT Overload.
7. **Create a truth table**: List all input combinations and the resulting output. Verify that the logic produces the desired behavior for all combinations.
8. **Verify against the ladder diagram**: Compare the Boolean equation and truth table to the ladder diagram to verify they match.

## Common Problems

- **Confusing series and parallel**: Series contacts are AND; parallel contacts are OR. Mixing them up leads to incorrect logic interpretation.
- **Forgetting NC contacts**: A normally closed contact is a NOT function. Forgetting to invert the logic leads to incorrect analysis.
- **Not recognizing seal-in**: The seal-in (holding) contact is an OR function with the start button. Not recognizing it leads to confusion about why the motor stays on after the start button is released.
- **Complex logic**: Multi-rung logic with interlocks and timers can be difficult to translate. Break it down rung by rung.
- **Not documenting the logic**: Without a Boolean equation or truth table, complex logic is difficult to communicate and verify.

## Best Practices

- Always write the Boolean equation for complex control circuits — it makes troubleshooting and verification easier.
- Use truth tables for critical safety circuits to verify all input combinations produce safe outputs.
- Label all contacts with their function (e.g., "Start," "Stop," "Overload," "Limit Switch Up").
- Use consistent numbering for rungs, contacts, and coils.
- Document the logic in the drawing notes or a separate logic description document.
- Verify the logic with a simulator or by manually tracing each input combination before building.

## Safety

- Incorrect logic interpretation can lead to dangerous operation (e.g., a motor starting when it should stop).
- Always verify safety-critical logic (emergency stop, interlocks) with a truth table before trusting the analysis.
- Never modify control logic without understanding the complete Boolean equation — a "simple" change can have unintended consequences.
- Test all modifications under controlled conditions before returning to normal operation.
- Document all logic changes and have a second person verify the modification.',
      40, true, true,
      '[
        {"question":"What does a series circuit in ladder logic represent?","options":["OR logic","AND logic (all contacts must be closed)","NOT logic","Memory"],"correctIndex":1},
        {"question":"What does a parallel circuit in ladder logic represent?","options":["AND logic","OR logic (any one branch can energize the output)","NOT logic","Memory"],"correctIndex":1},
        {"question":"What does a normally closed (NC) contact represent?","options":["AND logic","OR logic","NOT logic (output energized when input is NOT present)","Memory"],"correctIndex":2},
        {"question":"What is a seal-in (holding) contact in Boolean terms?","options":["AND","OR (parallel with the start button)","NOT","Exclusive OR"],"correctIndex":1},
        {"question":"What is a truth table used for?","options":["To measure voltage","To verify logic by listing all input combinations and resulting outputs","To size wire","To calculate power"],"correctIndex":1},
        {"question":"What is a common error when translating ladder logic to Boolean?","options":["Using the wrong wire size","Confusing series (AND) and parallel (OR) contacts","Using the wrong voltage","Missing a terminal block"],"correctIndex":1},
        {"question":"What should be done before modifying control logic?","options":["Just make the change","Understand the complete Boolean equation and verify all input combinations","Replace all components","Turn off the power"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Device Identification Standards & Wire Numbering',
      '## Overview

Consistent device identification and wire numbering are the difference between a maintainable control system and a nightmare. Standardized naming conventions allow any electrician to understand the system, troubleshoot efficiently, and make correct modifications. Understanding and applying these standards is a fundamental professional skill.

## Key Concepts

- **Device naming conventions**: Each device has a unique identifier (e.g., M1 for Motor 1 contactor, T1 for Timer 1, OL1 for Overload Relay 1). The identifier appears on the drawing and on the physical device.
- **Wire numbers**: Each wire has a unique number that appears on the drawing and on the physical wire (via a wire marker). Wire numbers allow tracing wires from the drawing to the panel.
- **Terminal numbers**: Each terminal on a device has a number (e.g., L1, L2, T1, T2 on a contactor). Terminal numbers appear on the device nameplate and on the drawing.
- **Line (rung) numbers**: Each rung on a ladder diagram has a unique number on the left side. Line numbers allow referencing specific rungs in documentation and troubleshooting.
- **Cross-referencing**: Contacts that appear on different rungs are cross-referenced — the coil shows the rung numbers where its contacts appear, and each contact shows the rung number of its coil.

## Step-by-Step: Applying Device Identification Standards

1. **Establish a naming convention**: Define prefixes for each device type (M = motor contactor, CR = control relay, T = timer, OL = overload, LS = limit switch, PB = push button, SS = selector switch).
2. **Assign unique numbers**: Each device gets a unique number within its type (M1, M2, M3; CR1, CR2; T1, T2). Number sequentially by location or function.
3. **Label devices in the panel**: Apply labels to each device with its identifier (e.g., "M1" on the Motor 1 contactor). Use a label maker for legibility.
4. **Number each wire**: Assign a unique number to each wire. Use a sequential numbering system or a page-line-wire system (e.g., wire 105 = page 1, line 05).
5. **Apply wire markers**: Install wire markers on each wire at both ends, matching the drawing wire number. Use pre-printed markers or a wire marker printer.
6. **Document terminal assignments**: Create a terminal schedule listing each terminal, its device, and the wires connected to it.
7. **Cross-reference contacts and coils**: On the ladder diagram, note the rung numbers where each coil''s contacts appear, and the rung number of each contact''s coil.
8. **Verify consistency**: Check that every device, wire, and terminal on the drawing has a matching label in the panel, and vice versa.

## Common Problems

- **Inconsistent naming**: Different electricians use different naming conventions, making the drawings inconsistent and difficult to follow.
- **Missing wire markers**: Wires without markers cannot be traced, making troubleshooting time-consuming and error-prone.
- **Unlabeled devices**: Devices without labels require tracing wires to identify, wasting troubleshooting time.
- **No cross-referencing**: Without cross-references, finding where a coil''s contacts appear requires scanning the entire drawing.
- **Outdated documentation**: The naming convention was changed but old drawings were not updated, creating confusion.

## Best Practices

- Establish a facility-wide naming convention and document it in the electrical standards.
- Use a wire marker printer for consistent, legible wire markers.
- Apply labels to all devices at installation time, not "later."
- Include a device list and wire list in the drawing package.
- Use cross-referencing on all ladder diagrams — it saves significant troubleshooting time.
- Keep the naming convention consistent across all projects and modifications.
- Train all electricians on the naming convention and enforce it.

## Safety

- Unlabeled or mislabeled devices and wires can lead to working on the wrong circuit — always verify with a meter.
- Inconsistent naming can cause a modification to be made to the wrong device, creating a safety hazard.
- Wire markers must be legible and durable — faded or missing markers create troubleshooting delays.
- When modifying a circuit, update all labels and documentation immediately — undocumented modifications are a safety hazard for the next technician.',
      40, true, true,
      '[
        {"question":"What does the prefix M typically represent in device naming?","options":["Motor","Motor contactor","Meter","Main breaker"],"correctIndex":1},
        {"question":"What is the purpose of wire numbers?","options":["To identify wire gauge","To uniquely identify each wire for tracing from the drawing to the panel","To indicate voltage","To show wire color"],"correctIndex":1},
        {"question":"What is cross-referencing in a ladder diagram?","options":["Linking drawings to other drawings","Noting the rung numbers where a coil''s contacts appear, and the rung number of each contact''s coil","Linking wires to terminals","Linking devices to the BOM"],"correctIndex":1},
        {"question":"Where should wire markers be applied?","options":["Only at one end","At both ends of each wire, matching the drawing wire number","Only in the panel","Only at the device"],"correctIndex":1},
        {"question":"What is a terminal schedule?","options":["A maintenance schedule","A document listing each terminal, its device, and the wires connected to it","A wire routing diagram","A device list"],"correctIndex":1},
        {"question":"What is a common problem with device identification in industrial facilities?","options":["Too many labels","Inconsistent naming conventions used by different electricians","Labels are too large","Labels are too colorful"],"correctIndex":1},
        {"question":"What should be done when modifying a circuit?","options":["Nothing — the original drawings are sufficient","Update all labels and documentation immediately","Delete the old drawings","Only update the wire list"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Electrical Safety Programs & NFPA 70E Application — Add Module 2: Risk Assessment & Hazard Identification
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Electrical Safety Programs & NFPA 70E Application' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Risk Assessment & Hazard Identification') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Risk Assessment & Hazard Identification', 2) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Electrical Hazard Risk Assessment',
      '## Overview

Risk assessment is the process of identifying electrical hazards, evaluating their severity, and implementing controls to mitigate them. NFPA 70E requires a risk assessment before any electrical work is performed. A thorough risk assessment identifies shock hazards, arc flash hazards, and other risks, and determines the controls needed to perform the work safely.

## Key Concepts

- **Shock hazard**: Contact with energized conductors can cause shock, burns, or death. The risk depends on voltage, available fault current, and the path through the body.
- **Arc flash hazard**: An arcing fault can release immense thermal energy, blast pressure, and sound. The risk depends on available fault current, clearing time, and working distance.
- **Risk assessment factors**: Voltage, available fault current, equipment type, task being performed, environmental conditions, and worker qualifications.
- **Hierarchy of controls**: Elimination (de-energize) > Engineering controls (remote operation, barriers) > Administrative controls (procedures, permits) > PPE.
- **Residual risk**: The risk that remains after controls are applied. Even with PPE, an arc flash can cause injury — PPE reduces but does not eliminate risk.

## Step-by-Step: Performing an Electrical Risk Assessment

1. **Identify the task**: What work is being performed? (Troubleshooting, maintenance, installation, inspection.)
2. **Identify the equipment**: What equipment is involved? What is the voltage, available fault current, and arc flash label?
3. **Identify the hazards**: Is there a shock hazard? An arc flash hazard? A blast hazard? What are the approach boundaries?
4. **Determine if de-energization is possible**: Can the equipment be de-energized? If yes, plan for LOTO. If no, document the justification.
5. **Evaluate the arc flash risk**: Read the arc flash label. What is the incident energy? What PPE category is required?
6. **Evaluate the shock risk**: What is the limited approach boundary? The restricted approach boundary? What PPE is needed?
7. **Select controls**: Apply the hierarchy of controls. Can the task be done remotely? Can a barrier be used? What PPE is needed?
8. **Determine residual risk**: After controls are applied, what risk remains? Is the residual risk acceptable? If not, do not perform the work.
9. **Document the assessment**: Record the task, hazards, controls, and residual risk. Include the assessment in the energized work permit if applicable.
10. **Brief the workers**: Review the risk assessment with all workers before starting the task. Ensure everyone understands the hazards and controls.

## Common Problems

- **Skipping the risk assessment**: Performing electrical work without a risk assessment leads to unanticipated hazards and injuries.
- **Underestimating the hazard**: Assuming a task is "quick" or "simple" and does not require full PPE. Even a quick task can result in an arc flash.
- **Not considering all hazards**: Focusing on shock and ignoring arc flash, or vice versa. Both must be assessed.
- **Relying on PPE alone**: PPE is the last line of defense. If the hazard can be eliminated or engineered out, that is preferable.
- **Not documenting the assessment**: An undocumented assessment cannot be verified or audited.

## Best Practices

- Perform a risk assessment before every electrical task, not just "high-risk" tasks.
- Use a standardized risk assessment form that covers shock, arc flash, and other hazards.
- Always attempt de-energization first — it is the most effective control.
- Read the arc flash label and verify it is current before relying on it.
- Apply the hierarchy of controls — do not jump straight to PPE.
- Document the assessment and include it in the energized work permit.
- Review the assessment with all workers before starting the task.

## Safety

- The risk assessment itself is a safety tool — do not treat it as paperwork.
- If the residual risk is unacceptable, do not perform the work. No task is worth a serious injury.
- The risk assessment must be performed by a qualified person who understands the hazards.
- Verify the arc flash label is current — an outdated label may underestimate the hazard.
- If conditions change during the work (e.g., a different circuit is energized), stop and reassess.',
      45, true, true,
      '[
        {"question":"What is the purpose of an electrical risk assessment?","options":["To satisfy paperwork requirements","To identify hazards, evaluate severity, and implement controls to mitigate them before performing work","To calculate project cost","To determine the project schedule"],"correctIndex":1},
        {"question":"What is the hierarchy of controls?","options":["PPE first, then elimination","Elimination (de-energize) > Engineering > Administrative > PPE (last resort)","Engineering only","Administrative only"],"correctIndex":1},
        {"question":"What should be attempted first before any electrical work?","options":["Wear PPE","De-energization — it is the most effective control","Read the arc flash label","Notify the supervisor"],"correctIndex":1},
        {"question":"What information is needed from the arc flash label?","options":["The manufacturer name","Incident energy, arc flash boundary, and required PPE category","The equipment model number","The installation date"],"correctIndex":1},
        {"question":"What is residual risk?","options":["Risk before controls","The risk that remains after controls are applied","Risk from other sources","Risk to the equipment"],"correctIndex":1},
        {"question":"What should be done if the residual risk is unacceptable?","options":["Proceed anyway with extra PPE","Do not perform the work — no task is worth a serious injury","Proceed quickly","Ask a coworker to help"],"correctIndex":1},
        {"question":"Who should perform the risk assessment?","options":["Anyone","A qualified person who understands the hazards","The supervisor","The safety officer only"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Hazardous Energy Control & LOTO Programs',
      '## Overview

Lockout/Tagout (LOTO) is the process of isolating hazardous energy sources and verifying isolation before performing work. An effective LOTO program is the single most important element of an electrical safety program — it prevents the most common cause of electrical fatalities: unexpected energization while working on equipment.

## Key Concepts

- **LOTO procedure**: A documented procedure for each piece of equipment that specifies the energy sources, isolation points, and verification methods.
- **Energy isolation devices**: Disconnects, breakers, valves, and other devices used to isolate energy. Must be capable of being locked.
- **Lock and tag**: Each worker applies a personal lock and tag to each isolation point. The tag identifies the worker, date, and reason.
- **Verification of isolation**: After applying locks, verify the absence of voltage with a rated tester. This is the most critical step — never skip it.
- **Group LOTO**: When multiple workers are involved, a lockbox with a lock from each worker is used. Each worker verifies the isolation before starting work.
- **LOTO exception**: Cord-and-plug connected equipment may be exempt from formal LOTO if the plug is under the exclusive control of the worker.

## Step-by-Step: Implementing a LOTO Program

1. **Inventory equipment**: Identify all equipment that requires LOTO. Create a list with equipment name, location, and energy sources.
2. **Develop LOTO procedures**: For each piece of equipment, document the energy sources, isolation points, method of isolation, and verification method. Create a written, equipment-specific procedure.
3. **Identify isolation points**: Physically locate each disconnect, breaker, or valve that isolates the energy. Verify it can be locked.
4. **Provide locks and tags**: Provide each worker with a personal lock (keyed differently) and tags. Locks must be unique to each worker.
5. **Train workers**: Train all workers on the LOTO procedure, including how to isolate, verify, apply locks, and remove locks.
6. **Implement the procedure**: Before any work, the worker isolates the energy, applies their personal lock and tag, and verifies absence of voltage.
7. **Verify isolation**: After applying locks, test for absence of voltage with a rated tester. Test the tester on a known live source before and after (live-dead-live test).
8. **Perform the work**: Only after verification of isolation may the work begin.
9. **Remove locks**: After work is complete, each worker removes their own lock and tag. The equipment can then be re-energized.
10. **Audit the program**: Periodically audit LOTO compliance by observing workers and reviewing procedures.

## Common Problems

- **No written procedures**: LOTO is performed "from memory" without written procedures, leading to missed isolation points.
- **Shared locks**: Workers share locks, defeating the purpose of personal locks. Each worker must have their own lock.
- **Skipping verification**: Not testing for absence of voltage after locking out. This is the most dangerous omission.
- **Not isolating all energy sources**: Forgetting to isolate secondary energy sources (control power, spring energy, hydraulic pressure).
- **Removing others'' locks**: Removing a lock that is not yours without following the specific removal procedure. This is a serious safety violation.
- **No LOTO for "quick" tasks**: Bypassing LOTO for tasks perceived as quick or simple. Even a quick task can result in a fatality if the equipment is unexpectedly energized.

## Best Practices

- Develop written, equipment-specific LOTO procedures for all equipment.
- Provide personal locks to each worker — never share locks.
- Always verify absence of voltage with a rated tester after locking out (live-dead-live test).
- Use a lockbox for group LOTO with a lock from each worker.
- Train all workers on LOTO procedures and verify competency.
- Audit LOTO compliance regularly by observing workers.
- Never bypass LOTO for any task, no matter how quick or simple.
- Post LOTO procedures at or near the equipment.

## Safety

- Never remove a lock that is not yours — follow the specific lock removal procedure if the worker is unavailable.
- Always verify absence of voltage with a rated tester — do not assume the equipment is de-energized.
- Test the tester on a known live source before and after testing the isolated equipment (live-dead-live verification).
- Isolate ALL energy sources, not just the primary source — control power, spring energy, and hydraulic pressure can also be hazardous.
- If LOTO cannot be verified, do not perform the work — stop and resolve the issue.
- Keep a record of all LOTO events, including the equipment, workers, and duration.',
      45, true, true,
      '[
        {"question":"What is the most critical step in the LOTO procedure?","options":["Applying the lock","Verification of absence of voltage with a rated tester","Applying the tag","Notifying the supervisor"],"correctIndex":1},
        {"question":"What is the live-dead-live test?","options":["A type of voltage test","Testing the tester on a known live source, then the isolated equipment (should read dead), then the live source again to verify the tester is working","Testing for voltage three times","Testing the motor while running"],"correctIndex":1},
        {"question":"Who may remove a lock that is not their own?","options":["Anyone","Only the person who applied it, or a specific removal procedure if they are unavailable","The supervisor","The safety officer"],"correctIndex":1},
        {"question":"What is group LOTO?","options":["One person locks out for everyone","A lockbox with a personal lock from each worker, so each worker is individually protected","A single lock for the whole group","No locks needed for group work"],"correctIndex":1},
        {"question":"What is the LOTO exception for cord-and-plug connected equipment?","options":["No LOTO is needed","If the plug is under the exclusive control of the worker, formal LOTO may not be required","All cord-and-plug equipment needs full LOTO","Only the plug needs to be tagged"],"correctIndex":1},
        {"question":"What energy sources must be isolated?","options":["Only the primary power source","All energy sources, including control power, spring energy, and hydraulic pressure","Only the main breaker","Only the voltage source"],"correctIndex":1},
        {"question":"What should be done if LOTO cannot be verified?","options":["Proceed carefully","Stop and resolve the issue — do not perform the work","Remove the lock and try again","Call a supervisor"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Hazardous Location Electrical Installations — Add Module 2: Equipment Selection & Installation Practices
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Hazardous Location Electrical Installations' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Equipment Selection & Installation Practices') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Equipment Selection & Installation Practices', 2) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Selecting Equipment for Classified Areas',
      '## Overview

Selecting the right equipment for hazardous (classified) locations is critical for safety. The wrong equipment can ignite a flammable atmosphere, causing an explosion. Equipment must be selected based on the Class, Division/Zone, Group, and temperature code of the area. Understanding the selection criteria and the available equipment types is essential for anyone designing or installing electrical equipment in classified areas.

## Key Concepts

- **Explosionproof equipment**: Designed to contain an internal explosion and prevent it from igniting the surrounding atmosphere. Used in Class I, Division 1.
- **Intrinsically safe equipment**: Limits electrical energy to a level that cannot ignite the hazardous atmosphere. Used for instruments and low-power devices.
- **Nonincendive equipment**: Designed to not produce arcs or sparks under normal operation. Used in Class I, Division 2 where hazards are present only under abnormal conditions.
- **Dust-ignitionproof**: Similar to explosionproof but designed for combustible dust (Class II). Prevents dust from entering and prevents surface temperature from igniting dust.
- **Purged and pressurized**: Enclosures purged with clean air or inert gas to prevent the hazardous atmosphere from entering. Used for large equipment that cannot be made explosionproof.
- **Temperature code (T-code)**: The maximum surface temperature of the equipment. Must not exceed 80% of the auto-ignition temperature of the hazardous gas or dust.

## Step-by-Step: Selecting Equipment for a Classified Area

1. **Determine the area classification**: Obtain the area classification drawing showing Class, Division/Zone, Group, and T-code for the specific area.
2. **Identify the equipment type**: Determine what equipment is needed (motor, lighting fixture, switch, receptacle, instrument, enclosure).
3. **Select the protection method**: Based on the classification, select the appropriate protection method (explosionproof, intrinsically safe, nonincendive, dust-ignitionproof, purged).
4. **Verify the T-code**: Ensure the equipment T-code is below the auto-ignition temperature of the hazardous material. For example, for propane (auto-ignition 470°C), select T1 (450°C max).
5. **Verify the Group rating**: Ensure the equipment is rated for the specific Group (A, B, C, D for gases; E, F, G for dusts).
6. **Check the NEMA rating**: Ensure the enclosure NEMA rating matches the environment (NEMA 7 for Class I, NEMA 9 for Class II).
7. **Verify listing**: Ensure the equipment is listed by a nationally recognized testing laboratory (UL, FM, CSA) for the specific classification.
8. **Document the selection**: Record the equipment selection, including the classification, protection method, T-code, and listing information.

## Common Problems

- **Wrong T-code**: Equipment with a T-code above the auto-ignition temperature of the hazardous material can ignite it.
- **Wrong Group**: Equipment rated for Group D (propane) used in a Group C (ethylene) area may not contain the explosion.
- **Unlisted equipment**: Equipment without a listing for the specific classification is not compliant and may not provide the required protection.
- **Wrong protection method**: Using nonincendive equipment in a Division 1 area where explosionproof is required.
- **Oversized lamps**: Replacing lamps with higher-wattage units that exceed the fixture''s T-code rating.

## Best Practices

- Always verify the area classification before selecting equipment.
- Use only listed and labeled equipment for the specific Class, Division, Group, and T-code.
- Keep a record of all equipment selections, including the classification basis and listing information.
- When in doubt, select equipment rated for a more severe classification (e.g., Division 1 instead of Division 2).
- Consult the equipment manufacturer to verify suitability for the specific application.
- Consider using intrinsically safe barriers for instruments — they are the safest option for low-power devices.
- Label all equipment with its classification rating for future reference.

## Safety

- Never install non-rated equipment in a classified area — this is a serious safety violation.
- Verify the T-code and Group rating of all equipment before installation.
- Do not replace lamps with higher-wattage units — this can exceed the T-code and ignite the atmosphere.
- Purged enclosures must have the purge gas supply monitored and alarmed — loss of purge pressure creates a hazard.
- Intrinsically safe barriers must be installed correctly per the manufacturer''s instructions — incorrect installation can allow unsafe energy into the classified area.',
      45, true, true,
      '[
        {"question":"What does explosionproof equipment do?","options":["Prevents explosions","Contains an internal explosion and prevents it from igniting the surrounding atmosphere","Is completely sealed","Is intrinsically safe"],"correctIndex":1},
        {"question":"What does intrinsically safe equipment do?","options":["Contains explosions","Limits electrical energy to a level that cannot ignite the hazardous atmosphere","Operates at low voltage","Is dust-ignitionproof"],"correctIndex":1},
        {"question":"What is the T-code?","options":["The temperature rating of the area","The maximum surface temperature of the equipment, which must not exceed 80% of the auto-ignition temperature of the hazardous material","The operating temperature","The storage temperature"],"correctIndex":1},
        {"question":"What protection method is used for large equipment that cannot be made explosionproof?","options":["Intrinsically safe","Purged and pressurized (clean air or inert gas purging)","Nonincendive","Dust-ignitionproof"],"correctIndex":1},
        {"question":"What listing is required for classified area equipment?","options":["No listing needed","Listing by a nationally recognized testing laboratory (UL, FM, CSA) for the specific classification","Any UL listing","Manufacturer self-certification"],"correctIndex":1},
        {"question":"What happens if a lamp with higher wattage is installed in an explosionproof fixture?","options":["It is brighter","It can exceed the T-code and ignite the hazardous atmosphere","It saves energy","It improves visibility"],"correctIndex":1},
        {"question":"When in doubt about the classification, what should be done?","options":["Use standard equipment","Select equipment rated for a more severe classification (e.g., Division 1 instead of Division 2)","Use the cheapest equipment","Consult the operator"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Installation Methods for Classified Locations',
      '## Overview

Installation methods in hazardous (classified) locations follow strict NEC requirements that differ from general industrial wiring. The wiring method, sealing practices, and grounding all have specific requirements. Understanding these requirements is essential for safe and compliant installations in classified areas.

## Key Concepts

- **Approved wiring methods**: RMC and IMC with threaded connections are the primary wiring methods in Division 1. EMT, FMC, and Type MC cable are permitted in Division 2 with restrictions.
- **Thread requirements**: All threads must be NPT and have at least 5 full threads engaged. Damaged threads compromise the flame path.
- **Seal fittings**: Required at enclosure boundaries in Division 1 (within 18 inches). Prevent gas migration through conduit.
- **Grounding and bonding**: All equipment must be grounded and bonded. The equipment grounding conductor must be run with the circuit conductors.
- **Flexible connections**: FMC (Sealtite) is permitted for short flexible connections to motors and equipment, but must be sealed if passing between classified and unclassified areas.

## Step-by-Step: Installing Wiring in a Class I, Division 1 Location

1. **Select the wiring method**: Use RMC or IMC with threaded NPT connections. EMT is NOT permitted in Division 1.
2. **Cut and thread the conduit**: Cut the conduit to length and thread with NPT dies. Apply anti-seize to threads to prevent galling.
3. **Make up the connections**: Engage at least 5 full threads at each connection. Wrench-tighten all connections — do not hand-tighten.
4. **Install seal fittings**: Install seal fittings within 18 inches of each enclosure and at each area boundary. Use the correct size seal for the conduit.
5. **Pull the conductors**: Pull the conductors through the conduit, separating them at seal fittings for compound penetration.
6. **Pour the seals**: Mix and pour the factory-approved sealing compound into each seal fitting. Separate the conductors so compound fills all voids. Allow to cure fully.
7. **Install explosionproof enclosures**: Use NEMA 7 enclosures with threaded hubs. Install gaskets and torque all bolts to specification.
8. **Ground and bond**: Connect the equipment grounding conductor to all enclosures and equipment frames. Bond all conduit to enclosures.
9. **Install lighting**: Use explosionproof lighting fixtures with the correct T-code and lamp wattage.
10. **Inspect and test**: Verify all threads are engaged, all seals are poured and cured, and all equipment is properly rated and grounded.

## Common Problems

- **Using EMT in Division 1**: EMT is not permitted in Division 1 — it cannot contain an explosion.
- **Insufficient thread engagement**: Fewer than 5 full threads compromises the flame path and violates code.
- **Missing or improper seals**: Seals missing at enclosures or boundaries, or seals with bundled conductors that prevent compound penetration.
- **Wrong conduit fittings**: Standard (non-rated) fittings used in classified areas. Only rated fittings may be used.
- **Improper grounding**: Missing or inadequate equipment grounding in classified areas creates a spark hazard.

## Best Practices

- Use RMC with threaded connections for all Class I, Division 1 installations.
- Apply anti-seize to all threads to prevent galling and ensure proper engagement.
- Install seals at every enclosure and at every area boundary.
- Separate conductors in seal fittings so compound fills all voids.
- Use only explosionproof enclosures, fittings, and fixtures.
- Verify all equipment is listed for the specific classification.
- Ground and bond all equipment and conduit.
- Document the installation with photos and inspection records.

## Safety

- Never use EMT or non-rated fittings in Division 1 — they cannot contain an explosion.
- Verify all threads have at least 5 full threads engaged before energizing.
- Do not energize until all seals are cured and inspected.
- Use non-sparking tools during installation in classified areas.
- Verify the area is gas-free before opening any enclosure or pulling conductors.
- All explosionproof enclosures must have all bolts reinstalled and torqued before energizing.',
      45, true, true,
      '[
        {"question":"What wiring method is permitted in Class I, Division 1?","options":["EMT","RMC or IMC with threaded NPT connections","Romex","PVC"],"correctIndex":1},
        {"question":"What is NOT permitted in Class I, Division 1?","options":["RMC","EMT","IMC","Type MI cable"],"correctIndex":1},
        {"question":"What is the minimum thread engagement for threaded connections in classified areas?","options":["2 full threads","5 full threads","10 full threads","No minimum"],"correctIndex":1},
        {"question":"Where must seal fittings be installed in Division 1?","options":["Only at the enclosure","Within 18 inches of each enclosure and at each area boundary","Every 10 feet","Only at the boundary"],"correctIndex":1},
        {"question":"What must be done with conductors in a seal fitting?","options":["Bundle them tightly","Separate them so the sealing compound fills all voids","Use only one conductor","Nothing special"],"correctIndex":1},
        {"question":"What should be applied to threads to prevent galling?","options":["Paint","Anti-seize compound","Grease","Nothing"],"correctIndex":1},
        {"question":"What must be verified before energizing a classified area installation?","options":["Nothing","All threads are engaged, all seals are cured, and all equipment is properly rated and grounded","The conduit color","The wire size"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Soft Starters & Reduced Voltage Starting — Add Module 2: Soft Starter Setup & Commissioning
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Soft Starters & Reduced Voltage Starting' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Soft Starter Setup & Commissioning') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Soft Starter Setup & Commissioning', 2) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Soft Starter Parameter Setup & Tuning',
      '## Overview

Setting up and tuning a soft starter requires understanding the motor, the load, and the soft starter''s parameters. Incorrect settings can cause the motor to stall, trip the overload, or fail to start. Proper tuning ensures smooth, reliable starting with minimum current and mechanical stress.

## Key Concepts

- **Initial voltage**: The voltage applied at the beginning of the start ramp. Typically 30-60% of full voltage. Too low = insufficient torque; too high = excessive current.
- **Ramp time**: The time to ramp from initial to full voltage. Typically 5-30 seconds. Too short = high current; too long = motor overheating.
- **Current limit**: The maximum current allowed during starting. Typically 200-400% of FLA. Overrides the voltage ramp if the current exceeds the limit.
- **Kick-start (pulse start)**: A short pulse of higher voltage at the beginning to break static friction. Useful for loaded conveyors and compressors.
- **Soft stop**: A controlled deceleration ramp. Useful for pumps to prevent water hammer. Not suitable for all loads (e.g., hoists that need to stop quickly).

## Step-by-Step: Setting Up and Tuning a Soft Starter

1. **Enter motor nameplate data**: Input motor FLA, voltage, frequency, and service factor into the soft starter.
2. **Set the initial voltage**: Start at 30% for centrifugal loads, 50% for constant torque loads. Adjust based on performance.
3. **Set the ramp time**: Start with 10 seconds for centrifugal loads, 15-20 seconds for high-inertia loads. Adjust based on actual acceleration.
4. **Set the current limit**: Start at 300% of FLA. Adjust down if the supply cannot handle the current, or up if the motor stalls.
5. **Enable kick-start if needed**: For loads with high static friction, enable kick-start at 60-70% for 0.5-1 second.
6. **Configure the bypass**: Enable the bypass contactor to engage at full speed for running efficiency.
7. **Set the overload class**: Match the soft starter''s electronic overload to the motor''s requirements (Class 10, 20, or 30).
8. **Test the start**: Start the motor and observe the current, voltage, and acceleration. The motor should accelerate smoothly without stalling.
9. **Tune the settings**: If the motor stalls, increase the initial voltage or current limit. If the starting current is too high, decrease the initial voltage or ramp time. If the motor accelerates too slowly, decrease the ramp time or increase the current limit.
10. **Document the final settings**: Record all parameters in the commissioning documentation.

## Common Problems

- **Motor stalls during ramp**: Initial voltage too low or ramp time too long. Increase initial voltage or current limit, or decrease ramp time.
- **Overload trips during start**: Starting time exceeds overload trip time. Use Class 30 overload or increase current limit to reduce starting time.
- **Excessive starting current**: Current limit set too high or initial voltage too high. Reduce current limit or initial voltage.
- **Motor does not reach full speed**: Ramp time too short or load too heavy. Increase ramp time or current limit.
- **Bypass does not engage**: Bypass threshold not reached or bypass contactor failed. Check bypass settings and contactor.

## Best Practices

- Start with conservative settings (low initial voltage, long ramp time) and adjust up to achieve reliable starting.
- Use current limit mode for applications with strict current limitations.
- Always enable the bypass contactor for continuous-duty applications.
- Match the overload class to the load type (Class 10 for submersible pumps, Class 30 for high-inertia loads).
- Document the final settings for future reference and troubleshooting.
- Test the soft starter under worst-case conditions (hot motor, loaded start) to ensure reliability.

## Safety

- De-energize and lock out before accessing soft starter terminals.
- The soft starter does not provide isolation — a separate disconnect is required.
- After parameter changes, test the motor start from a safe distance — incorrect parameters can cause unexpected motor behavior.
- The bypass contactor can energize the motor even when the soft starter is powered off — follow LOTO procedures.
- Soft starters generate heat during starting — ensure adequate enclosure ventilation.',
      40, true, true,
      '[
        {"question":"What is the typical initial voltage setting for a centrifugal pump?","options":["10%","30% of full voltage","80%","100%"],"correctIndex":1},
        {"question":"What should be done if the motor stalls during the start ramp?","options":["Decrease the initial voltage","Increase the initial voltage or current limit","Increase the ramp time","Disable the soft starter"],"correctIndex":1},
        {"question":"What is the purpose of kick-start (pulse start)?","options":["To start the motor faster","To provide a short pulse of higher voltage to break static friction on loaded equipment","To stop the motor","To improve efficiency"],"correctIndex":1},
        {"question":"What is the typical current limit setting for a soft starter?","options":["100% of FLA","200-400% of FLA","600% of FLA","1000% of FLA"],"correctIndex":1},
        {"question":"What overload class should be used for a high-inertia load with a long starting time?","options":["Class 5","Class 10","Class 30","Class 50"],"correctIndex":2},
        {"question":"What should be done after tuning the soft starter settings?","options":["Nothing","Document the final settings in the commissioning documentation","Reset to defaults","Remove the soft starter"],"correctIndex":1},
        {"question":"What safety precaution is needed when accessing soft starter terminals?","options":["Nothing — they are low voltage","De-energize and lock out — the soft starter does not provide isolation","Wear gloves","Use insulated tools only"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Soft Starter Troubleshooting & Maintenance',
      '## Overview

Soft starters are generally reliable, but they can experience faults and failures. Understanding common fault types, their causes, and troubleshooting procedures is essential for maintaining soft starter installations. Regular maintenance extends the life of the soft starter and prevents unexpected failures.

## Key Concepts

- **SCR failures**: The thyristors (SCRs) can fail open or shorted. A shorted SCR applies full voltage to the motor (no soft start). An open SCR prevents the motor from starting.
- **Overtemperature**: The soft starter has a heatsink temperature sensor. Overtemperature can be caused by blocked ventilation, high ambient, or oversized carrier frequency (not applicable to soft starters, but excessive starting frequency can cause overheating).
- **Control board failures**: The control board can fail from voltage transients, heat, or age. Symptoms include no output, incorrect ramp behavior, or communication failure.
- **Bypass contactor failure**: The bypass contactor can fail to close or fail to open. A failed-closed bypass means no soft start; a failed-open bypass means SCR losses during running.
- **Starting frequency**: Soft starters are rated for a certain number of starts per hour. Exceeding this causes overheating and premature failure.

## Step-by-Step: Troubleshooting a Soft Starter

1. **Read the fault code**: Note the fault code displayed on the soft starter. Look up the code in the manufacturer''s manual.
2. **Check the motor and cable**: Megger the motor and cable to check for insulation breakdown, shorted windings, or ground faults.
3. **Check the input power**: Measure the three-phase input voltage. Check for phase loss, voltage unbalance, or low voltage.
4. **Check the SCRs**: With power off, use a multimeter to check each SCR for short or open. A shorted SCR reads near zero in both directions; an open SCR reads high resistance.
5. **Check the heatsink temperature**: Verify the heatsink temperature sensor is reading correctly and the heatsink is not blocked with dust.
6. **Check the bypass contactor**: Verify the bypass contactor closes at full speed and opens when the motor stops. Check the contactor contacts for wear.
7. **Review the parameters**: Verify the motor nameplate data, initial voltage, ramp time, and current limit are correct for the application.
8. **Check the starting frequency**: Verify the number of starts per hour is within the soft starter''s rating. If not, consider a larger soft starter or a VFD.
9. **Clear the fault and test**: After identifying and correcting the cause, clear the fault and test the start under controlled conditions.

## Common Problems

- **SCR shorted**: The motor starts across-the-line (no soft start). Caused by voltage transients or age. Replace the soft starter or the SCR module.
- **Overtemperature trip**: The soft starter trips on overtemperature. Caused by blocked ventilation, high ambient, or excessive starting frequency.
- **Motor stalls during start**: The initial voltage or current limit is too low, or the load has increased. Adjust settings.
- **Bypass contactor fails to close**: The bypass contactor coil or contacts are bad. Replace the contactor.
- **Communication failure**: The soft starter does not communicate with the control system. Check the communication cable, address, and protocol settings.
- **Nuisance trips**: The soft starter trips without an apparent cause. Check for voltage transients, loose connections, or incorrect parameters.

## Best Practices

- Perform annual preventive maintenance: clean the heatsink, check terminal torque, and inspect SCRs.
- Keep spare soft starters or SCR modules for critical applications.
- Monitor the heatsink temperature and starting frequency for predictive maintenance.
- Install the soft starter in a properly ventilated enclosure.
- Use line reactors or surge protection to protect SCRs from voltage transients.
- Document all faults and their resolutions for future troubleshooting.

## Safety

- De-energize and lock out before accessing soft starter internals.
- The bypass contactor can energize the motor even when the soft starter is powered off.
- SCRs can fail shorted, causing the motor to start unexpectedly. Include a monitoring circuit.
- Wait for the heatsink to cool before touching it — it can be hot enough to burn.
- Use properly rated test instruments for the voltage level.',
      40, true, true,
      '[
        {"question":"What happens when an SCR fails shorted?","options":["The motor stops","The motor starts across-the-line with no soft start (full voltage applied immediately)","The soft starter trips","Nothing changes"],"correctIndex":1},
        {"question":"What is a common cause of overtemperature trips in soft starters?","options":["Low voltage","Blocked ventilation, high ambient, or excessive starting frequency","Undersized motor","Low carrier frequency"],"correctIndex":1},
        {"question":"How is a shorted SCR identified?","options":["It reads high resistance","It reads near zero ohms in both directions with a multimeter","It reads normal","It cannot be tested"],"correctIndex":1},
        {"question":"What should be checked if the bypass contactor fails to close?","options":["The motor","The bypass contactor coil and contacts","The input voltage","The SCRs"],"correctIndex":1},
        {"question":"What can cause nuisance trips in a soft starter?","options":["Oversized wire","Voltage transients, loose connections, or incorrect parameters","Low ambient temperature","Undersized motor"],"correctIndex":1},
        {"question":"What maintenance should be performed annually on a soft starter?","options":["Nothing","Clean the heatsink, check terminal torque, and inspect SCRs","Replace the soft starter","Update the firmware"],"correctIndex":1},
        {"question":"What safety hazard exists when an SCR fails shorted?","options":["The motor stops","The motor can start unexpectedly, causing injury to personnel working on the equipment","The soft starter overheats","The motor runs faster"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;
