#!/bin/bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPO="$DIR/.."
FLY_TEAM=wg-arp-diego

main() {
  local pipeline_dir="$(realpath $REPO/pipelines)"
  fly_login
  fly_pipeline wg-arp-diego-modules -f "${pipeline_dir}/wg-arp-diego-modules.yml" \
    -f "$REPO/index.yml" \
    -f "$REPO/../shared/helpers/ytt-helpers.star"
}

main
