/*
# Seed ForgeLine catalog — Engineering / Advanced Controls expansion (12 new courses)

## Overview
Adds 12 new premium Engineering / Advanced Controls courses to the catalog,
expanding the Engineering track from 4 to 16 courses. Each course has 2-3
modules with 2-3 lessons, professional plant-floor content, and at least one
knowledge-check quiz per lesson. No existing courses are modified.

## Courses added (sort_order 5-16)
1. Studio 5000 / Logix System Architecture Deep Dive (5)
2. Ethernet/IP Network Design & Segmentation (6)
3. OT Cybersecurity Fundamentals for Industrial Systems (7)
4. Functional Safety (ISO 13849 & IEC 61511) (8)
5. Commissioning, Startup & Project Execution (9)
6. Energy Management & Efficient Drive Systems (10)
7. Advanced PLC Programming Patterns & Standards (11)
8. Motion Control & Servo Systems (12)
9. Industrial Networking (Managed Switches, VLANs, QoS) (13)
10. Alarm Management & Rationalization (14)
11. Reliability Centered Maintenance Strategy (15)
12. Digital Transformation & IIoT Fundamentals for Maintenance (16)

## Security
No schema or policy changes. INSERT is allowed only for service role / SQL execution.

## Notes
1. Uses ON CONFLICT DO NOTHING keyed on (stage, title) so re-running is safe.
2. Each DO $$ block looks up the course by (stage, title) and returns early if not found.
3. Quizzes are JSON arrays: [{question, options:[...], correctIndex:0}].
*/

INSERT INTO courses (title, description, short_description, stage, tier, difficulty, estimated_hours, sort_order)
VALUES
('Studio 5000 / Logix System Architecture Deep Dive',
 'Comprehensive guide to Rockwell Studio 5000 and Logix platform architecture. Covers project organization, tasks, programs, routines, UDTs, AOIs, I/O configuration, and best practices for scalable, maintainable PLC projects in process and discrete applications.',
 'Studio 5000 project structure, UDTs, AOIs, tasks, and scalable PLC architecture.',
 'engineering','premium','advanced',4,5),
('Ethernet/IP Network Design & Segmentation',
 'Design and troubleshoot EtherNet/IP networks for industrial control systems. Covers topology, switch selection, IGMP snooping for multicast, QoS, DLR rings, and network segmentation per the Purdue model for reliable PLC-to-I/O communication.',
 'EtherNet/IP topology, IGMP snooping, QoS, DLR rings, and Purdue segmentation.',
 'engineering','premium','advanced',3.5,6),
('OT Cybersecurity Fundamentals for Industrial Systems',
 'Operational technology (OT) cybersecurity for industrial control systems. Covers the Purdue model, IEC 62443 zones, risk assessment, patching strategies, network segmentation, and incident response for PLC and SCADA systems.',
 'IEC 62443 zones, OT risk assessment, patching, segmentation, and incident response.',
 'engineering','premium','advanced',3.5,7),
('Functional Safety (ISO 13849 & IEC 61511)',
 'Functional safety engineering for machinery and process systems. Covers ISO 13849 (machinery safety) performance levels, IEC 61511 (process SIS) SIL verification, safety function design, validation, and the relationship between the two standards.',
 'ISO 13849 performance levels, IEC 61511 SIL verification, and safety function design.',
 'engineering','premium','advanced',4,8),
('Commissioning, Startup & Project Execution',
 'Systematic commissioning and startup of industrial control systems. Covers the commissioning plan, FAT/SAT, I/O checkout, loop checks, functional testing, punch list management, and handover to operations for a successful project startup.',
 'FAT/SAT, I/O checkout, loop checks, functional testing, and startup handover.',
 'engineering','premium','advanced',3,9),
('Energy Management & Efficient Drive Systems',
 'Industrial energy management and drive system optimization. Covers motor efficiency classes (IE1-IE4), VFD energy savings, demand management, power factor correction, and ISO 50001 energy management system implementation.',
 'IE motor classes, VFD energy savings, demand management, and ISO 50001.',
 'engineering','premium','advanced',3,10),
('Advanced PLC Programming Patterns & Standards',
 'Advanced PLC programming patterns for complex industrial applications. Covers state machines, sequencers, modular programming, IEC 61131-3 languages, and design patterns for batch, packaging, and process control.',
 'State machines, sequencers, modular programming, and IEC 61131-3 patterns.',
 'engineering','premium','advanced',4,11),
('Motion Control & Servo Systems',
 'Industrial motion control and servo drive systems. Covers servo motor theory, tuning, coordinated motion, camming, gearing, and safety-rated motion functions for high-speed packaging and manufacturing applications.',
 'Servo theory, tuning, coordinated motion, camming, and safety-rated motion.',
 'engineering','premium','advanced',3.5,12),
('Industrial Networking (Managed Switches, VLANs, QoS)',
 'Industrial network design with managed switches. Covers VLAN segmentation, trunking, Spanning Tree (RSTP/MSTP), QoS prioritization, port security, and network monitoring for resilient industrial Ethernet infrastructure.',
 'VLANs, RSTP/MSTP, QoS, port security, and industrial Ethernet monitoring.',
 'engineering','premium','advanced',3.5,13),
('Alarm Management & Rationalization',
 'Industrial alarm management per ISA 18.2. Covers alarm philosophy, rationalization, prioritization, nuisance alarm reduction, alarm shelving, and KPI monitoring for a manageable, actionable alarm system.',
 'ISA 18.2 alarm philosophy, rationalization, prioritization, and KPI monitoring.',
 'engineering','premium','advanced',3,14),
