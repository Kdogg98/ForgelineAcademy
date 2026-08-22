DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Alarm Management & Rationalization';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lessons
  UPDATE lessons SET content = '## Overview

An alarm philosophy document is the foundation of a well-managed alarm system. ISA 18.2 (the international standard for alarm management) requires a philosophy document that defines the alarm system''s purpose, design principles, and performance targets. Without it, every project and every engineer imposes their own alarm practices, and the alarm system floods the operator. This lesson covers the ISA 18.2 standard, the philosophy document''s contents, and the rationalization process that produces a manageable alarm system.

## Key Concepts

**ISA 18.2.** ISA 18.2 is the international standard for the management of alarm systems in the process industries. It defines the alarm management lifecycle: philosophy, identification, rationalization, detailed design, implementation, operation, maintenance, monitoring, and assessment. The standard requires a philosophy document, a rationalization process, and performance monitoring against defined targets. Compliance to ISA 18.2 is increasingly expected by regulators and insurers.

**The Philosophy Document.** The philosophy document defines: the purpose of the alarm system (to alert the operator to abnormal conditions requiring action), the alarm principles (every alarm requires an operator action, alarms are not used for normal status or for events that require no action), the priority scheme (Emergency, High, Medium, Low — with definitions, not just labels), the performance targets (the alarm rate per operator per 10 minutes, the percentage of time in alarm, the stale alarm threshold), and the procedures for alarm changes (who can add, modify, retire an alarm, with what approval). The philosophy is the contract for the alarm system; without it, the system is unmanaged.

**Rationalization.** Rationalization is the process of reviewing every alarm against the philosophy: does it require an operator action? Is it the right priority? Is the alarm limit correct? Is the description clear? Rationalization is done by a cross-functional team (engineering, operations, maintenance) and produces a documented decision for each alarm: keep, modify (change priority or limit), or retire. The goal is a manageable alarm system where every alarm is necessary, unique, and actionable. Rationalization is not a one-time event; the alarm system is re-rationalized periodically and after significant changes.

**Performance Targets.** ISA 18.2 defines performance targets: an average alarm rate of no more than 1 alarm per operator per 10 minutes (normal operation), no more than 10 per 10 minutes (upset), and a maximum of 10 standing alarms. These targets are measurable; a system that exceeds them floods the operator and is re-rationalized. The targets are the measure of a well-managed system; without them, "too many alarms" is a matter of opinion.

## Best Practices

- Write and approve an alarm philosophy document per ISA 18.2 before rationalization.
- Define the purpose, principles, priority scheme, performance targets, and change procedures in the philosophy.
- Rationalize every alarm with a cross-functional team; document keep/modify/retire decisions.
- Measure performance against ISA 18.2 targets (1 alarm/10 min normal, 10 upset, 10 standing); re-rationalize if exceeded.
- Re-rationalize periodically and after significant changes; rationalization is not a one-time event.

## Common Pitfalls

- **No philosophy document** means every project imposes its own alarm practices, flooding the operator.
- **Alarms for normal status or no-action events** flood the operator and train them to ignore alarms.
- **No rationalization** leaves the alarm system as it was built, with unnecessary and duplicate alarms.
- **No performance targets** means "too many alarms" is unmeasurable and unactionable.
- **One-time rationalization** decays as changes add alarms without review.

## Real-World Example

A plant had no alarm philosophy and 4,000 configured alarms, of which 1,200 were active during normal operation — far exceeding the ISA 18.2 target. After writing a philosophy, rationalizing (retiring 1,800 alarms that required no action, modifying 600 for priority or limit), and monitoring against the targets, the normal-operation alarm rate dropped to 0.5 per 10 minutes, and the operators could identify and act on the meaningful alarms. The philosophy and the rationalization, not the technology, had been the fix.

## Knowledge Check

