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

(define (projection indices table)
  (let ([proj-single (lambda (r)
                       (map (lambda (i)
                              (list-ref r i))
                            indices))])
    (map (lambda (p)
           (cons (proj-single (car p)) (cdr p)))
         table)))