#!/usr/bin/env bash
set -euo pipefail

WORK=$(mktemp -d)
TEX_TEMPLATE="resume.tmpl.tex"

main() {
	generate resume.json resume.pdf &

	if isValidJSON resume.secret.json; then
		jq -s '.[0] * .[1]' \
			resume.json \
			resume.secret.json > "$WORK/resume.secret.json"

		generate "$WORK/resume.secret.json" resume.secret.pdf &
	fi

	wait
}

# generate input.json output.pdf
generate() {
	local input="$1"
	local output="$2"
	local outputName="${output%.*}"

	gomplate \
		-c .="$input" \
		-o "$WORK/$outputName.tex" \
		-f "$TEX_TEMPLATE" \
		--left-delim '<' --right-delim '>'

	texi2pdf -c -q "$WORK/$outputName.tex" -o "$output"
}

# isValidJSON input.json
isValidJSON() {
	jq . "$1" &> /dev/null
}

cleanup() {
	rm -rf "$WORK"
}

trap cleanup EXIT
main "$@"
