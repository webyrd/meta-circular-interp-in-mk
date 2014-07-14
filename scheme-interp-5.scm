;; remove pmatch

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
         (cond
           [(symbol? expr) (env expr)]
           [(and (pair? expr)
                 (and (pair? (cdr expr))
                      (and (pair? (cdr (cdr expr)))
                           (and (null? (cdr (cdr (cdr expr))))
                                (and (equal? (car expr) (quote lambda))
                                     (and (pair? (cadr expr))
                                          (and (null? (cdadr expr))
                                               (symbol? (caadr expr)))))))))
            (lambda (a)
              ((eval-expr (caddr expr))
               (lambda (y)
                 (if (equal? (caadr expr) y)
                     a
                     (env y)))))]
           [(and (pair? expr)
                 (and (pair? (cdr expr))
                      (null? (cdr (cdr expr)))))
            (((eval-expr (car expr)) env)
             ((eval-expr (car (cdr expr))) env))])))))
  '(lambda (x) x))
 (lambda (x) 'error))
