DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Energy Management & Efficient Drive Systems';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lesson 1
  UPDATE lessons SET content = '## Overview

Electric motors consume the majority of industrial electricity, and the efficiency of the motor and its drive determines the operating cost for decades. International Efficiency (IE) classes standardize motor efficiency, and variable frequency drives (VFDs) save energy by matching motor speed to load. This lesson covers the IE efficiency classes, the energy savings from VFDs, and the application considerations that determine whether a VFD is the right choice.

## Key Concepts

**IE Efficiency Classes.** The IEC 60034-30 standard defines International Efficiency (IE) classes for motors: IE1 (standard efficiency), IE2 (high efficiency), IE3 (premium efficiency), IE4 (super-premium efficiency), and IE5 (ultra-premium, under development). Each class reduces losses relative to the previous; IE3 reduces losses by about 20% vs. IE2, IE4 by another 20%. Many jurisdictions now mandate IE3 or IE4 for new motors above a certain power. The efficiency difference matters most for motors that run many hours per year at high load — a 1% efficiency gain on a 100 kW motor running 8,000 hours saves about 8,000 kWh per year.

**VFD Energy Savings.** A VFD varies motor speed and torque to match the load, saving energy in applications where the load varies. The biggest savings are in centrifugal loads (pumps, fans, blowers) where power consumption scales with the cube of speed — reducing speed to 80% reduces power to about 50%. Without a VFD, a pump or fan is throttled (wasting energy across a valve or damper) or cycled on and off (causing transients). A VFD matches the output to the demand, eliminating the waste. Savings depend on the load profile: a pump that runs at 50% flow most of the time saves dramatically; one that runs at 100% most of the time saves little.

**Application Considerations.** A VFD is not always the right choice. VFDs add cost, complexity, and potential issues: harmonic distortion on the power system, motor bearing currents from common-mode voltage, electromagnetic interference, and the need for a suitable motor (inverter-duty, with insulation rated for the VFD''s voltage spikes). For constant-speed, high-load applications, a high-efficiency motor on a direct-on-line starter may be more cost-effective. For variable-torque loads (centrifugal pumps and fans), a VFD almost always pays back. Evaluate the load profile, the running hours, and the total cost of ownership, not just the purchase price.

**Sizing and Oversizing.** An oversized motor runs at low load fraction, where efficiency is lower (especially for IE2 and below; IE3 and IE4 maintain efficiency better at partial load). Size the motor to the actual load, not to a "comfort margin" of 150%. A VFD can provide the starting torque without oversizing, so the motor can be sized to the running load. An oversized motor on a VFD still wastes energy at low load; the right answer is right-sizing plus a VFD where the load varies.

## Best Practices

- Specify IE3 or IE4 motors for new and replacement installations, per jurisdictional mandates and TCO.
- Apply VFDs to variable-torque loads (centrifugal pumps, fans, blowers) where the load varies; the savings scale with speed cubed.
- Use inverter-duty motors with VFDs; address harmonics, bearing currents, and EMI in the installation.
- Size motors to the actual load, not to a comfort margin; a VFD can provide starting torque without oversizing.
- Evaluate the load profile and running hours to calculate payback; a VFD on a constant-load motor may not pay back.

## Common Pitfalls

- **IE1 motors on new installations** waste energy for the motor''s 20-year life.
- **VFDs on constant-load motors** add cost and complexity without savings.
- **Oversized motors** run at low load fraction where efficiency is lower.
- **Non-inverter-duty motors on VFDs** suffer insulation failure from voltage spikes.
- **Ignoring harmonics and bearing currents** causes power-quality and reliability issues.

## Real-World Example

A water utility replaced throttling valves on its pumps with VFDs and IE3 motors. The pumps had run at 100% speed with flow throttled to 60%, wasting energy across the valves. With the VFDs, the pumps ran at 80% speed to deliver the same flow, and power consumption dropped 40%. The payback was under 2 years, and the motors'' 20-year life meant decades of savings after. The load profile (variable demand) made the VFD the clear choice.

## Knowledge Check

