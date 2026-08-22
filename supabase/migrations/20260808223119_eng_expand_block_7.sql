DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='OT Cybersecurity Fundamentals for Industrial Systems';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lesson: IEC 62443 Zones & Conduits
  UPDATE lessons SET content = '## Overview

IEC 62443 is the international standard for cybersecurity of industrial automation and control systems (IACS). Its central architectural concepts — zones and conduits — translate the abstract idea of "defense in depth" into a concrete, auditable design. This lesson covers the IEC 62443 standard family, the zone and conduit model, the security levels (SL), and the requirements that drive product selection and system design.

## Key Concepts

**The IEC 62443 Standard Family.** IEC 62443 is a multi-part standard: 62443-2-1 covers security program requirements for asset owners; 62443-3-3 covers system security requirements and security levels; 62443-4-1 covers product security development lifecycle requirements for suppliers; 62443-4-2 covers component security requirements. The standard addresses the full lifecycle: the owner''s security program, the system design, and the product development. Understanding which part applies to your role is the first step.

**Zones and Conduits.** A zone is a grouping of assets with the same security requirements (same trust level, same criticality). A conduit is a controlled communication path between zones. The zone/conduit model forces the designer to identify what needs protecting, group it by security requirement, and control every path between groups. Every conduit has a defined purpose, an allowlist of protocols and endpoints, and a security control (firewall, data diode, authenticated gateway). The model is deny-by-default: a conduit carries only what is explicitly permitted.

**Security Levels (SL).** IEC 62443 defines security levels that represent the threat: SL 1 (protection against casual/accidental violation), SL 2 (protection against intentional violation with simple means, low resources), SL 3 (protection against intentional violation with sophisticated means, moderate resources), SL 4 (protection against intentional violation with sophisticated means, high resources, possibly nation-state). The system''s required SL (SL-T, target) is determined by risk assessment; the system''s achieved SL (SL-A) is determined by the controls implemented. SL-A must meet or exceed SL-T for every zone.

**Requirements and Product Selection.** 62443-3-3 defines system requirements (SR) grouped into families (identification and authentication, use control, data confidentiality, etc.). Each SR has a level of enhancement for each SL. When selecting products, look for 62443-4-2 certification at the SL the zone requires; a product certified to SL 2 cannot meet SL 3 requirements. The system integrator combines certified products with procedural controls to achieve the zone''s target SL.

## Best Practices

- Identify which part of IEC 62443 applies to your role (owner, integrator, supplier).
- Perform a cyber risk assessment to determine each zone''s SL-T.
- Select products certified to 62443-4-2 at the SL the zone requires.
- Design zones and conduits deny-by-default; document every conduit''s purpose, allowlist, and control.
- Verify that the achieved SL-A meets or exceeds the target SL-T for every zone.

## Common Pitfalls

- **Treating 62443 as a product certification only** ignores the owner''s security program and system design.
- **No risk assessment** leaves the target SL undefined, so controls cannot be verified.
- **Products certified below the required SL** cannot meet the zone''s requirements.
- **Undocumented conduits** accumulate and become unmonitored paths.
- **SL-A below SL-T** means the zone does not meet its risk target.

## Real-World Example

A water utility performed a risk assessment that set SL-T 3 for its treatment plant control zone (a nation-state-targeted critical infrastructure). The integrator selected 62443-4-2 SL 3-certified controllers and firewalls, segmented the zone with a deny-by-default conduit to the DMZ, and implemented procedural controls (patching, access management, monitoring). The verification confirmed SL-A 3 met SL-T 3 for the zone. Without the risk assessment and product certification check, the zone might have been built to SL 2 and failed its target.

## Knowledge Check

