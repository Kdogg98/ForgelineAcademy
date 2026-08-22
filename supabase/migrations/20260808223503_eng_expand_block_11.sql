DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Advanced PLC Programming Patterns & Standards';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lessons
  UPDATE lessons SET content = '## Overview

The state machine is the most powerful design pattern for sequential and mode-based control. Where ad hoc ladder logic produces "spaghetti" that is hard to troubleshoot and modify, a state machine expresses the process as a set of states with defined transitions, producing logic that is readable, testable, and maintainable. This lesson covers the state machine pattern, its implementation in ladder and structured text, and the benefits it brings to sequential control.

## Key Concepts

**The State Machine Model.** A state machine models a process as a finite set of states (e.g., Idle, Starting, Running, Stopping, Faulted) with defined transitions between them. At any time, the process is in exactly one state. Transitions occur on events (a start command, a fault, a stop command) and may have guard conditions (a permissive that must be true). The current state determines the outputs and the valid transitions. This model matches how processes actually behave and makes the logic explicit rather than implicit.

**Implementation in Ladder.** In ladder, a state machine is typically implemented with an integer state variable and a set of rungs, one per state, that are active when the state variable equals that state''s value. Each state''s rungs set the outputs for that state and evaluate the transitions to other states (moving the state variable on transition). Use a CASE or EQU structure so that only the current state''s rungs execute. Document each state and transition with comments; the state diagram is the primary documentation, and the ladder is its implementation.

**Implementation in Structured Text.** Structured Text (ST) implements a state machine cleanly with a CASE statement: CASE State OF 1: (* Idle *) ... 2: (* Starting *) ... END_CASE. Each case sets the outputs and evaluates the transitions. ST is more compact and readable than ladder for state machines, especially with many states, and supports transitions with guard conditions as IF statements. The state variable is an enumerated type (or an integer with named constants) for readability.

**Benefits of the Pattern.** A state machine is testable: each state and transition can be tested independently. It is maintainable: adding a state or a transition is a localized change, not a rewrite. It is readable: the state diagram communicates the process behavior to operators and engineers. It is fault-tolerant: a fault transitions to the Faulted state, which has a defined safe response and recovery. The pattern turns sequential control from a debugging exercise into a design exercise.

## Best Practices

- Model sequential and mode-based processes as state machines with defined states and transitions.
- Use an integer or enumerated state variable; document each state and transition with comments.
- Implement in ladder (EQU per state) or ST (CASE statement); ST is cleaner for many states.
- Draw the state diagram as the primary documentation; the code is its implementation.
- Route all faults to a Faulted state with a defined safe response and explicit recovery.

## Common Pitfalls

- **Ad hoc sequential logic** is hard to troubleshoot and modify; a state machine makes it explicit.
- **Undocumented states and transitions** make the machine unreadable.
- **No Faulted state** leaves fault handling scattered and inconsistent.
- **Transitions without guard conditions** allow invalid state changes.
- **Mixing state logic with output logic** obscures the state machine structure.

## Real-World Example

A batch process was written as ad hoc ladder with 600 rungs of sequential logic; a fault during the middle of the batch was nearly impossible to diagnose because the sequence state was implicit in the rungs. After refactoring as a state machine (10 states, 30 transitions, documented with a state diagram), a mid-batch fault transitioned to the Faulted state, which displayed the current state and the fault, and recovery was a defined transition back to Idle. Fault-to-fix time dropped from hours to minutes.

## Knowledge Check

