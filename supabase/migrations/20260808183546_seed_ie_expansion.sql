/*
# Seed ForgeLine catalog — I&E Instrumentation & Electrical expansion (13 new courses)

## Overview
Adds 13 new premium I&E courses to the catalog, expanding the I&E track from
5 to 18 courses. Each course has 2-3 modules with 2-3 lessons, professional
plant-floor content, and at least one knowledge-check quiz per lesson. No
existing courses are modified.

## Courses added (sort_order 6-18)
1. Pressure Measurement & Transmitters (6)
2. Temperature Measurement (RTD, Thermocouple, Infrared) (7)
3. Flow Measurement Technologies (8)
4. Level Measurement (Radar, Ultrasonic, Differential) (9)
5. Process Analyzers & Sample Conditioning Systems (10)
6. Smart Valve Positioners & Digital Feedback (11)
7. Safety Instrumented Systems (SIS) Fundamentals (12)
8. Calibration Management & Metrology (13)
9. Wireless Instrumentation & Remote I/O (14)
10. PROFIBUS, PROFINET & Field Device Networks (15)
11. HART Advanced Diagnostics & Device Management (16)
12. Control Loop Performance Monitoring (17)
13. Instrument Installation Practices & Best Practices (18)

## Security
No schema or policy changes. INSERT is allowed only for service role / SQL execution.

## Notes
1. Uses ON CONFLICT DO NOTHING keyed on (stage, title) so re-running is safe.
2. Each DO $$ block looks up the course by (stage, title) and returns early if not found.
3. Quizzes are JSON arrays: [{question, options:[...], correctIndex:0}].
*/

INSERT INTO courses (title, description, short_description, stage, tier, difficulty, estimated_hours, sort_order)
VALUES
('Pressure Measurement & Transmitters',
 'Configure, calibrate, and troubleshoot industrial pressure transmitters. Covers pressure types (gauge, absolute, differential), diaphragm seals, impulse lines, zero suppression/elevation, and 4-20 mA loop integration for process pressure measurement.',
 'Pressure transmitter selection, calibration, impulse lines, and loop integration.',
 'ie','premium','intermediate',3,6),
('Temperature Measurement (RTD, Thermocouple, Infrared)',
 'Industrial temperature measurement fundamentals. Covers RTD vs thermocouple selection, 2-wire/3-wire/4-wire RTD circuits, thermocouple types and cold junction compensation, and infrared pyrometry for surface and process temperature.',
 'RTD, thermocouple, and infrared temperature measurement and troubleshooting.',
 'ie','premium','intermediate',3,7),
('Flow Measurement Technologies',
 'Industrial flow measurement technologies and their application. Covers differential pressure (orifice, venturi), electromagnetic, vortex, Coriolis mass, and ultrasonic flow meters with selection criteria and troubleshooting.',
 'DP, magnetic, vortex, Coriolis, and ultrasonic flow meter selection and troubleshooting.',
 'ie','premium','advanced',3.5,8),
('Level Measurement (Radar, Ultrasonic, Differential)',
 'Industrial level measurement technologies. Covers differential pressure, ultrasonic, radar (FMCW and pulse), guided wave radar, capacitance, and hydrostatic level measurement with application selection and troubleshooting.',
 'Radar, ultrasonic, DP, and guided wave level measurement and troubleshooting.',
 'ie','premium','intermediate',3,9),
('Process Analyzers & Sample Conditioning Systems',
 'Maintain process analyzers (pH, ORP, conductivity, oxygen, gas chromatograph) and their sample conditioning systems. Covers probe selection, calibration, sample system design, and common analyzer faults.',
 'pH, ORP, conductivity, gas analyzers, and sample conditioning system design.',
 'ie','premium','advanced',4,10),
('Smart Valve Positioners & Digital Feedback',
 'Configure and troubleshoot smart digital valve positioners. Covers HART and Foundation Fieldbus positioners, partial stroke testing, valve signature diagnostics, and integration with asset management systems.',
 'Digital valve positioners, partial stroke testing, and valve signature diagnostics.',
 'ie','premium','intermediate',3,11),
('Safety Instrumented Systems (SIS) Fundamentals',
 'Introduction to Safety Instrumented Systems per IEC 61511. Covers SIS architecture, SIL verification, proof testing, bypass management, and the relationship between BPCS and SIS in process safety.',
 'SIS architecture, SIL verification, proof testing, and bypass management per IEC 61511.',
 'ie','premium','advanced',4,12),
('Calibration Management & Metrology',
 'Build and maintain a calibration program for process instrumentation. Covers calibration intervals, traceability, uncertainty, as-found/as-left data, and managing a calibration system per ISA and ISO 17025 principles.',
 'Calibration intervals, traceability, uncertainty, and calibration program management.',
 'ie','premium','intermediate',3,13),
('Wireless Instrumentation & Remote I/O',
 'Deploy and maintain wireless instrumentation networks (ISA 100, WirelessHART) and remote I/O systems. Covers network design, gateway configuration, battery life management, and troubleshooting wireless links.',
 'WirelessHART, ISA 100, remote I/O, and wireless network troubleshooting.',
 'ie','premium','intermediate',2.5,14),
('PROFIBUS, PROFINET & Field Device Networks',
 'Configure and troubleshoot PROFIBUS DP/PA and PROFINET networks. Covers topology, addressing, GSD files, diagnostic tools, and common network faults in industrial process and discrete applications.',
 'PROFIBUS DP/PA, PROFINET, topology, GSD files, and network troubleshooting.',
 'ie','premium','advanced',3.5,15),
('HART Advanced Diagnostics & Device Management',
 'Advanced HART diagnostics and asset management using a HART gateway or fieldbus coupler. Covers NAMUR NE 107 status signals, device alerts, predictive diagnostics, and integration with CMMS for maintenance workflow.',
 'NAMUR NE 107, device alerts, predictive diagnostics, and HART asset management.',
 'ie','premium','intermediate',3,16),
('Control Loop Performance Monitoring',
 'Monitor and diagnose control loop performance using statistical and frequency-domain methods. Covers oscillation detection, stiction diagnosis, performance indices, and prioritizing loop maintenance for maximum impact.',
 'Oscillation detection, stiction diagnosis, and loop performance benchmarking.',
 'ie','premium','advanced',3,17),
('Instrument Installation Practices & Best Practices',
 'Proper instrument installation per ISA and PIP standards. Covers impulse line routing, tubing and fittings, thermowell installation, grounding, lightning protection, and commissioning best practices for reliable measurement.',
 'Impulse lines, tubing, thermowells, grounding, and instrument commissioning.',
 'ie','premium','intermediate',3,18)
