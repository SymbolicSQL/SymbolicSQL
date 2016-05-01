#lang rosette

(require "table.rkt")
(require "operators.rkt")

;;; query structure

; select-args : a list of values
; from-queries : a list of tables/subqueries
; where-filter : a filter
(struct query-select (select-args from-query where-filter))
(struct query-join (query1 query2))
(struct query-named (table-ref))
(struct query-rename (query table-name))

(define (denote-sql query ctxt)
  (cond 
    ; denote named table
    [(query-named? query) 
     (query-named-table-ref query)]
    ; denote join to a racket program
    [(query-join? query) 
     (xproduct	
       (denote-sql (query-join-query1 query) ctxt)
       (denote-sql (query-join-query2 query) ctxt)
       "anonymous")
     ]
    ; denote rename table
    [(query-rename? query)
     (let ([q (denote-sql (query-rename-query query) ctxt)])
       (rename-table (denote-sql (query-rename-query query) ctxt)
                     (query-rename-table-name query)))]
    ; denote select query
    [(query-select? query) "xx"]))
       

;;; values
(struct val-const (val)
	#:transparent)
(struct val-column-ref (column-name)
	#:transparent)
(struct val-aggr (aggr-func query)
	#:transparent)

;;; filters
(struct filter-binop (op val1 val2))
(struct filter-conj (f1 f2))
(struct filter-disj (f1 f2))
(struct filter-not (f1 f2))
(struct filter-exists (query))
(struct filter-empty ())

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

(define q2 (query-rename (query-named table1) "qt"))


(define q3 (query-join (query-named table1) (query-rename (query-named table1) "t2")))

(println (denote-sql q3 '()))