Review the state machine model (states, transitions, guards), implementation in ladder and ST, the state diagram as documentation, and the Faulted state pattern before the quiz.',
  quiz = '[
    {"question":"What does a state machine model?","options":["A single output","A process as a finite set of states with defined transitions","A type of sensor","A network protocol"],"answer":1,"explanation":"A state machine expresses the process as states and transitions, making sequential logic explicit and testable."},
    {"question":"How is a state machine implemented in Structured Text?","options":["With a FOR loop","With a CASE statement, one case per state","With a timer","With a counter"],"answer":1,"explanation":"ST uses a CASE statement with one case per state; each case sets outputs and evaluates transitions."},
    {"question":"What is the primary documentation for a state machine?","options":["The tag list","The state diagram","The I/O map","The wiring diagram"],"answer":1,"explanation":"The state diagram communicates the process behavior; the code is its implementation."},
    {"question":"Why route all faults to a Faulted state?","options":["To hide them","A Faulted state has a defined safe response and explicit recovery, making fault handling consistent","To speed the scan","To reduce memory"],"answer":1,"explanation":"A Faulted state centralizes fault handling with a defined safe response and recovery, instead of scattered logic."},
    {"question":"What are guard conditions on transitions?","options":["Safety barriers","Permissives that must be true for a transition to occur","A type of sensor","A network protocol"],"answer":1,"explanation":"Guard conditions prevent invalid state changes; a transition occurs only when its guard is satisfied."},
    {"question":"What benefit does a state machine bring to testing?","options":["It cannot be tested","Each state and transition can be tested independently","It requires no testing","It slows testing"],"answer":1,"explanation":"Independent state and transition testing makes verification systematic; ad hoc logic cannot be tested this way."},
    {"question":"What did refactoring to a state machine achieve in the example?","options":["More rungs","Fault-to-fix time dropped from hours to minutes with a defined Faulted state and recovery","A slower process","More faults"],"answer":1,"explanation":"The state machine made the sequence explicit and the fault state defined, cutting diagnosis time dramatically."}
  ]'::jsonb
  WHERE title = 'State Machine Design Pattern' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

Modular programming and the IEC 61131-3 standard are the foundations of portable, reusable PLC code. IEC 61131-3 defines the programming languages and the program structure that let a team build a library of reusable components rather than bespoke per-project code. This lesson covers the IEC 61131-3 languages, the program organization unit (POU) structure, and the modular programming practices that make code reusable.

## Key Concepts

**The IEC 61131-3 Languages.** The standard defines five languages: Ladder Diagram (LD) for relay-style logic, Function Block Diagram (FBD) for graphical signal-flow logic, Structured Text (ST) for textual math and string handling, Instruction List (IL, largely deprecated) for low-level textual logic, and Sequential Function Chart (SFC) for state-driven and batch processes. Each language has its strengths; a well-structured project uses multiple languages, each where it fits. The standard also defines data types (BOOL, INT, REAL, structures, arrays) and the program organization units.

**Program Organization Units (POUs).** A POU is the basic unit of a program: a Program (the top-level, with access to I/O), a Function Block (reusable, with internal state, the IEC equivalent of an AOI), or a Function (reusable, no state, returns a value). POUs have a declaration part (variables, types) and a body (the code, in any of the languages). The POU structure enforces encapsulation: a Function Block''s internal variables are private, and the interface is the input/output parameters. This is the foundation of modular, reusable code.

**Modular Programming Practices.** Build a library of reusable Function Blocks (motor, valve, analog alarm, PID, state machine) and instantiate them in programs. Use standard data types (structures) for the interfaces so the blocks are portable. Version the library and store it in source control. Each Function Block has a single responsibility (a motor block does motor logic, not also batch sequencing). Test the library blocks independently; a tested block is a trusted component.

**Portability and Vendor Differences.** IEC 61131-3 is a standard, but vendors implement it differently (Logix uses AOIs and UDTs rather than the IEC POU terminology; some vendors support all five languages, others a subset). Portable code minimizes vendor-specific features and uses the common subset. For code that must run on multiple vendors'' platforms, abstract the vendor-specific parts (I/O addressing, communication) behind a standard interface. Full portability is often impractical, but modular, well-structured code is portable in principle and adaptable in practice.

## Best Practices

- Use the IEC 61131-3 language that fits each piece of logic (LD for relay, FBD for signal flow, ST for math, SFC for sequences).
- Build a library of reusable Function Blocks with single responsibilities and standard data type interfaces.
- Use the POU structure for encapsulation: private internal variables, defined input/output interface.
- Version the library, store it in source control, and test blocks independently.
- Abstract vendor-specific features behind a standard interface for portability across platforms.

## Common Pitfalls

- **Using one language for everything** makes some logic awkward (array math in ladder, relay logic in ST).
- **No reusable library** means bespoke code per project, with copy-paste divergence.
- **Function Blocks with multiple responsibilities** are not reusable and are hard to test.
- **Unversioned libraries** diverge across projects into incompatible copies.
- **Assuming full portability** ignores vendor differences; abstract the vendor-specific parts instead.

## Real-World Example

