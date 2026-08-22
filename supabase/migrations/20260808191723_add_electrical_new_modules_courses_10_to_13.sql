-- ============================================================
-- PART 4b: Add new modules + 2 lessons each for courses 10-13
-- ============================================================

-- Course 10: Electrical Troubleshooting Methodology — Add Module 3: Advanced Troubleshooting Scenarios
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Electrical Troubleshooting Methodology' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Advanced Troubleshooting Scenarios') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Troubleshooting Scenarios', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Intermittent Faults & Thermal Imaging',
      '## Overview

Intermittent faults are the most challenging problems in electrical troubleshooting. A motor that trips occasionally, a control circuit that works most of the time but fails unpredictably, or a breaker that nuisance-trips — these are the problems that test an electrician''s skill and patience. Thermal imaging (infrared scanning) is one of the most powerful tools for finding intermittent faults before they become permanent failures.

## Key Concepts

- **Intermittent fault characteristics**: Faults that appear and disappear, often temperature-dependent, vibration-dependent, or load-dependent. They are difficult to reproduce on demand.
- **Thermal imaging (IR scanning)**: Uses an infrared camera to detect heat signatures in electrical equipment. Hot spots indicate loose connections, overloading, or component degradation.
- **Temperature-dependent failures**: Connections that expand and contract with temperature cycling can become intermittent — good when cold, bad when hot, or vice versa.
- **Vibration-dependent failures**: Connections or components that fail under vibration (motor running) but test fine when stationary.
- **Load-dependent failures**: Circuits that work under light load but fail under full load due to voltage drop from high-resistance connections.

## Step-by-Step: Troubleshooting an Intermittent Motor Trip

1. **Gather information**: Interview operators. When does it trip? What was the motor doing? What was the ambient temperature? Was it after a long run or at startup?
2. **Review history**: Check maintenance records for previous trips, repairs, or modifications. Look for patterns (time of day, season, production cycle).
3. **Perform IR scan under load**: Scan the motor terminal box, contactor, overload relay, and all connections while the motor is running under full load. Look for hot spots (>10°C above ambient at connections).
4. **Check connections under load**: Use a voltmeter to measure voltage drop across each connection under load. More than 0.5V across a connection indicates a problem.
5. **Monitor with a data logger**: If the fault cannot be reproduced, install a power quality analyzer or data logger to record voltage, current, and power during normal operation. Wait for the next trip event.
6. **Check for thermal cycling**: If the fault is temperature-dependent, use a heat gun to warm suspect components or cold spray to cool them, and observe the effect.
7. **Check for vibration sensitivity**: Tap or vibrate suspect components while monitoring the circuit. A connection that opens under vibration is the likely culprit.
8. **Repair and verify**: Tighten or replace the faulty connection, replace the degraded component, and verify the problem is resolved by running through the conditions that previously caused the trip.

## Common Problems

- **Loose connections**: The most common cause of intermittent faults. Thermal cycling loosens compression connections over time.
- **Cracked wire strands**: A wire with partially broken strands carries current intermittently. Vibration or thermal expansion causes the remaining strands to make or break contact.
- **Contactor contact erosion**: Worn contacts make intermittent connection, especially under vibration.
- **Thermal overload relay drift**: An older overload relay may trip at a lower current than its setting due to calibration drift.
- **Voltage sags from other loads**: Large motor starts elsewhere in the facility can cause voltage sags that trip sensitive equipment.

## Best Practices

- Perform annual IR scans of all electrical connections under load. Trend the results to identify degradation over time.
- Use torque markers on critical connections to detect loosening.
- Install power quality monitoring on critical circuits to capture intermittent events.
- Train operators to document the exact conditions when an intermittent fault occurs — this information is critical for diagnosis.
- Do not overtighten connections — follow manufacturer torque specifications. Overtightening damages terminals and creates future failure points.
- Use spring-loaded terminal blocks (cage clamp) in high-vibration environments to prevent loosening.

## Safety

