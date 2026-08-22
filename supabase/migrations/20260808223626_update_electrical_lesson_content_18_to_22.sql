DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Lighting Systems, Ballasts & LED Retrofits';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Industrial lighting has evolved from the high-intensity discharge (HID) and fluorescent systems that dominated the 20th century to the LED systems that dominate today. Each technology has specific characteristics, failure modes, and maintenance requirements. An industrial electrician must understand all three because most facilities have a mix — a plant that is retrofitting to LED still has HID high bays in the warehouse and fluorescent tubes in the office. Understanding the technology, the ballast or driver, and the failure modes is essential for maintaining the existing systems and for planning the retrofits. This lesson covers the HID, fluorescent, and LED technologies, their components, their common failures, and the maintenance practices that keep them running.

## Key Concepts

**HID (High-Intensity Discharge).** HID lamps (metal halide, high-pressure sodium, mercury vapor) produce light by an arc through a gas. The lamp requires a ballast (magnetic or electronic) to limit the current and a starting pulse (an ignitor) to strike the arc. HID lamps have a long warm-up time (2–10 minutes to full brightness) and a restrike time (5–15 minutes after a power interruption before the lamp can restart). The lamp life is 10,000–30,000 hours, with a significant lumen depreciation (the light output drops 30–50% over the life).

**Fluorescent.** Fluorescent lamps (T12, T8, T5) produce light by a discharge through a phosphor-coated tube. The lamp requires a ballast (magnetic or electronic) to limit the current and, for some types, a starter to preheat the cathodes. Electronic ballasts are more efficient and quieter than magnetic ballasts. The lamp life is 20,000–30,000 hours, with moderate lumen depreciation. Fluorescent lamps contain mercury and must be disposed of as hazardous waste.

**LED (Light Emitting Diode).** LED fixtures produce light by semiconductor diodes that emit photons when forward-biased. The LED requires a driver (an electronic power supply that converts the AC input to a constant DC current for the LEDs). LED fixtures have instant on/off, no warm-up or restrike time, and a long life (50,000–100,000 hours) with low lumen depreciation (10–20% over the life). The efficiency is 2–5 times that of HID and fluorescent. LED fixtures do not contain mercury.

**Ballasts and drivers.** A HID ballast and a fluorescent ballast limit the current to the lamp. An LED driver converts the AC input to a constant DC current for the LEDs. The driver can be constant-current (the most common, with a fixed current and a variable voltage) or constant-voltage (with a fixed voltage and a variable current). The driver is the most common failure point in an LED fixture.

**Color temperature and CRI.** The color temperature (in Kelvin) describes the color of the light: 2700K (warm white), 4000K (cool white), 5000K (daylight), 6500K (cool daylight). The CRI (Color Rendering Index, 0–100) describes how accurately the light renders colors. For industrial applications, 4000–5000K and a CRI of 80+ are typical. A higher CRI is needed for inspection and color-matching tasks.

**Photopic vs scotopic.** The human eye has different sensitivity in bright light (photopic) and dim light (scotopic). HID and LED light has more scotopic content (more blue), which appears brighter to the eye than the same photopic lumen value. This is why an LED fixture with fewer photopic lumens can appear as bright as an HID fixture with more.

## Step-by-Step

1. **Identify the existing technology.** For each fixture, identify the technology (HID, fluorescent, LED), the lamp type, the wattage, the ballast or driver type, and the age. This is the inventory for the maintenance and the retrofit planning.
2. **For HID: troubleshoot the common failures.** A lamp that does not light: check the lamp (replace with a known good lamp), the ballast (measure the ballast output voltage), the ignitor (measure the pulse voltage), and the connections. A lamp that cycles on and off: the lamp is at end of life (the arc tube is deteriorating) or the ballast is failing. A lamp that is dim: the lamp is at end of life (lumen depreciation) or the ballast is failing.
3. **For fluorescent: troubleshoot the common failures.** A lamp that does not light: check the lamp (replace), the ballast (measure the output), the starter (if used), and the connections. A lamp that is dim or flickering: the lamp is at end of life or the ballast is failing. A lamp with dark ends: the cathodes are failing (the lamp is at end of life).
4. **For LED: troubleshoot the common failures.** A fixture that does not light: check the driver (measure the output voltage and current), the LED board (measure the forward voltage), and the connections. A fixture that is dim: the driver is failing (low output current) or the LEDs are degrading. A fixture that flickers: the driver is failing or the input voltage is unstable.
5. **Measure the light level.** Use a light meter to measure the foot-candles at the work surface. Compare to the recommended level for the task (per IES or the facility standard). A low level indicates the need for maintenance (cleaning, lamp replacement) or retrofit.
6. **Document the system.** Record the technology, the lamp type, the wattage, the ballast or driver, the age, and the light level for each fixture. The documentation is the basis for the maintenance schedule and the retrofit planning.

## Common Problems and Fixes

**HID lamp cycles on and off.** The lamp is at end of life (the arc tube is deteriorating and the arc cannot be maintained). Replace the lamp. If the cycling continues with a new lamp, the ballast is failing — replace the ballast.

**Fluorescent lamp with dark ends.** The cathodes are failing, which is a sign of end of life. Replace the lamp. If the dark ends appear on a new lamp, the ballast is overdriving the cathodes — replace the ballast.

**LED fixture flickers.** The driver is failing or the input voltage is unstable. Measure the driver output (should be a constant DC current). If the output is unstable, replace the driver. If the input voltage is unstable, investigate the supply (a loose neutral, a voltage sag from a large motor start).

**HID lamp does not restrike after a brief power interruption.** HID lamps have a restrike time (5–15 minutes) because the arc tube must cool before the arc can be re-struck. This is a characteristic of HID, not a fault. For applications that cannot tolerate the restrike time, use LED (instant on/off) or add a backup light.

**LED fixture is dim.** The driver is failing (low output current) or the LEDs are degrading (lumen depreciation at end of life). Measure the driver output and compare to the rated current. If the driver is failing, replace the driver. If the LEDs are degrading, replace the fixture.

## Best Practices and Field Tips

- Keep a stock of the most common lamps and ballasts for the facility. A lamp that fails takes the light down, and the spare gets it back up immediately.
- Clean the fixtures regularly. A dirty fixture can lose 20–30% of its light output. A cleaning is the cheapest lighting maintenance.
- When retrofitting to LED, verify the retrofit kit is compatible with the existing fixture. Some kits require the ballast to be removed (a direct wire to the line), others are plug-and-play (they use the existing ballast). The plug-and-play kits are easier but depend on the ballast, which may fail.
- Use LED fixtures with a rated life of 50,000+ hours and a warranty of 5+ years. A fixture with a shorter life or warranty will cost more in maintenance over the life.
- For a retrofit, measure the light level before and after. The LED fixture should produce the same or more light at a lower wattage. A measurement that shows less light indicates the LED fixture is not equivalent.

## Safety Notes

- HID lamps operate at high pressure and high temperature. A lamp that is at end of life can rupture (a non-passive failure) and scatter hot glass. Use the correct lamp for the fixture and replace lamps at the end of their rated life, not after they fail.
- Fluorescent lamps contain mercury. Dispose of them as hazardous waste, not in the regular trash. A broken fluorescent lamp releases mercury vapor, which is a health hazard — ventilate the area and clean up the debris with gloves.
- LED drivers produce DC voltage that can be above 50V. A driver output is a shock hazard. De-energize the fixture before working on the driver or the LED board.
- A ballast or driver that is failing can overheat and leak a tar-like compound. Do not touch a leaking ballast with bare hands — the compound can be a skin irritant and the ballast can be hot.
- When working on a high-bay fixture, use the correct lift and fall protection. A fall from a high-bay fixture can be fatal, and the fixture can be heavy enough to cause a serious injury if it falls.' WHERE title = 'HID, Fluorescent & LED Systems' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Lighting Systems, Ballasts & LED Retrofits';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

An LED retrofit is the replacement of an existing HID or fluorescent lighting system with an LED system. The retrofit is driven by energy savings (LED is 2–5 times more efficient), maintenance savings (LED lasts 5–10 times longer), and light quality (LED has better color rendering and controllability). But a retrofit that is planned without a lighting calculation and a consideration of the existing conditions can produce too little light, too much light, or light in the wrong places. The planning process — the lighting calculation, the fixture selection, the layout, and the energy calculation — is the difference between a retrofit that meets the needs of the facility and one that does not. This lesson covers the retrofit planning process, the lighting calculations (the lumen method and the point-by-point method), and the energy and payback calculations that justify the retrofit.

## Key Concepts

**The lumen method.** The lumen method calculates the average illuminance (in foot-candles) for a space. The formula: E = (N × L × CU × LLF) / A, where E is the illuminance, N is the number of fixtures, L is the lumens per fixture, CU is the coefficient of utilization (the fraction of the lumens that reach the work surface, from the manufacturer''s CU table), LLF is the light loss factor (the depreciation over time, typically 0.8 for LED), and A is the area. The method is used for general lighting in open spaces.

**The point-by-point method.** The point-by-point method calculates the illuminance at specific points using the photometric data of the fixture (the candela distribution). The method is used for task lighting, for spaces with obstructions, and for verifying the uniformity. The calculation is typically done with lighting software (like AGi32 or Visual), not by hand.

**Coefficient of utilization (CU).** The CU is the fraction of the fixture''s lumens that reach the work surface, accounting for the room geometry (the room cavity ratio), the surface reflectances (ceiling, wall, floor), and the fixture distribution. The CU is from the manufacturer''s CU table for the specific fixture and the room conditions.

**Light loss factor (LLF).** The LLF accounts for the depreciation of the light output over the maintenance cycle. For LED, the LLF is the lumen maintenance (typically 0.8–0.9 at 50,000 hours) times the dirt depreciation (typically 0.9 for a clean environment, 0.8 for a dirty one). The LLF is applied to the initial illuminance to get the maintained illuminance.

**Recommended illuminance.** The IES (Illuminating Engineering Society) publishes recommended illuminance levels for various tasks. For industrial spaces: 10–20 foot-candles for storage, 30–50 for rough manufacturing, 50–100 for fine manufacturing, 100+ for inspection. The retrofit should meet or exceed the recommended level.

