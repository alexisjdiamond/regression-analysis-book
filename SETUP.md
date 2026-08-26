# One-time publishing checklist

Follow these steps once to get the book live. Afterward you can delete this
file. Total time: about ten minutes.

## 1. Create the repository and push

On [github.com/new](https://github.com/new), create a **public** repository
(suggested name: `regression-analysis-book`). Do **not** initialize it with a
README, license, or .gitignore — this folder already has them. Then, from
inside this folder:

```sh
git init
git add -A
git commit -m "Regression Analysis v0.9 — initial public release"
git branch -M main
git remote add origin https://github.com/alexisjdiamond/regression-analysis-book.git
git push -u origin main
```

## 2. Personalize the links

In `README.md` and `docs/index.html`, replace every `alexisjdiamond` and
`regression-analysis-book` with your GitHub username and the repository name, then:

```sh
git commit -am "Personalize links"
git push
```

## 3. Turn on GitHub Pages

On GitHub: **Settings → Pages → Build and deployment**. Set Source to
**Deploy from a branch**, choose branch **main** and folder **/docs**, and
save. Within a minute or two your site is live at:

- Landing page: `https://alexisjdiamond.github.io/regression-analysis-book/`
- Direct PDF download: `https://alexisjdiamond.github.io/regression-analysis-book/regression_analysis_complete_final.pdf`
- Companion notebook: `https://alexisjdiamond.github.io/regression-analysis-book/regression_companion.html`

These URLs are public and shareable — anyone can download the PDF directly,
no GitHub account needed.

## 4. Publish the v0.9 release

This gives the PDF a *versioned*, permanent download URL that will survive
future editions. On GitHub: **Releases → Create a new release**. Set the tag
to `v0.9`, title it "Version 0.9", drag `docs/regression_analysis_complete_final.pdf`
into the assets box, and publish. (Alternatively, just push the tag —
`git tag v0.9 && git push origin v0.9` — and the included GitHub Action will
build the PDF and attach it to the release automatically.)

The stable download URL becomes:

```
https://github.com/alexisjdiamond/regression-analysis-book/releases/download/v0.9/regression_analysis_complete_final.pdf
```

## 5. Optional touches

- **License detection badge:** GitHub's license detector wants the full legal
  code. If you'd like the repo to display "CC-BY-4.0" automatically, replace
  the `LICENSE` file's contents with the full text from
  <https://creativecommons.org/licenses/by/4.0/legalcode.txt> (keep the
  copyright line and the note pointing code to LICENSE-CODE).
- **Repo description:** in the About box (top right of the repo page), add a
  one-liner and the Pages URL so both show up in search.
- **Issues:** leave Issues enabled so students can report typos.

## Ongoing workflow (after setup)

1. Edit `regression_analysis_complete_final.tex` or `regression_companion.Rmd`
   (never the PDF, HTML, or `.R` — those are generated).
2. `make all && make check`
3. Commit and push. The GitHub Action rebuilds the PDF from source on every
   push as a safety net.
4. For the next edition: bump the version/date in the three sources
   (`\date{...}` in the .tex, the YAML header in the .Rmd, the header comment
   in the regenerated `.R`), then tag it: `git tag v1.0 && git push origin v1.0`.
