DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Functional Safety (ISO 13849 & IEC 61511)';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lesson: Performance Levels & Safety Categories
  UPDATE lessons SET content = '## Overview

ISO 13849 is the standard for safety of machinery, providing a risk-based framework for designing safety-related control systems. Its central concepts — Performance Levels (PL), safety categories (B, 1, 2, 3, 4), and the combination of structure, MTTFd (mean time to dangerous failure), and DC (diagnostic coverage) — translate a machinery risk assessment into a concrete safety control design. This lesson covers the PL determination, the categories, and the design parameters that achieve a required PL.

## Key Concepts

**Performance Levels (PL).** A Performance Level is a discrete level (a–e) representing the reliability of a safety function in the presence of faults. PL a is the lowest (lowest reliability), PL e the highest. The required PL (PLr) is determined by the risk assessment (severity, frequency/exposure, possibility of avoidance). The achieved PL is determined by the design (category, MTTFd, DC). The achieved PL must meet or exceed the PLr. PL is the machinery equivalent of SIL in process safety, but the scales differ.

**Safety Categories.** The category defines the structural behavior of the safety system in the presence of a fault: Category B — basic; a fault can lead to loss of the safety function. Category 1 — well-tried components; a fault can lead to loss but is unlikely. Category 2 — periodic checking; a fault is detected by a test at the next demand. Category 3 — single fault does not cause loss; some faults are detected. Category 4 — single fault does not cause loss, faults are detected, and accumulation of faults does not cause loss. Higher categories require redundancy (categories 3, 4) and diagnostics (categories 2, 3, 4).

**MTTFd and DC.** MTTFd (mean time to dangerous failure) is the average time to a failure that compromises the safety function; higher MTTFd means higher reliability. DC (diagnostic coverage) is the fraction of dangerous failures that are automatically detected; higher DC means more faults are caught. The achieved PL is a combination of category, MTTFd, and DC — a category 3 system with high MTTFd and high DC can achieve PL e, while the same category with low MTTFd and low DC may achieve only PL d. The standard provides tables and calculation methods (the simplified method, the Markov modeling in ISO 13849-1).

**Common Cause Failures.** A common cause failure (CCF) is a single event that defeats multiple redundant channels (a power surge, a common environment, a shared design flaw). Categories 3 and 4 require measures against CCF: separation of channels, diversity, shielding, and the CCF scoring table in the standard. A redundant system with no CCF measures can fail as easily as a single channel.

## Best Practices

- Determine the required PL (PLr) from the risk assessment before designing.
- Choose the category, MTTFd, and DC to achieve a PL that meets or exceeds the PLr.
- Apply common cause failure measures (separation, diversity, shielding) for categories 3 and 4.
- Use well-tried components and well-tried safety principles for categories 1–4.
- Document the PL calculation and the CCF score for auditability.

## Common Pitfalls

- **Designing before determining the PLr** leads to over- or under-engineered safety.
- **Redundancy without CCF measures** can fail as easily as a single channel.
- **Ignoring MTTFd and DC** — category alone does not determine the PL.
- **Using non-well-tried components** in a safety function invalidates the category.
- **No documented calculation** makes the safety function unauditable.

## Real-World Example

A press safety system required PL d (PLr from the risk assessment). The designer chose category 3 (single-fault-tolerant) with redundant light curtains and a safety relay, but used components with low MTTFd and no diagnostics, achieving only PL c. After selecting components with higher MTTFd and adding diagnostic monitoring (DC medium), the system achieved PL d. The category was necessary but not sufficient; MTTFd and DC completed the calculation.

## Knowledge Check

