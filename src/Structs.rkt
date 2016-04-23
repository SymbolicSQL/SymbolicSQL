#lang rosette/safe
(require racket/generic)
(require racket/match)

(define-generics table-gen
  (get-col table-gen col-name)
  (set-col table-gen col-name val))

(struct SymTable ([columns #:mutable])
  #:transparent
  #:methods gen:table-gen
  [(define (get-col self col-name)
     (match-define (SymTable columns) self)
     (cadr (assoc col-name columns)))
   
   (define (set-col self col-name val)
     (match-define (SymTable columns) self)
     (map (lambda (p)
            (if (eq? (car p) col-name)
                (list (car p) val)
                p))
          columns))
   ])

(define (init-symtable col-names-types)
  (map (lambda (p)
         (let ([name (car p)]
               [type (cadr p)])
         (define-symbolic* col type) 
         (list name col)))
       col-names-types))

(struct Query (select where))