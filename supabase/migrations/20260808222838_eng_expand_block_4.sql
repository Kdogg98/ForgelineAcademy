DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Advanced Motion & Safety Systems';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lessons
  UPDATE lessons SET content = '## Overview

Coordinated motion and camming are the advanced techniques that let multi-axis machines perform synchronized, high-throughput operations — printing presses, rotary knife cutters, packaging machines, and textile winders. Beyond simple point-to-point moves, these applications require electronic gearing, electronic camming, and phase locking, where axes follow a master with defined relationships. This lesson covers the motion coordination modes, the cam profile, and the commissioning considerations that determine whether a synchronized machine runs smoothly or tears itself apart.

## Key Concepts

**Motion Coordination Modes.** Independent positioning moves each axis to a target without regard for others — used for pick-and-place. Electronic gearing slaves one axis to a master at a fixed ratio (e.g., a feed axis at 1.5× the master), used for continuous processes. Electronic camming slaves an axis to a master via a position-to-position table (the cam profile), used for periodic operations like a rotary knife that cuts once per package. Phase locking synchronizes an axis to a master at a defined phase offset, used for registering to a mark.

**The Cam Profile.** A cam profile maps master position to slave position, defining the slave''s motion as a function of the master. The profile is built from segments (linear, polynomial, spline) with defined boundary conditions (position, velocity, acceleration) to ensure continuity. Discontinuities in acceleration cause jerk, which causes mechanical shock and poor product quality. Modern motion controllers let you design the cam profile graphically and simulate it before commissioning.

**Master Source and Gearing In.** The master can be a real axis (a physical motor with an encoder), a virtual axis (a software-generated position), or an external encoder (a line-shaft). Virtual masters are preferred for flexibility — the master speed can be changed without mechanical effects, and the cam can be engaged at any master position. Gearing in (engaging the slave to the master) must be bumpless: the slave matches the master velocity before the position lock engages, to avoid a jerk.

**Commissioning Considerations.** Coordinated motion is sensitive to tuning and to mechanical stiffness. Loops must be tuned so that following error (the lag between commanded and actual position) is small and consistent; large following error causes the slave to deviate from the cam. Mechanical backlash and compliance cause the actual motion to differ from the commanded motion, especially at direction reversals. Test at speed and at load; a cam that looks good in simulation may fail under inertia.

## Best Practices

- Use a virtual master for flexibility; engage slaves bumplessly by matching velocity before locking position.
- Design cam profiles with continuous acceleration to avoid jerk; simulate before commissioning.
- Tune loops for small, consistent following error; large following error degrades synchronization.
- Characterize mechanical backlash and compliance, especially at reversals.
- Test at production speed and load; a cam that works in simulation may fail under inertia.

## Common Pitfalls

- **Acceleration discontinuities** cause jerk, mechanical shock, and poor product quality.
- **Bumpy gearing in** shocks the machine and can break product or mechanics.
- **Large following error** causes the slave to deviate from the cam profile.
- **Unmodeled backlash** causes the actual motion to differ from the commanded motion.
- **Testing only at low speed** hides problems that appear at production speed and load.

## Real-World Example

A rotary knife cutter used a cam profile with a linear segment that caused an acceleration discontinuity at the cut point, producing a visible mark on the product and premature knife wear. After redesigning the profile with a polynomial blend for continuous acceleration, the mark disappeared and knife life doubled. The cam profile''s smoothness directly determined product quality and mechanical wear.

## Knowledge Check

