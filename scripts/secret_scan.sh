#!/usr/bin/env bash
set -euo pipefail

patterns=(
  '-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----'
  'AKIA[0-9A-Z]{16}'
  'ASIA[0-9A-Z]{16}'
  'ghp_[A-Za-z0-9]{36,}'
  'github_pat_[A-Za-z0-9_]{20,}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  'AIza[0-9A-Za-z_-]{35}'
)

found=0
for pattern in "${patterns[@]}"; do
  if git grep -l -E "$pattern" -- . >/dev/null 2>&1; then
    echo "Potential secret pattern detected for: $pattern"
    git grep -l -E "$pattern" -- . | sort -u
    found=1
  fi
done

if [ "$found" -ne 0 ]; then
  echo "Secret scan failed. Remove secrets or add an approved exception."
  exit 1
fi

echo "Secret scan passed."
