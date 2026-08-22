-- ============================================================
-- PART 3b: Expand existing quizzes to 7 questions for courses 12-22
-- ============================================================

-- Course 12: Hazardous Location Electrical Installations
-- Lesson: NEC 500 Class I, II, III & Division/Zone Systems
UPDATE lessons SET quiz = '[
  {"question":"What does explosionproof equipment do?","options":["Prevents explosions from occurring","Contains an internal explosion and prevents it from igniting the surrounding atmosphere","Is completely sealed","Is intrinsically safe"],"correctIndex":1},
  {"question":"What does intrinsically safe equipment limit?","options":["The physical size of the equipment","The electrical energy to a level that cannot ignite the hazard","The operating temperature","The voltage only"],"correctIndex":1},
  {"question":"What does NEC Article 500 classify as Class I?","options":["Combustible dust","Flammable gases or vapors","Ignitible fibers","Corrosive environments"],"correctIndex":1},
  {"question":"What is the difference between Division 1 and Division 2 in NEC 500?","options":["Division 1 is for gases, Division 2 is for dust","Division 1 is where the hazard is present under normal conditions; Division 2 is where it is present only under abnormal conditions","Division 1 is indoor, Division 2 is outdoor","There is no difference"],"correctIndex":1},
  {"question":"What does Class II cover?","options":["Flammable gases","Combustible dust (grain, coal, flour, etc.)","Ignitible fibers","Flammable liquids"],"correctIndex":1},
  {"question":"What is the Zone system (NEC 505)?","options":["An alternative to the Division system based on IEC standards","A physical zone of a facility","A temperature classification","A wiring method"],"correctIndex":0},
  {"question":"What temperature classification (T-code) is required for a hazard with an ignition temperature of 200°C?","options":["T3 (200°C max surface temperature)","T4 (135°C)","T2 (300°C)","T6 (85°C)"],"correctIndex":0}
]'::jsonb
WHERE id = 'ab13221b-ebe7-40ae-b184-854663e53412';

-- Lesson: Sealing & Installation Requirements
UPDATE lessons SET quiz = '[
  {"question":"How far from the enclosure must a conduit seal be installed in Division 1?","options":["6 inches","18 inches","36 inches","72 inches"],"correctIndex":1},
  {"question":"What must be done with conductors in a seal fitting?","options":["Bundle them tightly","Separate them so the sealing compound fills the voids","Use only one conductor per seal","No special requirement"],"correctIndex":1},
  {"question":"What is the purpose of a conduit seal in a hazardous location?","options":["To prevent water entry","To prevent gases or vapors from passing through the conduit from one area to another","To reduce condensation","To ground the conduit"],"correctIndex":1},
  {"question":"What type of sealing compound is used in seal fittings?","options":["Silicone","A factory-supplied sealing compound that cures to a solid","Epoxy","Electrical tape"],"correctIndex":1},
  {"question":"What must not be done when pouring a seal?","options":["Mix the compound thoroughly","Leave the conductors separated until the compound cures","Bundle the conductors tightly together, preventing compound penetration","Allow adequate curing time"],"correctIndex":2},
  {"question":"Where are conduit seals required in a Division 1 location?","options":["Only at the enclosure","At the enclosure and at any point where the conduit enters or leaves the classified area","At every 10 feet","Only at the boundary"],"correctIndex":1},
  {"question":"What is a breather fitting used for?","options":["To seal the conduit","To allow breathing (pressure equalization) in explosionproof enclosures while preventing flame passage","To drain condensation","To ground the enclosure"],"correctIndex":1}
]'::jsonb
WHERE id = '7abfbfa0-5021-404e-9f8b-e6d9aa1af12c';

-- Course 13: Industrial Panel Building & Layout
-- Lesson: UL 508A Layout Requirements
UPDATE lessons SET quiz = '[
  {"question":"What determines the SCCR (Short-Circuit Current Rating) of an industrial control panel?","options":["The main breaker rating","The lowest-rated component in the power circuit","The wire size","The panel size"],"correctIndex":1},
  {"question":"What is the minimum clearance between non-dedicated power and control components in a panel?","options":["0.5 inches","1 inch","2 inches","No minimum"],"correctIndex":1},
  {"question":"What UL standard covers industrial control panels?","options":["UL 50","UL 508A","UL 100","UL 489"],"correctIndex":1},
  {"question":"What must the panel nameplate include?","options":["Only the manufacturer name","Manufacturer, panel model, voltage, SCCR, and date","Only the voltage","Only the serial number"],"correctIndex":1},
  {"question":"What is the minimum working clearance in front of a panel per NEC 110.26?","options":["12 inches","30 inches (for 120V to ground) to 48 inches (for 480V to ground)","36 inches for all voltages","No minimum"],"correctIndex":1},
  {"question":"What is the minimum wire bending space at a terminal per UL 508A?","options":["1 inch","Per NEC Table 312.6 based on wire size","2 inches","4 inches"],"correctIndex":1},
  {"question":"What must be provided for a panel rated over 50V?","options":["A light","A main disconnecting means and a means to lock it in the open position","A window","A fan"],"correctIndex":1}
]'::jsonb
WHERE id = 'ddfa9671-97ed-4837-9358-8ebc555b90f2';

