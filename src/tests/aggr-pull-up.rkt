#lang rosette

(require "test-util.rkt" "../table.rkt" "../sql.rkt" "../evaluator.rkt" "../equal.rkt")

(define (same q1 q2)
    (assert (bag-equal (get-content (run q1)) (get-content (run q2)))))



; (define t1 (Table "t1" (list "c1" "c2" "c3") (gen-sym-schema 3 3)))
(define t1 (Table "t1" (list "c1" "c2" "c3") concrete-table-3-col))

(define (aggr-sum l)
  (foldl + 0 (map (lambda (x) (* (car (car x)) (cdr x)))
       (get-content l))))

(define subq-aggr-1
  (SELECT-DISTINCT (VALS "t1.c1" (AGGR aggr-sum 
			      (SELECT (VALS "t2.c3")
				 FROM (AS (NAMED t1) ["t2" (list "c1" "c2" "c3")])
				 WHERE (BINOP "t2.c1" = "t1.c1"))))
     FROM (NAMED t1)
     WHERE (filter-empty)))

(define subq-aggr-2
  (SELECT-DISTINCT (VALS "t1.c1" (AGGR aggr-sum
			      (SELECT-DISTINCT (VALS (AGGR aggr-sum 
						  (SELECT (VALS "t3.c3")
						     FROM (AS (NAMED t1) ["t3" (list "c1" "c2" "c3")])
						     WHERE (AND (BINOP "t3.c1" = "t2.c1") (BINOP "t3.c2" = "t2.c2")))))
				 FROM (AS (NAMED t1) ["t2" (list "c1" "c2" "c3")])
				 WHERE (BINOP "t2.c1" = "t1.c1"))))
    FROM (NAMED t1)
    WHERE (filter-empty)))

(run subq-aggr-2)
(run subq-aggr-1)

; commutativity of selection query 1

; commutativity of selection query 2

;(verify (same selection-commute-q1 selection-commute-q2))
