DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='PLC Programming Best Practices (Logix-style)';
  IF NOT FOUND THEN RETURN; END IF;

  UPDATE lessons SET content = '## Overview

Effective PLC programming in a Logix-style environment (Allen-Bradley ControlLogix, CompactLogix) depends on disciplined program structure, consistent tag naming, and modular routine organization. This lesson establishes the foundational conventions that separate maintainable code from fragile "spaghetti" logic — conventions that pay dividends across the entire lifecycle of a control system, from commissioning through decades of modification.

## Key Concepts

**Tag Naming Conventions.** A consistent, hierarchical tag-naming scheme is the single most impactful standard a controls team can adopt. The recommended pattern is `Area_Subsystem_Device.Attribute` — for example, `Conveyor1_Motor1.CmdStart`, `Tank3_ValveInlet.PosCmd`, `Station2_CylinderA.SensorRet`. Base tags group related devices; aliases point to physical I/O so that controller logic remains hardware-independent during development and re-addressing. Avoid reserved words, leading numerals, and names longer than 40 characters to stay compatible with HMI symbol import limits and older panel drivers.

**Program Organization.** Organize the controller as a hierarchy: Tasks → Programs → Routines. The Main task contains a Main program whose MainRoutine calls subroutines via JSR instructions. Group equipment by area (Conveyor, Process Cell, Utility) into separate programs, each with its own MainRoutine and a set of operational, fault, and mode routines. This mirrors the physical plant and lets multiple engineers work in parallel without merge conflicts. Use the Continuous task for process logic and Periodic tasks for time-critical functions (motion planner updates, high-speed counting) at intervals that respect CPU loading — typically 10–50 ms.

**Scope and Modularity.** Use controller-scoped tags only for data shared across programs (production counts, system mode, shared interlocks). Keep everything else program-scoped or routine-local to prevent unintended coupling. Add-On Instructions (AOIs) encapsulate reusable device logic (motor, valve, analog alarm) with defined inputs, outputs, and local tags, exposing a clean interface and hiding internal state. AOIs version cleanly, can be locked for safety review, and reduce copy-paste divergence.

**Documentation.** Every routine should open with a rung comment describing its purpose, inputs, and outputs. Tag descriptions, rung comments, and page titles populate the auto-generated cross-reference and are the primary documentation a troubleshooter sees at 2 a.m. Treat comments as code: review them in code review, and update them whenever logic changes.

## Best Practices

- Adopt a written tag-naming standard before the first line of logic; retrofitting is expensive and error-prone.
- Prefer one Main program with JSR-driven subroutines over many small programs unless area boundaries are clear.
- Keep the Continuous task below 40% CPU utilization to leave headroom for periodic tasks, messaging, and future expansion.
- Lock AOIs that have passed safety review; document the revision history inside the AOI definition.
- Use descriptive tag descriptions even when the name is self-explanatory — HMI tooltips and printed reports rely on them.

## Common Pitfalls

- **Inconsistent naming** across shifts and contractors makes cross-referencing and HMI import painful.
- **Overuse of controller-scoped tags** creates hidden dependencies and makes refactoring risky.
- **Giant routines** (hundreds of rungs) are hard to troubleshoot and impossible to unit-test.
- **Stale comments** that no longer match the rung mislead the next technician and erode trust in documentation.
- **Ignoring CPU loading** leads to task overruns, watchdog faults, and intermittent behavior that is hard to reproduce.

## Real-World Example

A packaging line with 12 conveyors was originally written as one 1,400-rung MainRoutine. Faults took hours to isolate because interlocks crossed equipment boundaries invisibly. After refactoring into one program per conveyor, each with a standard set of Auto/Manual/Fault routines and a shared AOI for motor control, average fault-to-fix time dropped from 90 minutes to under 15. The AOI meant a single fix to motor interlock logic propagated to all 12 conveyors without manual edits.

## Knowledge Check