**Energy calculation.** The energy savings of a retrofit is the difference between the existing wattage and the LED wattage, times the operating hours, times the energy cost. The payback period is the retrofit cost divided by the annual savings. A retrofit with a payback of 3 years or less is typically justified; 5 years may be justified with maintenance savings.

## Step-by-Step

1. **Inventory the existing system.** For each space, record the fixture type, the wattage, the number of fixtures, the operating hours, and the measured illuminance. This is the baseline for the retrofit.
2. **Determine the required illuminance.** From the IES recommendation or the facility standard, determine the required maintained illuminance for the task in each space. This is the target for the retrofit.
3. **Calculate the required lumens (lumen method).** For each space, calculate the required lumens per fixture: L = (E × A) / (N × CU × LLF). Use the CU for the existing room conditions (reflectances, room geometry) and the LLF for the LED fixture (0.8 typical). Adjust the number of fixtures or the lumens per fixture to meet the target.
4. **Select the LED fixture.** Select an LED fixture that provides the required lumens, with the correct color temperature (4000–5000K for industrial), the correct CRI (80+), and the correct distribution (wide for open spaces, narrow for aisles). Verify the fixture is rated for the environment (wet, dusty, or hazardous if applicable).
5. **Perform a point-by-point calculation (if needed).** For spaces with obstructions, task lighting, or uniformity requirements, perform a point-by-point calculation with lighting software. Verify the illuminance at the specific points and the uniformity (the ratio of the minimum to the average illuminance, typically 0.6–0.8).
6. **Calculate the energy savings.** For each space, calculate the energy savings: (existing wattage - LED wattage) × operating hours × energy cost. Sum the savings for all spaces. Calculate the payback: retrofit cost / annual savings.
7. **Plan the installation.** Plan the installation to minimize the disruption to the facility. Consider the disposal of the existing lamps (fluorescent and HID lamps are hazardous waste), the modification of the existing fixtures (some LED retrofits require the ballast to be removed), and the verification of the circuit capacity (the LED fixtures draw less current, which may allow more fixtures on the circuit).

## Common Problems and Fixes

**Retrofit produces less light than the existing system.** The LED fixture has fewer lumens than the HID or fluorescent it replaced, or the LLF is too optimistic. Verify the lumen output of the LED fixture and the LLF. If the light is insufficient, add fixtures or use a higher-lumen fixture.

**Retrofit produces uneven light.** The fixture spacing or the distribution is wrong for the space. Perform a point-by-point calculation and adjust the spacing or the fixture distribution.

**LED fixture fails prematurely.** The fixture is in a hot environment (LED life is reduced by high temperature) or the driver is failing. Verify the fixture is rated for the ambient temperature, and verify the driver is not overheating (check the driver temperature with an IR camera).

**Retrofit does not meet the payback target.** The energy savings are less than expected, or the retrofit cost is higher than expected. Verify the operating hours and the energy cost, and verify the retrofit cost includes the installation and the disposal.

**Existing circuit is overloaded after the retrofit.** This is unusual (LED draws less current), but if the retrofit added more fixtures, the circuit may be overloaded. Verify the circuit capacity and the total LED wattage.

## Best Practices and Field Tips

- Always perform a lighting calculation before a retrofit. A retrofit that is based on "the same number of fixtures" without a calculation can produce too much or too little light.
- Use the maintained illuminance (with the LLF), not the initial illuminance, for the design. The light level at the end of the maintenance cycle is the one that matters.
- Consider the controllability of the LED. LED fixtures can be dimmed and can be controlled by occupancy sensors and daylight sensors, which can save more energy than the lamp replacement alone.
- For a large retrofit, do a pilot installation in one space and measure the results before committing to the full retrofit. A pilot catches the problems (too much light, too little light, glare, color) before they are repeated in every space.
- Keep the photometric data and the lighting calculation in the facility documentation. The calculation is the basis for future modifications and for verifying the retrofit met the design.

## Safety Notes

- The disposal of fluorescent and HID lamps is regulated (they contain mercury and other hazardous materials). Use a licensed disposal service, and do not break the lamps during removal.
- When working on a high-bay fixture, use the correct lift and fall protection. A retrofit that involves removing and replacing high-bay fixtures is a fall hazard.
- The existing circuit may have aged wiring that is not adequate for the new fixtures, even though the LED draws less current. Verify the wiring and the overcurrent protection before energizing the new fixtures.
- An LED driver that is failing can overheat and produce a burning smell. De-energize a fixture that is overheating and investigate the cause before re-energizing.
- When removing the existing ballast, verify the circuit is de-energized and locked out. A ballast that is still connected to the line is a shock hazard, and a ballast with a stored charge (from the capacitor) can shock even after the power is off.' WHERE title = 'Retrofit Planning & Energy Calculations' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Power Quality Basics';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Harmonics are voltage and current distortions at frequencies that are integer multiples of the fundamental (60 Hz in North America). The fundamental is the desired frequency; the harmonics are the distortion. In an industrial plant, the primary sources of harmonics are the non-linear loads — the VFDs, the UPS systems, the DC drives, the switching power supplies, and the arc furnaces — that draw current in pulses rather than as a sine wave. The harmonics these loads produce flow back into the power system, where they distort the voltage, overload the neutrals, overheat the transformers, and trip the capacitors. IEEE 519 is the standard that defines the limits for harmonic distortion at the point of common coupling (PCC) — the point where the utility and the facility connect. Understanding the harmonic sources, the effects, and the mitigation is essential for maintaining a power system that supports the sensitive electronic loads of a modern industrial plant.

## Key Concepts

**Harmonic orders.** The harmonic order is the multiple of the fundamental. The 3rd harmonic is 180 Hz, the 5th is 300 Hz, the 7th is 420 Hz. In a 3-phase system, the 3rd and its multiples (the "triplens") are zero-sequence — they add up in the neutral rather than canceling. The 5th, 7th, 11th, and 13th are characteristic of 6-pulse rectifiers (the front end of most VFDs).

**Total Harmonic Distortion (THD).** The THD is the ratio of the RMS of the harmonic content to the RMS of the fundamental, expressed as a percentage. The current THD (THDi) and the voltage THD (THDv) are both measured. IEEE 519 limits the voltage THD at the PCC to 5% (with no individual harmonic above 3%) for a general distribution system.

**The PCC (Point of Common Coupling).** The PCC is the point where the utility and the facility connect — typically the main service entrance or the metering point. The IEEE 519 limits apply at the PCC, not at the individual loads. The harmonics produced by the loads are attenuated by the system impedance before they reach the PCC.

**The Isc/IL ratio.** IEEE 519 uses the ratio of the short-circuit current (Isc) at the PCC to the maximum demand load current (IL) to determine the allowed current distortion. A "stiff" system (high Isc/IL) allows more current distortion because the voltage distortion is lower; a "weak" system (low Isc/IL) allows less.

**Sources of harmonics.** The primary sources are 6-pulse rectifiers (VFDs, UPS, DC drives), which produce 5th, 7th, 11th, 13th harmonics; switching power supplies (computers, PLCs), which produce 3rd harmonics; and arc furnaces and welding, which produce a broad spectrum. The harmonic spectrum of a 6-pulse rectifier has characteristic harmonics at 6k±1 (5, 7, 11, 13, 17, 19...).

**Effects of harmonics.** Harmonics distort the voltage (which can cause motors to overheat and electronics to malfunction), overload the neutrals (the 3rd harmonic adds in the neutral and can exceed the phase current), overheat the transformers (the eddy current losses increase with the square of the frequency), and trip the power factor correction capacitors (the harmonics can resonate with the capacitors and produce overvoltages).

## Step-by-Step

1. **Identify the non-linear loads.** Inventory the non-linear loads in the facility: the VFDs, the UPS, the DC drives, the switching power supplies, and the arc furnaces. Record the size and the quantity. This is the harmonic source inventory.
2. **Measure the harmonics at the PCC.** Use a power quality analyzer to measure the voltage and current THD at the PCC (the main service entrance). Record the THDv, the THDi, and the individual harmonic spectrum. The measurement is the baseline for the compliance assessment.
3. **Compare to the IEEE 519 limits.** Calculate the Isc/IL ratio at the PCC (from the utility short-circuit data and the facility demand). Use the IEEE 519 table to determine the allowed current distortion for the ratio. Compare the measured THDv and THDi to the limits.
4. **If the harmonics exceed the limits, identify the sources.** Use the harmonic spectrum to identify the sources. A 5th and 7th dominant spectrum indicates a 6-pulse rectifier (VFDs). A 3rd dominant spectrum indicates switching power supplies. The spectrum guides the mitigation.
5. **Select the mitigation.** For a 6-pulse rectifier, the mitigation options: a 12-pulse or 18-pulse rectifier (which cancels the 5th and 7th harmonics), a passive harmonic filter (which traps the 5th or 7th harmonic), an active harmonic filter (which injects the opposite of the harmonic to cancel it), or a line reactor (which reduces the harmonics but does not eliminate them). For switching power supplies, a neutral harmonic filter or a K-rated transformer.
6. **Verify the mitigation.** After the mitigation is installed, re-measure the harmonics at the PCC and verify the limits are met. The verification is the confirmation that the mitigation is effective.
7. **Document the study.** Record the harmonic sources, the measurements, the IEEE 519 compliance assessment, the mitigation, and the verification. The documentation is the basis for the utility compliance and for future modifications.

## Common Problems and Fixes

**Neutral conductor overheating.** The 3rd harmonic from the switching power supplies adds in the neutral and can exceed the phase current. The fix is a larger neutral conductor (sized for the harmonic load) or a neutral harmonic filter (which traps the 3rd harmonic) or a K-rated transformer (which has a neutral sized for the harmonics).

**Transformer overheating.** The eddy current losses in the transformer increase with the square of the frequency, so the harmonics cause disproportionate heating. The fix is a K-rated transformer (which is designed for the harmonic load) or a derating of the standard transformer (run at 80% of the nameplate for a typical harmonic load).

