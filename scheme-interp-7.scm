(((((lambda (Y)
      (lambda (F)
        (F (lambda (x) (((Y Y) F) x))))) 
    (lambda (Y)
      (lambda (F)
        (F (lambda (x) (((Y Y) F) x))))))
   (lambda (eval-expr)
     (lambda (expr)
       (lambda (env)
         (if (symbol? expr)
             (env expr)
             (if (and (pair? expr)
                      (and (pair? (cdr expr))
                           (and (pair? (cdr (cdr expr)))
                                (and (null? (cdr (cdr (cdr expr))))
                                     (and (equal? (car expr) (quote lambda))
                                          (and (pair? (car (cdr expr)))
                                               (and (null? (cdr (car (cdr expr))))
                                                    (symbol? (car (car (cdr expr)))))))))))
                 (lambda (a)
                   ((eval-expr (car (cdr (cdr expr))))
                    (lambda (y)
                      (if (equal? (car (car (cdr expr))) y)
                          a
                          (env y)))))
                 (if (and (pair? expr)
                          (and (pair? (cdr expr))
                               (null? (cdr (cdr expr)))))
                     (((eval-expr (car expr)) env)
                      ((eval-expr (car (cdr expr))) env))
                     (quote unmatched-expression-error))))))))
  (quote (lambda (x) x)))
 (lambda (x) (quote unbound-variable-error)))