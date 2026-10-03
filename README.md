# varungupta.info

Source for the site at **www.varungupta.info**, served by GitHub Pages from the
`main` branch of this repo.

Two things build this site. Four pages come from jemdoc. The publications page
is generated from a data file. That split is the one thing to remember.

---

## Quick start

From this folder, in PowerShell:

```
python jemdoc -c site.conf index.jemdoc bio.jemdoc teaching.jemdoc talks.jemdoc
python build_pubs.py
```

`-c site.conf` is required. Without it the jemdoc pages lose the mobile
viewport tag and `css/site.css`, and they stop matching the publications page
on phones.

Then commit the changed `.html` in GitHub Desktop and push.

**Which command do I need?**

| I edited… | Run |
|---|---|
| `index.jemdoc`, `bio.jemdoc`, `teaching.jemdoc`, `talks.jemdoc` | the first |
| `publications.toml` | the second |
| `MENU` | **both** — see the gotcha below |

Running both every time is harmless and takes a second. When in doubt, do that.

Requires **Python 3.11 or newer** and nothing else. No `pip install`.
(`tomllib` has been in the standard library since 3.11.)

---

## What's in here

### You edit these

| File | What it is |
|---|---|
| `index.jemdoc` `bio.jemdoc` `teaching.jemdoc` `talks.jemdoc` | page sources, jemdoc markup |
| `publications.toml` | **every publication**, as structured data |
| `MENU` | the sidebar, shared by all pages |
| `site.conf` | jemdoc overrides: viewport tag + `css/site.css` |

### Generated — never edit by hand

`index.html`, `bio.html`, `teaching.html`, `talks.html`, `publications.html`.
Anything you type into these is lost on the next build.

### Tooling

| File | What it is |
|---|---|
| `jemdoc` | the jemdoc-cvx script (Python, no extension). **Locally patched — see below.** |
| `build_pubs.py` | generates `publications.html` from `publications.toml` |
| `css/jemdoc-cvx.css` | the theme, plus `css/fonts/` |
| `css/site.css` | shared shell styles — responsive layout for **all** pages |
| `css/pubs.css` | styles for the publications page only |
| `Makefile` | optional; `make docs` runs both builds |

### Committed vs. local-only

Only the rendered `.html`, `css/`, images and PDFs are committed. **Your sources
are deliberately not published** — the `.jemdoc` files contain commented-out old
addresses and unpublished notes.

Gitignored, living only in Dropbox: `*.jemdoc`, `MENU`, `site.conf`,
`publications.toml`, `build_pubs.py`, `*.log`, `jemdoc.vim`.

> **This means Dropbox is the only backup of your sources.** Git has the output
> but not the input. Dropbox version history is the safety net.

> **`css/site.css` and `css/pubs.css` must stay committed.** Neither is ignored.
> Without `site.css` every page breaks on mobile; without `pubs.css` the
> publications page renders as unstyled text.

---

## Adding a publication

Open `publications.toml`, add a block anywhere (order in the file doesn't
matter — the generator sorts), run `python build_pubs.py`.

```toml
[[pub]]
title   = "Some New Paper"
authors = ["A. Coauthor", "V. Gupta"]
type    = "conference"
venue   = "NeurIPS"
year    = 2027
[[pub.links]]
label = "arXiv"
url   = "https://arxiv.org/abs/..."
[[pub.links]]
label = "DOI"
url   = "https://doi.org/..."
```

**Fields**

- `title` — required.
- `authors` — required. **In true publication order.** The entry matching
  `V. Gupta` exactly is rendered bold; other Guptas are left alone.
- `type` — `journal` | `conference` | `working` | `chapter` | `thesis`.
  Controls which section it lands in and the badge colour.
- `venue` — what shows in the badge. Keep it short: `Operations Research`,
  `NeurIPS`, `AISTATS`.
- `year` — shows inside the badge. Working papers can omit it.
- `detail` — volume/issue, e.g. `"74(2):100-120"`. **Not displayed** right now
  (see `SHOW_VOLUME`), but worth recording — it's there for a future BibTeX or
  CV export.