ON CONFLICT DO NOTHING;

-- ===================== Pressure Measurement & Transmitters =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Pressure Measurement & Transmitters';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Pressure Fundamentals & Transmitter Types', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Gauge, Absolute & Differential Pressure',
   'Pressure is measured relative to a reference. Gauge pressure is measured relative to atmospheric pressure — it reads zero at ambient. Absolute pressure is measured relative to a vacuum — it reads approximately 14.7 PSI at sea level. Differential pressure (DP) is the difference between two pressures — it is the most versatile measurement because it measures flow (across an orifice), level (hydrostatic head), and filter condition (across a filter). A DP transmitter has two ports (high and low) and measures the difference between them. For flow measurement, the high side connects upstream of the orifice (higher pressure) and the low side downstream (lower pressure). For level measurement in an open tank, the high side connects to the bottom of the tank (hydrostatic pressure) and the low side is vented to atmosphere. For a closed (pressurized) tank, the low side connects to the top of the tank to cancel the tank pressure, leaving only the hydrostatic head. This is called a dry reference leg. A wet reference leg (filled with a known fluid) is used when the tank vapor condenses and would fill a dry leg. Always verify the transmitter range matches the expected measurement span — a transmitter ranged 0-100 PSI measuring a 5 PSI signal has poor resolution.',
   50, 1,
   '[{"question":"What does a gauge pressure transmitter read at atmospheric pressure?","options":["14.7 PSI","Zero","1 bar","1 atm"],"correctIndex":1},{"question":"In a closed tank level measurement, what does the low side of the DP transmitter connect to?","options":["Atmosphere","The bottom of the tank","The top of the tank","A reference seal"],"correctIndex":2}]'),
  (m_id, 'Diaphragm Seals & Impulse Lines',
   'Impulse lines connect the process to the transmitter. They must be routed to drain (for liquids) or vent (for gases) and must not trap sediment or air. A trapped air bubble in a liquid impulse line causes a measurement error equal to the bubble height. A trapped liquid in a gas line causes a measurement error equal to the liquid head. For corrosive, viscous, or high-temperature processes, a diaphragm seal isolates the transmitter from the process. The seal is a thin flexible diaphragm that transmits pressure through a capillary filled with silicone oil. The capillary length affects the temperature sensitivity — a 10 degree C change in the capillary causes a 0.1% span shift per meter of capillary. Keep capillaries short and at the same temperature on both sides (high and low) to cancel the effect. For DP flow measurement, the impulse lines should be at the same elevation and the same length to cancel the head difference. Freeze protection: trace and insulate impulse lines that may freeze in cold weather — a frozen line blocks the pressure and the transmitter reads a false value.',
   45, 2,
   '[{"question":"What does a trapped air bubble in a liquid impulse line cause?","options":["Nothing","A measurement error equal to the bubble height","A complete blockage","A zero shift"],"correctIndex":1},{"question":"How do you cancel the temperature effect of capillary lines on a diaphragm seal?","options":["Use shorter capillaries","Keep both capillaries at the same temperature and length","Insulate the capillaries","Use a different fill fluid"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Calibration & Troubleshooting', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Zero, Span & Loop Integration',
   'A pressure transmitter is calibrated by setting the zero (4 mA at the lower range value, LRV) and the span (20 mA at the upper range value, URV). A 5-point calibration checks the transmitter at 0, 25, 50, 75, and 100% of span. The as-found data (before adjustment) reveals drift; the as-left data (after adjustment) confirms the calibration. For a DP transmitter on flow measurement, the output is linear in pressure but the flow is the square root of the DP — the transmitter either extracts the square root internally or the DCS does it. Verify which one does it — if both do it, the reading is the square root of the square root, which is wrong. Zero suppression and elevation are used when the impulse line has a static head. Zero suppression: the transmitter is below the tap and the liquid column adds pressure — subtract the head from the reading. Zero elevation: the transmitter is above the tap and the static head subtracts — add the head. A transmitter that drifts more than 0.5% of span between calibrations has a sensor issue and should be evaluated for replacement. Always document the calibration with the instrument tag, the date, the standard used, the as-found, and the as-left data.',
   50, 1,
   '[{"question":"What happens if both the transmitter and the DCS extract the square root of the DP?","options":["Correct reading","The reading is the square root of the square root, which is wrong","No effect","The reading doubles"],"correctIndex":1},{"question":"What does zero suppression correct for?","options":["A transmitter above the tap","A transmitter below the tap where the liquid column adds pressure","A zeroed transmitter","A span error"],"correctIndex":1}]');
END $$;

