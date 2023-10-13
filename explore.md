Initial Data Exploration of the `nhanesA` Package
================
Deepayan Sarkar

# Summary of available tables

Data in the `nhanesA` package are stored in a SQL Server database. The
database can be queried using the (unexported) `.nhanesQuery()` function
or its public wrapper `phonto::nhanesQuery()`.

``` r
library(nhanesA)
alltables <- nhanesA:::.nhanesQuery("select * from information_schema.tables;")
dim(alltables)
#> [1] 2965    4
head(alltables) |> kable() |> kable_minimal()
```

<table class=" lightable-minimal" style='font-family: "Trebuchet MS", verdana, sans-serif; margin-left: auto; margin-right: auto;'>

<thead>

<tr>

<th style="text-align:left;">

TABLE\_CATALOG

</th>

<th style="text-align:left;">

TABLE\_SCHEMA

</th>

<th style="text-align:left;">

TABLE\_NAME

</th>

<th style="text-align:left;">

TABLE\_TYPE

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Raw

</td>

<td style="text-align:left;">

LAB03

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Raw

</td>

<td style="text-align:left;">

BFRPOL\_I

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Raw

</td>

<td style="text-align:left;">

TCHOL\_J

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Raw

</td>

<td style="text-align:left;">

IHG\_E

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Raw

</td>

<td style="text-align:left;">

SMQMEC

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Raw

</td>

<td style="text-align:left;">

GHB\_E

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

</tbody>

</table>

There are two versions of each table, the raw table with original codes,
and translated versions with codes translated into human-readable
values. In addition, there are some metadata and ontology tables.

``` r
subset(alltables, !(TABLE_SCHEMA %in% c("Raw", "Translated"))) |> 
  kable() |> kable_minimal()
```

<table class=" lightable-minimal" style='font-family: "Trebuchet MS", verdana, sans-serif; margin-left: auto; margin-right: auto;'>

<thead>

<tr>

<th style="text-align:left;">

</th>

<th style="text-align:left;">

TABLE\_CATALOG

</th>

<th style="text-align:left;">

TABLE\_SCHEMA

</th>

<th style="text-align:left;">

TABLE\_NAME

</th>

<th style="text-align:left;">

TABLE\_TYPE

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

2955

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Metadata

</td>

<td style="text-align:left;">

QuestionnaireVariables

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2956

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Metadata

</td>

<td style="text-align:left;">

DownloadErrors

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2957

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Metadata

</td>

<td style="text-align:left;">

VariableCodebook

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2958

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Metadata

</td>

<td style="text-align:left;">

ExcludedTables

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2959

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Metadata

</td>

<td style="text-align:left;">

QuestionnaireDescriptions

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2960

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Ontology

</td>

<td style="text-align:left;">

dbxrefs

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2961

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Ontology

</td>

<td style="text-align:left;">

edges

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2962

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Ontology

</td>

<td style="text-align:left;">

entailed\_edges

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2963

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Ontology

</td>

<td style="text-align:left;">

labels

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2964

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Ontology

</td>

<td style="text-align:left;">

synonyms

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

<tr>

<td style="text-align:left;">

2965

</td>

<td style="text-align:left;">

NhanesLandingZone

</td>

<td style="text-align:left;">

Ontology

</td>

<td style="text-align:left;">

nhanes\_variables\_mappings

</td>

<td style="text-align:left;">

BASE TABLE

</td>

</tr>

</tbody>

</table>

The translated table names can be extracted as follows.

``` r
trtables <- subset(alltables, TABLE_SCHEMA == "Translated")$TABLE_NAME |> sort()
str(trtables)
#>  chr [1:1477] "AA_H" "AAS_H" "ACQ" "ACQ_B" "ACQ_C" "ACQ_D" "ACQ_E" "ACQ_F" "ACQ_G" "ACQ_H" ...
```

Many of these start with `P_`; we will skip them (they represent
releases made during the pandemic, and are inconsistent with previous
releases). The remaining tables often have suffixes (separated by
underscore) that indicate cycle, but may also have underscores in the
main table name.

