#lang rosette
; use rosette instead of rosette/safe only because the "error" call
(require racket/generic)
(require racket/match)

(define-generics table-interface
  ; get schema as a list of column names
  (get-schema table-interface)
  ; rename the column names
  (rename-cols table-interface col-names)
  ; get the lambda function that get the colum from the table
  (get-col-lambda table-interface col-name))

(define (find-index ele l)
  (letrec ([aux-func
             (lambda (ele l idx)
               (cond [(empty? l) (error 'find-index "can not find index")]
                     [(equal? ele (car l)) idx]
                     [else (aux-func ele (cdr l) (+ 1 idx))]))])
    (aux-func ele l 0)))

(struct Table (name
               [schema #:mutable]
               content)
  #:transparent
  #:methods gen:table-interface
  [(define (get-schema self)
     (Table-schema self))

   (define (rename-cols self col-names)
     (when (not (= (length col-names (Table-schema self))))
       (error 'rename-cols "Wrong number of names"))
     (set-Table-schema! self col-names))

   (define (get-col-lambda self col-name)
     (let ([idx (find-index col-name (Table-schema self))])
       (lambda (r) (list-ref r idx))))])

; Table -> Table -> Schema
(define (schema-join t1 t2)
  (let* ([s1 (get-schema t1)]
         [s2 (get-schema t2)]
         [n1 (Table-name t1)]
         [n2 (Table-name t2)]
         [renamed1 (map (lambda (x)
                          (if (list? x)
                              (cons n1 x)
                              (list n1 x)))
                        s1)]
         [renamed2 (map (lambda (x)
                          (if (list? x)
                              (cons n2 x)
                              (list n2 x)))
                        s2)])
    (append renamed1 renamed2)))

(define (string->colname str)
  (map string->symbol (string-split str ".")))

(define table1 (Table 't1 '(a b c) '()))
(define table2 (Table 't2 '(a b c) '()))
(define table3 (Table 't3 (schema-join table1 table2) '()))


                          
