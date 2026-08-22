-- ============================================================
-- PART 2: Add new modules + 2 lessons each for courses 2-5
-- ============================================================

-- Course 2: 3-Phase Power Systems & Troubleshooting — Add Module 3: Troubleshooting 3-Phase Systems
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = '3-Phase Power Systems & Troubleshooting' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;

  -- Only add if module doesn't already exist
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Troubleshooting 3-Phase Systems') THEN
    INSERT INTO modules (course_id, title, sort_order)
    VALUES (c_id, 'Troubleshooting 3-Phase Systems', 3)
    RETURNING id INTO m_id;

    -- Lesson 1: Diagnosing Single-Phasing Conditions
    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Diagnosing Single-Phasing Conditions',
      '## Overview

Single-phasing is the loss of one phase on a three-phase power system. It is one of the most common and damaging 3-phase faults. When one phase is lost, a three-phase motor continues to run (if already spinning) but draws excessive current on the remaining two phases, rapidly overheating the windings. A motor that is stopped will not start on single-phase power — it will hum and draw locked-rotor current.

## Key Concepts

- **Single-phasing causes**: Blown fuse, loose connection, broken conductor, failed contactor pole, or utility-side fault.
- **Current relationship**: When single-phasing occurs, the current on the two remaining lines increases to approximately 1.73 times normal full-load current.
- **Motor damage**: The windings on the two energized phases overheat while the third remains cool, creating uneven thermal stress.
- **Detection**: A clamp meter on each phase will show two phases with elevated current and one with zero. A voltmeter at the motor terminals shows normal phase-to-phase voltage on two pairs and zero on the third.
- **Protection**: Phase loss relays, motor protective relays, and overload relays with phase loss detection can disconnect the motor before damage occurs.

## Step-by-Step: Diagnosing Single-Phasing

1. **Safety first**: De-energize and lock out if possible. If the motor must be running to diagnose, wear appropriate PPE.
2. **Measure phase-to-phase voltage at the motor terminals**: Two pairs will read normal voltage, one pair will read near zero.
3. **Measure phase-to-phase voltage at the source (contactor/starter)**: If the source has all three phases but the motor does not, the problem is between the source and motor (contactor, cable, or connection).
4. **Check the contactor**: A burned or welded contactor pole is a common cause. Measure voltage across each pole — a failed pole will show voltage drop across it.
5. **Check upstream**: If the source is also missing a phase, trace upstream to the disconnect, breaker, and transformer.
6. **Check for blown fuses**: If fuses are used, check continuity on each fuse. A single blown fuse is the most common cause.
7. **Repair and verify**: Replace the fuse, contactor, or repair the connection. Verify all three phases are present before re-energizing the motor.

## Common Problems

- **Contactor pole failure**: One pole of a three-pole contactor burns or welds, interrupting one phase. This is the most frequent cause in industrial environments.
- **Loose lug connections**: A loose compression lug on one phase creates high resistance, eventually burning open.
- **Blown fuse**: One of three power fuses blows, leaving two phases energized.
- **Utility single-phase events**: A transient utility fault can momentarily drop one phase, which may not trip the main breaker but can damage motors.
- **Undersized overload relays**: If overload relays are set too high, they may not trip during single-phasing, allowing motor damage.

## Best Practices

- Install phase-loss / phase-reversal relays on all critical 3-phase motors.
- Use IEC overload relays with phase-loss detection (Class 10 or Class 20).
- Perform infrared scans of motor connections and contactors to detect early-stage degradation.
- Verify fuse ratings match the motor and coordination study — never oversize fuses.
- Document all single-phasing events and their root causes to identify systemic issues.

## Safety

- Never attempt to diagnose single-phasing on energized equipment without arc-rated PPE and an energized work permit.
- A motor that is humming and not starting may be single-phasing — de-energize immediately to prevent locked-rotor damage.
- After repair, verify proper phase rotation before returning the motor to service, especially for pumps and fans where reverse rotation can cause damage.
- Treat all conductors as energized until verified de-energized with a rated voltage tester.',
      45, true, true,
      '[
        {"question":"What is single-phasing?","options":["Loss of one phase on a 3-phase system","Loss of all three phases","A short between two phases","A ground fault"],"correctIndex":0},
        {"question":"What happens to current on the remaining phases when single-phasing occurs?","options":["It decreases","It stays the same","It increases to approximately 1.73 times normal","It goes to zero"],"correctIndex":2},
        {"question":"Will a stopped 3-phase motor start on single-phase power?","options":["Yes, normally","No, it will hum and draw locked-rotor current","Yes, but at half speed","Yes, but in reverse"],"correctIndex":1},
        {"question":"What is the most common cause of single-phasing in industrial environments?","options":["Utility power outages","Contactor pole failure","Motor bearing failure","Overloaded motor"],"correctIndex":1},
        {"question":"What will a voltmeter read across the two energized phases at the motor terminals during single-phasing?","options":["Zero volts","Normal phase-to-phase voltage","Half voltage","Double voltage"],"correctIndex":1},
        {"question":"What protective device can detect and disconnect a motor during single-phasing?","options":["A standard fuse","A phase-loss relay or overload relay with phase loss detection","A circuit breaker alone","A surge protector"],"correctIndex":1},
        {"question":"After repairing a single-phasing fault, what must be verified before returning the motor to service?","options":["Proper phase rotation","Motor temperature","Bearing lubrication","Cable tray fill"],"correctIndex":0}
      ]'::jsonb,
      80, 1);

    -- Lesson 2: Transformer Troubleshooting in 3-Phase Systems
    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Transformer Troubleshooting in 3-Phase Systems',
      '## Overview

