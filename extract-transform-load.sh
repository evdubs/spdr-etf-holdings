#!/usr/bin/env bash

today=$(date "+%F")
dir=$(dirname "$0")
current_year=$(date "+%Y")

racket -y ${dir}/extract.2021-10-01.rkt
racket -y ${dir}/transform-load-csv.2023-04-03.rkt -c -p "$1"

7zr a /var/tmp/spdr/etf-holdings/${current_year}.7z /var/tmp/spdr/etf-holdings/${today}
