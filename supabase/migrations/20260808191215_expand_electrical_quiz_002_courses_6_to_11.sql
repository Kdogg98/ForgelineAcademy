-- ============================================================
-- PART 3a: Expand existing quizzes to 7 questions for courses 6-11
-- ============================================================

-- Course 6: Conduit, Cable Tray & Industrial Wiring Methods
-- Lesson: Rigid, EMT & Conduit Bending
UPDATE lessons SET quiz = '[
  {"question":"What is the maximum conduit fill for three or more conductors?","options":["31%","40%","53%","60%"],"correctIndex":1},
  {"question":"What must be done to conduit ends before pulling wire?","options":["Paint them","Ream them to remove burrs","Thread them","Cap them"],"correctIndex":1},
  {"question":"What is the minimum radius for a conduit bend?","options":["3 times the conduit diameter","6 times the conduit diameter for 1/2-inch to 2-inch","10 times the conduit diameter","Any radius is acceptable"],"correctIndex":1},
  {"question":"How many 90-degree bends are allowed in one conduit run between pull points?","options":["1","2","4","No limit, but more than 4 quarter bends requires a junction box"],"correctIndex":3},
  {"question":"What is the advantage of EMT over RMC (rigid metal conduit)?","options":["It is stronger","It is lighter and easier to bend, requiring no threading","It can be used outdoors without protection","It has higher ampacity"],"correctIndex":1},
  {"question":"What type of bender is used for large-diameter rigid conduit?","options":["Hand bender","Mechanical or hydraulic bender","Knee bender","No bender is needed"],"correctIndex":1},
  {"question":"What is the purpose of a conduit body (LB, LL, LR)?","options":["To change conduit direction","To provide access for pulling and splicing, and to allow direction changes","To reduce condensation","To ground the conduit"],"correctIndex":1}
]'::jsonb
WHERE id = 'a7fa7cda-3524-45c9-8236-cfa24cb54f0c';

-- Lesson: Cable Tray & Tray Cable
UPDATE lessons SET quiz = '[
  {"question":"What separation between power and control cables in a cable tray prevents EMI?","options":["0.5 inches","At least 2 inches or a solid divider","No separation needed","6 inches"],"correctIndex":1},
  {"question":"What type of cable is rated for installation in cable trays?","options":["THHN","Type TC (tray cable)","Romex","UF"],"correctIndex":1},
  {"question":"What is the maximum cable tray fill for solid bottom tray with multi-conductor cables?","options":["25%","40%","50%","75%"],"correctIndex":2},
  {"question":"What is the maximum spacing for cable tray support?","options":["3 feet","5 feet","10 feet","8 feet for NEMA 12C, 5 feet for NEMA 8A"],"correctIndex":3},
  {"question":"What must be done where cable tray penetrates a fire-rated wall?","options":["Nothing","Install firestop to maintain the fire rating","Remove the tray section","Install a larger tray"],"correctIndex":1},
  {"question":"What is the minimum bending radius for Type TC cable in a tray?","options":["3 times the cable diameter","5 times the cable diameter","10 times the cable diameter","12 times the cable diameter for cables over 1 inch"],"correctIndex":3},
  {"question":"What is the purpose of a cable tray divider?","options":["To increase fill capacity","To separate different voltage levels or power and control cables","To strengthen the tray","To improve drainage"],"correctIndex":1}
]'::jsonb
WHERE id = 'd70a5d17-ea99-448f-8b39-e04d8bb28519';