Review the Performance Levels (PLr and achieved PL), the safety categories (B–4) and their fault behavior, the role of MTTFd and DC, and common cause failure measures before the quiz.',
  quiz = '[
    {"question":"What is a Performance Level (PL)?","options":["A speed rating","A discrete level (a–e) representing the reliability of a safety function in the presence of faults","A type of sensor","A safety category"],"answer":1,"explanation":"PL a–e represents the safety function’s reliability under faults; achieved PL must meet or exceed PLr."},
    {"question":"How is the required PL (PLr) determined?","options":["By the designer’s preference","By the risk assessment (severity, frequency/exposure, avoidance)","By the component cost","By the machine speed"],"answer":1,"explanation":"PLr comes from the risk assessment; the design must achieve a PL that meets or exceeds it."},
    {"question":"What does Category 3 guarantee?","options":["No faults ever","A single fault does not cause loss of the safety function; some faults are detected","Automatic recovery","No diagnostics needed"],"answer":1,"explanation":"Category 3 is single-fault-tolerant with some fault detection; category 4 adds full detection and accumulation tolerance."},
    {"question":"What do MTTFd and DC contribute to the achieved PL?","options":["Nothing","They combine with the category to determine the achieved PL","They reduce the PL","They replace the category"],"answer":1,"explanation":"Achieved PL = f(category, MTTFd, DC); a given category can achieve different PLs depending on MTTFd and DC."},
    {"question":"What is a common cause failure (CCF)?","options":["A single-channel failure","A single event that defeats multiple redundant channels","A type of sensor","A diagnostic"],"answer":1,"explanation":"CCF defeats redundancy; categories 3 and 4 require CCF measures (separation, diversity, shielding)."},
    {"question":"Why was the press safety system only PL c initially?","options":["Wrong category","Low MTTFd and no diagnostics, despite category 3","Too many sensors","Wrong PLr"],"answer":1,"explanation":"Category 3 alone was insufficient; low MTTFd and no DC limited the achieved PL until components and diagnostics were improved."},
    {"question":"What must be documented for a safety function under ISO 13849?","options":["Only the PLr","The PL calculation and the CCF score","Only the component list","Only the wiring diagram"],"answer":1,"explanation":"Documenting the PL calculation and CCF score makes the safety function auditable and verifiable."}
  ]'::jsonb
  WHERE title = 'Performance Levels & Safety Categories' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Update existing lesson: SIL Verification & Safety Lifecycle
  UPDATE lessons SET content = '## Overview

IEC 61511 is the standard for safety instrumented systems (SIS) in the process industries, covering the full safety lifecycle from hazard analysis through operation and modification. Where ISO 13849 addresses machinery safety, IEC 61511 addresses process safety — the chemical, oil and gas, and pharmaceutical processes where a safety function must detect a process hazard and drive the process to a safe state. This lesson covers the safety lifecycle, the SIL verification, and the operation and maintenance practices that sustain the SIS.

## Key Concepts

**The Safety Lifecycle.** IEC 61511 defines a lifecycle: process hazard analysis (PHA) identifies the hazards; risk assessment determines the SIL required for each safety function; the Safety Requirements Specification (SRS) defines what each function must do; design implements the SIS; verification confirms the design meets the SRS; validation confirms the installed system meets the SRS; operation and maintenance sustain the SIS; and modification follows the management-of-change process. Each phase has inputs, outputs, and deliverables; skipping a phase produces an unauditable SIS.

**SIL Verification.** SIL verification calculates the achieved PFD (or PFH for high-demand mode) of the designed architecture using failure-rate data, redundancy, voting, common-cause failure (β-factor), and proof-test coverage. The achieved PFD must fall within the SIL range required by the risk assessment (SIL 1: 10⁻²–10⁻¹, SIL 2: 10⁻³–10⁻², SIL 3: 10⁻⁴–10⁻³, SIL 4: 10⁻⁵–10⁻⁴). Verification uses methods from simplified equations to fault tree analysis and Markov modeling, depending on complexity. Use vendor FMEDA data and realistic proof-test coverage; optimistic assumptions understate the PFD.

**Operation and Maintenance.** The SIS must be maintained in its as-designed state: no bypasses without authorization and time limits, no setpoint changes without management of change, and proof testing on schedule. Proof testing exercises the full safety function (sensor, logic solver, final element) to detect dangerous failures that accumulate between tests; the proof-test interval is part of the SIL calculation, so stretching it invalidates the SIL. Bypasses are logged and reviewed; a forgotten bypass is a silent safety failure.

