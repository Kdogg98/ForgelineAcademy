DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='System Architecture & Network Design';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lessons
  UPDATE lessons SET content = '## Overview

The Purdue Model is the reference architecture for industrial control system (ICS) security and segmentation. Originally developed for manufacturing at Purdue University, it defines hierarchical levels from the physical process (Level 0) up to the enterprise network (Level 5), with a demilitarized zone (DMZ) between manufacturing and enterprise. This lesson explains each level, the conduits that connect them, and how the model maps to a real, defensible OT network.

## Key Concepts

**The Purdue Levels.** Level 0 is the physical process — sensors and actuators. Level 1 is basic control (PLCs, RTUs). Level 2 is supervisory control (HMIs, local SCADA). Level 3 is manufacturing operations (site historian, scheduling, engineering workstations). Level 3.5 is the DMZ, a buffer that terminates connections so none traverse it directly. Level 4 is enterprise IT (ERP, corporate email). Level 5 is the internet/cloud boundary. Each level has distinct trust, traffic, and security requirements.

**Conduits and Zones.** IEC 62443 formalizes the Purdue Model with zones (groupings of assets with similar security requirements) and conduits (the controlled communication paths between zones). Every conduit must have a defined purpose, an allowlist of protocols and endpoints, and a security control (firewall, data diode, authenticated gateway). The principle is deny-by-default: a conduit carries only what is explicitly permitted.

**The DMZ (Level 3.5).** The DMZ is the single most important architectural element. It hosts forward-facing services (historian relay, jump host, patch server, AV relay) so that enterprise users access a DMZ service, not the OT network directly. No connection traverses the DMZ; each terminates there. This means a compromised enterprise host cannot pivot straight to a PLC.

**Mapping to Reality.** A typical implementation: Level 0–2 on a dedicated OT VLAN per cell; Level 3 on a site-wide OT backbone; a firewall between Level 3 and the DMZ; a firewall between the DMZ and Level 4. Remote access lands in the DMZ via a jump host with multi-factor authentication and session recording. Internet egress for OT devices, if any, is proxied through the DMZ.

## Best Practices

- Use the Purdue Model as a design checklist, not a rigid prescription; adapt to site realities.
- Place a DMZ between OT and IT; never allow a direct connection to traverse it.
- Define every inter-zone conduit with an allowlist and a security control.
- Terminate remote access in the DMZ via a jump host with MFA and session recording.
- Document the zone and conduit model in a network architecture diagram that is kept current.

## Common Pitfalls

- **Flat networks** with no segmentation let a single compromise reach every PLC.
- **Direct IT-to-OT connections** bypass the DMZ and defeat the model.
- **Undocumented conduits** accumulate over years of "temporary" fixes.
- **Remote access without MFA or recording** is a primary intrusion vector.
- **Treating the model as a prescription** instead of a checklist leads to unworkable designs.

## Real-World Example

A food and beverage manufacturer discovered during a risk assessment that its historian was dual-homed between the OT and enterprise networks — a direct conduit that bypassed the DMZ. After re-architecting with a DMZ historian relay and a jump host for engineering access, the OT network became unreachable from a compromised enterprise host. A later phishing attack that compromised enterprise desktops had no path into the controllers.

## Knowledge Check

