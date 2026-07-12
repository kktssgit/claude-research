---
name: presearch
description: Comprehensive research on a topic using the Perplexity API, compiled into a self-contained HTML report saved in ~/claude-research. Defaults to cheap parallel Sonar Pro searches; pass --deep for Sonar Deep Research. Use when the user runs /presearch <topic> or asks for Perplexity-powered research on a subject.
---

# presearch

Same output contract as `/cresearch` — one self-contained HTML report at `~/claude-research/<topic-slug>.html` plus a chat summary — but the research step uses the Perplexity API instead of plain web search.

If no topic was given, ask for it and stop.

## Step 0 — Check the shelf first

Before researching, `grep -ril` the topic keywords against `~/claude-research/`. If a report already exists, read its **Sources** list and research date, treat those URLs as known, and aim the research at what has changed since. Offer to update in place rather than writing a dated duplicate.

## Step 1 — Research via Perplexity

Load the Perplexity MCP tools with ToolSearch (`select:mcp__perplexity__search,mcp__perplexity__deep_research,mcp__perplexity__reason`).

### Default: parallel `search` calls, NOT `deep_research`

**`deep_research` costs roughly 4× a full set of `search` calls (~60¢ vs ~15¢) and most of what it bills for is prose you throw away** — Perplexity's job here is facts and citations; *you* write the report. Don't pay Sonar Deep Research to draft an essay you will discard.

So the default is **4–5 `mcp__perplexity__search` calls issued as one parallel batch**, one per angle:

- **Overview** — what it is, key concepts, current state.
- **Evidence & data** — the actual numbers: statistics, effect sizes, sample sizes, trends.
- **Research papers** — titles, authors, years, venues, PubMed/arXiv/DOI links.
- **Recent developments** — topic-scaled window (months for a fast field, years for a slow one).
- **Counter-case** *(mandatory — see below)*.

Ask each one for sources with URLs. Optionally follow with one `mcp__perplexity__reason` call if the angles genuinely conflict and need synthesis.

### `--deep` (opt-in only)

Use `mcp__perplexity__deep_research` **only when the user passes `--deep`**, or when the topic is broad or obscure enough that parallel searches come back thin. When you do use it, **constrain the output** — an uncapped deep_research answer runs 90k+ characters, overflows the tool result to a file, and costs a second time in context to read back:

> Return dense, citation-bearing bullet points — findings, numbers, paper titles, source URLs. Do not write flowing prose or an essay. Hard cap ~1500 words.

Keep the query **scoped**. Internal search volume and reasoning tokens — the expensive part — scale with how sprawling the ask is. Request the specific angles, not a treatise.

If no Perplexity tools are available at all, tell the user and offer to run `/cresearch` instead — don't silently substitute.

### The counter-case (mandatory)

Search explicitly for the strongest disagreement: criticism, limitations, replication status, re-analyses, who disputes the consensus and on what grounds. A report that only relays consensus is laundered marketing.

**But do not presuppose the counter-case's shape.** Distinguish **contradicted by evidence** from **contested** from **simply untested** — absence of evidence is not evidence of absence. If nobody has replicated a result, say nobody has *tried*; do not imply it failed replication. If a compound isn't approved, establish whether it was **rejected** or **never submitted** — these are different findings, and conflating them is an error, not a caution. Getting this wrong invents a criticism that doesn't exist, which is the same failure as inventing a citation.

### Fetching and citations

Supplement with WebFetch on the most important cited URLs when the Perplexity output is thin on detail you need (e.g. exact numbers from a primary source). **Prompt WebFetch as an extractor, not a summarizer** — ask for the specific fields you need (sample size, effect size, limitations, funding, exact figures, authors), not "summarize this page".

**Never invent citations.** Author, year, and venue go in the report only if actually seen in a source. Leave a field blank rather than guess.

## Step 2 — Compile the HTML report

Identical to `/cresearch`: `mkdir -p ~/claude-research`, write a single self-contained HTML file (inline CSS only, dark-mode media query, max-width ~50rem) named `<topic-slug>.html` (append `-YYYY-MM-DD` on name collision), with sections:

- Title + research date
- Table of contents
- **Overview**
- **Key findings** — tables for data; signal strength of evidence behind major claims
- **What's contested / what we don't know** — disagreements, weak or single-study claims, the strongest counter-argument, open questions. Keep untested separate from disproven; say which one each claim is.
- **Research papers** — linked, with authors/year/venue/takeaway (blank any field not actually seen)
- **Recent developments** — dated, newest first
- **Sources** — numbered, cited inline as `[n]`

Note in the report footer that research was performed via Perplexity.

## Step 3 — Report back

Tell the user the file path and give a 3–5 sentence summary of the most important findings — including anything the *contested* section turned up.
