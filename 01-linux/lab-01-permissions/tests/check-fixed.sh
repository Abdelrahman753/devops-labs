#!/bin/bash
# Confirm the expected access. Run this after the incidents are fixed.
set -euo pipefail

# shellcheck source=helpers.sh
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

expect_output \
  "ticket 01: nora can run the deploy check" \
  "deploy-check: ok" \
  runuser -u lab-nora -- /srv/harbor-lab/bin/deploy-check.sh
owner=$(stat -c '%U' /srv/harbor-lab/bin/deploy-check.sh)
[[ "$owner" == "lab-nora" ]] || fail "ticket 01: deploy check owner is $owner"
pass "ticket 01: deploy check is still owned by lab-nora"

expect_output \
  "ticket 02: omar can list projects" \
  "README" \
  runuser -u lab-omar -- ls /srv/harbor-lab/projects
expect_ok \
  "ticket 02: omar can create a project file" \
  runuser -u lab-omar -- touch /srv/harbor-lab/projects/omar-wrote.txt
expect_denied \
  "ticket 02: guest cannot list projects" \
  runuser -u lab-guest -- ls /srv/harbor-lab/projects

owner=$(stat -c '%U' /srv/harbor-lab/releases/version.txt)
[[ "$owner" == "lab-app" ]] || fail "ticket 03: release marker owner is $owner"
expect_ok \
  "ticket 03: app can update the release marker" \
  runuser -u lab-app -- bash -c 'echo 1.4.3 > /srv/harbor-lab/releases/version.txt'
expect_denied \
  "ticket 03: guest cannot read the release marker" \
  runuser -u lab-guest -- cat /srv/harbor-lab/releases/version.txt

expect_ok \
  "ticket 04: omar can update the roadmap" \
  runuser -u lab-omar -- bash -c 'echo omar-edit >> /srv/harbor-lab/shared/roadmap.md'
expect_ok \
  "ticket 04: nora can update the roadmap" \
  runuser -u lab-nora -- bash -c 'echo nora-edit >> /srv/harbor-lab/shared/roadmap.md'
expect_denied \
  "ticket 04: guest cannot update the roadmap" \
  runuser -u lab-guest -- bash -c 'echo guest-edit >> /srv/harbor-lab/shared/roadmap.md'

expect_output \
  "ticket 05: lee can read the app log" \
  "disk almost full" \
  runuser -u lab-lee -- cat /srv/harbor-lab/logs/app.log
expect_denied \
  "ticket 05: guest cannot read the app log" \
  runuser -u lab-guest -- cat /srv/harbor-lab/logs/app.log
expect_output \
  "ticket 05: app can still read the app log" \
  "disk almost full" \
  runuser -u lab-app -- cat /srv/harbor-lab/logs/app.log
lee_groups=$(id -nG lab-lee)
[[ "$lee_groups" == "lab-support" ]] || fail "ticket 05: lab-lee groups are '$lee_groups'"
pass "ticket 05: lab-lee was not added to another group"

expect_output \
  "ticket 06: app can read the database password" \
  "DB_PASSWORD=lab-only-not-real" \
  runuser -u lab-app -- cat /srv/harbor-lab/secrets/db.env
expect_denied \
  "ticket 06: guest cannot read the database password" \
  runuser -u lab-guest -- cat /srv/harbor-lab/secrets/db.env
expect_denied \
  "ticket 06: nora cannot read the database password" \
  runuser -u lab-nora -- cat /srv/harbor-lab/secrets/db.env

expect_output \
  "ticket 07: sam can read the handbook" \
  "engineering handbook" \
  runuser -u lab-sam -- cat /srv/harbor-lab/team/handbook.md
expect_output \
  "ticket 07: nora can read the handbook" \
  "engineering handbook" \
  runuser -u lab-nora -- cat /srv/harbor-lab/team/handbook.md
expect_output \
  "ticket 07: omar can read the handbook" \
  "engineering handbook" \
  runuser -u lab-omar -- cat /srv/harbor-lab/team/handbook.md
expect_denied \
  "ticket 07: guest cannot read the handbook" \
  runuser -u lab-guest -- cat /srv/harbor-lab/team/handbook.md
handbook_owner=$(stat -c '%U' /srv/harbor-lab/team/handbook.md)
[[ "$handbook_owner" == "root" ]] || fail "ticket 07: handbook owner is $handbook_owner"
pass "ticket 07: handbook is still owned by root"

expect_output \
  "ticket 08: nora can read the archive notes" \
  "Q4 archive notes" \
  runuser -u lab-nora -- cat /srv/harbor-lab/archive/2024/q4.txt
expect_denied \
  "ticket 08: guest cannot read the archive notes" \
  runuser -u lab-guest -- cat /srv/harbor-lab/archive/2024/q4.txt
notes_owner=$(stat -c '%U' /srv/harbor-lab/archive/2024/q4.txt)
[[ "$notes_owner" == "lab-nora" ]] || fail "ticket 08: notes owner is $notes_owner"
pass "ticket 08: archive notes are still owned by lab-nora"

expect_ok \
  "ticket 09: backup can create an archive" \
  runuser -u lab-backup -- touch /srv/harbor-lab/backups/nightly.marker
expect_denied \
  "ticket 09: guest cannot create an archive" \
  runuser -u lab-guest -- touch /srv/harbor-lab/backups/guest.marker

expect_output \
  "ticket 10: app can read its config" \
  "PORT=8080" \
  runuser -u lab-app -- cat /srv/harbor-lab/config/app.conf
expect_output \
  "ticket 10: nora can still read the config" \
  "PORT=8080" \
  runuser -u lab-nora -- cat /srv/harbor-lab/config/app.conf
expect_denied \
  "ticket 10: guest cannot read the config" \
  runuser -u lab-guest -- cat /srv/harbor-lab/config/app.conf
config_owner=$(stat -c '%U' /srv/harbor-lab/config/app.conf)
[[ "$config_owner" == "lab-nora" ]] || fail "ticket 10: config owner is $config_owner"
pass "ticket 10: config is still owned by lab-nora"
if id -nG lab-app | grep -qw lab-engineering; then
  fail "ticket 10: lab-app is a member of lab-engineering"
fi
pass "ticket 10: lab-app was not added to lab-engineering"

refuse_world_writable
echo "All fixed-state checks passed."