-- ===================== Temperature Measurement (RTD, Thermocouple, Infrared) =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Temperature Measurement (RTD, Thermocouple, Infrared)';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'RTD & Thermocouple Fundamentals', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'RTD Selection & Wire Circuits',
   'A Resistance Temperature Detector (RTD) measures temperature by the change in resistance of a metal (typically platinum, Pt100 at 0 degrees C) with temperature. The resistance increases approximately 0.385 ohms per degree C for a Pt100. The 2-wire RTD is the simplest but the lead wire resistance adds to the measurement, causing an error — a 10-ohm lead on a Pt100 (100 ohms at 0C) causes a 26-degree C error. The 3-wire RTD is the industrial standard — one lead carries the excitation current, and the other two measure the voltage drop at the RTD, canceling the lead resistance if the leads are equal. The 4-wire RTD is the most accurate — two leads carry the current and two measure the voltage, completely eliminating the lead resistance. Always use 3-wire or 4-wire for industrial applications. The transmitter supplies the excitation current (typically 1 mA) and converts the resistance to a 4-20 mA signal. Verify the RTD type (Pt100, Pt1000, Ni) matches the transmitter configuration — a mismatch produces a large error. RTDs are more accurate and stable than thermocouples but have a lower temperature range (-200 to 850C) and are more fragile.',
   50, 1,
   '[{"question":"What error does a 10-ohm lead wire cause on a 2-wire Pt100 RTD?","options":["0.1 degrees C","2.6 degrees C","26 degrees C","100 degrees C"],"correctIndex":2},{"question":"Which RTD circuit completely eliminates lead wire resistance?","options":["2-wire","3-wire","4-wire","None"],"correctIndex":2}]'),
  (m_id, 'Thermocouple Types & Cold Junction Compensation',
   'A thermocouple generates a small voltage (millivolts) proportional to the temperature difference between the hot junction (the measurement point) and the cold junction (the reference). The thermocouple type (J, K, T, N, etc.) defines the voltage-temperature relationship and the usable range. Type J (iron-constantan, -40 to 750C) is common for general industrial use. Type K (chromel-alumel, -200 to 1250C) is the most common general-purpose thermocouple with a wide range. Type T (copper-constantan, -200 to 350C) is used for low temperatures. The cold junction is at the transmitter or the terminal block, where the thermocouple wire connects to copper wire. The transmitter measures the cold junction temperature with an RTD or thermistor and adds the equivalent voltage to the thermocouple reading — this is cold junction compensation (CJC). If the CJC fails, the reading is off by the cold junction temperature (typically 25 degrees C). Always use thermocouple extension wire of the same type as the thermocouple — using copper wire from the thermocouple to the transmitter creates a second thermocouple at the junction, producing an error. Verify the thermocouple type matches the transmitter configuration.',
   50, 2,
   '[{"question":"What does cold junction compensation (CJC) do?","options":["Measures the hot junction","Measures the cold junction temperature and adds the equivalent voltage to the thermocouple reading","Eliminates the need for a thermocouple","Calibrates the transmitter"],"correctIndex":1},{"question":"What happens if copper wire is used instead of thermocouple extension wire?","options":["Nothing — copper is fine","A second thermocouple is created at the junction, producing an error","The reading is more accurate","The transmitter fails"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Infrared & Installation', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Infrared Pyrometry & Thermowell Installation',
   'Infrared pyrometers measure temperature by detecting the infrared radiation emitted by a surface, without contact. They are used for moving surfaces (conveyor belts, rotating kilns), high-temperature surfaces (furnace tubes), and surfaces that cannot be touched (electrical bus). The pyrometer reads the surface temperature, not the internal temperature — the emissivity of the surface determines the accuracy. Set the emissivity to match the surface (0.95 for most non-metallic, 0.1-0.3 for bare metal). For bare metal, apply a high-emissivity coating (paint or tape) at the measurement point. A thermowell protects the temperature sensor in a process by inserting a closed-end tube into the process and mounting the sensor inside. The thermowell must be long enough for the sensor to reach the process temperature (typically 3-5 diameters into the pipe) and strong enough to withstand the flow velocity (check the Murfree or ASME PTC 19.3 calculation for the wake frequency). A thermowell that resonates with the flow vortices fails by fatigue — always verify the thermowell is rated for the process velocity. Install the thermowell in a way that allows sensor removal without opening the process — a threaded or flanged thermowell can be removed under pressure if the process is not toxic.',
   50, 1,
   '[{"question":"What does an infrared pyrometer measure?","options":["Internal temperature","Surface temperature","Air temperature","Pipe wall temperature"],"correctIndex":1},{"question":"What causes a thermowell to fail by fatigue?","options":["High temperature","Resonance with flow vortices (wake frequency)","Corrosion","Overpressure"],"correctIndex":1}]');
END $$;

-- ===================== Flow Measurement Technologies =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Flow Measurement Technologies';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Differential Pressure & Electromagnetic Flow', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Orifice, Venturi & Magnetic Flow Meters',
   'Differential pressure (DP) flow measurement is the oldest and most common method. An orifice plate creates a pressure drop proportional to the square of the flow rate (Bernoulli principle). The DP transmitter measures the drop, and the flow is calculated as Q = K x sqrt(DP). The orifice plate must be sharp-edged, concentric, and installed with the correct straight-run requirements (typically 10 diameters upstream and 5 downstream) to ensure a stable flow profile. A worn orifice edge shifts the calibration. A venturi tube uses a smooth converging-diverging profile instead of a sharp plate — it has a lower permanent pressure loss and is more accurate but more expensive. An electromagnetic (mag) flow meter measures the voltage induced when a conductive fluid passes through a magnetic field (Faraday law). It requires the fluid to be conductive (water, acids, bases — not hydrocarbons or deionized water). The mag meter has no obstruction, no pressure loss, and is accurate over a wide range. Verify the fluid conductivity meets the meter requirement (typically above 5 microsiemens/cm). Ground the meter per the manufacturer — a poor ground causes noise and erratic readings.',
   55, 1,
   '[{"question":"What is the relationship between flow and DP across an orifice plate?","options":["Flow is proportional to DP","Flow is proportional to the square root of DP","Flow is proportional to DP squared","Flow is inversely proportional to DP"],"correctIndex":1},{"question":"What is the minimum fluid conductivity for a magnetic flow meter?","options":["0.5 microsiemens/cm","5 microsiemens/cm","50 microsiemens/cm","500 microsiemens/cm"],"correctIndex":1}]'),
  (m_id, 'Vortex, Coriolis & Ultrasonic Flow Meters',
   'A vortex flow meter detects the vortices shed by a bluff body in the flow (Karman vortex street). The vortex frequency is proportional to the flow velocity. It has no moving parts and handles liquids, gases, and steam. The minimum flow is limited by the Reynolds number — below a certain flow, no vortices are shed and the meter reads zero. A Coriolis mass flow meter measures mass flow directly by detecting the twist in a vibrating tube caused by the Coriolis force. It is the most accurate flow meter (0.1% of rate) and measures mass, density, and temperature simultaneously. It is expensive and has a pressure drop but is the standard for custody transfer and batching. An ultrasonic flow meter measures flow by the time difference between an ultrasonic pulse traveling upstream and downstream. A clamp-on ultrasonic meter installs on the outside of the pipe without cutting — ideal for temporary or retrofit installations. Verify the pipe is full (a partially full pipe gives a false reading) and the pipe wall is clean (scale or paint attenuates the signal). For all flow meters, verify the meter is installed with the correct straight-run and the correct orientation (some meters require horizontal installation, others allow vertical).',
   50, 2,
   '[{"question":"What does a Coriolis flow meter measure directly?","options":["Volumetric flow","Mass flow","Velocity","Differential pressure"],"correctIndex":1},{"question":"What causes a clamp-on ultrasonic flow meter to give a false reading?","options":["A full pipe","A partially full pipe or scale/paint on the pipe wall","High temperature","Low flow rate"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Selection & Troubleshooting', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Flow Meter Selection & Common Faults',
   'Selecting the right flow meter depends on the fluid (liquid, gas, steam), the conductivity, the cleanliness (solids content), the accuracy requirement, the flow range (turndown), the pressure loss budget, and the cost. For clean water: a mag meter is the first choice (no obstruction, high accuracy, wide turndown). For hydrocarbons: a Coriolis (mass) or a turbine (volume). For steam: a vortex or a DP orifice. For dirty fluids with solids: a mag meter (no obstruction) or a Coriolis (no obstruction). For large pipes with budget constraints: a clamp-on ultrasonic. Common faults: a DP orifice that reads low has a worn orifice edge or a plugged impulse line — verify the orifice and blow down the lines. A mag meter that reads zero has an empty pipe or a failed coil — verify the pipe is full and check the coil resistance. A Coriolis that drifts has a coating on the tubes or a zero shift — perform a zero calibration with the flow stopped. A vortex that reads zero at low flow is below the minimum Reynolds — verify the flow rate or select a different meter. Always trend the flow reading against a reference (a tank level or a pump curve) to detect drift.',
   50, 1,
   '[{"question":"Which flow meter is the first choice for clean water?","options":["Orifice plate","Coriolis","Magnetic flow meter","Vortex"],"correctIndex":2},{"question":"What causes a Coriolis flow meter to drift?","options":["A worn orifice","A coating on the tubes or a zero shift","An empty pipe","Low Reynolds number"],"correctIndex":1}]');