Three-phase transformers are the backbone of industrial power distribution. Troubleshooting them requires understanding of transformer theory, connection configurations (wye-wye, delta-delta, wye-delta, delta-wye), and the specific failure modes that affect 3-phase units. A faulty transformer can cause voltage imbalances, circulating currents, and system-wide power quality issues.

## Key Concepts

- **Turns ratio**: The ratio of primary to secondary turns determines the voltage transformation. In a 3-phase transformer, the turns ratio and the connection type (wye vs delta) both affect the voltage transformation ratio.
- **Wye-Delta (Y-Δ) connections**: Step down voltage; the delta secondary has no neutral. Line voltage on the secondary equals phase voltage.
- **Delta-Wye (Δ-Y) connections**: Step up voltage or provide a neutral on the secondary for 277/480V distribution.
- **Circulating currents in delta**: A delta winding with unbalanced primary voltage will have circulating currents that can overheat the transformer even with no load.
- **TTR (Transformer Turns Ratio) test**: Measures the ratio of primary to secondary voltage to detect shorted turns or open windings.

## Step-by-Step: Troubleshooting a 3-Phase Transformer

1. **Visual inspection**: Check for oil leaks (on oil-filled units), discolored paint (indicating overheating), bulging tanks, and damaged bushings.
2. **Measure secondary voltage**: Check all three phase-to-phase and phase-to-neutral voltages. Unbalanced voltage indicates a problem.
3. **Perform a TTR test**: Use a TTR tester to measure the turns ratio on each phase. Compare to nameplate ratio. A deviation of more than 0.5% indicates a winding fault.
4. **Insulation resistance test**: Megger the windings (primary-to-ground, secondary-to-ground, primary-to-secondary). Compare readings to IEEE 43 minimums.
5. **Check for circulating currents**: On delta-connected windings, measure current in each phase with no load. Any current indicates voltage imbalance or a winding fault.
6. **Infrared scan**: Scan the transformer and connections under load. Hot spots on bushings or connections indicate loose connections; hot spots on the tank indicate internal winding issues.
7. **Oil analysis (if oil-filled)**: Perform a dissolved gas analysis (DGA) to detect internal arcing, corona, or overheating.

## Common Problems

- **Shorted turns**: A few shorted turns in one winding cause circulating currents, overheating, and voltage imbalance. TTR test detects this.
- **Open winding**: One phase winding opens, causing single-phasing on the secondary. Voltage readings show the fault.
- **Loose bushing connections**: High-resistance connections at the bushings cause localized heating, visible on infrared scan.
- **Core insulation breakdown**: Insulation between the core and frame degrades, causing stray currents and tank heating.
- **Tap changer failure**: A faulty tap changer causes voltage imbalance or intermittent operation.

## Best Practices

- Perform annual infrared scans of all transformer connections and tanks.
- Conduct DGA annually on oil-filled transformers and trend the results.
- Perform TTR and insulation resistance tests during scheduled maintenance outages.
- Keep transformer loading below 80% for normal operation to allow for peak demand and extend life.
- Verify that neutral grounding resistors (if used) are intact and properly rated.

## Safety