Review the motion coordination modes (gearing, camming, phase locking), the cam profile and the importance of continuous acceleration, the master source and bumpless gearing in, and the commissioning considerations before the quiz.',
  quiz = '[
    {"question":"What does electronic camming do?","options":["Moves an axis to a target independently","Slaves an axis to a master via a position-to-position table (the cam profile)","Locks an axis at a fixed position","Disables the master"],"answer":1,"explanation":"Camming slaves an axis to a master via a cam profile, used for periodic operations like rotary cutting."},
    {"question":"Why must a cam profile have continuous acceleration?","options":["To save energy","To avoid jerk, mechanical shock, and poor product quality","To reduce cost","To simplify tuning"],"answer":1,"explanation":"Acceleration discontinuities cause jerk, which shocks the machine and degrades the product."},
    {"question":"What is a bumpless gearing in?","options":["Engaging the slave at full speed","Matching the slave velocity to the master before locking position, to avoid a jerk","Disabling the master","Locking position first"],"answer":1,"explanation":"Bumpless engagement matches velocity before position lock, preventing a shock to the machine."},
    {"question":"Why is a virtual master preferred?","options":["It is cheaper","Master speed can be changed without mechanical effects and the cam can engage at any position","It is required by law","It eliminates tuning"],"answer":1,"explanation":"A virtual master is software-generated, giving flexibility in speed and engagement position."},
    {"question":"What does large following error indicate?","options":["Good tuning","The slave deviates from the cam profile \u2014 loops need better tuning","Excessive cost","A virtual master"],"answer":1,"explanation":"Large following error means the slave cannot keep up; tuning must reduce it for accurate synchronization."},
    {"question":"Why test coordinated motion at production speed and load?","options":["To save time","A cam that works in simulation may fail under inertia at speed","To reduce cost","It is not necessary"],"answer":1,"explanation":"Inertia and load effects appear only at production conditions; low-speed testing hides them."},
    {"question":"What causes the actual motion to differ from the commanded motion at reversals?","options":["A virtual master","Mechanical backlash and compliance","Continuous acceleration","A bumpless engage"],"answer":1,"explanation":"Backlash and compliance cause the actual motion to deviate from the command, especially at direction reversals."}
  ]'::jsonb
  WHERE title = 'Coordinated Motion & Camming' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

Safety Integrity Level (SIL) determination is the process of assigning a target reliability to each safety function based on the risk it reduces. Over-specify and you overspend; under-specify and you accept undue risk. This lesson covers the SIL determination methods (risk graphs, LOPA), the safety-function requirements specification, and the verification that closes the loop between the required SIL and the designed system.

## Key Concepts

**SIL Determination Methods.** The risk graph method uses parameters (consequence, frequency/exposure, avoidance, probability of failure on demand) to select a SIL via a decision tree — fast and qualitative, suitable for simpler applications. Layer of Protection Analysis (LOPA) quantifies the initiating event frequency and the independent protection layers'' probability of failure on demand (PFD) to determine the residual risk and the SIL required of the SIS — more rigorous, used for higher-hazard processes. Both methods are accepted by IEC 61511; choose based on hazard complexity.

**The Safety Function Requirements Specification.** For each safety function, the SRS defines: the process safety function (what it does), the safe state (where it drives the process), the initiating events that trigger it, the response time (how fast it must act), the process safety time (how long before the hazard occurs), the SIL, the proof-test interval, and the bypass/override requirements. The SRS is the contract between process engineering and safety system design; an ambiguous SRS produces an ambiguous safety system.

**SIL and PFD.** SIL is a discrete level (1–4) corresponding to a PFD range: SIL 1 = 10⁻² to 10⁻¹, SIL 2 = 10⁻³ to 10⁻², SIL 3 = 10⁻⁴ to 10⁻³, SIL 4 = 10⁻⁵ to 10⁻⁴ (for low-demand mode). Higher SIL means lower acceptable PFD, requiring more reliable architecture (redundancy, diagnostics, lower proof-test interval). SIL 4 is rare in process industries and typically requires special measures; most process SIS are SIL 1–2, with some SIL 3.

