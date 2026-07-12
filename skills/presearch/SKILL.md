---
name: presearch
description: Comprehensive research on a topic using the Perplexity API, compiled into a self-contained HTML report saved in ~/claude-research. Uses the capped pplx.sh script (~3c/report), NOT the uncapped MCP tools. Use when the user runs /presearch <topic> or asks for Perplexity-powered research on a subject.
---

# presearch

Same output contract as `/cresearch` — one self-contained HTML report at `~/claude-research/<topic-slug>.html` plus a chat summary — but the research step uses the Perplexity API instead of plain web search.

If no topic was given, ask for it and stop.

## Step 0 — Check the shelf first

Before researching, `grep -ril` the topic keywords against `~/claude-research/`. If a report already exists, read its **Sources** list and research date, treat those URLs as known, and aim the research at what has changed since. Offer to update in place rather than writing a dated duplicate.

## Step 1 — Research via Perplexity

### DO NOT USE THE PERPLEXITY MCP TOOLS. Use `pplx.sh`.

**The MCP tool schema exposes only `query` and `force_model`. There is no `max_tokens`.** It therefore *cannot* cap output, and asking nicely in the prompt does not work — measured across live runs, a word cap in the prompt was ignored on roughly 40% of calls, which returned 66–99 KB essays at ~20–40¢ each. Three MCP-based reports cost **60¢, ~$1.75, and ~$1.00**.

Use the script in this skill's directory instead. It calls the API directly, where **`max_tokens` is enforced server-side and cannot be ignored**, and it defaults to `sonar` ($1/M output) rather than `sonar-pro` ($15/M):

```bash
skills/presearch/pplx.sh "one narrow question" [max_tokens=500] [model=sonar]
```

It prints the answer, numbered source URLs, and — on stderr — **the real cost from the API's own `usage.cost` field**. Measured: **$0.0054 per call.** A five-angle report costs **under 3 cents**, versus ~$1.00 through the MCP. Roughly a **200× reduction**, and it is guaranteed rather than hoped for.

Run the angle queries **as one parallel batch** of `pplx.sh` calls. Sum the reported costs and state the total when you report back — never estimate the cost again, the script tells you.

### ONE QUESTION PER CALL

Still true, and still the difference between a good answer and a padded one:

- **One question per call.** If a query joins two distinct questions with "and", or lists several sub-topics, **split it into separate parallel calls** — the request fee dominates a capped call, so splitting costs almost nothing and the answers are sharper.
- A list of *fields of one kind* ("loading dose, maintenance dose, effect size, non-responder rate") is one question. Fine.
- A span of *different kinds of question* ("safety, replication, effect size, and funding") is not. Split it.

If a capped answer gets truncated mid-sentence, that's the cap biting — re-run that one call with a larger `max_tokens` (800–1200). That is a deliberate, priced decision, which is the whole point.

### `--deep` (opt-in only)

`deep_research` has **no capped equivalent** — it is only reachable through the uncapped MCP, and it cost 60¢ for output that was thrown away. Use it only if the user explicitly passes `--deep`, and say what it will cost before you do.

### Default: 4–5 capped `pplx.sh` calls in one parallel batch

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