An integrator built an IEC 61131-3 library of 40 Function Blocks (motor, valve, analog alarm, PID, state machine, mode logic) used across projects on three vendors'' platforms. The library''s standard data type interfaces let the blocks port with minimal adaptation; the vendor-specific I/O and communication were abstracted behind a thin interface layer. A motor block fix propagated to all projects via library import, and a new project started from the library rather than from scratch, cutting development time 40%.

## Knowledge Check

Review the five IEC 61131-3 languages and their uses, the POU structure (Program, Function Block, Function), modular programming with a reusable library, and portability via abstraction before the quiz.',
  quiz = '[
    {"question":"How many languages does IEC 61131-3 define?","options":["Two","Five","Ten","One"],"answer":1,"explanation":"IEC 61131-3 defines five languages: LD, FBD, ST, IL, and SFC, each with its strengths."},
    {"question":"What is a Program Organization Unit (POU)?","options":["A type of sensor","The basic unit of a program: Program, Function Block, or Function","A network protocol","A data type"],"answer":1,"explanation":"POUs are the building blocks: Programs (top-level, I/O access), Function Blocks (reusable, with state), Functions (reusable, no state)."},
    {"question":"Which IEC 61131-3 language is best for sequential and batch processes?","options":["Ladder Diagram","Sequential Function Chart (SFC)","Instruction List","Function Block Diagram"],"answer":1,"explanation":"SFC models state-driven and batch processes as steps and transitions, matching their structure."},
    {"question":"What is the IEC equivalent of a Logix AOI?","options":["A Program","A Function Block","A Function","A data type"],"answer":1,"explanation":"A Function Block is reusable with internal state, like an AOI; a Function has no state and returns a value."},
    {"question":"How is portability across vendors achieved?","options":["By using only one vendor","By abstracting vendor-specific features behind a standard interface","By ignoring the standard","By copying code"],"answer":1,"explanation":"Full portability is impractical, but abstracting vendor-specific parts (I/O, comms) behind a standard interface makes code adaptable."},
    {"question":"What is a key practice for a reusable library?","options":["One Function Block does everything","Each Function Block has a single responsibility and standard data type interfaces","No version control","No testing"],"answer":1,"explanation":"Single-responsibility blocks with standard interfaces are reusable and testable; multi-responsibility blocks are not."},
    {"question":"What did the integrator\u2019s library achieve in the example?","options":["Bespoke code per project","40% development time reduction by starting new projects from the library","Slower development","Higher cost"],"answer":1,"explanation":"The reusable library let new projects start from trusted components, cutting development time 40%."}
  ]'::jsonb
  WHERE title = 'Modular Programming & IEC 61131-3' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2 with 2 lessons (split into single-row INSERTs)
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Programming Patterns', 2) RETURNING id INTO m_id;

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Sequencer & Recipe Management Patterns', '## Overview

Sequencers and recipe management are the patterns that let a PLC execute repeatable, parameterized processes — batch recipes, machine cycles, multi-step operations. A sequencer drives a series of steps in order; a recipe provides the parameters for each run. Together they turn a machine that runs one product into a machine that runs many. This lesson covers the sequencer pattern, the recipe management design, and the integration between them.

## Key Concepts

**The Sequencer Pattern.** A sequencer is a specialized state machine for linear sequences: a series of steps executed in order, each with a transition condition to the next. The sequencer holds a step number; each step''s logic executes when the step number matches; the transition advances the step when the condition is met. The sequencer can be implemented with an integer step variable (like a state machine) or with a shift register / drum instruction (a built-in sequencer in some PLCs). The sequencer pattern is ideal for machine cycles and batch operations with a defined step order.

**Recipe Management.** A recipe is a set of parameters for a run: setpoints, times, speeds, ingredients. The recipe management system stores recipes (in the PLC, in a database, or in a file), lets the operator select one, and downloads it to the sequencer. The recipe separates the process logic (the sequencer, which is the same for all products) from the process parameters (the recipe, which varies per product). This lets one machine run many products without logic changes. Store recipes in a database for traceability and version control; download to the PLC on selection.

**Recipe-Driven Sequencing.** The sequencer reads its setpoints from the active recipe rather than from hardcoded values. When the operator selects a recipe, the recipe parameters load into the sequencer''s setpoint tags, and the sequencer runs with those values. This decouples the logic from the parameters: adding a new product is a new recipe, not a logic change. The recipe includes the step sequence (which steps to run, in what order, with what transitions) and the parameters (setpoints, times) for each step.