Recall the Purdue levels, the role of zones and conduits, the purpose of the DMZ, and the deny-by-default conduit principle before the quiz.',
  quiz = '[
    {"question":"What does Level 3.5 represent in the Purdue Model?","options":["The enterprise network","The DMZ between OT and IT","The physical process","The internet"],"answer":1,"explanation":"Level 3.5 is the demilitarized zone that buffers manufacturing (Level 3) from enterprise (Level 4)."},
    {"question":"What is a conduit in IEC 62443 terminology?","options":["A physical cable","A controlled communication path between zones with a defined allowlist and security control","A type of PLC","A firewall brand"],"answer":1,"explanation":"A conduit is the controlled path between zones, carrying only explicitly permitted traffic."},
    {"question":"What is the key rule for the DMZ?","options":["No connection should traverse it; each terminates there","All traffic passes through it unfiltered","It stores the historian database","It replaces the firewall"],"answer":0,"explanation":"The DMZ terminates connections so that no direct path exists between enterprise and OT."},
    {"question":"Where should remote access to the OT network terminate?","options":["Directly on a PLC","On a jump host in the DMZ with MFA and session recording","On the enterprise historian","On the HMI"],"answer":1,"explanation":"Remote access lands in the DMZ via a hardened jump host with MFA and recording."},
    {"question":"What does \"deny-by-default\" mean for a conduit?","options":["All traffic is allowed unless blocked","Only explicitly permitted traffic is allowed","No traffic is ever allowed","Only PLC traffic is allowed"],"answer":1,"explanation":"Deny-by-default means a conduit carries only what is explicitly allowed; everything else is dropped."},
    {"question":"Which Purdue level contains the site historian and engineering workstations?","options":["Level 0","Level 1","Level 3","Level 5"],"answer":2,"explanation":"Level 3 (manufacturing operations) hosts the site historian, scheduling, and engineering workstations."},
    {"question":"What is a common pitfall that defeats the Purdue Model?","options":["Using a DMZ","Direct IT-to-OT connections that bypass the DMZ","Documenting conduits","Using VLANs"],"answer":1,"explanation":"Direct IT-to-OT connections bypass the DMZ and create a path for lateral movement into the OT network."}
  ]'::jsonb
  WHERE title = 'The Purdue Model & OT Security' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  UPDATE lessons SET content = '## Overview

Controller selection and redundancy are architectural decisions made early — and expensive to reverse. The choice of controller family, the decision to redundantize, and the redundancy topology determine the system''s availability, its maintenance burden, and its cost. This lesson covers the criteria for controller selection, the patterns and limits of redundancy, and the trade-offs that engineers must make consciously rather than by default.

## Key Concepts

**Controller Selection Criteria.** Selection is driven by I/O count and type, memory and task requirements, communication ports and protocols, motion axes, safety integration, and environmental rating. Match the controller to the application: a CompactLogix for a 200-I/O cell, a ControlLogix for a 2,000-I/O line with motion and safety. Consider lifecycle: firmware support windows, spare availability, and migration paths. Avoid selecting on price alone — a too-small controller becomes a bottleneck within years.

**Redundancy Patterns.** Hot-standby redundancy uses two controllers: a primary that owns the I/O and a standby that mirrors it and takes over on primary failure. Switchover is automatic but not instantaneous (typically 50–500 ms), so the process must tolerate the gap. Redundancy covers controller failure only — not I/O, network, or power, which need their own redundancy. Cold and warm standby (slower, manual) are cheaper but unacceptable for continuous processes.

**Redundancy Limits.** Redundancy improves availability for random hardware failure but does not improve safety and does not protect against common-cause failures: a firmware bug, a configuration error, or a power surge takes both controllers. Redundancy also adds complexity — synchronization links, dual power, dual network — each a new failure mode. Treat redundancy as one layer in a defense-in-depth strategy, not a silver bullet.

**Power and Network Redundancy.** A redundant controller on a single power feed and a single network is a single point of failure in disguise. Pair controller redundancy with dual power supplies (on separate feeds) and a redundant ring or star-trunked network so that no single failure isolates the controller from its I/O.

## Best Practices

- Select the controller family against a 5-year I/O and feature growth projection, not just today''s count.
- Use hot-standby redundancy only where the process cannot tolerate a manual restart.
- Pair controller redundancy with dual power and redundant network paths.
- Document the redundancy topology, switchover behavior, and expected gap so operators know what to expect.
- Test switchover under load during commissioning; an untested failover is a hope, not a guarantee.

## Common Pitfalls

