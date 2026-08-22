DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Reliability Centered Maintenance Strategy';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lesson: RCM Principles & FMEA
  UPDATE lessons SET content = '## Overview

Reliability Centered Maintenance (RCM) is a structured methodology for developing a maintenance program that preserves the function of physical assets. Where time-based or run-to-failure strategies apply a single strategy to all equipment, RCM analyzes each asset''s functions, failure modes, and consequences to select the right maintenance strategy for each. This lesson covers the RCM principles, the RCM process (the seven questions), and how RCM integrates with FMEA.

## Key Concepts

**RCM Principles.** RCM is built on seven principles: (1) preserve function — maintenance exists to preserve what the asset does, not the asset itself; (2) identify failure modes — how each function can fail; (3) prioritize by consequence — the failure''s impact determines the maintenance priority; (4) select tasks by failure behavior — time-based for wear-out, condition-based for random; (5) recognize design limitations — maintenance cannot overcome design flaws; (6) the program must be living — it evolves with the asset; (7) RCM is a team process — operations, maintenance, engineering contribute.

**The RCM Process (Seven Questions).** RCM answers seven questions for each asset: (1) What are the functions and standards? (2) In what ways can it fail? (3) What causes each failure? (4) What happens when it fails? (5) Does it matter? (6) What can be done to prevent or predict it? (7) What if nothing is done? The answers produce a maintenance strategy for each failure mode: a scheduled task, a condition-based task, a failure-finding task, or run-to-failure.

**RCM and FMEA.** RCM and FMEA are related: both identify failure modes and effects. RCM extends FMEA by adding the consequence analysis (does it matter?) and the task selection (what can be done?). An RCM analysis often starts from an FMEA and adds the consequence and task columns. The FMEA identifies what can fail; the RCM decides what to do about it. The two are complementary, not competing.

**Task Selection.** The task is selected by the failure behavior: wear-out (β > 1 in Weibull) supports time-based replacement or overhaul; random (β ≈ 1) supports condition-based monitoring or run-to-failure; hidden failure (a protective device that fails silently) supports a failure-finding task (test it periodically to detect the failure). The task must be technically feasible (it detects or prevents the failure) and worth doing (the cost is less than the consequence). RCM produces a documented task for each failure mode.

## Best Practices

- Apply RCM to critical assets where the consequence of failure justifies the analysis effort; not every asset needs RCM.
- Answer the seven questions for each asset with a cross-functional team (operations, maintenance, engineering).
- Start from an FMEA and add the consequence and task columns to produce the RCM analysis.
- Select the task by the failure behavior: time-based for wear-out, condition-based for random, failure-finding for hidden.
- Ensure each task is technically feasible and worth doing; document the decision.

## Common Pitfalls

- **Applying RCM to everything** wastes effort on low-criticality assets that do not justify the analysis.
- **Single-author RCM** misses failure modes and consequences that other disciplines would catch.
- **Time-based tasks for random failures** waste money without improving reliability.
- **No failure-finding for hidden failures** leaves protective devices silently failed.
- **Non-living programs** decay as the asset and its context change.

## Real-World Example

A power plant applied RCM to its critical pumps. The analysis found that the seal failure mode was wear-out (β = 2.5), supporting time-based seal replacement at 18 months, while the bearing failure mode was random (β = 1.1), supporting condition-based vibration monitoring. The RCM produced two different strategies for two failure modes on the same pump, each matched to the failure behavior. The previous one-strategy-fits-all program had been over-maintaining the bearings and under-maintaining the seals.

## Knowledge Check

