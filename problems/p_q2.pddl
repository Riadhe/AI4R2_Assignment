(define (problem p_q2_test)
  (:domain agri-continuous)
  (:objects r1 - robot)
  (:init
    (= (battery r1) 100)
  )
  (:goal (moving r1))
)