-- Lesson: Wire Sizing, Bundling & Labeling Standards
UPDATE lessons SET quiz = '[
  {"question":"What is used on stranded wire connections to terminal blocks to prevent splaying?","options":["Electrical tape","Ferrule terminals","Solder","Heat shrink"],"correctIndex":1},
  {"question":"What is required for every terminal connection, not just by feel?","options":["A torque wrench to the manufacturer specification","A screwdriver","Pliers","Finger-tight is sufficient"],"correctIndex":0},
  {"question":"What is the standard wire color for AC control circuits?","options":["Red for ungrounded, white for grounded, blue for DC control","Black for all","Green for all","Yellow for all"],"correctIndex":0},
  {"question":"What is the maximum number of conductors permitted under one terminal?","options":["1","2 (unless the terminal is rated for more)","3","No limit"],"correctIndex":1},
  {"question":"What is the purpose of wire markers (numbers)?","options":["To identify wire gauge","To uniquely identify each wire for troubleshooting and matching to drawings","To indicate voltage","To show wire color"],"correctIndex":1},
  {"question":"What is the maximum bundle size for control wires in a panel?","options":["10 wires","20 wires","No code limit, but good practice limits bundles to a manageable size for heat dissipation and tracing","50 wires"],"correctIndex":2},
  {"question":"What must be done with spare conductors in a panel?","options":["Cut them off","Terminate them on a terminal strip and label them as spare","Tape them and leave loose","Ground them"],"correctIndex":1}
]'::jsonb
WHERE id = 'f385ae8b-4b0c-4412-840f-07156cdca86b';

-- Course 14: Lighting Systems, Ballasts & LED Retrofits
-- Lesson: HID, Fluorescent & LED Systems
UPDATE lessons SET quiz = '[
  {"question":"What does HID stand for?","options":["High Intensity Discharge","High Input Distribution","High Impact Diode","High Insulation Device"],"correctIndex":0},
  {"question":"What is the most common HID lamp type in industrial high-bay applications?","options":["Mercury vapor","High-pressure sodium (HPS) and metal halide","Incandescent","Tungsten halogen"],"correctIndex":1},
  {"question":"What is the typical efficacy (lumens per watt) of an LED high-bay fixture compared to metal halide?","options":["Similar (50-70 LPW)","Significantly higher (130-180 LPW vs 60-80 LPW for metal halide)","Lower","The same"],"correctIndex":1},
  {"question":"What is the main advantage of LED over HID in industrial applications?","options":["Lower cost","Higher efficacy, instant on/off, no warm-up time, longer life, and better color rendering","Brighter light","Easier to install"],"correctIndex":1},
  {"question":"What is the typical rated life of an industrial LED fixture?","options":["10,000 hours","50,000-100,000 hours (L70)","20,000 hours","5,000 hours"],"correctIndex":1},
  {"question":"What is a ballast factor?","options":["The weight of the ballast","The ratio of a ballast''s light output to a reference ballast","The power factor of the ballast","The voltage rating"],"correctIndex":1},
  {"question":"What is CRI (Color Rendering Index)?","options":["The color of the light","A measure of how accurately a light source renders colors compared to a reference (100 is perfect)","The intensity of the light","The temperature of the light"],"correctIndex":1}
]'::jsonb
WHERE id = '9d98e7c6-86ef-4664-a256-1a978fceb708';

-- Lesson: Retrofit Planning & Energy Calculations
UPDATE lessons SET quiz = '[
  {"question":"What is the first step in planning an LED retrofit?","options":["Buy fixtures","Audit existing lighting: count fixtures, types, wattages, and measure light levels","Turn off the lights","Call a contractor"],"correctIndex":1},
  {"question":"What is a simple payback calculation for a lighting retrofit?","options":["Total cost / annual energy savings","Annual energy savings / total cost","Total cost x annual savings","There is no formula"],"correctIndex":0},
  {"question":"What is the typical energy savings from an HID-to-LED high-bay retrofit?","options":["10-20%","50-70%","90%","5%"],"correctIndex":1},
  {"question":"What is a lighting power density (LPD)?","options":["The density of fixtures","Lighting power per square foot (W/sq ft), regulated by ASHRAE 90.1 and IECC","The number of lamps per fixture","The brightness of the light"],"correctIndex":1},
  {"question":"What must be considered when retrofitting to LED in a high-bay environment?","options":["The color of the fixtures","Ambient temperature, mounting height, beam angle, and light distribution pattern","The weight of the fixture","The brand name"],"correctIndex":1},
  {"question":"What is the advantage of LED fixtures with integrated controls (dimmable, occupancy sensors)?","options":["They are cheaper","Additional energy savings of 20-50% beyond the lamp replacement","They are brighter","They last longer"],"correctIndex":1},
  {"question":"What is a photometric study?","options":["A study of light fixture costs","A computer simulation that predicts light levels and distribution for a given space and fixture layout","A study of lamp life","A study of energy usage"],"correctIndex":1}
]'::jsonb
WHERE id = 'ece410f9-a241-4a75-9792-f9214e10b900';