Review the ISA 18.2 lifecycle, the philosophy document contents, the rationalization process, and the performance targets before the quiz.',
  quiz = '[
    {"question":"What does ISA 18.2 require as the foundation of an alarm system?","options":["More alarms","An alarm philosophy document defining purpose, principles, priorities, targets, and change procedures","Better hardware","No documentation"],"answer":1,"explanation":"The philosophy document is the contract for the alarm system; ISA 18.2 requires it before rationalization."},
    {"question":"What is the purpose of an alarm per ISA 18.2?","options":["To show normal status","To alert the operator to an abnormal condition requiring action","To log events","To decorate the HMI"],"answer":1,"explanation":"Every alarm requires an operator action; alarms for normal status or no-action events flood the operator and are not alarms."},
    {"question":"What is rationalization?","options":["Adding more alarms","Reviewing every alarm against the philosophy with a cross-functional team, deciding keep/modify/retire","Removing all alarms","Changing the HMI colors"],"answer":1,"explanation":"Rationalization produces a documented decision for each alarm, creating a manageable system where every alarm is necessary, unique, and actionable."},
    {"question":"What is the ISA 18.2 target for average alarm rate in normal operation?","options":["10 per 10 minutes","1 alarm per operator per 10 minutes","100 per 10 minutes","No limit"],"answer":1,"explanation":"The target is \u22641 alarm per operator per 10 minutes in normal operation; \u226410 in upset; exceeding these floods the operator."},
    {"question":"Why is rationalization not a one-time event?","options":["It is too expensive","Changes add alarms without review; periodic re-rationalization keeps the system manageable","It is not needed","It is illegal"],"answer":1,"explanation":"The alarm system decays as changes add alarms; periodic re-rationalization maintains the manageable state."},
    {"question":"What did the philosophy and rationalization achieve in the example?","options":["More alarms","Normal-operation alarm rate dropped from 1,200 to 0.5 per 10 minutes","No change","Fewer operators"],"answer":1,"explanation":"Retiring 1,800 no-action alarms and modifying 600 brought the rate within the ISA 18.2 target, making meaningful alarms actionable."},
    {"question":"Who should perform rationalization?","options":["A single engineer","A cross-functional team (engineering, operations, maintenance)","The vendor only","The operator only"],"answer":1,"explanation":"A cross-functional team catches alarms that one discipline would miss (e.g., an action that operations knows is unnecessary)."}
  ]'::jsonb
  WHERE title = 'Alarm Philosophy & Rationalization' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

Nuisance alarms and KPI monitoring are the operational side of alarm management. A rationalized alarm system decays without monitoring: new alarms are added, alarm limits drift, and nuisance alarms return. KPI monitoring makes the decay visible and drives corrective action. This lesson covers the types of nuisance alarms, the alarm KPIs that reveal them, and the corrective actions that sustain a manageable alarm system.

## Key Concepts

**Types of Nuisance Alarms.** A chattering alarm annunciates and clears repeatedly (e.g., a level alarm near the limit); it floods the alarm summary and hides meaningful alarms. A stale alarm stays annunciated for an extended period (e.g., a sensor failed and the alarm never clears); it trains the operator to ignore it. A duplicate alarm is multiple alarms for the same condition (e.g., a high level alarm and a high-high level alarm at the same limit); it wastes the operator''s attention. A no-action alarm annunciates but requires no operator action; it is not an alarm per the philosophy and should be retired. Each nuisance type has a characteristic KPI signature.

**Alarm KPIs.** The key KPIs: the average alarm rate per operator per 10 minutes (vs. the ISA 18.2 target), the peak alarm rate during upsets, the percentage of time in alarm, the top 10 most frequent alarms (chattering candidates), the top 10 longest-standing alarms (stale candidates), and the percentage of alarms that are priority-1 (if too high, priority inflation). Monitor these KPIs continuously; a KPI that trends wrong signals decay. The top 10 lists are the most actionable — they name the specific alarms to fix.

**Corrective Actions.** For chattering alarms: add deadband or delay to stop the chatter, or fix the process (the level control that drives the oscillation). For stale alarms: fix the condition (the failed sensor) or retire the alarm if it no longer applies. For duplicate alarms: consolidate or differentiate the limits. For no-action alarms: retire them per the philosophy. Each corrective action is documented and tracked; the KPI is re-measured after the action to confirm the fix.

**Sustaining the System.** The alarm system is sustained by continuous KPI monitoring, periodic rationalization, and a change-control process that prevents uncontrolled alarm addition. Monitor the KPIs monthly; review the top 10 lists; act on the worst offenders; re-rationalize when the KPIs exceed the targets. A change-control process requires approval for new alarms, ensuring they meet the philosophy before they are added. Without these, the rationalized system decays within months.

## Best Practices

- Monitor alarm KPIs continuously: average and peak rate, percentage of time in alarm, top 10 frequent and longest-standing, priority distribution.
- Act on the top 10 lists: chattering alarms (deadband/delay or process fix), stale alarms (fix or retire), duplicates (consolidate or differentiate).
- Retire no-action alarms per the philosophy; they are not alarms.
- Review KPIs monthly; re-rationalize when KPIs exceed the ISA 18.2 targets.
- Enforce a change-control process for new alarms to prevent uncontrolled addition and decay.

