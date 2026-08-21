DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Reliability Engineering & Predictive Maintenance Strategy';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lessons
  UPDATE lessons SET content = '## Overview

Failure Modes and Effects Analysis (FMEA) is the foundational technique of reliability engineering: a systematic, team-based examination of how a system can fail, the effects of those failures, and the controls that prevent or detect them. FMEA underpins predictive maintenance strategy, safety analysis, and design review. This lesson covers the FMEA process, the risk priority number (RPN), and how FMEA outputs drive maintenance and design decisions.

## Key Concepts

**The FMEA Process.** An FMEA is built by a cross-functional team (engineering, maintenance, operations). For each function of the system, the team lists failure modes (how the function can fail), effects (what happens), causes (why it happens), and controls (prevention and detection). Each failure mode is scored on Severity (1–10), Occurrence (1–10), and Detection (1–10). The product is the Risk Priority Number (RPN = S × O × D), which prioritizes action.

**Failure Modes vs. Failures.** A failure mode is the way a function fails (e.g., "pump does not start"); a failure is an actual event. FMEA enumerates possible modes, not historical events, so it catches failures that have not yet happened. Common failure modes for rotating equipment: no output, reduced output, erratic output, noise/vibration, leakage, overheating. For electrical devices: no operation, intermittent operation, short, open, drift.

**Severity, Occurrence, Detection.** Severity is the consequence if the failure occurs (10 = safety/ regulatory, 1 = nuisance). Occurrence is the likelihood (10 = frequent, 1 = improbable). Detection is the likelihood the failure is detected before reaching the customer or causing harm (10 = undetectable, 1 = certain detection). Note that Detection is about the control''s ability to catch the failure, not the operator''s skill.

**Action and Iteration.** FMEA is not a one-time document; it is a living analysis. High-RPN items drive actions: design changes (reduce Occurrence), additional detection (reduce Detection), or mitigation (reduce Severity). After actions, re-score. The FMEA is updated after every significant failure, every design change, and every review cycle. A stale FMEA is a missed opportunity.

## Best Practices

- Build FMEAs with a cross-functional team, not a single engineer in a room.
- Score consistently: use the same scales across the facility and calibrate with reference examples.
- Prioritize by RPN but also by high Severity regardless of RPN — a Severity-10 item demands action even if RPN is moderate.
- Treat the FMEA as a living document; update after failures, changes, and reviews.
- Link FMEA actions to the maintenance management system (CMMS) so they are tracked to closure.

## Common Pitfalls

- **Single-author FMEAs** miss failure modes that other disciplines would catch.
- **Inconsistent scoring** makes RPNs non-comparable across the facility.
- **One-time FMEAs** become stale and useless within a year.
- **Ignoring high-Severity items** because RPN is moderate leaves safety risks unaddressed.
- **Actions not tracked** in the CMMS are forgotten, so the FMEA produces no change.

## Real-World Example

A chemical plant FMEA on a reactor cooling system identified "cooling pump fails to start" as Severity 10 (runaway reaction), Occurrence 3, Detection 8 (operator notices only after temperature rises) — RPN 240. The team added an auto-start standby pump with a pressure-switch detection (Detection improved to 2), reducing RPN to 60 and, more importantly, reducing the risk of a runaway. The FMEA drove a design change, not just a maintenance task.

## Knowledge Check