**Power factor correction capacitor failure.** The harmonics can resonate with the capacitor and produce overvoltages that fail the capacitor. The fix is a detuning reactor (an inductor in series with the capacitor that shifts the resonance above the harmonic frequencies) or the removal of the capacitor if the harmonic load is high.

**VFD produces high harmonics.** A 6-pulse VFD produces 5th and 7th harmonics. The fix is a line reactor (which reduces the harmonics by 30–50%), a 12-pulse or 18-pulse VFD (which cancels the 5th and 7th), or an active harmonic filter (which cancels the harmonics from multiple VFDs).

**IEEE 519 limit exceeded at the PCC.** The facility harmonics exceed the IEEE 519 limit at the PCC. The fix is a mitigation at the source (a 12-pulse VFD or a passive filter) or at the PCC (an active harmonic filter that cancels the harmonics from the whole facility).

## Best Practices and Field Tips

- Always measure the harmonics before and after a mitigation. A mitigation that is not verified may not be effective, and the measurement is the proof.
- Use a power quality analyzer that can measure up to the 50th harmonic. The lower harmonics (5th, 7th) are the most common, but the higher harmonics (11th, 13th) can also be significant.
- For a facility with many VFDs, consider an active harmonic filter at the PCC rather than a filter on each VFD. The active filter is more cost-effective for a large facility and is easier to maintain.
- Size the neutral conductor for the harmonics, not just for the phase current. In a facility with many switching power supplies, the neutral current can exceed the phase current due to the 3rd harmonic.
- Keep the power quality study in the facility documentation. The study is the baseline for future modifications and for the utility compliance.

## Safety Notes

- A power quality analyzer is connected to a live circuit. Use the correct meter category (CAT III or CAT IV) and the correct PPE for the circuit voltage and the available fault current.
- A power factor correction capacitor that has failed may have a stored charge. Discharge the capacitor (with a discharge resistor, not a short) before working on it.
- An active harmonic filter is a power electronic device that produces heat and has a DC bus. Treat it with the same safety discipline as a VFD: wait for the DC bus to discharge before opening the enclosure.
- A transformer that is overheating from harmonics can fail and produce a fire. Monitor the transformer temperature and derate or replace the transformer if the temperature is excessive.
- A harmonic resonance can produce overvoltages that are above the insulation rating of the equipment. Verify the system does not have a resonance at a harmonic frequency, and install detuning reactors if it does.' WHERE title = 'Harmonic Sources & IEEE 519 Limits' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Power Quality Basics';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Voltage sags, swells, and flicker are the most common power quality disturbances in an industrial power system, and they are the most disruptive to sensitive electronic loads. A voltage sag (a brief reduction in voltage) can trip a VFD, reset a PLC, or drop a contactor — and in a continuous process, a 100-millisecond sag can cause hours of downtime. A voltage swell (a brief increase in voltage) can damage insulation and trip overvoltage protection. Flicker (a repeated, small voltage variation) can cause visible lighting fluctuations that are a nuisance and, in some cases, a safety hazard (the stroboscopic effect on rotating machinery). Understanding the causes, the effects, and the mitigation of these disturbances is essential for maintaining a power system that supports a modern industrial plant.

## Key Concepts

**Voltage sag (dip).** A sag is a reduction in the RMS voltage to between 0.1 and 0.9 per unit, lasting 0.5 cycles to 1 minute. The most common cause is a fault on the utility system or a fault within the facility (a short circuit that draws high current and depresses the voltage until the protection clears). A sag to 0.7 per unit for 6 cycles (0.1 seconds) can trip a VFD or reset a PLC.

**Voltage swell.** A swell is an increase in the RMS voltage to between 1.1 and 1.8 per unit, lasting 0.5 cycles to 1 minute. The most common cause is the switching off of a large load (the voltage rises when the load is removed) or a single-phase fault on a grounded system (the voltage on the unfaulted phases rises). A swell to 1.3 per unit can damage insulation and trip overvoltage protection.

**Flicker.** Flicker is a repeated, small voltage variation (typically 0.5–6% of the nominal voltage) that causes a visible lighting fluctuation. The most common cause is a rapidly cycling load (a welding machine, a large motor that starts frequently, an arc furnace). The flicker is measured with a flickermeter (per IEC 61000-4-15) and is expressed as the short-term flicker (Pst) and the long-term flicker (Plt). A Pst above 1.0 is the threshold of perception.

**The ITIC (CBEMA) curve.** The ITIC curve (the successor to the CBEMA curve) defines the voltage tolerance of information technology equipment. The curve shows the voltage magnitude and the duration that the equipment can tolerate. A sag above the curve is tolerated; a sag below the curve trips the equipment. The curve is the reference for the susceptibility of electronic loads to voltage disturbances.

**Ride-through.** The ride-through is the ability of a load to tolerate a voltage sag without tripping. A VFD with a ride-through of 0.7 per unit for 0.5 seconds can tolerate a sag to 0.7 for 0.5 seconds. The ride-through is a function of the internal capacitors (which hold up the DC bus) and the control logic. A UPS provides an infinite ride-through (it supplies the load from the battery during the sag).

**Causes of sags and swells.** Utility sags are caused by faults on the utility system (a lightning strike, a tree on a line, an animal contact) and by the starting of large motors on the feeder. Facility sags are caused by the starting of large motors (the inrush depresses the voltage) and by faults within the facility. Swells are caused by the switching of large loads and by single-phase faults.

## Step-by-Step

1. **Monitor the voltage.** Install a power quality analyzer at the main service entrance and at the sensitive loads. Monitor the voltage magnitude, the duration, and the frequency of sags, swells, and flicker over a representative period (at least a week, preferably a month).
2. **Identify the events.** From the monitoring data, identify the sags, swells, and flicker events. Record the magnitude, the duration, and the time of each event. Correlate the events with the facility operations (a motor start, a fault, a utility event) to identify the cause.
3. **Compare to the ITIC curve.** Plot the events on the ITIC curve. Events below the curve are likely to trip the equipment; events above are tolerated. The curve identifies the events that need mitigation.
4. **Identify the cause.** For each event that needs mitigation, identify the cause: a utility fault (contact the utility for a solution), a motor start (add a soft starter or a VFD), a fault within the facility (improve the protection coordination), or a rapidly cycling load (add a static var compensator or a filter).
5. **Select the mitigation.** For a sag that trips a sensitive load, the mitigation options: a UPS (which provides complete ride-through), a voltage regulator (which corrects small sags), a flywheel or a supercapacitor (which provides ride-through for short sags), or a VFD with a ride-through function. For flicker, a static var compensator or a larger transformer. For swells, a surge protector or a voltage regulator.
6. **Verify the mitigation.** After the mitigation is installed, re-monitor the voltage and verify the events are reduced or eliminated. The verification is the confirmation that the mitigation is effective.
7. **Document the study.** Record the monitoring data, the events, the ITIC comparison, the causes, the mitigation, and the verification. The documentation is the basis for the ongoing power quality management.

## Common Problems and Fixes

**VFD trips on a voltage sag.** The sag drops the DC bus voltage below the VFD''s trip level. The fix is a VFD with a ride-through function (which holds the output during the sag), a UPS on the VFD input, or a larger DC bus capacitor (which holds the voltage longer). If the sags are frequent, contact the utility to improve the supply.

**PLC resets on a voltage sag.** The sag drops the PLC power supply below the reset level. The fix is a UPS on the PLC power supply, which provides ride-through for any sag. A small UPS (500 VA) is adequate for a PLC.

**Lighting flickers when a large motor starts.** The motor inrush depresses the voltage, which causes the lighting to flicker. The fix is a soft starter or a VFD on the motor (which reduces the inrush), or a larger transformer (which reduces the voltage drop), or a separate feeder for the lighting (which isolates it from the motor inrush).

**Equipment damaged by a voltage swell.** The swell exceeds the insulation rating or the overvoltage trip level. The fix is a surge protector (which clamps the swell), a voltage regulator (which corrects the swell), or an investigation of the cause (a single-phase fault, a load switching event).

**Flicker above the perception threshold.** The flicker from a rapidly cycling load is above the Pst of 1.0. The fix is a static var compensator (which compensates the reactive power swings), a larger supply transformer (which reduces the voltage variation), or a change in the load cycle (if possible).

## Best Practices and Field Tips

- Always monitor the power quality before and after a mitigation. The monitoring is the proof that the mitigation is effective, and it is the baseline for future assessments.
- Use a power quality analyzer that can capture sags, swells, and flicker (not just harmonics). The analyzer should record the waveform, the magnitude, the duration, and the time of each event.
- For a sensitive load that trips on sags, a small UPS is the most cost-effective mitigation. The UPS provides complete ride-through for any sag, and it also provides protection from swells and outages.
- For a facility with many sensitive loads, consider a facility-wide UPS or a flywheel that provides ride-through for the entire facility. The cost is higher, but the protection is comprehensive.
- Keep the power quality monitoring data in the facility documentation. The data is the baseline for future assessments and for the utility compliance.

## Safety Notes

- A power quality analyzer is connected to a live circuit. Use the correct meter category and the correct PPE for the circuit voltage and the available fault current.
- A voltage swell can damage equipment insulation and can cause a fault. Verify the surge protection is installed and functional on sensitive equipment.
- A UPS that is providing ride-through can keep a circuit energized after the utility power is removed. Treat the UPS output as a live source, and follow the lockout procedure for the UPS input and the UPS bypass.
- A static var compensator is a power electronic device with a DC bus and capacitors. Treat it with the same safety discipline as a VFD: wait for the DC bus to discharge before opening the enclosure.
- Flicker can cause a stroboscopic effect on rotating machinery, which can make a spinning shaft appear stationary. This is a safety hazard (a worker may try to touch a shaft that appears to be stopped). Verify the flicker is corrected in areas with rotating machinery.' WHERE title = 'Voltage Sags, Swells & Flicker' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Power Quality Basics';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Power factor is the ratio of the real power (the power that does work, in kW) to the apparent power (the power that is delivered, in kVA). A power factor of 1.0 means all the delivered power does work; a power factor of 0.7 means only 70% of the delivered power does work, and the rest is reactive power that oscillates between the source and the load. A low power factor is costly (the utility charges for the reactive power, or charges a penalty for a power factor below a threshold) and it limits the capacity of the electrical system (the transformers and the conductors carry the reactive power in addition to the real power). Power factor correction is the installation of capacitors or other devices that supply the reactive power locally, so the source does not have to supply it. This lesson covers the power factor calculation, the correction methods, and the mitigation of the problems that correction can introduce (harmonic resonance and overcorrection).