-- Lesson: Conductor Pulling & NEC Chapter 3 Requirements
UPDATE lessons SET quiz = '[
  {"question":"How much does each 90-degree bend multiply the pulling tension?","options":["1.5x","2.2x","5x","10x"],"correctIndex":1},
  {"question":"What does pulling lubricant do?","options":["Cools the cable","Reduces friction by 50% and prevents insulation damage","Prevents corrosion","Improves conductivity"],"correctIndex":1},
  {"question":"What NEC chapter covers wiring methods?","options":["Chapter 1","Chapter 2","Chapter 3","Chapter 9"],"correctIndex":2},
  {"question":"What is the maximum pulling tension for copper conductors?","options":["0.008 x circular mil area","0.01 x circular mil area","0.1 x circular mil area","No limit"],"correctIndex":0},
  {"question":"What is the minimum bend radius for single-conductor cables?","options":["5 times the cable diameter","8 times the cable diameter for 0-500 kcmil, 10 times for over 500 kcmil","12 times the cable diameter","No minimum"],"correctIndex":1},
  {"question":"What must be verified before pulling conductors into existing conduit?","options":["The conduit color","That the conduit is clean and free of obstructions","The ambient temperature","The conduit manufacturer"],"correctIndex":1},
  {"question":"What is the NEC maximum number of current-carrying conductors in a raceway before derating applies?","options":["3","4 or more","6","10"],"correctIndex":1}
]'::jsonb
WHERE id = 'f5e47794-bb22-4239-8947-db50e04661e8';

-- Course 7: Control Transformers & 24V Control Circuits
-- Lesson: Control Transformer Sizing & Inrush
UPDATE lessons SET quiz = '[
  {"question":"Why must a control transformer be sized for inrush as well as continuous load?","options":["To save energy","To supply the pull-in VA without the secondary voltage dropping below 85%","To reduce heat","To improve power factor"],"correctIndex":1},
  {"question":"What type of fuse is used on the primary of a control transformer?","options":["Fast-acting","Time-delay (to tolerate inrush)","No fuse","High-voltage"],"correctIndex":1},
  {"question":"What is the typical inrush VA for a control transformer relative to its rated VA?","options":["1x","2-3x","5-10x","20x"],"correctIndex":2},
  {"question":"What is the standard control voltage for industrial control circuits?","options":["12V AC","24V AC or 24V DC","120V AC","240V AC"],"correctIndex":1},
  {"question":"What happens if a control transformer is undersized?","options":["It runs cooler","Contactors may chatter or fail to pull in due to voltage sag during inrush","It improves efficiency","Nothing — transformers self-regulate"],"correctIndex":1},
  {"question":"What is the VA rating needed for a circuit with three contactors each drawing 8VA sealed and 50VA inrush?","options":["24VA","150VA","174VA (sealing) and 150VA (inrush) — size for the higher of the two with margin","500VA"],"correctIndex":2},
  {"question":"Why are both primary fuses required on a control transformer (not just one)?","options":["For redundancy","To clear faults on either leg of the primary circuit","To reduce cost","They are not required"],"correctIndex":1}
]'::jsonb
WHERE id = '5025f0eb-4e7b-4903-9a9b-01e17dc7188e';

-- Lesson: Voltage Drop & Ground Fault Diagnosis
UPDATE lessons SET quiz = '[
  {"question":"What voltage drop on a 24V circuit can cause contactor chatter?","options":["0.1V","1.2V (5%)","5V","10V"],"correctIndex":1},
  {"question":"On a healthy 24V control circuit, what does each side read to ground?","options":["Both read 12V","One reads 24V, the other reads 0V","Both read 24V","Both read 0V"],"correctIndex":1},
  {"question":"What is the maximum recommended voltage drop for a control circuit?","options":["1%","5%","10%","20%"],"correctIndex":1},
  {"question":"What does a reading of 0V on both sides of a 24V control circuit to ground indicate?","options":["Normal operation","An open fuse or breaker on one side","A ground fault","The transformer is bad"],"correctIndex":1},
  {"question":"What is a common cause of intermittent control circuit failures?","options":["Oversized wire","Loose connections that create voltage drop under load","Undersized transformer VA","All of the above"],"correctIndex":1},
  {"question":"How do you find a ground fault in a 24V control circuit?","options":["Replace all components","Disconnect the circuit in sections and megger each section to ground","Add more fuses","Increase the voltage"],"correctIndex":1},
  {"question":"What instrument is best for diagnosing voltage drop in a control circuit?","options":["A clamp meter","A digital multimeter measuring voltage across each connection under load","An ohmmeter","A megger"],"correctIndex":1}
]'::jsonb
WHERE id = 'e690507b-251e-4623-a176-5bac25d2641c';