Review the IE efficiency classes, the cube-law savings from VFDs on centrifugal loads, the application considerations (harmonics, bearing currents, inverter-duty motors), and right-sizing before the quiz.',
  quiz = '[
    {"question":"How does power consumption scale with speed for a centrifugal load?","options":["Linearly","With the square of speed","With the cube of speed","Not at all"],"answer":2,"explanation":"For centrifugal loads, power scales with speed cubed \u2014 80% speed = ~50% power, enabling large VFD savings."},
    {"question":"Which IE class is \"premium efficiency\"?","options":["IE1","IE2","IE3","IE5"],"answer":2,"explanation":"IE3 is premium efficiency; IE4 is super-premium. Many jurisdictions mandate IE3 or IE4 for new motors."},
    {"question":"Where do VFDs save the most energy?","options":["Constant-load, high-load applications","Variable-torque loads (centrifugal pumps, fans, blowers) where the load varies","Small motors only","Motors that never run"],"answer":1,"explanation":"VFDs save most on variable-torque loads where power scales with speed cubed and the load varies."},
    {"question":"Why use an inverter-duty motor with a VFD?","options":["To save cost","To withstand the VFD\u2019s voltage spikes and harmonic content","To increase speed","To reduce efficiency"],"answer":1,"explanation":"VFDs produce voltage spikes and harmonics; inverter-duty motors have insulation rated for them."},
    {"question":"Why avoid oversized motors?","options":["They are cheaper","They run at low load fraction where efficiency is lower","They save energy","They are required"],"answer":1,"explanation":"Oversized motors run at low load where efficiency drops; size to the actual load, using a VFD for starting torque if needed."},
    {"question":"What must be addressed when installing a VFD?","options":["Nothing","Harmonics, bearing currents (from common-mode voltage), and EMI","Only the cost","Only the motor size"],"answer":1,"explanation":"VFDs introduce harmonics, bearing currents, and EMI; the installation must mitigate them (reactors, filters, shaft grounding)."},
    {"question":"What was the result of replacing throttling valves with VFDs in the example?","options":["No change","40% power reduction, under 2-year payback, decades of savings after","Higher energy use","Slower pumps"],"answer":1,"explanation":"Running pumps at 80% speed instead of throttling at 100% cut power 40%; the variable load profile made VFDs the clear choice."}
  ]'::jsonb
  WHERE title = 'IE Efficiency Classes & VFD Energy Savings' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Update existing lesson 2
  UPDATE lessons SET content = '## Overview

ISO 50001 is the international standard for energy management systems (EnMS), providing a framework for organizations to manage energy as a controllable resource. Demand management complements it by managing when and how much energy is consumed, reducing peak demand charges and participating in utility demand-response programs. This lesson covers the ISO 50001 EnMS, the energy planning process, and the demand management strategies that reduce cost and improve grid stability.

## Key Concepts

**ISO 50001 EnMS.** ISO 50001 follows the Plan-Do-Check-Act cycle: Plan (establish an energy policy, energy baselines, energy performance indicators, objectives, and targets), Do (implement energy management action plans), Check (monitor and measure energy performance), Act (take corrective action and review). The EnMS treats energy as a managed input with a baseline (EnB) and performance indicators (EnPIs) that track consumption against production. Certification to ISO 50001 provides third-party assurance and is increasingly required by customers and regulators.

**Energy Planning.** Energy planning establishes the baseline: the energy consumption by source (electricity, gas, steam), by area (process, building, utility), and by time. The baseline normalizes energy to production (kWh per unit) so that changes in production do not mask efficiency changes. Energy Performance Indicators (EnPIs) are the metrics tracked over time: kWh per unit, kWh per ton, therms per unit. The review identifies Significant Energy Uses (SEUs) — the equipment and processes that consume the most energy and offer the most opportunity. Focus improvement on SEUs, not on rounding-error items.

**Demand Management.** Demand management reduces the peak demand (the maximum power draw in a billing period) that drives demand charges, often a large fraction of an industrial bill. Strategies: shift loads to off-peak times (run batch processes at night), stagger large motor starts (avoid simultaneous inrush), use soft starters or VFDs to reduce starting current, and shed non-critical loads during peak periods. The peak demand, not the total energy, often determines the demand charge; reducing the peak by 10% can reduce the demand charge by 10% even if total energy is unchanged.

**Demand Response.** Demand response programs pay industrial customers to reduce load on utility request during grid stress. Participation requires a plan (which loads can be shed, by how much, for how long) and a control system that can execute the shed automatically. Demand response provides revenue and improves grid stability, but the shed must not violate safety or production requirements. Evaluate the shed capacity realistically; over-promising leads to penalties.

## Best Practices

- Establish an energy baseline normalized to production; track EnPIs over time to measure real improvement.
- Identify Significant Energy Uses (SEUs) and focus improvement on them, not on rounding-error items.
- Manage peak demand by staggering starts, using soft starters/VFDs, and shedding non-critical loads during peaks.
- Evaluate demand response participation with a realistic shed plan and automatic execution.
- Pursue ISO 50001 certification for third-party assurance and customer/regulatory compliance.

