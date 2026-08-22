DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Ethernet/IP Network Design & Segmentation';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lesson: Topology, IGMP Snooping & Multicast Management
  UPDATE lessons SET content = '## Overview

EtherNet/IP is the dominant industrial network for Logix-style control systems, but it inherits all the complexity of Ethernet — multicast traffic, broadcast domains, and the potential for traffic storms that can stop a controller. The network topology and multicast management strategy determine whether the network is deterministic and reliable or a source of intermittent faults. This lesson covers topology choices, the multicast traffic that EtherNet/IP produces, and the IGMP snooping and multicast management that keep it under control.

## Key Concepts

**Topology Choices.** The three common topologies are star, ring, and linear/star-trunk. A star topology uses a central switch with dedicated links to each device — simplest, highest bandwidth per device, but the central switch is a single point of failure. A ring topology connects switches in a loop with RSTP or DLR (Device Level Ring) for resilience — survives a single cable break, but ring convergence time (50 ms to seconds) must fit the application. A linear/star-trunk daisy-chains switches with a trunk — economical for long runs, but a trunk break isolates downstream devices. Choose by the availability and distance requirements; many plants use a resilient ring backbone with star drops to devices.

**EtherNet/IP Multicast Traffic.** EtherNet/IP uses producer/consumer communication for I/O: a producer (a controller or I/O adapter) produces data and multiple consumers receive it via multicast. Without management, multicast traffic floods every port on every switch, loading every device and every link — a phenomenon called multicast flooding. On a small network this is tolerable; on a large network it can consume bandwidth and cause intermittent communication faults. Multicast management is the single most important network design consideration for EtherNet/IP.

**IGMP Snooping.** IGMP (Internet Group Management Protocol) snooping is a switch feature that constrains multicast traffic to only the ports that have joined the multicast group. Without IGMP snooping, multicast floods all ports; with it, multicast goes only to consumers that have subscribed. This is essential on any EtherNet/IP network with more than a few devices. Configure IGMP snooping on all managed switches; configure an IGMP querier (often on the core switch or a router) so that snooping has a query source. Without a querier, snooping may not function correctly.

**Multicast Addressing.** EtherNet/IP assigns multicast addresses to connections; by default, the addresses can collide across the network, causing traffic to mix. Use the multicast address allocation feature in the controller properties to assign unique multicast address ranges per controller, preventing cross-controller traffic collision. On large networks, segment multicast domains via VLANs so that one controller''s multicast does not reach another''s consumers.

## Best Practices

- Choose topology by availability and distance: resilient ring backbone with star drops is common.
- Enable IGMP snooping on all managed switches and configure an IGMP querier.
- Use the controller''s multicast address allocation to assign unique ranges per controller.
- Segment multicast domains via VLANs on large networks to prevent cross-controller traffic collision.
- Document the topology, multicast addressing, and IGMP configuration in the network architecture diagram.

## Common Pitfalls

- **IGMP snooping without a querier** may not function, leaving multicast flooding.
- **Unmanaged switches** flood multicast to all ports, loading every device.
- **Multicast address collisions** mix traffic from different controllers.
- **Single switch (star) without redundancy** is a single point of failure.
- **No VLAN segmentation on large networks** lets multicast and broadcast traffic cross domains.

## Real-World Example

A large assembly line had 80 EtherNet/IP devices on unmanaged switches, and multicast traffic flooded every port. Intermittent I/O faults occurred during peak traffic, with no apparent cause. After replacing the unmanaged switches with managed switches with IGMP snooping and a querier, and segmenting the network into per-cell VLANs, multicast flooding stopped and the intermittent faults disappeared. The topology and multicast management, not the devices, had been the problem.

## Knowledge Check

