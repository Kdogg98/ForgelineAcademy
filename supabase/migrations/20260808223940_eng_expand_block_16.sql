DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='Digital Transformation & IIoT Fundamentals for Maintenance';
  IF NOT FOUND THEN RETURN; END IF;

  -- Update existing lesson: Edge Computing & Cloud Platforms
  UPDATE lessons SET content = '## Overview

Edge computing and cloud platforms are the two tiers of the IIoT architecture: the edge processes data near the source for low-latency action, and the cloud aggregates data for analytics and cross-site insight. Understanding the division of work between edge and cloud, and the platform choices, is essential for an IIoT deployment that delivers value rather than collecting dust. This lesson covers the edge-cloud architecture, the platform types, and the data and security considerations.

## Key Concepts

**Edge Computing.** The edge is the compute near the data source — on the controller, in a gateway, or on a local server. Edge computing processes data with low latency (sub-second), enabling real-time action (a local alert, a local control adjustment) without depending on a cloud round-trip. The edge also reduces the data volume sent to the cloud (aggregate, filter, summarize locally) and provides resilience (the edge continues if the cloud connection is lost). For industrial applications, the edge is where the real-time action happens; the cloud is where the cross-site analytics happens.

**Cloud Platforms.** The cloud provides scalable storage and compute for historical data, analytics, and cross-site comparison. Cloud platforms (AWS, Azure, Google Cloud, and industrial-specific platforms) provide data ingestion (IoT hubs, MQTT brokers), storage (time-series databases, data lakes), analytics (ML, dashboards), and integration (with enterprise systems). The cloud is where the data from many sites is combined for cross-site benchmarking, fleet analytics, and enterprise reporting. The cloud is not where real-time control happens (the latency and the reliability are wrong for that).

**The Edge-Cloud Division.** The division: real-time action and local resilience at the edge; historical analytics and cross-site insight in the cloud. The edge filters and aggregates, sending the cloud the summarized data (not every raw sample), reducing bandwidth and cloud cost. The cloud stores the history, runs the analytics, and provides the dashboards. A common mistake is sending all raw data to the cloud (high bandwidth, high cost, no edge action) or doing all analytics at the edge (no cross-site insight, limited compute). The right division uses both tiers for what each does best.

**Data and Security.** The data path must be secure end-to-end: encrypted in transit (TLS), authenticated at each hop, and access-controlled in the cloud. The data must be governed: what is collected, who can access it, how long it is retained. For industrial data, the security is not just IT security — it includes the OT security (the edge gateway is an OT device and must be hardened). The data path is only as secure as its weakest hop; secure the edge, the transit, and the cloud.

## Best Practices

- Use the edge for real-time action and local resilience; use the cloud for historical analytics and cross-site insight.
- Filter and aggregate at the edge; send the cloud summarized data, not every raw sample, to reduce bandwidth and cost.
- Secure the data path end-to-end: TLS in transit, authentication at each hop, access control in the cloud.
- Harden the edge gateway as an OT device; it is part of the OT security boundary.
- Govern the data: what is collected, who accesses it, how long it is retained.

## Common Pitfalls

- **Sending all raw data to the cloud** wastes bandwidth and cost, and provides no edge action.
- **All analytics at the edge** misses cross-site insight and is limited by edge compute.
- **Unencrypted or unauthenticated data path** is an attack surface from the edge to the cloud.
- **Edge gateway not hardened as an OT device** is a compromise path into the control network.
- **No data governance** risks collecting data no one uses and retaining it longer than justified.

## Real-World Example

A multi-site manufacturer deployed edge gateways that filtered and aggregated sensor data, sending the cloud hourly summaries (not every raw sample). The edge provided real-time alerts (a bearing vibration alert within 1 second); the cloud provided cross-site benchmarking (comparing pump reliability across 14 sites). The division reduced cloud cost 80% vs. the raw-data alternative and provided both real-time action and cross-site insight. The right edge-cloud division, not the cloud alone, had delivered the value.

## Knowledge Check

