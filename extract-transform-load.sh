#!/usr/bin/env bash

dir=$(dirname "$0")

racket ${dir}/extract.rkt
racket ${dir}/transform-load-csv.rkt -c -p "$1"
