-- ============================================================
-- PART 6: Expand quizzes for Industrial Motor Control Circuits (course 1) + add module 3
-- ============================================================

-- Lesson: Ladder Logic & Control Schematics (1 question → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"On a ladder diagram, what does a voltmeter read across an open control contact in an energized circuit?","options":["Zero volts","Half line voltage","Full line voltage","Battery voltage"],"correctIndex":2},
  {"question":"In a ladder diagram, what do the left and right rails represent?","options":["Input and output","L1 (hot) and L2 (neutral) — the power source","Start and stop","Open and closed"],"correctIndex":1},
  {"question":"How are components shown in a ladder diagram?","options":["In their energized state","In their de-energized (shelf) state","In their running state","In any state"],"correctIndex":1},
  {"question":"What does a normally open (NO) contact represent in a ladder diagram?","options":["A contact that is open when the coil is de-energized","A contact that is always open","A contact that is open when the coil is energized","A contact that is always closed"],"correctIndex":0},
  {"question":"What is the purpose of a reference number on the right side of a ladder coil?","options":["To identify the wire size","To show the line numbers where the coil''s contacts appear","To indicate the voltage rating","To identify the manufacturer"],"correctIndex":1},
  {"question":"When troubleshooting a ladder diagram, where should you start?","options":["At the motor","At the coil that is not pulling in and work backward through the series contacts","At the start button","At the transformer"],"correctIndex":1},
  {"question":"What does a voltmeter read across a closed (good) contact in an energized control circuit?","options":["Full line voltage","Near zero volts","Half line voltage","Double line voltage"],"correctIndex":1}
]'::jsonb
WHERE id = 'ceb11c71-5d26-447e-ae91-4608a1f726c7';

-- Lesson: Magnetic Starters & Overload Protection (2 questions → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"Why does an overload relay not trip on motor inrush?","options":["It is designed to tolerate short-duration inrush while tripping on sustained overload","It cannot detect inrush","The contactor shorts it out during start","It is bypassed by the start button"],"correctIndex":0},
  {"question":"Which overload trip class is standard for general-purpose motors?","options":["Class 10","Class 20","Class 30","Class 5"],"correctIndex":1},
  {"question":"What is the purpose of the seal-in (holding) contact on a magnetic starter?","options":["To seal the enclosure","To maintain the circuit after the start button is released, keeping the motor running","To protect against overload","To stop the motor"],"correctIndex":1},
  {"question":"What is the difference between a magnetic starter and a contactor?","options":["There is no difference","A magnetic starter includes an overload relay; a contactor does not","A contactor is larger","A magnetic starter is manual"],"correctIndex":1},
  {"question":"What is the purpose of the shading coil on an AC contactor?","options":["To reduce noise","To prevent the armature from chattering by creating a delayed magnetic flux that maintains pull between AC cycles","To improve efficiency","To reduce heat"],"correctIndex":1},
  {"question":"What happens if the overload relay is set too high?","options":["The motor runs more efficiently","The motor is not protected and may burn out from sustained overload","The motor starts faster","Nothing — the setting does not matter"],"correctIndex":1},
  {"question":"What is the advantage of a three-wire control circuit over a two-wire control circuit?","options":["It uses less wire","It does not auto-restart after a power loss (safer for machinery)","It is cheaper","It is faster"],"correctIndex":1}
]'::jsonb
WHERE id = 'fd4b906b-53c2-4059-a271-76899f4dba27';

-- Lesson: Control Circuit Troubleshooting (1 question → expand to 7)
UPDATE lessons SET quiz = '[
  {"question":"If the contactor coil has rated voltage applied but does not pull in, what is the likely fault?","options":["The motor is overloaded","The coil is open","The control fuse is blown","The start button is stuck"],"correctIndex":1},
  {"question":"What is the first check when a motor will not start?","options":["Replace the contactor","Check the control circuit voltage at the transformer","Check the motor","Replace the start button"],"correctIndex":1},
  {"question":"If the motor starts but stops when the start button is released, what is the likely cause?","options":["Bad stop button","The seal-in (holding) contact is not closing or is miswired","Bad coil","Blown fuse"],"correctIndex":1},
  {"question":"What does a full line voltage reading across a contact that should be closed indicate?","options":["The contact is closed and good","The contact is open or has high resistance","The circuit is overloaded","The voltage is too high"],"correctIndex":1},
  {"question":"What causes contactor chatter?","options":["Oversized wire","Voltage drop, weak coil, or loose connection causing rapid make/break","High voltage","Low current"],"correctIndex":1},
  {"question":"If the control fuse blows repeatedly, what should be checked?","options":["Just replace the fuse with a larger one","A short in the control circuit — check wiring, components, and coil for shorts","The motor size","The transformer voltage"],"correctIndex":1},
  {"question":"What should be done after repairing a motor control circuit?","options":["Nothing","Test the complete circuit including the stop button and emergency stop","Only check the motor","Only check the start button"],"correctIndex":1}
]'::jsonb
WHERE id = '522c7693-a773-4b8e-99f3-c6eac605e38e';

