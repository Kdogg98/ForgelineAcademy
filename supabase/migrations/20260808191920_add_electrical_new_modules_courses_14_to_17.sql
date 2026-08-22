-- ============================================================
-- PART 4c: Add new modules + 2 lessons each for courses 14-17
-- ============================================================

-- Course 14: Lighting Systems, Ballasts & LED Retrofits — Add Module 3: Lighting Controls & Smart Systems
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Lighting Systems, Ballasts & LED Retrofits' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Lighting Controls & Smart Systems') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Lighting Controls & Smart Systems', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Occupancy Sensors, Photocells & Dimming Controls',
      '## Overview

Lighting controls can reduce lighting energy consumption by 20-50% beyond the savings from LED conversion alone. Occupancy sensors turn lights off when spaces are unoccupied, photocells adjust light levels based on available daylight, and dimming controls provide flexible illumination levels. Understanding the types, applications, and installation of lighting controls is essential for modern industrial lighting.

## Key Concepts

- **Occupancy vs vacancy sensors**: Occupancy sensors turn lights ON automatically when motion is detected and OFF after a timeout. Vacancy sensors require manual ON but turn OFF automatically. Vacancy sensors save more energy in spaces with adequate daylight.
- **Sensor technologies**: Passive infrared (PIR) detects body heat; ultrasonic detects motion via Doppler; dual-technology combines both for maximum reliability. PIR is common in industrial; dual-tech is used where reliability is critical.
- **Photocells (daylight harvesting)**: Sensors that measure ambient light and dim or switch off fixtures when natural light is sufficient. Used in perimeter zones near windows and skylights.
- **0-10V dimming**: The most common LED dimming protocol. A 0-10V DC control signal varies the light output from 0% (0V) to 100% (10V).
- **DALI (Digital Addressable Lighting Interface)**: A digital protocol that allows individual fixture addressing, grouping, and control. More complex but more flexible than 0-10V.

## Step-by-Step: Designing a Lighting Control System for an Industrial Facility

1. **Survey the space**: Identify areas with different usage patterns (production floor, warehouse, offices, corridors, restrooms). Note available daylight sources (windows, skylights).
2. **Select sensor types**: Use occupancy sensors in intermittently occupied spaces (warehouses, corridors, restrooms). Use photocells in daylight zones. Use manual dimming in offices and meeting rooms.
3. **Determine control zones**: Group fixtures into zones that can be controlled independently. Each zone should have a similar usage pattern and daylight availability.
4. **Select the control protocol**: 0-10V for simple dimming, DALI for complex systems with individual fixture control, or wireless for retrofit applications where running control wires is impractical.
5. **Layout sensor coverage**: Place sensors to cover the entire controlled zone. Consider sensor range, mounting height, and potential obstructions. PIR requires line of sight; ultrasonic does not.
6. **Wire the control circuit**: Run low-voltage control wiring (0-10V or DALI) from sensors to fixtures or to a control panel. Follow manufacturer wiring diagrams exactly.
7. **Program the system**: Set occupancy timeout (typically 15-30 minutes), photocell thresholds, and dimming levels. For DALI or networked systems, configure groups and schedules.
8. **Commission and verify**: Walk through each zone to verify sensors detect motion correctly, photocells dim appropriately, and override switches work. Adjust sensitivity and timeouts as needed.

## Common Problems

- **False triggers**: HVAC air currents or small animals trigger ultrasonic sensors. Adjust sensitivity or switch to PIR.
- **Dead zones**: Areas not covered by sensor range leave occupants in the dark. Add sensors or adjust mounting.
- **Nuisance off**: Occupancy sensors turn off while people are present but moving slowly (e.g., working at a bench). Increase the timeout or use dual-tech sensors.
- **Photocell hunting**: The photocell turns lights on and off rapidly at the threshold. Use a wider deadband or time delay.
- **Dimming flicker**: Incompatible dimmer/fixture combinations cause visible flicker. Verify compatibility before installation.

## Best Practices

- Use dual-technology (PIR + ultrasonic) sensors in critical areas to eliminate false triggers and dead zones.
- Set occupancy timeouts to 15-20 minutes — shorter causes nuisance off, longer wastes energy.
- Use daylight harvesting in perimeter zones for maximum savings.
- Verify dimmer/fixture compatibility before installation — not all LEDs dim smoothly.
- Include manual override switches for maintenance and emergency situations.
- Document the control system design, including zone maps and sensor locations, for future maintenance.

## Safety

