> **Files to grade — PDDL (Q1):** `codes/domain/Q1_domain.pddl` + `codes/problems/Q1_problem1.pddl`, `Q1_problem2.pddl` · **PDDL+ (Q2):** `codes/domain/Q2_domain.pddl` + `codes/problems/Q2_problem1.pddl`, `Q2_problem2.pddl`, `Q2_problem3.pddl`. Plan outputs are in `codes/plans/`. These are the final, correct versions.

#  Agricultural Robotics – Energy Constrained Field Operations🚜⚡

**Course:** Artificial Intelligence for Robotics II (AI4R2)  
**Author:** Bahri Riadh

##  Project Overview
This project models a single mobile agricultural robot operating on a small field of four plots and one docking station. Each plot has exactly one operation that has to be performed there (monitoring, watering, fertilising, or harvesting), and the robot consumes energy on every move and every operation. The only place to refill the battery is the dock. The job of the planner is to find a sequence of actions that satisfies the farming goals without ever running the battery flat.


The project is structured into two main parts:
1. **Q1: Discrete Numeric Model**
2. **Q2: Continuous Time Model (PDDL+)**

---
## 📂 Repository Architecture
```text
📦 AI4R2_Assignment
 ┣ 📂 codes
 ┃   ┣ 📂 domain      # PDDL domain files (Q1_domain.pddl, Q2_domain.pddl)
 ┃   ┣ 📂 problems    # PDDL problem files (Q1_problem1/2, Q2_problem1/2/3)
 ┃   ┗ 📂 plans       # Generated execution plans (Q1_plan1/2, Q2_plan1/2/3)
 ┣ 📂 Report
 ┃   ┗ 📜 AI4R2_Project_Report.pdf   # Full report
 ┣ 📂 slide          # Presentation slides
 ┗ 📜 README.md       # Project execution guide and results summary
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

*Note: Once Java and ENHSP are set up, all execution commands in this README can be run directly as a single line in Git Bash. The commands below assume `enhsp.jar` sits in the repository root — adjust the path if your jar lives elsewhere.*

---


##  Q1: Discrete Numeric Model

In this baseline model, energy is abstracted as a discrete numeric fluent. Actions subtract predefined energy costs based on operation weights and edge costs, and the load carried by the robot adds to every move.

⚠️ **Note:** *For the complete theoretical model, PDDL abstraction details, energy traces, and VAL validation, please refer to the **Project Report**.*

### Execution Commands & Outputs
Run the following commands from the repository root using Git Bash:

### 1. Problem 1 (Baseline - Feasible on a single charge)
Tests a lightweight mission (monitor P1, water P2) over low-cost edges.
```bash
java -jar "enhsp.jar" -o "codes/domain/Q1_domain.pddl" -f "codes/problems/Q1_problem1.pddl" -s gbfs
```
**Goal:** `(monitored P1) ∧ (watered P2) ∧ (robot-at r1 D)`
**Result:** The robot completes the mission on a single charge (final battery 25/100) without needing to recharge.

### 2. Problem 2 (Recharge Required)
Tests a heavy mission (fertilize P3, harvest P4). The round trip exceeds the 100-unit battery, so the goal is **unreachable without recharging**.

```bash
java -jar "enhsp.jar" -o "codes/domain/Q1_domain.pddl" -f "codes/problems/Q1_problem2.pddl" -s gbfs
```
**Goal:** `(fertilized P3) ∧ (harvested P4) ∧ (robot-at r1 D)`
**Result:** The planner cannot reach the goal on the direct route under the 100-unit battery limit, so it autonomously inserts a `recharge` action at the Dock mid-mission and outputs an 11-step plan.

##  Q2: Continuous Time Model (PDDL+)

In this advanced formulation, the discrete energy jumps from Q1 are replaced with continuous temporal dynamics. Energy is consumed over time via PDDL+ `process` constructs (e.g., navigating a muddy path drains energy at a continuous rate per second). We also introduced autonomous `events`: one clips the battery at maximum capacity during recharge, and one fires on critical battery depletion.

⚠️ **Note:** *For the full PDDL+ architecture and timeline analysis, please refer to the **Project Report**.*

### Execution Commands & Experiments
Run the following commands to test the different continuous time scenarios. 

### Problem 1: Continuous Baseline
Testing basic continuous execution with start/stop actions, timed processes, and flat terrain.
```bash
java -jar "enhsp.jar" -o "codes/domain/Q2_domain.pddl" -f "codes/problems/Q2_problem1.pddl" -s gbfs
```
**Goal:** `(monitored P1) ∧ (watered P2) ∧ (robot-at r1 D) ∧ (not (depleted r1))`
**Result:** The robot completes the mission while continuously draining energy based on the duration of each move and operation, finishing with 45 units left.

### Problem 2: Muddy Mission & Recharge
Testing a heavy mission (fertilize P3, harvest P4) across muddy edges, where the continuous high-drain rate forces a recharge at the dock before the mission can complete.

```bash
java -jar "enhsp.jar" -o "codes/domain/Q2_domain.pddl" -f "codes/problems/Q2_problem2.pddl" -s gbfs
```
**Goal:** `(fertilized P3) ∧ (harvested P4) ∧ (robot-at r1 D) ∧ (not (depleted r1))`
**Result:** The robot drains heavily on the muddy legs, returns to the dock, and recharges via the continuous `recharge-battery` process. The `stop-overcharge` event clips the battery at 100 max capacity, allowing the mission to resume safely.

### Problem 3: Route Planning (Muddy vs Flat Detour)
Forcing the planner to weigh a short high-drain muddy edge against a longer low-drain flat path via waypoint W1.

```bash
java -jar "enhsp.jar" -o "codes/domain/Q2_domain.pddl" -f "codes/problems/Q2_problem3.pddl" -s gbfs
```
**Goal:** `(harvested P1) ∧ (robot-at r1 D) ∧ (not (depleted r1))`
**Result:** Minimizing total time, the planner takes the fast muddy edge inbound (while the robot is light) and the flat W1 detour outbound (once the harvested load makes muddy travel costlier), surviving with 5 units to spare. The same edge thus carries a different energy cost depending on duration and load — the defining feature of the continuous model.

---
## 📄 Detailed Analysis & Report

This README serves as the execution manual. For the comprehensive academic analysis, see **[Report/AI4R2_Project_Report.pdf](./Report/AI4R2_Project_Report.pdf)**. The report covers:

* **Discrete vs. continuous energy modelling.**
* **The interaction between route planning and resource management.**
* **Why energy constraints are central in long-horizon robotic autonomy.**
