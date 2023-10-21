NHANES database build-time checks
================
Deepayan Sarkar
2023-10-21

## Tables missing from table metadata

The following tables are in the database but not in the metadata stored
in the DB.

``` r
## code to generate list
nhanes_url <- function (nh_table) {
  nh_year <- nhanesA:::.get_year_from_nh_table(nh_table)
  paste0(nhanesA:::nhanesURL, nh_year, "/", nh_table, ".htm")
}
library(nhanesA) # mainly for querying database
all_tables_in_db <- 
  subset(nhanesA:::.nhanesQuery("select * from information_schema.tables;"),
         TABLE_SCHEMA == "Translated")$TABLE_NAME
all_tables_in_metadata <- 
  nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")$TableName
URLs <- 
  (setdiff(all_tables_in_db, all_tables_in_metadata) 
   |> grep(pattern = "^P_", invert = TRUE, value = TRUE) 
   |> sapply(FUN = nhanes_url))
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

This needs to be looked at manually (many, but not all, are due to
obvious bugs in the NHANES documentation pages).

## Cross check tables with NHANES master list

The NHANES website has a master list of all tables at

<https://wwwn.cdc.gov/Nchs/Nhanes/search/DataPage.aspx>

Let’s download this and save it in a CSV file using Python…

``` python
from bs4 import BeautifulSoup
import requests

## extraction functions for td elements
def etext(obj): return obj.get_text().strip()
def eurl(obj): return obj.find('a').get_attribute_list('href')[0]

url = 'https://wwwn.cdc.gov/Nchs/Nhanes/search/DataPage.aspx'

source_html = requests.get(url).content.decode('utf-8')
soup = BeautifulSoup(source_html, 'html.parser')

_table = soup.find('table', {'id' : 'GridView1'}) 

f = open('table_manifest.csv', 'w')
f.write("Table,Years,PubDate,DocURL,DataURL\n")
```

``` python
for row in _table.tbody.find_all('tr'):
    [year, docfile, datafile, pubdate] = row.find_all('td')
    if etext(pubdate) != 'Withdrawn':
        f.write("%s,%s,%s,https://wwwn.cdc.gov%s,https://wwwn.cdc.gov%s\n" % 
                    (etext(docfile).split()[0], 
                     etext(year), 
                     etext(pubdate),
                     eurl(docfile),
                     eurl(datafile)))
```

``` python
f.close()
```

…and then read this file in using R.

``` r
manifest <- read.csv("table_manifest.csv")
## fixup some weird URLs
manifest <- within(manifest, {
  DocURL <- gsub("cdc.gov../", "cdc.gov/Nchs/Nhanes/", DocURL, fixed = TRUE)
  DataURL <- gsub("cdc.gov../", "cdc.gov/Nchs/Nhanes/", DataURL, fixed = TRUE)
})
```

Sanity checks:

``` r
with(manifest, table(tools::file_ext(DocURL)))   # doc file extensions
```

    ## 
    ##      aspx  htm 
    ##    5    2 1505

``` r
with(manifest, table(tools::file_ext(DataURL)))  # data file extensions
```

    ## 
    ##      aspx  xpt  XPT  ZIP 
    ##    9    2    3 1493    5

``` r
with(manifest, Table[duplicated(Table)])         # uniqueness of table names
```

    ## [1] "All"

The `aspx` files and duplicated table name comes from additional details
specific to missingness in DXA and OMB tables (see links). Note that
`nhanesA` handles “DXA” specially, e.g., `nhanesA::nhanesDXA()`, but not
OMB.

``` r
subset(manifest, Table == "All")
```

    ##      Table     Years               PubDate
    ## 554    All 1999-2006 Updated December 2016
    ## 1052   All 2009-2012          October 2022
    ##                                                 DocURL
    ## 554      https://wwwn.cdc.gov/Nchs/Nhanes/Dxa/Dxa.aspx
    ## 1052 https://wwwn.cdc.gov/Nchs/Nhanes/Omp/Default.aspx
    ##                                                DataURL
    ## 554      https://wwwn.cdc.gov/Nchs/Nhanes/Dxa/Dxa.aspx
    ## 1052 https://wwwn.cdc.gov/Nchs/Nhanes/Omp/Default.aspx

We will simply skip these two entries.

``` r
manifest <- subset(manifest, Table != "All")
```

The ZIP extensions are from

``` r
subset(manifest, tolower(tools::file_ext(DataURL)) == "zip")
```

    ##         Table     Years               PubDate
    ## 1155 PAXRAW_D 2005-2006             June 2008
    ## 1156 PAXRAW_C 2003-2004 Updated December 2007
    ## 1353 SPXRAW_E 2007-2008         December 2011
    ## 1354 SPXRAW_F 2009-2010         December 2011
    ## 1355 SPXRAW_G 2011-2012         December 2014
    ##                                                       DocURL
    ## 1155 https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/PAXRAW_D.htm
    ## 1156 https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/PAXRAW_C.htm
    ## 1353 https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/SPXRAW_E.htm
    ## 1354 https://wwwn.cdc.gov/Nchs/Nhanes/2009-2010/SPXRAW_F.htm
    ## 1355 https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/SPXRAW_G.htm
    ##                                                      DataURL
    ## 1155 https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/PAXRAW_D.ZIP
    ## 1156 https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/PAXRAW_C.ZIP
    ## 1353 https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/SPXRAW_E.ZIP
    ## 1354 https://wwwn.cdc.gov/Nchs/Nhanes/2009-2010/SPXRAW_F.ZIP
    ## 1355 https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/SPXRAW_G.ZIP

These are very large files, with multiple entries per subject storing
minute-by-minute results recorded in a physical activity monitoring
device. These data are not included in the database (and probably should
not be), but we will retain these rows to remind us that the tables
exist.

OK, let’s now see if any of these are missing either from the list of
tables in the database, or from the table metadata.

``` r
setdiff(manifest$Table, all_tables_in_db) # missing from DB
```

    ##  [1] "CHLMDA_F" "CHLMDA_G" "CHLMDA_H" "CHLMDA_I" "LAB05"    "CHLMDA_D"
    ##  [7] "L05_C"    "L05_B"    "CHLMDA_E" "SSCT_H"   "SSCT_I"   "PAXRAW_D"
    ## [13] "PAXRAW_C" "PAXLUX_G" "PAXLUX_H" "PAXMIN_G" "PAXMIN_H" "PAX80_G" 
    ## [19] "PAX80_H"  "PAHS_G"   "PAHS_I"   "SPXRAW_E" "SPXRAW_F" "SPXRAW_G"
    ## [25] "VID_B"    "VID_C"    "VID_D"    "VID_E"    "VID_F"    "VID_G"   
    ## [31] "VID_H"    "VID_I"    "VID_J"

Links for exploration:

``` r
paste0("- <", 
       subset(manifest, Table %in% setdiff(manifest$Table, all_tables_in_db))$DocURL,
       ">") |>
  cat(sep = "\n")