-- Course 15: Motor Protection & Overcurrent Devices
-- Lesson: Fuses, Breakers & Motor Circuit Protectors
UPDATE lessons SET quiz = '[
  {"question":"What is the purpose of a motor circuit protector (MCP)?","options":["To protect against overloads","To provide short-circuit protection only (not overload) — used with a separate overload relay","To replace the overload relay","To protect the motor cable"],"correctIndex":1},
  {"question":"What is the NEC maximum fuse size for a motor branch circuit?","options":["100% of FLC","125% of FLC (300% for time-delay fuses on some motors)","200% of FLC","150% of FLC"],"correctIndex":1},
  {"question":"What is the difference between a fuse and a circuit breaker?","options":["Fuses are faster","Fuses are single-use; breakers can be reset. Fuses typically have higher interrupting ratings and better current limitation","Fuses are cheaper","Breakers are more accurate"],"correctIndex":1},
  {"question":"What is a current-limiting fuse?","options":["A fuse that reduces current","A fuse that clears a fault in less than half a cycle, limiting the peak let-through current and energy","A fuse with a low amp rating","A fuse that limits voltage"],"correctIndex":1},
  {"question":"What NEC article covers motor circuits?","options":["Article 240","Article 250","Article 430","Article 500"],"correctIndex":2},
  {"question":"What is the purpose of the motor overload relay?","options":["Short-circuit protection","Overload (overheating) protection for the motor — operates on time and current","Ground fault protection","Phase loss protection"],"correctIndex":1},
  {"question":"What is a Class J fuse and why is it used in motor circuits?","options":["A low-cost fuse","A time-delay, current-limiting fuse that can handle motor inrush while providing excellent short-circuit protection","A fast-acting fuse","A high-voltage fuse"],"correctIndex":1}
]'::jsonb
WHERE id = '5e0cdc04-4884-4b2a-9c04-e0cceccb51f0';

-- Lesson: Selective Coordination & NEC 430 Requirements
UPDATE lessons SET quiz = '[
  {"question":"What is selective coordination?","options":["All breakers trip together","Only the upstream device closest to the fault trips, leaving the rest of the system energized","All breakers trip in sequence","No breakers trip"],"correctIndex":1},
  {"question":"What NEC section requires selective coordination for critical systems?","options":["NEC 110","NEC 240.92 (for critical operations data systems) and 700 for emergency systems","NEC 250","NEC 430"],"correctIndex":1},
  {"question":"What is the purpose of NEC 430 Part II (Motor Branch Circuit Short-Circuit and Ground Fault Protection)?","options":["To specify overload protection","To specify the size and type of short-circuit protective device (fuses or breakers) for the motor branch circuit","To specify wire size","To specify grounding"],"correctIndex":1},
  {"question":"What is a time-current curve?","options":["A voltage graph","A graph showing how long a protective device takes to trip at a given current","A wire sizing chart","A motor starting curve"],"correctIndex":1},
  {"question":"Why is selective coordination important in an industrial facility?","options":["It saves money","It prevents a single fault from shutting down the entire facility","It improves power factor","It reduces harmonics"],"correctIndex":1},
  {"question":"What is the maximum FLC (Full Load Current) for a 50 HP, 460V motor per NEC 430.250?","options":["65A","77A","95A","125A"],"correctIndex":0},
  {"question":"What is the NEC 430.32 requirement for motor overload protection?","options":["100% of FLC","115% of FLC for motors with a 1.15 service factor, 125% for 1.0 service factor","150% of FLC","200% of FLC"],"correctIndex":1}
]'::jsonb
WHERE id = 'fc6c8c59-5c85-49ad-92e5-706920acc1e9';

-- Course 16: Motor Starters, Contactors & Overload Relays
-- Lesson: NEMA vs IEC Contactors
UPDATE lessons SET quiz = '[
  {"question":"What is the main difference between NEMA and IEC contactors?","options":["NEMA is smaller","NEMA is sized by horsepower with generous overload capacity; IEC is sized more precisely with less overload margin","NEMA is European","IEC is American"],"correctIndex":1},
  {"question":"What does a NEMA Size 1 contactor typically handle?","options":["10A","30A (approximately 10 HP at 460V)","100A","5A"],"correctIndex":1},
  {"question":"What is the advantage of IEC contactors?","options":["They are more durable","They are more compact and less expensive for properly sized applications","They handle more current","They are easier to repair"],"correctIndex":1},
  {"question":"What is the advantage of NEMA contactors?","options":["They are cheaper","They have generous overload capacity and can handle size uprating without replacement","They are smaller","They are more efficient"],"correctIndex":1},
  {"question":"What is AC-3 utilization category for contactors?","options":["Resistive load","Squirrel-cage motors: starting, stopping during running (standard motor duty)","Lighting","Heating"],"correctIndex":1},
  {"question":"What does the coil voltage rating on a contactor indicate?","options":["The motor voltage","The control circuit voltage required to energize the contactor","The maximum voltage","The contact voltage"],"correctIndex":1},
  {"question":"What is a common cause of contactor failure?","options":["Oversized wire","Contact erosion from arcing during make/break operations, and coil burnout from voltage transients","Low ambient temperature","Undersized motor"],"correctIndex":1}
]'::jsonb
WHERE id = '969ae21b-b1f8-4eef-84d7-ff3c0ca980e8';

