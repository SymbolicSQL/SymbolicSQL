#lang rosette                                                                                                                                                 

(require "../table.rkt" "../sql.rkt")

(define content
    (list
      (cons (list 1 1 2) 2)
      (cons (list 0 1 2) 2)                 
      (cons (list 1 2 1) 1)
      (cons (list 2 1 0) 3)))

(define t1 (Table "t1" (list "c1" "c2" "c3") content))
(define t2 (Table "t2" (list "c4" "c5" "c6") content))

(define q1
    (SELECT (VALS "t1.c1" "t1.c2" "t1.c3" "t3.c4" "t3.c5" "t3.c6")
       FROM (JOIN (NAMED t1) 
		   (AS (SELECT  (VALS "t2.c4" "t2.c5" "t2.c6")
			FROM  (NAMED t2)				                     
			WHERE (AND (BINOP "t2.c5" >= "t2.c4") (BINOP "t2.c5" <= "t2.c6"))) ["t3" (list "c4" "c5" "c6")]))
      WHERE (BINOP "t1.c1" eq? "t3.c4")))

(define q2
  (SELECT (VALS "t1.c1" "t1.c2" "t1.c3" "t2.c4" "t2.c5" "t2.c6")
     FROM (JOIN (NAMED t1) (NAMED t2))
    WHERE (AND (BINOP "t1.c1" eq? "t2.c4") (AND (BINOP "t2.c5" >= "t2.c4") (BINOP "t2.c5" <= "t2.c6")))))

(run q1)
(run q2)
