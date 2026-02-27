#!/usr/bin/env bash
set -euo pipefail

multipass list --format json | jq -r '.list[].name' | xargs -n1 multipass delete --purge