**Management of Change.** Any change to the SIS (a setpoint, a component, a logic change) follows management of change: assess the impact on the SIL, re-verify if needed, document and approve, and update the SRS. The most common SIS failure is an undocumented change that silently degrades the safety function — a setpoint changed to avoid nuisance trips, a redundant channel bypassed for "convenience," a proof test deferred. MOC is the control that prevents this decay.

## Best Practices

- Follow the safety lifecycle: PHA, risk assessment, SRS, design, verification, validation, operation, MOC.
- Verify the achieved PFD against the required SIL using vendor FMEDA data and realistic proof-test coverage.
- Proof test on the schedule assumed in the SIL calculation; stretching the interval invalidates the SIL.
- Log and review all bypasses with time limits; a forgotten bypass is a silent safety failure.
- Apply management of change to every SIS change; re-verify the SIL if the change affects it.

## Common Pitfalls

- **Skipping lifecycle phases** produces an unauditable SIS with unknown risk.
- **Optimistic proof-test coverage** in verification understates the achieved PFD.
- **Stretched proof-test intervals** invalidate the SIL calculation.
- **Forgotten bypasses** silently disable safety functions.
- **Undocumented changes** degrade the SIS without re-verification.

## Real-World Example

A refinery SIS function was SIL 2 with a 2-year proof-test interval. Operations had deferred the proof test for 18 months due to production pressure, and a redundant transmitter had been bypassed for 6 months to avoid a nuisance trip. A later review found that the achieved PFD had degraded from SIL 2 to below SIL 1 — the safety function no longer met its risk target. After restoring the proof-test schedule and removing the bypass, the function returned to SIL 2. The deferral and the bypass had silently undone the design.

## Knowledge Check

Review the safety lifecycle phases, SIL verification with FMEDA data and proof-test coverage, the proof-test interval''s role in the SIL, bypass logging, and management of change before the quiz.',
  quiz = '[
    {"question":"What is the first phase of the IEC 61511 safety lifecycle?","options":["SIL verification","Process hazard analysis (PHA)","Operation","Management of change"],"answer":1,"explanation":"PHA identifies the hazards; risk assessment then determines the SIL for each safety function."},
    {"question":"What does SIL verification calculate?","options":["The cost of the SIS","The achieved PFD of the designed architecture using failure-rate data, redundancy, voting, and proof-test coverage","The operator response time","The number of sensors"],"answer":1,"explanation":"Verification computes the achieved PFD and confirms it meets the required SIL range."},
    {"question":"What happens if the proof-test interval is stretched?","options":["Nothing","The SIL calculation is invalidated because the interval is part of the PFD calculation","The SIL improves","The cost decreases"],"answer":1,"explanation":"The proof-test interval is in the PFD calculation; stretching it increases the PFD and may drop the achieved SIL."},
    {"question":"How should SIS bypasses be managed?","options":["Left in place indefinitely","Logged and reviewed with time limits; a forgotten bypass is a silent safety failure","Never used","Hidden from operators"],"answer":1,"explanation":"Bypasses are authorized, time-limited, logged, and reviewed; forgotten bypasses silently disable safety."},
    {"question":"What does management of change (MOC) require for an SIS change?","options":["Nothing","Assess SIL impact, re-verify if needed, document, approve, and update the SRS","Just do it","Email the operator"],"answer":1,"explanation":"MOC controls SIS changes so they do not silently degrade the safety function; re-verify the SIL if affected."},
    {"question":"What degraded the refinery SIS function in the example?","options":["A firmware bug","A deferred proof test and a long-standing bypass, dropping the achieved PFD below SIL 1","A missing sensor","A bad cable"],"answer":1,"explanation":"The 18-month deferral and 6-month bypass increased the PFD, dropping the function below its SIL 2 target."},
    {"question":"What PFD range corresponds to SIL 2 (low-demand mode)?","options":["10⁻¹ to 10⁰","10⁻³ to 10⁻²","10⁻⁴ to 10⁻³","10⁻⁵ to 10⁻⁴"],"answer":1,"explanation":"SIL 2 = PFD 10⁻³ to 10⁻²; the achieved PFD must fall within the required SIL’s range."}
  ]'::jsonb
  WHERE title = 'SIL Verification & Safety Lifecycle' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add new module (sort_order 3)
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Safety System Design & Implementation', 3) RETURNING id INTO m_id;

  -- Lesson 1: Safety System Architecture & Sensor/Actuator Selection
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Safety System Architecture & Sensor/Actuator Selection', '## Overview

