
all: explore.md

explore.md: explore.rmd
	Rscript -e 'rmarkdown::render("explore.rmd")'
