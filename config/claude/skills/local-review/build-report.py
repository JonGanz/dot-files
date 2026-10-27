#!/usr/bin/env python3
"""Builds the local-review HTML report from a JSON file.

usage: build-report.py <review.json> <out.html>

review.json schema (see SKILL.md Step 7):
{
  "meta": {
    "id": "short-unique-id",            # keys the viewer's saved selections; change it per review
    "title": "Group Domain Review",     # <title>: a 2-4 word name, not a sentence
    "heading": "Group domain review",
    "branch": "feat/group-domain",      # optional, goes into the fix prompt
    "summaryHtml": "Branch <code>..</code> against ..., repos reviewed, how it was verified.",
    "warningHtml": "",                  # optional, e.g. "the branch moved since the review"
    "footerHtml": "Not reviewed: ..."
  },
  "commits": [ {"repo": "backend-api", "base": "e23007df", "head": "bfa06d15", "list": [["hash", "subject"], ...]} ],
  "findings": [ {
    "sev": "high|medium|low", "repo": "backend-api", "cross": "waiver-ui",   # cross optional
    "title": "...", "file": "path/in/repo.js", "start": 429,                  # start 0 = no line
    "code": ["line", ...] or null, "hl": [indexes into code],
    "why": "html", "origin": "html, optional", "fix": "html",
    "options": ["alternative approach", ...]                                  # optional, 2+ when the fix has alternatives
  } ]
}
"""
import json, os, sys

here = os.path.dirname(os.path.abspath(__file__))
src, out = sys.argv[1], sys.argv[2]
review = json.load(open(src))
meta = review["meta"]

for key in ("id", "title", "heading", "summaryHtml", "footerHtml"):
    if not meta.get(key):
        sys.exit(f"meta.{key} is required")
if not review.get("findings"):
    sys.exit("no findings: don't build a report, say everything is good in text")

for i, f in enumerate(review["findings"]):
    for key in ("sev", "repo", "title", "file", "why", "fix"):
        if key not in f:
            sys.exit(f"finding {i} ({f.get('title')}) is missing {key}")
    if f["sev"] not in ("high", "medium", "low"):
        sys.exit(f"finding {i}: sev must be high, medium or low")
    f.setdefault("start", 0)
    f.setdefault("code", None)
    f.setdefault("hl", [])
    f.setdefault("options", [])
review.setdefault("commits", [])

warn = meta.get("warningHtml") or ""
tpl = open(os.path.join(here, "report-template.html")).read()
data = json.dumps(review).replace("</", "<\\/")
html = (tpl.replace("/*REVIEW_JSON*/null/*END_REVIEW_JSON*/", data, 1)
        .replace("{{TITLE}}", meta["title"])
        .replace("{{HEADING}}", meta["heading"])
        .replace("{{SUMMARY_HTML}}", meta["summaryHtml"])
        .replace("{{WARNING_HTML}}", f'<p class="warn">{warn}</p>' if warn else "")
        .replace("{{FOOTER_HTML}}", meta["footerHtml"]))
open(out, "w").write(html)
print(out)
