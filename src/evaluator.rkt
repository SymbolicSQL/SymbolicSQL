#lang rosette

(provide gen-sym-schema
         dedup
         dedup-accum
	 projection
	 cross-prod)

(define (gen-sv)
  (define-symbolic* sv integer?)
  sv)

(define (gen-sym-schema num-col num-row)
  (let ([gen-row (lambda (x)
                   (cons (map (lambda (x) (gen-sv)) (range num-col)) (gen-sv)))])
    (map gen-row (range num-row))))

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

(define (dedup-accum table)
  (cond 
    [(equal? '() table) '()]
    [else 
      (let ([ele (car table)])
	(cons (cons (car ele) (foldl + 0 (map cdr
                                              (filter (lambda (x)
                                                        (equal? (car ele) (car x)))
                                                      table))))
	      (dedup-accum 
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