Review the tag-naming pattern, the Task→Program→Routine hierarchy, and the role of AOIs in encapsulating reusable device logic before attempting the quiz.',
  quiz = '[{"question":"Which tag-naming pattern is recommended for Logix-style projects?","options":["Area_Subsystem_Device.Attribute","device.attribute only","camelCaseDeviceName","Device_Number_Attribute"],"correctIndex":0},{"question":"What is the correct Program hierarchy in a Logix controller?","options":["Routine → Program → Task","Task → Program → Routine","Program → Task → Routine","Task → Routine → Program"],"correctIndex":1},{"question":"Where should shared, cross-program data live?","options":["Routine-local tags","Controller-scoped tags","Program-scoped tags only","Inside AOIs"],"correctIndex":1},{"question":"What is a primary benefit of Add-On Instructions (AOIs)?","options":["They run faster than inline logic","They encapsulate reusable device logic with a clean interface","They eliminate the need for any controller-scoped tags","They bypass the watchdog timer"],"correctIndex":1},{"question":"What Continuous task CPU utilization should you stay below?","options":["10%","25%","40%","80%"],"correctIndex":2},{"question":"Why should AOIs that pass safety review be locked?","options":["To speed up scan time","To prevent unauthorized edits and preserve the reviewed version","To free controller memory","To disable the AOI"],"correctIndex":1},{"question":"What is a common consequence of writing one giant MainRoutine?","options":["Faster execution","Easier troubleshooting","Hard-to-isolate faults and interlocks that cross equipment boundaries","Lower memory usage"],"correctIndex":2}]'::jsonb
  WHERE title = 'Tag Naming & Program Organization' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

Add-On Instructions (AOIs) are the primary reuse mechanism in Studio 5000 / Logix-style controllers. They let a team define a device''s behavior once — a motor starter, a two-state valve, an analog alarm block, a sequencer — and instantiate it many times with a consistent interface, internal state, and documentation. Used well, AOIs transform a project from a collection of bespoke rungs into a library of trusted, reviewed components.

## Key Concepts

**AOI Anatomy.** An AOI definition specifies input parameters, output parameters, in-out parameters (passed by reference, allowing the AOI to modify the caller''s tag), local tags (private state), and the routine logic itself. The caller sees only the parameter list — the internal logic and local tags are encapsulated. AOIs support multiple routines (Main plus optional EnableInFalse and pre-scan routines), and each instance maintains its own copy of local tags.

**Encapsulation and State.** Because each instance holds its own local tags, AOIs are ideal for stateful devices: a motor with a start/stop latch and a fault timer, or a valve with travel-time monitoring. The internal state cannot be accidentally modified from outside, which eliminates a whole class of "someone wrote to my timer" bugs. In-out parameters let the AOI update caller-owned tags (a command word, a status structure) without exposing internals.

**Versioning and Locking.** AOIs are versioned objects: a definition carries a revision number, vendor info, and optional change history. When you lock an AOI, instances cannot be edited inline and the definition becomes read-only in the project — critical for safety-reviewed or validated logic. Importing a new version updates all instances; use the AOI Library and a source-controlled export (.L5X) to manage changes across projects.

**When to Use an AOI vs. a Routine.** Use an AOI when the logic is reused, stateful, and has a clean parameter boundary. Use a plain subroutine when the logic is one-off, tightly coupled to a specific program''s tags, or needs direct access to many controller-scoped tags. Overusing AOIs for trivial logic adds overhead and indirection without benefit.

## Best Practices

- Define a standard AOI library (motor, valve, analog alarm, mode logic, sequencer) at the start of every project and reuse it.
- Use UDTs (User-Defined Data Types) for parameter structures so the AOI interface is self-documenting and stable across versions.
- Document each AOI with a header comment describing purpose, parameters, and revision history.
- Lock AOIs that have passed safety or validation review; track the locked revision in your change log.
- Export AOIs to .L5X and store them in source control alongside the project for reproducible builds.

