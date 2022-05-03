#lang racket/base

(require db
         racket/cmdline
         racket/list
         racket/sequence
         racket/string
         srfi/19 ; Time Data Types and Procedures
         threading
         "xls-api.rkt")

(define base-folder (make-parameter "/var/tmp/spdr/etf-holdings"))

(define folder-date (make-parameter (current-date)))

(define db-user (make-parameter "user"))

(define db-name (make-parameter "local"))

(define db-pass (make-parameter ""))

(command-line
 #:program "racket transform-load-com.rkt"
 #:once-each
 [("-b" "--base-folder") folder
                         "SPDR ETF Holdings base folder. Defaults to /var/tmp/spdr/etf-holdings"
                         (base-folder folder)]
 [("-d" "--folder-date") date
                         "SPDR ETF Holdings folder date. Defaults to today"
                         (folder-date (string->date date "~Y-~m-~d"))]
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

(define sectors (list "Consumer Discretionary" "Consumer Staples" "Energy" "Financials" "Health Care" "Industrials"
                      "Information Technology" "Materials" "Real Estate" "Telecommunication Services" "Utilities"))

; Core ETFs break down their components by sector
(define index-etfs (list "DIA" "MDY" "SLY" "SPY"))

(define industries (list
                    ; Materials
                    "Chemicals" "Construction Materials" "Containers & Packaging" "Metals & Mining"
                    ; Energy
                    "Energy Equipment & Services" "Oil Gas & Consumable Fuels"
                    ; Financials
                    "Banks" "Capital Markets" "Consumer Finance" "Diversified Financial Services" "Insurance"
                    ; Industrials
                    "Aerospace & Defense" "Air Freight & Logistics" "Airlines" "Building Products" "Commercial Services & Supplies"
                    "Construction & Engineering" "Electrical Equipment" "Industrial Conglomerates" "Machinery" "Professional Services"
                    "Road & Rail" "Trading Companies & Distributors"
                    ; Technology
                    "Communications Equipment" "Diversified Telecommunication Services" "Electronic Equipment Instruments & Components"
                    "Internet Software & Services" "It Services" "Semiconductors & Semiconductor Equipment" "Software"
                    "Technology Hardware Storage & Peripherals"
                    ; Consumer Staples
                    "Beverages" "Food & Staples Retailing" "Food Products" "Household Products" "Personal Products" "Tobacco"
                    ; Real Estate
                    "Equity Real Estate Investment Trusts (Reits)" "Real Estate Management & Development"
                    ; Utilities
                    "Electric Utilities" "Independent Power And Renewable Electricity Producers" "Multi-Utilities" "Water Utilities"
                    ; Health Care
                    "Biotechnology" "Health Care Equipment & Supplies" "Health Care Providers & Services" "Health Care Technology"
                    "Life Sciences Tools & Services" "Pharmaceuticals"
                    ; Consumer Discretionary
                    "Auto Components" "Automobiles" "Distributors" "Diversified Consumer Services" "Hotels Restaurants & Leisure"
                    "Household Durables" "Internet & Direct Marketing Retail" "Leisure Products" "Media" "Multiline Retail"
                    "Specialty Retail" "Textiles Apparel & Luxury Goods"))

; Sector ETFs break down their components by industry
(define sector-etfs (list "XLB" "XLE" "XLF" "XLI" "XLK" "XLP" "XLRE" "XLU" "XLV" "XLY"))

(define sub-industries (list
                        ; Banks
                        "Asset Management & Custody Banks" "Diversified Banks" "Other Diversified Financial Services" "Regional Banks"
                        "Thrifts & Mortgage Finance"
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
                        "Health Care Equipment" "Health Care Supplies"
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
                        "Apparel Retail" "Automotive Retail" "Computer & Electronics Retail" "Department Stores" "Drug Retail"
                        "Food Retail" "General Merchandise Stores" "Hypermarkets & Super Centers" "Internet & Direct Marketing Retail"
                        "Specialty Stores"
                        ; Semiconductors
                        "Semiconductors"
                        ; Software & Services
                        "Application Software" "Data Processing & Outsourced Services" "Home Entertainment Software"
                        "It Consulting & Other Services" "Research & Consulting Services" "Systems Software"
                        ; Technology Hardware
                        "Electronic Components" "Electronic Equipment & Instruments" "Technology Hardware Storage & Peripherals"
                        ; Telecommunications
                        "Alternative Carriers" "Communications Equipment" "Integrated Telecommunication Services"
                        "Wireless Telecommunication Services"
                        ; Transportation
                        "Air Freight & Logistics" "Airlines" "Airport Services" "Marine" "Railroads" "Trucking"
                        ; Internet
                        "Internet & Direct Marketing Retail" "Internet Software & Services"))

; Industry ETFs break down their components by sub-industry
(define industry-etfs (list "KBE" "KCE" "KIE" "KRE" "XAR" "XBI" "XES" "XHB" "XHE" "XHS" "XME" "XOP" "XPH" "XRT" "XSD" "XSW" "XTH" "XTL" "XTN" "XWEB"))

(parameterize ([current-directory (string-append (base-folder) "/" (date->string (folder-date) "~1") "/")])
  (for ([p (sequence-filter (λ (p) (string-contains? (path->string p) ".xls")) (in-directory))])
    (let ([file-name (string-append (base-folder) "/" (date->string (folder-date) "~1") "/" (path->string p))]
          [ticker-symbol (string-replace (path->string p) ".xls" "")])
      (call-with-input-file file-name
        (λ (in)
          (displayln file-name)
          (let*-values ([(doc) (open file-name)]
                        [(sheet-values) (vector->list (get-values doc (string-append ticker-symbol "_All_Holdings") "A1:E1000"))]
                        [(valid-rows invalid-rows) (partition (λ (row) (or (member (vector-ref row 3) sectors)
                                                                           (member (vector-ref row 3) industries)
                                                                           (member (vector-ref row 3) sub-industries))) sheet-values)])
            (displayln "Will not insert the following rows as the Sector/Industry/Sub-Industry is not in our definitions:")
            (~> (filter (λ (row) (not (void? (vector-ref row 3)))) invalid-rows)
                (for-each (λ (row) (displayln row)) _))
            (with-handlers ([exn:fail? (λ (e) (displayln (string-append "Failed to process "
                                                                        ticker-symbol
                                                                        " for date "
                                                                        (date->string (folder-date) "~1")))
                                         (displayln e)
                                         (rollback-transaction dbc))])
              (for-each (λ (row)
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
                                      (date->string (folder-date) "~1")
                                      (case (vector-ref row 1)
                                        [("CCL.U") "CCL"]
                                        [("*CM") "CM"]
                                        [else (vector-ref row 1)])
                                      (vector-ref row 2)
                                      (if (member ticker-symbol index-etfs) (vector-ref row 3) sql-null)
                                      (if (member ticker-symbol sector-etfs) (vector-ref row 3) sql-null)
                                      (if (member ticker-symbol industry-etfs) (vector-ref row 3) sql-null)
                                      (vector-ref row 4))
                          (commit-transaction dbc)) valid-rows))
            (close doc)))))))

(disconnect dbc)