**Verification.** SIL verification calculates the achieved PFD of the designed architecture (sensors, logic solver, final elements) using failure-rate data (from vendor FMEDA or industry databases), redundancy, voting (e.g., 2oo3), common-cause failure (β-factor), and proof-test coverage. If the achieved PFD meets the required SIL range, the design is adequate; if not, improve redundancy, diagnostics, or proof-test interval. Verification closes the loop between the required SIL and the as-built system.

## Best Practices

- Use risk graphs for simpler applications and LOPA for higher-hazard processes; both are IEC 61511-accepted.
- Write an unambiguous SRS for every safety function; it is the contract between process and safety design.
- Distinguish required SIL (from risk assessment) from achieved SIL (from verification); they must match.
- Use vendor FMEDA data and realistic proof-test coverage in verification; optimistic assumptions understate risk.
- Document the SIL determination and verification for auditability throughout the safety lifecycle.

## Common Pitfalls

- **Skipping LOPA for high-hazard processes** underestimates the required SIL.
- **Ambiguous SRS** produces a safety system that does not match the intended function.
- **Confusing required and achieved SIL** leads to a design that does not meet the risk target.
- **Optimistic proof-test coverage** in verification understates the achieved PFD.
- **No documentation** makes the SIL determination unauditable later.

## Real-World Example

A refinery used a risk graph to assign SIL 2 to a high-pressure separator shutdown function. A later LOPA revealed that the initiating event (cooling-water failure) was more frequent than the risk graph assumed, and that the operator response was not an independent layer. The LOPA upgraded the function to SIL 3, requiring redundant transmitters and a 2oo3 logic solver. The risk graph had under-estimated; the LOPA corrected it before the design was finalized.

## Knowledge Check

Review the SIL determination methods (risk graph, LOPA), the SRS contents, the SIL-to-PFD ranges, and the verification that closes the loop before the quiz.',
  quiz = '[
    {"question":"Which SIL determination method is more rigorous for higher-hazard processes?","options":["Risk graph","Layer of Protection Analysis (LOPA)","Guessing","Vendor recommendation"],"answer":1,"explanation":"LOPA quantifies initiating event frequency and independent layers, suited to higher-hazard processes."},
    {"question":"What does the Safety Requirements Specification (SRS) define?","options":["Only the SIL","The process safety function, safe state, response time, process safety time, SIL, proof-test interval, and bypass requirements","Only the sensor model","Only the cost"],"answer":1,"explanation":"The SRS is the contract between process and safety design; it defines everything the safety system must do."},
    {"question":"What PFD range corresponds to SIL 2 (low-demand mode)?","options":["10\u207b\u00b9 to 10\u2070","10\u207b\u00b3 to 10\u207b\u00b2","10\u207b\u2074 to 10\u207b\u00b3","10\u207b\u2075 to 10\u207b\u2074"],"answer":1,"explanation":"SIL 2 = PFD 10\u207b\u00b3 to 10\u207b\u00b2; higher SIL means lower acceptable PFD."},
    {"question":"What does SIL verification calculate?","options":["The cost of the SIS","The achieved PFD of the designed architecture using failure-rate data, redundancy, voting, and proof-test coverage","The operator response time","The SIL determination method"],"answer":1,"explanation":"Verification computes the achieved PFD and confirms it meets the required SIL range."},
    {"question":"Why distinguish required SIL from achieved SIL?","options":["They are the same","Required SIL comes from risk assessment; achieved SIL from verification \u2014 they must match","To reduce cost","To confuse auditors"],"answer":1,"explanation":"Required SIL is the target; achieved SIL is what the design delivers; a gap means the design is inadequate."},
    {"question":"What is a risk of optimistic proof-test coverage in verification?","options":["Faster verification","It understates the achieved PFD, making the design seem safer than it is","It increases cost","It is illegal"],"answer":1,"explanation":"Overstating proof-test coverage makes the achieved PFD look better than reality, understating risk."},
    {"question":"What did the LOPA reveal that the risk graph missed in the example?","options":["The SIL was too high","The initiating event was more frequent and operator response was not independent, requiring SIL 3","The SIS was unnecessary","The cost was too low"],"answer":1,"explanation":"LOPA found the risk graph underestimated frequency and over-counted protection layers, upgrading the SIL."}
  ]'::jsonb
  WHERE title = 'SIL Determination & Safety Functions' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add new module (sort_order 3) with 2 lessons
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Integrated Safety & Motion Commissioning', 3) RETURNING id INTO m_id;

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Safety-Rated Motion Functions & CIP Safety', '## Overview

