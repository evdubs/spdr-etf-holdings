#lang racket

;;
;; Use COM & mysterx to integrate with excel
;;
(require mysterx)

;; Some types - for all I know, a cell can hold more than just a 
;; string, number of empty. But this is what I've seen so far.
(define cell/c (or/c string? number? void?))
(define cells/c (vectorof (vectorof cell/c)))

(provide/contract
 [open (-> path-string? com-object?)]
 [close (-> com-object? any)]
 [new (-> com-object?)]
 [get-value (-> com-object? string? string? cell/c)]
 [set-value! (-> com-object? string? string? cell/c any)]
 [get-values (-> com-object? string? string? cells/c)]
 [set-values! (-> com-object? string? string? cells/c any)])

;; Try to be smart about getting ahold of excel. If it's running, use
;; that instance. If not, create a new instance.
(define (excel-instance)
  (define class-name "Microsoft Excel Application")
  (with-handlers ([exn? (lambda (ex)
                          (cocreate-instance-from-coclass class-name))])
    (com-get-active-object-from-coclass class-name)))

;; call the open method to access an existing workbook.
(define (open path)
  (let* ([excel (excel-instance)]
         [workbooks (com-get-property excel "Workbooks")])
    (com-invoke workbooks "Open" (if (path? path)
                                     (path->string path) path))))

;; Create a fresh workbook
(define (new)
  (let* ([excel (excel-instance)]
         [workbooks (com-get-property excel "Workbooks")])
    (com-invoke workbooks "Add")))

;; Close a workbook
(define (close doc)
  (com-invoke doc "Close"))

;; A private function to access a range. You provide
;; the document, the sheet of interest and the range.
;; Note the range can be any of the following:
;;  A3:B6 - a group of cells
;;  C17   - a single cell
;;  Foo   - a named range that's defined in the document already
;; There may be more options too - the range is just passed to excel to interpet.
(define (get-range doc sheet-name range)
  (let* ([sheets (com-get-property doc "Sheets")]
         [item (com-get-property sheets `("Item" ,sheet-name))])
    (com-get-property item `("Range" ,range))))

;; There's really no difference between getting and setting
;; one value over multiple values. We have a contract on these to 
;; provide some type checking and structure - but really, we leave Excel
;; in charge of figuring out when we mean 1 cell versus a block of cells.
(define (get-value doc sheet-name range)
  (com-get-property (get-range doc sheet-name range) "Value"))
(define (get-values doc sheet-name range)
  (com-get-property (get-range doc sheet-name range) "Value"))

;; Why Value2 below instead of Value? I have no idea. It works.
(define (set-values! doc sheet-name range value)
  (com-set-property! (get-range doc sheet-name range) "Value2" value))
(define (set-value! doc sheet-name range value)
  (com-set-property! (get-range doc sheet-name range) "Value2" value))
