---
name: lsresearch
description: List existing research reports in ~/claude-research related to a given topic. Use when the user runs /lsresearch [topic] or asks what research reports already exist on a subject.
---

# lsresearch

Input: an optional topic after the command. Output: a list of matching reports in `~/claude-research/`.

## Steps

1. If `~/claude-research/` doesn't exist or is empty, say so and stop.
2. Derive match keywords from the topic: the topic words themselves plus obvious synonyms/related terms (e.g. topic "LLMs" also matches "language model", "GPT", "transformer"). Case-insensitive.
3. Find matches by checking both **filenames** and **file content** — the `<title>` and `<h1>` of each HTML file, e.g.:
   ```bash
   grep -ril -e "keyword1" -e "keyword2" ~/claude-research/
   ```
   plus a filename match on the same keywords. Union the results.
4. No topic given → list every report.
5. For each match, show: file path, report title (from `<title>`), last-modified date, its `<h2>` section headings, and how many sources it cites — enough to judge a report without opening it. One extra pass per file, e.g.:
   ```bash
   grep -o '<h2[^>]*>[^<]*' file.html   # section headings
   grep -c '<li id="s' file.html        # source count
   ```
   Sort newest first. If nothing matches, say so and mention how many reports exist in total.
