#lang racket/base

(require gregor
         net/url
         racket/file
         racket/list
         racket/port
         tasks
         threading)

(define (download-etf-holdings symbol)
  (make-directory* (string-append "/var/tmp/spdr/etf-holdings/" (~t (today) "yyyy-MM-dd")))
  (call-with-output-file (string-append "/var/tmp/spdr/etf-holdings/" (~t (today) "yyyy-MM-dd") "/" symbol ".xls")
    (λ (out) (~> (string-append "https://us.spdrs.com/site-content/xls/" symbol "_All_Holdings.xls")
                 (string->url _)
                 (get-pure-port _)
                 (copy-port _ out)))
    #:exists 'replace))

(define spdr-etfs (list
                   ; Core ETFs
                   "DIA" "MDY" "SLY" "SPSM" "SPY"
                   ; Sector ETFs
                   "XLB" "XLC" "XLE" "XLF" "XLI" "XLK" "XLP" "XLRE" "XLU" "XLV" "XLY"
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
