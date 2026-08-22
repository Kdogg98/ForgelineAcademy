DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Industrial Panel Building & Layout';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

UL 508A is the standard for industrial control panels in North America, and compliance with it is required for a panel to be listed and accepted by an Authority Having Jurisdiction (AHJ). The standard covers the construction, the component selection, the wiring, the overcurrent protection, and the marking of the panel. For an industrial electrician or a panel builder, UL 508A is not a suggestion — it is the rulebook. A panel that is built without regard for UL 508A may work electrically but will not be listed, will not pass inspection, and in the event of an incident, will not have the manufacturer''s liability protection. This lesson covers the layout requirements of UL 508A: the enclosure selection, the component placement, the separation of power and control, the wiring methods, and the marking and documentation that make a panel compliant.

## Key Concepts

**Enclosure requirements.** UL 508A requires the enclosure to be suitable for the environment (NEMA 1 for indoor, NEMA 4/4X for washdown, NEMA 7 for hazardous locations). The enclosure must have a minimum spacing between live parts and the enclosure walls, and between live parts of different circuits. The enclosure must be rated for the short-circuit current that can be delivered to the panel.

**Component spacing.** UL 508A specifies minimum clearances between components and between components and the enclosure. The clearance depends on the voltage and the component type. For 480V components, the minimum clearance is typically 1 inch through air and 2 inches over a surface. Components must be mounted on a subpanel, not on the enclosure door (unless the door is rated for the component weight and the mounting method).

**Power vs control separation.** Power circuit conductors (480V, 240V motor leads) and control circuit conductors (120V, 24V) must be separated in the panel. The separation can be by physical distance (a minimum spacing) or by a barrier. The separation prevents noise from the power circuits from corrupting the control signals and prevents a power fault from damaging the control wiring.

**SCCR (Short-Circuit Current Rating).** UL 508A requires the panel to have a marked SCCR, which is the maximum fault current the panel can withstand. The SCCR is determined by the lowest-rated component in the panel (the "weakest link") unless the panel is engineered with current-limiting fuses or breakers that raise the rating. A panel with an unmarked SCCR is assumed to be 5 kA, which is rarely adequate for an industrial installation.

**Wiring methods.** UL 508A requires the internal wiring to be stranded or solid copper, with a minimum size of 14 AWG for power circuits (with exceptions for smaller control wiring). The wiring must be supported and routed in a neat and workmanlike manner. Wire bundling is allowed with restrictions on the number of conductors and the ampacity derating.

**Marking and nameplate.** UL 508A requires a nameplate with the manufacturer''s name, the panel model number, the electrical ratings (voltage, phases, full-load current, SCCR), and the UL listing mark. The nameplate must be visible after installation and must be durable.

## Step-by-Step

1. **Select the enclosure.** Based on the environment (indoor, outdoor, washdown, hazardous) and the size of the components, select a NEMA-rated enclosure with adequate internal space for the components and the wiring. Allow 20% spare space for future expansion.
2. **Lay out the components on the subpanel.** Place the power components (disconnect, contactors, overloads) at the top or on one side, and the control components (terminal blocks, relays, PLC) at the bottom or on the other side. Maintain the UL 508A clearances between components and between components and the enclosure.
3. **Calculate the SCCR.** Identify the SCCR of each component (from the component markings or the UL 508A tables). The panel SCCR is the lowest component SCCR unless current-limiting fuses are used to raise the rating. If the required SCCR (based on the available fault current at the installation) exceeds the panel SCCR, add current-limiting fuses or re-select components.
4. **Route the power wiring.** Run the power conductors (line side of the disconnect to the contactors, contactors to the overloads, overloads to the terminal blocks for the motor leads) with the shortest, neatest runs. Keep the power wiring separated from the control wiring by a minimum distance or a barrier.
5. **Route the control wiring.** Run the control conductors (control transformer to the terminal blocks, terminal blocks to the relays and the PLC) in a separate bundle from the power wiring. Use wire duct (slotted PVC raceway) for a neat, supported installation.
6. **Label every wire and every component.** Each wire must have a marker at each end with the wire number from the schematic. Each component must have a label with the component designation (e.g., "M1" for motor 1 contactor). The labels must be durable and legible after installation.
7. **Install the nameplate.** Attach the nameplate with the manufacturer''s name, the model number, the electrical ratings, the SCCR, and the UL listing mark. The nameplate must be visible and durable.
8. **Perform the UL 508A inspection.** Before the panel is shipped, perform an inspection against the UL 508A checklist: enclosure rating, component spacing, SCCR, wiring methods, labeling, and nameplate. Correct any deficiencies before the panel is listed.

## Common Problems and Fixes

**SCCR too low for the installation.** The available fault current at the installation exceeds the panel SCCR. Add current-limiting fuses on the line side of the panel, or re-select the contactors and the breakers for a higher SCCR. The SCCR must be equal to or greater than the available fault current.

**Power and control wiring not separated.** The power wiring induces noise in the control wiring, causing PLC input flickering or relay chattering. Re-route the control wiring into a separate bundle with a physical separation, or add a grounded barrier between the power and control wiring.

**Components too close to the enclosure.** A contactor or a breaker is mounted within the UL 508A minimum clearance of the enclosure wall. Move the component to meet the clearance, or use an insulating barrier to meet the requirement.

**Wire markers missing or illegible.** Wires without markers are difficult to troubleshoot and are a UL 508A violation. Label every wire at both ends with the wire number from the schematic, using a durable marker system.

**Nameplate missing or incomplete.** A panel without a complete nameplate cannot be listed. Install a nameplate with all the required information: manufacturer, model, voltage, phases, FLA, SCCR, and the UL mark.

## Best Practices and Field Tips

- Always calculate the SCCR before building the panel. A panel that is built with a 5 kA SCCR and installed on a system with 25 kA available fault current is a hazard and cannot be listed.
- Use wire duct for all internal wiring. Wire duct supports the conductors, makes the panel neat, and allows easy modification. Bundle the conductors in the duct with a maximum fill of 40% for future expansion.
- Keep 20% spare space on the subpanel and 20% spare terminals on the terminal blocks. The panel will be modified, and the spare space makes the modification clean.
- Use a consistent wire color scheme: black for AC power, red for AC control, blue for DC control, white for neutral, green for ground. A consistent scheme makes the panel easier to troubleshoot.
- Label the inside of the panel door with the schematic number and the date of the last revision. The next person to work on the panel needs to know which drawing is current.

## Safety Notes

- The SCCR of the panel is the maximum fault current the panel can withstand. A panel installed on a system with a higher available fault current can fail catastrophically during a fault. Always verify the available fault current is less than or equal to the panel SCCR.
- The enclosure must be grounded. The enclosure ground is the path that clears a fault to the enclosure. Verify the grounding of the enclosure before energizing the panel.
- Do not exceed the enclosure''s temperature rating. The components inside the panel dissipate heat, and a panel that is too hot will fail prematurely. Calculate the internal temperature rise and add ventilation or air conditioning if needed.
- When working inside a panel, be aware of the live parts. The line side of the disconnect is often energized even when the disconnect is open. Verify the absence of voltage before touching any component.
- A panel that is modified after listing may void the UL listing. Any modification (adding a component, changing a wire size, changing a breaker) must be evaluated and documented to maintain the listing.' WHERE title = 'UL 508A Layout Requirements' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Industrial Panel Building & Layout';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

The wiring inside an industrial control panel is the physical implementation of the schematic, and the quality of the wiring determines the reliability and the maintainability of the panel. Wire sizing, bundling, and labeling are not just cosmetic — they are functional. A wire that is too small overheats and fails; a bundle that is too tight overheats and makes modification impossible; a label that is missing or wrong turns a 10-minute troubleshooting task into a 2-hour hunt. UL 508A, NEC Chapter 3, and the industry standards (IEC 61439 for IEC panels) specify the requirements for internal panel wiring. This lesson covers the practical application of those standards: the selection of wire size, the bundling rules and the ampacity derating, the labeling systems, and the field practices that produce a panel that is both compliant and maintainable.

## Key Concepts

**Wire sizing for power circuits.** The power circuit conductors (from the disconnect to the contactor to the overload to the motor terminals) are sized per NEC Table 310.16 based on the motor full-load current and the 75°C column (the standard for industrial terminals). The minimum size for a power circuit is typically 14 AWG, but most industrial motor circuits use 12 AWG or larger. The conductor must be sized to carry 125% of the motor FLA for continuous duty (NEC 430.22).

**Wire sizing for control circuits.** The control circuit conductors are sized for the load current and the voltage drop. For a 120V control circuit, 14 AWG is typical; for a 24V DC control circuit, 14 AWG is the minimum for runs over 50 feet (to limit voltage drop). The control wire must be rated for the panel voltage and the temperature (typically 600V, 90°C insulation like THHN or XHHW).

**Bundling and ampacity derating.** NEC 310.15(C)(1) requires ampacity derating when more than three current-carrying conductors are bundled together. For 4–6 conductors, derate to 80%; for 7–9, 70%; for 10–20, 50%. The derating applies to the ampacity from Table 310.16, after any temperature correction. A bundle of 10 12 AWG conductors at 90°C has an ampacity of 10A (20A × 50%), which may be too small for the load.

**Wire duct fill.** Wire duct (slotted PVC raceway) has a maximum fill of 40% for the cross-sectional area of the conductors. Overfilling the duct makes wire pulling difficult, prevents heat dissipation, and makes modification impossible. The fill is calculated from the conductor diameter and the duct internal area.

**Labeling systems.** Each wire must be labeled at both ends with a unique identifier from the schematic. The labeling system can be numeric (1, 2, 3...) or alphanumeric (L1, L2, L3 for power; 101, 102 for control; 201, 202 for analog). A consistent system makes the panel easy to troubleshoot. The labels must be durable (heat-shrink or adhesive markers rated for the panel temperature) and legible after installation.

**Color coding.** A consistent color scheme aids troubleshooting and is required by some standards. The common industrial scheme: black for ungrounded AC power, red for ungrounded AC control, blue for ungrounded DC control, white for grounded (neutral) AC, white with yellow stripe for isolated neutral, green or green with yellow stripe for the equipment grounding conductor. NEC 200.6 requires grounded conductors to be white or gray; NEC 200.7 prohibits using white for ungrounded conductors.

## Step-by-Step

