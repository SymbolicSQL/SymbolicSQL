#lang rosette

(require "evaluator.rkt")

(provide queries test-table test-table1)

(define test-table
  (list
    (cons (list 1 1 2) 2)
    (cons (list 0 1 2) 2)	          
    (cons (list 1 2 1) 1)
    (cons (list 2 1 0) 3)))

(define test-table1
  (list
    (cons (list 1 1 2) 2)
    (cons (list 1 1 2) 2)
    (cons (list 0 1 2) 2)	          
    (cons (list 1 2 1) 1)
    (cons (list 1 2 3) 1)
    (cons (list 2 1 0) 3)))

; SELECT *
; FROM table
; WHERE c0 < c1 
;	AND c1 < c2 
(define q1 (lambda (content) 
     (filter 
	(lambda (t) 
	  (let ([ct (car t)])
	    (and 
	      (< (list-ref ct 0) (list-ref ct 1))
	      (< (list-ref ct 1) (list-ref ct 2))))) 
	content))
  )

; SELECT *
; FROM table
; WHERE c1 < c2
; 	AND c1 >= c0
(define q2 
  (lambda (content)
     (filter 
       (lambda (t) 
	 (let ([ct (car t)])
	   (and 
	     (< (list-ref ct 1) (list-ref ct 2))
	     (>= (list-ref ct 1) (list-ref ct 0)))))
       content))
  )

(define (flatten-once lst)
      (apply append lst))

; subquery:
; SELECT c2
; FROM table
; WHERE c0 = [0]
; 	AND c1 = [1]
(define q3-subquery
  (lambda (content c0 c1)
    (projection
      (list 2)
      (filter 
      	(lambda (t)
	  (let ([ct (car t)])
	    (and 
	      (eq? (list-ref ct 0) c0)
	      (eq? (list-ref ct 1) c1))))
      content))))

; SELECT c1, c2, MAX(subquery)
(define q3
  (lambda (content)
    (dedup 
      (map (lambda (p)
	(cons 
	  (append (car p) 
	    (list 
	      (apply 
		max 
		(flatten-once 
		  (map (lambda (t) (car t))
		       (q3-subquery content (list-ref (car p) 0) (list-ref (car p) 1))))))) 
	    (cdr p)))
	content))))

(define queries (list q1 q2 q3))

