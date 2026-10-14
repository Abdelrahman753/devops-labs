# Ticket 05 — Support cannot read the app log

## Incident

Support engineer Lee (`lab-lee`) cannot read `/srv/harbor-lab/logs/app.log`. The shell answers "Permission denied". Lee needs to read that log during incidents. The application account `lab-app` must still be able to read it. `lab-guest` must not.

## Objectives

- Find out why support cannot read the log.
- Give Lee read access without opening the log to everyone.

## Instructions

Reproduce the failure as `lab-lee`. Inspect the log with `ls -l` and `stat`. Compare Lee's account with `id` and `groups`. Change the log file, not Lee's account: do not add `lab-lee` to another group. Do not make the log readable or writable by every user.

## You are done when

- `sudo -u lab-lee cat /srv/harbor-lab/logs/app.log` prints `disk almost full`.
- `sudo -u lab-app cat /srv/harbor-lab/logs/app.log` still prints `disk almost full`.
- `sudo -u lab-guest cat /srv/harbor-lab/logs/app.log` is denied.
- `id -nG lab-lee` still prints only `lab-support`.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
