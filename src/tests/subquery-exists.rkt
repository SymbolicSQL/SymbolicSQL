#lang rosette                                                                                                                                                 

(require "../table.rkt" "../sql.rkt" "../evaluator.rkt" "../equal.rkt")

(define (same q1 q2)
    (assert (bag-equal (get-content (run q1)) (get-content (run q2)))))

(define (sv)
     (define-symbolic* y integer?) ; creates a different constant when evaluated
         y)

(define content
    (list
      (cons (list 1 1 2) 2)
      (cons (list 0 1 2) 2)                 
      (cons (list 1 2 1) 1)
      (cons (list 2 1 0) 3)))

(define acontent
    (list
      (cons (list 1 0 1) 8)))


; (define sym-content (gen-sym-schema 3 5))

(define sEmp (Table "Emp" (list "Name" "Emp" "Dept") (gen-sym-schema 3 2)))    
(define sDept (Table "Dept" (list "Dept" "Mgr" "Loc") (gen-sym-schema 3 2)))    

(define Emp (Table "Emp" (list "Name" "Emp" "Dept") acontent))    
(define Dept (Table "Dept" (list "Dept" "Mgr" "Loc") acontent))    

(define one-sv (sv))
	    
(define subq (SELECT (VALS "Dept.Dept")
	FROM (NAMED Dept)
	WHERE (AND (AND (BINOP 0 eq? "Dept.Mgr") (BINOP 1 eq? "Dept.Dept")) (BINOP "Dept.Loc" eq? 1))))

(run subq)

(define q1
  (SELECT (VALS "Emp.Name")
     FROM (NAMED Emp)
    WHERE (EXISTS 
	    (SELECT (VALS "Dept.Dept")
	       FROM (NAMED Dept)
	      WHERE (AND (AND (BINOP "Emp.Emp" eq? "Dept.Mgr") (BINOP "Emp.Dept" eq? "Dept.Dept")) (BINOP "Dept.Loc" eq? 1))))))

(define q2
  (SELECT (VALS "Emp.Name")
     FROM (JOIN (NAMED Emp) (NAMED Dept))
    WHERE (AND (BINOP "Emp.Dept" eq? "Dept.Dept") (AND (BINOP "Dept.Loc" eq? 1) (BINOP "Emp.Emp" eq? "Dept.Mgr")))))

(run q1)
(run q2)

(verify (same q1 q2))