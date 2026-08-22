DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Motion Control & Servo Systems';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lessons
  UPDATE lessons SET content = '## Overview

Servo motor theory and loop tuning are the foundations of motion control. A servo system achieves precise position, velocity, and torque control through a closed-loop architecture with three nested loops (current, velocity, position), each tuned to its bandwidth. Understanding the motor physics, the loop structure, and the tuning methods is essential for a system that tracks accurately and rejects disturbances. This lesson covers servo motor types, the nested loop architecture, and the tuning methods.

## Key Concepts

**Servo Motor Types.** The two main servo motor types are permanent magnet AC (PMSM, also called brushless AC servo) and brushless DC (BLDC). PMSM is the standard for industrial servo: it uses sinusoidal commutation for smooth torque and is driven by a field-oriented control (FOC) algorithm that decouples torque and flux. Brushless DC uses trapezoidal commutation (simpler, but with torque ripple). Stepper motors are open-loop position motors (no encoder feedback) used for low-cost, low-speed applications; they lose position on overload, unlike servos which stall and recover.

**The Nested Loop Architecture.** A servo drive has three nested control loops: the current (torque) loop is innermost and fastest (bandwidth ~1–5 kHz), the velocity loop is next (~100–500 Hz), and the position loop is outermost (~10–100 Hz). Each loop feeds back to the next inner loop: the position loop outputs a velocity command, the velocity loop outputs a torque command, the current loop controls the motor current to produce that torque. The bandwidths must be separated by about a factor of 5–10 to prevent interaction; tuning proceeds from inner to outer (current, then velocity, then position).

**Loop Tuning Methods.** The current loop is typically auto-tuned by the drive (it depends on motor inductance and resistance, which the drive measures). The velocity loop is tuned for bandwidth and damping, often by the auto-tune or by frequency-response methods (injecting a frequency sweep and measuring the response). The position loop is tuned for stiffness (gain), trading off against overshoot. Tune with the load connected and at representative speeds; a system tuned unloaded will be unstable under load. Watch for mechanical resonance (the load''s natural frequency excited by the loop bandwidth) and reduce bandwidth or add a low-pass or notch filter if it appears.

**Following Error and Stiffness.** Following error is the lag between the commanded and actual position; it is proportional to the load and inversely proportional to the position loop gain (stiffness). High stiffness (high gain) reduces following error but risks instability and resonance. The tuning trade-off is stiffness vs. stability: enough stiffness to meet the following-error requirement, not so much that the system oscillates or excites resonance. Document the final gains so they can be restored after a drive replacement.

## Best Practices

- Tune the loops from inner to outer: current (auto-tuned), velocity, position.
- Separate loop bandwidths by a factor of 5–10 to prevent interaction.
- Tune with the load connected and at representative speeds; unloaded tuning is unstable under load.
- Balance stiffness against stability; meet the following-error requirement without oscillation or resonance.
- Document the final gains so they can be restored after a drive replacement.

## Common Pitfalls

- **Tuning unloaded** produces instability under load.
- **Bandwidths too close** cause loop interaction and instability.
- **Too much stiffness** excites mechanical resonance and oscillation.
- **No resonance filtering** lets the load''s natural frequency destabilize the loop.
- **Undocumented gains** cannot be restored after a drive replacement.

## Real-World Example

A servo axis was tuned unloaded at the integrator''s bench and worked perfectly. On the machine with the load connected, it oscillated violently because the load''s natural frequency (35 Hz) was below the velocity loop bandwidth (200 Hz), exciting a resonance. After re-tuning with the load connected and adding a notch filter at 35 Hz, the system was stable. The unloaded tuning had been useless; the load-connected tuning and the resonance filter were essential.

## Knowledge Check

