
all: explore.md variables.md potential-issues.md nhanes-updates.md \
     check-numeric-categorical.md

%.md: %.rmd
	Rscript -e "rmarkdown::render('$<')"