## Common Pitfalls

- **Deep parameter nesting** with many in-out tags makes AOIs hard to call correctly; prefer structures over dozens of scalars.
- **Unlocked safety AOIs** can be silently edited, invalidating the review.
- **Ignoring the EnableInFalse routine** leaves outputs in their last state when the AOI is disabled, causing latched faults.
- **Copying AOIs between projects** without version control leads to divergent "almost-the-same" libraries.
- **Over-encapsulating trivial logic** adds call overhead and indirection with no reuse benefit.

## Real-World Example

A water utility standardized a single Motor AOI with start/stop interlocks, a fault timer, a run-permissive structure, and a status UDT. Across 14 plants and 600+ motor instances, every motor behaves identically, fault codes are consistent, and a single AOI update (adding a phase-loss alarm) rolled out to all instances via import. The HMI team built one faceplate that binds to the UDT, eliminating per-motor graphics work.

## Knowledge Check

Recall the AOI anatomy (inputs, outputs, in-outs, local tags), the role of the EnableInFalse routine, and when an AOI is preferable to a subroutine before taking the quiz.',
  quiz = '[{"question":"What does an AOI encapsulate that a plain subroutine does not?","options":["Its own local tags and internal state per instance","Nothing extra","A faster scan time","Direct access to all controller tags"],"correctIndex":0},{"question":"Which parameter type lets an AOI modify a tag owned by the caller?","options":["Input","Output","In-Out","Local"],"correctIndex":2},{"question":"What does locking an AOI prevent?","options":["Execution of the AOI","Inline editing of instances and changes to the definition","Memory use by the AOI","Export to .L5X"],"correctIndex":1},{"question":"What is the EnableInFalse routine used for?","options":["Running the AOI faster","Defining outputs/state when the AOI is disabled","Encrypting the AOI","Disabling in-out parameters"],"correctIndex":1},{"question":"When is a plain subroutine preferable to an AOI?","options":["When the logic is reused and stateful","When the logic is one-off and tightly coupled to a program''s tags","When you need per-instance state","When the logic must be locked"],"correctIndex":1},{"question":"What is a best practice for AOI parameter interfaces?","options":["Use dozens of scalar parameters","Use UDT structures so the interface is self-documenting and stable","Avoid documentation","Never use in-out parameters"],"correctIndex":1},{"question":"How should AOI versions be managed across projects?","options":["Manually copy and hope they match","Export to .L5X and store in source control alongside the project","Never update AOIs once deployed","Email the .ACD file to the team"],"correctIndex":1}]'::jsonb
  WHERE title = 'Add-On Instructions (AOIs)' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

Fault handling is what separates a control system that runs from one that keeps running. A well-designed fault strategy detects anomalies early, annunciates them clearly, drives the process to a safe state, and provides the operator with enough context to diagnose and recover. This lesson covers the fault lifecycle, standard fault categories, first-out (first-fault) detection, and recovery procedures in a Logix-style environment.

## Key Concepts

**The Fault Lifecycle.** A fault progresses through four phases: Detection (a condition becomes true), Annunciation (the operator is informed), Response (the process moves to a safe state), and Recovery (the operator acknowledges and the system returns to automatic). Each phase has an owner and a clear handoff; ambiguous ownership ("is that the PLC''s job or the operator''s?") is the root cause of most recovery confusion.

**Fault Categories.** Standard categories include Device Fault (motor overload, valve travel time), Process Fault (high/low level, deviation), Safety Fault (e-stop, light curtain, safety relay), and System Fault (controller fault, I/O fault, communication loss). Each category has a distinct annunciation priority and a distinct safe-state response — a device fault may stop one motor while a safety fault stops an entire zone.