Review the servo motor types, the nested loop architecture (current, velocity, position), the inner-to-outer tuning order, the bandwidth separation, and the stiffness-vs-stability trade-off before the quiz.',
  quiz = '[
    {"question":"What are the three nested control loops in a servo drive?","options":["Position, velocity, current (torque)","Speed, torque, power","Voltage, current, resistance","Start, run, stop"],"answer":0,"explanation":"The current (torque) loop is innermost and fastest, then velocity, then position (outermost, slowest)."},
    {"question":"In what order are the loops tuned?","options":["Position, velocity, current","Current, velocity, position (inner to outer)","Any order","Velocity only"],"answer":1,"explanation":"Tuning proceeds inner to outer: current (auto-tuned), then velocity, then position, so each outer loop builds on a tuned inner loop."},
    {"question":"By what factor should loop bandwidths be separated?","options":["1–2","5–10","100","0.5"],"answer":1,"explanation":"Bandwidths separated by 5–10 prevent loop interaction; too-close bandwidths cause instability."},
    {"question":"Why tune with the load connected?","options":["It is faster","A system tuned unloaded will be unstable under load","To save energy","It is not necessary"],"answer":1,"explanation":"Load inertia changes loop behavior; unloaded tuning produces instability when the load is connected."},
    {"question":"What is the stiffness-vs-stability trade-off?","options":["More stiffness is always better","Enough stiffness to meet following-error requirements, not so much that the system oscillates or excites resonance","Stability is not important","Stiffness is irrelevant"],"answer":1,"explanation":"High stiffness reduces following error but risks instability; the tuning balances the two."},
    {"question":"What is following error?","options":["The position overshoot","The lag between commanded and actual position, proportional to load and inverse to position gain","The motor speed","The loop bandwidth"],"answer":1,"explanation":"Following error is the tracking lag; higher position gain (stiffness) reduces it but risks instability."},
    {"question":"What caused the oscillation in the example?","options":["A bad motor","The load’s natural frequency (35 Hz) was below the velocity loop bandwidth (200 Hz), exciting resonance","A firmware bug","A missing encoder"],"answer":1,"explanation":"The unloaded tuning set the bandwidth above the load’s natural frequency; load-connected tuning and a notch filter resolved it."}
  ]'::jsonb
  WHERE title = 'Servo Motor Theory & Loop Tuning' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

Coordinated motion and safety-rated functions bring multiple servo axes into synchronized, high-throughput operations while maintaining functional safety for operator interaction. This lesson covers the coordination modes (gearing, camming, line-shaft), the safety-rated motion functions that let operators interact safely with powered equipment, and the integration of safety and motion in a modern servo system.

## Key Concepts

**Coordination Modes.** Electronic gearing slaves one axis to a master at a fixed ratio — used for continuous processes where the ratio is constant. Electronic camming slaves an axis to a master via a position-to-position table (the cam profile) — used for periodic operations where the relationship varies over the cycle. Line-shaft synchronization uses a virtual master to drive multiple axes as if mechanically linked, with each axis cammed or geared to the virtual master — used for printing presses, packaging machines, and any multi-axis machine that must stay in phase. The virtual master lets the whole machine speed up, slow down, and stop together.

**Phase and Registration.** Phase locking synchronizes an axis to a master at a defined phase offset, used for registering to a mark (a print mark, a product edge). Registration captures the axis position at a sensor event and adjusts the phase to align to the mark. This is essential for cut-to-length, print-to-mark, and label-placement applications where the product position varies and the motion must compensate.

**Safety-Rated Motion Functions.** Modern servo drives support safety-rated functions that let operators interact with powered equipment safely: Safe Stop 1 (SS1, controlled stop then power off), Safe Stop 2 (SS2, controlled stop and hold at zero with power on), Safe Limited Speed (SLS, limit to a safe speed for setup with the guard open), Safe Maximum Speed (SMS, monitor that speed does not exceed a limit), Safe Direction (SDI, prevent motion in an unsafe direction), and Safe Torque Off (STO, remove torque without removing power). These functions let the safety system supervise motion while the drive remains powered, enabling faster recovery and safer setup modes.

**Integration of Safety and Motion.** The safety functions are supervised by a safety PLC over a safety communication protocol (CIP Safety, PROFIsafe, openSAFETY). The safety PLC monitors safety inputs (light curtains, e-stops, door switches) and commands the safety functions on the drives. The drives execute the safety functions locally (the safety is in the drive, not just the PLC), so that a communication loss does not compromise the safety. The integration must be validated: each safety function is tested under worst-case load, and the stop time and safe speed limits are measured and documented.