## Common Pitfalls

- **No baseline** means improvement cannot be measured; production changes mask efficiency changes.
- **Focusing on small uses** wastes effort; the SEUs offer the opportunity.
- **Simultaneous large motor starts** create a peak that drives demand charges for the month.
- **Over-promising demand response** leads to penalties when the shed cannot be delivered.
- **No EnPI tracking** means the EnMS is asserted, not measured.

## Real-World Example

A manufacturer had a monthly demand charge driven by a single morning peak when three large fans started simultaneously. After staggering the starts by 5 minutes and adding soft starters, the peak dropped 15%, reducing the demand charge with no change in total energy. The manufacturer also enrolled in a demand response program, shedding non-critical loads on utility request for a payment that funded further energy projects. The demand management, not the energy efficiency, was the first win.

## Knowledge Check

Review the ISO 50001 EnMS and the Plan-Do-Check-Act cycle, energy baselines and EnPIs, Significant Energy Uses, peak demand management, and demand response before the quiz.',
  quiz = '[
    {"question":"What cycle does ISO 50001 follow?","options":["DMAIC","Plan-Do-Check-Act","Six Sigma","5S"],"answer":1,"explanation":"ISO 50001 uses the PDCA cycle: plan energy management, do action plans, check performance, act on results."},
    {"question":"What is an Energy Performance Indicator (EnPI)?","options":["A type of motor","A metric tracked over time (e.g., kWh per unit) to measure energy performance","A demand charge","A utility tariff"],"answer":1,"explanation":"EnPIs normalize energy to production so efficiency can be tracked independent of production volume."},
    {"question":"What are Significant Energy Uses (SEUs)?","options":["Small loads","The equipment and processes that consume the most energy and offer the most opportunity","Demand charges","EnPIs"],"answer":1,"explanation":"SEUs are where improvement effort pays back; focusing on rounding-error items wastes effort."},
    {"question":"What drives the demand charge in most industrial bills?","options":["Total energy","Peak demand (maximum power draw in the billing period)","Power factor","Voltage"],"answer":1,"explanation":"The peak demand, not total energy, often drives the demand charge; reducing the peak reduces the charge."},
    {"question":"How can peak demand be reduced?","options":["Run everything at once","Stagger large motor starts, use soft starters/VFDs, shed non-critical loads during peaks","Increase production","Ignore it"],"answer":1,"explanation":"Staggering starts and shedding non-critical loads during peaks reduces the maximum draw that sets the demand charge."},
    {"question":"What is demand response?","options":["A type of motor","Utility programs that pay customers to reduce load on request during grid stress","A demand charge","An EnPI"],"answer":1,"explanation":"Demand response pays for shed capacity; participation requires a realistic shed plan and automatic execution."},
    {"question":"What reduced the manufacturer\u2019s demand charge in the example?","options":["A new motor","Staggering three fan starts by 5 minutes and adding soft starters, cutting the peak 15%","A VFD on a pump","An ISO 50001 audit"],"answer":1,"explanation":"Staggering starts and soft starters cut the morning peak 15%, reducing the demand charge with no change in total energy."}
  ]'::jsonb
  WHERE title = 'ISO 50001 & Demand Management' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2 with lesson 1
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'VFD Application & Power Quality', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'VFD Selection, Configuration & Harmonics', '## Overview

Selecting and configuring a VFD involves more than matching the motor''s power rating. The VFD must be selected for the load type, configured for the application, and its power-quality effects (harmonics, common-mode voltage) must be managed. This lesson covers VFD selection criteria, the key configuration parameters, and the harmonics that a VFD introduces and how to mitigate them.

## Key Concepts

**VFD Selection Criteria.** Match the VFD to the load type: variable torque (centrifugal pumps, fans — lower torque at low speed), constant torque (conveyors, extruders — full torque at all speeds), constant power (winders, machine tools — torque decreases as speed increases). Size the VFD to the motor''s full-load current, not just the power; a VFD undersized for the current will trip on overload. Consider the overload capacity (typically 150% for 60 s, 110% for 60 s for variable torque). For regenerative loads (cranes, downhill conveyors), select a regenerative VFD or a braking resistor to absorb the regenerated energy.

