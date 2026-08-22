DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Studio 5000 / Logix System Architecture Deep Dive';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lessons
  UPDATE lessons SET content = '## Overview

The Task-Program-Routine hierarchy is the backbone of every Logix controller project. Understanding how tasks execute, how programs scope their data, and how routines are called is the difference between a project that scales cleanly and one that fights its own structure. This lesson covers the task types and execution model, program scope and the MainRoutine pattern, and the routine call mechanisms that tie them together.

## Key Concepts

**Task Types and Execution.** The Continuous task runs as fast as it can, repeatedly, and is the default for process logic. Periodic tasks run at a fixed interval (e.g., 10 ms) and preempt the Continuous task — used for time-critical functions like motion updates and high-speed counting. Event tasks run on a trigger (a consumed tag change, a module input, a motion registration event) — used for event-driven logic without polling. Each task has a watchdog that faults the controller if the task overruns its time. Periodic tasks have priority over the Continuous task; multiple periodic tasks are scheduled by priority.

**Program Scope and the MainRoutine.** A program is a container for routines and program-scoped tags. Each program has a MainRoutine that executes first when the program is scanned; the MainRoutine typically calls other routines via JSR (Jump to Subroutine). Program-scoped tags are visible only within the program, preventing coupling between programs. This lets multiple engineers work on different programs (Conveyor1, Conveyor2, Utility) without merge conflicts and without one program''s tags affecting another. Use controller-scoped tags only for data shared across programs.

**Routine Types and Call Mechanisms.** Ladder logic is the default for relay-style logic and is universally readable. Function Block Diagram (FBD) suits continuous control (PIDs, math) where signal flow is clearer graphically. Structured Text (ST) suits complex math, string handling, and array operations that are awkward in ladder. Sequential Function Chart (SFC) suits batch and state-driven processes. The MainRoutine calls subroutines via JSR (with optional input/output parameters) or via the SFC. Choose the routine type to the logic; mixing types within a program is normal and beneficial.

**Task Priority and CPU Loading.** The Continuous task should stay below ~40% CPU utilization to leave headroom for periodic tasks, messaging, and future expansion. Periodic tasks must complete within their interval or the watchdog faults. Monitor CPU loading in the controller properties and during commissioning; a project that loads the CPU 80% at commissioning has no room to grow.

## Best Practices

- Use the Continuous task for process logic; Periodic for time-critical; Event for event-driven.
- Keep the Continuous task below ~40% CPU to leave headroom for periodic tasks and growth.
- Use one program per equipment area with a MainRoutine that calls subroutines via JSR.
- Use program-scoped tags by default; controller-scoped only for cross-program shared data.
- Choose the routine type to the logic (ladder, FBD, ST, SFC); mixing is normal and beneficial.

## Common Pitfalls

- **Continuous task above 80% CPU** leaves no headroom and risks watchdog faults.
- **All tags controller-scoped** creates hidden coupling and makes refactoring risky.
- **One giant MainRoutine** is hard to troubleshoot and impossible to unit-test.
- **Wrong routine type** makes simple logic awkward (e.g., array math in ladder).
- **Periodic task overrunning its interval** faults the controller.

## Real-World Example

A water utility organized its 14 plants into one program per plant, each with a MainRoutine calling Auto, Manual, Fault, and Alarm subroutines. Program-scoped tags kept each plant independent, and a single controller-scoped "System Mode" tag coordinated interlocks. Five engineers worked on different plants in parallel without merge conflicts, and the Continuous task stayed at 25% CPU with room for future expansion.

## Knowledge Check