## Common Pitfalls

- **No KPI monitoring** lets nuisance alarms return unnoticed.
- **Acting on the average only** misses the top offenders; the top 10 lists are the actionable targets.
- **Fixing the symptom, not the cause** (deadband on a chattering alarm without fixing the process) lets the chatter return.
- **No change control** lets new alarms accumulate and decay the rationalized system.
- **One-time rationalization** decays within months without monitoring and re-rationalization.

## Real-World Example

A plant''s alarm KPIs showed a top-10 frequent alarm that chattered 300 times per day, flooding the alarm summary. The cause was a level control oscillation that drove the level across the alarm limit. Adding a deadband reduced the chatter, but the oscillation continued. After tuning the level controller, the oscillation stopped and the alarm annunciated only on real level changes — 5 times per week, not 300 per day. The process fix, not just the deadband, had been the real corrective action.

## Knowledge Check

Review the nuisance alarm types, the alarm KPIs (especially the top 10 lists), the corrective actions, and the sustainment practices before the quiz.',
  quiz = '[
    {"question":"What is a chattering alarm?","options":["An alarm that never clears","An alarm that annunciates and clears repeatedly, flooding the alarm summary","A high-priority alarm","A retired alarm"],"answer":1,"explanation":"Chattering alarms repeat rapidly, hiding meaningful alarms; the fix is deadband/delay and often a process fix."},
    {"question":"What is a stale alarm?","options":["An alarm that annunciates once","An alarm that stays annunciated for an extended period, training the operator to ignore it","A new alarm","A retired alarm"],"answer":1,"explanation":"Stale alarms persist; the fix is to address the condition (a failed sensor) or retire the alarm if it no longer applies."},
    {"question":"Which KPI lists are the most actionable?","options":["The average only","The top 10 most frequent and longest-standing alarms","The total alarm count","The priority distribution only"],"answer":1,"explanation":"The top 10 lists name the specific alarms to fix; the average is a summary, not an action target."},
    {"question":"What is the corrective action for a no-action alarm?","options":["Add deadband","Retire it per the philosophy \u2014 it is not an alarm","Change its priority","Add a delay"],"answer":1,"explanation":"A no-action alarm annunciates but requires no action; per the philosophy, it is not an alarm and should be retired."},
    {"question":"Why monitor KPIs monthly and re-rationalize when targets are exceeded?","options":["To increase alarm count","To catch decay early and restore the manageable system before it floods the operator","To slow the system","It is not necessary"],"answer":1,"explanation":"Monthly monitoring catches decay early; re-rationalization restores the system before nuisance alarms flood the operator."},
    {"question":"What was the real fix for the chattering alarm in the example?","options":["More deadband","Tuning the level controller that caused the oscillation","A new HMI","Retiring the alarm"],"answer":1,"explanation":"The deadband reduced the chatter, but tuning the level controller stopped the oscillation that caused it \u2014 the process fix was the real action."},
    {"question":"Why enforce change control for new alarms?","options":["To slow projects","To prevent uncontrolled alarm addition that decays the rationalized system","To increase cost","It is not necessary"],"answer":1,"explanation":"Change control ensures new alarms meet the philosophy before they are added, preventing the decay that uncontrolled addition causes."}
  ]'::jsonb
  WHERE title = 'Nuisance Alarms & KPI Monitoring' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2 with 2 lessons
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Alarm System Design', 2) RETURNING id INTO m_id;

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Alarm Suppression, Shelving & State-Based Alarming', '## Overview

Alarm suppression, shelving, and state-based alarming are the advanced techniques that handle the reality of industrial processes: not all alarms are relevant in all operating states, and during upsets the alarm flood must be managed. ISA 18.2 defines these techniques to keep the alarm system meaningful during the conditions when it matters most. This lesson covers alarm suppression and shelving, state-based alarming, and the design and audit considerations for their use.

## Key Concepts

**Alarm Suppression.** Alarm suppression temporarily hides an alarm that is not relevant in the current operating state. For example, a low-flow alarm on a pump is suppressed when the pump is stopped (the low flow is expected, not abnormal). Suppression is state-driven (the pump state determines the suppression) and documented (the suppression logic is part of the alarm design, not an ad hoc operator action). Suppression that is not documented or not state-driven is dangerous — it hides alarms that should be visible. ISA 18.2 requires that suppression be deliberate, documented, and auditable.

