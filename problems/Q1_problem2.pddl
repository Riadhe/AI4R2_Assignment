(define (problem p2)
  (:domain agri-energy)

  (:objects
    r1 - robot
    D P1 P2 P3 P4 - location
  )

  (:init
    (robot-at r1 D)
    (is-dock D)
    
    (needs-fertilize P3)
    (needs-harvest P4)

    (connected D P1)  (connected P1 D)
    (connected D P2)  (connected P2 D)
    (connected P1 P3) (connected P3 P1)
    (connected P2 P4) (connected P4 P2)
    (connected P3 P4) (connected P4 P3)

    (= (battery r1) 100)
    (= (capacity r1) 100)

    (= (move-cost D P1) 10)  (= (move-cost P1 D) 10)
    (= (move-cost D P2) 10)  (= (move-cost P2 D) 10)
    (= (move-cost P1 P3) 20) (= (move-cost P3 P1) 20)
    (= (move-cost P2 P4) 20) (= (move-cost P4 P2) 20)
    (= (move-cost P3 P4) 30) (= (move-cost P4 P3) 30)

    (= (op-cost-monitor) 5)
    (= (op-cost-water) 15)
    (= (op-cost-fertilize) 20)
    (= (op-cost-harvest) 25)
  )

  (:goal (and
    
    (fertilized P3)
    (harvested P4)
    (robot-at r1 D)
  ))
)