## Key Concepts

**Real, reactive, and apparent power.** Real power (P, in kW) is the power that does work. Reactive power (Q, in kVAR) is the power that oscillates between the source and the load (the energy stored in the magnetic fields of motors and transformers). Apparent power (S, in kVA) is the vector sum: S = √(P² + Q²). The power factor is P/S = cos(θ), where θ is the angle between P and S.

**Leading and lagging power factor.** An inductive load (a motor, a transformer) has a lagging power factor (the current lags the voltage). A capacitive load (a power factor correction capacitor) has a leading power factor (the current leads the voltage). The correction capacitor supplies the reactive power that the inductive load needs, so the source does not have to supply it.

**The power factor correction calculation.** The required capacitor kVAR is: Qc = P × (tan(θ1) - tan(θ2)), where P is the real power, θ1 is the initial power factor angle, and θ2 is the target power factor angle. For a 100 kW load at 0.7 PF corrected to 0.95 PF, the required capacitor is about 67 kVAR.

**Correction methods.** The correction can be at the load (a capacitor at each motor, which corrects the power factor only when the motor runs), at the distribution panel (a capacitor bank at the panel, which corrects the power factor for the panel), or at the main service (a capacitor bank at the main, which corrects the power factor for the facility). The choice depends on the load pattern and the cost.

**Automatic vs fixed correction.** A fixed capacitor is always connected (which can overcorrect when the load is low). An automatic capacitor (a capacitor bank with a controller that switches capacitors in and out based on the measured power factor) matches the correction to the load. The automatic bank is more expensive but avoids the overcorrection.

**Harmonic resonance.** A power factor correction capacitor can resonate with the system inductance at a harmonic frequency. The resonance amplifies the harmonic voltage and can cause overvoltages that damage the capacitor and the equipment. The fix is a detuning reactor (an inductor in series with the capacitor that shifts the resonance above the harmonic frequencies).

**Overcorrection.** A capacitor that is too large for the load can produce a leading power factor, which can cause overvoltages (the capacitor raises the voltage) and can trip the overvoltage protection. The fix is an automatic capacitor that matches the correction to the load, or a smaller fixed capacitor.

## Step-by-Step

1. **Measure the power factor.** Use a power quality analyzer or a power meter to measure the real power (kW), the reactive power (kVAR), the apparent power (kVA), and the power factor at the main service and at the major distribution panels. Record the values at the peak load and at the low load.
2. **Calculate the required correction.** For the target power factor (typically 0.95), calculate the required capacitor kVAR: Qc = P × (tan(θ1) - tan(θ2)). Use the real power at the peak load for the calculation.
3. **Select the correction method.** For a facility with a consistent load, a fixed capacitor at the main service may be adequate. For a facility with a variable load, an automatic capacitor at the main service or at the major panels. For a facility with many large motors, correction at each motor (which corrects the power factor and reduces the conductor losses).
4. **Check for harmonic resonance.** Calculate the resonant frequency of the capacitor and the system inductance: f_r = f_1 × √(S_sc / Q_c), where f_1 is the fundamental frequency, S_sc is the short-circuit capacity at the capacitor, and Q_c is the capacitor kVAR. If the resonant frequency is near a harmonic frequency (the 5th, 7th, 11th), install a detuning reactor.
5. **Install the correction.** Install the capacitor bank at the selected location, with the correct overcurrent protection and the correct switching (a contactor for an automatic bank). For a motor correction, install the capacitor after the motor contactor (so the capacitor is switched with the motor) and verify the motor does not self-excite (a motor with a capacitor can generate voltage after the power is removed).
6. **Verify the correction.** After the installation, re-measure the power factor and verify it is at the target. Verify the voltage is not excessive (overcorrection can raise the voltage). Verify the capacitor current is within the rating.
7. **Document the installation.** Record the measured power factor, the correction calculation, the capacitor kVAR, the installation location, and the verification. The documentation is the basis for the utility billing and for future modifications.

## Common Problems and Fixes

**Power factor penalty from the utility.** The utility charges a penalty for a power factor below the threshold (typically 0.9). The fix is the power factor correction to bring the power factor above the threshold. The correction cost is typically paid back in 1–2 years from the penalty savings.

**Capacitor fails from harmonic resonance.** The capacitor resonates with the system inductance at a harmonic frequency, which overvoltages the capacitor. The fix is a detuning reactor (which shifts the resonance above the harmonic frequencies) or the removal of the capacitor if the harmonic load is high.

**Overcorrection causes overvoltage.** The capacitor is too large for the low-load condition, which produces a leading power factor and raises the voltage. The fix is an automatic capacitor (which switches capacitors out at low load) or a smaller fixed capacitor.

**Motor self-excites after disconnection.** A motor with a correction capacitor can generate voltage after the power is removed (the capacitor provides the excitation and the residual magnetism provides the field). The fix is a capacitor that is sized no more than the motor''s magnetizing kVAR (typically 80% of the no-load kVAR), or a discharge resistor that drains the capacitor.

**Capacitor switch contacts weld.** The capacitor inrush (which can be 100 times the rated current) welds the switch contacts. The fix is a switch or a contactor that is rated for capacitor duty (with a making current rating that exceeds the capacitor inrush).

## Best Practices and Field Tips

- Always measure the power factor at the peak load and at the low load before sizing the correction. A correction that is sized for the peak load can overcorrect at the low load.
- Use an automatic capacitor for a facility with a variable load. The automatic bank matches the correction to the load and avoids the overcorrection.
- Install a detuning reactor on every power factor correction capacitor in a facility with harmonic loads (VFDs, UPS). The reactor prevents the harmonic resonance and protects the capacitor.
- For motor correction, size the capacitor no more than the motor''s no-load kVAR (to avoid the self-excitation). The no-load kVAR is typically 30–40% of the motor''s full-load kVA.
- Keep the power factor study and the correction calculation in the facility documentation. The study is the basis for the utility billing and for future modifications.

## Safety Notes

- A power factor correction capacitor stores a charge after it is disconnected. Discharge the capacitor (with a discharge resistor, not a short) before working on it. A charged capacitor can deliver a lethal shock.
- A capacitor that has failed from harmonic resonance can be swollen or leaking. Do not touch a swollen or leaking capacitor — it can rupture and scatter electrolyte.
- A motor with a correction capacitor can generate voltage after the power is removed (the self-excitation). Verify the motor is de-energized (with a voltmeter at the motor terminals) before working on it, even after the disconnect is opened.
- A capacitor bank with a controller has a DC power supply and a stored charge. De-energize the bank and wait for the discharge before opening the controller enclosure.
- When switching a capacitor bank, the inrush can produce a significant arc. Use a switch or a contactor that is rated for capacitor duty, and keep the enclosure closed during the switching.' WHERE title = 'Power Factor Correction & Mitigation' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Temporary Power & Construction Electrical';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Temporary power on a construction site is a unique electrical environment — it is installed quickly, used by multiple trades, exposed to weather and physical damage, and it changes as the construction progresses. The safety of the workers depends on the correct installation and the correct use of the temporary power system, and the regulatory requirements (OSHA 1926 Subpart K and NEC Article 590) are specific to the construction environment. The GFCI protection, the spider boxes (portable power distribution), and the generator sizing are the three areas that produce the most injuries and the most citations on a construction site. This lesson covers the GFCI requirements, the spider box use, and the generator sizing for a safe and compliant temporary power system.

## Key Concepts

**GFCI (Ground Fault Circuit Interrupter).** A GFCI is a device that detects a ground fault (a current imbalance between the hot and the neutral) and trips in less than 1/40 of a second. OSHA 1926.404(b)(1) requires GFCI protection on all 120V, 15A and 20A receptacles on a construction site. The GFCI protects the workers from shock by tripping before the fault current reaches a lethal level. NEC 590.6 requires GFCI on all temporary receptacles.

**Spider boxes (portable power distribution boxes).** A spider box is a portable power distribution box with multiple receptacles, designed for construction use. It is fed by a generator or a temporary service and distributes power to the tools. The spider box must be listed for the use, must have GFCI protection on all receptacles, and must be protected from physical damage. The cables feeding the spider box and the cords from the spider box to the tools must be rated for the environment (SOOW or equivalent).

**Generator sizing.** A generator on a construction site must be sized for the load (the tools and the equipment) and for the starting inrush of any motors (compressors, saws). The generator kW must exceed the sum of the running loads plus the largest motor inrush. A generator that is too small will sag the voltage on the motor start, which can trip the motor or stall the generator.

**OSHA 1926 Subpart K.** The OSHA standard for electrical safety on a construction site. It covers the installation, the use, the GFCI, the grounding, the overcurrent protection, and the wiring methods for temporary power. The standard is enforced by OSHA inspectors and is the basis for citations.

**NEC Article 590.** The NEC article for temporary installations. It covers the wiring methods, the GFCI, the grounding, and the time limit for temporary installations (the duration of the construction, the remodeling, or the emergency). The NEC is the installation standard; the OSHA is the use standard.

**Grounding of temporary power.** The grounding of a temporary power system is critical for the GFCI to function. The GFCI detects the imbalance between the hot and the neutral, which requires the neutral to be bonded to the ground at the source (the generator or the service). A generator that is not bonded will not allow the GFCI to function correctly.

## Step-by-Step

