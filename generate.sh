#!/usr/bin/env bash
set -euo pipefail

work=$(mktemp -d)

main() {
	RESUME=resume.json
	if jq . resume.secret.json &> /dev/null; then
		jq -s '.[0] * .[1]' resume.json resume.secret.json > "$work/resume.json"
		RESUME="$work/resume.json"
	fi

	gomplate \
		-c .="$RESUME" \
		-f resume.tmpl.tex \
		-o resume.tex \
		--left-delim '<' --right-delim '>'

	texi2pdf -c -o resume.pdf -q resume.tex
}

cleanup() {
	rm -rf "$work"
}

trap cleanup EXIT
main "$@"