-- Lesson: Arc Suppression & Contact Life
UPDATE lessons SET quiz = '[
  {"question":"What causes arcing at contactor contacts?","options":["Low voltage","The inductive kick from motor windings when the circuit is interrupted","High current only","Low current"],"correctIndex":1},
  {"question":"What is the purpose of an arc chute in a contactor?","options":["To cool the contacts","To extinguish the arc by stretching and cooling it, preventing it from continuing to conduct","To ground the arc","To increase the arc"],"correctIndex":1},
  {"question":"What is contact erosion?","options":["Corrosion from moisture","Material transfer and loss from the contacts due to arcing during make and break operations","Mechanical wear of the contact spring","Oxidation of the contact surface"],"correctIndex":1},
  {"question":"What is the typical electrical life of an IEC contactor?","options":["100,000 operations","1-3 million operations","10 million operations","100 operations"],"correctIndex":1},
  {"question":"What is the difference between make and break ratings of a contactor?","options":["They are the same","Make (closing) rating is higher than break (opening) rating because breaking an inductive load creates an arc","Make is lower","They are not rated"],"correctIndex":1},
  {"question":"What reduces contact life?","options":["Frequent cycling, high inrush current, and inductive loads","Low ambient temperature","Undersized wire","DC control voltage"],"correctIndex":0},
  {"question":"What is a solid-state relay (SSR) advantage over a mechanical contactor for certain applications?","options":["Higher current rating","No moving parts, no arc, no contact wear, and faster switching","Lower cost","Higher voltage rating"],"correctIndex":1}
]'::jsonb
WHERE id = '641824f1-233f-439a-b10f-2dcb19e90d3b';

-- Lesson: Overload Class Selection & Troubleshooting
UPDATE lessons SET quiz = '[
  {"question":"What is the trip time for a Class 10 overload relay at 600% of FLC?","options":["10 seconds","20 seconds","30 seconds","60 seconds"],"correctIndex":0},
  {"question":"What is the trip time for a Class 20 overload relay at 600% of FLC?","options":["10 seconds","20 seconds","30 seconds","60 seconds"],"correctIndex":1},
  {"question":"What is the trip time for a Class 30 overload relay at 600% of FLC?","options":["10 seconds","20 seconds","30 seconds","60 seconds"],"correctIndex":2},
  {"question":"Which overload class is recommended for high-inertia loads that take longer to start?","options":["Class 10","Class 20","Class 30","Class 5"],"correctIndex":2},
  {"question":"Which overload class is recommended for submersible pumps?","options":["Class 10","Class 20","Class 30","Class 5"],"correctIndex":0},
  {"question":"What is a common cause of nuisance overload tripping?","options":["Oversized motor","Undersized overload setting, voltage unbalance, or high ambient temperature","Low load","Cold motor"],"correctIndex":1},
  {"question":"What is the difference between eutectic and bimetallic overload relays?","options":["There is no difference","Eutectic uses a melting alloy (fixed trip); bimetallic uses a bending strip (adjustable)","Eutectic is electronic","Bimetallic is more accurate"],"correctIndex":1}
]'::jsonb
WHERE id = '31e3ae9b-a4fe-4912-af29-c6af25bd9655';

-- Course 17: Power Quality Basics
-- Lesson: Harmonic Sources & IEEE 519 Limits
UPDATE lessons SET quiz = '[
  {"question":"What is the fundamental frequency in North America?","options":["50 Hz","60 Hz","400 Hz","120 Hz"],"correctIndex":1},
  {"question":"What are harmonics?","options":["Integer multiples of the fundamental frequency that distort the waveform","Noise on the line","Voltage drops","Power factor issues"],"correctIndex":0},
  {"question":"What is the IEEE 519 voltage THD limit at the PCC?","options":["1%","3%","5%","10%"],"correctIndex":2},
  {"question":"What are common sources of harmonics in industrial facilities?","options":["Incandescent lights","VFDs, rectifiers, UPS systems, and other nonlinear loads","Motors","Transformers at no load"],"correctIndex":1},
  {"question":"What is Total Harmonic Distortion (THD)?","options":["The total power in the system","The ratio of all harmonic content to the fundamental, expressed as a percentage","The total voltage","The total current"],"correctIndex":1},
  {"question":"What is Total Demand Distortion (TDD)?","options":["Same as THD","Harmonic current as a percentage of the maximum demand load current","Total power distortion","Total voltage distortion"],"correctIndex":1},
  {"question":"What is the 5th harmonic characteristic of a 6-pulse VFD?","options":["It is not present","It is the largest harmonic, typically 30-40% of the fundamental","It is 100%","It is negligible"],"correctIndex":1}
]'::jsonb
WHERE id = 'e8198a60-2003-42a9-8899-8660d39b3881';

