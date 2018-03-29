# spdr-etf-holdings
These Racket programs will download the SPDR ETF holdings XLS documents and insert the holding data into a PostgreSQL database. 
The intended usage on Windows with Microsoft Excel is:

```bash
$ racket extract.rkt
$ racket transform-load-com.rkt
```

On other platforms, you will need to do something like the following (and will need some bit of software to do the XLS->CSV transformation):

```bash
$ racket extract.rkt
$ for f in `ls /var/tmp/spdr/etf-holdings/date/` ; do libreoffice --headless --convert-to csv --outdir /var/tmp/spdr/etf-holdings/date $f ; done
$ racket transform-load-csv.rkt
```

If you have libreoffice installed, you can instead just do the following as XLS->CSV conversion using libreoffice is supported within the process:

```bash
$ racket extract.rkt
$ racket transform-load-csv.rkt -c
```

The provided schema.sql file shows the expected schema within the target PostgreSQL instance. 
This process assumes you can write to a /var/tmp/spdr folder. This process also assumes you have loaded your database with NASDAQ symbol
file information. This data is provided by the [nasdaq-symbols](https://github.com/evdubs/nasdaq-symbols) project.

