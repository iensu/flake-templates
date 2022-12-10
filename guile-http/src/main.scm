(use-modules (web server)
             (web request)
             (web response)
             (web http)
             (web uri)
             (sxml simple)
             ((ice-9 match) #:prefix m:))

(define (request-path-components request)
  (split-and-decode-uri-path (uri-path (request-uri request))))

(define (templatize title body)
  `(html (head (title ,title))
         (body ,@body)))

(define* (respond #:optional body
                  #:key
                  (status 200)
                  (title "Hello hello!")
                  (doctype "<!DOCTYPE html>\n")
                  (content-type-params '((charset . "utf-8")))
                  (content-type 'text/html)
                  (extra-headers '())
                  (sxml (and body (templatize title body))))
       (values (build-response
                #:code status
                #:headers `((content-type
                             . (,content-type ,@content-type-params))
                            ,@extra-headers))
               (lambda (port)
                 (if sxml
                     (begin
                       (if doctype (display doctype port))
                       (sxml->xml sxml port))))))

(define (debug-page request body)
  (respond
   `((h1 "Debug page")
     (table
      (tr (th "Header") (th "Value"))
      ,@(map (lambda (pair)
               `(tr (td (@ (style "min-width: 250px;"))
                        (tt ,(with-output-to-string
                               (lambda () (display (header->string (car pair)))))))
                    (td (tt ,(with-output-to-string
                               (lambda () (write (cdr pair))))))))
             (request-headers request))))))

(define (not-found request)
  (respond `((h1 "Not found!")
             (p ,(string-append "Resource not found: "
                                (uri->string (request-uri request))))
             )
           #:status 404))

(define (route-handler request body)
  (m:match (request-path-components request)
           [("debug") (debug-page request body)]
           [else (not-found request)]))

(run-server route-handler 'http '(#:port 3000))
