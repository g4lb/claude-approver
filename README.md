# claude-approver

```bash
brew tap g4lb/tap && brew install claude-approver
```

Two tiny macOS scripts that save you from clicking "yes" on every [Claude Code](https://claude.com/claude-code) prompt when you have multiple sessions open.

Works with **iTerm2** and **Terminal.app**.

## After installing — do this once

### Step 1 — Try it

```bash
claude-accept-all
```

macOS will pop up permission prompts the first time. Click **OK** on each. If you click Deny by accident, add permissions manually using Steps 2 & 3.

### Step 2 — Grant Accessibility

Lets the script press keys in your terminal.

1. Open **System Settings → Privacy & Security → Accessibility**
2. Toggle **ON** whichever app you run the script from (Terminal, iTerm2, and/or `osascript`).

**Don't see Terminal in the list?** Add it manually:
1. Click the **`+`** button at the bottom of the list.
2. Press **`⌘ + Shift + G`** to open "Go to Folder".
3. Paste `/System/Applications/Utilities/` → Enter.
4. Select **Terminal.app** → click **Open**.
5. Toggle it **ON**.

> iTerm2 lives in `/Applications/iTerm.app` — same steps, different folder.

### Step 3 — Grant Automation

Lets your terminal control other apps.

1. Open **System Settings → Privacy & Security → Automation**
2. Find **Terminal** and/or **iTerm**, expand it, and toggle **ON**:
   - `System Events`
   - `Terminal` (if you use Terminal.app)
   - `iTerm` (if you use iTerm2)

### Step 4 — You're done

Now the commands below will actually work.

## Commands

```bash
# flip every open Claude session into auto-accept-edits mode
claude-accept-all

# or: fully bypass permissions (asks once before relaunching)
claude-relaunch-bypass

# dry-run — show what would happen without doing anything
claude-relaunch-bypass --dry-run

# custom match pattern (default is "claude")
claude-accept-all myproject
```

| Command | What it does |
|---|---|
| `claude-accept-all` | Sends `Shift+Tab` to every open Claude session → **auto-accept-edits** mode. |
| `claude-relaunch-bypass` | Restarts every open Claude session with `--dangerously-skip-permissions` → nothing prompts at all. |

## Alternative: clone instead of brew

```bash
git clone https://github.com/g4lb/claude-approver.git
cd claude-approver
chmod +x *.sh
./claude-accept-all.sh
```

## Heads-up

- `--dangerously-skip-permissions` means Claude runs **every** tool without asking — including destructive ones. Use with intent.
- Relaunching kills in-flight tool calls. Side effects already applied are **not** rolled back.
- macOS only. Tested with iTerm2 and Terminal.app.

## License

MIT
