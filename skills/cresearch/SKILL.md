---
name: cresearch
description: Research a topic on the internet (general info, data, news, research/science papers) and compile the findings into a self-contained HTML report saved in ~/claude-research. Use when the user runs /cresearch <topic> or asks for a compiled web-research report on a subject.
---

# cresearch

Input: the topic, given as arguments after the command. Output: one self-contained HTML report at `~/claude-research/<topic-slug>.html` plus a short summary in chat.

If no topic was given, ask for it and stop.

## Step 1 — Research

Use WebSearch (and WebFetch for the most valuable hits) to cover the topic from multiple angles. Run several distinct searches, not one:

- **Overview**: what the subject is, key concepts, current state of the field.
- **Data & statistics**: numbers, trends, benchmarks, market/measurement data.
- **Research papers**: search with terms like `<topic> arxiv`, `<topic> paper`, `site:arxiv.org`, `site:pubmed.ncbi.nlm.nih.gov`, `<topic> study`. Collect title, authors, year, venue, one-line finding, and link for each relevant paper.
- **Recent developments**: news and announcements from the last ~12 months.

Fetch full pages with WebFetch only for sources that clearly add depth (seminal papers, primary data sources, authoritative overviews). Prefer primary sources over blog rehashes. Keep track of every source URL used.

## Step 2 — Compile the HTML report

Create `~/claude-research/` if needed (`mkdir -p ~/claude-research`). Write a single HTML file — no external CSS/JS/fonts/images, everything inline — named after a short kebab-case slug of the topic (e.g. `solid-state-batteries.html`). If a file with that name already exists, append the date (`-YYYY-MM-DD`).

Structure:

- `<title>` and `<h1>`: the topic. Include the research date under the heading.
- Table of contents linking to sections.
- **Overview** — what the topic is and why it matters.
- **Key findings** — the substance: what you learned, organized into subsections that fit the topic. Use HTML tables for numeric data, `<blockquote>` for notable quotes.
- **Research papers** — a table or list: title (linked), authors, year, venue, one-line takeaway.
- **Recent developments** — dated items, newest first.
- **Sources** — numbered list of every URL used; cite them inline in the body as `[n]` links to this list.

Style: readable inline CSS (max-width ~50rem centered, system font stack, comfortable line-height, styled tables). Support dark mode via `@media (prefers-color-scheme: dark)`.

## Step 3 — Report back

Tell the user the file path and give a 3–5 sentence summary of the most important findings.
