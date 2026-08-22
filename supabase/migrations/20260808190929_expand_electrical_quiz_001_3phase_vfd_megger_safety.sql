-- ============================================================
-- PART 1: Expand existing quizzes to 7 questions for courses 2-5
-- (3-Phase Power, VFD Fundamentals, Motor Testing with Megger, Electrical Safety & Arc Flash)
-- ============================================================

-- Course 2: 3-Phase Power Systems & Troubleshooting
-- Lesson: Wye & Delta Systems (existing 2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"What phase-to-neutral voltage does a 480V wye system provide?","options":["240V","277V","480V","120V"],"correctIndex":1},
  {"question":"In a delta system, what is the relationship between line voltage and phase voltage?","options":["Line voltage is sqrt(3) times phase voltage","Line voltage equals phase voltage","Line voltage is half phase voltage","Line voltage is double phase voltage"],"correctIndex":1},
  {"question":"In a wye system, what is the relationship between line current and phase current?","options":["Line current is sqrt(3) times phase current","Line current equals phase current","Line current is half phase current","Line current is double phase current"],"correctIndex":1},
  {"question":"What is a corner-grounded delta system?","options":["A wye system with one phase grounded","A delta system with one phase conductor grounded","A delta system with a grounded neutral","A system with all three phases grounded"],"correctIndex":1},
  {"question":"Why is 277V commonly used for industrial lighting?","options":["It is the phase-to-neutral voltage of a 480V wye system","It is safer than 120V","It requires smaller conductors","It is a standard delta voltage"],"correctIndex":0},
  {"question":"What happens if you connect a wye-rated motor to a delta system of the same line voltage?","options":["The motor runs normally","The motor receives too much voltage and may burn out","The motor runs at half speed","The motor receives too little voltage"],"correctIndex":1},
  {"question":"When verifying a 480V wye system, what should phase-to-neutral and phase-to-phase readings be?","options":["480V/480V","277V/480V","120V/277V","240V/480V"],"correctIndex":1}
]'::jsonb
WHERE id = 'fa36f6c2-bf02-400f-9bd6-89c5acef9b58';

-- Lesson: Voltage Unbalance & Phasing (existing 2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"What is the maximum recommended voltage unbalance per NEMA?","options":["1%","3%","5%","10%"],"correctIndex":0},
  {"question":"What should a phasing check read across corresponding phases before closing a tie breaker?","options":["Full line voltage","Half line voltage","Near zero","Rated current"],"correctIndex":2},
  {"question":"A 1% voltage unbalance can cause approximately how much current unbalance in a motor?","options":["1%","3-5%","6-10%","15%"],"correctIndex":2},
  {"question":"What is the NEMA formula for voltage unbalance?","options":["(Max deviation / average) x 100","(Max voltage / min voltage) x 100","(Average / max deviation) x 100","(Sum of voltages / 3) x 100"],"correctIndex":0},
  {"question":"Why is voltage unbalance more damaging than overall low voltage?","options":["It is not more damaging","It causes uneven heating and negative sequence currents","It causes overvoltage","It has no effect on motors"],"correctIndex":1},
  {"question":"What instrument is used for a phasing check before paralleling two sources?","options":["A clamp meter","A voltmeter or phasing tester rated for the voltage","An ohmmeter","A megohmmeter"],"correctIndex":1},
  {"question":"If phasing reads full line voltage across one pair but zero across the other two, what does it indicate?","options":["All phases are matched","One phase is matched and two are rolled","The system is single-phased","The transformer is overloaded"],"correctIndex":1}
]'::jsonb
WHERE id = '1a6170e5-0865-4e38-b498-83722a3e7ece';