``` r
std_tables <- trtables[!grepl("^P_", trtables)]
std_tables_split <- strsplit(std_tables, "_", fixed = TRUE)
std_tables[ sapply(std_tables_split, length) == 3 ]
#>  [1] "AL_IGE_D" "ALB_CR_D" "ALB_CR_E" "ALB_CR_F" "ALB_CR_G" "ALB_CR_H" "ALB_CR_I" "ALB_CR_J"
#>  [9] "DXX_2_B"  "HEPB_S_D" "HEPB_S_E" "HEPB_S_F" "HEPB_S_G" "HEPB_S_H" "HEPB_S_I" "HEPB_S_J"
#> [17] "KIQ_P_B"  "KIQ_P_C"  "KIQ_P_D"  "KIQ_P_E"  "KIQ_U_B"  "KIQ_U_C"  "KIQ_U_D"  "KIQ_U_E" 
#> [25] "KIQ_U_F"  "KIQ_U_G"  "KIQ_U_H"  "KIQ_U_I"  "KIQ_U_J"  "L06_2_B"  "L10_2_B"  "L11_2_B" 
#> [33] "L11P_2_B" "L13_2_B"  "L16_2_B"  "L19_2_B"  "L25_2_B"  "L39_2_B"  "L40_2_B"  "RXQ_RX_B"
#> [41] "RXQ_RX_C" "RXQ_RX_D" "RXQ_RX_E" "RXQ_RX_F" "RXQ_RX_G" "RXQ_RX_H" "RXQ_RX_I" "RXQ_RX_J"
#> [49] "VIT_2_B"  "VIT_B6_D" "VIT_B6_E" "VIT_B6_F"
```

We will assume that suffixes `_A`, `_B`, …, `_J` indicate cycles. Then
valid table names are

``` r
drop_table_suffix(std_tables) |> table() |> sort(decreasing = TRUE) |> head(100)
#> 
#>    ACQ    ALQ    BMX    BPQ    BPX    CDQ    DBQ   DEMO    DIQ    DUQ    ECQ    FSQ    HIQ    HOQ 
#>     10     10     10     10     10     10     10     10     10     10     10     10     10     10 
#>    HSQ    HUQ    IMQ    MCQ    OCQ    OHQ    PAQ    PFQ    RHQ RXQ_RX    SMQ SMQFAM    WHQ    AUQ 
#>     10     10     10     10     10     10     10     10     10     10     10     10     10      9 
#>  AUXAR AUXTYM    DEQ  KIQ_U    SXQ    AUX DR1IFF DR1TOT DR2IFF DR2TOT DRXFCD OHXREF    OSQ ALB_CR 
#>      9      9      9      9      9      8      8      8      8      8      8      8      8      7 
#> BIOPRO    CBC    DPQ FASTQX FOLATE    GHB    GLU    HDL   HEPA HEPB_S  HEPBD   HEPC    HIV OHXDEN 
#>      7      7      7      7      7      7      7      7      7      7      7      7      7      7 
#>   PBCD  PERNT PHTHTE PUQMEC    RDQ    SLQ SMQRTU  TCHOL TRIGLY    UAS UCPREG    UHG    UIO  VOCWB 
#>      7      7      7      7      7      7      7      7      7      7      7      7      7      7 
#> WHQMEC BFRPOL    CBQ DS1IDS DS1TOT DS2IDS DS2TOT DSQIDS DSQTOT  DXXAG    HCQ HPVSWR    HSV    INQ 
#>      7      6      6      6      6      6      6      6      6      6      6      6      6      6 
#>   OGTT    PAH PCBPOL POOLTF PSTPOL   APOB   DEET DRXMCD DXXFEM DXXSPN FERTIN FOLFMS   HEPE    OPD 
#>      6      6      6      6      6      5      5      5      5      5      5      5      5      5 
#>   SSKL    SSQ 
#>      5      5
```

Some appear only once or twice. These are probably introduced later, and
were not necessarily continued; for example, the following two tables
relate to air quality.

``` r
std_tables[startsWith(std_tables, "AQQ")]
#> [1] "AQQ_E" "AQQ_F"
nhanesCodebook('AQQ_E') |> lapply("[[", "SAS Label:") |> str()
#> List of 14
#>  $ SEQN   : chr "Respondent sequence number"
#>  $ PAQ685 : chr "Bad air quality change activities"
#>  $ PAQ690A: chr "Wore a mask"
#>  $ PAQ690B: chr "Spent less time outdoors"
#>  $ PAQ690C: chr "Avoided roads that have heavy traffic"
#>  $ PAQ690D: chr "Did less strenuous activities"
#>  $ PAQ690E: chr "Took medication"
#>  $ PAQ690F: chr "Closed windows of your house"
#>  $ PAQ690G: chr "Drove my car less"
#>  $ PAQ690H: chr "Canceled outdoor activities"
#>  $ PAQ690I: chr "Exercised indoors instead of outdoors"
#>  $ PAQ690J: chr "Used buses trains or subways"
#>  $ PAQ690K: chr "Use or change air filter/air cleaner"
#>  $ PAQ690O: chr "Other"
```

# Using metadata tables to obtain table information

Alternatively, we can get information about available tables from the
metadata tables, although for some reason, these do not include the
`P_*` tables.

