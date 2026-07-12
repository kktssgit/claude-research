---
name: presearch
description: Comprehensive research on a topic using the Perplexity API (deep research), compiled into a self-contained HTML report saved in ~/claude-research. Use when the user runs /presearch <topic> or asks for Perplexity-powered research on a subject.
---

# presearch

Same output contract as `/cresearch` — one self-contained HTML report at `~/claude-research/<topic-slug>.html` plus a chat summary — but the research step uses the Perplexity API instead of plain web search.

If no topic was given, ask for it and stop.

## Step 1 — Research via Perplexity

Load the Perplexity MCP tools with ToolSearch (`select:mcp__perplexity__deep_research,mcp__perplexity__search,mcp__perplexity__reason`).

- Primary: run `mcp__perplexity__deep_research` on the topic with a prompt asking for a comprehensive report covering: overview, key findings, data/statistics, relevant research and science papers (with titles, authors, years, links), and recent developments — with sources cited.
- If deep_research is unavailable or fails, fall back to several `mcp__perplexity__search` calls covering the same angles (overview, data, papers, recent news), optionally `mcp__perplexity__reason` for synthesis.
- If no Perplexity tools are available at all, tell the user and offer to run `/cresearch` instead — don't silently substitute.

Supplement with WebFetch on the most important cited URLs when the Perplexity output is thin on detail you need (e.g. exact numbers from a primary source).

## Step 2 — Compile the HTML report

Identical to `/cresearch`: `mkdir -p ~/claude-research`, write a single self-contained HTML file (inline CSS only, dark-mode media query, max-width ~50rem) named `<topic-slug>.html` (append `-YYYY-MM-DD` on name collision), with sections: title + date, table of contents, Overview, Key findings (tables for data), Research papers (linked, with authors/year/takeaway), Recent developments, and a numbered Sources list cited inline as `[n]`. Note in the report footer that research was performed via Perplexity.

## Step 3 — Report back

Tell the user the file path and give a 3–5 sentence summary of the most important findings.