Review the edge (low-latency action, resilience), the cloud (analytics, cross-site insight), the edge-cloud division, and the data and security considerations before the quiz.',
  quiz = '[
    {"question":"What is the role of edge computing in IIoT?","options":["Cross-site analytics","Real-time action and local resilience with low latency","Long-term storage","Enterprise reporting"],"answer":1,"explanation":"The edge processes data near the source for sub-second action and continues if the cloud connection is lost."},
    {"question":"What is the role of the cloud in IIoT?","options":["Real-time control","Scalable storage, analytics, and cross-site comparison","Low-latency alerts","Local resilience"],"answer":1,"explanation":"The cloud aggregates data from many sites for historical analytics, cross-site benchmarking, and enterprise reporting."},
    {"question":"How should data be divided between edge and cloud?","options":["All raw data to the cloud","Edge filters and aggregates, sending summarized data to the cloud","All analytics at the edge","No data to the cloud"],"answer":1,"explanation":"Edge filtering reduces bandwidth and cost; the cloud receives summaries, not every raw sample, while the edge handles real-time action."},
    {"question":"What does sending all raw data to the cloud cause?","options":["Better analytics","High bandwidth and cost, with no edge action","Lower cost","More security"],"answer":1,"explanation":"Raw data to the cloud wastes bandwidth and cost and provides no real-time edge action; the right division uses both tiers."},
    {"question":"How must the IIoT data path be secured?","options":["Open for convenience","End-to-end: TLS in transit, authentication at each hop, access control in the cloud","Only at the cloud","Only at the edge"],"answer":1,"explanation":"The path is only as secure as its weakest hop; secure the edge, the transit, and the cloud."},
    {"question":"What did the edge-cloud division achieve in the example?","options":["Higher cloud cost","80% lower cloud cost plus real-time alerts and cross-site benchmarking","No edge action","Slower alerts"],"answer":1,"explanation":"Edge filtering and cloud summarization cut cloud cost 80% while providing both 1-second alerts and cross-site insight."},
    {"question":"Why harden the edge gateway as an OT device?","options":["To speed it up","It is part of the OT security boundary and a compromise path into the control network","To reduce cost","It is not necessary"],"answer":1,"explanation":"The edge gateway sits in the OT environment; if compromised, it is a path into the control network, so it must be hardened."}
  ]'::jsonb
  WHERE title = 'Edge Computing & Cloud Platforms' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Update existing lesson: Predictive Analytics & Business Case
  UPDATE lessons SET content = '## Overview

Predictive analytics and the business case are what turn IIoT data into maintenance value. The data without analytics is stored cost; the analytics without a business case is a science project. This lesson covers the predictive analytics applications for maintenance, the business case that justifies the IIoT investment, and the measurement that proves the value.

## Key Concepts

**Predictive Analytics Applications.** For maintenance, predictive analytics applications include: remaining useful life (RUL) prediction (estimating when a failure will occur from condition data), anomaly detection (alerting on deviation from normal), and failure mode classification (identifying the likely failure from the pattern). For rotating equipment, vibration spectra predict bearing and gear failures; for electrical equipment, thermography predicts connection failures; for process equipment, deviation from normal predicts degradation. The application must match a specific failure mode and a specific signal; a generic "predict failure" application without a specific target produces little value.

**The Business Case.** The business case for IIoT in maintenance is the avoided failure cost: the unplanned downtime, the repair cost, the safety and environmental consequence, and the production loss that a failure causes. Estimate the avoided failures per year (from the failure history and the analytics'' detection rate), the cost per avoided failure, and the IIoT investment (sensors, gateways, platform, analyst time). The payback is the investment divided by the annual savings; a payback under 2 years is typically justified, under 1 year is clearly justified. A business case without the avoided-failure cost is a technology case, not a business case.

**Measurement and Value Proof.** Measure the program''s value: the predictions made, the predictions that led to action, the failures avoided, and the cost of the avoided failures. The avoided-failure count and cost are the value proof — they quantify what the program prevented. A program that does not measure its avoided failures cannot prove its value and is vulnerable to budget cuts. The measurement is ongoing, not one-time; the value is proven every year with the year''s avoided failures.

**From Pilot to Scale.** Start with a pilot on the highest-value assets (where the failure cost justifies the investment), prove the value with the avoided-failure measurement, then scale to the next tier of assets. A pilot that does not measure its value cannot justify the scale-up; a scale-up without the pilot''s proof is a leap of faith. The pilot-measure-scale sequence manages the risk and the investment, deploying capital where the proof supports it.

## Best Practices

- Match each predictive analytics application to a specific failure mode and a specific signal; generic "predict failure" produces little value.
- Build the business case on avoided failure cost (downtime, repair, safety, production loss), not on technology; calculate the payback.
- Measure the program''s value: predictions, actions, avoided failures, and their cost; the avoided-failure count is the value proof.
- Start with a pilot on the highest-value assets; prove the value, then scale to the next tier.
- Prove the value every year with the year''s avoided failures; an unmeasured program is vulnerable to budget cuts.

