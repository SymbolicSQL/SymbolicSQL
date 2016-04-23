#lang racket

(provide queries)

(define test-table
  (list
    (cons (list 1 1 2) 2)
    (cons (list 0 1 2) 2)	          
    (cons (list 1 2 1) 1)
    (cons (list 2 1 0) 3)))

(define queries 
  (list
   (lambda (content) 
     (filter 
	(lambda (t) 
	  (let ([ct (car t)])
	    (and 
	      (< (list-ref ct 0) (list-ref ct 1))
	      (< (list-ref ct 1) (list-ref ct 2))))) 
	content))

   (lambda (content)
     (filter 
       (lambda (t) 
	 (let ([ct (car t)])
	   (and 
	     (< (list-ref ct 1) (list-ref ct 2))
	     (>= (list-ref ct 1) (list-ref ct 0)))))
       content))  
   ))

(println ((list-ref queries 0) test-table))