-- Lesson: Voltage Sags, Swells & Flicker
UPDATE lessons SET quiz = '[
  {"question":"What is a voltage sag (dip)?","options":["A complete loss of voltage","A reduction in RMS voltage between 0.1 and 0.9 pu for 0.5 cycles to 1 minute","An increase in voltage","Voltage fluctuation"],"correctIndex":1},
  {"question":"What is a voltage swell?","options":["A loss of voltage","An increase in RMS voltage between 1.1 and 1.8 pu for 0.5 cycles to 1 minute","A voltage reduction","A voltage spike"],"correctIndex":1},
  {"question":"What is the most common power quality problem?","options":["Harmonics","Voltage sags","Power factor","Flicker"],"correctIndex":1},
  {"question":"What is voltage flicker?","options":["A complete loss of voltage","Rapid, repeated voltage fluctuations that cause visible light flickering","A voltage sag","A voltage swell"],"correctIndex":1},
  {"question":"What is a common cause of voltage sags in industrial facilities?","options":["LED lighting","Motor starting (large inrush current) and utility faults","Transformers","Cable runs"],"correctIndex":1},
  {"question":"What is the ITIC (CBEMA) curve?","options":["A voltage curve","A graph that defines voltage tolerance limits for equipment — duration vs magnitude of voltage events","A current curve","A power factor curve"],"correctIndex":1},
  {"question":"What can mitigate voltage sags for sensitive equipment?","options":["Larger wire","UPS systems, voltage regulators, or sag correctors","More breakers","Better grounding"],"correctIndex":1}
]'::jsonb
WHERE id = '0f9e104c-dd18-4cd4-842c-0911c25697db';

-- Lesson: Power Factor Correction & Mitigation
UPDATE lessons SET quiz = '[
  {"question":"What is power factor?","options":["The ratio of real power to apparent power (W/VA)","The ratio of voltage to current","The ratio of real power to reactive power","The efficiency of the motor"],"correctIndex":0},
  {"question":"What causes low power factor in industrial facilities?","options":["LED lighting","Inductive loads (motors, transformers) drawing reactive power","Resistive heaters","Incandescent lights"],"correctIndex":1},
  {"question":"What is the typical power factor of an unloaded motor?","options":["1.0","0.95","0.2-0.4 (very low)","0.8"],"correctIndex":2},
  {"question":"What is the most common method of power factor correction?","options":["Adding capacitors","Adding inductors","Adding resistors","Changing the motor size"],"correctIndex":0},
  {"question":"What problem can occur when adding power factor correction capacitors to a system with VFDs?","options":["Nothing","Resonance with system inductance, causing overvoltage and capacitor failure","Improved power factor","Reduced harmonics"],"correctIndex":1},
  {"question":"What is a synchronous condenser?","options":["A type of capacitor","A synchronous motor running unloaded that can generate or absorb reactive power to correct PF","A transformer","A type of breaker"],"correctIndex":1},
  {"question":"What is the utility penalty for low power factor typically based on?","options":["The cost of real power","The kVA demand or the kVAR demand, depending on the rate structure","The voltage","The current"],"correctIndex":1}
]'::jsonb
WHERE id = '76278351-04d1-4aaf-a1b0-c1ec69c3f8b3';

-- Course 18: Soft Starters & Reduced Voltage Starting
-- Lesson: Autotransformer, Star-Delta & Solid-State Soft Starters
UPDATE lessons SET quiz = '[
  {"question":"What is the purpose of a reduced voltage starter?","options":["To save energy","To reduce the starting current and torque to minimize mechanical and electrical stress","To increase torque","To improve power factor"],"correctIndex":1},
  {"question":"What is the starting current for a star-delta starter compared to across-the-line?","options":["Same as across-the-line","Approximately 33% (1/3) of across-the-line current","50% of across-the-line","10% of across-the-line"],"correctIndex":1},
  {"question":"What is the starting torque for a star-delta starter compared to across-the-line?","options":["Same","33% (1/3) of across-the-line torque","50%","10%"],"correctIndex":1},
  {"question":"What is the advantage of a solid-state soft starter over a star-delta starter?","options":["It is cheaper","It provides smooth, stepless voltage ramp-up and adjustable starting parameters","It is simpler","It has no electronics"],"correctIndex":1},
  {"question":"What is the disadvantage of an autotransformer starter?","options":["It is too smooth","It has discrete voltage taps (not stepless) and is bulky and expensive","It is too small","It has no disadvantages"],"correctIndex":1},
  {"question":"What is the typical starting current reduction for a solid-state soft starter?","options":["10%","30-70% of across-the-line, adjustable","90%","100%"],"correctIndex":1},
  {"question":"What is a bypass contactor in a soft starter used for?","options":["To start the motor","To bypass the SCR during running to eliminate heat losses and improve efficiency","To stop the motor","To protect the motor"],"correctIndex":1}
]'::jsonb
WHERE id = '6f2296c2-e778-4983-9752-f1f2eb9913ad';