('Reliability Centered Maintenance Strategy',
 'Implement Reliability Centered Maintenance (RCM) for industrial assets. Covers FMEA, failure consequence analysis, task selection, and building a defensible maintenance program that balances cost, risk, and performance.',
 'RCM FMEA, consequence analysis, task selection, and maintenance program design.',
 'engineering','premium','advanced',3.5,15),
('Digital Transformation & IIoT Fundamentals for Maintenance',
 'Industrial IoT (IIoT) and digital transformation for maintenance organizations. Covers edge computing, cloud platforms, data architecture, predictive analytics, and building a business case for IIoT deployment in a maintenance context.',
 'Edge computing, cloud platforms, predictive analytics, and IIoT business cases.',
 'engineering','premium','advanced',3,16)
ON CONFLICT DO NOTHING;

-- ===================== Studio 5000 / Logix System Architecture Deep Dive =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Studio 5000 / Logix System Architecture Deep Dive';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Project Organization & Tasks', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Tasks, Programs & Routines',
   'A Logix project organizes code into tasks, programs, and routines. The continuous task runs constantly and is interrupted by periodic and event tasks. A periodic task runs at a fixed interval (e.g., every 10 ms) and is used for time-critical logic like motion control or high-speed counting. An event task is triggered by a hardware event (e.g., a high-speed input) and runs once. Within each task, programs are containers for routines. A program has its own tag scope (local tags) and can be scheduled independently. Within each program, routines contain the actual logic. The main routine is the entry point; subroutines are called by JSR (Jump to Subroutine) instructions. Organize programs by area (e.g., Fill, CIP, Packaging) and routines by equipment module (e.g., FILL_TANK101, FILL_VALVE102). This hierarchy maps the code to the physical equipment, making it easy to find and maintain. Avoid putting all logic in the continuous task — periodic tasks for time-critical logic and event tasks for fast response improve determinism and reduce scan time variability.',
   50, 1,
   '[{"question":"Which task type runs at a fixed interval for time-critical logic?","options":["Continuous task","Periodic task","Event task","Background task"],"correctIndex":1},{"question":"What is the entry point for logic within a program?","options":["The first subroutine","The main routine","The task","The controller tag"],"correctIndex":1}]'),
  (m_id, 'User-Defined Types & Add-On Instructions',
   'User-Defined Data Types (UDTs) encapsulate related tags into a single structure. For a motor, a UDT might include the start command, stop command, running status, faulted status, and speed reference. Each motor instance creates a tag of the UDT type, and all the related data is in one place. This makes the code self-documenting and prevents orphaned tags. Add-On Instructions (AOIs) encapsulate reusable logic with a defined interface (inputs, outputs, local tags). An AOI for a motor start/stop block contains the seal-in logic, the overload check, and the fault latch — every motor instance uses the same AOI, ensuring consistency. Define the AOI signature carefully: inputs and outputs are the interface; local tags are private to each instance. Use EnableIn and EnableOut to allow logic to short-circuit when upstream logic is false. Version AOIs and document changes — a change to the AOI definition propagates to every instance, so test thoroughly before releasing. Avoid AOIs for one-off logic — they add overhead without reuse benefit. For a large project, define the UDTs and AOIs early, before writing the routines, so the tag structure is consistent throughout.',
   50, 2,
   '[{"question":"What does a User-Defined Data Type (UDT) do?","options":["Encapsulates related tags into a single structure","Defines a new programming language","Creates a new task","Replaces the main routine"],"correctIndex":0},{"question":"What is the key benefit of Add-On Instructions (AOIs)?","options":["They run faster","They ensure consistency across every instance of the logic","They eliminate the need for tags","They bypass safety logic"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'I/O Configuration & Best Practices', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'I/O Configuration, Tag Aliasing & Project Scalability',
   'I/O configuration in Studio 5000 maps the physical I/O modules to the controller. Add the communication module (e.g., an EtherNet/IP module) to the tree, then add the I/O modules under it. Each module has a configuration (the type, the slot, the electronic keying). Electronic keying verifies the installed module matches the configured module — use compatible keying (verify the catalog number and the major revision) rather than exact keying (verify every attribute) to allow minor revisions. Map the I/O to tags using alias tags: an alias tag (e.g., FILL_TANK101_LS_HIGH) points to the physical input (e.g., Local:5:I.Data.3). This decouples the logic from the physical I/O — if the I/O module is moved to a different slot, only the alias changes, not the logic. For a scalable project, use a consistent naming convention (Area_Subsystem_Device_Attribute) and organize the tag database into folders by area. Use the controller-scoped tags for inter-program communication and program-scoped tags for local data. Avoid using the same tag name in different programs — it causes confusion during troubleshooting. Document the tag database with a tag description for every tag — the description appears in the logic and the HMI, saving troubleshooting time.',
   50, 1,
   '[{"question":"What does an alias tag do?","options":["Creates a new data type","Points to a physical I/O address, decoupling logic from hardware","Adds a new routine","Creates a new task"],"correctIndex":1},{"question":"Which electronic keying mode allows minor module revisions?","options":["Exact keying","Compatible keying (verify catalog number and major revision)","Disable keying","Manual keying"],"correctIndex":1}]');
END $$;

