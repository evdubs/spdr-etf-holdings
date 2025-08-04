#!/usr/bin/env bash

today=$(date "+%F")
dir=$(dirname "$0")
current_year=$(date "+%Y")

racket -y ${dir}/extract.2021-10-01.rkt
racket -y ${dir}/transform-load-csv.2019-11-02.rkt -c -p "$1"

7zr a /var/local/spdr/etf-holdings/${current_year}.7z /var/local/spdr/etf-holdings/${today}