## Best Practices

- Use a virtual master for line-shaft synchronization; gear or cam each axis to it for whole-machine speed control.
- Use phase locking and registration for cut-to-length, print-to-mark, and label-placement applications.
- Use safety-rated motion functions (SS1, SS2, SLS, STO) to enable safe operator interaction without full power-down.
- Integrate safety and motion via a safety protocol (CIP Safety, PROFIsafe); put safety execution in the drive.
- Validate each safety function under worst-case load; measure and document stop times and safe speed limits.

## Common Pitfalls

- **No virtual master** makes whole-machine speed changes and phase coordination difficult.
- **No registration** for cut-to-length applications causes cumulative product-length errors.
- **Power-down for every operator interaction** slows production and increases cycle time.
- **Safety only in the PLC** is compromised by a communication loss; safety execution must be in the drive.
- **Unvalidated safety functions** have assumed, not measured, stop times.

## Real-World Example

A packaging machine used a virtual master with 8 cammed axes, SS1 for safe access, and SLS for setup mode with the guard open. Operators could clear a jam in seconds (SS1 stopped the axes, the guard opened, the jam was cleared, the guard closed, the machine restarted) instead of waiting for a full power-down and re-homing cycle. SLS let setup run at 10% speed with the guard open, so operators could observe and adjust safely. The safety functions, validated under full load, made the machine both faster and safer.

## Knowledge Check

Review the coordination modes (gearing, camming, line-shaft with virtual master), phase and registration, the safety-rated motion functions, and the safety-motion integration with drive-local execution before the quiz.',
  quiz = '[
    {"question":"What does a virtual master enable?","options":["Single-axis control","Line-shaft synchronization of multiple axes that speed up, slow down, and stop together","Safety functions","Encoder feedback"],"answer":1,"explanation":"A virtual master drives multiple geared or cammed axes as if mechanically linked, enabling whole-machine coordination."},
    {"question":"What is registration used for?","options":["Homing","Capturing axis position at a sensor event to align to a mark (cut-to-length, print-to-mark)","Speed control","Torque control"],"answer":1,"explanation":"Registration captures position at a mark and adjusts phase to align, compensating for product position variation."},
    {"question":"What does Safe Stop 1 (SS1) do?","options":["Removes power immediately","Initiates a controlled deceleration then removes power at zero speed","Holds position with power on","Limits speed"],"answer":1,"explanation":"SS1 decelerates then removes power at zero speed — the standard for safe access."},
    {"question":"What does Safe Limited Speed (SLS) enable?","options":["Full-speed operation","Setup and jog modes with the guard open at a safe speed","Power-down","No motion"],"answer":1,"explanation":"SLS limits speed to a safe value so operators can interact with the machine during setup without full power-down."},
    {"question":"Where should safety function execution reside?","options":["Only in the safety PLC","In the drive (local execution), so communication loss does not compromise safety","In the HMI","In the enterprise network"],"answer":1,"explanation":"Drive-local safety execution ensures a communication loss does not compromise the safety function."},
    {"question":"How must safety functions be validated?","options":["By assumption","Under worst-case load, with measured and documented stop times and speed limits","At no load","Never"],"answer":1,"explanation":"Validation under worst-case load produces measured, not assumed, stop times; documentation makes it auditable."},
    {"question":"What did SS1 and SLS achieve in the example?","options":["Slower operation","Fast jam clearing (SS1) and safe setup at 10% speed with the guard open (SLS), making the machine faster and safer","Full power-down for every interaction","No safety benefit"],"answer":1,"explanation":"SS1 enabled quick stop-and-access; SLS enabled safe setup with the guard open, reducing cycle time and improving safety."}
  ]'::jsonb
  WHERE title = 'Coordinated Motion & Safety-Rated Functions' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add new module (sort_order 3) with 2 lessons
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Motion Application Engineering', 3) RETURNING id INTO m_id;

  -- Lesson 1: Mechanical Considerations: Inertia, Backlash & Couplings
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Mechanical Considerations: Inertia, Backlash & Couplings', '## Overview

