Potential Issues with `nhanesA` and `phonto`
================
Deepayan Sarkar

# List of available tables

Data in the `nhanesA` package (or more precisely, in the CCB `NHANES`
Docker) are stored in a SQL Server database. The database can be queried
using the (unexported) `nhanesA:::.nhanesQuery()` function or its public
wrapper `phonto::nhanesQuery()`.

There is no ‘R-like’ way (that I can tell) to get a list of all
available tables. However, there are at least two ways to get this via
direct SQL queries:

``` r
all_tables_in_db <- 
  subset(nhanesA:::.nhanesQuery("select * from information_schema.tables;"),
         TABLE_SCHEMA == "Translated")$TABLE_NAME
all_tables_in_metadata <- 
  nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")$TableName
```

The second one uses one of the several metadata tables stored in the
database. The first one is the list of actual tables available (labeled
as “Translated”). As a sanity check, we can verify that the list of
“Raw” and “Translated” tables is identical.

``` r
all_raw_tables_in_db <- 
  subset(nhanesA:::.nhanesQuery("select * from information_schema.tables;"),
         TABLE_SCHEMA == "Raw")$TABLE_NAME
identical(sort(all_tables_in_db), sort(all_raw_tables_in_db))
#  [1] TRUE
```

Also, all the tables listed in the metadata table are actually
available:

``` r
setdiff(all_tables_in_metadata, all_tables_in_db)
#  character(0)
```

However, the converse is not true: not all translated tables in the
database are listed in the metadata. These are of two types: those
starting with `P_` and the rest, listed separately below:

``` r
setdiff(all_tables_in_db, all_tables_in_metadata) |> 
  grep(pattern = "^P_", invert = FALSE, value = TRUE)
#    [1] "P_WHQMEC" "P_WHQ"    "P_VTQ"    "P_VOCWB"  "P_UVOC2"  "P_UVOC"   "P_UTAS"   "P_UNI"   
#    [9] "P_UM"     "P_UIO"    "P_UHG"    "P_UCPREG" "P_UCM"    "P_UCFLOW" "P_UAS"    "P_TRIGLY"
#   [17] "P_TFR"    "P_TCHOL"  "P_SMQSHS" "P_SMQRTU" "P_SMQFAM" "P_SMQ"    "P_SLQ"    "P_RXQASA"
#   [25] "P_RXQ_RX" "P_RHQ"    "P_PUQMEC" "P_PERNT"  "P_PBCD"   "P_PAQY"   "P_PAQ"    "P_OSQ"   
#   [33] "P_OHXREF" "P_OHXDEN" "P_OHQ"    "P_OCQ"    "P_MCQ"    "P_LUX"    "P_KIQ_U"  "P_INS"   
#   [41] "P_INQ"    "P_IMQ"    "P_IHGEM"  "P_HUQ"    "P_HSQ"    "P_HSCRP"  "P_HIQ"    "P_HEQ"   
#   [49] "P_HEPE"   "P_HEPC"   "P_HEPBD"  "P_HEPB_S" "P_HEPA"   "P_HDL"    "P_GLU"    "P_GHB"   
#   [57] "P_FSQ"    "P_FR"     "P_FOLFMS" "P_FOLATE" "P_FETIB"  "P_FERTIN" "P_FASTQX" "P_ETHOX" 
#   [65] "P_ECQ"    "P_DXXSPN" "P_DXXFEM" "P_DSQTOT" "P_DSQIDS" "P_DS2TOT" "P_DS2IDS" "P_DS1TOT"
#   [73] "P_DS1IDS" "P_DRXFCD" "P_DR2TOT" "P_DR2IFF" "P_DR1TOT" "P_DR1IFF" "P_DPQ"    "P_DIQ"   
#   [81] "P_DEQ"    "P_DEMO"   "P_DBQ"    "P_CRCO"   "P_COT"    "P_CMV"    "P_CDQ"    "P_CBQPFC"
#   [89] "P_CBQPFA" "P_CBC"    "P_BPXO"   "P_BPQ"    "P_BMX"    "P_BIOPRO" "P_AUXWBR" "P_AUXTYM"
#   [97] "P_AUXAR"  "P_AUX"    "P_AUQ"    "P_ALQ"    "P_ALB_CR" "P_ACQ"
```

(these are intentionally excluded — we may or may not want to revisit
that) and the rest:

