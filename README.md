# claude-approver

Two tiny macOS scripts that save you from clicking "yes" on every [Claude Code](https://claude.com/claude-code) prompt when you have multiple sessions open.

Works with **iTerm2** and **Terminal.app**.

## What they do

| Script | What it does |
|---|---|
| `claude-accept-all.sh` | Flips every open Claude session into **auto-accept-edits** mode (sends `Shift+Tab` to all of them at once). |
| `claude-relaunch-bypass.sh` | Restarts every open Claude session with `--dangerously-skip-permissions`, so nothing prompts at all. |

## Install

### Homebrew (easiest)

```bash
brew tap g4lb/tap
brew install claude-approver
```

You'll get `claude-accept-all` and `claude-relaunch-bypass` on your `$PATH`.

### Or clone directly

```bash
git clone https://github.com/g4lb/claude-approver.git
cd claude-approver
chmod +x *.sh
```

## Use

```bash
# flip everything to auto-accept
claude-accept-all

# or: fully bypass permissions (asks once before relaunching)
claude-relaunch-bypass

# see what would happen first
claude-relaunch-bypass --dry-run
```

> If you cloned the repo instead of installing via brew, run `./claude-accept-all.sh` and `./claude-relaunch-bypass.sh`.

## Grant macOS permissions (one-time setup)

The scripts use AppleScript to talk to your terminal. macOS will block them until you enable two things. Do this **once**:

### 1. Accessibility

Needed so the script can press keys in your terminal.

1. Open **System Settings → Privacy & Security → Accessibility**
2. Toggle **ON** whichever app you run the script from (Terminal, iTerm2, and/or `osascript`).

**Don't see Terminal in the list?** Add it manually:

1. Click the **`+`** button at the bottom of the list.
2. Press **`⌘ + Shift + G`** to open "Go to Folder".
3. Paste `/System/Applications/Utilities/` and hit Enter.
4. Select **Terminal.app** → click **Open**.
5. Make sure the toggle next to Terminal is **ON**.

> iTerm2 lives in `/Applications/iTerm.app` — same steps, just point to that folder.

### 2. Automation

Needed so your terminal can control other apps.

1. Open **System Settings → Privacy & Security → Automation**
2. Find **Terminal** and/or **iTerm**, expand it, and toggle **ON**:
   - `System Events`
   - `Terminal` (if you use Terminal.app)
   - `iTerm` (if you use iTerm2)

> First run tip: just run `./claude-accept-all.sh`. macOS will pop up the permission prompts automatically — click **OK** on each. If you click Deny by accident, add it manually using the steps above.

## Heads-up

- `--dangerously-skip-permissions` means Claude runs **every** tool without asking — including destructive ones. Use with intent.
- Relaunching kills in-flight tool calls. Side effects already applied are **not** rolled back.
- macOS only. Tested with iTerm2 and Terminal.app.

## License

MIT
