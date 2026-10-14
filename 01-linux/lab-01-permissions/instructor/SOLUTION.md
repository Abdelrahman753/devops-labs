# Instructor solution — Harbor permissions incidents

Trainees do not receive this file. Apply it only after they have tried the tickets.

From the lab folder:

```bash
sudo ./setup.sh
sudo ./instructor/apply-fix.sh
sudo ./tests/check-fixed.sh
```

`apply-fix.sh` is the same sequence as the commands below. Checks run as the affected lab user through `runuser`, which is the same access `sudo -u` uses.

## Ticket 01 — Deploy check will not run

Nora owns the script, and the mode is `644`, so the owner can read it but cannot execute it.

```bash
chmod u+x /srv/harbor-lab/bin/deploy-check.sh
```

`u+x` turns `644` into `744`. Nora can run it. It is still not writable by the group or by everyone else.

Before that change, Bash reports `Permission denied`. `sudo -u lab-nora /srv/harbor-lab/bin/deploy-check.sh` reports `command not found` until the file is executable. Check Nora with Bash:

```bash
sudo -u lab-nora bash -c '/srv/harbor-lab/bin/deploy-check.sh'
```

Expected output: `deploy-check: ok`

## Ticket 02 — Engineering cannot open the project directory

`/srv/harbor-lab/projects` is mode `700` and owned by `root:root`. Omar is in `lab-engineering`, but the directory's group is `root`, so his group membership does not help.

```bash
chgrp lab-engineering /srv/harbor-lab/projects
chmod 2770 /srv/harbor-lab/projects
```

`2770` means: setgid, owner `rwx`, group `rwx`, others nothing. Engineering can list and create files. New files inherit the group `lab-engineering`. `770` also lets the team in; `2770` is the better shared-directory mode. Do not use `777`.

```bash
sudo -u lab-omar ls /srv/harbor-lab/projects
sudo -u lab-omar touch /srv/harbor-lab/projects/omar-wrote.txt
sudo -u lab-guest ls /srv/harbor-lab/projects
```

The guest command is denied.

## Ticket 03 — Release marker owned by the wrong person

`version.txt` is mode `600` and owned by `lab-omar`. Only Omar can read or write it.

```bash
chown lab-app:lab-ops /srv/harbor-lab/releases/version.txt
chmod 600 /srv/harbor-lab/releases/version.txt
```

The application account becomes the owner. Mode `600` keeps guests out.

```bash
sudo -u lab-app bash -c 'echo 1.4.3 > /srv/harbor-lab/releases/version.txt'
sudo -u lab-guest cat /srv/harbor-lab/releases/version.txt
stat -c '%U' /srv/harbor-lab/releases/version.txt
```

## Ticket 04 — Developers cannot edit the roadmap

The roadmap is mode `644`, group `lab-engineering`. Nora can write because she is the owner. Omar is only in the group, and the group has read but not write.

```bash
chmod g+w /srv/harbor-lab/shared/roadmap.md
```

That changes `644` to `664`. Both developers can append. Others can still read, not write.

```bash
sudo -u lab-omar bash -c 'echo omar-edit >> /srv/harbor-lab/shared/roadmap.md'
sudo -u lab-guest bash -c 'echo guest-edit >> /srv/harbor-lab/shared/roadmap.md'
```

## Ticket 05 — Support cannot read the app log

`app.log` is mode `600`, owner `lab-app`, group `lab-ops`. Lee's only group is `lab-support`, so she is not the owner and not in the file's group.

```bash
chgrp lab-support /srv/harbor-lab/logs/app.log
chmod 640 /srv/harbor-lab/logs/app.log
```

Group `lab-support` can read. Everyone else cannot. Lee's account stays in `lab-support` only. Do not add her to `lab-ops`.

```bash
sudo -u lab-lee cat /srv/harbor-lab/logs/app.log
sudo -u lab-guest cat /srv/harbor-lab/logs/app.log
id -nG lab-lee
```

