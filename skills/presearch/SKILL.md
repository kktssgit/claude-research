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

### THE COST RULE: cap the output on every single call

**The bill is driven by output verbosity, not by which model you pick.** This was measured, not assumed:

| Call | Output | Approx. cost |
|---|---|---|
| `deep_research`, uncapped | 91,512 chars | ~60¢ |
| `search` (Sonar Pro), uncapped | **99,072 chars** | **~37¢** |
| `search` (Sonar Pro), **hard word cap** | **~1,600 chars** | **~1.6¢** |

Left alone, *every* Perplexity model writes a ~90–100k-character essay: preamble, "practical implications", "alternatives", safety boilerplate, step-by-step reasoning. All of it is padding you throw away — **you** write the report; Perplexity's job is facts and citations. Worse, Sonar Pro bills output at **$15/M** vs Deep Research's **$8/M**, so an uncapped "cheap" search can cost *more* than deep research. And a 90k-char result overflows the tool limit, spills to a file, and bills you a second time in context to read back.

**So: every query — `search`, `reason`, or `deep_research` — carries an explicit brevity constraint.** This is the whole ballgame; a ~60× reduction. Put it in the query text:

> Answer in UNDER 200 WORDS. Terse bullet points. NO preamble, NO "practical implications", NO "alternatives", NO step-by-step reasoning, NO safety boilerplate. Facts and citations only.

### ONE QUESTION PER CALL — the cap alone is not enough

**Measured on a live run: the word cap held on 3 of 5 calls and was ignored on 2. The two that blew up (73.6 KB and 66.3 KB) were the two written as multi-part questions** — one packed five sub-questions ("does it harm kidneys… is the hair claim replicated… do re-analyses dispute… is the effect smaller in trained people… industry funding?"). The model reads a compound question as licence to write a review article, and the word cap loses.

So the cap is necessary but **not sufficient**. The binding rule:

- **One question per call.** If the query contains "and" joining two distinct questions, or a semicolon-separated list of sub-topics, **split it into separate parallel calls** — they cost the same and they actually obey the cap.
- A request for a *list of one kind of thing* ("give the loading dose, maintenance dose, effect size, non-responder rate") is fine — that's one question with several fields.
- A request spanning *several kinds of question* ("cover safety, replication, effect size, and funding") is not. Split it.

### Default: 4–5 capped `search` calls in one parallel batch

One per angle:

- **Overview** — what it is, key concepts, current state.
- **Evidence & data** — the numbers: effect sizes, sample sizes, doses, trends.
- **Research papers** — titles, years, venues, PubMed/arXiv/DOI **links** (links, not prose).
- **Recent developments** — topic-scaled window (months for a fast field, years for a slow one).
- **Counter-case** *(mandatory — see below)*.

### Exact numbers come from WebFetch, not Perplexity

A capped search returns the **landscape and the citations**; it will *not* reliably give you a trial's dose, p-value, authors or PMID. Don't fix that by uncapping the search — **WebFetch the primary source and extract the fields**. It is free, and it is *more accurate*: on a live run, WebFetch on the PubMed page corrected a publication year that had been guessed from the model's output.

### `--deep` (opt-in only)

Use `deep_research` **only when the user passes `--deep`**, or when capped searches come back genuinely thin. Cap its output too (~1500 words, dense cited bullets). Its extra cost buys internal search breadth, not better prose.

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
