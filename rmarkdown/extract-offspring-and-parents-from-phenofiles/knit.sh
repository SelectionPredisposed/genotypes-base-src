#!/usr/bin/env bash

# Knit to markdown
R -e rmarkdown::render"('extract-offspring-parents-from-phenofiles.Rmd',output_file='report.md')"

# Knit to HTML
R -e rmarkdown::render"('extract-offspring-parents-from-phenofiles.Rmd',output_file='report.html')"