The mechanical system is half of a motion application, and its characteristics — inertia ratio, backlash, compliance, and coupling type — determine whether the servo system can meet its performance targets. A perfectly tuned servo on a poor mechanical system will still perform poorly. This lesson covers the inertia ratio, the mechanical compliance and backlash that degrade motion, and the coupling and transmission choices that affect performance.

## Key Concepts

**The Inertia Ratio.** The inertia ratio (load inertia reflected to the motor / motor inertia) is a critical design parameter. A low ratio (1:1 to 5:1) is easy to tune and stable; a high ratio (10:1 or more) is harder to tune, more prone to resonance, and less stable. The ratio affects the loop bandwidth achievable: a high ratio limits the bandwidth, increasing following error. For high-performance applications, target a ratio under 5:1 by selecting a motor with adequate inertia or adding a gearbox to reduce the reflected inertia (the gearbox reduces the reflected inertia by the square of the ratio).

**Mechanical Compliance and Backlash.** Compliance (springiness in the transmission) and backlash (play in a gear or coupling) degrade motion. Compliance introduces a mechanical resonance (the load bouncing on the compliant transmission) that limits the loop bandwidth; a stiff transmission (direct coupling, low-compliance couplings, short shafts) raises the resonance frequency and allows higher bandwidth. Backlash causes the load to lag the motor at direction reversals, producing position error and instability; a preloaded or zero-backlash transmission (ball screw with preloaded nut, timing belt, direct drive) eliminates backlash. For high-precision applications, direct drive (no transmission) is the ultimate solution.

**Couplings.** The coupling connects the motor to the load and absorbs misalignment. Types: rigid (no compliance, highest stiffness, requires precise alignment), flexible (bellows, disc, beam — absorb misalignment with some compliance), and elastomeric (jaw, tire — absorb misalignment and shock with high compliance). The choice trades stiffness against misalignment tolerance: a rigid coupling is stiff but requires precise alignment; a flexible coupling is less stiff but tolerates misalignment. For servo applications, prefer beam or disc couplings (good stiffness with some misalignment tolerance); avoid elastomeric couplings for high-performance applications (too compliant).

**Transmission Types.** The transmission converts the motor''s rotary motion to the load''s required motion and reduces the reflected inertia. Ball screws convert rotary to linear with high stiffness and low backlash (with a preloaded nut); timing belts convert rotary to rotary or linear with zero backlash but some compliance; gearboxes reduce speed and increase torque with a backlash that depends on the type (planetary: low backlash; worm: higher). The transmission ratio is chosen to match the motor''s speed and torque to the load, and to reduce the reflected inertia to an acceptable ratio.

## Best Practices

- Target an inertia ratio under 5:1 for high-performance applications; use a gearbox to reduce reflected inertia.
- Use a stiff transmission (direct coupling, ball screw with preloaded nut, timing belt) to raise the resonance frequency and allow higher loop bandwidth.
- Eliminate backlash with preloaded or zero-backlash transmissions; avoid backlash-prone gears for precision applications.
- Choose couplings by the stiffness-misalignment trade-off: beam or disc for servo, rigid for ultimate stiffness with precise alignment.
- Match the transmission ratio to the motor and load; consider direct drive for the highest precision.

## Common Pitfalls

- **High inertia ratio** limits bandwidth, increases following error, and risks instability.
- **Compliant transmission** introduces resonance that limits the loop bandwidth.
- **Backlash** causes position error and instability at direction reversals.
- **Elastomeric couplings on high-performance servos** are too compliant, limiting performance.
- **Wrong transmission ratio** mismatches the motor to the load, wasting performance.

## Real-World Example

A servo axis on a ball screw had a 15:1 inertia ratio and a backlash-prone gear coupling, causing following error and instability at direction reversals. After adding a 5:1 planetary gearbox (reducing the reflected inertia to under 1:1 and the backlash to negligible) and switching to a disc coupling, the loop bandwidth doubled, the following error halved, and the reversal instability disappeared. The mechanical changes, not the tuning, had been the limiting factor.

## Knowledge Check