Review the IEC 62443 family, the zone/conduit model, the security levels (SL-T and SL-A), and the product certification requirement before the quiz.',
  quiz = '[
    {"question":"What is a zone in IEC 62443?","options":["A single device","A grouping of assets with the same security requirements","A type of firewall","A protocol"],"answer":1,"explanation":"A zone groups assets with the same trust and criticality, enabling consistent controls."},
    {"question":"What is a conduit?","options":["A physical cable","A controlled communication path between zones with a defined allowlist and security control","A type of PLC","A brand of switch"],"answer":1,"explanation":"A conduit is the controlled path between zones, carrying only explicitly permitted traffic."},
    {"question":"What does SL-T represent?","options":["The achieved security level","The target security level determined by risk assessment","The product certification","The number of zones"],"answer":1,"explanation":"SL-T is the target security level from risk assessment; SL-A must meet or exceed it."},
    {"question":"What must SL-A do relative to SL-T?","options":["Be below it","Meet or exceed it","Be unrelated","Equal zero"],"answer":1,"explanation":"The achieved security level (SL-A) must meet or exceed the target (SL-T) for every zone."},
    {"question":"Which part of IEC 62443 covers component security requirements?","options":["62443-2-1","62443-3-3","62443-4-2","62443-1-1"],"answer":2,"explanation":"62443-4-2 covers component (product) security requirements; look for this certification when selecting products."},
    {"question":"What is a risk of selecting a product certified below the required SL?","options":["Lower cost","It cannot meet the zone\u2019s security requirements","Faster deployment","Better performance"],"answer":1,"explanation":"A product certified to a lower SL cannot meet the zone\u2019s target SL, regardless of configuration."},
    {"question":"What is the conduit design principle?","options":["Allow by default","Deny by default; carry only explicitly permitted traffic","Allow all on weekends","No documentation"],"answer":1,"explanation":"Deny-by-default conduits carry only defined traffic, limiting attack surface and blast radius."}
  ]'::jsonb
  WHERE title = 'IEC 62443 Zones & Conduits' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Update existing lesson: Patching, Incident Response & Risk Assessment
  UPDATE lessons SET content = '## Overview

Patching, incident response, and risk assessment are the operational pillars of an OT cybersecurity program. Where zone/conduit design and product selection are the architecture, these three processes keep the system secure throughout its life. This lesson covers the patch management lifecycle, the incident response plan, and the risk assessment that drives both.

## Key Concepts

**Patch Management Lifecycle.** OT patching differs from IT patching: patches must be tested because the controlled process cannot tolerate unexpected behavior, and patches must be applied during maintenance windows, not automatically. The lifecycle: monitor for advisories (vendor, ICS-CERT), assess severity and applicability, test in a non-production environment, schedule a maintenance window, apply with a rollback plan, and verify. Maintain a firmware/software inventory so applicability is known. Prioritize by severity and by exposure (an internet-facing device is patched before an isolated one).

**Incident Response Plan.** An incident response (IR) plan defines what happens when a compromise is suspected: detection, containment, eradication, recovery, and post-incident review. For OT, containment must consider the process — isolating a controller from the network may stop an attacker but also stop production, so the IR plan must define the safe state for each system. Define roles and contacts (operations, security, management, vendor, regulator), and exercise the plan annually; an unexercised plan fails when needed.

**Risk Assessment.** Risk assessment identifies threats, vulnerabilities, and consequences, and prioritizes mitigation. For OT, the assessment considers the process impact (safety, environmental, production) in addition to the data impact. Use a structured method (risk matrix, LOPA) and involve operations and safety, not just IT. Re-assess annually and after significant changes (new connection, new device, new threat). The risk assessment drives the patching priority and the IR plan scope.

**The Program, Not the Project.** Cybersecurity is a program, not a one-time project. The threat landscape changes, vulnerabilities are discovered, and the system changes. A program sustains the lifecycle: assess risk, implement controls, monitor, patch, respond, and re-assess. Without the program, the initial hardening decays within a year.

## Best Practices

- Maintain a firmware/software inventory and monitor vendor and ICS-CERT advisories.
- Test patches in a non-production environment before OT deployment; apply with a rollback plan.
- Define an incident response plan with roles, contacts, and the safe state for each system; exercise it annually.
- Perform a risk assessment annually and after significant changes, involving operations and safety.
- Treat cybersecurity as a sustained program, not a one-time project.

## Common Pitfalls