Review the topology choices, the multicast traffic that EtherNet/IP produces, IGMP snooping and the querier requirement, and multicast address allocation before the quiz.',
  quiz = '[
    {"question":"What causes multicast flooding on an EtherNet/IP network?","options":["Too few devices","Multicast traffic sent to all ports without IGMP snooping","Too much memory","Wrong firmware"],"answer":1,"explanation":"Without IGMP snooping, multicast floods every port, loading every device and link."},
    {"question":"What does IGMP snooping do?","options":["Increases multicast traffic","Constrains multicast to ports that have joined the multicast group","Disables multicast","Encrypts multicast"],"answer":1,"explanation":"IGMP snooping limits multicast to subscribed ports, preventing flooding."},
    {"question":"What must accompany IGMP snooping for it to function correctly?","options":["A faster switch","An IGMP querier","More devices","Unmanaged switches"],"answer":1,"explanation":"An IGMP querier provides the query source that snooping needs; without it, snooping may not function."},
    {"question":"Which topology survives a single cable break?","options":["Star","Ring with RSTP or DLR","Linear without redundancy","Bus"],"answer":1,"explanation":"A ring with RSTP or DLR survives a single break; convergence time must fit the application."},
    {"question":"How can multicast address collisions be prevented across controllers?","options":["Use unmanaged switches","Use the controller\u2019s multicast address allocation to assign unique ranges per controller","Disable multicast","Use more VLANs only"],"answer":1,"explanation":"Multicast address allocation assigns unique ranges per controller, preventing traffic collision."},
    {"question":"Why segment multicast domains via VLANs on large networks?","options":["To increase traffic","To prevent one controller\u2019s multicast from reaching another\u2019s consumers","To slow the network","To reduce security"],"answer":1,"explanation":"VLAN segmentation keeps each controller\u2019s multicast within its domain, preventing cross-controller collision."},
    {"question":"What was the root cause of the assembly line\u2019s intermittent I/O faults?","options":["Bad devices","Multicast flooding from unmanaged switches, fixed by IGMP snooping and VLAN segmentation","Firmware bugs","Too few devices"],"answer":1,"explanation":"The unmanaged switches flooded multicast; managed switches with snooping and VLANs resolved the faults."}
  ]'::jsonb
  WHERE title = 'Topology, IGMP Snooping & Multicast Management' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Update existing lesson: QoS & Network Segmentation
  UPDATE lessons SET content = '## Overview

Quality of Service (QoS) and network segmentation are the two mechanisms that let EtherNet/IP carry both deterministic control traffic and best-effort messaging on the same network without the messaging starving the control. QoS prioritizes traffic by class; segmentation isolates traffic by zone. Together they make a converged industrial network reliable and secure. This lesson covers QoS classification and prioritization, the segmentation strategies (VLANs, firewalls, the DMZ), and the configuration that makes them work.

## Key Concepts

**Quality of Service (QoS).** QoS classifies traffic and prioritizes it at congested links. EtherNet/IP control traffic (I/O, motion) is latency-sensitive and must be prioritized over messaging (uploading a project, historian polling, web access). The standard approach uses DSCP (Differentiated Services Code Point) markings: control traffic marked Expedited Forwarding (EF, DSCP 46) gets highest priority; messaging marked Best Effort (DSCP 0) gets default. Switches queue by priority; during congestion, EF traffic is served first. Configure the controller and switches to mark and honor DSCP; without it, congestion delays control traffic.

**Network Segmentation.** Segmentation isolates traffic by zone: a cell VLAN, a site OT backbone, a DMZ, an enterprise network. Each segment is a broadcast and multicast domain; traffic stays within it unless explicitly routed. Segmentation serves two purposes: it constrains multicast and broadcast (performance), and it limits the blast radius of a compromise (security). Use VLANs for intra-site segmentation and firewalls for inter-zone segmentation, with a DMZ between OT and IT per the Purdue Model.

**The DMZ and Inter-Zone Routing.** The DMZ (Purdue Level 3.5) is the buffer between OT and enterprise. No connection traverses the DMZ; each terminates there (historian relay, jump host, patch server). Inter-zone routing is deny-by-default: a firewall allows only explicitly defined flows (protocol, source, destination, port). Document every allowed flow and review periodically; "temporary" rules accumulate and become permanent security holes.

**QoS and Segmentation Together.** QoS handles congestion within a segment; segmentation handles isolation between segments. A well-designed network uses both: VLANs segment the cell traffic, the cell VLAN prioritizes control over messaging via DSCP, and the firewall between the cell and the backbone allows only the defined flows. Without QoS, congestion delays control; without segmentation, a fault or compromise spreads across the network.

## Best Practices

- Mark EtherNet/IP control traffic with DSCP EF and configure switches to honor it.
- Segment the network into cell VLANs with a site OT backbone and a DMZ to enterprise.
- Make inter-zone routing deny-by-default; document and periodically review every allowed flow.
- Use the DMZ to terminate OT-to-enterprise connections; never let a connection traverse it.
- Combine QoS (within-segment prioritization) and segmentation (between-segment isolation).

