#!/usr/bin/env bash
set -euo pipefail

echo "==> Secret scan"
bash scripts/secret_scan.sh

echo "==> Dependency scan (local optional)"
bash scripts/sca_check.sh

echo "==> Install Lua tools"
make tools

echo "==> Lint / format / test"
make check
