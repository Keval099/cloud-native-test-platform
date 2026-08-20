# Linux Day 1–2 Cheat Sheet

> Practical notes from our Linux lab.  
> Focus: Linux fundamentals, processes, Bash job control, systemd services, and logs.

---

## 1. Linux Navigation

### Current directory

```bash
pwd
```

Shows the directory you are currently in.

### List files

```bash
ls
ls -l
ls -la
```

- `ls` — list files/directories
- `ls -l` — detailed listing
- `ls -la` — detailed listing including hidden files

### Change directory

```bash
cd <directory>
cd ..
cd ~
cd /
```

| Command | Meaning |
|---|---|
| `cd <directory>` | Enter a directory |
| `cd ..` | Go to parent directory |
| `cd ~` | Go to current user's home directory |
| `cd /` | Go to filesystem root |

Special paths:

```text
.   = current directory
..  = parent directory
~   = home directory
/   = filesystem root
```

---

## 2. Files and Directories

### Create a directory

```bash
mkdir <directory>
```

Create nested directories:

```bash
mkdir -p <path>
```

### Create an empty file

```bash
touch <file>
```

### Display file contents

```bash
cat <file>
```

### Edit a file

```bash
nano <file>
```

Nano basics:

```text
Ctrl + O  → Save
Enter     → Confirm filename
Ctrl + X  → Exit
```

### Copy

```bash
cp <source> <destination>
```

Copy a directory:

```bash
cp -r <source-directory> <destination-directory>
```

### Move / Rename

```bash
mv <old-name> <new-name>
```

### Delete

```bash
rm <file>
rm -r <directory>
```

Be careful with:

```bash
rm -rf
```

It can recursively delete files/directories without asking for confirmation.

---

## 3. Users and Privileges

### Current user

```bash
whoami
```

### User and group information

```bash
id
```

### Run a command with elevated privileges

```bash
sudo <command>
```

Example:

```bash
sudo systemctl restart cron
```

### Root

`root` is the Linux administrative user with extensive privileges.

---

## 4. Linux Permissions

Linux permissions use:

```text
r = read
w = write
x = execute
```

A typical permission string:

```text
-rwxr-xr--
```

Permissions are grouped as:

```text
Owner | Group | Others
```

Example:

```text
rwx | r-x | r--
```

### Change permissions

```bash
chmod <permissions> <file>
```

Example:

```bash
chmod +x script.sh
```

This makes a script executable.

---

# 5. Processes

## What is a process?

A **process is a running instance of a program or command**.

Example:

```bash
sleep 300
```

When `sleep` runs, Linux creates a process for it.

---

## `ps`

Show processes associated with the current shell:

```bash
ps
```

Show detailed process information:

```bash
ps aux
```

Example:

```bash
ps aux | head
```

### Check a specific process

```bash
ps -p <PID>
```

More useful output:

```bash
ps -o pid,ppid,stat,cmd -p <PID>
```

---

# 6. PID and PPID

## PID

**Process ID**

A unique identifier assigned to a process.

## PPID

**Parent Process ID**

The PID of the process that started/created the process.

Example:

```text
bash
PID 11
 |
 └── sleep
     PID 633
     PPID 11
```

So:

```text
sleep PID  = 633
sleep PPID = 11
```

---

# 7. Process States and Job Control

We practiced:

```bash
sleep 300
```

Then:

```text
Ctrl + Z
```

This **suspends** the process.

A stopped process can still exist.

In `ps` output, a `T` state indicates a stopped process.

### Important keyboard controls

```text
Ctrl + Z  → Suspend the foreground process
Ctrl + C  → Interrupt the foreground process
```

They are different.

---

# 8. Background Processes

Run a command in the background:

```bash
sleep 300 &
```

You may see:

```text
[1] 684
```

Where:

```text
1   = Bash job number
684 = Process ID
```

### View jobs managed by the current shell

```bash
jobs
```

Example:

```text
[1]+  Running  sleep 300 &
```

### Bring a job to the foreground

```bash
fg
```

### Terminate a process

```bash
kill <PID>
```

Example:

```bash
kill 684
```

Important:

> `kill` sends a signal to a process. It does not inherently mean "force kill."

---

# 9. Processes vs Jobs

These are related but different concepts.

### `ps`

Shows **processes**.

```bash
ps
```

### `jobs`

Shows **jobs managed by the current Bash shell**.

```bash
jobs
```

Example:

```text
sleep 300 &
```

creates:

```text
Bash job #1
PID 684
```

---

# 10. systemd

We configured WSL to use systemd by adding:

```ini
[boot]
systemd=true

[user]
default=keval
```

to:

```text
/etc/wsl.conf
```

After restarting WSL:

```bash
systemctl is-system-running
```

should report:

```text
running
```

## What is systemd?

