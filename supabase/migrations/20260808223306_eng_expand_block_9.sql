DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Commissioning, Startup & Project Execution';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lesson 1
  UPDATE lessons SET content = '## Overview

Factory Acceptance Testing (FAT), Site Acceptance Testing (SAT), and I/O checkout are the staged verifications that de-risk a control system before it goes live. Each stage catches a different class of problem: FAT catches design and build errors while the equipment is still at the integrator; SAT catches shipping damage and site integration issues; I/O checkout catches wiring and addressing errors before logic is tested. This lesson covers the purpose and content of each stage, the test plans, and the pass/fail criteria.

## Key Concepts

**Factory Acceptance Test (FAT).** The FAT is conducted at the integrator''s facility before shipment. It verifies that the control panel and PLC program meet the functional specification: every I/O point is exercised, every sequence runs, every alarm annunciates, every HMI screen works. The FAT test plan is derived from the Functional Design Specification (FDS) and is written before the panel is built. The customer witnesses and signs off. A thorough FAT catches the majority of issues while they are cheap to fix — at the integrator, with the build team present. Skipping or rushing FAT pushes issues to the site, where they are expensive.

**Site Acceptance Test (SAT).** The SAT is conducted at the customer''s site after installation. It verifies that the system survived shipping and integrates with the field devices, the network, and the adjacent equipment. The SAT re-runs a subset of the FAT (the critical functions) plus site-specific tests (network integration, inter-system interlocks, field device operation). The SAT catches shipping damage, mis-wired field devices, and integration issues that the FAT could not. SAT is shorter than FAT but catches what FAT cannot.

**I/O Checkout.** I/O checkout verifies that every physical I/O point is wired correctly and addressed correctly in the controller. For each input, the technician energizes the field device and confirms the controller sees the correct state; for each output, the technician commands the output and confirms the field device responds. Discrepancies (wrong terminal, wrong address, wrong polarity) are found and fixed before logic testing begins. I/O checkout is methodical and documented (a point-to-point checklist); skipping it makes logic debugging a guessing game.

**Pass/Fail and Punch Lists.** Each test produces a pass/fail result and a punch list of discrepancies. A punch list item is a defect that must be fixed before the next stage or before acceptance. Track punch list items to closure with an owner and a date. Do not accept a system with an open punch list that affects safety or a critical function; non-critical items can be deferred with a documented commitment. The punch list is the contractually binding record of what is and is not complete.

## Best Practices

- Derive the FAT test plan from the FDS; write it before the panel is built; have the customer witness and sign off.
- Conduct a thorough FAT — it catches the majority of issues while they are cheap to fix.
- Run a SAT that re-tests critical functions plus site-specific integration tests.
- Perform methodical, documented I/O checkout before logic testing; use a point-to-point checklist.
- Track punch list items to closure with an owner and date; do not accept with open safety-critical items.

## Common Pitfalls

- **Rushed or skipped FAT** pushes issues to the site, where they are expensive and delay startup.
- **No written test plan** makes FAT ad hoc and non-repeatable.
- **Skipping I/O checkout** makes logic debugging a guessing game.
- **Untracked punch list items** are forgotten and become startup surprises.
- **Accepting with open safety-critical punch items** risks go-live with known defects.

## Real-World Example

A water treatment plant skipped a thorough FAT to meet a schedule and went to SAT with an untested panel. SAT found 60 wiring discrepancies, a mis-addressed analog card, and a sequence that did not match the spec — all issues a FAT would have caught at the integrator. The startup was delayed by three weeks while the integrator flew a technician to the site to fix what should have been fixed in the shop. The schedule pressure that drove the FAT skip caused a longer delay than the FAT would have.

## Knowledge Check

