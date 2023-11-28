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
> sort(setdiff(c(tm$Table, tl$Table), unique(vm$Table)))
 [1] "All Years"  "APOB_E"     "APOB_F"     "APOB_G"     "APOB_H"     "DOC_2000"   "DRXFCD_I"   "DRXFCD_J"   "DRXFMT"     "DRXFMT_B"   "FOODLK_C"   "FOODLK_D"   "IHG_D"      "IHG_E"     
[15] "IHG_F"      "IHGEM_G"    "L02HPA_A"   "L09_B"      "L09_C"      "L09RDC_A"   "L09RDC_B"   "L09RDC_C"   "L10_2_00"   "L11_2_B"    "L11P_2_B"   "L13_2_B"    "L13_2_R"    "L13_B"     
[29] "L13_C"      "L18_2_00"   "L25_2_B"    "L25_2_R"    "L26PP_B"    "L34_B"      "L34_B_R"    "L34_C"      "L34_C_R"    "L39_2_B"    "LAB02"      "LAB09"      "LAB13"      "P_DRXFCD"  
[43] "PAX80_G"    "PAX80_G_R"  "PAX80_H"    "PAXLUX_G"   "PAXLUX_G_R" "PAXLUX_H"   "PBCD_D"     "PBCD_E"     "PBCD_F"     "PBCD_G"     "PFC_POOL"   "POOLTF_D"   "POOLTF_E"   "VARLK_C"   
[57] "VARLK_D"    "YDQ"       
> sort(setdiff(unique(vm$Table), c(tm$Table, tl$Table)))
 [1] "ApoB_E"   "ApoB_F"   "ApoB_G"   "ApoB_H"   "CMV"      "GROWTHCH" "HGUHS"    "HGUHSSE"  "IHg_D"    "IHg_E"    "IHg_F"    "IHgEM_G"  "L02HPA_a" "L06VID_B" "L06VID_C" "l09_b"   
[17] "l09_c"    "l09rdc_a" "l09rdc_b" "l09rdc_c" "l10_2_00" "L11_2_b"  "l11p_2_b" "l13_2_b"  "l13_2_r"  "l13_b"    "l13_c"    "l18_2_00" "l25_2_b"  "l25_2_r"  "l26PP_B"  "l34_b"   
[33] "l34_b_r"  "l34_c"    "l34_c_r"  "l39_2_b"  "Lab02"    "lab09"    "Lab13"    "N3GE2000" "N3GE2010" "PbCd_D"   "PbCd_E"   "PbCd_F"   "PbCd_G"   "PFC_Pool" "SSN3UE_R" "SSNH3ANA"
[49] "SSNH3BTP" "SSNH3CYS" "SSNH3DFS" "SSNH3HEG" "SSNH3HEW" "SSNH3IGE" "SSNH3OL"  "SSNH3UOL" "SSTESTOS" "VID_2_00" "VID_2_B"  "VID_NH3" 
```







