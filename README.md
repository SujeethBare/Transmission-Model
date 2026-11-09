# Transmission Modeling & Gear Ratio Optimization (Single-Speed vs Two-Speed)

MATLAB/Simulink models for sizing the transmission of an electric vehicle (Nissan Leaf class), comparing a **single-speed** and a **two-speed** gearbox over the **UDDS** drive cycle.

---

## Aim

- Size the gear ratio from vehicle requirements (top speed, gradeability, acceleration) and study its effect on motor operating region, efficiency and energy consumption
- Find the optimum gear ratio pair for a two-speed transmission using a linear search

---

## Approach

### 1. Single-speed gear ratio sizing
- Vehicle, road-load, motor and transmission parameters defined in a MATLAB script
- Feasible gear ratio range calculated from:
  - **Motor speed limit** and **vehicle maximum speed**
  - **Gradeability** (wheel torque needed on a slope)
  - **Performance requirements** (acceleration)
- **Equivalent (effective) mass** calculated as a function of gear ratio, to include the rotating inertia of the motor and drivetrain
- Forward-facing Simulink powertrain model (drive cycle → driver → motor → transmission → vehicle) simulated on **UDDS**
- Motor operating points plotted on the **motor efficiency map**, together with the **peak and continuous torque** limits

### 2. Two-speed transmission model
- Same powertrain extended with two gear ratios and a gear selection strategy
- Motor operating points analysed separately for **1st gear** and **2nd gear**

### 3. Gear ratio optimization (linear search)
- A MATLAB script loops over every 1st/2nd gear ratio combination
- For each pair, the two-speed Simulink model is simulated on UDDS
- The pair with **minimum motor energy consumption** and **maximum average motor efficiency** is selected

---

## Repository guide

| # | File | What it does | Works with |
|---|---|---|---|
| 1 | `Imports.m` | Vehicle, road-load, motor and transmission parameters, plus single-speed gear ratio sizing calculations | `Powertrain.slx` |
| 2 | `GR_Sizing_Imports.m` | **Post-processing:** reads the results of `Powertrain.slx` and generates the plots | `Powertrain.slx` |
| 3 | `Imports_2GR.m` | Parameters for the **two-speed** setup (two gear ratios) | `Powertrain_2GR.slx` |
| 4 | `GR_Sizing_Imports_2GR.m` | **Post-processing:** reads the results of `Powertrain_2GR.slx` and generates the plots | `Powertrain_2GR.slx` |
| 5 | `TwoSpeed_Trans_Opti.m` | **Linear search optimizer:** simulates every two-speed gear ratio combination on UDDS and selects the pair with minimum motor energy and maximum efficiency | `Powertrain_2GR.slx` |

Drive cycle, motor torque curve and efficiency map data (`.csv`) are loaded by the import scripts, so keep them in the same folder.

---

## How to run

Open MATLAB and set the repository folder as the current folder.

**Single-speed**
1. Run `Imports.m`
2. Run `Powertrain.slx`
3. Run `GR_Sizing_Imports.m` to generate the plots

**Two-speed**
1. Run `Imports_2GR.m`
2. Run `Powertrain_2GR.slx`
3. Run `GR_Sizing_Imports_2GR.m` to generate the plots

**Optimization**
1. Run `Imports_2GR.m`
2. Run `TwoSpeed_Trans_Opti.m` (it simulates `Powertrain_2GR.slx` for every gear ratio pair, so it can take a while)

---

## Note
I have tried to add comments wherever the code might be ambiguous, though not everywhere.