Review the purpose and content of FAT, SAT, and I/O checkout, the test plan derivation from the FDS, and the punch list management before the quiz.',
  quiz = '[
    {"question":"What is the purpose of the FAT?","options":["To test at the customer site","To verify the panel and program meet the spec at the integrator\u2019s facility before shipment","To skip testing","To train operators"],"answer":1,"explanation":"FAT catches design and build issues at the integrator, where they are cheap to fix, before shipment."},
    {"question":"What is the purpose of the SAT?","options":["To replace the FAT","To verify the system survived shipping and integrates with field devices and adjacent equipment at the site","To test the panel before it is built","To skip I/O checkout"],"answer":1,"explanation":"SAT catches shipping damage and site integration issues that FAT cannot."},
    {"question":"What does I/O checkout verify?","options":["The logic","That every physical I/O point is wired and addressed correctly in the controller","The HMI graphics","The network"],"answer":1,"explanation":"I/O checkout confirms each field device maps to the correct controller point before logic testing."},
    {"question":"What should the FAT test plan be derived from?","options":["The integrator\u2019s memory","The Functional Design Specification (FDS)","The punch list","The operator\u2019s preference"],"answer":1,"explanation":"The FDS defines what the system must do; the FAT plan verifies it, written before the panel is built."},
    {"question":"What is a punch list?","options":["A list of completed tests","A list of discrepancies that must be fixed before the next stage or acceptance","A list of operators","A list of tools"],"answer":1,"explanation":"Punch list items are defects tracked to closure with an owner and date; safety-critical items block acceptance."},
    {"question":"Why perform I/O checkout before logic testing?","options":["To save time","So logic debugging is not a guessing game about wiring and addressing","To increase cost","It is optional"],"answer":1,"explanation":"Without I/O checkout, a logic failure could be a wiring error or a logic bug \u2014 impossible to distinguish."},
    {"question":"What did skipping FAT cost the water treatment plant?","options":["Nothing","A three-week startup delay to fix issues a FAT would have caught at the integrator","A better system","Lower cost"],"answer":1,"explanation":"The schedule pressure that drove the FAT skip caused a longer delay than the FAT would have."}
  ]'::jsonb
  WHERE title = 'FAT, SAT & I/O Checkout' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Update existing lesson 2
  UPDATE lessons SET content = '## Overview

Functional testing and punch list management are the heart of commissioning: proving that the system does what the specification says it does, and tracking every discrepancy to closure before the system is handed over to operations. This lesson covers the functional test plan, the step-by-step test execution, and the punch list discipline that turns a list of tests into a verified, accepted system.

## Key Concepts

**The Functional Test Plan.** The functional test plan verifies every function in the FDS: every operating mode (auto, manual, maintenance), every sequence, every interlock, every alarm, every HMI interaction. Each test has a unique ID, a description, the expected result, the actual result, and a pass/fail. The plan is written before testing begins and is executed step by step; ad hoc testing misses functions and produces no auditable record. The test plan is the contract: when every test passes, the system is functionally complete.

**Step-by-Step Execution.** Execute the test plan in order, one test at a time, recording the actual result and pass/fail for each. Do not batch tests and record them later — memory is unreliable, and a failed test may affect subsequent tests. When a test fails, record the failure, add a punch list item, and decide whether to continue (if the failure does not affect later tests) or stop and fix. A test plan that is "mostly passed" with a few unrecorded failures is not a verified system.

**Interlock and Alarm Testing.** Interlocks and alarms are safety-critical and must be tested explicitly: drive the system to the interlock condition and confirm the interlock acts; drive the system to the alarm condition and confirm the alarm annunciates with the correct priority and message. Do not assume an interlock works because the logic looks right — test it. Test the failure modes too: what happens when a sensor fails, when a communication drops, when an e-stop is pressed. These tests find the latent faults that only surface on demand.

**Punch List Discipline.** Every failed test and every observed discrepancy becomes a punch list item with a unique ID, a description, an owner, a target date, and a status. Review the punch list daily during commissioning: what was closed, what is open, what is blocking. A punch list that is not reviewed daily grows and loses items. Close items to closure (verified fixed, re-tested, passed), not just to "fixed." The punch list at acceptance is the contractual record of what is and is not complete.

## Best Practices