END $$;

-- ===================== Level Measurement (Radar, Ultrasonic, Differential) =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Level Measurement (Radar, Ultrasonic, Differential)';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Non-Contact Level Measurement', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Ultrasonic & Radar Level Measurement',
   'Ultrasonic level transmitters emit a sound pulse and measure the time of flight to the surface and back. They are non-contact, easy to install, and inexpensive, but are affected by vapor, foam, and turbulence on the surface. The sound speed in air varies with temperature and composition — a temperature sensor in the transmitter compensates for air temperature, but a vapor composition change (e.g., a solvent evaporating) shifts the sound speed and causes an error. Radar level transmitters emit a microwave pulse (or a frequency-modulated continuous wave, FMCW) and measure the time of flight. Radar is unaffected by vapor, foam, or temperature, and works in vacuum and pressure vessels. FMCW radar is more accurate than pulse radar because it measures frequency, not time, and is less affected by noise. For a turbulent surface, use a stilling well (a vertical tube with holes that calms the surface) to give the radar a stable target. For a tank with internal structures (agitators, heating coils), use a guided wave radar (GWR) — the radar pulse travels down a probe rod and reflects off the surface, ignoring the tank internals. GWR works in narrow, tall tanks where non-contact radar cannot be installed.',
   50, 1,
   '[{"question":"What affects an ultrasonic level transmitter that does NOT affect a radar?","options":["Temperature","Vapor, foam, and turbulence on the surface","Pressure","Tank height"],"correctIndex":1},{"question":"What is a guided wave radar (GWR) used for?","options":["Open channels","Narrow, tall tanks with internal structures where non-contact radar cannot be used","High-temperature applications","Low-pressure applications"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Contact & Hydrostatic Level', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'DP, Capacitance & Hydrostatic Level Measurement',
   'Differential pressure level measurement uses the hydrostatic head (the pressure exerted by the liquid column) to infer the level: P = rho x g x h, where rho is the density, g is gravity, and h is the height. A DP transmitter with the high side at the bottom of the tank and the low side at the top (for a closed tank) measures the level. The measurement is density-dependent — a density change (e.g., a different product in the tank) shifts the calibration. For a tank with a varying density, use a radar instead. Capacitance level measurement uses a probe in the tank as one plate of a capacitor and the tank wall as the other — the capacitance changes with the level. It works for liquids and solids (powders, granules) and handles high temperature and pressure. A capacitance probe must be calibrated for the specific product — a different dielectric constant changes the reading. A hydrostatic level transmitter (a submersible pressure transmitter) is placed at the bottom of an open tank or sump and measures the hydrostatic pressure directly. It is simple and reliable for open tanks and sumps. For all level measurements, verify the tank is vented (for open tanks) or the reference leg is correct (for closed tanks) — a blocked vent or reference leg causes a false reading.',
   50, 1,
   '[{"question":"What is the relationship between hydrostatic pressure and level?","options":["P = rho x g x h (pressure equals density times gravity times height)","P = h (pressure equals height)","P = rho x h (pressure equals density times height)","P = g x h"],"correctIndex":0},{"question":"What causes a DP level measurement to shift calibration?","options":["A temperature change","A density change (different product in the tank)","A pressure change","A flow change"],"correctIndex":1}]');
END $$;

-- ===================== Process Analyzers & Sample Conditioning Systems =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Process Analyzers & Sample Conditioning Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Analyzer Types & Calibration', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'pH, ORP, Conductivity & Oxygen Analyzers',
   'A pH analyzer measures the hydrogen ion concentration (acidity or alkalinity) using a glass electrode and a reference electrode. The glass electrode generates a voltage proportional to the pH (the Nernst equation: 59.2 mV per pH unit at 25C). The reference electrode provides a stable reference voltage. Calibration uses two buffer solutions (typically pH 4 and pH 7) — the slope between the two should be 95-105% of the theoretical 59.2 mV/pH. A slope below 90% indicates a degraded glass electrode that needs cleaning or replacement. ORP (oxidation-reduction potential) measures the electron activity in a solution and uses a platinum electrode and a reference electrode. Conductivity measures the ionic content of a solution using two electrodes — it is used for water quality and concentration measurement. Dissolved oxygen (DO) analyzers use a membrane-covered electrode (polarographic or galvanic) or an optical (fluorescence) sensor. The membrane electrode requires flow (the membrane consumes oxygen) and periodic membrane replacement. The optical sensor has no membrane and no flow requirement but is more expensive. For all analyzers, verify the calibration solution is fresh and at the correct temperature — an expired buffer gives a false calibration.',
   55, 1,
   '[{"question":"What is the theoretical Nernst slope for a pH electrode at 25C?","options":["7.0 mV/pH","14.0 mV/pH","59.2 mV/pH","100 mV/pH"],"correctIndex":2},{"question":"What does a pH electrode slope below 90% indicate?","options":["Normal aging","A degraded glass electrode that needs cleaning or replacement","A wrong buffer","A temperature error"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Sample Conditioning Systems', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Sample System Design & Maintenance',
   'A sample conditioning system extracts a representative sample from the process, conditions it (filters, cools, dries, pressure-reduces), and delivers it to the analyzer at the correct flow, pressure, and temperature. The sample tap must be in the active flow — a tap in a dead leg samples stagnant fluid that does not represent the process. The sample line should be short (to minimize transport delay — the time for the sample to reach the analyzer) and small diameter (to minimize the sample volume and the lag). A fast loop (a high-flow bypass that returns to the process) provides a fast response, with a small sidestream to the analyzer. Filter the sample to protect the analyzer from particulates — a clogged filter causes a slow response and a false reading. Cool gas samples below the dew point to remove condensable vapors that would contaminate the analyzer. For a gas chromatograph, the sample must be clean, dry, and at a controlled pressure — a pressure fluctuation shifts the injection volume and the peak area. Maintain the sample system as aggressively as the analyzer — a sample system failure produces a false reading that looks like an analyzer failure. Trend the sample flow and pressure; a change indicates a filter clog or a regulator drift.',
   50, 1,
   '[{"question":"Where must the sample tap be located?","options":["In a dead leg","In the active flow to sample representative fluid","At the analyzer","At the pump discharge"],"correctIndex":1},{"question":"What does a fast loop do?","options":["Cools the sample","Provides a fast response with a high-flow bypass and a small sidestream to the analyzer","Filters the sample","Pressurizes the sample"],"correctIndex":1}]');
