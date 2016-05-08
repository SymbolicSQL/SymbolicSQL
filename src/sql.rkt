#lang rosette

(require "table.rkt" "operators.rkt")

;;; query structure

; select-args : a list of values
; from-queries : a list of tables/subqueries
; where-filter : a filter
(struct query-select (select-args from-query where-filter))
(struct query-join (query1 query2))
(struct query-named (table-ref))
(struct query-rename (query table-name column-names))

(define (denote-sql query index-map)
  (cond 
    ; denote named table
    [(query-named? query) 
       (lambda (e) (query-named-table-ref query))]
    ; denote join to a racket program
    [(query-join? query) 
     (lambda (e) 
       (xproduct	
       	(denote-sql (query-join-query1 query) index-map)
       	(denote-sql (query-join-query2 query) index-map)
       "anonymous"))
     ]
    ; denote rename table
    [(query-rename? query)
     (let ([q (denote-sql (query-rename-query query) index-map)])
       (rename-table (denote-sql (query-rename-query query) index-map)
                     (query-rename-table-name query)))]
    ; denote select query
    [(query-select? query) "xx"]))
       
(define (extract-schema query)
  (cond 
    [(query-named? query) 
     (get-schema (query-named-table-ref query))]
    [(query-join? query) 
     (append (extract-schema (query-join-query1 query)) 
	     (extract-schema (query-join-query2 query)))]
    [(query-rename? query)
     (let ([tn (query-rename-table-name query)]
	   [cnames (query-rename-column-names query)])
       (map (lambda (x) (string-append tn cnames)) cnames))]
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
    [(val-const? value) (list 'lambda '(e) (val-const-val value))]
    [(val-column-ref? value)
     (list 'lambda '(e) (list 'list-ref (hash-ref nmap (val-column-ref-column-name value))))]
    [(val-agg? value)
     (list 'lambda '(e) (list (val-agg-agg-func value) (list (denote-sql (val-agg-query value) nmap) 'e)))]))
     

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
     (list 'lambda '(e) ('op (list (denote-value (filter-binop-val1 f) nmap) 'e)
                            (list (denote-value (filter-binop-val2 f) nmap) 'e)))]
    [(filter-conj? f)
     (list 'lambda '(e) ('and (list (denote-filter (filter-conj-f1 f) nmap) 'e)
                              (list (denote-filter (filter-conj-f2 f) nmap) 'e)))]
    [(filter-disj? f)
     (list 'lambda '(e) ('or (list (denote-filter (filter-disj-f1 f) nmap) 'e)
                             (list (denote-filter (filter-disj-f2 f) nmap) 'e)))]
    [(filter-not? f)
     (list 'lambda '(e) ('not (list (denote-filter (filter-not-f1 f) nmap) 'e)))]
    [(filter-exists? f)
     (list 'lambda '(e) (list 'if (list 'empty? (list (denote-sql (filter-exists-query f) nmap) 'e)) '#f '#t))]
    [(filter-empty? f) '(lambda (e) #t)]))
     

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

(println (denote-sql q3 '()))