- IR scanning must be performed on energized equipment — wear appropriate PPE and maintain safe approach distances.
- Never open an energized panel for IR scanning without an energized work permit and appropriate PPE.
- Use an IR window or port where possible to scan without opening the panel.
- Be aware that hot spots may indicate an imminent failure — do not ignore elevated temperatures.
- After identifying a hot connection, de-energize and lock out before tightening or replacing.',
      50, true, true,
      '[
        {"question":"What is the most common cause of intermittent electrical faults?","options":["Bad luck","Loose connections that make and break contact due to thermal cycling or vibration","Undersized wire","Overloaded circuits"],"correctIndex":1},
        {"question":"What does thermal imaging (IR scanning) detect in electrical equipment?","options":["Voltage levels","Heat signatures that indicate loose connections, overloading, or component degradation","Current flow","Power factor"],"correctIndex":1},
        {"question":"What voltage drop across a loaded connection indicates a problem?","options":["Less than 0.1V","More than 0.5V","1V","5V"],"correctIndex":1},
        {"question":"What should you do if an intermittent fault cannot be reproduced on demand?","options":["Give up","Install a data logger to record conditions and wait for the next event","Replace all components","Ignore it"],"correctIndex":1},
        {"question":"What is a temperature-dependent fault?","options":["A fault that only occurs in summer","A fault that appears or disappears based on temperature, due to thermal expansion and contraction of connections","A fault in the temperature sensor","A fault that causes overheating"],"correctIndex":1},
        {"question":"How often should IR scans be performed on electrical connections?","options":["Only after a failure","Annually, with results trended over time","Every 10 years","Only at installation"],"correctIndex":1},
        {"question":"What type of terminal block is recommended in high-vibration environments?","options":["Screw terminal blocks","Spring-loaded (cage clamp) terminal blocks that resist loosening","Solder terminals","Any terminal block"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Motor Control Circuit Troubleshooting',
      '## Overview

Motor control circuits are the most common troubleshooting target in industrial facilities. A motor that won''t start, won''t stop, starts and immediately stops, or runs but won''t stop — each symptom points to a different set of possible causes. A systematic approach using the ladder diagram and a voltmeter can quickly isolate the fault.

## Key Concepts

- **Control circuit power**: The control circuit is typically 24V or 120V, separate from the motor power circuit. Problems in the control circuit prevent the contactor from energizing.
- **Series path**: A motor control circuit is a series path from the control transformer through the stop button, start button/seal-in contact, overload contact, and coil. Any open component stops the motor.
- **Voltmeter method**: Measuring voltage across each component in the series path identifies the open one — the open component reads full voltage; closed components read near zero.
- **Contactor not pulling in**: The most common symptom. The fault is in the control circuit (no voltage to coil, open contact, or bad coil).
- **Motor won''t stop**: The seal-in contact is welded closed, or the stop button is bypassed/shorted.
- **Chatter**: The contactor rapidly opens and closes, usually caused by voltage drop, a weak coil, or a loose connection.

## Step-by-Step: Troubleshooting a Motor That Won''t Start

1. **Check the control circuit voltage**: Measure the control transformer secondary voltage. If zero, check the primary fuse and supply voltage.
2. **Check the control fuse**: Measure voltage across the control fuse. If full voltage, the fuse is blown. If near zero, the fuse is good.
3. **Measure voltage at the coil**: Place one voltmeter lead on each side of the contactor coil. If full control voltage is present, the coil should be energized — if not, the coil is bad. If zero voltage, the circuit is open upstream.
4. **Trace the series path**: Starting from the line side of the control circuit, measure voltage across each component (stop button, start button, seal-in contact, overload contact). The component that reads full voltage across it is the open one.
5. **Check the overload relay**: If the overload is tripped, the NC contact is open. Reset the overload and investigate the cause (motor overload, voltage unbalance, or overload setting too low).
6. **Check the start button**: Press the start button and measure voltage across it. If it reads full voltage when pressed, the button is bad. If near zero, the button is good.
7. **Check the seal-in contact**: If the motor starts but stops when the start button is released, the seal-in contact is not closing. Check the auxiliary contact and its wiring.
8. **Check the power circuit**: If the contactor is energized (pulled in) but the motor does not run, check the power circuit: fuses, breaker, contactor contacts, and motor terminals.

## Common Problems

- **Blown control fuse**: The most common cause of a motor that won''t start. Check for shorts in the control circuit.
- **Tripped overload**: The second most common cause. Check motor loading, voltage balance, and overload setting.
- **Bad start/stop button**: Buttons fail from wear, dirt, or moisture. Test by measuring voltage across the contacts.
- **Failed contactor coil**: Coils fail from voltage transients, overheating, or age. Measure coil resistance and compare to specifications.
- **Welded seal-in contact**: The motor won''t stop because the seal-in contact is welded closed. The only fix is to replace the contactor or the auxiliary contact.
- **Open limit switch or float switch**: In automatic control circuits, a failed limit switch or float switch prevents the motor from starting.

## Best Practices

- Always start with the ladder diagram — it shows the series path and the expected voltage at each point.
- Use the voltmeter method (voltage across each component) rather than the ohmmeter method (resistance) for energized circuits.
- Carry spare control fuses, overload relays, and contactor coils for quick replacement.
- Document the fault and the repair — this builds a knowledge base for future troubleshooting.
- After repairing, test the complete circuit including the stop button and emergency stop.
- Check for the root cause, not just the failed component — a blown fuse may indicate a short that will blow the replacement too.

## Safety

- De-energize and lock out before replacing any component.
- When measuring voltage on energized control circuits, wear PPE appropriate for the voltage level.
- Use properly rated test leads and meters — a meter rated for the wrong category can fail catastrophically.
- Do not bypass the overload relay or the stop button to "test" the motor — this is dangerous and can cause injury.
- After repair, verify the emergency stop circuit works correctly before returning the equipment to service.',
      50, true, true,
      '[
        {"question":"What is the first check when a motor will not start?","options":["Replace the contactor","Check the control circuit voltage at the transformer","Check the motor","Replace the start button"],"correctIndex":1},
        {"question":"What does a voltmeter read across an open component in a series control circuit?","options":["Zero volts","Full control voltage","Half voltage","Double voltage"],"correctIndex":1},
        {"question":"What does a voltmeter read across a closed (good) component in a series control circuit?","options":["Full control voltage","Near zero volts","Half voltage","No reading"],"correctIndex":1},
        {"question":"If the motor starts but stops when the start button is released, what is the likely cause?","options":["Bad stop button","The seal-in (holding) contact is not closing or is miswired","Bad coil","Blown fuse"],"correctIndex":1},
        {"question":"What causes contactor chatter?","options":["Oversized wire","Voltage drop, weak coil, or loose connection causing rapid make/break","High voltage","Low current"],"correctIndex":1},
        {"question":"If the contactor is energized but the motor does not run, where is the problem?","options":["In the control circuit","In the power circuit (fuses, breaker, contactor contacts, or motor)","In the start button","In the overload relay"],"correctIndex":1},
        {"question":"What should you do after repairing a motor control circuit?","options":["Nothing","Test the complete circuit including the stop button and emergency stop","Only check the motor","Only check the start button"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 11: Grounding, Bonding & Equipment Grounding Conductors — Add Module 3: Grounding System Design & Maintenance
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Grounding, Bonding & Equipment Grounding Conductors' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Grounding System Design & Maintenance') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Grounding System Design & Maintenance', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Grounding System Design for Industrial Facilities',
      '## Overview

Proper grounding system design is the foundation of electrical safety and power quality in industrial facilities. A well-designed grounding system protects personnel from shock, clears faults quickly, provides a reference for sensitive electronic equipment, and dissipates lightning energy. Poor grounding causes nuisance tripping, equipment damage, data errors, and safety hazards.

## Key Concepts

- **System grounding vs equipment grounding**: System grounding connects the current-carrying conductor (neutral) to earth at the service entrance. Equipment grounding connects non-current-carrying metal parts to earth to protect against shock.
- **Solidly grounded vs impedance grounded**: Solidly grounded systems connect the neutral directly to earth. High-resistance grounded (HRG) systems connect through a resistor to limit ground fault current, preventing arc flash and maintaining operation during a single fault.
- **Grounding electrode system**: A network of ground rods, building steel, concrete-encased electrodes (Ufer), water pipes, and ground rings designed to provide a low-impedance connection to earth.
- **Neutral-ground bond**: Made at only one point — the service entrance or the source of a separately derived system. Making this bond at subpanels creates parallel neutral current paths and dangerous touch voltages.
- **Equipment grounding conductor (EGC)**: Provides the low-impedance fault path that allows overcurrent devices to clear ground faults quickly.

## Step-by-Step: Designing an Industrial Grounding System

1. **Determine the system grounding method**: Solidly grounded (most common for 480/277V), high-resistance grounded (for critical processes), or ungrounded (rare, for specific applications).
2. **Design the grounding electrode system**: Per NEC 250.50, connect all available grounding electrodes (ground rods, building steel, concrete-encased electrode, water pipe, ground ring) to form the grounding electrode system.
3. **Size the grounding electrode conductor (GEC)**: Per NEC 250.66, based on the size of the service entrance conductors. For 500 kcmil copper, minimum 1/0 AWG copper.
4. **Size the equipment grounding conductor (EGC)**: Per NEC 250.122, based on the rating of the overcurrent device. For a 200A breaker, minimum 6 AWG copper.
5. **Specify the neutral-ground bond**: Install the main bonding jumper at the service entrance. Do NOT bond neutral and ground at subpanels.
6. **Design the ground grid**: For large facilities, design a ground grid (buried conductors) to achieve a target step and touch potential per IEEE 80.
7. **Specify surge protection**: Install surge protective devices (SPDs) at the service entrance and at sensitive equipment panels.
8. **Document the design**: Create a grounding diagram showing all electrodes, conductors, and bonds. Include specifications for materials and installation.

## Common Problems

- **Multiple neutral-ground bonds**: Bonding neutral and ground at subpanels creates parallel current paths, causing neutral current on the EGC, elevated touch voltages, and nuisance GFCI tripping.
- **Isolated ground rods**: Driving a separate ground rod for a specific piece of equipment (without bonding to the main system) creates a voltage difference that can damage equipment or cause shock.
- **Undersized EGC**: An EGC that is too small for the overcurrent device will not clear faults quickly, allowing dangerous touch voltages to persist.
- **Missing concrete-encased electrode**: Not using the building''s rebar as a grounding electrode misses the best available electrode, which typically has very low impedance.
- **Corroded connections**: Grounding connections corrode over time, increasing impedance. Annual inspection and testing is required.

## Best Practices

- Bond all grounding electrodes together to form a single grounding electrode system — never use isolated grounds.
- Make the neutral-ground bond at only one point (the service entrance).
- Use exothermic welds (Cadweld) for below-grade grounding connections — they do not corrode or loosen.
- Install a ground grid for facilities with large outdoor switchyards or high lightning risk.
- Perform annual ground resistance testing and trend the results.
- Install SPDs at the service entrance and at all panels feeding sensitive electronic equipment.
- Use a common grounding point for all systems (power, data, telephone, antenna) to prevent ground loops.

## Safety

- Never separate the neutral and ground at a subpanel and drive a separate ground rod — this creates a shock hazard.
- Grounding connections must be accessible for inspection — do not bury connections without access points.
- Before touching any equipment during a fault, verify the equipment grounding conductor is intact.
- High-resistance grounded systems can maintain a charge on the neutral after the fault — use proper discharge procedures.
- During ground testing, ensure the system is de-energized or use a clamp-on tester that does not require disconnection.',
      50, true, true,
      '[
        {"question":"Where is the neutral-ground bond made?","options":["At each subpanel","At the service entrance only (or the source of a separately derived system)","At each motor","At each receptacle"],"correctIndex":1},
        {"question":"What is the purpose of high-resistance grounding (HRG)?","options":["To save money","To limit ground fault current, preventing arc flash and allowing continued operation during a single ground fault","To improve power factor","To reduce harmonics"],"correctIndex":1},
        {"question":"What NEC table is used to size the grounding electrode conductor (GEC)?","options":["NEC 250.122","NEC 250.66","NEC 430.250","NEC 310.16"],"correctIndex":1},
        {"question":"What NEC table is used to size the equipment grounding conductor (EGC)?","options":["NEC 250.122","NEC 250.66","NEC 430.250","NEC 310.16"],"correctIndex":0},
        {"question":"What is the danger of driving a separate ground rod for a specific piece of equipment?","options":["It is illegal","It creates a voltage difference between the equipment ground and the system ground, which can damage equipment or cause shock","It improves grounding","It has no effect"],"correctIndex":1},
        {"question":"What type of connection is recommended for below-grade grounding connections?","options":["Mechanical clamps","Exothermic welds (Cadweld) that do not corrode or loosen","Solder","Electrical tape"],"correctIndex":1},
        {"question":"What happens if the neutral and ground are bonded at a subpanel?","options":["Nothing","Neutral current flows on the EGC, creating dangerous touch voltages and nuisance GFCI tripping","It improves grounding","It reduces impedance"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Grounding System Testing & Maintenance',
      '## Overview

A grounding system is not a "set it and forget it" installation. Ground resistance changes over time due to soil conditions, corrosion, settling, and environmental changes. Regular testing and maintenance of the grounding system is essential to ensure it continues to provide the protection it was designed for. NFPA 70B and IEEE 80 provide guidance on testing frequency and methods.

## Key Concepts

- **Ground resistance targets**: NEC 250 requires 25 ohms or less for a single rod. For industrial facilities, the target is typically 5 ohms or less, and for data centers and substations, 1 ohm or less.
- **Fall-of-potential (3-point) test**: The most accurate method, using current and potential probes driven into the soil at specific distances from the ground rod under test.
- **Clamp-on ground testing**: A faster method that does not require disconnecting the ground rod or driving auxiliary probes, but requires a parallel ground path.
- **Soil resistivity testing**: The 4-point (Wenner) method measures soil resistivity to design new grounding systems or evaluate existing ones.
- **Continuity testing**: Verifies that all equipment grounding conductors and bonds are electrically continuous, with impedance below 0.1 ohms.

## Step-by-Step: Testing and Maintaining a Grounding System

1. **Review the grounding diagram**: Understand the grounding electrode system design, all connections, and the expected resistance.
2. **Visual inspection**: Inspect all accessible grounding connections for corrosion, looseness, or damage. Check for missing or broken bonds.
3. **Perform continuity testing**: Use a DLRO or similar low-resistance ohmmeter to verify continuity of all bonds and EGCs. Impedance should be below 0.1 ohms.
4. **Perform ground resistance testing**: Use the fall-of-potential method for the most accurate results. Place the current probe at least 5 times the rod length from the test rod, and the potential probe at 62% of that distance.
5. **If fall-of-potential is not feasible**: Use a clamp-on ground tester. Verify a parallel ground path exists. The reading is the resistance of the entire loop, not just the rod.
6. **Test the neutral-ground bond**: Verify the main bonding jumper is intact and has low resistance. Check that no neutral-ground bonds exist at subpanels.
7. **Inspect surge protection**: Verify SPDs are installed and functioning (indicator lights are green, not red).
8. **Document results**: Record all measurements, date, weather conditions, and test method. Compare to previous readings and investigate any significant changes.
9. **Perform corrective maintenance**: Tighten loose connections, replace corroded connectors, install exothermic welds for below-grade connections, and add supplemental electrodes if resistance exceeds the target.

## Common Problems

- **Rising ground resistance over time**: Caused by corrosion, soil drying, or electrode degradation. Trend the readings to identify gradual degradation.
- **Corroded mechanical connections**: Below-grade mechanical clamps corrode and loosen. Replace with exothermic welds.
- **Broken bonds**: Physical damage or vibration can break bonding jumpers. Visual inspection and continuity testing find these.
- **Dry soil conditions**: During drought, soil resistivity increases. This is normal but should be noted in the test records.
- **Inadequate test setup**: Incorrect probe placement in the fall-of-potential test produces inaccurate readings. Follow the 62% rule and verify with multiple readings.

## Best Practices

- Test ground resistance annually and after any major electrical event (lightning strike, fault, equipment failure).
- Trend ground resistance readings over time — a gradual increase indicates degradation.
- Use exothermic welds for all below-grade connections; inspect mechanical connections annually.
- Perform continuity testing of all bonds and EGCs during scheduled maintenance.
- Keep detailed records of all tests, including weather conditions and soil moisture.
- Install test wells at grounding electrodes for easy access and testing.
- Use a clamp-on ground tester for routine checks and fall-of-potential for detailed analysis.

## Safety

- Do not disconnect a ground rod from the system while equipment is energized — this removes the fault path and creates a shock hazard.
- Use a fall-of-potential test when the system can be de-energized; use a clamp-on tester when de-energization is not possible.
- Be aware that ground resistance can change with soil moisture — test during the driest season for the most conservative reading.
- Wear insulated gloves when handling ground rods or connections, as they may carry stray current.
- Grounding electrodes may have a voltage difference from the surrounding soil during a fault — do not touch them during fault conditions.',
      45, true, true,
      '[
        {"question":"What is the NEC maximum ground resistance for a single rod?","options":["5 ohms","25 ohms","100 ohms","1 ohm"],"correctIndex":1},
        {"question":"What is the most accurate method for measuring ground resistance?","options":["A multimeter","Fall-of-potential (3-point) test","Clamp-on ground tester","Visual inspection"],"correctIndex":1},
        {"question":"Where should the potential probe be placed in a fall-of-potential test?","options":["At the ground rod","62% of the distance from the test rod to the current probe","At the current probe","10 feet from the rod"],"correctIndex":1},
        {"question":"What is the target ground resistance for an industrial facility?","options":["25 ohms","5 ohms or less","100 ohms","1 ohm"],"correctIndex":1},
        {"question":"What is the advantage of a clamp-on ground tester?","options":["It is more accurate","It does not require disconnecting the ground rod or driving auxiliary probes","It measures lower resistance","It is cheaper"],"correctIndex":1},
        {"question":"What type of connection is recommended for below-grade grounding connections to prevent corrosion?","options":["Mechanical clamps","Exothermic welds (Cadweld)","Solder","Electrical tape"],"correctIndex":1},
        {"question":"How often should ground resistance be tested?","options":["Only at installation","Annually and after major electrical events","Every 10 years","Only after a failure"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 12: Hazardous Location Electrical Installations — Add Module 3: Inspection & Maintenance of Classified Areas
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Hazardous Location Electrical Installations' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Inspection & Maintenance of Classified Areas') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Inspection & Maintenance of Classified Areas', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Inspecting Hazardous Location Installations',
      '## Overview

Inspection of hazardous (classified) location electrical installations requires specialized knowledge beyond general electrical inspections. The stakes are higher — a defect that would be a minor issue in a general location can cause an explosion in a classified area. Regular inspection and maintenance of explosionproof equipment, seals, and wiring methods is critical for safety and compliance.

## Key Concepts

- **Inspection frequency**: Classified area installations should be inspected at least annually, with more frequent visual inspections (monthly or quarterly) in Division 1 areas.
- **Explosionproof enclosure integrity**: The flame path (the machined mating surfaces of the enclosure) must be maintained. Scratches, corrosion, or improper gaskets can allow flame to escape.
- **Seal fitting integrity**: Seals must be intact, with no cracks, voids, or shrinkage. The sealing compound must fill the fitting completely.
- **Thread engagement**: All threaded connections must have at least 5 full threads engaged. Damaged or corroded threads compromise the flame path.
- **Temperature code compliance**: Equipment must maintain its T-code rating. Lamps replaced with higher-wattage units can exceed the T-code and create an ignition hazard.

## Step-by-Step: Inspecting a Class I, Division 1 Installation

1. **Review the area classification drawing**: Confirm the Class, Division, Group, and T-code for the area being inspected.
2. **Verify equipment ratings**: Check that all equipment in the classified area is rated for the correct Class, Division, Group, and T-code. Look for the marking on the nameplate.
3. **Inspect explosionproof enclosures**: Check the flame paths for scratches, corrosion, or damage. Verify all cover bolts are present and tightened to the correct torque. Check gaskets for condition.
4. **Inspect seal fittings**: Verify seals are present at all required locations (within 18 inches of enclosures in Division 1). Check for cracks, voids, or shrinkage in the sealing compound.
5. **Check thread engagement**: Verify at least 5 full threads are engaged on all threaded connections. Look for damaged or corroded threads.
6. **Inspect conduit and cable**: Check for damage, corrosion, or loose fittings. Verify that conduit seals are intact at area boundaries.
7. **Verify lamp wattage**: Check that all lamps are the correct wattage for the fixture rating. Oversized lamps exceed the T-code.
8. **Check for unauthorized modifications**: Look for added components, bypassed seals, or non-rated equipment installed since the last inspection.
9. **Document findings**: Record all deficiencies with photos and locations. Prioritize repairs by severity.

## Common Problems

- **Missing or damaged cover bolts**: Bolts are removed for maintenance and not reinstalled. The flame path is compromised.
- **Oversized lamps**: Higher-wattage lamps are installed as replacements, exceeding the T-code rating.
- **Deteriorated seals**: Sealing compound cracks or shrinks over time, allowing gas passage.
- **Corroded threads**: Threaded connections corrode, reducing thread engagement and compromising the flame path.
- **Non-rated equipment**: Standard (non-rated) equipment is installed in the classified area during modifications.
- **Damaged flame paths**: Scratches or gouges on the machined mating surfaces of explosionproof enclosures.

## Best Practices

- Use a classified area inspection checklist that covers all NEC and OSHA requirements.
- Inspect Division 1 areas at least quarterly and Division 2 areas at least annually.
- Train maintenance personnel to recognize classified area equipment and understand the consequences of modifications.
- Keep a log of all lamps installed in classified areas, including wattage and T-code.
- Replace damaged explosionproof enclosures — do not attempt to repair flame paths in the field.
- Use only factory-approved replacement parts for classified area equipment.
- After any maintenance in a classified area, perform a complete inspection before re-energizing.

## Safety

- Do not open explosionproof enclosures while energized in a classified atmosphere.
- Verify the area is gas-free with a calibrated gas detector before opening any enclosure.
- Use non-sparking tools in classified areas.
- After maintenance, verify all bolts are reinstalled and torqued, all seals are intact, and all threads are properly engaged.
- Never install non-rated equipment in a classified area — this is a serious safety violation.
- Report any damage to explosionproof equipment immediately and remove it from service until repaired.',
      50, true, true,
      '[
        {"question":"How often should Division 1 classified areas be inspected?","options":["Only at installation","At least quarterly, with annual detailed inspections","Every 5 years","Only after an incident"],"correctIndex":1},
        {"question":"What is the minimum thread engagement required for explosionproof threaded connections?","options":["2 full threads","5 full threads","10 full threads","No minimum"],"correctIndex":1},
        {"question":"What is the danger of installing a higher-wattage lamp in an explosionproof fixture?","options":["It uses more energy","It can exceed the T-code (temperature classification) and ignite the hazardous atmosphere","It reduces light output","It voids the warranty"],"correctIndex":1},
        {"question":"What must be verified before opening an explosionproof enclosure in a classified area?","options":["Nothing","The area is gas-free, verified with a calibrated gas detector","The enclosure is clean","The enclosure is cool"],"correctIndex":1},
        {"question":"What is a common defect found during classified area inspections?","options":["Oversized wire","Missing or damaged cover bolts that compromise the flame path","Undersized conduit","Wrong wire color"],"correctIndex":1},
        {"question":"What should be done with a damaged explosionproof enclosure flame path?","options":["File it smooth","Replace the enclosure — do not attempt field repair of flame paths","Apply grease","Wrap with tape"],"correctIndex":1},
        {"question":"What type of tools should be used in classified areas?","options":["Any tools","Non-sparking tools","Power tools only","Hand tools only"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Maintenance & Repair in Hazardous Locations',
      '## Overview

Maintenance and repair in hazardous (classified) locations requires special procedures, tools, and precautions. The fundamental principle is that no work should be performed on energized equipment in a classified atmosphere if it can be avoided. When maintenance is required, it must be performed in a way that does not compromise the explosionproof integrity of the installation.

## Key Concepts

- **De-energize first**: The safest maintenance in a classified area is performed on de-energized equipment. If the area is classified due to a continuous hazard, de-energization is mandatory.
- **Hot work permits**: Any work that could produce a spark or arc in a classified area requires a hot work permit, gas testing, and continuous monitoring.
- **Explosionproof enclosure reassembly**: After opening an enclosure, all flame paths must be clean and undamaged, all bolts reinstalled and torqued, and all gaskets replaced if damaged.
- **Seal fitting repair**: If a seal is damaged or must be replaced, the old compound must be completely removed and new compound poured. The conductors must be separated during pouring.
- **Thread protection**: Threads on explosionproof equipment must be protected with anti-seize and never painted, as paint on flame paths increases the gap and compromises the flame path.

## Step-by-Step: Performing Maintenance in a Class I, Division 1 Area

1. **Obtain a work permit**: Secure a hot work permit or maintenance permit as required by the facility procedures.
2. **Verify the area is safe**: Use a calibrated gas detector to verify the area is free of flammable gas. If gas is detected, do not proceed.
3. **De-energize the equipment**: Lock and tag out the circuit. Verify absence of voltage with a rated tester.
4. **Open the explosionproof enclosure**: Remove all cover bolts. Carefully separate the flame path surfaces — do not scratch or gouge them.
5. **Inspect flame paths**: Clean the flame path surfaces with a lint-free cloth. Inspect for scratches, corrosion, or damage. If damaged, the enclosure must be replaced.
6. **Perform the maintenance**: Replace the component, tighten connections to torque specifications, and verify wiring.
7. **Reassemble the enclosure**: Clean the flame paths, apply a light coat of anti-seize if specified by the manufacturer, reinstall the cover, and torque all bolts to the manufacturer''s specification.
8. **Verify seal integrity**: If any seal was disturbed, verify it is intact or re-pour it with new compound.
9. **Gas test again**: Verify the area is still gas-free before re-energizing.
10. **Re-energize and test**: Remove the lockout, re-energize, and verify proper operation.

## Common Problems

- **Painted flame paths**: Painting explosionproof enclosure joints increases the gap and compromises the flame path. Paint must be removed from flame paths.
- **Missing bolts**: After maintenance, not all bolts are reinstalled. This compromises the flame path and is a serious violation.
- **Overtightened bolts**: Overtightening can distort the enclosure and increase the flame path gap. Use a torque wrench.
- **Damaged gaskets**: Gaskets that are not replaced after damage allow flame to escape. Always replace damaged gaskets.
- **Improper seal repair**: Re-pouring a seal without removing all old compound creates a weak seal. All old compound must be removed.
- **Wrong replacement parts**: Non-rated replacement parts installed in classified equipment void the rating.

## Best Practices

- Always de-energize before performing maintenance in classified areas.
- Use calibrated gas detectors before and during work.
- Keep a supply of factory-approved replacement parts, including gaskets, bolts, and sealing compound.
- Use a torque wrench on all explosionproof enclosure bolts.
- Never paint flame paths — mask them before painting.
- Document all maintenance performed, including parts replaced and seal conditions.
- Train maintenance personnel specifically for classified area work — general electrical training is not sufficient.

## Safety

- Never perform energized work in a classified atmosphere unless absolutely necessary and with a permit, gas monitoring, and appropriate PPE.
- Use non-sparking tools in classified areas.
- Verify gas-free conditions before and during work with a calibrated detector.
- If gas is detected at any time, stop work immediately and evacuate.
- After maintenance, verify all explosionproof integrity is restored before re-energizing.
- Never bypass safety interlocks or modify explosionproof equipment in the field.',
      50, true, true,
      '[
        {"question":"What is the safest way to perform maintenance in a classified area?","options":["Work quickly","De-energize the equipment and lock it out","Wear insulated gloves","Use non-sparking tools only"],"correctIndex":1},
        {"question":"What must be done before performing work in a classified area?","options":["Nothing","Verify the area is gas-free with a calibrated gas detector","Clean the equipment","Notify the supervisor"],"correctIndex":1},
        {"question":"What is the danger of painting explosionproof enclosure flame paths?","options":["It looks bad","Paint increases the flame path gap, compromising the explosionproof integrity","It causes corrosion","It voids the warranty"],"correctIndex":1},
        {"question":"What must be done after opening an explosionproof enclosure for maintenance?","options":["Just close it","Reinstall all bolts and torque to manufacturer specification, verify flame paths are clean","Apply grease to the threads","Replace the enclosure"],"correctIndex":1},
        {"question":"What must be done if a seal fitting must be re-poured?","options":["Add new compound on top of old","Remove all old compound completely and pour new compound with conductors separated","Just add more compound","Replace the fitting entirely"],"correctIndex":1},
        {"question":"What should be done if gas is detected during maintenance in a classified area?","options":["Continue working carefully","Stop work immediately and evacuate","Turn on a fan","Call the supervisor"],"correctIndex":1},
        {"question":"What type of replacement parts must be used in classified area equipment?","options":["Any equivalent part","Factory-approved, rated replacement parts only","The cheapest available","Standard industrial parts"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 13: Industrial Panel Building & Layout — Add Module 3: Testing & Quality Control
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Industrial Panel Building & Layout' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Testing & Quality Control') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Testing & Quality Control', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Panel Testing & Point-to-Point Verification',
      '## Overview

Before an industrial control panel is energized and put into service, it must be thoroughly tested. Point-to-point verification confirms that every wire is connected to the correct terminal, matching the drawings exactly. This is the most critical quality control step in panel building — a single miswire can cause equipment damage, safety hazards, or hours of field troubleshooting.

## Key Concepts

- **Point-to-point verification**: Using a continuity tester or ohmmeter to verify that each wire is connected between the correct two terminals, with no opens or shorts to other circuits.
- **Megger testing**: Insulation resistance testing to verify no ground faults or insulation breakdowns exist in the panel wiring.
- **Control circuit functional test**: Energizing the control circuit (without power circuit) to verify that relays, contactors, and indicators operate correctly per the logic.
- **Dielectric (hipot) test**: Applying high voltage between conductors and ground to verify insulation integrity (per UL 508A for certain panels).
- **Torque verification**: Re-checking all terminal torques after testing to ensure connections are secure.

## Step-by-Step: Point-to-Point Verification of an Industrial Control Panel

1. **Review the drawings**: Study the wiring diagram, terminal schedule, and wire list. Understand the expected connections before testing.
2. **Disconnect all external wiring**: Ensure the panel is isolated from field wiring, motors, and external power sources.
3. **Set up the continuity tester**: Use a tone-type continuity tester or a digital multimeter with audible continuity. For long wire runs, use a tone generator and probe.
4. **Test each wire**: Starting at terminal 1, touch one probe to the terminal and the other probe to the destination terminal from the wire list. Verify continuity (near zero ohms).
5. **Check for shorts**: After verifying each wire, check for continuity to adjacent terminals and to ground. There should be no continuity to unintended terminals.
6. **Document results**: Mark each wire on the wire list as verified. Note any discrepancies for correction.
7. **Correct any miswires**: If a wire is connected to the wrong terminal, de-terminate it, re-route it to the correct terminal, and re-verify.
8. **Perform insulation resistance test**: Megger all power conductors to ground and to each other. Verify readings meet minimum values (1 megohm for 480V, per IEEE 43).
9. **Perform control circuit functional test**: Apply control power only (not power circuit). Verify that each control device (relay, contactor, indicator) operates correctly per the ladder logic.
10. **Final torque check**: Re-torque all terminals to manufacturer specifications. Document the torque values.

## Common Problems

- **Miswires**: The most common defect. A wire connected to the wrong terminal can cause a short circuit, equipment damage, or safety hazard.
- **Shorts to ground**: A wire with damaged insulation touching the panel enclosure or DIN rail creates a ground fault.
- **Shorts between circuits**: Wires with damaged insulation touching each other create cross-circuit faults.
- **Loose terminations**: Wires that are not properly torqued cause overheating and intermittent operation.
- **Wire strands not in terminal**: Stranded wire with some strands outside the terminal (splaying) creates a high-resistance connection.

## Best Practices

- Use a wire list and mark each wire as verified — do not rely on memory.
- Test every wire, not just a sample. One miswire can cause a catastrophic failure.
- Use ferrules on all stranded wire terminations to prevent splaying.
- Perform the insulation resistance test after point-to-point verification but before the functional test.
- Use a calibrated torque screwdriver or wrench for all terminations.
- Have a second person verify critical circuits (safety circuits, emergency stop circuits).
- Document all test results and include them in the panel documentation package.

## Safety

- Ensure the panel is completely de-energized and isolated before point-to-point testing.
- Discharge any capacitors before testing — they can store charge even after power is removed.
- Use a tester rated for the voltage category of the panel.
- After testing, verify all temporary test connections are removed before energizing.
- Wear PPE when performing the hipot test — it applies high voltage.
- Ensure the panel enclosure is properly grounded before any energized testing.',
      45, true, true,
      '[
        {"question":"What is point-to-point verification?","options":["Checking the panel layout","Using a continuity tester to verify each wire is connected between the correct two terminals","Testing the power circuit","Checking the torque"],"correctIndex":1},
        {"question":"What instrument is used for point-to-point verification?","options":["A megger","A continuity tester or ohmmeter","A clamp meter","A voltmeter"],"correctIndex":1},
        {"question":"What should be done if a miswire is found during point-to-point verification?","options":["Ignore it","De-terminate the wire, re-route it to the correct terminal, and re-verify","Note it for field correction","Replace the wire"],"correctIndex":1},
        {"question":"What is the purpose of the insulation resistance (megger) test?","options":["To verify wire size","To verify no ground faults or insulation breakdowns exist in the panel wiring","To test the control circuit","To verify torque"],"correctIndex":1},
        {"question":"What is the minimum insulation resistance for a 480V panel per IEEE 43?","options":["0.5 megohm","1 megohm","100 megohms","1000 megohms"],"correctIndex":1},
        {"question":"What is the purpose of the control circuit functional test?","options":["To test the power circuit","To verify that relays, contactors, and indicators operate correctly per the logic with control power only","To test the insulation","To test the torque"],"correctIndex":1},
        {"question":"What should be done after all testing is complete?","options":["Nothing","Re-torque all terminals to manufacturer specifications and document the values","Energize the panel","Close the panel"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'UL 508A Compliance & Certification',
      '## Overview

UL 508A is the standard for industrial control panels in North America. A panel bearing the UL 508A mark has been designed, built, and tested to meet stringent safety standards. Understanding UL 508A requirements is essential for panel shops that want to produce listed panels and for end users who need to verify compliance. Non-compliant panels cannot be legally installed in many jurisdictions.

## Key Concepts

- **UL 508A listing**: A panel that has been designed and built per UL 508A and inspected by UL (or a panel shop with a UL 508A follow-up procedure) can bear the UL mark.
- **SCCR (Short-Circuit Current Rating)**: The maximum short-circuit current the panel can withstand. Must be marked on the nameplate. Determined by the lowest-rated component in the power circuit.
- **Temperature rating**: The panel must be rated for the maximum ambient temperature. Components must be derated if necessary.
- **Wire suitability**: Only UL-listed wire (THHN, MTW, AWM) may be used. Wire must be properly sized per NEC and UL tables.
- **Component suitability**: Only UL-listed components may be used. Each component must be used within its listed ratings.
- **Follow-up inspection**: UL conducts periodic unannounced inspections of panel shops to verify ongoing compliance.

## Step-by-Step: Ensuring UL 508A Compliance for a Control Panel

1. **Review the UL 508A standard**: Understand the requirements for the specific panel type (general purpose, industrial machinery, etc.).
2. **Select UL-listed components**: Verify every component has a UL listing mark and is used within its listed ratings. Keep datasheets and UL file numbers.
3. **Determine the SCCR**: Per UL 508A Section SB, calculate the SCCR based on the lowest-rated power circuit component. Use current-limiting fuses to increase the SCCR.
4. **Size conductors**: Per NEC Table 310.16 and UL 508A Table 50.1. Verify ampacity, temperature rating, and conduit fill.
5. **Verify clearances**: Maintain minimum clearances between power and control components, and between components and the enclosure walls, per UL 508A.
6. **Verify enclosure rating**: The enclosure must be rated for the environment (NEMA 12 for indoor, NEMA 4 for washdown, NEMA 7 for hazardous, etc.).
7. **Perform required testing**: Point-to-point verification, dielectric test (if required), and functional test. Document all results.
8. **Create the nameplate**: Include manufacturer, model, voltage, SCCR, date, and UL mark (if listed).
9. **Submit for inspection**: If the panel shop has a UL follow-up procedure, the UL inspector will verify compliance during the next visit. For one-off panels, a field inspection may be required.

## Common Problems

- **Undetermined SCCR**: The SCCR is not calculated or is calculated incorrectly. The panel cannot be listed without a verified SCCR.
- **Non-listed components**: Using non-UL-listed components (e.g., imported contactors without UL listing) prevents the panel from being listed.
- **Inadequate clearances**: Components placed too close together violate UL 508A clearance requirements and can cause overheating.
- **Wrong wire type**: Using wire not listed for the application (e.g., THHN in a panel requiring MTW) violates the standard.
- **Missing documentation**: Without component datasheets, UL file numbers, and test records, the panel cannot be verified as compliant.

## Best Practices

- Maintain a library of UL file numbers and datasheets for all components used.
- Use current-limiting fuses to achieve higher SCCR ratings.
- Design panels with generous clearances — do not pack components tightly.
- Use only UL-listed wire and terminals.
- Keep the UL 508A standard on hand and reference it during design.
- Train panel builders on UL 508A requirements — compliance is everyone''s responsibility.
- Document every step of the build process, including torque values and test results.

## Safety

- A panel without proper SCCR rating may not withstand a fault, endangering personnel and equipment.
- Non-compliant panels may be rejected by the Authority Having Jurisdiction (AHJ), delaying project completion.
- Always verify the UL listing mark on the panel nameplate before installation.
- Do not modify a UL-listed panel without following the UL field modification procedure.
- Ensure the panel enclosure is properly grounded and bonded per UL 508A and NEC requirements.',
      45, true, true,
      '[
        {"question":"What does SCCR stand for?","options":["Standard Current Carrying Rating","Short-Circuit Current Rating","Standard Circuit Control Relay","Short Circuit Control Rating"],"correctIndex":1},
        {"question":"What determines the SCCR of a panel per UL 508A?","options":["The main breaker rating","The lowest-rated component in the power circuit","The wire size","The enclosure size"],"correctIndex":1},
        {"question":"What can be used to increase the SCCR of a panel?","options":["Larger wire","Current-limiting fuses","A larger enclosure","More components"],"correctIndex":1},
        {"question":"What type of components must be used in a UL-listed panel?","options":["Any components","UL-listed components used within their listed ratings","The cheapest available","Imported components"],"correctIndex":1},
        {"question":"What must be on the panel nameplate for a UL-listed panel?","options":["Only the manufacturer name","Manufacturer, model, voltage, SCCR, date, and UL mark","Only the voltage","Only the serial number"],"correctIndex":1},
        {"question":"What happens if a panel does not have a proper SCCR rating?","options":["Nothing","It may not withstand a fault, endangering personnel and equipment","It will be more efficient","It will cost less"],"correctIndex":1},
        {"question":"What should be done before modifying a UL-listed panel?","options":["Nothing — modifications are fine","Follow the UL field modification procedure","Replace the panel","Remove the UL mark"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;
