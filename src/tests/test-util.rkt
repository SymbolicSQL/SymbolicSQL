#lang rosette

(require "args.rkt" "../table.rkt" "../sql.rkt" "../evaluator.rkt" "../equal.rkt")

(provide same concrete-table-3-col concrete-table-2-col num-rows-in-sym-table)

(define (same q1 q2)
    (assert (bag-equal (get-content (run q1)) (get-content (run q2)))))

(define concrete-table-3-col
    (list
      (cons (list 1 1 2) 2)
      (cons (list 0 1 2) 2)                 
      (cons (list 1 2 1) 1)
      (cons (list 2 1 0) 3)))

(define concrete-table-2-col
    (list
      (cons (list 1 1) 2)
      (cons (list 0 2) 2)                 
      (cons (list 1 2) 1)
      (cons (list 2 1) 3)))
