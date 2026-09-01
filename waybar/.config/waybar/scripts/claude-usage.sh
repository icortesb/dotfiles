#!/usr/bin/env bash
# Waybar custom module: real Claude session/weekly limits.
# Source: the same endpoint Claude Code's `/usage` uses
#   GET https://api.anthropic.com/api/oauth/usage
# authenticated with the OAuth token Claude Code stores locally.
# We only READ the token (Claude Code refreshes it); on any failure we fall
# back to the last cached response so the bar never breaks.

CREDS="$HOME/.claude/.credentials.json"
CACHE="$HOME/.cache/waybar-claude-usage.json"

TOKEN="$(node -e 'try{const c=require(process.argv[1]);process.stdout.write((c.claudeAiOauth||c).accessToken||"")}catch(e){}' "$CREDS" 2>/dev/null)"

if [ -n "$TOKEN" ]; then
  resp="$(curl -s --max-time 8 \
    -H "Authorization: Bearer $TOKEN" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)"
  # Cache only genuinely valid payloads.
  if echo "$resp" | grep -q '"five_hour"'; then
    printf '%s' "$resp" > "$CACHE"
  fi
fi

# Always render from cache (fresh write above, or last good one).
[ -f "$CACHE" ] || { echo '{"text":"󰚩 —","tooltip":"No Claude usage data yet (run a Claude Code session)","class":"idle"}'; exit 0; }

node -e '
const fs = require("fs");
const cache = process.argv[1];
let j; try { j = JSON.parse(fs.readFileSync(cache,"utf8")); } catch(e){
  process.stdout.write(JSON.stringify({text:"󰚩 —",tooltip:"usage cache unreadable",class:"idle"})); process.exit(0);
}
const ageMs = Date.now() - fs.statSync(cache).mtimeMs;
const stale = ageMs > 1800000; // >30min since last successful fetch (429s are normal)

const s = j.five_hour || {};
const w = j.seven_day || {};
const sp = Math.round(s.utilization ?? 0);
const wp = Math.round(w.utilization ?? 0);

const until = iso => {
  if (!iso) return "—";
  const ms = new Date(iso).getTime() - Date.now();
  if (ms <= 0) return "now";
  const d = Math.floor(ms/8.64e7);
  const h = Math.floor((ms%8.64e7)/3.6e6), m = Math.floor((ms%3.6e6)/6e4);
  if (d>0) return `${d}d${h}h`;
  return h>0 ? `${h}h${String(m).padStart(2,"0")}m` : `${m}m`;
};
const at = iso => iso ? new Date(iso).toLocaleString("en-GB",{timeZone:"America/Argentina/Buenos_Aires",weekday:"short",hour:"2-digit",minute:"2-digit"}) : "—";

// Color by the tighter of the two limits (used for the CSS class fallback).
const worst = Math.max(sp, wp);
let cls = "low";
if (worst >= 85) cls = "high"; else if (worst >= 60) cls = "mid";
if (stale) cls = "idle";

// Tokyo Night palette — per-segment color by each level.
const C = { green:"#9ece6a", yellow:"#e0af68", red:"#f7768e", dim:"#565f89", brand:"#7aa2f7" };
const col = p => stale ? C.dim : p>=85 ? C.red : p>=60 ? C.yellow : C.green;
const span = (c,t) => `<span color="${c}">${t}</span>`;

// Colored progress bar for the tooltip (Pango markup).
const bar = p => {
  const n = Math.max(0, Math.min(20, Math.round(p/5)));
  return span(col(p), "█".repeat(n)) + span(C.dim, "░".repeat(20-n));
};
const row = (icon, label, p, reset) => [
  `${span(C.dim, icon)}  <b>${label}</b>`,
  `${bar(p)}  ${span(col(p), p+"%")}`,
  span(C.dim, `resets ${reset}`),
].join("\n");

// Scoped per-model weekly limits (e.g. Fable), if any are non-zero.
const scoped = (j.limits||[]).filter(l => l.group==="weekly" && l.scope && (l.percent||0) > 0)
  .map(l => "\n" + row("󰃭", l.scope.model?.display_name||"scoped", Math.round(l.percent), at(l.resets_at)));

// 󱑆 clock = session (5h) · 󰃭 calendar = week.
const text =
  span(stale?C.dim:C.brand, "󰚩") + " " +
  span(C.dim, "󱑆") + " " + span(col(sp), `${sp}%`) + " " + span(C.dim, until(s.resets_at)) +
  span(C.dim, "  ·  ") +
  span(C.dim, "󰃭") + " " + span(col(wp), `${wp}%`) + " " + span(C.dim, until(w.resets_at));
const tip = [
  `${span(C.brand, "󰚩")}  <b>Claude Usage</b>${stale ? span(C.dim, "   · stale") : ""}`,
  ``,
  row("󱑆", "Session (5h)", sp, `in ${until(s.resets_at)}  ·  ${at(s.resets_at)}`),
  ``,
  row("󰃭", "Week (all models)", wp, `in ${until(w.resets_at)}  ·  ${at(w.resets_at)}`),
  ...scoped,
].join("\n");

process.stdout.write(JSON.stringify({text, tooltip: tip, class: cls, percentage: sp}));
' "$CACHE"