1. **Plan the temporary power.** Before the construction starts, plan the temporary power: the source (a temporary service or a generator), the distribution (the spider boxes and the cables), and the loads (the tools and the equipment). The plan should cover the entire construction sequence, not just the first phase.
2. **Install the temporary service.** If the source is a temporary service, install it per NEC 590 and the local utility requirements. The service must have a disconnect, an overcurrent protection, a grounding electrode, and GFCI on all receptacles. The service must be inspected before it is energized.
3. **Select the generator.** If the source is a generator, size it for the load and the inrush: the generator kW must exceed the sum of the running loads plus the largest motor inrush. For a construction site with a 2 HP compressor (15A inrush), a 5 kW generator is the minimum; a 7–10 kW generator is recommended.
4. **Distribute the power with spider boxes.** Use listed spider boxes with GFCI on all receptacles. Place the spider boxes close to the work to keep the cord lengths short (long cords have voltage drop and are a trip hazard). Do not daisy-chain spider boxes (connecting one to another), which can overload the first box.
5. **Use the correct cords.** Use SOOW or equivalent cords (oil-resistant, weather-resistant, flexible) for all temporary power. Do not use extension cords with household indoor ratings. Inspect the cords daily for cuts and damage, and remove damaged cords from service.
6. **Verify the GFCI.** Test the GFCI on each spider box and each receptacle daily with the GFCI test button. A GFCI that does not trip on the test is defective and must be replaced. The test is the verification that the GFCI is functional.
7. **Inspect the system.** Inspect the temporary power system regularly (daily for the cords and the GFCI, weekly for the spider boxes and the generator). Remove any damaged or non-compliant equipment from service. Document the inspections.

## Common Problems and Fixes

**GFCI trips repeatedly.** The GFCI is detecting a ground fault in the load or in the cord. Find and fix the fault — do not bypass the GFCI. A common cause is water in a tool or a cord with a cut in the insulation. Replace the tool or the cord.

**Generator voltage sags on motor start.** The generator is too small for the motor inrush. Use a larger generator, or use a soft starter on the motor, or start the motor before the other loads are on (so the generator has the full capacity for the inrush).

**Spider box overloaded.** Too many tools on one spider box trip the overcurrent protection. Use a second spider box and split the load. Do not upsize the breaker on the spider box — the breaker is there to protect the box and the cords.

**Cord with a cut in the insulation.** A cord with a cut is a shock hazard and a fire hazard. Remove the cord from service immediately. Do not wrap the cut with tape (the tape can fail and expose the cut) — replace the cord.

**Generator not bonded to ground.** A generator that is not bonded to ground will not allow the GFCI to function correctly. Verify the generator has the neutral bonded to the frame (check the generator manual — some portable generators have a bonding jumper that must be installed). Without the bond, the GFCI cannot detect the imbalance.

## Best Practices and Field Tips

- Always test the GFCI on every spider box at the start of each shift. The test takes 5 seconds and confirms the GFCI is functional. A GFCI that is not tested may not trip when it is needed.
- Use the shortest cords possible. Long cords have voltage drop (which can cause tools to overheat) and are a trip hazard. Place the spider box close to the work.
- Inspect every cord daily before use. A cord that is cut, crushed, or has a damaged plug must be removed from service. Do not repair a cord with tape — replace it.
- Keep the generator in a well-ventilated area, away from the workers and away from the building. A generator in an enclosed space can produce carbon monoxide, which is a lethal hazard.
- Label the spider boxes with the source (the generator or the service) and the circuit number. A labeled spider box is easy to trace and easy to de-energize in an emergency.

## Safety Notes

- A GFCI that is bypassed or defective is a shock hazard. Never bypass a GFCI, and never use a receptacle with a GFCI that does not trip on the test. The GFCI is the primary shock protection on a construction site.
- A generator in an enclosed space can produce carbon monoxide, which is odorless and lethal. Always operate a generator outdoors, at least 20 feet from the building and the workers, and with the exhaust directed away from the work area.
- A cord with a cut in the insulation can energize any metal that touches the cut, including a wet floor or a metal ladder. Remove damaged cords from service immediately, and do not work with a cord that has a cut.
- A spider box that is overloaded can overheat and start a fire. Do not exceed the rated load of the spider box, and do not daisy-chain spider boxes. If the breaker trips, find the cause — do not reset it repeatedly.
- A temporary service that is not grounded will not allow the GFCI to function and will not clear a fault. Verify the grounding electrode and the neutral bond before energizing the service. An ungrounded temporary service is a shock and fire hazard.' WHERE title = 'GFCI, Spider Boxes & Generator Sizing' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Temporary Power & Construction Electrical';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

OSHA 1926 Subpart K is the federal safety standard for electrical work on a construction site, and NEC Article 590 is the installation standard for temporary electrical installations. Together, they define the requirements that keep construction workers safe from electrical hazards. The requirements are specific to the construction environment — the exposure to weather, the physical damage, the multiple trades, and the changing conditions — and they are enforced by OSHA inspectors who can issue citations and fines. For an industrial electrician doing construction work, or a construction electrician doing industrial work, the knowledge of Subpart K and Article 590 is the knowledge that keeps the site safe and the citations at zero. This lesson covers the key requirements of Subpart K and Article 590, the field decisions that produce a compliant temporary installation, and the inspection practices that catch the common violations.

## Key Concepts

**OSHA 1926 Subpart K scope.** Subpart K covers the electrical safety standards for construction work: the installation of temporary power, the use of electrical equipment, the grounding, the GFCI, the overcurrent protection, the wiring methods, the lighting, and the safety-related work practices. The standard is in 1926.400 through 1926.449.

**NEC Article 590 scope.** Article 590 covers the temporary electrical installations for construction, remodeling, maintenance, repair, demolition, and decorative lighting. The article allows the wiring methods and the materials that are specific to temporary installations, with a time limit (the duration of the project, or 90 days for decorative lighting).

**GFCI requirements.** OSHA 1926.404(b)(1) requires GFCI on all 125V, 15A, 20A, and 30A receptacles on a construction site. NEC 590.6 requires GFCI on all receptacles used for temporary installations. The GFCI can be a receptacle-type, a circuit-breaker-type, or a portable (inline) type. An "assured equipment grounding conductor program" is an alternative to GFCI on a construction site, but it is rarely used because the GFCI is simpler and more reliable.

**Grounding requirements.** The temporary power system must be grounded: the neutral must be bonded to the ground at the source (the service or the generator), and the equipment grounding conductor must be continuous from the source to the tools. A system that is not grounded will not allow the GFCI to function and will not clear a fault.

**Wiring methods.** NEC 590.4 allows the wiring methods for temporary installations: flexible cords and cables (SOOW or equivalent), nonmetallic-sheathed cable (NM, but only in buildings and not in wet locations), and metal-clad cable (MC). The wiring must be protected from physical damage, and the cords must be rated for the environment.

**Cord and cable requirements.** The cords for temporary power must be rated for the environment: SOOW (oil-resistant, weather-resistant) for outdoor and wet locations, SJOOW for lighter duty. The cords must be inspected daily for damage, and damaged cords must be removed from service. The cords must be continuous (no splices) except for a single splice that is made with a listed splice kit.

**Lighting.** NEC 590.10 requires the temporary lighting to be protected from physical damage (the lamps must be guarded), and the lighting must be rated for the environment (wet-location rated for outdoor and wet indoor locations). The lighting must not be hung from the cords (the cords are not designed to support the weight).

## Step-by-Step

1. **Plan the temporary power per Article 590.** Before the construction starts, plan the temporary power: the source, the distribution, the wiring methods, and the GFCI. The plan must meet the Article 590 requirements for the wiring methods and the GFCI, and the OSHA requirements for the use.
2. **Install the temporary power.** Install the temporary service or the generator per the plan. Use the Article 590 wiring methods (SOOW cords, listed spider boxes, GFCI on all receptacles). Bond the neutral to the ground at the source, and verify the equipment grounding conductor is continuous.
3. **Verify the GFCI.** Test the GFCI on every receptacle with the test button. A GFCI that does not trip must be replaced. The test is the verification that the GFCI is functional and that the grounding is correct (a GFCI will not test correctly if the grounding is wrong).
4. **Inspect the cords.** Inspect every cord for cuts, abrasions, and damaged plugs. Remove any damaged cord from service. Do not use a cord with a splice (except a listed splice kit). Do not use a household extension cord (not rated for the construction environment).
5. **Protect the wiring from physical damage.** Run the cords where they will not be driven over, stepped on, or pinched. Use cord covers or elevated runs where the cords cross a walkway. Do not hang cords from pipes or ducts (the cords are not designed to be supported).
6. **Install the temporary lighting.** Install the lighting per NEC 590.10: with guarded lamps, wet-location rated for outdoor and wet indoor locations, and not hung from the cords. Verify the lighting is adequate for the task (per the OSHA illumination requirements).
7. **Document the installation.** Record the temporary power plan, the GFCI test results, the cord inspections, and the lighting installation. The documentation is the basis for the OSHA compliance and for the daily inspections.

## Common Problems and Fixes

**Receptacle without GFCI.** A receptacle on a construction site without GFCI is an OSHA violation and a shock hazard. Install a GFCI receptacle, a GFCI breaker, or a portable inline GFCI on every receptacle.

**Household extension cord on a construction site.** A household cord (not rated for the construction environment) is an OSHA violation and a fire hazard. Replace with an SOOW or equivalent cord rated for the construction environment.

**Cord with a cut or a splice.** A cord with a cut or a non-listed splice is an OSHA violation and a shock hazard. Remove the cord from service and replace it. Do not repair with tape.

**Generator without a bonded neutral.** A generator without a bonded neutral will not allow the GFCI to function. Install the bonding jumper on the generator (check the generator manual for the location of the jumper). Some portable generators have a switchable bond — verify it is in the bonded position.

**Lighting without guards.** A temporary light without a guard is an OSHA violation and a fire hazard (a broken lamp can ignite combustibles). Install a guard on every temporary light.

## Best Practices and Field Tips

- Keep a supply of portable inline GFCI adapters in the truck. A receptacle without GFCI is a common violation, and the inline adapter is a quick fix that brings the receptacle into compliance.
- Inspect the cords and the GFCI at the start of every shift. The inspection takes 5 minutes and catches the damage before it causes an injury. Document the inspection on the daily inspection log.
- Use listed spider boxes with built-in GFCI on all receptacles. The spider box is the most convenient and the most compliant way to distribute temporary power.
- Do not use a cord longer than 100 feet. Long cords have voltage drop that can cause tools to overheat and can trip the GFCI. Place the spider box close to the work.
- Label the temporary power system: the source, the circuits, and the GFCI locations. A labeled system is easy to inspect and easy to de-energize in an emergency.

