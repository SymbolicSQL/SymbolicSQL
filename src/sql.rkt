#lang rosette

(require "table.rkt" "operators.rkt")

;;; define the current name space as ns
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))

;;; query structure

; select-args : a list of values
; from-queries : a list of tables/subqueries
; where-filter : a filter
(struct query-select (select-args from-query where-filter))
(struct query-join (query1 query2))
(struct query-named (table-ref))
(struct query-rename (query table-name column-names))

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
           (let* ([from-clause (eval (denote-sql table name-hash) ns)]
                  [where-clause (eval (denote-filter (query-select-where-filter query)) ns)]
                  [from-table `(,from-clause e)])
             `(map (lambda (arg) (denote-value arg name-hash))
                   (filter ,where-clause (map (lambda (r) (append e r))
                                              from-table))))))]))
           

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
(struct filter-binop (op val1 val2))
(struct filter-conj (f1 f2))
(struct filter-disj (f1 f2))
(struct filter-not (f1))
(struct filter-exists (query))
(struct filter-empty ())

;;; denote filters returns tuple -> bool
(define (denote-filter f nmap)
  (cond
    [(filter-binop? f)
     `(lambda (e) (op (,(denote-value (filter-binop-val1 f) nmap) e)
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
  (list (val-column-ref "c1") (val-column-ref "c2"))
  (list (query-named table1))
  (filter-binop "<" (val-column-ref "c1") (val-column-ref "c2"))))

(define q2 (query-rename (query-named table1) "qt" (list "c1" "c2" "c3")))

(define q3 (query-join (query-named table1) (query-rename (query-named table1) "t2" (list "c1" "c2" "c3"))))

(define part-of-q3 (query-rename (query-named table1) "t2" (list "c1" "c2" "c3")))

;; (print (denote-sql part-of-q3 '()))

(rename-table ((lambda (e) (Table "t1" (list "c1" "c2" "c3") '())) '()) "t2")

(define denotation-q3
   '(lambda (e) (rename-table ((lambda (e) (Table "t1" (list "c1" "c2" "c3") '())) e) "t2")) )

; ((eval (denote-sql q3 '()) ns) '())

(extract-schema q3)
