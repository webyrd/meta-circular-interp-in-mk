(load "pmatch.scm")

;; keep only CBV LC; change eq? to equal?

(define Y
  ((lambda (Y)
     (lambda (F)
       (F (lambda (x) (((Y Y) F) x))))) 
   (lambda (Y)
     (lambda (F)
       (F (lambda (x) (((Y Y) F) x)))))))

(define Y-data
  '((lambda (Y)
      (lambda (F)
        (F (lambda (x) (((Y Y) F) x))))) 
    (lambda (Y)
      (lambda (F)
        (F (lambda (x) (((Y Y) F) x)))))))

(((Y
   (lambda (eval-expr)
     (lambda (expr)
       (lambda (env)
         (pmatch expr
           [,x (guard (symbol? x)) (env x)]
           [(lambda (,x) ,e)
            (lambda (a)
              ((eval-expr e)
               (lambda (y)
                 (if (equal? x y)
                     a
                     (env y)))))]
           [(,e1 ,e2)
            (((eval-expr e1) env)
             ((eval-expr e2) env))])))))
  '(lambda (x) x))
 (lambda (x) 'error))