**Key Configuration Parameters.** The VFD must be configured for the motor (nameplate power, voltage, current, frequency, speed) and for the application. Key parameters: the V/Hz curve (linear for standard applications, variable torque for pumps/fans, flux optimization for energy savings), the acceleration and deceleration ramps (long enough to avoid overcurrent, short enough to meet the process), the carrier frequency (higher for quieter operation, lower to reduce EMI and motor heating), the control mode (V/Hz, sensorless vector, closed-loop vector for high-torque-at-low-speed applications), and the protection settings (overload, overvoltage, undervoltage, stall).

**Harmonics.** A VFD draws non-sinusoidal current from the line, producing harmonic currents that distort the voltage and affect other equipment. The total harmonic distortion of current (THDi) of a standard 6-pulse VFD can be 80–100% at full load. Harmonics cause transformer and conductor heating, nuisance tripping of breakers, and interference with sensitive equipment. Mitigation: line reactors (5% impedance reduces THDi to about 35%), DC link chokes, 12-pulse or 18-pulse rectifiers (which cancel low-order harmonics), active front ends (which can achieve THDi < 5%), and passive or active harmonic filters. The mitigation choice depends on the installation''s total harmonic load and the utility''s limits.

**Common-Mode Voltage and Bearing Currents.** VFDs produce common-mode voltage (voltage common to all three phases relative to ground) that can drive currents through motor bearings, causing fluting and premature failure. Mitigation: shaft grounding (a grounding brush or ring), insulated bearings (breaking the current path), and a VFD with a common-mode filter. Inverter-duty motors often include insulated bearings as standard. The issue is most severe on larger motors and on long motor cables; keep cables short, use shielded VFD cable, and consider a sine filter for long runs.

## Best Practices

- Match the VFD to the load type (variable torque, constant torque, constant power) and size to full-load current.
- Configure motor parameters from the nameplate and application parameters (V/Hz, ramps, carrier, control mode).
- Mitigate harmonics with line reactors, DC chokes, multi-pulse rectifiers, or active front ends per the installation''s total harmonic load.
- Address common-mode voltage with shaft grounding, insulated bearings, and shielded VFD cable, especially on larger motors and long cables.
- For regenerative loads, select a regenerative VFD or size a braking resistor to absorb the regenerated energy.

## Common Pitfalls

- **Undersized VFD** trips on overload; size to full-load current, not just power.
- **Unmitigated harmonics** cause transformer heating and nuisance tripping.
- **No shaft grounding on larger VFD motors** causes bearing fluting and premature failure.
- **Wrong control mode** (V/Hz where vector is needed) gives poor low-speed torque.
- **Unmanaged regenerated energy** trips the VFD on overvoltage or wastes energy in a resistor.

## Real-World Example

A plant installed a 200 HP VFD on a pump without a line reactor. The harmonics caused a shared transformer to overheat and tripped a neighboring sensitive instrument repeatedly. After adding a 5% line reactor, the THDi dropped from ~90% to ~35%, the transformer temperature fell, and the instrument trips stopped. The reactor, a small fraction of the VFD cost, was essential to the installation''s power quality.

## Knowledge Check

Review VFD selection by load type and full-load current, key configuration parameters, harmonics and mitigation (reactors, multi-pulse, active front ends), and common-mode voltage and bearing current mitigation before the quiz.',
  45, 1,
  '[
    {"question":"How should a VFD be sized?","options":["To the motor power only","To the motor\u2019s full-load current, considering overload capacity","To the smallest available size","To the cable size"],"answer":1,"explanation":"A VFD undersized for the current trips on overload; size to full-load current, not just power."},
    {"question":"Which load type requires torque to decrease as speed increases?","options":["Variable torque","Constant torque","Constant power","Centrifugal pump"],"answer":2,"explanation":"Constant power loads (winders, machine tools) have torque decrease as speed increases; the VFD must be selected for this profile."},
    {"question":"What is the THDi of a standard 6-pulse VFD at full load?","options":["Under 5%","80\u2013100%","0%","50%"],"answer":1,"explanation":"A standard 6-pulse VFD can have 80\u2013100% THDi, requiring mitigation to protect other equipment."},
    {"question":"What does a 5% line reactor typically reduce THDi to?","options":["Under 5%","About 35%","0%","80%"],"answer":1,"explanation":"A 5% line reactor reduces THDi to about 35%; active front ends can achieve under 5%."},
    {"question":"What causes bearing fluting in VFD-driven motors?","options":["Overgreasing","Common-mode voltage driving currents through the bearings","Undervoltage","Wrong carrier frequency"],"answer":1,"explanation":"Common-mode voltage drives bearing currents that cause fluting; mitigation is shaft grounding and insulated bearings."},
    {"question":"Which mitigation is most effective for harmonics on a large installation?","options":["A line reactor","12-pulse or 18-pulse rectifiers, or an active front end","Nothing","A bigger motor"],"answer":1,"explanation":"Multi-pulse rectifiers cancel low-order harmonics; active front ends can achieve THDi under 5% for large installations."},
    {"question":"What did the 5% line reactor achieve in the example?","options":["No change","THDi from ~90% to ~35%, ending transformer overheating and instrument trips","Higher THDi","A slower pump"],"answer":1,"explanation":"The reactor cut THDi and resolved the power-quality issues that the unmitigated VFD had caused."}
  ]'::jsonb);

  -- Add module 2 lesson 2
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Motor Management & Energy Monitoring Systems', '## Overview