Review the task types (Continuous, Periodic, Event) and their execution model, program scope and the MainRoutine pattern, routine types and JSR, and CPU loading before the quiz.',
  quiz = '[
    {"question":"Which task type runs repeatedly as fast as it can?","options":["Periodic","Event","Continuous","SFC"],"answer":2,"explanation":"The Continuous task runs repeatedly and is the default for process logic."},
    {"question":"What does a Periodic task do if it overruns its interval?","options":["Runs slower","Faults the controller via the watchdog","Skips the next scan","Nothing"],"answer":1,"explanation":"Periodic tasks have a watchdog that faults the controller if the task overruns its interval."},
    {"question":"What is the role of the MainRoutine in a program?","options":["It stores all tags","It executes first and typically calls subroutines via JSR","It runs periodically","It replaces the Continuous task"],"answer":1,"explanation":"The MainRoutine runs first when the program is scanned and calls other routines via JSR."},
    {"question":"Where should cross-program shared data live?","options":["Program-scoped tags","Controller-scoped tags","Inside a JSR","In the MainRoutine"],"answer":1,"explanation":"Controller-scoped tags are for data shared across programs; everything else should be program-scoped."},
    {"question":"Which routine type suits complex math and array operations?","options":["Ladder","Function Block Diagram","Structured Text","Sequential Function Chart"],"answer":2,"explanation":"Structured Text suits complex math, string handling, and array operations that are awkward in ladder."},
    {"question":"What CPU utilization should the Continuous task stay below?","options":["10%","25%","40%","80%"],"answer":2,"explanation":"Staying below ~40% leaves headroom for periodic tasks, messaging, and future expansion."},
    {"question":"Why use one program per equipment area?","options":["To increase CPU load","To enable parallel work without merge conflicts and keep tags scoped","To reduce memory","To bypass the MainRoutine"],"answer":1,"explanation":"Per-area programs scope tags and let multiple engineers work in parallel without conflicts."}
  ]'::jsonb
  WHERE title = 'Tasks, Programs & Routines' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

User-Defined Types (UDTs) and Add-On Instructions (AOIs) are the two reuse mechanisms that elevate a Logix project from a collection of tags and rungs to a structured, maintainable codebase. UDTs define data structures; AOIs define reusable logic. Together they let a team build a library of standard device and data definitions that are consistent across projects, reviewed once, and instantiated many times. This lesson covers UDT design, AOI design, and the interaction between them.

## Key Concepts

**User-Defined Types (UDTs).** A UDT is a custom data structure composed of members (atomic types, other UDTs, or arrays). UDTs let you model a device or a function as a single structured tag: a Motor UDT might have Cmd (Start, Stop), Status (Running, Faulted, FaultCode), and Config (StartType, FaultTime). UDTs make the data self-documenting (the tag name plus the member name tells you what it is), reduce tag-table clutter (one Motor tag instead of 20 scalars), and stabilize the AOI interface (the UDT is the parameter type). Version UDTs carefully — adding members is backward-compatible; removing or reordering is not.

**Add-On Instructions (AOIs).** An AOI encapsulates reusable logic with a defined interface (input, output, in-out parameters) and private local tags. The caller sees only the parameter list; the internal logic and local tags are hidden and protected. AOIs support multiple routines (Main, EnableInFalse, pre-scan), and each instance maintains its own local tags — ideal for stateful devices. AOIs version cleanly and can be locked after safety review. Use AOIs for reusable, stateful, cleanly-bounded logic; use subroutines for one-off, tightly-coupled logic.

**UDT and AOI Interaction.** The standard pattern is to define a UDT for the device''s data and an AOI for the device''s behavior, with the AOI taking the UDT as an in-out parameter. This separates data (the UDT instance) from logic (the AOI), so the same AOI works on any instance of the UDT. The Motor UDT plus the Motor AOI is a reusable component: instantiate a Motor tag, call the Motor AOI with it, and the device is fully defined and behaves consistently.

**Versioning and the AOI Library.** Manage UDTs and AOIs as a library: export to .L5X, store in source control, and import into new projects. Version the library (e.g., v1.2) and document the revision history. When a UDT or AOI changes, import the new version into existing projects; backward-compatible changes (adding a member, adding logic) update cleanly, while breaking changes require a migration. Lock AOIs that have passed safety review.

## Best Practices

- Define a UDT for each device type (Motor, Valve, AnalogAlarm) and an AOI for its behavior, with the UDT as the in-out parameter.
- Make UDTs self-documenting via descriptive member names and descriptions.
- Manage UDTs and AOIs as a versioned library in source control (.L5X export).
- Lock AOIs that have passed safety or validation review.
- Prefer backward-compatible UDT changes (adding members); document and plan breaking changes.

