#lang rosette

(require racket "queries.rkt")

;(provide tuple-in table-sum bag-contain bag-equal)

; sum the multiplicity of tuples in a table
(define (sum table)
  (cond
    [(empty? table) 0]
    [else (+ (cdr (first table)) (sum (rest table)))]))

;filter same tuple
(define (filter-tuple t table)
  (map
    (lambda (t1) (eq? (car t) (car t1)))
     table))

; sum the number of occurence of the same tuple
;(define (sum-tuple t table)
;  (sum
;   ))

; sum the multiplicity of each tuple in a table
;(define (table-sum table)
;  (map (lambda (t)
;         )
;       table)
;  )
  
(println (filter-tuple (cons (list 1 1 2) 2) test-table1))