-- ===================== Ethernet/IP Network Design & Segmentation =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Ethernet/IP Network Design & Segmentation';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'EtherNet/IP Topology & Multicast', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Topology, IGMP Snooping & Multicast Management',
   'EtherNet/IP uses both unicast (for explicit messaging and CIP connections) and multicast (for I/O scanner-to-adapter connections). Multicast traffic is used by the PLC to send I/O data to multiple devices — without management, multicast packets flood every switch port, saturating the network. IGMP snooping on managed switches prevents this: the switch learns which ports have joined which multicast groups and forwards the multicast only to those ports. Without IGMP snooping, a network with 20 I/O adapters floods every port with 20 multicast streams, and the network collapses. Enable IGMP snooping on every managed switch in an EtherNet/IP network, and configure the IGMP querier (one switch per VLAN sends the membership queries). The topology should be a star or a ring. A star topology (all devices connect to a central switch) is simple but has a single point of failure. A ring topology (Device Level Ring, DLR) uses two paths and recovers in under 3 ms for 50 nodes — use a ring for high availability. For large networks, segment into VLANs by cell or area to limit the multicast scope and the broadcast domain. Use a stratix or industrial managed switch that supports EtherNet/IP diagnostics — the PLC can read the switch health and the port status over the network.',
   55, 1,
   '[{"question":"What happens on an EtherNet/IP network without IGMP snooping?","options":["Multicast packets flood every switch port, saturating the network","The network runs faster","Multicast is disabled","Nothing — IGMP is optional"],"correctIndex":0},{"question":"What is the recovery time of a Device Level Ring (DLR) for 50 nodes?","options":["100 ms","3 ms","500 ms","1 second"],"correctIndex":1}]'),
  (m_id, 'QoS & Network Segmentation',
   'Quality of Service (QoS) prioritizes time-critical traffic (I/O and motion) over less critical traffic (HMI, programming, diagnostics). Without QoS, a large HMI upload can delay an I/O packet, causing a controller fault. Configure QoS on the managed switches: set the DSCP (Differentiated Services Code Point) value for EtherNet/IP I/O traffic (typically DSCP 55, expedited forwarding) and for HMI traffic (DSCP 0, best effort). The switch prioritizes the high-DSCP traffic on egress queues. The PLC and the I/O adapters must also be configured to set the DSCP value in the outgoing packets — the switch cannot prioritize what it cannot identify. Segment the network per the Purdue model: Level 0-1 (field devices and PLCs) on one VLAN, Level 2 (supervisory) on another, and Level 3 (site operations) on a third. The industrial DMZ (Level 3.5) separates the enterprise from the plant floor — no direct route. Use a firewall at the DMZ to broker controlled access (historians, jump hosts). This segmentation contains a network fault or a cyber attack within one segment, preventing it from spreading to the entire plant.',
   50, 2,
   '[{"question":"What does QoS do on an EtherNet/IP network?","options":["Speeds up all traffic equally","Prioritizes time-critical I/O traffic over less critical HMI traffic","Encrypts the traffic","Reduces the network speed"],"correctIndex":1},{"question":"What is the purpose of the industrial DMZ (Level 3.5)?","options":["To speed up enterprise access to PLCs","To broker controlled access between enterprise and plant floor with no direct route","To replace the PLC network","To host the ERP system"],"correctIndex":1}]');
END $$;

-- ===================== OT Cybersecurity Fundamentals for Industrial Systems =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='OT Cybersecurity Fundamentals for Industrial Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Threat Landscape & Standards', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'IEC 62443 Zones & Conduits',
   'IEC 62443 is the standard for industrial automation and control systems (IACS) cybersecurity. It defines security zones — groupings of assets with the same security level — and conduits — the communication paths between zones. Each zone has a security level (SL-T for target, SL-C for capability) that defines the required security controls. The zone and conduit model forces the designer to identify every asset, every communication path, and the security controls at each boundary. A typical plant has a control system zone (PLCs, I/O), a supervisory zone (SCADA, HMI), a DMZ (historian, jump host), and an enterprise zone (office, email). The conduits between zones are protected by firewalls with rules that allow only the required communication. The most common OT security failure is a flat network — all devices on one VLAN, reachable from any point. A flat network means a malware infection on one device can spread to every PLC in the plant. Segmenting into zones with firewalls between them contains the infection and limits the blast radius. Document the zone and conduit model in a network diagram and review it annually — new devices and new connections are added over time and the segmentation erodes if not maintained.',
   55, 1,
   '[{"question":"What are zones and conduits in IEC 62443?","options":["Zones are communication paths; conduits are assets","Zones are groupings of assets with the same security level; conduits are the communication paths between zones","Zones are firewalls; conduits are switches","Zones and conduits are the same thing"],"correctIndex":1},{"question":"What is the most common OT security failure?","options":["A flat network where all devices are on one VLAN, reachable from any point","Too many firewalls","Strong passwords","Excessive segmentation"],"correctIndex":0}]'),
  (m_id, 'Patching, Incident Response & Risk Assessment',
   'Patching OT systems is harder than IT — a PLC reboot may stop production, and a patch may change the behavior of the control logic. The patching strategy: test patches in a development environment, schedule the patch during a maintenance window, and have a rollback plan. For critical systems that cannot be patched, use compensating controls (network isolation, intrusion detection, access control). A risk assessment identifies the assets, the threats, the vulnerabilities, and the consequences. The risk is the product of the threat likelihood, the vulnerability, and the consequence. Prioritize the mitigation by risk — a high-consequence, high-likelihood risk is addressed first. Incident response for OT is different from IT: the first priority is to maintain the process safety, not to eradicate the malware. The response plan: detect (the intrusion), isolate (disconnect the infected zone), contain (prevent spread to other zones), eradicate (remove the malware), and recover (restore the system from a known-good backup). Practice the response with a tabletop exercise — a simulated incident that tests the plan and the team. An OT incident response plan that has never been tested will fail when it is needed. Document the plan, the roles, the contacts, and the recovery procedures.',
   50, 2,
   '[{"question":"What is the first priority in an OT incident response?","options":["Eradicate the malware","Maintain process safety","Restore from backup","Call the vendor"],"correctIndex":1},{"question":"How should an OT incident response plan be tested?","options":["It cannot be tested","With a tabletop exercise — a simulated incident","Only during a real incident","By reading the plan"],"correctIndex":1}]');
END $$;

