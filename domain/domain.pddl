(define (domain agri-energy)

  (:requirements :strips :typing :numeric-fluents)

  (:types robot location)

  (:predicates
    (robot-at ?r - robot ?l - location)
    (connected ?l1 ?l2 - location)
    (is-dock ?l - location)
    (monitored ?l - location)
    (watered ?l - location)
    (fertilized ?l - location)
    (harvested ?l - location)
    (needs-monitor ?l - location)
    (needs-water ?l - location)
    (needs-fertilize ?l - location)
    (needs-harvest ?l - location)
  )

  (:functions
    (battery ?r - robot)
    (capacity ?r - robot)
    (move-cost ?from ?to - location)
    (op-cost-monitor)
    (op-cost-water)
    (op-cost-fertilize)
    (op-cost-harvest)
  )

  (:action move
    :parameters (?r - robot ?from ?to - location)
    :precondition (and
      (robot-at ?r ?from)
      (connected ?from ?to)
      (>= (battery ?r) (move-cost ?from ?to))
    )
    :effect (and
      (not (robot-at ?r ?from))
      (robot-at ?r ?to)
      (decrease (battery ?r) (move-cost ?from ?to))
    )
  )

  (:action monitor
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (needs-monitor ?l)
      (>= (battery ?r) (op-cost-monitor))
    )
    :effect (and
      (monitored ?l)
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
      (decrease (battery ?r) (op-cost-water))
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
      (decrease (battery ?r) (op-cost-fertilize))
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
      (decrease (battery ?r) (op-cost-harvest))
    )
  )

  (:action recharge
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (is-dock ?l)
    )
:effect (and (assign (battery ?r) (capacity ?r)))  )

)