## Common Pitfalls

- **Dozens of scalar tags instead of a UDT** clutters the tag table and loses the device model.
- **AOIs without UDT parameters** have unwieldy scalar parameter lists.
- **Unlocked safety AOIs** can be silently edited, invalidating the review.
- **Unversioned libraries** diverge across projects into "almost-the-same" copies.
- **Breaking UDT changes without a migration plan** corrupt existing instances.

## Real-World Example

A systems integrator built a standard library of 30 UDT/AOI pairs (motor, valve, analog alarm, mode logic, sequencer) used across 50 projects. A single Motor AOI update (adding a phase-loss alarm) rolled out to all 50 projects via .L5X import, and the UDT''s self-documenting structure let the HMI team build one faceplate that bound to any Motor instance. The library turned bespoke per-project code into a consistent, maintainable asset.

## Knowledge Check

Review UDT structure and versioning, AOI encapsulation and the in-out UDT pattern, the library management via .L5X, and the locking of safety-reviewed AOIs before the quiz.',
  quiz = '[
    {"question":"What is a User-Defined Type (UDT)?","options":["A reusable logic block","A custom data structure composed of members","A type of task","A routine type"],"answer":1,"explanation":"A UDT is a custom data structure that models a device or function as a single structured tag."},
    {"question":"What is the standard pattern for UDT/AOI interaction?","options":["Define the AOI first, then the UDT","Define a UDT for the device data and an AOI for its behavior, with the UDT as an in-out parameter","Never use UDTs with AOIs","Use only scalar parameters"],"answer":1,"explanation":"The UDT holds the data; the AOI holds the behavior; the UDT is passed as an in-out parameter to the AOI."},
    {"question":"Why make UDTs self-documenting via member names and descriptions?","options":["To increase memory use","The tag plus member name tells you what it is, and HMI tooltips rely on descriptions","To slow the scan","To confuse reviewers"],"answer":1,"explanation":"Self-documenting UDTs make the data model clear and support HMI tooltips and printed reports."},
    {"question":"How should UDTs and AOIs be managed across projects?","options":["Manually copy each time","As a versioned library exported to .L5X and stored in source control","Email the .ACD file","Never reuse them"],"answer":1,"explanation":"A versioned .L5X library in source control gives consistent, reproducible reuse across projects."},
    {"question":"What is a backward-compatible UDT change?","options":["Removing a member","Adding a member","Reordering members","Deleting the UDT"],"answer":1,"explanation":"Adding a member is backward-compatible; removing or reordering is a breaking change requiring migration."},
    {"question":"Why lock AOIs that have passed safety review?","options":["To speed up execution","To prevent unauthorized edits and preserve the reviewed version","To free memory","To disable the AOI"],"answer":1,"explanation":"Locking preserves the reviewed version and prevents uncontrolled modification of safety-relevant logic."},
    {"question":"What is a benefit of the UDT/AOI library in the example?","options":["Per-project bespoke code","A single AOI update rolled out to 50 projects via .L5X import","Slower development","Higher cost"],"answer":1,"explanation":"A versioned library lets a single fix propagate to all projects via import, turning bespoke code into a consistent asset."}
  ]'::jsonb
  WHERE title = 'User-Defined Types & Add-On Instructions' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

I/O configuration, tag aliasing, and project scalability determine whether a Logix project grows gracefully or collapses under its own weight. The decisions made during I/O configuration — how physical I/O is addressed, how tags alias to it, how the project is structured for growth — set the trajectory for the entire project lifecycle. This lesson covers I/O configuration strategies, aliasing for hardware independence, and the scalability practices that keep large projects manageable.

## Key Concepts

**I/O Configuration.** I/O is configured in the controller organizer as a tree of modules under the controller. Local I/O sits in the same chassis; remote I/O connects via a network (EtherNet/IP, ControlNet, DeviceNet) and appears under a communication module. Each module has a slot or node address, an electronic keying setting (exact match, compatible module, disable keying), and a connection that consumes controller resources (connections are finite — a large remote I/O network can exhaust them). Configure modules with the correct catalog number and firmware revision to match the physical hardware.