1. **Determine the wire sizes.** From the schematic and the motor FLA, determine the size of each power circuit conductor. From the control circuit loads and the run lengths, determine the size of each control conductor. Verify the sizes meet NEC 430.22 (125% of FLA for motors) and the voltage drop limits.
2. **Select the wire type.** For industrial panels, THHN/THWN (600V, 90°C) is the standard for power and control. For high-temperature or harsh environments, use XHHW (cross-linked polyethylene, 90°C, more resistant to moisture and chemicals). For 24V DC, use a twisted pair or a shielded cable for analog signals.
3. **Plan the routing.** Route the power conductors in one set of wire ducts (or on one side of the panel) and the control conductors in a separate set (or on the other side). Maintain a minimum separation of 2 inches between power and control wiring where they run parallel, or use a grounded barrier.
4. **Calculate the bundle derating.** For each bundle of current-carrying conductors, count the conductors and apply the NEC 310.15(C)(1) derating. Verify the derated ampacity is adequate for the load. If not, upsize the conductors or split the bundle.
5. **Calculate the wire duct fill.** For each duct, sum the cross-sectional area of the conductors and verify it is less than 40% of the duct internal area. If the fill exceeds 40%, use a larger duct or split the conductors into two ducts.
6. **Pull and terminate the conductors.** Pull the conductors into the ducts, leaving a service loop at each termination. Strip the insulation with the correct tool (not a knife, which can nick the conductor). Terminate with the correct lug or terminal, torqued to the manufacturer''s specification. Use a terminal block for each external connection.
7. **Label every wire and every terminal.** Apply a wire marker at both ends of each conductor, using the wire number from the schematic. Label each terminal block with the terminal number and the external connection. Verify the labels match the schematic.
8. **Perform a continuity check.** Before energizing, perform a continuity check from each terminal to the corresponding terminal at the other end. Verify every wire is connected to the correct terminal and that there are no shorts or opens.

## Common Problems and Fixes

**Bundle overheating.** A bundle of current-carrying conductors that exceeds the derating limit overheats, which can melt the insulation and cause a fault. Count the current-carrying conductors in each bundle, apply the derating, and upsize or split the bundle if the derated ampacity is inadequate.

**Wire duct overfilled.** A duct that is more than 40% full makes wire pulling difficult and prevents heat dissipation. Use a larger duct or split the conductors into two ducts. A duct that is packed tight is also impossible to modify without removing all the conductors.

**Labels that fall off or are illegible.** A label that is not rated for the panel temperature or that is applied to a dirty wire will fall off or become illegible. Use heat-shrink markers or adhesive markers rated for 90°C, and apply them to clean, dry conductors.

**Wrong wire color.** A white wire used for an ungrounded conductor violates NEC 200.7 and can confuse the next electrician. Use the correct color for each function: white for neutral, black or red for ungrounded AC, blue for ungrounded DC, green for ground.

**Termination not torqued.** A termination that is not torqued to the manufacturer''s specification is a high-resistance connection that will overheat and fail. Use a torque screwdriver or wrench on every termination, and verify the torque is correct for the terminal and the wire size.

## Best Practices and Field Tips

- Use a wire numbering system that matches the schematic. A wire that is labeled "101" in the panel and "101" on the drawing is easy to trace; a wire that is labeled differently or not at all is a guessing game.
- Keep a service loop at each termination. A wire that is cut to the exact length cannot be re-terminated if the terminal fails; a wire with a service loop can be re-terminated once or twice.
- Use ferrule terminals on stranded wire that is terminated in a spring-clamp terminal block. A stranded wire that is inserted directly into a spring clamp can have a strand that is not captured, which causes a high-resistance connection.
- Label the wire duct with the conductor numbers it contains. A duct labeled "101-120" makes it easy to find a specific wire during troubleshooting.
- Keep a set of spare wire markers in the panel. A wire that is added during commissioning needs a label, and having the markers in the panel saves a trip to the truck.

## Safety Notes

- A wire that is undersized for the load will overheat and can start a fire. Always size the conductor for the load and the derating, not just for the terminal rating.
- A bundle that is overheating can melt the insulation of adjacent conductors, causing a fault that can arc and start a fire. Do not exceed the NEC bundling derating, and verify the bundle temperature during commissioning.
- A wire that is not torqued at the termination can arc and overheat. Use a torque screwdriver on every termination, and re-torque after the first thermal cycle (the first heat-up can loosen the connection).
- A wire with a nicked conductor (from a knife stripping) can break under thermal cycling, causing an open or a high-resistance connection. Use a wire stripper, not a knife, and inspect the conductor for nicks before terminating.
- The equipment grounding conductor must be green or green with yellow stripe. A ground wire that is the wrong color can be mistaken for a current-carrying conductor and disconnected, which removes the fault protection. Verify the color of every grounding conductor.' WHERE title = 'Wire Sizing, Bundling & Labeling Standards' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='UPS Systems, Batteries & Backup Power';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

An Uninterruptible Power Supply (UPS) is the device that keeps critical loads running when the utility fails. In an industrial plant, the critical loads are the PLCs, the HMIs, the instrumentation, the safety systems, and the communications that cannot tolerate even a momentary interruption. The three UPS topologies — online (double-conversion), line-interactive, and standby (offline) — offer different levels of protection at different costs, and the selection depends on the criticality of the load, the quality of the utility power, and the budget. Understanding the topologies, their transfer times, their efficiency, and their failure modes is essential for specifying and maintaining a UPS that will actually protect the load when the power fails.

## Key Concepts

**Online (double-conversion) UPS.** The online UPS continuously converts the AC input to DC (through a rectifier) and then back to AC (through an inverter) to power the load. The battery is connected to the DC bus, so if the input fails, the battery supplies the inverter with no transfer time. The output is a clean, regenerated sine wave, completely isolated from the input. The online UPS is the highest protection and the highest cost, and it is the standard for industrial critical loads.

**Line-interactive UPS.** The line-interactive UPS passes the utility power directly to the load (through a transformer or an autotransformer) and uses an inverter that is connected to the battery to add or subtract voltage to regulate the output. When the utility fails, the inverter switches to battery power with a transfer time of 2–4 milliseconds. The line-interactive UPS is more efficient than the online (no continuous double conversion) and less expensive, but it does not isolate the load from input disturbances as completely.

**Standby (offline) UPS.** The standby UPS passes the utility power directly to the load and switches to the inverter (powered by the battery) only when the utility fails. The transfer time is 4–8 milliseconds. The standby UPS is the least expensive and the least protective; it is suitable for non-critical loads that can tolerate a brief interruption.

**Transfer time.** The time between the utility failure and the UPS switching to battery power. For an online UPS, the transfer time is zero (the battery is always connected to the DC bus). For a line-interactive, 2–4 ms. For a standby, 4–8 ms. Most modern PLCs and power supplies can tolerate a 10–20 ms interruption (they have internal capacitors that hold up the output), so a line-interactive UPS is adequate for many industrial loads.

**Efficiency.** The online UPS is the least efficient (typically 92–96%) because the rectifier and the inverter are always running. The line-interactive is more efficient (96–98%) because the utility power passes directly to the load most of the time. The standby is the most efficient (98–99%) because the inverter is off most of the time. The efficiency difference matters for a large UPS that runs continuously.

**Battery runtime.** The UPS battery is sized to provide power for a specific time (typically 5–30 minutes) to allow an orderly shutdown or to ride through a brief outage. The runtime depends on the battery capacity (in amp-hours) and the load (in watts). A larger battery or a smaller load gives a longer runtime.

## Step-by-Step

1. **Identify the critical loads.** List every load that must continue running during a power failure: PLCs, HMIs, instrumentation, safety relays, communication switches, and any process-critical equipment. Sum the power (in watts) of these loads.
2. **Select the UPS topology.** For loads that cannot tolerate any interruption (safety systems, some instrumentation), use an online UPS. For loads that can tolerate a 2–4 ms interruption (most PLCs, HMIs), a line-interactive UPS is adequate. For non-critical loads that can tolerate a brief interruption, a standby UPS is sufficient.
3. **Size the UPS.** The UPS VA rating must exceed the load VA by a margin (typically 20–30% for future expansion and for the inrush of the loads). The UPS watt rating must exceed the load watts (some loads have a low power factor, so the VA rating may need to be much larger than the watt rating).
4. **Size the battery.** Determine the required runtime (5 minutes for an orderly shutdown, 30 minutes for riding through a typical outage, or longer for a generator to start and transfer). Use the manufacturer''s runtime curves to select the battery that provides the required runtime at the load watts.
5. **Select the battery type.** VRLA (valve-regulated lead-acid) is the standard for most industrial UPS systems (maintenance-free, sealed). Lithium-ion is becoming common (longer life, lighter, more cycles, but more expensive). For large UPS systems, flooded (wet) lead-acid may be used (longest life, but requires maintenance and ventilation).
6. **Install the UPS.** Install the UPS in a location with adequate ventilation (the battery and the inverter produce heat), away from extreme temperatures (battery life is halved for every 10°C above 25°C), and accessible for maintenance. Connect the UPS to a dedicated circuit with the correct overcurrent protection.
7. **Test the UPS.** After installation, perform a load test: disconnect the utility input and verify the UPS transfers to battery, the load continues to run, and the battery provides the expected runtime. Repeat the test annually.

## Common Problems and Fixes

**UPS transfers to battery frequently.** The utility voltage is outside the UPS transfer window (the voltage at which the UPS switches to battery). For a line-interactive UPS, widen the transfer window (if adjustable) or add a voltage regulator. For an online UPS, the input voltage window is wide, so frequent transfers indicate a severe utility problem.

**Battery runtime is shorter than expected.** The battery has aged (VRLA batteries lose capacity over 3–5 years) or the load is larger than the design. Test the battery capacity with a load test and replace if the capacity is below 80% of rated. Verify the actual load with a power meter.

**UPS shuts down on overload.** The load exceeds the UPS rating, or a load has a high inrush (a motor or a transformer) that exceeds the UPS peak rating. Move the high-inrush load to a non-UPS circuit, or upsize the UPS to handle the inrush.

**Online UPS runs hot.** The online UPS is less efficient and produces more heat. Verify the ventilation is adequate and the ambient temperature is within the UPS specification. If the UPS is in a hot enclosure, add ventilation or air conditioning.

**Battery fails prematurely.** The battery is in a hot environment (battery life is halved for every 10°C above 25°C), or the battery is being cycled frequently (deep discharges reduce the cycle life). Move the UPS to a cooler location, and verify the battery is not being discharged deeply on every minor disturbance.

## Best Practices and Field Tips

- Always size the UPS with 20–30% spare capacity. The load will grow, and a UPS that is at 100% capacity has no margin for inrush or for future expansion.
- Replace VRLA batteries every 3–5 years, or when the capacity test shows less than 80% of rated capacity. A battery that is not replaced will fail when it is needed.
- Keep a spare battery charged and ready. A battery that fails takes the critical load down, and the spare battery gets the load back up while the failed battery is replaced.
- Install the UPS in a cool, ventilated location. A UPS in a hot control room will have a short battery life and a higher failure rate.
- Test the UPS transfer annually with a load test. A UPS that is not tested may fail when it is needed, and the test confirms the battery, the inverter, and the transfer logic are all functional.

## Safety Notes

- A UPS battery can deliver very high current into a short circuit. Use the correct overcurrent protection on the battery circuit, and do not work on the battery terminals without de-energizing the UPS and isolating the battery.
- A VRLA battery can release hydrogen gas during charging. Do not install a large VRLA battery bank in a sealed enclosure without ventilation, and do not allow open flames or sparks near the battery.
- The output of a UPS is a live AC source even when the utility is disconnected. Treat the UPS output with the same respect as a utility circuit — it can shock and it can arc.
- When replacing a battery, verify the polarity. A reversed battery connection can destroy the UPS and cause a fire.
- A UPS that is in bypass mode (the load is on the utility, not the inverter) does not protect the load. Verify the UPS is in normal mode (inverter powering the load) after any maintenance.' WHERE title = 'Online, Line-Interactive & Standby UPS' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='UPS Systems, Batteries & Backup Power';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