-- Course 3: VFD Fundamentals & Parameterization
-- Lesson: Rectifier, DC Bus & IGBT Output (existing 2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"What is the function of the DC bus capacitor in a VFD?","options":["To rectify AC to DC","To smooth the DC ripple and store energy","To invert DC to AC","To protect against short circuits"],"correctIndex":1},
  {"question":"What does IGBT stand for?","options":["Insulated Gate Bipolar Transistor","Integrated Gate Base Transistor","Insulated Gate Base Transistor","Integrated Gate Bipolar Transistor"],"correctIndex":0},
  {"question":"What type of rectifier is used in most standard VFDs?","options":["A full-wave controlled rectifier","A half-wave rectifier","A 6-pulse diode bridge","A 12-pulse SCR bridge"],"correctIndex":2},
  {"question":"What is the typical DC bus voltage on a 480V VFD?","options":["480V DC","650V DC","277V DC","120V DC"],"correctIndex":1},
  {"question":"How does a VFD create a variable output frequency?","options":["By changing the DC bus voltage","By rapidly switching the IGBTs on and off (PWM)","By varying the input frequency","By using a variable transformer"],"correctIndex":1},
  {"question":"What is carrier frequency in a VFD?","options":["The frequency of the motor","The switching frequency of the IGBTs","The input line frequency","The DC bus ripple frequency"],"correctIndex":1},
  {"question":"Why might a VFD pre-charge circuit fail?","options":["Because of excessive carrier frequency","Because of a shorted DC bus capacitor or diode bridge","Because of low motor speed","Because of incorrect parameterization"],"correctIndex":1}
]'::jsonb
WHERE id = (SELECT l.id FROM lessons l JOIN modules m ON l.module_id = m.id JOIN courses c ON m.course_id = c.id WHERE c.title = 'VFD Fundamentals & Parameterization' AND l.title = 'Rectifier, DC Bus & IGBT Output');

-- Lesson: Essential Parameters & Auto-Tune (existing 2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"What is the purpose of auto-tune (auto-tuning) in a VFD?","options":["To set the carrier frequency","To measure motor parameters for accurate vector control","To adjust the input voltage","To set the motor FLA manually"],"correctIndex":1},
  {"question":"Which parameter must always match the motor nameplate?","options":["Carrier frequency","Motor rated voltage, current, and frequency","DC bus voltage","Ramp-up time"],"correctIndex":1},
  {"question":"What is V/Hz control mode best suited for?","options":["High-precision torque control","Simple constant-torque and variable-torque fan/pump applications","Servo positioning","Regenerative braking"],"correctIndex":1},
  {"question":"What is sensorless vector control?","options":["Control without any feedback device, estimating motor flux from electrical measurements","Control using a resolver","Control using an encoder","Open-loop V/Hz control"],"correctIndex":0},
  {"question":"What happens if the motor FLA parameter is set too low?","options":["The motor will overspeed","The drive may trip on overcurrent or underperform","The motor will draw excessive current","Nothing — it is a non-critical parameter"],"correctIndex":1},
  {"question":"What is the purpose of the acceleration ramp time parameter?","options":["To limit motor speed","To control how quickly the motor reaches set speed","To set the maximum frequency","To adjust the carrier frequency"],"correctIndex":1},
  {"question":"Why should a rotating auto-tune be performed with the motor uncoupled when possible?","options":["It is safer for the drive","It measures motor inertia without load interference","It is required by NEC","It reduces motor heating"],"correctIndex":1}
]'::jsonb
WHERE id = (SELECT l.id FROM lessons l JOIN modules m ON l.module_id = m.id JOIN courses c ON m.course_id = c.id WHERE c.title = 'VFD Fundamentals & Parameterization' AND l.title = 'Essential Parameters & Auto-Tune');

-- Lesson: Common VFD Faults (existing 1 question → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"What typically causes a DC bus overvoltage trip on deceleration?","options":["Regenerative energy from a high-inertia load","A shorted motor winding","A loose input connection","Excessive carrier frequency"],"correctIndex":0},
  {"question":"What is the most common cause of an overcurrent fault on a VFD?","options":["Low carrier frequency","A short in the motor or output cable","Excessive ramp time","Low input voltage"],"correctIndex":1},
  {"question":"What fault is caused by excessive heat in the drive?","options":["Overvoltage","Overload/Heatsink overtemperature","Ground fault","Phase loss"],"correctIndex":1},
  {"question":"What does an output phase loss fault indicate?","options":["A missing input phase","An open connection between the drive and motor","A DC bus undervoltage","A parameter error"],"correctIndex":1},
  {"question":"What is a common fix for DC bus overvoltage on deceleration?","options":["Increase the deceleration time or add a braking resistor","Decrease the deceleration time","Increase the carrier frequency","Disable the fault"],"correctIndex":0},
  {"question":"What does a ground fault on a VFD output typically indicate?","options":["A loose control wire","Insulation breakdown in the motor or output cable","Low input voltage","An oversized motor"],"correctIndex":1},
  {"question":"What should you check first when a VFD trips on input phase loss?","options":["The motor cable","The input power connections and voltage balance","The carrier frequency","The auto-tune settings"],"correctIndex":1}
]'::jsonb
WHERE id = (SELECT l.id FROM lessons l JOIN modules m ON l.module_id = m.id JOIN courses c ON m.course_id = c.id WHERE c.title = 'VFD Fundamentals & Parameterization' AND l.title = 'Common VFD Faults');