## Common Pitfalls

- **No QoS** lets messaging starve control traffic during congestion.
- **Flat networks** let multicast, broadcast, and compromise spread uncontained.
- **Allow-by-default firewalls** let any traffic through; "temporary" rules accumulate.
- **Direct OT-to-enterprise connections** bypass the DMZ and defeat segmentation.
- **DSCP markings not honored by switches** make QoS ineffective.

## Real-World Example

A plant had a converged network carrying I/O, motion, historian polling, and engineering uploads. During a project upload, the I/O traffic was delayed and a motion axis faulted on a timeout. After implementing DSCP EF marking for control traffic and configuring the switches to honor it, the upload no longer affected I/O. Combined with per-cell VLANs and a deny-by-default firewall to the backbone, the network became deterministic and secure.

## Knowledge Check

Review QoS and DSCP EF marking, network segmentation via VLANs and firewalls, the DMZ and deny-by-default routing, and the combination of QoS and segmentation before the quiz.',
  quiz = '[
    {"question":"What does QoS do for EtherNet/IP traffic?","options":["Encrypts it","Classifies and prioritizes traffic so control is served before messaging during congestion","Increases bandwidth","Disables multicast"],"answer":1,"explanation":"QoS prioritizes control traffic over messaging at congested links via DSCP markings."},
    {"question":"Which DSCP marking is standard for EtherNet/IP control traffic?","options":["Best Effort (DSCP 0)","Expedited Forwarding (EF, DSCP 46)","Default (DSCP 0)","Assured Forwarding (DSCP 10)"],"answer":1,"explanation":"Control traffic is marked EF (DSCP 46) for highest priority; messaging is Best Effort (DSCP 0)."},
    {"question":"What are the two purposes of network segmentation?","options":["Speed and cost","Constraining multicast/broadcast (performance) and limiting blast radius (security)","Encryption and compression","Power and cooling"],"answer":1,"explanation":"Segmentation constrains traffic within zones and isolates faults and compromises between zones."},
    {"question":"What is the rule for inter-zone routing?","options":["Allow by default","Deny by default; allow only explicitly defined flows","Allow all on weekends","No routing between zones"],"answer":1,"explanation":"Deny-by-default with explicit allows limits traffic to defined, reviewed flows."},
    {"question":"What is the DMZ\u2019s role between OT and enterprise?","options":["A direct connection path","A buffer where connections terminate; none traverse it","A faster switch","A backup server"],"answer":1,"explanation":"The DMZ terminates OT-to-enterprise connections so no direct path exists for lateral movement."},
    {"question":"Why must switches honor DSCP markings?","options":["To increase speed","Without honoring, QoS markings have no effect and control traffic is not prioritized","To reduce cost","To enable multicast"],"answer":1,"explanation":"Markings only matter if switches queue by them; un-honored DSCP provides no prioritization."},
    {"question":"What caused the motion axis timeout in the example?","options":["A bad axis","I/O traffic delayed by a project upload, fixed by DSCP EF marking for control traffic","A firmware bug","A missing VLAN"],"answer":1,"explanation":"The upload starved control traffic; DSCP EF marking prioritized I/O and motion, resolving the timeout."}
  ]'::jsonb
  WHERE title = 'QoS & Network Segmentation' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2: Network Resilience & Troubleshooting
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Network Resilience & Troubleshooting', 2) RETURNING id INTO m_id;

  -- Module 2, Lesson 1: Network Redundancy & Resilience Protocols
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Network Redundancy & Resilience Protocols', '## Overview

A network that stops when a cable breaks is a network that stops the plant. Industrial network resilience protocols — DLR (Device Level Ring), RSTP (Rapid Spanning Tree), MSTP (Multiple Spanning Tree), and PRP/HSR — provide the redundancy that keeps the network running through a single failure. This lesson covers the protocols, their convergence times and trade-offs, and the design considerations for a resilient industrial network.

## Key Concepts

**DLR (Device Level Ring).** DLR is the ODVA ring protocol for EtherNet/IP at the device level. Devices and switches form a ring; a DLR supervisor monitors the ring and, on a break, re-converges in under 50 ms (often under 3 ms for ring-only nodes). DLR is ideal for cell-level rings of EtherNet/IP devices where sub-50 ms convergence is required. DLR is simpler and faster than RSTP but is limited to rings and to EtherNet/IP devices that support it.