**Traceability and Versioning.** For regulated industries (food, pharma), the recipe system must record which recipe (and version) was used for each batch, with the actual values (setpoint and measured) and timestamps. This is the genealogy that supports a recall. Version the recipes (recipe ID and revision) and store the version used with the batch record. The traceability turns the recipe system from a convenience into a compliance tool.

## Best Practices

- Implement linear sequences as sequencers (integer step variable or shift register); use full state machines for non-linear logic.
- Separate process logic (the sequencer) from process parameters (the recipe); add a product by adding a recipe, not by changing logic.
- Store recipes in a database for traceability and version control; download to the PLC on selection.
- Make the sequencer recipe-driven: setpoints come from the active recipe, not from hardcoded values.
- For regulated industries, record the recipe ID, version, and actual values with timestamps for each batch.

## Common Pitfalls

- **Hardcoded setpoints in the sequencer** require a logic change for each new product.
- **Recipes stored only in the PLC** lack version control and traceability.
- **No recipe versioning** makes it impossible to know which version produced a batch.
- **No traceability** for regulated industries jeopardizes recall capability.
- **Mixing logic and parameters** makes the system unmodifiable without unintended effects.

## Real-World Example

A food processor ran 30 products on one line. Originally, each product had its own sequencer logic, and adding a product meant a logic change and a re-validation. After implementing a recipe-driven sequencer (one sequencer, 30 recipes in a database), adding a product was a new recipe entry, not a logic change. The recipe system recorded the recipe ID, version, and actual values for each batch, supporting the traceability required by the food safety standard. New product introductions dropped from weeks to days.

## Knowledge Check

Review the sequencer pattern, recipe management and the logic/parameter separation, recipe-driven sequencing, and traceability/versioning before the quiz.',
  45,
  1,
  '[
    {"question":"What does a sequencer do?","options":["Stores recipes","Drives a series of steps in order, each with a transition condition to the next","Manages the network","Controls the HMI"],"answer":1,"explanation":"A sequencer is a specialized state machine for linear sequences; each step transitions to the next on a condition."},
    {"question":"What does a recipe provide?","options":["The logic","The parameters (setpoints, times, speeds) for a run","The wiring","The network"],"answer":1,"explanation":"A recipe is the set of parameters for a run; the sequencer (logic) is the same, the recipe (parameters) varies per product."},
    {"question":"How does recipe-driven sequencing work?","options":["Setpoints are hardcoded","The sequencer reads setpoints from the active recipe, so adding a product is a new recipe, not a logic change","Each product has its own sequencer","Recipes are ignored"],"answer":1,"explanation":"Recipe-driven sequencing decouples logic from parameters; new products are new recipes, not new logic."},
    {"question":"Where should recipes be stored for traceability?","options":["Only in the PLC","In a database for version control and traceability","On paper","In the HMI only"],"answer":1,"explanation":"A database provides version control and traceability; PLC-only storage lacks both."},
    {"question":"What must a recipe system record for regulated industries?","options":["Only the recipe name","The recipe ID, version, and actual values with timestamps for each batch","The operator\u2019s name only","Nothing"],"answer":1,"explanation":"Recipe ID, version, and actual values with timestamps support traceability and recall capability."},
    {"question":"What is the benefit of separating logic from parameters?","options":["More logic changes","Adding a product is a new recipe, not a logic change or re-validation","Slower operation","Higher cost"],"answer":1,"explanation":"Separation means new products are data, not code \u2014 no logic change, no re-validation, faster introduction."},
    {"question":"What did the recipe-driven sequencer achieve in the example?","options":["Slower introductions","New product introductions dropped from weeks to days","More logic changes","No traceability"],"answer":1,"explanation":"One sequencer with 30 recipes turned product introductions from logic changes (weeks) into recipe entries (days)."}
  ]'::jsonb);

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Batch Process Control (ISA-88) & Interlocks', '## Overview

ISA-88 (IEC 61512) is the standard for batch process control, providing a model for structuring batch processes into equipment and procedural elements. Where a sequencer handles a single machine, ISA-88 handles a multi-unit batch process with shared equipment, parallel operations, and recipe-driven execution. This lesson covers the ISA-88 model, the procedural and equipment hierarchy, and the interlock design that keeps batch operations safe.

## Key Concepts