At a high level:

```text
systemd
 |
 +-- cron.service
 +-- rsyslog.service
 +-- systemd-journald.service
 +-- systemd-resolved.service
 +-- ...
```

systemd manages services/units.

---

# 11. `systemctl`

`systemctl` is used to inspect and manage systemd services/units.

### Check systemd version

```bash
systemctl --version
```

### Check system state

```bash
systemctl is-system-running
```

### List running services

```bash
systemctl list-units --type=service --state=running
```

### Check a service

```bash
systemctl status <service>
```

Example:

```bash
systemctl status cron
```

For non-paged output:

```bash
systemctl status cron --no-pager
```

---

# 12. Start / Stop / Restart Services

### Start

```bash
sudo systemctl start <service>
```

Example:

```bash
sudo systemctl start cron
```

### Stop

```bash
sudo systemctl stop <service>
```

Example:

```bash
sudo systemctl stop cron
```

### Restart

```bash
sudo systemctl restart <service>
```

Example:

```bash
sudo systemctl restart cron
```

---

# 13. Active vs Enabled

This is one of the most important concepts from Day 2.

### `active`

```bash
systemctl is-active cron
```

Answers:

> Is the service active/running now?

Possible result:

```text
active
```

or:

```text
inactive
```

### `enabled`

```bash
systemctl is-enabled cron
```

Answers:

> Is the service configured to start automatically when the appropriate systemd boot target is reached?

Possible result:

```text
enabled
```

or:

```text
disabled
```

### Remember

```text
active  → "Is it running NOW?"
enabled → "Should it start automatically?"
```

They are independent.

Example:

```text
active + enabled
```

means:

```text
Running now
+
Configured for automatic startup
```

We also demonstrated:

```text
inactive + enabled
```

The cron service was stopped manually but remained enabled.

---

# 14. `journalctl`

`journalctl` is used to view and filter logs stored in the systemd journal.

### View the journal

```bash
journalctl
```

### Logs for a specific service

```bash
journalctl -u <service>
```

Example:

```bash
journalctl -u cron
```

`-u` means:

```text
unit/service
```

### Last 20 entries

```bash
journalctl -u cron -n 20
```

### Avoid the pager

```bash
journalctl -u cron --no-pager
```

Combined:

```bash
journalctl -u cron --no-pager -n 20
```

---

# 15. Current Boot Logs

Use:

```bash
journalctl -u cron -b
```

`-b` refers to the current boot.

Useful combination:

```bash
journalctl -u cron -b --no-pager -n 20
```

This is useful when you want to troubleshoot the current boot rather than older journal entries.

---

# 16. Follow Logs Live

Use:

```bash
journalctl -u cron -f
```

`-f` means:

> **Follow the journal and continuously display new log entries as they arrive.**

It does NOT mean "filter."

Remember:

```text
-u  → select the service/unit
-f  → follow new log entries
```

Example:

```text
Terminal 1:
journalctl -u cron -f
       |
       | watching
       v
systemd journal
       ^
       |
Terminal 2:
sudo systemctl restart cron
```

The restart generates new journal entries that appear in Terminal 1.

To stop following:

```text
Ctrl + C
```

This stops `journalctl`, **not the cron service**.

---

# 17. `grep`

`grep` searches text.

Basic:

```bash
grep "started" file.txt
```

Case-insensitive:

```bash
grep -i "started" file.txt
```

`-i` means case-insensitive.

Therefore:

```text
Started
STARTED
started
```

all match:

```bash
grep -i "started"
```

---

# 18. Pipes `|`

The pipe sends the output of one command into another command.

Example:

```bash
journalctl -u cron -b --no-pager | grep -i "started"
```

Conceptually:

```text
journalctl
    |
    v
log output
    |
    | pipe
    v
grep
    |
    v
matching lines
```

---

# 19. Practical Log Filtering

Find startup messages:

```bash
journalctl -u cron -b --no-pager | grep -i "started"
```

Find error messages:

```bash
journalctl -u cron -b --no-pager | grep -i "error"
```

Find environment-related messages:

```bash
journalctl -u cron -b --no-pager | grep -i "environment"
```

Important:

> No output from `grep` means no matching text was found. It does not automatically prove that the service is healthy.

---

# 20. Our Service Troubleshooting Workflow

This is the most important operational pattern from Day 2:

```text
              PROBLEM
                 |
                 v
              OBSERVE
                 |
                 v
       systemctl status
                 |
                 v
           CHECK STATE
                 |
          +------+------+
          |             |
      is-active    is-enabled
          |             |
          +------+------+
                 |
                 v
            CHECK LOGS
                 |
                 v
            journalctl
                 |
                 v
            FILTER LOGS
                 |
                 v
               grep
                 |
                 v
             DIAGNOSE
                 |
                 v
               FIX
                 |
                 v
      start / stop / restart
                 |
                 v
              VERIFY
                 |
                 v
       systemctl status
```