- **Redundant controller, single power feed** — the feed fails and both controllers die.
- **Redundant controller, single network** — the network fails and the standby cannot see the I/O.
- **Assuming redundancy improves safety** — it does not; use safety-rated controllers and functions for safety.
- **Untested switchover** fails when it matters.
- **Over-redundancy** adds cost and complexity beyond what the process justifies.

## Real-World Example

A chemical plant redundantized its controllers but left a single power feed to the rack. A maintenance worker tripped the feed during cleaning, and both controllers — primary and standby — lost power simultaneously, stopping the reactor. After adding dual feeds from separate switchgear and a redundant ring network, a later feeder trip caused a seamless switchover with no process interruption.

## Knowledge Check

Review controller selection criteria, hot-standby redundancy behavior and limits, the need to pair controller redundancy with power and network redundancy, and the distinction between availability and safety before the quiz.',
  quiz = '[
    {"question":"What does hot-standby redundancy protect against?","options":["All possible failures","Random hardware failure of the controller","Firmware bugs","Power surges"],"answer":1,"explanation":"Hot-standby redundancy covers random controller hardware failure; it does not protect against common-cause failures."},
    {"question":"What is a typical switchover time for hot-standby redundancy?","options":["Instantaneous (0 ms)","50–500 ms","5 seconds","5 minutes"],"answer":1,"explanation":"Switchover is automatic but not instantaneous; the process must tolerate a 50–500 ms gap."},
    {"question":"Why is a redundant controller on a single power feed a hidden single point of failure?","options":["It isn''t","Both controllers lose power if the feed fails","The standby draws too much current","Redundancy is illegal"],"answer":1,"explanation":"A single feed means one failure kills both controllers; pair redundancy with dual feeds."},
    {"question":"Does controller redundancy improve safety?","options":["Yes, always","No — use safety-rated controllers and safety functions for safety","Only if the standby is larger","Only for motion"],"answer":1,"explanation":"Redundancy improves availability, not safety; safety requires safety-rated controllers and functions."},
    {"question":"What should controller selection be based on?","options":["Price alone","A 5-year I/O and feature growth projection, plus lifecycle support","The smallest available model","The vendor''s default"],"answer":1,"explanation":"Select against a growth projection and lifecycle support window, not just today''s count or price."},
    {"question":"When should switchover be tested?","options":["Only during a real failure","During commissioning, under load","Never","After the first outage"],"answer":1,"explanation":"Testing switchover under load during commissioning verifies the failover actually works."},
    {"question":"What is a common-cause failure that redundancy does not protect against?","options":["A CPU hardware fault","A firmware bug or configuration error","A network cable cut","A power feeder trip on a single feed"],"answer":1,"explanation":"Common-cause failures (firmware bugs, config errors) affect both controllers, so redundancy offers no protection."}
  ]'::jsonb
  WHERE title = 'Redundancy & Controller Selection' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2 with 2 lessons
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'System Integration & Data Flow', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'SCADA, MES & Enterprise Integration', '## Overview

Modern industrial systems are not islands. A controller''s data flows upward to SCADA for operator visibility, to MES for production tracking and traceability, and to ERP for business planning. Each integration has its own protocol, latency, and reliability expectations, and each is a potential attack surface and a potential single point of failure. This lesson covers the integration stack, the protocols that connect it, and the architectural patterns that keep it reliable and secure.

## Key Concepts

**The Integration Stack.** At the bottom, PLCs expose data via EtherNet/IP, Modbus TCP, OPC UA, or proprietary protocols. SCADA (Ignition, Wonderware, FactoryTalk) reads that data for operator visualization and control. MES captures production events (counts, downtime, genealogy) for execution and traceability. ERP (SAP, Oracle) consumes aggregated production data for planning and finance. Each layer abstracts the one below; each adds latency and a failure mode.