```

  - <https://wwwn.cdc.gov/Nchs/Nhanes/2009-2010/CHLMDA_F.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/CHLMDA_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/CHLMDA_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/CHLMDA_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/LAB05.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/CHLMDA_D.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/L05_C.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/L05_B.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/CHLMDA_E.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/SSCT_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/SSCT_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/PAXRAW_D.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/PAXRAW_C.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/PAXLUX_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/PAXLUX_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/PAXMIN_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/PAXMIN_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/PAX80_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/PAX80_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/PAHS_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/PAHS_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/SPXRAW_E.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2009-2010/SPXRAW_F.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/SPXRAW_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2001&e=2002&d=VID_B&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2003&e=2004&d=VID_C&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2005&e=2006&d=VID_D&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2007&e=2008&d=VID_E&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2009&e=2010&d=VID_F&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/VID_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/VID_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/VID_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/VID_J.htm>

Tables missing from metadata:

``` r
setdiff(manifest$Table, all_tables_in_metadata) # missing from metadata
```

    ##   [1] "P_ACQ"    "P_ALB_CR" "P_ALQ"    "SSAGP_I"  "SSAGP_J"  "P_UTAS"  
    ##   [7] "P_UAS"    "P_AUQ"    "P_AUX"    "P_AUXAR"  "P_AUXTYM" "P_AUXWBR"
    ##  [13] "SSDFS_A"  "SSANA_A"  "SSANA2_A" "P_BPXO"   "P_BPQ"    "P_BMX"   
    ##  [19] "P_CDQ"    "CHLMDA_F" "CHLMDA_G" "CHLMDA_H" "CHLMDA_I" "LAB05"   
    ##  [25] "CHLMDA_D" "L05_C"    "L05_B"    "CHLMDA_E" "SSCT_H"   "SSCT_I"  
    ##  [31] "P_HDL"    "P_TRIGLY" "P_TCHOL"  "P_UCM"    "P_CRCO"   "P_CBC"   
    ##  [37] "P_CBQPFA" "P_CBQPFC" "P_COT"    "P_HSQ"    "SSCMVG_A" "P_CMV"   
    ##  [43] "SSUCSH_A" "P_DEMO"   "P_DEQ"    "P_DIQ"    "P_DBQ"    "P_DR1IFF"
    ##  [49] "P_DR2IFF" "P_DR1TOT" "P_DR2TOT" "DRXFMT"   "DRXFMT_B" "DRXFCD_I"
    ##  [55] "DRXFCD_J" "P_DRXFCD" "DSBI"     "DSII"     "DSPI"     "P_DS1IDS"
    ##  [61] "P_DS2IDS" "P_DS1TOT" "P_DS2TOT" "P_DSQIDS" "P_DSQTOT" "P_DXXFEM"
    ##  [67] "P_DXXSPN" "P_ECQ"    "P_ETHOX"  "P_FASTQX" "P_FERTIN" "P_FR"    
    ##  [73] "P_FOLATE" "P_FOLFMS" "FOODLK_C" "FOODLK_D" "VARLK_C"  "VARLK_D" 
    ##  [79] "P_FSQ"    "SSCARD_A" "P_GHB"    "P_HIQ"    "P_HEQ"    "P_HEPA"  
    ##  [85] "P_HEPB_S" "P_HEPBD"  "SSHCV_E"  "P_HEPC"   "P_HEPE"   "SSTROP_A"
    ##  [91] "P_HSCRP"  "P_HUQ"    "P_IMQ"    "P_INQ"    "P_IHGEM"  "P_INS"   
    ##  [97] "P_UIO"    "P_FETIB"  "P_KIQ_U"  "P_PBCD"   "P_LUX"    "P_MCQ"   
    ## [103] "P_DPQ"    "P_UHG"    "P_UM"     "P_UNI"    "SSBNP_A"  "P_OCQ"   
    ## [109] "P_OHQ"    "P_OHXDEN" "P_OHXREF" "P_OSQ"    "P_PERNT"  "P_PUQMEC"
    ## [115] "P_PAQ"    "P_PAQY"   "PAXRAW_D" "PAXRAW_C" "PAXLUX_G" "PAXLUX_H"
    ## [121] "PAXMIN_G" "PAXMIN_H" "PAX80_G"  "PAX80_H"  "P_GLU"    "PAHS_G"  
    ## [127] "PAHS_I"   "PFC_POOL" "POOLTF_D" "POOLTF_E" "P_RXQ_RX" "RXQ_DRUG"
    ## [133] "P_RXQASA" "P_RHQ"    "P_SLQ"    "P_SMQ"    "P_SMQFAM" "P_SMQRTU"
    ## [139] "P_SMQSHS" "SPXRAW_E" "SPXRAW_F" "SPXRAW_G" "P_BIOPRO" "SSNH4THY"
    ## [145] "P_TFR"    "P_UCFLOW" "P_UCPREG" "VID_B"    "VID_C"    "VID_D"   
    ## [151] "VID_E"    "VID_F"    "VID_G"    "VID_H"    "VID_I"    "VID_J"   
    ## [157] "P_UVOC"   "P_UVOC2"  "P_VOCWB"  "P_VTQ"    "P_WHQ"    "P_WHQMEC"

Links for exploration (excluding `P_*` tables for now): \[Note that
these should be a superset of the earlier list of tables missing from
the metadata\]

``` r
paste0("- <", 
       subset(manifest, !startsWith(Table, "P_") & 
                Table %in% setdiff(manifest$Table, all_tables_in_metadata))$DocURL,
       ">") |>
  cat(sep = "\n")
