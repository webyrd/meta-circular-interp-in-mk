(load "mk.scm")
(load "test-check.scm")

(define lookupo
  (lambda (x env t)
    (fresh (y v rest)
      (== `((,y . ,v) . ,rest) env)
      (conde
        ((== y x) (== v t))
        ((=/= y x) (lookupo x rest t))))))

(define not-in-envo
  (lambda (x env)
    (conde
      ((== '() env))
      ((fresh (y v rest)
         (== `((,y . ,v) . ,rest) env)
         (=/= y x)
         (not-in-envo x rest))))))

(define eval-expo
  (lambda (exp env val)
    (conde
      ((symbolo exp) (lookupo exp env val))
      ((fresh (rator rand x body env^ a)
         (== `(,rator ,rand) exp)
         (eval-expo rator env `(closure ,x ,body ,env^))
         (eval-expo rand env a)
         (eval-expo body `((,x . ,a) . ,env^) val)))
      ((fresh (x body)
         (== `(lambda (,x) ,body) exp)
         (symbolo x)
         (not-in-envo 'lambda env)
         (== `(closure ,x ,body ,env) val))))))

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