END $$;

-- ===================== Smart Valve Positioners & Digital Feedback =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Smart Valve Positioners & Digital Feedback';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Digital Positioner Configuration', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'HART & Fieldbus Positioner Setup',
   'A smart digital valve positioner uses a microprocessor to control the valve position with higher precision than a pneumatic positioner. It communicates digitally (HART or Foundation Fieldbus) and provides diagnostics that a pneumatic positioner cannot. The auto-stroke function drives the valve from 0 to 100% and learns the open and closed endpoints, the travel time, and the friction profile. The valve signature is a plot of travel vs signal that reveals stiction (a flat region followed by a jump), hysteresis (a gap between upstroke and downstroke), and the actuator spring rate. The positioner stores the signature and compares future strokes to the baseline — a change indicates wear. For a HART positioner, configure the tag, the range, the action (direct or reverse), and the fail mode (fail open, fail close, fail in place). For a Fieldbus positioner, configure the function block and the resource block. The partial stroke test (PST) is a safety function that moves the valve a small amount (e.g., 10%) and verifies it moves — used for ESD (emergency shutdown) valves that must operate on demand but rarely move in normal service. The PST catches a stuck valve before it fails on demand.',
   50, 1,
   '[{"question":"What does the valve signature reveal?","options":["The valve size","Stiction, hysteresis, and the actuator spring rate","The valve material","The process pressure"],"correctIndex":1},{"question":"What is a partial stroke test (PST) used for?","options":["Calibrating the positioner","Testing ESD valves that must operate on demand but rarely move in normal service","Measuring flow","Setting the fail mode"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Diagnostics & Asset Management', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Predictive Valve Diagnostics & CMMS Integration',
   'A smart positioner provides predictive diagnostics that enable condition-based maintenance. The key diagnostic parameters: travel deviation (the difference between the commanded and actual position — a rising deviation indicates increasing friction), cycle count (the number of valve movements — high cycles indicate a modulating service that wears faster), and the friction trend (the stiction and hysteresis values over time). A rising friction trend indicates packing wear, a sticking valve, or a degraded air supply. The positioner alerts via NAMUR NE 107 status signals: Maintenance Required (the valve needs service soon), Function Check (the valve is degraded but still operating), Out of Specification (the valve is outside the performance limits), and Failure (the valve is not operating). Integrate these alerts with the CMMS: a Maintenance Required alert generates a work order for the next turnaround, a Function Check generates a work order for the next maintenance window, and a Failure generates an immediate work order. This integration moves valve maintenance from time-based (replace the packing every 2 years) to condition-based (replace the packing when the friction trend exceeds the threshold), reducing unnecessary maintenance and catching failures before they impact production.',
   50, 1,
   '[{"question":"What does a rising travel deviation in a smart positioner indicate?","options":["Improved performance","Increasing friction (packing wear, sticking valve, or degraded air supply)","A calibration error","Normal operation"],"correctIndex":1},{"question":"What does a NAMUR NE 107 Maintenance Required alert do when integrated with the CMMS?","options":["Nothing","Generates a work order for the next turnaround","Shuts down the valve","Generates an immediate work order"],"correctIndex":1}]');
END $$;

-- ===================== Safety Instrumented Systems (SIS) Fundamentals =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Safety Instrumented Systems (SIS) Fundamentals';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'SIS Architecture & SIL', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'SIS Concepts & Safety Integrity Level',
   'A Safety Instrumented System (SIS) is an independent layer of protection that brings the process to a safe state when the Basic Process Control System (BPCS) fails to maintain the process within safe limits. The SIS is separate from the BPCS — it has its own sensors, logic solver, and final elements. The Safety Integrity Level (SIL 1-4) is the required risk reduction for each safety function. SIL 1 (PFD 10^-1 to 10^-2) is the lowest, SIL 4 (PFD 10^-4 to 10^-5) is the highest and is rarely used in process industries. The SIL is determined by a hazard analysis (LOPA — Layer of Protection Analysis) that evaluates the severity, frequency, and independent protection layers. The SIS architecture uses voting: 1oo1 (single channel, failsafe), 1oo2 (two channels, either trips — higher safety), 2oo2 (two channels, both must trip — higher availability), and 2oo3 (three channels, two must trip — balanced safety and availability). The hardware fault tolerance (HFT) is the number of redundant channels minus one — a 1oo2 architecture has HFT 1, meaning it tolerates one fault and still functions. The SIL limits the architecture: SIL 2 requires HFT 1 or better; SIL 3 requires HFT 2 or better with a certified logic solver.',
   55, 1,
   '[{"question":"What is the relationship between the SIS and the BPCS?","options":["They are the same system","The SIS is separate and independent from the BPCS","The BPCS controls the SIS","The SIS controls the BPCS"],"correctIndex":1},{"question":"What does 2oo3 voting provide?","options":["Maximum safety","Maximum availability","Balanced safety and availability","No protection"],"correctIndex":2}]'),
  (m_id, 'Proof Testing & Bypass Management',
   'A proof test verifies that the SIS function operates correctly. The proof test interval is determined by the SIL calculation — the PFD (probability of failure on demand) is the sum of the failure rates times the test intervals. A longer interval increases the PFD and may violate the SIL. The proof test strokes the sensor, the logic solver, and the final element: verify the sensor reads correctly, the logic solver trips at the setpoint, and the final element moves to the safe state. Document the test with the as-found and as-left results. A bypass is a temporary disablement of a SIS function for maintenance. The bypass must be authorized by a permit, time-limited, and logged. A bypass that is left in place defeats the SIS and is a process safety incident. During a bypass, the operator must provide an alternative layer of protection (e.g., manual monitoring). The bypass register is audited to verify bypasses are removed promptly. For a SIS function that is bypassed during operation, verify the bypass is removed after the maintenance is complete — a forgotten bypass is the most common SIS failure mode.',
   50, 2,
   '[{"question":"What determines the proof test interval for a SIS function?","options":["The manufacturer","The SIL calculation (PFD = sum of failure rates times test intervals)","The operator","The maintenance schedule"],"correctIndex":1},{"question":"What is the most common SIS failure mode related to bypasses?","options":["Sensor failure","A forgotten bypass that is not removed after maintenance","Logic solver failure","Final element failure"],"correctIndex":1}]');
