#lang rosette

(require "test-util.rkt" "../table.rkt" "../sql.rkt" "../evaluator.rkt" "../equal.rkt")

(define (same q1 q2)
    (assert (bag-equal (get-content (run q1)) (get-content (run q2)))))

; (define t1 (Table "t1" (list "c1" "c2" "c3") (gen-sym-schema 3 3)))
(define ta (Table "R" (list "A" "B") concrete-table-2-col))

(define self-join-1
  (SELECT-DISTINCT (VALS "R.A" "R.B")
     FROM (NAMED ta)
     WHERE (filter-empty)))

(define self-join-2
  (SELECT-DISTINCT (VALS "X.A" "X.B")
     FROM (JOIN (AS (NAMED ta) ["X" (list "A" "B")]) 
		(AS (NAMED ta) ["Y" (list "A" "B")]))
     WHERE (AND (BINOP "X.A" = "Y.A") (BINOP "X.B" = "Y.B"))))

(run self-join-1)
(run self-join-2)

; commutativity of selection query 1

; commutativity of selection query 2

;(verify (same selection-commute-q1 selection-commute-q2))
