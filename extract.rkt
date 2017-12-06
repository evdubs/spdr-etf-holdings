#lang racket

(require net/url)
(require srfi/19) ; Time Data Types and Procedures
(require tasks)
(require threading)

(define (download-etf-holdings symbol)
  (make-directory* (string-append "/var/tmp/spdr/etf-holdings/" (date->string (current-date) "~1")))
  (call-with-output-file (string-append "/var/tmp/spdr/etf-holdings/" (date->string (current-date) "~1") "/" symbol ".xls")
    (λ (out) (~> (string-append "https://us.spdrs.com/site-content/xls/" symbol "_All_Holdings.xls")
                 (string->url _)
                 (get-pure-port _)
                 (copy-port _ out)))
    #:exists 'replace))

(define spdr-etfs (list
                   ; Core ETFs
                   "DIA" "MDY" "SLY" "SPY"
                   ; Sector ETFs
                   "XLB" "XLE" "XLF" "XLI" "XLK" "XLP" "XLRE" "XLU" "XLV" "XLY"
                   ; Industry (Modified Equal Weighted) ETFs
                   "KBE" "KCE" "KIE" "KRE" "XAR" "XBI" "XES" "XHB" "XHE" "XHS" "XME" "XOP" "XPH" "XRT" "XSD" "XSW" "XTH" "XTL" "XTN" "XWEB"))

(define delay-interval 10)

(define delays (map (λ (x) (* delay-interval x)) (range 0 (length spdr-etfs))))

(with-task-server (for-each (λ (l) (schedule-delayed-task (λ () (download-etf-holdings (first l)))
                                                          (second l)))
                            (map list spdr-etfs delays))
  ; add a final task that will halt the task server
  (schedule-delayed-task (λ () (schedule-stop-task)) (* delay-interval (length delays)))
  (run-tasks))
