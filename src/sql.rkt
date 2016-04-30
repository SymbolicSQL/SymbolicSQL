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

(define (denote-sql query external-row)
  (cond 
    [(query-named? query) query]
    [(query-join? query) "qj"]
    [(query-select? query) "qs"]
    [(query-rename? query) 
     (rename 
       (denote-sql (query-rename-query query))
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

(define q (query-select 
  (list (val-column-ref "c1") (val-column-ref "c2"))
  (list (query-named table1))
  (filter-binop "<" (val-column-ref "c1") (val-column-ref "c2"))))

(define q2 (query-rename (query-named table1) "qt"))

(denote-sql q2)


