(load "pmatch.scm")

;; pattern-matching environment-passing, big-step interpreter for a
;; minimal Scheme (call-by-value lambda-calculus, numbers, sub1, *,
;; zero?, and if)

(define eval-expr
  (lambda (expr env)
    (pmatch expr
      [,x (guard (symbol? x)) (env x)]
      [,n (guard (number? n)) n]
      [(zero? ,e) (zero? (eval-expr e env))]
      [(sub1 ,e) (sub1 (eval-expr e env))]
      [(* ,e1 ,e2)
       (* (eval-expr e1 env)
          (eval-expr e2 env))]
      [(if ,t ,c ,a)
       (if (eval-expr t env)
           (eval-expr c env)
           (eval-expr a env))]
      [(lambda (,x) ,e)
       (lambda (a)
         (eval-expr e (lambda (y)
                        (if (eq? x y)
                            a
                            (env y)))))]
      [(,e1 ,e2)
       ((eval-expr e1 env) (eval-expr e2 env))])))

(define Y
  '((lambda (Y)
      (lambda (F)
        (F (lambda (x) (((Y Y) F) x))))) 
    (lambda (Y)
      (lambda (F)
        (F (lambda (x) (((Y Y) F) x)))))))

(define Y-fact
  '(lambda (fact)
     (lambda (n)
       (if (zero? n)
           1
           (* (fact (sub1 n)) n)))))

(eval-expr `((,Y ,Y-fact) 5) (lambda (x) 'error))
