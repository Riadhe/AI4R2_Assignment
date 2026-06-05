# Field Model — Q1 (Discrete Numeric PDDL)

## Overview

This is the field model for Q1 of the D5-V8 assignment. A single mobile agricultural robot operates on a small field made of four plots and one docking station. Each plot needs exactly one operation (monitor, water, fertilize, or harvest). The robot consumes energy when moving between locations and when performing operations; it can refill its battery only at the dock. This Q1 model uses discrete numeric PDDL — energy is tracked as a numeric fluent and every action changes it in a single instantaneous jump.

## Locations

Five locations in total:

- **D** — docking station. The robot starts here. It is the only place where recharging is possible.
- **P1** — plot that needs monitoring.
- **P2** — plot that needs watering.
- **P3** — plot that needs fertilizing.
- **P4** — plot that needs harvesting.

## Edges and terrain

Edges are bidirectional. Move-cost is the energy spent crossing one edge in one direction.

| edge     | terrain | move-cost |
| -------- | ------- | --------- |
| D – P1   | flat    | 10        |
| D – P2   | flat    | 10        |
| P1 – P3  | rough   | 20        |
| P2 – P4  | rough   | 20        |
| P3 – P4  | muddy   | 30        |

The graph has two branches from the dock: P1 ↔ P3 on one side and P2 ↔ P4 on the other. The muddy edge P3 – P4 connects the two branches but is the most expensive way to cross between them. This shape forces the planner to choose between alternative routes, which is what makes the recharge story in Problem 2 non-trivial.

## Numeric fluents

Two numeric fluents on the robot:

- `(battery ?r)` — current energy level. Initial value: 100.
- `(capacity ?r)` — maximum the battery can hold. Set to 100.

Two static numeric functions that hold per-edge and per-operation constants:

- `(move-cost ?from ?to)` — energy cost of moving along an edge (values come from the edge table above).
- `(op-cost ?op-type)` — energy cost of performing an operation (values in the next section).

Load-dependent consumption is not modelled in Q1. The assignment marks load as optional; it may be added in Q2.

## Operations

Each plot has exactly one operation that must be performed at it.

| plot | operation | op-cost | completion flag      |
| ---- | --------- | ------- | -------------------- |
| P1   | monitor   | 5       | `(monitored P1)`     |
| P2   | water     | 15      | `(watered P2)`       |
| P3   | fertilize | 20      | `(fertilized P3)`    |
| P4   | harvest   | 25      | `(harvested P4)`     |

Op-costs increase with the physical weight of the operation: monitoring uses sensors only, harvesting needs mechanical actuators.

## Design choices

- **Battery = 100** chosen for clean mental arithmetic; lets us tune costs in the 5–30 range without fractions.
- **Terrain ratios ~1 : 2 : 3** (flat 10, rough 20, muddy 30) so terrain genuinely affects plan cost rather than being decoration.
- **Two-branch topology** (not a star, not a chain) so the planner has alternative routes and edge terrain is a real decision variable.
- **One operation per plot** keeps the model defendable in a single sentence per plot.
- **p1 goal at the cheap plots, p2 goal at the expensive ones** so the contrast between "fits on one charge" and "requires recharge" is sharp.

## Problem 1 — feasible without recharge

**Initial state.** Robot at D, `(battery robot) = 100`, no operation completed.

**Goal.** `(monitored P1) ∧ (watered P2) ∧ (robot-at D)`.

**Cheapest plan, energy budget:**

```
D → P1   :  10
monitor  :   5
P1 → D   :  10
D → P2   :  10
water    :  15
P2 → D   :  10
-----------------
total    :  60
```

Battery at the end: 100 − 60 = 40. Since 60 < 100, the robot completes both operations on a single charge — **no recharge needed**.

## Problem 2 — recharge required

**Initial state.** Robot at D, `(battery robot) = 100`, no operation completed.

**Goal.** `(fertilized P3) ∧ (harvested P4) ∧ (robot-at D)`.

**Cheapest direct plan (no recharge):**

```
D → P1 → P3  :  10 + 20 = 30
fertilize    :  20
P3 → P4      :  30
harvest      :  25
P4 → P2 → D  :  20 + 10 = 30
-------------------------
total        : 135
```

135 > 100, so the robot cannot complete this plan on a single charge. Every alternative route also exceeds 100, because crossing between the two branches without going through the dock requires the muddy edge plus the rough edges on each side. **The plan is infeasible without a recharge.**

**Plan with one recharge (one of several valid orderings):**

```
D → P1 → P3      :  30        (battery: 100 → 70)
fertilize        :  20        (battery:  70 → 50)
P3 → P1 → D      :  30        (battery:  50 → 20)
recharge         :   —        (battery:  20 → 100)
D → P2 → P4      :  30        (battery: 100 → 70)
harvest          :  25        (battery:  70 → 45)
P4 → P2 → D      :  30        (battery:  45 → 15)
```

The robot finishes at the dock with 15 energy remaining. The recharge in the middle is what makes the plan valid — no segment between full-charges exceeds the capacity of 100.

## Summary

- p1 fits comfortably on one charge (cheapest plan uses 60 energy).
- p2 cannot fit on one charge (cheapest direct plan is 135 energy) and requires the planner to insert a recharge action at the dock mid-mission.
- The contrast between p1 and p2 demonstrates the core point of Q1: energy is a numeric resource the planner must reason about, not just a constraint on which actions are reachable.