### Golden rule

> **Observe → Diagnose → Fix → Verify**

Do not restart/change something simply because there is a warning.

First establish whether the warning actually causes a problem.

---

# 21. Our Cron Troubleshooting Exercise

We used `cron` as our example service.

Healthy state:

```text
Active: active (running)
Enabled: enabled
```

We intentionally stopped it:

```bash
sudo systemctl stop cron
```

Then:

```bash
systemctl is-active cron
```

returned:

```text
inactive
```

while:

```bash
systemctl is-enabled cron
```

returned:

```text
enabled
```

This demonstrated:

```text
inactive + enabled
```

We then checked:

```bash
systemctl status cron
```

and:

```bash
journalctl -u cron -b --no-pager -n 10
```

The journal showed:

```text
cron.service: Deactivated successfully.
Stopped cron.service
```

This was not a crash. We had intentionally stopped it.

We recovered it:

```bash
sudo systemctl start cron
```

Then verified:

```bash
systemctl is-active cron
```

Result:

```text
active
```

---

# 22. Useful Command Combinations

### Service health check

```bash
systemctl status cron --no-pager
```

### Service state

```bash
systemctl is-active cron
systemctl is-enabled cron
```

### Recent logs

```bash
journalctl -u cron -b --no-pager -n 20
```

### Follow logs

```bash
journalctl -u cron -f
```

### Search logs for errors

```bash
journalctl -u cron -b --no-pager | grep -i "error"
```

### Search logs for a specific keyword

```bash
journalctl -u cron -b --no-pager | grep -i "environment"
```

---

# 23. Quick Reference Table

| Command | Purpose |
|---|---|
| `pwd` | Show current directory |
| `ls` | List files |
| `cd` | Change directory |
| `mkdir` | Create directory |
| `touch` | Create file |
| `cat` | Read file |
| `nano` | Edit file |
| `cp` | Copy |
| `mv` | Move/rename |
| `rm` | Delete |
| `whoami` | Show current user |
| `id` | Show user/group information |
| `sudo` | Run command with elevated privileges |
| `chmod` | Change permissions |
| `ps` | View processes |
| `ps aux` | Detailed process list |
| `jobs` | View Bash jobs |
| `fg` | Bring job to foreground |
| `kill <PID>` | Send signal to process |
| `systemctl status` | Check service |
| `systemctl start` | Start service |
| `systemctl stop` | Stop service |
| `systemctl restart` | Restart service |
| `systemctl is-active` | Check current service state |
| `systemctl is-enabled` | Check automatic-start configuration |
| `journalctl` | View systemd journal |
| `journalctl -u` | Filter by service |
| `journalctl -b` | Current boot |
| `journalctl -n` | Last N entries |
| `journalctl -f` | Follow logs live |
| `grep` | Search text |
| `grep -i` | Case-insensitive search |
| `\|` | Pipe output to another command |

---

# 24. Day 2 Key Concepts

```text
PROCESS
  ↓
Running instance of a program
  ↓
PID / PPID
```

```text
BASH JOB CONTROL
  ↓
&       → background
Ctrl+Z  → suspend
fg      → foreground
Ctrl+C  → interrupt
kill    → send signal
```

```text
SYSTEMD
  ↓
SERVICE MANAGEMENT
  ↓
systemctl
```

```text
LOGGING
  ↓
systemd journal
  ↓
journalctl
```

```text
LOG FILTERING
  ↓
journalctl
  ↓
|
  ↓
grep
```

---

# 25. AWS / DevOps Connection

These Linux fundamentals will become building blocks for the project:

```text
Developer
    |
    v
GitHub
    |
    v
CI/CD
    |
    v
Docker Image
    |
    v
ECR
    |
    v
EKS
    |
    v
Spring Boot
    |
    +---------> RDS PostgreSQL
    |
    +---------> CloudWatch
    |
    +---------> Prometheus
    |
    +---------> Grafana
```

The Linux troubleshooting mindset remains:

```text
Application problem
       |
       v
Observe
       |
       v
Check state
       |
       v
Check process
       |
       v
Check logs
       |
       v
Filter logs
       |
       v
Diagnose
       |
       v
Fix
       |
       v
Verify
```

---

## Day 2 Golden Rule

> **Don't just run commands. Understand what question each command answers.**

For example:

```bash
systemctl status cron
```

asks:

> "What is the current state of this service?"

while:

```bash
journalctl -u cron
```

asks:

> "What has this service/systemd reported?"

And:

```bash
ps
```

asks:

> "What processes exist?"

That distinction will become increasingly important as we move into **networking → Docker → AWS → Kubernetes/EKS**.