## Safety Notes

- A GFCI that is bypassed or defective is a shock hazard. Never bypass a GFCI, and never use a receptacle with a GFCI that does not trip on the test. The GFCI is the primary shock protection on a construction site.
- A cord with a cut in the insulation can energize any metal that touches the cut, including a wet floor or a metal ladder. Remove damaged cords from service immediately.
- A temporary service that is not grounded will not allow the GFCI to function and will not clear a fault. Verify the grounding electrode and the neutral bond before energizing the service.
- A generator in an enclosed space can produce carbon monoxide, which is odorless and lethal. Always operate a generator outdoors, at least 20 feet from the building and the workers.
- A temporary light without a guard can break and ignite combustibles. Install a guard on every temporary light, and do not place lights near combustible materials.' WHERE title = 'OSHA 1926 Subpart K & Temporary Wiring Rules' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Electrical Safety Programs & NFPA 70E Application';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

NFPA 70E is the standard for electrical safety in the workplace, and it is the standard that OSHA uses to define what a "safe" electrical workplace looks like. The standard requires the employer to have an electrical safety program that includes the policies, the procedures, the training, the hazard analysis, the PPE, and the incident investigation. A safety program that is a binder on a shelf is not a program — it is a document. A real program is the set of practices that the electricians follow every day, the training that keeps them competent, and the culture that values safety over speed. This lesson covers the components of an NFPA 70E safety program, the implementation in an industrial facility, and the culture that makes the program effective.

## Key Concepts

**The electrical safety program.** NFPA 70E Article 110 requires the employer to implement a safety program that includes the policies and procedures for the electrical work, the hazard analysis (the arc-flash and the shock hazard), the PPE selection and use, the training, the job briefings, the incident investigation, and the audit of the program. The program must be documented, and it must be audited at least every 3 years.

**The hazard analysis.** The hazard analysis is the assessment of the arc-flash and the shock hazard for each piece of equipment. The arc-flash hazard is the incident energy (in cal/cm²) at a working distance, calculated per IEEE 1584 or from the arc-flash labels. The shock hazard is the voltage and the boundary (the limited approach boundary and the restricted approach boundary). The hazard analysis determines the PPE and the safe work practices.

**The arc-flash label.** The equipment must be labeled with the arc-flash hazard: the incident energy, the working distance, the PPE category, and the boundary. The label is the communication of the hazard to the worker. A piece of equipment without a label is a hazard that is not communicated.

**The energized work permit.** NFPA 70E requires an energized work permit for any work on energized equipment (above 50V) that is not diagnostic or troubleshooting. The permit documents the justification (why the work cannot be done de-energized), the hazard analysis, the PPE, the job briefing, and the approval. The permit is the process that makes the energized work a deliberate, documented decision, not a default.

**The lockout/tagout (LOTO).** NFPA 70E requires the lockout/tagout for any work on de-energized equipment. The LOTO is the process of isolating the energy, locking the disconnect, verifying the absence of voltage, and releasing the lock when the work is complete. The LOTO is the primary protection for the electrical worker.

**The job briefing.** NFPA 70E requires a job briefing before any electrical work. The briefing covers the hazards, the work procedures, the PPE, the emergency procedures, and the responsibilities. The briefing is the communication that ensures every worker knows the hazards and the plan.

## Step-by-Step

1. **Write the safety program.** Document the policies and the procedures for the electrical work: the LOTO, the energized work permit, the hazard analysis, the PPE, the training, the job briefings, and the incident investigation. The program must be specific to the facility and the equipment.
2. **Perform the hazard analysis.** For each piece of equipment, calculate or measure the arc-flash incident energy and the shock boundary. Install the arc-flash labels on the equipment. The analysis is the basis for the PPE and the safe work practices.
3. **Select and provide the PPE.** Based on the hazard analysis, select the PPE for each task: the arc-rated clothing (with a rating above the incident energy), the voltage-rated gloves (for the shock hazard), the face shield and the hood (for the arc-flash), and the hearing protection. Provide the PPE to the workers and train them in the use.
4. **Train the workers.** Train every electrical worker on the safety program, the hazard analysis, the PPE, the LOTO, the energized work permit, and the job briefings. The training must be classroom and hands-on, and it must be documented. The training is repeated at least every 3 years (or when the worker is assigned a new task).
5. **Implement the LOTO.** Implement the LOTO for every de-energized work. Verify the LOTO procedure is followed: the isolation, the lock, the verification of the absence of voltage, and the release. Audit the LOTO regularly.
6. **Implement the energized work permit.** Require the energized work permit for any work on energized equipment that is not diagnostic. The permit is the process that makes the energized work a deliberate decision, not a default. The permit is approved by the supervisor and the safety officer.
7. **Conduct the job briefings.** Require a job briefing before every electrical job. The briefing is documented on a briefing form that covers the hazards, the procedures, the PPE, the emergency procedures, and the responsibilities. The briefing is the communication that ensures the safety.
8. **Investigate the incidents.** Investigate every electrical incident (a shock, an arc flash, a near-miss) with a root cause analysis. The investigation is the learning that prevents the next incident. Document the investigation and the corrective actions.
9. **Audit the program.** Audit the safety program at least every 3 years. The audit verifies the program is implemented, the training is current, the hazard analysis is accurate, and the PPE is adequate. The audit is the continuous improvement of the program.

## Common Problems and Fixes

**Program is a document, not a practice.** The safety program is written but not followed. The fix is the implementation: the training, the audits, and the enforcement. A program that is not enforced is not a program.

**Hazard analysis not performed.** The arc-flash labels are missing or outdated. Perform the hazard analysis and install the labels. A piece of equipment without a label is a hazard that is not communicated.

**PPE not worn.** The PPE is provided but not worn, or not worn correctly. The fix is the training and the enforcement. A worker who does not wear the PPE is at risk, and the supervisor who does not enforce the PPE is responsible.

**Energized work without a permit.** The energized work is done without a permit, because "it''s faster" or "it''s always been done this way." The fix is the enforcement of the permit process. Energized work without a permit is a violation of the safety program and a risk to the worker.

**Job briefing not conducted.** The job briefing is skipped because "the job is simple" or "the crew has done it before." The fix is the enforcement of the briefing for every job. A job without a briefing is a job without the communication that ensures the safety.

## Best Practices and Field Tips

- Make the safety program a living document. Review and update it regularly, and involve the workers in the review. A program that is written by the workers is more likely to be followed than one that is written by the management.
- Keep the arc-flash labels current. The labels are the communication of the hazard, and an outdated label is a miscommunication. Update the labels when the equipment or the system changes.
- Provide the PPE that is comfortable and convenient. A PPE that is hot, heavy, or difficult to use will not be worn. Invest in the PPE that the workers will actually use.
- Make the job briefing a habit, not a formality. A 5-minute briefing at the start of the job is the most effective safety tool. A briefing that is a signature on a form is not a briefing.
- Investigate the near-misses, not just the injuries. A near-miss is a free lesson — it is an incident that did not produce an injury but could have. The investigation of the near-miss prevents the next injury.

## Safety Notes

- The electrical safety program is the employer''s responsibility, and the enforcement is the supervisor''s responsibility. A worker who is injured because the program was not enforced has a claim against the employer.
- The arc-flash hazard is real and can be fatal. The incident energy at a 480V switchgear can be 40 cal/cm² or more, which is fatal. The PPE and the boundaries are the protection, and they must be followed.
- The energized work permit is not a permission to work energized — it is a process that makes the energized work a deliberate, documented decision. If the work can be done de-energized, it must be done de-energized.
- The LOTO is the primary protection for the electrical worker. A worker who does not follow the LOTO is at risk of an energization while working. The LOTO must be followed for every de-energized job.
- The job briefing is the communication that ensures the safety. A job without a briefing is a job where the hazards and the plan are not communicated, and the risk is higher. The briefing must be conducted for every job.' WHERE title = 'Building an NFPA 70E Safety Program' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Electrical Safety Programs & NFPA 70E Application';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

The job briefing and the incident investigation are the two practices that connect the safety program to the daily work and the continuous improvement. The job briefing is the communication before the work that ensures every worker knows the hazards, the procedures, and the emergency plan. The incident investigation is the learning after an event (an injury, an arc flash, or a near-miss) that identifies the root cause and the corrective actions. Together, they are the practices that turn a safety program from a document into a culture. This lesson covers the job briefing process, the incident investigation process, and the integration of both with the NFPA 70E safety program.

## Key Concepts

**The job briefing.** NFPA 70E 110.1(G) requires a job briefing before any electrical work. The briefing covers the hazards (the arc-flash and the shock), the work procedures, the PPE, the emergency procedures, the energy sources, and the responsibilities. The briefing is conducted by the person in charge and is attended by all the workers on the job. The briefing is documented on a briefing form.

**The briefing levels.** NFPA 70E defines two briefing levels: a basic briefing (for routine work) and an enhanced briefing (for complex or high-risk work). The basic briefing covers the hazards and the procedures; the enhanced briefing includes a more detailed hazard analysis, a written job plan, and a more extensive PPE review.

**The incident investigation.** NFPA 70E 110.1(K) requires the investigation of every electrical incident (a shock, an arc flash, a near-miss). The investigation includes the root cause analysis (the 5 Whys or the fault tree), the contributing factors, the corrective actions, and the documentation. The investigation is the learning that prevents the next incident.

**The near-miss.** A near-miss is an incident that did not produce an injury but could have. A near-miss is a free lesson — it is an opportunity to learn and improve without the cost of an injury. The investigation of the near-miss is as important as the investigation of an injury, because the next incident with the same cause may not be a near-miss.