``` r
setdiff(all_tables_in_db, all_tables_in_metadata) |> 
  grep(pattern = "^P_", invert = TRUE, value = TRUE)
#   [1] "RXQ_DRUG" "DRXFMT_B" "DRXFMT"   "DRXFCD_J" "DRXFCD_I" "SSNH4THY" "SSHCV_E"  "SSDFS_A" 
#   [9] "POOLTF_E" "POOLTF_D" "SSCMVG_A" "SSCARD_A" "SSBNP_A"  "SSANA2_A" "SSANA_A"  "SSAGP_J" 
#  [17] "SSAGP_I"  "PFC_POOL" "DSPI"     "FOODLK_D" "DSII"     "FOODLK_C" "DSBI"     "VARLK_D" 
#  [25] "VARLK_C"  "SSUCSH_A" "SSTROP_A"
```

Most of these seem to be legitimate tables, so they should not be
excluded. Here are corresponding links to the NHANES website for easy
exploration.

``` r
URLs <- 
  setdiff(all_tables_in_db, all_tables_in_metadata) |> 
  grep(pattern = "^P_", invert = TRUE, value = TRUE) |>
  sapply(FUN = nhanes_url)
```

``` r
cat("", sprintf("- [%s](%s)", names(URLs), URLs), sep = "\n")
```

  - [RXQ\_DRUG](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/RXQ_DRUG.htm)
  - [DRXFMT\_B](https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/DRXFMT_B.htm)
  - [DRXFMT](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DRXFMT.htm)
  - [DRXFCD\_J](https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DRXFCD_J.htm)
  - [DRXFCD\_I](https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DRXFCD_I.htm)
  - [SSNH4THY](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSNH4THY.htm)
  - [SSHCV\_E](https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/SSHCV_E.htm)
  - [SSDFS\_A](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSDFS_A.htm)
  - [POOLTF\_E](https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/POOLTF_E.htm)
  - [POOLTF\_D](https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/POOLTF_D.htm)
  - [SSCMVG\_A](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSCMVG_A.htm)
  - [SSCARD\_A](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSCARD_A.htm)
  - [SSBNP\_A](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSBNP_A.htm)
  - [SSANA2\_A](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSANA2_A.htm)
  - [SSANA\_A](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSANA_A.htm)
  - [SSAGP\_J](https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/SSAGP_J.htm)
  - [SSAGP\_I](https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/SSAGP_I.htm)
  - [PFC\_POOL](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/PFC_POOL.htm)
  - [DSPI](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DSPI.htm)
  - [FOODLK\_D](https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/FOODLK_D.htm)
  - [DSII](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DSII.htm)
  - [FOODLK\_C](https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/FOODLK_C.htm)
  - [DSBI](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DSBI.htm)
  - [VARLK\_D](https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/VARLK_D.htm)
  - [VARLK\_C](https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/VARLK_C.htm)
  - [SSUCSH\_A](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSUCSH_A.htm)
  - [SSTROP\_A](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSTROP_A.htm)

All of these tables actually exist in the database; but they appear not
to have proper codebooks. For example,

``` r
nhanes("POOLTF_E") |> str()
#  'data.frame':    2282 obs. of  3 variables:
#   $ SEQN    : int  41481 41559 41608 41611 41643 41731 41740 41775 41801 41812 ...
#   $ SAMPLEID: int  NA NA NA NA NA NA NA NA NA NA ...
#   $ WTSA2YRA: num  0 0 0 0 0 0 0 0 0 0 ...
nhanesCodebook("POOLTF_E") |> str()
#  List of 3
#   $ SEQN    :List of 4
#    ..$ Variable Name:: chr "SEQN"
#    ..$ SAS Label:    : chr "Respondent sequence number"
#    ..$ English Text: : chr "Respondent sequence number"
#    ..$ Target:       : chr NA
#   $ SAMPLEID:List of 4
#    ..$ Variable Name:: chr "SAMPLEID"
#    ..$ SAS Label:    : chr NA
#    ..$ English Text: : chr NA
#    ..$ Target:       : chr NA
#   $ WTSA2YRA:List of 4
#    ..$ Variable Name:: chr "WTSA2YRA"
#    ..$ SAS Label:    : chr NA
#    ..$ English Text: : chr NA
#    ..$ Target:       : chr NA
```

This one is particularly interesting, because for the next cycle, we
have