Managing motors as assets and monitoring energy as a resource are the practices that sustain the savings from efficient motors and VFDs over time. Without motor management, efficient motors are replaced with inefficient ones on failure; without energy monitoring, savings decay invisibly. This lesson covers motor management practices (inventory, repair/replace decisions, specification) and energy monitoring systems that sustain efficiency.

## Key Concepts

**Motor Inventory and Management.** Maintain an inventory of every motor: location, power, IE class, criticality, age, and repair history. The inventory enables repair/replace decisions: when an IE1 motor fails, replace it with an IE3 or IE4 motor (the efficiency gain pays back the price premium quickly for motors that run many hours). For critical motors, hold a spare so that failure does not stop production. The inventory also identifies the IE1 motors that are candidates for proactive replacement before failure, based on running hours and payback.

**Repair vs. Replace.** A motor rewind can reduce efficiency (by 0.5–1% per rewind if not done carefully); for an IE1 motor, replacement with an IE3 motor is often more cost-effective than rewind. For an IE3 motor, a quality rewind that preserves efficiency may be appropriate. The decision depends on the motor''s age, IE class, running hours, and the rewind cost vs. replacement cost. Use a repair/replace decision tree that accounts for the efficiency loss and the running hours; a default "rewind everything" policy wastes energy for decades.

**Specification for New and Replacement Motors.** Specify IE3 or IE4 for all new and replacement motors above the jurisdictional threshold, with inverter-duty construction where VFDs are used. Specify the efficiency class, the frame size, the enclosure, the voltage, and the service factor in the standard specification so that purchases default to efficient motors. Without a standard specification, purchases default to the cheapest motor, which is IE1 or IE2, wasting energy for the motor''s life.

**Energy Monitoring Systems.** An energy monitoring system (EMS) measures electricity, gas, steam, and other energy flows by area and by significant equipment, and reports consumption against the baseline and EnPIs. The EMS detects drift (a pump running faster than needed, a VFD in bypass, a process running outside production hours) that would otherwise waste energy invisibly. Submetering at the SEU level is essential; a single main meter cannot identify where energy is wasted. Review the EMS reports monthly and act on the drifts.

## Best Practices

- Maintain a motor inventory with location, power, IE class, criticality, age, and repair history.
- Use a repair/replace decision tree that accounts for efficiency loss and running hours; do not default to rewind.
- Specify IE3 or IE4 (inverter-duty where applicable) in the standard motor specification.
- Submeter energy at the Significant Energy Use level; review EMS reports monthly and act on drifts.
- Identify IE1 motors that are candidates for proactive replacement based on running hours and payback.

## Common Pitfalls

- **No motor inventory** means failures are surprises and repair/replace decisions are ad hoc.
- **Default rewind policy** wastes energy for decades on motors that should be replaced with IE3/IE4.
- **No standard motor specification** defaults purchases to the cheapest (IE1/IE2) motor.
- **Main-meter-only energy monitoring** cannot identify where energy is wasted.
- **Unreviewed EMS reports** collect data without driving action; savings decay invisibly.

## Real-World Example

A plant had no motor inventory and defaulted to rewind on failure. An energy audit found 40 IE1 motors running over 6,000 hours per year. The plant built an inventory, adopted an IE3 standard specification, and used a repair/replace decision tree that replaced IE1 motors on failure with IE3 motors. Over three years, as motors failed and were replaced, the plant''s motor efficiency improved measurably, with the EMS showing a downward trend in kWh per unit. The inventory and the standard, not a single project, drove the sustained improvement.

## Knowledge Check