**Protocols and Trade-offs.** EtherNet/IP is native to Logix but is a control protocol, not an integration protocol — using it for high-volume historian data loads the controller. OPC UA provides a standardized, vendor-neutral interface with structured data and security, and is the preferred integration protocol for modern SCADA and MES. Modbus TCP is simple and ubiquitous but unauthenticated and unstructured. MQTT (often with Sparkplug B) enables publish/subscribe integration that scales to many consumers without loading the controller.

**The Historian as Integration Hub.** A site historian (often in the DMZ) collects data from controllers and republishes it to MES, ERP, and analytics. This decouples consumers from the controller: adding a new consumer does not touch the PLC, and the controller is insulated from consumer failures. The historian also provides buffering so that short network outages do not lose data.

**Security at Each Boundary.** Every integration point is an attack surface. Use OPC UA with signing and encryption, restrict MQTT brokers to authenticated clients, and place integration services in the DMZ. Never expose a PLC directly to the enterprise; route through a gateway or historian that can enforce access control and logging.

## Best Practices

- Use OPC UA with signing and encryption as the default integration protocol.
- Place the historian and integration gateways in the DMZ; do not expose controllers directly.
- Decouple consumers from controllers via a historian or broker so adding consumers does not load the PLC.
- Choose the protocol to the use case: OPC UA for structured SCADA/MES, MQTT/Sparkplug for many-consumer telemetry, Modbus only for legacy.
- Document every integration point, its protocol, and its security controls in the architecture diagram.

## Common Pitfalls

- **Direct PLC-to-ERP connections** load the controller and expose it to the enterprise.
- **Unauthenticated Modbus TCP** lets anyone on the network read and write registers.
- **No buffering** means a short network outage loses data permanently.
- **Undocumented integrations** accumulate and become unmaintainable.
- **Using EtherNet/IP for high-volume historian polling** starves control traffic.

## Real-World Example

A manufacturer had 12 consumers (SCADA, MES, two analytics platforms, an energy dashboard) each polling its PLCs directly via EtherNet/IP, loading the controllers and causing intermittent control timeouts. After deploying an OPC UA aggregator in the DMZ that collected once and republished to all consumers via MQTT/Sparkplug, controller CPU dropped 30% and adding a 13th consumer was a broker configuration, not a PLC change.

## Knowledge Check

Recall the integration stack (PLC → SCADA → MES → ERP), the protocol trade-offs (OPC UA, Modbus, MQTT/Sparkplug), the historian-as-hub pattern, and the security requirement at each boundary before the quiz.',
  45, 1,
  '[
    {"question":"Which protocol is preferred for modern, secure SCADA/MES integration?","options":["Unauthenticated Modbus TCP","OPC UA with signing and encryption","Raw EtherNet/IP Class 1 messaging","Telnet"],"answer":1,"explanation":"OPC UA provides structured data, signing, and encryption, making it the preferred secure integration protocol."},
    {"question":"Why place the historian in the DMZ?","options":["To speed up the PLC","To decouple consumers from controllers and avoid exposing PLCs to the enterprise","To reduce storage cost","To bypass authentication"],"answer":1,"explanation":"A DMZ historian collects once and republishes, decoupling consumers from the controller and protecting it."},
    {"question":"What problem does MQTT/Sparkplug B solve?","options":["Slow scan times","Publish/subscribe scaling to many consumers without loading the controller","Lack of EtherNet/IP","Firmware bugs"],"answer":1,"explanation":"MQTT/Sparkplug enables many consumers to subscribe without each polling the controller."},
    {"question":"What is a risk of direct PLC-to-ERP connections?","options":["They are faster","They load the controller and expose it to the enterprise network","They reduce cost","They improve security"],"answer":1,"explanation":"Direct PLC-to-ERP connections load the PLC and create an attack path from enterprise to OT."},
    {"question":"Why is unauthenticated Modbus TCP a risk?","options":["It is too slow","Anyone on the network can read and write registers","It uses too much memory","It is not widely supported"],"answer":1,"explanation":"Modbus TCP has no authentication or encryption; any reachable client can read and write registers."},
    {"question":"What does the historian provide during a short network outage?","options":["Faster polling","Buffering so data is not lost","Encryption","Lower latency"],"answer":1,"explanation":"Historians buffer data locally so that brief outages do not cause permanent data loss."},
    {"question":"Why avoid using EtherNet/IP for high-volume historian polling?","options":["It is not supported","It can starve control traffic by loading the controller","It is too secure","It requires a license"],"answer":1,"explanation":"EtherNet/IP is a control protocol; high-volume polling can consume controller CPU and starve control traffic."}
  ]'::jsonb);

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Time Synchronization & Data Historians', '## Overview