The battery is the component that determines whether a UPS will actually protect the load when the power fails. A UPS with a failed battery is just a heavy box that will drop the load the moment the utility blinks. Battery testing is therefore the most critical maintenance task for a UPS system, and it is the task that is most often deferred until the battery fails. The two battery types that dominate industrial UPS systems are VRLA (valve-regulated lead-acid, also called "sealed" or "maintenance-free") and flooded (wet) lead-acid. Each has a specific testing protocol, a specific failure mode, and a specific maintenance requirement. This lesson covers the testing methods for both types, the interpretation of the results, and the maintenance practices that maximize battery life.

## Key Concepts

**VRLA batteries.** A VRLA battery is a lead-acid battery with a valve that regulates the internal pressure and recombines the hydrogen and oxygen produced during charging back into water. It is sealed (no water addition) and can be mounted in any orientation. The typical life is 3–5 years at 25°C (77°F), halved for every 10°C above. The failure mode is usually internal corrosion of the positive grid or drying out (loss of electrolyte through the valve).

**Flooded (wet) batteries.** A flooded lead-acid battery has liquid electrolyte that is visible and can be tested for specific gravity with a hydrometer or a refractometer. The battery requires periodic water addition and ventilation (it produces hydrogen during charging). The typical life is 10–20 years with proper maintenance. The failure mode is usually grid corrosion or sediment accumulation.

**Impedance testing.** The internal impedance of a battery increases as the battery ages and the internal components corrode. An impedance test (also called a conductance test) applies a small AC signal to the battery and measures the response. The impedance is compared to the baseline (the impedance when the battery was new) and to the manufacturer''s end-of-life value. A battery with an impedance 30–50% above the baseline is near the end of life.

**Discharge (load) testing.** A discharge test applies a known load to the battery and measures the time to reach the end-of-discharge voltage. The test gives the actual capacity of the battery, which is the definitive measure of battery health. The test is performed at the rated discharge rate (for a UPS, typically the 5-minute or 10-minute rate) and the capacity is calculated as the percentage of the rated runtime.

**Float voltage.** A battery on float (continuous charging) is held at a specific voltage (2.25–2.30 V per cell for lead-acid at 25°C). The float voltage must be temperature-compensated (lower at higher temperatures) to prevent overcharging and drying out. A float voltage that is too high dries out the battery; a float voltage that is too low allows the battery to sulfate.

**Specific gravity (flooded batteries only).** The specific gravity of the electrolyte is a direct measure of the state of charge. A fully charged cell has a specific gravity of 1.265–1.285 (depending on the manufacturer); a discharged cell has 1.120 or lower. A cell with a specific gravity more than 0.025 below the others is a weak cell and should be investigated.

## Step-by-Step

1. **Perform a visual inspection.** For a VRLA battery, inspect for swelling, leakage, and terminal corrosion. For a flooded battery, inspect the electrolyte level (should be above the plates) and the color of the electrolyte (brown or gray indicates a problem). Record any visual defects.
2. **Measure the float voltage of each cell or battery.** For a VRLA battery, measure the terminal voltage (should be 2.25–2.30 V per cell, or 13.5–13.8 V for a 12V battery). For a flooded battery, measure each cell (should be 2.20–2.25 V per cell). A cell or battery with a voltage more than 0.05 V from the average is a weak cell.
3. **Measure the specific gravity (flooded batteries only).** Use a hydrometer or a refractometer to measure the specific gravity of each cell. A cell with a specific gravity more than 0.025 below the average is a weak cell. Investigate the cause (a partial short, a low electrolyte level, or a need for equalization).
4. **Perform an impedance test.** Use a battery impedance tester to measure the internal impedance of each battery. Compare to the baseline (the impedance when the battery was new) and to the manufacturer''s end-of-life value. A battery with an impedance 30–50% above the baseline is near the end of life and should be scheduled for replacement.
5. **Perform a discharge test (annually or when the impedance indicates a concern).** Disconnect the battery from the UPS (or use a test load) and apply a known discharge current. Measure the time to reach the end-of-discharge voltage (typically 1.75 V per cell). Calculate the capacity as the percentage of the rated runtime. A battery with less than 80% of rated capacity should be replaced.
6. **Record the results.** Record the date, the battery ID, the float voltage, the specific gravity (if applicable), the impedance, and the discharge capacity (if tested). The trend over time is the best predictor of battery failure.
7. **Schedule the replacement.** Based on the test results and the trend, schedule the battery replacement before the battery fails. A battery that is replaced on schedule does not drop the load; a battery that is replaced after it fails already has.

## Common Problems and Fixes

**VRLA battery swollen or leaking.** The battery is being overcharged (float voltage too high or not temperature-compensated) or is in a hot environment. Verify the float voltage and the temperature compensation, and improve the ventilation. Replace the swollen or leaking battery immediately — it is a safety hazard.

**Flooded battery cell with low specific gravity.** The cell is undercharged or has a partial short. Equalize the battery (a controlled overcharge that brings all cells to full charge) and re-measure. If the specific gravity is still low, the cell is weak and the battery should be replaced or the cell should be replaced (if the battery is a multi-cell design with replaceable cells).

**Impedance rising rapidly.** The battery is aging faster than expected, usually due to high temperature or frequent deep discharges. Verify the temperature and the discharge frequency. If the temperature is high, improve the ventilation or move the battery. If the discharges are frequent, consider a larger battery that is not discharged as deeply.

**Discharge test shows low capacity.** The battery has aged and needs replacement. If the capacity is below 80% of rated, replace the battery. If the capacity is low but the battery is new, verify the discharge rate and the end-of-discharge voltage are correct.

**Float voltage uneven across cells.** One or more cells are weak and are dragging the float voltage. Measure the individual cell voltages and the specific gravities (if flooded). Replace the weak cells or the battery.

## Best Practices and Field Tips

- Test the battery impedance quarterly and the discharge capacity annually. The impedance trend detects a failing battery before it drops the load; the discharge test confirms the capacity.
- Keep a battery log with the test results for each battery. The trend is the best predictor of failure — a battery with a rising impedance and a falling capacity is near the end of life, even if it has not failed yet.
- Replace VRLA batteries at 3–5 years, regardless of the test results. A VRLA battery can fail suddenly (internal short) without much warning from the impedance test, and the age is the best predictor.
- For flooded batteries, add distilled water (never tap water) at the scheduled interval. A cell with the plates exposed to air will sulfate and fail.
- Keep the battery and the UPS cool. Battery life is halved for every 10°C above 25°C. A battery in a 35°C control room has half the life of a battery in a 25°C room.

## Safety Notes

- A lead-acid battery can deliver very high current into a short circuit. Remove all metal jewelry before working on a battery, and use insulated tools. A wrench dropped across the battery terminals can vaporize and cause a flash burn.
- A flooded battery produces hydrogen gas during charging. Do not smoke or allow open flames near a flooded battery, and ensure the battery room is ventilated. A hydrogen accumulation can explode.
- A VRLA battery can release hydrogen through the valve if it is overcharged. Do not seal a VRLA battery in an enclosure without ventilation, and do not allow sparks near the valve.
- The electrolyte in a flooded battery is sulfuric acid. Wear chemical-resistant gloves and eye protection when handling the electrolyte, and have an eyewash station nearby. A splash of electrolyte in the eye requires immediate flushing for 15 minutes.
- When replacing a battery, verify the polarity. A reversed connection can destroy the UPS and cause a fire. Connect the positive terminal first, then the negative, and torque the terminals to the manufacturer''s specification.' WHERE title = 'VRLA & Flooded Battery Testing' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Hazardous Location Electrical Installations';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

NEC Article 500 is the entry point to the hazardous location requirements — the classification of areas where flammable gases, vapors, dusts, or fibers may be present in sufficient quantity to ignite, and the electrical installation rules that prevent an electrical arc or spark from becoming the ignition source. The classification system (Class I, II, III; Division 1 and 2; or the Zone system) determines the type of equipment and the installation methods that are permitted. For an industrial electrician in a refinery, a chemical plant, a grain elevator, or a coal handling facility, the hazardous location classification is not a theoretical exercise — it is the difference between a safe installation and an explosion. This lesson covers the NEC 500 classification system, the equipment protection methods, and the field decisions that make a hazardous location installation compliant and safe.

## Key Concepts

**Class I (gases and vapors).** Class I locations are where flammable gases or vapors are or may be present in the air in sufficient quantity to ignite. Typical facilities: refineries, chemical plants, paint spray booths, solvent storage. The gases are grouped by their ignition properties: Group A (acetylene), Group B (hydrogen), Group C (ethylene), Group D (methane, propane, gasoline).

**Class II (dusts).** Class II locations are where combustible dusts are present in sufficient quantity to ignite. Typical facilities: grain elevators, flour mills, coal handling, pharmaceutical manufacturing. The dusts are grouped: Group E (combustible metal dusts), Group F (carbonaceous dusts like coal and carbon black), Group G (agricultural and plastic dusts like grain and flour).

**Class III (fibers and flyings).** Class III locations are where easily ignitable fibers or flyings are present but not likely to be in suspension in the air. Typical facilities: textile mills, woodworking plants, cotton gins. The fibers are not grouped.

**Division 1 vs Division 2.** Division 1 is where the hazard is present during normal operation (the gas is routinely present). Division 2 is where the hazard is present only during abnormal operation (a spill, a leak, a failure). The Division determines the equipment and the installation methods — Division 1 is more restrictive.

**The Zone system (NEC 505, 506).** An alternative to the Division system, used in Europe and increasingly in the US. Zone 0 (continuous hazard), Zone 1 (hazard during normal operation), Zone 2 (hazard during abnormal operation). The Zone system allows different protection methods (intrinsic safety, increased safety) that are not always available under the Division system.

**Equipment protection methods.** Explosion-proof (the enclosure contains an internal explosion without igniting the surrounding atmosphere), dust-ignition-proof (prevents dust from entering and prevents the surface from igniting the dust), intrinsic safety (the energy in the circuit is too low to ignite), purged and pressurized (the enclosure is filled with clean air or inert gas to keep the hazard out), and nonincendive (the circuit cannot produce an arc or spark during normal operation).

## Step-by-Step