- **Automatic patching** can break the controlled process; OT patches must be tested.
- **No firmware inventory** leaves applicability unknown, so advisories cannot be acted on.
- **An unexercised IR plan** fails when needed; annual exercises find the gaps.
- **Risk assessment by IT only** misses process and safety impacts.
- **One-time hardening** decays without a sustained program.

## Real-World Example

A manufacturer had an IR plan on paper but had never exercised it. During an annual exercise, the team discovered that the plan called for isolating a controller from the network, but the only person who knew the firewall rules had left the company, and the vendor contact number was out of date. After the exercise, the plan was updated with current contacts, documented firewall rules, and a defined safe state. Six months later, a real incident was contained in hours, not days, because the plan worked.

## Knowledge Check

Review the patch management lifecycle, the incident response plan and the safe-state consideration, the risk assessment with operations involvement, and the program-not-project principle before the quiz.',
  quiz = '[
    {"question":"Why must OT patches be tested before deployment?","options":["To save money","The controlled process cannot tolerate unexpected behavior","To increase speed","Patches are free"],"answer":1,"explanation":"OT patches can affect the controlled process; testing in a non-production environment prevents surprises."},
    {"question":"What must an OT incident response plan define for each system?","options":["Only the firewall rules","The safe state, since isolating a controller may stop production","The vendor invoice","The patch schedule"],"answer":1,"explanation":"OT containment must consider the process; the plan defines the safe state so isolation does not cause a hazard."},
    {"question":"How often should the IR plan be exercised?","options":["Never","Annually","Every 10 years","Only after an incident"],"answer":1,"explanation":"Annual exercises find gaps (outdated contacts, unknown rules) before a real incident exposes them."},
    {"question":"Who should be involved in the OT risk assessment?","options":["IT only","Operations and safety, in addition to IT","The vendor only","No one"],"answer":1,"explanation":"OT risk includes process and safety impacts; operations and safety must participate alongside IT."},
    {"question":"How often should the risk assessment be re-done?","options":["Once, ever","Annually and after significant changes","Every 5 years","Only at project handover"],"answer":1,"explanation":"The threat landscape and the system change; annual re-assessment (plus post-change) keeps it current."},
    {"question":"Why maintain a firmware/software inventory?","options":["For decoration","To know which advisories apply to which devices","To increase storage","To slow patching"],"answer":1,"explanation":"Without an inventory, applicability of advisories is unknown, so patches cannot be acted on."},
    {"question":"What is the key lesson from the manufacturer\u2019s IR exercise?","options":["Plans are unnecessary","An unexercised plan fails; exercises find gaps like outdated contacts and unknown rules","Exercises are too expensive","IR is IT-only"],"answer":1,"explanation":"The exercise found the plan\u2019s gaps (departed expert, outdated contacts) before a real incident did."}
  ]'::jsonb
  WHERE title = 'Patching, Incident Response & Risk Assessment' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2: Access Control & Identity Management
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Access Control & Identity Management', 2) RETURNING id INTO m_id;

  -- Module 2, Lesson 1: Identity, Authentication & Remote Access
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Identity, Authentication & Remote Access', '## Overview

Identity and authentication are the front door of OT security: if an attacker can authenticate as a legitimate user, the network segmentation and product certification behind that door do not matter. OT identity management extends IT identity practices (unique accounts, strong authentication, centralized management) into the industrial environment, with adaptations for the OT realities of shared workstations, vendor access, and 24/7 operations. This lesson covers account management, authentication strength, and the special case of remote access.

## Key Concepts

**Account Management.** Every user has a unique, named account — no shared accounts, no generic logins like "operator." Unique accounts make actions attributable, which is essential for incident investigation and for compliance. Remove accounts when a user leaves; disable vendor accounts between visits. Use centralized authentication (Active Directory, RADIUS) where feasible so that access is revocable from one place; for OT devices that cannot join AD, use a privileged access management (PAM) system that vaults and rotates local accounts. Maintain an inventory of accounts and review it quarterly.

**Authentication Strength.** Passwords must be strong (long, complex, unique per system) and never default. Where supported, use multi-factor authentication (MFA) — especially for remote access and privileged accounts. For OT devices that do not support MFA natively, enforce MFA at the jump host or VPN that fronts them. Do not write passwords on the panel door; do not share them across shifts. The HMI is an authentication point too — configure HMI login with unique accounts and a screen-lock timeout.

