<div align="center">

# 📚 claude-research

**Turn any question into a cited, self-contained research report — without leaving your terminal.**

Three Claude Code skills that search the web, read the papers, and hand you a single HTML file you can open, keep, and share.

`/cresearch` · `/presearch` · `/lsresearch`

</div>

---

## Contents

- [Install](#install) — clone, symlink, go
- [What it does](#what-it-does) — one line in, a cited report out
- [The three commands](#the-three-commands) — `/cresearch`, `/presearch`, `/lsresearch`
- [What a report looks like](#what-a-report-looks-like) — anatomy of the output
- [Requirements](#requirements) — what needs Perplexity, what doesn't
- [Reading your library](#reading-your-library) — browsing past reports
- [Design notes](#design-notes) — why the reports are built this way

## Install

```bash
git clone https://github.com/kktssgit/claude-research ~/vs/claude-research

for s in cresearch presearch lsresearch; do
  ln -s ~/vs/claude-research/skills/$s ~/.claude/skills/$s
done
```

Restart Claude Code — skills are picked up on session start. Type `/cresearch` and go.

Symlinks mean `git pull` updates your skills in place. Nothing is copied, nothing drifts.

## What it does

You type one line:

```
/cresearch nootropics 101, what are they, benefits, risks, known examples
```

Claude runs a spread of searches — overview, hard data, research papers, the last 12 months of news — reads the primary sources that actually matter, and writes `~/claude-research/nootropics-101.html`: a styled, dark-mode-aware report with a table of contents, data tables, a papers table with authors and takeaways, dated recent developments, and every claim footnoted to a numbered source list.

Then it summarises the findings in chat, so you know what you got before you open anything.

No accounts. No PDFs to wrangle. No half-remembered browser tabs. One file, one link, done.

## The three commands

| Command | What it does |
|:--|:--|
| **`/cresearch <topic>`** | Web research from many angles — overview, statistics, arXiv/PubMed papers, recent news, and a deliberate hunt for the counter-case — compiled into a self-contained HTML report. The workhorse. |
| **`/presearch <topic>`** | Same report, same output contract, but researched through the **Perplexity API** (deep research) instead of plain web search. Reach for it when you want Perplexity's synthesis and citation trail. |
| **`/lsresearch [topic]`** | Your library. Lists reports in `~/claude-research/` matching a topic (by filename *and* content), newest first. No topic → lists everything. |

## What a report looks like

Every report is **one HTML file** — inline CSS, no external fonts, scripts, or images. It works offline, it works in ten years, and you can email it to someone without breaking it.

Inside:

- **Title + research date**, so you always know how stale it is
- **Table of contents** linking to every section
- **Overview** — what the topic is and why it matters
- **Key findings** — the substance, in sections that fit the topic, with `<table>`s for numbers and blockquotes for the quotes worth pulling, and the strength of evidence flagged per claim
- **What's contested / what we don't know** — where the sources disagree, which claims rest on a single weak study, and the strongest argument against the consensus
- **Research papers** — title (linked), authors, year, venue, one-line takeaway
- **Recent developments** — dated, newest first
- **Sources** — numbered, complete, and cited inline as `[n]` throughout the body

Styled for reading: ~50rem measure, system font stack, generous line-height, and a `prefers-color-scheme: dark` block so it follows your OS theme.

Naming is a kebab-case slug of the topic (`solid-state-batteries.html`). Research a topic you've already covered and it finds the old report, reuses its sources instead of re-fetching them, and offers to bring it up to date rather than clobbering your earlier work.

## Requirements

- **Claude Code** with web search enabled — that's all `/cresearch` and `/lsresearch` need.
- **`/presearch` additionally needs a Perplexity MCP server** exposing `mcp__perplexity__deep_research` / `search` / `reason`. Without it, `/presearch` tells you and offers `/cresearch` instead — it never silently substitutes a different research method behind your back.

## Reading your library

Reports pile up in `~/claude-research/`. Two good ways to browse them:

```bash
# Ask Claude
/lsresearch batteries

# Or serve the whole shelf in a browser
python3 -m http.server 1234 --directory ~/claude-research
# → http://localhost:1234
```

The directory index gives you a plain, dependency-free reading list of everything you've researched.

## Design notes

A few deliberate choices, in case you're wondering:

- **It goes looking for the counter-case.** Every run includes a mandatory sweep for criticism, failed replications, limitations and regulatory rejections. A tool that only searches "what is X" and "benefits of X" will launder marketing into an authoritative-looking HTML file. This is the difference between a research report and a brochure.
- **Blank beats invented.** Author, year and venue appear only if actually seen in a source. A research tool that fabricates plausible citations is worse than no tool at all.
- **Self-contained by rule.** No CDN, no webfont, no build step. A report that needs the network to render is a report that dies.
- **Primary sources over blog rehashes.** Full pages are fetched only for sources that genuinely add depth — seminal papers, primary data — and WebFetch is asked to *extract specific fields*, not to summarize. Cheaper and sharper.
- **Every claim carries a number.** Inline `[n]` citations back to a real URL. If it isn't cited, it isn't in the report.
- **It knows when to stop.** Searches run to saturation — once new queries only resurface sources already seen, the topic is covered. No padding the count.
- **The chat summary is part of the product.** You shouldn't have to open a file to learn what it says.

---

<div align="center">
<sub>Three markdown files and a good prompt. That's the whole trick.</sub>
</div>
