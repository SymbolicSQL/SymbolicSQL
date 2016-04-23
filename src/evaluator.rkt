#lang rosette/safe

(define (dedup table)
  (cond 
    [(eq? '() table) '()]
    [else 
      (let ([ele (car table)])
	(cons (cons (car ele) 1)
	      (dedup 
		(filter 
		  (lambda (x)
		    (not (eq? (car ele) (car x))))
		  (cdr table)))))]))
