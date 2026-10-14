#!/bin/bash
# Download the Harbor permissions lab and create the broken starting state.
# curl -fsSL https://raw.githubusercontent.com/Abdelrahman753/devops-labs/main/01-linux/lab-01-permissions/bootstrap.sh | sudo bash
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/Abdelrahman753/devops-labs/main/01-linux/lab-01-permissions"
DEST="/opt/harbor-permissions-lab"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root:" >&2
  echo "  curl -fsSL ${BASE_URL}/bootstrap.sh | sudo bash" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

files=(
  README.md
  setup.sh
  reset.sh
  cleanup.sh
  lib/constants.sh
  tests/helpers.sh
  tests/check-broken.sh
  tests/check-fixed.sh
)

install -d -m 755 \
  "${DEST}" \
  "${DEST}/lib" \
  "${DEST}/tests"

if [[ -d "${DEST}/tickets" ]]; then
  rm -rf -- "${DEST}/tickets"
fi

for file in "${files[@]}"; do
  echo "Fetching ${file}"
  curl -fsSL "${BASE_URL}/${file}" -o "${DEST}/${file}"
done

chmod 755 \
  "${DEST}/setup.sh" \
  "${DEST}/reset.sh" \
  "${DEST}/cleanup.sh" \
  "${DEST}/tests/check-broken.sh" \
  "${DEST}/tests/check-fixed.sh"

bash "${DEST}/setup.sh"

cat <<EOF

Lab files: ${DEST}
Next:      ${DEST}/README.md
Reset:     sudo bash ${DEST}/reset.sh
Cleanup:   sudo bash ${DEST}/cleanup.sh
EOF