Review the motor inventory, the repair/replace decision tree, the standard motor specification, submetering at the SEU level, and monthly EMS review before the quiz.',
  45, 2,
  '[
    {"question":"What should a motor inventory include?","options":["Only the location","Location, power, IE class, criticality, age, and repair history","Only the price","Only the vendor"],"answer":1,"explanation":"A complete inventory enables repair/replace decisions, spare holding, and proactive replacement planning."},
    {"question":"Why avoid a default rewind policy?","options":["Rewinds are free","A rewind can reduce efficiency; for IE1 motors, IE3 replacement often pays back faster","Rewinds are illegal","Rewinds increase efficiency"],"answer":1,"explanation":"Rewinds can lose efficiency; for IE1 motors, replacement with IE3 is often more cost-effective, especially at high running hours."},
    {"question":"What should a standard motor specification require?","options":["The cheapest motor","IE3 or IE4, with inverter-duty where VFDs are used","IE1","Any available motor"],"answer":1,"explanation":"A standard spec defaults purchases to efficient motors; without it, purchases default to the cheapest (IE1/IE2)."},
    {"question":"Why submeter at the Significant Energy Use level?","options":["To increase cost","A main meter alone cannot identify where energy is wasted","To slow the process","It is not necessary"],"answer":1,"explanation":"Submetering at SEUs pinpoints waste; a single main meter shows total consumption but not its sources."},
    {"question":"How often should EMS reports be reviewed?","options":["Never","Monthly, acting on drifts","Annually","Every 10 years"],"answer":1,"explanation":"Monthly review catches drift (a VFD in bypass, off-hours operation) before it wastes significant energy."},
    {"question":"What did the repair/replace decision tree achieve in the example?","options":["Higher energy use","A downward trend in kWh per unit as IE1 motors were replaced with IE3 on failure","More rewinds","No change"],"answer":1,"explanation":"Replacing IE1 motors with IE3 on failure, driven by the inventory and standard, produced a measurable efficiency improvement over three years."},
    {"question":"What does an EMS detect that would otherwise be invisible?","options":["Motor color","Drift such as a pump running faster than needed or a VFD in bypass","Vendor name","Cable size"],"answer":1,"explanation":"An EMS detects energy drift that wastes energy invisibly; submetering localizes it to the source."}
  ]'::jsonb);

  -- Add module 3 with lesson 1
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Sustainable Energy & Regulatory Compliance', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Renewable Energy & On-site Generation Integration', '## Overview

On-site renewable energy (solar, wind) and combined heat and power (CHP) generation are increasingly viable for industrial facilities, reducing energy cost and carbon footprint. Integrating these sources with the industrial electrical system and the control system requires understanding the generation characteristics, the interconnection requirements, and the control strategies. This lesson covers on-site generation options, the interconnection and protection requirements, and the control integration.

## Key Concepts

**On-site Generation Options.** Solar photovoltaic (PV) generates DC power converted to AC by inverters; output varies with irradiance, so it is intermittent. Wind generates AC power via a turbine; output varies with wind speed, also intermittent. Combined heat and power (CHP) generates electricity and useful heat from a single fuel (natural gas, biogas), achieving high overall efficiency (75–85%) where the heat is used on-site. Battery energy storage systems (BESS) store energy for peak shaving, demand response, or backup. Each option has different economics, intermittency, and integration requirements.

**Interconnection and Protection.** On-site generation that is connected to the grid must meet the utility''s interconnection requirements: IEEE 1547 for inverter-based generation (PV, BESS), and utility-specific requirements for synchronous generation (CHP, wind). The requirements cover voltage and frequency tolerances, anti-islanding (the generator must disconnect when the grid is down, to protect line workers), and protection (overcurrent, over/under voltage and frequency). The interconnection study determines the impact on the local grid and the protection settings. Do not connect generation without the utility''s approval and the interconnection study.

**Control Integration.** The generation must be integrated with the facility''s control system: monitoring (output, status, alarms), control (curtailment, dispatch for demand response), and coordination with the load (peak shaving, load following). For PV, the inverter typically communicates via Modbus, DNP3, or OPC UA. For CHP, the generator controller provides the interface. The control system must handle the intermittency (for PV and wind) by coordinating with other sources and the load. For a microgrid (islandable operation), the control system must manage the transition between grid-connected and islanded modes.

**Power Quality and Stability.** Inverter-based generation (PV, BESS) can affect power quality: harmonics (from the inverter), voltage regulation (the inverter''s response to voltage changes), and fault behavior (the inverter''s contribution to fault current, which is limited compared to a synchronous generator). For a facility with significant on-site generation, a power quality study and a stability assessment may be needed. BESS can improve power quality and stability by providing reactive power and smoothing the intermittency of PV.

## Best Practices