``` r
tableDesc <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")
tableDesc <- within(tableDesc, TableBase <- drop_table_suffix(TableName))
str(tableDesc)
#> 'data.frame':    1348 obs. of  10 variables:
#>  $ Description   : chr  "Acculturation" "Acculturation" "Acculturation" "Acculturation" ...
#>  $ TableName     : chr  "ACQ" "ACQ_D" "ACQ_E" "ACQ_F" ...
#>  $ BeginYear     : int  1999 2005 2007 2009 2011 2013 2015 2017 2005 2013 ...
#>  $ EndYear       : int  2000 2006 2008 2010 2012 2014 2016 2018 2006 2014 ...
#>  $ DataGroup     : chr  "Questionnaire" "Questionnaire" "Questionnaire" "Questionnaire" ...
#>  $ UseConstraints: chr  "None" "None" "None" "None" ...
#>  $ DocFile       : chr  "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/ACQ.htm" "https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/ACQ_D.htm" "https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/ACQ_E.htm" "https://wwwn.cdc.gov/Nchs/Nhanes/2009-2010/ACQ_F.htm" ...
#>  $ DataFile      : chr  "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/ACQ.XPT" "https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/ACQ_D.XPT" "https://wwwn.cdc.gov/Nchs/Nhanes/2007-2008/ACQ_E.XPT" "https://wwwn.cdc.gov/Nchs/Nhanes/2009-2010/ACQ_F.XPT" ...
#>  $ DatePublished : chr  "June 2002" "March 2008" "September 2009" "August 2012" ...
#>  $ TableBase     : chr  "ACQ" "ACQ" "ACQ" "ACQ" ...
```

We will work with this from now on. We can summarize this table by table
/ questionnaire descriptions as follows.

``` r
tableSummary <- 
  xtabs(~ TableBase + Description + DataGroup, tableDesc) |> 
  as.data.frame.table() |> subset(Freq > 0)
head(tableSummary, 20) |> kable() # use datatable() for html_output
```

<table>

<thead>

<tr>

<th style="text-align:left;">

</th>

<th style="text-align:left;">

TableBase

</th>

<th style="text-align:left;">

Description

</th>

<th style="text-align:left;">

DataGroup

</th>

<th style="text-align:right;">

Freq

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

42234

</td>

<td style="text-align:left;">

DEMO

</td>

<td style="text-align:left;">

Demographic Variables & Sample Weights

</td>

<td style="text-align:left;">

Demographics

</td>

<td style="text-align:right;">

7

</td>

</tr>

<tr>

<td style="text-align:left;">

42660

</td>

<td style="text-align:left;">

DEMO

</td>

<td style="text-align:left;">

Demographic Variables and Sample Weights

</td>

<td style="text-align:left;">

Demographics

</td>

<td style="text-align:right;">

3

</td>

</tr>

<tr>

<td style="text-align:left;">

225000

</td>

<td style="text-align:left;">

DRXIFF

</td>

<td style="text-align:left;">

Dietary Interview - Individual Foods

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

225421

</td>

<td style="text-align:left;">

DR1IFF

</td>

<td style="text-align:left;">

Dietary Interview - Individual Foods, First Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

225849

</td>

<td style="text-align:left;">

DR2IFF

</td>

<td style="text-align:left;">

Dietary Interview - Individual Foods, Second Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

226280

</td>

<td style="text-align:left;">

DRXTOT

</td>

<td style="text-align:left;">

Dietary Interview - Total Nutrient Intakes

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

226700

</td>

<td style="text-align:left;">

DR1TOT

</td>

<td style="text-align:left;">

Dietary Interview - Total Nutrient Intakes, First Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

227128

</td>

<td style="text-align:left;">

DR2TOT

</td>

<td style="text-align:left;">

Dietary Interview - Total Nutrient Intakes, Second Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

227555

</td>

<td style="text-align:left;">

DRXFCD

</td>

<td style="text-align:left;">

Dietary Interview Technical Support File - Food Codes

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

6

</td>

</tr>

<tr>

<td style="text-align:left;">

227983

</td>

<td style="text-align:left;">

DRXMCD

</td>

<td style="text-align:left;">

Dietary Interview Technical Support File - Modification Codes

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

5

</td>

</tr>

<tr>

<td style="text-align:left;">

228421

</td>

<td style="text-align:left;">

DTQ

</td>

<td style="text-align:left;">

Dietary Screener Questionnaire

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

228837

</td>

<td style="text-align:left;">

DS1IDS

</td>

<td style="text-align:left;">

Dietary Supplement Use 24-Hour - Individual Dietary Supplements, First
Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

6

</td>

</tr>

<tr>

<td style="text-align:left;">

229265

</td>

<td style="text-align:left;">

DS2IDS

</td>

<td style="text-align:left;">

Dietary Supplement Use 24-Hour - Individual Dietary Supplements, Second
Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

6

</td>

</tr>

<tr>

<td style="text-align:left;">

