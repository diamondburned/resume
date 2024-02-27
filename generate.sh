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

	# Enforce reproducible builds.
	# See https://reproducible-builds.org/docs/source-date-epoch/.
	export SOURCE_DATE_EPOCH=0

	gomplate \
		-c .="$input" \
		-o "$outputName.tex" \
		-f "$TEX_TEMPLATE" \
		--left-delim '<' --right-delim '>'

	tectonic -c minimal -Z shell-escape "$outputName.tex" \
		|& grep -v '^warning: ' \
		|  grep -v '^Invalid UTF-8 byte or sequence' \
		|  grep -v '^Requested font' \
		>&2
	rm "$outputName.tex"
}

# isValidJSON input.json
isValidJSON() {
	jq . "$1" &> /dev/null
}

cleanup() {
	# rm -rf "$WORK"
	:
}

if main "$@"; then
	cleanup
else
	echo "Error: failed to generate resume" >&2
	echo "Working directory: $WORK" >&2
	exit 1
fi
