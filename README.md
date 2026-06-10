#  Agricultural Robotics – Energy Constrained Field Operations🚜⚡

**Course:** Artificial Intelligence for Robotics II (AI4R2)  
**Author:** Bahri Riadh

##  Project Overview
This project models a single mobile agricultural robot operating on a small field of four plots and one docking station. Each plot has exactly one operation that has to be performed there (monitoring, watering, fertilising, or harvesting), and the robot consumes energy on every move and every operation. The only place to refill the battery is the dock. The job of the planner is to find a sequence of actions that satisfies the farming goals without ever running the battery flat.


The project is structured into two main parts:
1. **Q1: Discrete Numeric Model** 
2. **Q2: Continuous Time Model with PDDL+** 

---
## 📂 Repository Architecture
```text
📦 AI4R2_Assignment
 ┣ 📂 docs          # Physical world specifications (Topology, Terrain, Energy Math)
 ┣ 📂 domain        # PDDL domain files (Q1_domain.pddl, Q2_domain.pddl)
 ┣ 📂 problems      # PDDL problem files with varying difficulty
 ┣ 📂 plans         # Generated execution plans and logs
 ┗ 📜 README.md     # Project execution guide and results analysis  
```

## 🛠️ Tools & Prerequisites

To run this project, you need to set up the **ENHSP** planner. We chose ENHSP over standard classical planners (like FastDownward) simply because it natively supports both **Numeric PDDL** (required for Q1) and **Continuous PDDL+ processes and events** (required for Q2). 

| Tool | Version / Source | Role |
|------|------------------|------|
| **Java** | 17 (or compatible) | Required to run ENHSP. |
| **ENHSP** | `github.com/hstairs/enhsp` | The core planner handling numeric and continuous models. |
| **VAL** | via VS Code PDDL extension | Used for plan validation. |
| **VS Code** | + "PDDL" extension | Editor and environment setup. |
| **Git Bash** | Windows shell | Used to run the exact execution commands provided below. |

*Note: Once Java and ENHSP are set up, all execution commands in this README can be run directly as a single line in Git Bash.*

---
##  Q1: Discrete Numeric Model

In this section, we modeled the environment using classical PDDL with numeric fluents to handle the energy constraints. 

👉 *For the complete field topology, terrain classifications, and mathematical design rationale, please refer to [docs/field_model.md](./docs/field_model.md).*

### Energy Abstraction
In this discrete numeric model, the robot's energy is abstracted using PDDL `numeric-fluents`. The current battery level and maximum capacity are defined as numeric variables `(battery ?r)` and `(capacity ?r)`. Energy consumption is discretized by assigning specific constant costs to movements (depending on terrain difficulty: flat, rough, or muddy) and to agricultural operations (e.g., monitoring, watering). 

Each action includes a precondition to check for sufficient energy `(>= (battery ?r) cost)` and an effect that consumes energy using the `decrease` operator. To model battery replenishment, a `recharge` action is restricted to the Dock location, utilizing the `assign` operator to instantaneously reset the battery level to its maximum capacity. This constraint-based abstraction successfully forces the planner to account for energy limits and schedule explicit recharge actions when a naive shortest-path plan fails.

### Execution Commands & Scenarios

Run the following commands from the repository root using Git Bash:

**1. Problem 1 (Baseline - Feasible on a single charge):**
Tests a lightweight mission (monitor P1, water P2) over flat terrain.
```bash
java -jar "tools/enhsp/enhsp-dist/enhsp.jar" -o "domain/Q1_domain.pddl" -f "problems/Q1_problem1.pddl" -s gbfs
```
### 📊 Results & Discussion

#### 1. Problem 1: The Baseline (Single Charge Mission)
**Goal:** `(monitored P1) ∧ (watered P2) ∧ (robot-at Dock)`

**Analysis:** 
This scenario establishes the baseline functionality of the navigation and discrete energy systems. The planner successfully finds a direct, sequential route to complete the mission. Because the required operations are lightweight (monitoring and watering) and the connecting paths are flat (`Dock <-> P1` and `Dock <-> P2`), the energy constraints are never violated.

**Energy Breakdown:**
* `move Dock P1` (flat): -10 
* `monitor P1`: -5 
* `move P1 Dock` (flat): -10 
* `move Dock P2` (flat): -10 
* `water P2`: -15 
* `move P2 Dock` (flat): -10 
* **Total Energy Consumed:** 60 units.

Since 60 is well below the maximum capacity of 100, the robot completes the entire 6-step mission efficiently on a single charge without needing to trigger a `recharge` action.

![Plan Output for Problem 1](./Q1_P1_plan.png)