229690

</td>

<td style="text-align:left;">

DS1TOT

</td>

<td style="text-align:left;">

Dietary Supplement Use 24-Hour - Total Dietary Supplements, First Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

6

</td>

</tr>

<tr>

<td style="text-align:left;">

230118

</td>

<td style="text-align:left;">

DS2TOT

</td>

<td style="text-align:left;">

Dietary Supplement Use 24-Hour - Total Dietary Supplements, Second Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

6

</td>

</tr>

<tr>

<td style="text-align:left;">

230549

</td>

<td style="text-align:left;">

DSQIDS

</td>

<td style="text-align:left;">

Dietary Supplement Use 30 Day - Individual Dietary Supplements

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

3

</td>

</tr>

<tr>

<td style="text-align:left;">

230971

</td>

<td style="text-align:left;">

DSQ1

</td>

<td style="text-align:left;">

Dietary Supplement Use 30-Day - File 1, Supplement Counts

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

3

</td>

</tr>

<tr>

<td style="text-align:left;">

230973

</td>

<td style="text-align:left;">

DSQFILE1

</td>

<td style="text-align:left;">

Dietary Supplement Use 30-Day - File 1, Supplement Counts

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

231398

</td>

<td style="text-align:left;">

DSQ2

</td>

<td style="text-align:left;">

Dietary Supplement Use 30-Day - File 2, Participant’s Use of Supplements

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

3

</td>

</tr>

<tr>

<td style="text-align:left;">

231400

</td>

<td style="text-align:left;">

DSQFILE2

</td>

<td style="text-align:left;">

Dietary Supplement Use 30-Day - File 2, Participant’s Use of Supplements

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

1

</td>

</tr>

</tbody>

</table>

# Extracting table data

Before trying to analyse any data, we may be interested in knowing
whether the codebook has changed for a particular table across different
cycles. Let’s try this with the demographic tables.

``` r
demotables <- get_table_names('DEMO', db = tableDesc)
cb.demo <- lapply(demotables, function(x) names(nhanesCodebook(x)))
str(cb.demo)
#> List of 10
#>  $ : chr [1:145] "SEQN" "SDDSRVYR" "RIDSTATR" "RIDEXMON" ...
#>  $ : chr [1:37] "SEQN" "SDDSRVYR" "RIDSTATR" "RIDEXMON" ...
#>  $ : chr [1:44] "SEQN" "SDDSRVYR" "RIDSTATR" "RIDEXMON" ...
#>  $ : chr [1:43] "SEQN" "SDDSRVYR" "RIDSTATR" "RIDEXMON" ...
#>  $ : chr [1:43] "SEQN" "SDDSRVYR" "RIDSTATR" "RIDEXMON" ...
#>  $ : chr [1:43] "SEQN" "SDDSRVYR" "RIDSTATR" "RIDEXMON" ...
#>  $ : chr [1:48] "SEQN" "SDDSRVYR" "RIDSTATR" "RIAGENDR" ...
#>  $ : chr [1:47] "SEQN" "SDDSRVYR" "RIDSTATR" "RIAGENDR" ...
#>  $ : chr [1:47] "SEQN" "SDDSRVYR" "RIDSTATR" "RIAGENDR" ...
#>  $ : chr [1:46] "SEQN" "SDDSRVYR" "RIDSTATR" "RIAGENDR" ...
```

So the number of recorded variables keep changing. To combine across
years, we will get all common variables, assuming that their
interpretations have not changed over cycles.

``` r
demovars <- get_common_vars(demotables)
str(demovars)
#>  chr [1:21] "SEQN" "SDDSRVYR" "RIDSTATR" "RIDEXMON" "RIAGENDR" "RIDAGEYR" "RIDAGEMN" "RIDRETH1" ...
```

We can then merge all versions of a table by restricting to these common
variables.

``` r
demo.all <- merge_tables(demotables)
```

Some elementary summaries of the demographic variables:

``` r
qqmath(~ RIDAGEYR | SDDSRVYR, demo.all, plot.points = FALSE, distribution = qexp,
       f.value = ppoints(500), pch = ".", cex = 2, as.table = TRUE, grid = TRUE)
```

<img src="figures/age_dist_yr-1.svg" width="100%" />

``` r
xtabs(~ SDDSRVYR + RIAGENDR + RIDRETH1, demo.all) |> 
  dotplot(auto.key = list(columns = 2), type = "o", 
          par.settings = simpleTheme(pch = 16))
```

<img src="figures/race_dist_yr-1.svg" width="100%" />

# Combining tables for analysis

Suppose we want to combine demographic data with data from one or more
other tables to perform some analysis. Let’s start by looking at which
tables have been populated in most (at least 8) cycles. The `DEMO` table
will not appear in this list because it has two slightly different
descriptions (with frequencies 7 and 3).

