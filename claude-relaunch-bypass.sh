#!/usr/bin/env bash
# Quits each running Claude Code CLI session and relaunches it in the same
# terminal with --dangerously-skip-permissions (and --continue by default),
# so all permission prompts are suppressed.
#
# Usage:
#   ./claude-relaunch-bypass.sh              # interactive; relaunches with --continue
#   ./claude-relaunch-bypass.sh --dry-run    # just list what would be relaunched
#   ./claude-relaunch-bypass.sh --no-continue  # start fresh sessions instead
#
# Env:
#   CLAUDE_CMD_PATTERN  regex passed to grep -E when matching process
#                       command lines (default: "claude")
#
# Caveats:
#   - Kills in-flight tool calls; side effects are NOT rolled back.
#   - --continue resumes the most-recent session in a cwd. If you had two
#     Claude sessions in the same cwd, both relaunches race for the same
#     history; one wins. Use --no-continue in that case.
#   - Supports iTerm2 and Terminal.app only.

set -euo pipefail

dry_run=0
continue_flag="--continue"

while (( $# > 0 )); do
  case "$1" in
    -n|--dry-run)    dry_run=1 ;;
    --no-continue)   continue_flag="" ;;
    -h|--help)
      sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

pattern="${CLAUDE_CMD_PATTERN:-claude}"
self="$(basename "$0")"

# Collect: pid|/dev/ttyNN|cwd for each matching, tty-attached process.
entries=()
while IFS='|' read -r pid tty cmd; do
  case "$cmd" in
    *"$self"*|*"claude-accept-all"*|*grep*) continue ;;
  esac
  [[ -z "$tty" || "$tty" == "?"* ]] && continue
  cwd="$(lsof -p "$pid" 2>/dev/null | awk '$4=="cwd"{for(i=9;i<=NF;i++) printf "%s%s",$i,(i<NF?" ":""); exit}' || true)"
  [[ -z "$cwd" ]] && continue
  entries+=("$pid|/dev/$tty|$cwd")
done < <(ps -axo pid=,tty=,command= | awk -v pat="$pattern" '$0 ~ pat { pid=$1; tty=$2; $1=""; $2=""; sub(/^  */,""); print pid "|" tty "|" $0 }')

if (( ${#entries[@]} == 0 )); then
  echo "No matching Claude sessions found (pattern: $pattern)."
  exit 0
fi

printf "Found %d candidate session(s):\n" "${#entries[@]}"
for e in "${entries[@]}"; do
  IFS='|' read -r p t c <<<"$e"
  printf "  pid=%s  tty=%s  cwd=%s\n" "$p" "$t" "$c"
done

if (( dry_run )); then
  echo "(dry run — nothing relaunched)"
  exit 0
fi

read -r -p "Relaunch all in bypass mode? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

for e in "${entries[@]}"; do
  IFS='|' read -r pid tty cwd <<<"$e"
  relaunch="cd $(printf %q "$cwd") && claude --dangerously-skip-permissions $continue_flag"
  set +e
  result="$(osascript - "$tty" "$relaunch" <<'APPLESCRIPT' 2>&1
on run argv
  set ttyPath to item 1 of argv
  set relaunchCmd to item 2 of argv

  -- Terminal.app: focus + System Events keystrokes
  try
    tell application "System Events"
      set termOn to (exists (processes where name is "Terminal"))
    end tell
    if termOn then
      tell application "Terminal"
        repeat with w in every window
          repeat with tb in every tab of w
            if (tty of tb as string) is ttyPath then
              set selected of tb to true
              set frontmost of w to true
              activate
              delay 0.4
              tell application "System Events"
                keystroke "c" using control down
                delay 0.4
                keystroke "c" using control down
                delay 1.5
                keystroke relaunchCmd
                key code 36
              end tell
              return "terminal:" & ttyPath
            end if
          end repeat
        end repeat
      end tell
    end if
  on error errMsg number errNum
    return "terminal-error:" & ttyPath & " err=" & errNum & " " & errMsg
  end try

  return "unmatched:" & ttyPath
end run
APPLESCRIPT
)"
  rc=$?
  set -e
  printf "  [%s] rc=%s result=%s\n" "$tty" "$rc" "$result"
done

echo "Done."
