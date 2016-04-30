#lang rosette

(define test-table1
    (list
      (cons (list 1 1 2) 2)
      (cons (list 1 1 2) 2)
      (cons (list 0 1 2) 2)
      (cons (list 1 2 1) 1)
      (cons (list 1 2 3) 1)
      (cons (list 2 1 0) 3)))

(struct query-select (select-args from-queries where-filter)
	#:transparent)

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

(list (val-const 3) (val-column-ref "c1") (val-const 4) (val-aggr "aggr-max" (query-named test-table1)))



