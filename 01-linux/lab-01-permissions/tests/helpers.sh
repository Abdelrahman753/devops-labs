# shellcheck shell=bash

LAB_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck source=../lib/constants.sh
source "$LAB_DIR/lib/constants.sh"

require_root

if ! command -v runuser >/dev/null; then
  echo "runuser is required (util-linux)." >&2
  exit 1
fi

if [[ ! -f "$LAB_ROOT/.lab-marker" ]] || [[ "$(cat "$LAB_ROOT/.lab-marker")" != "$LAB_MARKER_TEXT" ]]; then
  echo "Lab directory is missing. Run sudo ./setup.sh first." >&2
  exit 1
fi

pass() {
  echo "PASS: $*"
}

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

expect_output() {
  local desc="$1"
  local want="$2"
  shift 2
  local out
  if ! out=$("$@" 2>&1); then
    fail "$desc"$'\n'"$out"
  fi
  if [[ "$out" != *"$want"* ]]; then
    fail "$desc (output was: $out)"
  fi
  pass "$desc"
}

expect_ok() {
  local desc="$1"
  shift
  local out
  if ! out=$("$@" 2>&1); then
    fail "$desc"$'\n'"$out"
  fi
  pass "$desc"
}

expect_denied() {
  local desc="$1"
  shift
  local out rc
  set +e
  out=$("$@" 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -eq 0 ]]; then
    fail "$desc (command succeeded: $out)"
  fi
  if [[ "$out" != *"Permission denied"* ]]; then
    fail "$desc (expected Permission denied, rc=$rc, output: $out)"
  fi
  pass "$desc"
}

refuse_world_writable() {
  local path found=0
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    echo "World-writable: $path" >&2
    found=1
  done < <(find "$LAB_ROOT" -perm /o+w -print)
  if [[ "$found" -ne 0 ]]; then
    fail "a lab path is writable by every user"
  fi
  pass "nothing under $LAB_ROOT is world-writable"
}
