#lang rosette

(require "../table.rkt" "../sql.rkt" "../evaluator.rkt" "../equal.rkt")

(define (same q1 q2)
    (assert (bag-equal (get-content (run q1)) (get-content (run q2)))))



(define t1 (Table "t1" (list "c1" "c2" "c3") (gen-sym-schema 3 3)))

(define (aggr-sum l) 
  (foldl + 0 l))

(define subq-aggr
  (SELECT (VALS "t1.c1" (AGGR aggr-sum 
			      (SELECT (VALS "t2.c3")
				 FROM (AS (NAMED t1) ["t2" (list "c1" "c2" "c3")])
				 WHERE (BINOP "t2.c1" = "t1.c1"))))
     FROM (NAMED t1)))

; commutativity of selection query 1

; commutativity of selection query 2

;(verify (same selection-commute-q1 selection-commute-q2))