Review the seven RCM principles, the seven-question process, the RCM-FMEA relationship, and the task selection by failure behavior before the quiz.',
  quiz = '[
    {"question":"What is the first principle of RCM?","options":["Replace everything on a schedule","Preserve function \u2014 maintenance exists to preserve what the asset does","Run to failure","Reduce cost"],"answer":1,"explanation":"RCM preserves function, not the asset; the analysis starts from what the asset does, not what it is."},
    {"question":"How many questions does the RCM process answer?","options":["Three","Seven","Ten","One"],"answer":1,"explanation":"RCM answers seven questions: functions, failures, causes, effects, consequences, prevention, and what if nothing is done."},
    {"question":"How does RCM relate to FMEA?","options":["They are unrelated","RCM extends FMEA with consequence analysis and task selection","RCM replaces FMEA","FMEA replaces RCM"],"answer":1,"explanation":"FMEA identifies failure modes and effects; RCM adds consequence (does it matter?) and task (what to do?)."},
    {"question":"Which task suits a wear-out failure (Weibull \u03b2 > 1)?","options":["Condition-based monitoring","Time-based replacement or overhaul","Run-to-failure","Failure-finding"],"answer":1,"explanation":"Wear-out means age predicts failure, so time-based replacement is appropriate."},
    {"question":"Which task suits a hidden failure (a protective device that fails silently)?","options":["Time-based replacement","Failure-finding (test it periodically to detect the failure)","Condition monitoring","Run-to-failure"],"answer":1,"explanation":"Hidden failures are not detected until a demand; a failure-finding task tests the device periodically to detect it."},
    {"question":"What did RCM find for the power plant pumps?","options":["One strategy fits all","Seal failure was wear-out (time-based) and bearing failure was random (condition-based) \u2014 two strategies for one pump","Both run-to-failure","Both time-based"],"answer":1,"explanation":"RCM matched each failure mode to its behavior; the previous one-strategy program had over-maintained bearings and under-maintained seals."},
    {"question":"Why not apply RCM to every asset?","options":["It is too cheap","The analysis effort is justified only for assets where the consequence of failure is significant","It is illegal","It is not effective"],"answer":1,"explanation":"RCM is effort-intensive; it pays back on critical assets where failure consequences justify the analysis."}
  ]'::jsonb
  WHERE title = 'RCM Principles & FMEA' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Update existing lesson: Task Selection & Program Implementation
  UPDATE lessons SET content = '## Overview

Task selection and program implementation turn the RCM analysis into a living maintenance program. The analysis identifies what to do; the implementation does it, measures it, and improves it. This lesson covers the task selection decision tree, the implementation into the CMMS, and the program measurement and improvement that sustain it.

## Key Concepts

**The Task Selection Decision Tree.** For each failure mode, the decision tree asks: Is the failure mode detectable? If no (hidden), use a failure-finding task. If yes, is there a clear wear-out pattern (β > 1)? If yes, use scheduled restoration or discard. If no (random), is condition monitoring feasible and cost-effective? If yes, use condition-based task. If no, is the consequence acceptable? If yes, run-to-failure. If no, redesign (the design cannot support the required reliability). The tree produces a documented task for each failure mode, with the reasoning.

**Implementation into the CMMS.** Each task becomes a work order in the CMMS: a scheduled task becomes a preventive maintenance (PM) work order with an interval; a condition-based task becomes a condition-monitoring route or a sensor-based alert; a failure-finding task becomes a functional test work order. The CMMS tracks the task (scheduled, completed, overdue) and the findings (which tasks found a failure, which did not). The CMMS is the system of record; a task not in the CMMS is a task that does not happen.

**Program Measurement.** Measure the program: PM compliance (% of PMs completed on time), the finding rate (which PMs or condition tasks found a failure), the avoided-failure rate (which findings became avoided failures), and the cost vs. the savings. The avoided-failure rate is the program''s value proof — it quantifies the failures the program prevented. A program that does not measure its avoided failures cannot prove its value and is vulnerable to budget cuts.

**Continuous Improvement.** The program improves by feeding findings and failures back into the analysis: a failure that occurred despite the task prompts a re-analysis (was the task wrong, or the interval too long?); a task that never finds a failure prompts a re-analysis (is the task necessary?). The program is living — it evolves with the asset, the failure data, and the operating context. A program that is built and not improved decays.

## Best Practices

- Use the task selection decision tree to produce a documented task for each failure mode with the reasoning.
- Implement each task in the CMMS (PM, condition, or functional test work order); a task not in the CMMS does not happen.
- Measure PM compliance, finding rate, avoided-failure rate, and cost vs. savings; the avoided-failure rate is the value proof.
- Feed findings and failures back into the analysis; re-analyze when a task fails or never finds.
- Treat the program as living; it evolves with the asset, the data, and the context.

## Common Pitfalls

- **Tasks not in the CMMS** are tasks that do not happen.
- **No measurement of avoided failures** leaves the program unable to prove its value.
- **No feedback from failures** lets the same failures recur because the task was wrong or the interval too long.
- **Tasks that never find a failure** are not re-analyzed for necessity.
- **Non-living programs** decay as the asset and context change.