``` r
nhanesCodebook("POOLTF_F") |> str()
#  List of 3
#   $ SEQN    :List of 4
#    ..$ Variable Name:: chr "SEQN"
#    ..$ SAS Label:    : chr "Respondent sequence number"
#    ..$ English Text: : chr "Respondent sequence number"
#    ..$ Target:       : chr "Both males and females 12 YEARS - 150 YEARS"
#   $ SAMPLEID:List of 4
#    ..$ Variable Name:: chr "SAMPLEID"
#    ..$ SAS Label:    : chr "Pool identification number"
#    ..$ English Text: : chr "Pool identification number"
#    ..$ Target:       : chr "Both males and females 12 YEARS - 150 YEARS"
#   $ WTSA2YRA:List of 5
#    ..$ Variable Name:: chr "WTSA2YRA"
#    ..$ SAS Label:    : chr "Adjusted subsample weight"
#    ..$ English Text: : chr "Adjusted subsample weight for the individual participant in pooled sample"
#    ..$ Target:       : chr "Both males and females 12 YEARS - 150 YEARS"
#    ..$ WTSA2YRA      :'data.frame':   2 obs. of  5 variables:
#    .. ..$ Code.or.Value    : chr [1:2] "0 to 537270.45707" "."
#    .. ..$ Value.Description: chr [1:2] "Range of Values" "Missing"
#    .. ..$ Count            : int [1:2] 2524 0
#    .. ..$ Cumulative       : int [1:2] 2524 2524
#    .. ..$ Skip.to.Item     : chr [1:2] NA NA
```

Looking at the corresponding webpages, it turns out that `POOLTF_D` and
`POOLTF_E` don’t have a proper codebook, so that’s probably what is
causing the failure. Several others (but not all) have similar problems.

These two have the problem that they don’t have the proper suffix, so
their URL cannot be computed from the table names:

  - <https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/PFC_POOL.htm>

  - <https://wwwn.cdc.gov/nchs/nhanes/2001-2002/SSNH4THY.htm>

# Metadata for `L02HPA_A`

This may be a completely one-off problem in the table metadata:

``` r
tableDesc <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")
subset(tableDesc, TableName |> startsWith("L02HPA"))
#               Description TableName BeginYear EndYear  DataGroup UseConstraints
#  301 Hepatitis A Antibody  L02HPA_A      1999    2000 Laboratory           None
#  302 Hepatitis A Antibody  L02HPA_B      2001    2002 Laboratory           None
#  303 Hepatitis A Antibody  L02HPA_C      2003    2004 Laboratory           None
#                                                      DocFile
#  301                                                        
#  302 https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/L02HPA_B.htm
#  303 https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/L02HPA_C.htm
#                                                     DataFile DatePublished
#  301                                                                      
#  302 https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/L02HPA_B.XPT    March 2008
#  303 https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/L02HPA_C.XPT    March 2008
```

Note that the `DocFile` and `DataFile` entries are empty for the first
of these, even though this link works:

``` r
cat("\n\n<", nhanes_url("L02HPA_A"), ">\n\n", sep = "")
```

<https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/L02HPA_A.htm>

The one unusual thing about this table is that the `_A` suffix was not
actually a cycle indicator (and it was originally a lowercase `_a`),
though the original meaning was subsequently dropped.

# Things that would be nice to have

(Maybe they already exist)

  - `browseNHANES(nh_table = "BPQ_J")` etc. opens NHANES website — maybe
    we can add the option to return the URL instead of opening it (could
    be helpful when creating our own summary), or have a different
    `getNHANES_URL()` with the same arguments. I have a limited
    implementation `nhanes_url()` in [this file](R/utilities.R).

  - `nhanesAttr()` could return number of `NA` values columnwise
    (currently returns total)

<!-- end list -->

``` r
nhanesAttr("BPQ_J") |> str()
#  List of 9
#   $ names : chr [1:11] "SEQN" "BPQ020" "BPQ030" "BPD035" ...
#   $ class : chr "data.frame"
#   $ nrow  : int 6161
#   $ ncol  : int 11
#   $ unique: logi TRUE
#   $ na    : int 26003
#   $ size  : 'object_size' num 544176
#   $ types : Named chr [1:11] "numeric" "numeric" "numeric" "numeric" ...
#    ..- attr(*, "names")= chr [1:11] "SEQN" "BPQ020" "BPQ030" "BPD035" ...
#   $ labels: Named chr [1:11] "Respondent sequence number" "Ever told you had high blood pressure" "Told had high blood pressure - 2+ times" "Age told had hypertension" ...
#    ..- attr(*, "names")= chr [1:11] "SEQN" "BPQ020" "BPQ030" "BPD035" ...
```

  - Searchable table of NHANES tables (using datatable maybe). Something
    better than <https://wwwn.cdc.gov/nchs/nhanes/search/DataPage.aspx>.
    Either have pre-built versions, or generate on-the-fly, depending on
    speed. I am planning to work on this anyway as it will be useful for
    downstream analysis, but we can discuss whether it would be
    something useful to have either in `nhanesA` or `phonto`.

  - Some way to navigate between tables and variables — in particular,
    it’s perhaps not obvious that the same variable can be in different
    tables in different years, and even in the same year. Note that
    there is already `nhanesSearchTableNames()` and
    `nhanesSearchVarName()`, e.g.,

