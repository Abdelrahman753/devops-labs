# Ticket 03 — Release marker owned by the wrong person

## Incident

The release marker `/srv/harbor-lab/releases/version.txt` is owned by Omar (`lab-omar`). The application account `lab-app` cannot update the version and gets "Permission denied". That file is for the application, not for Omar. `lab-guest` must not be able to read it.

## Objectives

- Confirm who owns the release marker.
- Let the application account update it, and keep guests out.

## Instructions

Reproduce the failure as `lab-app`. Inspect the file with `ls -l` and `stat`. The application account should become the owner. Do not make the file readable or writable by every user.

## You are done when

- `stat -c '%U' /srv/harbor-lab/releases/version.txt` prints `lab-app`.
- `sudo -u lab-app bash -c 'echo 1.4.3 > /srv/harbor-lab/releases/version.txt'` succeeds.
- `sudo -u lab-guest cat /srv/harbor-lab/releases/version.txt` is denied.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
