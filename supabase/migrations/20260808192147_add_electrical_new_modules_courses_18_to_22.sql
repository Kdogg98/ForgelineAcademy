-- ============================================================
-- PART 4d: Add new modules + 2 lessons each for courses 18-22
-- ============================================================

-- Course 18: Soft Starters & Reduced Voltage Starting — Add Module 3: Soft Starter Application & Sizing
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Soft Starters & Reduced Voltage Starting' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Soft Starter Application & Sizing') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Soft Starter Application & Sizing', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Soft Starter Selection & Application Guidelines',
      '## Overview

Solid-state soft starters use thyristors (SCRs) to gradually increase the voltage applied to the motor during starting, reducing inrush current and mechanical stress. Unlike VFDs, soft starters do not control motor speed during running — they only control the starting (and stopping) ramp. Understanding when to use a soft starter vs a VFD vs an across-the-line starter is essential for cost-effective motor starting solutions.

## Key Concepts

- **Soft starter operation**: During starting, the SCRs fire at a delayed phase angle, applying reduced voltage. The firing angle is gradually advanced until full voltage is applied. This provides a smooth, stepless voltage ramp.
- **Current limit vs voltage ramp**: Soft starters can be programmed for a voltage ramp (linear increase from initial to full voltage over a set time) or a current limit (maximum current during starting). Current limit is more commonly used for demanding applications.
- **Initial voltage setting**: The starting voltage is typically set to 30-60% of full voltage. Too low and the motor cannot develop enough breakaway torque; too high and the starting current reduction is minimal.
- **Ramp time**: The time from initial to full voltage, typically 5-30 seconds. Longer ramps reduce starting current but increase motor heating.
- **Bypass contactor**: After the motor reaches full speed, a bypass contactor closes around the SCRs, eliminating SCR losses during running. This improves efficiency and extends SCR life.

## Step-by-Step: Selecting and Sizing a Soft Starter

1. **Determine the motor specifications**: Collect motor HP, FLA, voltage, LRC (locked rotor current as % of FLA), LRT (locked rotor torque as % of full-load torque), and starting time.
2. **Determine the load characteristics**: Identify the load type (centrifugal pump, fan, conveyor, compressor), breakaway torque requirement, and acceleration time.
3. **Calculate the required starting current**: Determine the maximum allowable starting current based on the electrical system capacity (transformer size, available fault current, coordination with other loads).
4. **Select the soft starter size**: Size the soft starter to the motor FLA. Do not oversize — the soft starter must be able to detect and protect the motor at its actual FLA.
5. **Select the starting mode**: Choose voltage ramp for simple applications, current limit for demanding applications, or kick-start for loads with high breakaway torque.
6. **Set the initial voltage**: Start at 30-40% for centrifugal loads, 50-60% for constant torque loads. Adjust based on actual starting performance.
7. **Set the ramp time**: Start with 10-15 seconds for centrifugal loads, 15-30 seconds for high-inertia loads. Adjust based on actual acceleration time.
8. **Set the current limit**: If using current limit mode, set to 200-400% of FLA based on the allowable starting current.
9. **Configure the bypass**: Enable the bypass contactor for running efficiency. Set the bypass to engage when the motor reaches full speed.
10. **Test and commission**: Start the motor and observe the current, voltage, and acceleration. Adjust settings for smooth starting without stalling or excessive current.

## Common Problems

- **Insufficient starting torque**: The initial voltage is set too low, and the motor cannot develop enough torque to start the load. Increase the initial voltage or use kick-start.
- **Motor stalls during ramp**: The ramp time is too long or the load torque exceeds the motor torque at the reduced voltage. Shorten the ramp time or increase the current limit.
- **Excessive starting current**: The current limit is set too high or the initial voltage is too high. Reduce the current limit or initial voltage.
- **Overload trips during starting**: The starting time exceeds the overload relay trip time. Use a Class 30 overload or increase the current limit to reduce starting time.
- **No bypass engagement**: The bypass contactor fails to close, leaving the SCRs in circuit during running, causing overheating and reduced efficiency.

## Best Practices

- Use soft starters for all motors above 50 HP that do not need speed control, to reduce mechanical and electrical stress.
- Always use a bypass contactor for continuous-duty applications to eliminate SCR losses.
- Set the initial voltage as low as possible while still reliably starting the load — this minimizes starting current and mechanical stress.
- Use current limit mode for applications with strict current limitations (weak supply, generator power).
- Use kick-start (pulse start) for loads with high static friction (reciprocating compressors, loaded conveyors).
- Coordinate the soft starter with the motor overload protection — the overload class must accommodate the extended starting time.
- Install the soft starter in a properly ventilated enclosure rated for the ambient temperature.

## Safety

