(define (problem q2-p3)
  (:domain agri-continuous)
  
  (:objects
    r1 - robot
    D W1 P1 - location
  )
  
  (:init
    (robot-at r1 D)
    (is-dock D)

    ;; Operation needed
    (needs-harvest P1)

    ;; Graph connections
    (connected D P1) (connected P1 D)       ; Direct short path
    (connected D W1) (connected W1 D)       ; Detour path part 1
    (connected W1 P1) (connected P1 W1)     ; Detour path part 2

    ;; Terrain Types (The Trap)
    (muddy D P1) (muddy P1 D)               ; Short but drains battery heavily
    (flat D W1) (flat W1 D)                 ; Long but safe
    (flat W1 P1) (flat P1 W1)               ; Long but safe

    ;; Initial Numeric Values
    (= (battery r1) 100.0)
    (= (capacity r1) 100.0)
    (= (time-spent r1) 0.0)

    ;; Move Times (Durations)
    (= (move-time D P1) 4.0) (= (move-time P1 D) 4.0)       ; 4 secs (Muddy = 60 energy)
    (= (move-time D W1) 2.0) (= (move-time W1 D) 2.0)       ; 2 secs (Flat = 10 energy)
    (= (move-time W1 P1) 3.0) (= (move-time P1 W1) 3.0)     ; 3 secs (Flat = 15 energy)

    ;; Operation Times
    (= (op-time-monitor) 1.0)
    (= (op-time-water) 3.0)
    (= (op-time-fertilize) 4.0)
    (= (op-time-harvest) 5.0)                               ; 5 secs (Flat = 25 energy)
  )
  
  (:goal (and
    (harvested P1)
    (robot-at r1 D)
    (not (depleted r1)) ; Must survive
  ))
)