-- Add Module 3: Advanced Motor Control Applications
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Industrial Motor Control Circuits' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Advanced Motor Control Applications') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Motor Control Applications', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Jogging, Plugging & Multi-Speed Control',
      '## Overview

Beyond basic start/stop control, industrial motor control circuits include jogging (inching), plugging (reverse-current braking), and multi-speed control. These advanced control techniques are used in specific applications where precise positioning, rapid stopping, or multiple operating speeds are required.

## Key Concepts

- **Jogging (inching)**: A control mode where the motor runs only while the jog button is held. The seal-in circuit is disabled during jogging. Used for positioning equipment during setup or maintenance.
- **Plugging**: Momentarily reversing the motor to stop it quickly. Requires a zero-speed switch (plugging switch) to disconnect the reverse contactor at the moment the motor stops, preventing reverse rotation.
- **Multi-speed control**: Controlling a motor with two or more speeds using Dahlander (tap-wound) or separate-winding motors. Each speed requires a separate contactor, and the contactors must be interlocked.
- **Jog/Run selector**: A selector switch that enables either jog mode (no seal-in) or run mode (with seal-in). In jog mode, the motor runs only while the button is pressed.

## Step-by-Step: Wiring a Jog/Run Control Circuit

1. **Start with a standard three-wire control circuit**: Stop button in series, start button in parallel with seal-in contact, through overload to coil.
2. **Add a jog/run selector switch**: Wire a selector switch (SS) in series with the seal-in contact. In RUN mode, the selector is closed (seal-in enabled). In JOG mode, the selector is open (seal-in disabled).
3. **Add a jog button**: Wire a jog button (NO) in parallel with the start button, but through the jog/run selector set to JOG mode. When the jog button is pressed, the motor runs. When released, the motor stops (no seal-in).
4. **Verify interlocks**: Ensure that the jog and run circuits cannot both be active simultaneously. The selector switch provides this interlock.
5. **Test the circuit**: In RUN mode, press start — the motor starts and continues running (seal-in holds). Press stop — the motor stops. In JOG mode, press and hold jog — the motor runs. Release — the motor stops immediately.

## Common Problems

- **Jog button runs the motor continuously**: The seal-in contact is not disabled in JOG mode. Check the selector switch wiring.
- **Motor reverses after plugging stop**: The zero-speed switch is not disconnecting the reverse contactor at zero speed. Adjust or replace the zero-speed switch.
- **Multi-speed contactors close simultaneously**: Missing or failed interlocks between speed contactors. Verify both mechanical and electrical interlocks.
- **Jogging causes excessive current**: Jogging at full voltage draws locked-rotor current. Use a reduced-voltage jog circuit for large motors.

## Best Practices

- Use a jog/run selector switch to clearly separate jog and run modes.
- Install a zero-speed switch for plugging applications to prevent reverse rotation.
- Interlock all multi-speed contactors both mechanically and electrically.
- Use a reduced-voltage jog circuit for motors above 20 HP to limit jog current.
- Label all jog, run, and selector controls clearly to prevent operator confusion.
- Document the control circuit with a clear description of each mode.

## Safety