Time synchronization and data historians are the invisible infrastructure that makes everything else in an integrated system trustworthy. Without a common time base, event sequences across controllers are impossible to reconstruct; without a historian, every incident becomes a one-time story with no data. This lesson covers PTP and NTP time synchronization, historian architecture, and the data-quality flags that distinguish real measurements from stale guesses.

## Key Concepts

**Time Synchronization.** Industrial systems need sub-millisecond time alignment across controllers, I/O, and network switches to reconstruct event sequences. NTP (Network Time Protocol) provides millisecond-level alignment to a time server — adequate for many applications. IEEE 1588 PTP (Precision Time Protocol) provides sub-microsecond alignment using hardware-supported timestamping at the switch and NIC, and is required for sequence-of-events recording and IEC 61850. Choose PTP for sub-cycle event correlation and NTP for general SCADA.

**Historian Architecture.** A historian collects tagged data from controllers at a configured rate, time-stamps it, and stores it in a time-series database. Architecture choices: embedded (on the SCADA server, simple but limited), dedicated (a separate server, scalable), and distributed (a collector per site feeding a central database). Buffering at the collector survives network outages; redundancy at the database survives server failure. Retention policy (e.g., 1-second data for 30 days, 1-minute for 1 year, 1-hour for 10 years) balances storage cost against investigability.

**Data Quality.** Every tag carries a quality flag: Good (valid measurement), Bad (sensor failure, communication loss), or Uncertain (stale, out-of-range). A historian that stores Bad-quality data without flagging it poisons analytics — a "temperature" that is really a stale value looks real. Configure the historian to store quality alongside value and configure consumers to filter on it.

**Sequence of Events.** For fault analysis, a sequence-of-events (SOE) log records every state change with a high-resolution timestamp. SOE inputs are typically digital points wired to a dedicated SOE module with hardware timestamping. Combined with PTP, an SOE lets you reconstruct a cascade to the millisecond and identify the first-out event definitively.

## Best Practices

- Use PTP for sub-cycle event correlation and SOE; NTP for general SCADA and logging.
- Configure historian retention by resolution tier to balance storage and investigability.
- Store data quality alongside value; configure consumers to filter on quality.
- Buffer at the collector so short outages do not lose data.
- Document the time hierarchy (stratum-1 source, PTP grandmaster, NTP servers) and monitor for drift.

## Common Pitfalls

- **No common time base** makes cross-controller event correlation impossible.
- **Storing Bad-quality data as Good** poisons analytics and dashboards.
- **No retention tiering** either fills storage or loses resolution.
- **No collector buffering** loses data during every network blip.
- **Unmonitored time drift** silently corrupts timestamps until an incident exposes it.

## Real-World Example

A power distribution substation used PTP with hardware-timestamped SOE modules to record breaker operations. When a fault tripped three breakers within 8 ms, the SOE log showed the exact sequence and timing, identifying a protection coordination error. Without PTP, the timestamps would have been within 10–50 ms of each other — too coarse to distinguish cause from effect.

## Knowledge Check