**Remote Access.** Remote access is the most common intrusion vector. All remote access lands in the DMZ via a jump host with MFA and session recording; no direct connection from the internet to an OT device. Vendor access is provisioned per visit, time-limited, and recorded. Use a VPN with MFA for the connection to the DMZ, then a jump host for the final hop to the OT device, so that the vendor never has direct network access to the OT environment. Terminate the session and revoke the access when the visit ends.

**Privileged Access Management.** Privileged accounts (admin, root, service) are the highest-value targets. Use a PAM system to vault privileged credentials, check them out for a specific task, and rotate them after use. This eliminates shared admin passwords and provides an audit trail of who used the privilege, when, and for what. For OT devices that only support local accounts, the PAM system becomes the source of truth and the rotation mechanism.

## Best Practices

- Give every user a unique, named account; no shared or generic accounts.
- Use centralized authentication (AD, RADIUS) or a PAM system for local accounts; review accounts quarterly.
- Enforce strong passwords and MFA where supported, especially for remote and privileged access.
- Route all remote access through a DMZ jump host with MFA and session recording; provision vendor access per visit.
- Use a PAM system to vault, check out, and rotate privileged credentials.

## Common Pitfalls

- **Shared accounts** make actions non-attributable and cannot be revoked per-user.
- **Default passwords** on controllers and HMIs are trivially discoverable.
- **Direct internet access to OT devices** bypasses the DMZ and jump host.
- **Vendor access left open** between visits is a persistent intrusion vector.
- **No PAM for privileged accounts** leaves shared admin passwords that cannot be rotated or audited.

## Real-World Example

A plant used a shared "admin" account on all its controllers, and a vendor had VPN access that was never revoked after a project. A penetration test found the vendor credentials still active, used them to access the DMZ, and from there used the shared admin account to access every controller. After implementing per-user accounts, a PAM system for privileged access, and per-visit vendor provisioning through a jump host with recording, the same test found no path from the internet to a controller.

## Knowledge Check

Review unique accounts, centralized authentication and PAM, MFA for remote and privileged access, the DMZ jump host pattern for remote access, and per-visit vendor provisioning before the quiz.',
  45, 1,
  '[
    {"question":"Why require unique, named accounts for every user?","options":["To increase account count","Actions become attributable, essential for investigation and compliance","To slow login","To reduce security"],"answer":1,"explanation":"Unique accounts make every action attributable; shared accounts make investigation impossible."},
    {"question":"Where should remote access terminate?","options":["Directly on the PLC","At a jump host in the DMZ with MFA and session recording","On the HMI","On the enterprise historian"],"answer":1,"explanation":"Remote access lands in the DMZ via a jump host with MFA and recording; no direct path to OT devices."},
    {"question":"How should vendor access be provisioned?","options":["Permanently, for convenience","Per visit, time-limited, and recorded","Via shared accounts","Via default passwords"],"answer":1,"explanation":"Vendor access is per-visit, time-limited, and recorded; it is revoked when the visit ends."},
    {"question":"What does a PAM system do for privileged accounts?","options":["Shares them across the team","Vaults, checks out, and rotates credentials with an audit trail","Deletes them","Disables logging"],"answer":1,"explanation":"PAM vaults privileged credentials, checks them out per task, rotates them, and logs usage \u2014 eliminating shared admin passwords."},
    {"question":"Where should MFA be enforced?","options":["Only on the HMI","Especially for remote access and privileged accounts","Nowhere in OT","Only on the historian"],"answer":1,"explanation":"MFA is most critical for remote access and privileged accounts; for devices without native MFA, enforce it at the jump host or VPN."},
    {"question":"What was the root cause of the penetration test\u2019s success in the example?","options":["A firmware bug","A shared admin account and unrevoked vendor VPN access","A missing VLAN","A bad cable"],"answer":1,"explanation":"The vendor credentials were still active, and the shared admin account let the tester reach every controller."},
    {"question":"How often should the account inventory be reviewed?","options":["Never","Quarterly","Every 10 years","Only after an incident"],"answer":1,"explanation":"Quarterly review catches stale accounts (departed users, leftover vendor access) before they become intrusion vectors."}
  ]'::jsonb);

  -- Module 2, Lesson 2: Security Monitoring & Detection in OT
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Security Monitoring & Detection in OT', '## Overview