- Evaluate generation options by economics, intermittency, and integration requirements; match to the facility''s load profile.
- Obtain utility interconnection approval and complete the interconnection study before connecting generation.
- Integrate generation monitoring and control with the facility''s control system (Modbus, DNP3, OPC UA).
- For islandable operation (microgrid), design the control for grid-connected and islanded transitions.
- Assess power quality and stability for facilities with significant inverter-based generation; consider BESS for smoothing.

## Common Pitfalls

- **Connecting generation without utility approval** violates the interconnection agreement and risks safety.
- **No anti-islanding protection** endangers line workers during grid outages.
- **Unintegrated generation** cannot be monitored, controlled, or coordinated with the load.
- **Ignoring intermittency** (PV, wind) leads to unstable operation without coordination or storage.
- **No power quality assessment** for significant inverter-based generation risks harmonics and voltage issues.

## Real-World Example

A food processor installed a 2 MW solar array and a 500 kWh BESS. The PV output varied with clouds, causing voltage flicker on the facility bus. The BESS smoothed the PV output, eliminating the flicker, and provided peak shaving during the afternoon demand peak. The control system coordinated the PV, BESS, and load, curtailing PV only when the BESS was full and the load was low. The integration turned an intermittent source into a stable, dispatchable resource.

## Knowledge Check

Review the generation options and their characteristics, interconnection and anti-islanding requirements, control integration, and power quality and stability considerations before the quiz.',
  45, 1,
  '[
    {"question":"What is anti-islanding protection?","options":["Protection against theft","The generator must disconnect when the grid is down, to protect line workers","A type of inverter","A grounding method"],"answer":1,"explanation":"Anti-islanding prevents the generator from energizing a dead grid, protecting utility line workers; IEEE 1547 requires it."},
    {"question":"What is the overall efficiency of CHP where the heat is used on-site?","options":["30\u201340%","75\u201385%","10%","50%"],"answer":1,"explanation":"CHP achieves 75\u201385% overall efficiency by using both the electricity and the heat, far higher than separate generation."},
    {"question":"Why is PV output intermittent?","options":["It is always constant","Output varies with irradiance (clouds, time of day)","It depends on the load","It is not intermittent"],"answer":1,"explanation":"PV output varies with irradiance; integration must handle the intermittency via coordination or storage (BESS)."},
    {"question":"What must be obtained before connecting on-site generation to the grid?","options":["Nothing","Utility interconnection approval and an interconnection study","A new motor","A VFD"],"answer":1,"explanation":"The utility must approve the interconnection; the study determines the impact and protection settings."},
    {"question":"How can a BESS support PV integration?","options":["By increasing intermittency","By smoothing PV output and providing peak shaving","By disconnecting the PV","By increasing harmonics"],"answer":1,"explanation":"A BESS smooths PV intermittency, eliminates voltage flicker, and provides peak shaving, turning PV into a more stable resource."},
    {"question":"What must a microgrid control system handle?","options":["Only grid-connected mode","The transition between grid-connected and islanded modes","Only islanded mode","Nothing"],"answer":1,"explanation":"A microgrid is islandable; the control must manage the transition between grid-connected and islanded operation."},
    {"question":"What did the BESS eliminate in the example?","options":["The PV array","Voltage flicker from cloud-caused PV variation","The control system","The utility bill"],"answer":1,"explanation":"The BESS smoothed the PV output, eliminating the voltage flicker that cloud variation had caused."}
  ]'::jsonb);

  -- Add module 3 lesson 2
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Energy Regulations, Rebates & Reporting Compliance', '## Overview

Energy management operates within a regulatory and incentive landscape: mandates for efficiency, rebates for efficiency projects, and reporting requirements for consumption and emissions. Navigating this landscape reduces cost (rebates), avoids penalties (mandates), and satisfies stakeholders (reporting). This lesson covers the regulatory landscape, the rebate and incentive programs, and the reporting frameworks that apply to industrial facilities.

## Key Concepts

**Efficiency Mandates.** Many jurisdictions mandate minimum motor efficiency (IE3 or IE4 for motors above a power threshold), building energy codes (ASHRAE 90.1, IECC), and industrial energy efficiency standards. Non-compliance can block a permit, void a warranty, or incur a penalty. Maintain awareness of the applicable mandates by jurisdiction and ensure new and replacement equipment meets them. The mandates typically set the floor, not the target; exceeding them often pays back through lower operating cost.