**Alarm Shelving.** Alarm shelving is an operator-initiated, temporary suppression of a nuisance alarm, with a time limit and a reason. Shelving is used for a chattering or stale alarm that is being investigated or repaired; the operator shelves it to stop the flood while the fix is in progress, and it auto-unshelves after the time limit. Shelving is logged (who, when, why, how long) and reviewed; a shelved alarm that is never unshelved is a hidden problem. Shelving is a tool for managing a known nuisance, not for hiding a problem.

**State-Based Alarming.** State-based alarming changes the active alarm set based on the process state. For example, during startup, certain alarms are suppressed (the conditions are expected during the transient) and others are added (startup-specific limits). During normal operation, the normal alarm set is active. During shutdown, a different set applies. State-based alarming requires a defined state machine (the process states and transitions) and a documented alarm set per state. It prevents the startup from flooding the operator with alarms that are expected during the transient.

**Design and Audit.** Suppression, shelving, and state-based alarming are powerful and dangerous: they hide alarms, and a hidden alarm that should be visible is a safety issue. Design them deliberately (state-driven, documented logic), audit them periodically (which alarms are suppressed in which states, are the suppressions still valid), and log all operator shelving for review. The audit confirms that suppression hides only irrelevant alarms, not problems; the review catches shelved alarms that were never unshelved.

## Best Practices

- Use state-driven, documented alarm suppression for alarms not relevant in the current operating state.
- Use operator-initiated alarm shelving with a time limit, reason, and log for known nuisance alarms under investigation.
- Use state-based alarming with a defined state machine and a documented alarm set per process state.
- Audit suppression periodically to confirm suppressed alarms are still irrelevant; review shelving logs for unshelved alarms.
- Design suppression and shelving deliberately; a hidden alarm that should be visible is a safety issue.

## Common Pitfalls

- **Undocumented suppression** hides alarms that should be visible, with no record of what is hidden or why.
- **Shelving without a time limit** lets alarms stay hidden indefinitely.
- **No state machine** for state-based alarming produces ad hoc, inconsistent alarm sets.
- **No audit** lets suppression decay into hiding problems.
- **Shelving to hide a problem** rather than to manage a known nuisance masks the underlying issue.

## Real-World Example

A plant''s startup flooded the operator with 200 alarms in the first 10 minutes, most of which were expected during the transient (low flows, low pressures as the process came up). After implementing state-based alarming that suppressed the expected alarms during the startup state and added startup-specific limits, the startup alarm rate dropped to 15, and the operator could focus on the unexpected alarms. The state-based design, documented and audited, kept the alarm system meaningful during the most demanding phase.

## Knowledge Check

Review alarm suppression (state-driven, documented), alarm shelving (operator-initiated, time-limited, logged), state-based alarming (state machine, alarm set per state), and the audit and review practices before the quiz.',
  45, 1,
  '[
    {"question":"What is alarm suppression?","options":["Permanently removing an alarm","Temporarily hiding an alarm not relevant in the current operating state, state-driven and documented","Operator shelving","A type of sensor"],"answer":1,"explanation":"Suppression hides irrelevant alarms based on process state; it must be state-driven and documented, not ad hoc."},
    {"question":"What is alarm shelving?","options":["Permanent suppression","Operator-initiated, temporary suppression of a nuisance alarm with a time limit and reason","State-based suppression","A type of priority"],"answer":1,"explanation":"Shelving manages a known nuisance under investigation; it auto-unshelves after the time limit and is logged and reviewed."},
    {"question":"What does state-based alarming require?","options":["No documentation","A defined state machine and a documented alarm set per process state","Operator judgment only","More hardware"],"answer":1,"explanation":"State-based alarming changes the active alarm set by process state; it requires a state machine and a documented alarm set per state."},
    {"question":"Why audit alarm suppression periodically?","options":["To increase suppression","To confirm suppressed alarms are still irrelevant and not hiding problems","To slow the system","It is not necessary"],"answer":1,"explanation":"Suppression can decay into hiding problems; the audit confirms each suppression is still valid."},
    {"question":"What is the danger of shelving without a time limit?","options":["It saves time","Alarms stay hidden indefinitely, masking problems","It improves safety","It is required"],"answer":1,"explanation":"A time limit ensures shelved alarms auto-unshelve; without it, alarms stay hidden and problems are masked."},
    {"question":"What did state-based alarming achieve in the example?","options":["More startup alarms","Startup alarm rate dropped from 200 to 15 by suppressing expected alarms and adding startup-specific limits","No change","Slower startup"],"answer":1,"explanation":"Suppressing expected transient alarms and adding startup-specific ones let the operator focus on unexpected alarms during startup."},
    {"question":"What distinguishes suppression from shelving?","options":["Nothing","Suppression is state-driven and automatic; shelving is operator-initiated and temporary with a time limit","Both are the same","Shelving is permanent"],"answer":1,"explanation":"Suppression is automatic and state-driven; shelving is operator-initiated, time-limited, and logged for review."}
  ]'::jsonb);

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'HMI Design for Alarm Response & Operator Effectiveness', '## Overview