## Real-World Example

A plant''s RCM program generated 500 PM work orders. After a year, the measurement found that 50 of the PMs never found a failure and 20 had found failures that the task should not have missed. The team retired the 50 ineffective PMs (saving maintenance cost) and re-analyzed the 20 (extending the interval or improving the task). The program measurement and the feedback loop, not the initial analysis, had driven the improvement.

## Knowledge Check

Review the task selection decision tree, the CMMS implementation, the program measurement (especially the avoided-failure rate), and the continuous improvement feedback before the quiz.',
  quiz = '[
    {"question":"What does the task selection decision tree produce?","options":["A single strategy for all assets","A documented task for each failure mode with the reasoning","A list of failures","A budget"],"answer":1,"explanation":"The tree produces a task per failure mode (failure-finding, scheduled, condition-based, run-to-failure, or redesign) with the reasoning."},
    {"question":"Where must each task be implemented?","options":["On paper only","In the CMMS as a PM, condition, or functional test work order","In the HMI","In the PLC"],"answer":1,"explanation":"The CMMS is the system of record; a task not in the CMMS is a task that does not happen."},
    {"question":"What is the program\u2019s value proof?","options":["The number of tasks","The avoided-failure rate \u2014 the failures the program prevented","The PM compliance","The cost"],"answer":1,"explanation":"The avoided-failure rate quantifies the failures prevented; without it, the program cannot prove its value."},
    {"question":"What prompts a re-analysis of a task?","options":["Nothing","A failure that occurred despite the task, or a task that never finds a failure","A new vendor","A budget cut"],"answer":1,"explanation":"A task that fails or never finds prompts re-analysis (wrong task, wrong interval, or unnecessary); the program is living."},
    {"question":"Why retire PMs that never find a failure?","options":["To reduce PM count","They are ineffective and waste maintenance cost; re-analysis confirms whether they are necessary","To increase findings","It is required"],"answer":1,"explanation":"PMs that never find a failure may be unnecessary; re-analysis confirms, and retiring them saves cost without reducing reliability."},
    {"question":"What did the plant\u2019s measurement find in the example?","options":["All PMs were effective","50 PMs never found a failure (retired) and 20 missed failures (re-analyzed)","No PMs","Too many failures"],"answer":1,"explanation":"The measurement and feedback loop drove the improvement: retire ineffective PMs, re-analyze the ones that missed."},
    {"question":"Why is the program called \u201cliving\u201d?","options":["It is a legal term","It evolves with the asset, the failure data, and the operating context","It is software","It is permanent"],"answer":1,"explanation":"A living program improves from findings and failures; a non-living program decays as the asset and context change."}
  ]'::jsonb
  WHERE title = 'Task Selection & Program Implementation' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2: Failure Modes & Maintenance Strategy Selection
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Failure Modes & Maintenance Strategy Selection', 2) RETURNING id INTO m_id;

  -- Module 2, Lesson 1: Hidden Failures & Protective Device Testing
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Hidden Failures & Protective Device Testing', '## Overview

Hidden failures are the most insidious failure mode in maintenance: a protective device (a safety relay, a pressure relief valve, an emergency shutdown) that fails silently, with no indication until a demand reveals it. The device is intended to act in an emergency; if it has failed, the emergency is unmitigated. This lesson covers the hidden failure concept, the failure-finding task, and the testing program for protective devices.

## Key Concepts

**Hidden Failures.** A hidden failure is one that is not evident to the operator under normal conditions — the device sits idle until a demand. Examples: a pressure relief valve that sticks closed (no symptom until an overpressure event), a safety relay that does not trip (no symptom until a hazard), an emergency pump that does not start (no symptom until it is needed). The failure is hidden because the device is not exercised in normal operation; the operator has no way to know it has failed. Hidden failures are particularly dangerous because they defeat protection that is assumed to be functional.

**The Failure-Finding Task.** For hidden failures, the RCM task is a failure-finding task: test the device periodically to detect the failure. The test interval is set by the failure rate and the acceptable probability of the device being failed on demand (the multiple of the failure rate and the interval). A device with a failure rate of 0.01/year and an acceptable failed-on-demand probability of 0.01 (1%) requires testing every year; one with a 0.1/year rate and the same acceptance requires testing every 36 days. The interval is calculated, not guessed.