END $$;

-- ===================== Calibration Management & Metrology =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Calibration Management & Metrology';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Calibration Principles', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Traceability, Uncertainty & Intervals',
   'Calibration traceability means the measurement standard is linked to a national standard (NIST in the US) through an unbroken chain of comparisons. Every calibration must reference the standard used and its calibration certificate. Measurement uncertainty is the estimated range of the error — it includes the standard uncertainty, the resolution of the instrument, the repeatability, and the environmental factors (temperature, humidity). Report the calibration result with the uncertainty (e.g., 100.0 PSI +/- 0.5 PSI, k=2). The test uncertainty ratio (TUR) is the ratio of the instrument tolerance to the calibration standard uncertainty — a TUR of 4:1 or better is required for a valid calibration. The calibration interval is the time between calibrations — it is determined by the instrument stability, the criticality, and the regulatory requirement. Adjust the interval based on the as-found data: if an instrument is consistently within tolerance, extend the interval; if it is out of tolerance, shorten the interval. A calibration management system (CMS) schedules the calibrations, stores the records, and generates the reports. The CMS must be audited to verify the records are complete, the standards are in calibration, and the intervals are appropriate.',
   50, 1,
   '[{"question":"What does calibration traceability mean?","options":["The instrument is new","The measurement standard is linked to a national standard through an unbroken chain","The instrument is expensive","The calibration is done in-house"],"correctIndex":1},{"question":"What test uncertainty ratio (TUR) is required for a valid calibration?","options":["1:1","2:1","4:1 or better","10:1"],"correctIndex":2}]'),
  (m_id, 'As-Found/As-Left & Out-of-Tolerance',
   'The as-found data is the instrument reading before adjustment; the as-left data is the reading after adjustment. The as-found data is the most important — it reveals whether the instrument was within tolerance during the calibration interval. If the as-found is out of tolerance, the instrument was producing bad data during the interval, and the process records for that period are suspect. An out-of-tolerance (OOT) event requires a notification to the process owner, an impact assessment (was the process affected?), and a corrective action (repair, adjust, or replace the instrument). Document the OOT event with the instrument tag, the as-found value, the tolerance, the date, and the impact assessment. The OOT event is a quality record and may be auditable. For a transmitter that drifts consistently in one direction, the calibration interval may be too long — shorten it or replace the transmitter with a more stable model. For a transmitter that passes as-found but fails as-left (the adjustment moved it out of tolerance), the calibration procedure or the standard may be wrong — investigate before re-calibrating. Trend the as-found drift for each instrument — a rising drift rate indicates a degrading sensor that should be replaced before it goes out of tolerance.',
   45, 2,
   '[{"question":"What does the as-found data reveal?","options":["The instrument reading after adjustment","Whether the instrument was within tolerance during the calibration interval","The calibration standard","The environmental conditions"],"correctIndex":1},{"question":"What must be done when an out-of-tolerance (OOT) event is found?","options":["Nothing — just adjust it","Notify the process owner, assess the impact, and take corrective action","Replace the instrument immediately","Re-calibrate without documentation"],"correctIndex":1}]');
END $$;

-- ===================== Wireless Instrumentation & Remote I/O =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Wireless Instrumentation & Remote I/O';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Wireless Network Design', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'WirelessHART & ISA 100 Network Architecture',
   'Wireless instrumentation eliminates the cost of running cable to remote instruments. Two standards dominate: WirelessHART (IEC 62591) and ISA 100.11a. Both use the 2.4 GHz ISM band and IEEE 802.15.4 radio, with mesh networking — each device is a node that can relay messages from other devices, extending the network range and providing redundancy. A gateway connects the wireless network to the control system via a wired backhaul (Modbus, Ethernet). The mesh self-heals — if a node fails, the network reroutes through another node. The update rate (how often the instrument reports) is a trade-off with battery life — a 1-second update drains the battery in months, a 60-second update lasts years. Most process monitoring applications use a 30-60 second update rate. Design the network with a gateway at a central, elevated location and enough devices to create a multi-hop path. Verify the signal strength (RSSI) at each device during commissioning — a weak signal causes dropped messages and slow response. A site survey with a spectrum analyzer identifies interference sources (WiFi, microwaves) before installation.',
   50, 1,
   '[{"question":"What frequency band do WirelessHART and ISA 100 use?","options":["900 MHz","2.4 GHz ISM band","5 GHz","433 MHz"],"correctIndex":1},{"question":"What is the trade-off between update rate and battery life?","options":["Faster update = longer battery","Faster update = shorter battery life","No relationship","Update rate does not affect battery"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Remote I/O & Troubleshooting', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Remote I/O Systems & Wireless Troubleshooting',
   'Remote I/O systems place I/O modules near the field devices and communicate with the controller via a network (Ethernet, Modbus, or a proprietary bus). This reduces the home-run wiring from each field device to the control room — instead, one network cable carries the data for many devices. Remote I/O is used for large sites where the field devices are far from the control room, for skid packages, and for expansions where adding home-run cable is expensive. The remote I/O cabinet requires power (120V or 24V) and a network connection. Verify the network redundancy — a single network cable is a single point of failure. For wireless troubleshooting: a device that drops off the network has a weak signal, a failed battery, or interference. Check the RSSI (received signal strength indicator) — below -80 dBm is marginal. Check the battery voltage — below the threshold indicates a dead battery. Check the path — a new obstruction (a vessel, a building) may block the signal. Use the gateway management interface to view the network topology, the device health, and the message success rate. A device with a high retry count has a marginal signal — add a repeater or relocate the device. Document the network layout and the signal strengths for future reference.',
   45, 1,
   '[{"question":"What is the main advantage of remote I/O?","options":["Faster response","Reduces home-run wiring from each field device to the control room","Lower cost per point","No power required"],"correctIndex":1},{"question":"What RSSI value indicates a marginal wireless signal?","options":["Above -50 dBm","Above -80 dBm","Below -80 dBm","Below -100 dBm"],"correctIndex":2}]');
