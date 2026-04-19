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

osascript - "$pattern" <<'APPLESCRIPT'
on run argv
  set pat to item 1 of argv
  set escSeq to (ASCII character 27) & "[Z"
  set matched to 0

  -- iTerm2: native write, no focus stealing
  tell application "System Events"
    set itermOn to (exists (processes where name is "iTerm2"))
  end tell
  if itermOn then
    try
      tell application "iTerm"
        repeat with w in windows
          repeat with t in tabs of w
            repeat with s in sessions of t
              try
                set sName to name of s as string
                if sName contains pat then
                  tell s to write text escSeq newline NO
                  set matched to matched + 1
                end if
              end try
            end repeat
          end repeat
        end repeat
      end tell
    end try
  end if

  -- Terminal.app: focus each matching tab, send Shift+Tab via System Events
  tell application "System Events"
    set termOn to (exists (processes where name is "Terminal"))
  end tell
  if termOn then
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
  end if

  return "matched sessions: " & matched
end run
APPLESCRIPT
