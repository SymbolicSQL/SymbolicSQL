#lang rosette

(require "table.rkt")

(struct table (name schema content))

(define table1-content
    (list
      (cons (list 1 1 2) 2)
      (cons (list 1 1 2) 2)
      (cons (list 0 1 2) 2)
      (cons (list 1 2 1) 1)
      (cons (list 1 2 3) 1)
      (cons (list 2 1 0) 3)))

(define table1 
  (table
    "table1" 
    (list "c1" "c2" "c3")
    table1-content))

;;; query structure

; select-args : a list of values
; from-queries : a list of tables/subqueries
; where-filter : a filter
(struct query-select (select-args from-query where-filter))
(struct query-join (queries))
(struct query-named (table-ref))
(struct query-rename (query table-name))

(define (denote-sql query)
  (cond 
    [query-named? "qn"]
    [query-join? "qj"]
    [query-select? "qs"]
    [query-rename? "qr"]))

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

(denote-sql q)


