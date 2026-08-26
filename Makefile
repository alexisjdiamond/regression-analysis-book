# Regression Analysis: Prediction, Foundations, and Inference — build automation
#
# Sources of truth: regression_analysis_complete_final.tex, regression_companion.Rmd
# Everything else (PDF, HTML, .R) is generated.

BOOK      = regression_analysis_complete_final
COMPANION = regression_companion
LATEX     = pdflatex -interaction=nonstopmode

.PHONY: all book companion check clean

all: book companion

# The pass order matters: the index must be generated AFTER the table of
# contents has stabilized (two passes), then two more passes resolve the
# index's own page references. Running makeindex after only one pass
# produces index page numbers that are stale by the length of the TOC.
book:
	$(LATEX) $(BOOK).tex
	$(LATEX) $(BOOK).tex
	makeindex $(BOOK).idx
	$(LATEX) $(BOOK).tex
	$(LATEX) $(BOOK).tex
	cp $(BOOK).pdf docs/$(BOOK).pdf

# Regenerate the plain-R script from the notebook, then knit the HTML.
# The .R is generated — never edit it directly.
companion:
	Rscript tools/make_companion_script.R
	Rscript -e 'rmarkdown::render("$(COMPANION).Rmd", output_file = "docs/$(COMPANION).html", quiet = TRUE)'

# Smoke test: the companion script must run end-to-end without errors.
check:
	Rscript -e 'pdf(NULL); source("$(COMPANION).R"); cat("COMPANION SCRIPT RAN CLEAN\n")'

clean:
	rm -f $(BOOK).aux $(BOOK).log $(BOOK).toc $(BOOK).idx $(BOOK).ind \
	      $(BOOK).ilg $(BOOK).out $(BOOK).pdf
