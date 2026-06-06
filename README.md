#  Agricultural Robotics – Energy Constrained Field Operations🚜⚡

**Course:** Artificial Intelligence for Robotics II (AI4R2)  
**Program:** Robotics Engineering, University of Genoa (UniGe)  
**Author:** Bahri Riadh

##  Project Overview
This project addresses the energy management and scheduling of an agricultural robot using Automated Planning (PDDL). The robot navigates a topological map of fields (represented as a graph) to perform tasks such as monitoring, watering, fertilizing, and harvesting, while strictly managing its finite battery capacity.

The project is structured into two main parts:
1. **Q1: Discrete Numeric Model** (Completed)
2. **Q2: Continuous Time Model & PDDL+** (To be added)

---

##  Q1: Discrete Numeric Model

In this section, we modeled the environment using classical PDDL with numeric fluents to handle the energy constraints.

### Energy Abstraction
In this discrete numeric model, the robot's energy is abstracted using PDDL `numeric-fluents`. The current battery level and maximum capacity are defined as numeric variables `(battery ?r)` and `(capacity ?r)`. Energy consumption is discretized by assigning specific constant costs to movements (depending on terrain difficulty: flat, rough, or muddy) and to agricultural operations (e.g., monitoring, watering). 

Each action includes a precondition to check for sufficient energy `(>= (battery ?r) cost)` and an effect that consumes energy using the `decrease` operator. To model battery replenishment, a `recharge` action is restricted to the Dock location, utilizing the `assign` operator to instantaneously reset the battery level to its maximum capacity. This constraint-based abstraction successfully forces the planner to account for energy limits and schedule explicit recharge actions when a naive shortest-path plan fails.

###  Project Structure
- `/docs`: Contains the mathematical and logical modeling of the field (`field_model.md`).
- `/domain`: Contains the discrete domain file (`domain.pddl`).
- `/problems`: Contains the problem instances (`p1.pddl` for sufficient energy, `p2.pddl` for forced recharge).
- `/plans`: Contains the generated plans validated by VAL.

###  How to Run (Planning)
To generate the plans using **ENHSP**, run the following commands from the root directory:

**Problem 1 (Energy is sufficient):**
```bash
java -jar tools/enhsp/enhsp-dist/enhsp.jar -o domain/domain.pddl -f problems/p1.pddl
```
**Problem 2 (Recharge is required):**

```bash
java -jar tools/enhsp/enhsp-dist/enhsp.jar -o domain/domain.pddl -f problems/p2.pddl
```
### Plan Validation (VAL)
Both generated plans have been successfully validated using the VAL tool. To verify the plans, execute:

**Validate Plan 1:**

```bash
"/c/Users/bahri/AppData/Roaming/Code/User/globalStorage/jan-dolejsi.pddl/val/Val-20210401.1-win64/bin/Validate.exe" domain/domain.pddl problems/p1.pddl plans/plan1.txt
```
**Validate Plan 2:**

```bash
"/c/Users/bahri/AppData/Roaming/Code/User/globalStorage/jan-dolejsi.pddl/val/Val-20210401
```