**The ISA-88 Model.** ISA-88 separates the physical equipment (the cell, units, equipment modules, control modules) from the procedural control (the procedure, unit procedures, operations, phases). A recipe defines the procedure (the steps) and the equipment requirements (which units). The physical model and the procedural model are independent: the same procedure can run on different units, and a unit can run different procedures. This separation enables equipment reuse and recipe portability.

**The Procedural Hierarchy.** A procedure (the whole batch, e.g., "Make Product A") is composed of unit procedures (operations on a unit, e.g., "Charge Reactor"), which are composed of operations (a step sequence, e.g., "Add Ingredient B"), which are composed of phases (the atomic actions, e.g., "Open Valve V1", "Start Agitator"). Each level has a defined interface and state. The phase is the lowest level and typically maps to a PLC routine or AOI.

**The Equipment Hierarchy.** A process cell contains units (independent processing vessels, e.g., Reactor 1, Reactor 2); a unit contains equipment modules (functional groups, e.g., the charging system); an equipment module contains control modules (individual devices, e.g., a valve, a pump). Units are the key abstraction: a unit can run one operation at a time and has its own state (Idle, Running, Faulted). The unit allocation logic assigns operations to units based on availability and recipe requirements.

**Interlocks for Batch Operations.** Batch operations have interlocks that are more complex than continuous control: per-phase interlocks (the phase can only start if its preconditions are met), per-unit interlocks (the unit can only run if it is allocated and not faulted), and per-cell interlocks (shared equipment, like a common header, can only be used by one unit at a time). The interlocks are safety-critical and must be tested explicitly during commissioning. A common failure is a race condition where two units attempt to use shared equipment simultaneously; the interlock must prevent this.

## Best Practices

- Structure batch processes per ISA-88: separate the physical (cell, units, equipment modules, control modules) from the procedural (procedure, unit procedures, operations, phases).
- Make units the key abstraction: one operation per unit at a time, with a defined unit state.
- Implement unit allocation logic that assigns operations to units based on availability and recipe requirements.
- Design per-phase, per-unit, and per-cell interlocks; test them explicitly during commissioning.
- Map phases to PLC routines or AOIs with defined interfaces for portability and reuse.

## Common Pitfalls

- **Mixing physical and procedural models** produces inflexible code that cannot reuse equipment or recipes.
- **No unit state** lets operations collide on a unit.
- **No allocation logic** for shared equipment causes race conditions.
- **Untested batch interlocks** harbor race conditions that surface during parallel operations.
- **Phases without defined interfaces** are not reusable across units.

## Real-World Example

A batch chemical plant had two reactors sharing a common ingredient header. Without ISA-88 structure, the code allowed both reactors to charge from the header simultaneously, causing cross-contamination and pressure excursions. After restructuring per ISA-88 with unit allocation logic (the header was allocated to one unit at a time) and per-cell interlocks (the header could not open to a second unit while in use), the race condition was eliminated. The structure, not just the interlock, fixed the problem.

## Knowledge Check

Review the ISA-88 physical/procedural separation, the procedural and equipment hierarchies, unit allocation, and the three levels of batch interlocks before the quiz.',
  45,
  2,
  '[
    {"question":"What does ISA-88 separate?","options":["Logic and parameters","The physical equipment from the procedural control","The HMI and the PLC","The sensors and the actuators"],"answer":1,"explanation":"ISA-88 separates the physical model (cell, units, equipment modules) from the procedural model (procedure, unit procedures, operations, phases)."},
    {"question":"What is the lowest level of the procedural hierarchy?","options":["Procedure","Phase","Unit procedure","Operation"],"answer":1,"explanation":"The phase is the atomic action (e.g., Open Valve V1); it typically maps to a PLC routine or AOI."},
    {"question":"What is the key equipment abstraction in ISA-88?","options":["The control module","The unit (one operation at a time, with a defined state)","The equipment module","The process cell"],"answer":1,"explanation":"Units are independent processing vessels that run one operation at a time; allocation logic assigns operations to units."},
    {"question":"What are the three levels of batch interlocks?","options":["Sensor, actuator, logic","Per-phase, per-unit, and per-cell","Auto, manual, maintenance","Start, run, stop"],"answer":1,"explanation":"Per-phase (preconditions), per-unit (allocation and fault), and per-cell (shared equipment) interlocks prevent unsafe batch operations."},
    {"question":"What is a common batch failure that interlocks must prevent?","options":["A slow phase","A race condition where two units attempt to use shared equipment simultaneously","A missing recipe","A bad HMI graphic"],"answer":1,"explanation":"Shared equipment (a common header) must be allocated to one unit at a time; the interlock prevents simultaneous use."},
    {"question":"What does unit allocation logic do?","options":["Stores recipes","Assigns operations to units based on availability and recipe requirements","Controls the HMI","Manages the network"],"answer":1,"explanation":"Allocation logic routes operations to available units per the recipe, preventing collisions and enabling parallel processing."},
    {"question":"What did the ISA-88 restructuring fix in the example?","options":["A slow recipe","A race condition causing cross-contamination and pressure excursions from simultaneous header use","A missing phase","A bad cable"],"answer":1,"explanation":"Unit allocation and per-cell interlocks prevented both reactors from using the shared header simultaneously."}
  ]'::jsonb);

  -- Add module 3 with 2 lessons (split into single-row INSERTs)
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Code Quality, Testing & Maintenance', 3) RETURNING id INTO m_id;

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Code Quality Metrics & Refactoring Strategies', '## Overview