**Electronic Keying.** Electronic keying prevents inserting the wrong module into a slot. "Exact Match" requires the same catalog number and revision — safest but least flexible for spares. "Compatible Module" allows a module with compatible features — flexible for spares but requires care. "Disable Keying" accepts any module — fastest but riskiest. Use Exact Match for safety-critical and motion modules; Compatible for general I/O where spare flexibility matters.

**Tag Aliasing.** An alias tag is a tag that points to another tag — typically a controller-scoped tag that aliases a physical I/O address (e.g., Motor1_Start aliases Local:1:I.Data.0). Aliasing decouples logic from hardware: the logic references Motor1_Start, and if the I/O is re-addressed during commissioning, only the alias changes, not the logic. This is the foundation of hardware-independent development: write and test logic against alias tags before the I/O is physically wired, then point the aliases at the real I/O when it is ready.

**Project Scalability.** A scalable project is organized so that adding equipment does not require restructuring. Use one program per equipment area, a standard set of routines per program (Auto, Manual, Fault, Alarm), a standard UDT/AOI library, and consistent naming. Size the controller for 5-year growth (I/O count, memory, connections). Use program-scoped tags by default so new programs do not interfere with existing ones. Document the structure so that the next engineer can extend it without reverse-engineering.

## Best Practices

- Use alias tags to decouple logic from physical I/O addresses, enabling hardware-independent development.
- Choose electronic keying by risk: Exact Match for safety and motion, Compatible for general I/O.
- Organize one program per equipment area with a standard routine set and naming convention.
- Size the controller for 5-year growth in I/O, memory, and connections.
- Use program-scoped tags by default so new programs do not interfere with existing ones.

## Common Pitfalls

- **Direct I/O references in logic** require editing the logic if I/O is re-addressed.
- **Disable Keying on safety modules** accepts the wrong module and defeats the safety intent.
- **One giant program** cannot scale and cannot be worked on in parallel.
- **Undersized controller** becomes a bottleneck within years.
- **All tags controller-scoped** creates coupling that makes adding equipment risky.

## Real-World Example

A packaging line was developed with all logic referencing alias tags (Motor1_Start, Valve2_Open) before the I/O was physically wired. The integrator tested the logic against simulated I/O, then pointed the aliases at the real I/O during commissioning. When a wiring error required moving two inputs to different terminals, only the aliases changed — no logic was edited, and no regression risk was introduced. Aliasing made the re-addressing a 5-minute change instead of a 2-hour retest.

## Knowledge Check

Review I/O configuration and electronic keying, aliasing for hardware independence, and the scalability practices (per-area programs, standard routines, 5-year sizing) before the quiz.',
  quiz = '[
    {"question":"What does a tag alias do?","options":["Runs faster","Points to another tag, typically decoupling logic from a physical I/O address","Stores a constant","Replaces a UDT"],"answer":1,"explanation":"An alias points to another tag, letting logic reference a logical name while the alias targets the physical I/O."},
    {"question":"Which electronic keying setting is safest but least flexible for spares?","options":["Disable Keying","Compatible Module","Exact Match","Auto Keying"],"answer":2,"explanation":"Exact Match requires the same catalog and revision \u2014 safest but inflexible for spares."},
    {"question":"Why use alias tags for I/O?","options":["To increase scan time","To decouple logic from physical I/O addresses, enabling hardware-independent development","To reduce memory","To bypass keying"],"answer":1,"explanation":"Aliasing lets logic reference a logical name; re-addressing I/O changes only the alias, not the logic."},
    {"question":"What is a scalability best practice for large projects?","options":["One giant program","One program per equipment area with a standard routine set","All tags controller-scoped","Disable keying everywhere"],"answer":1,"explanation":"Per-area programs with standard routines scale cleanly and enable parallel work."},
    {"question":"How should the controller be sized?","options":["For today\u2019s I/O only","For 5-year growth in I/O, memory, and connections","For the smallest available model","For the cheapest option"],"answer":1,"explanation":"Sizing for 5-year growth prevents the controller from becoming a bottleneck within years."},
    {"question":"Why use program-scoped tags by default?","options":["To increase coupling","So new programs do not interfere with existing ones","To use more memory","To bypass the MainRoutine"],"answer":1,"explanation":"Program-scoped tags isolate programs, so adding equipment does not risk breaking existing logic."},
    {"question":"What did aliasing enable in the packaging line example?","options":["Slower commissioning","Re-addressing I/O by changing only aliases, with no logic edits","Higher cost","More wiring"],"answer":1,"explanation":"When wiring required moving inputs, only the aliases changed \u2014 no logic edits, no regression risk."}
  ]'::jsonb
  WHERE title = 'I/O Configuration, Tag Aliasing & Project Scalability' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add new module (sort_order 3) with 2 lessons
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Project Features & Diagnostics', 3) RETURNING id INTO m_id;

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Produced/Consumed Tags & Message Instructions', '## Overview