The architecture of a safety system — the arrangement of sensors, logic solver, and final elements, with their redundancy and voting — determines whether the system achieves the required SIL and whether it avoids nuisance trips. This lesson covers the architecture patterns (1oo1, 1oo2, 2oo2, 2oo3), the sensor and final element selection, and the trade-off between safety (low PFD) and availability (low nuisance trip rate).

## Key Concepts

**Voting Architectures.** 1oo1 (one of one) is a single channel — no redundancy, no fault tolerance; the PFD is the channel''s PFD. 1oo2 (one of two) trips if either channel detects the hazard — higher safety (lower PFD) but more nuisance trips (either channel''s false trip stops the process). 2oo2 (two of two) trips only if both channels detect — same PFD as 1oo1 but lower nuisance trip rate; a single channel failure does not trip. 2oo3 (two of three) trips if two of three detect — high safety and high availability; a single channel failure does not trip, and the hazard is still detected. The choice trades PFD against nuisance trips and cost.

**Sensor Selection.** Safety sensors must be certified for the required SIL and must be independent from the basic process control system (BPCS) where possible — sharing a transmitter with control means a transmitter failure affects both control and safety. Use separate transmitters (or a dedicated safety transmitter) for safety functions. For redundancy, use 2oo3 voting to balance safety and availability. Consider the failure mode: a transmitter that fails high may cause a nuisance trip; one that fails low may miss a hazard. Choose sensors whose failure mode biases toward the safe state where possible.

**Final Element Selection.** The final element (a valve, a contactor, a drive''s STO) is often the highest-PFD component because mechanical devices fail more often than electronic ones. Use a fail-safe final element (spring-return valve, de-energize-to-trip) so that loss of power produces the safe state. For redundancy, use 1oo2 for higher safety or 2oo2 for lower nuisance trips, depending on the SIL and the trip cost. Proof-test the final element as part of the function; a final element that is never exercised may stick and fail on demand.

**Separation from the BCS.** The SIS should be separate from the BCS: separate logic solver (a safety PLC, not the control PLC), separate sensors where possible, separate final elements where the SIL requires it. Sharing components between control and safety means a single failure affects both, defeating the defense-in-depth principle. The separation can be physical (separate equipment) or functional (safety-certified functions in a combined safety/controller), but the safety functions must be independently verified.

## Best Practices

- Choose voting architecture by the SIL and the nuisance-trip tolerance: 2oo3 balances safety and availability.
- Use safety-certified sensors independent from the BCS; choose fail-safe failure modes where possible.
- Use fail-safe final elements (de-energize-to-trip) and proof-test them as part of the function.
- Separate the SIS from the BCS (separate logic solver, separate sensors where possible).
- Document the architecture, voting, and separation rationale for auditability.

## Common Pitfalls

- **1oo2 for a high-trip-cost process** causes excessive nuisance trips.
- **Sharing sensors with the BCS** means a sensor failure affects both control and safety.
- **Energize-to-trip final elements** fail unsafe on power loss.
- **Never-exercised final elements** stick and fail on demand.
- **No separation from the BCS** defeats defense in depth.

## Real-World Example

A high-pressure separator used 1oo2 voting on pressure transmitters for its SIL 2 shutdown. The process had a high trip cost (long restart), and the 1oo2 voting caused a nuisance trip every few months from transmitter drift. After switching to 2oo3 voting, the nuisance trip rate dropped to near zero while the PFD improved (2oo3 has lower PFD than 1oo2). The architecture change improved both safety and availability, justified by the trip cost.

## Knowledge Check

