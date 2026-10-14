# Ticket 07 — New developer cannot read the handbook

## Incident

Sam (`lab-sam`) joined engineering today. Nora and Omar can read `/srv/harbor-lab/team/handbook.md`. Sam cannot, and the shell answers "Permission denied". Sam needs the same read access the other developers already have. `lab-guest` must not be able to read the handbook. The file should stay owned by `root`.

## Objectives

- Compare Sam's account with the other developers.
- Give Sam the same handbook access they already have.

## Instructions

Reproduce the failure as `lab-sam`, then read the handbook as `lab-nora`. Compare the accounts with `id` and `groups`. Inspect the handbook and its directory with `ls -l` and `stat`. Do not change the handbook owner. Do not make the handbook readable by every user.

## You are done when

- `sudo -u lab-sam cat /srv/harbor-lab/team/handbook.md` prints `engineering handbook`.
- `sudo -u lab-nora cat /srv/harbor-lab/team/handbook.md` prints `engineering handbook`.
- `sudo -u lab-omar cat /srv/harbor-lab/team/handbook.md` prints `engineering handbook`.
- `sudo -u lab-guest cat /srv/harbor-lab/team/handbook.md` is denied.
- `sudo stat -c '%U' /srv/harbor-lab/team/handbook.md` prints `root`.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