- Write the functional test plan before testing; derive it from the FDS; give each test a unique ID.
- Execute and record one test at a time; do not batch and record later.
- Test interlocks and alarms explicitly, including failure modes (sensor failure, comm loss, e-stop).
- Track every failed test and discrepancy as a punch list item with an owner and date; review daily.
- Close items to verified-fixed-and-re-tested, not just to \u201cfixed\u201d; the punch list at acceptance is contractual.

## Common Pitfalls

- **Ad hoc testing** misses functions and produces no auditable record.
- **Batched recording** is unreliable and misses the effect of failures on later tests.
- **Untested interlocks and alarms** harbor latent faults that surface on demand.
- **Unreviewed punch lists** grow and lose items.
- **Closing to \u201cfixed\u201d without re-test** lets fixes that did not work slip through.

## Real-World Example

A packaging line commissioning had a 200-test functional plan. The team executed it step by step, recording each result. Test 147 (a low-pressure interlock) failed — the interlock did not act. The punch list item was assigned, fixed (a typo in the comparison), and re-tested to pass. Without the explicit interlock test, the fault would have remained latent until a low-pressure event caused a hazard. The step-by-step discipline found it during commissioning, not during operation.

## Knowledge Check

Review the functional test plan derivation and unique IDs, step-by-step execution and recording, explicit interlock and alarm testing including failure modes, and daily punch list discipline before the quiz.',
  quiz = '[
    {"question":"What should the functional test plan be derived from?","options":["The operator\u2019s preference","The Functional Design Specification (FDS)","The punch list","The vendor catalog"],"answer":1,"explanation":"The FDS defines the functions; the test plan verifies each one, written before testing begins."},
    {"question":"How should tests be executed and recorded?","options":["Batched and recorded later","One at a time, recording the actual result and pass/fail immediately","Skipped if they look easy","From memory"],"answer":1,"explanation":"One-at-a-time recording is reliable and captures the effect of failures on later tests."},
    {"question":"What must be tested explicitly, including failure modes?","options":["Only the HMI","Interlocks and alarms, including sensor failure, comm loss, and e-stop","Only the auto mode","Only the manual mode"],"answer":1,"explanation":"Interlocks and alarms are safety-critical; testing their failure modes finds latent faults before demand."},
    {"question":"What does every failed test and discrepancy become?","options":["Ignored","A punch list item with a unique ID, owner, target date, and status","A completed test","A new FDS"],"answer":1,"explanation":"Every discrepancy is tracked as a punch list item; untracked items are forgotten."},
    {"question":"How often should the punch list be reviewed during commissioning?","options":["Never","Daily \u2014 what was closed, what is open, what is blocking","Once at the end","Monthly"],"answer":1,"explanation":"Daily review keeps the punch list current and prevents items from being lost."},
    {"question":"What does \u201cclose to closure\u201d mean for a punch list item?","options":["Marked \u201cfixed\u201d","Verified fixed, re-tested, and passed","Deleted","Ignored"],"answer":1,"explanation":"Closing to verified-re-tested-passed ensures the fix actually worked; \u201cfixed\u201d alone is insufficient."},
    {"question":"What did test 147 find in the example?","options":["A good interlock","A low-pressure interlock that did not act due to a typo, found and fixed before a demand","A missing HMI","A bad cable"],"answer":1,"explanation":"The explicit interlock test found a latent fault during commissioning; without it, the fault would have surfaced as a hazard."}
  ]'::jsonb
  WHERE title = 'Functional Testing & Punch List' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Startup Execution & Cut-over Planning', 2) RETURNING id INTO m_id;

  -- Module 2, lesson 1
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Startup Sequencing & Process Commissioning', '## Overview

Startup is the transition from a verified-but-idle system to a running process. It is where the control system meets the process dynamics for the first time, and where the tuning, the sequences, and the interlocks are proven under real conditions. A well-planned startup proceeds in a defined sequence with hold points; a poorly planned startup is a scramble that risks equipment, product, and safety. This lesson covers the startup sequence, the hold points, and the process commissioning practices that de-risk the go-live.

## Key Concepts