-- ===================== Functional Safety (ISO 13849 & IEC 61511) =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Functional Safety (ISO 13849 & IEC 61511)';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'ISO 13849 Machinery Safety', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Performance Levels & Safety Categories',
   'ISO 13849 defines the Performance Level (PL a-e) for machinery safety functions. PL e is the highest (the risk is so high that a failure could cause death or serious injury). The PL is determined by the risk graph: the severity of injury (S1 minor, S2 serious), the frequency and duration of exposure (F1 rare, F2 frequent), and the possibility of avoidance (P1 possible, P2 not possible). The combination (e.g., S2 + F2 + P2) determines the required PL (e). The safety category (B, 1, 2, 3, 4) defines the architecture of the safety circuit. Category B is basic (single channel, no redundancy). Category 1 adds monitoring. Category 2 adds a check function. Category 3 is dual channel with monitoring (a single fault does not cause the loss of the safety function). Category 4 is dual channel with high diagnostic coverage (a single fault is detected and the safety function still operates). The achieved PL is limited by the category, the MTTFd (mean time to dangerous failure) of the components, and the diagnostic coverage (DC). A Category 3 circuit with high MTTFd components and high DC achieves PL e. The safety function is verified by calculation (the SISTEMA software tool) and by validation testing. Document the calculation, the components, and the validation results in the technical file.',
   55, 1,
   '[{"question":"What is the highest Performance Level in ISO 13849?","options":["PL a","PL d","PL e","PL f"],"correctIndex":2},{"question":"What does Category 4 architecture provide?","options":["Single channel, no redundancy","Dual channel with high diagnostic coverage — a single fault is detected and the safety function still operates","Basic monitoring","Check function only"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'IEC 61511 Process SIS', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'SIL Verification & Safety Lifecycle',
   'IEC 61511 is the process sector counterpart to ISO 13849. It defines the Safety Integrity Level (SIL 1-4) for Safety Instrumented Functions (SIF). The SIL is determined by LOPA (Layer of Protection Analysis) — the gap between the unmitigated risk and the tolerable risk determines the required risk reduction, which is the SIL. The SIL is verified by calculation: the PFDavg (probability of failure on demand) of the SIF must be within the SIL range (SIL 1: 10^-1 to 10^-2, SIL 2: 10^-2 to 10^-3, SIL 3: 10^-3 to 10^-4). The PFDavg is the sum of the failure rates of the sensor, logic solver, and final element, multiplied by the proof test interval, divided by 2 (for a 1oo1 architecture). The architecture (HFT — hardware fault tolerance) and the systematic capability (the quality of the engineering process) also limit the achievable SIL. The safety lifecycle per IEC 61511: hazard analysis, SIL determination, SIF design, SIL verification, operation, maintenance, and decommissioning. Each phase has deliverables and verification. The proof test is critical — it verifies the SIF operates correctly and restores the PFDavg to the as-new condition. An overdue or inadequate proof test invalidates the SIL claim. Document the SIL calculation, the proof test procedure, and the proof test results in the safety file. The safety file is the regulatory record that demonstrates the SIS meets the required SIL.',
   55, 1,
   '[{"question":"What is the PFDavg range for SIL 2?","options":["10^-1 to 10^-2","10^-2 to 10^-3","10^-3 to 10^-4","10^-4 to 10^-5"],"correctIndex":1},{"question":"What does the proof test do?","options":["Calibrates the sensor","Verifies the SIF operates correctly and restores the PFDavg to the as-new condition","Tunes the loop","Tests the network"],"correctIndex":1}]');
END $$;

-- ===================== Commissioning, Startup & Project Execution =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Commissioning, Startup & Project Execution';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Testing & Verification', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'FAT, SAT & I/O Checkout',
   'The Factory Acceptance Test (FAT) is performed at the vendor or integrator facility before the equipment ships. The FAT verifies the panel wiring, the PLC program, and the HMI against the functional specification. The customer witnesses the FAT and signs the FAT report — any deficiencies are corrected before shipment. The Site Acceptance Test (SAT) is performed after installation, with the equipment in its final location. The SAT verifies the installation (the wiring, the I/O, the communication) and the integration with the field devices. The I/O checkout is the first field test: every input is driven from the field (a limit switch, a transmitter) and the PLC reads the correct value; every output is commanded from the PLC and the field device responds. This is a point-to-point verification — a wiring error found during I/O checkout is a 10-minute fix; the same error found during startup is a 2-hour troubleshooting session. Use a standard I/O checkout form for each point: the tag, the expected value, the actual value, and the pass/fail. The form is the record that the I/O is verified and is part of the commissioning documentation.',
   50, 1,
   '[{"question":"What is the difference between FAT and SAT?","options":["FAT is at the vendor facility before shipment; SAT is at the final location after installation","They are the same test","FAT is for software; SAT is for hardware","FAT is optional; SAT is required"],"correctIndex":0},{"question":"Why is an I/O checkout error a 10-minute fix during checkout but a 2-hour troubleshooting session during startup?","options":["Because the panel is open during checkout","Because the error is identified point-to-point during checkout, but during startup it must be found by troubleshooting","Because the vendor fixes it during FAT","Because the PLC is not running during checkout"],"correctIndex":1}]'),
  (m_id, 'Functional Testing & Punch List',
   'Functional testing verifies the control logic against the functional specification. Each function is tested: a motor starts when the start button is pressed, stops when the stop button is pressed, trips when the overload activates, and the fault resets when the reset button is pressed. The test is performed with the process in a safe state (water in the tank, product on the conveyor) or with the field devices simulated (a signal generator for the transmitter, a relay for the motor). Document each test with the test number, the expected behavior, the actual behavior, and the pass/fail. Failures go on the punch list — a list of deficiencies that must be corrected before handover. The punch list is prioritized: items that prevent operation are A (must fix before startup), items that affect production quality are B (fix during startup), and cosmetic items are C (fix after startup). The punch list is reviewed daily during the startup phase and closed out as items are corrected. The handover to operations is the formal transfer of the system from the project team to the operations team. The handover includes the training, the documentation (the as-built drawings, the PLC program, the HMI, the I/O list, the functional specification), the spare parts list, and the warranty period. A system that is handed over without documentation and training will be misoperated and will fail prematurely.',
   50, 2,
   '[{"question":"What is the punch list?","options":["A list of spare parts","A list of deficiencies that must be corrected before handover","The project schedule","The commissioning plan"],"correctIndex":1},{"question":"What does the handover to operations include?","options":["Only the PLC program","Training, documentation, spare parts list, and warranty period","Only the HMI","Only the I/O list"],"correctIndex":1}]');