-- Course 8: Electrical Prints, Schematics & Ladder Diagrams
-- Lesson: One-Line, Ladder & Wiring Diagrams
UPDATE lessons SET quiz = '[
  {"question":"Which drawing is the primary tool for troubleshooting control circuits?","options":["One-line diagram","Ladder (schematic) diagram","Wiring diagram","Panel layout"],"correctIndex":1},
  {"question":"What does a wiring diagram show that a ladder diagram does not?","options":["The control logic","The physical layout of wires and components","The power distribution","The line numbers"],"correctIndex":1},
  {"question":"What does a one-line diagram show?","options":["Control logic","The power distribution system in a simplified single-line format","Wire routing","Terminal numbers"],"correctIndex":1},
  {"question":"In a ladder diagram, what do the left and right rails represent?","options":["Input and output","L1 (hot) and L2 (neutral) — the power source","Start and stop","Open and closed"],"correctIndex":1},
  {"question":"How are components shown in a ladder diagram?","options":["In their energized state","In their de-energized (shelf) state","In their running state","In any state"],"correctIndex":1},
  {"question":"What does a reference number on the right side of a ladder coil indicate?","options":["The wire size","The line numbers where the coil''s contacts appear","The voltage rating","The component manufacturer"],"correctIndex":1},
  {"question":"What is the purpose of wire numbers on a ladder diagram?","options":["To identify the wire gauge","To uniquely identify each wire for troubleshooting and documentation","To indicate voltage level","To indicate wire color"],"correctIndex":1}
]'::jsonb
WHERE id = '97f42cc0-7487-47f8-be78-a6a5e6611cc3';

-- Lesson: Terminal Blocks & Cross-Referencing
UPDATE lessons SET quiz = '[
  {"question":"What does the terminal block represent in troubleshooting?","options":["The control logic","The interface between panel and field wiring","The power source","The motor connection"],"correctIndex":1},
  {"question":"What must be done when wiring is changed during a repair?","options":["Nothing","Document the changes on the as-built drawings","Replace the drawings entirely","Note it in the CMMS only"],"correctIndex":1},
  {"question":"What is the purpose of cross-referencing in ladder diagrams?","options":["To identify wire size","To link contacts and coils that appear on different rungs","To show voltage levels","To indicate wire color"],"correctIndex":1},
  {"question":"What does a terminal number on a component indicate?","options":["The wire size","The specific connection point on the component for wiring","The voltage level","The component sequence"],"correctIndex":1},
  {"question":"What is a common error when modifying control circuits?","options":["Using the wrong wire color","Failing to update the drawings, making future troubleshooting impossible","Overtightening terminals","Using too many terminal blocks"],"correctIndex":1},
  {"question":"What is the advantage of numbered terminal blocks over unnumbered ones?","options":["They are cheaper","They allow systematic troubleshooting by providing a test point for each wire","They carry more current","They are not required by code"],"correctIndex":1},
  {"question":"What should you do if the as-built drawings do not match the actual wiring?","options":["Ignore the discrepancy","Update the drawings to match the actual wiring and verify the changes are correct","Remove the wiring","Replace the drawings with new ones"],"correctIndex":1}
]'::jsonb
WHERE id = 'c6a9555d-dd38-4c65-bc57-ced342c89ff2';

