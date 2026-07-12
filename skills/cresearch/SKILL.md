---
name: cresearch
description: Research a topic on the internet (general info, data, news, research/science papers) and compile the findings into a self-contained HTML report saved in ~/claude-research. Use when the user runs /cresearch <topic> or asks for a compiled web-research report on a subject.
---

# cresearch

Input: the topic, given as arguments after the command. Output: one self-contained HTML report at `~/claude-research/<topic-slug>.html` plus a short summary in chat.

If no topic was given, ask for it and stop.

## Step 0 — Check the shelf first

Before searching, look for an existing report on this topic:

```bash
grep -ril -e "keyword1" -e "keyword2" ~/claude-research/ 2>/dev/null
```

If one exists, read its **Sources** list and its research date. Don't re-fetch URLs it already used — treat them as known, and aim your searches at what has changed since that date. Offer to update the report in place rather than writing a dated duplicate. If nothing exists, proceed clean.

## Step 1 — Research

Cover the topic from multiple angles. **Budget: roughly 6–10 searches and 2–5 fetches.** Stop early on **saturation** — when new searches keep surfacing sources you've already seen, the topic is covered; stop, don't pad the count.

**Issue the core angles as one parallel batch**, read the whole landscape, *then* decide what deserves a fetch.

### Core angles (always)

- **Overview** — what the subject is, key concepts, current state of the field.
- **Evidence & data** — the numbers the topic actually has: statistics, benchmarks, trends, measurements.
- **Recent developments** — news and announcements, with a **topic-scaled window**: months for a fast-moving field, years for a slow one. Judge the field's clock — don't default to 12 months.
- **Counter-case** *(mandatory)* — search explicitly for the strongest disagreement: `<topic> criticism`, `<topic> failed replication`, `<topic> debunked`, `<topic> limitations`, `<topic> meta-analysis re-analysis`, regulatory rejections. Find who disputes the consensus and on what grounds. This is the angle that separates a research report from laundered marketing.

### Menu (pick 2–3 that fit; skip the rest)

Research papers (`<topic> arxiv`, `site:arxiv.org`, `site:pubmed.ncbi.nlm.nih.gov`, `<topic> study`) · market/industry data · practical how-to · key people & organizations · head-to-head comparisons · history. A market-size search on a topic with no market is pure waste — don't run angles that don't apply.

### Fetching

Fetch full pages with WebFetch only for sources that clearly add depth (seminal papers, primary data, authoritative overviews). Prefer primary sources over blog rehashes.

**Prompt WebFetch as an extractor, not a summarizer.** Ask for the specific fields the report needs — sample size, effect size, limitations, funding source, exact figures, publication date, authors — not "summarize this page". It returns only what you ask, so a targeted prompt is both cheaper and more usable.

**Never invent citations.** Author, year, and venue go in the report only if actually seen in a source. Leave a field blank rather than guess a plausible-looking value. Keep track of every source URL used.

## Step 2 — Compile the HTML report

Create `~/claude-research/` if needed (`mkdir -p ~/claude-research`). Write a single HTML file — no external CSS/JS/fonts/images, everything inline — named after a short kebab-case slug of the topic (e.g. `solid-state-batteries.html`). If a file with that name already exists, append the date (`-YYYY-MM-DD`).

Structure:

- `<title>` and `<h1>`: the topic. Include the research date under the heading.
- Table of contents linking to sections.
- **Overview** — what the topic is and why it matters.
- **Key findings** — the substance: what you learned, organized into subsections that fit the topic. Use HTML tables for numeric data, `<blockquote>` for notable quotes. Signal the strength of evidence behind major claims (a per-claim tier — strong / moderate / weak / contested — is worth its column).
- **What's contested / what we don't know** — where sources disagree, which claims rest on weak or single studies, the strongest counter-argument, and what remains genuinely open. This is a reorganization of what the counter-case angle surfaced — no extra research.
- **Research papers** — a table or list: title (linked), authors, year, venue, one-line takeaway. Blank any field you didn't actually see.
- **Recent developments** — dated items, newest first.
- **Sources** — numbered list of every URL used; cite them inline in the body as `[n]` links to this list.

Style: readable inline CSS (max-width ~50rem centered, system font stack, comfortable line-height, styled tables). Support dark mode via `@media (prefers-color-scheme: dark)`.

## Step 3 — Report back

Tell the user the file path and give a 3–5 sentence summary of the most important findings — including anything the *contested* section turned up.