Review the FMEA process, the distinction between failure modes and failures, the S/O/D scoring, the RPN calculation, and the living-document principle before the quiz.',
  quiz = '[
    {"question":"What does FMEA stand for?","options":["Failure Modes and Effects Analysis","Fault Management and Equipment Analysis","Failure Measurement and Evaluation Approach","Functional Maintenance and Equipment Audit"],"answer":0,"explanation":"FMEA is Failure Modes and Effects Analysis, a systematic technique for identifying how a system can fail."},
    {"question":"How is the Risk Priority Number (RPN) calculated?","options":["S + O + D","S \u00d7 O \u00d7 D","S \u00d7 O","O \u00d7 D"],"answer":1,"explanation":"RPN = Severity \u00d7 Occurrence \u00d7 Detection, each scored 1\u201310."},
    {"question":"What does the Detection score measure?","options":["Operator skill","The control\u2019s ability to detect the failure before harm","The frequency of the failure","The cost of the failure"],"answer":1,"explanation":"Detection measures how likely the current controls catch the failure before it causes harm."},
    {"question":"What is the difference between a failure mode and a failure?","options":["They are the same","A failure mode is a possible way a function fails; a failure is an actual event","A failure mode is an event; a failure is a possibility","There is no difference"],"answer":1,"explanation":"FMEA enumerates possible failure modes, including ones that have not yet occurred."},
    {"question":"Why should high-Severity items be addressed even if RPN is moderate?","options":["They are cheap","A Severity-10 item implies safety/regulatory risk regardless of likelihood","RPN is wrong","They are easy to fix"],"answer":1,"explanation":"High-severity failures carry safety or regulatory consequences that demand action beyond RPN."},
    {"question":"Who should build an FMEA?","options":["A single engineer","A cross-functional team (engineering, maintenance, operations)","The vendor only","The operator only"],"answer":1,"explanation":"A cross-functional team catches failure modes that a single discipline would miss."},
    {"question":"When should an FMEA be updated?","options":["Never, once written","After every significant failure, design change, and review cycle","Only at project handover","Only when the vendor requires it"],"answer":1,"explanation":"A living FMEA is updated after failures, changes, and reviews; a stale FMEA is a missed opportunity."}
  ]'::jsonb
  WHERE title = 'FMEA & Failure Modes' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

Weibull analysis is the workhorse of reliability statistics. Where FMEA identifies what can fail, Weibull analysis quantifies when it fails — the probability of failure as a function of time or cycles. Named for Waloddi Weibull, the distribution is flexible enough to model infant mortality, random failure, and wear-out in a single framework, making it the standard for life data analysis in industrial maintenance.

## Key Concepts

**The Weibull Distribution.** The two-parameter Weibull distribution has a shape parameter (β, beta) and a scale parameter (η, eta). The cumulative distribution function F(t) = 1 − exp(−(t/η)^β) gives the probability of failure by time t. The shape parameter β tells you the failure pattern: β < 1 is infant mortality (decreasing failure rate), β = 1 is random/exponential (constant failure rate), β > 1 is wear-out (increasing failure rate). The scale parameter η is the characteristic life — the age at which 63.2% of the population has failed.

**Life Data and Censoring.** Weibull analysis uses life data: time-to-failure for failed units and running time for units still in service (right-censored). Censored data is not noise — it is real information that the unit survived to its current age. A Weibull fit that ignores censored data is biased optimistic. Rank the failures (median ranks are standard) and plot on Weibull probability paper to estimate β and η.

**The Weibull Plot.** Plotting ln(t) against ln(−ln(1 − F)) yields a straight line if the data fits Weibull; the slope is β and the intercept gives η. A curved plot indicates a mixed population (multiple failure modes) or a non-Weibull distribution — both are diagnostic. Modern software (ReliaSoft, Minitab) performs the fit and goodness-of-test automatically, but understanding the plot lets you judge whether the fit is trustworthy.

**Using the Results.** A wear-out population (β > 1) supports time-based replacement: replace before the failure rate rises. A random population (β ≈ 1) supports condition-based or run-to-failure strategy, since age does not predict failure. An infant-mortality population (β < 1) points to a quality or installation problem, not a maintenance problem. The characteristic life η sets the planning horizon; the B10 life (age at which 10% fail) is a common replacement benchmark.

## Best Practices

- Include censored (still-running) units; ignoring them biases the fit optimistic.
- Inspect the Weibull plot for curvature, which indicates mixed populations or non-Weibull data.
- Match the maintenance strategy to the shape: wear-out → time-based, random → condition-based, infant mortality → quality.
- Use B10 or B5 life as the replacement benchmark, not the mean (which is skewed by survivors).
- Re-fit periodically as new failures arrive; a single fit is a snapshot, not a truth.

