#lang racket/base

(require db
         gregor
         racket/cmdline
         racket/list
         racket/sequence
         racket/string
         racket/system
         threading)

(struct etf-component
  (name
   ticker
   identifier
   sedol
   weight
   sector
   shares-held
   local-currency)
  #:transparent)

(define base-folder (make-parameter "/var/tmp/spdr/etf-holdings"))

(define convert-xls (make-parameter #f))

(define folder-date (make-parameter (today)))

(define db-user (make-parameter "user"))

(define db-name (make-parameter "local"))

(define db-pass (make-parameter ""))

(command-line
 #:program "racket transform-load-csv.2019-11-02.rkt"
 #:once-each
 [("-b" "--base-folder") folder
                         "SPDR ETF Holdings base folder. Defaults to /var/tmp/spdr/etf-holdings"
                         (base-folder folder)]
 [("-c" "--convert-xls") "Convert XLS documents to CSV for handling. This requires libreoffice to be installed"
                         (convert-xls #t)]
 [("-d" "--folder-date") date
                         "SPDR ETF Holdings folder date. Defaults to today"
                         (folder-date (iso8601->date date))]
 [("-n" "--db-name") name
                     "Database name. Defaults to 'local'"
                     (db-name name)]
 [("-p" "--db-pass") password
                     "Database password"
                     (db-pass password)]
 [("-u" "--db-user") user
                     "Database user name. Defaults to 'user'"
                     (db-user user)])

(define dbc (postgresql-connect #:user (db-user) #:database (db-name) #:password (db-pass)))

(define sectors (list "Communication Services" "Consumer Discretionary" "Consumer Staples" "Energy" "Financials" "Health Care"
                      "Industrials" "Information Technology" "Materials" "Real Estate" "Telecommunication Services" "Utilities"))

; Core ETFs break down their components by sector
(define index-etfs (list "DIA" "MDY" "SLY" "SPY"))

(define industries (list
                    ; Materials
                    "Chemicals" "Construction Materials" "Containers & Packaging" "Metals & Mining"
                    ; Energy
                    "Energy Equipment & Services" "Oil Gas & Consumable Fuels"
                    ; Financials
                    "Banks" "Capital Markets" "Consumer Finance" "Financial Services" "Insurance"
                    ; Industrials
                    "Aerospace & Defense" "Air Freight & Logistics" "Airlines" "Building Products" "Commercial Services & Supplies"
                    "Construction & Engineering" "Electrical Equipment" "Ground Transportation" "Industrial Conglomerates" "Machinery"
                    "Professional Services" "Trading Companies & Distributors"
                    ; Technology
                    "Communications Equipment" "Diversified Telecommunication Services" "Electronic Equipment Instruments & Components"
                    "Internet Software & Services" "It Services" "Semiconductors & Semiconductor Equipment" "Software"
                    "Technology Hardware Storage & Peripherals"
                    ; Consumer Staples
                    "Beverages" "Consumer Staples Distribution & Retail" "Food Products" "Household Products" "Personal Care Products" "Tobacco"
                    ; Real Estate
                    "Health Care REITs" "Hotel & Resort REITs" "Industrial REITs" "Office REITs" "Real Estate Management & Development"
                    "Residential REITs" "Retail REITs" "Specialized REITs"
                    ; Utilities
                    "Electric Utilities" "Gas Utilities" "Independent Power And Renewable Electricity Producers" "Multi-Utilities" "Water Utilities"
                    ; Health Care
                    "Biotechnology" "Health Care Equipment & Supplies" "Health Care Providers & Services" "Health Care Technology"
                    "Life Sciences Tools & Services" "Pharmaceuticals"
                    ; Consumer Discretionary
                    "Automobile Components" "Automobiles" "Broadline Retail" "Distributors" "Diversified Consumer Services"
                    "Hotels Restaurants & Leisure" "Household Durables" "Leisure Products" "Media" "Multiline Retail"
                    "Specialty Retail" "Textiles Apparel & Luxury Goods"
                    ; Communication Services
                    "Interactive Media & Services" "Entertainment" "Wireless Telecommunication Services"))

; Sector ETFs break down their components by industry
(define sector-etfs (list "XLB" "XLC" "XLE" "XLF" "XLI" "XLK" "XLP" "XLRE" "XLU" "XLV" "XLY"))

(define sub-industries (list
                        ; Banks
                        "Asset Management & Custody Banks" "Commercial & Residential Mortgage Finance" "Diversified Banks"
                        "Diversified Financial Services" "Regional Banks"
                        ; Capital Markets
                        "Asset Management & Custody Banks" "Financial Exchanges & Data" "Investment Banking & Brokerage"
                        ; Insurance
                        "Insurance Brokers" "Life & Health Insurance" "Multi-Line Insurance" "Property & Casualty Insurance" "Reinsurance"
                        ; Regional Banks
                        "Diversified Banks" "Regional Banks"
                        ; Aerospace & Defense
                        "Aerospace & Defense"
                        ; Biotechnology
                        "Biotechnology"
                        ; Health Care Equipment
                        "Health Care Equipment" "Health Care Supplies" "Life Sciences Tools & Services"
                        ; Health Care Services
                        "Health Care Distributors" "Health Care Facilities" "Health Care Services" "Managed Health Care"
                        ; Metals & Mining
                        "Aluminum" "Coal & Consumable Fuels" "Copper" "Diversified Metals & Mining" "Gold" "Silver" "Steel"
                        ; Oil & Gas Equipment & Services
                        "Oil & Gas Equipment & Services" "Oil & Gas Drilling"
                        ; Oil & Gas Exploration & Production
                        "Integrated Oil & Gas" "Oil & Gas Exploration & Production" "Oil & Gas Refining & Marketing"
                        ; Homebuilders
                        "Building Products" "Home Furnishings" "Home Improvement Retail" "Homebuilding" "Homefurnishing Retail" "Household Appliances" 
                        ; Pharmaceuticals
                        "Pharmaceuticals"
                        ; Retail
                        "Apparel Retail" "Automotive Retail" "Broadline Retail" "Computer & Electronics Retail"
                        "Consumer Staples Merchandise Retail" "Drug Retail" "Food Retail" "General Merchandise Stores" "Other Specialty Retail"
                        ; Semiconductors
                        "Semiconductors"
                        ; Software & Services
                        "Application Software" "Data Processing & Outsourced Services" "Home Entertainment Software" "Interactive Home Entertainment"
                        "It Consulting & Other Services" "Research & Consulting Services" "Systems Software"
                        ; Technology Hardware
                        "Electronic Components" "Electronic Equipment & Instruments" "Technology Hardware Storage & Peripherals"
                        ; Telecommunications
                        "Alternative Carriers" "Communications Equipment" "Integrated Telecommunication Services"
                        "Wireless Telecommunication Services"
                        ; Transportation
                        "Air Freight & Logistics" "Airport Services" "Cargo Ground Transportation" "Marine" "Passenger Airlines"
                        "Passenger Ground Transportation" "Rail Transportation" "Trucking"
                        ; Internet
                        "Internet & Direct Marketing Retail" "Internet Software & Services" "Interactive Media & Services"
                        "Internet Services & Infrastructure" "Real Estate Services"))

; Industry ETFs break down their components by sub-industry
(define industry-etfs (list "KBE" "KCE" "KIE" "KRE" "XAR" "XBI" "XES" "XHB" "XHE" "XHS" "XME" "XOP" "XPH" "XRT" "XSD" "XSW" "XTH" "XTL" "XTN" "XWEB"))

(parameterize ([current-directory (string-append (base-folder) "/" (~t (folder-date) "yyyy-MM-dd") "/")])
  (cond [(convert-xls)
         (for ([p (sequence-filter (λ (p) (string-contains? (path->string p) ".xls")) (in-directory (current-directory)))])
           (system (string-append "libreoffice --headless --convert-to csv --outdir " (path->string (current-directory)) " " (path->string p))))])
  (for ([p (sequence-filter (λ (p) (string-contains? (path->string p) ".csv")) (in-directory (current-directory)))])
    (let* ([file-name (path->string p)]
           [ticker-symbol (string-replace (string-replace file-name (path->string (current-directory)) "") ".csv" "")])
      (call-with-input-file file-name
        (λ (in)
          (displayln file-name)
          (let*-values ([(sheet-values) (sequence->list (in-lines in))]
                        [(ignored-rows) (filter (λ (r) (not (or (string-contains? r "Fund Name:,")
                                                                (string-contains? r "Ticker Symbol:,")
                                                                (string-contains? r "Holdings:,")
                                                                (string-contains? r "Name,Ticker,Identifier,")
                                                                (string-contains? r "Important Risk Information")
                                                                (string-contains? r "Diversification does not")
                                                                (string-contains? r "Investing in commodities")
                                                                (string-contains? r "Important Information Relating")
                                                                (string-contains? r "The GLD prospectus")
                                                                (string-contains? r "The GLDM prospectus")
                                                                (string-contains? r "is a registered trademark")
                                                                (string-contains? r "SPD002545")
                                                                (string-contains? r ",,,,,,,")))) sheet-values)]
                        ; we do this string replace hack here because "Technology Hardware, Storage & Peripherals" added a comma.
                        ; this additional comma messes with our regexp-split call, and I am too lazy to rework it to do real regexp matching
                        ;
                        ; 2021-09-01 update:
                        ; This has been further missed for "Oil, Gas & Consumable Fuels" and "Hotels, Restaurants & Leisure".
                        ; Here's a command for the comma check:
                        ; $ for f in `ls /var/tmp/spdr/etf-holdings/2021-09-01 | grep csv` ; do echo $f ; grep -P "[0-9]+,\".*?\",[0-9]+" /var/tmp/spdr/etf-holdings/2021-09-01/$f ; done
                        [(altered-rows) (map (λ (r) (~> (string-replace r "Independent Power and Renewable Electricity Producers" "Independent Power And Renewable Electricity Producers")
                                                        (string-replace _ "IT Services" "It Services")
                                                        (string-replace _ "IT Consulting & Other Services" "It Consulting & Other Services")
                                                        (string-replace _ "Multi-line Insurance" "Multi-Line Insurance")
                                                        (string-replace _ "Aerospace & Defence" "Aerospace & Defense")
                                                        (string-replace _ "Equity Real Estate Investment Trusts (REITs)" "Equity Real Estate Investment Trusts (Reits)")
                                                        (string-replace _ "\"Technology Hardware, Storage & Peripherals\"" "Technology Hardware Storage & Peripherals")
                                                        (string-replace _ "\"Oil, Gas & Consumable Fuels\"" "Oil Gas & Consumable Fuels")
                                                        (string-replace _ "\"Hotels, Restaurants & Leisure\"" "Hotels Restaurants & Leisure"))) ignored-rows)]
                        [(filtered-rows) (filter (λ (r) (= 8 (length (regexp-split #rx"," r)))) altered-rows)]
                        [(rows) (map (λ (r) (apply etf-component (regexp-split #rx"," r))) filtered-rows)]
                        [(components) (map (λ (r) (etf-component
                                                   (etf-component-name r)
                                                   (etf-component-ticker r)
                                                   (etf-component-identifier r)
                                                   (etf-component-sedol r)
                                                   (etf-component-weight r)
                                                   (etf-component-sector r)
                                                   (etf-component-shares-held r)
                                                   (etf-component-local-currency r))) rows)]
                        [(valid-rows invalid-rows) (partition (λ (row) (or (member (etf-component-sector row) sectors)
                                                                           (member (etf-component-sector row) industries)
                                                                           (member (etf-component-sector row) sub-industries))) components)])
            (displayln "Will not insert the following rows as the Sector/Industry/Sub-Industry is not in our definitions:")
            (~> (filter (λ (row) (not (void? (etf-component-sector row)))) invalid-rows)
                (for-each (λ (row) (displayln row)) _))
            (define insert-counter 0)
            (define insert-success-counter 0)
            (define insert-failure-counter 0)
            (for-each (λ (row)
                        (set! insert-counter (add1 insert-counter))
                        (with-handlers ([exn:fail? (λ (e) (displayln (string-append "Failed to process component "
                                                                                    (etf-component-ticker row)
                                                                                    " for ETF "
                                                                                    ticker-symbol
                                                                                    " on date "
                                                                                    (date->iso8601 (folder-date))))
                                                      (displayln e)
                                                      (rollback-transaction dbc)
                                                      (set! insert-failure-counter (add1 insert-failure-counter)))])
                          (start-transaction dbc)
                          (query-exec dbc "
insert into spdr.etf_holding
(
  etf_symbol,
  date,
  component_symbol,
  weight,
  sector,
  industry,
  sub_industry,
  shares_held
) values (
  $1,
  $2::text::date,
  $3,
  $4::text::numeric,
  $5::text::spdr.sector,
  $6::text::spdr.industry,
  $7::text::spdr.sub_industry,
  $8::text::numeric
) on conflict (etf_symbol, date, component_symbol) do nothing;
"
                                      ticker-symbol
                                      (~t (folder-date) "yyyy-MM-dd")
                                      (case (etf-component-ticker row)
                                        [("CCL.U") "CCL"]
                                        [("*CM") "CM"]
                                        [else (etf-component-ticker row)])
                                      (etf-component-weight row)
                                      (if (member ticker-symbol index-etfs) (etf-component-sector row) sql-null)
                                      (if (member ticker-symbol sector-etfs) (etf-component-sector row) sql-null)
                                      (if (member ticker-symbol industry-etfs) (etf-component-sector row) sql-null)
                                      (etf-component-shares-held row))
                          (commit-transaction dbc)
                          (set! insert-success-counter (add1 insert-success-counter)))) valid-rows)
            (displayln (string-append "Attempted to insert " (number->string insert-counter) " rows. "
                                      (number->string insert-success-counter) " were successful. "
                                      (number->string insert-failure-counter) " failed."))))))))

(disconnect dbc)