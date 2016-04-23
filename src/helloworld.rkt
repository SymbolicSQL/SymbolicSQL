#lang rosette 

(define concrete-content
  (list 
    (cons (list 1 1 2) 2) 
    (cons (list 0 1 2) 2)
    (cons (list 1 2 1) 1) 
    (cons (list 2 1 0) 3)))

;(define (sv)
;   (define-symbolic* y integer?) ; creates a different constant when evaluated
;    y)

(define-symbolic* sv integer?)

(define sym-content
  (list 
    (cons (list sv sv sv) sv)
    (cons (list sv sv sv) sv)))

(define (q1 content) 
  (filter 
    (lambda (t) 
      (let 
	([ct (car t)])
	(and 
	  (< (list-ref ct 0) (list-ref ct 1))
	  (< (list-ref ct 1) (list-ref ct 2))))) 
    content))

(define (q2 content) 
  (filter 
    (lambda (t) 
      (let 
	([ct (car t)])
	(and 
	  (< (list-ref ct 1) (list-ref ct 2))
	  (>= (list-ref ct 1) (list-ref ct 0)))))
    content))

(assert (eq? (q1 concrete-content) (q2 concrete-content)))

(define (same content)
  (assert (eq? (q1 content) (q2 content))))

(define cex (verify (same sym-content)))

; (verify (assert (= sv sv)))

(verify (same sym-content))

;(evaluate sym-content cex)
