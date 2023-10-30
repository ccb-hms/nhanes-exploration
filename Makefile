
all: explore.md variables.md potential-issues.md nhanes-updates.md

%.md: %.rmd
	Rscript -e "rmarkdown::render('$<')"