-- Lesson: Starting Torque & Load Considerations
UPDATE lessons SET quiz = '[
  {"question":"What is the starting torque of a star-delta starter compared to DOL (across-the-line)?","options":["100%","33% (1/3)","50%","10%"],"correctIndex":1},
  {"question":"What type of load is NOT suitable for star-delta starting?","options":["Centrifugal pumps","Loads that require high starting torque (conveyors, crushers, positive displacement pumps)","Fans","Compressors"],"correctIndex":1},
  {"question":"What is the relationship between starting current and starting torque for a reduced voltage starter?","options":["Torque decreases proportionally to the square of the voltage reduction, current decreases proportionally to the voltage","Torque and current decrease equally","Torque stays the same","Torque increases"],"correctIndex":0},
  {"question":"What is the minimum starting torque required for a motor to start a load?","options":["10% of full-load torque","The breakaway torque of the load — typically 10-40% for fans/pumps, up to 100%+ for high-inertia loads","100% of full-load torque","200% of full-load torque"],"correctIndex":1},
  {"question":"What happens if the starting torque is insufficient?","options":["The motor starts slowly","The motor fails to accelerate and draws locked-rotor current, tripping the overload or burning out","The motor runs at half speed","Nothing"],"correctIndex":1},
  {"question":"What is the acceleration time of a motor-load system determined by?","options":["Motor size only","The difference between motor torque and load torque (net accelerating torque) and the system inertia (WK²)","Voltage only","Current only"],"correctIndex":1},
  {"question":"What is a kick-start (pulse start) feature on a soft starter?","options":["A way to start faster","A short pulse of higher voltage at the beginning to break static friction, then ramp down to a lower voltage","A safety feature","A way to stop the motor"],"correctIndex":1}
]'::jsonb
WHERE id = '1c43e1b3-c58a-4016-9e42-585798dcd2c5';

-- Course 19: Temporary Power & Construction Electrical
-- Lesson: GFCI, Spider Boxes & Generator Sizing
UPDATE lessons SET quiz = '[
  {"question":"What is the OSHA requirement for GFCI on construction sites?","options":["Recommended only","All 120V, 15A and 20A receptacles must have GFCI protection","Only for outdoor use","Only for wet locations"],"correctIndex":1},
  {"question":"What is a spider box (portable power distribution box)?","options":["A storage box","A portable power distribution center with multiple receptacles and GFCI protection for construction sites","A junction box","A tool box"],"correctIndex":1},
  {"question":"How do you size a generator for temporary power?","options":["Match the largest motor","Calculate the total connected load, add motor starting kVA, and add 20% margin for future loads and generator derating","Use the voltage","Use the current"],"correctIndex":1},
  {"question":"What is the NEC article for temporary installations?","options":["Article 500","Article 590","Article 430","Article 250"],"correctIndex":1},
  {"question":"What is the maximum length for temporary wiring per NEC 590?","options":["30 days","90 days for construction, remodeling, maintenance, repair, demolition, and similar activities","180 days","1 year"],"correctIndex":1},
  {"question":"What must be done with a portable generator on a construction site?","options":["Nothing","It must be grounded per NEC 250 and OSHA requirements, and bonded to the equipment grounding conductor","It must be indoors","It must be painted yellow"],"correctIndex":1},
  {"question":"What is the advantage of using an inverter generator over a conventional generator for sensitive equipment?","options":["It is cheaper","It produces clean, stable power (low THD) suitable for electronics and tools with variable frequency drives","It is louder","It uses less fuel"],"correctIndex":1}
]'::jsonb
WHERE id = '8cc6e1f5-2a08-4428-9b8f-540453fd57d0';

-- Lesson: OSHA 1926 Subpart K & Temporary Wiring Rules
UPDATE lessons SET quiz = '[
  {"question":"What OSHA standard covers electrical safety in construction?","options":["29 CFR 1910","29 CFR 1926 Subpart K","NEC Article 500","NFPA 70E"],"correctIndex":1},
  {"question":"What is the OSHA requirement for ground-fault circuit protection on construction sites?","options":["Not required","GFCI or an assured equipment grounding conductor program for 120V, 15A and 20A circuits","Only for 240V circuits","Only for indoor use"],"correctIndex":1},
  {"question":"What is an assured equipment grounding conductor program?","options":["A written program that tests all equipment grounding conductors daily for continuity and correct polarity","A visual inspection","A GFCI replacement","A grounding rod test"],"correctIndex":0},
  {"question":"What is the OSHA requirement for flexible cords on construction sites?","options":["They can be used as permanent wiring","They must be used only in continuous lengths without splice or tap; hard service or junior hard service type","They can be spliced freely","They can be used for permanent wiring"],"correctIndex":1},
  {"question":"What must be done with temporary lights on construction sites?","options":["Nothing","They must be guarded to prevent contact with combustible material and have bulb guards","They must be LED","They must be 12V"],"correctIndex":1},
  {"question":"What is the OSHA requirement for working near energized power lines?","options":["No requirement","Minimum clearance distances based on voltage: 10 feet for up to 50kV, plus 4 inches for every 10kV above","5 feet for all voltages","20 feet for all voltages"],"correctIndex":1},
  {"question":"What is the OSHA requirement for electrical equipment that is wet or in damp locations?","options":["Nothing","It must be approved for the location and protected from moisture","It must be indoors","It must be 12V"],"correctIndex":1}
]'::jsonb
WHERE id = '78149199-c250-48a2-b182-4475e305dc72';

