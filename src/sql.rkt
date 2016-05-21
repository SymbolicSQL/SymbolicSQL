#lang rosette

(require "table.rkt" "operators.rkt" "evaluator.rkt")

(provide (all-defined-out))

;;; define the current name space as ns
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))

;;; query structure

; select-args : a list of values
; from-queries : a list of tables/subqueries
; where-filter : a filter
(struct query-select (select-args from-query where-filter) #:transparent)
(struct query-join (query1 query2) #:transparent)
(struct query-named (table-ref) #:transparent)
(struct query-rename (query table-name column-names) #:transparent)

;; query: the sql query to denote to
;; index-map: the mapping of the names to their index in the context, which is a hash map
;; result: a quasi-quated lambda calculas representing the denotation of the sql query
(define (denote-sql query index-map)
  (cond 
    ; denote named table
    [(query-named? query) 
       `(lambda (e) ,(query-named-table-ref query))]
    ; denote join to a racket program
    [(query-join? query) 
     `(lambda (e) 
       (xproduct	
       	(,(denote-sql (query-join-query1 query) index-map) e)
       	(,(denote-sql (query-join-query2 query) index-map) e)
       "anonymous"))]
    ; denote rename table
    [(query-rename? query)
     `(lambda (e)
        (rename-table (,(denote-sql (query-rename-query query) index-map) e) ,(query-rename-table-name query)))]
    ; denote select query
    [(query-select? query)
     `(lambda (e)
        ,(let* ([table (query-select-from-query query)]
                [schema (extract-schema table)]
                [name-hash (hash-copy index-map)])
           (map (lambda (col-name idx)
                  (hash-set! name-hash col-name (+ idx (hash-count index-map))))
                schema (range (length schema)))
           (let* ([from-clause (eval (denote-sql table index-map) ns)]
                  [where-clause (eval (denote-filter
                                       (query-select-where-filter query)
                                       name-hash) ns)]
                  [from-table `(,from-clause e)]
                  [row-funcs (map (lambda (arg) (eval (denote-value arg name-hash) ns))
                                  (query-select-select-args query))]
                  [row-func-wrap (lambda (r)
                                   (map (lambda (f) (f r))
                                        row-funcs))])
             `(let ([content (map (lambda (r) (cons (,row-func-wrap (car r)) (cdr r)))
                                  (filter (lambda (r) (,where-clause (car r)))
                                          (map (lambda (r) (cons (append e (car r)) (cdr r)))
                                               (Table-content ,from-table))))]
                    [new-name "dummy-name"]
                    [new-schema (,extract-schema ,query)])
                (Table new-name new-schema (dedup-accum content))))))]))

;; convert schema list to hash map (name -> index)           
(define (list->hash l)
  (let ([h (make-hash)])
    (map (lambda (name idx)
           (hash-set! h name idx))
         l
         (range (length l)))
    h))

;; query: the sql query to extract schema for
(define (extract-schema query)
  (cond 
    [(query-named? query)
     (get-qualified-schema (query-named-table-ref query))]
     ;(map (lambda (x) (string-append (get-table-name (query-named-table-ref query)) "." x))(get-schema (query-named-table-ref query)))]
    [(query-join? query) 
     (append (extract-schema (query-join-query1 query)) 
	     (extract-schema (query-join-query2 query)))]
    [(query-rename? query)
     (let ([tn (query-rename-table-name query)]
	   [cnames (query-rename-column-names query)])
       (map (lambda (x) (string-append tn "." x)) cnames))]
    [(query-select? query)
     (map (lambda (x) "dummy") (query-select-select-args query))]))

;;; values
(struct val-const (val)
	#:transparent)
(struct val-column-ref (column-name)
	#:transparent)
(struct val-agg (agg-func query)
	#:transparent)

;;; denote value returns tuple -> value
(define (denote-value value nmap)
  (cond
    [(val-const? value) `(lambda (e) ,(val-const-val value))]
    [(val-column-ref? value)
     `(lambda (e) (list-ref e ,(hash-ref nmap (val-column-ref-column-name value))))]
    [(val-agg? value)
     `(lambda (e) (,(val-agg-agg-func value) (,(denote-sql (val-agg-query value) nmap) e)))]))

;;; filters
(struct filter-binop (op val1 val2) #:transparent)
(struct filter-conj (f1 f2) #:transparent)
(struct filter-disj (f1 f2) #:transparent)
(struct filter-not (f1) #:transparent)
(struct filter-exists (query) #:transparent)
(struct filter-empty () #:transparent)

;;; denote filters returns tuple -> bool
(define (denote-filter f nmap)
  (cond
    [(filter-binop? f)
     `(lambda (e) (,(filter-binop-op f) (,(denote-value (filter-binop-val1 f) nmap) e)
                                        (,(denote-value (filter-binop-val2 f) nmap) e)))]
    [(filter-conj? f)
     `(lambda (e) (and (,(denote-filter (filter-conj-f1 f) nmap) e)
                       (,(denote-filter (filter-conj-f2 f) nmap) e)))]
    [(filter-disj? f)
     `(lambda (e) (or (,(denote-filter (filter-disj-f1 f) nmap) e)
                      (,(denote-filter (filter-disj-f2 f) nmap) e)))]
    [(filter-not? f)
     `(lambda (e) (not (,(denote-filter (filter-not-f1 f) nmap) e)))]
    [(filter-exists? f)
     `(lambda (e) (if (empty? (,(denote-sql (filter-exists-query f) nmap) e)) #f #t))]
    [(filter-empty? f) `(lambda (e) #t)]))

(define (run q)
  (let ([racket-q (denote-sql q (make-hash))])
    ((eval racket-q ns) '())))

;;; for test purpose

(define test-table1
    (list
      (cons (list 1 1 2) 2)
      (cons (list 1 1 2) 2)
      (cons (list 0 1 2) 2)
      (cons (list 1 2 1) 1)
      (cons (list 1 2 3) 1)
      (cons (list 2 1 0) 3)))
(define table1 (Table "t1" (list "c1" "c2" "c3") test-table1))

(define q (query-select 
  (list (val-column-ref "t1.c1") (val-column-ref "t1.c2"))
  (query-named table1)
  (filter-binop < (val-column-ref "t1.c1") (val-column-ref "t1.c2"))))

(define q2 (query-rename (query-named table1) "qt" (list "c1" "c2" "c3")))

(define q3 (query-join (query-named table1) (query-rename (query-named table1) "t2" (list "c1" "c2" "c3"))))

(define part-of-q3 (query-rename (query-named table1) "t2" (list "c1" "c2" "c3")))

;; (print (denote-sql part-of-q3 '()))

(rename-table ((lambda (e) (Table "t1" (list "c1" "c2" "c3") '())) '()) "t2")

(define denotation-q3
   '(lambda (e) (rename-table ((lambda (e) (Table "t1" (list "c1" "c2" "c3") '())) e) "t2")) )

; ((eval (denote-sql q3 '()) ns) '())

(extract-schema q3)
(denote-sql q (make-hash))
((eval (denote-sql q (make-hash)) ns) '())

;; easy syntax rules to write sql queries

(define-syntax-rule
  (SELECT v FROM q WHERE f)
  (query-select v q f))

(define-syntax-rule
  (JOIN q1 q2)
  (query-join q1 q2))

(define-syntax-rule (NAMED t)
  (query-named t))

(define-syntax-rule (AS q [t l])
  (query-rename q t l))

(define (VAL v)
  (cond
    [(string? v) (val-column-ref v)]
    [(int? v) (val-const v)]
    [(val-agg? v) v]))

(define (VALS . v)
  (map (lambda (x) (VAL x)) v))

(define (AGGR aggr-fun q)
  (val-agg aggr-fun q))

(define (BINOP v1 op v2)
  (filter-binop op (VAL v1) (VAL v2)))

(define (AND f1 f2)
  (filter-conj f1 f2))

;;(define test-query1
;;  (SELECT (VALS "t1.c1" "t1.c2" "t1.c3" "t2.c1" "t2.c2" "t2.c3")
;;   FROM (JOIN (NAMED table1) (AS (NAMED table1) ["t2" '("c1" "c2" "c3")]))
;;   WHERE (AND (BINOP "t1.c1" < "t2.c2") (BINOP "t1.c3" < "t2.c3"))))

;; (run test-query1)
