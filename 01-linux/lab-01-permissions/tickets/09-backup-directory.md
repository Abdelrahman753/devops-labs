# Ticket 09 — Backup account cannot save archives

## Incident

The nightly backup job runs as `lab-backup`. It cannot create a file in `/srv/harbor-lab/backups` and gets "Permission denied". The backup account needs to create archives there. `lab-guest` must not be able to create files in that directory.

## Objectives

- Find out why the backup account cannot create a file.
- Give that account write access without opening the directory to everyone.

## Instructions

Reproduce the failure as `lab-backup`. Inspect the directory with `ls -ld` and `stat`, and inspect the account with `id`. Do not make the directory writable by every user.

## You are done when

- `sudo -u lab-backup touch /srv/harbor-lab/backups/nightly.marker` succeeds.
- `sudo -u lab-guest touch /srv/harbor-lab/backups/guest.marker` is denied.
- The directory is not writable by every user.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
