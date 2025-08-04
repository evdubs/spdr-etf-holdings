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
$ for f in `ls /var/local/spdr/etf-holdings/date/` ; do libreoffice --headless --convert-to csv --outdir /var/local/spdr/etf-holdings/date $f ; done
$ racket transform-load-csv.rkt
```

If you have libreoffice installed, you can instead just do the following as XLS->CSV conversion using libreoffice is supported within the process:

```bash
$ racket extract.rkt
$ racket transform-load-csv.rkt -c
```

You will need to provide a database password for the `transform-load-*.rkt` programs. The available parameters are:

```bash
$ racket transform-load-csv.2019-11-02.rkt -h
racket transform-load-csv.2019-11-02.rkt [ <option> ... ]
 where <option> is one of
  -b <folder>, --base-folder <folder> : SPDR ETF Holdings base folder. Defaults to /var/local/spdr/etf-holdings
  -c, --convert-xls : Convert XLS documents to CSV for handling. This requires libreoffice to be installed
  -d <date>, --folder-date <date> : SPDR ETF Holdings folder date. Defaults to today
  -n <name>, --db-name <name> : Database name. Defaults to 'local'
  -p <password>, --db-pass <password> : Database password
  -u <user>, --db-user <user> : Database user name. Defaults to 'user'
  --help, -h : Show this help
  -- : Do not treat any remaining argument as a switch (at this level)
 Multiple single-letter switches can be combined after one `-`. For
  example: `-h-` is the same as `-h --`
```

The provided `schema.sql` file shows the expected schema within the target PostgreSQL instance. 
This process assumes you can write to a `/var/local/spdr` folder. This process also assumes you have loaded your database with NASDAQ symbol
file information. This data is provided by the [nasdaq-symbols](https://github.com/evdubs/nasdaq-symbols) project.

### Dependencies

It is recommended that you start with the standard Racket distribution. With that, you will need to install the following packages:

```bash
$ raco pkg install --skip-installed gregor http-easy tasks threading
```

## Format and URL updates

On 2020-01-01, the URL for SPDR ETF documents changed; `extract.2020-01-01.rkt` uses this new location. 

On 2019-11-02, columns were added to the SPDR ETF documents; `transform-load.2019-11-02.rkt` can process these new columns.