Produced/Consumed tags and Message instructions are the two mechanisms Logix controllers use to share data with other controllers and devices. Produced/Consumed tags provide automatic, periodic data exchange between controllers on the same network; Message instructions (MSG) provide explicit, on-demand communication to any device that speaks a supported protocol. Choosing the right mechanism and configuring it correctly is essential for multi-controller systems and for integration with SCADA, drives, and instruments.

## Key Concepts

**Produced/Consumed Tags.** A controller produces a tag (the producer) and one or more controllers consume it (the consumers). The producer pushes the tag''s value to consumers at a configured RPI (Requested Packet Interval); consumers receive it automatically without any logic. Produced/Consumed tags are ideal for inter-controller interlocks and shared state (system mode, production counts) where low-latency, automatic exchange is needed. Each produced tag consumes a connection on the producer and each consumer; connections are finite, so plan them. The consumer''s controller must be in the producer''s I/O tree (or use a generic CIP connection for third-party devices).

**Message Instructions (MSG).** A MSG instruction explicitly reads or writes data to another device on demand. MSG supports CIP (Logix-to-Logix, to PanelView, to drives), CIP Generic (third-party CIP devices), and SLC/PLC-2/PLC-3/PLC-5 legacy protocols via a DHRIO or ENI module. MSG is ideal for on-demand queries (read a recipe when needed), for large data transfers that do not need periodic updates, and for devices that do not support Produced/Consumed. Each MSG consumes a connection while in progress; manage connection count by limiting concurrent MSGs.

**Choosing Between Them.** Use Produced/Consumed for continuous, low-latency, automatic data exchange between controllers (interlocks, shared state). Use MSG for on-demand, large, or non-Logix communication (recipe reads, drive parameter access, legacy PLC integration). Produced/Consumed is simpler and automatic but consumes connections continuously; MSG is flexible but requires logic to trigger and to handle errors.

**Error Handling and Diagnostics.** Produced/Consumed tag connections can fail; the consumer sees the tag as stale and can detect the failure via the connection''s status bits. MSG instructions return error codes (in the message control structure) that must be checked; an unchecked MSG that fails silently produces a system that "sometimes" works. Always check MSG error bits and log failures; always monitor Produced/Consumed connection status and drive the consumer to a safe state on connection loss.

## Best Practices

- Use Produced/Consumed for continuous, low-latency inter-controller data; use MSG for on-demand and non-Logix communication.
- Plan connection count — each Produced tag and each in-flight MSG consumes a connection.
- Always check MSG error bits and log failures; an unchecked MSG fails silently.
- Monitor Produced/Consumed connection status and drive the consumer to a safe state on connection loss.
- Use a generic CIP connection for third-party devices that support CIP but are not Logix.

## Common Pitfalls

- **Exhausting connections** by over-using Produced/Consumed or concurrent MSGs.
- **Unchecked MSG errors** produce intermittent "sometimes works" behavior.
- **No safe state on Produced/Consumed loss** lets the consumer act on stale data.
- **Using MSG for periodic data** that would be simpler and more reliable as Produced/Consumed.
- **No connection count planning** leads to "cannot add another device" late in the project.