```

  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/SSAGP_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/SSAGP_J.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSDFS_A.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSANA_A.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSANA2_A.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2009-2010/CHLMDA_F.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/CHLMDA_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/CHLMDA_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/CHLMDA_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/LAB05.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/CHLMDA_D.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/L05_C.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/L05_B.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/CHLMDA_E.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/SSCT_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/SSCT_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSCMVG_A.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSUCSH_A.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DRXFMT.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/DRXFMT_B.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DRXFCD_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DRXFCD_J.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DSBI.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DSII.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DSPI.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/FOODLK_C.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/FOODLK_D.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/VARLK_C.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/VARLK_D.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSCARD_A.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/SSHCV_E.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSTROP_A.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSBNP_A.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/PAXRAW_D.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/PAXRAW_C.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/PAXLUX_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/PAXLUX_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/PAXMIN_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/PAXMIN_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/PAX80_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/PAX80_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/PAHS_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/PAHS_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/PFC_POOL.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/POOLTF_D.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/POOLTF_E.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/RXQ_DRUG.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/SPXRAW_E.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2009-2010/SPXRAW_F.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/SPXRAW_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/SSNH4THY.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2001&e=2002&d=VID_B&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2003&e=2004&d=VID_C&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2005&e=2006&d=VID_D&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2007&e=2008&d=VID_E&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2009&e=2010&d=VID_F&x=htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/VID_G.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/VID_H.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/VID_I.htm>
  - <https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/VID_J.htm>

Although there should not be, let’s also make sure that no table in the
DB is missing from the manifest.

``` r
setdiff(all_tables_in_db, manifest$Table)
```

    ## character(0)

## Missing documentation

For some reason, many tables in the current metadata do not have a URL.

``` r
table_metadata <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")
subset(table_metadata, !startsWith(DocFile, "https"))[-1]
```

    ##      TableName BeginYear EndYear  DataGroup UseConstraints DocFile DataFile
    ## 26      APOB_E      2007    2008 Laboratory           None                 
    ## 27      APOB_G      2011    2012 Laboratory           None                 
    ## 82     L11_2_B      2001    2002 Laboratory           None                 
    ## 86      PBCD_D      2005    2006 Laboratory           None                 
    ## 87      PBCD_E      2007    2008 Laboratory           None                 
    ## 88      PBCD_F      2009    2010 Laboratory           None                 
    ## 112      L13_B      2001    2002 Laboratory           None                 
    ## 113      L13_C      2003    2004 Laboratory           None                 
    ## 255    L39_2_B      2001    2002 Laboratory           None                 
    ## 301   L02HPA_A      1999    2000 Laboratory           None                 
    ## 309      LAB02      1999    2000 Laboratory           None                 
    ## 329      L09_B      2001    2002 Laboratory           None                 
    ## 330      L09_C      2003    2004 Laboratory           None                 
    ## 412      IHG_D      2005    2006 Laboratory           None                 
    ## 574   L11P_2_B      2001    2002 Laboratory           None                 
    ## 719     APOB_F      2009    2010 Laboratory           None                 
    ## 720     APOB_H      2013    2014 Laboratory           None                 
    ## 753      L34_B      2001    2002 Laboratory           None                 
    ## 754      L34_C      2003    2004 Laboratory           None                 
    ## 787     PBCD_G      2011    2012 Laboratory           None                 
    ## 809      LAB13      1999    2000 Laboratory           None                 
    ## 810    L13_2_B      2001    2002 Laboratory           None                 
    ## 819    L25_2_B      2001    2002 Laboratory           None                 
    ## 1031     LAB09      1999    2000 Laboratory           None                 
    ## 1104     IHG_E      2007    2008 Laboratory           None                 
    ## 1105     IHG_F      2009    2010 Laboratory           None                 
    ## 1111   IHGEM_G      2011    2012 Laboratory           None                 
    ## 1179   L26PP_B      2001    2002 Laboratory           None                 
    ##      DatePublished
    ## 26                
    ## 27                
    ## 82                
    ## 86                
    ## 87                
    ## 88                
    ## 112               
    ## 113               
    ## 255               
    ## 301               
    ## 309               
    ## 329               
    ## 330               
    ## 412               
    ## 574               
    ## 719               
    ## 720               
    ## 753               
    ## 754               
    ## 787               
    ## 809               
    ## 810               
    ## 819               
    ## 1031              
    ## 1104              
    ## 1105              
    ## 1111              
    ## 1179

For now, we will not try to conjecture why these have failed.

Let’s check a few other things regarding the URLs:

``` r
manifest_doc_url <- with(manifest, structure(DocURL, names = Table))
manifest_data_url <- with(manifest, structure(DataURL, names = Table))
metadata_doc_url <- with(subset(table_metadata, DocFile != ""), structure(DocFile, names = TableName))
metadata_data_url <- with(subset(table_metadata, DataFile != ""), structure(DataFile, names = TableName))
```

  - If not missing, doc / data URLs in the metadata should match those
    in the manifest.

<!-- end list -->

``` r
all(metadata_doc_url == manifest_doc_url[names(metadata_doc_url)])
```

    ## [1] TRUE

``` r
all(metadata_data_url == manifest_data_url[names(metadata_data_url)])
```

    ## [1] TRUE

  - Auto-generated Doc URLs should match the ones in the manifest

<!-- end list -->

``` r
generated_urls <- sapply(names(manifest_doc_url), nhanes_url)
subset(data.frame(table = names(manifest_doc_url), 
                  generated_urls, 
                  manifest_doc_url), 
       generated_urls != manifest_doc_url)