**RSTP and MSTP.** RSTP (IEEE 802.1w) is the rapid spanning tree protocol, converging in 1–10 seconds (vs. 30–50 s for legacy STP). MSTP (IEEE 802.1s) extends RSTP to multiple spanning trees, one per VLAN, allowing per-VLAN traffic engineering. RSTP/MSTP are vendor-neutral and support any topology (ring, mesh, star), making them suitable for the site backbone where multi-vendor switches are common. The trade-off is convergence time: RSTP is slower than DLR, so use DLR for sub-50 ms cell rings and RSTP/MSTP for the backbone where seconds are tolerable.

**PRP and HSR.** PRP (Parallel Redundancy Protocol, IEC 62439-3) sends every frame over two parallel networks; the receiver takes the first and discards the duplicate, achieving zero-recovery-time redundancy. HSR (High-availability Seamless Redundancy) does the same over a ring. PRP/HSR provide seamless redundancy but require dedicated hardware (PRP nodes or HSR-capable switches) and duplicate cabling — expensive, used only for the most critical applications (substation protection, safety systems).

**Choosing a Protocol.** Match the protocol to the convergence requirement and the topology. DLR for sub-50 ms cell rings of EtherNet/IP devices. RSTP/MSTP for multi-vendor backbones where seconds are tolerable. PRP/HSR for zero-recovery-time critical applications. Do not mix protocols in the same ring without a clear understanding of interaction; a DLR ring connected to an RSTP backbone needs the DLR-to-RSTP boundary configured correctly.

## Best Practices

- Use DLR for sub-50 ms cell-level rings of EtherNet/IP devices.
- Use RSTP/MSTP for multi-vendor backbones where seconds of convergence are tolerable.
- Use PRP/HSR only for zero-recovery-time critical applications, accepting the cost.
- Do not mix redundancy protocols in the same ring without understanding the interaction.
- Test failover during commissioning; an untested ring may not converge as expected.

## Common Pitfalls

- **RSTP where sub-50 ms is required** converges too slowly for the application.
- **Mixing DLR and RSTP without boundary configuration** produces unexpected behavior.
- **Untested failover** fails when a real cable break occurs.
- **PRP/HSR without duplicate cabling** provides no redundancy.
- **Single ring with no backbone** — a second break isolates part of the network.

## Real-World Example

A bottling line used a DLR ring of 30 EtherNet/IP devices for sub-50 ms convergence, connected via a DLR-to-RSTP boundary to an RSTP site backbone. When a forklift cut a ring cable, the DLR re-converged in 12 ms and production continued uninterrupted. The backbone, with multi-vendor switches, used RSTP and converged in 4 s on a separate cable cut — tolerable for the backbone''s monitoring and historian traffic but not for the cell, hence the DLR choice.

## Knowledge Check

Review DLR, RSTP/MSTP, PRP/HSR, their convergence times and trade-offs, and the protocol-to-requirement matching before the quiz.',
  45, 1,
  '[
    {"question":"What is DLR\u2019s typical convergence time?","options":["30\u201350 seconds","Under 50 ms (often under 3 ms for ring-only nodes)","1\u201310 seconds","Zero"],"answer":1,"explanation":"DLR re-converges in under 50 ms, ideal for cell-level EtherNet/IP rings."},
    {"question":"What is RSTP\u2019s typical convergence time?","options":["30\u201350 seconds","1\u201310 seconds","Under 50 ms","Zero"],"answer":1,"explanation":"RSTP converges in 1\u201310 seconds, suitable for backbones where seconds are tolerable."},
    {"question":"Which protocol provides zero-recovery-time redundancy?","options":["RSTP","MSTP","PRP/HSR","DLR"],"answer":2,"explanation":"PRP/HSR send frames over two paths, achieving zero recovery time at the cost of duplicate hardware and cabling."},
    {"question":"Where is DLR the best choice?","options":["Multi-vendor backbones","Sub-50 ms cell-level rings of EtherNet/IP devices","Substation protection","Enterprise networks"],"answer":1,"explanation":"DLR is fast and simple but limited to rings of EtherNet/IP devices at the cell level."},
    {"question":"Where is RSTP/MSTP the best choice?","options":["Sub-50 ms cell rings","Multi-vendor backbones where seconds of convergence are tolerable","Zero-recovery-time safety","Single device connections"],"answer":1,"explanation":"RSTP/MSTP are vendor-neutral and support any topology, suited to multi-vendor backbones."},
    {"question":"What is a risk of mixing DLR and RSTP in the same ring?","options":["Faster convergence","Unexpected behavior without correct boundary configuration","Lower cost","Nothing"],"answer":1,"explanation":"Mixing protocols requires a correctly configured DLR-to-RSTP boundary; otherwise behavior is unpredictable."},
    {"question":"What must be done with ring failover before go-live?","options":["Nothing","Test during commissioning","Only after the first cable cut","Disable it"],"answer":1,"explanation":"An untested ring may not converge as expected; testing during commissioning verifies the redundancy."}
  ]'::jsonb);

  -- Module 2, Lesson 2: Network Troubleshooting & Packet Analysis
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Network Troubleshooting & Packet Analysis', '## Overview