- Lighting control wiring is typically low voltage (0-10V or 24V), but line voltage is present at the fixtures. De-energize before working on fixtures.
- Do not exceed the sensor or dimmer manufacturer''s maximum load ratings.
- Ensure emergency lighting circuits are not controlled by occupancy sensors — they must remain on at all times.
- Use properly rated control cable for the environment (plenum-rated in air handling spaces).
- Verify that the control system does not interfere with life safety systems (fire alarm, emergency lighting).',
      45, true, true,
      '[
        {"question":"What is the difference between an occupancy sensor and a vacancy sensor?","options":["There is no difference","Occupancy sensors turn lights ON and OFF automatically; vacancy sensors require manual ON but turn OFF automatically","Occupancy sensors are for indoor use","Vacancy sensors are for outdoor use"],"correctIndex":1},
        {"question":"Which sensor technology requires line of sight?","options":["Ultrasonic","PIR (passive infrared)","Both","Neither"],"correctIndex":1},
        {"question":"What is the most common LED dimming protocol?","options":["DALI","0-10V DC","Phase-cut dimming","PWM"],"correctIndex":1},
        {"question":"What is daylight harvesting?","options":["Growing plants with lights","Using photocells to dim or switch off fixtures when natural light is sufficient","Turning off all lights during the day","Using solar panels for lighting"],"correctIndex":1},
        {"question":"What is a common cause of nuisance off with occupancy sensors?","options":["Sensor too sensitive","Occupants moving slowly, not triggering the sensor within the timeout period","Low voltage","Wrong sensor type"],"correctIndex":1},
        {"question":"What should the occupancy timeout typically be set to?","options":["1 minute","15-20 minutes","60 minutes","5 seconds"],"correctIndex":1},
        {"question":"What must be ensured for emergency lighting circuits?","options":["They should have occupancy sensors","They must NOT be controlled by occupancy sensors and must remain on at all times","They should use photocells","They should be dimmable"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Networked Lighting & IoT Integration',
      '## Overview

Networked lighting systems connect fixtures, sensors, and controllers to a central management platform, enabling facility-wide control, data collection, and integration with other building systems. The Internet of Things (IoT) extends this by embedding sensors and connectivity into each fixture, turning the lighting system into a platform for building intelligence. Understanding networked lighting is essential for modern industrial facility design.

## Key Concepts

- **Networked lighting control**: A system where fixtures and sensors communicate over a network (wired or wireless) to a central controller or cloud platform. Enables scheduling, zoning, dimming, and monitoring from a single interface.
- **Wireless protocols**: Zigbee, Bluetooth Mesh, LoRaWAN, and Wi-Fi are common wireless protocols for lighting. Each has different range, power, and data characteristics.
- **IoT fixtures**: LED fixtures with embedded sensors (occupancy, light level, temperature) and network connectivity. They can report data and be controlled individually.
- **Building management system (BMS) integration**: Networked lighting can share occupancy and temperature data with the HVAC system, enabling coordinated energy management.
- **Energy monitoring**: Networked systems track energy consumption by zone, fixture, or circuit, providing detailed energy analytics and identifying savings opportunities.

## Step-by-Step: Implementing a Networked Lighting System

1. **Define the objectives**: Determine what the system should achieve — energy savings, occupancy analytics, maintenance alerts, or BMS integration.
2. **Select the protocol**: Choose a wireless or wired protocol based on facility size, construction (metal walls, high ceilings), and IT requirements. Zigbee and Bluetooth Mesh are common for lighting.
3. **Design the network layout**: Plan fixture placement, gateway/repeater locations, and network segmentation. Ensure adequate signal coverage throughout the facility.
4. **Select fixtures and controllers**: Choose IoT-enabled fixtures or add network nodes to standard fixtures. Verify compatibility with the selected protocol.
5. **Install the network infrastructure**: Install gateways, repeaters, and network cabling as needed. Configure the network before installing fixtures.
6. **Commission fixtures**: Add each fixture to the network, assign it to zones, and configure dimming levels and schedules.
7. **Configure the management platform**: Set up the central dashboard with zones, schedules, energy monitoring, and alert thresholds.
8. **Integrate with other systems**: If desired, integrate with the BMS, HVAC, or security systems using APIs or BACnet/Modbus gateways.
9. **Test and verify**: Walk through the facility to verify fixture control, sensor response, and network reliability. Monitor the dashboard for data accuracy.
10. **Train facility staff**: Train maintenance and operations staff on using the management platform and responding to alerts.

## Common Problems

- **Network reliability**: Wireless signals can be blocked by metal walls, machinery, or high-density storage. Plan the network layout carefully and add repeaters as needed.
- **Cybersecurity**: Networked lighting systems connected to the internet can be a cybersecurity vulnerability. Use encrypted protocols and secure the network.
- **Protocol incompatibility**: Fixtures from different manufacturers may not interoperate. Verify compatibility or use a gateway.
- **Commissioning complexity**: Large systems with hundreds of fixtures require significant commissioning time. Plan for this in the project schedule.
- **IT department conflicts**: Networked lighting may conflict with IT network policies. Coordinate with IT early in the design process.

## Best Practices

- Use open protocols (Zigbee, DALI, BACnet) rather than proprietary systems for long-term flexibility.
- Segment the lighting network from the IT network for security and reliability.
- Include a wired fallback for critical lighting circuits in case the wireless network fails.
- Plan for future expansion — select a system that can scale to additional fixtures and sensors.
- Use the energy monitoring data to identify savings opportunities and verify actual savings.
- Include cybersecurity in the system design — encrypt communications, use strong passwords, and keep firmware updated.

## Safety

- Networked lighting does not eliminate the need for emergency lighting — ensure emergency circuits are independent of the network.
- Do not locate wireless repeaters or gateways in hazardous (classified) areas unless rated for the environment.
- Verify that the networked system does not interfere with life safety systems (fire alarm, emergency lighting).
- When installing network cabling, maintain separation from power conductors per NEC requirements.
- Ensure the system has a manual override for maintenance and emergency situations.',
      45, true, true,
      '[
        {"question":"What is a networked lighting control system?","options":["A system with network cables only","A system where fixtures and sensors communicate over a network to a central controller, enabling facility-wide control and monitoring","A system that uses the internet for all lighting","A system with no central control"],"correctIndex":1},
        {"question":"Which wireless protocol is commonly used for lighting networks?","options":["Ethernet","Zigbee","Fiber optic","Coaxial"],"correctIndex":1},
        {"question":"What is an IoT-enabled lighting fixture?","options":["A fixture with internet access","A fixture with embedded sensors (occupancy, light level, temperature) and network connectivity for data reporting and control","A fixture that uses Wi-Fi only","A fixture with a camera"],"correctIndex":1},
        {"question":"What is a key cybersecurity concern with networked lighting?","options":["It uses too much bandwidth","Networked systems connected to the internet can be a cybersecurity vulnerability","It interferes with Wi-Fi","It is too slow"],"correctIndex":1},
        {"question":"What should be done with emergency lighting circuits in a networked system?","options":["Connect them to the network","Ensure they are independent of the network and always on","Use occupancy sensors on them","Dim them during the day"],"correctIndex":1},
        {"question":"What is the advantage of using open protocols (Zigbee, DALI, BACnet)?","options":["They are cheaper","They provide long-term flexibility and interoperability between manufacturers","They are faster","They use less power"],"correctIndex":1},
        {"question":"What should be planned for during a networked lighting project?","options":["Only installation time","Significant commissioning time for large systems with hundreds of fixtures","Only IT approval","Only fixture selection"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 15: Motor Protection & Overcurrent Devices — Add Module 3: Motor Protection Coordination Studies
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Motor Protection & Overcurrent Devices' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Motor Protection Coordination Studies') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Motor Protection Coordination Studies', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Time-Current Curves & Coordination Principles',
      '## Overview

A coordination study ensures that protective devices (fuses, breakers, overload relays) operate in the correct sequence during a fault. The goal is selective coordination: only the device closest to the fault trips, leaving the rest of the system energized. This is achieved by analyzing time-current curves (TCCs) to verify that upstream devices do not trip before downstream devices. Understanding TCCs is essential for designing and maintaining motor protection systems.

## Key Concepts

- **Time-current curve (TCC)**: A logarithmic graph showing the time a protective device takes to trip at a given current. The horizontal axis is current (multiples of FLA or amps), the vertical axis is time (seconds).
- **Selective coordination**: The downstream device trips before the upstream device for all fault currents. The TCC of the downstream device must be below (faster than) the TCC of the upstream device at all current levels.
- **Overload region**: The low-current, long-time region of the curve (typically 1-6 times FLA). Overload relays operate here.
- **Short-circuit region**: The high-current, short-time region (typically 6-25 times FLA). Fuses and breakers operate here.
- **Instantaneous trip**: Some breakers have an instantaneous trip function that operates with no intentional delay at high fault currents. This can defeat coordination if not set correctly.

## Step-by-Step: Performing a Motor Circuit Coordination Study

1. **Gather system data**: Collect motor FLA, starting current, starting time, cable impedance, transformer impedance, and available fault current at the motor.
2. **Plot the motor starting curve**: On log-log paper or software, plot the motor''s starting current (typically 6x FLA) and starting time (typically 5-15 seconds). This is the motor damage curve.
3. **Plot the overload relay TCC**: Plot the overload relay curve at its selected setting (e.g., Class 10, 20, or 30). The overload curve must be above the motor starting curve (to allow starting) and below the motor damage curve (to protect the motor).
4. **Plot the short-circuit device TCC**: Plot the fuse or breaker curve. The short-circuit device curve must be above the overload curve (to allow overload relay to handle overloads) and below the cable damage curve (to protect the cable).
5. **Plot the upstream feeder device TCC**: Plot the upstream feeder breaker or fuse curve. This curve must be above the motor branch circuit device curve at all current levels for selective coordination.
6. **Check for overlaps**: Look for any point where the upstream curve crosses below the downstream curve. This indicates a loss of coordination at that current level.
7. **Adjust settings**: If coordination is lost, adjust the device settings (pickup, time delay, instantaneous) or select different devices to achieve coordination.
8. **Document the study**: Create a coordination study report with the TCC plot, device settings, and conclusions. Include the study in the facility documentation.

## Common Problems

- **Instantaneous trip defeating coordination**: An upstream breaker with an instantaneous trip setting lower than the downstream device''s clearing current will trip first, causing a loss of coordination at high fault currents.
- **Overload setting too high**: An overload relay set above the motor damage curve does not protect the motor.
- **Fuse mismatch**: Using a fuse that is too large allows the cable to be damaged before the fuse clears. Using a fuse that is too small causes nuisance tripping during motor starting.
- **Cable too small**: A cable with ampacity below the motor FLC will overheat before the overload relay trips.
- **Not accounting for motor starting time**: A high-inertia load with a long starting time may trip the overload relay during starting. A Class 30 overload may be needed.

## Best Practices

- Use software (ETAP, SKM, EasyPower) for coordination studies — manual plotting is error-prone.
- Always verify coordination at the maximum available fault current, not just the expected fault current.
- For critical systems (emergency power, life safety), require full selective coordination per NEC 700 and 702.
- Use current-limiting fuses for motor branch circuits to achieve both coordination and equipment protection.
- Document the coordination study and keep it updated when the system changes.
- Include the motor starting curve on the TCC plot to verify the overload relay allows starting.

## Safety

- An uncoordinated system can trip the main breaker for a single motor fault, blacking out the entire facility.
- An overload relay set too high can allow the motor to burn out, creating a fire hazard.
- A fuse that is too large may not protect the cable, causing the cable to overheat and potentially start a fire.
- Always verify coordination after changing any protective device or motor.
- Keep the coordination study available for the Authority Having Jurisdiction (AHJ) to review.',
      50, true, true,
      '[
        {"question":"What is the goal of selective coordination?","options":["All devices trip together","Only the device closest to the fault trips, leaving the rest of the system energized","No devices trip","The main breaker trips first"],"correctIndex":1},
        {"question":"What is a time-current curve (TCC)?","options":["A voltage graph","A logarithmic graph showing the time a protective device takes to trip at a given current","A current graph","A power graph"],"correctIndex":1},
        {"question":"What can defeat selective coordination at high fault currents?","options":["An overload relay","An upstream breaker with an instantaneous trip set lower than the downstream device''s clearing current","A fuse","A motor starter"],"correctIndex":1},
        {"question":"What must the overload relay curve be relative to the motor starting curve?","options":["Below it","Above it (to allow starting) and below the motor damage curve (to protect the motor)","At the same level","Unrelated"],"correctIndex":1},
        {"question":"What happens if the overload relay is set above the motor damage curve?","options":["The motor starts faster","The motor is not protected and may burn out","The fuse blows","The breaker trips"],"correctIndex":1},
        {"question":"What is used to perform coordination studies in modern practice?","options":["Manual plotting on graph paper","Software such as ETAP, SKM, or EasyPower","A calculator","A spreadsheet"],"correctIndex":1},
        {"question":"What should be done after changing any protective device or motor?","options":["Nothing","Verify coordination by updating and reviewing the coordination study","Replace all devices","Reset all settings"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Protective Relay Settings & Motor Differential Protection',
      '## Overview

For large motors (typically above 1500 HP) and critical applications, simple overload relays and fuses are not sufficient. Protective relays (electronic or microprocessor-based) provide more sophisticated protection: thermal modeling, current unbalance, ground fault, and differential protection. Understanding protective relay settings and differential protection is essential for maintaining large industrial motors.

## Key Concepts

- **Microprocessor protective relay**: A digital relay that measures current and voltage, performs calculations, and trips the breaker based on programmable settings. Examples: GE Multilin SR469, Siemens SIPROTEC, ABB REM6xx.
- **Thermal model**: The relay calculates motor heating based on current, time, and cooling constants, providing more accurate overload protection than a simple thermal relay.
- **Current unbalance protection (46)**: Trips the motor if the current unbalance between phases exceeds a set threshold (typically 10-15%), protecting against single-phasing and voltage unbalance.
- **Ground fault protection (50G/51G)**: Detects ground faults using a zero-sequence CT or residual connection. Trips faster than phase protection for ground faults.
- **Differential protection (87M)**: Compares current entering and leaving the motor. Any difference indicates an internal fault. Extremely fast and sensitive — the gold standard for large motor protection.

## Step-by-Step: Setting Up a Motor Protective Relay

1. **Enter motor nameplate data**: Input motor FLA, voltage, frequency, service factor, starting time, and locked rotor current into the relay.
2. **Set thermal overload (49) parameters**: Set the thermal capacity used alarm (typically 90%), trip (100%), and cooling time constant. The relay calculates thermal capacity based on running current and history.
3. **Set current unbalance (46) protection**: Set the unbalance trip threshold (typically 10-15% with a time delay of 5-10 seconds) and alarm threshold (typically 5%).
4. **Set ground fault (50G/51G) protection**: Set the ground fault pickup (typically 5-10% of FLA for industrial motors) and time delay (instantaneous or 0.5-1 second).
5. **Set instantaneous overcurrent (50)**: Set above the motor locked rotor current (typically 1.5-2x LRC) to avoid tripping during starting but trip quickly for close-in short circuits.
6. **Set differential (87M) protection if equipped**: Install CTs on both ends of each phase. Set the differential pickup (typically 5-10% of FLA). Any current difference above this threshold trips immediately.
7. **Set starting protection**: Set the maximum start time (to trip if the motor does not reach speed), starts per hour limit (to prevent overheating from frequent starting), and lockout after too many starts.
8. **Configure alarms and trips**: Set which protections alarm only and which trip the breaker. Critical protections (differential, ground fault) should trip; informational items (unbalance alarm, thermal alarm) can alarm only.
9. **Test the relay**: Inject test current and verify each protection function operates at the correct setting. Document the test results.
10. **Commission**: Verify all CT and VT connections, test the trip circuit, and perform a live test during motor startup.

## Common Problems

- **Incorrect CT polarity for differential**: If CTs on one end of the motor are reversed, the relay sees full current as differential and trips immediately on startup. Verify CT polarity before energizing.
- **Thermal model not matching motor**: If the cooling time constant or service factor is wrong, the relay may trip prematurely or not protect the motor adequately.
- **Instantaneous setting too low**: Set below the locked rotor current, the relay trips every time the motor starts. Set at 1.5-2x LRC.
- **Ground fault setting too sensitive**: Set below the normal leakage current, the relay nuisance-trips. Set at 5-10% of FLA.
- **Starts-per-hour limit too low**: Prevents necessary restarts after a process trip. Adjust based on motor thermal capacity.

## Best Practices

- Use microprocessor protective relays for all motors above 300 HP.
- Use differential protection for motors above 1500 HP or critical applications.
- Document all relay settings in the coordination study and on the relay faceplate.
- Perform annual relay testing with a secondary injection test set.
- Trend relay data (thermal capacity, unbalance, ground fault current) for predictive maintenance.
- Use the relay''s event log to diagnose trips — it records the fault type, current, and time.
- Set up communication (Modbus, Ethernet, IEC 61850) to monitor relay status from a central location.

## Safety

- Differential protection can trip the motor in less than one cycle — ensure personnel are clear before testing.
- Relay testing with a secondary injection set does not de-energize the motor — follow LOTO procedures.
- Never disable differential or ground fault protection to "get through the shift" — this can allow a catastrophic motor failure.
- After a relay trip, investigate the event log before resetting — the relay records the fault type and magnitude.
- Verify CT polarity before energizing a differential-protected motor — incorrect polarity causes immediate tripping.',
      50, true, true,
      '[
        {"question":"What size motor typically requires protective relays instead of simple overload relays?","options":["10 HP and above","100 HP and above","300 HP and above","1500 HP and above"],"correctIndex":2},
        {"question":"What does differential protection (87M) compare?","options":["Voltage and current","Current entering and leaving the motor — any difference indicates an internal fault","Starting current and running current","Phase current and neutral current"],"correctIndex":1},
        {"question":"What is the purpose of the thermal model in a microprocessor relay?","options":["To measure temperature","To calculate motor heating based on current, time, and cooling constants for more accurate overload protection","To measure ambient temperature","To calculate power factor"],"correctIndex":1},
        {"question":"What happens if CTs on one end of the motor are reversed for differential protection?","options":["Nothing","The relay sees full current as differential and trips immediately on startup","The relay does not trip","The motor runs normally"],"correctIndex":1},
        {"question":"What is the typical setting for current unbalance (46) protection?","options":["1%","10-15% with a time delay","50%","100%"],"correctIndex":1},
        {"question":"What should the instantaneous overcurrent (50) setting be for a motor?","options":["Equal to FLA","1.5-2x locked rotor current to avoid tripping during starting","Equal to locked rotor current","Equal to starting current"],"correctIndex":1},
        {"question":"What should be done after a protective relay trips?","options":["Just reset it","Investigate the event log to determine the fault type, current, and time before resetting","Replace the relay","Ignore it"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 16: Motor Starters, Contactors & Overload Relays — Add Module 3: Solid-State Starting & Motor Protection
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Motor Starters, Contactors & Overload Relays' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Solid-State Starting & Motor Protection') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Solid-State Starting & Motor Protection', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Solid-State Overload Relays & Electronic Motor Protection',
      '## Overview

Solid-state (electronic) overload relays have largely replaced bimetallic and eutectic overload relays in modern industrial installations. They offer more accurate protection, additional features like ground fault and phase loss detection, and communication capabilities. Understanding the features, settings, and troubleshooting of solid-state overload relays is essential for modern motor control.

## Key Concepts

- **Solid-state overload relay**: Uses current sensors (CTs or Hall-effect sensors) and a microprocessor to monitor motor current and calculate thermal capacity. More accurate and faster than thermal overload relays.
- **Class selection**: Like thermal relays, solid-state relays are set to a trip class (Class 5, 10, 20, 30). The microprocessor calculates the trip time based on the class and current.
- **Phase loss detection**: Solid-state relays can detect the loss of one phase (single-phasing) and trip the motor within seconds, before damage occurs.
- **Ground fault detection**: Some solid-state relays include ground fault detection using an internal zero-sequence current calculation.
- **Communication**: Many solid-state relays have Modbus, DeviceNet, or Ethernet communication, allowing remote monitoring of motor current, thermal capacity, and trip history.

## Step-by-Step: Setting Up a Solid-State Overload Relay

1. **Enter motor nameplate data**: Input the motor FLA, service factor, and trip class (typically Class 10 or 20) into the relay.
2. **Set the overload current**: Set the relay to the motor FLA from the nameplate (not NEC Table 430.250 — the nameplate is used for overload setting).
3. **Select the trip class**: Class 10 for fast-trip applications (submersible pumps, hermetic compressors), Class 20 for standard applications, Class 30 for high-inertia loads.
4. **Enable phase loss protection**: Set the phase loss trip threshold (typically the relay trips if one phase drops below 70% of average for more than 3 seconds).
5. **Enable ground fault protection if available**: Set the ground fault pickup (typically 30-50% of FLA) and time delay.
6. **Set alarms**: Set the thermal capacity alarm (typically 90%), current unbalance alarm (typically 5%), and any other alarm thresholds.
7. **Configure communication if applicable**: Set the communication address, baud rate, and protocol parameters.
8. **Test the relay**: Inject test current and verify the relay trips at the correct current and time for the selected class.
9. **Document settings**: Record all settings on the relay faceplate and in the motor documentation.

## Common Problems

- **Wrong FLA entered**: Entering the NEC Table 430.250 value instead of the nameplate FLA causes the relay to trip prematurely or not protect the motor adequately.
- **Wrong trip class**: A Class 10 relay on a high-inertia load trips during starting. A Class 30 relay on a submersible pump allows the motor to overheat.
- **Phase loss sensitivity**: Some relays are too sensitive and nuisance-trip on voltage dips. Adjust the threshold or add a time delay.
- **Communication failure**: If the communication network fails, the relay may not report trips or alarms. Verify the network and have local indication as backup.
- **Ambient temperature compensation**: Some solid-state relays require ambient temperature compensation. If not configured, the relay may trip prematurely in hot environments.

## Best Practices

- Use solid-state overload relays for all new motor installations — they provide better protection and more features than thermal relays.
- Always use the motor nameplate FLA for the overload setting, not the NEC Table 430.250 value.
- Select the trip class based on the load type, not just "the same as before."
- Use relays with communication capability for motors above 50 HP to enable remote monitoring and predictive maintenance.
- Trend motor thermal capacity and current data from the relay for predictive maintenance.
- Test solid-state relays annually with a primary or secondary injection test set.

## Safety

- Solid-state relays trip faster than thermal relays — verify the trip class is appropriate for the load before energizing.
- Do not bypass the phase loss or ground fault protection — these features protect against dangerous conditions.
- The relay may store energy in its capacitors after power is removed — wait before touching internal components.
- When testing with injected current, use a properly rated test set and follow the manufacturer''s procedures.
- After a trip, check the relay''s trip indicator and event log to determine the cause before resetting.',
      45, true, true,
      '[
        {"question":"What is the main advantage of a solid-state overload relay over a bimetallic relay?","options":["It is cheaper","More accurate protection, additional features like phase loss and ground fault detection, and communication capabilities","It is smaller","It does not require power"],"correctIndex":1},
        {"question":"What current value should be entered into a solid-state overload relay?","options":["NEC Table 430.250 value","The motor nameplate FLA","The motor starting current","The locked rotor current"],"correctIndex":1},
        {"question":"Which trip class is recommended for high-inertia loads?","options":["Class 5","Class 10","Class 30","Class 50"],"correctIndex":2},
        {"question":"What does phase loss detection in a solid-state relay do?","options":["Detects loss of control power","Detects the loss of one phase (single-phasing) and trips the motor within seconds","Detects loss of communication","Detects ground faults"],"correctIndex":1},
        {"question":"What is a common cause of nuisance tripping with solid-state relays?","options":["Correct FLA entered","Phase loss sensitivity causing trips on voltage dips","Communication failure","Correct trip class"],"correctIndex":1},
        {"question":"What should be done with the motor thermal capacity data from a solid-state relay?","options":["Ignore it","Trend it for predictive maintenance","Delete it","Report it to management"],"correctIndex":1},
        {"question":"What should be checked after a solid-state relay trips?","options":["Just reset it","Check the relay''s trip indicator and event log to determine the cause before resetting","Replace the relay","Increase the FLA setting"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Reversing Starters & Multi-Speed Motor Controls',
      '## Overview

Reversing starters and multi-speed motor controls extend the capabilities of basic motor starters. Reversing starters change the direction of a three-phase motor by swapping two of the three phase leads. Multi-speed controllers use Dahlander or separate-winding motors to provide two or more speeds from a single motor. Understanding these configurations is essential for applications like hoists, conveyors, and fans.

## Key Concepts

- **Reversing starter**: Two contactors (forward and reverse) with the T1 and T3 leads interchanged on the reverse contactor. The motor reverses by energizing the reverse contactor instead of the forward contactor.
- **Mechanical and electrical interlocks**: Both forward and reverse contactors must NEVER be energized simultaneously, as this creates a phase-to-phase short. Mechanical interlocks physically prevent both from closing; electrical interlocks use NC auxiliary contacts to prevent the control circuit from energizing both.
- **Multi-speed motor (Dahlander)**: A single winding with two speeds (typically 1:2 ratio) achieved by changing the connection from series (low speed) to parallel (high speed). Uses a 2-contactor or 3-contactor configuration.
- **Separate winding multi-speed**: Two independent windings in one motor, each with a different pole count, providing two speeds in any ratio. Uses separate contactors for each winding.
- **Braking**: Reversing starters can provide plugging (reverse-current braking) by momentarily energizing the reverse contactor to stop the motor quickly. Requires a zero-speed switch to disconnect at stop.

## Step-by-Step: Wiring a Reversing Motor Starter

1. **Install both contactors**: Mount the forward (F) and reverse (R) contactors side by side in the panel. Install the mechanical interlock between them.
2. **Wire the power circuit**: Connect L1, L2, L3 to the line side of both contactors. On the load side of the forward contactor, connect T1, T2, T3 to the motor. On the load side of the reverse contactor, connect T1 to motor T3, T2 to motor T2, T3 to motor T1 (swap T1 and T3).
3. **Wire the electrical interlocks**: Connect the NC auxiliary contact of the forward contactor in series with the reverse contactor coil. Connect the NC auxiliary contact of the reverse contactor in series with the forward contactor coil. This prevents both from being energized simultaneously.
4. **Wire the control circuit**: Connect the forward start button (NO) in parallel with the forward seal-in contact, through the stop button and overload contact, to the forward coil (through the reverse NC interlock). Repeat for the reverse start button and coil (through the forward NC interlock).
5. **Verify the interlocks**: Before energizing, manually press both contactors and verify the mechanical interlock prevents both from closing simultaneously. Verify the electrical interlocks prevent both coils from being energized.
6. **Test the operation**: Energize the control circuit. Press forward — the motor should run forward. Press stop. Press reverse — the motor should run in reverse. Press both forward and reverse simultaneously — only one should engage (the first one pressed).

## Common Problems

- **Welded interlock**: If the mechanical interlock is damaged or removed, both contactors can close simultaneously, creating a phase-to-phase short that destroys the contactors and may cause an arc flash.
- **Missing electrical interlock**: Without the NC auxiliary contacts, the control circuit can energize both coils, and the mechanical interlock alone may not prevent a short.
- **Wrong phase swap**: Swapping L1 and L2 instead of T1 and T3 does not reverse the motor. The swap must be on the load side, not the line side.
- **No off-delay between forward and reverse**: Immediately reversing a running motor (plugging) causes very high current and mechanical stress. Use a timer or zero-speed switch to ensure the motor has stopped before reversing.
- **Multi-speed contactor sequencing**: On Dahlander motors, the low-speed and high-speed contactors must never be energized simultaneously. Use the same interlocking principles as reversing starters.

## Best Practices

- Always install both mechanical and electrical interlocks on reversing starters — never rely on one alone.
- Use a zero-speed switch or timer to prevent immediate reversal (plugging) unless the application specifically requires it.
- Label forward and reverse contactors and their control buttons clearly (FWD/REV) to prevent operator confusion.
- For multi-speed motors, use a transition timer between speeds to prevent simultaneous contactor closure.
- Include a motor overtemperature sensor (if equipped) in the control circuit for large reversing and multi-speed motors.
- Document the wiring diagram with clear forward/reverse and speed designations.

## Safety

- Never remove or bypass the mechanical interlock on a reversing starter — this can cause a phase-to-phase short and arc flash.
- Verify both interlocks (mechanical and electrical) are functional before energizing a reversing starter.
- Plugging (reverse-current braking) can cause very high current — ensure the contactors and protection are rated for plugging duty.
- On multi-speed motors, verify the contactors are interlocked to prevent simultaneous energization of different speed windings.
- De-energize and lock out before modifying any reversing or multi-speed control circuit.',
      50, true, true,
      '[
        {"question":"How does a reversing starter change the direction of a 3-phase motor?","options":["By changing the voltage","By swapping two of the three phase leads (T1 and T3)","By reversing the control circuit","By changing the frequency"],"correctIndex":1},
        {"question":"What prevents both forward and reverse contactors from closing simultaneously?","options":["Nothing","Mechanical interlocks (physical) and electrical interlocks (NC auxiliary contacts in the control circuit)","A fuse","A timer"],"correctIndex":1},
        {"question":"What happens if both forward and reverse contactors close simultaneously?","options":["The motor runs faster","A phase-to-phase short circuit occurs, potentially destroying the contactors and causing an arc flash","The motor stops","Nothing — the interlocks prevent this"],"correctIndex":1},
        {"question":"What is plugging in the context of reversing starters?","options":["Blocking the motor","Momentarily energizing the reverse contactor to stop the motor quickly (reverse-current braking)","Disconnecting the motor","Slowing the motor gradually"],"correctIndex":1},
        {"question":"What is a Dahlander motor?","options":["A DC motor","A single-winding motor with two speeds (1:2 ratio) achieved by changing from series to parallel connection","A single-speed motor","A variable-speed motor"],"correctIndex":1},
        {"question":"What should be used to prevent immediate reversal of a running motor?","options":["A larger contactor","A zero-speed switch or timer to ensure the motor has stopped before reversing","A fuse","A circuit breaker"],"correctIndex":1},
        {"question":"What must be verified before energizing a reversing starter?","options":["The motor size","Both mechanical and electrical interlocks are functional","The wire color","The panel layout"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 17: Power Quality Basics — Add Module 3: Power Quality Monitoring & Mitigation
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Power Quality Basics' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Power Quality Monitoring & Mitigation') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Power Quality Monitoring & Mitigation', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Power Quality Monitoring & Data Analysis',
      '## Overview

Power quality monitoring is the process of continuously measuring and recording voltage, current, and power quality parameters to identify issues before they cause equipment damage or process interruptions. Modern power quality analyzers can capture harmonics, transients, sags, swells, and flicker, providing the data needed to diagnose and mitigate power quality problems. Understanding how to set up monitoring and interpret the data is essential for maintaining reliable industrial power systems.

## Key Concepts

- **Power quality analyzer**: An instrument that measures and records voltage, current, power, harmonics, transients, and other parameters. Can be portable (for troubleshooting) or permanently installed (for continuous monitoring).
- **RMS voltage and current**: The effective value of AC voltage and current. True RMS measurement is essential for distorted waveforms (nonlinear loads).
- **Harmonic spectrum**: A breakdown of the harmonic content by order (1st, 3rd, 5th, 7th, etc.) and magnitude. Identifies the source and type of harmonic distortion.
- **Transient capture**: Recording short-duration (microseconds to milliseconds) voltage events such as lightning, capacitor switching, and fault clearing.
- **Trending**: Recording parameters over time (days, weeks, months) to identify patterns and gradual degradation.

## Step-by-Step: Setting Up Power Quality Monitoring

1. **Define the monitoring objective**: Determine what you are looking for — harmonics, sags, transients, unbalance, or general power quality assessment.
2. **Select the monitoring location**: Install the analyzer at the point of common coupling (PCC) for compliance monitoring, or at the suspect load for troubleshooting.
3. **Select the analyzer**: Choose a portable analyzer for short-term monitoring or a permanently installed meter for continuous monitoring. Ensure it measures the required parameters.
4. **Install CTs and PTs**: Install current transformers (CTs) and potential transformers (PTs) or direct voltage connections per the analyzer manufacturer''s instructions. Verify CT polarity and ratio.
5. **Configure the analyzer**: Set the recording interval (e.g., 1-minute averages), transient capture threshold (e.g., 10% above nominal), and harmonic recording (up to 50th order).
6. **Start monitoring**: Let the analyzer record for at least one full business cycle (typically 1 week) to capture all operating conditions.
7. **Download and analyze data**: Transfer the data to a computer and use the analyzer software to generate reports. Look for events, trends, and patterns.
8. **Interpret the results**: Compare measured values to IEEE 519 limits, equipment tolerance curves (ITIC/CBEMA), and historical data. Identify the root cause of any violations.
9. **Recommend mitigation**: Based on the analysis, recommend mitigation measures (filters, line reactors, UPS, etc.) and verify their effectiveness after installation.

## Common Problems

- **Incorrect CT installation**: Reversed CTs produce negative power readings. Wrong CT ratio produces incorrect current values. Always verify CT polarity and ratio.
- **Inadequate monitoring duration**: A one-day snapshot may miss events that occur weekly or monthly. Monitor for at least one full operating cycle.
- **Misinterpreting transients**: Not all transients are harmful. Capacitor switching transients are normal; lightning transients require surge protection.
- **Confusing cause and effect**: A voltage sag may be caused by a motor start, not a utility problem. Correlate events with facility operations.
- **Data overload**: Modern analyzers produce massive amounts of data. Focus on events and trends, not every data point.

## Best Practices

- Use true RMS analyzers for nonlinear loads — average-responding meters underread distorted waveforms.
- Install permanent power quality monitoring at the main service entrance and at critical loads.
- Monitor for at least one week to capture all operating conditions and shift patterns.
- Compare power quality data to equipment operation logs to correlate events with causes.
- Use the ITIC/CBEMA curve to evaluate voltage events against equipment tolerance.
- Trend power quality data over time to identify gradual degradation.
- Share power quality data with the utility — they may be able to mitigate utility-side issues.

## Safety

- Install CTs and voltage connections only on de-energized equipment, or use clamp-on CTs and insulated voltage probes for energized installations.
- Use analyzers and probes rated for the voltage category (CAT III or CAT IV) of the installation.
- Follow the analyzer manufacturer''s safety instructions for connection and disconnection.
- Never leave an analyzer connected without proper strain relief on CTs and voltage leads.
- Be aware that CT secondary circuits can develop dangerous voltages if open-circuited — always short the CT secondary before disconnecting.',
      50, true, true,
      '[
        {"question":"What is the purpose of power quality monitoring?","options":["To reduce energy costs","To continuously measure and record voltage, current, and power quality parameters to identify issues before they cause damage","To improve power factor","To measure motor speed"],"correctIndex":1},
        {"question":"What is the recommended minimum monitoring duration for a power quality study?","options":["1 hour","1 day","1 week (one full operating cycle)","1 month"],"correctIndex":2},
        {"question":"What is the ITIC/CBEMA curve used for?","options":["To measure harmonics","To evaluate voltage events against equipment tolerance (duration vs magnitude)","To size transformers","To calculate power factor"],"correctIndex":1},
        {"question":"What is a common error when installing CTs for power quality monitoring?","options":["Using the wrong color wire","Reversed CTs producing negative power readings, or wrong CT ratio producing incorrect values","Using too many CTs","Installing CTs on the wrong phase"],"correctIndex":1},
        {"question":"Why must true RMS analyzers be used for nonlinear loads?","options":["They are cheaper","Average-responding meters underread distorted waveforms, leading to incorrect measurements","They are faster","They use less power"],"correctIndex":1},
        {"question":"What is the purpose of transient capture in a power quality analyzer?","options":["To measure steady-state voltage","To record short-duration voltage events such as lightning, capacitor switching, and fault clearing","To measure harmonics","To measure power factor"],"correctIndex":1},
        {"question":"What must be done before disconnecting a CT from an energized circuit?","options":["Nothing","Short the CT secondary to prevent dangerous voltages from developing on an open CT","Turn off the analyzer","Wear gloves"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Power Quality Mitigation Solutions',
      '## Overview

Once a power quality problem is identified through monitoring, mitigation solutions can be designed and implemented. The choice of mitigation depends on the type and severity of the problem: harmonics require filters, sags require UPS or voltage regulators, transients require surge protection, and power factor requires capacitors or active correction. Understanding the available solutions and when to apply each is essential for resolving power quality issues.

## Key Concepts

- **Passive harmonic filters**: Tuned LC circuits that shunt specific harmonic frequencies to ground. Effective for a specific harmonic order but can cause resonance.
- **Active harmonic filters**: Power electronic devices that inject equal and opposite harmonic current to cancel the distortion. More flexible than passive filters but more expensive.
- **UPS systems**: Provide clean, regulated power and ride-through for sags and momentary outages. Online (double conversion) UPS provides the best power quality.
- **Voltage regulators**: Automatically adjust output voltage to compensate for sags and swells. Include tap changers, ferroresonant, and electronic types.
- **Surge protective devices (SPDs)**: Divert transient overvoltages (lightning, switching) to ground, protecting downstream equipment. Installed at the service entrance and at point-of-use.
- **Power factor correction capacitors**: Improve power factor by supplying reactive power. Must be carefully applied to avoid resonance with system inductance.

## Step-by-Step: Selecting and Implementing a Power Quality Mitigation Solution

1. **Identify the problem type**: From the monitoring data, determine if the issue is harmonics, sags, swells, transients, flicker, or power factor.
2. **Quantify the severity**: Determine the magnitude and frequency of the events. Compare to IEEE 519 limits, ITIC curve, or equipment specifications.
3. **Identify the source**: Determine whether the problem is internal (facility loads) or external (utility). This affects the mitigation approach.
4. **Evaluate mitigation options**: For harmonics: passive or active filters, line reactors, multi-pulse drives. For sags: UPS, voltage regulator, or flywheel. For transients: SPDs. For power factor: capacitors or active correction.
5. **Perform a cost-benefit analysis**: Compare the cost of each option to the cost of the problem (downtime, equipment damage, energy penalties). Select the most cost-effective solution.
6. **Design the solution**: Size the mitigation equipment, select the installation location, and design the electrical connections. Verify compatibility with existing equipment.
7. **Install the solution**: Install the mitigation equipment per the manufacturer''s instructions and NEC requirements. Coordinate with facility operations for any required downtime.
8. **Verify effectiveness**: After installation, repeat the power quality monitoring to verify the problem is resolved. Compare pre- and post-mitigation data.
9. **Document the solution**: Record the problem, the selected mitigation, the installation details, and the verification results. Include this in the facility documentation.

## Common Problems

- **Resonance with power factor capacitors**: Adding capacitors to a system with harmonic sources can cause resonance, amplifying harmonics and damaging the capacitors. Use detuned capacitor banks.
- **Oversized UPS**: Installing a UPS that is too large for the load wastes energy (double conversion losses) and money. Size the UPS to the actual critical load.
- **Wrong SPD location**: An SPD at the service entrance does not protect equipment on a remote panel. Install SPDs at the service entrance AND at point-of-use for sensitive equipment.
- **Passive filter mistuning**: A passive filter tuned to the 5th harmonic can drift over time due to capacitor degradation, reducing effectiveness or causing resonance.
- **Mitigation without monitoring**: Installing mitigation equipment without first monitoring the problem leads to incorrect sizing and ineffective solutions.

## Best Practices

- Always perform power quality monitoring before selecting mitigation equipment.
- Use active harmonic filters for facilities with many VFDs and variable harmonic profiles.
- Install SPDs at the service entrance (Type 1) and at panelboards feeding sensitive equipment (Type 2).
- Use detuned power factor correction capacitor banks to prevent resonance with harmonics.
- Size UPS systems to the actual critical load plus 20% margin for future growth.
- Verify mitigation effectiveness with post-installation monitoring.
- Consider the total cost of ownership, not just the purchase price, when selecting mitigation equipment.

## Safety

- Capacitor banks store energy after disconnection — wait the manufacturer-specified discharge time before touching.
- SPDs may be destroyed by a large surge — inspect them after any major electrical event and replace if the indicator shows failure.
- UPS batteries contain hazardous materials — follow environmental and safety procedures for battery handling and disposal.
- Active harmonic filters are power electronic devices that generate heat — ensure adequate ventilation.
- All mitigation equipment must be installed per NEC requirements and manufacturer instructions. Improper installation can create new hazards.',
      45, true, true,
      '[
        {"question":"What is the difference between a passive and active harmonic filter?","options":["There is no difference","Passive filters are tuned LC circuits for specific harmonics; active filters inject opposite harmonic current to cancel distortion and are more flexible","Passive filters are cheaper and better","Active filters are only for large systems"],"correctIndex":1},
        {"question":"What is the best solution for protecting equipment from voltage sags?","options":["A larger transformer","A UPS system or voltage regulator","A surge protector","A capacitor bank"],"correctIndex":1},
        {"question":"What problem can occur when adding power factor correction capacitors to a system with harmonics?","options":["Nothing","Resonance that amplifies harmonics and can damage the capacitors","Improved power factor","Reduced harmonics"],"correctIndex":1},
        {"question":"How can resonance with power factor capacitors be prevented?","options":["Remove the capacitors","Use detuned capacitor banks with series reactors","Add more capacitors","Use smaller capacitors"],"correctIndex":1},
        {"question":"Where should surge protective devices (SPDs) be installed?","options":["Only at the service entrance","At the service entrance (Type 1) AND at panelboards feeding sensitive equipment (Type 2)","Only at the equipment","Only at the transformer"],"correctIndex":1},
        {"question":"What should be done before selecting power quality mitigation equipment?","options":["Buy the most expensive solution","Perform power quality monitoring to identify and quantify the problem","Ask the utility","Replace all equipment"],"correctIndex":1},
        {"question":"What should be done after installing power quality mitigation equipment?","options":["Nothing","Repeat the power quality monitoring to verify the problem is resolved","Replace the equipment","Increase the load"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;