END $$;

-- ===================== Energy Management & Efficient Drive Systems =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Energy Management & Efficient Drive Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Motor Efficiency & VFD Savings', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'IE Efficiency Classes & VFD Energy Savings',
   'The IEC 60034-30 standard defines motor efficiency classes: IE1 (standard efficiency), IE2 (high efficiency), IE3 (premium efficiency), and IE4 (super premium efficiency). The efficiency improvement from IE1 to IE3 is typically 2-4 percentage points — an IE3 motor that is 94% efficient versus an IE1 motor at 90% saves 4% of the input energy. For a 50 HP motor running 8000 hours per year at $0.10/kWh, the annual energy cost is $31,200. A 4% savings is $1,248 per year. The payback for upgrading to an IE3 motor (cost premium $300-500) is 3-5 months. VFD energy savings come from matching the motor speed to the load demand — a centrifugal pump or fan on a throttling valve or damper wastes energy because the motor runs at full speed and the excess flow is dumped. A VFD reduces the speed to match the demand, and the power drops with the cube of the speed (the affinity laws): 80% speed = 50% power. For a fan running at 80% speed for 50% of the time, the VFD saves 50% of the energy. The payback for a VFD installation ($2,000-5,000 per drive) is typically 1-2 years for fans and pumps that run at reduced speed for significant periods.',
   50, 1,
   '[{"question":"How much energy does a centrifugal fan at 80% speed consume versus 100% speed (affinity laws)?","options":["80% of full speed energy","50% of full speed energy","64% of full speed energy","100% — energy is the same"],"correctIndex":1},{"question":"What is the typical payback for a VFD installation on a fan or pump?","options":["5-10 years","1-2 years","10+ years","Less than 1 month"],"correctIndex":1}]'),
  (m_id, 'ISO 50001 & Demand Management',
   'ISO 50001 is the energy management system standard — it provides a framework for an organization to establish an energy policy, set energy targets, measure energy use, and improve energy performance. The key elements: an energy review (identify the significant energy uses — motors, compressors, heaters), energy baselines (the baseline energy consumption for each significant use), energy performance indicators (kWh per unit of production), and energy objectives (targets for reduction). The plan-do-check-act cycle: plan the energy targets, implement the energy-saving projects, measure the results, and act to improve. Demand management reduces the peak demand charge (the maximum kW in a 15-minute interval) by shedding load during peak periods — turning off non-critical motors, reducing the compressor output, or shifting production to off-peak hours. The peak demand charge can be 30-50% of the electric bill — reducing the peak by 10% saves 3-5% of the total bill. Install a power monitor at the main switchgear and trend the kW and the kVA. A rising peak without a production increase indicates an efficiency loss or a new load that was not accounted for.',
   45, 2,
   '[{"question":"What does ISO 50001 provide?","options":["A specific energy-saving technology","A framework for energy policy, targets, measurement, and improvement","A motor efficiency standard","A VFD specification"],"correctIndex":1},{"question":"What percentage of the electric bill can the peak demand charge represent?","options":["5-10%","30-50%","80-90%","100%"],"correctIndex":1}]');
END $$;

-- ===================== Advanced PLC Programming Patterns & Standards =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Advanced PLC Programming Patterns & Standards';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'State Machines & Sequencers', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'State Machine Design Pattern',
   'A state machine is the most powerful pattern for sequential control. The machine is in one state at a time, and transitions move it from state to state based on conditions. For a filling station: State 0 (Idle) — wait for start. State 10 (Fill) — open the fill valve, wait for the level. State 20 (Settle) — close the valve, wait 2 seconds. State 30 (Cap) — lower the capper, wait for the cap sensor. State 40 (Eject) — activate the ejector, wait for the ejector complete. State 0 (Idle) — return to start. The transitions are: State 0 to 10 when the start button is pressed. State 10 to 20 when the level is reached. State 20 to 30 when the timer is done. State 30 to 40 when the cap sensor is on. State 40 to 0 when the ejector is complete. The advantage of a state machine over ad-hoc logic: the state is always known (it is in one integer), the transitions are explicit, and the fault handling is centralized — any fault transitions to a fault state that stops the sequence and alerts the operator. Implement the state machine with a CASE instruction on the state integer, and each state as a rung in the CASE. The state integer is displayed on the HMI for operator awareness. This pattern scales to any sequential process and is self-documenting.',
   55, 1,
   '[{"question":"What is the key advantage of a state machine over ad-hoc logic?","options":["It runs faster","The state is always known, transitions are explicit, and fault handling is centralized","It uses less memory","It does not require tags"],"correctIndex":1},{"question":"How is a state machine typically implemented in a PLC?","options":["With a series of rungs","With a CASE instruction on the state integer, each state as a rung","With a subroutine only","With a timer"],"correctIndex":1}]'),
  (m_id, 'Modular Programming & IEC 61131-3',
   'Modular programming breaks the control system into equipment modules, each with its own state machine and its own AOI. An equipment module (e.g., a filling valve) has a state machine (Idle, Opening, Open, Closing, Closed, Fault) and an AOI that encapsulates the valve logic. The module communicates with the supervisory logic via the module interface: the start command, the stop command, the status, and the fault. This separation allows the module to be tested independently and reused across projects. IEC 61131-3 defines five programming languages: Ladder (LD), Function Block (FBD), Structured Text (ST), Instruction List (IL, deprecated), and Sequential Function Chart (SFC). Use the language that fits the task: LD for discrete logic, FBD for analog control, ST for math and string manipulation, SFC for sequential processes. Mixing languages within a module is acceptable if it improves clarity. The key to maintainability is consistency — a module written in LD by one engineer and ST by another is confusing to troubleshoot. Establish a project standard that defines the language for each module type and document it in the project specification.',
   50, 2,
   '[{"question":"What does modular programming break the control system into?","options":["Routines","Equipment modules, each with its own state machine and AOI","Tasks only","Programs only"],"correctIndex":1},{"question":"Which IEC 61131-3 language is best for sequential processes?","options":["Ladder (LD)","Function Block (FBD)","Structured Text (ST)","Sequential Function Chart (SFC)"],"correctIndex":3}]');