``` r
subset(tableSummary, Freq > 7) |> kable() |> kable_minimal()
```

<table class=" lightable-minimal" style='font-family: "Trebuchet MS", verdana, sans-serif; margin-left: auto; margin-right: auto;'>

<thead>

<tr>

<th style="text-align:left;">

</th>

<th style="text-align:left;">

TableBase

</th>

<th style="text-align:left;">

Description

</th>

<th style="text-align:left;">

DataGroup

</th>

<th style="text-align:right;">

Freq

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

225421

</td>

<td style="text-align:left;">

DR1IFF

</td>

<td style="text-align:left;">

Dietary Interview - Individual Foods, First Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

225849

</td>

<td style="text-align:left;">

DR2IFF

</td>

<td style="text-align:left;">

Dietary Interview - Individual Foods, Second Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

226700

</td>

<td style="text-align:left;">

DR1TOT

</td>

<td style="text-align:left;">

Dietary Interview - Total Nutrient Intakes, First Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

227128

</td>

<td style="text-align:left;">

DR2TOT

</td>

<td style="text-align:left;">

Dietary Interview - Total Nutrient Intakes, Second Day

</td>

<td style="text-align:left;">

Dietary

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

373621

</td>

<td style="text-align:left;">

AUX

</td>

<td style="text-align:left;">

Audiometry

</td>

<td style="text-align:left;">

Examination

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

374049

</td>

<td style="text-align:left;">

AUXAR

</td>

<td style="text-align:left;">

Audiometry - Acoustic Reflex

</td>

<td style="text-align:left;">

Examination

</td>

<td style="text-align:right;">

9

</td>

</tr>

<tr>

<td style="text-align:left;">

374476

</td>

<td style="text-align:left;">

AUXTYM

</td>

<td style="text-align:left;">

Audiometry - Tympanometry

</td>

<td style="text-align:left;">

Examination

</td>

<td style="text-align:right;">

9

</td>

</tr>

<tr>

<td style="text-align:left;">

377895

</td>

<td style="text-align:left;">

BPX

</td>

<td style="text-align:left;">

Blood Pressure

</td>

<td style="text-align:left;">

Examination

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

379171

</td>

<td style="text-align:left;">

BMX

</td>

<td style="text-align:left;">

Body Measures

</td>

<td style="text-align:left;">

Examination

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

483784

</td>

<td style="text-align:left;">

OHXREF

</td>

<td style="text-align:left;">

Oral Health - Recommendation of Care

</td>

<td style="text-align:left;">

Examination

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

722499

</td>

<td style="text-align:left;">

ACQ

</td>

<td style="text-align:left;">

Acculturation

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

725062

</td>

<td style="text-align:left;">

ALQ

</td>

<td style="text-align:left;">

Alcohol Use

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

734868

</td>

<td style="text-align:left;">

AUQ

</td>

<td style="text-align:left;">

Audiometry

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

9

</td>

</tr>

<tr>

<td style="text-align:left;">

739994

</td>

<td style="text-align:left;">

BPQ

</td>

<td style="text-align:left;">

Blood Pressure & Cholesterol

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

747671

</td>

<td style="text-align:left;">

CDQ

</td>

<td style="text-align:left;">

Cardiovascular Health

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

761414

</td>

<td style="text-align:left;">

HSQ

</td>

<td style="text-align:left;">

Current Health Status

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

765583

</td>

<td style="text-align:left;">

DEQ

</td>

<td style="text-align:left;">

Dermatology

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

9

</td>

</tr>

<tr>

<td style="text-align:left;">

766011

</td>

<td style="text-align:left;">

DIQ

</td>

<td style="text-align:left;">

Diabetes

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

766432

</td>

<td style="text-align:left;">

DBQ

</td>

<td style="text-align:left;">

Diet Behavior & Nutrition

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

775406

</td>

<td style="text-align:left;">

DUQ

</td>

<td style="text-align:left;">

Drug Use

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

786078

</td>

<td style="text-align:left;">

ECQ

</td>

<td style="text-align:left;">

Early Childhood

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

798879

</td>

<td style="text-align:left;">

FSQ

</td>

<td style="text-align:left;">

Food Security

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

801875

</td>

<td style="text-align:left;">

HIQ

</td>

<td style="text-align:left;">

Health Insurance

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

813388

</td>

<td style="text-align:left;">

HUQ

</td>

<td style="text-align:left;">

Hospital Utilization & Access to Care

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

813805

</td>

<td style="text-align:left;">

HOQ

</td>

<td style="text-align:left;">

Housing Characteristics

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

820207

</td>

<td style="text-align:left;">

IMQ

</td>

<td style="text-align:left;">

Immunization

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

823194

</td>

