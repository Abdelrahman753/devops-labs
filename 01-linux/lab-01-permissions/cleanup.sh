#!/bin/bash
# Remove only Harbor lab users, lab groups, and /srv/harbor-lab.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/constants.sh
source "$ROOT/lib/constants.sh"

require_root
assert_lab_path

lab_comment() {
  local name="$1"
  getent passwd "$name" | cut -d: -f5
}

marker_matches() {
  [[ -f /srv/harbor-lab/.lab-marker ]] \
    && [[ "$(cat /srv/harbor-lab/.lab-marker)" == "$LAB_MARKER_TEXT" ]]
}

refuse_unexpected_directory() {
  if [[ ! -e /srv/harbor-lab ]]; then
    return 0
  fi
  if [[ -L /srv/harbor-lab || ! -d /srv/harbor-lab ]]; then
    echo "Refusing to remove /srv/harbor-lab." >&2
    exit 1
  fi
  if ! marker_matches; then
    echo "Refusing to remove /srv/harbor-lab: lab marker missing." >&2
    exit 1
  fi
}

group_is_lab_only() {
  local group="$1"
  local line gid members member name pgid

  line=$(getent group "$group")
  gid=$(printf '%s\n' "$line" | cut -d: -f3)
  members=$(printf '%s\n' "$line" | cut -d: -f4)

  if [[ -n "$members" ]]; then
    IFS=',' read -ra member_list <<< "$members"
    for member in "${member_list[@]}"; do
      if ! is_lab_user "$member"; then
        echo "Refusing to remove group $group: member $member is not a lab user." >&2
        return 1
      fi
    done
  fi

  while IFS=: read -r name _ _ pgid _; do
    if [[ "$pgid" == "$gid" ]] && ! is_lab_user "$name"; then
      echo "Refusing to remove group $group: it is the primary group of $name." >&2
      return 1
    fi
  done < /etc/passwd
}

refuse_unexpected_directory

removed_user=0
for user in "${LAB_USERS[@]}"; do
  if ! id "$user" >/dev/null 2>&1; then
    continue
  fi
  if [[ "$(lab_comment "$user")" != "$LAB_COMMENT" ]]; then
    echo "Refusing to remove $user: the account is not a lab user." >&2
    exit 1
  fi
  home=$(getent passwd "$user" | cut -d: -f6)
  userdel "$user"
  if [[ "$home" == "/home/$user" && ! -L "$home" && -d "$home" ]]; then
    rm -rf -- "$home"
  fi
  removed_user=1
  echo "Removed user $user"
done

for group in "${LAB_GROUPS[@]}"; do
  if ! getent group "$group" >/dev/null; then
    continue
  fi
  group_is_lab_only "$group"
  groupdel "$group"
  echo "Removed group $group"
done

if [[ -d /srv/harbor-lab && ! -L /srv/harbor-lab ]]; then
  rm -rf -- /srv/harbor-lab
  echo "Removed /srv/harbor-lab"
elif [[ "$removed_user" -eq 0 ]]; then
  echo "Lab resources are already gone."
fi