- Soft starters do not provide isolation — a separate disconnecting means is required per NEC 430.102.
- The bypass contactor must be interlocked to prevent closing before the SCRs have ramped to full voltage.
- SCRs can fail shorted — if the soft starter fails, the motor may start across-the-line without warning. Include a monitoring circuit.
- Ensure the enclosure has adequate cooling — soft starters generate significant heat during starting.
- Follow LOTO procedures when servicing — the bypass contactor can energize the motor even if the soft starter is powered off.',
      45, true, true,
      '[
        {"question":"What is the primary function of a soft starter?","options":["To control motor speed during running","To gradually increase voltage during starting, reducing inrush current and mechanical stress","To improve power factor","To protect against overloads"],"correctIndex":1},
        {"question":"What is the purpose of a bypass contactor in a soft starter?","options":["To bypass the motor","To close around the SCRs after starting is complete, eliminating SCR losses during running","To protect the SCRs","To start the motor"],"correctIndex":1},
        {"question":"What is the typical initial voltage setting for a centrifugal pump?","options":["10% of full voltage","30-40% of full voltage","80% of full voltage","100% of full voltage"],"correctIndex":1},
        {"question":"What happens if the initial voltage is set too low?","options":["The motor starts faster","The motor cannot develop enough breakaway torque to start the load","The starting current increases","Nothing happens"],"correctIndex":1},
        {"question":"What is kick-start (pulse start) used for?","options":["To start the motor faster","To provide a short pulse of higher voltage to break static friction on loads like loaded conveyors","To stop the motor","To improve efficiency"],"correctIndex":1},
        {"question":"What overload class should be used for loads with long starting times?","options":["Class 5","Class 10","Class 30","Class 50"],"correctIndex":2},
        {"question":"What can happen if an SCR fails shorted?","options":["The motor stops","The motor may start across-the-line without warning","The soft starter trips","Nothing"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Soft Starter vs VFD: Choosing the Right Solution',
      '## Overview

The choice between a soft starter and a VFD is one of the most common decisions in motor control applications. Both reduce starting current and mechanical stress, but they differ significantly in cost, complexity, and capability. Understanding when to use each is essential for cost-effective and reliable motor control system design.

## Key Concepts

- **Soft starter**: Controls voltage during starting and stopping only. Does not control motor speed during running. Lower cost, simpler, smaller, and more efficient during running (with bypass contactor).
- **VFD**: Controls voltage and frequency continuously, allowing variable speed operation. Higher cost, more complex, larger, and slightly less efficient during running (but can save energy on variable-torque loads).
- **Starting current**: Soft starters reduce starting current to 30-70% of DOL. VFDs can limit starting current to 100-150% of FLA (much lower).
- **Starting torque**: Soft starters reduce starting torque proportionally to the square of the voltage reduction. VFDs can provide full torque at reduced speed and current.
- **Energy savings**: VFDs save energy on variable-torque loads (pumps, fans) by matching speed to demand. Soft starters do not save energy during running (with bypass, they are as efficient as DOL).
- **Cost**: Soft starters are typically 30-50% of the cost of a comparable VFD.

## Step-by-Step: Deciding Between a Soft Starter and a VFD

1. **Determine if speed control is needed**: If the application requires variable speed during operation, a VFD is required. If only soft starting is needed, a soft starter may suffice.
2. **Evaluate the load type**: For variable-torque loads (centrifugal pumps, fans) that can benefit from speed reduction, a VFD provides energy savings. For constant-torque loads (conveyors, compressors), speed control may not save energy.
3. **Assess the starting requirements**: If the motor must start under load (high breakaway torque), a VFD provides better starting torque at lower current. If the motor starts unloaded or lightly loaded, a soft starter is adequate.
4. **Evaluate the electrical system**: If the supply is weak (generator, long cable run, high impedance), a VFD''s lower starting current is advantageous. If the supply is robust, a soft starter''s higher starting current is acceptable.
5. **Consider the stopping requirements**: If controlled deceleration is needed (avoiding water hammer, preventing load runaway), a VFD or soft starter with soft stop is required. If coast-to-stop is acceptable, either works.
6. **Evaluate cost and complexity**: If speed control is not needed and the starting requirements are moderate, a soft starter is more cost-effective and simpler. If speed control or maximum starting torque at minimum current is needed, a VFD is the better choice.
7. **Consider harmonics**: VFDs produce harmonics that may require mitigation (line reactors, filters). Soft starters produce harmonics only during starting (typically not a concern). If harmonics are a concern, a soft starter may be preferable.
8. **Make the decision**: Based on the above analysis, select the solution that meets the requirements at the lowest cost and complexity.

## Common Problems

- **Using a VFD when a soft starter would suffice**: Over-engineering increases cost, complexity, and maintenance requirements. If speed control is not needed, a soft starter is the better choice.
- **Using a soft starter when speed control is needed**: If the process requires variable speed, a soft starter cannot provide it. The motor will run at full speed only.
- **Ignoring harmonic impact of VFDs**: Installing multiple VFDs without harmonic mitigation can cause system-wide power quality problems.
- **Undersizing the soft starter**: A soft starter must be sized to the motor FLA. Undersizing causes overheating and failure.
- **Not using a bypass contactor**: Without a bypass, the soft starter dissipates heat continuously, reducing efficiency and requiring a larger enclosure.

## Best Practices

- Use a soft starter when: speed control is not needed, starting current reduction is the primary goal, cost is a concern, and the supply can handle 30-70% of DOL starting current.
- Use a VFD when: speed control is needed, maximum starting torque at minimum current is required, energy savings on variable-torque loads is a goal, or the supply is weak.
- Always use a bypass contactor on soft starters for continuous-duty applications.
- If using a VFD, include a line reactor (3% minimum) for harmonic mitigation and motor protection.
- Consider a soft starter with built-in bypass for compact installations.
- For critical applications, consider a VFD with bypass — if the VFD fails, the motor can run across-the-line via the bypass.
- Document the decision process and rationale for future reference.

## Safety

- Both soft starters and VFDs require a separate disconnecting means per NEC 430.102.
- VFDs retain charge in the DC bus after power is removed — wait the manufacturer-specified time before servicing.
- Soft starters with bypass contactors can energize the motor even when the soft starter is powered off — follow LOTO procedures.
- VFDs can start the motor unexpectedly if a run command is present — verify the run command is removed before servicing.
- Both devices generate heat — ensure adequate enclosure ventilation and cooling.',
      45, true, true,
      '[
        {"question":"When should a soft starter be used instead of a VFD?","options":["When speed control is needed","When speed control is NOT needed and the primary goal is reducing starting current at lower cost","When energy savings is the primary goal","When the supply is weak"],"correctIndex":1},
        {"question":"What is the main advantage of a VFD over a soft starter?","options":["It is cheaper","It provides variable speed control and can provide full torque at reduced speed and current","It is simpler","It is smaller"],"correctIndex":1},
        {"question":"How much starting current reduction does a VFD typically provide?","options":["30-70% of DOL","100-150% of FLA (much lower than a soft starter)","No reduction","50% of DOL"],"correctIndex":1},
        {"question":"What is the cost comparison between a soft starter and a VFD?","options":["They cost the same","Soft starters are typically 30-50% of the cost of a comparable VFD","VFDs are cheaper","Soft starters are twice as expensive"],"correctIndex":1},
        {"question":"Which device produces harmonics during running (not just starting)?","options":["Soft starter","VFD","Both equally","Neither"],"correctIndex":1},
        {"question":"What should be included with a VFD for harmonic mitigation and motor protection?","options":["A bypass contactor","A line reactor (3% minimum)","A soft starter","Nothing"],"correctIndex":1},
        {"question":"What should be used on a soft starter for continuous-duty applications to eliminate SCR losses?","options":["A larger enclosure","A bypass contactor","A line reactor","Nothing — SCR losses are negligible"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 19: Temporary Power & Construction Electrical — Add Module 3: Temporary Power System Design
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Temporary Power & Construction Electrical' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Temporary Power System Design') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Temporary Power System Design', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Designing Temporary Power Distribution for Construction Sites',
      '## Overview

Designing a temporary power distribution system for a construction site requires balancing safety, functionality, and cost. The system must provide power for tools, lighting, and equipment while complying with OSHA 1926 Subpart K and NEC Article 590. A well-designed temporary power system prevents accidents, reduces downtime, and adapts as the construction project progresses.

## Key Concepts

- **Load assessment**: Calculate the total connected load (tools, lighting, equipment, temporary HVAC) and apply demand factors to determine the required capacity.
- **Voltage selection**: 120V for receptacles and hand tools, 240V for larger tools, 480V for temporary distribution to spider boxes and panels. Match the voltage to the load and distance.
- **Generator vs utility power**: Utility power is preferred when available (cheaper, cleaner, more reliable). Generators are used for remote sites or as backup. Size generators for the total load plus motor starting kVA.
- **GFCI protection**: OSHA requires GFCI on all 120V, 15A and 20A receptacles on construction sites. Use GFCI spider boxes and GFCI breakers in temporary panels.
- **Cable management**: Use Type W or Type SO cable for temporary power. Route cables to avoid trip hazards, damage from vehicles, and exposure to water. Use cable ramps or elevate cables where they cross walkways.

## Step-by-Step: Designing a Construction Site Temporary Power System

1. **Assess the power requirements**: List all tools, equipment, and lighting with their voltage, amperage, and quantity. Calculate the total connected load and apply a demand factor (typically 70% for construction).
2. **Determine the power source**: Check if utility power is available at the site. If not, size a generator for the total demand load plus motor starting kVA (typically 2-3x the largest motor FLA).
3. **Design the distribution system**: From the source (utility transformer or generator), distribute to temporary panels and spider boxes. Use 480V for long-distance distribution, step down to 120/240V at the point of use.
4. **Size the conductors**: Calculate the conductor size based on the load current, distance (voltage drop), and NEC ampacity tables. Keep voltage drop below 5%.
5. **Select GFCI protection**: Install GFCI breakers in all temporary panels and use GFCI spider boxes for all 120V receptacles. Verify GFCI trip threshold is 5mA (Class A).
6. **Plan cable routing**: Route cables along walls, under cable ramps, or elevated on hangers. Avoid running cables through water, across floors where vehicles drive, or in areas where they can be damaged.
7. **Install the system**: Install the temporary service, panels, spider boxes, and cables per the design. Label all panels and spider boxes with their voltage and GFCI rating.
8. **Test the system**: Verify voltage at each receptacle, test all GFCIs with the built-in test button, and verify grounding continuity at each spider box.
9. **Inspect and document**: Perform a daily visual inspection of the temporary power system. Document any defects and correct them immediately.

## Common Problems

- **Undersized generator**: The generator cannot handle the simultaneous load plus motor starting, causing voltage dips and generator stalling. Size for the worst-case starting scenario.
- **Missing GFCI**: A spider box or receptacle without GFCI protection is a serious OSHA violation and shock hazard. Verify GFCI on every 120V receptacle.
- **Cable damage**: Cables run across floors are damaged by vehicles, foot traffic, or sharp objects. Use cable ramps or elevate cables.
- **Voltage drop**: Long cable runs with undersized conductors cause excessive voltage drop, reducing tool performance and potentially damaging equipment.
- **Wet conditions**: Construction sites are wet. Use rain-tight enclosures, elevate connections above grade, and use GFCI on all circuits.
- **Overloaded spider boxes**: Plugging too many tools into one spider box overloads the circuit and trips the breaker. Distribute loads across multiple spider boxes.

## Best Practices

- Use GFCI on all 120V, 15A and 20A receptacles — this is an OSHA requirement, not a recommendation.
- Use Type W cable for temporary power — it is rated for extra-hard service and is oil and water resistant.
- Elevate cables above grade where possible, and use cable ramps where cables cross walkways or roads.
- Install temporary panels in weatherproof enclosures (NEMA 3R or better).
- Label all panels, spider boxes, and cables with voltage, source, and circuit identification.
- Perform daily visual inspections and weekly GFCI tests.
- Plan the system for expansion — as construction progresses, power needs change. Design for flexibility.

## Safety

- All temporary wiring must comply with OSHA 1926 Subpart K and NEC Article 590.
- Never use damaged cables or connectors — replace them immediately.
- De-energize and lock out temporary panels before working on them.
- Keep all electrical connections out of water — elevate above grade and use rain-tight enclosures.
- Test GFCIs daily with the built-in test button before use.
- Ensure all temporary panels and spider boxes are properly grounded.',
      45, true, true,
      '[
        {"question":"What OSHA regulation covers electrical safety on construction sites?","options":["29 CFR 1910","29 CFR 1926 Subpart K","NEC Article 500","NFPA 70E"],"correctIndex":1},
        {"question":"What NEC article covers temporary installations?","options":["Article 500","Article 590","Article 430","Article 250"],"correctIndex":1},
        {"question":"What is the OSHA requirement for GFCI on construction sites?","options":["Recommended only","All 120V, 15A and 20A receptacles must have GFCI protection","Only for outdoor use","Only for wet locations"],"correctIndex":1},
        {"question":"What type of cable is recommended for temporary power?","options":["Romex","Type W or Type SO cable rated for extra-hard service","THHN","Any extension cord"],"correctIndex":1},
        {"question":"How should cables be routed on a construction site?","options":["Across the floor wherever convenient","Along walls, under cable ramps, or elevated on hangers to avoid trip hazards and damage","Through water","Across roads without protection"],"correctIndex":1},
        {"question":"How often should GFCIs be tested on a construction site?","options":["Monthly","Daily with the built-in test button before use","Weekly","Annually"],"correctIndex":1},
        {"question":"What demand factor is typically applied for construction load calculations?","options":["100%","70%","50%","30%"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Generator Power & Load Management for Temporary Installations',
      '## Overview

Generators are the primary power source for many construction sites and temporary installations. Proper sizing, load management, and connection are critical for safe and reliable operation. An undersized generator causes voltage dips and stalling; an improperly connected generator creates backfeed hazards. Understanding generator sizing and load management is essential for anyone responsible for temporary power.

## Key Concepts

- **Generator sizing**: The generator must supply the continuous load plus the starting (inrush) current of motors. Motor starting kVA is typically 2-3 times the running kVA for each motor.
- **Power factor**: Generators are rated in kVA. To convert to kW, multiply by the power factor (typically 0.8 for industrial loads). Ensure the generator kW rating exceeds the load kW.
- **Load sequencing**: Starting the largest motor first, then progressively smaller motors, reduces the peak demand on the generator. This is essential when multiple motors are on one generator.
- **Neutral and grounding**: Portable generators require proper grounding per NEC 250.34. The neutral may be bonded to the frame or floating, depending on the generator design and application.
- **Transfer switches**: When both utility and generator power are available, a transfer switch is required to prevent backfeed. Automatic transfer switches (ATS) switch automatically; manual transfer switches require operator action.

## Step-by-Step: Sizing and Setting Up a Generator for Temporary Power

1. **Calculate the continuous load**: Sum the running kW of all loads that will operate simultaneously. Include tools, lighting, and HVAC.
2. **Calculate the motor starting load**: For each motor, calculate the starting kVA (typically 2-3x running kVA). The largest motor starting determines the peak demand.
3. **Determine the generator size**: The generator kW must exceed the continuous load, and the generator kVA must exceed the peak starting kVA. Add 20% margin for future loads and generator derating at altitude or high temperature.
4. **Select the generator type**: Diesel generators are most common for construction (durable, fuel-efficient). Natural gas or propane generators are used where fuel supply is available. Inverter generators are used for sensitive electronic equipment.
5. **Plan the grounding**: Per NEC 250.34, ground the generator frame to a ground rod or building steel. If the generator supplies a panel, bond the neutral per the generator manufacturer''s instructions.
6. **Plan the load connection**: Connect the generator to a temporary panel or spider boxes using properly sized cable. Ensure all connections are weatherproof.
7. **Sequence the loads**: If multiple motors are on the generator, start the largest first, then progressively smaller ones. This minimizes the peak demand.
8. **Test the system**: Start the generator, verify voltage and frequency at the panel, and start loads in sequence. Monitor generator voltage and frequency during starting — voltage should not dip below 90% and frequency should not drop below 58 Hz.
9. **Set up fuel management**: Calculate fuel consumption at the expected load and arrange for refueling. Install fuel level alarms for unattended operation.

## Common Problems

- **Undersized generator**: The generator cannot handle motor starting, causing voltage dips that trip equipment or stall the generator. Size for the worst-case starting scenario.
- **Backfeed**: Connecting a generator without a transfer switch backfeeds the utility lines, endangering utility workers. Always use a transfer switch or isolate the load from the utility.
- **Improper grounding**: Not grounding the generator frame creates a shock hazard. Ground per NEC 250.34.
- **Fuel starvation**: Running out of fuel during operation causes sudden power loss. Monitor fuel level and refuel before the tank is empty.
- **Wet stacking**: Diesel generators operated at very light loads (below 30%) develop carbon deposits (wet stacking) that reduce performance and damage the engine. Load the generator to at least 30% of rated capacity.

## Best Practices

- Size the generator for the continuous load plus the largest motor starting kVA, plus 20% margin.
- Use diesel generators for construction applications — they are more durable and fuel-efficient.
- Install a transfer switch whenever both utility and generator power are available.
- Ground the generator frame per NEC 250.34 and the manufacturer''s instructions.
- Sequence motor starts to minimize peak demand — largest motor first.
- Load diesel generators to at least 30% to prevent wet stacking.
- Install fuel level monitoring and alarms for unattended operation.
- Perform regular maintenance (oil changes, filter changes) per the manufacturer''s schedule.

## Safety

- Never connect a generator to a building electrical system without a transfer switch — backfeed kills utility workers.
- Ground the generator frame to protect against shock.
- Never operate a generator indoors or in an enclosed space — carbon monoxide is deadly.
- Use properly rated cable and connectors for the generator output.
- Keep fuel away from ignition sources and follow fuel storage regulations.
- De-energize the generator and lock out before servicing.',
      45, true, true,
      '[
        {"question":"How is motor starting kVA typically estimated for generator sizing?","options":["Equal to running kVA","2-3 times the running kVA for each motor","10 times running kVA","Half the running kVA"],"correctIndex":1},
        {"question":"What is backfeed and why is it dangerous?","options":["It improves generator performance","Connecting a generator without a transfer switch energizes utility lines, endangering utility workers","It reduces fuel consumption","It improves power quality"],"correctIndex":1},
        {"question":"What NEC section covers grounding for portable generators?","options":["NEC 250.34","NEC 430.102","NEC 590.4","NEC 500.5"],"correctIndex":0},
        {"question":"What is wet stacking in diesel generators?","options":["A type of fuel","Carbon deposits from operating at light loads (below 30%), reducing performance and damaging the engine","A cooling system problem","An electrical fault"],"correctIndex":1},
        {"question":"How should multiple motors be started on a single generator?","options":["All simultaneously","Start the largest first, then progressively smaller ones to minimize peak demand","Start the smallest first","In any order"],"correctIndex":1},
        {"question":"What margin should be added to the calculated generator size?","options":["5%","20% for future loads and derating at altitude/temperature","50%","100%"],"correctIndex":1},
        {"question":"Why must generators never be operated indoors?","options":["They are too noisy","Carbon monoxide is deadly","They overheat","They are too large"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 20: Testing & Commissioning of Electrical Equipment — Add Module 3: Field Commissioning & Hand-off
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Testing & Commissioning of Electrical Equipment' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Field Commissioning & Hand-off') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Field Commissioning & Hand-off', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Commissioning Process & Pre-Energization Checks',
      '## Overview

Commissioning is the systematic process of verifying that electrical equipment is installed correctly, functions as designed, and is ready for energization and operation. It begins after installation is complete and before the equipment is energized. A thorough commissioning process prevents equipment damage, safety incidents, and operational problems that result from installation errors.

## Key Concepts

- **Commissioning vs testing**: Testing verifies individual components; commissioning verifies the complete system. Commissioning includes testing plus functional verification, interlock checks, and documentation.
- **Pre-energization checks**: Visual inspections, mechanical verification, continuity checks, insulation tests, and protective device verification performed before energizing.
- **Energization sequence**: A planned, step-by-step sequence for energizing equipment, starting from the source and working downstream. Each step is verified before proceeding to the next.
- **Interlock and protection verification**: Testing that safety interlocks, protective relays, and emergency stops function correctly before the system is placed in operation.
- **Commissioning documentation**: A complete record of all tests, settings, and verifications, forming the baseline for future maintenance.

## Step-by-Step: Commissioning a New Electrical Installation

1. **Review the design and installation**: Compare the installed equipment to the design drawings. Verify all components are installed per the drawings and manufacturer instructions.
2. **Perform visual inspection**: Check for physical damage, missing components, loose connections, incorrect wire sizes, and code compliance issues. Document any deficiencies.
3. **Perform mechanical verification**: Verify all bolts, lugs, and terminations are torqued to manufacturer specifications. Check that breakers and switches operate mechanically (open and close freely).
4. **Perform continuity and point-to-point verification**: Verify every wire is connected to the correct terminal, with no opens or shorts. Use a continuity tester or DLRO.
5. **Perform insulation resistance testing**: Megger all conductors to ground and to each other. Verify readings meet IEEE 43 minimums.
6. **Verify protective device settings**: Check that all breaker trip settings, fuse ratings, and relay settings match the coordination study. Verify CT and VT ratios and polarities.
7. **Test interlocks and safety circuits**: Verify that safety interlocks prevent unsafe operations (e.g., breaker cannot close with the earthing switch closed). Test emergency stop circuits.
8. **Perform control circuit functional test**: Energize the control circuit (without power circuit) and verify that all control devices operate correctly per the design logic.
9. **Plan the energization sequence**: Document the step-by-step sequence for energizing, starting from the source. Include verification steps between each energization step.
10. **Conduct a pre-energization review meeting**: Review all test results, resolve any deficiencies, and confirm that all personnel are briefed on the energization plan and safety procedures.

## Common Problems

- **Skipping pre-energization checks**: Energizing without verification leads to equipment damage from miswires, insulation failures, or incorrect settings.
- **Incomplete documentation**: Missing test records make future maintenance difficult and may violate commissioning requirements.
- **Incorrect protective device settings**: Breakers or relays set wrong can fail to clear faults or nuisance-trip. Verify against the coordination study.
- **Missing interlock testing**: Safety interlocks that are not tested may not function when needed, creating a safety hazard.
- **Rushing the process**: Time pressure leads to skipped steps and overlooked defects. Plan adequate time for commissioning.

## Best Practices

- Use a commissioning checklist that covers every component and test.
- Document every test result, including pass/fail and measured values.
- Verify all torque values with a calibrated torque wrench — do not "feel" the torque.
- Test every interlock and safety circuit — do not assume they work.
- Have a second person verify critical tests (insulation resistance, protective device settings).
- Conduct a pre-energization review meeting with all stakeholders before energizing.
- Plan the energization sequence in advance and follow it step by step.
- Keep the commissioning documentation as the baseline for future maintenance.

## Safety

- Never energize equipment that has not passed all pre-energization checks.
- All commissioning tests on de-energized equipment require LOTO procedures.
- When energizing, follow the planned sequence and verify each step before proceeding.
- Wear appropriate PPE during energization — the first energization is when undiscovered faults are most likely to manifest.
- Ensure all personnel are clear of the equipment before energizing.
- Have emergency response procedures in place before energizing, including the location of the nearest disconnect and fire extinguisher.',
      50, true, true,
      '[
        {"question":"What is the difference between testing and commissioning?","options":["There is no difference","Testing verifies individual components; commissioning verifies the complete system including functional verification, interlocks, and documentation","Commissioning is simpler","Testing is more thorough"],"correctIndex":1},
        {"question":"What is performed during pre-energization checks?","options":["Only visual inspection","Visual inspection, mechanical verification, continuity checks, insulation tests, and protective device verification","Only insulation testing","Only torque verification"],"correctIndex":1},
        {"question":"What is the energization sequence?","options":["Random order","A planned, step-by-step sequence starting from the source and working downstream, with verification at each step","From downstream to upstream","All at once"],"correctIndex":1},
        {"question":"What must be verified for protective devices before energizing?","options":["Nothing","All breaker trip settings, fuse ratings, and relay settings match the coordination study, and CT/VT ratios and polarities are correct","Only the main breaker","Only the fuses"],"correctIndex":1},
        {"question":"What should be done with interlocks and safety circuits?","options":["Skip them to save time","Test every interlock and safety circuit — do not assume they work","Test only the main interlock","Test them after energizing"],"correctIndex":1},
        {"question":"What should be conducted before energizing?","options":["Nothing","A pre-energization review meeting with all stakeholders to review test results and confirm the energization plan","A cost analysis","A training session"],"correctIndex":1},
        {"question":"What PPE should be worn during the first energization?","options":["None — it is safe","Appropriate PPE, as undiscovered faults are most likely to manifest during first energization","Just safety glasses","Just gloves"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Commissioning Documentation & Hand-off Procedures',
      '## Overview

The commissioning hand-off is the formal transfer of a commissioned system from the construction/commissioning team to the operations and maintenance team. It includes all documentation, test results, settings, drawings, and training necessary for the O&M team to operate and maintain the system. A well-executed hand-off ensures continuity and prevents the loss of knowledge that often occurs at project completion.

## Key Concepts

- **Commissioning report**: A comprehensive document that records all tests performed, results, settings, and any deviations from the design. It is the baseline for future maintenance.
- **As-built drawings**: The final drawings reflecting all field modifications, updated from the design drawings.
- **Settings sheet**: A document listing all protective device settings, relay configurations, and alarm thresholds.
- **O&M manuals**: Operating and maintenance manuals from equipment manufacturers, compiled into a system-specific document.
- **Spare parts list**: A list of recommended spare parts with part numbers, quantities, and storage locations.
- **Training records**: Documentation of training provided to O&M personnel, including content, dates, and attendees.

## Step-by-Step: Preparing a Commissioning Hand-off Package

1. **Compile the commissioning report**: Gather all test results, inspection reports, and commissioning checklists. Organize by equipment and system.
2. **Update as-built drawings**: Transfer all field modifications to the final CAD drawings. Include red-line markups and photos.
3. **Create the settings sheet**: Document all breaker trip settings, relay configurations, alarm thresholds, and communication addresses.
4. **Compile O&M manuals**: Gather manufacturer manuals for all equipment. Add system-specific operating procedures and maintenance schedules.
5. **Create the spare parts list**: Identify critical spare parts (relays, fuses, contactors, coils) and list part numbers, quantities, and recommended stock levels.
6. **Document the single-line diagram**: Create or update the single-line diagram with all equipment ratings, settings, and protection schemes.
7. **Prepare the training materials**: Develop training materials covering system operation, maintenance procedures, safety, and emergency response.
8. **Conduct training**: Provide training to O&M personnel. Include classroom instruction and hands-on demonstration. Document attendance and content.
9. **Conduct the hand-off meeting**: Formally transfer the documentation and system responsibility. Have both the commissioning team and O&M team sign the hand-off form.
10. **Archive the documentation**: Store all commissioning documentation in a controlled location (physical and electronic). Ensure the O&M team knows where it is.

## Common Problems

- **Missing or incomplete documentation**: The most common hand-off failure. Without complete documentation, the O&M team cannot effectively maintain the system.
- **No training**: The O&M team is expected to operate and maintain a system they were never trained on. This leads to errors and safety hazards.
- **Outdated drawings**: The as-built drawings do not reflect field modifications, making future troubleshooting difficult.
- **No spare parts list**: When a component fails, the O&M team does not know the part number or where to get a replacement, causing extended downtime.
- **No formal hand-off**: The commissioning team leaves without a formal transfer, and knowledge is lost.

## Best Practices

- Start the hand-off package early — do not wait until the project is over to compile documentation.
- Use a standardized hand-off checklist to ensure nothing is missed.
- Include photos of the installation, especially panel interiors and cable routing.
- Provide both electronic and hard copies of all documentation.
- Conduct hands-on training, not just classroom — O&M personnel need to touch the equipment.
- Have both teams sign a formal hand-off document acknowledging the transfer.
- Store the documentation in a known, accessible location and inform the O&M team.
- Schedule a follow-up review 30-60 days after hand-off to address any issues.

## Safety

- The hand-off documentation must include all safety procedures, interlock descriptions, and emergency response plans.
- Training must cover safety hazards, PPE requirements, and LOTO procedures specific to the system.
- The O&M team must understand the protective device settings and the consequences of changing them.
- The as-built drawings must accurately reflect the installation — incorrect drawings create safety hazards during future maintenance.
- The spare parts list must include safety-critical components (fuses, relays, overload relays) to ensure rapid repair of safety functions.',
      40, true, true,
      '[
        {"question":"What is a commissioning report?","options":["A cost report","A comprehensive document recording all tests, results, settings, and deviations — the baseline for future maintenance","A training manual","A project schedule"],"correctIndex":1},
        {"question":"What must be included in the hand-off package?","options":["Only the commissioning report","Commissioning report, as-built drawings, settings sheet, O&M manuals, spare parts list, and training records","Only the drawings","Only the spare parts list"],"correctIndex":1},
        {"question":"What should training include?","options":["Only classroom instruction","Both classroom instruction and hands-on demonstration with the equipment","Only reading the manual","Only a video"],"correctIndex":1},
        {"question":"What is the most common hand-off failure?","options":["Missing training","Missing or incomplete documentation","No spare parts","No formal meeting"],"correctIndex":1},
        {"question":"What should be done with the as-built drawings?","options":["Keep the original design drawings","Transfer all field modifications to the final CAD drawings","Discard them","File them without updating"],"correctIndex":1},
        {"question":"What should the spare parts list include?","options":["Only expensive parts","Critical spare parts with part numbers, quantities, and recommended stock levels, including safety-critical components","Only common parts","No spare parts"],"correctIndex":1},
        {"question":"What should be scheduled after the hand-off?","options":["Nothing","A follow-up review 30-60 days after hand-off to address any issues","A new project","A training session"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 21: UPS Systems, Batteries & Backup Power — Add Module 3: UPS System Design & Maintenance
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'UPS Systems, Batteries & Backup Power' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'UPS System Design & Maintenance') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'UPS System Design & Maintenance', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'UPS System Sizing & Configuration',
      '## Overview

Proper UPS system sizing and configuration is critical for ensuring that critical loads remain powered during utility outages. An undersized UPS cannot support the load; an oversized UPS wastes money and energy. The configuration (single UPS, redundant, or parallel) determines the system reliability. Understanding sizing methodology and configuration options is essential for designing reliable backup power systems.

## Key Concepts

- **Load assessment**: Identify all critical loads that must remain powered, including their voltage, current, power factor, and inrush requirements. Include future growth (typically 20% margin).
- **UPS sizing (kVA and kW)**: The UPS kVA must exceed the total load kVA. The UPS kW must exceed the total load kW (accounting for power factor). Most UPS systems are rated at 0.8-0.9 PF.
- **Battery sizing (runtime)**: The battery must support the load for the required runtime (typically 5-15 minutes for generator transfer, or longer for standalone operation). Battery size depends on load, runtime, and temperature.
- **Redundancy configurations**: N+1 (one extra module for redundancy), 2N (two complete systems), or parallel (multiple modules sharing the load). Higher redundancy = higher reliability but higher cost.
- **Bypass options**: A maintenance bypass allows the UPS to be taken offline for maintenance while the load remains powered. An automatic bypass transfers the load to utility if the UPS fails.

## Step-by-Step: Sizing and Configuring a UPS System

1. **Identify the critical loads**: List all equipment that must remain powered, including servers, PLCs, communication equipment, and safety systems. Note their voltage, wattage, and power factor.
2. **Calculate the total load**: Sum the kW and kVA of all critical loads. Apply a diversity factor if not all loads run simultaneously (typically 0.8-1.0).
3. **Add growth margin**: Add 20% for future growth. This gives the minimum UPS rating.
4. **Select the UPS topology**: Online (double conversion) for critical loads requiring clean power. Line-interactive for moderate loads with voltage regulation needs. Standby for non-critical loads.
5. **Determine the required runtime**: How long must the UPS support the load? 5-15 minutes for generator transfer. 30+ minutes for standalone operation.
6. **Size the battery**: Based on the load kW, runtime, and end-of-discharge voltage. Use the battery manufacturer''s sizing tables or software. Add temperature derating (battery capacity decreases at low temperatures).
7. **Select the redundancy configuration**: N+1 for moderate redundancy. 2N for critical applications. Parallel for large loads requiring multiple modules.
8. **Plan the bypass**: Include a maintenance bypass switch for UPS maintenance. Configure the automatic bypass for UPS failure.
9. **Design the installation**: Plan the UPS location (temperature-controlled, ventilated room), battery rack, cable routing, and grounding. Ensure the floor can support the weight of the UPS and batteries.
10. **Document the design**: Create a one-line diagram, load list, battery sizing calculation, and installation drawings.

## Common Problems

- **Undersized UPS**: The UPS cannot support the actual load, causing overload trips or insufficient runtime. Always size with margin.
- **Insufficient runtime**: The battery is too small for the required runtime. Recalculate with actual load and temperature derating.
- **High temperature reducing battery life**: Batteries in hot environments (above 25°C/77°F) have significantly reduced life. Install in a temperature-controlled room.
- **No maintenance bypass**: The UPS cannot be taken offline for maintenance without shutting down the load. Always include a maintenance bypass.
- **Overlooked inrush**: Motor loads or power supplies with high inrush can overload the UPS. Size for inrush, not just running load.
- **Single point of failure**: A single UPS with no redundancy is a single point of failure. Use N+1 or 2N for critical applications.

## Best Practices

- Size the UPS to 120% of the actual load to allow for growth and prevent overload.
- Use online (double conversion) UPS for critical loads — it provides the cleanest power.
- Install batteries in a temperature-controlled room at 25°C (77°F) for maximum life.
- Include a maintenance bypass switch for all UPS installations.
- Use N+1 redundancy for critical applications — one additional module handles the failure of any single module.
- Size the battery for the actual load, not the UPS rating — an oversized UPS with an undersized battery has insufficient runtime.
- Perform a load test after installation to verify the UPS and battery can support the actual load for the required runtime.
- Plan for battery replacement — VRLA batteries typically need replacement every 3-5 years.

## Safety

- UPS batteries contain lead and sulfuric acid — follow environmental and safety procedures for handling and disposal.
- Battery strings have high DC voltage (potentially lethal) — never touch battery terminals without proper PPE.
- The UPS bypass can energize the load from utility power — follow LOTO procedures when servicing.
- Battery rooms must be ventilated to prevent hydrogen gas accumulation (for flooded batteries).
- Do not install UPS equipment in wet or hazardous locations unless specifically rated.
- Ensure the UPS installation meets all local electrical codes and fire codes.',
      50, true, true,
      '[
        {"question":"What margin should be added when sizing a UPS?","options":["5%","20% for future growth","50%","100%"],"correctIndex":1},
        {"question":"Which UPS topology provides the cleanest power?","options":["Standby (offline)","Online (double conversion)","Line-interactive","All are equal"],"correctIndex":1},
        {"question":"What is N+1 redundancy?","options":["No redundancy","One additional module beyond what is needed, so the failure of any single module is covered","Two complete systems","Parallel operation"],"correctIndex":1},
        {"question":"What is the typical runtime for a UPS designed for generator transfer?","options":["1 minute","5-15 minutes","60 minutes","4 hours"],"correctIndex":1},
        {"question":"What is the recommended battery room temperature for maximum battery life?","options":["10°C (50°F)","25°C (77°F)","35°C (95°F)","Any temperature"],"correctIndex":1},
        {"question":"What must be included in all UPS installations for maintenance?","options":["A larger battery","A maintenance bypass switch","A second UPS","An automatic transfer switch"],"correctIndex":1},
        {"question":"How often do VRLA batteries typically need replacement?","options":["Every year","Every 3-5 years","Every 10 years","Every 20 years"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'UPS Maintenance & Battery Replacement Programs',
      '## Overview

UPS maintenance is critical for ensuring that the backup power system works when needed. UPS systems that are not maintained may appear functional but fail during an actual power outage. Battery maintenance is the most critical aspect — batteries degrade over time and can fail without warning. A structured maintenance program with regular testing, monitoring, and planned replacement is essential for reliable UPS operation.

## Key Concepts

- **Preventive maintenance schedule**: Regular, scheduled maintenance including visual inspection, battery testing, electrical measurements, and functional tests. Typically performed semi-annually or quarterly.
- **Battery monitoring systems**: Permanently installed systems that continuously monitor battery voltage, internal resistance, and temperature, providing early warning of battery degradation.
- **Impedance/conductance testing**: A non-invasive test that measures battery internal resistance. Increasing resistance indicates degradation and predicts failure.
- **Load (capacity) testing**: Discharging the battery string to verify it can support the load for the required runtime. The most definitive test of battery health.
- **Battery replacement planning**: Tracking battery age and test results to plan replacement before failure. VRLA batteries typically need replacement every 3-5 years.

## Step-by-Step: Performing UPS Preventive Maintenance

1. **Visual inspection**: Inspect the UPS and battery installation for physical damage, leaks (battery cases), dust accumulation, and ventilation. Check that all fans are operating.
2. **Check the environment**: Verify the room temperature is at 25°C (77°F) and humidity is within the UPS manufacturer''s specification. Check ventilation and air conditioning.
3. **Measure battery float voltage**: Measure the float voltage of each battery cell or monoblock. Compare to the manufacturer''s specification. Any cell more than 0.05V below specification may be failing.
4. **Perform impedance or conductance testing**: Use a battery impedance tester to measure each battery''s internal resistance. Compare to baseline and trend over time. A 20-30% increase from baseline indicates a failing battery.
5. **Check battery ripple voltage**: Measure AC ripple voltage across the battery string. Excessive ripple (above 0.5% of float voltage) indicates a failing UPS rectifier or filter capacitor and can reduce battery life.
6. **Verify UPS alarms and indicators**: Test the UPS alarm indicators (battery low, overload, fault) and verify they function correctly. Check the UPS event log for any recorded events.
7. **Perform a load test**: If scheduled, perform a capacity (load) test by disconnecting the utility and verifying the UPS supports the load on battery for the required runtime.
8. **Clean the UPS**: Remove dust from the UPS interior and fans using compressed air or a vacuum. Dust accumulation reduces cooling and can cause component failure.
9. **Document all results**: Record all measurements, test results, and observations. Compare to previous readings and trend the data.
10. **Plan battery replacement**: Based on battery age, test results, and trend data, plan battery replacement before the batteries fail. Order replacement batteries and schedule the replacement.

## Common Problems

- **Battery failure without warning**: VRLA batteries can fail suddenly without prior indication. Impedance testing and continuous monitoring help predict failures, but load testing is the only definitive test.
- **High ambient temperature**: Batteries in hot environments age rapidly. Every 8°C (15°F) above 25°C halves the battery life. Temperature control is essential.
- **Excessive ripple voltage**: A failing UPS rectifier or filter capacitor causes AC ripple on the DC bus, reducing battery life and indicating UPS component degradation.
- **Uneven battery aging**: In a battery string, one or two batteries may fail before the rest, causing the entire string to fail. Individual battery monitoring identifies weak cells.
- **No maintenance records**: Without trend data, it is impossible to predict battery failure or plan replacement. Maintain detailed records of all tests.

## Best Practices

- Perform preventive maintenance semi-annually at minimum, quarterly for critical applications.
- Use a battery monitoring system for continuous surveillance of battery health.
- Perform impedance testing at every maintenance visit and trend the results.
- Perform a full load test annually to verify battery capacity.
- Replace batteries based on age (3-5 years for VRLA) and test results, not just on failure.
- Replace the entire battery string, not individual batteries, when the string reaches end of life — mixing old and new batteries causes uneven charging.
- Keep the battery room at 25°C (77°F) for maximum battery life.
- Document all maintenance and test results for trending and warranty claims.

## Safety

- Battery strings have high DC voltage (potentially lethal) — use insulated tools and wear PPE when working on batteries.
- Short-circuiting a battery terminal can cause severe burns and fire — use insulated tools and remove jewelry.
- Flooded batteries produce hydrogen gas — ensure ventilation and no sparks or open flames.
- Battery acid is corrosive — wear acid-resistant gloves and face shield, and have an eyewash station nearby.
- When load testing, be prepared for the UPS to fail — have a backup power source or maintenance bypass available.
- Dispose of batteries per environmental regulations — lead-acid batteries are hazardous waste.',
      45, true, true,
      '[
        {"question":"How often should UPS preventive maintenance be performed?","options":["Only when the UPS fails","Semi-annually at minimum, quarterly for critical applications","Every 5 years","Annually"],"correctIndex":1},
        {"question":"What is the most definitive test of battery health?","options":["Voltage measurement","Load (capacity) testing by discharging the battery string","Visual inspection","Temperature measurement"],"correctIndex":1},
        {"question":"What does impedance or conductance testing measure?","options":["Battery voltage","Battery internal resistance — increasing resistance indicates degradation","Battery temperature","Battery current"],"correctIndex":1},
        {"question":"How much does battery life decrease for every 8°C (15°F) above 25°C (77°F)?","options":["No effect","Battery life is halved","Battery life is reduced by 10%","Battery life is reduced by 25%"],"correctIndex":1},
        {"question":"What does excessive AC ripple voltage on the battery indicate?","options":["Normal operation","A failing UPS rectifier or filter capacitor","Battery failure","High ambient temperature"],"correctIndex":1},
        {"question":"When replacing batteries, should individual batteries or the entire string be replaced?","options":["Individual batteries as they fail","The entire string — mixing old and new batteries causes uneven charging","Only the failed ones","It does not matter"],"correctIndex":1},
        {"question":"What is the typical replacement interval for VRLA batteries?","options":["Every year","Every 3-5 years","Every 10 years","Every 20 years"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 22: Variable Frequency Drive Installation & Commissioning — Add Module 3: VFD Troubleshooting & Maintenance
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Variable Frequency Drive Installation & Commissioning' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'VFD Troubleshooting & Maintenance') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'VFD Troubleshooting & Maintenance', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'VFD Fault Diagnosis & Troubleshooting',
      '## Overview

VFD troubleshooting requires a systematic approach that combines knowledge of VFD theory, the specific drive''s fault codes, and the ability to interpret the drive''s event log. VFDs provide extensive diagnostic information through fault codes, alarm logs, and parameter monitoring. Understanding how to read and interpret this information is essential for rapid and accurate troubleshooting.

## Key Concepts

- **Fault codes**: VFDs display specific fault codes that identify the type of fault (overcurrent, overvoltage, overheating, ground fault, phase loss). Each manufacturer has their own code system.
- **Event log**: Most VFDs maintain an event log that records the last several faults and alarms with timestamps, operating conditions (speed, current, voltage), and fault details.
- **Fault categories**: Electrical faults (overcurrent, overvoltage, undervoltage, ground fault, phase loss), thermal faults (heatsink overtemperature, motor overload), and mechanical faults (overspeed, stall, loss of load).
- **Troubleshooting sequence**: Always start with the fault code and event log, then verify the operating conditions, inspect the physical installation, and test components.
- **Parameter review**: Incorrect parameters (motor FLA, V/Hz mode, acceleration time, current limit) can cause faults that appear to be hardware problems.

## Step-by-Step: Troubleshooting a VFD Fault

1. **Read the fault code**: Note the fault code displayed on the VFD keypad or communicated via the network. Look up the code in the manufacturer''s manual.
2. **Review the event log**: Access the event log and note the fault type, timestamp, and operating conditions at the time of the fault (output frequency, current, voltage, DC bus voltage).
3. **Categorize the fault**: Determine if the fault is electrical (overcurrent, overvoltage, ground fault), thermal (overheating, overload), or mechanical (overspeed, stall).
4. **Check for obvious causes**: Inspect the installation for obvious problems — loose connections, damaged motor cable, water in the junction box, blocked ventilation.
5. **Verify motor and cable**: Megger the motor and cable to check for insulation breakdown. Check for shorted windings or ground faults.
6. **Verify input power**: Measure the three-phase input voltage. Check for phase loss, voltage unbalance, or low voltage.
7. **Review parameters**: Verify motor nameplate parameters (FLA, voltage, frequency), control mode (V/Hz, sensorless vector), and protection settings (current limit, overload class).
8. **Check the load**: Is the load jammed or oversized? Does the load require more torque than the motor can provide at the current speed?
9. **Clear the fault and test**: After identifying and correcting the cause, clear the fault and run the VFD under controlled conditions to verify the fault does not recur.
10. **Document the fault and resolution**: Record the fault code, root cause, corrective action, and any parameter changes. This builds a troubleshooting knowledge base.

## Common Problems

- **Overcurrent (OC)**: Caused by short circuits in the motor or cable, sudden load changes, or acceleration time too short. Check motor and cable insulation, increase acceleration time.
- **DC bus overvoltage (OV)**: Caused by regenerative energy during deceleration. Increase deceleration time, add a braking resistor, or enable overvoltage suppression.
- **Undervoltage (UV)**: Caused by input voltage sag or momentary power loss. Check input voltage, add a UPS, or enable ride-through (power loss) parameter.
- **Overload (OL)**: Caused by the motor drawing more than FLA for an extended period. Check for jammed load, undersized motor, or incorrect FLA parameter.
- **Ground fault (GF)**: Caused by insulation breakdown in the motor or output cable. Megger the motor and cable to locate the fault.
- **Heatsink overtemperature (OH)**: Caused by blocked ventilation, high ambient temperature, or oversized carrier frequency. Clean filters, reduce ambient, or reduce carrier frequency.
- **Phase loss (PHL)**: Caused by a missing input phase. Check input connections and voltage.

## Best Practices

- Always start with the fault code and event log — the VFD tells you what is wrong.
- Keep the manufacturer''s manual on hand for fault code interpretation.
- Verify motor and cable insulation before resetting an overcurrent or ground fault.
- Trend VFD operating data (current, voltage, DC bus voltage, temperature) for predictive maintenance.
- Document all faults and resolutions to build a troubleshooting knowledge base.
- Use the VFD''s built-in diagnostic tools (oscilloscope function, data logger) if available.
- Train operators to record the fault code and operating conditions before resetting.

## Safety

- VFD DC bus capacitors retain charge after power is removed — wait the manufacturer-specified time (typically 5-10 minutes) before opening the drive.
- Never reset a fault without investigating the cause — the fault will recur and may cause damage.
- When meggering the motor, disconnect the motor from the VFD — megger voltage can damage the VFD output IGBTs.
- Use properly rated test instruments — VFD output voltage is PWM, not sinusoidal. Use a true RMS meter or a meter designed for VFD measurements.
- Follow LOTO procedures when servicing the VFD or motor.',
      50, true, true,
      '[
        {"question":"What is the first step in VFD troubleshooting?","options":["Replace the VFD","Read the fault code and review the event log","Check the motor","Reset the fault"],"correctIndex":1},
        {"question":"What is the most common cause of a DC bus overvoltage fault?","options":["Low input voltage","Regenerative energy during deceleration","Shorted motor winding","High ambient temperature"],"correctIndex":1},
        {"question":"What is the most common cause of an overcurrent fault?","options":["Low carrier frequency","A short in the motor or output cable, or acceleration time too short","Excessive ramp time","Low input voltage"],"correctIndex":1},
        {"question":"What should be done before resetting a ground fault?","options":["Just reset it","Megger the motor and cable to locate the insulation breakdown","Increase the current limit","Replace the VFD"],"correctIndex":1},
        {"question":"Why must the motor be disconnected from the VFD before meggering?","options":["For accuracy","Megger voltage can damage the VFD output IGBTs","It is not necessary","To save time"],"correctIndex":1},
        {"question":"How long should you wait after removing power before opening a VFD?","options":["10 seconds","The manufacturer-specified time (typically 5-10 minutes) for DC bus capacitor discharge","1 minute","No wait is needed"],"correctIndex":1},
        {"question":"What type of meter should be used for VFD output measurements?","options":["An average-responding meter","A true RMS meter or a meter designed for VFD PWM measurements","Any multimeter","A clamp meter only"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'VFD Preventive Maintenance & Long-Term Care',
      '## Overview

VFD preventive maintenance extends the life of the drive, prevents unexpected failures, and maintains optimal performance. While VFDs are generally reliable, they contain electrolytic capacitors, cooling fans, and semiconductor devices that degrade over time. A structured maintenance program addresses these wear components before they cause failures. Understanding VFD maintenance requirements is essential for anyone responsible for drive reliability.

## Key Concepts

- **Electrolytic capacitor degradation**: The DC bus capacitors degrade over time and with temperature. Typical life is 7-10 years at rated temperature, less at elevated temperatures. Degradation reduces capacitance and increases ESR, leading to higher DC bus ripple and eventual failure.
- **Cooling fan wear**: VFD cooling fans have a typical life of 3-5 years. Fan failure leads to overheating and drive failure. Fans should be replaced proactively, not after failure.
- **Dust and contamination**: Dust accumulation on the heatsink reduces cooling efficiency and can cause overheating. In industrial environments, dust can also be conductive, causing tracking faults.
- **Terminal and connection degradation**: Thermal cycling loosens power and control terminals over time. Loose connections cause overheating and eventual failure.
- **Firmware updates**: Manufacturers release firmware updates that fix bugs, improve performance, and add features. Keeping firmware current prevents known issues.

## Step-by-Step: Performing VFD Preventive Maintenance

1. **De-energize and lock out the VFD**: Follow LOTO procedures. Wait the manufacturer-specified time (typically 5-10 minutes) for DC bus capacitor discharge.
2. **Visual inspection**: Inspect the VFD interior for dust accumulation, discoloration (indicating overheating), bulging or leaking capacitors, and corroded or discolored terminals.
3. **Clean the heatsink**: Use compressed air or a vacuum to remove dust from the heatsink fins. Ensure the airflow path is clear. Do not use high-pressure air that can damage components.
4. **Check the cooling fan**: Spin the fan by hand — it should rotate freely without noise. If the fan is noisy, stiff, or does not rotate freely, replace it. Check the fan for dust accumulation and clean if necessary.
5. **Inspect and re-torque terminals**: Check all power and control terminals for looseness and discoloration. Re-torque power terminals to the manufacturer''s specification using a torque screwdriver or wrench.
6. **Inspect capacitors**: Look for bulging, leaking, or venting on the electrolytic capacitors. If any capacitor shows signs of degradation, plan for drive or capacitor replacement.
7. **Check the enclosure environment**: Verify the enclosure temperature is within the VFD rating (typically 40-50°C). Check enclosure ventilation, filters, and air conditioning.
8. **Verify firmware version**: Check the VFD firmware version against the manufacturer''s latest release. If an update is available, evaluate whether to apply it (considering the risk of update-related issues).
9. **Back up parameters**: Download all VFD parameters to a computer or storage device. This ensures parameters can be restored if the drive fails and is replaced.
10. **Document the maintenance**: Record all findings, measurements, and actions. Note the fan and capacitor condition for trending. Schedule the next maintenance visit.

## Common Problems

- **Fan failure**: The most common VFD failure mode. Fans fail after 3-5 years, causing overheating. Replace proactively at 3-5 year intervals.
- **Capacitor degradation**: Electrolytic capacitors degrade after 7-10 years. Degradation causes higher DC bus ripple, reduced performance, and eventual failure. Plan for drive replacement or capacitor refurbishment.
- **Dust contamination**: In industrial environments, dust and oil accumulate on the heatsink, reducing cooling. Regular cleaning prevents overheating.
- **Loose terminals**: Thermal cycling loosens terminals, causing high-resistance connections and overheating. Re-torque at every maintenance visit.
- **Environment changes**: If the ambient temperature increases (new equipment nearby, reduced ventilation), the VFD may overheat even if it was fine before. Monitor the environment.

## Best Practices

- Perform preventive maintenance annually at minimum, semi-annually for harsh environments.
- Replace cooling fans proactively at 3-5 year intervals, not after failure.
- Clean the heatsink at every maintenance visit using compressed air or a vacuum.
- Re-torque all power terminals at every maintenance visit.
- Back up VFD parameters after any parameter change and at every maintenance visit.
- Keep a spare VFD (or at least a spare of the most critical model) for rapid replacement.
- Trend the DC bus ripple voltage at maintenance visits — increasing ripple indicates capacitor degradation.
- Plan for VFD replacement at 7-10 years of age, before capacitor failure occurs.
- Keep firmware current, but test updates on a non-critical drive first.

## Safety

- Always de-energize and lock out the VFD before performing any internal maintenance.
- Wait the manufacturer-specified time for DC bus capacitor discharge (typically 5-10 minutes) before opening the drive.
- Verify the DC bus voltage is zero with a rated DC voltmeter before touching internal components.
- Do not use conductive cleaning materials or liquids inside the VFD.
- When replacing fans or capacitors, use only manufacturer-approved parts — incorrect parts can cause drive failure.
- After maintenance, verify all covers are reinstalled and all safety labels are in place before re-energizing.',
      45, true, true,
      '[
        {"question":"What is the typical life of VFD cooling fans?","options":["1 year","3-5 years","10 years","20 years"],"correctIndex":1},
        {"question":"What is the typical life of VFD electrolytic capacitors?","options":["3-5 years","7-10 years at rated temperature","20 years","1 year"],"correctIndex":1},
        {"question":"What is the most common VFD failure mode?","options":["IGBT failure","Cooling fan failure","Control board failure","Software corruption"],"correctIndex":1},
        {"question":"How often should VFD preventive maintenance be performed?","options":["Only when the VFD fails","Annually at minimum, semi-annually for harsh environments","Every 5 years","Every 10 years"],"correctIndex":1},
        {"question":"What should be done with VFD parameters during maintenance?","options":["Nothing","Back up all parameters to a computer or storage device","Delete them","Reset to defaults"],"correctIndex":1},
        {"question":"What indicates capacitor degradation in a VFD?","options":["Lower current","Increasing DC bus ripple voltage","Higher motor speed","Lower temperature"],"correctIndex":1},
        {"question":"How long should you wait after de-energizing a VFD before opening it?","options":["10 seconds","The manufacturer-specified time (typically 5-10 minutes) for DC bus capacitor discharge","1 minute","No wait needed"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;
