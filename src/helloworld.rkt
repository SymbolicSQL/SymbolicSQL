#lang rosette 

(require "queries.rkt")

(provide 
  sym-table-gen)

(define (sv)
   (define-symbolic* y integer?) ; creates a different constant when evaluated
    y)

(define sym-content
  (list 
    (cons (list (sv) (sv) (sv)) (sv))
    (cons (list (sv) (sv) (sv)) (sv))))

(define (sym-table-gen num-col num-unique-rows)
  (let ([gen-list (lambda (proc n)
                    (map (lambda (x) (proc)) (range n)))])
    (gen-list (lambda ()
                (cons (gen-list sv num-col) (sv)))
              num-unique-rows)))


; the running part
(define q1 (list-ref queries 0))
(define q2 (list-ref queries 1))

(define (same content)
  (assert (eq? (q1 content) (q2 content))))

(define cex (verify (same sym-content)))

(println (q1 test-table))
(println (q2 test-table))

;(verify (same sym-content))