END $$;

-- ===================== Motion Control & Servo Systems =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Motion Control & Servo Systems';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Servo Fundamentals & Tuning', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Servo Motor Theory & Loop Tuning',
   'A servo system consists of a servo motor, a servo drive, and a feedback device (encoder or resolver). The servo drive closes the position loop, the velocity loop, and the current (torque) loop. The current loop is the innermost and is tuned first — it controls the torque by regulating the motor current. The velocity loop is next — it controls the motor speed by commanding the current loop. The position loop is the outermost — it controls the position by commanding the velocity loop. Tuning proceeds from inner to outer: tune the current loop for a fast, stable response (high bandwidth, typically 500-1000 Hz). Then tune the velocity loop for a fast, stable response (bandwidth 100-200 Hz). Then tune the position loop for the required accuracy (bandwidth 20-50 Hz). The tuning method: increase the gain until the response oscillates, then reduce the gain by 30-50% for stability. Add integral action to eliminate steady-state error, and derivative action to improve damping. The following error (the difference between the commanded and actual position) is the key performance metric — a high following error indicates a tuning problem, a load problem, or a mechanical issue (backlash, a loose coupling). Use the drive tuning software (e.g., Rockwell Motion Analyzer) to auto-tune the loops and to plot the step response.',
   55, 1,
   '[{"question":"In what order are servo loops tuned?","options":["Position, velocity, current","Current, velocity, position (innermost to outermost)","All simultaneously","Position only"],"correctIndex":1},{"question":"What does a high following error indicate?","options":["Normal operation","A tuning problem, a load problem, or a mechanical issue (backlash, loose coupling)","The motor is oversized","The encoder is faulty"],"correctIndex":1}]');

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Coordinated Motion & Safety', 2) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Coordinated Motion & Safety-Rated Functions',
   'Coordinated motion synchronizes multiple servo axes to a master reference. In electronic gearing, a slave axis follows a master at a fixed gear ratio. In camming, the slave follows a non-linear position profile defined by a cam table — the cam table maps the master position to the slave position at discrete points, and the drive interpolates between them. Camming replaces mechanical cams with software, allowing profile changes on the fly. For a packaging machine with a rotary infeed and a linear sealer, the cam table defines the relationship between the infeed angle and the sealer position for each product. When commissioning coordinated motion, first tune each axis individually, then enable the master and verify the slave tracks without following error. A high following error at a constant speed indicates a tuning or load problem; a high error at the cam transition points indicates a discontinuity in the cam profile. Safety-rated motion functions use a safety PLC and safety-rated servo drives to stop the axes in a controlled manner on a safety demand. The safety function (e.g., safe stop, safe limited speed) is executed by the safety PLC, which monitors the actual speed and position and commands the drive to stop if the safety limit is exceeded. The safety function must be validated by calculation (the SIL or PL) and by testing — the stop time and the stopping distance must be within the specification.',
   55, 1,
   '[{"question":"What does a cam table do?","options":["Maps the master position to the slave position at discrete points, and the drive interpolates between them","Sets the motor speed","Controls the torque","Monitors the following error"],"correctIndex":0},{"question":"What does a safety-rated motion function do?","options":["Increases the motor speed","Uses a safety PLC and safety-rated drives to stop the axes in a controlled manner on a safety demand","Replaces the encoder","Tunes the servo loop"],"correctIndex":1}]');
END $$;