-- Course 9: Electrical Safety Programs & NFPA 70E Application
-- Lesson: Building an NFPA 70E Safety Program
UPDATE lessons SET quiz = '[
  {"question":"How often must an NFPA 70E electrical safety program be audited?","options":["Annually","At least every 3 years","Every 5 years","Only after an incident"],"correctIndex":1},
  {"question":"What is the default approach to electrical work per NFPA 70E?","options":["Work energized by default","De-energization is the default","Always use insulated tools","Work without a permit"],"correctIndex":1},
  {"question":"Who is responsible for the electrical safety program?","options":["The electricians","The employer (management)","The safety officer only","OSHA"],"correctIndex":1},
  {"question":"What must the safety program include for energized work?","options":["Just PPE","Justification, an energized work permit, and appropriate PPE","A note in the logbook","Supervisor approval only"],"correctIndex":1},
  {"question":"What training is required for qualified persons under NFPA 70E?","options":["A one-hour orientation","Training on safe work practices, hazard recognition, emergency procedures, and PPE selection — refreshed at least every 3 years","A college degree","No formal training"],"correctIndex":1},
  {"question":"What must be included in the electrical safety program regarding LOTO?","options":["Nothing specific","Lockable disconnecting means, procedures, training, and verification of isolation","Just a note to use locks","Annual LOTO drills"],"correctIndex":1},
  {"question":"What is the purpose of an electrical safety audit?","options":["To find fault with workers","To verify the program is being followed and is effective","To satisfy OSHA paperwork","To reduce insurance costs"],"correctIndex":1}
]'::jsonb
WHERE id = '5e4774e0-669f-4108-9d23-cf11a8472910';

-- Lesson: Job Briefings & Incident Investigation
UPDATE lessons SET quiz = '[
  {"question":"What must a job briefing cover before each electrical task?","options":["Only the task description","The task, hazards, PPE, LOTO, emergency response, and special conditions","Only the PPE","Only the LOTO procedure"],"correctIndex":1},
  {"question":"How should a near miss be investigated?","options":["It does not need investigation","With the same rigor as an injury","Only if it involves management","Only if equipment is damaged"],"correctIndex":1},
  {"question":"How often should job briefings be conducted?","options":["Once per project","Before each shift or task, and whenever conditions change","Weekly","Monthly"],"correctIndex":1},
  {"question":"What should be documented after a job briefing?","options":["Nothing","The briefing content, participants, and date","Only the task","Only the time"],"correctIndex":1},
  {"question":"What is the purpose of incident investigation?","options":["To assign blame","To identify root causes and prevent recurrence","To satisfy regulatory requirements","To reduce insurance premiums"],"correctIndex":1},
  {"question":"What is a near miss?","options":["An incident that almost caused injury or damage but did not","A minor injury","A first aid case","An equipment failure"],"correctIndex":0},
  {"question":"What is the benefit of investigating near misses?","options":["It satisfies OSHA requirements","It identifies hazards before they cause actual harm","It is required by NFPA 70E","It reduces workers'' compensation costs"],"correctIndex":1}
]'::jsonb
WHERE id = '94a519ac-db6b-4ef2-8c26-c69b630d959e';

-- Course 10: Electrical Troubleshooting Methodology
-- Lesson: The Half-Split Method & Decision Trees
UPDATE lessons SET quiz = '[
  {"question":"How many checks does the half-split method require for a circuit with 8 components?","options":["8","4","3","1"],"correctIndex":2},
  {"question":"What is the first check in the half-split method for a motor control circuit?","options":["The motor","The control voltage at the transformer","The start button","The overload relay"],"correctIndex":1},
  {"question":"What is the advantage of the half-split method over sequential checking?","options":["It is more thorough","It reduces the number of checks by testing at the midpoint of the circuit","It requires no tools","It works for all faults"],"correctIndex":1},
  {"question":"What is a decision tree in troubleshooting?","options":["A type of wiring diagram","A systematic flowchart that guides troubleshooting decisions based on symptoms and test results","A software program","A list of spare parts"],"correctIndex":1},
  {"question":"What should you do before starting the half-split method?","options":["Replace all components","Understand the circuit by studying the schematic and identifying test points","Order parts","Call the manufacturer"],"correctIndex":1},
  {"question":"What does the half-split method assume?","options":["That the fault is at the midpoint","That there is a single fault and the circuit can be tested at any point","That all components are bad","That the circuit is DC"],"correctIndex":1},
  {"question":"When is the half-split method less effective?","options":["On DC circuits","When there are multiple simultaneous faults or intermittent connections","On AC circuits","On digital circuits"],"correctIndex":1}
]'::jsonb
WHERE id = '5a01fb65-3a33-4bfe-aac0-a3655cfcc32a';

