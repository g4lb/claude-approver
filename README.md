# claude-approver

Two macOS helper scripts for flipping multiple open [Claude Code](https://claude.com/claude-code) sessions into a "don't ask me" mode at once — without focusing each terminal tab manually.

Supports **iTerm2** and **Terminal.app**.

## The scripts

### `claude-accept-all.sh`
Sends `Shift+Tab` to every terminal session whose title or running process matches a pattern (default: `claude`). This flips Claude Code into **auto-accept-edits** mode.

```bash
./claude-accept-all.sh            # matches "claude"
./claude-accept-all.sh myproj     # custom pattern
```

- iTerm2 sessions receive the escape sequence directly (no focus stealing).
- Terminal.app sessions are briefly focused to send the keystroke.

### `claude-relaunch-bypass.sh`
Kills each running Claude Code CLI process and relaunches it in the same terminal with `--dangerously-skip-permissions` (and `--continue` by default), suppressing all permission prompts.

```bash
./claude-relaunch-bypass.sh              # interactive; relaunches with --continue
./claude-relaunch-bypass.sh --dry-run    # list what would be relaunched
./claude-relaunch-bypass.sh --no-continue  # start fresh sessions instead
```

Env:
- `CLAUDE_CMD_PATTERN` — regex passed to `grep -E` when matching process command lines (default: `claude`).

## Install

```bash
git clone https://github.com/g4lb/claude-approver.git
cd claude-approver
chmod +x claude-accept-all.sh claude-relaunch-bypass.sh
```

Optionally put them on your `PATH`:

```bash
ln -s "$PWD/claude-accept-all.sh" /usr/local/bin/claude-accept-all
ln -s "$PWD/claude-relaunch-bypass.sh" /usr/local/bin/claude-relaunch-bypass
```

## Permissions

macOS will ask for **Accessibility** and/or **Automation** permission the first time you run these (System Settings → Privacy & Security). Grant it to whichever app invokes the script — Terminal, iTerm2, or `osascript`.

## Caveats

- `--dangerously-skip-permissions` means Claude Code runs tools without asking. Destructive actions won't be gated. Use with intent.
- `claude-relaunch-bypass.sh` kills in-flight tool calls — side effects are **not** rolled back.
- `--continue` resumes the most-recent session in a cwd. If you had two Claude sessions in the same directory, both relaunches race for the same history; one wins. Use `--no-continue` in that case.
- Only tested on macOS with iTerm2 and Terminal.app.

## License

MIT
