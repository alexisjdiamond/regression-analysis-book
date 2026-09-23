# Working on this book

Instructions for any AI assistant (or human) drafting or revising this book.
Read this before editing prose, code, or figures.

## 1. Causal language is reserved for designs that earn it

**This is the house rule and it is not negotiable.**

Do not describe a regression quantity with causal vocabulary unless the surrounding
text has established an *ex ante* design reason to interpret it causally — a
randomized experiment, or an explicitly stated identification assumption the text
is willing to defend.

Words that require that warrant: *effect*, *affects*, *impact*, *influences*,
*causes*, *determines*, *leads to*, *due to*, *produces*.

The book already states the rule, in Chapter 3, "Coefficients are indexed to a
specification":

> The discipline this suggests is to stop speaking of "the effect of \(X\)" and
> start naming the estimand precisely.

and gives the test case:

> Writing "95% confidence interval for the unadjusted association between \(X\)
> and \(Y\)" is accurate, useful, and the interval genuinely supports it. Writing
> "95% confidence interval for the effect of \(X\) on \(Y\)" is not supported, and
> the numbers printed on the page are exactly the same in both cases.

**Write instead:** *the fitted relationship between X and Y*; *the coefficient on
X*; *the association between X and Y*; *the fitted change in Y associated with a
one-unit increase in X*; *predicted values differ by*; *carries information about Y*.

**Where causal language IS correct:** Chapter 5 (Regression, Overlap, Model
Dependence, and Causal Inference); Chapter 1 §"Why Regression Matters for Causal
Inference"; Chapter 3's omitted-variable-bias material; glossary entries defining
causal terms. In all of these the causal vocabulary is the subject matter, and
the text names the design or assumption that licenses it.

**Nomenclature:** the book does not use *main effect*. Terms that appear on their
own alongside an interaction are named directly (e.g. "the star expands to `x`,
`d`, and their interaction"). A footnote in Chapter 4 records the conventional
name and explains the choice. Do not reintroduce *main effect* in the body text.

**Beware the near-misses.** Some uses of these words are not causal claims and are
fine: "in effect" (idiom); "different research questions produce different kinds of
dependent variables"; "the specification determines what shapes the model can
learn" (a statement about the model, not the world). Judge whether the sentence
attributes action in the world to a variable.

## 2. Sources of truth

| File | Status |
|---|---|
| `regression_analysis_complete_final.tex` | source — edit this |
| `regression_companion.Rmd` | source — edit this |
| `regression_companion.R` | **generated** by `tools/make_companion_script.R` — never edit |
| `docs/regression_companion.html` | **generated** by `make companion` — tracked, so commit it |
| `docs/*.pdf` | **generated** — gitignored; CI builds it and Pages serves the artifact |

A change to a worked example usually needs to land in **both** the `.tex` and the
`.Rmd`, or the book and the companion will disagree.

## 3. Building

```bash
make book        # 4 pdflatex passes + makeindex; ~16s; currently 87 pages
make companion   # regenerates the .R, knits the HTML
make check       # smoke test: the companion script must run end-to-end
```

`makeindex` lives in `~/Library/TinyTeX/bin/universal-darwin`, which is not on the
default PATH on this machine. Prepend it or `make book` fails at the index step.

The pass order in the Makefile matters — see the comment there before changing it.

## 4. Verify numbers, don't trust them

Every numeric claim in the text is reproducible from base R and the built-in
datasets (`mtcars`, `faithful`, `cars`). If you write or change a number, run the
code and check it. If you change a model's specification, re-derive every
coefficient quoted in the surrounding prose — they are quoted to three decimals in
several places.

## 5. Style

- Base R only. No tidyverse, no external packages in examples.
- Figures are drawn twice: once in TikZ/pgfplots for the PDF, once in base R in a
  `lstlisting` so the reader can reproduce it. Keep the two consistent.
- Fitted lines are drawn only across each group's **observed support**, never across
  the full plot. This is deliberate and anticipates the extrapolation material.
- Prose is measured and precise; it explains why something matters before showing
  how to compute it. Match that register.
