(define (problem p2_q2)
  (:domain agri-continuous)

  (:objects
    r1 - robot
    D P1 P2 P3 P4 - location
  )

  (:init
    ;; Initial State
    (robot-at r1 D)
    (is-dock D)
    (= (battery r1) 100.0)
    (= (capacity r1) 100.0)
    (= (time-spent r1) 0.0)

    ;; Operation Requirements
    (needs-fertilize P3)
    (needs-harvest P4)

    ;; Topology (Connections)
    (connected D P1)  (connected P1 D)
    (connected D P2)  (connected P2 D)
    (connected P1 P3) (connected P3 P1)
    (connected P2 P4) (connected P4 P2)
    (connected P3 P4) (connected P4 P3)

    ;; Terrain Types
    (flat D P1) (flat P1 D)
    (flat D P2) (flat P2 D)
    
    (muddy P1 P3) (muddy P3 P1)
    (muddy P2 P4) (muddy P4 P2)

    ;; Move Times (Scaled down by 5 for faster search)
    (= (move-time D P1) 1.0)  (= (move-time P1 D) 1.0)
    (= (move-time D P2) 1.0)  (= (move-time P2 D) 1.0)
    (= (move-time P1 P3) 2.0) (= (move-time P3 P1) 2.0)
    (= (move-time P2 P4) 2.0) (= (move-time P4 P2) 2.0)
    (= (move-time P3 P4) 3.0) (= (move-time P4 P3) 3.0)

    ;; Operation Times (Scaled down by 5)
    (= (op-time-monitor) 1.0)
    (= (op-time-water) 3.0)
    (= (op-time-fertilize) 4.0)
    (= (op-time-harvest) 5.0)
  )

  (:goal (and
    (fertilized P3)
    (harvested P4)
    (robot-at r1 D)
    (not (depleted r1)) ; Safety constraint
  ))
)