<td style="text-align:left;">

KIQ\_U

</td>

<td style="text-align:left;">

Kidney Conditions - Urology

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

9

</td>

</tr>

<tr>

<td style="text-align:left;">

828827

</td>

<td style="text-align:left;">

MCQ

</td>

<td style="text-align:left;">

Medical Conditions

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

840761

</td>

<td style="text-align:left;">

OCQ

</td>

<td style="text-align:left;">

Occupation

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

842467

</td>

<td style="text-align:left;">

OHQ

</td>

<td style="text-align:left;">

Oral Health

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

846741

</td>

<td style="text-align:left;">

OSQ

</td>

<td style="text-align:left;">

Osteoporosis

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

8

</td>

</tr>

<tr>

<td style="text-align:left;">

859523

</td>

<td style="text-align:left;">

PAQ

</td>

<td style="text-align:left;">

Physical Activity

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

862091

</td>

<td style="text-align:left;">

PFQ

</td>

<td style="text-align:left;">

Physical Functioning

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

868071

</td>

<td style="text-align:left;">

RXQ\_RX

</td>

<td style="text-align:left;">

Prescription Medications

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

872329

</td>

<td style="text-align:left;">

RHQ

</td>

<td style="text-align:left;">

Reproductive Health

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

874949

</td>

<td style="text-align:left;">

SXQ

</td>

<td style="text-align:left;">

Sexual Behavior

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

9

</td>

</tr>

<tr>

<td style="text-align:left;">

877449

</td>

<td style="text-align:left;">

SMQFAM

</td>

<td style="text-align:left;">

Smoking - Household Smokers

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

<tr>

<td style="text-align:left;">

902692

</td>

<td style="text-align:left;">

WHQ

</td>

<td style="text-align:left;">

Weight History

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

</tbody>

</table>

Let’s say we now want to combine the tables DEMO, TCHOL (Weight
history), BPX (Blood pressure) and BMX (Body measurements)

``` r
## combine tables, say DEMO, WHQ (Weight history), 
## BPX (Blood pressure) and BMX (Body measurements)

sapply(nhanesCodebook('TCHOL_D'), "[[", "SAS Label:")
sapply(nhanesCodebook('BMX'), "[[", "SAS Label:")
sapply(nhanesCodebook('BPX'), "[[", "SAS Label:")

wtables <- c("DEMO", "WHQ", "BMX", "BPX")

tablist <- lapply(wtables, function(x) merge_tables(get_table_names(x, tableDesc)))
names(tablist) <- wtables

sapply(tablist, nrow) # WHQ has fewer

## Merge by first subsetting to common SEQN values (in same order)

common_id <- Reduce(intersect, lapply(tablist, "[[", "SEQN"))
tablist_common <- lapply(tablist, function(d) d[match(common_id, d$SEQN), ])
dcombined <- Reduce(merge, tablist)

## OK, so we are ready for some anaylsis. But variable names are still 
## incomprehensible without referring to codebook

variableDesc <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireVariables")
## This one includes the P_* tables, which we will exclude (among other reasons, 
## they have not been processed correctly), e.g.,
subset(variableDesc, TableName |> startsWith("P_")) |> head()
## despite https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_ACQ.htm#ACD011A having the info

## so
variableDesc <- subset(variableDesc, !startsWith(TableName, "P_"))
str(variableDesc)

uvarDesc <- subset(variableDesc, Variable %in% names(dcombined), select = c(Variable, SasLabel)) |> unique()

## crude search (or use datatable)
subset(uvarDesc, agrepl("weight", SasLabel, ignore.case = TRUE, fixed = TRUE))

xyplot(I(WHD020 * 0.453592) ~ BMXWT, dcombined) # weird - special codes not mapped to NA

nhanesCodebook("BMX")[["BMXWT"]][["BMXWT"]] # no issues - only missing
subset(variableDesc, Variable == "WHD020")
nhanesCodebook("WHQ")[["WHD020"]][["WHD020"]] # 77777 / 99999
nhanesCodebook("WHQ_B")[["WHD020"]][["WHD020"]] # 7777 / 9999

xyplot(I(WHD020 * 0.453592) ~ BMXWT | RIAGENDR, dcombined, subset = WHD020 < 1000, 
       alpha = 0.5, abline = c(0, 1), smooth = "lm", type=c("p", "r"))

xyplot(BMXWT ~  RIDAGEYR | RIAGENDR, dcombined,
       alpha = 0.5, smooth = "lm", type=c("p", "smooth"), col.line = 1)




```

# Miscellaneous oddities

There is a mismatch for tables with base name `SSDFS` (there may be
others as well).

