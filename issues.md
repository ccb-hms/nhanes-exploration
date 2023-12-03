---
title: 'NHANES: Summary of outstanding issues'
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

* Question: Does installing the docker install the current github
  version of `nhanesA` or the one that was current when the docker
  image was released?


---

# Software checks

* Check whether `R CMD INSTALL / check` works inside docker

    * `R CMD INSTALL nhanes` - works
    * `R CMD build nhanes` - works
    * `R CMD INSTALL nhanesA_0.8.9.tar.gz` - works
    * `R CMD check nhanesA_0.8.9.tar.gz` - works other than expected `.onLoad` warnings

* `Rscript -e "remotes::install_cran('lme4', force = TRUE)"`

    * works (binary install from <https://p3m.dev/cran/__linux__/jammy/latest/src/contrib/lme4_1.1-35.1.tar.gz>)

* `Rscript -e "remotes::install_cran('lme4', force = TRUE, repos = 'https://cloud.r-project.org')"`

    * works (source install from <https://cloud.r-project.org/src/contrib/lme4_1.1-35.1.tar.gz>)

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

* Tables that are in the database but not in the metadata stored in the DB. Many of these are excluded
  because of size and should be listed in the database under `Metadata.ExcludedTables`.

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

* Discuss how to get initial list of tables to put in DB (also see discussion below)

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


---

# Discrepancies between manifest and group-wise tables

* Several sources:

	1. <https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Laboratory> etc.

	2. <https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx>

	3. <https://wwwn.cdc.gov/nchs/nhanes/search/variablelist.aspx?Component=Laboratory> etc


* We have `nhanesManifest("public")` for ` and `nhanesManifest("variables")` for 3

* The following should be run outside docker:

```r
tm <- nhanesManifest("public")
tl <- nhanesManifest("limited")
vm <- nhanesManifest("variables")
```

Differences:

```
> sort(setdiff(toupper(c(tm$Table, tl$Table)), unique(toupper(vm$Table))))
 [1] "ALL YEARS"  "DOC_2000"   "DRXFCD_I"   "DRXFCD_J"   "DRXFMT"     "DRXFMT_B"   "FOODLK_C"   "FOODLK_D"   "P_DRXFCD"   "PAX80_G"   
[11] "PAX80_G_R"  "PAX80_H"    "PAXLUX_G"   "PAXLUX_G_R" "PAXLUX_H"   "POOLTF_D"   "POOLTF_E"   "VARLK_C"    "VARLK_D"    "YDQ"       
> sort( setdiff( unique(toupper(vm$Table)), toupper(c(tm$Table, tl$Table))))
 [1] "CMV"      "GROWTHCH" "HGUHS"    "HGUHSSE"  "L06VID_B" "L06VID_C" "N3GE2000" "N3GE2010" "SSN3UE_R" "SSNH3ANA" "SSNH3BTP" "SSNH3CYS"
[13] "SSNH3DFS" "SSNH3HEG" "SSNH3HEW" "SSNH3IGE" "SSNH3OL"  "SSNH3UOL" "SSTESTOS" "VID_2_00" "VID_2_B"  "VID_NH3" 
```


---

# Other non-DB issues

- Translation of special 'numeric' codes

- Should we 'standardize' response codes that differ in case across years (`2nd Grade` vs `2nd grade`)?


---

# 