Review PTP vs. NTP, historian architecture and retention tiering, the importance of data-quality flags, and sequence-of-events recording before the quiz.',
  45, 2,
  '[
    {"question":"Which protocol provides sub-microsecond time alignment with hardware timestamping?","options":["NTP","IEEE 1588 PTP","SNTP","DNS"],"answer":1,"explanation":"PTP uses hardware-supported timestamping at the switch and NIC for sub-microsecond alignment."},
    {"question":"What is NTP adequate for?","options":["Sub-cycle event correlation","General SCADA and logging at millisecond level","IEC 61850 sampling","Motion synchronization"],"answer":1,"explanation":"NTP provides millisecond-level alignment, suitable for general SCADA and event logging."},
    {"question":"Why store data quality alongside the value in a historian?","options":["To increase storage","To let consumers filter out Bad/Uncertain data and avoid poisoning analytics","To speed up queries","To reduce network traffic"],"answer":1,"explanation":"Storing quality lets consumers distinguish real measurements from stale or failed values."},
    {"question":"What does historian retention tiering balance?","options":["Security and cost","Storage cost against investigability (resolution over time)","Speed and accuracy","Redundancy and simplicity"],"answer":1,"explanation":"Tiering keeps high-resolution data short-term and lower-resolution data long-term to balance cost and usefulness."},
    {"question":"What does collector buffering protect against?","options":["Security breaches","Data loss during short network outages","Time drift","Disk failure"],"answer":1,"explanation":"Buffering at the collector stores data locally so brief outages do not cause permanent loss."},
    {"question":"What is a sequence-of-events (SOE) log used for?","options":["Energy billing","Reconstructing event sequences with high-resolution timestamps for fault analysis","Operator training","Alarm silencing"],"answer":1,"explanation":"SOE records state changes with high-resolution timestamps to reconstruct cascades and find first-out events."},
    {"question":"What happens if Bad-quality data is stored as Good?","options":["Faster queries","Analytics and dashboards treat stale or failed values as real measurements","Lower storage cost","Better security"],"answer":1,"explanation":"Unflagged Bad data poisons analytics, making stale or failed values appear valid."}
  ]'::jsonb);

  -- Add module 3 with 2 lessons
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Documentation & Lifecycle Management', 3) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Architecture Documentation & Diagrams', '## Overview

An architecture that is not documented is an architecture that cannot be reviewed, maintained, or handed off. Good architecture documentation is the bridge between the design intent and the people who must operate, modify, and audit the system for decades. This lesson covers what diagrams an industrial system needs, the standards that make them useful, and the lifecycle that keeps them current.

## Key Concepts

**Required Diagrams.** A complete architecture documentation set includes: a network architecture diagram (Purdue zones, conduits, IP subnets, firewalls), a control system architecture (controllers, I/O, safety systems, redundancy), a P&ID / process flow diagram (instruments and control loops), an electrical one-line (power distribution and redundancy), and an I/O map (tag to physical point). Each diagram answers a different question for a different audience; none substitutes for another.

**Standards and Conventions.** Use recognized symbols (ISA-5.1 for P&IDs, IEC 60617 for electrical) so that any engineer can read the drawings. Maintain a consistent scale, title block, revision history, and cross-reference scheme. Use layers in CAD to separate disciplines (process, electrical, control) so each audience can filter to what they need.

**The Living Document.** Documentation that is not updated is worse than none — it actively misleads. Tie documentation updates to the change-request workflow: no change is closed until the affected drawings are updated and reviewed. Store documentation in a document management system with version control, access control, and a review/approve cycle. The "as-built" must match the field, not the original design.

**Handoff and Onboarding.** A new engineer or contractor should be able to understand the system from the documentation alone. Include a system narrative (what the system does, its operating modes, its known issues), a glossary of tag names and abbreviations, and a pointer to the current code revision. Test the documentation by having someone unfamiliar walk through it before accepting it.

## Best Practices

- Produce all five required diagram types; do not let one substitute for another.
- Use standard symbols (ISA-5.1, IEC 60617) so any engineer can read the drawings.
- Tie documentation updates to the change-request workflow; no change is closed until drawings are updated.
- Store documentation in a DMS with version control and a review/approve cycle.
- Validate documentation by having an unfamiliar engineer walk through it before acceptance.