- `status` — working papers only: `"Under submission"`, `"Work in progress"`.
- `award` — gets its own gold line under the entry.
- `[[pub.links]]` — repeat for each. Labels are normalised and reordered to
  `DOI · arXiv · SSRN · PDF · Tech report · Slides · Video`; unknown labels
  (e.g. `OpenReview`) are kept as written and sort last.

If the TOML is malformed the build **fails loudly** with a line number. It will
never produce a half-broken page.

---

## Page layout

Two rows per paper:

```
Title of the paper
[VENUE | YEAR]  A. Author, V. Gupta and B. Author   [DOI] [arXiv]
```

The badge leads row two so every badge starts at the same left position and
forms a column you can scan down. (Right-aligned badges were tried and rejected:
the gap from a short title grows with window width and you have to go looking.)
An award, when there is one, gets a third row.

Four switches at the top of `build_pubs.py`:

```python
WORKING_STYLE    = "compact"   # "compact" | "full" | "collapsed"
WORKING_POSITION = "top"       # "top" | "bottom"
GROUP_BY_YEAR    = False       # True = year headings instead of year-in-badge
SHOW_VOLUME      = False       # True = show "Vol. 73(3), pp. 1496-1534"
```

`collapsed` hides working papers behind a click-to-open toggle — useful if that
list grows past eight or so.

---

## Publishing

In GitHub Desktop: review the changed files, write a summary, **Commit to main**,
**Push origin**. Then load the site and hard-refresh (**Ctrl+Shift+R**) — the
browser caches aggressively.

Only `.html` files should normally appear in the Changes list. If you see
`publications.toml` or a `.jemdoc` file there, something is wrong with
`.gitignore`.

---

## Gotchas

**Editing `MENU` needs both builds.** The sidebar is baked into every page, and
`build_pubs.py` reads `MENU` independently of jemdoc. Rebuild only one side and
the publications page silently keeps the old sidebar.

**The `jemdoc` script is locally patched. Upgrading wipes the patches.** If you
ever download a newer jemdoc-cvx and unpack it over this folder, re-apply:

1. Line ~190, `[defaultcss]` — must read `href="css/jemdoc-cvx.css"`.
   Upstream points at the repo root; the theme lives in `css/` here so its
   `@font-face url("fonts/…")` rules resolve. *Symptom if lost: every page
   renders as unstyled text.*
2. Lines ~304, ~383, ~749 — the `target` attribute. Upstream emits
   `target="blank"`, and jemdoc's own smart-quote pass then mangles it into
   `target=&ldquo;blank&rdquo;`. Lines 304 and 383 use plain `' target="_blank"'`.
   Line 749 sits inside `replacelinks()`, which runs through `br()`, so it must
   escape both the quotes and the underscore: `' target=\"\_blank\"'`.
   Do **not** use a bare `_blank` there — jemdoc reads `_` as underline markup
   and emits `target=<u>blank>`. *Symptom if lost: links open in the same tab.*

**`publications.jemdoc` is dead.** If it's still sitting in this folder, delete
it. Nothing builds it; editing it does nothing.

**Equations.** None of your pages have any. If you add LaTeX to a jemdoc page,
run `npm install` once here to get the pinned KaTeX, otherwise math renders as
raw `\(...\)`. The publications page doesn't support equations at all.

---

## Troubleshooting

| Symptom | Cause |
|---|---|
| Site is plain text, no styling | a file in `css/` not committed, or the jemdoc patch above was lost |
| Pages tiny / zoomed out on a phone | built without `-c site.conf` |
| Page scrolls sideways on a phone | something long is `white-space: nowrap`; let it wrap in `css/site.css` or `css/pubs.css` |
| Publications page has an old sidebar | edited `MENU` but only ran jemdoc |
| Changes don't appear after pushing | browser cache — **Ctrl+Shift+R**; GitHub Pages also takes a minute |
| Links open in the same tab | the `target` patch was lost |
| `python` not recognised | try `py` instead |
| Edited a page, nothing changed | you edited the `.html`, not the source |

---

## Related

- `publications.toml` holds the data; your CV (`cv_varun.pdf`) is maintained
  separately and the two drift. They were last reconciled on 1 Oct 2026.
- jemdoc-cvx's own documentation: <https://cvxgrp.org/jemdoc-cvx/>
  (its README is also in `jemdoc-cvx-1.0.0/README.md`).