Safety-rated motion functions and CIP Safety bring functional safety into the motion and network domains. Traditional safety stopped motion by removing power (category 0 stop) or by a controlled stop then power removal (category 2). Safety-rated motion functions — safe stop, safe limited speed, safe maximum speed, safe direction — let the safety system supervise motion while the drive remains powered, enabling faster recovery and safer setup modes. CIP Safety extends safety communication over standard EtherNet/IP, eliminating dedicated safety wiring. This lesson covers the safety motion functions, the CIP Safety protocol, and the commissioning considerations.

## Key Concepts

**Safety-Rated Motion Functions.** Safe Stop 1 (SS1) initiates a controlled deceleration then removes power when at zero speed — the standard for safe access. Safe Stop 2 (SS2) decelerates and holds position at zero speed with power on — used when re-starting quickly is required. Safe Limited Speed (SLS) limits the maximum speed to a safe value — used for setup and jog modes with the guard open. Safe Maximum Speed (SMS) monitors that speed does not exceed a limit. Safe Direction (SDI) prevents motion in an unsafe direction. These functions let operators interact with the machine safely without full power-down cycles.

**Safe Torque Off (STO).** STO removes torque without removing power — the drive is energized but cannot produce torque. This is the foundation of most safety motion functions: STO is the final safety action when a safe stop completes or when a safety function is triggered. STO is faster and gentler than contactor-based power removal, and it avoids the wear and arc of contactors.

**CIP Safety.** CIP Safety is the safety extension of EtherNet/IP, allowing safety devices (safety PLCs, safety I/O, safety drives) to communicate over the same network as standard control. Safety messages use a separate connection with additional integrity (sequence numbers, time stamps, CRCs) so that standard and safety traffic coexist safely. This eliminates dedicated safety wiring (the traditional hard-wired safety relay chain) and enables safety diagnostics over the network. CIP Safety is a black-channel protocol: the network does not need to be safety-rated, only the safety devices and the protocol integrity.

**Commissioning Considerations.** Safety motion functions require validating the stop time and the safe speed limits under worst-case load. Stop time must be measured, not assumed, because it depends on load inertia and friction. Safe speed limits must account for the worst-case speed error. The safety validation must confirm that the safety function responds within the process safety time. CIP Safety networks must be configured for the safety connection''s timeout and must be tested for communication loss behavior.

## Best Practices

- Use safety-rated motion functions (SS1, SS2, SLS) to enable safe setup and quick recovery without full power-down.
- Use STO as the final safety action; it is faster and gentler than contactor-based power removal.
- Validate stop time and safe speed limits under worst-case load by measurement, not assumption.
- Configure CIP Safety connections with appropriate timeouts and test communication-loss behavior.
- Document the safety validation, including measured stop times and safe speed limits, for auditability.

## Common Pitfalls

- **Assumed stop times** understate the actual stop time under load, leaving the safety function inadequate.
- **Safe speed limits set without margin** are exceeded by speed error under load.
- **Untested CIP Safety loss behavior** may not fail to the safe state as expected.
- **Mixing standard and safety traffic without the safety connection''s integrity** defeats the safety protocol.
- **No documented validation** makes the safety function unauditable.

## Real-World Example

