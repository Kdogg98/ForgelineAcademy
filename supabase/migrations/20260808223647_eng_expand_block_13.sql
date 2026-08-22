DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Industrial Networking (Managed Switches, VLANs, QoS)';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lesson 1: VLAN Segmentation & Trunking
  UPDATE lessons SET content = '## Overview

VLAN segmentation and trunking are the fundamental techniques that turn a flat, shared Ethernet into a structured, isolated industrial network. A VLAN (Virtual LAN) is a logical broadcast domain that groups devices regardless of physical location, and trunking carries multiple VLANs over a single link. This lesson covers the VLAN concept, the access and trunk port modes, the 802.1Q tag, and the design practices for segmenting an industrial network.

## Key Concepts

**The VLAN Concept.** A VLAN is a logical grouping of devices that share a broadcast and multicast domain, independent of physical switch location. Devices in the same VLAN communicate at layer 2 as if on the same switch; devices in different VLANs require a router or layer-3 switch to communicate. VLANs segment traffic for performance (broadcast and multicast stay within the VLAN) and for security (a device in one VLAN cannot directly reach a device in another). In an industrial network, a common design is one VLAN per cell or per controller, with a site-wide backbone VLAN connecting them.

**Access and Trunk Ports.** An access port carries one VLAN (untagged); the device on the port does not know about VLANs. A trunk port carries multiple VLANs, each tagged with an 802.1Q tag that identifies the VLAN. Trunks connect switches to each other and to routers, carrying all the VLANs that span the link. Configure device ports as access ports in the correct VLAN (a controller port in the cell VLAN, a PC port in the engineering VLAN); configure inter-switch links as trunks carrying the needed VLANs. Do not trunk to an end device unless the device is VLAN-aware (a few controllers and PCs are).

**The 802.1Q Tag.** The 802.1Q tag is a 4-byte header inserted into the Ethernet frame that carries the VLAN ID (12 bits, allowing 4094 VLANs). The tag is added on egress from a trunk port and removed on ingress to an access port, so end devices see untagged frames. The native VLAN on a trunk is sent untagged (a legacy feature; modern practice is to tag all VLANs including the native, or to use a dummy native VLAN to avoid untagged traffic). Misconfigured native VLANs cause traffic to leak between VLANs.

**VLAN Design for Industrial Networks.** Segment by cell or by controller, with one VLAN per segment. Use a backbone VLAN or layer-3 switching to route between VLANs. Keep EtherNet/IP multicast within a VLAN (the multicast does not cross a router), so a controller''s multicast stays in its cell. Use a separate management VLAN for switch and controller management traffic, isolated from the production traffic. Document the VLAN design (VLAN IDs, which devices, which ports) in the network architecture diagram; an undocumented VLAN design is unmaintainable.

## Best Practices

- Segment by cell or controller, with one VLAN per segment, to constrain broadcast and multicast.
- Configure device ports as access ports in the correct VLAN; configure inter-switch links as trunks.
- Tag all VLANs on trunks (including the native, or use a dummy native VLAN) to prevent traffic leakage.
- Use a separate management VLAN for switch and controller management, isolated from production.
- Keep EtherNet/IP multicast within a VLAN; route between VLANs via a layer-3 switch or router.
- Document the VLAN design (IDs, devices, ports) in the network architecture diagram.

## Common Pitfalls

- **Flat networks** with no VLANs let broadcast, multicast, and compromise spread uncontained.
- **Misconfigured native VLAN** on a trunk leaks traffic between VLANs.
- **Trunking to an end device** that is not VLAN-aware causes communication failures.
- **No management VLAN** mixes management traffic with production traffic.
- **Undocumented VLAN design** becomes unmaintainable as the network grows.

## Real-World Example

A plant had a flat network where all 200 devices shared one broadcast domain. A broadcast storm from a misconfigured device took down the entire network, stopping all controllers. After segmenting into per-cell VLANs with a layer-3 backbone, a broadcast storm in one cell was contained to that cell, and the rest of the plant continued running. The VLAN segmentation turned a plant-wide outage into a single-cell event.

## Knowledge Check

