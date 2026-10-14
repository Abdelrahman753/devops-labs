#!/bin/bash
# Create Harbor lab users and the broken permission incidents.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/constants.sh
source "$ROOT/lib/constants.sh"

require_root
assert_lab_path
umask 022

ensure_group() {
  local name="$1"
  if ! getent group "$name" >/dev/null; then
    groupadd "$name"
  fi
}

ensure_user() {
  local name="$1"
  local group="$2"

  if id "$name" >/dev/null 2>&1; then
    local comment shell group_now
    comment=$(getent passwd "$name" | cut -d: -f5)
    if [[ "$comment" != "$LAB_COMMENT" ]]; then
      echo "Refusing to change $name: the account exists and is not a lab user." >&2
      exit 1
    fi
    shell=$(getent passwd "$name" | cut -d: -f7)
    group_now=$(id -gn "$name")
    if [[ "$group_now" != "$group" || "$shell" != "/bin/bash" ]]; then
      usermod --gid "$group" --shell /bin/bash --comment "$LAB_COMMENT" "$name"
    fi
  else
    useradd \
      --create-home \
      --shell /bin/bash \
      --gid "$group" \
      --comment "$LAB_COMMENT" \
      "$name"
  fi

  # Lab accounts are used with sudo/runuser. They have no password.
  local locked
  locked=$(getent shadow "$name" | cut -d: -f2)
  case "$locked" in
    '!'*|'*'*) ;;
    *) usermod --lock "$name" ;;
  esac
}

drop_sam_from_engineering() {
  if id -nG lab-sam | grep -qw lab-engineering; then
    if [[ "$(id -gn lab-sam)" == "lab-engineering" ]]; then
      usermod --gid lab-sam lab-sam
    fi
    if id -nG lab-sam | grep -qw lab-engineering; then
      gpasswd -d lab-sam lab-engineering >/dev/null
    fi
  fi
}

write_tree() {
  if [[ -L "$LAB_ROOT" ]]; then
    echo "Refusing to replace $LAB_ROOT: it is a symlink." >&2
    exit 1
  fi
  if [[ -e "$LAB_ROOT" && ! -d "$LAB_ROOT" ]]; then
    echo "Refusing to replace $LAB_ROOT: it is not a directory." >&2
    exit 1
  fi
  if [[ -d "$LAB_ROOT" ]]; then
    local marker=""
    if [[ -f "$LAB_ROOT/.lab-marker" ]]; then
      marker=$(cat "$LAB_ROOT/.lab-marker")
    fi
    if [[ "$marker" != "$LAB_MARKER_TEXT" ]]; then
      echo "Refusing to replace $LAB_ROOT: it is not this lab." >&2
      exit 1
    fi
    rm -rf -- /srv/harbor-lab
  fi

  install -d -o root -g root -m 755 /srv/harbor-lab
  printf '%s\n' "$LAB_MARKER_TEXT" > /srv/harbor-lab/.lab-marker
  chmod 644 /srv/harbor-lab/.lab-marker

  # Ticket 01: Nora owns the deploy check, but it is not executable.
  install -d -o root -g root -m 755 /srv/harbor-lab/bin
  cat > /srv/harbor-lab/bin/deploy-check.sh <<'EOF'
#!/bin/bash
echo "deploy-check: ok"
EOF
  chown lab-nora:lab-engineering /srv/harbor-lab/bin/deploy-check.sh
  chmod 644 /srv/harbor-lab/bin/deploy-check.sh

  # Ticket 02: the engineering project directory is closed to the team.
  install -d -o root -g root -m 700 /srv/harbor-lab/projects
  printf '%s\n' "project-drop" > /srv/harbor-lab/projects/README
  chown root:root /srv/harbor-lab/projects/README
  chmod 644 /srv/harbor-lab/projects/README

  # Ticket 03: the release marker is owned by Omar, mode 600.
  install -d -o root -g root -m 755 /srv/harbor-lab/releases
  printf '%s\n' "1.4.2" > /srv/harbor-lab/releases/version.txt
  chown lab-omar:lab-engineering /srv/harbor-lab/releases/version.txt
  chmod 600 /srv/harbor-lab/releases/version.txt

  # Ticket 04: the roadmap is group-readable, not group-writable.
  install -d -o root -g root -m 755 /srv/harbor-lab/shared
  printf '%s\n' "Q4 roadmap" > /srv/harbor-lab/shared/roadmap.md
  chown lab-nora:lab-engineering /srv/harbor-lab/shared/roadmap.md
  chmod 644 /srv/harbor-lab/shared/roadmap.md

  # Ticket 05: the app log is readable only by the app account.
  install -d -o root -g root -m 755 /srv/harbor-lab/logs
  printf '%s\n' "disk almost full" > /srv/harbor-lab/logs/app.log
  chown lab-app:lab-ops /srv/harbor-lab/logs/app.log
  chmod 600 /srv/harbor-lab/logs/app.log

  # Ticket 06: the database password is world-readable.
  install -d -o root -g root -m 755 /srv/harbor-lab/secrets
  printf '%s\n' "DB_PASSWORD=lab-only-not-real" > /srv/harbor-lab/secrets/db.env
  chown lab-app:lab-ops /srv/harbor-lab/secrets/db.env
  chmod 644 /srv/harbor-lab/secrets/db.env

  # Ticket 07: the handbook is limited to lab-engineering. Sam is not a member.
  install -d -o root -g lab-engineering -m 750 /srv/harbor-lab/team
  printf '%s\n' "engineering handbook" > /srv/harbor-lab/team/handbook.md
  chown root:lab-engineering /srv/harbor-lab/team/handbook.md
  chmod 640 /srv/harbor-lab/team/handbook.md

  # Ticket 08: Nora owns the notes, but the archive directory blocks everyone else.
  install -d -o root -g root -m 700 /srv/harbor-lab/archive
  install -d -o lab-nora -g lab-engineering -m 755 /srv/harbor-lab/archive/2024
  printf '%s\n' "Q4 archive notes" > /srv/harbor-lab/archive/2024/q4.txt
  chown lab-nora:lab-engineering /srv/harbor-lab/archive/2024/q4.txt
  chmod 644 /srv/harbor-lab/archive/2024/q4.txt

  # Ticket 09: the backup directory is not writable by the backup account.
  install -d -o root -g root -m 755 /srv/harbor-lab/backups

  # Ticket 10: the config is owned by Nora and grouped for engineering, not ops.
  install -d -o root -g root -m 755 /srv/harbor-lab/config
  printf '%s\n' "PORT=8080" > /srv/harbor-lab/config/app.conf
  chown lab-nora:lab-engineering /srv/harbor-lab/config/app.conf
  chmod 640 /srv/harbor-lab/config/app.conf
}

ensure_group lab-engineering
ensure_group lab-support
ensure_group lab-ops
ensure_group lab-guest
ensure_group lab-sam

ensure_user lab-nora lab-engineering
ensure_user lab-omar lab-engineering
ensure_user lab-lee lab-support
ensure_user lab-app lab-ops
ensure_user lab-backup lab-ops
ensure_user lab-guest lab-guest
ensure_user lab-sam lab-sam
drop_sam_from_engineering

write_tree

cat <<EOF
Harbor permissions lab is ready.

Directory: /srv/harbor-lab
Next: read README.md

Lab users have no passwords. Example:
  sudo -u lab-nora ls -l /srv/harbor-lab/bin
EOF
