(load "mk.scm")

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

(define proper-listo
  (lambda (exp env val)
    (conde
      ((== '() exp)
       (== '() val))
      ((fresh (a d v-a v-d)
         (== `(,a . ,d) exp)
         (== `(,v-a . ,v-d) val)
         (eval-expo a env v-a)
         (proper-listo d env v-d))))))

(define non-symbol-valueo
  (lambda (val)
    (conde
      [(== #f val)]
      [(== #t val)]
      [(== '() val)]
      [(numbero val)]
      [(fresh (a d)
         (== `(,a . ,d) val))])))

(define non-number-valueo
  (lambda (val)
    (conde
      [(== #f val)]
      [(== #t val)]
      [(== '() val)]
      [(symbolo val)]
      [(fresh (a d)
         (== `(,a . ,d) val))])))

(define non-null-valueo
  (lambda (val)
    (conde
      [(== #f val)]
      [(== #t val)]
      [(numbero val)]
      [(symbolo val)]
      [(fresh (a d)
         (== `(,a . ,d) val))])))

(define atomo
  (lambda (atom)
    (conde
      [(== #f atom)]
      [(== #t atom)]
      [(== '() atom)]
      [(numbero atom)]
      [(symbolo atom)])))

(define eval-expo
  (lambda (exp env val)
    (conde
      ;; leave 'error' unbound, so calls to 'error' will cause failure
      ;;
      ((== #f exp) (== #f val))      
      ((== #t exp) (== #t val))
      ((numbero exp) (== exp val))
      ((fresh (v)
         (== `(quote ,v) exp)
         (not-in-envo 'quote env)
         (absento 'closure v)
         (== v val)))
;      ((fresh (a*)
;         (== `(list . ,a*) exp)
;         (not-in-envo 'list env)
;         (absento 'closure a*)
;         (proper-listo a* env val)))
      ((fresh (e1 e2 v1 v2)
         (== `(equal? ,e1 ,e2) exp)
         (not-in-envo 'equal? env)
         (conde
           [(== v1 v2) (== #t val)]
           [(=/= v1 v2) (== #f val)])
         (eval-expo e1 env v1)
         (eval-expo e2 env v2)))
      ((fresh (e)
         (== `(null? ,e) exp)
         (not-in-envo 'null? env)
         (conde
           [(== #t val)
            (eval-expo e env '())]
           [(== #f val)
            (fresh (v)
              (non-null-valueo v)
              (eval-expo e env v))])))      
      ((fresh (e)
         (== `(pair? ,e) exp)
         (not-in-envo 'pair? env)
         (conde
           [(== #t val)
            (fresh (a d)
              (absento 'closure `(,a . ,d))
              (eval-expo e env `(,a . ,d)))]
           [(== #f val)
            (fresh (atom)
              (atomo atom)
              (eval-expo e env atom))])))      
      ((fresh (e d)
         (== `(car ,e) exp)
         (not-in-envo 'car env)
         (absento 'closure `(,val . ,d))
         (eval-expo e env `(,val . ,d))))
      ((fresh (e a)
         (== `(cdr ,e) exp)
         (not-in-envo 'cdr env)
         (absento 'closure `(,a . ,val))
         (eval-expo e env `(,a . ,val))))
      ((fresh (e1 e2)
         (== `(and ,e1 ,e2) exp)
         (not-in-envo 'and env)         
         (conde
           [(== #f val)
            (eval-expo e1 env #f)]
           [(fresh (v1)
              (=/= #f v1)
              (eval-expo e1 env v1))
            (eval-expo e2 env val)])))
      ((fresh (e v)
         (== `(number? ,e) exp)
         (not-in-envo 'number? env)
         (conde
           [(numbero v) (== #t val)]
           [(non-number-valueo v) (== #f val)])
         (eval-expo e env v)))      
      ((fresh (e v)
         (== `(symbol? ,e) exp)
         (not-in-envo 'symbol? env)
         (conde
           [(symbolo v) (== #t val)]
           [(non-symbol-valueo v) (== #f val)])
         (eval-expo e env v)))
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
         (== `(closure ,x ,body ,env) val)))
      ((fresh (t c a)
         (== `(if ,t ,c ,a) exp)
         (not-in-envo 'if env)
         (conde
           [(eval-expo t env #f)
            (eval-expo a env val)]
           [(fresh (b)
              (=/= #f b)
              (eval-expo t env b))
            (eval-expo c env val)]))))))