A hardened OT network that is not monitored is a hardened network that will not detect the attacker who eventually gets in. OT security monitoring extends IT security monitoring (log collection, SIEM, intrusion detection) into the industrial environment, with adaptations for the OT realities of legacy devices, limited bandwidth, and the criticality of the process. This lesson covers what to monitor, the OT-specific detection content, and the response workflow.

## Key Concepts

**What to Monitor.** Collect logs from firewalls (allowed and denied connections), switches (port up/down, configuration changes, authentication), controllers and HMIs (login, program changes, mode changes), and the jump host (session start/stop, commands). Forward to a SIEM (security information and event management) system in the DMZ or a dedicated security segment. For devices that cannot log (legacy PLCs), monitor the network around them via a passive tap and an OT-aware IDS that knows the expected CIP traffic and alerts on anomalies.

**OT-Specific Detection Content.** Generic IT detections (port scans, malware signatures) are necessary but not sufficient. OT-specific detections include: a new connection to a controller from an unexpected source, a program download to a running controller, a mode change (program to run or remote to local) outside a maintenance window, a configuration change on a switch, and authentication failures on the jump host. These detections require knowing the baseline (who talks to whom, when) and alerting on deviations. Use an OT-aware IDS (e.g., Claroty, Nozomi) that understands industrial protocols.

**The Response Workflow.** A detection is only valuable if it produces a response. Define the workflow: the SIEM alerts, the security analyst triages, and if confirmed, the incident response plan activates. For OT, the response must coordinate with operations — taking a controller offline to contain an attacker may stop production, so the decision involves operations and management. Define escalation paths and decision authority before an incident; during an incident is too late.

**Passive vs. Active Monitoring.** Passive monitoring (a tap that copies traffic, an IDS that reads it) cannot affect the process and is safe for any OT network. Active monitoring (scanning, vulnerability probing) can disrupt legacy devices and must be carefully scoped — scan only during maintenance windows, and never scan a running controller. Prefer passive monitoring for continuous visibility and reserve active scanning for scheduled assessments.

## Best Practices

- Collect logs from firewalls, switches, controllers, HMIs, and the jump host; forward to a SIEM.
- For devices that cannot log, monitor the network passively with an OT-aware IDS.
- Develop OT-specific detections: unexpected controller connections, program downloads, mode changes, config changes.
- Define the response workflow with operations coordination and decision authority before an incident.
- Prefer passive monitoring for continuous visibility; reserve active scanning for maintenance windows.

## Common Pitfalls

- **No log collection** leaves intrusion invisible; a hardened network without monitoring is blind.
- **IT-only detections** miss OT-specific events like program downloads and mode changes.
- **No response workflow** means detections produce no action.
- **Active scanning of running controllers** can disrupt the process.
- **No operations coordination** in the response leads to unsafe containment decisions.

## Real-World Example

A plant deployed passive network monitoring with an OT-aware IDS that learned the baseline CIP traffic. One night, the IDS alerted on a program download to a running controller from an engineering workstation that was not in the maintenance schedule. Investigation found a compromised workstation being used to push modified logic. Because the detection was specific (program download, off-schedule, unexpected source) and the response workflow was defined, the attack was caught before the modified logic ran.

## Knowledge Check

