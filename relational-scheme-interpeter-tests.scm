(load "relational-scheme-interpreter.scm")
(load "test-check.scm")

(test "1"
  (run* (q) (eval-expo '#f '() q))
  '(#f))

(test "2"
  (run* (q) (eval-expo '#t '() q))
  '(#t))

(test "3a"
  (run* (q) (eval-expo '(quote a) '() q))
  '(a))

(test "3b"
  (run* (q) (eval-expo '(quote 5) '() q))
  '(5))

(test "3c"
  (run* (q) (eval-expo '(quote (3 . 4)) '() q))
  '((3 . 4)))

(test "4"
  (run* (q) (eval-expo '(equal? (quote foo) (quote bar)) '() q))
  '(#f))

(test "5"
  (run* (q) (eval-expo '(equal? (quote foo) (quote foo)) '() q))
  '(#t))

(test "6a"
  (run* (q) (eval-expo '(symbol? (quote foo)) '() q))
  '(#t))

(test "6b"
  (run* (q) (eval-expo '(number? (quote foo)) '() q))
  '(#f))

(test "6c"
  (run* (q) (eval-expo '(number? 5) '() q))
  '(#t))

(test "7"
  (run* (q) (eval-expo '((lambda (x) (symbol? x)) (quote foo)) '() q))
  '(#t))

(test "8a"
  (run* (q) (eval-expo '(symbol? #f) '() q))
  '(#f))

(test "8b"
  (run* (q) (eval-expo '(symbol? 5) '() q))
  '(#f))

(test "8c"
  (run* (q) (eval-expo '(symbol? (quote (3 . 4))) '() q))
  '(#f))

(test "9"
  (run* (q) (eval-expo '((lambda (x) (symbol? x)) #t) '() q))
  '(#f))

(test "10"
  (run* (q) (eval-expo '(if (symbol? (quote foo)) (quote true) (quote false)) '() q))
  '(true))

(test "11"
  (run* (q) (eval-expo '(if (symbol? (quote #f)) (quote true) (quote false)) '() q))
  '(false))

(test "12"
  (run* (q) (eval-expo '(car (quote (a b c))) '() q))
  '(a))

(test "13"
  (run* (q) (eval-expo '(cdr (quote (a b c))) '() q))
  '((b c)))

(test "14a"
  (run* (q) (eval-expo '(pair? (car (quote (a b c)))) '() q))
  '(#f))

(test "14b"
  (run* (q) (eval-expo '(pair? (cdr (quote (a b c)))) '() q))
  '(#t))

(test "14c"
  (run* (q) (eval-expo '(pair? (quote ())) '() q))
  '(#f))

(test "15a"
  (run* (q) (eval-expo '(null? (cdr (quote (a b c)))) '() q))
  '(#f))

(test "15b"
  (run* (q) (eval-expo '(null? (cdr (cdr (quote (a b c))))) '() q))
  '(#f))

(test "15c"
  (run* (q) (eval-expo '(null? (cdr (cdr (cdr (quote (a b c)))))) '() q))
  '(#t))

(test "15d"
  (run* (q) (eval-expo '(null? (quote ())) '() q))
  '(#t))

(test "16"
  (run* (q) (eval-expo '(and 5 6) '() q))
  '(6))

(test "17"
  (run* (q) (eval-expo '(and #f 6) '() q))
  '(#f))

(test "18a"
  (run* (q) (eval-expo '(and (and (and (and (null? (quote ())) 7) 8) 9) 6) '() q))
  '(6))

(test "18b"
  (run* (q) (eval-expo '(and 6 (and (and (and 7 (null? (quote ()))) 8) 9)) '() q))
  '(9))

(test "19"
  (run* (q) (eval-expo '(and 6 (and (and (and 7 (null? (quote 5))) 8) 9)) '() q))
  '(#f))

(test "20"
  (run* (q) (eval-expo '(if (and 6 (and (and (and 7 (null? (quote 5))) 8) 9))
                            (quote true)
                            (quote false))
                       '()
                       q))
  '(false))

(test "21"
  (run* (q) (eval-expo '(if (and 6 (and (and (and 7 (null? (quote ()))) 8) 9))
                            (quote true)
                            (quote false))
                       '()
                       q))
  '(true))

(test "Y-a"
  (run* (q)
    (eval-expo
     '(lambda (Y)
        (lambda (F)
          (F (lambda (x) (((Y Y) F) x)))))
     '()
     q))
  '((closure Y (lambda (F) (F (lambda (x) (((Y Y) F) x)))) ())))

(test "Y-1"
  (run* (q)
    (eval-expo
     '((lambda (Y)
         (lambda (F)
           (F (lambda (x) (((Y Y) F) x)))))
       (lambda (Y)
         (lambda (F)
           (F (lambda (x) (((Y Y) F) x))))))
     '()
     q))
  '((closure F (F (lambda (x) (((Y Y) F) x))) ((Y closure Y (lambda (F) (F (lambda (x) (((Y Y) F) x)))) ())))))


(test "interp-1"
  (run* (q)
    (eval-expo
     '(((((lambda (Y)
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
     '()
     q))
  '((closure a ((eval-expr (car (cdr (cdr expr)))) (lambda (y) (if (equal? (car (car (cdr expr))) y) a (env y)))) ((env closure x 'unbound-variable-error ()) (expr lambda (x) x) (eval-expr closure x (((Y Y) F) x) ((F closure eval-expr (lambda (expr) (lambda (env) (if (symbol? expr) (env expr) (if (and (pair? expr) (and (pair? (cdr expr)) (and (pair? (cdr (cdr expr))) (and (null? (cdr (cdr (cdr expr)))) (and (equal? (car expr) 'lambda) (and (pair? (car (cdr expr))) (and (null? (cdr (car (cdr expr)))) (symbol? (car (car (cdr expr))))))))))) (lambda (a) ((eval-expr (car (cdr (cdr expr)))) (lambda (y) (if (equal? (car (car (cdr expr))) y) a (env y))))) (if (and (pair? expr) (and (pair? (cdr expr)) (null? (cdr (cdr expr))))) (((eval-expr (car expr)) env) ((eval-expr (car (cdr expr))) env)) 'unmatched-expression-error))))) ()) (Y closure Y (lambda (F) (F (lambda (x) (((Y Y) F) x)))) ())))))))

(test "interp-2"
  (run* (q)
    (eval-expo
     '(((((lambda (Y)
            (lambda (F)
              (F (lambda (x) (((Y Y) F) x))))) 
          (lambda (Y)
            (lambda (F)
              (F (lambda (x) (((Y Y) F) x))))))
         (lambda (eval-expr)
           (lambda (expr)
             (lambda (env)
               (if (number? expr)
                   expr
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
                               (quote unmatched-expression-error)))))))))
        (quote (((lambda (x) x) (lambda (y) y)) 5)))
       (lambda (x) (quote unbound-variable-error)))
     '()
     q))
  '(5))

(test "interp-3"
  (run 5 (q)
    (eval-expo
     `(((((lambda (Y)
            (lambda (F)
              (F (lambda (x) (((Y Y) F) x))))) 
          (lambda (Y)
            (lambda (F)
              (F (lambda (x) (((Y Y) F) x))))))
         (lambda (eval-expr)
           (lambda (expr)
             (lambda (env)
               (if (number? expr)
                   expr
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
                               (quote unmatched-expression-error)))))))))
        ,q)
       (lambda (x) (quote unbound-variable-error)))
     '()
     5))
  '(5
    '5
    ((car '(5 . _.0)) (absento (closure _.0)))
    ('((lambda (_.0) 5) _.1)
     (=/= ((_.0 closure)))
     (num _.1)
     (sym _.0))
    ('((lambda (_.0) 5) #f)
     (=/= ((_.0 closure)))
     (sym _.0))))
