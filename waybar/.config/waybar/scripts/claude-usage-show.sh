#!/usr/bin/env bash
# Human-readable Claude limits readout (for the Waybar click action).
CREDS="$HOME/.claude/.credentials.json"
TOKEN="$(node -e 'try{const c=require(process.argv[1]);process.stdout.write((c.claudeAiOauth||c).accessToken||"")}catch(e){}' "$CREDS" 2>/dev/null)"
curl -s --max-time 8 \
  -H "Authorization: Bearer $TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" \
  "https://api.anthropic.com/api/oauth/usage" | node -e '
let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{
  let j; try{j=JSON.parse(s)}catch(e){console.log("Could not fetch usage (token may be expired — open Claude Code once).");return;}
  const at=iso=>iso?new Date(iso).toLocaleString("en-GB",{timeZone:"America/Argentina/Buenos_Aires",weekday:"short",day:"2-digit",month:"short",hour:"2-digit",minute:"2-digit"}):"—";
  const bar=p=>{const n=Math.round(p/5);return "["+"#".repeat(n)+"-".repeat(20-n)+"]";};
  const s5=j.five_hour||{}, w=j.seven_day||{};
  console.log("\n  CLAUDE USAGE\n");
  console.log(`  Session (5h)   ${bar(s5.utilization||0)} ${Math.round(s5.utilization||0)}%   resets ${at(s5.resets_at)}`);
  console.log(`  Week (all)     ${bar(w.utilization||0)} ${Math.round(w.utilization||0)}%   resets ${at(w.resets_at)}`);
  (j.limits||[]).filter(l=>l.scope&&(l.percent||0)>0).forEach(l=>
    console.log(`  ${(l.scope.model?.display_name||"scoped").padEnd(13)}${bar(l.percent)} ${Math.round(l.percent)}%   resets ${at(l.resets_at)}`));
  console.log("");
});'