**Testing Protective Devices.** The test exercises the device''s function: a relief valve is popped (pressure raised to the set point), a safety relay is tripped (the trip condition is simulated), an emergency pump is started (the start command is given). The test must exercise the full function, not just a part; testing the relay coil but not the contacts leaves a contact failure undetected. The test is documented (date, result, any repairs) and the device is returned to service. A test that is not documented is a test that cannot be audited.

**The Risk of Testing.** Testing a protective device can itself cause a risk: popping a relief valve can cause it to leak after the test, tripping a safety relay can cause an unexpected shutdown. Manage the test risk: test during a maintenance window, with the process in a safe state, and with a plan for the test consequence (a leak, a trip). The test risk is part of the task selection; a test whose risk exceeds the benefit is not worth doing, and an alternative (a less invasive test, or redesign) is sought.

## Best Practices

- Identify hidden failures (protective devices that sit idle until a demand) and assign a failure-finding task to each.
- Calculate the test interval from the failure rate and the acceptable failed-on-demand probability; do not guess.
- Test the full function (relay coil and contacts, valve pop and reseat), not just a part; document each test.
- Manage the test risk (test in a maintenance window, with the process safe, and a plan for the consequence).
- Document and audit the tests; an undocumented test cannot be verified.

## Common Pitfalls

- **No failure-finding for hidden failures** leaves protective devices silently failed.
- **Guessed test intervals** are either too long (high failed-on-demand probability) or too short (excessive testing cost and risk).
- **Partial tests** (coil but not contacts) leave failures undetected.
- **Test risk not managed** causes leaks, trips, or shutdowns from the test itself.
- **Undocumented tests** cannot be audited or verified.

## Real-World Example

A plant had never tested its pressure relief valves; one was found stuck closed during an overpressure event, and the vessel ruptured. After the incident, the plant instituted a failure-finding program: each relief valve was popped at an interval calculated from its failure rate and the acceptable failed-on-demand probability. The first round of testing found 3 of 40 valves stuck; they were replaced before another event. The hidden-failure program turned a post-incident reaction into a preventive practice.

## Knowledge Check

Review the hidden failure concept, the failure-finding task and interval calculation, the full-function testing, and the test risk management before the quiz.',
  45,
  1,
  '[
    {"question":"What is a hidden failure?","options":["A failure with a visible symptom","A failure not evident under normal conditions; the device sits idle until a demand","A fast failure","A slow failure"],"answer":1,"explanation":"Hidden failures (protective devices) have no symptom until a demand; the operator cannot know the device has failed."},
    {"question":"What is the RCM task for a hidden failure?","options":["Run-to-failure","A failure-finding task (test the device periodically to detect the failure)","Time-based replacement","Condition monitoring"],"answer":1,"explanation":"Hidden failures are not detected in normal operation; a failure-finding task tests the device periodically to detect the failure."},
    {"question":"How is the failure-finding interval determined?","options":["By guessing","By the failure rate and the acceptable failed-on-demand probability","By the vendor default","By the operator"],"answer":1,"explanation":"The interval is calculated so the multiple of the failure rate and the interval stays below the acceptable failed-on-demand probability."},
    {"question":"What must a failure-finding test exercise?","options":["Only the relay coil","The full function (relay coil and contacts, valve pop and reseat)","Only the contacts","Only the wiring"],"answer":1,"explanation":"A partial test leaves failures undetected; the full function must be exercised to detect all failure modes."},
    {"question":"What is a risk of testing a protective device?","options":["No risk","The test itself can cause a risk (a relief valve leak, an unexpected trip)","It is too expensive","It is illegal"],"answer":1,"explanation":"Testing can cause the event it prevents; manage the risk by testing in a maintenance window with the process safe."},
    {"question":"What did the plant find in its first round of relief valve testing?","options":["All valves were fine","3 of 40 valves were stuck closed, replaced before another event","All valves were stuck","No valves were testable"],"answer":1,"explanation":"The first round found 3 stuck valves; the failure-finding program caught them before another overpressure event."},
    {"question":"Why document failure-finding tests?","options":["For decoration","An undocumented test cannot be audited or verified","To increase cost","It is not necessary"],"answer":1,"explanation":"Documentation (date, result, repairs) is the audit trail that the protective devices have been tested and are functional."}
  ]'::jsonb);

  -- Module 2, Lesson 2: Design-Out vs. Maintenance: When to Redesign
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Design-Out vs. Maintenance: When to Redesign', '## Overview