-- Course 20: Testing & Commissioning of Electrical Equipment
-- Lesson: NETA Acceptance Testing Overview
UPDATE lessons SET quiz = '[
  {"question":"What does NETA stand for?","options":["National Electrical Testing Association","National Equipment Testing Agency","New Equipment Testing Association","National Electrical Testing Agency"],"correctIndex":0},
  {"question":"What is acceptance testing?","options":["Testing to accept delivery","Testing performed on new equipment to verify it meets specifications before energizing","Testing after failure","Testing during operation"],"correctIndex":1},
  {"question":"What is the NETA standard for acceptance testing?","options":["NETA ATS (Acceptance Testing Specifications)","NETA MTS (Maintenance Testing Specifications)","IEEE 1584","NFPA 70B"],"correctIndex":0},
  {"question":"What tests are typically performed during acceptance testing of a transformer?","options":["Visual inspection only","Insulation resistance, TTR, winding resistance, power factor, oil tests (if oil-filled), and AC hipot","Voltage measurement","Current measurement"],"correctIndex":1},
  {"question":"What is the purpose of a contact resistance test?","options":["To measure wire resistance","To measure the resistance across breaker or contactor contacts to verify they are clean and properly aligned","To test ground resistance","To test insulation"],"correctIndex":1},
  {"question":"What is a primary injection test?","options":["Testing with secondary current","Injecting full-rated current through the primary of a CT or through a breaker to verify operation and trip settings","Testing the insulation","Testing the voltage"],"correctIndex":1},
  {"question":"What must be done before acceptance testing begins?","options":["Nothing","The equipment must be visually inspected, the test plan reviewed, and safety procedures (LOTO) established","The equipment must be energized","The equipment must be painted"],"correctIndex":1}
]'::jsonb
WHERE id = '19ccac6e-ba31-45d2-9c16-f6a4962aeea7';

-- Lesson: Contact Resistance, TTR & Primary Injection
UPDATE lessons SET quiz = '[
  {"question":"What is the acceptable contact resistance for a circuit breaker?","options":["Less than 1 ohm","Typically less than 100-200 micro-ohms, per manufacturer and NETA specifications","Less than 1 milliohm","No limit"],"correctIndex":1},
  {"question":"What does a TTR test measure?","options":["Insulation resistance","The ratio of primary to secondary turns (voltage ratio) in a transformer","Contact resistance","Power factor"],"correctIndex":1},
  {"question":"What is the purpose of primary injection testing?","options":["To test insulation","To verify the operation and calibration of protective relays, CTs, and breakers by injecting current through the primary circuit","To measure resistance","To test voltage"],"correctIndex":1},
  {"question":"What is the NETA acceptance criterion for TTR?","options":["Within 10% of nameplate","Within 0.5% of nameplate ratio for each phase","Within 5% of nameplate","Within 1% of nameplate"],"correctIndex":1},
  {"question":"What instrument is used for a contact resistance (DLRO) test?","options":["A megger","A digital low-resistance ohmmeter (DLRO) using a 10A or higher test current","A multimeter","A clamp meter"],"correctIndex":1},
  {"question":"What is the purpose of a winding resistance test on a transformer?","options":["To measure insulation","To detect open or shorted windings and verify proper tap changer operation by measuring DC resistance of each winding","To test oil","To test power factor"],"correctIndex":1},
  {"question":"What is the purpose of a power factor (dissipation factor) test?","options":["To measure power factor of the load","To measure the insulation power factor (watts loss) of bushings and windings to detect contamination or degradation","To measure voltage","To measure current"],"correctIndex":1}
]'::jsonb
WHERE id = 'f68e43b1-a356-4014-8ff9-5f0bb4cc54bb';

-- Course 21: UPS Systems, Batteries & Backup Power
-- Lesson: Online, Line-Interactive & Standby UPS
UPDATE lessons SET quiz = '[
  {"question":"What is the difference between an online and a standby UPS?","options":["Online is cheaper","Online (double conversion) continuously converts AC to DC and back to AC, providing zero transfer time and complete isolation; standby switches to battery on power loss","Online is slower","Standby provides better power"],"correctIndex":1},
  {"question":"What is the transfer time for a standby (offline) UPS?","options":["Zero","2-10 milliseconds (typically fast enough to maintain most loads)","100 milliseconds","1 second"],"correctIndex":1},
  {"question":"What is the advantage of a line-interactive UPS over a standby UPS?","options":["Zero transfer time","It has a buck/boost transformer that regulates voltage without switching to battery, extending battery life","It is cheaper","It is smaller"],"correctIndex":1},
  {"question":"What is the efficiency of an online (double conversion) UPS?","options":["99%","90-95% (due to double conversion losses)","80%","70%"],"correctIndex":1},
  {"question":"What is the advantage of an online UPS despite lower efficiency?","options":["It is cheaper","Complete isolation from input power, zero transfer time, and consistent output voltage and frequency","It is smaller","It is lighter"],"correctIndex":1},
  {"question":"What is a UPS bypass?","options":["A way to skip the UPS","A path that routes power around the UPS inverter to the load, for maintenance or if the UPS fails","A type of battery","A type of breaker"],"correctIndex":1},
  {"question":"What is the typical backup time for a UPS at full load?","options":["1 hour","5-15 minutes (enough for orderly shutdown or generator transfer)","30 minutes","2 hours"],"correctIndex":1}
]'::jsonb
WHERE id = '72ab11bc-17c6-4146-8ae5-64554c9f7308';

