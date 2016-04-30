#lang rosette

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

; select-args : a list of values
; from-queries : a list of tables/subqueries
; where-filter : a filter
(struct query-select (select-args from-queries where-filter)
	#:transparent)
	;#:method gen:custom-write
	;[(define (write-proc query-select port mode)
	   ;(show ":::::" port))])

(struct query-named (table-ref))

(struct val-const (val)
	#:transparent)
(struct val-column-ref (column-name)
	#:transparent)
(struct val-aggr (aggr-func query)
	#:transparent)

(struct filter-binop (op val1 val2))
(struct filter-conj (f1 f2))
(struct filter-disj (f1 f2))
(struct filter-not (f1 f2))
(struct filter-exists (query))
(struct filter-empty ())

(query-select 
  (list (val-column-ref "c1") (val-column-ref "c2"))
  (list (query-named table1))
  (filter-binop "<" (val-column-ref "c1") (val-column-ref "c2")))



