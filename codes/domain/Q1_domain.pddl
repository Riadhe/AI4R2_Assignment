;; Q1 - agri-energy domain (discrete numeric PDDL)
;; one mobile robot, four plots, one dock. battery is a numeric fluent.

(define (domain agri-energy)

  (:requirements :strips :typing :numeric-fluents)

  (:types robot location)


  ;; ------- predicates -------

  (:predicates
    ;; robot position. note: "robot-at" instead of "at",
    ;; because ENHSP reserves "at" as a temporal keyword.
    (robot-at ?r - robot ?l - location)

    ;; graph edges (we list both directions in the problem file)
    (connected ?l1 ?l2 - location)

    ;; flag marking the docking station(s)
    (is-dock ?l - location)

    ;; completion flags - true after each operation has been performed
    (monitored ?l - location)
    (watered ?l - location)
    (fertilized ?l - location)
    (harvested ?l - location)

    ;; requirement flags - which plot needs which operation.
    ;; set in the problem's :init, consumed by the action effect.
    (needs-monitor ?l - location)
    (needs-water ?l - location)
    (needs-fertilize ?l - location)
    (needs-harvest ?l - location)
  )


  ;; ------- numeric fluents -------

  (:functions
    ;; per-robot energy state
    (battery ?r - robot)
    (capacity ?r - robot)
    (load ?r - robot)
    ;; per-edge move cost (set in the problem file, encodes terrain)
    (move-cost ?from ?to - location)

    ;; per-operation costs (nullary functions, set as constants in the problem file)
    (op-cost-monitor)
    (op-cost-water)
    (op-cost-fertilize)
    (op-cost-harvest)
  )


  ;; ------- actions -------

  ;; move along a connected edge if there is enough battery.
  ;; spends the edge's move-cost.
  (:action move
    :parameters (?r - robot ?from ?to - location)
    :precondition (and
      (robot-at ?r ?from)
      (connected ?from ?to)
      ;; Energy needed is move-cost + current load penalty
      (>= (battery ?r) (+ (move-cost ?from ?to) (load ?r)))
    )
    :effect (and
      (not (robot-at ?r ?from))
      (robot-at ?r ?to)
      (decrease (battery ?r) (+ (move-cost ?from ?to) (load ?r)))
    )
  )

  ;; the four operations below share the same shape:
  ;;   require robot-at, the matching needs-X flag, and enough battery;
  ;;   set the completion flag, drop the needs flag, decrease battery.
  ;; only the names and costs differ.

  (:action monitor
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (needs-monitor ?l)
      (>= (battery ?r) (op-cost-monitor))
    )
    :effect (and
      (monitored ?l)
      (not (needs-monitor ?l))
      (decrease (battery ?r) (op-cost-monitor))
    )
  )

  (:action water
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (needs-water ?l)
      (>= (battery ?r) (op-cost-water))
    )
    :effect (and
      (watered ?l)
      (not (needs-water ?l))
      (decrease (battery ?r) (op-cost-water))
      (decrease (load ?r) 5) ;;  Robot becomes lighter after watering
    )
  )

  (:action fertilize
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (needs-fertilize ?l)
      (>= (battery ?r) (op-cost-fertilize))
    )
    :effect (and
      (fertilized ?l)
      (not (needs-fertilize ?l))
      (decrease (battery ?r) (op-cost-fertilize))
      (decrease (load ?r) 5) ;; Robot becomes lighter after fertilizing
    )
  )

  (:action harvest
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (needs-harvest ?l)
      (>= (battery ?r) (op-cost-harvest))
    )
    :effect (and
      (harvested ?l)
      (not (needs-harvest ?l))
      (decrease (battery ?r) (op-cost-harvest))
      (increase (load ?r) 5) ;; Robot becomes heavier after harvesting
    )
  )

  ;; recharge - only valid at the dock. resets battery to capacity
  ;; in a single discrete jump (Q1 behaviour; Q2 will use a continuous process).
  (:action recharge
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (is-dock ?l)
    )
    :effect (and
      (assign (battery ?r) (capacity ?r))
    )
  )
)