#lang rosette                                                                                                                                                 

(require "../table.rkt" "../sql.rkt" "../evaluator.rkt" "../equal.rkt")

(define (same q1 q2)
    (assert (bag-equal (get-content (run q1)) (get-content (run q2)))))

(define (sv)
     (define-symbolic* y integer?) ; creates a different constant when evaluated
         y)

(define sym-content
    (list
      (cons (list (sv) (sv) (sv)) (sv))))

(define content
    (list
      (cons (list 1 1 2) 2)
      (cons (list 0 1 2) 2)                 
      (cons (list 1 2 1) 1)
      (cons (list 2 1 0) 3)))

; (define sym-content (gen-sym-schema 3 5))

(define Sym-Emp (Table "Emp" (list "Name" "Emp" "Dept") sym-content))    
(define Sym-Dept (Table "Dept" (list "Dept" "Mgr" "Loc") sym-content))    

(define Emp (Table "Emp" (list "Name" "Emp" "Dept") content))    
(define Dept (Table "Dept" (list "Dept" "Mgr" "Loc") content))    

(define one-sv (sv))

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
