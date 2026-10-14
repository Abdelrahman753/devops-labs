# Names shared by setup, reset, cleanup, and tests.
# shellcheck shell=bash

LAB_ROOT=/srv/harbor-lab
LAB_MARKER_TEXT=harbor-permissions-lab
LAB_COMMENT="Harbor permissions lab"

# Fixed allowlist. Cleanup refuses any other account.
LAB_USERS=(
  lab-nora
  lab-omar
  lab-sam
  lab-lee
  lab-app
  lab-backup
  lab-guest
)

LAB_GROUPS=(
  lab-engineering
  lab-support
  lab-ops
  lab-guest
  lab-sam
)

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "Run this script as root. Example: sudo ./setup.sh" >&2
    exit 1
  fi
}

assert_lab_path() {
  if [[ "$LAB_ROOT" != /srv/harbor-lab ]]; then
    echo "Refusing to continue: lab path is not /srv/harbor-lab." >&2
    exit 1
  fi
}

is_lab_user() {
  local name="$1"
  local candidate
  for candidate in "${LAB_USERS[@]}"; do
    if [[ "$candidate" == "$name" ]]; then
      return 0
    fi
  done
  return 1
}

# Lab-only passwords. Students use these with su.
lab_password() {
  case "$1" in
    lab-nora) printf '%s' 'nora-lab1' ;;
    lab-omar) printf '%s' 'omar-lab1' ;;
    lab-sam) printf '%s' 'sam-lab1' ;;
    lab-lee) printf '%s' 'lee-lab1' ;;
    lab-app) printf '%s' 'app-lab1' ;;
    lab-backup) printf '%s' 'backup-lab1' ;;
    lab-guest) printf '%s' 'guest-lab1' ;;
    *)
      echo "No lab password for $1" >&2
      return 1
      ;;
  esac
}
