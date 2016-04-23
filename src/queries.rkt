#lang rosette

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
    (cons (list 2 1 0) 3)))

(define q1 (lambda (content) 
     (filter 
	(lambda (t) 
	  (let ([ct (car t)])
	    (and 
	      (< (list-ref ct 0) (list-ref ct 1))
	      (< (list-ref ct 1) (list-ref ct 2))))) 
	content))
  )

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


(define q3-subquery
  (lambda (content c0 c1)
    (filter 
      (lambda (t)
	(let ([ct (car t)])
	  (and 
	    (eq? (list-ref ct 0) c0)
	    (eq? (list-ref ct 1) c1))))
      content)))

(define q3
  (lambda (content)
      (map 
	(lambda (p)
	  (cons 
	    (append 
	      (car p) 
	      (max (q3-subquery ()))) 
	    (cdr p)))
	content)))

(print (q3 test-table))

(define queries (list q1 q2))