``` r
std_tables[startsWith(std_tables, "SSDFS")]
#> [1] "SSDFS_A" "SSDFS_G"
subset(tableDesc, startsWith(TableName, "SSDFS"))[1:5]
#>                                                    Description TableName BeginYear EndYear
#> 56 Autoantibodies - Anti-DFS70 Autoantibody Analyses (Surplus)   SSDFS_G      2011    2012
#>     DataGroup
#> 56 Laboratory
```

The `SSDFS_A` table does exist:

``` r
str(nhanes('SSDFS_A', translated = TRUE))
#> 'data.frame':    148 obs. of  5 variables:
#>  $ SEQN    : int  255 341 1227 1693 1825 2473 2484 3018 3098 3715 ...
#>  $ WTANA6YR: num  7706 55179 102257 36033 8923 ...
#>  $ SSDFSS  : num  1 1 1 1 1 1 1 1 1 1 ...
#>  $ SSDFSE  : num  3.82 35.31 53.08 47.19 121.8 ...
#>  $ SSDFSR  : num  0 1 1 1 1 0 1 1 1 0 ...
```

However, even though `SSDFS_G` is a legitimate table, there is no
<https://wwwn.cdc.gov/Nchs/Nhanes/2011-2012/SSDFS_A.htm>, and the
corresponding codebook naturally has no useful information. Where did
the `SSDFS_A` table come from?

What is the difference between `includelabels = TRUE` and `FALSE`?
Neither version seems to include the SAS labels

``` r
nhanes('DEMO_G', includelabels = FALSE) |> attributes() |> str()
#> List of 3
#>  $ names    : chr [1:48] "SEQN" "SDDSRVYR" "RIDSTATR" "RIAGENDR" ...
#>  $ class    : chr "data.frame"
#>  $ row.names: int [1:9756] 1 2 3 4 5 6 7 8 9 10 ...
nhanes('DEMO_G', includelabels = TRUE) |> attributes() |> str()
#> List of 3
#>  $ names    : chr [1:48] "SEQN" "SDDSRVYR" "RIDSTATR" "RIAGENDR" ...
#>  $ class    : chr "data.frame"
#>  $ row.names: int [1:9756] 1 2 3 4 5 6 7 8 9 10 ...
```

Consider tables whose description contains “cholesterol”.

``` r
subset(tableSummary, grepl("cholesterol", Description, ignore.case = TRUE)) |> kable()
```

<table>

<thead>

<tr>

<th style="text-align:left;">

</th>

<th style="text-align:left;">

TableBase

</th>

<th style="text-align:left;">

Description

</th>

<th style="text-align:left;">

DataGroup

</th>

<th style="text-align:right;">

Freq

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

567994

</td>

<td style="text-align:left;">

HDL

</td>

<td style="text-align:left;">

Cholesterol - HDL

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

5

</td>

</tr>

<tr>

<td style="text-align:left;">

568420

</td>

<td style="text-align:left;">

HDL

</td>

<td style="text-align:left;">

Cholesterol - High - Density Lipoprotein (HDL)

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

568846

</td>

<td style="text-align:left;">

HDL

</td>

<td style="text-align:left;">

Cholesterol - High-Density Lipoprotein (HDL)

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

569329

</td>

<td style="text-align:left;">

L13AM

</td>

<td style="text-align:left;">

Cholesterol - LDL & Triglycerides

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

569377

</td>

<td style="text-align:left;">

LAB13AM

</td>

<td style="text-align:left;">

Cholesterol - LDL & Triglycerides

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

569518

</td>

<td style="text-align:left;">

TRIGLY

</td>

<td style="text-align:left;">

Cholesterol - LDL & Triglycerides

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

4

</td>

</tr>

<tr>

<td style="text-align:left;">

569944

</td>

<td style="text-align:left;">

TRIGLY

</td>

<td style="text-align:left;">

Cholesterol - LDL, Triglyceride & Apoliprotein (ApoB)

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

570370

</td>

<td style="text-align:left;">

TRIGLY

</td>

<td style="text-align:left;">

Cholesterol - Low - Density Lipoprotein (LDL) & Triglycerides

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

570796

</td>

<td style="text-align:left;">

TRIGLY

</td>

<td style="text-align:left;">

Cholesterol - Low-Density Lipoproteins (LDL) & Triglycerides

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

571215

</td>

<td style="text-align:left;">

TCHOL

</td>

<td style="text-align:left;">

Cholesterol - Total

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

7

</td>

</tr>

<tr>

<td style="text-align:left;">

571457

</td>

<td style="text-align:left;">

L13

</td>

<td style="text-align:left;">

Cholesterol - Total & HDL

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

571506

</td>

<td style="text-align:left;">

LAB13

</td>

<td style="text-align:left;">

Cholesterol - Total & HDL

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

571884

</td>

<td style="text-align:left;">

L13\_2

</td>