## Real-World Example

A multi-controller line used Produced/Consumed tags for inter-controller interlocks (system mode, e-stop status) and MSG for on-demand recipe downloads from a supervisory controller. The interlocks updated automatically every 5 ms; the recipes downloaded only when the operator selected a new product. A connection-count review during FAT caught that the design would exhaust connections if a 15th conveyor was added; the team consolidated some Produced tags and left headroom for growth.

## Knowledge Check

Review when to use Produced/Consumed vs. MSG, connection planning, MSG error handling, and safe-state behavior on connection loss before the quiz.',
  45, 1,
  '[
    {"question":"When should you use Produced/Consumed tags?","options":["For on-demand recipe reads","For continuous, low-latency, automatic inter-controller data exchange","For legacy PLC communication","For drive parameter access"],"answer":1,"explanation":"Produced/Consumed tags provide automatic, periodic exchange ideal for interlocks and shared state."},
    {"question":"When should you use Message (MSG) instructions?","options":["For continuous interlocks","For on-demand, large, or non-Logix communication","For automatic tag exchange","For safety functions"],"answer":1,"explanation":"MSG is for on-demand queries, large transfers, and devices that do not support Produced/Consumed."},
    {"question":"What does each Produced tag and each in-flight MSG consume?","options":["Memory only","A connection","A task","A routine"],"answer":1,"explanation":"Connections are finite; each Produced tag and in-flight MSG consumes one, so plan the count."},
    {"question":"What must you do with MSG error bits?","options":["Ignore them","Check them and log failures","Delete them","Disable them"],"answer":1,"explanation":"Unchecked MSG errors fail silently; always check error bits and log failures."},
    {"question":"What should a consumer do on Produced/Consumed connection loss?","options":["Continue on stale data","Drive to a safe state","Ignore the loss","Restart the controller"],"answer":1,"explanation":"On connection loss, the tag is stale; the consumer must drive to a safe state, not act on stale data."},
    {"question":"How can third-party CIP devices be connected for Produced/Consumed?","options":["They cannot","Via a generic CIP connection","Via Modbus only","Via a hard-wired relay"],"answer":1,"explanation":"Third-party CIP devices use a generic CIP connection in the I/O tree to consume produced tags."},
    {"question":"What did the connection-count review catch in the example?","options":["A wiring error","That adding a 15th conveyor would exhaust connections","A firmware bug","A missing UDT"],"answer":1,"explanation":"The review found the design would exhaust connections at 15 conveyors; consolidating tags left headroom."}
  ]'::jsonb);

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Diagnostics, Trending & Controller Performance Analysis', '## Overview

A Logix controller provides a rich set of built-in diagnostics that, used well, turn troubleshooting from guesswork into measurement. Task execution time, CPU loading, connection status, I/O faults, and the trend tool together let an engineer see what the controller is actually doing — not what it is assumed to be doing. This lesson covers the diagnostic resources in Studio 5000, the trend tool, and the performance analysis that keeps a controller healthy throughout its life.

## Key Concepts

**Task and CPU Diagnostics.** The controller properties display the CPU usage of each task (Continuous, Periodic, Event) and the total CPU utilization. The task watchdog for each task shows the maximum scan time and the configured timeout. These diagnostics reveal whether a task is approaching its watchdog limit, whether the Continuous task is over-loaded, and whether a periodic task is overrunning its interval. Monitor these during commissioning and periodically thereafter; a controller at 70% CPU at commissioning has no room to grow.

**I/O and Connection Diagnostics.** Each I/O module displays its connection status, module status, and any fault. A module''s connection status shows whether it is communicating; the module status shows run/no-run and any fault code. The controller''s connection list shows all connections (Produced/Consumed, I/O, MSG) and their status. Use these to diagnose a lost module, a failed remote I/O link, or an exhausted connection count. Log I/O faults with timestamps for post-mortem analysis.

