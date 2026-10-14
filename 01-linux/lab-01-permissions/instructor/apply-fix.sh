#!/bin/bash
# Apply the fixes documented in SOLUTION.md.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck source=../lib/constants.sh
source "$ROOT/lib/constants.sh"

require_root
assert_lab_path

if [[ ! -f /srv/harbor-lab/.lab-marker ]] || [[ "$(cat /srv/harbor-lab/.lab-marker)" != "$LAB_MARKER_TEXT" ]]; then
  echo "Lab is not set up. From the lab folder run: sudo ./setup.sh" >&2
  exit 1
fi

# 01 Nora can execute the deploy check. She already owns it.
chmod u+x /srv/harbor-lab/bin/deploy-check.sh

# 02 Engineering can enter the shared directory and create files.
#    The setgid bit keeps new files in lab-engineering.
chgrp lab-engineering /srv/harbor-lab/projects
chmod 2770 /srv/harbor-lab/projects

# 03 The application account owns the release marker.
chown lab-app:lab-ops /srv/harbor-lab/releases/version.txt
chmod 600 /srv/harbor-lab/releases/version.txt

# 04 Engineering can edit the roadmap. Others stay read-only.
chmod g+w /srv/harbor-lab/shared/roadmap.md

# 05 Support can read the log. Other users cannot.
chgrp lab-support /srv/harbor-lab/logs/app.log
chmod 640 /srv/harbor-lab/logs/app.log

# 06 Only the application account can read the database password.
chmod 600 /srv/harbor-lab/secrets/db.env

# 07 Sam gets the same engineering access as Nora and Omar.
usermod -aG lab-engineering lab-sam

# 08 Engineering can traverse the archive. Other users cannot.
chgrp lab-engineering /srv/harbor-lab/archive
chmod 750 /srv/harbor-lab/archive

# 09 The backup account can create archives. Other users cannot.
chown lab-backup:lab-ops /srv/harbor-lab/backups
chmod 750 /srv/harbor-lab/backups

# 10 Ops can read the config. Nora stays the owner. The app account stays out of engineering.
chgrp lab-ops /srv/harbor-lab/config/app.conf

echo "Applied the Harbor permission fixes."