When an EtherNet/IP network misbehaves, the symptoms are often intermittent and the cause invisible: a missed I/O connection, a delayed message, a multicast storm. The tools that make the invisible visible are packet capture and analysis. This lesson covers the troubleshooting methodology, the tools (ping, port mirroring, packet capture, Wireshark), and the common faults that packet analysis reveals.

## Key Concepts

**The Troubleshooting Methodology.** Start with the symptom: which device, which connection, which time. Isolate the scope: is it one device, one cell, or the whole network? Check the physical layer first (cable, port, link, duplex), then the network layer (IP, subnet, gateway, ARP), then the application layer (the EtherNet/IP connection, the CIP path). Move from the simple and likely to the complex and rare; most faults are physical or configuration, not exotic protocol bugs.

**Basic Tools.** Ping tests reachability and latency; continuous ping (ping -t) catches intermittent loss. ARP tables show whether the controller can resolve a device''s MAC; a missing ARP entry indicates a layer 2 problem. Port statistics on managed switches show errors (CRC, runts, collisions) that indicate a physical or duplex issue. The controller''s I/O connection status shows whether a connection is active, idle, or faulted, and the fault code points to the cause.

**Port Mirroring and Packet Capture.** When basic tools do not reveal the cause, capture the traffic. Port mirroring (SPAN) on a managed switch copies traffic from one or more ports to a monitor port where a capture tool (Wireshark, a field network analyzer) records it. Packet capture shows the actual frames: who is talking to whom, how often, with what latency, and whether frames are being lost or retransmitted. Wireshark''s EtherNet/IP dissector decodes CIP messages, making the application layer visible.

**Common Faults Revealed by Packet Analysis.** A duplex mismatch (one side full, one side half) shows as collisions and CRC errors on the half-duplex side. A multicast storm shows as a flood of multicast frames on every port — indicating IGMP snooping is off or misconfigured. A missed I/O connection shows as repeated connection requests with no response — indicating a path, RPI, or connection-count problem. A broadcast storm shows as thousands of broadcast frames per second — indicating a loop without spanning tree.

## Best Practices

- Follow a methodology: symptom, scope, physical, network, application.
- Use basic tools first (ping, ARP, port statistics, connection status) before packet capture.
- Use port mirroring to capture traffic for Wireshark analysis when basic tools are insufficient.
- Learn the EtherNet/IP dissector in Wireshark to decode CIP messages.
- Keep a known-good packet capture from commissioning to compare against during troubleshooting.

## Common Pitfalls

- **Skipping the physical layer** and chasing protocol bugs when the cause is a bad cable.
- **No port mirroring available** (unmanaged switches) leaves packet capture impossible.
- **Ignoring port error statistics** that clearly indicate a duplex or cable problem.
- **No known-good baseline capture** makes it hard to spot what changed.
- **Capturing without a filter** produces huge captures that are hard to analyze.

## Real-World Example

A cell had intermittent I/O connection faults that occurred a few times per hour. Ping showed no loss; port statistics showed no errors. A port-mirrored capture revealed that the controller was sending connection requests to an adapter that occasionally did not respond — and the adapter''s port was dropping frames due to a duplex mismatch with an auto-negotiation failure. Setting both sides to forced full-duplex eliminated the drops and the faults. The packet capture, not the basic tools, revealed the cause.

## Knowledge Check