Review what to monitor, OT-specific detection content, the response workflow with operations coordination, and passive vs. active monitoring before the quiz.',
  45, 2,
  '[
    {"question":"What should be collected and forwarded to a SIEM?","options":["Only firewall logs","Logs from firewalls, switches, controllers, HMIs, and the jump host","Only controller logs","Nothing"],"answer":1,"explanation":"Comprehensive log collection from all security-relevant devices gives the SIEM the full picture."},
    {"question":"How should devices that cannot log be monitored?","options":["Ignore them","Passively, via a network tap and an OT-aware IDS","By scanning them continuously","By rebooting them"],"answer":1,"explanation":"Passive monitoring reads traffic without affecting the process, ideal for legacy devices that cannot log."},
    {"question":"What is an OT-specific detection?","options":["A port scan","A program download to a running controller outside a maintenance window","A malware signature","A failed IT login"],"answer":1,"explanation":"OT detections target industrial events: unexpected controller connections, program downloads, mode changes, config changes."},
    {"question":"Why must the OT response workflow coordinate with operations?","options":["To speed up the response","Taking a controller offline to contain an attacker may stop production, so operations must be involved","To reduce logging","To avoid detection"],"answer":1,"explanation":"OT containment can affect the process; the response workflow defines operations coordination and decision authority."},
    {"question":"Why prefer passive monitoring over active scanning?","options":["Passive is cheaper","Active scanning can disrupt legacy devices and running controllers","Passive is faster","Active is illegal"],"answer":1,"explanation":"Passive monitoring cannot affect the process; active scanning can disrupt legacy devices and must be scheduled."},
    {"question":"What did the OT-aware IDS detect in the example?","options":["A port scan","A program download to a running controller from an off-schedule, unexpected source","A malware signature","A failed login"],"answer":1,"explanation":"The IDS learned the baseline and alerted on the off-schedule program download, catching the compromised workstation."},
    {"question":"When should the response workflow and decision authority be defined?","options":["During an incident","Before an incident","Never","Only by IT"],"answer":1,"explanation":"Defining escalation paths and decision authority before an incident ensures a coordinated, safe response."}
  ]'::jsonb);

  -- Add module 3: Security Program & Compliance
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Security Program & Compliance', 3) RETURNING id INTO m_id;

  -- Module 3, Lesson 1: Building an OT Security Program
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Building an OT Security Program', '## Overview

An OT security program is the organizational structure that sustains cybersecurity across the lifecycle: the policies, roles, responsibilities, and processes that keep the system secure year after year. Without a program, the initial hardening decays; with a program, the hardening is maintained and improved. This lesson covers the components of an OT security program, the roles and responsibilities, and the metrics that prove the program is working.

## Key Concepts

**Program Components.** An OT security program comprises: a security policy approved by management, risk assessment and management, zone/conduit design and maintenance, access control and identity management, patch and vulnerability management, monitoring and detection, incident response, and continuous improvement. Each component has an owner, a process, and a metric. The program is documented, approved, and audited; it is not a binder on a shelf but a living set of practices.

**Roles and Responsibilities.** Define who does what: the asset owner (operations) owns the risk and the system; the security team owns the program, monitoring, and incident response; the integrator/vendor supports patching and incident response; IT supports identity and network services where they cross into OT. The most common failure is unclear ownership — "is security IT''s job or operations''?" The answer is both, with defined boundaries. Use a RACI (responsible, accountable, consulted, informed) matrix to make ownership explicit.

**Management Buy-In.** A security program without management buy-in is unfunded, unstaffed, and unenforced. The risk assessment provides the business case: the consequences (safety, environmental, production, regulatory) of a compromise, translated into terms management cares about. Present the risk and the program cost together; a program that prevents a multi-day outage pays for itself with one avoided incident.

**Metrics.** Measure the program: patch compliance (% of critical patches applied within SLA), vulnerability scan findings (open vs. closed), access review completion, IR exercise completion, and time-to-detect / time-to-respond from exercises and incidents. Review metrics quarterly with management; metrics that are not reviewed are decoration. Use metrics to drive improvement, not to assign blame.

## Best Practices

- Document and approve the security program; assign an owner to each component with a process and a metric.
- Use a RACI matrix to make roles and responsibilities explicit across operations, security, IT, and vendors.
- Build the business case via risk assessment; secure management buy-in before seeking budget and staff.
- Track a focused set of metrics (patch compliance, vulnerability findings, access reviews, IR exercises, TTD/TTR).
- Review metrics quarterly with management to drive improvement, not blame.

## Common Pitfalls

