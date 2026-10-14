# Ticket 04 — Developers cannot edit the roadmap

## Incident

Nora and Omar both work on `/srv/harbor-lab/shared/roadmap.md`. Nora can save changes. Omar can open the file but cannot save, and the shell answers "Permission denied". Both developers need to edit it. `lab-guest` must not be able to change it.

## Objectives

- See why one developer can edit the file and the other cannot.
- Let both developers save changes.

## Instructions

Reproduce the failure as `lab-omar`, then try the same change as `lab-nora`. Inspect the file with `ls -l` and `stat`, and compare the two accounts with `id`. Do not make the file writable by every user.

## You are done when

- `sudo -u lab-omar bash -c 'echo omar-edit >> /srv/harbor-lab/shared/roadmap.md'` succeeds.
- `sudo -u lab-nora bash -c 'echo nora-edit >> /srv/harbor-lab/shared/roadmap.md'` succeeds.
- `sudo -u lab-guest bash -c 'echo guest-edit >> /srv/harbor-lab/shared/roadmap.md'` is denied.

## Reset

From the lab folder, run `sudo ./reset.sh` to return all tickets to the broken start.