**The root cause analysis (RCA).** The RCA is the process that identifies the root cause of the incident — the condition that, if changed, would have prevented the incident. The RCA uses the 5 Whys, the fault tree, or the contributing factors analysis. The RCA is not complete until the root cause is actionable — a change in design, maintenance, or operation that prevents the next incident.

**The corrective action.** The corrective action is the change that eliminates the root cause. The action is assigned an owner and a due date, and it is tracked to completion. The corrective action is the output of the investigation, and it is the measure of the investigation''s effectiveness.

## Step-by-Step

1. **Conduct the job briefing.** Before the work starts, gather the crew and conduct the briefing. Cover the hazards (the arc-flash and the shock, from the hazard analysis and the labels), the work procedures (the step-by-step plan), the PPE (the arc-rated clothing, the gloves, the face shield), the emergency procedures (the location of the emergency disconnect, the first aid, the evacuation), the energy sources (the LOTO points), and the responsibilities (who does what). Document the briefing on the briefing form.
2. **Verify the briefing is understood.** Ask the crew to repeat the hazards and the procedures. A briefing that is not understood is not effective. If a worker does not understand, re-brief until they do.
3. **Perform the work per the briefing.** Follow the procedures and the PPE from the briefing. If the conditions change (a new hazard is discovered, the LOTO cannot be verified), stop the work and re-brief.
4. **Investigate any incident.** If an incident occurs (a shock, an arc flash, a near-miss), stop the work and secure the scene. Gather the evidence (the equipment, the PPE, the witnesses). Do not clean or discard the evidence.
5. **Perform the root cause analysis.** Use the 5 Whys or the fault tree to identify the root cause. Ask "why" repeatedly until the cause is actionable. Identify the contributing factors (the conditions that made the incident more likely or more severe).
6. **Define the corrective actions.** For each root cause, define the action that eliminates it. Assign an owner and a due date. The actions are tracked to completion.
7. **Document the investigation.** Record the incident, the evidence, the root cause, the contributing factors, the corrective actions, and the completion. The documentation is the basis for the trend analysis and the continuous improvement.
8. **Share the learning.** Share the investigation and the corrective actions with the other crews and the other facilities. A lesson learned on one job is a lesson that can prevent an incident on another job.

## Common Problems and Fixes

**Job briefing is a signature, not a communication.** The briefing form is signed but the hazards and the procedures are not discussed. The fix is the enforcement of the communication: the person in charge must cover the hazards and the procedures verbally, and the crew must confirm the understanding.

**Incident investigation stops at the physical cause.** "The worker touched the energized bus" is a physical cause, not a root cause. The root cause is the condition that allowed the worker to touch the bus (a missing LOTO, an inadequate PPE, a missing label). Continue the analysis to the root cause.

**Near-misses are not reported.** A near-miss that is not reported is a lesson that is not learned. The fix is the culture that encourages the reporting of the near-misses (no blame, no penalty) and the investigation of every near-miss.

**Corrective actions are not completed.** An investigation with corrective actions that are not completed is a wasted effort. The fix is the tracking: assign the owners, track the due dates, and verify the completion.

**Learning is not shared.** An investigation that is documented but not shared is a lesson that is learned by one crew but not by the others. The fix is the sharing: distribute the investigation to the other crews and the other facilities, and discuss the lessons in the safety meetings.

## Best Practices and Field Tips

- Make the job briefing a habit, not a formality. A 5-minute briefing at the start of the job is the most effective safety tool. A briefing that is a signature on a form is not a briefing.
- Use a briefing form that covers all the NFPA 70E requirements: the hazards, the procedures, the PPE, the emergency procedures, the energy sources, and the responsibilities. A complete form ensures nothing is missed.
- Investigate the near-misses with the same rigor as the injuries. A near-miss is a free lesson, and the investigation of the near-miss prevents the next injury.
- Share the investigation and the corrective actions with the other crews. A lesson learned on one job is a lesson that can prevent an incident on another job. The sharing is the multiplier of the learning.
- Track the corrective actions to completion. An investigation that produces corrective actions that are not completed is a wasted effort. The completion is the measure of the investigation''s effectiveness.

## Safety Notes

- The job briefing is the communication that ensures the safety. A job without a briefing is a job where the hazards and the plan are not communicated, and the risk is higher. The briefing must be conducted for every job.
- The incident investigation is the learning that prevents the next incident. An incident that is not investigated is a lesson that is not learned, and the same incident can recur. The investigation must be conducted for every incident.
- A near-miss is an incident that could have been an injury. Treat the near-miss with the same seriousness as the injury — the next incident with the same cause may not be a near-miss.
- The root cause analysis must go beyond the physical cause to the system cause. A physical cause ("the worker touched the bus") is not actionable; a system cause ("the LOTO was not followed because the procedure was unclear") is actionable and prevents the next incident.
- The corrective actions must be completed and verified. An investigation that produces corrective actions that are not completed is a wasted effort, and the same incident can recur. The completion is the measure of the investigation''s effectiveness.' WHERE title = 'Job Briefings & Incident Investigation' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Testing & Commissioning of Electrical Equipment';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

NETA (the International Electrical Testing Association) is the organization that defines the acceptance testing standards for electrical equipment in North America. The NETA Acceptance Testing Specifications (ATS) is the standard that specifies the tests, the procedures, and the acceptance criteria for new and modified electrical installations. For an industrial electrician, the NETA ATS is the reference for the commissioning of a new installation — the tests that verify the equipment is correctly installed and safe to energize. The NETA testing is typically performed by a NETA-accredited testing company, but the industrial electrician must understand the tests, the acceptance criteria, and the documentation to support the commissioning and the hand-off. This lesson covers the NETA ATS structure, the common tests, and the acceptance criteria for the major equipment types.

## Key Concepts

**NETA ATS structure.** The NETA ATS is organized by equipment type: switchgear, transformers, cables, motors, protective relays, circuit breakers, and more. Each section specifies the tests, the test procedures, and the acceptance criteria. The standard is updated every few years; the current edition is the reference for the commissioning.

**The test categories.** The NETA tests are categorized as: visual and mechanical inspections (the physical verification of the installation), electrical tests (the measurement of the electrical characteristics), and functional tests (the verification of the operation). The tests are performed in a specific order: the visual and mechanical first, then the electrical, then the functional.

**Acceptance criteria.** Each test has an acceptance criterion — the value or the condition that the equipment must meet to pass. The criteria are from the NETA ATS, the manufacturer''s specifications, or the industry standards. A test that does not meet the criterion is a failure, and the equipment must be corrected before it is energized.

**The test report.** The NETA testing is documented in a test report that includes the equipment, the tests, the test values, the acceptance criteria, and the pass/fail result. The test report is the documentation of the commissioning and is the basis for the acceptance of the installation.

**Certified test technicians.** The NETA testing is performed by NETA-certified technicians (Level I through Level IV) who have the training and the experience to perform the tests safely and correctly. The certification is the assurance of the quality of the testing.

**Safety during testing.** The NETA testing is performed on de-energized equipment (for the electrical tests) and on energized equipment (for the functional tests). The testing requires the same safety discipline as any electrical work: the LOTO, the PPE, and the job briefings.

## Step-by-Step

1. **Plan the testing.** Before the testing starts, plan the sequence: the equipment to be tested, the tests to be performed, the order, the safety measures, and the documentation. The plan is the basis for the testing and the coordination with the installation and the energization.
2. **Perform the visual and mechanical inspections.** For each piece of equipment, perform the visual inspection (the physical condition, the cleanliness, the labeling, the grounding) and the mechanical inspection (the operation of the moving parts, the torque of the connections, the alignment). Document the results.
3. **Perform the electrical tests.** For each piece of equipment, perform the electrical tests specified in the NETA ATS: the insulation resistance (megger), the contact resistance, the turns ratio, the overcurrent trip, the ground resistance. Document the test values and compare to the acceptance criteria.
4. **Perform the functional tests.** For each piece of equipment, perform the functional tests: the operation of the breakers, the relays, the interlocks, the alarms. Verify the equipment operates correctly per the design and the manufacturer''s specifications.
5. **Evaluate the results.** Compare the test values to the acceptance criteria. A test that does not meet the criterion is a failure — investigate the cause, correct the deficiency, and re-test. Do not energize the equipment with a failed test.
6. **Document the testing.** Produce the test report with the equipment, the tests, the test values, the acceptance criteria, and the pass/fail result. The test report is the documentation of the commissioning and the basis for the acceptance.
7. **Hand off the equipment.** After the testing is complete and the equipment passes, hand off the equipment to the owner with the test report, the as-built drawings, and the operation and maintenance manuals. The hand-off is the transition from the construction to the operation.

## Common Problems and Fixes

**Insulation resistance below the acceptance criterion.** The insulation is compromised (moisture, contamination, damage). Investigate the cause: clean and dry the equipment, or repair the damaged insulation. Re-test after the correction. A low insulation resistance can cause a fault when the equipment is energized.

**Contact resistance above the acceptance criterion.** The contact surfaces are oxidized, dirty, or not making good contact. Clean the contacts, tighten the connections, and re-test. A high contact resistance can overheat and fail.

**Overcurrent trip does not operate at the set point.** The trip device is out of calibration or damaged. Calibrate or replace the trip device, and re-test. A trip that does not operate at the set point can fail to clear a fault.

**Interlock does not function.** The interlock is misaligned, damaged, or wired incorrectly. Adjust, repair, or rewire the interlock, and re-test. An interlock that does not function can allow an unsafe operation (energizing a piece of equipment that is in an unsafe state).

**Ground resistance above the acceptance criterion.** The grounding system is not adequate (a high soil resistivity, a missing bond, a corroded electrode). Add electrodes, bond the connections, and re-test. A high ground resistance can prevent the fault protection from operating.

## Best Practices and Field Tips

- Always use the current edition of the NETA ATS as the reference for the testing. The acceptance criteria are updated with the standards, and an outdated criterion can lead to an incorrect pass or fail.
- Perform the tests in the order specified by the NETA ATS: visual and mechanical first, then electrical, then functional. A functional test on equipment that has not passed the electrical tests can be unsafe.
- Document every test value, not just the pass or fail. The test values are the baseline for the future maintenance testing, and a trend over time can detect a degradation before it fails.
- Use the correct test equipment for each test: a megohmmeter for the insulation resistance, a micro-ohmmeter for the contact resistance, a TTR for the turns ratio, a primary injection set for the overcurrent trip. The wrong test equipment can give a wrong result.
- Keep the test report in the facility documentation. The report is the baseline for the maintenance testing and the proof of the commissioning. A facility without the test report has no baseline for the future testing.