Review the voting architectures (1oo1, 1oo2, 2oo2, 2oo3) and their safety/availability trade-offs, sensor selection and independence, final element fail-safe design, and separation from the BCS before the quiz.',
  45,
  1,
  '[
    {"question":"What does 2oo3 voting provide?","options":["Lowest safety","High safety and high availability — a single channel failure does not trip, and the hazard is still detected","No redundancy","Energize-to-trip"],"answer":1,"explanation":"2oo3 trips when two of three detect; it balances low PFD (high safety) with low nuisance trip rate (high availability)."},
    {"question":"Why use sensors independent from the BCS?","options":["To save money","A shared sensor failure affects both control and safety, defeating defense in depth","To increase trip rate","To simplify wiring"],"answer":1,"explanation":"Sharing a sensor means one failure compromises both systems; independent sensors preserve defense in depth."},
    {"question":"What is a fail-safe final element?","options":["One that fails to the safe state on loss of power (e.g., spring-return valve, de-energize-to-trip)","One that never fails","One that fails to the running state","One that requires power to trip"],"answer":0,"explanation":"A fail-safe final element drives the process to the safe state on power loss, failing safe not unsafe."},
    {"question":"Why is the final element often the highest-PFD component?","options":["It is electronic","Mechanical devices fail more often than electronic ones","It is cheap","It is never used"],"answer":1,"explanation":"Mechanical final elements have higher failure rates than electronic logic solvers, often dominating the PFD."},
    {"question":"What did switching from 1oo2 to 2oo3 achieve in the example?","options":["More nuisance trips","Lower nuisance trip rate and improved PFD, justified by the high trip cost","Higher cost","Lower safety"],"answer":1,"explanation":"2oo3 reduced nuisance trips (availability) and improved PFD (safety), both justified by the high restart cost."},
    {"question":"What should be documented for a safety architecture?","options":["Only the wiring","The architecture, voting, and separation rationale","Only the cost","Only the vendor name"],"answer":1,"explanation":"Documenting the architecture, voting, and separation rationale makes the design auditable and verifiable."},
    {"question":"Why proof-test the final element as part of the function?","options":["To save time","A never-exercised final element may stick and fail on demand","To reduce cost","It is not necessary"],"answer":1,"explanation":"Mechanical final elements that are never exercised can stick; proof testing detects this before a demand."}
  ]'::jsonb);

  -- Lesson 2: Proof Testing, Bypass Management & Safety Maintenance
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Proof Testing, Bypass Management & Safety Maintenance', '## Overview

A safety system is not "set and forget." Between commissioning and the end of life, the system must be proof tested, bypassed and restored under control, and maintained — and the records of all of this must be kept. These operational practices sustain the SIL that the design achieved; without them, the SIL decays. This lesson covers proof testing, bypass management, and the maintenance practices that keep the SIS at its designed reliability.

## Key Concepts

**Proof Testing.** A proof test exercises the full safety function (sensor, logic solver, final element) to detect dangerous failures that have accumulated but have not yet caused a trip. The proof-test interval is part of the SIL calculation — the PFD assumes the function is tested at that interval. A proof test must cover the full function, not just the easy parts; testing the sensor but not the final element leaves the highest-PFD component untested. Document the test (what was tested, by whom, when, the result, any repairs) so the SIL calculation''s assumption is verifiable.

**Bypass Management.** A bypass disables a safety function (or a channel) for maintenance or operation. Bypasses are necessary but dangerous: a forgotten bypass is a silent safety failure. Manage bypasses with authorization (a permit), time limits (a bypass that is "temporary" for months is not temporary), logging (who, when, why, when restored), and review (periodic review of open bypasses). A bypass that is needed constantly to avoid nuisance trips indicates a design problem, not a bypass need — fix the nuisance trips, do not institutionalize the bypass.

**Maintenance and the SIL.** Maintenance sustains the SIL: replacing a failed sensor with the same certified model (not a "equivalent" non-certified one), preserving the separation from the BCS, not modifying the logic without MOC, and keeping the proof-test schedule. The most common SIL decay is a repair that uses a non-equivalent part or a modification that changes the function without re-verification. Maintenance procedures must reference the SIL requirements so that a technician knows what is and is not acceptable.

