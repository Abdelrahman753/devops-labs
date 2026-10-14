# Ticket 01 — Deploy check will not run

## Incident

Nora (`lab-nora`) runs Harbor's deploy check at `/srv/harbor-lab/bin/deploy-check.sh` from her shell. Bash reports `Permission denied`. The script text is fine. A successful run prints `deploy-check: ok`.

## Objectives

- Find out why Nora cannot run the script.
- Let Nora run it.

## Instructions

Reproduce the failure with `sudo -u lab-nora bash -c '/srv/harbor-lab/bin/deploy-check.sh'`. Inspect the script with `ls -l` and `stat`. Restore her access. Do not edit the script, and do not make it writable by every user.

## You are done when

- `sudo -u lab-nora bash -c '/srv/harbor-lab/bin/deploy-check.sh'` prints `deploy-check: ok`.
- The script is still owned by `lab-nora`.
- The script is not writable by every user.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