**The Startup Sequence.** A startup proceeds in a defined order: utilities first (power, air, water, steam), then permissive checks (all interlocks healthy, all safety functions proven), then process introduction (feed, heat, pressure) in a controlled ramp, then control loops on-auto one at a time, then production ramp to rate. Each step has a hold point — a checkpoint where the team confirms the step is complete and stable before proceeding. Skipping a hold point or proceeding on an unstable step cascades into a difficult, dangerous startup.

**Permissive and Safety Proving.** Before process introduction, prove that every permissive and safety function works: drive each interlock to its trip condition and confirm the safe state. This is the last chance to find a latent safety fault before the process is running. Document the proving; an unproven safety function is an assertion, not a fact. If a safety function fails during proving, stop and fix it — do not proceed on the assumption that it will "probably" work.

**Control Loop Commissioning.** Bring control loops on-auto one at a time, in the right order: flow loops first (fast, stable), then temperature and pressure (slower, interacting), then composition (slowest, often analyzer-based). Tune each loop at the operating point; a loop tuned at low flow may be unstable at high flow. Confirm the loop holds the setpoint under disturbance before moving on. Bringing all loops on-auto at once makes it impossible to tell which loop is causing an oscillation.

**Process Ramping.** Ramp the process to rate in steps, holding at intermediate rates to confirm stability. A startup that goes straight to full rate risks overshoot, instability, and equipment damage. The ramp rate is limited by the process (thermal expansion, reaction kinetics, equipment limits). Document the ramp plan and the hold points; a startup that deviates from the plan without a documented decision is out of control.

## Best Practices

- Follow a defined startup sequence: utilities, permissive proving, process introduction, loops on-auto, ramp to rate.
- Use hold points at each step; do not proceed until the step is stable and confirmed.
- Prove every permissive and safety function before process introduction; document the proving.
- Bring control loops on-auto one at a time in the right order; tune at the operating point.
- Ramp to rate in steps with holds; document the ramp plan and deviations.

## Common Pitfalls

- **Skipping hold points** cascades instability into the next step.
- **Unproven safety functions** are assertions that may fail on the first demand.
- **All loops on-auto at once** makes oscillation sources impossible to identify.
- **Straight to full rate** risks overshoot, instability, and equipment damage.
- **Undocumented deviations** from the ramp plan mean the startup is out of control.

## Real-World Example

A reactor startup brought all temperature loops on-auto simultaneously, and the reactor began oscillating with no clear cause. After two hours of instability, the team took all loops to manual, then brought them on-auto one at a time, finding that one loop''s tuning was unstable at the operating point. The one-at-a-time approach identified the culprit in 20 minutes; the all-at-once approach had made it impossible to isolate. The startup discipline, not the tuning, was the lesson.

## Knowledge Check

Review the startup sequence and hold points, permissive and safety proving, one-at-a-time loop commissioning in the right order, and stepped ramping before the quiz.',
  45, 1,
  '[
    {"question":"What is the correct startup sequence?","options":["Ramp to rate, then utilities, then loops","Utilities, permissive proving, process introduction, loops on-auto, ramp to rate","Loops on-auto, then utilities, then process","Process introduction, then utilities, then loops"],"answer":1,"explanation":"The defined sequence builds from utilities through permissives to process to control to rate, with hold points."},
    {"question":"What is a hold point?","options":["A storage location","A checkpoint where the team confirms a step is stable before proceeding","A type of sensor","A bypass"],"answer":1,"explanation":"Hold points prevent proceeding on an unstable step, which would cascade into a difficult startup."},
    {"question":"When should safety functions be proven?","options":["After the process is running","Before process introduction, with documentation","Never","During the ramp"],"answer":1,"explanation":"Proving safety functions before process introduction is the last chance to find latent faults; document the proving."},
    {"question":"How should control loops be brought on-auto?","options":["All at once","One at a time, in the right order (flow, then temperature/pressure, then composition)","In reverse order","Only in manual"],"answer":1,"explanation":"One at a time in the right order isolates oscillation sources; all at once makes them impossible to identify."},
    {"question":"Why ramp to rate in steps with holds?","options":["To save energy","To confirm stability at intermediate rates and avoid overshoot and equipment damage","To reduce cost","It is faster"],"answer":1,"explanation":"Stepped ramping confirms stability; going straight to full rate risks overshoot, instability, and damage."},
    {"question":"What did the all-at-once loop commissioning cause in the example?","options":["A fast startup","Reactor oscillation with no identifiable cause for two hours","A better tune","Lower cost"],"answer":1,"explanation":"All-at-once made the oscillation source unidentifiable; one-at-a-time found the unstable loop in 20 minutes."},
    {"question":"Where should a loop be tuned?","options":["At zero flow","At the operating point","In manual only","At full rate only"],"answer":1,"explanation":"A loop tuned at one operating point may be unstable at another; tune at the actual operating point."}
  ]'::jsonb);

  -- Module 2, lesson 2
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Cut-over, Rollback & Handover to Operations', '## Overview