Review the troubleshooting methodology, the basic tools, port mirroring and packet capture, and the common faults that packet analysis reveals before the quiz.',
  45, 2,
  '[
    {"question":"What is the correct troubleshooting order?","options":["Application, network, physical","Physical, network, application","Network, physical, application","Application, physical, network"],"answer":1,"explanation":"Start at the physical layer (most common cause), then network, then application."},
    {"question":"What does port mirroring (SPAN) do?","options":["Encrypts traffic","Copies traffic from one or more ports to a monitor port for capture","Increases bandwidth","Disables a port"],"answer":1,"explanation":"Port mirroring lets a capture tool record traffic from other ports for analysis."},
    {"question":"What does a duplex mismatch show as in port statistics?","options":["No errors","Collisions and CRC errors on the half-duplex side","Broadcast storms","Multicast floods"],"answer":1,"explanation":"A duplex mismatch produces collisions and CRC errors on the half-duplex side."},
    {"question":"What does a multicast storm in a packet capture indicate?","options":["Normal traffic","IGMP snooping is off or misconfigured","A duplex mismatch","A cable cut"],"answer":1,"explanation":"A multicast storm (multicast flooding all ports) indicates IGMP snooping is not constraining multicast."},
    {"question":"Why keep a known-good baseline capture from commissioning?","options":["For decoration","To compare against during troubleshooting and spot what changed","For compliance only","To delete later"],"answer":1,"explanation":"A baseline capture lets you diff current behavior against known-good to find the change."},
    {"question":"What does the EtherNet/IP dissector in Wireshark do?","options":["Encrypts CIP","Decodes CIP messages so the application layer is visible","Increases speed","Disables multicast"],"answer":1,"explanation":"The dissector decodes CIP, making the application-layer messages readable in the capture."},
    {"question":"What did the packet capture reveal in the example that basic tools missed?","options":["A bad controller","Frames dropped due to a duplex mismatch from auto-negotiation failure","A firmware bug","A missing VLAN"],"answer":1,"explanation":"The capture showed the adapter occasionally not responding due to a duplex mismatch; forcing full-duplex fixed it."}
  ]'::jsonb);

  -- Add module 3: Industrial Network Security & Management
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Industrial Network Security & Management', 3) RETURNING id INTO m_id;

  -- Module 3, Lesson 1: OT Network Security Hardening
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'OT Network Security Hardening', '## Overview

An EtherNet/IP network connected to anything beyond itself is a network that can be attacked. OT network security hardening applies the principles of defense in depth to the industrial network: segment, restrict, monitor, and patch. This lesson covers the hardening practices specific to the network layer — switch configuration, port security, management access, and firmware — that complement the architectural segmentation covered earlier.

## Key Concepts

**Switch Hardening.** Disable unused switch ports so that a rogue device cannot simply plug in. Enable port security to limit the MAC addresses per port, preventing MAC flooding and rogue device insertion. Disable unused protocols and services on the switch (Telnet, HTTP, SNMP v1/v2) and use secure alternatives (SSH, HTTPS, SNMP v3). Change default passwords and use unique credentials per switch. These basic practices eliminate the most common network-layer attack vectors.

**Management Access.** Switches and controllers should be managed only from a dedicated management VLAN or subnet, not from the production network. Use SSH and HTTPS, not Telnet and HTTP. Use a centralized authentication server (RADIUS/TACACS+) so that access is per-user and revocable, not shared. Log all management access. For remote access, use a jump host in the DMZ with multi-factor authentication and session recording — never expose a switch or controller directly to the internet.

**Firmware and Patching.** Switch and controller firmware has vulnerabilities; vendors release patches. Maintain an inventory of firmware versions and a patching schedule. Test patches in a non-production environment before deploying to the OT network. Patch during a maintenance window, with a rollback plan. Subscribe to vendor security advisories and prioritize patches by severity. An unpatched switch with a known vulnerability is an open door.

**Monitoring and Logging.** Enable syslog on switches and controllers and forward to a central log collector or SIEM. Configure SNMP v3 (not v1/v2) for monitoring. Monitor for configuration changes (which can indicate intrusion or error), port up/down events, and authentication failures. A network that is not monitored cannot be defended; the logs are the evidence of an attack or a misconfiguration.

## Best Practices