## Common Pitfalls

- **Ignoring censored data** biases the characteristic life optimistic.
- **Mixed populations** (two failure modes) curve the plot and invalidate a single fit.
- **Choosing time-based replacement for random failures** wastes money without improving reliability.
- **Using the mean time to failure** as the replacement benchmark is skewed by survivors.
- **One-time fits** go stale as the population ages and the environment changes.

## Real-World Example

A fleet of 200 pumps showed a Weibull fit with β = 2.4 (wear-out) and η = 18 months. The maintenance team had been running the pumps to failure, with a mean time between failures of 14 months. After switching to a B10 replacement at 9 months, unscheduled failures dropped 70% and the rebuild cost fell because pumps were rebuilt before catastrophic secondary damage. The Weibull shape drove the strategy.

## Knowledge Check

Recall the two-parameter Weibull (β, η), the meaning of β < 1, β = 1, β > 1, the importance of censored data, and how β drives the maintenance strategy before the quiz.',
  quiz = '[
    {"question":"What does the Weibull shape parameter \u03b2 indicate?","options":["The characteristic life","The failure pattern (infant mortality, random, or wear-out)","The cost of failure","The number of failures"],"answer":1,"explanation":"\u03b2 < 1 is infant mortality, \u03b2 = 1 is random, \u03b2 > 1 is wear-out."},
    {"question":"What is the characteristic life \u03b7?","options":["The age at which 10% fail","The age at which 63.2% of the population has failed","The mean time to failure","The median life"],"answer":1,"explanation":"\u03b7 is the scale parameter \u2014 the age at which 63.2% of the population has failed."},
    {"question":"Why must censored (still-running) units be included?","options":["They increase the failure count","Ignoring them biases the characteristic life optimistic","They are not relevant","They reduce the cost"],"answer":1,"explanation":"Censored data is real information that a unit survived to its current age; omitting it biases the fit."},
    {"question":"What maintenance strategy fits a wear-out population (\u03b2 > 1)?","options":["Run-to-failure","Time-based replacement before the failure rate rises","Condition monitoring only","No maintenance"],"answer":1,"explanation":"Wear-out means age predicts failure, so time-based replacement is appropriate."},
    {"question":"What does a curved Weibull plot indicate?","options":["A perfect fit","A mixed population (multiple failure modes) or non-Weibull data","Too few failures","Wrong software"],"answer":1,"explanation":"Curvature signals mixed populations or a different distribution, both of which invalidate a single fit."},
    {"question":"What is B10 life?","options":["The age at which 10% of the population has failed \u2014 a common replacement benchmark","The mean life","The characteristic life","The warranty period"],"answer":0,"explanation":"B10 is the age at which 10% fail; it is a conservative replacement benchmark, unlike the skewed mean."},
    {"question":"What does an infant-mortality population (\u03b2 < 1) point to?","options":["A maintenance problem","A quality or installation problem, not a maintenance problem","A wear-out problem","A random failure problem"],"answer":1,"explanation":"Infant mortality indicates quality or installation defects, addressed at the source, not by maintenance."}
  ]'::jsonb
  WHERE title = 'Weibull Analysis' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

Condition monitoring and key performance indicators (KPIs) turn the promise of predictive maintenance into measurable practice. Condition monitoring is the sensing that detects deterioration before failure; KPIs are the metrics that tell management whether the program is working. Together they close the loop between strategy and execution. This lesson covers the principal condition-monitoring technologies, the KPIs that matter, and how to use them to drive continuous improvement.

## Key Concepts

**Condition-Monitoring Technologies.** Vibration analysis is the standard for rotating equipment — it detects bearing wear, imbalance, misalignment, and looseness via frequency spectra. Oil analysis detects wear particles, contamination, and lubricant degradation in gearboxes and hydraulics. Thermography detects electrical hot spots (loose connections, overloaded contacts) and mechanical friction. Ultrasonic detects compressed-air leaks, bearing friction, and partial discharge. Motor current signature analysis detects rotor and bearing faults via the motor''s own current. Each technology has a sweet spot; none covers everything.