Review the inertia ratio and its effect on bandwidth, compliance and resonance, backlash and its effect on reversals, coupling types and the stiffness-misalignment trade-off, and transmission selection before the quiz.',
  45,
  1,
  '[
    {"question":"What is the recommended inertia ratio for high-performance applications?","options":["1:1 to 5:1","10:1 or more","50:1","Any ratio"],"answer":0,"explanation":"A ratio under 5:1 is easy to tune and stable; high ratios limit bandwidth and risk resonance and instability."},
    {"question":"How does a gearbox affect the reflected inertia?","options":["It increases it","It reduces it by the square of the ratio","It has no effect","It doubles it"],"answer":1,"explanation":"A gearbox reduces the reflected load inertia by the square of its ratio, lowering the inertia ratio."},
    {"question":"What does mechanical compliance introduce?","options":["Better stiffness","A mechanical resonance that limits the loop bandwidth","Zero backlash","Higher torque"],"answer":1,"explanation":"Compliance creates a resonance; a stiff transmission raises the resonance frequency and allows higher bandwidth."},
    {"question":"What does backlash cause at direction reversals?","options":["Smoother motion","Position error and instability as the load lags the motor","Higher speed","Lower cost"],"answer":1,"explanation":"Backlash lets the load lag the motor at reversals, producing position error and instability; preload or zero-backlash transmissions fix it."},
    {"question":"Which coupling type suits high-performance servo applications?","options":["Elastomeric (jaw)","Beam or disc (good stiffness with misalignment tolerance)","Rigid only","Any coupling"],"answer":1,"explanation":"Beam and disc couplings balance stiffness with misalignment tolerance; elastomeric couplings are too compliant for high performance."},
    {"question":"What is the ultimate solution for the highest precision?","options":["A high-ratio gearbox","Direct drive (no transmission)","An elastomeric coupling","A worm gear"],"answer":1,"explanation":"Direct drive eliminates backlash and compliance entirely, offering the highest precision at the cost of motor size and cost."},
    {"question":"What fixed the instability in the example?","options":["Better tuning","A 5:1 planetary gearbox (reducing inertia ratio and backlash) and a disc coupling","A faster motor","A new controller"],"answer":1,"explanation":"The mechanical changes — gearbox and coupling — not the tuning, had been the limiting factor; they doubled bandwidth and halved following error."}
  ]'::jsonb);

  -- Lesson 2: Motion Application Sizing & Motor Selection
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Motion Application Sizing & Motor Selection', '## Overview

Sizing a motion application — selecting the motor, gearbox, and drive that meet the performance requirements — is the engineering that determines whether the system works. An undersized motor cannot meet the motion profile; an oversized motor wastes cost and energy. This lesson covers the sizing process: the motion profile, the torque and speed requirements, the inertia calculation, and the motor and gearbox selection.

## Key Concepts

**The Motion Profile.** The motion profile defines the position, velocity, and acceleration over time for each move: the move distance, the move time, the acceleration and deceleration (trapezoidal or S-curve), and the dwell between moves. The profile determines the required torque (acceleration torque plus friction torque plus gravity torque) and the required speed (the peak speed during the move). The profile is the starting point for sizing; without a defined profile, sizing is a guess.

**Torque and Speed Requirements.** The RMS torque (the root-mean-square over the duty cycle) must be within the motor''s continuous torque rating; the peak torque (the maximum during acceleration) must be within the motor''s peak (intermittent) torque rating, typically 2–3× continuous for a limited time. The peak speed must be within the motor''s rated speed, with margin for over-speed conditions. The torque and speed requirements come from the motion profile, the load (mass, friction, gravity), and the transmission (ratio, efficiency).

**Inertia Calculation.** Calculate the reflected load inertia (the load inertia divided by the square of the gearbox ratio, plus the gearbox and coupling inertia) and add the motor inertia to get the total inertia. The inertia ratio (reflected load / motor) should be under 5:1 for high performance. The inertia affects the acceleration torque (T = J × α, torque = inertia × angular acceleration) and the loop tuning. An accurate inertia calculation is essential; an assumed inertia leads to an undersized or unstable system.

