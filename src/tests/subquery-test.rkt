#lang rosette                                                                                                                                                 

(require "../table.rkt" "../sql.rkt" "../evaluator.rkt" "../equal.rkt")

(define (same q1 q2)
    (assert (bag-equal (get-content (run q1)) (get-content (run q2)))))

(define (sv)
     (define-symbolic* y integer?) ; creates a different constant when evaluated
         y)

(define sym-content
    (list
      (cons (list (sv) (sv) (sv)) (sv))
      (cons (list (sv) (sv) (sv)) (sv))))

(define content
    (list
      (cons (list 1 1 2) 2)
      (cons (list 0 1 2) 2)                 
      (cons (list 1 2 1) 1)
      (cons (list 2 1 0) 3)))

; (define sym-content (gen-sym-schema 3 5))

(define symbolic-t1 (Table "t1" (list "c1" "c2" "c3") sym-content))    
(define symbolic-t2 (Table "t2" (list "c4" "c5" "c6") sym-content))    

(define t1 (Table "t1" (list "c1" "c2" "c3") content))
(define t2 (Table "t2" (list "c4" "c5" "c6") content))

(define q1
    (SELECT (VALS "t1.c1" "t1.c2" "t1.c3" "t3.c4" "t3.c5" "t3.c6")
       FROM (JOIN (NAMED symbolic-t1) 
		   (AS (SELECT  (VALS "t2.c4" "t2.c5" "t2.c6")
			FROM  (NAMED symbolic-t2)				                     
			WHERE (AND (BINOP "t2.c5" >= "t2.c4") (BINOP "t2.c5" <= "t2.c6"))) ["t3" (list "c4" "c5" "c6")]))
      WHERE (BINOP "t1.c1" eq? "t3.c4")))

(define q2
  (SELECT (VALS "t1.c1" "t1.c2" "t1.c3" "t2.c4" "t2.c5" "t2.c6")
     FROM (JOIN (NAMED symbolic-t1) (NAMED symbolic-t2))
    WHERE (AND (BINOP "t1.c1" eq? "t2.c4") (AND (BINOP "t2.c5" >= "t2.c4") (BINOP "t2.c5" <= "t2.c6")))))

(run q1)
(run q2)

(verify (same q1 q2))