-- Lesson: Voltage Drop & Current Measurement
UPDATE lessons SET quiz = '[
  {"question":"What voltage drop across a loaded connection indicates a problem?","options":["Less than 0.1V","0.5V or more","1V","5V"],"correctIndex":1},
  {"question":"What does a current unbalance greater than 10% between phases indicate?","options":["Normal operation","Voltage unbalance, bad winding, or loose connection","Undersized motor","Overload"],"correctIndex":2},
  {"question":"What is the most common cause of voltage drop in a control circuit?","options":["Oversized wire","Loose or corroded connections","Undersized transformer","Long wire runs"],"correctIndex":1},
  {"question":"How should current be measured in a motor circuit?","options":["With a voltmeter","With a clamp-on ammeter around each phase","With an ohmmeter","By calculating from voltage"],"correctIndex":1},
  {"question":"What does a voltage reading of near zero across a closed contact indicate?","options":["The contact is open","The contact is closed and conducting properly","The contact is shorted","The circuit is de-energized"],"correctIndex":1},
  {"question":"What does a full line voltage reading across a contact that should be closed indicate?","options":["The contact is closed","The contact is open or has high resistance","The circuit is overloaded","The voltage is too high"],"correctIndex":1},
  {"question":"What is the advantage of a true RMS clamp meter for troubleshooting?","options":["It is cheaper","It gives accurate readings on distorted waveforms (VFDs, nonlinear loads)","It measures resistance","It does not require batteries"],"correctIndex":1}
]'::jsonb
WHERE id = '81f2f79b-65b6-4228-8348-ddacf27b9005';

-- Lesson: Root Cause Analysis & Documentation
UPDATE lessons SET quiz = '[
  {"question":"What does root cause analysis seek to find?","options":["What failed","Why the failure occurred, not just what failed","Who is responsible","How much it cost"],"correctIndex":1},
  {"question":"What does a component that fails repeatedly indicate?","options":["Bad luck","A systemic root cause requiring a design change","Normal wear","Poor maintenance"],"correctIndex":1},
  {"question":"What is the 5-Why technique?","options":["A method that asks why 5 times to drill down to root cause","A method that asks 5 people","A method that uses 5 tools","A method that takes 5 minutes"],"correctIndex":0},
  {"question":"What is the purpose of documenting troubleshooting steps?","options":["To satisfy paperwork requirements","To create a knowledge base for future troubleshooting and to verify the fix addressed the root cause","To assign blame","To calculate downtime costs"],"correctIndex":1},
  {"question":"What is a fishbone (Ishikawa) diagram?","options":["A wiring diagram","A visual tool for mapping potential causes of a problem across categories (man, machine, method, material, environment)","A troubleshooting flowchart","A type of schematic"],"correctIndex":1},
  {"question":"What is the difference between a symptom and a root cause?","options":["They are the same","A symptom is the observable effect; the root cause is the underlying reason the symptom occurred","A symptom is always electrical; a root cause is mechanical","A root cause is always human error"],"correctIndex":1},
  {"question":"What should be done after a root cause is identified and fixed?","options":["Nothing","Verify the fix prevents recurrence and document the findings for training","Order spare parts","Replace the entire system"],"correctIndex":1}
]'::jsonb
WHERE id = '4b9bfd62-b205-4576-9fdc-2d13ee3fe495';

-- Course 11: Grounding, Bonding & Equipment Grounding Conductors
-- Lesson: NEC Article 250 & Grounding Electrode Systems
UPDATE lessons SET quiz = '[
  {"question":"What is the NEC maximum ground resistance for a single rod?","options":["5 ohms","25 ohms","100 ohms","1 ohm"],"correctIndex":1},
  {"question":"When should ground resistance be tested for the most conservative reading?","options":["During the wet season","During the dry season when soil resistivity is highest","At night","Any time"],"correctIndex":1},
  {"question":"What NEC article covers grounding and bonding?","options":["Article 240","Article 250","Article 300","Article 430"],"correctIndex":1},
  {"question":"What must be done if a single ground rod reads above 25 ohms?","options":["Nothing — it is acceptable","Install a second rod at least 6 feet away","Replace the rod with a longer one","Add more soil"],"correctIndex":1},
  {"question":"What is the purpose of the grounding electrode system?","options":["To carry fault current","To connect the electrical system to earth for lightning and voltage stabilization","To reduce energy bills","To improve power factor"],"correctIndex":1},
  {"question":"What is the minimum size grounding electrode conductor for a service with 500 kcmil copper conductors?","options":["2 AWG copper","1/0 AWG copper","4 AWG copper","6 AWG copper"],"correctIndex":1},
  {"question":"What is a concrete-encased electrode (Ufer ground)?","options":["A copper rod in concrete","A steel rebar in a concrete foundation, at least 20 feet of #4 rebar","A ground rod driven through concrete","Any electrode near concrete"],"correctIndex":1}
]'::jsonb
WHERE id = 'bf7966b6-7963-4e45-b065-10386eecf7b1';