**The P-F Curve.** The P-F curve shows the time from when a failure becomes detectable (P, potential failure) to when it becomes functional (F, failure). The interval P–F is the window for action. Condition monitoring aims to detect at P and act before F. The monitoring interval must be shorter than P–F; a monthly measurement on a failure with a 2-week P–F interval will miss it. Choose the technology and interval to match the failure''s P–F.

**KPIs That Matter.** Mean time between failures (MTBF) and mean time to repair (MTTR) measure reliability and maintainability. Availability = MTBF / (MTBF + MTTR) measures uptime. Percent planned maintenance (% PM) measures how much maintenance is planned vs. reactive — world-class is > 80% planned. Maintenance cost as a percentage of asset replacement value (RAV) benchmarks spend. Mean time to detect (MTTD) and mean time to isolate (MTTI) measure the detection and response side. Track a handful of KPIs that drive behavior, not a dashboard of 50 that no one acts on.

**Closing the Loop.** KPIs without action are decoration. Review KPIs monthly with maintenance and operations; identify the worst-performing assets; apply root-cause analysis (often via FMEA); implement a fix; measure the improvement. The loop is detect → analyze → act → measure. A predictive maintenance program that does not close this loop collects data and changes nothing.

## Best Practices

- Match the condition-monitoring technology to the failure mode and the P–F interval.
- Set the monitoring interval shorter than the shortest P–F interval of interest.
- Track a focused set of KPIs (MTBF, MTTR, availability, % planned, cost/RAV) that drive behavior.
- Review KPIs monthly with maintenance and operations; act on the worst performers.
- Close the loop: detect → analyze → act → measure, every time.

## Common Pitfalls

- **Wrong technology for the failure mode** — vibration on a gearbox oil-degradation failure misses it.
- **Monitoring interval longer than P–F** — the failure occurs between measurements.
- **Dashboard of 50 KPIs** that no one acts on.
- **KPIs without a monthly review** — data is collected but nothing changes.
- **No root-cause follow-through** — the same failures recur because the cause was never addressed.

## Real-World Example

A pulp mill deployed vibration analysis on its refiner motors with a monthly route. Bearing failures were still occurring because the P–F interval for certain bearing defects was under 3 weeks. After switching to permanently mounted sensors with weekly automated analysis, bearing failures were detected early enough to plan the rebuild, and unplanned refiner downtime dropped 45% in a year. The monitoring interval had to match the P–F.

## Knowledge Check