-- Lesson: VRLA & Flooded Battery Testing
UPDATE lessons SET quiz = '[
  {"question":"What does VRLA stand for?","options":["Valve Regulated Lead Acid","Very Reliable Lead Acid","Variable Rate Lead Acid","Voltage Regulated Lead Acid"],"correctIndex":0},
  {"question":"What is the typical design life of a VRLA battery?","options":["1 year","3-5 years for commercial grade, 10+ years for industrial grade","20 years","50 years"],"correctIndex":1},
  {"question":"What is the most common cause of VRLA battery failure?","options":["Overcharging","Dryout (loss of electrolyte water) and positive plate grid corrosion","Undercharging","Temperature"],"correctIndex":1},
  {"question":"What is the recommended float voltage for a 12V VRLA battery?","options":["12.0V","13.5-13.8V (2.25-2.30 V/cell)","14.4V","12.5V"],"correctIndex":1},
  {"question":"What is a load (capacity) test for a battery?","options":["Measuring voltage","Discharging the battery at a specified current for a specified time to verify it can support the load for the required duration","Measuring resistance","Measuring temperature"],"correctIndex":1},
  {"question":"What is the IEEE standard for testing VRLA batteries?","options":["IEEE 1188 (VRLA), IEEE 450 (flooded lead-acid), IEEE 1187 (NiCd)","IEEE 519","IEEE 1584","IEEE 43"],"correctIndex":0},
  {"question":"What is the most important environmental factor affecting battery life?","options":["Humidity","Temperature — every 8°C (15°F) above 25°C (77°F) halves the battery life","Altitude","Vibration"],"correctIndex":1}
]'::jsonb
WHERE id = 'a79c811a-cebd-4bbf-98b9-ce5d54457b10';

-- Course 22: Variable Frequency Drive Installation & Commissioning
-- Lesson: VFD Wiring, EMC & Motor Cable Selection
UPDATE lessons SET quiz = '[
  {"question":"What type of cable is recommended for VFD motor connections?","options":["Standard THHN in conduit","Shielded, symmetrical cable (three conductors plus a full-size ground, or three grounds) to minimize EMI and bearing currents","Romex","Any cable"],"correctIndex":1},
  {"question":"What is the maximum recommended motor cable length for a VFD without output filtering?","options":["10 feet","50-100 feet (varies by manufacturer; longer lengths require output reactors or dV/dt filters)","500 feet","No limit"],"correctIndex":1},
  {"question":"What is the purpose of a VFD output reactor?","options":["To improve power factor","To reduce the rate of voltage rise (dV/dt) and peak voltage at the motor terminals, protecting motor insulation","To reduce harmonics on the input","To increase motor speed"],"correctIndex":1},
  {"question":"What is EMC (Electromagnetic Compatibility) in VFD installations?","options":["A brand name","The requirement that the VFD does not emit excessive EMI and is immune to external EMI — addressed by proper grounding, shielding, and cable routing","A type of cable","A type of filter"],"correctIndex":1},
  {"question":"Why must the VFD be grounded properly?","options":["For safety only","For safety, to minimize common-mode voltage and bearing currents, and to meet EMC requirements","To improve efficiency","To reduce harmonics"],"correctIndex":1},
  {"question":"What is the purpose of a line reactor on the input of a VFD?","options":["To protect the motor","To reduce input harmonic currents and protect the VFD from line transients","To improve power factor","To increase voltage"],"correctIndex":1},
  {"question":"What is the recommended grounding method for a VFD installation?","options":["A single ground rod","A low-impedance, high-frequency bond between the VFD, motor, and panel using flat braided grounding straps or a full-size equipment grounding conductor","No grounding needed","Grounding to the nearest water pipe"],"correctIndex":1}
]'::jsonb
WHERE id = '6ecbed5a-a145-4b6e-9007-a188054bd430';

-- Lesson: Startup Procedure & Commissioning Hand-off
UPDATE lessons SET quiz = '[
  {"question":"What is the first step in VFD commissioning?","options":["Turn on the motor","Verify all wiring, enter motor nameplate data, and perform safety checks before energizing","Set the frequency","Set the ramp time"],"correctIndex":1},
  {"question":"What must be entered from the motor nameplate before running the VFD?","options":["Nothing","Motor rated voltage, FLA, frequency, RPM, and power (HP/kW)","Motor color","Motor manufacturer"],"correctIndex":1},
  {"question":"What is auto-tuning (auto-tuning) and when is it required?","options":["It is always optional","A procedure that measures motor electrical parameters for optimal vector control; required for sensorless vector and flux vector modes","It is only for large motors","It is only for fans"],"correctIndex":1},
  {"question":"What should be verified during the first test run?","options":["Nothing","Motor direction of rotation, smooth acceleration, no abnormal noise or vibration, and correct speed at the reference signal","Current draw only","Voltage only"],"correctIndex":1},
  {"question":"What is the purpose of a commissioning hand-off document?","options":["Paperwork only","To transfer responsibility from the commissioning team to operations, including all settings, test results, and operating instructions","To close the project","To invoice the customer"],"correctIndex":1},
  {"question":"What is a jog test during commissioning?","options":["Running the motor at full speed","Briefly jogging the motor to verify direction of rotation before full-speed operation","Testing the brake","Testing the encoder"],"correctIndex":1},
  {"question":"What should be done if the motor runs in the wrong direction during commissioning?","options":["Replace the motor","Swap any two of the three motor output leads at the VFD (not at the motor) and re-test","Reverse the input phases","Change a parameter"],"correctIndex":1}
]'::jsonb
WHERE id = '1b6e0fee-171d-4cbb-aca3-64fb0b0e1859';