```

    ##             table                                          generated_urls
    ## PFC_POOL PFC_POOL https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/PFC_POOL.htm
    ## SSNH4THY SSNH4THY https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/SSNH4THY.htm
    ## VID_B       VID_B    https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/VID_B.htm
    ## VID_C       VID_C    https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/VID_C.htm
    ## VID_D       VID_D    https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/VID_D.htm
    ## VID_E       VID_E    https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/VID_E.htm
    ## VID_F       VID_F    https://wwwn.cdc.gov/Nchs/Nhanes/2009-2010/VID_F.htm
    ##                                                                                   manifest_doc_url
    ## PFC_POOL                                   https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/PFC_POOL.htm
    ## SSNH4THY                                   https://wwwn.cdc.gov/Nchs/Nhanes/2001-2002/SSNH4THY.htm
    ## VID_B    https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2001&e=2002&d=VID_B&x=htm
    ## VID_C    https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2003&e=2004&d=VID_C&x=htm
    ## VID_D    https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2005&e=2006&d=VID_D&x=htm
    ## VID_E    https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2007&e=2008&d=VID_E&x=htm
    ## VID_F    https://wwwn.cdc.gov/Nchs/Nhanes/vitamind/analyticalnote.aspx?b=2009&e=2010&d=VID_F&x=htm

At the time of writing, `PFC_POOL` and `SSNH4THY` give mismatches
because they are from cycle 2 but do not have the `_B` suffix, so the
auto-generated URLs have the wrong year. These should probably be
special-cased in `nhanesA`.

The others are legitimate differences. For these tables, the master
table on the NHANES website links to a note, but the underlying URLs are
still valid.

## Translation

Do we want to (optionally) translate special codes in numeric values?

``` r
varcb <- nhanesA:::.nhanesQuery("select * from Metadata.VariableCodebook")
dim(varcb)
```

    ## [1] 177220      7

``` r
head(varcb)
```

    ##   Variable TableName CodeOrValue                      ValueDescription Count
    ## 1  DMAETHN      DEMO           1                         Value Imputed     2
    ## 2  DMAETHN      DEMO           .                               Missing  9963
    ## 3  DMARACE      DEMO           1                         Value Imputed     2
    ## 4  DMARACE      DEMO           .                               Missing  9963
    ## 5  DMDBORN      DEMO           1 Born in 50 US States or Washington DC  8069
    ## 6  DMDBORN      DEMO           2                        Born in Mexico  1146
    ##   Cumulative SkipToItem
    ## 1          2       <NA>
    ## 2       9965       <NA>
    ## 3          2       <NA>
    ## 4       9965       <NA>
    ## 5       8069       <NA>
    ## 6       9215       <NA>

First of all, is there a way to “know” that a variable is supposed to be
numeric?

``` r
(num_variables <- with(varcb, length(unique(Variable)))) # total number of variables
```

    ## [1] 12850

``` r
with(varcb, xtabs(~ ValueDescription)) |> sort(decreasing = TRUE) |> head(20)
```

    ## ValueDescription
    ##                         Missing                 Range of Values 
    ##                           48689                           28082 
    ##                      Don't know                         Refused 
    ##                           11449                           11135 
    ##                             Yes                              No 
    ##                            5875                            5863 
    ##              Cannot be assessed     Below lower detection limit 
    ##                            2539                            2306 
    ## At or above the detection limit                        Positive 
    ##                            1826                            1479 
    ##                        Negative                      Inadequate 
    ##                            1476                             842 
    ##                Could not obtain                           Other 
    ##                             815                             550 
    ##     At or above detection limit                           Blank 
    ##                             490                             442 
    ##                           Error              Value was recorded 
    ##                             442                             433 
    ##                           Never                    Questionable 
    ##                             421                             391

So hopefully the presence of `"Range of Values"` as an option for a
variable should indicate that it is a continuous variable. Let’s check
for any typos just in case:

``` r
with(varcb,
     grep("range", ValueDescription, ignore.case = TRUE, value = TRUE)
     |> table()
     |> sort(decreasing = TRUE))
```

    ## 
    ##                                                   Range of Values 
    ##                                                             28082 
    ##       Detectable result and exceeds the calibrated range of assay 
    ##                                                               273 
    ##       detectable result and exceeds the calibrated range of assay 
    ##                                                               139 
    ## Detectable result and exceeds the calibrated range of       assay 
    ##                                                                41 
    ## Detectable Result and Exceeds the Calibrated Range of       Assay 
    ##                                                                21 
    ##                                                 Other arrangement 
    ##                                                                10 
    ##                                                            Orange 
    ##                                                                 2 
    ##                                                  PALL MALL ORANGE 
    ##                                                                 2 
    ##                                                    PYRAMID ORANGE 
    ##                                                                 1

(suggests other problems, but not in what we care about), and

``` r
with(varcb,
     grep("values", ValueDescription, ignore.case = TRUE, value = TRUE)
     |> table()
     |> sort(decreasing = TRUE))
```

    ## 
    ##                                                                    Range of Values 
    ##                                                                              28082 
    ## Occurrence of contiguous adjacent identical non-zero values on the x- y- or z-axis 
    ##                                                                                  3 
    ##               Occurrence of contiguous adjacent zero values on the z- y- or z-axis 
    ##                                                                                  3 
    ## Occurrence of contiguous impossible g_values for gravity (i.e. zero g for gravity) 
    ##                                                                                  3 
    ##                            Occurrence of contiguous maximum g_values on the x-axis 
    ##                                                                                  3 
    ##                            Occurrence of contiguous maximum g_values on the y-axis 
    ##                                                                                  3 
    ##                            Occurrence of contiguous maximum g_values on the z-axis 
    ##                                                                                  3 
    ##                            Occurrence of contiguous minimum g_values on the x-axis 
    ##                                                                                  3 
    ##                            Occurrence of contiguous minimum g_values on the y-axis 
    ##                                                                                  3 
    ##                            Occurrence of contiguous minimum g_values on the z-axis 
    ##                                                                                  3 
    ##                                       Occurrence of maximum g_values on the x-axis 
    ##                                                                                  3 
    ##                                       Occurrence of maximum g_values on the y-axis 
    ##                                                                                  3 
    ##                                       Occurrence of maximum g_values on the z-axis 
    ##                                                                                  3 
    ##                                       Occurrence of minimum g_values on the x-axis 
    ##                                                                                  3 
    ##                                       Occurrence of minimum g_values on the y-axis 
    ##                                                                                  3 
    ##                                       Occurrence of minimum g_values on the z-axis 
    ##                                                                                  3

OK, so let’s now see what other values appear for these ‘numeric’
variables.

``` r
numeric_variables <- 
  unique(subset(varcb, 
                ValueDescription == "Range of Values")[["Variable"]])
length(numeric_variables)
```

    ## [1] 7018

``` r
numeric_descriptions <- 
  subset(varcb, 
         Variable %in% numeric_variables, 
         select = c(Variable, ValueDescription, CodeOrValue))