## Common Pitfalls

- **Generic analytics without a specific failure target** produces little value.
- **Technology case instead of business case** justifies the investment with technology, not with avoided failures.
- **No measurement of avoided failures** leaves the program unable to prove its value.
- **Scale-up without a pilot''s proof** is a leap of faith that risks the investment.
- **One-time value proof** decays; the value must be proven every year with current avoided failures.

## Real-World Example

A plant piloted predictive analytics on 10 critical pumps, with a business case based on the $500K annual unplanned downtime from pump failures. The pilot produced 15 predictions that led to planned rebuilds, avoiding 12 failures and $300K in downtime in the first year — a payback under 1 year on the 10-pump investment. The measurement justified scaling to 50 pumps, and the program sustained itself with the annual avoided-failure report. The business case and the measurement, not the technology, had driven the investment and the scale-up.

## Knowledge Check

Review the predictive analytics applications, the business case on avoided failure cost, the measurement and value proof, and the pilot-to-scale sequence before the quiz.',
  quiz = '[
    {"question":"What must a predictive analytics application match?","options":["Nothing","A specific failure mode and a specific signal","A new platform","A vendor"],"answer":1,"explanation":"A generic \u201cpredict failure\u201d without a specific target produces little value; the application must target a specific failure and signal."},
    {"question":"What is the business case for IIoT in maintenance?","options":["The technology cost","The avoided failure cost (downtime, repair, safety, production loss)","The sensor count","The platform features"],"answer":1,"explanation":"The business case is the cost of the failures the program prevents; the payback is the investment divided by the annual savings."},
    {"question":"What is the value proof of an IIoT maintenance program?","options":["The sensor count","The avoided-failure count and cost \u2014 what the program prevented","The platform features","The data volume"],"answer":1,"explanation":"Avoided failures are the value proof; a program that does not measure them cannot prove its value and is vulnerable to cuts."},
    {"question":"What is the pilot-to-scale sequence?","options":["Scale first, then pilot","Pilot on highest-value assets, prove value, then scale to the next tier","Pilot only, never scale","Scale without a pilot"],"answer":1,"explanation":"The pilot proves the value; the proof justifies the scale-up, managing the risk and the investment."},
    {"question":"Why measure the value every year?","options":["To increase storage","A one-time proof decays; the value must be proven with current avoided failures to sustain support","To slow the program","It is not necessary"],"answer":1,"explanation":"An unmeasured program is vulnerable to budget cuts; annual value proof sustains management support."},
    {"question":"What did the plant''s pilot achieve in the example?","options":["No avoided failures","12 avoided failures and $300K downtime saved, payback under 1 year, justifying scale-up to 50 pumps","A new platform","More sensors"],"answer":1,"explanation":"The pilot''s measured value (12 avoided failures, $300K, <1 year payback) justified the scale-up; the business case drove the investment."},
    {"question":"Why is a technology case not a business case?","options":["It is cheaper","It justifies the investment with technology, not with avoided failures, so it does not prove business value","It is more accurate","It is required"],"answer":1,"explanation":"A technology case (features, sensors) does not prove business value; the business case (avoided failures, payback) does."}
  ]'::jsonb
  WHERE title = 'Predictive Analytics & Business Case' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);

  -- Add module 2: IIoT Implementation & Data Architecture
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'IIoT Implementation & Data Architecture', 2) RETURNING id INTO m_id;

  -- Module 2, Lesson 1: Sensor Selection & Data Acquisition Architecture
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Sensor Selection & Data Acquisition Architecture', '## Overview

Sensor selection and data acquisition are the foundation of an IIoT deployment: without the right sensors and a reliable data path, the analytics have nothing to analyze. This lesson covers the sensor selection criteria, the data acquisition architecture (wired, wireless, protocols), and the quality considerations that determine whether the data is trustworthy.

## Key Concepts

**Sensor Selection Criteria.** Select sensors by the failure mode to detect and the environment. For vibration: accelerometers (frequency range, sensitivity) for bearing and gear faults. For temperature: RTDs, thermocouples, or infrared for thermal faults. For pressure and flow: transmitters for process faults. For oil: sampling ports or online sensors for wear and contamination. The sensor must survive the environment (temperature, vibration, moisture, hazardous area) and must be reliable enough that the data is trustworthy — a sensor that fails produces misleading data, not just missing data. Consider power: wired sensors draw from the loop; wireless sensors need batteries with a viable maintenance plan.