Review the condition-monitoring technologies and their sweet spots, the P-F curve and the monitoring-interval rule, the core maintenance KPIs, and the detect-analyze-act-measure loop before the quiz.',
  quiz = '[
    {"question":"What is the P-F interval?","options":["The time between failures","The time from when a failure becomes detectable (P) to when it becomes functional (F)","The maintenance interval","The mean time to repair"],"answer":1,"explanation":"P\u2013F is the action window; condition monitoring must detect at P and act before F."},
    {"question":"What must the monitoring interval be relative to P-F?","options":["Longer","Shorter than the shortest P\u2013F interval of interest","Equal to MTBF","Irrelevant"],"answer":1,"explanation":"If the interval exceeds P\u2013F, the failure occurs between measurements and is missed."},
    {"question":"Which technology is the standard for detecting bearing wear in rotating equipment?","options":["Oil analysis","Vibration analysis","Thermography","Ultrasonic"],"answer":1,"explanation":"Vibration spectra detect bearing wear, imbalance, misalignment, and looseness."},
    {"question":"What does % planned maintenance measure?","options":["The percentage of assets","How much maintenance is planned vs. reactive \u2014 world-class is > 80%","The cost of maintenance","The downtime"],"answer":1,"explanation":"% PM measures planning quality; world-class programs exceed 80% planned work."},
    {"question":"How is availability calculated?","options":["MTBF / (MTBF + MTTR)","MTBF \u00d7 MTTR","MTTR / MTBF","MTBF + MTTR"],"answer":0,"explanation":"Availability = MTBF / (MTBF + MTTR), combining reliability and maintainability."},
    {"question":"What is the detect-analyze-act-measure loop?","options":["A type of sensor","The continuous-improvement cycle that closes the gap between KPIs and action","A vibration analysis technique","A KPI formula"],"answer":1,"explanation":"Without this loop, KPIs are decoration; the loop turns data into improved performance."},
    {"question":"Why did the pulp mill still suffer bearing failures with monthly vibration routes?","options":["Vibration does not detect bearings","The P\u2013F interval was under 3 weeks, shorter than the monthly route","The sensors were broken","The analysts were untrained"],"answer":1,"explanation":"The monitoring interval (monthly) exceeded the P\u2013F interval (under 3 weeks), so failures were missed."}
  ]'::jsonb
  WHERE title = 'Condition Monitoring & KPIs' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add new module (sort_order 3) with 2 lessons
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Reliability Program Implementation', 3) RETURNING id INTO m_id;

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Building a Predictive Maintenance Program', '## Overview

A predictive maintenance (PdM) program is not a sensor purchase; it is an organizational capability. Many programs stall after buying technology because they underestimated the people, process, and data work. This lesson covers the building blocks of a successful PdM program: the asset criticality assessment, the technology selection, the analyst capability, the work-management integration, and the continuous-improvement loop that keeps the program alive.

## Key Concepts

**Asset Criticality Assessment.** Not every asset deserves PdM. Rank assets by criticality (safety, environmental, production impact, and repair cost) and by failure predictability (does it give warning?). High-criticality, predictable-failure assets are PdM candidates; low-criticality or unpredictable assets are run-to-failure candidates. This ranking prevents wasted effort on assets where PdM cannot pay back.

**Technology Selection.** Match the technology to the failure modes identified in the FMEA and to the P–F interval. Vibration for rotating equipment, oil analysis for lubricated gearboxes, thermography for electrical connections, ultrasonic for compressed air and partial discharge. Avoid "one technology for everything" vendors; the right portfolio is usually multi-vendor. Start with a pilot on the top 10–20 critical assets before scaling.

**The Analyst Capability.** Data without analysis is noise. A PdM program needs a trained analyst (or a contracted service) who can interpret spectra, set alarm limits, and recommend action. The analyst is the difference between a program that catches failures early and one that generates alerts that are ignored. Invest in training and certification (ISO 18436 for vibration analysts) and in retaining the analyst — institutional knowledge is irreplaceable.

**Work-Management Integration.** A PdM finding that does not become a work order is wasted. Integrate PdM recommendations into the CMMS so that each finding generates a planned work order with priority, parts, and procedure. Track the finding from detection to completion and measure how many findings became avoided failures — this is the program''s value proof.

**Continuous Improvement.** Review program performance quarterly: which assets generated findings, which were caught early, which failed despite monitoring. Feed failures back into the FMEA and the monitoring strategy. A PdM program that does not learn from its misses stagnates.

## Best Practices

- Start with an asset criticality assessment; do not monitor everything.
- Match technology to failure modes and P–F intervals; avoid single-technology dogma.
- Invest in a trained, certified analyst; data without analysis is noise.
- Integrate findings into the CMMS as planned work orders; track to closure.
- Review program performance quarterly and feed misses back into the strategy.

## Common Pitfalls

- **Buying sensors before assessing criticality** wastes budget on non-critical assets.
- **Single-technology programs** miss failure modes outside that technology''s scope.
- **No analyst** means alerts are generated but not interpreted or acted on.
- **Findings not in the CMMS** are forgotten, so the program produces no avoided failures.
- **No quarterly review** lets the program stagnate and miss its own failures.