**Rebate and Incentive Programs.** Utilities and governments offer rebates and incentives for energy efficiency projects: prescriptive rebates (a fixed amount per measure, e.g., $/HP for a VFD), custom rebates (a negotiated amount based on measured savings), and tax incentives (federal, state). The rebate can significantly reduce a project''s payback. Apply before starting the project (many programs require pre-approval), document the savings (measurement and verification, M&V), and submit the paperwork. A project that ignores available rebates leaves money on the table.

**Measurement and Verification (M&V).** M&V quantifies the savings from an efficiency project, using protocols (IPMVP - International Performance Measurement and Verification Protocol) that define how to measure and adjust for production and weather. M&V is required for custom rebates and for reporting savings to stakeholders. A project without M&V has asserted savings, not verified savings; the M&V plan is part of the project, not an afterthought.

**Reporting Frameworks.** Facilities face various reporting requirements: energy consumption (to utilities or regulators), greenhouse gas emissions (to regulators under programs like the EPA GHGRP or the EU ETS), and sustainability metrics (to customers and investors under frameworks like GRI, CDP, TCFD). The reporting requires accurate metering and a consistent methodology. Integrate the reporting with the EMS so that the data is collected once and reported to multiple frameworks.

## Best Practices

- Track applicable efficiency mandates by jurisdiction; ensure new and replacement equipment meets or exceeds them.
- Apply for rebates and incentives before starting projects; document savings with M&V per IPMVP.
- Include M&V in the project plan, not as an afterthought; verified savings support rebates and reporting.
- Integrate energy and emissions reporting with the EMS to collect data once and report to multiple frameworks.
- Treat mandates as a floor; exceed them where the operating-cost savings justify it.

## Common Pitfalls

- **Ignoring mandates** blocks permits or incurs penalties.
- **Missing rebates** by not applying before the project or not documenting savings.
- **No M&V** means savings are asserted, not verified, jeopardizing rebates and reporting.
- **Manual, framework-by-framework reporting** duplicates effort and risks inconsistency.
- **Treating mandates as the target** misses the larger operating-cost savings from exceeding them.

## Real-World Example

A manufacturer planned a $500K VFD and motor project with a 3-year payback. The energy team applied for a utility custom rebate before starting, documented the savings with IPMVP Option B (retrofit isolation with measurement), and received a $150K rebate, reducing the payback to under 2 years. The same M&V data fed the facility''s GHG emissions report, avoiding duplicate measurement. The rebate and the integrated reporting turned a marginal project into a clear win.

## Knowledge Check

Review efficiency mandates, rebate and incentive programs, M&V per IPMVP, reporting frameworks, and integration with the EMS before the quiz.',
  45, 2,
  '[
    {"question":"When should a utility rebate be applied for?","options":["After the project is complete","Before starting the project, as many programs require pre-approval","Never","A year later"],"answer":1,"explanation":"Many rebate programs require pre-approval before the project starts; applying after may disqualify the project."},
    {"question":"What is M&V?","options":["A type of motor","Measurement and Verification, quantifying savings per IPMVP","A rebate","A mandate"],"answer":1,"explanation":"M&V verifies savings using IPMVP protocols; it is required for custom rebates and credible reporting."},
    {"question":"What does IPMVP define?","options":["Motor efficiency","How to measure and adjust savings for production and weather","Rebate amounts","Emissions limits"],"answer":1,"explanation":"IPMVP defines measurement and verification methods that adjust savings for production and weather variables."},
    {"question":"Why integrate reporting with the EMS?","options":["To increase cost","To collect data once and report to multiple frameworks consistently","To slow reporting","To reduce accuracy"],"answer":1,"explanation":"Integrated reporting collects data once and reports to multiple frameworks (GHG, sustainability, utility) consistently."},
    {"question":"What is a prescriptive rebate?","options":["A negotiated amount","A fixed amount per measure (e.g., $/HP for a VFD)","A tax","A mandate"],"answer":1,"explanation":"Prescriptive rebates are fixed per measure; custom rebates are negotiated based on measured savings."},
    {"question":"What did the $150K rebate achieve in the example?","options":["No change","Reduced the project payback from 3 years to under 2 years","Increased the payback","Voided the warranty"],"answer":1,"explanation":"The custom rebate, supported by IPMVP M&V, reduced the payback and turned a marginal project into a clear win."},
    {"question":"How should efficiency mandates be treated?","options":["As the target","As a floor; exceed them where operating-cost savings justify it","As optional","As irrelevant"],"answer":1,"explanation":"Mandates set the minimum; exceeding them often pays back through lower operating cost over the equipment\u2019s life."}
  ]'::jsonb);
END $$;