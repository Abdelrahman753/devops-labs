# Lab 01 — Harbor permissions incidents

## Incident

After a rushed cleanup, Harbor staff cannot use scripts, shared folders, logs, and other files under `/srv/harbor-lab`. A few private files are readable by people who should not see them.

## Objectives

- Inspect accounts with `id` and `groups`.
- Inspect files and directories with `ls -l` and `stat`.
- Restore the access each ticket asks for.
- Leave unrelated users and system files alone.

## Instructions

On any Ubuntu VM, prepare the lab with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/Abdelrahman753/devops-labs/main/01-linux/lab-01-permissions/bootstrap.sh | sudo bash
```

That downloads this lab to `/opt/harbor-permissions-lab` and creates the broken starting state. You need permission to create local users. The script adds only the lab accounts below.

| Account | Who they are |
| --- | --- |
| `lab-nora` | Developer |
| `lab-omar` | Developer |
| `lab-sam` | New developer |
| `lab-lee` | Support |
| `lab-app` | Application account |
| `lab-backup` | Backup account |
| `lab-guest` | A person who should not see private files |

These accounts have no password. Run a command as one of them with `sudo`:

```bash
sudo -u lab-nora ls -l /srv/harbor-lab/bin
```

Open the tickets in order. Reproduce the problem as the account named in the ticket, then fix that ticket only. Do not make a file or directory writable by every user. `lab-guest` stands in for an unauthorized person.

1. [Deploy check will not run](tickets/01-deploy-script.md)
2. [Engineering cannot open the project directory](tickets/02-shared-projects.md)
3. [Release marker owned by the wrong person](tickets/03-wrong-owner.md)
4. [Developers cannot edit the roadmap](tickets/04-shared-roadmap.md)
5. [Support cannot read the app log](tickets/05-support-logs.md)
6. [Database password is readable by everyone](tickets/06-world-readable-secret.md)
7. [New developer cannot read the handbook](tickets/07-new-team-member.md)
8. [Owner cannot open the archive notes](tickets/08-parent-directory.md)
9. [Backup account cannot save archives](tickets/09-backup-directory.md)
10. [App cannot read its config](tickets/10-app-config.md)

## You are done when

- Every ticket's checks succeed when you run them as the affected account.
- `lab-guest` cannot read the database password or the app log.
- No file or directory under `/srv/harbor-lab` is writable by every user.
- `sudo bash /opt/harbor-permissions-lab/tests/check-fixed.sh` prints `All fixed-state checks passed.`

## Reset

Return to the broken starting state. Lab users stay on the machine. The command is safe to run twice.

```bash
sudo bash /opt/harbor-permissions-lab/reset.sh
```

## Cleanup

When the class is over, remove only this lab:

```bash
sudo bash /opt/harbor-permissions-lab/cleanup.sh
```

That deletes the lab accounts, their lab groups, and `/srv/harbor-lab`. It does not remove other users.
