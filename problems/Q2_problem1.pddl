(define (problem q2-p1)
  (:domain agri-continuous)
  
  (:objects
    r1 - robot
    D P1 P2 P3 P4 - location
  )
  
  (:init
    (robot-at r1 D)
    (is-dock D)

    ;; 1. Flags for needed operations (The "Consume" logic)
    (needs-monitor P1)
    (needs-water P2)

    ;; 2. Graph connections
    (connected D P1) (connected P1 D)
    (connected D P2) (connected P2 D)
    (connected P1 P3) (connected P3 P1)
    (connected P2 P4) (connected P4 P2)

    ;; 3. Terrain Types (All flat for easy traversal)
    (flat D P1) (flat P1 D)
    (flat D P2) (flat P2 D)
    (flat P1 P3) (flat P3 P1)
    (flat P2 P4) (flat P4 P2)

    ;; 4. Initial Numeric Values
    (= (battery r1) 100.0)
    (= (capacity r1) 100.0)
    (= (time-spent r1) 0.0)
    (= (load r1) 5.0) ;; <--- Zidneha houni

    ;; 5. Move Times (Durations)
    (= (move-time D P1) 1.0) (= (move-time P1 D) 1.0)
    (= (move-time D P2) 1.0) (= (move-time P2 D) 1.0)
    (= (move-time P1 P3) 2.0) (= (move-time P3 P1) 2.0)
    (= (move-time P2 P4) 3.0) (= (move-time P4 P2) 3.0)

    ;; 6. Operation Times
    (= (op-time-monitor) 1.0)
    (= (op-time-water) 3.0)
    (= (op-time-fertilize) 4.0)
    (= (op-time-harvest) 5.0)
  )
  
  (:goal (and
    (monitored P1)
    (watered P2)
    (robot-at r1 D)
    (not (depleted r1)) ; Safety constraint
  ))
(:metric minimize (total-time))

)