Maintenance cannot overcome a design flaw. When a failure mode recurs despite the maintenance, or when the consequence of failure is unacceptable and no maintenance task can reduce it enough, the answer is to redesign — to change the design so the failure mode is eliminated or its consequence is acceptable. This lesson covers the design-out decision, the redesign options, and the integration of design-out with the RCM process.

## Key Concepts

**The Design-Out Decision.** The RCM task selection decision tree includes redesign as a last resort: if no maintenance task (scheduled, condition-based, failure-finding) can reduce the failure consequence to an acceptable level, the design must be changed. Design-out is also indicated when a failure mode recurs despite the maintenance — the maintenance is not working, and the design is the root cause. The decision is not a maintenance failure but a design opportunity; maintenance and design are complementary, and some problems are design problems.

**Redesign Options.** Redesign options include: eliminate the failure mode (remove the component that fails, or change the function so it is not needed), reduce the failure rate (a more reliable component, a different technology), reduce the consequence (a guard, a secondary containment, an interlock), or add redundancy (a standby that takes over on failure). The choice depends on the cost, the feasibility, and the consequence. A cost-benefit analysis compares the redesign cost to the avoided failure cost over the asset''s life.

**Integration with RCM.** Design-out is part of RCM, not separate from it: the RCM analysis identifies the failure modes that maintenance cannot address, and the redesign is the action. After the redesign, the RCM is re-analyzed for the new design (new failure modes, new tasks). The RCM and the design team collaborate; the RCM provides the data (which failures recur, what the consequence is), and the design team provides the solution (the redesign). Without the integration, the maintenance team struggles with failures the design team could have fixed.

**When Not to Redesign.** Not every recurring failure warrants redesign: if the maintenance cost is less than the redesign cost and the consequence is acceptable, continue the maintenance. The redesign is justified when the maintenance cost (over the life) plus the residual failure cost exceeds the redesign cost, or when the consequence is unacceptable (safety, environmental) regardless of cost. A redesign that is not justified by cost or consequence is gold-plating.

## Best Practices

- Use redesign when no maintenance task can reduce the failure consequence to an acceptable level.
- Use redesign when a failure mode recurs despite the maintenance; the maintenance is not working, and the design is the root cause.
- Evaluate redesign options (eliminate, reduce rate, reduce consequence, add redundancy) with a cost-benefit analysis.
- Re-analyze the RCM after the redesign for new failure modes and tasks.
- Do not redesign when the maintenance cost is less than the redesign cost and the consequence is acceptable; that is gold-plating.

## Common Pitfalls

- **Continuing maintenance on a design problem** wastes effort on failures the design team could fix.
- **Redesigning without cost-benefit** gold-plates the asset with unnecessary cost.
- **No re-analysis after redesign** leaves new failure modes unaddressed.
- **Maintenance and design teams not collaborating** leaves the maintenance team struggling with design problems.
- **Redesign as a first resort** before analyzing the maintenance options misses cheaper solutions.

## Real-World Example

A plant had a pump that failed its seal every 6 months despite scheduled seal replacement. The RCM analysis found the failure mode was cavitation from a design issue (the suction piping was undersized). Maintenance could not fix it; the redesign (enlarging the suction piping) eliminated the cavitation and the seal failures. After the redesign, the seal replacement interval extended to 3 years. The maintenance team had been treating a design problem; the redesign fixed it.

## Knowledge Check