A packaging machine replaced a hard-wired safety relay chain with a safety PLC and CIP Safety drives, using SS1 for safe access and SLS for setup mode. Operators could now enter the cell for clearing in seconds instead of waiting for a full power-down and re-start cycle. Measured stop time under load was 350 ms, longer than the assumed 200 ms, so the safety distance to the light curtain was increased to match. The validation documented the measured time and the resulting distance.

## Knowledge Check

Review the safety motion functions (SS1, SS2, SLS, STO), the CIP Safety black-channel principle, and the commissioning requirement to measure stop time under load before the quiz.',
  45, 1,
  '[
    {"question":"What does Safe Stop 1 (SS1) do?","options":["Removes power immediately","Initiates a controlled deceleration then removes power at zero speed","Holds position at zero speed with power on","Limits the maximum speed"],"answer":1,"explanation":"SS1 decelerates then removes power at zero speed \u2014 the standard for safe access."},
    {"question":"What is Safe Torque Off (STO)?","options":["Removing power via contactors","Removing torque without removing power \u2014 the drive is energized but cannot produce torque","A type of safety PLC","A CIP Safety message"],"answer":1,"explanation":"STO removes torque while the drive remains powered, faster and gentler than contactor-based removal."},
    {"question":"What does CIP Safety allow?","options":["Dedicated safety wiring","Safety communication over standard EtherNet/IP, eliminating dedicated safety wiring","Faster motion","Lower safety levels"],"answer":1,"explanation":"CIP Safety extends safety communication over EtherNet/IP using a black-channel protocol with added integrity."},
    {"question":"What does \"black-channel\" mean for CIP Safety?","options":["The network must be safety-rated","The network does not need to be safety-rated; only the safety devices and protocol integrity matter","The network is encrypted","The network is wired in black cable"],"answer":1,"explanation":"Black-channel means the network itself need not be safety-rated; safety is achieved by the protocol and devices."},
    {"question":"How must stop time be determined for safety validation?","options":["Assumed from the drive manual","Measured under worst-case load","Estimated from motor size","Ignored"],"answer":1,"explanation":"Stop time depends on load inertia and friction; it must be measured, not assumed, under worst-case load."},
    {"question":"What must safe speed limits account for?","options":["Only the commanded speed","The worst-case speed error under load","The operator\u2019s preference","The drive\u2019s maximum rating"],"answer":1,"explanation":"Speed error under load can exceed the limit; safe speed limits must include margin for error."},
    {"question":"What must be tested for CIP Safety networks?","options":["Only the IP addresses","Communication-loss behavior and the safety connection\u2019s timeout","The cable color","The vendor name"],"answer":1,"explanation":"CIP Safety connections must be configured for timeout and tested for safe behavior on communication loss."}
  ]'::jsonb);

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Motion System Commissioning & Safety Validation', '## Overview

Commissioning a motion system with integrated safety is the moment when design assumptions meet physical reality. Loop tuning, homing, following-error verification, and safety validation must all be completed before the machine can be released to production. This lesson covers the commissioning sequence for motion systems, the safety validation that confirms the safety functions perform as specified, and the documentation that makes the commissioning auditable.

## Key Concepts

**The Commissioning Sequence.** Motion commissioning proceeds in a defined order: mechanical verification (coupling, alignment, lubrication), encoder verification (correct direction, counts per revolution), loop tuning (position loop after velocity loop, with the load connected), homing (establishing a repeatable reference position), following-error verification (confirming the loop tracks within spec at speed and load), and finally the safety validation. Skipping steps or tuning without load produces a system that works at low speed and fails at production speed.

**Loop Tuning.** The velocity loop is tuned first (bandwidth, damping), then the position loop (gain). Tune with the load connected and at representative speeds; a system tuned unloaded will be unstable under inertia. Use frequency-response or step-response methods; both are valid if applied consistently. Watch for resonance (mechanical vibration excited by the loop bandwidth) and reduce bandwidth or add a low-pass filter if it appears. Document the final gains so they can be restored after a drive replacement.