Review the VLAN concept, access vs. trunk ports, the 802.1Q tag and native VLAN, and the per-cell segmentation design before the quiz.',
  quiz = '[
    {"question":"What is a VLAN?","options":["A physical switch","A logical broadcast domain that groups devices regardless of physical location","A type of cable","A protocol"],"answer":1,"explanation":"A VLAN is a logical grouping that shares a broadcast/multicast domain, independent of physical switch location."},
    {"question":"What does an access port carry?","options":["Multiple VLANs tagged","One VLAN, untagged","No traffic","All VLANs"],"answer":1,"explanation":"An access port carries one VLAN, untagged; the end device does not know about VLANs."},
    {"question":"What does a trunk port carry?","options":["One VLAN","Multiple VLANs, each tagged with an 802.1Q tag","No traffic","Only the native VLAN"],"answer":1,"explanation":"A trunk carries multiple VLANs, each tagged with 802.1Q; trunks connect switches and routers."},
    {"question":"What is the native VLAN on a trunk?","options":["The encrypted VLAN","The VLAN sent untagged (use a dummy native or tag all to prevent leakage)","The management VLAN","The first VLAN"],"answer":1,"explanation":"The native VLAN is sent untagged; misconfiguration leaks traffic. Modern practice tags all VLANs or uses a dummy native."},
    {"question":"How should an industrial network be segmented?","options":["One flat VLAN","By cell or controller, with one VLAN per segment and a layer-3 backbone","By device type only","By vendor only"],"answer":1,"explanation":"Per-cell VLANs constrain broadcast/multicast and limit the blast radius of faults and compromise."},
    {"question":"Why use a separate management VLAN?","options":["To increase traffic","To isolate switch and controller management from production traffic","To slow the network","To reduce security"],"answer":1,"explanation":"A management VLAN isolates management traffic, improving security and keeping it off the production path."},
    {"question":"What did VLAN segmentation achieve in the example?","options":["A plant-wide outage","A broadcast storm was contained to one cell; the rest of the plant kept running","Slower communication","No effect"],"answer":1,"explanation":"Per-cell VLANs turned a plant-wide broadcast-storm outage into a single-cell event."}
  ]'::jsonb
  WHERE title = 'VLAN Segmentation & Trunking' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Update existing lesson 2: RSTP, MSTP & Network Monitoring
  UPDATE lessons SET content = '## Overview

RSTP, MSTP, and network monitoring are the resilience and visibility mechanisms that keep a segmented industrial network running and knowable. RSTP and MSTP provide loop-free resilience in multi-switch networks; network monitoring provides the visibility to detect faults before they stop production. This lesson covers the spanning tree protocols, the convergence behavior, and the monitoring tools and practices.

## Key Concepts

**Spanning Tree Basics.** Spanning tree (STP, IEEE 802.1D) prevents loops in a network with redundant paths by blocking ports that would create a loop, leaving one active path and blocked backups. On a link failure, spanning tree re-converges by unblocking a backup port. Legacy STP converges in 30–50 seconds — too slow for most industrial applications. RSTP (IEEE 802.1w) converges in 1–10 seconds; MSTP (IEEE 802.1s) extends RSTP to multiple spanning trees, one per VLAN or group of VLANs, allowing per-VLAN traffic engineering.

**RSTP and MSTP Convergence.** RSTP converges faster than STP by using rapid transitions (a port can move to forwarding without waiting for the full timer if it is an edge port or if it receives an agreement from the neighbor). MSTP allows different VLANs to use different active paths, so a link failure affects only the VLANs whose path it carried, not all VLANs. For industrial networks, RSTP or MSTP is the minimum; legacy STP is too slow. Configure the root bridge explicitly (the core switch), do not let it be elected randomly, and configure the bridge priorities to control the topology.

**Network Monitoring Tools.** Managed switches support SNMP (Simple Network Management Protocol) for polling interface counters, CPU, and status, and syslog for event messages (link up/down, authentication, configuration change). An NMS (network management system) collects this data, evaluates thresholds, and alerts. For EtherNet/IP, the controller''s connection status and the switch''s port statistics reveal I/O and multicast issues. Use SNMP v3 (authenticated, encrypted), not v1/v2 (clear text). Configure syslog to a central collector for event correlation.

**Monitoring Practices.** Monitor the metrics that matter: link up/down on critical links, interface error rates (CRC, collisions) above a threshold, CPU above 80%, authentication failures, configuration changes. Set thresholds that alert before a fault (a rising error rate before a link fails). Review alerts daily; route them to the people who can act. Periodically review trends (bandwidth growth, error rate trends) for capacity planning. A network that is not monitored cannot be defended or maintained.

## Best Practices

- Use RSTP or MSTP (not legacy STP) for industrial networks; configure the root bridge explicitly.
- Use MSTP to allow per-VLAN traffic engineering and to limit the impact of a link failure to affected VLANs.
- Monitor via SNMP v3 and syslog to a central NMS; configure thresholds that alert before a fault.
- Review alerts daily and trends periodically for capacity planning.
- Monitor link up/down, error rates, CPU, authentication, and configuration changes on critical devices.

## Common Pitfalls

- **Legacy STP** converges too slowly (30–50 s) for industrial applications.
- **Random root bridge election** produces an unpredictable topology; configure the root explicitly.
- **SNMP v1/v2** sends credentials in clear text; use v3.
- **No monitoring** leaves faults invisible until they stop production.
- **Thresholds set too high** alert after the fault, not before.

## Real-World Example