1. **Determine the area classification.** The classification is determined by a process hazard analysis (PHA) that considers the flammable materials, the process conditions, and the ventilation. The classification is documented on the area classification drawing, which shows the Class, the Division (or Zone), and the Group for each area of the facility.
2. **Select the equipment for the classification.** For a Class I, Division 1 location, use explosion-proof equipment (NEMA 7 enclosures, explosion-proof fittings and seals). For a Class I, Division 2 location, use equipment that is rated for Division 2 (which may include nonincendive or sealed equipment, less expensive than Division 1). For a Class II, Division 1 location, use dust-ignition-proof equipment (NEMA 9 enclosures).
3. **Select the wiring method.** For Class I, Division 1, use threaded rigid metal conduit (RMC) or IMC with threaded hubs, with explosion-proof seals at the enclosure entries and at the boundaries of the Division. For Class I, Division 2, use RMC, IMC, or Type MC cable with the appropriate fittings. For Class II, use RMC or IMC with dust-tight fittings.
4. **Install the seals.** Explosion-proof seals (Chico seals or equivalent) are required at every enclosure entry in a Division 1 location and at the boundary between a Division 1 and a Division 2 or a non-hazardous area. The seal prevents the gas from traveling through the conduit from one area to another. The seal is a dam that is poured with a sealing compound.
5. **Verify the torque and the threading.** Threaded conduit in a hazardous location must have at least 5 full threads engaged (for NPT threads). The fittings must be torqued to the manufacturer''s specification. A loose fitting can allow gas to pass through and can fail to contain an internal explosion.
6. **Install the bonding and grounding.** The bonding and grounding in a hazardous location must be continuous and low-impedance. A ground fault that produces a spark can ignite the atmosphere, so the EGC must be capable of clearing the fault quickly. Use bonding bushings and jumpers at every fitting.
7. **Document the installation.** Record the area classification, the equipment used, the seal locations, and the torque verification. The documentation is the basis for the inspection and for future modifications.

## Common Problems and Fixes

**Wrong equipment for the classification.** A NEMA 4 enclosure (water-tight) installed in a Class I, Division 1 location is not explosion-proof and is a violation. Replace with a NEMA 7 enclosure (explosion-proof) rated for the correct group.

**Missing or improperly installed seals.** A conduit run that crosses from a Division 1 to a non-hazardous area without a seal allows gas to travel from the hazardous to the non-hazardous area. Install a seal at the boundary, within 10 feet of the boundary but on the hazardous side.

**Conduit threads not fully engaged.** A fitting with only 2 or 3 threads engaged can fail to contain an internal explosion. Re-thread or replace the fitting to achieve at least 5 full threads engaged. Use a thread lubricant (never Teflon tape, which can prevent metal-to-metal contact) on the threads.

**Seal installed in the wrong location.** A seal that is installed on the non-hazardous side of a Division boundary does not prevent gas from entering the non-hazardous area. Install the seal on the hazardous side, within 10 feet of the boundary.

**Equipment not rated for the group.** A Class I, Group D explosion-proof enclosure installed in a Group C (ethylene) location is not rated for the gas and can fail to contain an explosion. Replace with a Group C (or Group B, which covers Group C) enclosure.

## Best Practices and Field Tips

- Always verify the area classification before specifying or installing equipment. The classification is on the area classification drawing, which is maintained by the facility. Do not guess the classification.
- Use a thread lubricant (anti-seize or a listed thread compound) on threaded conduit in hazardous locations, never Teflon tape. Teflon tape can prevent the metal-to-metal contact that is part of the explosion containment and can act as a gas path.
- Keep a set of explosion-proof seals and sealing compound in the truck. A missing seal is a common finding, and the compound takes time to cure, so installing it the first time is faster than a return trip.
- Torque every fitting with a torque wrench. A fitting that is "hand-tight" or "wrench-tight" without a torque verification can fail to contain an explosion. The manufacturer publishes the torque for each fitting.
- Label the hazardous area boundaries on the conduit and the equipment. A label that says "Class I, Div 1, Group D Boundary" at the seal location tells the next electrician where the hazardous area starts and ends.

## Safety Notes

- Do not energize a hazardous location installation that has not been inspected and verified. An installation with a missing seal, a wrong fitting, or a loose thread can allow an internal explosion to propagate to the surrounding atmosphere.
- The sealing compound in an explosion-proof seal takes time to cure (typically 8–24 hours). Do not energize the circuit until the seal is cured, and verify the cure with the manufacturer''s specification.
- A ground fault in a hazardous location can ignite the atmosphere. The EGC must clear the fault quickly, and the overcurrent protection must be coordinated. Verify the grounding and the protection before energizing.
- When working in a hazardous location, use a gas tester to verify the atmosphere is safe before opening any enclosure. An enclosure that is opened in a hazardous atmosphere can allow a spark from the internal equipment to ignite the atmosphere.
- Explosion-proof equipment is heavy and has tight tolerances. Do not modify an explosion-proof enclosure (drill a hole, add a fitting that is not listed for the enclosure) — the modification can void the explosion-proof rating and create a hazard.' WHERE title = 'NEC 500 Class I, II, III & Division/Zone Systems' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Hazardous Location Electrical Installations';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Sealing is the most distinctive and most frequently misunderstood requirement of hazardous location electrical installations. An explosion-proof seal (also called a conduit seal or a Chico seal) is a dam that is poured inside a conduit at specific locations to prevent flammable gas from traveling through the conduit from one area to another, and to prevent an internal explosion from propagating from one enclosure to another through the conduit. The seal is not a water seal, not a corrosion seal, and not a weather seal — it is a gas and flame barrier. The installation requirements (location, spacing, compound, and pour) are specified in NEC 501.15 (Class I), 502.15 (Class II), and 503.15 (Class III), and the details matter. A seal that is in the wrong location, made with the wrong compound, or poured with the wrong technique can fail and allow an explosion to propagate. This lesson covers the sealing requirements, the installation procedure, and the field decisions that make a seal effective.

## Key Concepts

**Purpose of the seal.** In a Class I, Division 1 location, the seal prevents gas from traveling through the conduit from a hazardous area to a non-hazardous area, and prevents an internal explosion in one enclosure from propagating through the conduit to another enclosure. The seal is a dam of sealing compound (a poured, fiber-reinforced compound) that fills the conduit and encapsulates the conductors.

**Seal locations (Class I, Division 1).** A seal is required at every enclosure entry in a Division 1 location (at each fitting or within 18 inches of the enclosure), and at the boundary between a Division 1 and a Division 2 or a non-hazardous area (within 10 feet of the boundary, on the hazardous side). The seal at the boundary prevents gas from traveling from the hazardous to the non-hazardous area.

**Seal locations (Class I, Division 2).** A seal is required at the boundary between a Division 2 and a non-hazardous area, and at any enclosure that is required to be explosion-proof (typically only if the enclosure contains a sparking device, like a switch or a contactor).

**Vertical vs horizontal seals.** A seal can be installed in a vertical or a horizontal run. A vertical seal (with the compound poured from the top) is easier to pour and to verify. A horizontal seal requires a sealing fitting with a dam that holds the compound in place while it cures. The manufacturer''s sealing fitting is designed for the orientation — use the correct fitting for the orientation.

**Sealing compound.** The compound is a two-part or a water-mixed compound (like Chico) that is poured into the sealing fitting. The compound must be listed for the purpose and must fill the conduit completely, encapsulating the conductors. The compound is not cement (it is not structural) and it is not a conductor insulator (it does not need to insulate the conductors, only to block the gas).

**Conductor fill in a seal.** The sealing fitting has a maximum conductor fill (the sum of the conductor cross-sectional areas must not exceed a percentage of the conduit area, typically 25–40%). Overfilling the fitting prevents the compound from flowing around the conductors and leaves voids that allow gas to pass.

**Factory-sealed equipment.** Some explosion-proof equipment (certain switches, lights, and motors) is factory-sealed, which means the internal seal is built into the equipment and a field seal is not required at the entry. The equipment is marked "Factory Sealed" and the installation instructions confirm the seal is not required. Do not install a field seal at a factory-sealed entry — it is unnecessary and can interfere with the factory seal.

## Step-by-Step

1. **Identify the seal locations.** From the area classification drawing and the NEC requirements, identify every location that requires a seal: at each enclosure entry in a Division 1 area, at each Division boundary, and at each sparking enclosure in a Division 2 area.
2. **Select the sealing fitting.** Select a sealing fitting that is rated for the area classification (Class I, the correct group) and the conduit size. Use a vertical fitting for a vertical run and a horizontal fitting for a horizontal run. Verify the fitting is listed and marked for the classification.
3. **Prepare the conductors.** Strip the insulation from the conductors inside the sealing fitting, per the fitting manufacturer''s instruction (typically 1/2 inch of insulation is removed to allow the compound to bond to the conductor). Do not strip more than instructed — the compound must not extend beyond the fitting.
4. **Install the dam and the fiber.** Install the sealing fitting with the dam in place (for a horizontal fitting, the dam is a fiber packing that holds the compound). Insert the fiber packing material (a ceramic or fiber dam) around the conductors to hold the compound in place.
5. **Mix and pour the compound.** Mix the sealing compound per the manufacturer''s instruction (for a two-part compound, mix the two parts; for a water-mix compound, add the water and mix). Pour the compound into the fitting, filling it completely. Tap the fitting to release any air bubbles.
6. **Verify the fill.** After the compound is poured, verify the fitting is full and there are no voids. The compound should be visible at the top of the fitting (for a vertical fitting) or at the inspection port (for a horizontal fitting). Add compound if needed.
7. **Allow the compound to cure.** Allow the compound to cure per the manufacturer''s specification (typically 8–24 hours). Do not energize the circuit until the compound is cured. The cure time depends on the temperature — at low temperatures, the cure takes longer.
8. **Document the seal.** Record the seal location, the fitting, the compound, the date, and the installer. The documentation is the basis for the inspection and for future verification.

## Common Problems and Fixes

**Seal in the wrong location.** A seal installed on the non-hazardous side of a Division boundary does not prevent gas from entering the non-hazardous area. Remove the seal and install it on the hazardous side, within 10 feet of the boundary.

**Seal overfilled with conductors.** Too many conductors in the sealing fitting prevent the compound from flowing around the conductors, leaving voids. Verify the conductor fill per the fitting manufacturer''s table. If overfilled, use a larger fitting or split the conductors into two runs.

**Compound not fully cured before energizing.** The compound takes time to cure, and an energized circuit before the cure is complete can produce heat that prevents the cure or that creates voids. Wait the full cure time before energizing.

**Void in the seal.** A void (an air pocket) in the seal allows gas to pass through. Tap the fitting during the pour to release air bubbles, and verify the fill at the inspection port. If a void is found after the cure, drill it out and re-pour.

**Factory-sealed equipment with an unnecessary field seal.** A field seal installed at a factory-sealed enclosure entry is unnecessary and can interfere with the factory seal. Verify the equipment is marked "Factory Sealed" and do not install a field seal at the entry.

## Best Practices and Field Tips

- Always use a listed sealing compound, never a substitute (like cement or epoxy). The compound is engineered to bond to the conductors and the conduit and to remain gas-tight after thermal cycling.
- Pour the seal at the time of installation, not later. A seal that is left "to be poured later" is often forgotten, and the installation is not compliant until the seal is poured and cured.
- Keep a stock of sealing compound and fiber on the truck. The compound has a shelf life, so rotate the stock. A compound that is past its shelf life may not cure properly.
- For a horizontal seal, use a fitting with an inspection port. The port allows you to verify the fill without removing the fitting, which is important for the inspection.
- Label each seal with the date and the installer. A label that says "Sealed 7/15/2023 by J.S." tells the inspector when the seal was poured and who to ask if there is a question.

## Safety Notes