The HMI is the operator''s window into the alarm system, and its design determines whether the operator can detect, diagnose, and respond to alarms effectively. A well-designed HMI presents alarms clearly and in context; a poorly designed one floods the operator with color and noise. This lesson covers the HMI design principles for alarm response, the alarm display hierarchy, and the operator effectiveness measures that make alarms actionable.

## Key Concepts

**HMI Design Principles.** The HMI follows the principle of hierarchy: overview displays show the process at a glance with abnormal conditions highlighted, unit displays show detail, and detail displays show the device level. Alarms are presented consistently (color, sound, priority) across all levels. The HMI uses color sparingly — a gray background with color reserved for abnormal conditions — so that the color stands out. A "Christmas tree" HMI (everything colored) hides alarms in a sea of color; a high-performance HMI (mostly gray, color for the abnormal) makes alarms visible. The ASM (Abnormal Situation Management) Consortium guidelines are the reference for high-performance HMI design.

**The Alarm Display Hierarchy.** The alarm summary shows active alarms in priority order with time, tag, description, and state. The alarm banner (a persistent strip across the top of every display) shows the count of active alarms by priority, so the operator always knows the alarm status without navigating to the summary. The alarm details (on the unit or detail display) show the alarm in process context — the related measurements, the cause, and the response guidance. The hierarchy lets the operator see the alarm status at a glance, drill to the summary for the list, and drill to the context for the response.

**Operator Effectiveness.** An effective alarm system lets the operator detect (the alarm is visible), diagnose (the cause is clear from the context), and respond (the action is known). The response guidance — documented in the alarm''s description or in a linked procedure — tells the operator what to do. An alarm without response guidance is a notification, not an alarm. Train operators on the alarm responses; verify competency, not just attendance. The alarm system and the operator are a team; the system presents, the operator acts.

**High-Performance HMI.** High-performance HMI (per the ASM Consortium) uses a gray background, color reserved for abnormal conditions, minimal animation, and a clear hierarchy. It shows the process state (levels, flows, temperatures) in a way that abnormal conditions are immediately visible without reading every value. It uses deviation bars (showing the value''s distance from normal) and color only for out-of-normal. The high-performance design reduces the operator''s cognitive load and makes alarms stand out, improving detection and response time.

## Best Practices

- Follow the ASM Consortium high-performance HMI guidelines: gray background, color reserved for abnormal, clear hierarchy.
- Use a persistent alarm banner showing active alarm counts by priority on every display.
- Provide response guidance for every alarm (in the description or a linked procedure).
- Train operators on alarm responses; verify competency, not just attendance.
- Use deviation bars and minimal animation to make abnormal conditions immediately visible.

## Common Pitfalls

- **Christmas tree HMIs** (everything colored) hide alarms in a sea of color.
- **No alarm banner** forces the operator to navigate to see the alarm status.
- **Alarms without response guidance** are notifications, not alarms.
- **Untrained operators** cannot respond effectively, even to a well-designed system.
- **Excessive animation** distracts the operator from the abnormal conditions.

## Real-World Example

A plant redesigned its HMI from a "Christmas tree" (every value colored, every alarm red) to a high-performance design (gray background, color for abnormal, alarm banner, deviation bars). After the redesign, operators detected abnormal conditions 40% faster (the color stood out against the gray) and responded more accurately (the response guidance was at hand). The HMI design, not the alarm system, had been the limiting factor in operator effectiveness.

## Knowledge Check