Cut-over is the moment when a new or modified system takes over from the old, and handover is when the system moves from the project team to operations. Both are transitions with high risk: a botched cut-over stops production, and a poor handover leaves operations unable to run the system. This lesson covers the cut-over plan, the rollback strategy, and the handover package that makes the transition safe and sustainable.

## Key Concepts

**The Cut-over Plan.** A cut-over plan defines the exact sequence of steps to switch from the old system to the new: the timing (usually a maintenance window), the sequence (decommission old, commission new, transfer process), the roles (who does what, who verifies), and the communication (who is notified at each step). The plan is rehearsed, not invented on the day. Every step has an owner and a verification. A cut-over without a plan is a gamble; a cut-over with a plan is a controlled transition.

**Rollback Strategy.** Every cut-over must have a tested rollback: if the new system does not work, return to the old system. The rollback plan defines the conditions for rollback (what constitutes failure), the steps, and the time limit (how long the team has to decide). Test the rollback during commissioning, not on cut-over day. A cut-over without a tested rollback is a one-way door — if the new system fails, the team is stuck. The decision to roll back must be made by a named authority before time runs out, not by committee under pressure.

**Handover Package.** The handover package is what operations needs to run the system: the operating manual (modes, procedures, setpoints), the alarm list with priorities and responses, the maintenance manual (proof tests, spare parts, procedures), the as-built documentation (P&IDs, electrical, network), the software and backups (the current revision, the backup revision), and the training records. Without a complete handover package, operations is left to figure out the system, which produces errors and downtime. The handover is a formal sign-off: operations accepts the system when the package is complete and the training is done.

**Training and Competency.** Operations and maintenance must be trained before handover, not after. Training covers the operating modes, the alarm responses, the maintenance procedures, and the known issues. Verify competency (not just attendance) — a sign-in sheet is not training. Untrained operators make errors that the system design cannot prevent; training is part of the system, not an add-on.

## Best Practices

- Write and rehearse the cut-over plan; give every step an owner and a verification.
- Define and test the rollback strategy during commissioning; name the rollback decision authority and time limit.
- Produce a complete handover package: operating manual, alarm list, maintenance manual, as-builts, software/backups, training records.
- Train operations and maintenance before handover; verify competency, not just attendance.
- Make handover a formal sign-off; operations accepts when the package is complete and training is done.

## Common Pitfalls

- **Unrehearsed cut-over** is a scramble that stops production.
- **No tested rollback** makes the cut-over a one-way door.
- **Incomplete handover package** leaves operations unable to run or maintain the system.
- **Training after handover** means operators make errors on a system they do not understand.
- **Sign-in-sheet training** verifies attendance, not competency.

## Real-World Example

A control system upgrade had a cut-over plan with a 4-hour maintenance window and a tested rollback. At hour 3, a critical sequence failed on the new system, and the rollback authority (named in the plan) decided to roll back within the time limit. The rollback restored the old system, and production resumed on schedule. The tested rollback and the named authority turned a would-be multi-day outage into a non-event. A peer project without a rollback plan spent three days down after a similar failure.

