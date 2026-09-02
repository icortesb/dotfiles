#!/usr/bin/env bash
# Re-run (with sudo) after every `ags-hyprpanel-git` update: pacman/yay
# overwrite /usr/share/hyprpanel/hyprpanel-app wholesale and silently drop
# this patch along with it.
#
# Bug: HyprPanel renders one button per freedesktop notification action
# with no check for an empty id/label, so Claude Code's default
# (focus-terminal-on-click) action shows up as a blank pill in the
# notification popup. Upstream fix was Jas-SinghFSU/HyprPanel#1181, closed
# unmerged when the project archived in favor of Wayle -- no release will
# ever ship it, so we patch the shipped JS bundle directly.
set -euo pipefail

APP="/usr/share/hyprpanel/hyprpanel-app"
MARKER="__mdg_filter_empty_actions_patch"

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo $0" >&2
  exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# The launcher is a bash script with the JS bundle base64-encoded on one
# line inside a heredoc. Find that line by length rather than a hardcoded
# line number, since it can shift between package rebuilds.
b64_lineno=$(awk '{ if (length($0) > 1000) { print NR; exit } }' "$APP")
if [[ -z "$b64_lineno" ]]; then
  echo "Could not find the embedded bundle line in $APP -- launcher format changed, patch needs updating." >&2
  exit 1
fi

sed -n "${b64_lineno}p" "$APP" | base64 --decode > "$tmpdir/bundle.js"

if grep -q "$MARKER" "$tmpdir/bundle.js"; then
  echo "Already patched."
  exit 0
fi

TARGET='notification.get_actions().map((action) => {'
REPLACEMENT='notification.get_actions().filter((action) => /* '"$MARKER"' */ Boolean(action.id && action.id.trim()) && Boolean(action.label && action.label.trim())).map((action) => {'

if ! grep -qF "$TARGET" "$tmpdir/bundle.js"; then
  echo "Target notification-actions code not found -- HyprPanel internals changed, patch needs updating." >&2
  exit 1
fi

python3 - "$tmpdir/bundle.js" "$TARGET" "$REPLACEMENT" <<'PY'
import sys
path, target, replacement = sys.argv[1:4]
with open(path, "r") as f:
    content = f.read()
count = content.count(target)
if count != 1:
    sys.exit(f"expected exactly 1 occurrence of target, found {count}")
content = content.replace(target, replacement, 1)
with open(path, "w") as f:
    f.write(content)
PY

base64 -w0 "$tmpdir/bundle.js" > "$tmpdir/bundle.b64"

# Rebuild the launcher: every original line except the payload line, which
# gets swapped for the patched, re-encoded bundle.
{
  sed -n "1,$((b64_lineno - 1))p" "$APP"
  cat "$tmpdir/bundle.b64"
  echo
  tail -n "+$((b64_lineno + 1))" "$APP"
} > "$tmpdir/hyprpanel-app.new"

install -m 755 -o root -g root "$tmpdir/hyprpanel-app.new" "$APP"

echo "Patched $APP -- notification actions with empty id/label are now filtered out."
echo "Restart HyprPanel to apply: pkill hyprpanel; ~/.config/hyprpanel/generate.sh & hyprpanel &"
