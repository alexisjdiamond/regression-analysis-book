# Regenerates regression_companion.R from regression_companion.Rmd,
# preserving the "# ---- chunk-name ----" section format.
# Invoked by `make companion`; not intended to be run inside the notebook.

rmd <- readLines("regression_companion.Rmd")
txt <- paste(rmd, collapse = "\n")

m <- gregexpr("(?s)```\\{r ([^,}]+)[^}]*\\}\n(.*?)```", txt, perl = TRUE)
starts <- m[[1]]
lens <- attr(m[[1]], "match.length")

header <- c(
  "# Regression Analysis: Companion R Script",
  "# Author: Alexis Diamond, PhD (assisted by Claude and ChatGPT)",
  "# Version 0.9 --- August 26, 2026",
  "# Generated from regression_companion.Rmd.",
  "# Run from top to bottom. Uses base R grammar only.",
  "", ""
)

out <- header
for (i in seq_along(starts)) {
  chunk <- substr(txt, starts[i], starts[i] + lens[i] - 1)
  name <- sub("^```\\{r ([^,}]+).*", "\\1", chunk)
  name <- trimws(sub("\\n.*$", "", name))
  if (identical(name, "setup")) next
  body <- sub("^```\\{r [^}]*\\}\n", "", chunk)
  body <- sub("```$", "", body)
  body <- sub("\n+$", "", body)
  out <- c(out, sprintf("# ---- %s ----", name), body, "")
}

while (length(out) > 0 && out[length(out)] == "") out <- out[-length(out)]
writeLines(out, "regression_companion.R")
cat("regression_companion.R regenerated:",
    sum(grepl("^# ---- ", out)), "sections\n")
