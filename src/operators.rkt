#lang rosette

(require "table.rkt")

;; rawTable -> rawTable -> rawTable
(define (xproduct-raw a b)
  (let ([imr (cartesian-product a b)])
    (map (lambda (x)
           (cons (append (car (car x)) (car (cdr x))) (* (cdr (car x)) (cdr (cdr x)))) imr)
         )
    )
  )

;; Table -> Table -> Table
(define (xproduct a b name)
  (let* ([ta (Table-content a)]
         [tb (Table-content b)]
         [scm (schema-join a b)]
         )
    (Table
     name scm (xproduct-raw ta tb)
    ) 
    )
  )

;; test xproduct
(define content-a
  (list
    (cons (list 1 1 2) 2)
    (cons (list 0 1 2) 2)))

(define content-b
  (list
    (cons (list 1 2 3) 1)
    (cons (list 2 1 0) 3)))

(define table-a
  (Table 'a '(a b c) content-a))

(define table-b
  (Table 'b' '(a b c) content-b))

(println (xproduct table-a table-b))
