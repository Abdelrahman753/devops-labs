# Ticket 10 — App cannot read its config

## Incident

The Harbor application runs as `lab-app` and cannot read `/srv/harbor-lab/config/app.conf`. The shell answers "Permission denied". Nora (`lab-nora`) maintains that file and can read it. She should remain the owner. The application must be able to read the file. `lab-guest` must not. Do not put `lab-app` in the engineering group; that would give the application the developers' other files.

## Objectives

- Find out why the application account cannot read a file Nora can read.
- Give the application read access without handing it Nora's other access.

## Instructions

Reproduce the failure as `lab-app`, then read the file as `lab-nora`. Inspect the file with `ls -l` and `stat`. Compare both accounts with `id` and `groups`. Leave Nora as the owner. Do not add `lab-app` to `lab-engineering`. Do not make the file readable by every user.

## You are done when

- `sudo -u lab-app cat /srv/harbor-lab/config/app.conf` prints `PORT=8080`.
- `sudo -u lab-nora cat /srv/harbor-lab/config/app.conf` prints `PORT=8080`.
- `sudo -u lab-guest cat /srv/harbor-lab/config/app.conf` is denied.
- `stat -c '%U' /srv/harbor-lab/config/app.conf` prints `lab-nora`.
- `id -nG lab-app` does not include `lab-engineering`.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