- **No documented program** means practices depend on individuals and decay when they leave.
- **Unclear ownership** (IT vs. operations) leaves gaps that neither fills.
- **No management buy-in** leaves the program unfunded and unenforced.
- **No metrics** means the program''s effectiveness is unknown.
- **Metrics used for blame** drive concealment, not improvement.

## Real-World Example

A plant had a security program on paper but no owner for patching; advisories arrived and sat in an inbox. After assigning patching to the security team with operations support, defining a 30-day SLA for critical patches, and tracking patch compliance as a quarterly metric, compliance rose from 40% to 95% within two quarters. The metric and the named owner, not the policy binder, drove the improvement.

## Knowledge Check

Review the program components, roles and the RACI matrix, management buy-in via the risk-based business case, and the focused metrics with quarterly review before the quiz.',
  45, 1,
  '[
    {"question":"What are the components of an OT security program?","options":["Only patching","Policy, risk assessment, zone/conduit design, access control, patching, monitoring, IR, and continuous improvement","Only incident response","Only monitoring"],"answer":1,"explanation":"A complete program spans policy through continuous improvement, each with an owner, process, and metric."},
    {"question":"What tool makes roles and responsibilities explicit?","options":["A network diagram","A RACI matrix","A P&ID","A risk graph"],"answer":1,"explanation":"A RACI matrix defines who is responsible, accountable, consulted, and informed for each activity, eliminating ownership gaps."},
    {"question":"How is management buy-in secured?","options":["By demanding it","By presenting the risk assessment\u2019s consequences and the program cost together","By skipping the business case","By waiting for an incident"],"answer":1,"explanation":"The risk assessment translates consequences into business terms; presenting risk and cost together justifies the program."},
    {"question":"What is a key metric for the patching component?","options":["Number of vendors","Patch compliance (% of critical patches applied within SLA)","Number of PLCs","Cable length"],"answer":1,"explanation":"Patch compliance measures whether critical patches are applied within the SLA, a direct indicator of the patching process."},
    {"question":"How often should program metrics be reviewed with management?","options":["Never","Quarterly","Every 10 years","Only after an incident"],"answer":1,"explanation":"Quarterly review keeps the program visible to management and drives improvement."},
    {"question":"What is a common failure of OT security programs?","options":["Too many owners","Unclear ownership (IT vs. operations) leaving gaps","Too much budget","Too many metrics"],"answer":1,"explanation":"Without explicit ownership, neither IT nor operations fills the gap, and practices decay."},
    {"question":"What drove the improvement in the example?","options":["The policy binder","A named owner and a tracked metric (patch compliance)","A new vendor","A firmware update"],"answer":1,"explanation":"Assigning an owner and tracking patch compliance \u2014 not the policy document \u2014 raised compliance from 40% to 95%."}
  ]'::jsonb);

  -- Module 3, Lesson 2: Compliance, Standards & Audit Readiness
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Compliance, Standards & Audit Readiness', '## Overview

Compliance and audit readiness are the evidence that an OT security program is real, not aspirational. Regulated industries (chemicals, power, water, pharma) face mandatory cybersecurity standards (IEC 62443, NERC CIP, TSA pipeline directives), and even unregulated industries face customer and insurer expectations. This lesson covers the standards landscape, the audit-ready evidence, and the practice of being continuously audit-ready rather than scrambling before an audit.

## Key Concepts

**The Standards Landscape.** IEC 62443 is the international standard for IACS cybersecurity, applicable across industries. NERC CIP (Critical Infrastructure Protection) is mandatory for the North American bulk power system. TSA security directives apply to pipeline and rail operators in the US. ISO 27001 is a general information security management standard that some organizations extend into OT. Sector-specific regulations (FDA 21 CFR Part 11 for pharma, EPA for water) add cybersecurity expectations. Know which standards apply to your industry and your sites.

**Audit-Ready Evidence.** An auditor does not assess intent; they assess evidence. For each control, have the evidence ready: the security policy (approved, dated), the risk assessment (current, signed off), the zone/conduit diagram (current, matching the field), the access review records, the patch records (what, when, tested, applied), the IR plan and exercise records, the monitoring logs and alert handling records, and the metrics reports. Organize evidence by control so an auditor can find it; disorganized evidence fails an audit even when the practice is sound.

