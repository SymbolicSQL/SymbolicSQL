#lang rosette 

(define (poly x)
   (+ (* x x x x) (* 6 x x x) (* 11 x x) (* 6 x)))
 
(define (factored x)
   (* x (+ x 1) (+ x 2) (+ x 2)))
 
(define (same p f x)
   (assert (= (p x) (f x))))

(define-symbolic i integer?)
(define cex (verify (same poly factored i)))

(evaluate i cex)