-- Course 4: Motor Testing with Megger & PI
-- Lesson: Megger Test Procedure & Interpretation (existing 2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"What is the minimum acceptable insulation resistance for a 480V motor?","options":["0.5 megohm","1 megohm","100 megohms","1000 megohms"],"correctIndex":1},
  {"question":"What test voltage is typically used for a 480V motor?","options":["100V DC","250V DC","500V DC or 1000V DC","5000V DC"],"correctIndex":2},
  {"question":"Why must the motor be disconnected from the drive or starter before meggering?","options":["To get a more accurate reading","To avoid damaging electronic components in the drive or starter","To save time","It does not matter"],"correctIndex":1},
  {"question":"What does a very low insulation resistance reading indicate?","options":["The motor is in excellent condition","The insulation has degraded or is contaminated with moisture","The motor is running too fast","The bearings are worn"],"correctIndex":1},
  {"question":"How long should you continue applying test voltage for a standard insulation resistance test?","options":["1 second","10 seconds","1 minute (or until reading stabilizes)","30 minutes"],"correctIndex":2},
  {"question":"What should you do with the motor leads after completing a megger test?","options":["Nothing","Discharge the windings by grounding them","Apply more voltage","Test again immediately"],"correctIndex":1},
  {"question":"What is the IEEE 43 standard minimum insulation resistance for form-wound motors?","options":["1 megohm","5 megohms","100 megohms","1000 megohms"],"correctIndex":1}
]'::jsonb
WHERE id = (SELECT l.id FROM lessons l JOIN modules m ON l.module_id = m.id JOIN courses c ON m.course_id = c.id WHERE c.title = 'Motor Testing with Megger & PI' AND l.title = 'Megger Test Procedure & Interpretation');

-- Lesson: Polarization Index & Dielectric Absorption (existing 2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"What is the Polarization Index (PI)?","options":["The ratio of 10-minute to 1-minute insulation resistance","The ratio of 1-minute to 10-minute insulation resistance","The ratio of 30-second to 60-second resistance","The absolute insulation resistance at 10 minutes"],"correctIndex":0},
  {"question":"What PI value is considered acceptable per IEEE 43?","options":["1.0 or greater","2.0 or greater","5.0 or greater","10.0 or greater"],"correctIndex":1},
  {"question":"What does a PI value below 1.0 indicate?","options":["Excellent insulation","The insulation is wet, dirty, or degraded","The test voltage was too high","The motor is too cold"],"correctIndex":1},
  {"question":"What is the Dielectric Absorption Ratio (DAR)?","options":["The ratio of 60-second to 30-second resistance","The ratio of 10-minute to 1-minute resistance","The ratio of 1-minute to 600-second resistance","The absolute resistance at 30 seconds"],"correctIndex":0},
  {"question":"What DAR value is considered good for most industrial motors?","options":["1.0","1.4 or greater","2.0 or greater","5.0 or greater"],"correctIndex":1},
  {"question":"Why is PI less meaningful on very high-resistance (new) motors?","options":["It is more meaningful on new motors","The readings are so high that the ratio approaches 1.0","New motors cannot be tested","PI only applies to DC motors"],"correctIndex":1},
  {"question":"What temperature consideration is important when performing PI tests?","options":["Temperature does not affect insulation resistance","Insulation resistance decreases with increasing temperature; readings must be temperature-corrected","Tests should only be done below 0°C","Insulation resistance increases with temperature"],"correctIndex":1}
]'::jsonb
WHERE id = (SELECT l.id FROM lessons l JOIN modules m ON l.module_id = m.id JOIN courses c ON m.course_id = c.id WHERE c.title = 'Motor Testing with Megger & PI' AND l.title = 'Polarization Index & Dielectric Absorption');