- A seal that is improperly installed (wrong location, voids, uncured compound) can allow an internal explosion to propagate through the conduit to another enclosure or to a non-hazardous area. Do not energize a hazardous location circuit until all seals are verified.
- The sealing compound is not conductive, but the conductors inside the seal are energized. Do not probe the seal with a metal tool — the tool can contact a conductor and cause a shock or an arc.
- When pouring a seal, wear eye protection and gloves. The compound can irritate the skin and the eyes, and the mixing can splash.
- A seal that is drilled out for re-pouring can damage the conductors. Use a non-conductive drill bit (a fiber or wood bit) and drill carefully to avoid contacting the conductors.
- The sealing compound can shrink during curing, especially at high temperatures. Verify the fill after the cure and add compound if the shrinkage has created a gap. A gap allows gas to pass and the seal is not effective.' WHERE title = 'Sealing & Installation Requirements' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Motor Protection & Overcurrent Devices';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Motor protection is a two-level system: the overload relay protects the motor windings from sustained overcurrent (running overload), and the short-circuit protection (fuse or breaker) protects the circuit from fault current (shorts and ground faults). The two devices have different characteristics and different roles, and they must work together — the overload trips slowly (seconds to minutes) to tolerate the motor''s starting inrush, and the short-circuit device trips quickly (cycles) to clear a fault before it damages the conductors or starts a fire. NEC Article 430 governs the selection and the coordination of these devices for motor circuits. This lesson covers the types of short-circuit protection (fuses, breakers, and motor circuit protectors), their characteristics, and the selection and coordination for a motor circuit.

## Key Concepts

**Fuses.** A fuse is a one-time device that melts a link when the current exceeds the rating for a specific time. The types used in motor circuits: dual-element (time-delay) fuses, which have a time-delay element for the motor inrush and a fast element for the short-circuit; Class J, Class RK1, Class RK5, and Class CC fuses, which have different interrupting ratings and current-limiting characteristics. A current-limiting fuse clears a fault in less than a half-cycle, limiting the peak let-through current.

**Circuit breakers.** A circuit breaker is a resettable device that trips on a thermal (bimetallic) or a magnetic (instantaneous) element, or both. The types used in motor circuits: thermal-magnetic breakers (with an adjustable magnetic trip), magnetic-only breakers (motor circuit protectors, MCP), and electronic breakers (with programmable trip curves). A breaker does not limit the let-through current as effectively as a current-limiting fuse.

**Motor circuit protectors (MCP).** An MCP is a magnetic-only breaker with an adjustable instantaneous trip, designed for the short-circuit protection of a motor circuit. The MCP has no thermal element (the overload relay provides the thermal protection). The MCP is sized to the motor''s inrush and is adjusted to trip above the inrush but below the fault current.

**Time-current curves.** Every overcurrent device has a time-current curve that shows the trip time for a given current. The curve is plotted on log-log paper, with current on the horizontal axis and time on the vertical. The coordination of two devices is the verification that their curves do not overlap — the downstream device trips before the upstream device for every fault current.

**Interrupting rating.** The interrupting rating (AIC, Ampere Interrupting Capacity) is the maximum fault current the device can safely interrupt. The AIC must exceed the available fault current at the device''s line terminals. A device with an AIC of 10 kA installed on a circuit with 25 kA available fault current can fail catastrophically during a fault.

**Current limitation.** A current-limiting fuse or breaker clears the fault so quickly (in less than a half-cycle) that the fault current does not reach its peak. The let-through current (the peak current that passes through the device) is less than the prospective fault current. Current limitation reduces the damage at the fault and the stress on the downstream equipment.

## Step-by-Step

1. **Determine the motor full-load current.** From the motor nameplate, record the FLA, the voltage, the phase, and the service factor. The FLA is the basis for the overload and the short-circuit protection sizing.
2. **Select the short-circuit device.** For a motor circuit, the short-circuit device can be a fuse (dual-element time-delay, sized at 175% of FLA per NEC 430.52, or up to 225% if the 175% size will not tolerate the inrush) or a breaker (inverse-time breaker at 250% of FLA, or an instantaneous-trip MCP at 800–1700% of FLA). The selection depends on the available fault current, the coordination requirements, and the cost.
3. **Verify the interrupting rating.** The AIC of the selected device must exceed the available fault current at the device''s line terminals. Calculate the available fault current (from the utility, the transformer, and the conductor impedance) and verify the AIC. If the AIC is too low, use a current-limiting fuse or a breaker with a higher AIC.
4. **Select the overload relay.** The overload is sized to the motor FLA (or to 115% of FLA for a 1.15 service factor motor). The trip class is selected based on the motor''s acceleration time (Class 10 for standard motors, Class 20 or 30 for high-inertia loads).
5. **Check the coordination.** Plot the time-current curves of the short-circuit device, the overload relay, and the upstream feeder protection. Verify the curves do not overlap — the overload trips before the short-circuit device for currents up to the overload''s maximum, and the short-circuit device trips before the upstream feeder for fault currents. If the curves overlap, adjust the device settings or select different devices.
6. **Verify the conductor protection.** The conductor must be protected by the short-circuit device. NEC 430.22 requires the conductor to be sized at 125% of FLA for continuous duty. The short-circuit device must protect the conductor from fault current (the conductor''s short-circuit withstand must exceed the let-through of the device).
7. **Document the selection.** Record the motor FLA, the short-circuit device (type, rating, AIC), the overload (type, setting, trip class), and the coordination study. The documentation is the basis for the inspection and for future modifications.

## Common Problems and Fixes

**Fuse that blows on motor startup.** The fuse is sized too small for the motor inrush, or it is a fast-acting fuse (not a time-delay). Use a dual-element time-delay fuse, sized per NEC 430.52 (175% of FLA, or up to 225% if needed for the inrush).

**Breaker that trips on motor startup.** The magnetic trip of the breaker is set too low for the motor inrush. Raise the magnetic trip setting (if adjustable) to above the inrush (typically 800–1700% of FLA). If the breaker is not adjustable, replace with an MCP or a breaker with an adjustable magnetic trip.

**Lack of coordination.** The motor short-circuit device and the feeder breaker both trip on a motor fault, taking down the other motors on the feeder. Adjust the trip settings or select devices with better coordination. A current-limiting fuse on the motor circuit can improve the coordination by reducing the let-through.

**Interrupting rating too low.** The available fault current exceeds the AIC of the device. Use a device with a higher AIC, or use a current-limiting fuse upstream that reduces the available fault current at the device.

**Overload trips but the short-circuit device does not.** This is correct behavior — the overload trips for a running overload (current above FLA but below the fault level), and the short-circuit device trips for a fault (current above the overload''s maximum). If the overload trips and the motor is not overloaded, investigate the cause (voltage imbalance, high ambient, worn bearings).

## Best Practices and Field Tips

- Always use dual-element time-delay fuses for motor circuits, never fast-acting fuses. A fast-acting fuse will blow on every motor start and is not suitable for motor duty.
- For circuits with high available fault current (over 100 kA), use current-limiting fuses (Class J, RK1, or CC) to reduce the let-through and to protect the downstream equipment.
- Keep a copy of the time-current curves for each device in the maintenance file. The curves are the basis for the coordination study and for troubleshooting nuisance trips.
- When replacing a fuse or a breaker, verify the type and the AIC match the original. A replacement with a lower AIC or a different trip curve can fail or can miscoordinate.
- Label the short-circuit device and the overload with the motor number and the FLA. A label that says "M3, 25 FLA, Class 20 overload at 25A, 50A Class J fuse" tells the next electrician what is installed and what is correct.

## Safety Notes

- The interrupting rating (AIC) is the maximum fault current the device can safely interrupt. A device with an AIC below the available fault current can fail catastrophically during a fault, producing an arc flash and shrapnel. Always verify the AIC exceeds the available fault current.
- A fuse that has blown may have been subjected to a fault. Do not simply replace the fuse and re-energize — investigate the cause of the fault first. A fault that is not cleared can re-occur and cause more damage.
- A breaker that has tripped on a fault may have damaged contacts. Test the breaker for continuity and for insulation resistance before re-energizing. A breaker with damaged contacts can fail to clear the next fault.
- When replacing a fuse, use a fuse puller, not bare hands. The fuse may be hot (from the fault current or from the ambient), and the line terminal may still be energized from the upstream side.
- A motor circuit that is not coordinated can take down the entire feeder on a motor fault, which can be a safety hazard if the feeder supplies safety-critical loads. Verify the coordination for every motor circuit.' WHERE title = 'Fuses, Breakers & Motor Circuit Protectors' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Motor Protection & Overcurrent Devices';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Selective coordination is the design of an overcurrent protection system so that the device closest to the fault trips first, isolating the fault without affecting the rest of the system. In a selectively coordinated system, a fault on a motor circuit trips only the motor''s short-circuit device, not the feeder breaker or the main breaker. In a non-coordinated system, the same fault can trip multiple devices, taking down the entire feeder or the entire facility. For critical facilities (hospitals, data centers, continuous process plants), selective coordination is not a preference — it is a requirement (NEC 700.27 for emergency systems, 701.18 for legally required standby systems, 708.54 for critical operations power systems). This lesson covers the coordination study, the NEC 430 requirements for motor circuits, and the field practices that produce a coordinated system.

## Key Concepts

**Selective coordination.** Two overcurrent devices are selectively coordinated if the downstream device trips before the upstream device for every fault current. The coordination is verified by plotting the time-current curves of the two devices on the same graph and confirming they do not overlap. If the curves overlap, there is a range of fault currents for which both devices trip (a lack of coordination).

**Time-current curves.** The curve shows the trip time for a given current. The curve has a long-time region (thermal, for running overloads), a short-time region (for faults), and an instantaneous region (for high-level faults). The coordination is checked at every current level — the downstream curve must be below the upstream curve at every current.

**Coordination with fuses.** Two fuses of the same type are coordinated if the ratio of their ratings is at least 2:1 (for most fuse types). A 100A fuse is coordinated with a 200A fuse of the same type. The ratio depends on the fuse type — current-limiting fuses have a better coordination ratio than non-current-limiting.

**Coordination with breakers.** Two breakers are coordinated if their trip curves do not overlap. This often requires the upstream breaker to have a short-time delay (a deliberate delay in the short-time region) to allow the downstream breaker to trip first. The short-time delay increases the arc-flash energy at the upstream breaker, which is a trade-off between coordination and safety.

**NEC 430 requirements.** NEC 430.52 specifies the maximum short-circuit device rating for a motor circuit (175% for fuses, 250% for inverse-time breakers, 800% for instantaneous-trip MCPs, with exceptions for larger sizes if needed for the inrush). NEC 430.62 requires the feeder to a group of motors to be sized for the largest motor plus the sum of the others, and the feeder short-circuit device to be coordinated with the individual motor devices.

**The coordination study.** A coordination study is the process of plotting the time-current curves of all the overcurrent devices in a system (from the utility transformer to the individual loads) and verifying the coordination. The study identifies the devices that miscoordinate and the changes (settings, device types) that achieve the coordination.

## Step-by-Step

