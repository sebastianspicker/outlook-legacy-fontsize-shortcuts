#!/usr/bin/env bash
set -euo pipefail

if ! command -v osv-scanner >/dev/null 2>&1; then
  echo "SCA skipped: osv-scanner not installed. CI runs OSV-Scanner."
  exit 0
fi

if osv-scanner scan source --recursive .; then
  exit 0
fi

if osv-scanner --recursive .; then
  exit 0
fi

echo "SCA failed: osv-scanner returned a non-zero exit code."
exit 1