-- ===================== Industrial Networking (Managed Switches, VLANs, QoS) =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Industrial Networking (Managed Switches, VLANs, QoS)';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'VLANs & Spanning Tree', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'VLAN Segmentation & Trunking',
   'A Virtual LAN (VLAN) segments a physical network into logical networks. Devices in different VLANs cannot communicate without a router (or a layer-3 switch). VLANs limit the broadcast domain (a broadcast in one VLAN does not reach the other), improve security (a device in one VLAN cannot access the other without a firewall), and simplify troubleshooting (a fault in one VLAN does not affect the other). Assign ports to VLANs by port (access mode — the port belongs to one VLAN) or by tag (trunk mode — the port carries multiple VLANs with an 802.1Q tag). For an industrial network, segment by area: the filling cell on VLAN 10, the packaging cell on VLAN 20, the SCADA on VLAN 30. The PLC that controls the filling cell and the packaging cell has a trunk port that carries both VLANs. The inter-VLAN communication goes through a firewall or a layer-3 switch that routes between the VLANs. Configure the firewall rules to allow only the required communication (the PLC to the SCADA, the SCADA to the historian) and deny all other traffic. This segmentation contains a network fault or a cyber attack within one VLAN and prevents it from spreading to the entire plant.',
   50, 1,
   '[{"question":"What does a VLAN do?","options":["Speeds up the network","Segments a physical network into logical networks, limiting the broadcast domain","Encrypts the traffic","Replaces the firewall"],"correctIndex":1},{"question":"How does a trunk port carry multiple VLANs?","options":["By using multiple cables","By using 802.1Q tags","By increasing the speed","By using a different protocol"],"correctIndex":1}]'),
  (m_id, 'RSTP, MSTP & Network Monitoring',
   'The Spanning Tree Protocol (STP) prevents network loops — if two switches are connected by two cables, the loop causes a broadcast storm that saturates the network. STP blocks one path and uses the other, and if the active path fails, STP unblocks the backup path. The original STP converges in 30-50 seconds — too slow for industrial networks. Rapid STP (RSTP) converges in 1-3 seconds. Multiple STP (MSTP) supports multiple spanning trees for multiple VLANs, allowing different VLANs to use different paths. Configure the root bridge (the switch at the center of the network) with the lowest bridge priority — a misconfigured root bridge causes traffic to take a suboptimal path and saturate a link. For network monitoring, use SNMP (Simple Network Management Protocol) to poll the switch health (CPU, memory, port status) and to receive traps (alerts sent by the switch when a port goes down or a link fails). An industrial network should be monitored 24/7 — a switch failure that goes undetected can stop production. Use a network management system (e.g., Rockwell FactoryTalk, or an open-source tool like Nagios or Zabbix) to trend the switch health and to alert on failures. Document the network topology, the VLAN assignments, the IP addresses, and the switch configurations in a network document that is updated whenever the network changes.',
   50, 2,
   '[{"question":"How long does RSTP take to converge?","options":["30-50 seconds","1-3 seconds","100 ms","10 seconds"],"correctIndex":1},{"question":"What protocol is used to monitor switch health?","options":["EtherNet/IP","SNMP (Simple Network Management Protocol)","PROFINET","Modbus"],"correctIndex":1}]');
END $$;

-- ===================== Alarm Management & Rationalization =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Alarm Management & Rationalization';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'ISA 18.2 Alarm Philosophy', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Alarm Philosophy & Rationalization',
   'ISA 18.2 is the standard for alarm management in process industries. The alarm philosophy document defines the alarm objectives, the alarm priority criteria, the alarm classification, and the alarm performance metrics. The rationalization is the process of reviewing every alarm and determining if it is necessary, what priority it should be, and what action the operator should take. Each alarm is documented with the tag, the trigger condition, the consequence (what happens if the alarm is ignored), the operator action, and the priority. The priority is assigned by the consequence severity: high priority for safety/environmental consequences, medium for production, low for minor. The target alarm rate per ISA 18.2 is no more than 1-2 alarms per 10 minutes per operator — above this, the operator is overwhelmed and misses critical alarms. A plant with 500 configured alarms and 50 per minute has an alarm flooding problem. Rationalization reduces the 500 to 100 meaningful alarms and sets the rest to lower priority or removes them. The rationalization is a team effort — the engineer, the operator, and the maintenance technician review each alarm and agree on the priority and the action.',
   55, 1,
   '[{"question":"What is the ISA 18.2 target alarm rate per operator?","options":["10 alarms per 10 minutes","1-2 alarms per 10 minutes","50 alarms per 10 minutes","No limit"],"correctIndex":1},{"question":"What does the rationalization process determine for each alarm?","options":["Only the priority","Whether the alarm is necessary, its priority, and the operator action","The alarm sound","The alarm color"],"correctIndex":1}]'),
  (m_id, 'Nuisance Alarms & KPI Monitoring',
   'A nuisance alarm is an alarm that activates frequently but requires no operator action — it trains the operator to ignore it, and the operator then misses the critical alarm that follows. The most common nuisance alarm is a level alarm that trips on every batch cycle — it should be suppressed during the batch and armed only during the idle state. ISA 18.2 defines alarm suppression (shelving) — the operator shelves the alarm temporarily, and it returns automatically after the suppression condition clears. A chattering alarm (one that activates and resets rapidly) is a nuisance alarm that must be fixed by adding a time delay or by changing the trigger condition. Alarm KPIs (key performance indicators) are trended monthly: the alarm rate (alarms per day), the percent of time in alarm (the fraction of alarms that are active), the top 10 alarms (the most frequent), and the average alarm priority. A rising alarm rate or a high percent of time in alarm indicates a process problem or a bad alarm configuration. The top 10 alarms are the rationalization candidates — review them and suppress, re-prioritize, or fix the root cause. Document the KPIs monthly and review with the operations team to maintain a manageable alarm system.',
   50, 2,
   '[{"question":"What is a nuisance alarm?","options":["A high-priority alarm","An alarm that activates frequently but requires no operator action, training the operator to ignore it","An alarm that never activates","An alarm with no priority"],"correctIndex":1},{"question":"What is the most common rationalization candidate?","options":["The lowest-priority alarms","The top 10 most frequent alarms","The newest alarms","The oldest alarms"],"correctIndex":1}]');
END $$;

