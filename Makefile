
all: explore.md variables.md

%.md: %.rmd
	Rscript -e "rmarkdown::render('$<')"