<td style="text-align:left;">

Cholesterol - Total, HDL, LDL & Triglycerides, Second Exam

</td>

<td style="text-align:left;">

Laboratory

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

739994

</td>

<td style="text-align:left;">

BPQ

</td>

<td style="text-align:left;">

Blood Pressure & Cholesterol

</td>

<td style="text-align:left;">

Questionnaire

</td>

<td style="text-align:right;">

10

</td>

</tr>

</tbody>

</table>

Clearly, similar data is included in tables with different names, so our
strategy of merging by table name may be fundamentally flawed. It may be
more useful to decide on variable names of interest, and obtain all data
for those variables regardless of which table they are in.

``` r
subset(tableDesc, TableBase == "TRIGLY")[1:4]
#>                                                       Description TableName BeginYear EndYear
#> 104                             Cholesterol - LDL & Triglycerides  TRIGLY_E      2007    2008
#> 105                             Cholesterol - LDL & Triglycerides  TRIGLY_G      2011    2012
#> 106 Cholesterol - Low - Density Lipoprotein (LDL) & Triglycerides  TRIGLY_I      2015    2016
#> 803                             Cholesterol - LDL & Triglycerides  TRIGLY_F      2009    2010
#> 804                             Cholesterol - LDL & Triglycerides  TRIGLY_H      2013    2014
#> 805         Cholesterol - LDL, Triglyceride & Apoliprotein (ApoB)  TRIGLY_D      2005    2006
#> 806  Cholesterol - Low-Density Lipoproteins (LDL) & Triglycerides  TRIGLY_J      2017    2018
sapply(nhanesCodebook("TRIGLY_E"), "[[", "SAS Label:")
#>                                  SEQN                              WTSAF2YR 
#>          "Respondent sequence number" "Fasting Subsample 2 Year MEC Weight" 
#>                                 LBXTR                               LBDTRSI 
#>                "Triglyceride (mg/dL)"               "Triglyceride (mmol/L)" 
#>                                LBDLDL                              LBDLDLSI 
#>             "LDL-cholesterol (mg/dL)"            "LDL-cholesterol (mmol/L)"
```

So let’s search for the `LBDLDL` variable in all tables.

``` r
varDesc <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireVariables")
subset(varDesc, Variable == "LBDLDL")[c(1, 2, 3)] |> kable()
```

<table>

<thead>

<tr>

<th style="text-align:left;">

</th>

<th style="text-align:left;">

Variable

</th>

<th style="text-align:left;">

TableName

</th>

<th style="text-align:left;">

Description

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

27717

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

L13AM\_B

</td>

<td style="text-align:left;">

LDL-cholesterol (mg/dL)

</td>

</tr>

<tr>

<td style="text-align:left;">

27723

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

L13AM\_C

</td>

<td style="text-align:left;">

LDL-cholesterol (mg/dL)

</td>

</tr>

<tr>

<td style="text-align:left;">

29115

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

LAB13AM

</td>

<td style="text-align:left;">

LDL-cholesterol (mg/dL)

</td>

</tr>

<tr>

<td style="text-align:left;">

40307

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

P\_TRIGLY

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

47135

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

TRIGLY\_D

</td>

<td style="text-align:left;">

LDL-cholesterol (mg/dL)

</td>

</tr>

<tr>

<td style="text-align:left;">

47143

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

TRIGLY\_E

</td>

<td style="text-align:left;">

LDL-cholesterol (mg/dL)

</td>

</tr>

<tr>

<td style="text-align:left;">

47149

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

TRIGLY\_F

</td>

<td style="text-align:left;">

LDL-cholesterol (mg/dL)

</td>

</tr>

<tr>

<td style="text-align:left;">

47155

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

TRIGLY\_G

</td>

<td style="text-align:left;">

LDL-cholesterol (mg/dL)

</td>

</tr>

<tr>

<td style="text-align:left;">

47161

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

TRIGLY\_H

</td>

<td style="text-align:left;">

LDL-cholesterol (mg/dL)

</td>

</tr>

<tr>

<td style="text-align:left;">

47167

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

TRIGLY\_I

</td>

<td style="text-align:left;">

LDL-cholesterol (mg/dL)

</td>

</tr>

<tr>

<td style="text-align:left;">

47173

</td>

<td style="text-align:left;">

LBDLDL

</td>

<td style="text-align:left;">

TRIGLY\_J

</td>

<td style="text-align:left;">

LDL-Cholesterol Friedewald equation (mg/dL). LBDLDL = (LBXTC-(LBDHDD +
LBXTR/5) round to 0 decimal places) for LBXTR less than 400 mg/dL and
missing for LBXTR greater than 400 mg/dL. LBDHDD from public release
file HDL\_J

</td>

</tr>

</tbody>

</table>
