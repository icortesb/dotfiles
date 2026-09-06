#!/usr/bin/env bash
# Feeds the HyprPanel `custom/claude` module.
# Reuses hyprpanel/.config/hyprpanel/scripts/claude-usage.sh (JSON + Pango output) and
# re-emits { "label": <short>, "tooltip": <multiline> } as plain text, which the
# module's "{label}" / "{tooltip}" templates then render.
set -o pipefail

raw="$("$HOME/.config/hyprpanel/scripts/claude-usage.sh" 2>/dev/null)"
[ -n "$raw" ] || { printf '{"label":"-","tooltip":"No Claude usage data yet"}'; exit 0; }

printf '%s' "$raw" | node -e '
let s = "";
process.stdin.on("data", d => (s += d)).on("end", () => {
  const strip = x => (x || "")
    .replace(/<[^>]*>/g, "")        // pango spans
    .replace(/\u{F06A9}/gu, "")     // brand glyph (module draws its own icon)
    .replace(/[ \t]+/g, " ");
  let label = "-", tip = "";
  try {
    const o = JSON.parse(s);
    label = strip(o.text).replace(/\s+/g, " ").trim();
    tip = strip(o.tooltip).replace(/^\n+/, "").trimEnd();
  } catch (e) {}
  process.stdout.write(JSON.stringify({ label: label || "-", tooltip: tip || label }));
});
'
