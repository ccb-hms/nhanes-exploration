---
layout: remark
title: NHANES: Summary of outstanding issues
author: Deepayan Sarkar
---


# Summary

* Software versions and related issues

* Database content

* Documentation


---

# Software versions

* [Update R](https://github.com/ccb-hms/NHANES/issues/97)

	- Now 4.3.2
	
	- `repos` is Posit Public Package Manager <https://p3m.dev/> (probably from rocker?)

* [Update RStudio](https://github.com/ccb-hms/NHANES/issues/98)

	- Now 2023.09.1

* Should look into why the following are still needed.

```
# -- vanilla because there is a bug that causes the R intro / preamble text to get pushed into the compiler
RUN Rscript --vanilla -e "remotes::install_cran('lme4', repos='"$R_REPOSITORY"')"
RUN Rscript --vanilla -e "remotes::install_cran('survminer', repos='"$R_REPOSITORY"')"

# need old version of rvest in order for the hack that parses URLs to work in the NHANES download script
RUN Rscript -e "remove.packages('rvest')"
RUN Rscript -e "remotes::install_cran('rvest', repos='https://packagemanager.posit.co/cran/__linux__/focal/2021-01-29')"
```

* TODO: Check whether `R CMD check` works inside docker

* Question: Does installing the docker install the current github
  version of `nhanesA` or the one that was current when the docker
  image was released?

---

# Mounting local files

Running with

```
	-v /Users/deepayan/git/github/ccb-hms-personal/hms-ccb/NHANES/experiments:/home/deepayan/experiments
```

doesn't seem to work

* TODO: Check whether it works (only?) for `/hostData`


---

# Database content 1

See [here](https://github.com/ccb-hms/nhanes-exploration/blob/main/build-time-checks.md) for

* Tables that are in the database but not in the metadata stored in the DB

* Tables that are in the NHANES
  [manifest](https://wwwn.cdc.gov/Nchs/Nhanes/search/DataPage.aspx)
  but not in the DB metadata
  
* Tables whose documentation URL is missing from the DB metadata

```r
table_metadata <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")
subset(table_metadata, !startsWith(DocFile, "https"))[-1]
```

* Also explores [unusual value descriptions](https://github.com/ccb-hms/NHANES/issues/112) for
  supposedly numeric variables (but not a DB issue)

---

# Action points

* Discuss how to get initial list of tables to put in DB

* Incorporate relevant parts of these checks in DB build pipeline

* Discuss how to deal with missing documentation. 

	* This needs a closer look, because they are probably probably
      caused by errors in parsing the NHANES web pages.
  
	* Could be systematic structural differences that appear in multiple pages 
	
	* Could be one-off errors that are not worth pursuing

---

# Database content 2

* Missing codebook details [due to case mismatch](https://github.com/ccb-hms/NHANES/issues/115). 
  This may turn out to be an R code issue --- will check and update.

* [Repeated rows](https://github.com/ccb-hms/NHANES/issues/118) in
  codebook tables. Relatively minor as it only affects one table, but
  would be good to figure out the root cause.

* Difference in how [columns are ordered](https://github.com/ccb-hms/NHANES/issues/114) 
  (no need to fix)