**First-Out Detection.** When many alarms trigger at once (a cascade), the first one is usually the cause and the rest are effects. A first-out (first-fault) latch records which alarm became true first and holds it until reset, so the operator can address the root cause instead of chasing symptoms. Implement first-out with a latch set by the first alarm and reset only by an explicit operator acknowledge.

**Safe State and Recovery.** Every fault must drive the process to a defined safe state — typically de-energize motion, close fail-safe valves, hold position. Recovery should require an explicit operator action (acknowledge/reset), not auto-clear on condition change, to prevent sudden restarts. Latch the fault, require reset, and only then allow restart — this is the "three-step restart" pattern.

## Best Practices

- Use a standard Fault UDT (active, latched, first-out, code, timestamp, message) for every device and zone.
- Drive all faults through a common fault handler routine so annunciation and logging are consistent.
- Latch faults and require explicit operator reset; never auto-recover on condition change.
- Provide a first-out latch for cascading alarms so the root cause is preserved.
- Log every fault transition (active, acknowledged, reset) with a timestamp for post-mortem analysis.

## Common Pitfalls

- **Auto-recovery** on condition change causes sudden restarts and is a safety hazard.
- **No first-out** leaves the operator chasing the loudest alarm rather than the cause.
- **Inconsistent fault structures** across devices make HMI and logging painful.
- **Faults that don''t latch** flicker on and off, masking intermittent failures.
- **Recovery without reset** lets a transient fault clear and the machine restart with no operator awareness.

## Real-World Example

A paper mill had 200+ analog alarms that would cascade within seconds of a stock-flow upset, flooding the operator with hundreds of annunciated alarms. After implementing first-out latching and a standard Fault UDT, the first alarm (a pump cavitation flow-low) was held as the root cause and the cascade was suppressed. Mean time to diagnose dropped from 12 minutes to under 2, and the historian captured the exact sequence for every event.

## Knowledge Check

Review the four-phase fault lifecycle, the standard fault categories, the purpose of first-out detection, and the three-step restart pattern before taking the quiz.',
  quiz = '[{"question":"What are the four phases of the fault lifecycle?","options":["Detect, Log, Reset, Forget","Detection, Annunciation, Response, Recovery","Start, Run, Stop, Fault","Sense, Latch, Clear, Restart"],"correctIndex":1},{"question":"What is the purpose of first-out (first-fault) detection?","options":["To silence all alarms","To record which alarm triggered first in a cascade so the root cause is preserved","To auto-restart the process","To reduce CPU load"],"correctIndex":1},{"question":"What is the three-step restart pattern?","options":["Fault, latch, auto-restart","Detect, latch, require explicit operator reset before restart","Reset, restart, re-fault","Auto-clear, restart, log"],"correctIndex":1},{"question":"Why should faults drive the process to a defined safe state?","options":["To keep production running","To de-energize motion and hold a safe condition until recovery","To save energy","To clear the alarm automatically"],"correctIndex":1},{"question":"What should a standard Fault UDT include?","options":["Only a boolean active flag","Active, latched, first-out, code, timestamp, message","Just a message string","Only a timestamp"],"correctIndex":1},{"question":"Why route all faults through a common fault handler routine?","options":["To slow down annunciation","To ensure consistent annunciation, logging, and safe-state response","To bypass the HMI","To hide faults from operators"],"correctIndex":1},{"question":"What is a key risk of auto-recovery on condition change?","options":["It saves operator time","It can cause sudden, unexpected restarts and is a safety hazard","It improves logging","It reduces alarm count"],"correctIndex":1}]'::jsonb
  WHERE title = 'Fault Handling & Recovery' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Code Standards & Version Control', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Coding Standards & Peer Review', '## Overview

A written coding standard is the backbone of a maintainable PLC project. Without one, every programmer (and every contractor) imposes their own style, and the codebase becomes an archaeological dig of personal preferences. This lesson covers what a Logix-style coding standard should contain, how to enforce it through peer review, and how to integrate it with version control so that standards are auditable rather than aspirational.

## Key Concepts

