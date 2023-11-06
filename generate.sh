#!/usr/bin/env bash
set -euo pipefail

gomplate \
	-c .=./resume.json \
	-f resume.tmpl.tex \
	-o resume.tex \
	--left-delim '<' --right-delim '>'

texi2pdf -c -o resume.pdf -q resume.tex