Review the HMI design principles (hierarchy, gray background, color for abnormal), the alarm display hierarchy (summary, banner, details), operator effectiveness (detect, diagnose, respond), and high-performance HMI before the quiz.',
  45, 2,
  '[
    {"question":"What is the high-performance HMI principle?","options":["Color everything","Gray background with color reserved for abnormal conditions, so alarms stand out","Red background","Maximum animation"],"answer":1,"explanation":"High-performance HMI uses mostly gray with color only for abnormal, making alarms immediately visible against the neutral background."},
    {"question":"What does the alarm banner show?","options":["The process flow","A persistent strip with active alarm counts by priority on every display","The vendor name","The operator\u2019s name"],"answer":1,"explanation":"The banner shows alarm counts by priority on every display, so the operator always knows the status without navigating."},
    {"question":"What makes an alarm actionable rather than a notification?","options":["A loud sound","Response guidance (the operator knows what to do)","A red color","A high priority"],"answer":1,"explanation":"An alarm without response guidance is a notification; the guidance (in the description or a linked procedure) makes it actionable."},
    {"question":"What is the ASM Consortium?","options":["A vendor","The reference for high-performance HMI design guidelines","A protocol","A standard for PLC programming"],"answer":1,"explanation":"The Abnormal Situation Management Consortium publishes the high-performance HMI guidelines used in process industries."},
    {"question":"What is a deviation bar?","options":["A type of alarm","A display showing the value\u2019s distance from normal, making abnormal immediately visible","A type of sensor","A network metric"],"answer":1,"explanation":"Deviation bars show how far a value is from normal, so abnormal conditions are visible without reading every number."},
    {"question":"What did the high-performance HMI redesign achieve in the example?","options":["Slower detection","40% faster detection and more accurate response","No change","More alarms"],"answer":1,"explanation":"The gray-background design made alarms stand out; detection was 40% faster and response more accurate with guidance at hand."},
    {"question":"Why train operators on alarm responses and verify competency?","options":["To save time","The system presents, the operator acts; untrained operators cannot respond effectively","To reduce cost","It is not necessary"],"answer":1,"explanation":"Even a well-designed system fails with untrained operators; competency verification ensures they can respond."}
  ]'::jsonb);

  -- Add module 3 with 2 lessons
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Alarm System Lifecycle & Advanced Topics', 3) RETURNING id INTO m_id;

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Alarm System Lifecycle & Continuous Improvement', '## Overview

An alarm system is not built once and left; it has a lifecycle of design, operation, monitoring, and improvement that spans the system''s life. ISA 18.2 defines this lifecycle, and managing it sustains a manageable alarm system over years of changes. This lesson covers the alarm management lifecycle, the roles and responsibilities, and the continuous improvement practices that keep the system effective.

## Key Concepts

**The Alarm Management Lifecycle.** ISA 18.2 defines the lifecycle: philosophy (the foundation), identification (where are alarms needed), rationalization (which alarms, at what priority), detailed design (the alarm logic, HMI, priority), implementation (configure the system), operation (run and monitor), maintenance (fix and adjust), monitoring (measure performance), and assessment (audit and improve). The lifecycle is iterative: monitoring and assessment feed back into rationalization and design. A system that is built but not monitored and improved decays.

**Roles and Responsibilities.** The alarm system has stakeholders: engineering (designs and rationalizes), operations (uses and provides feedback), maintenance (fixes the field devices that drive alarms), and the alarm management team (owns the philosophy, the KPIs, and the improvement cycle). The most common failure is unclear ownership — "who owns the alarm system?" The answer is a named alarm management team, with engineering and operations supporting. Without an owner, the system decays.

**Continuous Improvement.** The continuous improvement cycle: monitor the KPIs monthly, identify the worst offenders (top 10 frequent and longest-standing), analyze the cause (chattering, stale, duplicate, no-action), implement the fix (deadband, process fix, retire), and re-measure the KPI. The cycle repeats monthly; a system that is not cycled decays. The cycle is the operational equivalent of rationalization — it keeps the system manageable between major rationalizations.

**Management of Change for Alarms.** Every alarm change (add, modify, retire) follows management of change: assess the impact on the alarm load and the operator, document the change, approve per the philosophy, and update the rationalization records. Uncontrolled alarm addition is the primary cause of alarm system decay; MOC is the control that prevents it. The MOC process is part of the philosophy and is enforced by the alarm management team.

## Best Practices

- Manage the alarm system per the ISA 18.2 lifecycle: philosophy, rationalization, design, operation, monitoring, assessment.
- Assign a named alarm management team to own the philosophy, KPIs, and improvement cycle.
- Run the continuous improvement cycle monthly: monitor KPIs, identify worst offenders, analyze, fix, re-measure.
- Apply management of change to every alarm change; uncontrolled addition is the primary cause of decay.
- Feed monitoring and assessment back into rationalization and design; the lifecycle is iterative.

## Common Pitfalls

- **No named owner** lets the alarm system decay without anyone responsible.
- **Built but not monitored** systems decay as changes add alarms without review.
- **No continuous improvement cycle** lets nuisance alarms return and persist.
- **No MOC for alarms** lets uncontrolled addition flood the operator.
- **One-time rationalization** decays within months without the lifecycle.