1. **Gather the device data.** For each overcurrent device in the system, obtain the time-current curve, the rating, the type, and the settings (for adjustable breakers). The data is from the manufacturer''s published curves.
2. **Calculate the available fault current.** At each device, calculate the available fault current from the utility, the transformer, and the conductor impedance. The fault current is the current that the device must interrupt, and it is the current at which the coordination is checked.
3. **Plot the curves.** On log-log paper (or with coordination software), plot the time-current curve of each device, with the current on the horizontal axis and the time on the vertical. Plot the downstream device first, then the upstream device.
4. **Check the coordination.** For each pair of devices (downstream and upstream), verify the downstream curve is below the upstream curve at every current. If the curves overlap, there is a miscoordination at the overlap current.
5. **Resolve the miscoordination.** For a fuse-fuse pair, increase the ratio (use a larger upstream fuse). For a breaker-breaker pair, add a short-time delay to the upstream breaker or adjust the instantaneous trip. For a fuse-breaker pair, verify the fuse curve is below the breaker curve at the fuse''s current-limiting range.
6. **Verify the motor circuit coordination.** For each motor, verify the motor''s short-circuit device (fuse or MCP) is coordinated with the feeder device. The motor device must trip before the feeder device for a fault at the motor. NEC 430.52 allows the motor device to be sized up to 175% (fuse) or 800% (MCP) of FLA, which usually provides the coordination.
7. **Document the study.** Record the device curves, the available fault current, the coordination verification, and any changes made. The documentation is the basis for the inspection and for future modifications.

## Common Problems and Fixes

**Feeder breaker trips when a motor faults.** The motor short-circuit device and the feeder breaker are not coordinated — the feeder trips before the motor device. Add a short-time delay to the feeder breaker, or use a current-limiting fuse on the motor circuit to reduce the let-through.

**Main breaker trips for any feeder fault.** The main and the feeder breakers are not coordinated. Add a short-time delay to the main breaker, or use a different breaker type with a better coordination characteristic.

**Motor fuse blows but the feeder breaker also trips.** The fuse and the feeder breaker are not coordinated at the fuse''s current-limiting range. Use a faster fuse (Class RK1 or J instead of RK5) or adjust the feeder breaker''s instantaneous trip.

**Coordination achieved but the arc-flash energy is too high.** The short-time delay that achieves the coordination also increases the arc-flash energy at the upstream device. This is a fundamental trade-off. Use a maintenance switch (that temporarily sets the upstream breaker to instantaneous for maintenance) or an arc-flash relay (that trips the breaker on a flash detection) to reduce the arc-flash energy while maintaining the coordination for normal operation.

**Coordination study not performed.** A system that is installed without a coordination study may have hidden miscoordination that is not discovered until a fault takes down more of the system than expected. Perform the study before commissioning and update it after any device change.

## Best Practices and Field Tips

- Always perform a coordination study for a system with critical loads. The study identifies the miscoordination before a fault exposes it, and the documentation is the basis for the settings.
- Use current-limiting fuses for motor circuits with high available fault current. The fuses coordinate well with the upstream breakers and reduce the arc-flash energy.
- Keep a copy of the coordination study in the maintenance file. The study is the reference for the device settings and for troubleshooting nuisance trips.
- When changing a device (replacing a breaker, upsizing a fuse), update the coordination study. A change that is not studied can introduce a miscoordination that is not discovered until a fault.
- For a system with adjustable breakers, record the settings on the coordination study and on the breaker itself. A setting that is not recorded can be changed by the next person, and the coordination can be lost.

## Safety Notes

- A non-coordinated system can trip the main breaker for a single motor fault, which can drop the entire facility. For a facility with life-safety loads, this is a safety hazard. Verify the coordination for every system with critical loads.
- The short-time delay that achieves coordination increases the arc-flash energy. When working on an energized system with short-time delays, wear the appropriate arc-rated PPE and use the maintenance switch if available.
- A coordination study that is not documented is not verifiable. The AHJ may require the study for a critical facility, and the documentation is the proof of compliance.
- When adjusting a breaker''s trip settings, use the correct tool and the correct procedure. A setting that is changed incorrectly can miscoordinate the system or can fail to trip on a fault.
- A motor circuit that is not coordinated with the feeder can take down the feeder on a motor fault. If the feeder supplies safety-critical loads (emergency lighting, fire pumps), the lack of coordination is a life-safety hazard. Coordinate every motor circuit on a critical feeder.' WHERE title = 'Selective Coordination & NEC 430 Requirements' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Variable Frequency Drive Installation & Commissioning';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

A Variable Frequency Drive (VFD) is a power electronic device that converts the fixed-frequency AC input to a variable-frequency, variable-voltage AC output to control the speed and torque of an induction motor. The installation of a VFD is not the same as the installation of a motor starter — a VFD produces high-frequency electrical noise (EMI) that can corrupt nearby signals, it produces voltage reflections on the motor cable that can damage the motor insulation, and it requires a specific motor cable and specific grounding to manage these effects. The wiring, the EMC (electromagnetic compatibility) measures, and the motor cable selection are the details that determine whether a VFD installation is reliable or whether it produces nuisance trips, motor failures, and signal corruption. This lesson covers the VFD wiring, the EMC requirements, and the motor cable selection for a reliable installation.

## Key Concepts

**VFD topology.** A VFD has three stages: a rectifier (converts the AC input to DC), a DC bus (with a capacitor bank that filters the DC and stores energy), and an inverter (converts the DC to a variable-frequency AC output using IGBTs). The inverter produces a PWM (pulse-width modulated) output that approximates a sine wave by switching the DC bus at a high frequency (typically 2–8 kHz).

**EMI and EMC.** The high-frequency switching of the inverter produces conducted and radiated electromagnetic interference (EMI). The EMI can corrupt nearby analog signals, can trip PLC inputs, and can interfere with radio communications. The EMC (electromagnetic compatibility) measures — shielded cable, proper grounding, and filtering — reduce the EMI to an acceptable level.

**Voltage reflection (dV/dt).** The fast switching of the IGBTs (rise times of 50–200 nanoseconds) produces voltage pulses on the motor cable. At the motor terminals, the pulses can reflect off the impedance mismatch (the cable impedance is different from the motor impedance) and double the voltage. On a 480V system, the motor can see 1200–1600V peaks, which can damage the motor insulation over time.

**Motor cable selection.** The motor cable for a VFD must be a shielded cable (to contain the EMI), with a specific impedance (to minimize the voltage reflection), and with an equipment grounding conductor sized for the VFD. The cable length is limited by the voltage reflection — longer cables produce higher reflections. Some VFDs require a specific cable type (like a continuous corrugated aluminum armor cable, MC-OF) for the motor connection.

**Grounding and bonding.** The VFD grounding is critical for EMC. The VFD must be bonded to the enclosure with a low-impedance connection (a flat braided strap, not a round wire, for high frequencies). The motor must be bonded to the VFD with the shield of the motor cable, which must be terminated at both ends with a 360-degree termination (an EMC cable gland, not a pigtail).

**Input and output filtering.** An input filter (a line reactor or a dV/dt filter) on the VFD input reduces the harmonics the VFD draws from the line and protects the VFD from line transients. An output filter (a dV/dt filter or a sine-wave filter) on the VFD output reduces the voltage reflection and the EMI on the motor cable. The filters are selected based on the cable length and the motor type.

## Step-by-Step

1. **Select the VFD.** Size the VFD to the motor full-load current (not the horsepower — a 10 HP motor with a 14A FLA needs a VFD rated for at least 14A, with a margin for the load type). For a variable-torque load (a centrifugal pump or fan), a standard VFD is adequate. For a constant-torque load (a conveyor or a crane), use a VFD with a higher overload capacity (150% for 60 seconds).
2. **Select the motor cable.** Use a shielded VFD cable (a continuous corrugated aluminum armor cable, or a cable with a copper shield and three symmetrical conductors plus a ground). The cable must be sized for the VFD output current and the ambient temperature. Limit the cable length per the VFD manufacturer''s table (typically 100–300 feet without an output filter, longer with a filter).
3. **Install the input wiring.** Connect the VFD input to the line through a disconnect and a short-circuit protection device (fuse or breaker, sized per the VFD manufacturer''s instructions). Use a shielded cable for the input if the VFD is near sensitive equipment, or install a line reactor to reduce the input harmonics.
4. **Install the output wiring.** Connect the VFD output to the motor with the selected VFD cable. Terminate the shield at both ends with a 360-degree EMC cable gland (a gland that clamps around the shield, not a pigtail wire). Keep the output cable as short as possible and away from the input and the control wiring.
5. **Install the control wiring.** Connect the control wiring (start/stop, speed reference, feedback) to the VFD control terminals. Use shielded, twisted-pair cable for the analog signals, with the shield grounded at one end (usually at the VFD) to prevent ground loops. Keep the control wiring in a separate bundle from the power wiring.
6. **Install the output filter (if needed).** If the motor cable exceeds the VFD manufacturer''s length limit, or if the motor is not inverter-duty (not rated for the dV/dt), install a dV/dt filter or a sine-wave filter on the VFD output. The filter reduces the voltage reflection and protects the motor.
7. **Verify the grounding and bonding.** Verify the VFD is bonded to the enclosure with a flat braided strap. Verify the motor is bonded to the VFD with the cable shield, terminated with 360-degree glands. Verify the enclosure is bonded to the facility ground. A poor ground is the most common cause of VFD nuisance trips and signal corruption.
8. **Document the installation.** Record the VFD model, the motor model, the cable type and length, the filters, and the grounding method. The documentation is the basis for the commissioning and for future troubleshooting.

## Common Problems and Fixes

**VFD trips on overcurrent.** The load is too high, the acceleration time is too short, or the motor is undersized. Check the load current during acceleration, lengthen the acceleration time, or verify the motor is sized for the load. If the trip is on a high-inertia load, use a VFD with a higher overload capacity or add a braking resistor.

**Motor insulation fails.** The voltage reflection from the VFD is damaging the motor insulation. Install a dV/dt filter or a sine-wave filter on the VFD output, or use an inverter-duty motor (with insulation rated for the dV/dt, typically 1600V peak). Limit the motor cable length.

**Analog signals are corrupted.** The VFD EMI is coupling into the analog signal wiring. Use shielded, twisted-pair cable for the analog signals, with the shield grounded at one end. Route the analog wiring away from the VFD power wiring (minimum 12 inches separation, or in a separate conduit).

**VFD trips on ground fault.** The motor or the cable has a ground fault, or the VFD ground-fault detection is too sensitive. Check the motor and the cable for a ground fault with a megohmmeter. If the insulation is good, adjust the VFD ground-fault sensitivity (if the application allows) or disable the ground-fault trip (with caution — the ground-fault protection is there for a reason).

**Motor runs hot.** The VFD output has high harmonic content (from the PWM), which causes additional motor heating. Use an inverter-duty motor (with a higher thermal capacity), or install a sine-wave filter on the VFD output, or derate the motor (run at 90% of the nameplate FLA).

## Best Practices and Field Tips

- Always use a shielded VFD cable for the motor connection, never a standard conduit with unshielded conductors. The shield contains the EMI and provides the return path for the high-frequency noise.
- Terminate the cable shield with a 360-degree EMC cable gland at both ends. A pigtail termination (a wire from the shield to the ground) is a high-impedance at high frequencies and does not provide the EMC protection.
- Keep the motor cable as short as possible. Longer cables produce higher voltage reflections and more EMI. If the motor must be far from the VFD, use a sine-wave filter.
- Use a line reactor on the VFD input if the VFD is on a system with high harmonics or if the VFD is near sensitive equipment. The reactor reduces the input harmonics and the EMI.
- Verify the motor is inverter-duty. A standard motor (not rated for the dV/dt) can fail in months on a VFD. An inverter-duty motor has insulation rated for 1600V peak and a higher thermal capacity.