## Real-World Example

A food manufacturer bought 200 vibration sensors across its plant but had no analyst; the alerts were ignored because no one could interpret them. After hiring a certified vibration analyst and integrating findings into the CMMS, the program documented 40 avoided failures in its first year, with an estimated savings of $1.2M in downtime. The sensors were necessary but not sufficient; the analyst and the CMMS integration were the difference.

## Knowledge Check

Recall the asset criticality assessment, technology-to-failure-mode matching, the analyst''s role, CMMS integration, and the quarterly review loop before the quiz.',
  45,
  1,
  '[
    {"question":"What is the first step in building a PdM program?","options":["Buy sensors","An asset criticality assessment to decide what to monitor","Hire an analyst","Integrate the CMMS"],"answer":1,"explanation":"Criticality assessment focuses effort on assets where PdM can pay back; not everything should be monitored."},
    {"question":"Why avoid single-technology programs?","options":["They are too cheap","They miss failure modes outside that technology\u2019s scope","They are too accurate","They are illegal"],"answer":1,"explanation":"No single technology covers all failure modes; the right portfolio is usually multi-vendor."},
    {"question":"What does a PdM analyst do that sensors cannot?","options":["Generate more data","Interpret spectra, set alarm limits, and recommend action","Install sensors","Buy sensors"],"answer":1,"explanation":"Data without analysis is noise; the analyst turns data into actionable recommendations."},
    {"question":"What must happen to a PdM finding for it to have value?","options":["It must be logged in a spreadsheet","It must become a planned work order in the CMMS and be tracked to closure","It must be emailed around","It must be ignored"],"answer":1,"explanation":"A finding that does not become a work order is wasted; CMMS integration tracks value to closure."},
    {"question":"What is the program\u2019s value proof?","options":["Sensor count","The number of findings that became avoided failures","The analyst\u2019s certification","The vendor invoice"],"answer":1,"explanation":"Tracking findings to avoided failures quantifies the program\u2019s return and justifies continued investment."},
    {"question":"How often should program performance be reviewed?","options":["Never","Quarterly, feeding misses back into the FMEA and monitoring strategy","Every 5 years","Only at program launch"],"answer":1,"explanation":"Quarterly review keeps the program learning; misses drive FMEA and strategy updates."},
    {"question":"What certification is standard for vibration analysts?","options":["ISA-84","ISO 18436","IEC 61511","ISO 50001"],"answer":1,"explanation":"ISO 18436 certifies vibration analysts, ensuring competent interpretation of spectra."}
  ]'::jsonb);

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Reliability-Centered KPIs & Continuous Improvement', '## Overview

Reliability is a numbers game: what gets measured gets improved, and what is not measured drifts. A reliability program without a focused set of KPIs is a program without a steering wheel. This lesson covers the KPIs that drive reliability behavior, how to avoid vanity metrics, and how to use KPIs to sustain continuous improvement rather than to assign blame.

## Key Concepts

**Leading vs. Lagging Indicators.** Lagging indicators (MTBF, downtime, failure count) measure what already happened; leading indicators (% PM compliance, condition-monitoring coverage, finding-to-fix time) predict future performance. A balanced program tracks both: lagging to confirm results, leading to drive action. A program that tracks only lagging indicators finds out about problems after the damage.

**The Core Reliability KPIs.** MTBF and MTTR measure reliability and maintainability. Availability combines them. % planned maintenance measures planning quality. Maintenance cost as % of RAV benchmarks spend. OEE (overall equipment effectiveness) = availability × performance × quality, links reliability to production. Mean time to detect (MTTD) and mean time to isolate (MTTI) measure the detection-and-response side. Finding-to-fix time measures the PdM loop. Choose 5–8 that drive behavior, not 50 that decorate a dashboard.

**Avoiding Vanity Metrics.** A vanity metric makes the program look good but drives no action: "number of sensors installed," "number of routes completed," "number of work orders closed." A useful metric drives a decision: "% critical assets under condition monitoring," "% findings acted on within P–F," "% unplanned downtime." Replace vanity metrics with action-driving ones.