**Motor and Gearbox Selection.** Select the motor to meet the continuous (RMS) and peak torque and the speed requirements, with the inertia ratio in the target range. Select the gearbox to match the motor''s speed and torque to the load and to reduce the reflected inertia to an acceptable ratio. Consider the gearbox backlash and efficiency (planetary: high efficiency, low backlash; worm: lower efficiency, higher backlash). Iterate: a different gearbox ratio changes the reflected inertia and the required motor torque, so the motor and gearbox are selected together, not independently.

## Best Practices

- Define the motion profile (distance, time, acceleration, dwell) before sizing; without it, sizing is a guess.
- Calculate the RMS and peak torque and the peak speed from the profile, load, and transmission; select the motor to meet them with margin.
- Calculate the reflected inertia accurately; target an inertia ratio under 5:1 for high performance.
- Select the motor and gearbox together; the gearbox ratio affects both the reflected inertia and the required motor torque.
- Consider gearbox backlash and efficiency; iterate the motor and gearbox selection until both meet the requirements.

## Common Pitfalls

- **Undefined motion profile** makes sizing a guess; the motor may be under- or oversized.
- **Assumed inertia** leads to undersized or unstable systems; calculate it accurately.
- **High inertia ratio** limits bandwidth and risks instability.
- **Selecting motor and gearbox independently** ignores their interaction; the ratio affects both.
- **Ignoring gearbox backlash and efficiency** produces a system that cannot meet precision or torque requirements.

## Real-World Example

A pick-and-place axis was sized with an assumed inertia and a trapezoidal profile, and the selected motor overheated within an hour. The actual motion profile (with shorter dwells than assumed) produced a higher RMS torque, and the actual load inertia (with a heavier tooling than estimated) produced a higher acceleration torque. After re-sizing with the actual profile and inertia, a motor with a higher continuous torque rating and a 3:1 gearbox (to reduce the inertia ratio) was selected, and the system ran cool. The initial assumptions had undersized the system.

## Knowledge Check

Review the motion profile, the RMS and peak torque and speed requirements, the inertia calculation and ratio, and the iterative motor-gearbox selection before the quiz.',
  45,
  2,
  '[
    {"question":"What is the starting point for motion sizing?","options":["The motor catalog","The motion profile (distance, time, acceleration, dwell)","The gearbox ratio","The coupling type"],"answer":1,"explanation":"The motion profile determines the required torque and speed; without a defined profile, sizing is a guess."},
    {"question":"What torque must be within the motor’s continuous rating?","options":["Peak torque","RMS torque over the duty cycle","Starting torque","Friction torque"],"answer":1,"explanation":"RMS torque is the equivalent continuous torque; it must be within the motor’s continuous rating to avoid overheating."},
    {"question":"What inertia ratio is targeted for high performance?","options":["10:1 or more","Under 5:1","50:1","Any ratio"],"answer":1,"explanation":"A ratio under 5:1 is easy to tune and stable; high ratios limit bandwidth and risk instability."},
    {"question":"Why select the motor and gearbox together?","options":["They are independent","The gearbox ratio affects both the reflected inertia and the required motor torque","To save cost","It is not necessary"],"answer":1,"explanation":"The gearbox ratio changes the reflected inertia (squared) and the torque/speed trade-off; motor and gearbox must be selected iteratively."},
    {"question":"What does T = J × α describe?","options":["Ohm’s law","Acceleration torque = inertia × angular acceleration","The inertia ratio","The gearbox efficiency"],"answer":1,"explanation":"The acceleration torque is the total inertia times the angular acceleration; accurate inertia is essential for sizing."},
    {"question":"What caused the motor to overheat in the example?","options":["A bad motor","Assumed profile and inertia undersized the motor; actual dwells and tooling weight were higher","A firmware bug","Wrong coupling"],"answer":1,"explanation":"The assumptions understated RMS torque and inertia; re-sizing with actual values and a 3:1 gearbox fixed it."},
    {"question":"What must the peak torque be within?","options":["The continuous rating","The motor’s peak (intermittent) rating, typically 2–3× continuous for a limited time","The RMS torque","Zero"],"answer":1,"explanation":"Peak torque (during acceleration) must be within the motor’s intermittent rating; exceeding it trips the drive."}
  ]'::jsonb);
END $$;