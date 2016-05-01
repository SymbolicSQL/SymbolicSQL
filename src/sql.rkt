#lang rosette

(require "table.rkt")

;;; query structure

; select-args : a list of values
; from-queries : a list of tables/subqueries
; where-filter : a filter
(struct query-select (select-args from-query where-filter))
(struct query-join (queries))
(struct query-named (table-ref))
(struct query-rename (query table-name))

(define (denote-sql query ctxt)
  (cond 
    [(query-named? query) 
     (query-named-table-ref query)]
    [(query-join? query) "qj"]
    [(query-select? query) "qs"]
    [(query-rename? query)
     (rename-table 
	(denote-sql (query-rename-query query) ctxt)
	(query-rename-table-name query))]))

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
(define table1 (Table 't1 '(a b c) test-table1))

(define q (query-select 
  (list (val-column-ref "c1") (val-column-ref "c2"))
  (list (query-named table1))
  (filter-binop "<" (val-column-ref "c1") (val-column-ref "c2"))))

(define q2 (query-rename (query-named table1) "qt"))

(println (denote-sql q2 '()))