Review the design-out decision, the redesign options, the integration with RCM, and the when-not-to-redesign criteria before the quiz.',
  45,
  2,
  '[
    {"question":"When is redesign indicated in RCM?","options":["Always","When no maintenance task can reduce the failure consequence to an acceptable level","Never","When the maintenance is cheap"],"answer":1,"explanation":"Redesign is the last resort in the task selection tree, used when maintenance cannot achieve the required reliability."},
    {"question":"What is a key indicator that a failure is a design problem?","options":["The maintenance is cheap","The failure mode recurs despite the maintenance","The pump is new","The operator is trained"],"answer":1,"explanation":"Recurrent failure despite correct maintenance indicates the design is the root cause and redesign is needed."},
    {"question":"What are the redesign options?","options":["Only replacement","Eliminate the mode, reduce the rate, reduce the consequence, or add redundancy","Only add redundancy","Only eliminate"],"answer":1,"explanation":"Redesign can eliminate the failure, reduce its rate, reduce its consequence, or add redundancy; the choice depends on cost and feasibility."},
    {"question":"What must be done after a redesign?","options":["Nothing","Re-analyze the RCM for the new design\u2019s new failure modes and tasks","Replace the pump","Increase maintenance"],"answer":1,"explanation":"A new design has new failure modes; the RCM must be re-analyzed to address them."},
    {"question":"When is redesign NOT justified?","options":["When the consequence is unacceptable","When the maintenance cost is less than the redesign cost and the consequence is acceptable","Always","When the failure recurs"],"answer":1,"explanation":"If maintenance is cheaper than redesign and the consequence is acceptable, continuing maintenance is correct; redesigning is gold-plating."},
    {"question":"What was the root cause of the pump\u2019s recurrent seal failures in the example?","options":["Bad seals","Cavitation from undersized suction piping (a design issue)","Operator error","Bad maintenance"],"answer":1,"explanation":"The cavitation from undersized piping was a design problem; enlarging the piping eliminated the cavitation and the seal failures."},
    {"question":"Why must maintenance and design teams collaborate?","options":["To reduce headcount","The RCM provides the failure data; the design team provides the redesign solution","To increase cost","It is not necessary"],"answer":1,"explanation":"Without collaboration, the maintenance team struggles with failures the design team could fix; together they address design problems with data."}
  ]'::jsonb);

  -- Add module 3: RCM Program Sustainment & Advanced Topics
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'RCM Program Sustainment & Advanced Topics', 3) RETURNING id INTO m_id;

  -- Module 3, Lesson 1: RCM Program Sustainment & Cultural Adoption
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'RCM Program Sustainment & Cultural Adoption', '## Overview

An RCM program that is built but not sustained decays. Sustainment is the harder half of RCM: keeping the program alive over years, through staff turnover, budget pressures, and changing priorities. This lesson covers the organizational practices that sustain an RCM program, the cultural adoption that makes it the way work is done, and the metrics that prove the program is alive.

## Key Concepts

**Organizational Practices.** Sustainment requires: a named program owner (the RCM lead), a cross-functional team that meets regularly (monthly or quarterly), a budget for the program (analyst time, condition monitoring, testing), and management support that protects the program during budget pressure. Without a named owner, the program loses its champion when the original team moves on. Without management support, the program is the first cut when budgets tighten — and the avoided failures that would have justified it are invisible because they did not happen.

**Cultural Adoption.** RCM becomes effective when it is the way maintenance is done, not a separate project. This requires: training the maintenance and operations teams on RCM principles, integrating RCM into the work management (every PM has an RCM basis, every failure triggers an RCM review), and celebrating the avoided failures (the program''s wins). A program that is a separate exercise from the daily work is a program that decays; a program that is integrated into the daily work is a program that sustains.

**Metrics for Sustainment.** Measure the program''s health: PM compliance, the finding rate, the avoided-failure rate, the cost vs. savings, and the program activity (how many RCM reviews were done this year, how many tasks were updated). A program whose activity metrics drop is a program that is decaying, even if the reliability metrics still look good (from the prior work). Review the metrics quarterly with management; a program that is not reviewed is a program that is forgotten.

**The Living Program.** The program evolves: new assets are analyzed, failures feed back into the analysis, and tasks are updated. The RCM lead owns this evolution; without an owner, the program is a snapshot that decays. The living program is the goal; the one-time analysis is the start, not the end.

## Best Practices

- Assign a named RCM lead to own the program; without an owner, the program loses its champion.
- Secure a budget and management support; protect the program during budget pressure with the avoided-failure data.
- Integrate RCM into the daily work (every PM has an RCM basis, every failure triggers a review); a separate program decays.
- Train the teams on RCM principles; celebrate the avoided failures to build cultural adoption.
- Measure program activity (reviews, task updates) and reliability metrics; review quarterly with management.

## Common Pitfalls

- **No named owner** loses the program when the original team moves on.
- **No budget or management support** makes the program the first cut when budgets tighten.
- **RCM as a separate project** decays because it is not integrated into the daily work.
- **No celebration of avoided failures** leaves the program\u2019s wins invisible, inviting budget cuts.
- **Activity metrics not measured** hides the decay before the reliability metrics show it.