PLC code, like any code, accrues technical debt: shortcuts, duplications, and inconsistencies that make the code harder to maintain over time. Code quality metrics make the debt visible, and refactoring strategies pay it down before it compounds into unmaintainability. This lesson covers the metrics that reveal PLC code quality, the refactoring patterns that improve it, and the discipline that sustains quality over the project''s life.

## Key Concepts

**Code Quality Metrics.** Useful metrics for PLC code include: routine size (routines over 100 rungs or 200 lines are candidates for splitting), tag count per routine (high count suggests the routine does too much), duplication (the same logic copy-pasted across devices, a candidate for an AOI), comment density (routines with few comments are hard to maintain), and complexity (deeply nested rungs or nested IF/CASE are hard to follow). Measure these metrics periodically; a metric that trends in the wrong direction signals growing debt.

**Refactoring Patterns.** Common refactoring patterns for PLC code: Extract AOI (replace copy-pasted device logic with an AOI instance), Split Routine (break a giant routine into focused subroutines), Introduce UDT (replace many scalars with a structured UDT), Rename for Clarity (replace cryptic tag names with descriptive ones), and Consolidate Fault Handling (replace scattered fault logic with a common handler). Each refactoring preserves behavior while improving structure; the key is that refactoring is behavior-preserving, verified by testing before and after.

**The Refactoring Discipline.** Refactor in small, verified steps: make one change, test, commit. Do not batch refactoring with feature changes — a refactoring commit should contain only the refactoring, so that a regression is attributable. Test before and after (the FAT test plan is the regression test). Use version control so that a bad refactoring is revertible. Refactor opportunistically (when adding a feature, clean up the code you touch) and periodically (a dedicated refactoring sprint for the worst debt).

**Sustaining Quality.** Quality is sustained by the coding standard (which sets the target), the review checklist (which enforces it), the metrics (which measure it), and the refactoring (which improves it). Without all four, quality decays. Review the metrics quarterly; if a metric trends wrong, schedule refactoring. A project that does not measure, review, and refactor accumulates debt until maintenance becomes prohibitively expensive.

## Best Practices

- Measure code quality metrics periodically (routine size, tag count, duplication, comment density, complexity).
- Apply refactoring patterns (Extract AOI, Split Routine, Introduce UDT, Rename, Consolidate Fault Handling) in small, verified steps.
- Keep refactoring commits separate from feature changes; test before and after using the FAT test plan.
- Refactor opportunistically (clean up code you touch) and periodically (dedicated sprints for the worst debt).
- Sustain quality with the standard, the review checklist, the metrics, and the refactoring \u2014 all four are needed.

## Common Pitfalls

- **No metrics** means debt is invisible until maintenance becomes painful.
- **Refactoring without testing** risks regressions that are hard to attribute.
- **Batching refactoring with features** makes regressions unattributable.
- **No version control** makes a bad refactoring unrevertible.
- **No periodic refactoring** lets debt compound until maintenance is prohibitively expensive.

## Real-World Example

A project had 20 motor instances with copy-pasted logic (50 rungs each, 1,000 rungs total) and a 1,400-rung MainRoutine. After Extract AOI (one Motor AOI, 20 instances, 50 rungs of logic once) and Split Routine (the MainRoutine into 14 focused subroutines), the code shrank to 400 rungs, and a motor logic fix became a one-line AOI change instead of 20 edits. The metrics (routine size, duplication) had made the debt visible; the refactoring paid it down.

