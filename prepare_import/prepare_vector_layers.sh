#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

RAW_JSON=$1
LIST_LAYERS=${RAW_JSON:17:-1}

echo "${LIST_LAYERS//\"/\\\"}"