**Data Acquisition Architecture.** The architecture connects sensors to the analytics. Wired architectures (4-20 mA, Modbus, fieldbus) are reliable and powered but require cabling. Wireless architectures (WirelessHART, ISA-100, industrial WLAN) avoid cabling but need power management and reliability planning. The data path: sensor to gateway (aggregation, protocol conversion), gateway to edge (filtering, local analytics), edge to cloud (summarized data for historical analytics). Each hop must be reliable; a hop that drops data silently produces misleading analytics, not just missing data.

**Protocol Choices.** Modbus TCP and RTU are simple and ubiquitous but unstructured and unauthenticated. OPC UA is structured and secure, preferred for SCADA and gateway integration. MQTT/Sparkplug is lightweight and scalable for telemetry. EtherNet/IP and PROFINET are for control-grade I/O. The protocol choice depends on the device, the integration target, and the security requirement; do not use Modbus on an unsegmented network, and prefer OPC UA for structured secure integration.

**Data Quality.** The data must be timely (the sampling rate must capture the phenomenon), complete (missing data is flagged, not silently interpolated), and accurate (calibrated sensors, with drift monitoring). A data quality flag accompanies each value (good, bad, uncertain); the analytics filter on it. Data without quality flags poisons the analytics — a "vibration" that is really a sensor failure looks real. Build the quality flags into the acquisition, not as an afterthought.

## Best Practices

- Select sensors by the failure mode to detect and the environment; ensure they survive and are reliable.
- Choose the data acquisition architecture (wired or wireless) by the reliability and power requirements.
- Match the protocol to the device and integration (OPC UA for structured secure, MQTT for scalable telemetry, Modbus only on segmented networks).
- Build data quality flags into the acquisition; the analytics filter on good/bad/uncertain.
- Monitor sensor drift and calibrate; a drifted sensor produces misleading data, not just inaccurate data.

## Common Pitfalls

- **Sensors that do not survive the environment** fail and produce misleading or missing data.
- **Wireless without a power maintenance plan** has dead sensors within a year.
- **Modbus on an unsegmented network** lets anyone read and write registers.
- **No data quality flags** poisons the analytics with sensor failures that look like real data.
- **No drift monitoring** lets a drifted sensor mislead the analytics silently.

## Real-World Example

A plant deployed vibration sensors on its pumps; the sensors were rated for a lower temperature than the pump environment and failed within 3 months. The "data" from the failed sensors was zero vibration, which the analytics interpreted as "no fault" — until a pump failed that the analytics had missed. After selecting sensors rated for the environment and adding quality flags (a zero vibration was flagged "bad" not "good"), the analytics were trustworthy. The sensor selection and the quality flags, not the analytics, had been the issue.

## Knowledge Check

Review the sensor selection criteria, the data acquisition architecture, the protocol choices, and the data quality flags before the quiz.',
  45,
  1,
  '[
    {"question":"What drives sensor selection?","options":["The vendor","The failure mode to detect and the environment","The cost only","The protocol"],"answer":1,"explanation":"Sensors must detect the target failure mode and survive the environment; a sensor that fails produces misleading data."},
    {"question":"What is a key trade-off in wireless sensor deployment?","options":["Speed vs. cost","Power management (battery maintenance) and reliability","Protocol vs. vendor","Wired vs. wireless cost only"],"answer":1,"explanation":"Wireless avoids cabling but needs a power maintenance plan; dead sensors leave gaps in the data."},
    {"question":"Which protocol is preferred for structured, secure integration?","options":["Modbus TCP","OPC UA","Raw EtherNet/IP","Telnet"],"answer":1,"explanation":"OPC UA is structured (types, metadata) and secure (signing, encryption), preferred for SCADA and gateway integration."},
    {"question":"Why must data quality flags accompany each value?","options":["To increase storage","So analytics can filter out bad/uncertain data and avoid poisoning with sensor failures","To slow the system","It is not necessary"],"answer":1,"explanation":"Without quality flags, a sensor failure looks like real data; the flags let analytics filter on good data only."},
    {"question":"What did the failed vibration sensors cause in the example?","options":["No data","Zero vibration was interpreted as \u201cno fault\u201d until a pump failed that the analytics had missed","A new protocol","More sensors"],"answer":1,"explanation":"The failed sensors produced zero vibration, misinterpreted as healthy; environment-rated sensors and quality flags fixed it."},
    {"question":"Why monitor sensor drift?","options":["To increase cost","A drifted sensor produces misleading data silently, not just inaccurate data","To slow the system","It is not necessary"],"answer":1,"explanation":"Drift misleads the analytics silently; drift monitoring and calibration keep the data trustworthy."},
    {"question":"What is the data path in a typical IIoT architecture?","options":["Sensor directly to cloud","Sensor to gateway to edge to cloud, with each hop reliable and quality-flagged","Sensor to HMI only","Sensor to PLC only"],"answer":1,"explanation":"Each hop (gateway, edge, cloud) must be reliable; a hop that drops data silently produces misleading analytics."}
  ]'::jsonb);

  -- Module 2, Lesson 2: Cybersecurity for IIoT & OT Data Governance
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Cybersecurity for IIoT & OT Data Governance', '## Overview