**The Trend Tool.** The trend tool plots tag values over time, like a portable oscilloscope for the controller. Trends are essential for diagnosing intermittent behavior, tuning loops, and verifying motion following error. Configure trends with an appropriate sample rate (faster than the phenomenon of interest) and duration (long enough to capture the event). Save trend configurations so they can be recalled during troubleshooting. Trends turn "it sometimes misses" into "the following error spikes to 2 mm at 80 m/min."

**Performance Analysis.** Periodically review task execution times, CPU loading, connection count, and I/O fault history. A gradual increase in CPU loading or task execution time indicates growth that will eventually hit a limit. A recurring I/O fault on a specific module indicates a hardware or environmental issue. Trend these metrics over months to see the trajectory; a controller that was healthy at commissioning can degrade silently as the project grows and the environment changes.

## Best Practices

- Monitor task execution times and CPU loading during commissioning and periodically thereafter.
- Use the controller''s connection list to diagnose lost modules and connection exhaustion.
- Configure trends with an appropriate sample rate and duration; save configurations for recall.
- Log I/O faults with timestamps for post-mortem analysis.
- Trend CPU loading, task times, and I/O faults over months to see the trajectory.

## Common Pitfalls

- **Ignoring CPU loading** until a watchdog fault stops the controller.
- **No trend configured** when an intermittent fault occurs, leaving the engineer guessing.
- **Unlogged I/O faults** make post-mortem analysis impossible.
- **No periodic performance review** lets gradual degradation go unnoticed until a limit is hit.
- **Trends with the wrong sample rate** miss the phenomenon of interest.

## Real-World Example

A machine had intermittent "position fault" alarms that occurred a few times per shift. The team configured a trend of the axis following error at 10 ms sampling and caught a 2 mm spike that occurred exactly when a nearby conveyor started — electrical noise on the encoder cable. After re-routing the cable and adding shielding, the spikes disappeared. Without the trend, the team would have continued replacing parts; the trend turned the guess into a measurement.

## Knowledge Check

Review the task/CPU diagnostics, the I/O/connection diagnostics, the trend tool''s sample-rate and duration considerations, and the periodic performance review before the quiz.',
  45, 2,
  '[
    {"question":"What do the controller properties display for each task?","options":["Only the task name","CPU usage, max scan time, and watchdog timeout","The tag count","The I/O count"],"answer":1,"explanation":"Task properties show CPU usage, max scan time, and watchdog timeout, revealing whether a task is approaching its limit."},
    {"question":"What does the controller\u2019s connection list show?","options":["Only local I/O","All connections (Produced/Consumed, I/O, MSG) and their status","The tag table","The task list"],"answer":1,"explanation":"The connection list shows every connection and its status, diagnosing lost modules and connection exhaustion."},
    {"question":"What is the trend tool used for?","options":["Editing logic","Plotting tag values over time to diagnose intermittent behavior and tune loops","Configuring I/O","Backing up the project"],"answer":1,"explanation":"Trends plot tag values over time, like a portable oscilloscope, essential for intermittent-fault diagnosis."},
    {"question":"How should a trend\u2019s sample rate be chosen?","options":["As slow as possible","Faster than the phenomenon of interest","Always 1 second","Irrelevant"],"answer":1,"explanation":"The sample rate must be fast enough to capture the phenomenon; too slow misses the event."},
    {"question":"Why log I/O faults with timestamps?","options":["To increase storage","For post-mortem analysis and pattern detection","To slow the scan","To confuse operators"],"answer":1,"explanation":"Timestamped fault logs let you correlate faults with events and find patterns during post-mortem."},
    {"question":"What does a gradual increase in CPU loading indicate?","options":["The controller is failing","Growth that will eventually hit a limit","A firmware bug","Nothing"],"answer":1,"explanation":"Gradual loading growth signals future exhaustion; trending it over months shows the trajectory."},
    {"question":"What did the trend reveal in the example?","options":["A bad motor","A 2 mm following-error spike when a nearby conveyor started, caused by encoder cable noise","A software bug","A missing tag"],"answer":1,"explanation":"The trend caught the spike correlated with the conveyor start, pointing to electrical noise on the encoder cable."}
  ]'::jsonb);
END $$;