## Common Pitfalls

- **Stale drawings** that do not match the field mislead troubleshooters and cause errors.
- **Missing diagram types** leave gaps that no other diagram fills.
- **Non-standard symbols** are unreadable outside the original team.
- **No narrative** leaves the drawings without context.
- **Documentation outside change control** drifts silently from reality.

## Real-World Example

A water utility lost its original integrator and found that the network diagram was three years out of date — it showed a flat network that had since been segmented. A subsequent incident response was delayed because responders relied on the stale diagram. After tying drawing updates to the change-request workflow and auditing the documentation annually, the utility maintained drawings that matched the field and could onboard a new integrator in days.

## Knowledge Check

Recall the five required diagram types, the value of standard symbols, the tie between documentation and change control, and the onboarding test before the quiz.',
  45, 1,
  '[
    {"question":"Which five diagram types does a complete architecture set include?","options":["Only a P&ID","Network, control system, P&ID, electrical one-line, and I/O map","Only a network diagram","Only an electrical one-line"],"answer":1,"explanation":"Each diagram answers a different question for a different audience; none substitutes for another."},
    {"question":"Which standard governs P&ID symbols?","options":["IEC 60617","ISA-5.1","IEEE 1588","IEC 62443"],"answer":1,"explanation":"ISA-5.1 defines P&ID symbols so any engineer can read the drawings."},
    {"question":"How should documentation updates be tied to change management?","options":["Updated whenever someone remembers","No change is closed until affected drawings are updated and reviewed","Only at project handover","Never"],"answer":1,"explanation":"Tying updates to the change-request workflow keeps documentation in sync with the field."},
    {"question":"What is the onboarding test for documentation?","options":["Check it into Git","Have an unfamiliar engineer walk through it before acceptance","Print and bind it","Review it annually"],"answer":1,"explanation":"If an unfamiliar engineer cannot understand the system from the docs, the docs are insufficient."},
    {"question":"Why is stale documentation worse than none?","options":["It costs more","It actively misleads troubleshooters","It is illegal","It cannot be stored"],"answer":1,"explanation":"Stale drawings cause responders to rely on wrong information, leading to errors."},
    {"question":"What should a system narrative include?","options":["Only tag names","What the system does, operating modes, known issues, and a pointer to the current code revision","Only the vendor list","Only the IP addresses"],"answer":1,"explanation":"The narrative gives context that drawings alone cannot convey."},
    {"question":"Where should documentation be stored?","options":["On a personal laptop","In a DMS with version control, access control, and a review/approve cycle","In a shared folder with no versioning","Printed in a binder only"],"answer":1,"explanation":"A DMS with versioning and review cycles keeps documentation controlled and current."}
  ]'::jsonb);

  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Spare Parts, Obsolescence & Migration Planning', '## Overview

Every industrial control system has a lifecycle: introduction, support, obsolescence, and migration. The day a controller is commissioned, the clock starts on its firmware support window and spare availability. Engineers who ignore obsolescence face emergency migrations during outages; engineers who plan for it migrate on their own schedule. This lesson covers lifecycle planning, spare-parts strategy, and the migration playbook.

## Key Concepts

**Lifecycle Stages.** A controller moves from active sales, to active support (no new sales, but spares and firmware available), to limited support, to obsolete. Each vendor publishes lifecycle status; track it per device. A system at "active support" has years of runway; a system at "limited support" needs a migration plan now; a system at "obsolete" needs a migration in flight.

**Spare-Parts Strategy.** Critical spares are the parts whose failure stops production and whose lead time exceeds the tolerable downtime. For each such part, hold a spare (or a documented source with guaranteed lead time). Rotate spares into service periodically so that shelf-life issues (capacitor drying, battery depletion) are caught before an emergency. Track spare age and test history; a 10-year-old spare that has never been powered is a gamble, not a spare.

