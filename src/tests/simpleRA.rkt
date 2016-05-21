#lang rosette

(require "../table.rkt" "../sql.rkt" "../evaluator.rkt" "../equal.rkt")

(define content
    (list
      (cons (list 1 1 2) 2)
      (cons (list 0 1 2) 2)                 
      (cons (list 1 2 1) 1)
      (cons (list 2 1 0) 3)))

(define t1 (Table "t1" (list "c1" "c2" "c3") content))

; commutativity of selection query 1
(define selection-commute-q1
  (SELECT (VALS "t2.c1" "t2.c2" "t2.c3")
          FROM  (AS (SELECT (VALS "t1.c1" "t1.c2" "t1.c3")
                                FROM (NAMED t1)
                                WHERE (BINOP "t1.c1" < "t1.c2"))
                    ["t2" (list "c1" "c2" "c3")])
          WHERE  (BINOP "t2.c1" < "t2.c3")))

; commutativity of selection query 2
(define selection-commute-q2
    (SELECT (VALS "t1.c1" "t1.c2" "t1.c3")
	       FROM   (NAMED t1)
               WHERE  (AND (BINOP "t1.c1" < "t1.c2") (BINOP "t1.c1" < "t1.c3"))))

(run selection-commute-q1)
(run selection-commute-q2)


