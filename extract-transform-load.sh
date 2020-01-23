#!/usr/bin/env bash

today=$(date "+%F")
dir=$(dirname "$0")
current_year=$(date "+%Y")

racket ${dir}/extract.2020-01-01.rkt
racket ${dir}/transform-load-csv.2019-11-02.rkt -c -p "$1"

7zr a /var/tmp/spdr/etf-holdings/${current_year}.7z /var/tmp/spdr/etf-holdings/${today}
