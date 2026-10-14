# Ticket 02 — Engineering cannot open the project directory

## Incident

Omar (`lab-omar`) cannot open the shared engineering directory `/srv/harbor-lab/projects`. The shell answers "Permission denied". The engineering team needs to list that directory and create files in it. `lab-guest` must still be kept out.

## Objectives

- Find out why a developer cannot enter the shared directory.
- Give the engineering team access without opening it to everyone.

## Instructions

Reproduce the failure as `lab-omar`. Inspect the directory with `ls -ld` and `stat`. Compare Omar's account with `id`. Restore team access. Do not make the directory writable by every user.

## You are done when

- `sudo -u lab-omar ls /srv/harbor-lab/projects` lists `README`.
- `sudo -u lab-omar touch /srv/harbor-lab/projects/omar-wrote.txt` succeeds.
- `sudo -u lab-guest ls /srv/harbor-lab/projects` is denied.
- The directory is not writable by every user.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