END $$;

-- ===================== PROFIBUS, PROFINET & Field Device Networks =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='PROFIBUS, PROFINET & Field Device Networks';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'PROFIBUS DP & PA', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'PROFIBUS DP/PA Topology & Addressing',
   'PROFIBUS DP (Decentralized Periphery) is a high-speed (up to 12 Mbit/s) serial bus for discrete automation — it connects PLCs to remote I/O, drives, and motor control centers. PROFIBUS PA (Process Automation) is the slower (31.25 kbit/s) intrinsically safe variant for process instruments — it also provides power to the field devices over the bus cable. A DP/PA coupler converts between the two. The bus is a single shielded twisted pair cable (RS-485 for DP, MBP for PA) terminated at both ends with an active terminator. A missing terminator causes signal reflection and communication errors. Each device has a unique address (0-126 for DP, 0-126 for PA) set by DIP switches or software. Address conflicts cause intermittent communication. The bus length depends on the speed: at 12 Mbit/s, the maximum is 100 meters; at 1.5 Mbit/s, 200 meters; at 93.75 kbit/s, 1200 meters. Use a repeater to extend the bus or add a branch. The GSD file (a text file from the device manufacturer) describes the device configuration to the PLC — import the GSD file before configuring the device. A device without the correct GSD file cannot be configured.',
   50, 1,
   '[{"question":"What is the maximum bus length for PROFIBUS DP at 12 Mbit/s?","options":["100 meters","200 meters","1200 meters","4000 meters"],"correctIndex":0},{"question":"What file describes a PROFIBUS device to the PLC?","options":["A PDF manual","A GSD file","A CSV file","An XML file"],"correctIndex":1}]'),
  (m_id, 'PROFINET & Network Diagnostics',
   'PROFINET is the Ethernet-based successor to PROFIBUS. It uses standard Ethernet (100 Mbit/s or 1 Gbit/s) with real-time extensions (RT for most applications, IRT for isochronous motion control). PROFINET uses standard Ethernet switches but benefits from managed switches with PROFINET diagnostics. Each device has an IP address and a PROFINET name (set by the configuration tool). The device name is critical — a device with the wrong name does not connect. Set the name via the manufacturer configuration tool or via DCP (Discovery and Configuration Protocol). Diagnose PROFINET with a network analyzer (e.g., Profitrace): check the cycle time, the number of devices, the watchdog errors, and the device health. A device with a high watchdog error count is dropping communication — check the cable, the connector, and the switch port. A device that reports a module failure has a wrong configuration or a failed I/O module. Use the PROFINET diagnostic buffer in the PLC to read the device diagnostic records — they identify the specific fault (channel failure, wire break, short circuit). For a network that intermittently drops, check the switch port error counters (FCS errors, alignment errors) and the cable continuity.',
   50, 2,
   '[{"question":"What is critical for a PROFINET device to connect?","options":["The IP address only","The PROFINET device name must be correct","The MAC address","The subnet mask"],"correctIndex":1},{"question":"What does a high watchdog error count on a PROFINET device indicate?","options":["Normal operation","The device is dropping communication — check cable, connector, and switch port","The device is too fast","The network is overloaded"],"correctIndex":1}]');
END $$;

-- ===================== HART Advanced Diagnostics & Device Management =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='HART Advanced Diagnostics & Device Management';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'NAMUR NE 107 & Predictive Diagnostics', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'NAMUR NE 107 Status Signals',
   'NAMUR NE 107 defines standard status signals for field devices: Good (the device is functioning correctly), Maintenance Required (the device needs service but is still operating correctly), Function Check (the device is degraded and may not be operating correctly), Out of Specification (the device is outside its rated conditions — e.g., the process temperature is above the sensor rating), and Failure (the device is not operating). These status signals are transmitted via HART to the control system and the asset management system (AMS). The key advantage: the operator sees the process value and the device status simultaneously — a Maintenance Required status on a transmitter tells the operator the value is still valid but the device needs attention. Without NE 107, a device failure produces a bad value that the operator cannot distinguish from a process upset. Configure the control system to display the NE 107 status as an alarm or a color indicator next to the value. Set the alarm priority: Failure is high priority, Out of Specification is medium, Function Check is medium, and Maintenance Required is low. This prioritization prevents alarm flooding while ensuring critical device issues are not missed.',
   50, 1,
   '[{"question":"What does a NAMUR NE 107 Maintenance Required status tell the operator?","options":["The value is invalid","The value is still valid but the device needs attention","The device has failed","The process is upset"],"correctIndex":1},{"question":"What NE 107 status is high priority?","options":["Maintenance Required","Function Check","Failure","Out of Specification"],"correctIndex":2}]'),
  (m_id, 'Asset Management & CMMS Integration',
   'An asset management system (AMS) collects the HART diagnostic data from all field devices and presents it in a maintenance-oriented interface. The AMS shows the device list, the status, the configuration, the calibration history, and the diagnostic details. A device with a Maintenance Required status appears in the AMS as a work candidate — the maintenance team reviews the list and generates work orders for the devices that need attention. Integrate the AMS with the CMMS: a Maintenance Required alert generates a CMMS work order automatically, with the device tag, the diagnostic description, and the recommended action. This integration moves maintenance from reactive (fix it when it fails) to predictive (fix it when the diagnostics say it is degrading). The AMS also stores the device configuration — a device that is replaced can be configured from the stored configuration, reducing the commissioning time. Verify the AMS polling cycle — a device that is polled every 24 hours may have a diagnostic alert that is 24 hours old. For critical devices, configure a faster polling cycle or use a fieldbus (Foundation Fieldbus or PROFIBUS) that reports the status in real time.',
   50, 1,
   '[{"question":"What does an asset management system (AMS) do?","options":["Controls the process","Collects HART diagnostic data from all field devices and presents it for maintenance","Stores the PLC program","Manages the network"],"correctIndex":1},{"question":"What does AMS-CMMS integration enable?","options":["Faster process control","Predictive maintenance — fixing devices when diagnostics say they are degrading","Remote configuration","Alarm management"],"correctIndex":1}]');