-- ===================== Reliability Centered Maintenance Strategy =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Reliability Centered Maintenance Strategy';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'RCM Analysis & FMEA', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'RCM Principles & FMEA',
   'Reliability Centered Maintenance (RCM) is a structured method for developing a maintenance program that balances cost, risk, and performance. RCM starts with the FMEA: list the functions of each asset, the failure modes, the effects, and the consequences. The consequence is classified as hidden (the failure is not evident during normal operation — e.g., a safety relay that does not trip on demand), safety/environmental, operational (production loss), or non-operational (no production loss). The consequence determines the maintenance task: a hidden failure gets a failure-finding task (test the safety relay monthly), a safety/environmental failure gets a proactive task (inspect, monitor, or redesign), an operational failure gets a proactive or a reactive task based on the cost-benefit, and a non-operational failure gets a reactive task (run to failure). The key RCM principle: the maintenance task must address the specific failure mode and its consequence — a generic PM on an asset without considering the failure modes wastes labor on components that do not fail and misses the components that do. The RCM analysis is documented in the equipment maintenance plan and reviewed annually.',
   55, 1,
   '[{"question":"What is the starting point of an RCM analysis?","options":["The maintenance budget","The FMEA — functions, failure modes, effects, and consequences","The equipment age","The spare parts inventory"],"correctIndex":1},{"question":"What maintenance task does a hidden failure get?","options":["Run to failure","A failure-finding task (test the function periodically)","A time-based replacement","No task"],"correctIndex":1}]'),
  (m_id, 'Task Selection & Program Implementation',
   'RCM task selection matches the task to the failure pattern. A failure with a clear wear-out pattern (bearing fatigue) gets a condition-based task (vibration monitoring) that detects degradation before failure. A failure with a random pattern (seal failure from cavitation) gets a design change (better flush, higher NPSH margin) rather than more frequent PM. A failure with an age-related pattern (filter clogging) gets a time-based replacement (change the filter every 3 months). A failure that is not safety or environmentally critical and has a low production impact gets a run-to-failure strategy (fix it when it breaks). The RCM program implementation: document the maintenance plan for each asset, train the technicians on the failure modes and the tasks, schedule the tasks in the CMMS, and trend the results. The program is reviewed annually — update the FMEA with new failure modes, adjust the task intervals based on the condition data, and remove tasks that are not adding value. The RCM program is a living system — it evolves as the equipment ages, the operating conditions change, and the failure data accumulates. A program that is not reviewed becomes a static PM schedule that does not adapt to the actual equipment condition.',
   50, 2,
   '[{"question":"What maintenance task does a wear-out failure pattern get?","options":["Run to failure","A condition-based task (vibration monitoring) that detects degradation before failure","A time-based replacement","No task"],"correctIndex":1},{"question":"How often should an RCM program be reviewed?","options":["Every 10 years","Annually","Monthly","Never — it is a one-time exercise"],"correctIndex":1}]');
END $$;

-- ===================== Digital Transformation & IIoT Fundamentals for Maintenance =====================
DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Digital Transformation & IIoT Fundamentals for Maintenance';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'IIoT Architecture & Edge Computing', 1) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'Edge Computing & Cloud Platforms',
   'The Industrial Internet of Things (IIoT) connects field devices to the internet, enabling data collection, analysis, and action at a scale that was not possible with traditional SCADA. The architecture has three layers: the edge (the field devices and the edge gateway), the cloud (the data storage and the analytics), and the application (the user interface and the decision support). The edge gateway collects data from the field devices (vibration sensors, flow meters, motor current sensors) and performs local processing (filtering, aggregation, and simple analytics) before sending the data to the cloud. The edge reduces the data volume (sending every raw vibration sample to the cloud is expensive) and provides local autonomy (the edge analytics can trigger a local action if the cloud is unavailable). The cloud stores the data, runs the advanced analytics (machine learning models for anomaly detection and remaining-life prediction), and provides the user interface (dashboards, alerts, reports). The application layer presents the results to the maintenance team: a dashboard showing the health of each asset, an alert when an anomaly is detected, and a report of the predicted remaining life. The IIoT platform (e.g., AWS IoT, Azure IoT, or an on-premise platform like GE Proficy or PTC ThingWorx) provides the infrastructure for the data pipeline.',
   55, 1,
   '[{"question":"What are the three layers of the IIoT architecture?","options":["PLC, HMI, SCADA","Edge, cloud, application","Sensors, wires, computer","Input, processing, output"],"correctIndex":1},{"question":"Why does the edge gateway perform local processing before sending data to the cloud?","options":["To improve security","To reduce the data volume and provide local autonomy when the cloud is unavailable","To speed up the network","To replace the cloud"],"correctIndex":1}]'),
  (m_id, 'Predictive Analytics & Business Case',
   'Predictive analytics uses machine learning to detect anomalies and predict remaining life from the condition data. A machine learning model is trained on the historical data (the vibration spectrum, the oil analysis, the motor current) and the known outcomes (the failures). The model learns the normal pattern and flags deviations as anomalies — a bearing that deviates from its baseline spectrum is flagged for investigation. The remaining-life prediction uses the degradation trend (the rate of change of the vibration, the wear metal concentration) to estimate the time to failure. The prediction allows the maintenance to be scheduled before the failure, during a planned window, rather than during a breakdown. The business case for IIoT: the cost of the IIoT installation (sensors, edge gateway, cloud subscription, analytics) is compared to the cost of the avoided failures (downtime, lost production, emergency repair). A typical plant with 50 critical machines and a $10,000 average downtime cost per failure, with 5 failures per year avoided by the IIoT, saves $500,000 per year. The IIoT cost ($100,000-200,000 for the installation and $50,000 per year for the cloud and analytics) pays back in 6-12 months. Build the business case with the plant-specific numbers — a generic case does not convince the finance team. Start with a pilot on 5-10 machines to prove the concept and the savings before scaling to the full plant.',
   50, 2,
   '[{"question":"What does a predictive analytics model learn from the historical data?","options":["The exact failure date","The normal pattern, and it flags deviations as anomalies","The equipment age","The maintenance cost"],"correctIndex":1},{"question":"How is the IIoT business case built?","options":["With generic industry numbers","With plant-specific numbers — the cost of the IIoT versus the cost of the avoided failures","With vendor estimates","Without any numbers"],"correctIndex":1}]');
END $$;