- Always de-energize and lock out a transformer before performing any hands-on testing.
- Oil-filled transformers may contain PCBs in older units — follow environmental protocols for oil handling.
- Never approach a transformer tank that is bulging, hissing, or showing signs of internal pressure — it may be arcing internally and could rupture.
- After de-energizing, wait for the windings to discharge before touching — large transformers can store capacitive energy.
- Ground all windings before performing insulation tests, and discharge after testing.',
      50, true, true,
      '[
        {"question":"What does a TTR test measure?","options":["Insulation resistance","The ratio of primary to secondary voltage (turns ratio)","Transformer oil quality","Load current"],"correctIndex":1},
        {"question":"What deviation in TTR indicates a winding fault?","options":["More than 5%","More than 0.5%","More than 10%","Any deviation"],"correctIndex":1},
        {"question":"What causes circulating currents in a delta-connected transformer winding?","options":["Overloading","Unbalanced primary voltage or shorted turns","Low oil level","High ambient temperature"],"correctIndex":1},
        {"question":"What does a dissolved gas analysis (DGA) detect?","options":["Insulation resistance","Internal arcing, corona, or overheating in oil-filled transformers","Turns ratio","Power factor"],"correctIndex":1},
        {"question":"What does a hot spot on a transformer bushing connection indicate during an infrared scan?","options":["Normal operation","A loose connection with high resistance","Overloading","Low oil level"],"correctIndex":1},
        {"question":"What should you do if you find a transformer tank that is bulging or hissing?","options":["Approach and inspect it","Do not approach — it may be arcing internally and could rupture","Reduce the load","Tighten the bolts"],"correctIndex":1},
        {"question":"What is the recommended maximum loading for normal transformer operation?","options":["50%","80%","100%","120%"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 3: VFD Fundamentals & Parameterization — Add Module 3: VFD Energy & Harmonics
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'VFD Fundamentals & Parameterization' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;

  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'VFD Energy & Harmonics') THEN
    INSERT INTO modules (course_id, title, sort_order)
    VALUES (c_id, 'VFD Energy & Harmonics', 3)
    RETURNING id INTO m_id;

    -- Lesson 1: Harmonic Distortion from VFDs
    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Harmonic Distortion from VFDs',
      '## Overview

VFDs are nonlinear loads — they draw current in short pulses rather than sinusoidal waveforms. This creates harmonic currents that flow back into the power system, distorting the voltage waveform and causing problems for other equipment. Understanding harmonics is essential for VFD applications in industrial facilities, especially when multiple drives are installed.

## Key Concepts

- **6-pulse rectifier harmonics**: A standard 6-pulse VFD produces characteristic harmonics at 5th, 7th, 11th, 13th, and higher orders. The 5th harmonic is typically the largest.
- **Total Harmonic Distortion (THD)**: The ratio of all harmonic content to the fundamental frequency, expressed as a percentage. IEEE 519 recommends voltage THD below 5% at the point of common coupling (PCC).
- **True Power Factor vs Displacement PF**: VFDs have a displacement PF near 0.95 but a true PF that may be much lower due to harmonic distortion.
- **Line reactors**: Adding a 3% or 5% impedance line reactor at the VFD input reduces harmonic current distortion and protects the drive from transients.
- **12-pulse and 18-pulse drives**: Using multi-pulse rectifier configurations dramatically reduces low-order harmonics by canceling them through phase-shifting transformers.

## Step-by-Step: Assessing and Mitigating VFD Harmonics

1. **Identify the Point of Common Coupling (PCC)**: This is where the utility and facility share the bus — typically the main service entrance.
2. **Measure harmonic spectrum**: Use a power quality analyzer to measure current and voltage THD at the PCC and at each VFD.
3. **Compare to IEEE 519 limits**: Voltage THD should be below 5% at the PCC; current TDD (Total Demand Distortion) limits depend on the short-circuit ratio.
4. **Add line reactors**: If not already installed, add 3% or 5% impedance line reactors to each VFD. This is the simplest and most cost-effective mitigation.
5. **Consider a DC link choke**: Some VFDs have built-in DC bus chokes that reduce harmonics similarly to line reactors.
6. **Evaluate multi-pulse drives**: For large drives (>100 HP), consider 12-pulse or 18-pulse drives that cancel harmonics through phase shifting.
7. **Consider active front-end (AFE) drives**: AFE drives use IGBT-based rectifiers that draw near-sinusoidal current, virtually eliminating low-order harmonics.
8. **Verify mitigation effectiveness**: After installation, re-measure THD at the PCC to confirm compliance with IEEE 519.

## Common Problems

- **Overheated neutral conductors**: In wye systems with many VFDs, triplen harmonics (3rd, 9th) can add up in the neutral, causing overheating.
- **Transformer overheating**: Harmonic currents cause eddy current losses in transformers, reducing their effective capacity. Transformers feeding VFD loads may need K-factor ratings.
- **Nuisance tripping of breakers**: Harmonic currents can cause true RMS-sensitive breakers to trip even when the fundamental current is within rating.
- **Capacitor bank failures**: Harmonics can resonate with power factor correction capacitors, causing overvoltage and capacitor failure.
- **Telephone interference**: Harmonic currents on power lines can induce noise in nearby communication circuits (ITI factor).

## Best Practices

- Install line reactors (3% minimum) on every VFD unless the drive has a built-in DC choke.
- Use K-rated transformers (K-4 or K-13) for panels feeding multiple VFDs.
- Perform a harmonic study before installing large VFDs or many small VFDs on one bus.
- Monitor THD at the PCC periodically, especially when adding new nonlinear loads.
- Consider active harmonic filters for facilities with high VFD density.

## Safety

- Do not disconnect or service line reactors or harmonic filters while energized — they can store energy.
- Capacitor banks used for PF correction must be fully discharged before handling — wait the manufacturer-specified discharge time.
- When measuring harmonics with a power quality analyzer, use properly rated probes and PPE for the voltage level.
- Be aware that resonance between capacitors and system inductance can create dangerous overvoltages.',
      50, true, true,
      '[
        {"question":"What are the characteristic harmonics produced by a 6-pulse VFD?","options":["2nd, 3rd, 4th","5th, 7th, 11th, 13th","1st, 3rd, 5th","7th, 9th, 11th"],"correctIndex":1},
        {"question":"What is the IEEE 519 recommended voltage THD limit at the PCC?","options":["1%","3%","5%","10%"],"correctIndex":2},
        {"question":"What is the simplest and most cost-effective harmonic mitigation for a VFD?","options":["Adding a 12-pulse converter","Adding a 3% or 5% line reactor","Installing an active filter","Using a larger motor"],"correctIndex":1},
        {"question":"Why do transformers feeding VFD loads need K-factor ratings?","options":["To handle higher voltages","Because harmonic currents cause additional eddy current losses","To improve power factor","To reduce harmonics"],"correctIndex":1},
        {"question":"What is the difference between displacement PF and true PF on a VFD?","options":["There is no difference","Displacement PF is near 0.95 but true PF is lower due to harmonics","True PF is always 1.0","Displacement PF is always lower"],"correctIndex":1},
        {"question":"How do 12-pulse drives reduce harmonics?","options":["By filtering them out","By phase-shifting and canceling low-order harmonics","By increasing the carrier frequency","By reducing motor speed"],"correctIndex":1},
        {"question":"What problem can harmonics cause in power factor correction capacitors?","options":["No effect","Resonance leading to overvoltage and capacitor failure","Improved PF","Reduced harmonics"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    -- Lesson 2: Energy Savings & VFD Application Strategy
    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Energy Savings & VFD Application Strategy',
      '## Overview

The primary economic justification for VFDs in many industrial applications is energy savings. Centrifugal pumps, fans, and blowers follow the affinity laws — power consumption drops with the cube of speed. A 20% reduction in speed yields nearly 50% reduction in power. Understanding when and how to apply VFDs for energy savings is critical for industrial electrical work.

## Key Concepts

- **Affinity laws**: For centrifugal loads, Flow ∝ Speed, Pressure ∝ Speed², Power ∝ Speed³. This is why VFDs save so much energy on variable-flow applications.
- **Variable torque vs constant torque loads**: Fans, pumps, and blowers are variable torque (high savings potential). Conveyors, hoists, and positive displacement pumps are constant torque (limited savings from speed reduction alone).
- **Energy savings calculation**: Compare the power consumed at throttled/bypassed operation vs VFD-controlled operation at the same flow rate. The difference, times operating hours, times energy cost, gives annual savings.
- **Payback analysis**: Divide the installed cost of the VFD by the annual energy savings to determine simple payback. Most pump and fan VFD installations pay back in 1-3 years.
- **Baseline measurement**: Before installing a VFD, measure the current energy consumption and operating profile. After installation, verify savings with the same measurement methodology.

## Step-by-Step: Evaluating a VFD Energy Savings Project

1. **Identify the load type**: Confirm it is a centrifugal fan, pump, or blower (variable torque). Constant torque loads have limited savings potential.
2. **Measure the operating profile**: Log flow rate, pressure, and motor power over a representative period (at least one week). Identify the percentage of time at each flow rate.
3. **Calculate baseline energy use**: Integrate power over time to get baseline kWh consumption and cost.
4. **Estimate VFD energy use**: For each operating point, calculate the power required at the reduced speed using affinity laws. Integrate to get projected kWh.
5. **Calculate savings**: Subtract projected VFD energy use from baseline energy use. Multiply by energy cost for dollar savings.
6. **Determine installed cost**: Include VFD cost, installation labor, enclosure, cooling, line reactor, and any required sensors or controls.
7. **Calculate payback**: Divide installed cost by annual savings. If under 3 years, the project is typically justified.
8. **Verify post-installation**: After VFD installation, repeat the measurement to verify actual savings match projections.

## Common Problems

- **Oversized motors**: Motors oversized for the load operate at low efficiency. VFDs can improve part-load efficiency but cannot fix severe oversizing.
- **Constant-speed operation**: If a VFD is installed but always runs at 60 Hz, there are no energy savings. Ensure the control strategy actually varies speed.
- **Harmonic losses**: VFD harmonic currents cause additional losses in transformers and cables, partially offsetting savings. Mitigation reduces this.
- **Critical speed resonance**: Variable speed operation can excite mechanical resonances in fans or pumps, causing vibration. Identify and program around critical speeds.
- **Motor cooling at low speed**: TEFC motors rely on shaft-mounted fans. At very low speeds, cooling may be insufficient. Use inverter-duty motors or force ventilation.

## Best Practices

- Size VFDs to the motor FLA, not oversized — oversizing reduces efficiency and increases cost.
- Use inverter-duty motors rated for VFD operation (NEMA MG 1 Part 31 compliance).
- Install bypass contactors for critical applications so the motor can run across-the-line if the VFD fails.
- Program minimum speed limits to prevent motor overheating and mechanical resonance.
- Integrate VFD control with the process control system (PLC, DCS, or BAS) for optimal performance.
- Trend energy consumption before and after VFD installation to document savings.

## Safety

- Ensure the VFD enclosure is properly ventilated and rated for the ambient temperature.
- When installing a bypass contactor, ensure interlocks prevent the VFD and bypass from being energized simultaneously.
- Follow lockout/tagout procedures when servicing VFDs — capacitors in the DC bus retain charge after power is removed.
- Verify the motor is rated for inverter duty before applying a VFD to an existing motor — older motors may have insulation that cannot withstand VFD voltage stress.',
      45, true, true,
      '[
        {"question":"According to the affinity laws, how does power consumption change with speed for a centrifugal load?","options":["Power is proportional to speed","Power is proportional to speed squared","Power is proportional to speed cubed","Power is constant"],"correctIndex":2},
        {"question":"A 20% reduction in speed yields approximately how much reduction in power for a centrifugal load?","options":["20%","30%","50%","80%"],"correctIndex":2},
        {"question":"Which load type has the highest VFD energy savings potential?","options":["Constant torque (conveyors)","Variable torque (centrifugal pumps and fans)","Positive displacement pumps","Hoists and cranes"],"correctIndex":1},
        {"question":"What is the typical payback period for a VFD on a centrifugal pump or fan?","options":["5-10 years","1-3 years","10+ years","Less than 6 months"],"correctIndex":1},
        {"question":"What problem occurs if a VFD is installed but always runs at 60 Hz?","options":["No energy savings are achieved","The motor will be damaged","The VFD will trip","Harmonics increase"],"correctIndex":0},
        {"question":"Why might a TEFC motor overheat when operated at very low speed with a VFD?","options":["The VFD generates more heat","The shaft-mounted cooling fan provides insufficient airflow at low speed","The motor draws more current at low speed","The bearings fail"],"correctIndex":1},
        {"question":"What is the purpose of a bypass contactor in a VFD installation?","options":["To improve efficiency","To allow the motor to run across-the-line if the VFD fails","To reduce harmonics","To improve power factor"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 4: Motor Testing with Megger & PI — Add Module 2: Advanced Motor Diagnostics
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Motor Testing with Megger & PI' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;

  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Advanced Motor Diagnostics') THEN
    INSERT INTO modules (course_id, title, sort_order)
    VALUES (c_id, 'Advanced Motor Diagnostics', 2)
    RETURNING id INTO m_id;

    -- Lesson 1: Surge Testing & Winding Fault Detection
    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Surge Testing & Winding Fault Detection',
      '## Overview

Surge testing (also called impulse or surge comparison testing) is a powerful diagnostic for detecting turn-to-turn, coil-to-coil, and phase-to-phase insulation failures in motor windings. While a megger test detects ground wall insulation failures, surge testing finds faults between turns within the same winding — the most common precursor to catastrophic motor failure.

## Key Concepts

- **Surge test principle**: A high-frequency, high-voltage impulse is injected into each winding. The resulting oscillating waveform is compared between phases. Identical windings produce identical waveforms; a fault creates a visible difference.
- **Turn-to-turn faults**: Shorted turns change the inductance of the winding, altering the surge waveform. These faults are undetectable by megger testing.
- **Test voltage**: Surge test voltage is typically 2 × (V_motor + 1000) for form-wound motors, per IEEE 522. For random-wound motors, 2 × V_motor + 1000V.
- **Surge comparison**: The waveforms from all three phases are overlaid. Any deviation between phases indicates a winding fault.
- **Partial discharge detection**: Advanced surge testers can detect partial discharge activity that indicates insulation degradation before a complete short occurs.

## Step-by-Step: Performing a Surge Test

1. **Safety preparation**: De-energize and lock out the motor. Disconnect the motor leads from the drive, starter, and any surge protection. Ground the frame.
2. **Visual inspection**: Check for obvious signs of damage — burned windings, oil contamination, or moisture.
3. **Perform insulation resistance test first**: Megger the windings to ground. If ground insulation is bad, surge testing may cause further damage. Do not surge test if IR is below minimum.
4. **Connect the surge tester**: Connect the tester leads to two motor terminals at a time (T1-T2, T2-T3, T1-T3). Do not connect to ground.
5. **Start at low voltage**: Begin at 500V and compare the waveforms. Look for any difference between the three comparisons.
6. **Increase voltage gradually**: Raise the voltage in steps to the test voltage. Watch for waveform changes at any voltage level.
7. **Compare waveforms**: Overlap the three comparison waveforms. Identical waveforms indicate healthy windings. Any divergence indicates a turn-to-turn or phase-to-phase fault.
8. **Document results**: Save or photograph the waveforms for each comparison and note the test voltage.

## Common Problems

- **Turn-to-turn shorts**: The most common winding fault. The surge test detects these before they escalate to complete winding failure.
- **Coil-to-coil faults**: Faults between coils within the same phase. Detected as waveform deviation in one comparison only.
- **Phase-to-phase faults**: Faults between phases. Detected as waveform deviation in two comparisons.
- **False positives from external connections**: Surge protection devices or VFDs connected to the motor can distort the waveform. Always disconnect these before testing.
- **Inherent imbalance**: Some motors (especially rewound ones) have inherent impedance differences between phases that produce slight waveform differences. Compare to baseline if available.

## Best Practices

- Always perform insulation resistance testing before surge testing.
- Disconnect all external connections (drives, surge protectors, power factor correction capacitors) before testing.
- Start at low voltage and increase gradually — do not apply full test voltage immediately.
- Keep baseline surge test results for comparison during future testing.
- Use surge testing as part of a comprehensive predictive maintenance program, not just for troubleshooting.
- For critical motors, perform surge testing during scheduled outages and trend the results.

## Safety

- Surge testing applies high voltage to the windings. Follow all electrical safety procedures.
- The motor frame must be grounded before testing to protect the tester and personnel.
- Do not surge test motors with known ground faults — the test can worsen the fault.
- After testing, discharge the windings by connecting all leads to ground for at least the time specified by the tester manufacturer.
- Wear arc-rated PPE when performing surge tests, especially on medium-voltage motors.',
      50, true, true,
      '[
        {"question":"What type of fault does surge testing detect that megger testing cannot?","options":["Ground wall insulation failures","Turn-to-turn insulation faults within a winding","Open circuits","Bearing failures"],"correctIndex":1},
        {"question":"How are surge test results interpreted?","options":["By measuring resistance","By comparing oscillating waveforms between phases","By measuring capacitance","By measuring inductance directly"],"correctIndex":1},
        {"question":"What test should be performed before a surge test?","options":["A continuity test","An insulation resistance (megger) test","A TTR test","A hipot test"],"correctIndex":1},
        {"question":"What is the typical surge test voltage for a 480V motor?","options":["500V","1000V","2000V","5000V"],"correctIndex":2},
        {"question":"Why must external devices (VFDs, surge protectors) be disconnected before surge testing?","options":["They will be damaged by the test","They distort the surge waveform and cause false readings","They are not rated for the voltage","They interfere with the tester"],"correctIndex":1},
        {"question":"What does a divergence in the surge waveform between two phases indicate?","options":["Healthy windings","A turn-to-turn or phase-to-phase fault","A ground fault","Normal motor operation"],"correctIndex":1},
        {"question":"What must be done after completing a surge test?","options":["Nothing","Discharge the windings by connecting all leads to ground","Reconnect the VFD immediately","Run the motor"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    -- Lesson 2: Bearing Currents & Shaft Voltage Testing
    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Bearing Currents & Shaft Voltage Testing',
      '## Overview

Bearing failure is one of the most common causes of motor failure in industrial applications. A significant and often overlooked cause of bearing failure in VFD-driven motors is electrical bearing damage from shaft currents. VFDs create common-mode voltage that drives current through the motor bearings, causing EDM (Electrical Discharge Machining) pitting and eventually bearing failure. Understanding and diagnosing bearing currents is essential for VFD applications.

## Key Concepts

- **Common-mode voltage**: VFD PWM switching creates a common-mode voltage on the motor shaft relative to ground. This voltage can drive current through the bearings.
- **EDM pitting**: When shaft voltage exceeds the dielectric breakdown of bearing lubricant (~10-30V), current arcs through the bearing, creating microscopic pits (fluting) on the race.
- **Bearing current paths**: Current flows through the bearing via two paths: capacitive coupling (high frequency, low energy) and conductive (low frequency, high energy through the shaft and frame).
- **Shaft voltage measurement**: Measuring the voltage between the shaft and frame detects the presence of bearing currents. A reading above 10V AC indicates a risk.
- **Mitigation methods**: Shaft grounding rings (AEGIS), insulated bearings, ceramic balls, and conductive grease are common mitigation strategies.

## Step-by-Step: Measuring Shaft Voltage and Diagnosing Bearing Currents

1. **Safety preparation**: The motor must be running for this test. Ensure appropriate PPE and follow energized work procedures.
2. **Set up the measurement**: Use an oscilloscope with a high-bandwidth voltage probe. Connect the probe tip to the motor shaft (using a carbon brush or spring-loaded contact) and the ground lead to the motor frame.
3. **Measure shaft voltage**: Observe the waveform. Look for high-frequency pulses (PWM-related) and peak voltage. Record the peak-to-peak voltage.
4. **Interpret the reading**: Peak shaft voltage below 5V is generally safe. 5-10V is marginal. Above 10V indicates a high risk of bearing damage.
5. **Check for bearing current**: Use a high-frequency current probe (CT) around the shaft or bearing housing to measure bearing current directly.
6. **Inspect the bearings**: If the motor is disassembled, inspect the bearing races for fluting (washboard pattern) or frosting — hallmarks of electrical bearing damage.
7. **Recommend mitigation**: If shaft voltage is high, recommend shaft grounding rings, insulated bearings, or other mitigation appropriate to the application.

## Common Problems

- **EDM fluting**: The characteristic washboard pattern on bearing races caused by repeated electrical discharges. Causes vibration and noise.
- **Grease degradation**: Bearing currents break down the lubricant, reducing its effectiveness and accelerating mechanical wear.
- **Premature bearing failure**: Motors on VFDs without bearing protection may fail in 6 months to 2 years, compared to 5-10 years for properly protected motors.
- **False diagnosis**: Mechanical bearing damage can mimic electrical damage. Always measure shaft voltage to confirm electrical cause.
- **Inadequate grounding**: Poor motor grounding increases common-mode voltage and bearing current risk.

## Best Practices

- Install shaft grounding rings on all VFD-driven motors, especially those above 100 HP.
- Use insulated bearings (typically on the non-drive end) to break the circulating current path.
- Ensure proper motor grounding — use high-frequency bonding straps, not just the equipment grounding conductor.
- Minimize the motor cable length between VFD and motor to reduce common-mode coupling.
- Use symmetrical VFD motor cables (three conductors plus a full-size ground, or three conductors with three grounds) to reduce common-mode current.
- Perform shaft voltage testing during commissioning of VFD systems and periodically as part of predictive maintenance.

## Safety

- Shaft voltage measurement requires the motor to be running — follow all energized work safety procedures.
- Use a non-contact shaft contact method (carbon brush on a probe) to avoid contact with rotating equipment.
- Never touch the motor shaft while the motor is running — shaft voltage can cause a shock, and rotating equipment is a mechanical hazard.
- When inspecting bearings, ensure the motor is de-energized and locked out.',
      45, true, true,
      '[
        {"question":"What causes EDM pitting in motor bearings on VFD-driven motors?","options":["Mechanical overload","Common-mode voltage from VFD PWM driving current through the bearings","Excessive lubrication","High ambient temperature"],"correctIndex":1},
        {"question":"At approximately what shaft voltage does bearing damage begin to occur?","options":["1V","10-30V","100V","500V"],"correctIndex":1},
        {"question":"What is the characteristic pattern on bearing races caused by electrical discharge?","options":["Smooth wear","Fluting (washboard pattern)","Corrosion pits","Cracking"],"correctIndex":1},
        {"question":"What instrument is used to measure shaft voltage?","options":["A megger","An oscilloscope with a high-bandwidth voltage probe","A clamp meter","A multimeter"],"correctIndex":1},
        {"question":"What is the most common mitigation method for bearing currents on VFD motors?","options":["Increasing motor size","Installing shaft grounding rings","Using a larger VFD","Reducing motor speed"],"correctIndex":1},
        {"question":"Why is proper motor grounding important for VFD applications?","options":["It improves efficiency","Poor grounding increases common-mode voltage and bearing current risk","It reduces harmonics","It improves power factor"],"correctIndex":1},
        {"question":"How long might a VFD-driven motor bearing last without bearing protection?","options":["10-20 years","6 months to 2 years","20+ years","Same as a non-VFD motor"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;

-- Course 5: Electrical Safety & Arc Flash Awareness — Add Module 3: Arc Flash Hazard Analysis
DO $$
DECLARE
  c_id uuid;
  m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Electrical Safety & Arc Flash Awareness' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;

  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Arc Flash Hazard Analysis') THEN
    INSERT INTO modules (course_id, title, sort_order)
    VALUES (c_id, 'Arc Flash Hazard Analysis', 3)
    RETURNING id INTO m_id;

    -- Lesson 1: Incident Energy & Arc Flash Calculations
    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Incident Energy & Arc Flash Calculations',
      '## Overview

Arc flash hazard analysis is the process of calculating the incident energy at a given working distance from an arcing fault. This analysis determines the arc flash boundary, the required PPE category, and the warning labels that must be affixed to equipment. Understanding the inputs and methodology of arc flash calculations is essential for anyone working on or near energized electrical equipment.

## Key Concepts

- **Incident energy**: The thermal energy (cal/cm²) delivered to a surface at a specific distance from an arc flash. It determines the severity of potential burns and the required PPE.
- **Arc flash boundary**: The distance from the arc source at which incident energy equals 1.2 cal/cm² (the threshold for a second-degree burn).
- **Working distance**: The distance from the arc source to the worker''s face and chest. Typical values: 18 inches for low-voltage panels, 24 inches for switchgear, 36 inches for larger equipment.
- **Available fault current**: The maximum short-circuit current at the equipment. Higher fault current means higher incident energy.
- **Clearing time**: The time for the upstream protective device to clear the fault. Longer clearing time means more incident energy. This is the single most important variable.
- **IEEE 1584 vs NFPA 70E tables**: IEEE 1584 provides the calculation methodology. NFPA 70E tables provide a simplified, conservative alternative based on task and equipment type.

## Step-by-Step: Understanding an Arc Flash Calculation

1. **Determine the system parameters**: Voltage, available fault current (from a short-circuit study), and the upstream protective device clearing time (from a coordination study).
2. **Identify the working distance**: Based on the equipment type and task. Use standard distances from IEEE 1584 or the facility''s standard.
3. **Select the calculation method**: IEEE 1584 empirical equations (most accurate) or NFPA 70E table method (simpler, more conservative).
4. **Calculate arcing current**: Use the IEEE 1584 equations to convert available fault current to arcing current (arcing current is lower than bolted fault current due to arc impedance).
5. **Determine clearing time**: Find the time for the upstream protective device to clear at the arcing current. This requires the device''s time-current curve.
6. **Calculate incident energy**: Apply the IEEE 1584 incident energy equations using arcing current, clearing time, working distance, and equipment configuration.
7. **Determine the arc flash boundary**: Calculate the distance at which incident energy equals 1.2 cal/cm².
8. **Select PPE category**: Compare the calculated incident energy to PPE category ratings (Category 1: 4 cal/cm², Category 2: 8 cal/cm², Category 3: 25 cal/cm², Category 4: 40 cal/cm²).

## Common Problems

- **Outdated studies**: Arc flash studies must be updated when the system changes (new equipment, different fuse/breaker, changed utility fault current). An outdated study is dangerous.
- **Incorrect clearing time**: The most common error. Using the wrong protective device curve or not accounting for device tolerance leads to incorrect clearing time and wrong incident energy.
- **Wrong working distance**: Using a longer distance than the actual working distance underestimates the hazard.
- **Ignoring maintenance mode**: Some facilities have a "maintenance mode" on breakers that reduces clearing time for safer energized work. This must be reflected in the calculation.
- **Labels not updated**: After a study update, labels must be replaced. Old labels with wrong incident energy are a serious safety hazard.

## Best Practices

- Perform a complete arc flash study every 5 years or whenever the system changes significantly.
- Use IEEE 1584 calculations rather than NFPA 70E tables for critical equipment.
- Include all available sources (utility, generators, motors) in the short-circuit study.
- Verify protective device settings match the coordination study — a changed fuse or breaker setting invalidates the arc flash study.
- Install arc flash labels on all equipment showing incident energy, arc flash boundary, working distance, and required PPE.
- Train all qualified workers to read and understand arc flash labels.

## Safety

- Never perform energized work without first consulting the arc flash label and wearing the required PPE.
- If the arc flash study is outdated or unavailable, use the highest PPE category (Category 4) as a conservative default.
- Remember that the arc flash label only tells you the PPE — it does not make the work safe. Follow all safe work practices.
- Incident energy above 40 cal/cm² is considered "dangerous" — do not perform energized work at these levels under any circumstances.
- Blast pressure and sound from an arc flash can cause injury even with proper PPE — minimize exposure time and use remote operation when possible.',
      50, true, true,
      '[
        {"question":"What is incident energy?","options":["The voltage at the arc","The thermal energy (cal/cm²) delivered to a surface at a specific distance from an arc flash","The current flowing during the arc","The duration of the arc"],"correctIndex":1},
        {"question":"What is the arc flash boundary?","options":["The distance at which PPE is required","The distance at which incident energy equals 1.2 cal/cm²","The distance at which voltage is zero","The boundary for LOTO"],"correctIndex":1},
        {"question":"What is the most important variable in determining incident energy?","options":["Voltage","Available fault current","Clearing time of the upstream protective device","Ambient temperature"],"correctIndex":2},
        {"question":"What is the typical working distance for low-voltage panel work?","options":["6 inches","18 inches","36 inches","60 inches"],"correctIndex":1},
        {"question":"What PPE category is required for an incident energy of 15 cal/cm²?","options":["Category 1","Category 2","Category 3","Category 4"],"correctIndex":2},
        {"question":"Above what incident energy level is energized work generally not permitted?","options":["8 cal/cm²","25 cal/cm²","40 cal/cm²","100 cal/cm²"],"correctIndex":2},
        {"question":"How often should a complete arc flash study be performed?","options":["Every year","Every 5 years or when the system changes significantly","Every 10 years","Only once"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    -- Lesson 2: Creating & Implementing an Arc Flash Safety Program
    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Creating & Implementing an Arc Flash Safety Program',
      '## Overview

An arc flash safety program is a comprehensive system of policies, procedures, training, and equipment that protects workers from arc flash hazards. It goes beyond simply having arc flash labels — it encompasses the entire workflow from hazard identification through work execution and incident investigation. A well-implemented program is the difference between compliance and actual safety.

## Key Concepts

- **Program scope**: The program must cover all employees and contractors who may be exposed to electrical hazards, not just electricians.
- **Hierarchy of controls**: Elimination (de-energize) > Engineering controls (remote operation, arc-resistant equipment) > Administrative controls (procedures, permits) > PPE. PPE is the last line of defense.
- **Qualified vs unqualified workers**: Only qualified workers (trained and authorized) may perform energized electrical work. The program must define qualification requirements and track them.
- **Energized work justification**: NFPA 70E requires documented justification for energized work — it must be demonstrated that de-energizing introduces greater risk or is infeasible.
- **Program audit**: The program must be audited at least every 3 years to verify compliance and effectiveness.

## Step-by-Step: Implementing an Arc Flash Safety Program

1. **Conduct a hazard assessment**: Identify all energized electrical equipment and the tasks performed on or near it. Determine which tasks require energized work.
2. **Perform an arc flash study**: Hire a qualified engineering firm or use in-house expertise to perform IEEE 1584-based arc flash calculations for all equipment.
3. **Install arc flash labels**: Affix labels to all equipment showing incident energy, arc flash boundary, working distance, and required PPE.
4. **Develop written procedures**: Create procedures for energized work permits, LOTO, PPE selection and inspection, and emergency response.
5. **Select and purchase PPE**: Provide arc-rated clothing, face shields, gloves, and other PPE appropriate for the highest hazard category in the facility.
6. **Train workers**: Provide initial and refresher training to all qualified workers. Training must cover hazard recognition, safe work practices, PPE use, and emergency response.
7. **Implement a permit system**: Require energized work permits for any work above 50V that cannot be de-energized. Permits must be signed by the worker, supervisor, and safety officer.
8. **Audit the program**: Conduct internal audits annually and a full program audit every 3 years. Document findings and track corrective actions.

## Common Problems

- **Compliance without safety**: Facilities install labels and buy PPE but do not enforce the procedures. Workers still perform energized work without permits or PPE.
- **Inadequate training**: Workers receive a one-time training session and never get refresher training. Skills and knowledge degrade over time.
- **PPE not worn**: PPE is purchased but not worn because it is uncomfortable, too hot, or perceived as unnecessary for "quick" tasks.
- **No energized work justification**: Workers perform energized work without documenting why de-energizing was not feasible.
- **Outdated studies**: The arc flash study was done once and never updated. Equipment changes have invalidated the labels.
- **Contractor compliance**: Contractors are not held to the same standards as employees. They perform work without the facility''s PPE or procedures.

## Best Practices

- Make de-energization the default — require a written, signed justification for any energized work.
- Use remote operation devices (remote racking, remote switching) to eliminate the need for energized work.
- Provide comfortable, properly sized PPE — workers will not wear PPE that does not fit or is too hot.
- Conduct regular field audits — observe workers performing tasks and verify compliance with procedures.
- Include contractors in the program — require them to follow facility procedures and provide their own qualified workers.
- Track near-misses and incidents — investigate every arc flash event or near-miss to identify program gaps.
- Use arc-resistant switchgear for new installations — it redirects arc energy away from the worker.

## Safety

- The safety program itself must be safe to implement — do not create procedures that are so complex they are bypassed.
- Ensure that the push for productivity does not override safety procedures. Management must visibly support the program.
- Emergency response must be part of the program — workers must know what to do if an arc flash occurs.
- Regular drills and practice are essential — workers must be able to don PPE correctly and quickly.
- Never allow a "culture of convenience" to override the program — one bypassed procedure can lead to a fatal incident.',
      45, true, true,
      '[
        {"question":"What is the hierarchy of controls for arc flash safety?","options":["PPE first, then engineering, then elimination","Elimination (de-energize), then engineering, then administrative, then PPE","Administrative controls first, then PPE","Engineering controls only"],"correctIndex":1},
        {"question":"What does NFPA 70E require for energized work?","options":["Nothing special","Documented justification that de-energizing introduces greater risk or is infeasible","Just supervisor approval","Only PPE"],"correctIndex":1},
        {"question":"How often must an arc flash safety program be audited?","options":["Every year","Every 3 years","Every 5 years","Every 10 years"],"correctIndex":1},
        {"question":"Who may perform energized electrical work under an arc flash program?","options":["Anyone","Only qualified workers who are trained and authorized","Only supervisors","Only contractors"],"correctIndex":1},
        {"question":"What is a common reason PPE is not worn even when available?","options":["It is too expensive","It is uncomfortable, too hot, or perceived as unnecessary for quick tasks","It is not required","Workers do not know how to use it"],"correctIndex":1},
        {"question":"What must an energized work permit include signatures from?","options":["Just the worker","The worker, supervisor, and safety officer","Just the supervisor","Just the safety officer"],"correctIndex":1},
        {"question":"What should be done with every arc flash event or near-miss?","options":["Nothing — it happens","Investigate to identify program gaps","Report it to the utility","Replace the equipment"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;