## Knowledge Check

Review the cut-over plan and rehearsal, the tested rollback with named authority and time limit, the handover package contents, and competency-verified training before the quiz.',
  45, 2,
  '[
    {"question":"What must every cut-over plan include?","options":["A hope it works","A tested rollback with named decision authority and time limit","A longer maintenance window only","A bigger team"],"answer":1,"explanation":"A tested rollback with a named authority and time limit makes the cut-over a two-way door, not a one-way gamble."},
    {"question":"When should the rollback be tested?","options":["On cut-over day","During commissioning, before cut-over","After the first failure","Never"],"answer":1,"explanation":"Testing the rollback during commissioning verifies it works before it is needed under pressure."},
    {"question":"What is in a handover package?","options":["Only the software","Operating manual, alarm list, maintenance manual, as-builts, software/backups, training records","Only the P&IDs","Only the spare parts list"],"answer":1,"explanation":"A complete package gives operations everything needed to run and maintain the system."},
    {"question":"When should operations and maintenance training occur?","options":["After handover","Before handover, with competency verified","During the first outage","Never"],"answer":1,"explanation":"Training before handover prevents operator errors on an unfamiliar system; verify competency, not attendance."},
    {"question":"What is handover?","options":["A handshake","A formal sign-off where operations accepts when the package is complete and training is done","An email","A phone call"],"answer":1,"explanation":"Handover is a formal acceptance; without it, the system is not operationally owned."},
    {"question":"What did the tested rollback achieve in the example?","options":["A multi-day outage","A non-event \u2014 the rollback restored the old system within the window","A failed project","A longer cut-over"],"answer":1,"explanation":"The tested rollback and named authority turned a would-be multi-day outage into a non-event."},
    {"question":"Why verify competency, not just attendance, in training?","options":["To save time","Attendance does not prove the operator can run the system; competency does","To reduce cost","It is not necessary"],"answer":1,"explanation":"A sign-in sheet verifies attendance, not the ability to operate; competency verification prevents errors."}
  ]'::jsonb);

  -- Add module 3
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Project Management & Continuous Improvement', 3) RETURNING id INTO m_id;

  -- Module 3, lesson 1
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Project Planning, Scheduling & Risk Management', '## Overview

A control system project is a project: it has scope, schedule, budget, and risk, and it succeeds or fails on how well these are managed. Technical excellence cannot rescue a project with unmanaged scope, an unrealistic schedule, or unmanaged risk. This lesson covers the project planning that sets up a control system project for success, the scheduling that keeps it on track, and the risk management that anticipates what will go wrong.

## Key Concepts

**Scope Definition.** The scope is what the project will deliver, defined by the FDS and the I/O list, with explicit exclusions. Scope creep — adding functions during execution — is the primary cause of schedule and budget overruns. Manage scope through a change-control process: every addition is assessed for impact (cost, schedule, risk) and approved (or deferred) by the change authority. A project without scope control grows until it fails.

**Scheduling.** A project schedule breaks the work into tasks with dependencies and durations, identifying the critical path — the sequence of tasks that determines the project duration. The critical path is where schedule risk concentrates; a delay on a critical-path task delays the project. Build the schedule with the team (not imposed), include contingency (typically 15–20%), and update it weekly. A schedule that is not updated is a fiction; a schedule that is updated weekly is a management tool.

**Risk Management.** Risk management identifies what can go wrong, assesses likelihood and impact, and plans mitigation. For control system projects, common risks include: long-lead items (controllers, panels, instruments with multi-month lead times), vendor resource availability, integration with existing systems, and commissioning surprises. Maintain a risk register with each risk''s likelihood, impact, mitigation, and owner. Review the register weekly; a risk that is not reviewed is a risk that is not managed.

**Long-Lead Item Management.** Long-lead items (controllers, safety-certified devices, custom panels, specialized instruments) can have lead times of 3–6 months or more. Identify long-lead items early and order them on a preliminary design, before the full design is complete. The lead time, not the design, often determines the project duration. A project that waits for the full design to order long-lead items adds months to its schedule.