- Disable unused ports and enable port security to prevent rogue device insertion.
- Use SSH/HTTPS and centralized authentication (RADIUS/TACACS+); change default passwords.
- Manage switches and controllers from a dedicated management VLAN, not the production network.
- Maintain a firmware inventory and patch schedule; test patches before OT deployment.
- Enable syslog and SNMP v3 monitoring; forward to a central collector or SIEM.

## Common Pitfalls

- **Enabled unused ports** let a rogue device plug in and access the network.
- **Telnet and default passwords** on switches are trivially exploitable.
- **Shared management credentials** cannot be revoked per-user and are not auditable.
- **Unpatched switches** with known vulnerabilities are open doors.
- **No monitoring or logging** leaves intrusion and misconfiguration invisible.

## Real-World Example

A plant audit found that all switches used the default password, had Telnet enabled, and had 40 unused ports active. A penetration test plugged a laptop into an unused port, logged into a switch via Telnet with the default password, and reconfigured the network to capture traffic. After hardening (disabling ports, enabling port security, SSH-only, unique passwords, RADIUS, syslog to a SIEM), the same test found no exploitable entry point. The hardening eliminated every vector the test had used.

## Knowledge Check

Review switch hardening, secure management access, firmware patching, and monitoring/logging before the quiz.',
  45, 1,
  '[
    {"question":"Why disable unused switch ports?","options":["To save power","To prevent a rogue device from plugging in and accessing the network","To increase speed","To reduce cost"],"answer":1,"explanation":"Disabled ports prevent unauthorized physical access; enabled unused ports are an open door."},
    {"question":"Which protocols should be disabled on switches?","options":["SSH and HTTPS","Telnet, HTTP, and SNMP v1/v2","Syslog","SNMP v3"],"answer":1,"explanation":"Insecure protocols (Telnet, HTTP, SNMP v1/v2) should be disabled in favor of SSH, HTTPS, SNMP v3."},
    {"question":"How should switch and controller management access be controlled?","options":["From the production network with shared passwords","From a dedicated management VLAN with SSH/HTTPS and centralized authentication","Via Telnet with default passwords","From any device on the internet"],"answer":1,"explanation":"Management from a dedicated VLAN with SSH/HTTPS and RADIUS/TACACS+ is per-user, revocable, and auditable."},
    {"question":"What should be done before deploying a switch patch to the OT network?","options":["Deploy immediately","Test in a non-production environment with a rollback plan","Ignore it","Email it to the operator"],"answer":1,"explanation":"Test patches before OT deployment; deploy during a maintenance window with a rollback plan."},
    {"question":"Why enable syslog and SNMP v3 monitoring?","options":["To increase traffic","To detect intrusion, misconfiguration, and changes via central logs","To slow the network","To reduce security"],"answer":1,"explanation":"Central logs and SNMP v3 monitoring provide the evidence of attacks and misconfiguration."},
    {"question":"What did the penetration test exploit in the example?","options":["A firmware bug","Default passwords, Telnet, and enabled unused ports","A missing VLAN","A bad cable"],"answer":1,"explanation":"The test used default passwords, Telnet, and an unused port; hardening eliminated every vector."},
    {"question":"Why use centralized authentication (RADIUS/TACACS+)?","options":["To share one password","Access is per-user, revocable, and auditable","To increase speed","To reduce logging"],"answer":1,"explanation":"Centralized authentication makes access per-user and revocable, with audit logs, unlike shared credentials."}
  ]'::jsonb);

  -- Module 3, Lesson 2: Network Management & Monitoring Systems
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Network Management & Monitoring Systems', '## Overview

A network that is not monitored is a network that fails silently. Industrial network management and monitoring systems (NMS) provide the visibility to detect faults before they stop production and to diagnose them quickly when they do. This lesson covers the NMS architecture for OT, the SNMP and syslog data sources, and the alerts and dashboards that turn data into action.

## Key Concepts

**NMS Architecture for OT.** An OT NMS collects data from switches, controllers, and devices via SNMP (v3 for security), syslog, and (increasingly) streaming telemetry. It stores the data, evaluates thresholds, and alerts on faults. The NMS should be in the DMZ or a dedicated management segment, not on the production network, so that monitoring traffic does not compete with control traffic and so that a compromised NMS does not sit on the OT network. For multi-site operations, a collector per site feeds a central NMS.