-- Lesson: Equipment Grounding & Bonding Jumpers
UPDATE lessons SET quiz = '[
  {"question":"Where is the only place the neutral and ground are bonded?","options":["At each subpanel","At the service entrance","At the transformer","At each motor"],"correctIndex":1},
  {"question":"What is the most common grounding defect at a service entrance?","options":["A ground rod that is too short","An open neutral","A missing GFCI","An oversized EGC"],"correctIndex":1},
  {"question":"What is the purpose of the equipment grounding conductor (EGC)?","options":["To carry normal load current","To provide a low-impedance fault path to clear overcurrent devices during a ground fault","To ground the system to earth","To reduce harmonics"],"correctIndex":1},
  {"question":"What is the maximum impedance between an equipment frame and system ground?","options":["1 ohm","0.1 ohm","10 ohms","100 ohms"],"correctIndex":1},
  {"question":"Why must the EGC be run in the same raceway as the circuit conductors?","options":["To save conduit","To keep the impedance low by magnetic coupling","For appearance","It is not required"],"correctIndex":1},
  {"question":"What is the purpose of a bonding jumper?","options":["To carry load current","To electrically connect two metal parts to ensure they are at the same potential","To ground equipment to earth","To reduce resistance"],"correctIndex":1},
  {"question":"What happens if the neutral-ground bond is made at a subpanel?","options":["Nothing","Neutral current returns on the EGC, creating dangerous voltage on equipment frames","It improves grounding","It reduces impedance"],"correctIndex":1}
]'::jsonb
WHERE id = '101495aa-3e0a-43cf-91a0-270a5769968a';

-- Lesson: Fall-of-Potential & Clamp-On Ground Testing
UPDATE lessons SET quiz = '[
  {"question":"What is the most accurate method for measuring ground resistance?","options":["A multimeter","Fall-of-potential (3-point) test","Clamp-on ground tester","Visual inspection"],"correctIndex":1},
  {"question":"What distance should the potential probe be from the ground rod in a fall-of-potential test?","options":["5 feet","62% of the distance to the current probe","At the current probe","10 feet"],"correctIndex":1},
  {"question":"What is the advantage of a clamp-on ground tester over fall-of-potential?","options":["It is more accurate","It does not require disconnecting the ground rod or driving auxiliary probes","It measures lower resistance","It is cheaper"],"correctIndex":1},
  {"question":"What is a limitation of the clamp-on ground tester?","options":["It cannot be used on any system","It requires a parallel ground path and cannot be used on isolated single rods","It is inaccurate","It is too expensive"],"correctIndex":1},
  {"question":"How many probes are needed for a fall-of-potential test?","options":["1","2 (current and potential)","3","4"],"correctIndex":1},
  {"question":"What does the fall-of-potential test measure?","options":["Soil resistivity","The resistance of the grounding electrode to earth","The resistance of the EGC","The impedance of the neutral"],"correctIndex":1},
  {"question":"What should be done if the ground resistance reading is unstable during a fall-of-potential test?","options":["Use the first reading","Move the probes to a different location, away from underground metal objects or parallel paths","Ignore the instability","Use a clamp-on tester instead"],"correctIndex":1}
]'::jsonb
WHERE id = '2206d3d7-503a-4ddd-8c0e-d8b1c44129cf';