## Best Practices

- Define scope in the FDS with explicit exclusions; control changes through a change-control process.
- Build the schedule with the team, identify the critical path, include 15–20% contingency, and update weekly.
- Maintain a risk register with likelihood, impact, mitigation, and owner; review weekly.
- Identify long-lead items early and order them on a preliminary design before the full design is complete.
- Treat the schedule and risk register as management tools, not paperwork.

## Common Pitfalls

- **Scope creep** grows the project until it fails.
- **Imposed schedules** without team input are unrealistic and unowned.
- **No contingency** means any slip becomes an overrun.
- **Unmanaged risks** become issues that stop the project.
- **Late long-lead orders** add months to the schedule.

## Real-World Example

A project had a 12-month schedule with a critical-path panel build that depended on a 16-week-lead controller. The team ordered the controller on the preliminary I/O count at week 2, before the full design. When the full design at week 8 changed the I/O count by 10%, the controller was already in production and the panel build started on time. A peer project waited for the full design to order and lost 16 weeks — the controller lead time, not the design, determined the schedule.

## Knowledge Check

Review scope definition and change control, critical-path scheduling with contingency and weekly updates, the risk register, and long-lead item management before the quiz.',
  45, 1,
  '[
    {"question":"What is scope creep?","options":["A well-managed project","Adding functions during execution without change control, causing overruns","A type of schedule","A risk mitigation"],"answer":1,"explanation":"Scope creep is uncontrolled addition of scope; it is the primary cause of overruns and is managed by change control."},
    {"question":"What is the critical path?","options":["The shortest path","The sequence of tasks that determines the project duration","The cheapest path","The safest path"],"answer":1,"explanation":"The critical path is where schedule risk concentrates; a delay on it delays the project."},
    {"question":"How much contingency should a project schedule include?","options":["0%","15\u201320%","50%","100%"],"answer":1,"explanation":"15\u201320% contingency absorbs normal slips without an overrun; no contingency means any slip overruns."},
    {"question":"How often should the schedule and risk register be updated?","options":["Never","Weekly","Monthly","At project end"],"answer":1,"explanation":"Weekly updates keep the schedule and risk register as management tools; un-updated, they are fiction."},
    {"question":"When should long-lead items be ordered?","options":["After the full design","On a preliminary design, before the full design is complete","At project end","Whenever convenient"],"answer":1,"explanation":"Long-lead items (3\u20136 month lead) often determine the schedule; ordering on a preliminary design saves months."},
    {"question":"What does a risk register contain for each risk?","options":["Only a description","Likelihood, impact, mitigation, and owner","Only the cost","Only the date"],"answer":1,"explanation":"Each risk has likelihood, impact, mitigation, and owner; weekly review keeps risks managed, not ignored."},
    {"question":"What did ordering the controller on the preliminary design achieve?","options":["A 16-week delay","The panel build started on time despite a 10% I/O change at week 8","A cheaper controller","A better design"],"answer":1,"explanation":"Ordering early on the preliminary count meant the 16-week lead did not delay the panel build; the peer project lost 16 weeks."}
  ]'::jsonb);

  -- Module 3, lesson 2
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Lessons Learned & Post-Project Continuous Improvement', '## Overview

A project that ends without capturing lessons learned repeats the same mistakes on the next one. The post-project review is the mechanism that turns experience into improvement: what went well, what did not, and what to do differently. This lesson covers the post-project review process, the lessons-learned register, and the practices that turn lessons into changes in how the organization works.

## Key Concepts

**The Post-Project Review.** Within a few weeks of project completion, convene the team (engineering, integration, operations, maintenance) for a structured review. Cover what went well (to be repeated), what did not (to be avoided), and what to do differently (actionable changes). Use a facilitator to keep the review constructive, not blame-seeking. The output is a set of lessons and actions, not a narrative. Time-box the review; a review that drags on loses participation.

