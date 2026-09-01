#!/usr/bin/env bash
# Click action for the Waybar Claude module: send a notification popup
# with progress bars, sourced from the same usage endpoint.
CREDS="$HOME/.claude/.credentials.json"
TOKEN="$(node -e 'try{const c=require(process.argv[1]);process.stdout.write((c.claudeAiOauth||c).accessToken||"")}catch(e){}' "$CREDS" 2>/dev/null)"

CACHE="$HOME/.cache/waybar-claude-usage.json"
resp="$(curl -s --max-time 8 \
  -H "Authorization: Bearer $TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" \
  "https://api.anthropic.com/api/oauth/usage")"
# Fall back to cache if the live call was rate-limited / failed.
echo "$resp" | grep -q '"five_hour"' || resp="$(cat "$CACHE" 2>/dev/null)"

body="$(printf '%s' "$resp" | node -e '
let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{
  let j; try{j=JSON.parse(s)}catch(e){process.stdout.write("Could not fetch usage — open Claude Code once to refresh the token.");return;}
  const bar=p=>{const n=Math.max(0,Math.min(10,Math.round(p/10)));return "█".repeat(n)+"░".repeat(10-n);};
  const until=iso=>{if(!iso)return "—";const ms=new Date(iso).getTime()-Date.now();if(ms<=0)return "now";const d=Math.floor(ms/8.64e7),h=Math.floor((ms%8.64e7)/3.6e6),m=Math.floor((ms%3.6e6)/6e4);return d>0?`${d}d ${h}h`:h>0?`${h}h ${m}m`:`${m}m`;};
  const row=(label,o)=>{const p=Math.round(o.utilization||0);return `${label.padEnd(8)}${bar(p)} ${p}%\n   resets in ${until(o.resets_at)}`;};
  const out=[row("Session",j.five_hour||{}), row("Week",j.seven_day||{})];
  (j.limits||[]).filter(l=>l.scope&&(l.percent||0)>0).forEach(l=>out.push(row(l.scope.model?.display_name||"Scoped",{utilization:l.percent,resets_at:l.resets_at})));
  process.stdout.write(out.join("\n"));
});')"

notify-send \
  -a "Claude" \
  -i "utilities-system-monitor" \
  -u low \
  -h "string:x-canonical-private-synchronous:claude-usage" \
  "󰚩  Claude Usage" "$body"
