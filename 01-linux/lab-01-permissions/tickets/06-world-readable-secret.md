# Ticket 06 — Database password is readable by everyone

## Incident

The database password file `/srv/harbor-lab/secrets/db.env` is readable by accounts that should not see it, including `lab-guest` and developer Nora (`lab-nora`). Only the application account `lab-app` should be able to read it. The password value is a lab placeholder, not a real credential.

## Objectives

- See who can read the password file.
- Limit that file to the application account.

## Instructions

Try to read the file as `lab-guest`, `lab-nora`, and `lab-app`. Inspect it with `ls -l` and `stat`. Leave the file contents unchanged. Do not make it writable by every user.

## You are done when

- `sudo -u lab-app cat /srv/harbor-lab/secrets/db.env` prints `DB_PASSWORD=lab-only-not-real`.
- `sudo -u lab-guest cat /srv/harbor-lab/secrets/db.env` is denied.
- `sudo -u lab-nora cat /srv/harbor-lab/secrets/db.env` is denied.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