## Ticket 06 — Database password is readable by everyone

`db.env` is mode `644`. Owner, group, and everyone else can read it.

```bash
chmod 600 /srv/harbor-lab/secrets/db.env
```

Only `lab-app`, the owner, can read it. Nora and the guest account cannot.

```bash
sudo -u lab-app cat /srv/harbor-lab/secrets/db.env
sudo -u lab-nora cat /srv/harbor-lab/secrets/db.env
sudo -u lab-guest cat /srv/harbor-lab/secrets/db.env
```

## Ticket 07 — New developer cannot read the handbook

The team directory is mode `750` and the handbook is mode `640`, both group `lab-engineering`. Nora and Omar are in that group. Sam's only group is `lab-sam`.

```bash
usermod -aG lab-engineering lab-sam
```

`-aG` adds a supplementary group and does not remove Sam's existing group. A new `sudo -u lab-sam` session sees the new group. An already-open shell would not, until that user logs in again.

```bash
sudo -u lab-sam cat /srv/harbor-lab/team/handbook.md
id lab-sam
```

Do not `chmod` the handbook to a world-readable mode. That would let `lab-guest` read it too.

## Ticket 08 — Owner cannot open the archive notes

Nora owns `q4.txt` and the mode is `644`, so the file itself allows her to read it. The parent `/srv/harbor-lab/archive` is mode `700` and owned by `root:root`. Reaching a file requires search permission (`x`) on every directory above it. Nora does not have `x` on `archive`.

```bash
chgrp lab-engineering /srv/harbor-lab/archive
chmod 750 /srv/harbor-lab/archive
```

Nora is in `lab-engineering`, so the group `x` lets her through. Others, including `lab-guest`, still cannot enter. Changing only `q4.txt` does not fix this.

```bash
sudo -u lab-nora cat /srv/harbor-lab/archive/2024/q4.txt
sudo -u lab-guest cat /srv/harbor-lab/archive/2024/q4.txt
namei -l /srv/harbor-lab/archive/2024/q4.txt
```

`namei -l` is optional. It prints the mode of each directory on the path.

## Ticket 09 — Backup account cannot save archives

`/srv/harbor-lab/backups` is mode `755` and owned by `root:root`. The backup account can pass through the directory but cannot create files, because write on a directory belongs to the owner and the group, not to everyone else.

```bash
chown lab-backup:lab-ops /srv/harbor-lab/backups
chmod 750 /srv/harbor-lab/backups
```

`lab-backup` is the owner, so it can create files. Mode `750` gives the group read and search, and gives everyone else nothing.

```bash
sudo -u lab-backup touch /srv/harbor-lab/backups/nightly.marker
sudo -u lab-guest touch /srv/harbor-lab/backups/guest.marker
```

## Ticket 10 — App cannot read its config

`app.conf` is mode `640`, owner `lab-nora`, group `lab-engineering`. Nora can read it as the owner. `lab-app` is in `lab-ops`, not `lab-engineering`, and the "other" bits are `0`.

```bash
chgrp lab-ops /srv/harbor-lab/config/app.conf
```

The mode can stay `640`. The application account's group can read. Nora remains the owner. Do not add `lab-app` to `lab-engineering`, and do not use mode `644`, which would let `lab-guest` read the file.

```bash
sudo -u lab-app cat /srv/harbor-lab/config/app.conf
sudo -u lab-guest cat /srv/harbor-lab/config/app.conf
stat -c '%U %G %a' /srv/harbor-lab/config/app.conf
id -nG lab-app
```

## Check the whole lab

Broken start, after `sudo ./setup.sh` or `sudo ./reset.sh`:

```bash
sudo ./tests/check-broken.sh
```

After the fix:

```bash
sudo ./tests/check-fixed.sh
```

`sudo ./reset.sh` rebuilds the broken files and removes `lab-sam` from `lab-engineering`. It is safe to run twice. `sudo ./cleanup.sh` removes only the lab users, lab groups, and `/srv/harbor-lab`.