## Knowledge Check

Review the code quality metrics, the refactoring patterns, the small-steps-with-testing discipline, and the four-part quality sustainment before the quiz.',
  45,
  1,
  '[
    {"question":"What does routine size as a metric reveal?","options":["The cost","Routines over 100 rungs or 200 lines are candidates for splitting","The vendor","The network"],"answer":1,"explanation":"Large routines are hard to troubleshoot and test; size is a primary quality metric."},
    {"question":"What is the Extract AOI refactoring?","options":["Deleting an AOI","Replacing copy-pasted device logic with an AOI instance","Adding a new routine","Renaming a tag"],"answer":1,"explanation":"Extract AOI consolidates duplicated logic into a single reusable AOI, eliminating copy-paste divergence."},
    {"question":"Why keep refactoring commits separate from feature changes?","options":["To slow development","So a regression is attributable to the refactoring or the feature, not both","To increase commits","To avoid testing"],"answer":1,"explanation":"Separate commits make regressions attributable; a batched commit hides whether the regression is from the refactoring or the feature."},
    {"question":"What must be done before and after a refactoring?","options":["Nothing","Test (using the FAT test plan as the regression test) to verify behavior is preserved","Rename all tags","Delete comments"],"answer":1,"explanation":"Refactoring is behavior-preserving; testing before and after verifies that behavior did not change."},
    {"question":"What are the four elements that sustain code quality?","options":["Cost, schedule, budget, risk","The standard, the review checklist, the metrics, and the refactoring","The vendor, the integrator, the operator, the maintainer","Tags, routines, programs, tasks"],"answer":1,"explanation":"All four are needed; without any one, quality decays over the project\u2019s life."},
    {"question":"What is opportunistic refactoring?","options":["Refactoring everything at once","Cleaning up the code you touch when adding a feature","Ignoring refactoring","Refactoring only at project end"],"answer":1,"explanation":"Opportunistic refactoring improves the code as it is touched, preventing debt from accumulating in active areas."},
    {"question":"What did the Extract AOI and Split Routine achieve in the example?","options":["More rungs","Code shrank from 1,400 to 400 rungs; a motor fix became a one-line AOI change","Slower development","No change"],"answer":1,"explanation":"The refactoring paid down the debt: less code, no copy-paste, and a single-point fix for motor logic."}
  ]'::jsonb);

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Simulation, Testing & Virtual Commissioning', '## Overview

Simulation and virtual commissioning are the practices that let a team test PLC logic before the physical equipment exists or is available. A digital twin of the process simulates the I/O, and the PLC logic runs against it, catching logic errors early when they are cheap to fix. This lesson covers the simulation approaches, the virtual commissioning workflow, and the benefits and limits of simulation.

## Key Concepts

**Simulation Approaches.** Three levels of simulation are used: I/O simulation (a simple table or script that toggles inputs and observes outputs — useful for logic debugging), process simulation (a model of the process dynamics — a tank level, a motor acceleration — that responds to the PLC outputs realistically), and hardware-in-the-loop (HIL, the PLC runs against a real-time simulation on dedicated hardware, the most realistic). The choice depends on the complexity and the risk; I/O simulation catches logic bugs, process simulation catches control issues, HIL catches timing and integration issues.

**Virtual Commissioning.** Virtual commissioning runs the PLC logic against a process simulation before the physical equipment is built or available. The team executes the FAT test plan against the simulated process, catching logic errors, sequence issues, and tuning problems while the equipment is still being built or is otherwise occupied. The issues found in virtual commissioning are cheap to fix (edit the logic, re-run the simulation); the same issues found on the physical equipment are expensive (delay the startup, require the integrator on site). Virtual commissioning compresses the commissioning schedule by front-loading the debugging.

**The Digital Twin.** A digital twin is the process simulation plus the PLC logic plus the HMI, running together as a virtual copy of the system. The twin is built from the mechanical and process design (CAD, P&ID) and the control design (PLC program, HMI). It lets the team test the full system, train operators, and demonstrate the system to the customer before it is built. The twin is most valuable for complex systems (multi-axis machines, batch processes) where physical commissioning is expensive and risky.

