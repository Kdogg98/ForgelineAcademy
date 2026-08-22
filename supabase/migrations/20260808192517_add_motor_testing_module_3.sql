-- ============================================================
-- PART 7: Add missing module 3 for Motor Testing with Megger & PI
-- ============================================================

DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE title = 'Motor Testing with Megger & PI' AND stage = 'electrical';
  IF c_id IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c_id AND title = 'Motor Bearing Testing & Condition Monitoring') THEN
    INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'Motor Bearing Testing & Condition Monitoring', 3) RETURNING id INTO m_id;

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Vibration Analysis & Bearing Condition Assessment',
      '## Overview

Bearing failures account for approximately 50% of all motor failures in industrial applications. Vibration analysis is the most powerful tool for detecting bearing degradation before failure occurs. By monitoring vibration signatures over time, maintenance teams can identify bearing wear, misalignment, imbalance, and other mechanical issues, enabling predictive maintenance that prevents unplanned downtime.

## Key Concepts

- **Vibration spectrum**: A frequency-domain representation of vibration, showing the amplitude at each frequency. Each mechanical fault produces characteristic frequencies that identify the fault type.
- **Bearing fault frequencies**: Each bearing component (outer race, inner race, rolling element, cage) has a characteristic fault frequency based on bearing geometry. These frequencies are calculated from bearing dimensions and RPM.
- **Overall vibration level**: The total vibration amplitude across all frequencies, measured in mm/s or in/s (velocity) or g (acceleration). ISO 10816 provides severity guidelines.
- **Acceleration enveloping (envelope analysis)**: A technique that amplifies high-frequency impact signals from bearing defects, making early-stage bearing wear detectable before it appears in the overall vibration level.
- **Condition monitoring**: The practice of regularly measuring and trending vibration data to detect gradual degradation and predict time to failure.

## Step-by-Step: Performing Vibration Analysis on a Motor

1. **Mount the accelerometer**: Place the accelerometer on the motor bearing housing in the horizontal, vertical, and axial directions. Use a magnetic mount or threaded stud for consistent placement.
2. **Measure the overall vibration level**: Record the overall RMS vibration velocity (mm/s or in/s). Compare to ISO 10816 severity limits for the motor size and mounting type.
3. **Capture the vibration spectrum**: Record the frequency spectrum from 0 to 10,000 Hz or higher. Identify the dominant frequencies.
4. **Identify the running speed frequency**: The motor running speed (RPM/60 for 60 Hz motors) appears as a peak in the spectrum. This is the 1X frequency.
5. **Identify bearing fault frequencies**: Calculate the bearing fault frequencies (BPFO - outer race, BPFI - inner race, BSF - ball spin, FTF - cage) from the bearing part number and RPM. Look for peaks at these frequencies.
6. **Compare to baseline**: If a baseline spectrum exists, compare the current spectrum to the baseline. New peaks or increasing amplitudes indicate degradation.
7. **Trend the data**: Record the overall vibration level and key fault frequencies over time. An increasing trend indicates progressive degradation.
8. **Recommend action**: Based on the severity and trend, recommend continued monitoring, increased monitoring frequency, or bearing replacement.

## Common Problems

- **Outer race fault**: The most common bearing fault. Appears as a peak at BPFO (ball pass frequency outer) in the spectrum, with harmonics. Caused by bearing load concentration.
- **Inner race fault**: Appears as a peak at BPFI with harmonics and 1X sidebands. Less common but more severe than outer race faults.
- **Rolling element (ball/roller) fault**: Appears at BSF with FTF sidebands. Indicates damaged rolling elements.
- **Cage fault**: Appears at FTF (fundamental train frequency). Indicates cage damage, often caused by lubrication failure.
- **Misalignment**: Appears as a high 2X peak (twice running speed). Causes bearing overload and premature failure.
- **Imbalance**: Appears as a high 1X peak (running speed). Causes vibration that damages bearings over time.

## Best Practices

