#!/bin/bash
# Put the lab files and Sam's group membership back to the broken start.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
echo "Restoring the broken Harbor permissions lab."
exec ./setup.sh