## Real-World Example

A plant built an RCM program with a named lead, a monthly team meeting, and a budget. When a recession cut budgets, the program was protected because the avoided-failure data showed $2M in prevented downtime the prior year. The program survived the cut and continued, while a peer plant without the data lost its program. The avoided-failure measurement, not the analysis, had saved the program.

## Knowledge Check

Review the organizational practices (named owner, budget, management support), cultural adoption (integration into daily work, celebration), and the sustainment metrics before the quiz.',
  45,
  1,
  '[
    {"question":"What is the harder half of RCM?","options":["The analysis","Sustainment \u2014 keeping the program alive over years","The FMEA","The CMMS"],"answer":1,"explanation":"Building the program is the start; sustaining it through turnover, budget pressure, and changing priorities is the harder half."},
    {"question":"What is essential for sustainment?","options":["A bigger CMMS","A named program owner, a budget, and management support","More sensors","A new vendor"],"answer":1,"explanation":"Without a named owner, budget, and management support, the program loses its champion and is cut when budgets tighten."},
    {"question":"How does RCM become the way work is done?","options":["As a separate project","By integrating into daily work (every PM has an RCM basis, every failure triggers a review)","By mandate only","By hiring more people"],"answer":1,"explanation":"A program integrated into the daily work sustains; a separate project decays because it is not part of how work is done."},
    {"question":"What saved the plant\u2019s RCM program during the budget cut?","options":["A bigger budget","The avoided-failure data showing $2M in prevented downtime","A new vendor","Luck"],"answer":1,"explanation":"The avoided-failure measurement proved the program\u2019s value; the data, not the analysis, protected the program from the cut."},
    {"question":"Why celebrate avoided failures?","options":["To increase headcount","To make the program\u2019s wins visible, building cultural adoption and protecting against budget cuts","To reduce cost","It is not necessary"],"answer":1,"explanation":"Avoided failures are invisible (they did not happen); celebrating them makes the wins visible and builds support for the program."},
    {"question":"What do activity metrics (reviews, task updates) reveal?","options":["The cost","The decay before the reliability metrics show it","The vendor","The headcount"],"answer":1,"explanation":"Dropping activity (fewer reviews, fewer task updates) signals decay before the reliability metrics (which reflect prior work) decline."},
    {"question":"How often should program metrics be reviewed with management?","options":["Never","Quarterly","Every 10 years","Only at project launch"],"answer":1,"explanation":"Quarterly review keeps the program visible to management and drives continued support and improvement."}
  ]'::jsonb);

  -- Module 3, Lesson 2: RCM in the Digital Age: Predictive Analytics & Digital Twins
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'RCM in the Digital Age: Predictive Analytics & Digital Twins', '## Overview

The digital age is extending RCM with predictive analytics and digital twins. Predictive analytics uses data (condition monitoring, process data, failure history) to predict failure; digital twins simulate the asset to test maintenance strategies and predict performance. These tools augment RCM, they do not replace the principles. This lesson covers predictive analytics for RCM, digital twins for maintenance strategy, and the realistic integration of these tools.

## Key Concepts

**Predictive Analytics for RCM.** Predictive analytics applies ML and statistical models to condition and process data to predict failure before it occurs. For rotating equipment, vibration spectra and oil analysis predict bearing and gear failures; for electrical equipment, thermography predicts connection failures; for process equipment, deviation from normal operation predicts degradation. The prediction produces a remaining useful life (RUL) estimate and an alert before the failure, enabling a planned intervention instead of a reactive one. The prediction is probabilistic, not certain; the alert threshold balances false alarms (too sensitive) against missed predictions (too insensitive).

**Digital Twins for Maintenance Strategy.** A digital twin is a simulation of the asset that can test maintenance strategies before implementing them. The twin models the asset''s degradation (wear, fatigue, corrosion) under the operating conditions, and the maintenance strategy (time-based, condition-based) is simulated to compare the reliability and cost outcomes. The twin lets the team ask "what if we extend the interval?" or "what if we switch to condition-based?" without risking the real asset. The twin is most valuable for high-consequence assets where a strategy change is risky to test in production.