- Establish baseline vibration spectra for all critical motors when they are new or newly rebuilt.
- Perform vibration analysis quarterly on critical motors and annually on all motors.
- Use acceleration enveloping for early detection of bearing faults before they appear in the overall vibration level.
- Trend overall vibration levels and key fault frequencies over time.
- Calculate bearing fault frequencies from the bearing part number — each bearing has unique frequencies.
- Use ISO 10816 severity guidelines to determine when to act on vibration levels.
- Integrate vibration data with other condition monitoring (oil analysis, thermography) for comprehensive predictive maintenance.

## Safety

- Never take vibration measurements on rotating equipment without guards in place — rotating shafts are a serious mechanical hazard.
- Use magnetic mount accelerometers with care — they can pinch fingers when attaching to ferrous surfaces.
- High vibration levels may indicate imminent failure — do not continue running a motor with dangerous vibration levels.
- Follow LOTO procedures when mounting or removing permanent sensors.
- Be aware that vibration analysis on running equipment requires proximity to rotating machinery — maintain safe distances.',
      50, true, true,
      '[
        {"question":"What percentage of motor failures are caused by bearing failures?","options":["10%","Approximately 50%","75%","90%"],"correctIndex":1},
        {"question":"What is a vibration spectrum?","options":["A time-domain graph","A frequency-domain representation showing vibration amplitude at each frequency","A velocity graph","An acceleration graph"],"correctIndex":1},
        {"question":"What does a high 1X peak (running speed frequency) in the vibration spectrum indicate?","options":["Bearing fault","Imbalance","Misalignment","Cage fault"],"correctIndex":1},
        {"question":"What does a high 2X peak (twice running speed) indicate?","options":["Imbalance","Misalignment","Bearing fault","Electrical fault"],"correctIndex":1},
        {"question":"What is acceleration enveloping used for?","options":["To reduce vibration","To amplify high-frequency impact signals from bearing defects for early detection before overall vibration increases","To measure speed","To measure temperature"],"correctIndex":1},
        {"question":"What is the most common type of bearing fault?","options":["Inner race fault","Outer race fault","Rolling element fault","Cage fault"],"correctIndex":1},
        {"question":"What standard provides vibration severity guidelines?","options":["IEEE 43","ISO 10816","NEC 430","NFPA 70E"],"correctIndex":1}
      ]'::jsonb,
      80, 1);

    INSERT INTO lessons (module_id, title, content, estimated_minutes, has_video, has_pdf, quiz, pass_threshold, sort_order)
    VALUES (m_id, 'Online Condition Monitoring & Predictive Maintenance',
      '## Overview

Online condition monitoring uses permanently installed sensors to continuously monitor motor health. Unlike periodic (walk-around) monitoring, online monitoring provides real-time data that can detect sudden changes and trend gradual degradation. When integrated with a predictive maintenance program, it enables maintenance to be scheduled before failure occurs, minimizing unplanned downtime and reducing maintenance costs.

## Key Concepts

- **Online monitoring**: Permanently installed sensors (vibration, temperature, current) that continuously monitor motor condition and transmit data to a central system.
- **Predictive maintenance**: Maintenance strategy that uses condition data to predict when maintenance is needed, scheduling it before failure occurs. Contrasted with preventive (time-based) and reactive (run-to-failure) maintenance.
- **Wireless sensor networks**: Battery-powered wireless sensors that transmit vibration and temperature data, eliminating the need for wiring. Common for retrofit applications.
- **Motor current signature analysis (MCSA)**: Analyzing the motor''s current waveform to detect mechanical and electrical faults. Bearing faults, broken rotor bars, and air gap eccentricity produce characteristic current signatures.
- **IoT integration**: Connecting condition monitoring data to cloud platforms for advanced analytics, machine learning, and automated alerts.

## Step-by-Step: Implementing an Online Condition Monitoring System

1. **Identify critical motors**: Select motors whose failure would cause significant downtime, safety risk, or cost. These are candidates for online monitoring.
2. **Select the monitoring parameters**: Vibration (accelerometers), temperature (RTD or thermocouple), and current (CTs) are the most common parameters. Select based on the failure modes of concern.
3. **Select the sensor type**: Wireless sensors for retrofit applications, wired sensors for new installations. Consider battery life, range, and data rate.
4. **Install the sensors**: Mount accelerometers on bearing housings, temperature sensors on stator or bearing, and CTs on motor leads. Follow manufacturer installation guidelines.
5. **Set up the data collection**: Configure the data collection rate (continuous or interval), data transmission (wireless or wired), and storage (local or cloud).
6. **Establish baselines**: After installation, record baseline data for each motor. This is the reference for future comparison.
7. **Set alert thresholds**: Set warning and alarm thresholds for each parameter based on ISO standards, manufacturer recommendations, or historical data.
8. **Configure alerts**: Set up email or SMS alerts for threshold exceedances. Route critical alerts to the maintenance team for immediate action.
9. **Trend the data**: Monitor trends over time. Increasing vibration, temperature, or current unbalance indicates degradation.
10. **Integrate with maintenance workflow**: When an alert is generated, automatically create a work order in the CMMS for inspection or maintenance.

## Common Problems

- **Sensor failure**: Sensors can fail or drift, producing false data. Regularly verify sensor calibration and compare to walk-around measurements.
- **False alarms**: Thresholds set too low generate excessive alerts, causing alarm fatigue. Adjust thresholds based on operating data.
- **Data overload**: Continuous monitoring generates massive amounts of data. Use analytics and dashboards to focus on actionable information.
- **Battery failure (wireless)**: Wireless sensor batteries last 1-5 years. Plan for battery replacement to avoid data gaps.
- **Integration challenges**: Connecting the monitoring system to the CMMS or control system can be technically challenging. Use open protocols (OPC UA, MQTT).

## Best Practices

- Prioritize critical motors for online monitoring — not every motor needs permanent monitoring.
- Use wireless sensors for retrofit applications to avoid the cost and complexity of wiring.
- Set alert thresholds based on ISO standards and historical data, not arbitrary values.
- Trend data over time and use machine learning or statistical analysis to identify degradation patterns.
- Integrate alerts with the CMMS to automatically generate work orders.
- Perform regular sensor calibration checks to ensure data accuracy.
- Combine vibration, temperature, and current data for comprehensive condition assessment.
- Use the data to transition from time-based maintenance to condition-based maintenance.

## Safety

- Online monitoring does not replace the need for physical inspections — continue periodic visual and IR scans.
- Wireless sensors in hazardous areas must be rated for the area classification.
- Sensor installation on running equipment requires proximity to rotating machinery — follow safety procedures.
- Do not rely solely on automated alerts — review the data regularly to catch gradual changes that may not trigger alerts.
- When an alert indicates imminent failure, take the motor out of service immediately to prevent a hazardous failure.',
      45, true, true,
      '[
        {"question":"What is the difference between online monitoring and periodic (walk-around) monitoring?","options":["There is no difference","Online monitoring uses permanently installed sensors for continuous monitoring; periodic monitoring uses portable instruments at intervals","Online is cheaper","Periodic is more accurate"],"correctIndex":1},
        {"question":"What is predictive maintenance?","options":["Maintenance after failure","Maintenance that uses condition data to predict when maintenance is needed, scheduling it before failure","Time-based maintenance","No maintenance"],"correctIndex":1},
        {"question":"What is motor current signature analysis (MCSA)?","options":["Measuring motor speed","Analyzing the motor''s current waveform to detect mechanical and electrical faults","Measuring motor voltage","Measuring motor temperature"],"correctIndex":1},
        {"question":"What is a common challenge with wireless condition monitoring sensors?","options":["They are too large","Battery failure causing data gaps — plan for battery replacement","They are too expensive","They are inaccurate"],"correctIndex":1},
        {"question":"What should be done with alert thresholds to avoid alarm fatigue?","options":["Disable all alarms","Set thresholds based on ISO standards and historical data, not arbitrary values","Set all thresholds to maximum","Only use visual inspection"],"correctIndex":1},
        {"question":"What is the advantage of integrating condition monitoring with the CMMS?","options":["It saves money","Alerts automatically generate work orders for inspection or maintenance","It improves power factor","It reduces harmonics"],"correctIndex":1},
        {"question":"What should be done when an alert indicates imminent motor failure?","options":["Wait for the next scheduled maintenance","Take the motor out of service immediately to prevent a hazardous failure","Reduce the load","Ignore it — the system will auto-correct"],"correctIndex":1}
      ]'::jsonb,
      80, 2);
  END IF;
END $$;
