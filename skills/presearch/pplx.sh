#!/usr/bin/env bash
# Capped Perplexity search. The MCP tool exposes no max_tokens, so it cannot
# cap output — uncapped calls have run 90k+ chars and ~40c each. This hits the
# API directly, where max_tokens is enforced server-side and cannot be ignored.
#
#   ./pplx.sh "your narrow question"            # ~$0.005
#   ./pplx.sh "your question" 800 sonar-pro     # more room, pricier model
#
# Prints the answer, then numbered source URLs, then the REAL cost (from the
# API's own usage.cost field) to stderr. Never guess the cost again.
#
# Key is read from ~/.mcp.json — never hardcode it here, this repo is public.
set -euo pipefail

q="${1:?usage: pplx.sh \"query\" [max_tokens] [model]}"
max_tokens="${2:-500}"
model="${3:-sonar}"

key=$(python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.mcp.json')))['mcpServers']['perplexity']['env']['PERPLEXITY_API_KEY'])")

body=$(python3 -c '
import json,sys
q,mt,model = sys.argv[1], int(sys.argv[2]), sys.argv[3]
sys.stdout.write(json.dumps({
    "model": model,
    "max_tokens": mt,
    "messages": [
        {"role":"system","content":"Terse bullet points only. No preamble, no caveats, no practical implications, no alternatives, no safety boilerplate. Facts and citations only."},
        {"role":"user","content":q},
    ],
}))' "$q" "$max_tokens" "$model")

curl -sS https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $key" \
  -H "Content-Type: application/json" \
  -d "$body" \
| python3 -c '
import sys, json
d = json.load(sys.stdin)
if "error" in d:
    sys.exit("perplexity error: " + d["error"].get("message", "unknown"))
print(d["choices"][0]["message"]["content"])
cites = d.get("citations") or []
if cites:
    print("\nSOURCES")
    for i, u in enumerate(cites, 1):
        print(f"  {i}: {u}")
u = d["usage"]
cost = (u.get("cost") or {}).get("total_cost")
tag = "$%.4f" % cost if cost is not None else "cost n/a"
model = d.get("model", "?")
out = u.get("completion_tokens", "?")
print("[%s | %s out tokens | %s]" % (model, out, tag), file=sys.stderr)
'
