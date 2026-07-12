---
name: presearch
description: Comprehensive research on a topic using the Perplexity API (deep research), compiled into a self-contained HTML report saved in ~/claude-research. Use when the user runs /presearch <topic> or asks for Perplexity-powered research on a subject.
---

# presearch

Same output contract as `/cresearch` — one self-contained HTML report at `~/claude-research/<topic-slug>.html` plus a chat summary — but the research step uses the Perplexity API instead of plain web search.

If no topic was given, ask for it and stop.

## Step 0 — Check the shelf first

Before researching, `grep -ril` the topic keywords against `~/claude-research/`. If a report already exists, read its **Sources** list and research date, treat those URLs as known, and aim the research at what has changed since. Offer to update in place rather than writing a dated duplicate.

## Step 1 — Research via Perplexity

Load the Perplexity MCP tools with ToolSearch (`select:mcp__perplexity__deep_research,mcp__perplexity__search,mcp__perplexity__reason`).

- Primary: run `mcp__perplexity__deep_research` on the topic with a prompt asking for a comprehensive report covering: overview, key findings, data/statistics, relevant research and science papers (with titles, authors, years, links), recent developments — **and, explicitly, the counter-case: criticism, failed replications, limitations, regulatory rejections, and who disputes the consensus and on what grounds.** Ask for sources cited throughout. The counter-case is not optional; a report that only relays consensus is laundered marketing.
- If deep_research is unavailable or fails, fall back to several `mcp__perplexity__search` calls covering the same angles (overview, data, papers, recent news, counter-case), optionally `mcp__perplexity__reason` for synthesis.
- If no Perplexity tools are available at all, tell the user and offer to run `/cresearch` instead — don't silently substitute.

Supplement with WebFetch on the most important cited URLs when the Perplexity output is thin on detail you need (e.g. exact numbers from a primary source). **Prompt WebFetch as an extractor, not a summarizer** — ask for the specific fields you need (sample size, effect size, limitations, funding, exact figures, authors), not "summarize this page".

**Never invent citations.** Author, year, and venue go in the report only if actually seen in a source. Leave a field blank rather than guess.

## Step 2 — Compile the HTML report

Identical to `/cresearch`: `mkdir -p ~/claude-research`, write a single self-contained HTML file (inline CSS only, dark-mode media query, max-width ~50rem) named `<topic-slug>.html` (append `-YYYY-MM-DD` on name collision), with sections:

- Title + research date
- Table of contents
- **Overview**
- **Key findings** — tables for data; signal strength of evidence behind major claims
- **What's contested / what we don't know** — disagreements, weak or single-study claims, the strongest counter-argument, open questions
- **Research papers** — linked, with authors/year/venue/takeaway (blank any field not actually seen)
- **Recent developments** — dated, newest first
- **Sources** — numbered, cited inline as `[n]`

Note in the report footer that research was performed via Perplexity.

## Step 3 — Report back

Tell the user the file path and give a 3–5 sentence summary of the most important findings — including anything the *contested* section turned up.