## Real-World Example

A plant rationalized its alarm system and reached the ISA 18.2 targets, but had no named owner and no monitoring. Within a year, changes had added 800 new alarms, and the alarm rate was back above the targets. After assigning an alarm management team, instituting monthly KPI monitoring and the improvement cycle, and enforcing MOC for alarm changes, the system stayed within the targets for the next three years. The owner and the cycle, not the initial rationalization, sustained the system.

## Knowledge Check

Review the ISA 18.2 lifecycle, the named owner, the continuous improvement cycle, and the MOC for alarms before the quiz.',
  45, 1,
  '[
    {"question":"What does the ISA 18.2 alarm management lifecycle include?","options":["Only rationalization","Philosophy, identification, rationalization, design, implementation, operation, maintenance, monitoring, assessment","Only operation","Only design"],"answer":1,"explanation":"The lifecycle spans philosophy through assessment and is iterative; monitoring and assessment feed back into rationalization."},
    {"question":"Who should own the alarm system?","options":["No one","A named alarm management team, with engineering and operations supporting","The vendor","The operator only"],"answer":1,"explanation":"A named owner prevents the decay that occurs when no one is responsible; the team owns the philosophy, KPIs, and cycle."},
    {"question":"What is the continuous improvement cycle?","options":["A one-time rationalization","Monitor KPIs monthly, identify worst offenders, analyze, fix, re-measure \u2014 repeated monthly","Adding more alarms","Ignoring KPIs"],"answer":1,"explanation":"The monthly cycle keeps the system manageable between major rationalizations; without it, nuisance alarms return."},
    {"question":"What is the primary cause of alarm system decay?","options":["Rationalization","Uncontrolled alarm addition without MOC","Monitoring","The philosophy"],"answer":1,"explanation":"Uncontrolled addition adds alarms without review; MOC is the control that prevents it."},
    {"question":"What does management of change for alarms require?","options":["Nothing","Assess impact, document, approve per the philosophy, and update rationalization records","Just do it","Email the operator"],"answer":1,"explanation":"MOC ensures new and modified alarms meet the philosophy before they are added, preventing decay."},
    {"question":"What happened to the plant\u2019s alarm system without an owner?","options":["It improved","800 new alarms were added in a year, and the rate exceeded the targets again","It stayed the same","It was rationalized"],"answer":1,"explanation":"Without an owner and monitoring, uncontrolled changes decayed the system within a year; the owner and the cycle restored and sustained it."},
    {"question":"Why is the lifecycle iterative?","options":["It is too slow","Monitoring and assessment feed back into rationalization and design for continuous improvement","It is not iterative","To reduce cost"],"answer":1,"explanation":"The lifecycle feeds monitoring and assessment back into rationalization and design, sustaining the system over its life."}
  ]'::jsonb);

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Advanced Alarm Analytics & Machine Learning Applications', '## Overview

Advanced alarm analytics and machine learning (ML) are extending alarm management beyond the ISA 18.2 practices, applying data analysis and ML to detect alarm floods, identify nuisance patterns, and predict alarm events. These tools do not replace the discipline of rationalization and KPI monitoring; they augment it, handling the volume and complexity that manual review cannot. This lesson covers alarm analytics, ML applications, and the realistic limits of these technologies.

## Key Concepts

**Alarm Analytics.** Alarm analytics applies data analysis to the alarm history: statistical analysis of alarm rates, frequencies, and durations; clustering to identify alarm patterns (groups of alarms that co-occur); and sequence analysis to identify the first-out in cascades. Analytics turns the alarm event log into actionable insight: the top chattering alarms, the recurring cascade patterns, the alarms that never act. These insights feed the continuous improvement cycle, targeting the worst offenders with data rather than guesswork.

**Machine Learning Applications.** ML applies to alarm management in several ways: anomaly detection (ML learns the normal alarm pattern and alerts on deviations), alarm flood prediction (ML predicts an impending flood from precursor patterns), and alarm clustering (ML groups similar alarms to identify common causes). ML can also classify alarms by likely cause, supporting the operator''s diagnosis. These applications require a substantial alarm history to train on and a clear problem statement; ML without a clear problem produces interesting but useless results.

