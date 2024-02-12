
all: explore.md variables.md potential-issues.md nhanes-updates.md \
     check-numeric-categorical.md

%.md: %.rmd
	Rscript -e "rmarkdown::render('$<')"

# html is useful for local preview, but checking in is pointless as
# GitHub will not display properly

%.html: %.rmd
	Rscript -e "rmarkdown::render('$<', 'html_document')"