## Safety Notes

- The DC bus capacitors in a VFD retain a lethal charge after the input is disconnected. Wait at least 5 minutes (or the manufacturer''s specified time) after disconnecting the input before opening the VFD enclosure, and verify the DC bus voltage is zero with a meter.
- The VFD output is a live AC source even when the motor is not running (the VFD can be enabled without a run command). Verify the VFD is disabled before working on the motor terminals.
- The VFD can start the motor unexpectedly if a run command is present. De-energize the VFD before working on the motor or the driven equipment, and follow the lockout procedure for the VFD input disconnect.
- The voltage reflection on the motor cable can produce voltages above the motor insulation rating. Use an inverter-duty motor or an output filter to prevent the insulation failure, which can cause a ground fault and an arc flash.
- A VFD that fails with a shorted output IGBT can apply DC to the motor, which can overheat and destroy the motor. The VFD protection should trip on a shorted IGBT, but verify the protection is functional before relying on it.' WHERE title = 'VFD Wiring, EMC & Motor Cable Selection' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Variable Frequency Drive Installation & Commissioning';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

The startup and commissioning of a VFD is the process that turns a correctly wired installation into a correctly operating drive. A VFD that is started without commissioning — with the default parameters, the wrong motor data, and the unverified protection — can run the motor, but it can also damage the motor, trip on the first load, or produce a speed that does not match the process. The commissioning is the verification that the VFD is configured for the specific motor, the specific load, and the specific application, and it is the hand-off from the installer to the operator with the documentation that supports the ongoing operation. This lesson covers the startup procedure, the parameter setting, the test run, and the commissioning hand-off.

## Key Concepts

**Motor nameplate data.** The VFD must be programmed with the motor nameplate data: the rated voltage, the rated current (FLA), the rated frequency, the rated speed (RPM), and the power factor (if required). The VFD uses this data to model the motor and to calculate the flux and the torque. Wrong motor data produces a VFD that runs the motor incorrectly and can damage the motor.

**Motor auto-tune (auto-tuning or ID run).** Many VFDs have an auto-tune function that measures the motor''s electrical characteristics (the stator resistance, the rotor resistance, the leakage inductance) by applying a test signal to the motor. The auto-tune improves the VFD''s motor model and the torque accuracy, especially at low speeds. The auto-tune can be performed with the motor coupled (a static tune) or uncoupled (a rotating tune).

**Control mode.** The VFD can operate in V/Hz mode (a simple voltage-to-frequency ratio, suitable for most variable-torque loads like pumps and fans) or in sensorless vector mode (a more complex control that calculates the motor flux and provides higher torque at low speeds, suitable for constant-torque loads). The control mode is selected based on the application.

**Acceleration and deceleration.** The acceleration time (the time to ramp from 0 to full speed) and the deceleration time (the time to ramp from full speed to 0) are set based on the load inertia and the process requirements. A high-inertia load with a short deceleration time can trip the VFD on overvoltage (the motor acts as a generator and the DC bus voltage rises). A braking resistor may be needed to absorb the regenerated energy.

**Protection settings.** The VFD has adjustable protection: the overload current (usually set to the motor FLA), the overcurrent trip (usually set to 150% of the VFD rating), the overvoltage trip (usually set to a fixed level above the nominal DC bus voltage), and the ground-fault trip. The settings must be coordinated with the motor and the application.

**Reference and I/O.** The VFD receives the speed reference (from a potentiometer, a 4–20 mA signal, a fieldbus, or the keypad) and the run/stop commands (from the terminals or the fieldbus). The I/O must be configured for the specific installation: the analog input type, the digital input function, and the relay output function.

## Step-by-Step

1. **Verify the installation.** Before applying power, verify the VFD is correctly installed: the input wiring, the output wiring, the grounding, the control wiring, and the enclosure. Verify the motor is correctly coupled to the load and is free to rotate.
2. **Apply power and verify the VFD.** Apply the input power and verify the VFD powers up without a fault. Check the input voltage on the VFD display (should be the nominal voltage). Check the DC bus voltage (should be 1.35 times the RMS input voltage for a 3-phase VFD).
3. **Enter the motor nameplate data.** Program the VFD with the motor rated voltage, rated current, rated frequency, and rated speed. Verify the data matches the motor nameplate exactly.
4. **Perform the auto-tune.** If the VFD has an auto-tune function and the application requires it (sensorless vector mode, or a high-torque application), perform the auto-tune. For a rotating tune, uncouple the motor from the load (if possible) and run the tune. For a static tune, the motor can remain coupled.
5. **Set the control mode and the references.** Select the control mode (V/Hz or sensorless vector) based on the application. Configure the speed reference source (keypad, analog input, fieldbus) and the run/stop command source.
6. **Set the acceleration and deceleration.** Set the acceleration and deceleration times based on the load inertia and the process requirements. For a high-inertia load, start with a long acceleration (30–60 seconds) and adjust. If the VFD trips on overvoltage during deceleration, lengthen the deceleration time or add a braking resistor.
7. **Set the protection.** Set the overload current to the motor FLA. Verify the overcurrent, overvoltage, and ground-fault trips are at the VFD defaults (or as specified by the application).
8. **Perform a test run.** Run the motor at a low speed (10–20%) and verify the direction of rotation, the smoothness, and the absence of faults. Run the motor at full speed and verify the current, the voltage, and the speed match the expected values. Run the motor through the full speed range and verify the operation at all speeds.
9. **Document the commissioning.** Record the VFD model, the motor model, the parameters (motor data, control mode, acceleration, protection), the test run results, and any deviations from the expected. The documentation is the hand-off to the operator and the basis for future troubleshooting.

## Common Problems and Fixes

**Motor runs in the wrong direction.** The VFD output phases are connected in the wrong order. Swap any two of the three output conductors at the VFD or the motor, or change the rotation parameter in the VFD (if the VFD supports it).

**VFD trips on overcurrent during acceleration.** The acceleration time is too short, or the load is too high. Lengthen the acceleration time, or verify the load is within the VFD and motor rating. For a high-inertia load, use a VFD with a higher overload capacity or add a braking resistor.

**VFD trips on overvoltage during deceleration.** The deceleration time is too short for the load inertia, and the regenerated energy raises the DC bus voltage. Lengthen the deceleration time, or add a braking resistor to absorb the regenerated energy.

**Motor overheats at low speed.** The motor cooling fan (which is on the motor shaft) does not provide enough cooling at low speed. Use an inverter-duty motor with a higher thermal capacity, or add a separately powered cooling fan, or limit the continuous operation at low speed.

**VFD does not follow the speed reference.** The reference source is not configured correctly, or the reference signal is wrong. Verify the reference source in the VFD parameters, and measure the reference signal at the VFD terminals (a 4–20 mA signal should read 4 mA at zero speed and 20 mA at full speed).

## Best Practices and Field Tips

- Always perform the auto-tune for a sensorless vector application. The auto-tune measures the motor characteristics that the VFD cannot know from the nameplate, and it significantly improves the low-speed torque and the speed accuracy.
- Document every parameter that is changed from the default. A VFD that is commissioned with undocumented parameter changes is difficult to troubleshoot and difficult to replicate if the VFD is replaced.
- Run the motor through the full speed range during commissioning. A VFD that runs at full speed but has not been tested at low speed may trip or produce inadequate torque when the process runs at low speed.
- For a high-inertia load, test the deceleration carefully. A deceleration that trips on overvoltage in the test will trip in the operation, and the braking resistor must be sized before the hand-off.
- Keep a copy of the VFD parameters (a parameter backup) in the maintenance file. A VFD that fails can be replaced and the parameters can be restored from the backup, which reduces the downtime.

## Safety Notes

- The DC bus capacitors retain a lethal charge after the input is disconnected. Wait the manufacturer''s specified time (at least 5 minutes) before opening the VFD, and verify the DC bus voltage is zero with a meter.
- The VFD can start the motor unexpectedly if a run command is present. De-energize the VFD before working on the motor or the driven equipment, and follow the lockout procedure.
- The VFD output is a live AC source even when the motor is not running. Verify the VFD is disabled before touching the motor terminals or the output cable.
- During the test run, keep personnel clear of the driven equipment. A VFD that starts the motor unexpectedly can move the equipment and injure someone who is too close.
- The braking resistor can get very hot during operation. Mount the resistor away from combustible materials and away from personnel, and verify the resistor''s temperature rating is not exceeded during the deceleration duty.' WHERE title = 'Startup Procedure & Commissioning Hand-off' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Electrical Prints, Schematics & Ladder Diagrams';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Electrical drawings are the language of the industrial electrical trade. A one-line diagram, a ladder diagram, and a wiring diagram each serve a different purpose and each is drawn to a different convention. The one-line shows the power distribution from the service to the loads in a single-line representation; the ladder diagram shows the control logic in a format that reads like a rung of a ladder; the wiring diagram shows the physical connections between components. An industrial electrician must read all three fluently, must be able to trace a signal from the one-line to the ladder to the wiring, and must be able to produce a drawing that communicates the installation to the next electrician. This lesson covers the conventions of each type, the reading of the diagrams, and the production of a clear, correct drawing.

## Key Concepts

**One-line diagram.** A one-line (or single-line) diagram shows the power distribution with a single line representing each three-phase circuit. The components (transformers, breakers, contactors, motors) are represented by standard symbols (per ANSI/IEEE or IEC). The one-line shows the ratings (voltage, current, kVA, HP) and the connections but not the physical layout. It is the overview of the power system.

**Ladder diagram.** A ladder diagram (or elementary diagram or schematic) shows the control logic. The left rail is the power source (L1, the hot leg); the right rail is the return (L2, the neutral or the other hot leg). The control logic is drawn as rungs between the rails, with each rung representing one control function (a motor start, a valve open, an interlock). The rungs read left to right: the inputs (pushbuttons, limit switches, relay contacts) on the left, the output (a coil, a solenoid, a light) on the right.

**Wiring diagram.** A wiring diagram (or connection diagram) shows the physical connections between components, with the wire numbers and the terminal numbers. It is the diagram that the electrician uses to wire the panel and to troubleshoot the connections. It shows the actual routing of the wires, not the logic.

**Cross-referencing.** The three diagrams are cross-referenced: a contactor on the one-line (e.g., "M1") is the same contactor on the ladder (the coil M1 and the contacts M1) and on the wiring (the terminal numbers for the coil and the contacts). The cross-reference allows the electrician to trace from the power to the control to the physical connection.

**Symbols.** The standard symbols (ANSI/IEEE in the US, IEC internationally) represent the components: a contactor (a circle with contacts), a transformer (two coils), a motor (a circle with an M), a pushbutton (a line with a contact), a limit switch (a line with a contact and an actuator). The symbols are the vocabulary of the drawings.