**Recording and Audit.** Every proof test, bypass, and maintenance action is recorded. The records are the evidence that the SIL is being sustained; without them, the SIL is asserted, not proven. Periodically audit a sample of records against the requirements; a gap (a missed proof test, an unreviewed bypass, a non-equivalent part) is a finding that must be closed. The records also feed the reliability analysis: failure rates observed in service can update the SIL calculation if they differ from the assumed rates.

## Best Practices

- Proof test the full safety function at the interval assumed in the SIL calculation; document each test.
- Manage bypasses with authorization, time limits, logging, and periodic review; fix constant-bypass causes.
- Use only SIL-certified equivalent parts in repairs; reference SIL requirements in maintenance procedures.
- Apply MOC to any SIS modification; re-verify the SIL if the change affects it.
- Record every proof test, bypass, and maintenance action; audit a sample periodically.

## Common Pitfalls

- **Partial proof tests** leave the highest-PFD component (often the final element) untested.
- **Forgotten bypasses** silently disable safety functions.
- **Non-equivalent replacement parts** invalidate the SIL certification.
- **Undocumented modifications** change the function without re-verification.
- **No records** means the SIL is asserted, not proven, and decay goes undetected.

## Real-World Example

An audit of a chemical plant''s SIS found that proof tests had been testing the transmitters but not the shutdown valves for three years — the valves, the highest-PFD component, were untested. Two of the eight valves were found stuck on the first full test after the audit finding. The SIL calculation had assumed full-function testing; the partial testing had silently invalidated it. After instituting full-function proof testing and recording the results, the SIL was restored and the stuck valves were repaired before a demand exposed them.

## Knowledge Check

Review full-function proof testing at the SIL interval, bypass management with authorization and time limits, certified-equivalent parts in repairs, MOC for modifications, and recording/audit before the quiz.',
  45,
  2,
  '[
    {"question":"What must a proof test cover?","options":["Only the sensor","The full safety function (sensor, logic solver, final element)","Only the logic solver","Only the final element"],"answer":1,"explanation":"A partial test leaves the untested components’ PFD unverified; the full function must be exercised."},
    {"question":"What is the danger of a forgotten bypass?","options":["It saves time","It is a silent safety failure — the function is disabled without anyone remembering","It improves safety","It reduces cost"],"answer":1,"explanation":"A forgotten bypass disables the safety function invisibly; bypass management prevents this."},
    {"question":"What does a constantly-needed bypass indicate?","options":["Good design","A design problem causing nuisance trips — fix the cause, do not institutionalize the bypass","A good bypass","A cheap system"],"answer":1,"explanation":"If a bypass is always needed, the nuisance trips indicate a design issue; fix the cause rather than relying on the bypass."},
    {"question":"What must a replacement part be?","options":["Any available part","A SIL-certified equivalent to the original","The cheapest part","A used part"],"answer":1,"explanation":"A non-equivalent or non-certified part invalidates the SIL; repairs must use certified equivalents."},
    {"question":"Why record every proof test, bypass, and maintenance action?","options":["For decoration","The records are the evidence that the SIL is sustained; without them, it is asserted, not proven","To increase storage","To slow maintenance"],"answer":1,"explanation":"Records prove the SIL is being maintained; they also feed reliability analysis and audit."},
    {"question":"What did the audit find in the chemical plant example?","options":["Missing sensors","Proof tests had skipped the shutdown valves (the highest-PFD component) for three years","Too many bypasses","A firmware bug"],"answer":1,"explanation":"Partial testing left the valves untested; two were stuck, invalidating the SIL until full testing was restored."},
    {"question":"What must happen to any SIS modification?","options":["Nothing","Management of change, with SIL re-verification if the change affects it","Just do it","Email the operator"],"answer":1,"explanation":"MOC controls modifications; if a change affects the SIL, re-verify before returning to service."}
  ]'::jsonb);
END $$;