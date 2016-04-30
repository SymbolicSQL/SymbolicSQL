#lang rosette/safe

(provide dedup
	 projection
	 cross-prod)

(define (dedup table)
  (cond 
    [(equal? '() table) '()]
    [else 
      (let ([ele (car table)])
	(cons (cons (car ele) 1)
	      (dedup 
		(filter 
		  (lambda (x)
		    (not (equal? (car ele) (car x))))
		  (cdr table)))))]))

(define (projection indices table)
  (let ([proj-single (lambda (r)
                       (map (lambda (i)
                              (list-ref r i))
                            indices))])
    (map (lambda (p)
           (cons (proj-single (car p)) (cdr p)))
         table)))

(define (cross-prod table1 table2)
  (let ([cross-single (lambda (p1)
                        (map (lambda (p2)
                               (let ([r1 (car p1)]
                                     [r2 (car p2)]
                                     [cnt (* (cdr p1) (cdr p2))])
                                 (cons (append r1 r2) cnt)))
                             table2))])
    (foldr append '() (map cross-single table1))))