**Wire numbers and terminal numbers.** Each wire has a unique number (from the schematic) that is the same at both ends. Each terminal on a component has a number (from the manufacturer) that identifies the connection point. The wire number and the terminal number together identify the connection unambiguously.

## Step-by-Step

1. **Start with the one-line.** Read the one-line to understand the power distribution: the service, the transformers, the feeders, the motor control centers, the individual motors. Identify the ratings (voltage, kVA, HP, FLA) and the overcurrent protection. The one-line is the map of the power system.
2. **Move to the ladder diagram.** For the specific motor or function you are working on, find the rung on the ladder diagram. Read the rung from left to right: the inputs (the start button, the stop button, the overload contacts, the limit switches) and the output (the contactor coil). The ladder is the logic of the control.
3. **Trace the cross-references.** The contactor coil on the ladder (e.g., "M1") has contacts that are used in other rungs (the holding contact, the interlock contacts). The cross-reference (a letter and a number, like "4/3" for rung 4, contact 3) tells you where the contact is used. Trace the contacts to understand the full logic.
4. **Move to the wiring diagram.** For the physical connections, find the wiring diagram for the panel. The wiring diagram shows the terminal blocks, the wire numbers, and the routing. Use the wire numbers from the schematic to trace the physical wires.
5. **Verify the drawing against the installation.** If you are troubleshooting, verify the drawing matches the installation. A drawing that does not match (a wire that is in a different terminal, a component that has been changed) can mislead the troubleshooting. Update the drawing if the installation has been modified.
6. **Produce a clear drawing.** If you are documenting a modification, produce a drawing that follows the conventions: the correct symbols, the wire numbers, the terminal numbers, and the cross-references. A drawing that does not follow the conventions is difficult to read and can mislead the next electrician.

## Common Problems and Fixes

**Drawing does not match the installation.** The installation has been modified but the drawing has not been updated. Verify the drawing against the installation, and update the drawing to match. A drawing that does not match is worse than no drawing because it misleads.

**Wire numbers missing or wrong.** A wire without a number, or with a number that does not match the schematic, is difficult to trace. Verify the wire numbers at both ends and correct the drawing or the installation as needed.

**Cross-references missing.** A contactor with contacts in multiple rungs but no cross-reference is difficult to trace. Add the cross-references to the drawing (the rung and the contact number for each contact).

**Symbols not standard.** A drawing with non-standard symbols is difficult to read. Use the ANSI/IEEE or IEC symbols, and include a symbol legend if the drawing uses any non-standard symbols.

**One-line and ladder not consistent.** A motor on the one-line (e.g., "M3") that is not on the ladder, or a motor on the ladder that is not on the one-line, indicates a documentation error. Verify the one-line and the ladder are consistent and correct the error.

## Best Practices and Field Tips

- Always carry a copy of the drawings when troubleshooting. The drawing is the guide, and a troubleshooting session without the drawing is a guessing game.
- Keep the drawings updated. A modification that is not documented is lost, and the next electrician will have to reverse-engineer the installation. Update the drawing at the time of the modification, not later.
- Use a consistent wire numbering scheme. A scheme that is consistent (e.g., power wires 1-99, control wires 100-199, analog wires 200-299) makes the drawing easier to read and the wires easier to trace.
- Include a legend on the drawing for the symbols and the wire colors. A drawing with a legend is self-documenting; one without requires the reader to know the conventions.
- When producing a drawing, use CAD software (or a clear hand-drawing for a small modification) and keep the digital file. A drawing that is only on paper is easily lost; a digital file can be backed up and shared.

## Safety Notes

- A drawing is a guide, not a guarantee. Verify the actual installation before working on it — a drawing can be wrong, and the installation can have been modified without documentation. Always verify the absence of voltage with a tester before touching.
- When reading a drawing for troubleshooting, be aware that the drawing may show the circuit de-energized when it is actually energized (or vice versa). Do not assume the drawing reflects the current state of the installation.
- A drawing that is used for lockout/tagout must be verified against the installation. A disconnect that is shown on the drawing but is not the actual disconnect for the circuit can lead to an unsafe lockout.
- When producing a drawing, include the safety information (the available fault current, the arc-flash hazard, the PPE requirement) on the drawing. The drawing is the communication tool, and the safety information must be communicated.
- A drawing that is outdated or incorrect can lead to a wrong troubleshooting decision, which can be dangerous. Always verify the drawing against the installation, and update the drawing if the installation has been modified.' WHERE title = 'One-Line, Ladder & Wiring Diagrams' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Electrical Prints, Schematics & Ladder Diagrams';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Terminal blocks and cross-referencing are the details that make a control panel maintainable. A terminal block is the connection point where a wire from inside the panel meets a wire from outside the panel, and where a wire from one section of the panel meets a wire from another. The terminal block organizes the wiring, provides a test point, and allows a wire to be disconnected without disturbing the others. Cross-referencing is the system that links the components and the contacts across the drawings — a contactor coil on rung 5 with a contact on rung 12 is cross-referenced so the reader can find both. Together, terminal blocks and cross-referencing are the infrastructure that turns a panel from a tangle of wires into a maintainable system. This lesson covers the selection and the labeling of terminal blocks, the cross-referencing conventions, and the field practices that make the panel easy to troubleshoot.

## Key Concepts

**Terminal block types.** The common types: screw-clamp terminals (the traditional type, with a screw that clamps the wire), spring-clamp terminals (with a spring that clamps the wire, faster and more reliable than screw-clamp), and multi-level terminals (with two or three connection levels in the same space, for high-density panels). Each type has a specific application and a specific installation tool.

**Terminal block functions.** A terminal block can be a feed-through (connects two wires, one on each side), a disconnect (with a knife switch that opens the circuit for testing), a fuse (with a fuse in the terminal for circuit protection), a ground (with a connection to the DIN rail for the equipment grounding conductor), and a shield (with a connection for a cable shield). The function is selected for the specific connection.

**DIN rail mounting.** Terminal blocks are mounted on DIN rails (standard 35 mm or 15 mm rails) that are snapped into the panel subpanel. The DIN rail provides a standardized mounting and a common ground for the ground terminals. The terminal blocks snap on and off the rail for easy replacement.

**Terminal labeling.** Each terminal is labeled with a unique number (from the schematic) that identifies the wire and the connection. The label is on the terminal itself (a marker strip that snaps onto the block) and on the wire (a wire marker at both ends). The terminal number and the wire number together identify the connection.

**Cross-referencing.** On a ladder diagram, a contactor coil and its contacts are cross-referenced. The coil (on one rung) has a reference (like "5/3" for rung 5, contact 3) that tells the reader where the contacts are. The contacts (on other rungs) have a reference back to the coil (like "7/2" for rung 7, coil 2). The cross-reference allows the reader to trace the logic from the coil to the contacts and back.

**Page and line references.** On a multi-page drawing, the cross-reference includes the page number and the line number (like "3/14" for page 3, line 14). The reference tells the reader exactly where to find the referenced component or contact. A drawing without page and line references is difficult to navigate on a multi-page schematic.

## Step-by-Step

1. **Select the terminal block type.** Based on the wire size, the number of connections, and the panel density, select the terminal block type (screw-clamp, spring-clamp, or multi-level). For a high-density panel, use multi-level terminals. For a panel that will be modified frequently, use spring-clamp terminals (faster to connect and disconnect).
2. **Select the terminal function.** For each connection, select the function: feed-through for a simple connection, disconnect for a connection that needs to be opened for testing, fuse for a connection that needs local protection, ground for the EGC, and shield for a cable shield. Use the correct function for each connection.
3. **Mount the terminal blocks on the DIN rail.** Snap the terminal blocks onto the DIN rail in the order shown on the schematic. Install the end stops at each end of the rail. Install the marker strips on the terminals with the terminal numbers from the schematic.
4. **Wire the terminals.** Connect the wires to the terminals per the schematic, with the wire numbers from the schematic. Torque the screw terminals to the manufacturer''s specification. For spring-clamp terminals, use the correct insertion tool and verify the wire is fully inserted.
5. **Label the terminals and the wires.** Verify the terminal markers match the schematic. Verify the wire markers match the schematic. A mismatch is a documentation error or an installation error — correct it before energizing.
6. **Add the cross-references to the drawing.** On the ladder diagram, add the cross-references: the coil reference (where the contacts are) and the contact reference (where the coil is). On a multi-page drawing, add the page and line references. Verify the cross-references are correct and complete.
7. **Document the terminal layout.** Produce a terminal layout drawing that shows the terminal numbers, the wire numbers, and the external connections. The layout is the guide for the installer and the troubleshooter.

## Common Problems and Fixes

**Wrong terminal type for the wire size.** A terminal that is too small for the wire cannot make a reliable connection. Verify the terminal is rated for the wire size, and use a larger terminal or a ferrule for stranded wire.

**Terminal not labeled or mislabeled.** A terminal without a label, or with a label that does not match the schematic, is difficult to trace. Verify the terminal markers match the schematic, and correct any mismatch.

**Wire not fully inserted in a spring-clamp terminal.** A stranded wire that is not fully inserted in a spring-clamp terminal can have a strand that is not captured, which causes a high-resistance connection. Use a ferrule on stranded wire, and verify the wire is fully inserted (a tug test confirms the connection).

**Cross-references missing or wrong.** A contactor with contacts on multiple rungs but no cross-reference is difficult to trace. Add the cross-references to the drawing, and verify they are correct (a wrong cross-reference is worse than none because it misleads).

**Terminal block overloaded.** A terminal with too many wires in one connection point can have a high-resistance connection. Use a terminal with the correct number of connection points, or use a jumper to connect adjacent terminals.

## Best Practices and Field Tips

- Use spring-clamp terminals for panels that will be modified frequently. The spring-clamp is faster to connect and disconnect, and it does not loosen over time like a screw terminal.
- Use ferrules on all stranded wires in spring-clamp terminals. A ferrule captures all the strands and provides a reliable, gas-tight connection.
- Keep a set of spare terminal markers in the panel. A terminal that is added during commissioning needs a marker, and having the markers in the panel saves a trip to the truck.
- Cross-reference every contact on the ladder diagram. A drawing with complete cross-references is easy to trace; one without is a guessing game.
- Use a consistent terminal numbering scheme. A scheme that is consistent (e.g., T1, T2, T3 for the power terminals; T101, T102 for the control terminals) makes the drawing easier to read and the terminals easier to find.

## Safety Notes

- A terminal that is not torqued to the specification can overheat and cause a fire. Use a torque screwdriver on every screw terminal, and verify the torque is correct for the terminal and the wire size.
- A terminal that is overloaded (too many wires in one point) can overheat. Use the correct number of connection points, and do not force multiple wires into a single point.
- A ground terminal must be connected to the DIN rail (which is bonded to the enclosure). Verify the ground terminal is the correct type and is bonded to the rail, or the EGC is not effective.
- A disconnect terminal that is opened for testing can leave the downstream circuit energized from another source. Verify the absence of voltage on both sides of the disconnect before working on the downstream circuit.
- A fuse terminal with the wrong fuse rating can fail to protect the circuit. Verify the fuse rating matches the schematic, and do not upsize the fuse to stop nuisance blowing without finding the cause.' WHERE title = 'Terminal Blocks & Cross-Referencing' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;