IIoT extends the OT network to the cloud, expanding the attack surface and the data governance scope. An IIoT deployment that is not secure and not governed is a risk, not an asset. This lesson covers the cybersecurity for IIoT (the edge, the transit, the cloud), the data governance (what is collected, who accesses it, how long it is retained), and the compliance considerations.

## Key Concepts

**Cybersecurity for IIoT.** The IIoT data path crosses the OT-IT boundary, so the security spans both. The edge gateway (an OT device) must be hardened (disabled ports, strong passwords, no default credentials, patched firmware) and segmented from the control network via a firewall. The transit (edge to cloud) must be encrypted (TLS) and authenticated. The cloud (storage and analytics) must have access control (per-user, per-role), and the data must be encrypted at rest. Each hop is a potential attack surface; the path is only as secure as its weakest hop. Follow IEC 62443 for the OT side and ISO 27001 or the cloud provider''s security model for the cloud side.

**Data Governance.** Data governance defines what is collected, who can access it, how long it is retained, and for what purpose. For industrial data, governance includes: which measurements are collected (only what is needed, not everything possible), who can access the raw data vs. the analytics (operators, engineers, management, vendors), how long the data is retained (regulatory requirements, analytics needs), and the purpose limitation (data collected for maintenance is not used for personnel monitoring without consent). Governance is a policy, not just a technical control; it requires management approval and periodic review.

**Compliance.** Industrial data may be subject to regulation: data residency (some jurisdictions require data to stay in-country), data protection (GDPR for personal data, even incidentally collected), and sector-specific rules (FDA 21 CFR Part 11 for pharma, NERC CIP for power). The IIoT deployment must comply with the applicable regulations; a deployment that ignores them risks fines and shutdown. Involve the compliance and legal teams in the IIoT design, not after deployment.

**Vendor and Supply Chain Security.** IIoT platforms involve vendors (cloud providers, analytics vendors, sensor vendors). Each vendor is a trust decision: what data they can access, what they do with it, how they secure it, and what happens if the relationship ends. Review vendor security (SOC 2, ISO 27001 certification), data terms (who owns the data, can it be exported, is it deleted on termination), and supply chain (the vendor''s vendors). A vendor that holds the data hostage or uses it for their own purposes is a risk.

## Best Practices

- Harden the edge gateway as an OT device (IEC 62443); segment it from the control network via a firewall.
- Encrypt and authenticate the transit (TLS); control access in the cloud (per-user, per-role); encrypt data at rest.
- Govern the data: what is collected, who accesses it, how long retained, for what purpose; approve and review the policy.
- Comply with applicable regulations (data residency, GDPR, sector-specific); involve compliance and legal in the design.
- Review vendor security and data terms; ensure data ownership, export, and deletion on termination.

## Common Pitfalls

- **Unhardened edge gateway** is a compromise path into the control network.
- **Unencrypted transit** lets anyone on the path read the data.
- **No data governance** risks collecting data no one uses and using it for purposes without consent.
- **Ignored compliance** risks fines and shutdown; involve compliance and legal early.
- **Vendor data terms not reviewed** risks data held hostage or used for the vendor''s purposes.

## Real-World Example

A manufacturer deployed an IIoT platform without involving compliance, then discovered that the cloud provider stored the data in another country, violating data residency rules, and that the vendor''s terms allowed the vendor to use the data for its own analytics. After a compliance review, the manufacturer renegotiated the data terms (data ownership, in-country storage, deletion on termination) and involved compliance in the IIoT design. The early involvement would have avoided the renegotiation and the compliance risk.

## Knowledge Check