**The Lessons-Learned Register.** Capture lessons in a register that persists across projects: the lesson, the project, the category (design, commissioning, vendor, schedule), and the action (what will change). The register is searchable so that the next project can learn from the last. A lesson that is not captured is a lesson that is lost when the team moves on. Review the register at the start of each new project — "what did we learn last time that applies here?"

**Turning Lessons into Changes.** A lesson without an action is a complaint. Each lesson produces an action: a standard update (add to the coding standard), a checklist update (add to the FAT checklist), a process change (order long-lead items earlier), or a training need. Assign the action an owner and a date, and track it to closure. The measure of a lessons-learned program is not the number of lessons but the number of changes made.

**Metrics and Trends.** Track project metrics over time: schedule adherence, budget adherence, defect counts at FAT and SAT, commissioning duration. Trends reveal whether the organization is improving; a single project''s metrics are anecdote, a trend is evidence. Use trends to identify systemic issues (consistently late long-lead orders, consistently high SAT defect counts) and target them with specific changes.

## Best Practices

- Convene a structured, time-boxed post-project review with a facilitator; seek constructive lessons, not blame.
- Capture lessons in a searchable register with the lesson, project, category, and action.
- Turn each lesson into an action (standard, checklist, process, training) with an owner and date; track to closure.
- Review the lessons-learned register at the start of each new project.
- Track project metrics over time to identify trends and target systemic issues.

## Common Pitfalls

- **No post-project review** means the same mistakes repeat.
- **Blame-seeking reviews** drive concealment, not learning.
- **Lessons without actions** are complaints that change nothing.
- **No searchable register** means lessons are lost when the team moves on.
- **Single-project metrics** are anecdote; without trends, improvement is unmeasurable.

## Real-World Example

An integrator found that its projects consistently had high SAT defect counts for wiring. The lessons-learned register showed the same lesson across five projects: "FAT did not include point-to-point I/O checkout." The action was to add point-to-point I/O checkout to the standard FAT checklist. The next three projects had 60% fewer SAT wiring defects. The lesson, the action, and the tracking turned a recurring problem into a permanent improvement.

## Knowledge Check

Review the post-project review process, the lessons-learned register, turning lessons into actions with owners, and metrics/trends before the quiz.',
  45, 2,
  '[
    {"question":"When should the post-project review occur?","options":["Never","Within a few weeks of project completion","A year later","At project kickoff"],"answer":1,"explanation":"A review within a few weeks captures lessons while memory is fresh and the team is available."},
    {"question":"What is the output of a post-project review?","options":["A narrative report","A set of lessons and actionable changes","A list of people to blame","A new schedule"],"answer":1,"explanation":"The output is lessons and actions, not a narrative or a blame list."},
    {"question":"What must each lesson produce?","options":["Nothing","An action (standard, checklist, process, or training) with an owner and date","A meeting","A report"],"answer":1,"explanation":"A lesson without an action is a complaint; each lesson produces a tracked action."},
    {"question":"Why maintain a searchable lessons-learned register?","options":["For storage","So the next project can learn from the last; lessons are not lost when the team moves on","To increase cost","To slow projects"],"answer":1,"explanation":"A searchable register makes lessons available to future projects; without it, lessons are lost."},
    {"question":"What is the measure of a lessons-learned program?","options":["Number of lessons","Number of changes made","Number of meetings","Number of reports"],"answer":1,"explanation":"Lessons without changes are complaints; the measure is how many changes the lessons produced."},
    {"question":"Why track project metrics over time as trends?","options":["For decoration","Trends reveal systemic issues and whether the organization is improving","To increase storage","To slow projects"],"answer":1,"explanation":"A single project is anecdote; a trend is evidence that identifies systemic issues and improvement."},
    {"question":"What did the integrator\u2019s lessons-learned register reveal?","options":["A one-time issue","The same lesson across five projects \u2014 no point-to-point I/O checkout at FAT","A vendor problem","A budget overrun"],"answer":1,"explanation":"The recurring lesson drove a checklist change; the next three projects had 60% fewer SAT wiring defects."}
  ]'::jsonb);
END $$;