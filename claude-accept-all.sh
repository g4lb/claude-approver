#!/usr/bin/env bash
# Sends Shift+Tab to every iTerm2 / Terminal.app session whose title or
# running process matches PATTERN (default: "claude"). Used to flip open
# Claude Code sessions into auto-accept-edits mode without focusing each one.
#
# Usage:  ./claude-accept-all.sh            # matches "claude"
#         ./claude-accept-all.sh myproj     # custom pattern
#
# Notes:
#   - iTerm2 path writes the ESC[Z sequence directly via native scripting.
#   - Terminal.app path uses System Events to press Shift+Tab; it will focus
#     each matching tab briefly and requires Accessibility permission for
#     whichever app launches the script (Terminal/iTerm/osascript).

set -euo pipefail

pattern="${1:-claude}"
matched_total=0

# iTerm branch: only run if iTerm is installed AND running. We isolate this in
# its own osascript call because `tell application "iTerm"` fails at parse time
# on machines without iTerm installed, which would break the whole script.
if [[ -d /Applications/iTerm.app ]] && pgrep -xq iTerm2; then
  iterm_matched="$(osascript - "$pattern" <<'APPLESCRIPT'
on run argv
  set pat to item 1 of argv
  set escSeq to (ASCII character 27) & "[Z"
  set matched to 0
  try
    tell application "iTerm"
      repeat with w in windows
        repeat with t in tabs of w
          repeat with s in sessions of t
            try
              set sName to name of s as string
              if sName contains pat then
                tell s to write text escSeq newline false
                set matched to matched + 1
              end if
            end try
          end repeat
        end repeat
      end repeat
    end tell
  end try
  return matched as string
end run
APPLESCRIPT
  )"
  matched_total=$(( matched_total + iterm_matched ))
fi

# Terminal.app branch: focus each matching tab, send Shift+Tab via System Events.
if pgrep -xq Terminal; then
  term_matched="$(osascript - "$pattern" <<'APPLESCRIPT'
on run argv
  set pat to item 1 of argv
  set matched to 0
  try
    tell application "Terminal"
      repeat with w in every window
        repeat with t in every tab of w
          set matchTab to false
          try
            set ct to custom title of t as string
            if ct contains pat then set matchTab to true
          end try
          if not matchTab then
            try
              set procs to processes of t
              repeat with p in procs
                if (p as string) contains pat then set matchTab to true
              end repeat
            end try
          end if
          if matchTab then
            set selected of t to true
            set frontmost of w to true
            activate
            delay 0.15
            tell application "System Events" to key code 48 using {shift down}
            set matched to matched + 1
          end if
        end repeat
      end repeat
    end tell
  end try
  return matched as string
end run
APPLESCRIPT
  )"
  matched_total=$(( matched_total + term_matched ))
fi

echo "matched sessions: $matched_total"