**Obsolescence Triggers.** Plan migration when any of these occurs: the vendor announces end-of-sale, firmware support ends within the support window, spares become scarce or unobtanium, or the platform cannot meet new requirements (security, performance, integration). Do not wait for a hard obsolescence notice — by then, spares are gone and migration is a fire drill.

**The Migration Playbook.** A migration is a project, not an event. It includes: scope and risk assessment, a parallel-run or cut-over strategy, a tested rollback, an I/O and tag mapping, a regression test plan, and operator training. For large systems, migrate in phases (per line, per cell) so that each phase is small enough to recover. Document the new system to the same standard as the original should have been.

## Best Practices

- Track vendor lifecycle status per device; review annually.
- Hold critical spares for parts whose lead time exceeds tolerable downtime; rotate them into service.
- Trigger migration planning at end-of-sale or end-of-firmware-support, not at hard obsolescence.
- Treat migration as a project with scope, risk, cut-over strategy, rollback, and regression testing.
- Migrate large systems in phases so each phase is recoverable.

## Common Pitfalls

- **Ignoring lifecycle status** until a spare is unobtanium and production is down.
- **Shelf-life spares** that have never been powered fail when finally installed.
- **Waiting for hard obsolescence** leaves no time and no spares for migration.
- **Big-bang migrations** are unrecoverable if they fail.
- **No regression test plan** lets subtle behavior changes reach production undetected.

## Real-World Example

A steel mill ran a 15-year-old PLC platform that the vendor placed on limited support. Rather than wait, the team started a phased migration: one finishing line per quarter, with a parallel-run period and a tested rollback. Two years later, the vendor announced hard obsolescence, but the mill had already migrated 80% of its systems on schedule, with no emergency work and no production loss.

## Knowledge Check

Review the lifecycle stages, the definition of a critical spare and the rotation practice, the obsolescence triggers, and the phased migration playbook before the quiz.',
  45, 2,
  '[
    {"question":"What is a critical spare?","options":["The cheapest part","A part whose failure stops production and whose lead time exceeds tolerable downtime","Any part in the BOM","A part that is obsolete"],"answer":1,"explanation":"Critical spares are those you cannot afford to wait for; hold one (or a guaranteed source)."},
    {"question":"Why rotate spares into service periodically?","options":["To reduce inventory","To catch shelf-life issues (capacitor drying, battery depletion) before an emergency","To save money","To test the vendor"],"answer":1,"explanation":"Rotation catches shelf-life failures so a spare works when you need it."},
    {"question":"When should migration planning start?","options":["At hard obsolescence","At end-of-sale or end-of-firmware-support, while spares are still available","Only after a failure","Never"],"answer":1,"explanation":"Starting at end-of-sale leaves time and spares for a planned migration."},
    {"question":"Why migrate large systems in phases?","options":["To save money","So each phase is small enough to recover if it fails","To avoid testing","To reduce documentation"],"answer":1,"explanation":"Phased migration keeps each cut-over recoverable; a big-bang migration is not."},
    {"question":"What should a migration include?","options":["Only the new hardware","Scope, risk assessment, cut-over strategy, rollback, I/O mapping, regression testing, and training","Only operator training","Only a purchase order"],"answer":1,"explanation":"A migration is a project with all the elements of any controlled change."},
    {"question":"What is a risk of an unpowered 10-year-old spare?","options":["It is too new","It may fail on first power-on due to shelf-life issues","It is too expensive","It needs no testing"],"answer":1,"explanation":"Shelf-life aging (dried capacitors, depleted batteries) can cause first-power failures."},
    {"question":"What does tracking vendor lifecycle status per device enable?","options":["Faster scan times","Proactive migration planning before spares disappear","Lower power use","Better HMI graphics"],"answer":1,"explanation":"Annual lifecycle review gives early warning so migration is planned, not emergency."}
  ]'::jsonb);
END $$;