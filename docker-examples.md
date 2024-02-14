Examples of workflows enabled by docker
================

## Potential topics to include:

- Reproducibility - [Cobalt
  paper](https://ccb-hms.github.io/phonto/vignettes/cobalt_paper.html)

- Combining data across cycles

- Consistency checks:

  - Across cycles: change in units

  - Within cycles: Variables appearing in multiple tables

- Better [search
  facilities](https://ccb-hms.github.io/phonto/vignettes/search-tables.html):
  e.g., tables, variables

- Special codes in numeric variables

- Variables that are potentially skipped

## Combining data across cycles

To illustrate the process of combining data across cycles, we combine
the demographic data table from all cycles. NHANES table names typically
have a suffix; the suffixes `_A`, `_B`, `_C`,and so on generally
correspond to NHANES cycle years from 1999-2000, 2001-2002, 2003-2004,
etc. However, it is important to highlight that not every table strictly
adheres to this naming convention. For instance, while `DEMO_B` and
`DEMO_C` are associated with the 2001-2002 and 2003-2004 cycles,
respectively, the corresponding table for the 1999-2000 cycle is named
‘DEMO’, without the `_A` suffix. While this pattern holds for most
tables, certain tables such as `SSAFB_A` and `SSANA_A` from the
1999-2000 cycle do include the `_A` suffix. To assist users in
navigating these variations, the `nhanesA` package includes the
`nhanesSearchTableNames()` function, which allows users to easily locate
all table names containing a specific string, thus simplifying the
process of identifying relevant table names.

``` r
library(nhanesA)
demo_all <- nhanesSearchTableNames("DEMO")
demo_all
```

     [1] "DEMO"   "DEMO_B" "DEMO_C" "DEMO_D" "DEMO_E" "DEMO_F" "DEMO_G" "DEMO_H" "DEMO_I" "DEMO_J"
    [11] "P_DEMO"

The last table in this list merits special mention. During the 2019-2020
cycle, data collection was disrupted by the COVID-19 pandemic.
Therefore, the partial 2019-2020 data (herein 2019-March 2020 data) were
combined with data from the previous cycle (2017-2018) to create a
nationally representative sample covering 2017-March 2020. These data
files have the same basic file name, e.g., `DEMO`, but add the prefix
`P_`. These ‘pre-pandemic’ files require special handling and the CDC
has provided substantial guidance as well as updated survey weights.

We can now download all these datasets from the CDC website using the
`nhanes()` function. Note, however, that this process is likely to be
somewhat slow as several files will need to be downloaded.

``` r
all_demo_data <- sapply(demo_all, nhanes, simplify = FALSE)
object.size(all_demo_data) # ~45 MB
```

    47137304 bytes

``` r
sapply(all_demo_data, dim)
```

         DEMO DEMO_B DEMO_C DEMO_D DEMO_E DEMO_F DEMO_G DEMO_H DEMO_I DEMO_J P_DEMO
    [1,] 9965  11039  10122  10348  10149  10537   9756  10175   9971   9254  15560
    [2,]  145     37     44     43     43     43     48     47     47     46     29

The first row in the output above gives the number of participants in
each cycle, and the second row denotes the number of variables in the
corresponding `DEMO` table. We can see that each cycle has around 10,000
participants, who are unique across cycles. Note, however, that the
larger number of participants in the `P_DEMO` dataset is misleading,
because many of these participants are actually from the previous cycle
as described above. We will drop this table before combining the
remaining datasets.

The differing number of variables across cycles indicate that variables
are not measured consistently across cycles. In fact, many variables
included in the `DEMO` table in the first cycle were subsequently
included in other tables, and others have been dropped altogether or
added. We can make a list of the variables that are common to all `DEMO`
tables, and combine the corresponding data subsets together, as follows.

``` r
all_demo_data <- head(all_demo_data, -1)
common_vars <- lapply(all_demo_data, names) |> Reduce(f = intersect)
common_vars
```

     [1] "SEQN"     "SDDSRVYR" "RIDSTATR" "RIDEXMON" "RIAGENDR" "RIDRETH1" "DMDCITZN" "DMDYRSUS"
     [9] "DMDEDUC3" "DMDEDUC2" "DMDMARTL" "RIDEXPRG" "DMDHRGND" "RIDAGEYR" "RIDAGEMN" "DMDHHSIZ"
    [17] "INDFMPIR" "WTINT2YR" "WTMEC2YR" "SDMVPSU"  "SDMVSTRA"

``` r
demo_combined <-
    lapply(all_demo_data, `[`, common_vars) |>
    do.call(what = rbind) |>
    transform(cycle = substring(SDDSRVYR, 8, 17))
dim(demo_combined)
```

    [1] 101316     22

The combined dataset can be analysed further using standard tools. For
example, Figure 2 uses the `lattice` package \[cite\] to summarize the
number of participants by recorded ethnicity and gender by cycle.

``` r
library("lattice")
demo_combined |>
    xtabs(~ cycle + RIAGENDR + RIDRETH1, data = _) |>
    array2DF() |>
    dotplot(Value ~ cycle | RIAGENDR,
            groups = RIDRETH1,
            layout = c(1, 2), type = "b",
            par.settings = simpleTheme(pch = 16),
            auto.key = list(columns = 3))
```

<img src="images/demoplot-1.svg" width="100%" />

One must be cautious when combining data across cycles, because the
NHANES data are sometimes inconsistent in unexpected ways. As a simple
example, consider the `DMDEDUC3` variable, which records education level
of children and youth. The following code illustrates that the values of
this variable have inconsistent capitalization in different cycles.

``` r
xtabs(~ cycle + DMDEDUC3, demo_combined)[, 1:4]
```

                DMDEDUC3
    cycle        10th grade 10th Grade 11th grade 11th Grade
      1999-2000           0        307          0        281
      2001-2002           0        324          0        319
      2003-2004           0        284          0        295
      2005-2006           0        307          0        277
      2007-2008           0        154          0        165
      2009-2010           0        193          0        185
      2011-2012         167          0        150          0
      2013-2014         162          0        186          0
      2015-2016         160          0        153          0
      2017-2018         139          0        155          0

## Cross-cycle Consistency checks using variable codebooks

In our experience, inconsistencies such as the change in capitalization
described above occur quite often, and in a variety of different ways,
requiring attention to detail when combining data from across cycles.
These inconsistencies are not necessarily mistakes, as NHANES
questionnaires and variables are often modified from cycle to cycle. The
primary source that must be consulted to identify such inconsistencies
are the per-table documentation, and in particular the variable
codebooks giving details of how each variable is recorded.

The NHANES database contains the variable codebooks for all tables
across all cycles in a single database table called
`Metadata.VariableCodebook`. Once imported into R, this information can
be manipulated in various ways to glean information of interest.

\[See
<https://ccb-hms.github.io/phonto/vignettes/diagnostics-codebook.html>
for more examples.\]

``` r
library("phonto")
dim(all_cb <- nhanesQuery("select * from Metadata.VariableCodebook"))
```

    [1] 202018      7

``` r
## dim(all_cb <- metaData("Codebook")) # alt interface
all_cb <- dplyr::filter(all_cb, !startsWith(TableName, "P_")) # skip pre-pandemic tables
```

An analyst would typically be interested in some specific variables that
are relevant to their study. The first step is to identify how many
cycles these variables were recorded in. To this end, we may start by
examining the number of *tables* each variable appears in across all
cycles of continuous NHANES.

``` r
var_freq <- 
    all_cb[c("Variable", "TableName")] |> unique() |>
        xtabs(~ Variable, data = _) |>
        sort(decreasing = TRUE)
table(var_freq)
```

    var_freq
       1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20 
    4720 3861 2358  564  373  696  776  529  266  365   49   46  263   50   11   23    2   33    3   48 
      21   22   23   25   28   29   30   32   40   56   58   66   74  111 
       1    4    1    3    8    1    1    2    1    1    1    1    1    1 

Not surprisingly, many variables appear only once or twice across all
cycles, and for such variables combining data across cycles would not be
interesting. Variables that appear in multiple cycles, but only once per
cycle, may usually be merged as in the `DEMO` example above, but note
that they may appear in different tables. One must be careful about
ensuring that the variable is measuring the same quantity in all cycles.
This is usually true, but not always. For example, the range of values
for the `LBCBHC` variable in different cycles seem to exhibit some
discrepancy.

``` r
subset(all_cb, Variable == "LBCBHC")[1:5]
```

           Variable TableName      CodeOrValue ValueDescription Count
    150088   LBCBHC  PSTPOL_D  0.004 to 2.3147  Range of Values   247
    150089   LBCBHC  PSTPOL_D                .          Missing     0
    150168   LBCBHC  PSTPOL_E 0.0044 to 5.2617  Range of Values   264
    150169   LBCBHC  PSTPOL_E                .          Missing     0
    150249   LBCBHC  PSTPOL_F    3.465 to 4801  Range of Values   295
    150250   LBCBHC  PSTPOL_F                .          Missing     6
    150324   LBCBHC  PSTPOL_G    3.536 to 5401  Range of Values   251
    150325   LBCBHC  PSTPOL_G                .          Missing     0
    150399   LBCBHC  PSTPOL_H    3.536 to 5648  Range of Values   281
    150400   LBCBHC  PSTPOL_H                .          Missing     3
    150467   LBCBHC  PSTPOL_I    3.536 to 1330  Range of Values   265
    150468   LBCBHC  PSTPOL_I                .          Missing     0

More useful information about the variables may be obtained from the
`Metadata.QuestionnaireVariables` table in the database, which contains
one row for each variable in each table containing its description,
target group, etc., obtained from the HTML documentation of NHANES
tables.

``` r
dim(all_var <- phonto::nhanesQuery("select * from Metadata.QuestionnaireVariables"))
```

    [1] 50714    11

``` r
## dim(all_var <- metaData("Variables"))
subset(all_var, Variable == "LBCBHC")[1:5]
```

          Variable TableName                       Description
    43244   LBCBHC  PSTPOL_D Beta-hexachlorocyclohexane (ng/g)
    43277   LBCBHC  PSTPOL_E Beta-hexachlorocyclohexane (ng/g)
    43310   LBCBHC  PSTPOL_F Beta-hexachlorocyclohexane (pg/g)
    43340   LBCBHC  PSTPOL_G Beta-hexachlorocyclohexane (pg/g)
    43370   LBCBHC  PSTPOL_H Beta-hexachlorocyclohexane (pg/g)
    43397   LBCBHC  PSTPOL_I Beta-hexachlorocyclohexane (pg/g)
                                               Target                          SasLabel
    43244 Both males and females 12 YEARS - 150 YEARS Beta-hexachlorocyclohexane (ng/g)
    43277 Both males and females 12 YEARS - 150 YEARS Beta-hexachlorocyclohexane (ng/g)
    43310 Both males and females 12 YEARS - 150 YEARS Beta-hexachlorocyclohexane (pg/g)
    43340 Both males and females 12 YEARS - 150 YEARS Beta-hexachlorocyclohexane (pg/g)
    43370 Both males and females 12 YEARS - 150 YEARS Beta-hexachlorocyclohexane (pg/g)
    43397 Both males and females 12 YEARS - 150 YEARS Beta-hexachlorocyclohexane (pg/g)

This shows that the unit of measurement was changed from the 2009–2010
cycle, explaining the discrepancy. Without a careful check, such changes
may be overlooked, leading to errors in interpretation.

It is not easy to systematically detect such changes without manual
inspection of variables of interest. One way to shortlist possible
candidate variables are to identify those for whom the `Description` or
`SasLabel` field has changed. Unfortunately, such changes happen
frequently for completely benign reasons, leading to many false
positives.

## Within-cycle consistency

Somewhat more surprisingly, several variables appear in more tables than
there are cycles, which means that they must appear in multiple tables
within the same cycle. The following variables appear in more than 20
tables.

``` r
var_freq[ var_freq > 20 ]
```

    Variable
      URXUCR  WTSA2YR   WTDRD1   DRDINT   WTDR2D RIAGENDR    DRABF  WTSB2YR  WTSC2YR WTSAF2YR   DR1DAY 
         111       74       66       58       56       40       32       32       30       29       28 
    DR1DRSTZ DR1EXMER  DR1LANG   DR2DAY DR2DRSTZ DR2EXMER  DR2LANG  RIANSMP RIDAGGRP    WTFSM WTSVOC2Y 
          28       28       28       28       28       28       28       25       25       25       23 
     DR1DBIH  DR2DBIH PHAFSTHR PHAFSTMN  DSDSUPP 
          22       22       22       22       21 

For such variables, selecting the corresponding subset of `all_cb` shows
all entries in the codebook tables for that variable, across all tables
and cycles. For example,

``` r
subset(all_cb, Variable == "PHAFSTMN")[1:5]
```

           Variable TableName CodeOrValue ValueDescription Count
    74503  PHAFSTMN  FASTQX_D     0 to 59  Range of Values  8903
    74504  PHAFSTMN  FASTQX_D           .          Missing   537
    74546  PHAFSTMN  FASTQX_E     0 to 59  Range of Values  8832
    74547  PHAFSTMN  FASTQX_E           .          Missing   475
    74589  PHAFSTMN  FASTQX_F     0 to 59  Range of Values  9557
    74590  PHAFSTMN  FASTQX_F           .          Missing   278
    74632  PHAFSTMN  FASTQX_G     0 to 59  Range of Values  8528
    74633  PHAFSTMN  FASTQX_G           .          Missing   428
    74675  PHAFSTMN  FASTQX_H     0 to 59  Range of Values  9182
    74676  PHAFSTMN  FASTQX_H           .          Missing   240
    74718  PHAFSTMN  FASTQX_I     0 to 59  Range of Values  8911
    74719  PHAFSTMN  FASTQX_I           .          Missing   254
    74761  PHAFSTMN  FASTQX_J     0 to 59  Range of Values  7996
    74762  PHAFSTMN  FASTQX_J           .          Missing   370
    84545  PHAFSTMN     GLU_D     0 to 59  Range of Values  3251
    84546  PHAFSTMN     GLU_D           .          Missing   101
    84559  PHAFSTMN     GLU_E     0 to 59  Range of Values  3223
    84560  PHAFSTMN     GLU_E           .          Missing    92
    84573  PHAFSTMN     GLU_F     0 to 59  Range of Values  3535
    84574  PHAFSTMN     GLU_F           .          Missing    46
    84587  PHAFSTMN     GLU_G     0 to 59  Range of Values  3167
    84588  PHAFSTMN     GLU_G           .          Missing    72
    84598  PHAFSTMN     GLU_H     0 to 59  Range of Values  3291
    84599  PHAFSTMN     GLU_H           .          Missing    38
    92762  PHAFSTMN     INS_H     0 to 59  Range of Values  3291
    92763  PHAFSTMN     INS_H           .          Missing    38
    92776  PHAFSTMN     INS_I     0 to 59  Range of Values  3135
    92777  PHAFSTMN     INS_I           .          Missing    56
    110377 PHAFSTMN    OGTT_D     0 to 59  Range of Values  3251
    110378 PHAFSTMN    OGTT_D           .          Missing   101
    110395 PHAFSTMN    OGTT_E     0 to 59  Range of Values  3223
    110396 PHAFSTMN    OGTT_E           .          Missing    92
    110430 PHAFSTMN    OGTT_F     0 to 59  Range of Values  3163
    110431 PHAFSTMN    OGTT_F           .          Missing     0
    110465 PHAFSTMN    OGTT_G     0 to 59  Range of Values  2815
    110466 PHAFSTMN    OGTT_G           .          Missing     0
    110505 PHAFSTMN    OGTT_H     0 to 59  Range of Values  2909
    110506 PHAFSTMN    OGTT_H           .          Missing     0
    148145 PHAFSTMN        PH     0 to 59  Range of Values  8350
    148146 PHAFSTMN        PH           .          Missing   482
    148188 PHAFSTMN      PH_B     0 to 59  Range of Values  9480
    148189 PHAFSTMN      PH_B           .          Missing   449
    148231 PHAFSTMN      PH_C     0 to 59  Range of Values  9013
    148232 PHAFSTMN      PH_C           .          Missing   166

Inspection of this table shows that the `PHAFSTMN` variable was
initially recorded in the `PH` table for the first three cycles, after
which it was recorded in three different tables (`FASTQX`, `GLU`, and
`OGTT`) for several cycles, before being dropped again from the latter
two tables. It is natural to wonder whether all these tables contain the
same data. This can only be verified by comparing the actual data, which
we will not do for this example, but some hints are provided by the data
counts included in the codebook. For example, for the 2005–2006 cycle,
we have

``` r
subset(all_cb, Variable == "PHAFSTMN" & endsWith(TableName, "_D"))[1:5]
```

           Variable TableName CodeOrValue ValueDescription Count
    74503  PHAFSTMN  FASTQX_D     0 to 59  Range of Values  8903
    74504  PHAFSTMN  FASTQX_D           .          Missing   537
    84545  PHAFSTMN     GLU_D     0 to 59  Range of Values  3251
    84546  PHAFSTMN     GLU_D           .          Missing   101
    110377 PHAFSTMN    OGTT_D     0 to 59  Range of Values  3251
    110378 PHAFSTMN    OGTT_D           .          Missing   101

From the variable metadata table, we see that

``` r
subset(all_var, Variable == "PHAFSTMN" & endsWith(TableName, "_D"))[c(1, 2, 4, 5)]
```

          Variable TableName                                      Target
    24274 PHAFSTMN  FASTQX_D  Both males and females 1 YEARS - 150 YEARS
    25529 PHAFSTMN     GLU_D Both males and females 12 YEARS - 150 YEARS
    31383 PHAFSTMN    OGTT_D Both males and females 12 YEARS - 150 YEARS
                                     SasLabel
    24274   Total length of food fast minutes
    25529 Total length of 'food fast' minutes
    31383 Total length of 'food fast' minutes

While not definitive, this suggests that the `PHAFSTMN` variable
measures the same quantity in all three tables, and the difference in
number of observations may be due to the difference in target age group.

Even if a preliminary inspection suggests no obvious problems, one
should verify by comparing the actual recorded data. For example,
consider the `ENQ100` variable, which appears in both `ENX` and `SPX`
tables.

``` r
subset(all_var, Variable == "ENQ100" & endsWith(TableName, "_E"))[c(1, 2, 4, 5)]
```

          Variable TableName                                    Target                        SasLabel
    23932   ENQ100     ENX_E Both males and females 6 YEARS - 79 YEARS Cough cold resp illness 7 days?
    45401   ENQ100     SPX_E Both males and females 6 YEARS - 79 YEARS        Had respiratory illness?

``` r
merge(nhanes("ENX_E")[c("SEQN", "ENQ100")],
      nhanes("SPX_E")[c("SEQN", "ENQ100")], by = "SEQN") |>
    xtabs(~ ENQ100.x + ENQ100.y, data =_, addNA = TRUE)
```

                ENQ100.y
    ENQ100.x     Don't know   No  Yes <NA>
      Don't know          3    0    0    0
      No                  0 5013    0    0
      Yes                 0    0 1354    0
      <NA>                0  217   63 1093

Comparing the records in the two tables after matching by `SEQN`, the
participant identifier, we see that even though most records are
consistent, several records with `Yes` or `No` answers in the `SPX`
tables are recorded as `NA` (missing) in the `ENX` tables.

A more egregious example, where the same variable is clearly measuring
two different things, is provided by the `LBXHCT` variable.

``` r
subset(all_cb, Variable == "LBXHCT" & endsWith(TableName, "_H"))[1:5]
```

          Variable TableName   CodeOrValue ValueDescription Count
    24512   LBXHCT     CBC_H  17.9 to 56.5  Range of Values  8544
    24513   LBXHCT     CBC_H             .          Missing   878
    33809   LBXHCT     COT_H 0.011 to 1150  Range of Values  8029
    33810   LBXHCT     COT_H             .          Missing   884

``` r
subset(all_var, Variable == "LBXHCT" & endsWith(TableName, "_H"))[c(1, 2, 3, 4, 5)]
```

          Variable TableName                   Description                                     Target
    9538    LBXHCT     CBC_H                Hematocrit (%) Both males and females 1 YEARS - 150 YEARS
    11531   LBXHCT     COT_H Hydroxycotinine Serum (ng/mL) Both males and females 3 YEARS - 150 YEARS
                               SasLabel
    9538                 Hematocrit (%)
    11531 Hydroxycotinine Serum (ng/mL)

``` r
merge(nhanes("CBC_H")[c("SEQN", "LBXHCT")],
      nhanes("COT_H")[c("SEQN", "LBXHCT")], by = "SEQN") |> head()
```

       SEQN LBXHCT.x LBXHCT.y
    1 73557     45.4    1.330
    2 73558     36.7    4.480
    3 73559     49.9    0.055
    4 73560     37.8    0.025
    5 73561     43.8    0.011
    6 73562     41.5    0.011

## Searching variables

Having access to all variable descriptions in a single dataset makes
search operations convenient. For example,

``` r
all_var |> within({ Description <- tolower(Description) }) |>
    subset(endsWith(TableName, "_C") &
           (grepl("hypertension", Description) |
            grepl("blood pressure", Description)),
           select = c(1, 2, 5))
```

          Variable TableName                                 SasLabel
    8894    BPQ010     BPQ_C    Last blood pressure reading by doctor
    8895    BPQ020     BPQ_C    Ever told you had high blood pressure
    8896    BPQ030     BPQ_C  Told had high blood pressure - 2+ times
    8897   BPQ040A     BPQ_C     Taking prescription for hypertension
    8898   BPQ040B     BPQ_C  Told to control weight for hypertension
    8899   BPQ040C     BPQ_C   Told to reduce sodium for hypertension
    8900   BPQ040D     BPQ_C   Told to exercise more for hypertension
    8901   BPQ040E     BPQ_C  Told to reduce alcohol for hypertension
    8902   BPQ040F     BPQ_C Told to do other things for hypertension
    9097  PEASCST1     BPX_C                    Blood Pressure Status
    9098  PEASCTM1     BPX_C           Blood Pressure Time in Seconds
    9099  PEASCCT1     BPX_C                   Blood Pressure Comment
    9112    BPXSY1     BPX_C     Systolic: Blood pres (1st rdg) mm Hg
    9113    BPXDI1     BPX_C    Diastolic: Blood pres (1st rdg) mm Hg
    9115    BPXSY2     BPX_C     Systolic: Blood pres (2nd rdg) mm Hg
    9116    BPXDI2     BPX_C    Diastolic: Blood pres (2nd rdg) mm Hg
    9118    BPXSY3     BPX_C     Systolic: Blood pres (3rd rdg) mm Hg
    9119    BPXDI3     BPX_C    Diastolic: Blood pres (3rd rdg) mm Hg
    9121    BPXSY4     BPX_C     Systolic: Blood pres (4th rdg) mm Hg
    9122    BPXDI4     BPX_C    Diastolic: Blood pres (4th rdg) mm Hg
    11863  CVQ220C     CVX_C             Priority 2 Stop excessive BP
    11864  CVQ220E     CVX_C  Priority 2 Stop significant drop in SBP
    11880   CVAARM     CVX_C  Arm selected for blood pressure monitor
    11881  CVACUFF     CVX_C     Cuff size for blood pressure monitor
    11888   CVDWSY     CVX_C              Warm-up systolic BP (mm Hg)
    11889   CVDWDI     CVX_C             Warm-up diastolic BP (mm Hg)
    11895  CVDS1SY     CVX_C              Stage 1 systolic BP (mm Hg)
    11896  CVDS1DI     CVX_C             Stage 1 diastolic BP (mm Hg)
    11902  CVDS2SY     CVX_C              Stage 2 systolic BP (mm Hg)
    11903  CVDS2DI     CVX_C             Stage 2 diastolic BP (mm Hg)
    11906  CVDR1SY     CVX_C           Recovery 1 systolic BP (mm Hg)
    11907  CVDR1DI     CVX_C          Recovery 1 diastolic BP (mm Hg)
    11910  CVDR2SY     CVX_C           Recovery 2 systolic BP (mm Hg)
    11911  CVDR2DI     CVX_C          Recovery 2 diastolic BP (mm Hg)
    11914  CVDR3SY     CVX_C           Recovery 3 systolic BP (mm Hg)
    11915  CVDR3DI     CVX_C          Recovery 3 diastolic BP (mm Hg)
    29638  LEXBRP1   LEXAB_C                   Brachial SBP 1 (mm Hg)
    29639  LEXBRP2   LEXAB_C                   Brachial SBP 2 (mm Hg)
    29640  LEXBRPM   LEXAB_C                Mean Brachial SBP (mm Hg)
    29641 LEXLPTS1   LEXAB_C      Left Posterior Tibial SBP 1 (mm Hg)
    29642 LEXLPTS2   LEXAB_C      Left Posterior Tibial SBP 2 (mm Hg)
    29643 LEXLPTSM   LEXAB_C   Left Mean Posterior Tibial SBP (mm Hg)
    29645 LEXRPTS1   LEXAB_C     Right Posterior Tibial SBP 1 (mm Hg)
    29646 LEXRPTS2   LEXAB_C     Right Posterior Tibial SBP 2 (mm Hg)
    29647 LEXRPTSM   LEXAB_C  Right Mean Posterior Tibial SBP (mm Hg)
    29651 LEALAPNC   LEXAB_C              Left ankle SBP > 255 mm Hg?
    29652 LEARAPNC   LEXAB_C             Right ankle SBP > 255 mm Hg?
    30223  MCQ250F     MCQ_C    Blood relatives w/hypertension/stroke
    42272  PFD069J     PFQ_C  Hypertension or high blood pressuredays

Information in this table can be supplemented using the
`nhanesTableSummary()` function, which computes further information such
as the variable type and number of non-missing observations. More
details are given in \[cite
<https://ccb-hms.github.io/phonto/vignettes/search-tables.html>\], which
also provides links to publicly accessible online search interfaces.

## Special codes in numeric variables

## Data coarsening

## Variables that are potentially skipped

``` r
## Tables where some items are skipped

tables_with_skipping <- unique(subset(all_cb, !is.na(SkipToItem))$TableName)

## around 30% of tables

length(tables_with_skipping) / length(unique(all_cb$TableName))
```

    [1] 0.2893401

``` r
## what we really want is to flag variables that might have been
## skipped based on a previous answer

subset(all_cb, TableName == tables_with_skipping[[1]], select = -c(Count, Cumulative))
```

        Variable TableName CodeOrValue   ValueDescription SkipToItem
    415   AGQ010     AGQ_D           1                Yes       <NA>
    416   AGQ010     AGQ_D           2                 No     AGQ040
    417   AGQ010     AGQ_D           7            Refused     AGQ040
    418   AGQ010     AGQ_D           9         Don't know     AGQ040
    419   AGQ010     AGQ_D           .            Missing       <NA>
    420   AGD020     AGQ_D     1 to 81    Range of Values       <NA>
    421   AGD020     AGQ_D          85  85 years or older       <NA>
    422   AGD020     AGQ_D         777            Refused       <NA>
    423   AGD020     AGQ_D         999         Don't know       <NA>
    424   AGD020     AGQ_D           .            Missing       <NA>
    425   AGQ030     AGQ_D           1                Yes       <NA>
    426   AGQ030     AGQ_D           2                 No       <NA>
    427   AGQ030     AGQ_D           7            Refused       <NA>
    428   AGQ030     AGQ_D           9         Don't know       <NA>
    429   AGQ030     AGQ_D           .            Missing       <NA>
    430   AGQ040     AGQ_D           1                Yes       <NA>
    431   AGQ040     AGQ_D           2                 No     AGQ070
    432   AGQ040     AGQ_D           7            Refused     AGQ070
    433   AGQ040     AGQ_D           9         Don't know     AGQ070
    434   AGQ040     AGQ_D           .            Missing       <NA>
    435   AGD050     AGQ_D     1 to 82    Range of Values       <NA>
    436   AGD050     AGQ_D          85  85 years or older       <NA>
    437   AGD050     AGQ_D         777            Refused       <NA>
    438   AGD050     AGQ_D         999         Don't know       <NA>
    439   AGD050     AGQ_D           .            Missing       <NA>
    440   AGQ060     AGQ_D           1                Yes       <NA>
    441   AGQ060     AGQ_D           2                 No       <NA>
    442   AGQ060     AGQ_D           7            Refused       <NA>
    443   AGQ060     AGQ_D           9         Don't know       <NA>
    444   AGQ060     AGQ_D           .            Missing       <NA>
    445   AGQ070     AGQ_D           1                Yes       <NA>
    446   AGQ070     AGQ_D           2                 No     AGQ090
    447   AGQ070     AGQ_D           7            Refused     AGQ090
    448   AGQ070     AGQ_D           9         Don't know     AGQ090
    449   AGQ070     AGQ_D           .            Missing       <NA>
    450  AGQ080A     AGQ_D           1                Dog       <NA>
    451  AGQ080A     AGQ_D           7            Refused       <NA>
    452  AGQ080A     AGQ_D           9         Don't know       <NA>
    453  AGQ080A     AGQ_D           .            Missing       <NA>
    454  AGQ080B     AGQ_D           2                Cat       <NA>
    455  AGQ080B     AGQ_D           .            Missing       <NA>
    456  AGQ080C     AGQ_D           3 Small furry animal       <NA>
    457  AGQ080C     AGQ_D           .            Missing       <NA>
    458   AGQ090     AGQ_D           1                Yes       <NA>
    459   AGQ090     AGQ_D           2                 No       <NA>
    460   AGQ090     AGQ_D           7            Refused       <NA>
    461   AGQ090     AGQ_D           9         Don't know       <NA>
    462   AGQ090     AGQ_D           .            Missing       <NA>
    463   AGQ100     AGQ_D           1                Yes       <NA>
    464   AGQ100     AGQ_D           2                 No     AGQ120
    465   AGQ100     AGQ_D           7            Refused     AGQ120
    466   AGQ100     AGQ_D           9         Don't know     AGQ120
    467   AGQ100     AGQ_D           .            Missing       <NA>
    468  AGQ110A     AGQ_D           1             Spring       <NA>
    469  AGQ110A     AGQ_D           7            Refused       <NA>
    470  AGQ110A     AGQ_D           9         Don't know       <NA>
    471  AGQ110A     AGQ_D           .            Missing       <NA>
    472  AGQ110B     AGQ_D           2             Summer       <NA>
    473  AGQ110B     AGQ_D           .            Missing       <NA>
    474  AGQ110C     AGQ_D           3               Fall       <NA>
    475  AGQ110C     AGQ_D           .            Missing       <NA>
    476  AGQ110D     AGQ_D           4             Winter       <NA>
    477  AGQ110D     AGQ_D           .            Missing       <NA>
    478   AGQ120     AGQ_D           1                Yes       <NA>
    479   AGQ120     AGQ_D           2                 No       <NA>
    480   AGQ120     AGQ_D           7            Refused       <NA>
    481   AGQ120     AGQ_D           9         Don't know       <NA>
    482   AGQ120     AGQ_D           .            Missing       <NA>
    483   AGQ130     AGQ_D           1                Yes       <NA>
    484   AGQ130     AGQ_D           2                 No     AGQ180
    485   AGQ130     AGQ_D           7            Refused     AGQ180
    486   AGQ130     AGQ_D           9         Don't know     AGQ180
    487   AGQ130     AGQ_D           .            Missing       <NA>
    488   AGQ140     AGQ_D           1                Yes       <NA>
    489   AGQ140     AGQ_D           2                 No     AGQ160
    490   AGQ140     AGQ_D           7            Refused     AGQ160
    491   AGQ140     AGQ_D           9         Don't know     AGQ160
    492   AGQ140     AGQ_D           .            Missing       <NA>
    493   AGQ150     AGQ_D           1                Yes       <NA>
    494   AGQ150     AGQ_D           2                 No       <NA>
    495   AGQ150     AGQ_D           7            Refused       <NA>
    496   AGQ150     AGQ_D           9         Don't know       <NA>
    497   AGQ150     AGQ_D           .            Missing       <NA>
    498   AGQ160     AGQ_D           1                Yes       <NA>
    499   AGQ160     AGQ_D           2                 No       <NA>
    500   AGQ160     AGQ_D           7            Refused       <NA>
    501   AGQ160     AGQ_D           9         Don't know       <NA>
    502   AGQ160     AGQ_D           .            Missing       <NA>
    503   AGD170     AGQ_D     1 to 84    Range of Values       <NA>
    504   AGD170     AGQ_D          85  85 years or older       <NA>
    505   AGD170     AGQ_D         777            Refused       <NA>
    506   AGD170     AGQ_D         999         Don't know       <NA>
    507   AGD170     AGQ_D           .            Missing       <NA>
    508   AGQ180     AGQ_D           1                Yes       <NA>
    509   AGQ180     AGQ_D           2                 No       <NA>
    510   AGQ180     AGQ_D           7            Refused       <NA>
    511   AGQ180     AGQ_D           9         Don't know       <NA>
    512   AGQ180     AGQ_D           .            Missing       <NA>

``` r
## question: for a given question, can different answers lead to
## skipping to different places? In any case, given a table, we want
## to first flag all questions that can lead to skipping, and if so, where.
```
