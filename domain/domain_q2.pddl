(define (domain agri-continuous)
  (:requirements :typing :numeric-fluents :time :continuous-effects)
  (:types robot)
  (:predicates
    (moving ?r - robot)
  )
  (:functions
    (battery ?r - robot)
  )

  ;; فعل عادي باش الروبوت يبدا يمشي
  (:action start-moving
    :parameters (?r - robot)
    :precondition (not (moving ?r))
    :effect (moving ?r)
  )

  ;; هوني السحر متع PDDL+ : الـ Process اللي تخدم في الخلفية (Continuous Time)
  (:process discharge
    :parameters (?r - robot)
    :precondition (moving ?r)
    :effect (decrease (battery ?r) (* #t 2.0))
  )
)