- Jogging moves equipment without warning — ensure personnel are clear before jogging.
- Plugging creates high current and mechanical stress — ensure the contactors and motor are rated for plugging duty.
- Multi-speed contactors that close simultaneously create a phase-to-phase short — verify interlocks before energizing.
- Emergency stop must work in all modes (jog, run, and multi-speed).
- De-energize and lock out before modifying any control circuit.',
      45, true, true,
      '[
        {"question":"What is jogging (inching) in motor control?","options":["Running the motor at reduced speed","A control mode where the motor runs only while the jog button is held (seal-in is disabled)","Running the motor in reverse","Stopping the motor quickly"],"correctIndex":1},
        {"question":"What is plugging in motor control?","options":["Blocking the motor","Momentarily reversing the motor to stop it quickly, using a zero-speed switch to disconnect at stop","Disconnecting the motor","Slowing the motor gradually"],"correctIndex":1},
        {"question":"What is the purpose of a jog/run selector switch?","options":["To select the motor speed","To enable either jog mode (no seal-in) or run mode (with seal-in)","To select the voltage","To select the direction"],"correctIndex":1},
        {"question":"What is required for plugging to work correctly?","options":["A larger motor","A zero-speed switch to disconnect the reverse contactor at the moment the motor stops","A VFD","A brake"],"correctIndex":1},
        {"question":"What happens if multi-speed contactors close simultaneously?","options":["The motor runs faster","A phase-to-phase short circuit occurs","The motor stops","Nothing — the interlocks prevent this"],"correctIndex":1},
        {"question":"What is a common problem with jog circuits?","options":["The motor runs too slowly","The seal-in contact is not disabled in JOG mode, causing the motor to run continuously","The motor overheats","The fuse blows"],"correctIndex":1},
        {"question":"What should be used for motors above 20 HP to limit jog current?","options":["A larger contactor","A reduced-voltage jog circuit","A VFD","A larger wire"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Sequence Control & Interlocking Circuits',
      '## Overview

Sequence control ensures that motors or operations start and stop in a specific order. Interlocking prevents incompatible operations from occurring simultaneously. These circuits are common in industrial processes where equipment must start in a specific sequence (e.g., a conveyor must start before the feeder) or where two operations must never occur at the same time (e.g., forward and reverse).

## Key Concepts

- **Sequence starting**: Motors start in a specific order, typically with timers between each start to prevent simultaneous inrush. Motor 1 starts, then after a delay, Motor 2 starts, etc.
- **Sequence stopping**: Motors stop in a specific order, often the reverse of the starting sequence. Timers control the delay between each stop.
- **Interlocking**: Using contacts (mechanical or electrical) to prevent two operations from occurring simultaneously. NC auxiliary contacts from one contactor are placed in the control circuit of the conflicting contactor.
- **Permissive interlock**: A contact that must be closed before a motor can start (e.g., a flow switch that must be closed before a pump can start, indicating there is fluid to pump).
- **Failure mode**: If any motor in the sequence fails or trips, all subsequent motors stop (or all motors stop, depending on the process requirements).

## Step-by-Step: Designing a Sequence Control Circuit

1. **Define the sequence**: Motor 1 starts first, then after 5 seconds Motor 2 starts, then after 5 seconds Motor 3 starts. If any motor trips, all motors stop.
2. **Wire Motor 1 start**: The start button energizes Motor 1 contactor (M1) and on-delay timer (T1) set for 5 seconds.
3. **Wire Motor 2 start**: When T1 times out, its NO contact closes and energizes Motor 2 contactor (M2) and on-delay timer (T2) set for 5 seconds.
4. **Wire Motor 3 start**: When T2 times out, its NO contact closes and energizes Motor 3 contactor (M3).
5. **Wire the stop**: The stop button de-energizes all contactors and timers simultaneously (all motors stop).
6. **Add interlocks**: Place NC auxiliary contacts from M1 in the M2 circuit (M2 cannot start unless M1 is running). Place NC from M2 in the M3 circuit.
7. **Add fault logic**: Wire all overload NC contacts in series in the control circuit. If any overload trips, the entire sequence stops.
8. **Add permissive interlocks if needed**: If a flow switch or pressure switch must be satisfied before starting, wire its NO contact in series with the start circuit.
9. **Test the circuit**: Press start — M1 starts, then M2 after 5 seconds, then M3 after 5 seconds. Press stop — all stop. Trip any overload — all stop.

## Common Problems

- **Out-of-sequence start**: Missing interlocks allow motors to start out of order. Verify NC auxiliary contacts are wired correctly.
- **Simultaneous start**: Timer failure or missing timer causes all motors to start simultaneously, creating excessive inrush.
- **No fault cascade**: If a motor trips but others continue running, the fault logic is incorrect. All overload NC contacts must be in series.
- **Missing permissive**: A motor starts without its permissive condition being met (e.g., a pump starts with no fluid). Verify permissive contacts are in series with the start circuit.

## Best Practices

- Always use interlocks (both mechanical and electrical) for conflicting operations.
- Use timers to sequence motor starts and prevent simultaneous inrush.
- Wire all overload NC contacts in series so any motor fault stops the entire sequence.
- Include permissive interlocks for safety-critical conditions (flow, pressure, level).
- Use a master control relay (MCR) to de-energize all outputs on emergency stop.
- Document the sequence, interlocks, and permissives in the drawing notes.
- Test the complete sequence and all failure modes during commissioning.

## Safety

- Sequence control is a safety feature — do not bypass interlocks or timers without engineering review.
- Emergency stop must de-energize all motors in the sequence immediately.
- Permissive interlocks protect against unsafe conditions — do not bypass them.
- Test all failure modes (motor trip, loss of permissive, emergency stop) during commissioning.
- De-energize and lock out before modifying any sequence control circuit.',
      45, true, true,
      '[
        {"question":"What is the purpose of sequence control?","options":["To save energy","To ensure motors or operations start and stop in a specific order","To improve power factor","To reduce harmonics"],"correctIndex":1},
        {"question":"What is interlocking in motor control?","options":["Locking the panel","Using contacts to prevent two incompatible operations from occurring simultaneously","Locking the motor","Locking the start button"],"correctIndex":1},
        {"question":"What is a permissive interlock?","options":["A lock that prevents access","A contact that must be closed before a motor can start (e.g., a flow switch before a pump)","A type of overload relay","A type of timer"],"correctIndex":1},
        {"question":"What should happen if any motor in a sequence trips?","options":["Only that motor stops","All motors in the sequence stop (all overload NC contacts in series)","The next motor starts","Nothing"],"correctIndex":1},
        {"question":"What is the purpose of a master control relay (MCR)?","options":["To control the main motor","To de-energize all outputs on emergency stop","To control the sequence","To protect against overload"],"correctIndex":1},
        {"question":"What is a common problem with sequence control circuits?","options":["Motors start too slowly","Missing interlocks allow motors to start out of order","Excessive wire usage","Low voltage"],"correctIndex":1},
        {"question":"What must be tested during commissioning of a sequence control circuit?","options":["Only the start sequence","The complete sequence AND all failure modes (motor trip, loss of permissive, emergency stop)","Only the stop sequence","Only the timer accuracy"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;