**Benefits and Limits.** Simulation catches logic, sequence, and control issues early, compresses the commissioning schedule, and enables operator training before the equipment exists. It does not catch physical issues (a mis-wired I/O, a mechanical interference, a sensor that does not match the process) — those require the physical equipment. Simulation is a complement to, not a replacement for, physical commissioning. The team still needs FAT, SAT, and I/O checkout on the real equipment; simulation just makes them faster by front-loading the logic debugging.

## Best Practices

- Match the simulation level to the risk: I/O simulation for logic, process simulation for control, HIL for timing and integration.
- Execute the FAT test plan against the simulation in virtual commissioning to catch issues while they are cheap to fix.
- Build a digital twin for complex systems from the mechanical, process, and control design; use it for testing and training.
- Treat simulation as a complement to physical commissioning; still perform FAT, SAT, and I/O checkout on the real equipment.
- Use the simulation to train operators before the equipment exists, compressing the training schedule.

## Common Pitfalls

- **No simulation** front-loads all debugging to physical commissioning, delaying startup.
- **I/O simulation only** for a complex process misses control and timing issues.
- **Assuming simulation replaces physical commissioning** misses physical issues (wiring, mechanical, sensor).
- **No digital twin for a complex system** means physical commissioning is the first time the full system runs.
- **Not training operators on the simulation** wastes the opportunity to train before the equipment exists.

## Real-World Example

A multi-axis packaging machine was virtually commissioned against a process simulation while the mechanical build was still in progress. The virtual FAT caught 80 logic and sequence issues that were fixed in the logic before the machine was built. When the physical machine was assembled, the physical FAT found only 5 additional issues (all physical — a mis-wired sensor, a mechanical adjustment), and the startup was 3 weeks shorter than the previous comparable project. The virtual commissioning front-loaded the cheap-to-fix issues and left only the physical issues for the physical commissioning.

## Knowledge Check

Review the simulation levels (I/O, process, HIL), the virtual commissioning workflow, the digital twin, and the benefits and limits before the quiz.',
  45,
  2,
  '[
    {"question":"What are the three levels of simulation?","options":["Low, medium, high","I/O simulation, process simulation, and hardware-in-the-loop (HIL)","Auto, manual, maintenance","Start, run, stop"],"answer":1,"explanation":"I/O simulation catches logic bugs, process simulation catches control issues, HIL catches timing and integration issues."},
    {"question":"What is virtual commissioning?","options":["Commissioning without any testing","Running PLC logic against a process simulation before the physical equipment is available","Skipping FAT","Training only"],"answer":1,"explanation":"Virtual commissioning front-loads logic debugging by running the FAT test plan against a simulation, finding issues while they are cheap to fix."},
    {"question":"What is a digital twin?","options":["A backup PLC","The process simulation plus PLC logic plus HMI running together as a virtual copy","A type of sensor","A network protocol"],"answer":1,"explanation":"A digital twin integrates simulation, logic, and HMI, enabling full-system testing, training, and demonstration before build."},
    {"question":"What does simulation NOT catch?","options":["Logic errors","Physical issues like mis-wired I/O, mechanical interferences, and sensor-process mismatches","Sequence errors","Tuning problems"],"answer":1,"explanation":"Simulation catches logic, sequence, and control issues; physical issues require the real equipment and physical commissioning."},
    {"question":"Why is simulation a complement, not a replacement, for physical commissioning?","options":["It is too expensive","It cannot catch physical issues; FAT, SAT, and I/O checkout are still needed on the real equipment","It is too slow","It is inaccurate"],"answer":1,"explanation":"Simulation front-loads logic debugging; physical commissioning still catches the physical issues simulation cannot."},
    {"question":"What did virtual commissioning achieve in the example?","options":["More physical issues","80 logic issues found before build; physical FAT found only 5 physical issues; startup 3 weeks shorter","A longer startup","No benefit"],"answer":1,"explanation":"Virtual commissioning front-loaded the cheap-to-fix logic issues, leaving only physical issues for the physical FAT and shortening startup."},
    {"question":"What is a key benefit of a digital twin for operators?","options":["Slower training","Training before the equipment exists, compressing the training schedule","No training needed","More paperwork"],"answer":1,"explanation":"The twin lets operators train on a virtual copy before the equipment is built, so they are ready at startup."}
  ]'::jsonb);
END $$;