## Safety Notes

- The NETA testing is performed on de-energized equipment for the electrical tests, but the equipment may be energized for the functional tests. Follow the LOTO for the de-energized tests and the energized work procedures for the functional tests.
- A megohmmeter (megger) applies a high voltage (500–5000V) to the insulation. Do not touch the equipment during the test, and discharge the equipment after the test (the insulation can store a charge from the test voltage).
- A primary injection test applies a high current to the circuit. The test can produce an arc if the connection is loose. Verify the connections are tight before the test, and wear the arc-rated PPE.
- The testing may require the removal of covers and the access to live parts. Follow the safety procedures for the access: the LOTO, the PPE, and the job briefing.
- A piece of equipment that fails a NETA test may have a defect that can cause a fault when energized. Do not energize the equipment until the defect is corrected and the re-test passes. The NETA testing is the verification that the equipment is safe to energize.' WHERE title = 'NETA Acceptance Testing Overview' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;

DO $$
DECLARE c_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='electrical' AND title='Testing & Commissioning of Electrical Equipment';
  IF NOT FOUND THEN RETURN; END IF;
  UPDATE lessons SET content = '## Overview

Contact resistance, transformer turns ratio (TTR), and primary injection are three of the most fundamental and most informative tests in the NETA acceptance testing suite. The contact resistance test measures the resistance of the circuit breaker contacts and the bus connections — a high resistance indicates a poor connection that will overheat and fail. The TTR test measures the ratio of the transformer turns and verifies the winding is correct — a wrong ratio indicates a winding fault or a tap changer problem. The primary injection test injects a high current through the circuit breaker and verifies the trip unit operates at the set point — a trip that does not operate at the set point can fail to clear a fault. Together, these three tests verify the integrity of the connections, the windings, and the protection of the equipment. This lesson covers the test methods, the acceptance criteria, and the interpretation of the results for each test.

## Key Concepts

**Contact resistance (DLRO).** The contact resistance is measured with a micro-ohmmeter (a Digital Low Resistance Ohmmeter, or DLRO) that applies a high current (10–100A) through the contact and measures the voltage drop. The resistance is the voltage drop divided by the current. The test is performed on the circuit breaker contacts (pole to pole, and each pole individually) and on the bus connections (joint to joint). The acceptance criterion is typically less than 100 micro-ohms for a breaker contact, or a value within the manufacturer''s specification.

**The TTR (Transformer Turns Ratio) test.** The TTR test measures the ratio of the primary turns to the secondary turns of a transformer. The test applies a low AC voltage to the primary and measures the secondary voltage. The ratio is the primary voltage divided by the secondary voltage. The test is performed on each tap position and on each phase. The acceptance criterion is the ratio within 0.5% of the nameplate ratio. A ratio outside the criterion indicates a winding fault (a shorted turn, an open winding) or a tap changer problem.

**Primary injection.** The primary injection test injects a high current (hundreds to thousands of amps) through the circuit breaker and verifies the trip unit operates at the set point. The test is performed by connecting a primary injection set (a high-current, low-voltage transformer) to the breaker, injecting the current, and measuring the trip time. The test verifies the entire trip circuit — the CTs, the trip unit, and the trip mechanism — not just the electronic trip unit. The acceptance criterion is the trip time within the manufacturer''s tolerance for the set point.

**Secondary injection vs primary injection.** A secondary injection test applies a current to the trip unit (the secondary of the CT) and verifies the trip unit operates. The secondary injection does not test the CTs or the primary wiring. The primary injection tests the entire circuit, including the CTs and the primary wiring. The primary injection is the more comprehensive test and is the one required by the NETA ATS for the acceptance testing.

**Insulation resistance (megger).** The insulation resistance is measured with a megohmmeter that applies a high DC voltage (500–5000V) to the insulation and measures the leakage current. The resistance is the voltage divided by the current. The test is performed phase to ground and phase to phase. The acceptance criterion is typically 1 megohm per 1000V of rated voltage (for example, 1000 megohms for a 1000V rated cable), or a value within the manufacturer''s specification.

**Polarization Index (PI) and Dielectric Absorption Ratio (DAR).** The PI is the ratio of the insulation resistance at 10 minutes to the resistance at 1 minute. The DAR is the ratio at 60 seconds to 30 seconds. The PI and DAR are indicators of the insulation condition — a PI above 2.0 and a DAR above 1.4 indicate good insulation. A low PI or DAR indicates moisture or contamination in the insulation.

## Step-by-Step

1. **Perform the contact resistance test.** For each circuit breaker pole, connect the DLRO to the line and load terminals. Inject the test current (10–100A) and measure the voltage drop. Calculate the resistance. Compare to the acceptance criterion (less than 100 micro-ohms for a typical breaker, or the manufacturer''s specification). A resistance above the criterion indicates a poor contact — clean or replace the contact.
2. **Perform the TTR test.** For each transformer phase and each tap position, connect the TTR test set to the primary and the secondary. Apply the test voltage and measure the ratio. Compare to the nameplate ratio. The ratio must be within 0.5% of the nameplate. A ratio outside the criterion indicates a winding fault — investigate the winding and the tap changer.
3. **Perform the primary injection test.** For each circuit breaker pole, connect the primary injection set to the line and load terminals. Inject the test current (at the trip unit set point) and measure the trip time. Compare to the manufacturer''s trip curve. The trip time must be within the tolerance. A trip that does not operate at the set point indicates a trip unit or a mechanism problem — calibrate or replace the trip unit.
4. **Perform the insulation resistance test.** For each phase, connect the megohmmeter to the phase and ground (with the other phases grounded). Apply the test voltage (500V for low-voltage equipment, 1000–5000V for medium-voltage) for 1 minute. Record the resistance. Repeat for each phase and for phase to phase. Compare to the acceptance criterion. A resistance below the criterion indicates compromised insulation — clean, dry, or repair the insulation.
5. **Perform the PI and DAR tests.** For the insulation resistance test, record the resistance at 30 seconds, 60 seconds, and 10 minutes. Calculate the DAR (60s / 30s) and the PI (10min / 1min). A PI above 2.0 and a DAR above 1.4 indicate good insulation. A low PI or DAR indicates moisture or contamination — dry or clean the insulation and re-test.
6. **Document the results.** Record the equipment, the tests, the test values, the acceptance criteria, and the pass/fail result. The documentation is the basis for the acceptance and the baseline for the future maintenance testing.
7. **Evaluate the results.** Compare the test values to the acceptance criteria. A test that does not meet the criterion is a failure — investigate the cause, correct the deficiency, and re-test. Do not energize the equipment with a failed test.

## Common Problems and Fixes

**Contact resistance above the criterion.** The contact surfaces are oxidized, dirty, or not making good contact. Clean the contacts with a non-abrasive cleaner, tighten the connections, and re-test. If the resistance is still high, the contacts are worn — replace the breaker or the contacts.

**TTR outside the 0.5% criterion.** The winding has a fault (a shorted turn, an open winding) or the tap changer is in the wrong position. Verify the tap position, and re-test. If the ratio is still wrong, the winding has a fault — the transformer must be repaired or replaced.

**Primary injection trip time outside the tolerance.** The trip unit is out of calibration, the CT is saturated, or the mechanism is sluggish. Calibrate the trip unit, verify the CT ratio and saturation, and check the mechanism. Re-test after the correction.

**Insulation resistance below the criterion.** The insulation is compromised by moisture, contamination, or damage. Clean and dry the equipment, and re-test. If the resistance is still low, the insulation is damaged — repair or replace the equipment.

**PI or DAR below the criterion.** The insulation has absorbed moisture or contamination. Dry the insulation (with heat or with a dry-air purge), and re-test. If the PI or DAR is still low, the insulation is permanently degraded — repair or replace the equipment.

## Best Practices and Field Tips

- Always use the correct test equipment for each test: a DLRO for the contact resistance, a TTR test set for the turns ratio, a primary injection set for the overcurrent trip, and a megohmmeter for the insulation resistance. The wrong equipment can give a wrong result.
- Document every test value, not just the pass or fail. The test values are the baseline for the future maintenance testing, and a trend over time can detect a degradation before it fails.
- Perform the primary injection test, not just the secondary injection, for the acceptance testing. The primary injection tests the entire trip circuit, including the CTs and the primary wiring, which the secondary injection does not.
- For the insulation resistance test, record the 30-second, 60-second, and 10-minute values to calculate the DAR and the PI. The PI and DAR are more sensitive to the insulation condition than the 1-minute value alone.
- Keep the test report in the facility documentation. The report is the baseline for the maintenance testing and the proof of the commissioning. A facility without the test report has no baseline for the future testing.

## Safety Notes

- A megohmmeter applies a high DC voltage (500–5000V) to the insulation. Do not touch the equipment during the test, and discharge the equipment after the test (the insulation can store a charge from the test voltage). Use the megohmmeter''s discharge function or a discharge resistor.
- A primary injection test applies a high current (hundreds to thousands of amps) to the circuit. The test can produce an arc if a connection is loose. Verify the connections are tight before the test, and wear the arc-rated PPE.
- A DLRO applies a high current (10–100A) through the contact. The test can heat the contact if the current is applied for too long. Use the shortest test time that gives a stable reading, and do not touch the contact during the test.
- The testing may require the removal of covers and the access to live parts. Follow the safety procedures for the access: the LOTO, the PPE, and the job briefing.
- A piece of equipment that fails a test may have a defect that can cause a fault when energized. Do not energize the equipment until the defect is corrected and the re-test passes. The testing is the verification that the equipment is safe to energize.' WHERE title = 'Contact Resistance, TTR & Primary Injection' AND module_id IN (SELECT id FROM modules WHERE course_id = c_id);
END $$;
