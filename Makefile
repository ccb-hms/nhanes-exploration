
all: explore.md variables.md potential-issues.md

%.md: %.rmd
	Rscript -e "rmarkdown::render('$<')"