-- Course 5: Electrical Safety & Arc Flash Awareness
-- Lesson: Approach Boundaries (existing 2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"What is the limited approach boundary?","options":["The closest distance an unqualified person may approach energized equipment","The distance at which arc flash energy is 1.2 cal/cm²","The closest a qualified person may approach without PPE","The distance for grounding"],"correctIndex":0},
  {"question":"What is the arc flash boundary?","options":["The distance at which incident energy equals 1.2 cal/cm²","The distance at which voltage drops to safe levels","The distance for unqualified workers","The boundary for LOTO application"],"correctIndex":0},
  {"question":"What is the restricted approach boundary?","options":["The closest a qualified person may approach without arc-rated PPE and an energized work permit","The boundary for unqualified personnel","The distance for grounding","The arc flash boundary"],"correctIndex":0},
  {"question":"At what incident energy level does a second-degree burn occur?","options":["0.5 cal/cm²","1.2 cal/cm²","5.0 cal/cm²","10.0 cal/cm²"],"correctIndex":1},
  {"question":"What determines the arc flash boundary?","options":["The system voltage only","The available fault current and clearing time of the protective device","The size of the enclosure","The type of PPE worn"],"correctIndex":1},
  {"question":"Who may cross the limited approach boundary?","options":["Anyone","Only qualified persons, or unqualified persons when escorted by a qualified person","Only the facility owner","Only electricians"],"correctIndex":1},
  {"question":"What is required to cross the restricted approach boundary?","options":["Nothing special","Arc-rated PPE, an energized work permit, and a documented justification","Just safety glasses","A hard hat"],"correctIndex":1}
]'::jsonb
WHERE id = (SELECT l.id FROM lessons l JOIN modules m ON l.module_id = m.id JOIN courses c ON m.course_id = c.id WHERE c.title = 'Electrical Safety & Arc Flash Awareness' AND l.title = 'Approach Boundaries');

-- Lesson: PPE Category Selection (existing 2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"What is PPE Category 1 arc-rated clothing?","options":["4 cal/cm² minimum ATPV","8 cal/cm² minimum ATPV","1.2 cal/cm² minimum ATPV","40 cal/cm² minimum ATPV"],"correctIndex":0},
  {"question":"What is PPE Category 2 arc-rated clothing?","options":["4 cal/cm² minimum ATPV","8 cal/cm² minimum ATPV","25 cal/cm² minimum ATPV","40 cal/cm² minimum ATPV"],"correctIndex":1},
  {"question":"What does ATPV stand for?","options":["Arc Thermal Performance Value","Arc Test Protection Voltage","Arc Thermal Protective Vest","Arc Threshold Performance Value"],"correctIndex":0},
  {"question":"What PPE category requires a minimum of 25 cal/cm²?","options":["Category 1","Category 2","Category 3","Category 4"],"correctIndex":2},
  {"question":"What PPE category requires a minimum of 40 cal/cm²?","options":["Category 1","Category 2","Category 3","Category 4"],"correctIndex":3},
  {"question":"Above what incident energy level is it generally not permitted to perform energized work?","options":["1.2 cal/cm²","8 cal/cm²","25 cal/cm²","40 cal/cm²"],"correctIndex":3},
  {"question":"What must be worn under arc-rated clothing?","options":["Nothing","Non-melting, flammable layers (cotton)","Synthetic base layers for warmth","Any clothing"],"correctIndex":1}
]'::jsonb
WHERE id = (SELECT l.id FROM lessons l JOIN modules m ON l.module_id = m.id JOIN courses c ON m.course_id = c.id WHERE c.title = 'Electrical Safety & Arc Flash Awareness' AND l.title = 'PPE Category Selection');

-- Lesson: Energized Work Permits & Lockout/Tagout (existing 2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"When is an energized work permit required?","options":["Whenever work is performed on energized equipment above 50V","Only for arc flash work","Only for low voltage","Never"],"correctIndex":0},
  {"question":"What is the first step of lockout/tagout?","options":["Apply the lock","Identify and isolate all energy sources","Notify the supervisor","Test for absence of voltage"],"correctIndex":1},
  {"question":"What must be done after isolating energy sources but before beginning work?","options":["Apply locks and tags","Verify absence of voltage with a rated tester","Both A and B","Notify the supervisor"],"correctIndex":2},
  {"question":"Who is authorized to remove a lock that is not their own?","options":["Any supervisor","The person who applied it, or a specific removal procedure if they are unavailable","Any qualified worker","The facility manager"],"correctIndex":1},
  {"question":"What is the purpose of a group lockout?","options":["To save time","To allow multiple workers to be protected by a lockbox with individual locks","To avoid individual locks","To reduce the number of tags"],"correctIndex":1},
  {"question":"What is a LOTO exception for cord-and-plug connected equipment?","options":["No LOTO is needed","If the plug is under the exclusive control of the worker, formal LOTO may not be required","Cord-and-plug equipment never needs LOTO","Only the plug needs to be tagged"],"correctIndex":1},
  {"question":"What must an energized work permit include?","options":["Justification for why the work cannot be de-energized","A description of the safe work practices and PPE required","The signatures of responsible parties","All of the above"],"correctIndex":3}
]'::jsonb
WHERE id = (SELECT l.id FROM lessons l JOIN modules m ON l.module_id = m.id JOIN courses c ON m.course_id = c.id WHERE c.title = 'Electrical Safety & Arc Flash Awareness' AND l.title = 'Energized Work Permits & Lockout/Tagout');