**Integration with RCM.** Predictive analytics and digital twins augment RCM: the analytics provide the data (which failures are approaching, what the RUL is), and the RCM provides the framework (what to do about it — the task selection). Without the RCM framework, the analytics produce alerts no one acts on; without the analytics, the RCM relies on less timely data. The two together produce a program that predicts and acts, not one that reacts.

**Realistic Limits.** Predictive analytics require substantial clean data to train on and a clear problem (which failure mode, which signals). Digital twins require a validated model (the twin must match the real asset''s behavior). Both require a human to act on the output. Analytics and twins that produce insights no one acts on are decoration. The RCM principles remain the foundation; the digital tools augment them where the data and the problem justify the investment.

## Best Practices

- Apply predictive analytics to high-criticality assets where the failure is predictable and the data is available; not every asset justifies the investment.
- Use digital twins for high-consequence assets to test maintenance strategies before implementing them in production.
- Integrate analytics and twins with the RCM framework; analytics predict, RCM decides the task.
- Ensure the data is clean and the problem is clear; analytics without a clear problem produce interesting but useless results.
- Act on the output; analytics and twins that produce insights no one acts on are decoration.

## Common Pitfalls

- **Analytics without the RCM framework** produces alerts no one acts on.
- **Analytics on every asset** wastes investment on assets that do not justify the data and modeling cost.
- **Digital twins without validation** produce predictions that do not match the real asset.
- **No clear problem statement** for analytics produces interesting but useless results.
- **Insights no one acts on** are decoration, not a program.

## Real-World Example

A plant applied predictive analytics to its critical pumps, using vibration spectra and oil analysis to predict bearing and seal failures. The analytics produced RUL estimates and alerts 2–4 weeks before failure, enabling planned rebuilds instead of reactive ones. The RCM framework provided the task (rebuild on alert, with the procedure and parts ready); the analytics provided the timing. Together, they reduced unplanned pump downtime 60%. Neither could have achieved it alone: analytics without RCM is alerts without action; RCM without analytics is timely data without prediction.

## Knowledge Check

Review predictive analytics for RCM, digital twins for maintenance strategy, the integration with the RCM framework, and the realistic limits before the quiz.',
  45,
  2,
  '[
    {"question":"What does predictive analytics provide for RCM?","options":["A replacement for RCM","Failure predictions and RUL estimates, enabling planned intervention","A new CMMS","A digital twin"],"answer":1,"explanation":"Analytics predict failure before it occurs, producing RUL and alerts; the RCM framework decides the task in response."},
    {"question":"What is a digital twin used for in maintenance?","options":["Replacing the asset","Testing maintenance strategies before implementing them in production","Replacing the CMMS","Replacing the operator"],"answer":1,"explanation":"The twin simulates the asset to compare strategy outcomes (reliability, cost) without risking the real asset."},
    {"question":"How do predictive analytics and RCM integrate?","options":["They are unrelated","Analytics predict; RCM decides the task \u2014 together they produce a program that predicts and acts","Analytics replaces RCM","RCM replaces analytics"],"answer":1,"explanation":"Without RCM, analytics are alerts without action; without analytics, RCM has less timely data. Together they predict and act."},
    {"question":"What do predictive analytics require to be useful?","options":["Nothing","Substantial clean data and a clear problem (which failure mode, which signals)","A new HMI","More operators"],"answer":1,"explanation":"Analytics need clean data and a clear problem; without these, they produce interesting but useless results."},
    {"question":"What is the alert threshold trade-off in predictive analytics?","options":["No trade-off","False alarms (too sensitive) vs. missed predictions (too insensitive)","Cost vs. speed","Security vs. usability"],"answer":1,"explanation":"The threshold balances false alarms against missed predictions; both extremes are failures of the analytics."},
    {"question":"What did the plant\u2019s analytics and RCM achieve together in the example?","options":["No change","60% reduction in unplanned pump downtime via planned rebuilds from 2\u20134 week RUL alerts","More failures","Higher cost"],"answer":1,"explanation":"Analytics provided the 2\u20134 week warning; RCM provided the rebuild task; together they cut unplanned downtime 60%."},
    {"question":"What is a realistic limit of digital twins?","options":["They are free","The twin must be validated to match the real asset\u2019s behavior","They replace the operator","They are illegal"],"answer":1,"explanation":"An unvalidated twin produces predictions that do not match the real asset; validation is essential before trusting the twin."}
  ]'::jsonb);

END $$;