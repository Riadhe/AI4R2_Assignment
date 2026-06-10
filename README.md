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

In this baseline model, energy is abstracted as a discrete numeric fluent. Actions dynamically subtract predefined energy costs based on operation weights and terrain types.

⚠️ **Note:** *For the complete theoretical model, PDDL abstraction details, energy traces, and VAL validation, please refer to the **Project Report**.*
👉 *For the field topology and math rationale, see [docs/field_model.md](./docs/field_model.md).*

### Execution Commands & Outputs
Run the following commands from the repository root using Git Bash:

### 1. Problem 1 (Baseline - Feasible on a single charge)
Tests a lightweight mission (monitor P1, water P2) over flat terrain.
```bash
java -jar "tools/enhsp/enhsp-dist/enhsp.jar" -o "domain/Q1_domain.pddl" -f "problems/Q1_problem1.pddl" -s gbfs
```
**Goal:** `(monitored P1) ∧ (watered P2) ∧ (robot-at Dock)`
**Result:** The robot completes the 6-step mission on a single charge (consumes 60/100 energy units) without needing to recharge.
### 2. Problem 2 (Energy Bottleneck - Recharge Required)
Tests a heavy mission (fertilize P3, harvest P4) forcing the robot to cross the highly expensive muddy path.

```Bash
java -jar "tools/enhsp/enhsp-dist/enhsp.jar" -o "domain/Q1_domain.pddl" -f "problems/Q1_problem2.pddl" -s gbfs
```
**Goal:** `(fertilized P3) ∧ (harvested P4) ∧ (robot-at Dock)`
**Result:** The planner detects a dead-end on the direct route due to the 100-unit battery limit, autonomously inserts a recharge action at the Dock mid-mission, and outputs an 11-step plan.
##  Q2: Continuous Time Model (PDDL+)

In this advanced formulation, the discrete energy jumps from Q1 are replaced with continuous temporal dynamics. Energy is consumed over time via PDDL+ `process` constructs (e.g., navigating a muddy path drains energy at a continuous rate per second). We also introduced autonomous `events` to handle battery overcharge protection.

⚠️ **Note:** *For the full PDDL+ architecture, timeline analysis, and algorithm benchmarking (A\* vs GBFS), please refer to the **Project Report**.*

### Execution Commands & Experiments
Run the following commands to test the different continuous time scenarios. 

### Experiment 1: Continuous Baseline
Testing basic continuous execution with wait times and flat terrain.
```bash
java -jar "tools/enhsp/enhsp-dist/enhsp.jar" -o "domain/Q2_domain.pddl" -f "problems/Q2_exp1.pddl" -s gbfs
```
**Result:** The robot completes the mission while continuously draining energy based on the duration of its moves and operations.

### Experiment 2: The Recharge Event
Testing battery replenishment and the autonomous stop-overcharge event.

```Bash
java -jar "tools/enhsp/enhsp-dist/enhsp.jar" -o "domain/Q2_domain.pddl" -f "problems/Q2_exp2.pddl" -s gbfs
```
**Result:** The robot halts at the dock to charge. The background PDDL+ event successfully clips the battery at 100 max capacity, allowing the mission to resume safely.

### Experiment 3: Route Planning (Muddy vs Flat)
Forcing the planner to choose between a short, continuous high-drain path (Muddy) and a longer, low-drain path (Flat Detour via W1).

```Bash
java -jar "tools/enhsp/enhsp-dist/enhsp.jar" -o "domain/Q2_domain.pddl" -f "problems/Q2_exp3.pddl" -s gbfs
```
**Result:** The planner autonomously avoids the muddy path to prevent fatal energy drain, opting for the safer W1 waypoint.

### Experiment 4: Algorithm Benchmarking (GBFS vs A*)
Comparing Sub-optimal greedy search vs Optimal search on a complex continuous problem.

Run with GBFS (Fast but sub-optimal):

```Bash
java -jar "tools/enhsp/enhsp-dist/enhsp.jar" -o "domain/Q2_domain.pddl" -f "problems/Q2_exp4.pddl" -s gbfs
```
Run with Weighted A* (Slower but optimal duration):

```Bash
java -jar "tools/enhsp/enhsp-dist/enhsp.jar" -o "domain/Q2_domain.pddl" -f "problems/Q2_exp4.pddl" -s wa-star
```
**Result:** WA* yields a tighter schedule with minimized idle times compared to GBFS, proving the efficacy of optimal search in continuous domains.

---
## 📄 Detailed Analysis & Report

This README serves as the execution manual. For the comprehensive academic analysis, please refer to the **Project Report**. The report includes the mathematical models of the field, step-by-step energy traces, and an in-depth discussion covering:

* **Discrete vs. continuous energy modelling.**
* **The interaction between route planning and resource management.**
* **Why energy constraints are central in long-horizon robotic autonomy.**

👉 **Read the full project report here: [AI4R2_Assignment_Report.pdf](./AI4R2_Project_Report.pdf)** 