**What a Coding Standard Covers.** A complete standard defines tag-naming conventions, routine structure (header comment, section banners, rung comments), AOI usage and locking, memory-organization rules (controller vs. program scope), fault-handling patterns, and HMI/PLC interface contracts. It should also specify banned practices — e.g., no MOV into a timer preset, no unconditional OTL without a corresponding OTU, no math on uninitialized tags — with the reasoning behind each rule.

**Peer Review.** Every change to a released project should pass a peer review: a second engineer checks the code against the standard, verifies fault handling, confirms I/O addressing, and reviews comments and documentation. Review is most effective when it is lightweight (a checklist, not a committee) and when it happens before deployment, not after. Use a review checklist derived from the coding standard so the review is consistent and auditable.

**Version Control for PLC Projects.** Studio 5000 projects are binary .ACD files by default, which version-control systems handle poorly. Export the project to .L5X (XML) or use the Logix Designer''s built-in integration with Git to store text-based, diff-able versions. Commit at logical milestones (per feature, per bug fix), write meaningful commit messages, and tag releases. Branch per feature or per site so that parallel work does not collide.

**Auditable Standards.** A standard that is not audited is a wish. Tie the standard to the review checklist, tie the checklist to the commit gate, and periodically audit a sample of released projects against the standard. Track conformance over time and feed gaps back into training.

## Best Practices

- Write the standard down, version it, and make it required reading for every team member and contractor.
- Derive a review checklist from the standard so reviews are consistent and fast.
- Store projects as .L5X in Git; commit per logical change with a meaningful message.
- Tag releases in version control to map a running system back to an exact code revision.
- Audit a sample of released projects against the standard each quarter and feed gaps into training.

## Common Pitfalls

- **Unwritten standards** drift with every new hire and contractor.
- **Review after deployment** catches problems too late to prevent downtime.
- **Binary-only version control** makes diffs and rollback impossible.
- **Checklists that don''t match the standard** make review inconsistent.
- **No audits** let the standard silently erode until it is irrelevant.

## Real-World Example

A systems integrator adopted a one-page coding standard, a 12-item review checklist, and Git-based .L5X versioning. Within a year, post-release defect counts dropped 60%, and every running site could be mapped to an exact code revision via a Git tag. When a customer reported a fault, the integrator checked out the tagged revision, reproduced the logic, and shipped a fix in hours instead of days.

## Knowledge Check