END $$;

-- ===================== Control Loop Performance Monitoring =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Control Loop Performance Monitoring';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Performance Indices & Oscillation Detection', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Loop Performance Benchmarking & Oscillation Detection',
   'A control loop performance monitoring program measures how well each loop is performing and prioritizes maintenance. The performance index compares the actual loop variance to the minimum achievable variance (the Harris index) — a loop operating at 25% of minimum variance is performing poorly and needs attention. Oscillation detection identifies loops that are cycling — the autocorrelation of the PV reveals a periodic component. An oscillating loop may be caused by a tuning issue, valve stiction, or an external disturbance. Distinguish the cause: if the oscillation persists when the loop is in Manual, the cause is external (an upstream loop or a process disturbance). If the oscillation stops in Manual, the cause is in the loop (tuning or stiction). A stiction test (the valve signature) confirms valve stiction. Prioritize the loops: a loop that oscillates and disturbs downstream loops is high priority; a loop that is sluggish but does not affect downstream is lower priority. Use the performance monitoring software to rank the loops by impact and assign maintenance to the highest-impact loops first. A plant with 500 control loops may have 50 that need attention — the monitoring program identifies the 50 and saves the maintenance team from checking all 500.',
   50, 1,
   '[{"question":"What does the Harris index compare?","options":["The loop tuning to the manufacturer spec","The actual loop variance to the minimum achievable variance","The PV to the SP","The output to the PV"],"correctIndex":1},{"question":"How do you distinguish a tuning issue from an external disturbance?","options":["By retuning the loop","By putting the loop in Manual — if the oscillation stops, the cause is in the loop; if it persists, the cause is external","By increasing the gain","By decreasing the integral time"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Stiction Diagnosis & Maintenance Prioritization', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Stiction Quantification & Loop Maintenance Strategy',
   'Valve stiction is the most common cause of loop oscillation. Quantify the stiction by the relay method: put the loop in Manual, move the output up by 1% and observe the PV. If the PV does not move, increase the output until the PV jumps — the dead band is the stiction. A stiction of 1% or more causes visible oscillation in most loops. Correct stiction by repacking the valve (over-tightened packing is the most common cause), replacing the valve packing, or replacing the positioner. After correcting the stiction, re-tune the loop — the original tuning was compensating for the stiction and may now be too aggressive. For a loop that is not oscillating but is sluggish (slow response to setpoint changes), the controller gain may be too low or the integral time too long. Increase the gain by 50% and observe the response — if it improves without oscillating, the gain was too low. For a loop with a long dead time (the time between the output change and the PV response), lambda tuning with a lambda of 3x the dead time gives a robust response. Document the loop performance before and after the maintenance — the improvement justifies the maintenance effort and builds the case for a loop monitoring program.',
   50, 1,
   '[{"question":"What is the most common cause of valve stiction?","options":["Undersized actuator","Over-tightened packing","Wrong positioner","Short signal cable"],"correctIndex":1},{"question":"What should be done after correcting valve stiction?","options":["Nothing","Re-tune the loop — the original tuning was compensating for the stiction and may now be too aggressive","Replace the valve","Increase the setpoint"],"correctIndex":1}]');
END $$;

-- ===================== Instrument Installation Practices & Best Practices =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='ie' AND title='Instrument Installation Practices & Best Practices';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Tubing, Fittings & Impulse Lines', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Tubing, Fittings & Impulse Line Routing',
   'Instrument tubing connects the process to the transmitter. Stainless steel 316 tubing is the standard for process applications — 1/2 inch OD is common for impulse lines, 1/4 inch for analyzer samples. Cut tubing with a tube cutter (not a hacksaw) and deburr the end — a burr restricts flow and creates turbulence. Use compression fittings (Swagelok-type) and tighten per the manufacturer instructions — for Swagelok, tighten the nut 1-1/4 turns from finger-tight for new fittings, and 3/4 turn for reassembled fittings. Over-tightening damages the ferrules and causes leaks; under-tightening also leaks. Verify the fitting does not leak by pressurizing and checking with a leak detector or soap solution. Route impulse lines to drain (for liquids) or vent (for gases) — a low point in a liquid line traps sediment, and a high point traps air. Support the tubing every 6-8 feet to prevent vibration and sagging. Keep the impulse lines short and at the same elevation for DP measurements to cancel the head difference. Use a root valve at the process tap for isolation — the root valve allows the transmitter to be removed without isolating the process.',
   50, 1,
   '[{"question":"How many turns from finger-tight should a new Swagelok compression fitting be tightened?","options":["1/4 turn","3/4 turn","1-1/4 turns","2 turns"],"correctIndex":2},{"question":"How should impulse lines for DP measurement be routed?","options":["Any direction","Short and at the same elevation to cancel the head difference","Long and coiled","With high and low points"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Grounding, Lightning Protection & Commissioning', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Grounding, Lightning Protection & Loop Commissioning',
   'Proper instrument grounding prevents noise and damage. Ground the transmitter case to the building ground with a dedicated ground wire — do not ground through the conduit or the tubing. For 4-20 mA loops, the ground is at one point only (usually the power supply negative) to prevent ground loops. A ground loop (multiple ground points) causes circulating currents that add noise to the signal. Use shielded cable for low-level signals (thermocouple, RTD) and ground the shield at one end only — grounding both ends creates a ground loop. For lightning protection, install surge protectors on all field instrument loops — a surge protector shunts the lightning-induced voltage to ground before it reaches the transmitter. Verify the surge protector is rated for the signal type (4-20 mA, thermocouple, RTD) and the loop voltage. During commissioning, verify the loop: confirm the transmitter output (4 mA at LRV, 20 mA at URV) at the DCS, verify the loop resistance (250 ohms for HART), and check for noise (less than 1% of span). Perform a loop check: drive the transmitter signal from the field and confirm the DCS reads the correct value — this verifies the wiring, the I/O card, and the DCS configuration in one test. Document the loop check with the instrument tag, the date, the test values, and the pass/fail result.',
   50, 1,
   '[{"question":"What does grounding the shield at both ends create?","options":["Better shielding","A ground loop that adds noise to the signal","Improved signal quality","No effect"],"correctIndex":1},{"question":"What does a loop check verify?","options":["Only the transmitter","The wiring, the I/O card, and the DCS configuration in one test","Only the DCS","Only the field wiring"],"correctIndex":1}]');
END $$;