A plant used MSTP with a configured root bridge and per-VLAN spanning trees. When a backbone link failed, only the VLANs whose path it carried were affected, and MSTP re-converged those VLANs in 4 seconds while the other VLANs continued uninterrupted. The NMS, polling via SNMP v3, alerted on the link failure and the re-convergence, and the error-rate trend over the next week showed a degrading backup link that was replaced before it failed. The resilience and the monitoring together kept the plant running.

## Knowledge Check

Review RSTP/MSTP and their convergence, the root bridge configuration, SNMP v3 and syslog monitoring, and the thresholds and trend review practices before the quiz.',
  quiz = '[
    {"question":"What is the convergence time of legacy STP?","options":["1–10 seconds","30–50 seconds","Under 50 ms","Zero"],"answer":1,"explanation":"Legacy STP converges in 30–50 seconds, too slow for industrial applications; use RSTP or MSTP."},
    {"question":"What does MSTP allow that RSTP does not?","options":["Faster convergence","Per-VLAN spanning trees, so different VLANs use different active paths","Encryption","More VLANs"],"answer":1,"explanation":"MSTP supports multiple spanning trees, one per VLAN group, enabling per-VLAN traffic engineering and limiting failure impact."},
    {"question":"How should the root bridge be determined?","options":["By random election","By explicit configuration of the core switch","By the lowest MAC address","By the vendor default"],"answer":1,"explanation":"Configure the root bridge explicitly to control the topology; random election produces unpredictable results."},
    {"question":"Which SNMP version should be used for monitoring?","options":["v1","v2","v3","None"],"answer":2,"explanation":"SNMP v3 provides authentication and encryption; v1/v2 send credentials in clear text and should be disabled."},
    {"question":"What should thresholds be set to do?","options":["Alert after the fault","Alert before the fault (e.g., a rising error rate before a link fails)","Never alert","Alert on everything"],"answer":1,"explanation":"Thresholds should alert before a fault (a rising error rate, a rising CPU) so action can be taken before production stops."},
    {"question":"What did MSTP achieve in the example?","options":["All VLANs were affected by the link failure","Only the VLANs whose path the link carried were affected; others continued uninterrupted","No convergence","Slower convergence than STP"],"answer":1,"explanation":"MSTP limited the failure impact to the affected VLANs and re-converged them in 4 seconds while others ran on."},
    {"question":"What did the error-rate trend reveal in the example?","options":["Nothing","A degrading backup link that was replaced before it failed","A fast link","A new VLAN"],"answer":1,"explanation":"The trend showed a degrading backup link; proactive replacement prevented a second failure."}
  ]'::jsonb
  WHERE title = 'RSTP, MSTP & Network Monitoring' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2: Advanced Network Features & Security (sort_order 2)
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Advanced Network Features & Security', 2) RETURNING id INTO m_id;

  -- Module 2, Lesson 1: Port Security, ACLs & Network Access Control (sort_order 1, 45 min)
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (
    m_id,
    'Port Security, ACLs & Network Access Control',
    '## Overview

Port security, access control lists (ACLs), and network access control (NAC) are the network-layer defenses that restrict who and what can connect to the industrial network. Where VLANs segment traffic, these features control access at the port and the flow. This lesson covers port security for rogue device prevention, ACLs for flow restriction, and NAC for identity-based access.

## Key Concepts

**Port Security.** Port security limits the MAC addresses that can use a switch port: a port can be configured to allow only specific MACs, or a maximum number of MACs, with a violation action (protect, restrict, shutdown). This prevents rogue device insertion (an attacker cannot plug into an enabled port and access the network) and MAC flooding (an attacker cannot flood the MAC table to force traffic flooding). Configure port security on all access ports with the expected MAC or a reasonable maximum; shutdown on violation alerts the team to investigate.

**Access Control Lists (ACLs).** An ACL is a rule set on a switch or router that permits or denies traffic by source, destination, protocol, and port. In an industrial network, ACLs restrict inter-VLAN traffic to only the required flows: a cell VLAN can reach the historian in the DMZ but not the enterprise VLAN; a maintenance PC can reach the controllers but a general PC cannot. ACLs are deny-by-default (an explicit permit for each allowed flow) or permit-by-default (an explicit deny for each blocked flow); use deny-by-default for security, with documented permits. Review ACLs periodically; "temporary" permits accumulate.

**Network Access Control (NAC).** NAC authenticates devices before granting network access: a device connects, the NAC checks its identity (802.1X with a RADIUS server, or MAC-based for devices that cannot authenticate), and assigns it to the correct VLAN based on its identity and posture. NAC ensures that only authorized devices connect and that each device lands in the correct VLAN. For industrial networks, MAC-based NAC is common (many PLCs cannot do 802.1X); for PCs and engineering workstations, 802.1X with certificates is stronger.

**Defense in Depth.** Port security, ACLs, and NAC are layers in a defense-in-depth strategy: port security prevents rogue physical access, NAC prevents unauthorized logical access, and ACLs restrict what authorized devices can reach. No single layer is sufficient; together they reduce the attack surface and the blast radius of a compromise. Combine them with segmentation (VLANs), monitoring (SNMP, syslog), and hardening (disabled ports, strong passwords) for a layered defense.

## Best Practices

- Enable port security on all access ports with the expected MAC or a reasonable maximum; shutdown on violation.
- Use deny-by-default ACLs for inter-VLAN traffic, with documented permits; review periodically.
- Deploy NAC (802.1X for capable devices, MAC-based for PLCs) to authenticate devices and assign the correct VLAN.
- Combine port security, NAC, and ACLs as layers in a defense-in-depth strategy.
- Document all access controls and review them periodically; "temporary" rules accumulate.

## Common Pitfalls

- **Enabled unused ports** let a rogue device plug in; disable and secure all access ports.
- **Permit-by-default ACLs** let any traffic through; use deny-by-default with explicit permits.
- **No NAC** lets any device connect and land in the default VLAN, regardless of authorization.
- **Single-layer defense** is bypassed by a single failure; defense in depth requires multiple layers.
- **Unreviewed access controls** accumulate "temporary" rules that become permanent holes.

## Real-World Example

A plant audit found that a contractor had plugged a laptop into an enabled, unsecured port and accessed the controller VLAN. After enabling port security (shutdown on violation), deploying MAC-based NAC (devices landed in the correct VLAN by MAC), and a deny-by-default ACL between the controller and enterprise VLANs, a repeat test found no path from an unauthorized device to a controller. The three layers together closed what any one would have missed.

## Knowledge Check

Review port security and violation actions, ACLs and deny-by-default, NAC (802.1X and MAC-based), and defense in depth before the quiz.',
    45,
    1,
    '[
    {"question":"What does port security prevent?","options":["Slow traffic","Rogue device insertion and MAC flooding","Broadcast storms","Configuration changes"],"answer":1,"explanation":"Port security limits the MACs per port, preventing rogue devices and MAC flooding; violation actions alert or shut down the port."},
    {"question":"Which ACL mode is preferred for security?","options":["Permit-by-default","Deny-by-default with explicit permits","No ACLs","Permit all on weekends"],"answer":1,"explanation":"Deny-by-default with documented permits restricts traffic to defined flows; permit-by-default lets anything through."},
    {"question":"What does NAC do?","options":["Encrypts traffic","Authenticates devices and assigns them to the correct VLAN based on identity and posture","Increases speed","Disables ports"],"answer":1,"explanation":"NAC ensures only authorized devices connect and land in the correct VLAN; 802.1X for capable devices, MAC-based for PLCs."},
    {"question":"Why is MAC-based NAC common for PLCs?","options":["PLCs are fast","Many PLCs cannot do 802.1X authentication","MAC-based is more secure","It is cheaper only"],"answer":1,"explanation":"Many PLCs lack 802.1X supplicant support; MAC-based NAC authenticates by MAC address as a practical alternative."},
    {"question":"What is defense in depth?","options":["A single strong firewall","Multiple layers (port security, NAC, ACLs, VLANs, monitoring) so no single failure compromises all","A thick wall","Encryption only"],"answer":1,"explanation":"Defense in depth layers controls so that bypassing one does not bypass all; no single layer is sufficient."},
    {"question":"What did the contractor exploit in the example?","options":["A firmware bug","An enabled, unsecured port giving access to the controller VLAN","A missing VLAN","A bad cable"],"answer":1,"explanation":"The enabled unsecured port let an unauthorized device reach the controllers; port security, NAC, and ACLs closed the path."},
    {"question":"Why review access controls periodically?","options":["To increase their number","“Temporary” rules accumulate and become permanent holes","To slow the network","It is not necessary"],"answer":1,"explanation":"Periodic review removes stale rules and “temporary” permits that would otherwise become permanent security holes."}
  ]'::jsonb
  );

  -- Module 2, Lesson 2: Industrial Protocols: PROFINET, EtherCAT & Modbus TCP (sort_order 2, 45 min)
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (
    m_id,
    'Industrial Protocols: PROFINET, EtherCAT & Modbus TCP',
    '## Overview

Beyond EtherNet/IP, the industrial network world includes PROFINET, EtherCAT, and Modbus TCP, each with distinct characteristics, strengths, and application niches. Understanding the protocol landscape lets an engineer choose the right protocol for the application and integrate multi-protocol environments. This lesson covers the major industrial Ethernet protocols, their communication models, and the selection criteria.

## Key Concepts

**PROFINET.** PROFINET is the industrial Ethernet standard from the PROFIBUS/PROFINET organization (heavily used in Siemens environments). It has three conformance classes: NRT (non-real-time, TCP/IP, for configuration and diagnostics), RT (real-time, layer-2 prioritized, for general I/O, ~10 ms), and IRT (isochronous real-time, hardware-scheduled, for motion and high-speed I/O, <1 ms). PROFINET uses a controller-device model with a device description file (GSD). It is the standard in Siemens-centric plants and supports motion via IRT.

**EtherCAT.** EtherCAT is a deterministic, high-speed fieldbus that uses a "on the fly" processing model: the master sends a frame that passes through each slave, which reads its data and writes its data as the frame passes, with the frame returning to the master in one cycle. This gives very short cycle times (down to 12 µs for small frames) and tight synchronization (distributed clocks, <1 µs jitter). EtherCAT is ideal for motion control and high-speed I/O where deterministic, sub-cycle communication is required. It uses a master-slave model with a device description (ESI file).

**Modbus TCP.** Modbus TCP is the Ethernet version of the classic Modbus protocol: a simple, open, master-slave (client-server) protocol that reads and writes registers and coils. It is ubiquitous, supported by nearly every industrial device, and easy to implement, but it is unauthenticated, unencrypted, and unstructured (no data types, no metadata). Modbus TCP is suitable for simple integration (reading a meter, writing a setpoint) and for legacy compatibility, but not for high-speed control or for security-sensitive applications. Use it where simplicity and ubiquity matter, and secure it with network segmentation (it has no built-in security).

**Protocol Selection.** Match the protocol to the application: EtherNet/IP for Logix-centric control and I/O; PROFINET for Siemens-centric environments and motion (IRT); EtherCAT for high-speed motion and deterministic I/O; Modbus TCP for simple integration and legacy compatibility. Multi-protocol environments are common (a plant with Logix and Siemens controllers, with Modbus TCP for some instruments); use VLANs to segment the protocols and gateways where protocol translation is needed. Do not force one protocol where another fits better; the protocol is a tool, not a religion.

## Best Practices

- Match the protocol to the application: EtherNet/IP for Logix, PROFINET for Siemens and motion (IRT), EtherCAT for high-speed motion, Modbus TCP for simple/legacy integration.
- Use the protocol''s real-time class for time-critical I/O (PROFINET IRT, EtherCAT distributed clocks, EtherNet/IP CIP Motion).
- Segment multi-protocol environments with VLANs; use gateways for protocol translation where needed.
- Secure Modbus TCP with network segmentation; it has no built-in authentication or encryption.
- Use device description files (GSD for PROFINET, EDS for EtherNet/IP, ESI for EtherCAT) for configuration and diagnostics.

## Common Pitfalls

- **Forcing one protocol** where another fits better produces a suboptimal system.
- **Modbus TCP on an unsegmented network** lets anyone read and write registers.
- **Wrong real-time class** (PROFINET NRT for motion) cannot meet the timing requirement.
- **No device description file** prevents proper configuration and diagnostics.
- **No segmentation in multi-protocol environments** lets protocols interfere and increases attack surface.

## Real-World Example

A plant had a Logix controller (EtherNet/IP), a Siemens motion controller (PROFINET IRT), and several power meters (Modbus TCP). Originally, all were on one flat network, and the Modbus TCP polling loaded the network and interfered with the control traffic. After segmenting into per-protocol VLANs (EtherNet/IP VLAN, PROFINET VLAN, Modbus TCP VLAN) with a gateway for the Modbus-to-EtherNet/IP integration, the interference stopped, and each protocol ran on its own segment with appropriate real-time handling.

## Knowledge Check

Review PROFINET (NRT, RT, IRT), EtherCAT (on-the-fly, distributed clocks), Modbus TCP (simple, insecure), and the protocol selection criteria before the quiz.',
    45,
    2,
    '[
    {"question":"Which PROFINET class is used for motion and high-speed I/O?","options":["NRT","RT","IRT","TCP"],"answer":2,"explanation":"IRT (isochronous real-time) is hardware-scheduled for motion and high-speed I/O, with sub-1 ms cycle times."},
    {"question":"What makes EtherCAT fast?","options":["It uses TCP","“On the fly” processing: slaves read/write as the frame passes, returning to the master in one cycle","It is wireless","It uses UDP only"],"answer":1,"explanation":"EtherCAT’s on-the-fly processing gives very short cycle times and tight synchronization via distributed clocks."},
    {"question":"What is a limitation of Modbus TCP?","options":["It is too fast","It is unauthenticated, unencrypted, and unstructured (no data types)","It requires special hardware","It is not widely supported"],"answer":1,"explanation":"Modbus TCP is simple and ubiquitous but has no built-in security or data typing; secure it with segmentation."},
    {"question":"How should a multi-protocol environment be handled?","options":["Force one protocol","Segment with VLANs and use gateways for protocol translation","Put all on one flat network","Use only Modbus TCP"],"answer":1,"explanation":"VLANs segment protocols to prevent interference; gateways translate where integration across protocols is needed."},
    {"question":"Which protocol is standard in Siemens-centric plants?","options":["EtherNet/IP","PROFINET","EtherCAT","Modbus TCP"],"answer":1,"explanation":"PROFINET is the Siemens-standard industrial Ethernet; EtherNet/IP is the Logix (Allen-Bradley) standard."},
    {"question":"Why secure Modbus TCP with network segmentation?","options":["It is too slow","It has no built-in authentication or encryption; segmentation limits who can reach it","To increase speed","It is not necessary"],"answer":1,"explanation":"Modbus TCP has no security; segmentation (VLANs, firewalls) is the only way to limit access to its registers."},
    {"question":"What did per-protocol VLANs achieve in the example?","options":["More interference","Stopped Modbus polling from interfering with control traffic","Slower communication","No effect"],"answer":1,"explanation":"Segmenting by protocol let each run on its own VLAN, eliminating the interference from the flat-network design."}
  ]'::jsonb
  );

  -- Add module 3: Wireless & IIoT Connectivity (sort_order 3)
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Wireless & IIoT Connectivity', 3) RETURNING id INTO m_id;

  -- Module 3, Lesson 1: Industrial Wireless: WLAN, ISA-100 & WirelessHART (sort_order 1, 45 min)
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (
    m_id,
    'Industrial Wireless: WLAN, ISA-100 & WirelessHART',
    '## Overview

Industrial wireless extends the network to mobile assets, rotating equipment, and locations where cabling is impractical. The technologies — industrial WLAN, ISA-100.11a, and WirelessHART — each address different applications, from mobile operator terminals to instrument networks where power is available but cabling is not. This lesson covers the wireless technologies, their application niches, and the reliability and security considerations for industrial wireless.

## Key Concepts

**Industrial WLAN (IEEE 802.11).** Industrial WLAN is the ruggedized version of standard Wi-Fi, used for mobile operator terminals, AGV/AMR communication, and wireless field access. Industrial access points are ruggedized (metal enclosures, industrial temperature, DIN mount) and support roaming (a mobile client moves between access points without dropping the connection). Reliability is the challenge: industrial environments have metal, motors, and other sources of interference that cause dropouts. Use industrial-grade access points, plan the coverage with a site survey, and use mesh or controller-based roaming for mobile clients. WLAN is not suitable for deterministic control; use it for monitoring, mobile access, and non-critical I/O.

**ISA-100.11a.** ISA-100.11a is an industrial wireless standard (from the ISA) for process monitoring and control. It is mesh-based (devices relay for each other, self-healing), time-slotted (deterministic, low power), and operates in the 2.4 GHz band with channel hopping for reliability. ISA-100 is designed for process instrumentation (temperature, pressure) where cabling is impractical (rotating equipment, remote tanks). It supports security (AES-128 encryption, authentication) and quality of service. ISA-100 is suitable for slow to moderate rate monitoring and some control, not high-speed control.

**WirelessHART.** WirelessHART (IEC 62591) is the wireless extension of the HART protocol, used for process instrumentation. Like ISA-100, it is mesh-based, time-slotted, and channel-hopping in the 2.4 GHz band, with AES-128 security. WirelessHART is designed to bring the diagnostic and measurement data from HART field devices (which are often wired for the 4-20 mA control signal but have a wireless path for the digital HART data) into the system without running new cables. It is ubiquitous in process plants that have HART instruments and want the digital data without rewiring.

**Reliability and Security.** Industrial wireless must be reliable (self-healing mesh, channel hopping, redundancy) and secure (encryption, authentication, network segmentation). For reliability, use mesh topologies so that a single path loss does not isolate a device, and channel hopping to avoid interference. For security, use AES encryption and authentication, segment the wireless network from the wired control network via a firewall, and treat wireless as an untrusted network that lands in a DMZ or dedicated VLAN. Do not put deterministic control on wireless; use it for monitoring, diagnostics, and non-critical I/O.

## Best Practices

- Use industrial WLAN for mobile access and non-critical I/O; plan coverage with a site survey; use mesh or controller-based roaming.
- Use ISA-100.11a or WirelessHART for process instrumentation where cabling is impractical (rotating equipment, remote tanks).
- Use mesh topologies and channel hopping for reliability; a single path loss should not isolate a device.
- Secure wireless with AES encryption and authentication; segment it from the wired control network via a firewall.
- Do not put deterministic control on wireless; use it for monitoring, diagnostics, and non-critical I/O.

## Common Pitfalls

- **Consumer-grade WLAN** in an industrial environment causes dropouts and unreliability.
- **No site survey** produces coverage gaps and interference that appear only after deployment.
- **No mesh** means a single path loss isolates devices.
- **Unencrypted or unsegmented wireless** is an attack path into the control network.
- **Deterministic control on wireless** is unreliable due to dropouts and latency variation.

## Real-World Example

A plant used industrial WLAN for mobile operator terminals on AGVs. The initial deployment used consumer-grade access points and had frequent dropouts as the AGVs moved, causing the terminals to freeze. After replacing with industrial access points with controller-based roaming and conducting a site survey to add access points in coverage gaps, the dropouts stopped and the terminals stayed connected as the AGVs moved. The industrial-grade equipment and the site survey, not the protocol, had been the issue.

## Knowledge Check

Review industrial WLAN, ISA-100.11a, WirelessHART, their application niches, and the reliability and security practices before the quiz.',
    45,
    1,
    '[
    {"question":"What is industrial WLAN used for?","options":["Deterministic control","Mobile operator terminals, AGV communication, and wireless field access","Process instrumentation only","High-speed motion"],"answer":1,"explanation":"Industrial WLAN suits mobile access and non-critical I/O; it is not suitable for deterministic control due to dropouts."},
    {"question":"What are ISA-100.11a and WirelessHART designed for?","options":["Mobile access","Process instrumentation where cabling is impractical (rotating equipment, remote tanks)","High-speed motion","Enterprise IT"],"answer":1,"explanation":"Both are mesh-based, time-slotted, channel-hopping standards for process instrumentation where wiring is impractical."},
    {"question":"What topology provides reliability in industrial wireless?","options":["Star","Mesh (self-healing, so a single path loss does not isolate a device)","Bus","Ring"],"answer":1,"explanation":"Mesh topologies self-heal around a path loss; combined with channel hopping, they provide industrial-grade reliability."},
    {"question":"How should a wireless network be secured and segmented?","options":["Open access","AES encryption and authentication, segmented from the wired control network via a firewall","No encryption","On the same VLAN as control"],"answer":1,"explanation":"Wireless is untrusted; encrypt it, authenticate it, and land it in a DMZ or dedicated VLAN separated from control."},
    {"question":"Why should deterministic control not be put on wireless?","options":["It is too fast","Dropouts and latency variation make it unreliable for deterministic control","It is not secure enough","It is too expensive"],"answer":1,"explanation":"Wireless has variable latency and dropouts; use it for monitoring and non-critical I/O, not deterministic control."},
    {"question":"What caused the AGV terminal dropouts in the example?","options":["A bad protocol","Consumer-grade access points and coverage gaps, fixed by industrial APs with roaming and a site survey","A firmware bug","Too many AGVs"],"answer":1,"explanation":"Consumer APs and missing coverage caused the dropouts; industrial APs with controller-based roaming and a site survey fixed it."},
    {"question":"What security do ISA-100.11a and WirelessHART provide?","options":["None","AES-128 encryption and authentication","Clear text only","WEP"],"answer":1,"explanation":"Both standards use AES-128 encryption and authentication, providing industrial-grade security for the wireless instrument network."}
  ]'::jsonb
  );

  -- Module 3, Lesson 2: OPC UA, MQTT & IIoT Data Connectivity (sort_order 2, 45 min)
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (
    m_id,
    'OPC UA, MQTT & IIoT Data Connectivity',
    '## Overview

OPC UA and MQTT are the two dominant protocols for IIoT data connectivity — getting data from the industrial network to the cloud, to analytics platforms, and to enterprise systems. OPC UA provides a structured, secure, vendor-neutral interface to controller data; MQTT provides a lightweight, publish/subscribe model for scalable telemetry. This lesson covers OPC UA, MQTT (and Sparkplug B), and the architectural patterns for IIoT data connectivity.

## Key Concepts

**OPC UA.** OPC UA (Unified Architecture) is the successor to OPC Classic (DA, HDA, A&E), providing a vendor-neutral, platform-independent interface to industrial data. OPC UA is structured (data types, metadata, browseable address space), secure (signing, encryption, authentication), and platform-independent (not tied to Windows/DCOM like Classic). An OPC UA server (often in the SCADA or a dedicated gateway) exposes the controller''s tags with their types and metadata; an OPC UA client (an analytics platform, a cloud connector) subscribes to them. OPC UA is the preferred protocol for SCADA-to-MES and for secure, structured integration.

**MQTT and Sparkplug B.** MQTT is a lightweight publish/subscribe protocol: a broker receives messages on topics, and subscribers receive the messages on the topics they subscribe to. MQTT is scalable (one publisher, many subscribers) and lightweight (low overhead, suitable for constrained devices). Sparkplug B is an industrial profile for MQTT that defines the payload structure (stateful, with birth and death certificates, so a subscriber knows when a device comes and goes). MQTT/Sparkplug B is the preferred protocol for IIoT telemetry where many consumers need the same data without each polling the controller.

**The IIoT Data Path.** A typical IIoT data path: the controller exposes data via OPC UA (to a gateway) or EtherNet/IP; a gateway (an industrial edge device) collects the data and publishes it via MQTT/Sparkplug to a broker; the broker (in the DMZ or cloud) republishes to subscribers (an analytics platform, a cloud storage, a dashboard). The gateway decouples the controller from the consumers: adding a consumer is a broker subscription, not a controller change. The broker buffers during network outages so that data is not lost.

**Security for IIoT Connectivity.** IIoT connectivity extends the attack surface to the cloud. Use OPC UA with signing and encryption; use MQTT with TLS and authenticated clients (username/password or certificates); restrict the broker to authenticated clients; place the broker and gateway in the DMZ or a dedicated IIoT segment; never expose a controller directly to the internet. The data path is only as secure as its weakest link; secure each hop.

## Best Practices

- Use OPC UA with signing and encryption for structured, secure SCADA-to-MES and gateway integration.
- Use MQTT/Sparkplug B for scalable IIoT telemetry where many consumers need the same data without loading the controller.
- Use a gateway to decouple the controller from consumers; adding a consumer is a broker subscription, not a controller change.
- Place the broker and gateway in the DMZ or a dedicated IIoT segment; never expose a controller directly to the internet.
- Secure each hop: OPC UA with signing/encryption, MQTT with TLS and authenticated clients.

## Common Pitfalls

- **Direct controller-to-cloud connections** load the controller and expose it to the internet.
- **Unencrypted MQTT** lets anyone on the path read the telemetry.
- **No broker buffering** loses data during network outages.
- **Adding a consumer requires a controller change** when no broker is used, loading the controller.
- **Unsegmented IIoT connectivity** lets a cloud compromise reach the control network.

## Real-World Example

A plant had 10 consumers (SCADA, two analytics platforms, a cloud dashboard, an energy monitor) each polling its controllers via EtherNet/IP, loading the controllers. After deploying an OPC UA gateway that collected once and published via MQTT/Sparkplug to a broker in the DMZ, the 10 consumers subscribed to the broker instead of polling the controllers. Controller CPU dropped 25%, and adding an 11th consumer was a broker configuration, not a controller change. The gateway and broker decoupled the consumers from the controllers.

## Knowledge Check

Review OPC UA (structured, secure), MQTT/Sparkplug B (lightweight pub/sub), the IIoT data path with a gateway and broker, and the security for each hop before the quiz.',
    45,
    2,
    '[
    {"question":"What does OPC UA provide?","options":["A lightweight pub/sub protocol","A structured, secure, vendor-neutral interface to industrial data with types and metadata","Unencrypted polling","Legacy DCOM access"],"answer":1,"explanation":"OPC UA is structured (types, metadata, browseable address space), secure (signing, encryption), and platform-independent."},
    {"question":"What is MQTT?","options":["A structured interface","A lightweight publish/subscribe protocol with a broker routing messages by topic","A type of PLC","A network switch"],"answer":1,"explanation":"MQTT is a lightweight pub/sub protocol; a broker routes messages to subscribers by topic, enabling one-to-many scalability."},
    {"question":"What does Sparkplug B add to MQTT?","options":["Encryption","An industrial payload structure with stateful birth/death certificates","Faster polling","Legacy support"],"answer":1,"explanation":"Sparkplug B defines the MQTT payload for industrial use, with stateful birth/death certificates so subscribers know when devices come and go."},
    {"question":"What is the role of a gateway in the IIoT data path?","options":["It replaces the controller","It decouples the controller from consumers; adding a consumer is a broker subscription, not a controller change","It encrypts the controller","It replaces the broker"],"answer":1,"explanation":"The gateway collects once and publishes to the broker; consumers subscribe to the broker, so adding one does not load the controller."},
    {"question":"Why place the broker and gateway in the DMZ?","options":["To speed them up","To segment IIoT connectivity from the control network and avoid exposing controllers to the internet","To reduce cost","It is not necessary"],"answer":1,"explanation":"The DMZ segments IIoT connectivity; a cloud compromise cannot reach the control network directly."},
    {"question":"What did the gateway and broker achieve in the example?","options":["More controller loading","Controller CPU dropped 25%; adding a consumer became a broker configuration","Slower data","No effect"],"answer":1,"explanation":"The gateway collected once and the broker republished, decoupling 10 consumers from the controllers and cutting CPU 25%."},
    {"question":"How should each hop in the IIoT data path be secured?","options":["Leave it open","OPC UA with signing/encryption, MQTT with TLS and authenticated clients","No encryption","Shared passwords"],"answer":1,"explanation":"Each hop must be secured; the path is only as secure as its weakest link."}
  ]'::jsonb
  );
END $$;