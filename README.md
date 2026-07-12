<div align="center">

# 📚 claude-research

**Turn any question into a cited, self-contained research report — without leaving your terminal.**

Two Claude Code skills that search the web, read the papers, verify the citations, and hand you a single HTML file you can open, keep, and share.

`/cresearch` · `/lsresearch`

</div>

---

## Contents

- [Install](#install) — clone, symlink, go
- [What it does](#what-it-does) — one line in, a cited report out
- [The two commands](#the-two-commands) — `/cresearch`, `/lsresearch`
- [What a report looks like](#what-a-report-looks-like) — anatomy of the output
- [Requirements](#requirements) — genuinely just Claude Code
- [Reading your library](#reading-your-library) — browsing past reports
- [Design notes](#design-notes) — why the reports are built this way
- [Why there's no `/presearch`](#why-theres-no-presearch) — we tried it; it invented citations

## Install

```bash
git clone https://github.com/kktssgit/claude-research ~/vs/claude-research

for s in cresearch lsresearch; do
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

Claude runs a spread of searches — overview, hard data, research papers, recent news, and a deliberate hunt for the counter-case — reads the primary sources that actually matter, **checks that every DOI and PubMed ID is real**, and writes `~/claude-research/nootropics-101.html`: a styled, dark-mode-aware report with a table of contents, data tables, a papers table with authors and takeaways, dated recent developments, and every claim footnoted to a numbered source list.

Then it summarises the findings in chat, so you know what you got before you open anything.

No accounts. No API keys. No PDFs to wrangle. No half-remembered browser tabs. One file, one link, done.

## The two commands

| Command | What it does |
|:--|:--|
| **`/cresearch <topic>`** | The default. Web research from many angles — overview, statistics, arXiv/PubMed papers, recent news, and a mandatory sweep for the counter-case — compiled into a self-contained HTML report with verified citations. |
| **`/lsresearch [topic]`** | Your library. Lists reports in `~/claude-research/` matching a topic, newest first. No topic → lists everything. Reads titles only, so it stays cheap as the shelf grows. |

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

**Claude Code with web search enabled.** That's the whole list.

No API keys, no MCP servers, no paid services. This used to require a Perplexity subscription for one of the commands; [it doesn't anymore](#why-theres-no-presearch), and the reports got *more* accurate when that dependency went away.

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

- **Every identifier is verified.** Any DOI, PMID or PMCID that wasn't seen on a real page gets checked against Crossref before it can appear in a report. A DOI that resolves to nothing is a fabricated citation, and it gets dropped. This is the single most important rule here, and it exists because we watched a research tool invent them.
- **Blank beats invented.** Author, year and venue appear only if actually seen in a source. A field that can't be verified is left empty, not filled with something plausible.
- **It goes looking for the counter-case.** Every run includes a mandatory sweep for criticism, limitations, replication status and regulatory action. A tool that only searches "what is X" and "benefits of X" will launder marketing into an authoritative-looking HTML file. That's the difference between a research report and a brochure.
- **Untested ≠ disproven ≠ contested.** These get kept apart. If nobody has replicated a result, the report says nobody has *tried* — it doesn't imply the replication failed. If something isn't approved, it establishes whether it was *rejected* or *never submitted*. Inventing a criticism that doesn't exist is the same failure as inventing a citation.
- **Self-contained by rule.** No CDN, no webfont, no build step. A report that needs the network to render is a report that dies.
- **Primary sources over blog rehashes.** Full pages are fetched only for sources that genuinely add depth, and WebFetch is asked to *extract specific fields* — sample size, effect size, funding — not to summarize. Cheaper and sharper.
- **It knows when to stop.** Searches run to saturation — once new queries only resurface sources already seen, the topic is covered. No padding the count.
- **The chat summary is part of the product.** You shouldn't have to open a file to learn what it says.

## Why there's no `/presearch`

There used to be. It did the same job through the **Perplexity API** instead of plain web search, on the theory that a dedicated research API would find better sources than a search engine.

We tested that properly: identical prompt, same topic (NMN / NAD+ supplements), two isolated agents, neither aware of the other or of the comparison. The free path won on every axis that mattered.

|  | `/cresearch` (free) | `/presearch` (paid) |
|:--|:--|:--|
| API cost | **$0** | $0.034 |
| Wall-clock | 5 min 51 s | 5 min 50 s |
| Sources cited | **23** | 15 |
| Page fetches needed | **7** | 12 |
| **Fabricated citations** | **none** | **fake PMCIDs, fake DOIs, wrong author** |

Perplexity returned a confidently formatted paper list containing **PMCIDs and DOIs that do not exist** (`PMC9876543`; `doi:10.1002/age.2021.0001`, for which Crossref returns nothing), and attributed a real *Nature Metabolism* trial to the wrong first author. These were caught only by checking every identifier against Crossref and the primary pages — both free, and both things `/cresearch` already does. The paid tool created the problem; the free tools cleaned it up, which is why it needed *more* fetches, not fewer.

The deeper reason is architectural, and it isn't going to change: **WebSearch returns search results, not generated prose, so it structurally cannot invent a DOI.** A generative research API can — and on the one job it should have won, finding the papers, it hallucinated them.

So `/presearch` is retired, and the lesson it taught is now a hard rule in `/cresearch`. It's recoverable from git history if you disagree.

---

<div align="center">
<sub>Two markdown files and a good prompt. That's the whole trick.</sub>
</div>