**Homing.** Homing establishes the position reference; without it, the machine cannot know where it is. The homing sequence must be repeatable (the same position every time) and must account for the home sensor''s tolerance and the direction of approach. A common method is to seek the home switch at low speed, then seek the Z pulse (encoder index) for high repeatability. Document the homing sequence and the expected repeatability; an inconsistent home causes cumulative product defects.

**Safety Validation.** Safety validation confirms that each safety function performs as specified: the safe stop stops within the measured time, the safe limited speed does not exceed the limit, the safe direction prevents the unsafe direction, and the safety response occurs within the process safety time. Validation is performed under worst-case load and is documented with the measured values. The validation report is the evidence that the safety system meets its specification; without it, the safety function is asserted, not proven.

## Best Practices

- Commission in order: mechanical, encoder, loop tuning, homing, following-error, safety validation.
- Tune with the load connected and at representative speeds; document the final gains.
- Use a repeatable homing sequence (home switch plus Z pulse) and document the expected repeatability.
- Validate every safety function under worst-case load and document the measured values.
- Produce a validation report that proves each safety function meets its specification.

## Common Pitfalls

- **Tuning unloaded** produces instability under load.
- **Skipping the encoder verification** leads to wrong direction or wrong counts, breaking motion.
- **Inconsistent homing** causes cumulative product defects.
- **Safety validation under no load** understates the actual stop time.
- **No validation report** means the safety function is asserted, not proven.

## Real-World Example

A converting line was commissioned with the velocity loop tuned unloaded for speed; at production speed under the roller inertia, it oscillated and broke the web. After re-tuning with the load connected at production speed, the oscillation disappeared. The safety validation, performed under full roll weight, measured a stop time 40% longer than the unloaded estimate, requiring a longer safety distance to the light curtain. Both findings required load-connected commissioning to discover.

## Knowledge Check

Review the commissioning sequence, the load-connected tuning principle, the repeatable homing requirement, and the under-load safety validation before the quiz.',
  45, 2,
  '[
    {"question":"What is the correct commissioning sequence for a motion system?","options":["Safety validation, tuning, mechanical, encoder","Mechanical, encoder, loop tuning, homing, following-error, safety validation","Homing, tuning, mechanical, safety","Encoder, safety, tuning, mechanical"],"answer":1,"explanation":"The defined order ensures each step builds on the previous; skipping or reordering breaks the process."},
    {"question":"Why must loop tuning be done with the load connected?","options":["It is faster","A system tuned unloaded will be unstable under inertia","It saves energy","It is required by the drive manual"],"answer":1,"explanation":"Inertia changes loop behavior; tuning unloaded produces instability under load."},
    {"question":"Which loop is tuned first?","options":["Position loop","Velocity loop","Current loop is skipped","Neither"],"answer":1,"explanation":"The velocity loop is tuned first, then the position loop, with the load connected."},
    {"question":"What does a repeatable homing sequence provide?","options":["Faster motion","A consistent position reference every time","Lower cost","Higher speed"],"answer":1,"explanation":"Without repeatable homing, the machine cannot establish a reliable position reference."},
    {"question":"Under what condition must safety validation be performed?","options":["No load","Worst-case load","Half load","Any load"],"answer":1,"explanation":"Worst-case load produces the longest stop time; validation under lighter load understates it."},
    {"question":"What is the purpose of the safety validation report?","options":["To decorate a binder","To prove each safety function meets its specification with measured values","To reduce cost","To replace the SRS"],"answer":1,"explanation":"The report is the evidence that the safety system performs as specified; without it, the function is asserted, not proven."},
    {"question":"What happened when the converting line was tuned unloaded?","options":["It ran fine","It oscillated and broke the web at production speed under roller inertia","It saved time","It improved quality"],"answer":1,"explanation":"Unloaded tuning missed the inertia effect; the loop was unstable under load at production speed."}
  ]'::jsonb);
END $$;