**Continuous Audit Readiness.** Audit readiness is a state, not an event. Maintain the evidence continuously: update the zone/conduit diagram when the network changes, complete the access review quarterly, record every patch, exercise the IR plan annually. An organization that maintains audit readiness year-round passes audits with minimal preparation; an organization that scrambles before an audit produces inconsistent evidence and fails. Tie evidence maintenance to the change-request workflow so that changes produce their own evidence.

**Gap Assessments.** Periodically (annually or before a known audit) perform a gap assessment against the applicable standard: identify where the practice falls short of the requirement, prioritize the gaps by risk, and close them on a schedule. A gap assessment before an audit finds the gaps when there is time to fix them; during an audit, it is too late.

## Best Practices

- Know which standards apply to your industry and sites; map your program to their requirements.
- Maintain audit-ready evidence organized by control: policy, risk assessment, diagrams, reviews, patches, IR, monitoring, metrics.
- Be continuously audit-ready by maintaining evidence year-round, tied to the change workflow.
- Perform annual gap assessments against applicable standards; close gaps on a risk-prioritized schedule.
- Treat evidence as the product; an auditor assesses evidence, not intent.

## Common Pitfalls

- **Not knowing which standards apply** leads to surprises during an audit.
- **Disorganized evidence** fails an audit even when the practice is sound.
- **Scrambling before an audit** produces inconsistent, incomplete evidence.
- **No gap assessment** means gaps are found by the auditor, with no time to fix them.
- **Stale diagrams and records** that do not match the field undermine credibility.

## Real-World Example

A pipeline operator faced a TSA security directive audit. Because the operator maintained audit-ready evidence year-round (current zone/conduit diagrams, quarterly access reviews, recorded patches, annual IR exercises), the audit was a matter of presenting the organized evidence. A peer operator that scrambled for two weeks before the audit produced inconsistent diagrams and missing patch records and received findings that required months of remediation. Continuous readiness was the difference.

## Knowledge Check

Review the standards landscape, audit-ready evidence organized by control, continuous audit readiness, and gap assessments before the quiz.',
  45, 2,
  '[
    {"question":"What does an auditor assess?","options":["Intent","Evidence","Future plans","Budget"],"answer":1,"explanation":"Auditors assess evidence; disorganized or missing evidence fails an audit even when the practice is sound."},
    {"question":"Which standard is mandatory for the North American bulk power system?","options":["IEC 62443","NERC CIP","ISO 27001","TSA directives"],"answer":1,"explanation":"NERC CIP is mandatory for the North American bulk power system; IEC 62443 is voluntary/international."},
    {"question":"How should audit-ready evidence be organized?","options":["By date","By control, so an auditor can find it","By vendor","By site only"],"answer":1,"explanation":"Evidence organized by control maps directly to the auditor\u2019s checklist, making the audit efficient."},
    {"question":"What is continuous audit readiness?","options":["Scrambling before an audit","Maintaining evidence year-round, tied to the change workflow","Ignoring audits","Auditing once a decade"],"answer":1,"explanation":"Year-round evidence maintenance, tied to changes, means audits are presentations, not scrambles."},
    {"question":"When should a gap assessment be performed?","options":["During the audit","Annually or before a known audit, when there is time to fix gaps","Never","After the audit"],"answer":1,"explanation":"A pre-audit gap assessment finds gaps with time to close them; during the audit, it is too late."},
    {"question":"What undermined the peer operator\u2019s TSA audit in the example?","options":["A missing PLC","Inconsistent diagrams and missing patch records from scrambling","A firmware bug","Too many metrics"],"answer":1,"explanation":"Scrambling produced inconsistent evidence; the continuously ready operator passed by presenting organized records."},
    {"question":"Why tie evidence maintenance to the change workflow?","options":["To slow changes","So changes produce their own evidence, keeping records current","To increase cost","To avoid audits"],"answer":1,"explanation":"Tying evidence to changes keeps diagrams and records current automatically, sustaining audit readiness."}
  ]'::jsonb);

END $$;