combinations <- (
  xtabs(~ ValueDescription + CodeOrValue, numeric_descriptions, 
        subset = ValueDescription != "Range of Values") 
  |> as.data.frame.table() 
  |> subset(Freq > 0)
)
dim(combinations)
```

    ## [1] 432   3

``` r
options(width = 120)
print(combinations, max = 2000)
```

    ##                                                      ValueDescription                         CodeOrValue  Freq
    ## 210                            First Fill Value of Limit of Detection                              -0.001     1
    ## 660                           Second Fill Value of Limit of Detection                              -0.004     1
    ## 890                            First Fill Value of Limit of Detection                               -0.01     2
    ## 1017                                      Value could not be computed                               -0.01    12
    ## 1230                           First Fill Value of Limit of Detection                               -0.02     1
    ## 1340                          Second Fill Value of Limit of Detection                               -0.02     1
    ## 1570                           First Fill Value of Limit of Detection                               -0.03     1
    ## 1690                           Third Fill Value of Limit of Detection                               -0.03     1
    ## 2020                          Second Fill Value of Limit of Detection                               -0.04     1
    ## 2360                          Second Fill Value of Limit of Detection                               -0.05     2
    ## 2590                           First Fill Value of Limit of Detection                               -0.07     1
    ## 2927                                 Fill Value of Limit of Detection                               -0.22     1
    ## 3380                          Second Fill Value of Limit of Detection                               -0.23     1
    ## 3401                                                                .                                   .     1
    ## 3642                                                          Missing                                   . 28414
    ## 3982                                                          Missing                           < blank >     2
    ## 4085                                                                0                                   0   174
    ## 4086                                                           0 days                                   0     3
    ## 4270                         Day 1 dietary recall not done/incomplete                                   0    24
    ## 4272                         Day 2 dietary recall not done/incomplete                                   0    24
    ## 4292                                               Hasn't started yet                                   0    10
    ## 4303                                                Less than 1 month                                   0    19
    ## 4308                                                Less than one day                                   0     1
    ## 4309                                               Less than one hour                                   0     8
    ## 4335                                                            Never                                   0    51
    ## 4339                                           Never on a daily basis                                   0    15
    ## 4340                                    Never smoked a pipe regularly                                   0     3
    ## 4342                                Never smoked cigarettes regularly                                   0    10
    ## 4343                                    Never smoked cigars regularly                                   0     3
    ## 4344                             Never used chewing tobacco regularly                                   0     3
    ## 4345                                       Never used snuff regularly                                   0     3
    ## 4346                                       No complete MEC collection                                   0     2
    ## 4347                                     No complete urine collection                                   0   289
    ## 4348                                                    No lab result                                   0     1
    ## 4349                                                    No lab Result                                   0     1
    ## 4350                                                    No Lab Result                                   0    73
    ## 4351                  No Lab Result or Not Fasting for 8 to <24 hours                                   0     3
    ## 4352                                                   No lab samples                                   0     3
    ## 4353                                                   No Lab samples                                   0     2
    ## 4354                                                  No lab specimen                                   0    37
    ## 4355                                                  No Lab Specimen                                   0    10
    ## 4356                                                  No modification                                   0    10
    ## 4359                                           No time spent outdoors                                   0    12
    ## 4361                                                   Non-Respondent                                   0    10
    ## 4362                                                             None                                   0    55
    ## 4363                             None never or rarely eat these foods                                   0     5
    ## 4364                                          Not in Replicate Sample                                   0    30
    ## 4365      Not in replicate sample or no complete urine     collection                                   0    45
    ## 4366          Not in replicate sample or no complete urine collection                                   0   210
    ## 4367                                                 Not MEC Examined                                   0     3
    ## 4368                                     Not tested in last 12 months                                   0     2
    ## 4372                      Participants 12+ years with no lab specimen                                   0     6
    ## 4373                         Participants 3+ years with no Lab Result                                   0     1
    ## 4374                       Participants 3+ years with no lab specimen                                   0     2
    ## 4375               Participants 3+ years with no surplus lab specimen                                   0     1
    ## 4376                         Participants 6+ years with no Lab Result                                   0     1
    ## 4377                       Participants 6+ years with no lab specimen                                   0    13
    ## 4378                      Participants 6+ years with no lab specimen.                                   0     1
    ## 4407                                              Still breastfeeding                                   0    10
    ## 4408                                           Still drinking formula                                   0    10
    ## 4627                                 Fill Value of Limit of Detection                              0.0025     6
    ## 4967                                 Fill Value of Limit of Detection                              0.0028     1
    ## 5307                                 Fill Value of Limit of Detection                              0.0031     1
    ## 5647                                 Fill Value of Limit of Detection                              0.0039     7
    ## 5987                                 Fill Value of Limit of Detection                               0.005     1
    ## 6327                                 Fill Value of Limit of Detection                              0.0073     1
    ## 6667                                 Fill Value of Limit of Detection                               0.009     2
    ## 6779                          Second Below Detection Limit Fill Value                               0.009     2
    ## 6971                           At or below detection limit fill value                                0.01     1
    ## 6975                                         Below Limit of Detection                                0.01     3
    ## 7009                           First Below Detection Limit Fill Value                                0.01     2
    ## 7315                                         Below Limit of Detection                               0.011     2
    ## 7347                                 Fill Value of Limit of Detection                               0.011     3
    ## 7687                                 Fill Value of Limit of Detection                               0.012     2
    ## 7995                                         Below Limit of Detection                               0.021     1
    ## 8169                                                           0.0283                              0.0283     3
    ## 8707                                 Fill Value of Limit of Detection                                0.03     1
    ## 9015                                         Below Limit of Detection                               0.035     2
    ## 9190                                                             0.04                                0.04     1
    ## 9351                           At or below detection limit fill value                                0.04     1
    ## 9355                                         Below Limit of Detection                                0.04     1
    ## 9727                                 Fill Value of Limit of Detection                              0.0497     1
    ## 10070                          First Fill Value of Limit of Detection                                0.05     1
    ## 10211                                                           0.051                               0.051     1
    ## 10747                                Fill Value of Limit of Detection                                0.06     1
    ## 11051                          At or below detection limit fill value                                0.07     1
    ## 11232                                                          0.0707                              0.0707     1
    ## 11767                                Fill Value of Limit of Detection                                0.08     1
    ## 11880                         Second Fill Value of Limit of Detection                                0.08     1
    ## 12107                                Fill Value of Limit of Detection                                0.09     1
    ## 12253                                                             0.1                                 0.1     1
    ## 12414                                  Below First Limit of Detection                                 0.1     1
    ## 12415                                        Below Limit of Detection                                 0.1     2
    ## 12447                                Fill Value of Limit of Detection                                 0.1     1
    ## 12753                                Below Detection Limit Fill Value                                0.14     2
    ## 12756                                 Below Second Limit of Detection                                0.14     1
    ## 12787                                Fill Value of Limit of Detection                                0.14     7
    ## 13127                                Fill Value of Limit of Detection                              0.1625     1
    ## 13467                                Fill Value of Limit of Detection                              0.1681     1
    ## 13614                                                            0.18                                0.18     1
    ## 13809                          First Below Detection Limit Fill Value                                0.18     2
    ## 14147                                Fill Value of Limit of Detection                               0.192     1
    ## 14455                                        Below Limit of Detection                                 0.2     3
    ## 14791                          At or below detection limit fill value                                0.21     2
    ## 14827                                Fill Value of Limit of Detection                                0.21     8
    ## 14939                         Second Below Detection Limit Fill Value                                0.21     2
    ## 15169                          First Below Detection Limit Fill Value                                0.25     3
    ## 15315                                                            0.26                                0.26     1
    ## 15959                         Second Below Detection Limit Fill Value                                0.28     3
    ## 16155                                        Below Limit of Detection                                 0.3     1
    ## 16527                                Fill Value of Limit of Detection                                0.35     1
    ## 16676                                                          0.3536                              0.3536     2
    ## 17207                                Fill Value of Limit of Detection                                0.49     2
    ## 17514                                  Below First Limit of Detection                                 0.5     1
    ## 17887                                Fill Value of Limit of Detection                                0.57     2
    ## 18195                                        Below Limit of Detection                                 0.6     1
    ## 18567                                Fill Value of Limit of Detection                                0.64     1
    ## 18876                                 Below Second Limit of Detection                                 0.7     1
    ## 19215                                        Below Limit of Detection                                0.71     1
    ## 19555                                        Below Limit of Detection                                0.89     1
    ## 19728                                                      0-6 months                                   1     2
    ## 19737                                                               1                                   1    42
    ## 19738                                             1 cigarette or less                                   1    15
    ## 19739                                                           1 day                                   1     3
    ## 19740                                                 1 month or less                                   1    12
    ## 19741                                                  1 year or less                                   1     1
    ## 19884                                    Agriculture Forestry Fishing                                   1     4
    ## 19911                                                      Day 1 only                                   1    56
    ## 19924                                                         English                                   1    56
    ## 19946                                       Less than 10 years of age                                   1     4
    ## 19956                                          Management Occupations                                   1     8
    ## 20021                                                        Positive                                   1    20
    ## 20035                                              Regular (68-72 mm)                                   1     8
    ## 20041                                                       Sensitive                                   1     4
    ## 20267                                Fill Value of Limit of Detection                                1.06     1
    ## 20573                                Below Detection Limit Fill Value                                1.25     2
    ## 20719                         Second Below Detection Limit Fill Value                                1.25     3
    ## 20949                          First Below Detection Limit Fill Value                                 1.4     3
    ## 21255                                        Below Limit of Detection                                 1.5     1
    ## 21627                                Fill Value of Limit of Detection                                 1.7     1
    ## 21784                                                              10                                  10     9
    ## 21974                   Healthcare Practitioner Technical Occupations                                  10     8
    ## 21977                                                     Information                                  10     1
    ## 21978                                            Information Services                                  10     3
    ## 22125                                                           100 +                                 100     6
    ## 22126                                                     100 or more                                 100    27
    ## 22467                                                              11                                  11     8
    ## 22468                                                      11 or more                                  11     6
    ## 22469                                                      11 or More                                  11     3
    ## 22470                                               11 pounds or more                                  11     2
    ## 22471                                               11 years or under                                  11     6
    ## 22648                                               Finance Insurance                                  11     4
    ## 22655                                  Healthcare Support Occupations                                  11     8
    ## 22812                                                              12                                  12     8
    ## 22813                                                12 hours or more                                  12     5
    ## 22814                                             12 years or younger                                  12     8
    ## 23087                                  Protective Service Occupations                                  12     8
    ## 23090                                      Real Estate Rental Leasing                                  12     4
    ## 23155                                                              13                                  13     2
    ## 23156                                                      13 or more                                  13     8
    ## 23157                                                      13 or More                                  13     2
    ## 23158                                               13 pounds or more                                  13     8
    ## 23331                            Food Preparation Serving Occupations                                  13     8
    ## 23425                      Professional Scientific Technical Services                                  13     3
    ## 23426                                 Professional Technical Services                                  13     1
    ## 23482                                                    1-14 minutes                                  14    12
    ## 23499                                                              14                                  14     1
    ## 23500                                                14 hours or more                                  14     2
    ## 23501                                               14 years or under                                  14    22
    ## 23502                                             14 years or younger                                  14     9
    ## 23638             Building & Grounds Cleaning Maintenance Occupations                                  14     8
    ## 23695                        Management Administrative Waste Services                                  14     3
    ## 23697                       ManagementBusinessCleaning/Waste Services                                  14     1
    ## 23843                                               15 drinks or more                                  15     2
    ## 24001                                              Education Services                                  15     1
    ## 24003                                            Educational Services                                  15     3
    ## 24099                               Personal Care Service Occupations                                  15     8
    ## 24184                                                              16                                  16     1
    ## 24185                                             16 years or younger                                  16    14
    ## 24353                                   Health Care Social Assistance                                  16     4
    ## 24458                                     Sales & Related Occupations                                  16     8
    ## 24526                                                              17                                  17     1
    ## 24648                                   Arts Entertainment Recreation                                  17     4
    ## 24769                       Office Administrative Support Occupations                                  17     8
    ## 24867                                                              18                                  18     3
    ## 24983                                     Accommodation Food Services                                  18     4
    ## 25026                            Farming Fishing Forestry Occupations                                  18     8
    ## 25208                                               19 years or under                                  19     6
    ## 25346                             Construction Extraction Occupations                                  19     8
    ## 25451                                                  Other Services                                  19     4
    ## 25549                                                               2                                   2    40
    ## 25550                                                          2 days                                   2     3
    ## 25626                                                     7-12 months                                   2     2
    ## 25673                                Below Detection Limit Fill Value                                   2     4
    ## 25679                       Business Financial Operations Occupations                                   2     8
    ## 25689                                                 Day 1 and day 2                                   2    56
    ## 25707                                Fill Value of Limit of Detection                                   2     1
    ## 25721                                                 King (79-88 mm)                                   2     8
    ## 25732                                               Less then 3 hours                                   2     2
    ## 25741                                                          Mining                                   2     4
    ## 25754                                                        Negative                                   2    20
    ## 25816                                                       Resistant                                   2     4
    ## 25826                                                         Spanish                                   2    56
    ## 25835                                                      Ungradable                                   2     4
    ## 25891                                                            2.12                                2.12     4
    ## 26232                                                 20 days or more                                  20     1
    ## 26233                                                      20 or more                                  20     5
    ## 26234                                                20 or more times                                  20     8
    ## 26235                                                       20 to 150                                  20     1
    ## 26236                                               20 years or older                                  20     2
    ## 26399                     Installation Maintenance Repair Occupations                                  20     8
    ## 26482                                               Private Household                                  20     3
    ## 26483                                              Private Households                                  20     1
    ## 26577                                                    2000 or more                                2000    19
    ## 26918                                                              21                                  21     1
    ## 27164                                          Production Occupations                                  21     8
    ## 27169                                           Public Administration                                  21     4
    ## 27366                                                    Armed Forces                                  22     4
    ## 27531                      Transportation Material Moving Occupations                                  22     8
    ## 27706                                                    Armed Forces                                  23     8
    ## 27939                                                              24                                  24     1
    ## 28280                                                              28                                  28     1
    ## 28621                                                              29                                  29     1
    ## 28902                                                     > 12 months                                   3     2
    ## 28962                                                               3                                   3    29
    ## 28963                                                          3 days                                   3     3
    ## 28964                                                       3 or more                                   3    17
    ## 28965                                                       3 or More                                   3    12
    ## 28966                                                3 pounds or less                                   3     2
    ## 29084                               Computer Mathematical Occupations                                   3     8
    ## 29105                                             English and Spanish                                   3    56
    ## 29116                                                      Inadequate                                   3    16
    ## 29120                                                    Intermediate                                   3     4
    ## 29134                                                Long (94-101 mm)                                   3     8
    ## 29236                                                       Utilities                                   3     4
    ## 29307                                                            3.32                                3.32     1
    ## 29648                                                             3.5                                 3.5     1
    ## 29989                                                              30                                  30     1
    ## 30166                                      More than 20 times a month                                  30     1
    ## 30330                                                              31                                  31     1
    ## 30671                                                              32                                  32     1
    ## 31112                   At work or at school 9 to 5 seven days a week                                3333     6
    ## 31133                                   Does not work or go to school                                3333     6
    ## 31352                                                              35                                  35     1
    ## 31693                                                              36                                  36     1
    ## 32034                                                              38                                  38     1
    ## 32375                                                               4                                   4    21
    ## 32376                                                          4 days                                   4     3
    ## 32377                                                       4 or more                                   4     3
    ## 32465                            Architecture Engineering Occupations                                   4     8
    ## 32473                                Below Detection Limit Fill Value                                   4     1
    ## 32485                                                    Construction                                   4     4
    ## 32578                                                       No Result                                   4     4
    ## 32590                                                           Other                                   4    56
    ## 32633                                         Ultra long (110-121 mm)                                   4     8
    ## 32815                                        Below Limit of Detection                                4.26     1
    ## 33058                                                              40                                  40     4
    ## 33059                                                      40 or more                                  40     4
    ## 33060                                                      40 or More                                  40     3
    ## 33401                                                    400 and over                                 400     1
    ## 33742                                                              42                                  42     1
    ## 34083                                                              44                                  44     1
    ## 34424                                                              45                                  45     1
    ## 34425                                               45 years or older                                  45    30
    ## 34766                                                              48                                  48     1
    ## 35107                                              480 Months or more                                 480     2
    ## 35448                                                              49                                  49     1
    ## 35707                                                      0-5 Months                                   5     1
    ## 35723                                                       1-5 Hours                                   5     1
    ## 35789                                                               5                                   5    22
    ## 35790                                                          5 days                                   5     3
    ## 35869                                                 Asian Languages                                   5    28
    ## 35933                        Life Physical Social Science Occupations                                   5     8
    ## 35938                                     Manufacturing: Durable Good                                   5     1
    ## 35939                                    Manufacturing: Durable Goods                                   5     3
    ## 36000                         PIR value greater than or equal to 5.00                                   5     4
    ## 36038                             Value greater than or equal to 5.00                                   5    12
    ## 36131                                                              50                                  50     1
    ## 36473                                                500 mg or higher                                 500     2
    ## 36814                                                              51                                  51     1
    ## 37155                                                              54                                  54     1
    ## 37496                                                              55                                  55     3
    ## 37661                                  Never smoked a whole cigarette                                  55     6
    ## 37923                                               Compliance <= 0.2                                 555    32
    ## 37984                                    More than 1 year unspecified                                 555     3
    ## 38327                                                    More than 21                                5555     2
    ## 38328                                     More than 21 meals per week                                5555     9
    ## 38329                                     More than 21 times per week                                5555     1
    ## 38338                                              Never heard of LDL                                5555     6
    ## 38608     Current HH FS benefits recipient last received date unknown                               55555     8
    ## 38663                                                 More than $1000                               55555     2
    ## 38670                                              More than 300 days                               55555     2
    ## 38857                                                              57                                  57     1
    ## 39198                                                              58                                  58     2
    ## 39539                                                              59                                  59     2
    ## 39880                                                               6                                   6    18
    ## 39881                                                          6 days                                   6     3
    ## 39882                                                 6 times or more                                   6     8
    ## 39883                                                 6 years or less                                   6     7
    ## 39884                                                6 years or under                                   6     5
    ## 39950                                     Asian Languages and English                                   6    28
    ## 39955                                        Below Limit of Detection                                   6     1
    ## 39962                           Community Social Services Occupations                                   6     8
    ## 40020                                Manufacturing: Non-Durable Goods                                   6     4
    ## 40291                          At or below detection limit fill value                                6.36     1
    ## 40565                                                              60                                  60     2
    ## 40566                                              60 minutes or more                                  60     2
    ## 40568                                               60 years or older                                  60     6
    ## 40909                                              600 Months or more                                 600     2
    ## 41250                                                              61                                  61     1
    ## 41591                                                              62                                  62     2
    ## 41932                                                              63                                  63     1
    ## 42273                                                              64                                  64     1
    ## 42614                                                              65                                  65     3
    ## 42955                                                            6575                                6575     1
    ## 43296                                                              66                                  66     1
    ## 43627                                               60 or more months                                 666     1
    ## 43743                                               Less than 1 month                                 666     7
    ## 43744                                                Less than 1 year                                 666     8
    ## 43750                                              Less than one year                                 666     3
    ## 43777                                         Never heard of A1C test                                 666     2
    ## 43797                                                     No response                                 666   288
    ## 43844                                            Single person family                                 666     2
    ## 43854                                   Unable to do activity (blind)                                 666     3
    ## 44091                                                Less than weekly                                6666     4
    ## 44113                                   More than 90 times in 30 days                                6666     4
    ## 44116                                      Never had cholesterol test                                6666     6
    ## 44168                                   Provider did not specify goal                                6666    18
    ## 44292                                                50 years or more                               66666     3
    ## 44427                                               Less than monthly                               66666     2
    ## 44480 Non-current HH FS benefits recipient last received date unknown                               66666     8
    ## 44522                                                     Since birth                               66666    68
    ## 44523                                                     Since Birth                               66666     4
    ## 44785                                More than 1095 days (3-year) old                              666666     6
    ## 44791                                 More than 365 days (1-year) old                              666666     2
    ## 44792                                 More than 730 days (2-year) old                              666666     2
    ## 45078                                Don't know what is 'whole grain'                            66666666     2
    ## 45337                                                              67                                  67     2
    ## 45678                                                              68                                  68     1
    ## 46019                                                              69                                  69     1
    ## 46360                                                               7                                   7     9
    ## 46361                                                          7 days                                   7     3
    ## 46362                                                       7 or more                                   7    11
    ## 46363                                  7 or more people in the Family                                   7     7
    ## 46364                               7 or more people in the Household                                   7    10
    ## 46365                                                 7 years or less                                   7     1
    ## 46447                                Fill Value of Limit of Detection                                   7     2
    ## 46462                                               Legal Occupations                                   7     8
    ## 46553                                                         Refused                                   7    69
    ## 46580                                                 Wholesale Trade                                   7     4
    ## 46787                                Fill Value of Limit of Detection                                 7.1     1
    ## 47047                                                              70                                  70     3
    ## 47048                                                      70 or more                                  70    10
    ## 47049                                                       70 to 150                                  70     2
    ## 47390                                                              71                                  71     1
    ## 47731                                                              72                                  72     1
    ## 48072                                                              73                                  73     2
    ## 48413                                                              75                                  75     2
    ## 48754                                                              76                                  76     1
    ## 49095                                                              77                                  77     1
    ## 49271                                                          Refuse                                  77    30
    ## 49273                                                         Refused                                  77   557
    ## 49274                                                         REFUSED                                  77    15
    ## 49285                                                      SP refused                                  77    11
    ## 49611                                                          Refuse                                 777    24
    ## 49613                                                         Refused                                 777   666
    ## 49614                                                         REFUSED                                 777     2
    ## 49951                                                          Refuse                                7777     9
    ## 49953                                                         Refused                                7777   479
    ## 50293                                                         Refused                               77777  1140
    ## 50633                                                         Refused                              777777    96
    ## 50973                                                         Refused                             7777777    10
    ## 51312                                                         refused                            77777777     2
    ## 51313                                                         Refused                            77777777    10
    ## 51476                                                              78                                  78     1
    ## 51817                                                              79                                  79     1
    ## 52158                                                               8                                   8     9
    ## 52207                                                Could not obtain                                   8     5
    ## 52222                          Education Training Library Occupations                                   8     8
    ## 52227                                Fill Value of Limit of Detection                                   8     1
    ## 52337                                                    Retail Trade                                   8     4
    ## 52499                                                             8.9                                 8.9     2
    ## 52703                                              >= 80 years of age                                  80     7
    ## 52840                                                              80                                  80     1
    ## 52841                                                80 Hours or more                                  80     2
    ## 52842                                             80 or greater years                                  80     1
    ## 52843                                                     80 or older                                  80    78
    ## 52844                                        80 years of age and over                                  80     7
    ## 52845                                               80 years or older                                  80   252
    ## 52846                                                      80or older                                  80     2
    ## 53187                                                              81                                  81     1
    ## 53528                                                              82                                  82     1
    ## 53869                                                   8400 and over                                8400    10
    ## 54064                                              >= 85 years of age                                  85     8
    ## 54211                                             85 or greater years                                  85     2
    ## 54212                                                     85 or older                                  85    56
    ## 54213                                               85 years or older                                  85   171
    ## 54550                                                   85 or greater                       85 or greater     1
    ## 54927                                                Could not obtain                                  88   115
    ## 55267                                                Could not obtain                                 888   410
    ## 55574                                                               9                                   9     9
    ## 55575                                                      9 or fewer                                   9     1
    ## 55576                                                    9 or younger                                   9     1
    ## 55577                                              9 years or younger                                   9    29
    ## 55587              Arts Design Entertainment Sports Media Occupations                                   9     8
    ## 55615                                                      Don't know                                   9    69
    ## 55645                                                    Less than 10                                   9     3
    ## 55752                                      Transportation Warehousing                                   9     4
    ## 55918                                                             9.8                                 9.8     2
    ## 56259                                                              90                                  90     1
    ## 56600                                                           900 +                                 900    27
    ## 56941                                           95 cigarettes or more                                  95    21
    ## 56942                                                      95 or more                                  95     3
    ## 57449                                      Text present but uncodable                                  98     6
    ## 57637                                            Blank but applicable                                  99     6
    ## 57640                                Calculation cannot be determined                                  99   168
    ## 57641                                              Cannot be assessed                                  99  2017
    ## 57654                                                     Don't  Know                                  99     3
    ## 57655                                                      Don't know                                  99   592
    ## 57657                                                      DON'T KNOW                                  99    18
    ## 57995                                                      Don't know                                 999   636
    ## 57996                                                      Don't Know                                 999     2
    ## 57997                                                      DON'T KNOW                                 999     2
    ## 58335                                                      Don't know                                9999   463
    ## 58336                                                      Don't Know                                9999    12
    ## 58339                                             Don't know/not sure                                9999     7
    ## 58340                                                       Dont Know                                9999     6
    ## 58675                                                      Don't know                               99999  1140
    ## 59015                                                      Don't know                              999999    96
    ## 59355                                                      Don't know                             9999999    10
    ## 59695                                                      Don't know                            99999999    12
    ## 60179                                              Value was recorded Age at diagnosis of prostate cancer     1

OK, so why is “English and Spanish” included here?

``` r
which_vars <- 
  unique(subset(numeric_descriptions, 
                ValueDescription == "English and Spanish")$Variable)
subset(varcb, Variable %in% which_vars & 
         ValueDescription == "Range of Values")
```

    ##        Variable TableName CodeOrValue ValueDescription Count Cumulative SkipToItem
    ## 101987  DR1LANG  DS1IDS_G      5 to 6  Range of Values    78         78       <NA>
    ## 102248  DR1LANG  DS1TOT_G      5 to 6  Range of Values   112        112       <NA>
    ## 102393  DR2LANG  DS2TOT_G      5 to 6  Range of Values    98         98       <NA>

These seem to be bugs in the NHANES data.

``` r
nhanes("DS1IDS_G")$DR1LANG |> table()
```

    ## 
    ##    1    2    3    4    5    6 
    ## 4988  248   38   18   35   43

For comparison,

``` r
nhanes("DS1IDS_E")$DR1LANG |> table()
```

    ## 
    ##             English English and Spanish               Other             Spanish 
    ##                5250                  59                   9                 405

Can’t see an easy way to automate this.

But in general, for numeric variables, there seem to be mainly two types
of records we need to worry about:

  - Missing values with a specific reason for being missing

  - Left or right censored values (less than or greater than something)

Also, 0 codes are somewhat tricky.