Review the IIoT cybersecurity (edge, transit, cloud), the data governance, the compliance considerations, and the vendor and supply chain security before the quiz.',
  45,
  2,
  '[
    {"question":"How must the edge gateway be treated in IIoT?","options":["As an IT device","As an OT device, hardened per IEC 62443 and segmented from the control network","As an open device","As a consumer device"],"answer":1,"explanation":"The edge gateway is an OT device; harden it and segment it from the control network via a firewall."},
    {"question":"What must the transit (edge to cloud) provide?","options":["Open access","Encryption (TLS) and authentication","Faster speed","No security"],"answer":1,"explanation":"The transit crosses the OT-IT boundary; TLS and authentication protect the data in transit."},
    {"question":"What does data governance define?","options":["Only the storage cost","What is collected, who accesses it, how long retained, for what purpose","Only the vendor","Only the protocol"],"answer":1,"explanation":"Governance is a policy covering collection, access, retention, and purpose; it requires management approval and review."},
    {"question":"Why involve compliance and legal in the IIoT design?","options":["To increase cost","To comply with data residency, GDPR, and sector-specific rules, avoiding fines and shutdown","To slow the project","It is not necessary"],"answer":1,"explanation":"Compliance and legal identify the applicable regulations early; involving them after deployment risks renegotiation and compliance failures."},
    {"question":"What is a risk of unreviewed vendor data terms?","options":["Lower cost","The vendor may hold the data hostage or use it for its own purposes","Faster deployment","Better security"],"answer":1,"explanation":"Vendor terms may allow the vendor to use the data or prevent export; review ensures data ownership, export, and deletion on termination."},
    {"question":"What did the manufacturer discover in the example?","options":["A good vendor","Data stored in another country (residency violation) and vendor terms allowing the vendor''s own use of the data","A new protocol","A cheap platform"],"answer":1,"explanation":"Without early compliance involvement, the deployment violated residency and the vendor terms allowed unintended use; renegotiation was required."},
    {"question":"What security standard applies to the OT side of IIoT?","options":["ISO 27001","IEC 62443","GDPR","SOC 2"],"answer":1,"explanation":"IEC 62443 covers the OT side (the edge gateway, the control network); ISO 27001 or the cloud provider''s model covers the cloud side."}
  ]'::jsonb);

  -- Add module 3: Digital Transformation Strategy & Change Management
  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Digital Transformation Strategy & Change Management', 3) RETURNING id INTO m_id;

  -- Module 3, Lesson 1: Digital Transformation Strategy & Roadmap
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Digital Transformation Strategy & Roadmap', '## Overview

Digital transformation is not a technology project; it is an organizational change that uses technology to improve how the organization works. A transformation without a strategy is a series of pilots that never scale; a transformation with a strategy is a deliberate journey from the current state to the target. This lesson covers the digital transformation strategy, the roadmap, and the prioritization that focuses investment where it pays back.

## Key Concepts

**The Strategy.** The strategy defines the target state (what the organization will be able to do that it cannot do now), the gaps (what is missing — data, skills, processes, technology), the initiatives (the projects that close the gaps), and the sequence (the order, based on value and dependency). The strategy is driven by business outcomes (avoided downtime, improved safety, reduced cost), not by technology. A strategy that starts with the technology ("we will deploy IoT") rather than the outcome ("we will reduce unplanned downtime by 30%") produces technology without value.

**The Roadmap.** The roadmap sequences the initiatives over time: quick wins first (high value, low effort, building momentum and funding), then the foundational initiatives (data, platform, skills), then the transformative initiatives (the high-value, high-effort projects that the foundation enables). The roadmap balances quick wins (to prove value and sustain support) with foundations (to enable the transformative initiatives). A roadmap that is all quick wins never builds the foundation; a roadmap that is all foundations never proves the value.

**Prioritization.** Prioritize initiatives by value (the business outcome) and effort (the cost and time), using a value-effort matrix. High-value, low-effort initiatives are quick wins; high-value, high-effort are transformative; low-value initiatives are candidates for deferral. Prioritization is a portfolio decision: not every initiative is funded, and the funded ones are those with the best value-effort ratio. Re-prioritize periodically as initiatives complete and the context changes.

**Dependency and Sequencing.** Initiatives have dependencies: the analytics depend on the data, the data depends on the sensors, the sensors depend on the network. Sequence the initiatives to respect the dependencies — the data foundation before the analytics, the network before the sensors. A roadmap that sequences an initiative before its dependency is a roadmap that stalls.

## Best Practices

