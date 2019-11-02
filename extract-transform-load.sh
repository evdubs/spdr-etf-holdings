#!/usr/bin/env bash

dir=$(dirname "$0")

racket ${dir}/extract.rkt
racket ${dir}/transform-load-csv.2019-11-02.rkt -c -p "$1"