**SNMP and Syslog.** SNMP (Simple Network Management Protocol) polls devices for interface counters, CPU, memory, and status; SNMP v3 provides authentication and encryption (v1/v2 do not and should be disabled). Syslog receives event messages from devices (link up/down, authentication failure, configuration change). Together they provide the full picture: SNMP for periodic metrics, syslog for events. Configure devices to send both to the NMS, and configure the NMS to correlate them.

**Alerts and Thresholds.** An NMS that alerts on everything alerts on nothing. Configure thresholds that matter: link up/down on critical links, interface error rates above a threshold, CPU above 80%, authentication failures, configuration changes. Route alerts to the people who can act (operations for link faults, security for authentication failures) and suppress alerts during maintenance windows. Review alert volume monthly; if a threshold produces too many alerts, tune it or the underlying problem.

**Dashboards and Reporting.** Dashboards show the current state (topology map with link status, interface utilization, recent events). Reports show trends (bandwidth growth, error rate trends, device availability over time). Use dashboards for operations and reports for capacity planning and reliability review. A dashboard that no one looks at is decoration; tie dashboard use to the operations workflow.

## Best Practices

- Place the NMS in the DMZ or a dedicated management segment, not on the production network.
- Use SNMP v3 (not v1/v2) and syslog; configure devices to send both to the NMS.
- Configure meaningful thresholds and route alerts to the people who can act; suppress during maintenance.
- Review alert volume monthly and tune thresholds or fix underlying problems.
- Use dashboards for operations and reports for capacity planning and reliability review.

## Common Pitfalls

- **NMS on the production network** competes with control traffic and is a risk if compromised.
- **SNMP v1/v2** sends credentials in clear text and should be disabled.
- **Alerting on everything** produces alert fatigue and ensures nothing is acted on.
- **No alert routing** sends security events to operators who cannot act on them.
- **Unused dashboards** collect dust and provide no operational value.

## Real-World Example

A multi-site manufacturer deployed an NMS in the DMZ with a collector per site, polling switches via SNMP v3 and receiving syslog. The NMS alerted operations on a critical link''s rising error rate weeks before the link failed, allowing a scheduled cable replacement during a maintenance window instead of an unplanned outage. The monthly alert review caught a threshold that produced 200 alerts per week on a non-critical link; tuning it restored alert usefulness.

## Knowledge Check

Review the NMS architecture, SNMP v3 and syslog, alert thresholds and routing, and dashboards vs. reports before the quiz.',
  45, 2,
  '[
    {"question":"Where should the OT NMS be placed?","options":["On the production network","In the DMZ or a dedicated management segment","On a PLC","On the internet"],"answer":1,"explanation":"The DMZ or management segment isolates the NMS from control traffic and limits risk if compromised."},
    {"question":"Which SNMP version should be used?","options":["v1","v2","v3","None"],"answer":2,"explanation":"SNMP v3 provides authentication and encryption; v1/v2 send credentials in clear text and should be disabled."},
    {"question":"What does syslog provide that SNMP polling does not?","options":["Periodic metrics","Event messages (link up/down, auth failures, config changes)","Encryption","Faster polling"],"answer":1,"explanation":"Syslog delivers events in real time; SNMP polls periodic metrics. Both are needed for the full picture."},
    {"question":"Why configure meaningful thresholds rather than alerting on everything?","options":["To increase alert volume","Alerting on everything produces alert fatigue and ensures nothing is acted on","To reduce security","To slow the NMS"],"answer":1,"explanation":"Too many alerts cause fatigue; meaningful thresholds ensure alerts are acted on."},
    {"question":"What should be done with a threshold producing too many alerts?","options":["Ignore it","Tune it or fix the underlying problem","Delete the NMS","Disable all alerts"],"answer":1,"explanation":"Monthly alert review catches noisy thresholds; tune them or address the root cause to restore alert value."},
    {"question":"What is the role of dashboards vs. reports?","options":["Both are decoration","Dashboards for current operational state; reports for trends and capacity planning","Both are the same","Reports for operations, dashboards for planning"],"answer":1,"explanation":"Dashboards show current state for operations; reports show trends for capacity and reliability planning."},
    {"question":"What did the NMS alert on in the example?","options":["A failed link","A rising error rate on a critical link weeks before failure","A configuration change","A missing device"],"answer":1,"explanation":"The NMS caught the rising error rate early, enabling a scheduled replacement instead of an unplanned outage."}
  ]'::jsonb);
END $$;