**KPIs for Improvement, Not Blame.** KPIs that are used to punish drive gaming and concealment; KPIs that are used to learn drive improvement. Review KPIs in a no-blame setting focused on system causes. Celebrate the avoided failures; analyze the missed ones. The goal is a better system, not a scapegoat.

**Sustaining the Loop.** Reliability decays without effort. Sustain the loop by reviewing KPIs monthly, acting on the worst performers, and re-baselining annually. A program that reviews KPIs only at the annual budget cycle has already lost the year.

## Best Practices

- Track both leading and lagging indicators; lagging to confirm, leading to drive.
- Choose 5–8 action-driving KPIs; replace vanity metrics with ones that drive decisions.
- Review KPIs in a no-blame setting focused on system causes, not individual fault.
- Celebrate avoided failures; analyze missed ones for system causes.
- Review KPIs monthly and re-baseline annually; reliability decays without sustained effort.

## Common Pitfalls

- **Only lagging indicators** tell you about problems after the damage is done.
- **Vanity metrics** make the program look good but drive no action.
- **KPIs used for blame** drive gaming and concealment, not improvement.
- **Too many KPIs** overwhelm and result in no action.
- **Annual-only review** loses the year; monthly review sustains the loop.

## Real-World Example

A plant tracked "number of work orders completed" as a KPI and saw it rise steadily — but unplanned downtime rose too, because crews were closing easy work orders and deferring hard ones. After replacing the vanity metric with "% unplanned downtime" and "% findings acted on within P–F," behavior shifted toward the hard, high-value work, and unplanned downtime fell 30% in six months.

## Knowledge Check

Review leading vs. lagging indicators, the core reliability KPIs, the vanity-metric trap, the no-blame review principle, and the monthly review cadence before the quiz.',
  45,
  2,
  '[
    {"question":"What is the difference between leading and lagging indicators?","options":["They are the same","Leading indicators predict future performance; lagging indicators measure what already happened","Lagging indicators predict; leading measure the past","There is no difference"],"answer":1,"explanation":"A balanced program tracks both: leading to drive action, lagging to confirm results."},
    {"question":"Which is a vanity metric?","options":["% unplanned downtime","Number of sensors installed","% findings acted on within P\u2013F","MTBF"],"answer":1,"explanation":"\u201cNumber of sensors installed\u201d looks good but drives no action; replace it with action-driving metrics."},
    {"question":"How many KPIs should a reliability program track?","options":["1","5\u20138 action-driving KPIs","50","As many as possible"],"answer":1,"explanation":"A focused set of 5\u20138 KPIs drives behavior; 50 decorate a dashboard and drive nothing."},
    {"question":"How should KPIs be used to drive improvement?","options":["To punish underperformers","In a no-blame setting focused on system causes","To fire people","To justify budget cuts"],"answer":1,"explanation":"KPIs for learning drive improvement; KPIs for blame drive gaming and concealment."},
    {"question":"What does OEE combine?","options":["Availability \u00d7 performance \u00d7 quality","MTBF \u00d7 MTTR","Cost \u00d7 RAV","Sensor count \u00d7 route count"],"answer":0,"explanation":"OEE = availability \u00d7 performance \u00d7 quality, linking reliability to production output."},
    {"question":"How often should KPIs be reviewed to sustain the loop?","options":["Annually","Monthly, with annual re-baselining","Every 5 years","Only at program launch"],"answer":1,"explanation":"Monthly review sustains the loop; annual-only review loses the year."},
    {"question":"What happened when the plant tracked work orders completed?","options":["Downtime fell","Unplanned downtime rose because crews closed easy work and deferred hard work","Nothing changed","The program was cancelled"],"answer":1,"explanation":"The vanity metric drove gaming \u2014 easy work closed, hard work deferred \u2014 until an action-driving metric replaced it."}
  ]'::jsonb);
END $$;