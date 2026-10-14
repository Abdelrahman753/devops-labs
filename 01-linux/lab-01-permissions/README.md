# Lab 01 — Harbor permissions incidents

## Incident

After a rushed cleanup, Harbor staff cannot use files under `/srv/harbor-lab`. A few private files are open to the wrong people.

## Objectives

- See who can use each file with `id`, `groups`, `ls -l`, and `stat`.
- Restore the access listed below.
- Leave other users and system files alone.

## Instructions

1. Start the lab. You need Ubuntu and sudo.

```bash
curl -fsSL https://raw.githubusercontent.com/Abdelrahman753/devops-labs/main/01-linux/lab-01-permissions/bootstrap.sh | sudo bash
```

2. Log in as the user and try the problem. After you change access, log in again and try the same command. Type `exit` to come back.

```bash
su - lab-nora
/srv/harbor-lab/bin/deploy-check.sh
exit
```

| Account | Password | Who they are |
| --- | --- | --- |
| `lab-nora` | `nora-lab1` | Developer |
| `lab-omar` | `omar-lab1` | Developer |
| `lab-sam` | `sam-lab1` | New developer |
| `lab-lee` | `lee-lab1` | Support |
| `lab-app` | `app-lab1` | Application account |
| `lab-backup` | `backup-lab1` | Backup account |
| `lab-guest` | `guest-lab1` | Must not see private files |

3. Inspect the file and the user with `ls -l`, `stat`, `id`, and `groups`. Restore only the access described.
4. Do not make a file or directory writable by every user.

These are the problems:

1. `lab-nora` cannot run `/srv/harbor-lab/bin/deploy-check.sh`. It should print `deploy-check: ok`.
2. `lab-omar` cannot open `/srv/harbor-lab/projects`. `lab-guest` must stay out.
3. `/srv/harbor-lab/releases/version.txt` is owned by `lab-omar`. `lab-app` must own it and be able to change it. `lab-guest` must not read it.
4. `lab-omar` cannot save `/srv/harbor-lab/shared/roadmap.md`. Both developers need to edit it. `lab-guest` must not.
5. `lab-lee` cannot read `/srv/harbor-lab/logs/app.log`. `lab-app` still can. `lab-guest` must not. Do not add `lab-lee` to another group.
6. `lab-guest` and `lab-nora` can read `/srv/harbor-lab/secrets/db.env`. Only `lab-app` should read it.
7. `lab-sam` cannot read `/srv/harbor-lab/team/handbook.md`. The other developers can. `lab-guest` must not. The owner stays `root`.
8. `lab-nora` owns `/srv/harbor-lab/archive/2024/q4.txt` and still cannot read it. `lab-guest` must not.
9. `lab-backup` cannot create a file in `/srv/harbor-lab/backups`. `lab-guest` must not.
10. `lab-app` cannot read `/srv/harbor-lab/config/app.conf`. `lab-nora` can, and stays the owner. `lab-guest` must not. Do not add `lab-app` to `lab-engineering`.

## You are done when

- Each line above works when you try it as that user.
- `lab-guest` cannot read the database password or the app log.
- Nothing under `/srv/harbor-lab` is writable by every user.
- `sudo bash /opt/harbor-permissions-lab/tests/check-fixed.sh` prints `All fixed-state checks passed.`

## Reset

```bash
sudo bash /opt/harbor-permissions-lab/reset.sh
```

Lab users stay on the machine. The command is safe to run twice.

## Cleanup

```bash
sudo bash /opt/harbor-permissions-lab/cleanup.sh
```

That deletes the lab accounts, their lab groups, and `/srv/harbor-lab`. It does not remove other users.
