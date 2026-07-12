---
name: lsresearch
description: List existing research reports in ~/claude-research related to a given topic. Use when the user runs /lsresearch [topic] or asks what research reports already exist on a subject.
---

# lsresearch

Input: an optional topic after the command. Output: a list of matching reports in `~/claude-research/`.

## Steps

1. If `~/claude-research/` doesn't exist or is empty, say so and stop.
2. Extract just the titles in one pass — never grep full file bodies:
   ```bash
   for f in ~/claude-research/*.html; do printf '%s\t%s\t%s\n' "$f" "$(date -r "$f" +%Y-%m-%d)" "$(grep -o -m1 '<title>[^<]*' "$f" | cut -c8-)"; done
   ```
3. Match against that list only: filename + title, case-insensitive, using the topic words plus obvious synonyms (e.g. "LLMs" also matches "language model", "GPT", "transformer"). Judge the matches yourself from the title list — no further file reads.
4. No topic given → list every report.
5. Show matches as file path, title, last-modified date, sorted newest first. If nothing matches, say so and mention how many reports exist in total.
