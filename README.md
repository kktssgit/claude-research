# claude-research

Claude Code skills for researching topics and compiling HTML reports into `~/claude-research/`.

## Commands

| Command | What it does |
|---|---|
| `/cresearch <topic>` | Web research (searches, papers, data, news) compiled into a self-contained HTML report |
| `/presearch <topic>` | Same report, but researched via the Perplexity API (deep research) |
| `/lsresearch [topic]` | List existing reports in `~/claude-research/` matching the topic (or all of them) |

Reports are single self-contained HTML files (inline CSS, dark-mode aware) with an overview, key findings, research papers, recent developments, and cited sources.

## Install

Symlink the skills into your Claude Code skills directory:

```bash
git clone https://github.com/kktssgit/claude-research ~/vs/claude-research
ln -s ~/vs/claude-research/skills/cresearch ~/.claude/skills/cresearch
ln -s ~/vs/claude-research/skills/presearch ~/.claude/skills/presearch
ln -s ~/vs/claude-research/skills/lsresearch ~/.claude/skills/lsresearch
```

New skills are picked up on session start.

`/presearch` requires a Perplexity MCP server (tools `mcp__perplexity__deep_research` / `search` / `reason`) configured in Claude Code; it falls back to offering `/cresearch` when absent.
