(define (domain agri-continuous)
  (:requirements :typing :numeric-fluents :continuous-effects :time :negative-preconditions)
  
  (:types robot location)
  
  (:predicates
    (robot-at ?r - robot ?l - location)
    (connected ?l1 ?l2 - location)
    (is-dock ?l - location)
    (flat ?l1 ?l2 - location)
    (muddy ?l1 ?l2 - location)
    
    (needs-monitor ?l - location)
    (needs-water ?l - location)
    (needs-fertilize ?l - location)
    (needs-harvest ?l - location)
    
    (monitored ?l - location)
    (watered ?l - location)
    (fertilized ?l - location)
    (harvested ?l - location)
    
    ;; Flags State
    (moving ?r - robot)
    (operating ?r - robot)
    (recharging ?r - robot)
    (depleted ?r - robot)

    ;; Memory Flags 
    (going ?r - robot ?from ?to - location)
    (doing-monitor ?r - robot ?l - location)
    (doing-water ?r - robot ?l - location)
    (doing-fertilize ?r - robot ?l - location)
    (doing-harvest ?r - robot ?l - location)
  )
  
  (:functions
    (battery ?r - robot)
    (capacity ?r - robot)
    (time-spent ?r - robot) 
    
    (move-time ?from ?to - location)
    (op-time-monitor)
    (op-time-water)
    (op-time-fertilize)
    (op-time-harvest)
  )

  ;; =========================================================
  ;; NAVIGATION (Start & Stop)
  ;; =========================================================

  (:action start-move
    :parameters (?r - robot ?from ?to - location)
    :precondition (and
      (robot-at ?r ?from)
      (connected ?from ?to)
      (not (moving ?r))
      (not (operating ?r))
      (not (recharging ?r))
      (not (depleted ?r))
    )
    :effect (and
      (not (robot-at ?r ?from))
      (moving ?r)
      (going ?r ?from ?to)
      (assign (time-spent ?r) 0) 
    )
  )

  (:action stop-move
    :parameters (?r - robot ?from ?to - location)
    :precondition (and
      (moving ?r)
      (going ?r ?from ?to)
      (>= (time-spent ?r) (move-time ?from ?to)) 
    )
    :effect (and
      (not (moving ?r))
      (not (going ?r ?from ?to))
      (robot-at ?r ?to)
    )
  )

  ;; =========================================================
  ;; OPERATIONS (Start & Stop)
  ;; =========================================================

  (:action start-monitor
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (needs-monitor ?l)
      (not (moving ?r))
      (not (operating ?r))
      (not (depleted ?r))
      (not (recharging ?r))
    )
    :effect (and
      (operating ?r)
      (doing-monitor ?r ?l)
      (assign (time-spent ?r) 0)
    )
  )

  (:action stop-monitor
    :parameters (?r - robot ?l - location)
    :precondition (and
      (operating ?r)
      (doing-monitor ?r ?l)
      (>= (time-spent ?r) (op-time-monitor))
    )
    :effect (and
      (not (operating ?r))
      (not (doing-monitor ?r ?l))
      (monitored ?l)
      (not (needs-monitor ?l))  ; <--- Consumed
    )
  )

  (:action start-water
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (needs-water ?l)
      (not (moving ?r))
      (not (operating ?r))
      (not (depleted ?r))
      (not (recharging ?r))
    )
    :effect (and
      (operating ?r)
      (doing-water ?r ?l)
      (assign (time-spent ?r) 0)
    )
  )

  (:action stop-water
    :parameters (?r - robot ?l - location)
    :precondition (and
      (operating ?r)
      (doing-water ?r ?l)
      (>= (time-spent ?r) (op-time-water))
    )
    :effect (and
      (not (operating ?r))
      (not (doing-water ?r ?l))
      (watered ?l)
      (not (needs-water ?l)) ; <--- Consumed
    )
  )

  (:action start-fertilize
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (needs-fertilize ?l)
      (not (moving ?r))
      (not (operating ?r))
      (not (depleted ?r))
      (not (recharging ?r))
    )
    :effect (and
      (operating ?r)
      (doing-fertilize ?r ?l)
      (assign (time-spent ?r) 0)
    )
  )

  (:action stop-fertilize
    :parameters (?r - robot ?l - location)
    :precondition (and
      (operating ?r)
      (doing-fertilize ?r ?l)
      (>= (time-spent ?r) (op-time-fertilize))
    )
    :effect (and
      (not (operating ?r))
      (not (doing-fertilize ?r ?l))
      (fertilized ?l)
      (not (needs-fertilize ?l)) ; <--- Consumed
    )
  )

  (:action start-harvest
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (needs-harvest ?l)
      (not (moving ?r))
      (not (operating ?r))
      (not (depleted ?r))
      (not (recharging ?r))
    )
    :effect (and
      (operating ?r)
      (doing-harvest ?r ?l)
      (assign (time-spent ?r) 0)
    )
  )

  (:action stop-harvest
    :parameters (?r - robot ?l - location)
    :precondition (and
      (operating ?r)
      (doing-harvest ?r ?l)
      (>= (time-spent ?r) (op-time-harvest))
    )
    :effect (and
      (not (operating ?r))
      (not (doing-harvest ?r ?l))
      (harvested ?l)
      (not (needs-harvest ?l)) ; <--- Consumed
    )
  )

  ;; =========================================================
  ;; RECHARGING
  ;; =========================================================

  (:action start-recharging
    :parameters (?r - robot ?l - location)
    :precondition (and 
      (robot-at ?r ?l) 
      (is-dock ?l) 
      (not (recharging ?r))
      (not (moving ?r))
      (not (operating ?r))
    )
    :effect (recharging ?r)
  )

  (:action stop-recharging
    :parameters (?r - robot)
    :precondition (recharging ?r)
    :effect (not (recharging ?r))
  )

  ;; =========================================================
  ;; CONTINUOUS PROCESSES (Time & Energy Dynamics)
  ;; =========================================================

  (:process process-moving-flat
    :parameters (?r - robot ?from ?to - location)
    :precondition (and 
      (moving ?r) 
      (going ?r ?from ?to) 
      (flat ?from ?to)
    )
    :effect (and
      (increase (time-spent ?r) (* #t 1.0)) 
      (decrease (battery ?r) (* #t 5.0)) 
    )
  )

  (:process process-moving-muddy
    :parameters (?r - robot ?from ?to - location)
    :precondition (and 
      (moving ?r) 
      (going ?r ?from ?to) 
      (muddy ?from ?to)
    )
    :effect (and
      (increase (time-spent ?r) (* #t 1.0)) 
      (decrease (battery ?r) (* #t 15.0)) 
    )
  )

  (:process process-operating
    :parameters (?r - robot)
    :precondition (operating ?r)
    :effect (and
      (increase (time-spent ?r) (* #t 1.0)) 
      (decrease (battery ?r) (* #t 5.0)) 
    )
  )

  (:process recharge-battery
    :parameters (?r - robot)
    :precondition (recharging ?r)
    :effect (increase (battery ?r) (* #t 25.0))
  )

  ;; =========================================================
  ;; EVENTS
  ;; =========================================================

  (:event critical-depletion
    :parameters (?r - robot)
    :precondition (and 
      (<= (battery ?r) 0)
      (not (depleted ?r)) 
    )
    :effect (and 
      (assign (battery ?r) 0)
      (depleted ?r)
    )
  )

  (:event stop-overcharge
    :parameters (?r - robot)
    :precondition (and 
      (recharging ?r) 
      (>= (battery ?r) (capacity ?r))
    )
    :effect (and 
      (assign (battery ?r) (capacity ?r))
      (not (recharging ?r))
    )
  )
)