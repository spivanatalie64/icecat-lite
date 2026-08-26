#!/usr/bin/env bash
# Audit: every data/ path referenced by makeicecat must exist in this repo.
set -euo pipefail
cd "$(dirname "$0")/.."

missing=0

# Extract literal DATADIR-relative paths from makeicecat and check them.
paths=$(
    grep -oE '"\$\{DATADIR\}"/[A-Za-z0-9_@./-]+' makeicecat |
        sed 's|"\${DATADIR}"/||' | sort -u
)
for p in ${paths}; do
    # strip trailing glob components for existence check of the parent
    if [[ ${p} == *\** ]]; then
        p="$(dirname "${p}")"
        [ -d "data/${p}" ] || { echo "MISSING dir: data/${p}"; missing=1; }
    elif [ ! -e "data/${p}" ]; then
        echo "MISSING: data/${p}"
        missing=1
    fi
done

# Cross-references used with DATADIR/../ prefix
for p in artwork/icecat.jpg tools/process-json-files.py; do
    [ -e "${p}" ] || { echo "MISSING: ${p}"; missing=1; }
done

# Extensions referenced implicitly: each dir must be a valid webext (MV2/MV3 manifest)
for m in data/extensions/*/manifest.json; do
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "${m}" ||
        { echo "INVALID JSON: ${m}"; missing=1; }
done

# DNR rulesets must parse and stay within Firefox limits (rule count cap is 30k)
for r in data/extensions/*/rules.json; do
    n=$(python3 -c "import json,sys; print(len(json.load(open(sys.argv[1]))))" "${r}")
    [ "${n}" -le 30000 ] || { echo "TOO MANY RULES (${n}): ${r}"; missing=1; }
done

exit ${missing}
