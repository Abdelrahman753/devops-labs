# Ticket 08 — Owner cannot open the archive notes

## Incident

Nora (`lab-nora`) owns `/srv/harbor-lab/archive/2024/q4.txt` and still cannot read it. The shell answers "Permission denied". She needs to open those notes. `lab-guest` must not. Nora should remain the owner of the notes file.

## Objectives

- Find what blocks Nora even though she owns the file.
- Restore her access without opening the notes to everyone.

## Instructions

Reproduce the failure as `lab-nora`. Inspect the notes file and each directory above it with `ls -ld` and `stat`. Do not change the owner of `q4.txt`. Do not make the archive writable by every user.

## You are done when

- `sudo -u lab-nora cat /srv/harbor-lab/archive/2024/q4.txt` prints `Q4 archive notes`.
- `sudo -u lab-guest cat /srv/harbor-lab/archive/2024/q4.txt` is denied.
- `sudo stat -c '%U' /srv/harbor-lab/archive/2024/q4.txt` prints `lab-nora`.
- `/srv/harbor-lab/archive` is not writable by every user.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
