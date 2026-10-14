#!/bin/bash
# Confirm each incident is present. Run this after setup.sh or reset.sh.
set -euo pipefail

# shellcheck source=helpers.sh
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

expect_denied \
  "ticket 01: nora cannot run the deploy check" \
  runuser -u lab-nora -- /srv/harbor-lab/bin/deploy-check.sh

expect_denied \
  "ticket 02: omar cannot list projects" \
  runuser -u lab-omar -- ls /srv/harbor-lab/projects

expect_denied \
  "ticket 03: app cannot update the release marker" \
  runuser -u lab-app -- bash -c 'echo 1.4.3 > /srv/harbor-lab/releases/version.txt'

owner=$(stat -c '%U' /srv/harbor-lab/releases/version.txt)
[[ "$owner" == "lab-omar" ]] || fail "ticket 03: release marker owner is $owner"
pass "ticket 03: release marker is owned by lab-omar"

expect_ok \
  "ticket 04: nora can update the roadmap" \
  runuser -u lab-nora -- bash -c 'echo nora-note >> /srv/harbor-lab/shared/roadmap.md'
expect_denied \
  "ticket 04: omar cannot update the roadmap" \
  runuser -u lab-omar -- bash -c 'echo omar-note >> /srv/harbor-lab/shared/roadmap.md'

expect_denied \
  "ticket 05: lee cannot read the app log" \
  runuser -u lab-lee -- cat /srv/harbor-lab/logs/app.log
expect_output \
  "ticket 05: app can still read the app log" \
  "disk almost full" \
  runuser -u lab-app -- cat /srv/harbor-lab/logs/app.log

expect_output \
  "ticket 06: guest can read the database password" \
  "DB_PASSWORD=lab-only-not-real" \
  runuser -u lab-guest -- cat /srv/harbor-lab/secrets/db.env

expect_denied \
  "ticket 07: sam cannot read the handbook" \
  runuser -u lab-sam -- cat /srv/harbor-lab/team/handbook.md
expect_output \
  "ticket 07: nora can read the handbook" \
  "engineering handbook" \
  runuser -u lab-nora -- cat /srv/harbor-lab/team/handbook.md

expect_denied \
  "ticket 08: nora cannot read her archive notes" \
  runuser -u lab-nora -- cat /srv/harbor-lab/archive/2024/q4.txt

expect_denied \
  "ticket 09: backup cannot create an archive" \
  runuser -u lab-backup -- touch /srv/harbor-lab/backups/nightly.marker

expect_denied \
  "ticket 10: app cannot read its config" \
  runuser -u lab-app -- cat /srv/harbor-lab/config/app.conf
expect_output \
  "ticket 10: nora can read the config" \
  "PORT=8080" \
  runuser -u lab-nora -- cat /srv/harbor-lab/config/app.conf

refuse_world_writable
echo "All broken-state checks passed."