**First-Out Detection with Analytics.** In a cascade, the first alarm is the cause and the rest are effects. Analytics reconstructs the sequence from the alarm log with precise timestamps and identifies the first-out — the alarm that annunciated first and that is the likely root cause. This is the same first-out principle as in fault handling, applied at the alarm-system level with data rather than latches. The first-out identification guides the operator to the root cause instead of the loudest symptom.

**Realistic Limits.** ML and analytics are tools, not solutions. They require clean data (the alarm log must be accurate and complete), a clear problem statement (what are we predicting or classifying?), and a human to act on the output (the analytics identifies the worst offenders; the team fixes them). ML that produces insights no one acts on is decoration. The discipline of rationalization, KPI monitoring, and the continuous improvement cycle remain the foundation; analytics and ML augment them, they do not replace them.

## Best Practices

- Apply alarm analytics to the alarm history: statistical analysis, clustering, and sequence analysis to identify the worst offenders and cascade patterns.
- Use first-out detection with analytics to guide the operator to the root cause in a cascade.
- Apply ML with a clear problem statement (anomaly detection, flood prediction, clustering) and a substantial training history.
- Ensure the alarm log is accurate and complete; analytics on dirty data produces misleading insights.
- Act on the analytics output; ML that produces insights no one acts on is decoration. The discipline remains the foundation.

## Common Pitfalls

- **Analytics without action** produces insights that change nothing.
- **ML without a clear problem statement** produces interesting but useless results.
- **Dirty alarm data** (inaccurate timestamps, missing events) misleads the analytics.
- **Treating ML as a replacement for discipline** ignores the rationalization and KPI monitoring that sustain the system.
- **No human to act on the output** means the analytics is a report, not a tool.

## Real-World Example

A plant applied alarm analytics to a year of alarm history and found that 5 alarms accounted for 40% of all alarm events — all chattering alarms on level loops with oscillating control. The analytics identified the worst offenders in minutes; the team tuned the 5 level controllers, and the alarm rate dropped 40%. The analytics targeted the fix; the discipline (tuning, rationalization) executed it. Together, they achieved what neither could alone.

## Knowledge Check

Review alarm analytics (statistical, clustering, sequence), ML applications (anomaly detection, flood prediction, clustering), first-out detection, and the realistic limits before the quiz.',
  45, 2,
  '[
    {"question":"What does alarm analytics do?","options":["Adds more alarms","Applies statistical analysis, clustering, and sequence analysis to identify worst offenders and cascade patterns","Replaces rationalization","Decorates the HMI"],"answer":1,"explanation":"Analytics turns the alarm log into actionable insight, targeting the worst offenders with data rather than guesswork."},
    {"question":"What is first-out detection with analytics?","options":["Removing the first alarm","Reconstructing the cascade sequence from timestamps to identify the first (root cause) alarm","Adding more alarms","A type of suppression"],"answer":1,"explanation":"Analytics identifies the first alarm in a cascade as the likely root cause, guiding the operator to it instead of the loudest symptom."},
    {"question":"What does ML require to be useful in alarm management?","options":["Nothing","A clear problem statement and a substantial training history","More hardware","A new HMI"],"answer":1,"explanation":"ML needs a clear problem (anomaly detection, flood prediction) and training data; without these, it produces interesting but useless results."},
    {"question":"What is a realistic limit of analytics and ML?","options":["They replace rationalization","They require clean data, a clear problem, and a human to act on the output","They are too expensive","They are illegal"],"answer":1,"explanation":"Analytics and ML augment the discipline; they need clean data, a clear problem, and action on the output to be useful."},
    {"question":"Why must the alarm log be accurate and complete for analytics?","options":["To increase storage","Analytics on dirty data (inaccurate timestamps, missing events) produces misleading insights","To slow the system","It is not necessary"],"answer":1,"explanation":"Dirty data misleads the analytics; clean, complete alarm logs are the foundation of useful analysis."},
    {"question":"What did the plant\u2019s analytics find in the example?","options":["No pattern","5 chattering alarms accounted for 40% of all alarm events; tuning the level controllers dropped the rate 40%","A new protocol","A missing alarm"],"answer":1,"explanation":"The analytics targeted the 5 worst offenders; the discipline (tuning) executed the fix; together they achieved what neither could alone."},
    {"question":"What is the relationship between analytics/ML and the alarm discipline?","options":["ML replaces the discipline","Analytics and ML augment the discipline; they do not replace rationalization and KPI monitoring","They are unrelated","The discipline replaces ML"],"answer":1,"explanation":"The discipline (rationalization, KPIs, improvement cycle) is the foundation; analytics and ML augment it, handling volume and complexity."}
  ]'::jsonb);
END $$;