<!-- end list -->

``` r
nhanesSearchVarName('PHAFSTMN')
#   [1] "OGTT_E"   "FASTQX_D" "FASTQX_E" "FASTQX_F" "FASTQX_G" "FASTQX_H" "FASTQX_I" "FASTQX_J"
#   [9] "GLU_E"    "PH"       "PH_B"     "PH_C"     "GLU_D"    "GLU_F"    "GLU_G"    "GLU_H"   
#  [17] "INS_H"    "INS_I"    "OGTT_D"   "OGTT_F"   "OGTT_G"   "OGTT_H"
```

# Example code

The output produced is not what I would expect

  - `?dataDescription`

<!-- end list -->

``` r
dataDescription(list(BPQ_J=c("BPQ020", "BPQ050A"), DEMO_J=c("RIDAGEYR","RIAGENDR")))
#  data frame with 0 columns and 0 rows
```

  - `?nhanesSearchTableNames` - also doesn’t set `details = TRUE` as
    documented

<!-- end list -->

``` r
hepbd <- nhanesSearchTableNames('HEPBD', includeurl=TRUE)
dim(hepbd)
#  NULL
str(hepbd)
#   chr [1:7] "HEPBD_D" "HEPBD_E" "HEPBD_F" "HEPBD_G" "HEPBD_H" "HEPBD_I" "HEPBD_J"
```

  - `?nhanes` - No visible difference. Bug?

<!-- end list -->

``` r
nhanes('DEMO_G', includelabels = FALSE) |> attributes() |> str()
#  List of 3
#   $ names    : chr [1:48] "SEQN" "SDDSRVYR" "RIDSTATR" "RIAGENDR" ...
#   $ class    : chr "data.frame"
#   $ row.names: int [1:9756] 1 2 3 4 5 6 7 8 9 10 ...
nhanes('DEMO_G', includelabels = TRUE) |> attributes() |> str()
#  List of 3
#   $ names    : chr [1:48] "SEQN" "SDDSRVYR" "RIDSTATR" "RIAGENDR" ...
#   $ class    : chr "data.frame"
#   $ row.names: int [1:9756] 1 2 3 4 5 6 7 8 9 10 ...
```

# Some curiosities

These are not problems exactly, but maybe deserve some thought.

One reason for translating tables is to make data comparable across
cycles. The task of translation is complicated when a *continuous*
measurement uses specific numeric values to encode special meaning. It
is not clear how these can be handled without introducing new variables,
but not handling this may lead to user confusion.

Not surprisingly, the special coding may even change from cycle to
cycle. For example,

``` r
nhanesCodebook("WHQ")[["WHD020"]][["WHD020"]] # 77777 / 99999
#    Code.or.Value Value.Description Count Cumulative Skip.to.Item
#  1     60 to 420   Range of Values  5902       5902         <NA>
#  2         77777           Refused     7       5909         <NA>
#  3         99999        Don't know   130       6039         <NA>
#  4             .           Missing     5       6044         <NA>
nhanesCodebook("WHQ_B")[["WHD020"]][["WHD020"]] # 7777 / 9999
#    Code.or.Value Value.Description Count Cumulative Skip.to.Item
#  1     50 to 450   Range of Values  6524       6524         <NA>
#  2          7777           Refused    14       6538         <NA>
#  3          9999        Don't know    92       6630         <NA>
#  4             .           Missing     4       6634         <NA>
```

A not-too-difficult solution is to convert all special values to
missing, though that will lead to loss of information.

Finally, is the CRAN repository intentionally fixed to an old snapshot?
This could be a Bioconductor-like design, which is OK, but it’s not what
one normally expects from CRAN.

``` r
R.version[["version.string"]]
#  [1] "R version 4.2.1 (2022-06-23)"
getOption("repos")
#                                                               CRAN 
#  "https://packagemanager.posit.co/cran/__linux__/focal/2022-10-18"
```

The relevant parts in the Docker file that controls these are:

``` sh
ENV R_VERSION_MAJOR 4
ENV R_VERSION_MINOR 2
ENV R_VERSION_BUGFIX 1
ENV R_REPOSITORY=https://packagemanager.posit.co/cran/__linux__/focal/2022-10-18
```

Also the base image from 2019

``` sh
FROM mcr.microsoft.com/mssql/server:2019-CU12-ubuntu-20.04
```

seems to have a [2022
update](https://hub.docker.com/_/microsoft-mssql-server) (with the same
version of Ubuntu though).