Recall what a coding standard should cover, the role of a review checklist derived from the standard, and why .L5X/Git versioning beats binary .ACD storage before the quiz.',
  50, 1,
  '[{"question":"What does a complete Logix coding standard define?","options":["Only tag names","Tag naming, routine structure, AOI usage, scope rules, fault handling, and HMI/PLC contracts","Only comment style","Only I/O addressing"],"correctIndex":1},{"question":"What is the most effective timing for peer review?","options":["After deployment, during the next outage","Before deployment, using a lightweight checklist","Only at project handover","Never — trust the programmer"],"correctIndex":1},{"question":"Why export PLC projects to .L5X for version control?","options":[".L5X runs faster on the controller",".L5X is text-based and diff-able, unlike binary .ACD",".L5X is smaller in memory",".L5X removes the need for a controller"],"correctIndex":1},{"question":"What should a review checklist be derived from?","options":["Personal preference","The written coding standard","The HMI graphics","The controller firmware version"],"correctIndex":1},{"question":"What is a banned practice worth specifying in a standard?","options":["Using JSR","Unconditional OTL without a matching OTU","Using AOIs","Using controller-scoped tags for shared data"],"correctIndex":1},{"question":"Why tag releases in version control?","options":["To decorate the commit graph","To map a running system back to an exact code revision","To delete old commits","To increase commit count"],"correctIndex":1},{"question":"What happens to an unaudited standard over time?","options":["It becomes law","It silently erodes until irrelevant","It speeds up the controller","It auto-updates"],"correctIndex":1}]'::jsonb),
  (m_id, 'Version Control & Change Management Workflows', '## Overview

Version control is not just storing files — it is a disciplined workflow that makes every change traceable, reviewable, and reversible. For PLC projects, where a bad change can stop a plant, a rigorous change-management workflow is a safety system, not a convenience. This lesson covers branching strategies, the change-request process, release tagging, and rollback procedures for Logix-style projects.

## Key Concepts

**Branching Strategy.** Use a main branch for the currently-deployed revision and a feature branch per change request. Small fixes branch off main, are reviewed, and merge back; larger efforts (new line, major retrofit) live on a long-lived feature branch with periodic rebase onto main. This keeps main always deployable while parallel work proceeds safely.

**Change-Request Process.** Every change to a released system starts with a written change request: what, why, risk assessment, test plan, and rollback plan. The request is approved before code is written, the branch is named after the request ID, and the merge commit references the request. This ties every line of code to a business reason and a risk evaluation.

**Release Tagging and Traceability.** When a revision is deployed, tag it in version control with the site, date, and change-request IDs included. The running controller''s project should match a tagged revision exactly; store the .ACD and .L5X for that tag so that the deployed state is fully reproducible. This is your audit trail for ISO 9001, IEC 61511, and FDA-regulated environments.

**Rollback.** Every deployment must have a tested rollback path: the previous tagged revision is re-imported and downloaded. Practice rollback during FAT so that it is not the first time under pressure. Document the rollback procedure in the change request and confirm it works before go-live.

## Best Practices

- Keep main always deployable; branch per change request.
- Name branches after the change-request ID for traceability.
- Tag every deployment with site, date, and change-request IDs.
- Store both .ACD and .L5X for each tagged release so the deployed state is reproducible.
- Test rollback during FAT; never attempt an untested rollback under pressure.

## Common Pitfalls

- **Long-lived branches** that diverge from main become unmergeable.
- **No change request** means no risk assessment and no rollback plan.
- **Untagged deployments** make it impossible to know what is running.
- **Untested rollback** fails when you need it most.
- **Direct commits to main** bypass review and break traceability.

## Real-World Example

A pharmaceutical facility regulated by FDA 21 CFR Part 11 required full traceability for every PLC change. By tying Git branches to change-request IDs, tagging each deployment, and storing both .ACD and .L5X, the team produced a complete audit trail on demand. An FDA inspection that previously took weeks of reconstruction was answered in minutes by querying the Git history.

## Knowledge Check

Review the branching strategy (main + feature branches), the change-request process, release tagging for traceability, and the rollback requirement before the quiz.',
  50, 2,
  '[{"question":"What should the main branch always be?","options":["Under active edit by everyone","Deployable","A long-lived feature branch","Deleted after each release"],"correctIndex":1},{"question":"What should every change to a released system start with?","options":["A direct commit to main","A written change request with risk assessment and rollback plan","An email to the operator","A firmware update"],"correctIndex":1},{"question":"How should feature branches be named for traceability?","options":["After the programmer","After the change-request ID","Randomly","After the controller name"],"correctIndex":1},{"question":"What should each deployment be tagged with in version control?","options":["Only a date","Site, date, and change-request IDs","Only a version number","The programmer''s name"],"correctIndex":1},{"question":"Why store both .ACD and .L5X for each tagged release?","options":[".ACD is for Git, .L5X is for the controller",".ACD is the binary project; .L5X is the text version for diffing — both are needed for reproducibility","To double the storage cost",".L5X is obsolete"],"correctIndex":1},{"question":"When should rollback be tested?","options":["Only during a real outage","During FAT, before go-live","Never","After the next release"],"correctIndex":1},{"question":"What is a key risk of direct commits to main?","options":["Faster releases","They bypass review and break traceability","They save storage","They improve safety"],"correctIndex":1}]'::jsonb);
END $$;