- Define the strategy by business outcomes (avoided downtime, safety, cost), not by technology.
- Build a roadmap with quick wins first (value, momentum), then foundations, then transformative initiatives.
- Prioritize initiatives by a value-effort matrix; fund the best ratio, defer the low-value.
- Sequence initiatives to respect dependencies (data before analytics, network before sensors).
- Re-prioritize periodically as initiatives complete and the context changes.

## Common Pitfalls

- **Technology-first strategy** produces technology without value.
- **All quick wins** never builds the foundation for the transformative initiatives.
- **All foundations** never proves the value to sustain support.
- **No prioritization** funds everything, which funds nothing well.
- **Ignoring dependencies** stalls initiatives that are sequenced before their prerequisites.

## Real-World Example

A manufacturer defined its digital transformation by the outcome "reduce unplanned downtime by 30% in 2 years." The roadmap: quick win (predictive analytics on 10 critical pumps, proving $300K value in 6 months), foundation (data platform and sensor expansion to 50 pumps), transformative (fleet-wide predictive maintenance and cross-site benchmarking). The quick win proved the value and funded the foundation; the foundation enabled the transformative initiative. The outcome-driven strategy and the sequenced roadmap achieved the 30% reduction in 2 years.

## Knowledge Check

Review the strategy (outcome-driven), the roadmap (quick wins, foundations, transformative), the value-effort prioritization, and the dependency sequencing before the quiz.',
  45,
  1,
  '[
    {"question":"What should drive a digital transformation strategy?","options":["The technology","Business outcomes (avoided downtime, safety, cost)","The vendor","The platform"],"answer":1,"explanation":"A technology-first strategy produces technology without value; the strategy is driven by the business outcomes."},
    {"question":"What does the roadmap sequence?","options":["Foundations only","Quick wins first, then foundations, then transformative initiatives","Transformative first","Quick wins only"],"answer":1,"explanation":"Quick wins prove value and sustain support; foundations enable the transformative; both are needed in sequence."},
    {"question":"How are initiatives prioritized?","options":["By cost","By a value-effort matrix (fund the best ratio, defer low-value)","By vendor preference","By alphabet"],"answer":1,"explanation":"The value-effort matrix identifies quick wins (high value, low effort) and transformative (high value, high effort); low-value is deferred."},
    {"question":"Why respect dependencies in sequencing?","options":["To slow the project","Analytics depend on data, data on sensors, sensors on network \u2014 sequencing before a dependency stalls","To reduce cost","It is not necessary"],"answer":1,"explanation":"An initiative sequenced before its prerequisite (analytics before data) stalls; the roadmap respects the dependency order."},
    {"question":"What does an all-quick-wins roadmap miss?","options":["Value","The foundation for the transformative initiatives","Cost","Speed"],"answer":1,"explanation":"Quick wins prove value but do not build the foundation; without it, the transformative initiatives cannot be enabled."},
    {"question":"What did the manufacturer''s roadmap achieve in the example?","options":["A technology pilot","30% unplanned downtime reduction in 2 years via a sequenced quick-win-foundation-transformative roadmap","A new platform","More sensors"],"answer":1,"explanation":"The outcome-driven strategy and the sequenced roadmap (quick win proving value, foundation enabling scale, transformative delivering the outcome) achieved the 30% target."},
    {"question":"Why re-prioritize periodically?","options":["To increase the count","As initiatives complete and the context changes, the priorities shift","To slow the program","It is not necessary"],"answer":1,"explanation":"The portfolio changes as initiatives complete and the context evolves; periodic re-prioritization keeps the roadmap relevant."}
  ]'::jsonb);

  -- Module 3, Lesson 2: Change Management & Workforce Upskilling
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES (m_id, 'Change Management & Workforce Upskilling', '## Overview

Digital transformation changes how people work, and without change management and workforce upskilling, the technology sits unused. The people are the difference between a transformation that delivers value and one that produces shelfware. This lesson covers the change management practices, the workforce upskilling, and the sustainment that makes the new ways of working stick.

## Key Concepts

**Change Management.** Change management addresses the people side of transformation: why the change is happening (the business case, communicated clearly), what is changing (the new processes, the new tools), and what is in it for the people (how their work improves, what they gain). People resist change that is imposed without explanation; people adopt change that they understand and that benefits them. Communicate the why early and often, involve the users in the design (they know the work), and address the fears (job security, new skills) honestly. Change management is not a memo; it is a sustained engagement.

**Workforce Upskilling.** The new technology requires new skills: data analysis (interpreting the analytics, acting on the predictions), sensor and platform maintenance (the new infrastructure), and digital literacy (using the new tools confidently). Upskilling is training plus practice: classroom training introduces the concepts, but on-the-job coaching (an expert working alongside the team) builds the skill. Verify competency, not just attendance; a certificate without competency is a certificate, not a skill. Budget the upskilling as part of the transformation, not as an afterthought.

**Sustainment.** The new ways of working sustain when they are integrated into the daily work and the performance management: the analytics are part of the maintenance routine (not a separate "digital" activity), the KPIs include the digital adoption (predictions acted on, avoided failures), and the leadership models the new behavior (using the analytics, not just mandating them). A transformation that is a separate "digital initiative" decays when the initiative ends; a transformation that is integrated into the daily work sustains.

**The Pilot Team and Scale.** A pilot team (early adopters who embrace the new tools) proves the value and becomes the internal champions. Scale from the pilot team to the broader organization using the pilot team''s success as the proof and the pilot team members as the coaches. The pilot team is the bridge between the technology and the organization; without it, the scale-up lacks internal credibility.

## Best Practices

- Communicate the why (business case) early and often; involve users in the design; address fears honestly.
- Upskill with training plus on-the-job coaching; verify competency, not just attendance; budget upskilling as part of the transformation.
- Integrate the new ways into the daily work and the KPIs; model the new behavior at the leadership level.
- Use a pilot team as early adopters and internal champions; scale using their success as proof and their members as coaches.
- Sustain by making the digital activity part of the routine, not a separate initiative.

## Common Pitfalls

- **Imposed change without explanation** drives resistance, not adoption.
- **Training without coaching** produces certificates, not skills.
- **Certificate without competency verification** is a certificate, not a skill.
- **A separate \u201cdigital initiative\u201d** decays when the initiative ends; integrate into the daily work.
- **No pilot team** leaves the scale-up without internal credibility or coaches.

## Real-World Example

A plant deployed predictive analytics with classroom training but no coaching and no pilot team. The analytics were unused within 3 months — the maintenance team did not trust the predictions and had no one to ask. After deploying a pilot team (3 early adopters who worked with the analytics and coached their peers) and adding on-the-job coaching, adoption reached 80% within 6 months, and the pilot team''s avoided-failure count proved the value to the broader team. The pilot team and the coaching, not the classroom training, had driven the adoption.

## Knowledge Check

Review the change management practices (why, what, in-it-for-them), the workforce upskilling (training plus coaching, competency verification), the sustainment (integration into daily work and KPIs), and the pilot team before the quiz.',
  45,
  2,
  '[
    {"question":"What does change management address?","options":["The technology","The people side of transformation (why, what, in-it-for-them)","The vendor","The platform"],"answer":1,"explanation":"Change management engages the people; without it, the technology sits unused regardless of its quality."},
    {"question":"What does workforce upskilling require beyond classroom training?","options":["Nothing","On-the-job coaching (an expert working alongside the team) to build the skill","A new platform","More sensors"],"answer":1,"explanation":"Training introduces concepts; coaching builds skills on the job; both are needed, and competency must be verified."},
    {"question":"How are the new ways of working sustained?","options":["As a separate initiative","By integrating into the daily work, the KPIs, and leadership modeling","By mandate only","By hiring new people"],"answer":1,"explanation":"A separate initiative decays when it ends; integration into the daily routine and the KPIs sustains the new ways."},
    {"question":"What is the role of a pilot team?","options":["To replace the maintenance team","To prove the value as early adopters and become internal champions and coaches for scale-up","To reduce cost","To buy the technology"],"answer":1,"explanation":"The pilot team proves the value internally and coaches peers; without it, the scale-up lacks internal credibility."},
    {"question":"Why verify competency, not just attendance?","options":["To save time","A certificate without competency is a certificate, not a skill","To reduce cost","It is not necessary"],"answer":1,"explanation":"Attendance proves presence, not the ability to do the work; competency verification ensures the skill was built."},
    {"question":"What caused the analytics to go unused in the example?","options":["Bad analytics","Classroom training with no coaching and no pilot team \u2014 the team did not trust the predictions and had no one to ask","A bad platform","Too many sensors"],"answer":1,"explanation":"Without coaching and a pilot team, the training did not build trust or skill; the pilot team and coaching drove 80% adoption in 6 months."},
    {"question":"Why communicate the why early and often?","options":["To increase communication","People resist imposed change; understanding the why and the benefit drives adoption","To slow the project","It is not necessary"],"answer":1,"explanation":"People adopt change they understand and that benefits them; imposed change without explanation drives resistance."}
  ]'::jsonb);
END $$;