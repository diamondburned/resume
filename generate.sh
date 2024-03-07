#!/usr/bin/env bash
set -euo pipefail

WORK=$(mktemp -d)
PIDS=()
TEX_TEMPLATE="resume.tmpl.tex"

main() {
	if ! jq . resume.json >/dev/null 2>&1; then
		echo "Error: resume.json is not a valid JSON file" >&2
		return 1
	fi

	generate_async resume.json resume.pdf

	if jq -s '.[0] * .[1]' \
		resume.json \
		resume.secret.json \
		1> "$WORK/resume.secret.json" \
		2>/dev/null
	then
		generate_async "$WORK/resume.secret.json" resume.secret.pdf
	fi

	generate_finish
}

# generate_async input.json output.pdf
generate_async() {
	generate "$1" "$2" &
	PIDS+=($!)
}

# generate_finish
generate_finish() {
	# Wait for each PID individually. This allows the status code to be
	# propagated correctly.
	local status=0
	for pid in "${PIDS[@]}"; do
		wait "$pid" || status=$?
	done

	# Ensure that all background processes have finished separately before
	# returning.
	wait

	return $status
}

# generate input.json output.pdf
generate() {
	local input="$1"
	local output="$2"
	local outputName="${output%.*}"

	# Enforce reproducible builds.
	# See https://reproducible-builds.org/docs/source-date-epoch/.
	export SOURCE_DATE_EPOCH=0

	if ! gomplate \
		-c .="$input" \
		-o "$outputName.tex" \
		-f "$TEX_TEMPLATE" \
		--left-delim '<' --right-delim '>'
	then
		return 1
	fi

	tectonic -c minimal "$outputName.tex"
	status=$?

	rm "$outputName.tex"
	return $status
}

if main "$@"; then
	rm -r "$WORK"
else
	echo "Error: failed to generate resume" >&2
	echo "Working directory: $WORK" >&2
	exit 1
fi
