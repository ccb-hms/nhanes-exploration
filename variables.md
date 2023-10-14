Variables in NHANES
================
Deepayan Sarkar

# Summary of available variables

We can get information about available variables from the metadata table
`Metadata.QuestionnaireVariables`.

``` r
library(nhanesA)
variableDesc <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireVariables")
dim(variableDesc)
#> [1] 50611    10
```

There are not actually these many variables, because every occurrence in
every table is recorded separately.

``` r
length(unique(variableDesc$Variable))
#> [1] 12469
```

Let’s start by dropping the `P_*` tables for now.

``` r
variableDesc <- subset(variableDesc, !startsWith(TableName, "P_"))
dim(variableDesc)
#> [1] 47023    10
```

Most “useful” variables would be recorded in most (if not all) cycles;
so let’s see how many appear in at least 7 tables.

``` r
table(variableDesc$Variable) |> sort(decreasing = TRUE) |> table()
#> 
#>    1    2    3    4    5    6    7    8    9   10   11   12   13   14   16   20   21   22   23   25 
#> 2766 3368 2336  589  374  673  835  531  297  348   28   28  228    4    1    1    1    5    1    2 
#>   28   29   30   32   35   56   58   66   73  110 1326 
#>    9    1    1    2    1    1    1    1    1    1    1
```

What does it mean for a variable to appear in more than 10 tables? This
makes sense for `SEQN`:

``` r
sum(variableDesc$Variable == "SEQN")
#> [1] 1326
```

But what are the other ones?

``` r
variableFreq <- table(variableDesc$Variable) |> sort(decreasing = TRUE)
variableFreq[variableFreq > 13]
#> 
#>     SEQN   URXUCR  WTSA2YR   WTDRD1   DRDINT   WTDR2D RIAGENDR    DRABF  WTSB2YR  WTSC2YR WTSAF2YR 
#>     1326      110       73       66       58       56       35       32       32       30       29 
#>   DR1DAY DR1DRSTZ DR1EXMER  DR1LANG   DR2DAY DR2DRSTZ DR2EXMER  DR2LANG SAMPLEID  RIANSMP RIDAGGRP 
#>       28       28       28       28       28       28       28       28       28       25       25 
#> WTSVOC2Y  DR1DBIH  DR2DBIH PHAFSTHR PHAFSTMN    WTFSM  DSDSUPP DSDSUPID WTSMSMPA DXDLSPST OHAEXSTS 
#>       23       22       22       22       22       22       21       20       16       14       14 
#> RIDRETH1 RIDRETH3 
#>       14       14
```

Let’s look at one of these.

``` r
subset(variableDesc, Variable == "PHAFSTMN", select = c(1, 2, 5)) #|> kable()
#>       Variable TableName                            SasLabel
#> 24260 PHAFSTMN  FASTQX_D   Total length of food fast minutes
#> 24279 PHAFSTMN  FASTQX_E   Total length of food fast minutes
#> 24298 PHAFSTMN  FASTQX_F   Total length of food fast minutes
#> 24317 PHAFSTMN  FASTQX_G   Total length of food fast minutes
#> 24336 PHAFSTMN  FASTQX_H   Total length of food fast minutes
#> 24355 PHAFSTMN  FASTQX_I   Total length of food fast minutes
#> 24374 PHAFSTMN  FASTQX_J   Total length of food fast minutes
#> 25515 PHAFSTMN     GLU_D Total length of 'food fast' minutes
#> 25523 PHAFSTMN     GLU_E Total length of 'food fast' minutes
#> 25531 PHAFSTMN     GLU_F Total length of 'food fast' minutes
#> 25539 PHAFSTMN     GLU_G Total length of 'food fast' minutes
#> 25545 PHAFSTMN     GLU_H Total length of 'food fast' minutes
#> 27036 PHAFSTMN     INS_H Total length of 'food fast' minutes
#> 27043 PHAFSTMN     INS_I Total length of 'food fast' minutes
#> 31374 PHAFSTMN    OGTT_D Total length of 'food fast' minutes
#> 31383 PHAFSTMN    OGTT_E Total length of 'food fast' minutes
#> 31395 PHAFSTMN    OGTT_F Total length of 'food fast' minutes
#> 31407 PHAFSTMN    OGTT_G Total length of 'food fast' minutes
#> 31421 PHAFSTMN    OGTT_H Total length of 'food fast' minutes
#> 42558 PHAFSTMN        PH   Total length of food fast minutes
#> 42577 PHAFSTMN      PH_B   Total length of food fast minutes
#> 42596 PHAFSTMN      PH_C   Total length of food fast minutes
```

This raises the obvious question: Are these measuring the same thing?
Let’s look at actual data in `FASTQX_D`, `GLU_D`, and `OGTT_D`.

``` r
wtables <- c("FASTQX_D", "GLU_D", "OGTT_D")
tablist <- sapply(wtables, 
                  function(name) nhanes(name)[c("SEQN", "PHAFSTMN")], 
                  simplify = FALSE)
str(tablist)
#> List of 3
#>  $ FASTQX_D:'data.frame':    9440 obs. of  2 variables:
#>   ..$ SEQN    : int [1:9440] 39088 33031 32244 33323 32287 39237 34992 35135 33592 36237 ...
#>   ..$ PHAFSTMN: num [1:9440] 47 33 30 12 11 26 35 42 14 5 ...
#>  $ GLU_D   :'data.frame':    3352 obs. of  2 variables:
#>   ..$ SEQN    : int [1:3352] 31139 31141 31265 31311 31331 31416 31481 31511 31749 32007 ...
#>   ..$ PHAFSTMN: num [1:3352] NA NA NA NA NA NA NA NA NA NA ...
#>  $ OGTT_D  :'data.frame':    3352 obs. of  2 variables:
#>   ..$ SEQN    : int [1:3352] 31139 31141 31265 31311 31331 31416 31481 31511 31749 32007 ...
#>   ..$ PHAFSTMN: num [1:3352] NA NA NA NA NA NA NA NA NA NA ...
```

Let’s check if they are idential for every common `SEQN`:

``` r
str(with(tablist, sort(intersect(FASTQX_D$SEQN, GLU_D$SEQN))))
#>  int [1:3352] 31130 31131 31132 31133 31134 31139 31141 31148 31150 31151 ...
str(with(tablist, sort(intersect(FASTQX_D$SEQN, OGTT_D$SEQN))))
#>  int [1:3352] 31130 31131 31132 31133 31134 31139 31141 31148 31150 31151 ...
str(with(tablist, sort(intersect(GLU_D$SEQN, OGTT_D$SEQN))))
#>  int [1:3352] 31130 31131 31132 31133 31134 31139 31141 31148 31150 31151 ...
keep <- with(tablist, 
             FASTQX_D$SEQN |> intersect(GLU_D$SEQN) |> intersect(OGTT_D$SEQN))
keep <- sort(keep) # SEQN to get from each table
keep.index <- lapply(tablist, function(d) match(keep, d$SEQN) )
sublist <- sapply(wtables, 
                  function(name) tablist[[name]][keep.index[[name]] , ],
                  simplify = FALSE)
all.equal(sublist$FASTQX_D, sublist$GLU_D, check.attributes = FALSE)
#> [1] TRUE
all.equal(sublist$FASTQX_D, sublist$OGTT_D, check.attributes = FALSE)
#> [1] TRUE
```

So at least there seems to be some consistency.

# Variable names and descriptions

Ideally, each variable should have the same description and SAS Label
whenever it appears. Let’s look at unique combinations.

``` r
unique(variableDesc$Variable) |> length()
#> [1] 12436
unique(variableDesc[c("Variable", "Description", "SasLabel")]) |> dim()
#> [1] 15201     3
unique(variableDesc[c("Variable", "Description")]) |> dim()
#> [1] 14731     2
unique(variableDesc[c("Variable", "SasLabel")]) |> dim()
#> [1] 13937     2
```

So not too bad. Let’s look at the variables that have multiple
`SasLabels` first.

``` r
multLabels <- subset(unique(variableDesc[c("Variable", "SasLabel")]),
                     Variable %in% names(which(table(Variable) > 1)))
sort(multLabels, by = ~ Variable) |> head(100) |> kable()
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

SasLabel

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

35

</td>

<td style="text-align:left;">

ACD040

</td>

<td style="text-align:left;">

Language(s) usually spoken at home

</td>

</tr>

<tr>

<td style="text-align:left;">

81

</td>

<td style="text-align:left;">

ACD040

</td>

<td style="text-align:left;">

Language(s) spoken at home - Hispanics

</td>

</tr>

<tr>

<td style="text-align:left;">

104

</td>

<td style="text-align:left;">

AGQ030

</td>

<td style="text-align:left;">

Episode of hay fever in past 12 months

</td>

</tr>

<tr>

<td style="text-align:left;">

30625

</td>

<td style="text-align:left;">

AGQ030

</td>

<td style="text-align:left;">

Did SP have episode of hay fever/past yr

</td>

</tr>

<tr>

<td style="text-align:left;">

43529

</td>

<td style="text-align:left;">

AGQ030

</td>

<td style="text-align:left;">

Episode of hay fever in past 12 months?

</td>

</tr>

<tr>

<td style="text-align:left;">

325

</td>

<td style="text-align:left;">

ALQ130

</td>

<td style="text-align:left;">

Avg \# alcoholic drinks/day -past 12 mos

</td>

</tr>

<tr>

<td style="text-align:left;">

379

</td>

<td style="text-align:left;">

ALQ130

</td>

<td style="text-align:left;">

Avg \# alcoholic drinks/day - past 12 mos

</td>

</tr>

<tr>

<td style="text-align:left;">

407

</td>

<td style="text-align:left;">

ALQ130

</td>

<td style="text-align:left;">

Avg \# alcohol drinks/day - past 12 mos

</td>

</tr>

<tr>

<td style="text-align:left;">

874

</td>

<td style="text-align:left;">

AUAFMANR

</td>

<td style="text-align:left;">

Frequency-Switch to Manual Mode Right

</td>

</tr>

<tr>

<td style="text-align:left;">

1017

</td>

<td style="text-align:left;">

AUAFMANR

</td>

<td style="text-align:left;">

Frequency Switch to Manual Mode Right

</td>

</tr>

<tr>

<td style="text-align:left;">

907

</td>

<td style="text-align:left;">

AUALEQC

</td>

<td style="text-align:left;">

Left Ear Quality Code

</td>

</tr>

<tr>

<td style="text-align:left;">

1051

</td>

<td style="text-align:left;">

AUALEQC

</td>

<td style="text-align:left;">

Left Ear Tympanogram Quality Code

</td>

</tr>

<tr>

<td style="text-align:left;">

908

</td>

<td style="text-align:left;">

AUAREQC

</td>

<td style="text-align:left;">

Right Ear Quality Code

</td>

</tr>

<tr>

<td style="text-align:left;">

1050

</td>

<td style="text-align:left;">

AUAREQC

</td>

<td style="text-align:left;">

Right Ear Tympanogram Quality Code

</td>

</tr>

<tr>

<td style="text-align:left;">

856

</td>

<td style="text-align:left;">

AUDLOABC

</td>

<td style="text-align:left;">

Comment:Other Ear Exam Abnormality Left

</td>

</tr>

<tr>

<td style="text-align:left;">

999

</td>

<td style="text-align:left;">

AUDLOABC

</td>

<td style="text-align:left;">

Comment Other Ear Exam Abnormality Left

</td>

</tr>

<tr>

<td style="text-align:left;">

1070

</td>

<td style="text-align:left;">

AUDLOABC

</td>

<td style="text-align:left;">

CommentOther Exam Abnormality Left Ear

</td>

</tr>

<tr>

<td style="text-align:left;">

862

</td>

<td style="text-align:left;">

AUDROABC

</td>

<td style="text-align:left;">

Comment Other Ear Exam Abnormality Right

</td>

</tr>

<tr>

<td style="text-align:left;">

1076

</td>

<td style="text-align:left;">

AUDROABC

</td>

<td style="text-align:left;">

CommentOther Exam Abnormality Right Ear

</td>

</tr>

<tr>

<td style="text-align:left;">

725

</td>

<td style="text-align:left;">

AUQ110

</td>

<td style="text-align:left;">

Hearing cause frustration when talking?

</td>

</tr>

<tr>

<td style="text-align:left;">

816

</td>

<td style="text-align:left;">

AUQ110

</td>

<td style="text-align:left;">

Hearing causes frustration when talking?

</td>

</tr>

<tr>

<td style="text-align:left;">

670

</td>

<td style="text-align:left;">

AUQ138

</td>

<td style="text-align:left;">

Ever had tube placed in ear?

</td>

</tr>

<tr>

<td style="text-align:left;">

11638

</td>

<td style="text-align:left;">

AUQ138

</td>

<td style="text-align:left;">

Ever had a tube placed in your ear?

</td>

</tr>

<tr>

<td style="text-align:left;">

675

</td>

<td style="text-align:left;">

AUQ191

</td>

<td style="text-align:left;">

Ears ringing roaring buzzing past year

</td>

</tr>

<tr>

<td style="text-align:left;">

819

</td>

<td style="text-align:left;">

AUQ191

</td>

<td style="text-align:left;">

Ears ringing buzzing past year?

</td>

</tr>

<tr>

<td style="text-align:left;">

682

</td>

<td style="text-align:left;">

AUQ231

</td>

<td style="text-align:left;">

Loud noise exposure for 5 hours?

</td>

</tr>

<tr>

<td style="text-align:left;">

716

</td>

<td style="text-align:left;">

AUQ231

</td>

<td style="text-align:left;">

Ever had non-job exposure to loud noise?

</td>

</tr>

<tr>

<td style="text-align:left;">

676

</td>

<td style="text-align:left;">

AUQ250

</td>

<td style="text-align:left;">

How long bothered by ringing roaring

</td>

</tr>

<tr>

<td style="text-align:left;">

820

</td>

<td style="text-align:left;">

AUQ250

</td>

<td style="text-align:left;">

How long bothered by ringing buzzing?

</td>

</tr>

<tr>

<td style="text-align:left;">

678

</td>

<td style="text-align:left;">

AUQ270

</td>

<td style="text-align:left;">

Bothered by ringing when going to sleep

</td>

</tr>

<tr>

<td style="text-align:left;">

823

</td>

<td style="text-align:left;">

AUQ270

</td>

<td style="text-align:left;">

Bothered by ringing when going to sleep?

</td>

</tr>

<tr>

<td style="text-align:left;">

742

</td>

<td style="text-align:left;">

AUQ330

</td>

<td style="text-align:left;">

Ever had a job exposure to loud noise?

</td>

</tr>

<tr>

<td style="text-align:left;">

829

</td>

<td style="text-align:left;">

AUQ330

</td>

<td style="text-align:left;">

Ever had job exposure to loud noise?

</td>

</tr>

<tr>

<td style="text-align:left;">

743

</td>

<td style="text-align:left;">

AUQ340

</td>

<td style="text-align:left;">

How long exposed to loud noise at work?

</td>

</tr>

<tr>

<td style="text-align:left;">

830

</td>

<td style="text-align:left;">

AUQ340

</td>

<td style="text-align:left;">

How long exposed to loud noise at work

</td>

</tr>

<tr>

<td style="text-align:left;">

744

</td>

<td style="text-align:left;">

AUQ350

</td>

<td style="text-align:left;">

Ever exposed to very loud noise at work

</td>

</tr>

<tr>

<td style="text-align:left;">

774

</td>

<td style="text-align:left;">

AUQ350

</td>

<td style="text-align:left;">

Ever exposed to very loud noise at work?

</td>

</tr>

<tr>

<td style="text-align:left;">

901

</td>

<td style="text-align:left;">

AUXR1K2L

</td>

<td style="text-align:left;">

Left Retest Threshold 1000-2nd Read

</td>

</tr>

<tr>

<td style="text-align:left;">

1044

</td>

<td style="text-align:left;">

AUXR1K2L

</td>

<td style="text-align:left;">

Left Retest Threshold 1000Hz-2nd Read

</td>

</tr>

<tr>

<td style="text-align:left;">

867

</td>

<td style="text-align:left;">

AUXTMEPL

</td>

<td style="text-align:left;">

Middle Ear Pressure Tymp Left in dapa

</td>

</tr>

<tr>

<td style="text-align:left;">

939

</td>

<td style="text-align:left;">

AUXTMEPL

</td>

<td style="text-align:left;">

Middle Ear Pressure Tymp Left in daPa

</td>

</tr>

<tr>

<td style="text-align:left;">

7487

</td>

<td style="text-align:left;">

BAQ075

</td>

<td style="text-align:left;">

How long ago where you treated

</td>

</tr>

<tr>

<td style="text-align:left;">

7511

</td>

<td style="text-align:left;">

BAQ075

</td>

<td style="text-align:left;">

How long ago were you treated

</td>

</tr>

<tr>

<td style="text-align:left;">

8733

</td>

<td style="text-align:left;">

BMDBMIC

</td>

<td style="text-align:left;">

BMI Category - Children/Adolescents

</td>

</tr>

<tr>

<td style="text-align:left;">

8759

</td>

<td style="text-align:left;">

BMDBMIC

</td>

<td style="text-align:left;">

BMI Category - Children/Youth

</td>

</tr>

<tr>

<td style="text-align:left;">

9045

</td>

<td style="text-align:left;">

BPAARM

</td>

<td style="text-align:left;">

Arm selected:

</td>

</tr>

<tr>

<td style="text-align:left;">

9217

</td>

<td style="text-align:left;">

BPAARM

</td>

<td style="text-align:left;">

Arm selected

</td>

</tr>

<tr>

<td style="text-align:left;">

8835

</td>

<td style="text-align:left;">

BPQ050A

</td>

<td style="text-align:left;">

Now taking prescribed medicine

</td>

</tr>

<tr>

<td style="text-align:left;">

8933

</td>

<td style="text-align:left;">

BPQ050A

</td>

<td style="text-align:left;">

Now taking prescribed medicine for HBP

</td>

</tr>

<tr>

<td style="text-align:left;">

9065

</td>

<td style="text-align:left;">

BPXDAR

</td>

<td style="text-align:left;">

DBP average reported to examinee

</td>

</tr>

<tr>

<td style="text-align:left;">

9125

</td>

<td style="text-align:left;">

BPXDAR

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

9047

</td>

<td style="text-align:left;">

BPXPLS

</td>

<td style="text-align:left;">

60 sec. pulse (30 sec. pulse \* 2):

</td>

</tr>

<tr>

<td style="text-align:left;">

9219

</td>

<td style="text-align:left;">

BPXPLS

</td>

<td style="text-align:left;">

60 sec. pulse (30 sec. pulse \* 2)

</td>

</tr>

<tr>

<td style="text-align:left;">

9050

</td>

<td style="text-align:left;">

BPXPTY

</td>

<td style="text-align:left;">

Pulse type:

</td>

</tr>

<tr>

<td style="text-align:left;">

9221

</td>

<td style="text-align:left;">

BPXPTY

</td>

<td style="text-align:left;">

Pulse type

</td>

</tr>

<tr>

<td style="text-align:left;">

9064

</td>

<td style="text-align:left;">

BPXSAR

</td>

<td style="text-align:left;">

SBP average reported to examinee

</td>

</tr>

<tr>

<td style="text-align:left;">

9124

</td>

<td style="text-align:left;">

BPXSAR

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

9679

</td>

<td style="text-align:left;">

CBQ645

</td>

<td style="text-align:left;">

Calorie needed per day

</td>

</tr>

<tr>

<td style="text-align:left;">

9817

</td>

<td style="text-align:left;">

CBQ645

</td>

<td style="text-align:left;">

Calories needed per day

</td>

</tr>

<tr>

<td style="text-align:left;">

11585

</td>

<td style="text-align:left;">

CSQ120E

</td>

<td style="text-align:left;">

Taste in mouth Metalic

</td>

</tr>

<tr>

<td style="text-align:left;">

11620

</td>

<td style="text-align:left;">

CSQ120E

</td>

<td style="text-align:left;">

Taste in mouth Metallic

</td>

</tr>

<tr>

<td style="text-align:left;">

11599

</td>

<td style="text-align:left;">

CSQ240

</td>

<td style="text-align:left;">

Head Injury/Loss of counsciousness

</td>

</tr>

<tr>

<td style="text-align:left;">

11634

</td>

<td style="text-align:left;">

CSQ240

</td>

<td style="text-align:left;">

Head Injury/Loss of consciousness

</td>

</tr>

<tr>

<td style="text-align:left;">

11906

</td>

<td style="text-align:left;">

DBD020

</td>

<td style="text-align:left;">

Age started eating other foods (days)

</td>

</tr>

<tr>

<td style="text-align:left;">

11987

</td>

<td style="text-align:left;">

DBD020

</td>

<td style="text-align:left;">

Age started eating other foods(days)

</td>

</tr>

<tr>

<td style="text-align:left;">

11908

</td>

<td style="text-align:left;">

DBD040

</td>

<td style="text-align:left;">

Age first fed formula daily (days)

</td>

</tr>

<tr>

<td style="text-align:left;">

11989

</td>

<td style="text-align:left;">

DBD040

</td>

<td style="text-align:left;">

Age first fed formula daily(days)

</td>

</tr>

<tr>

<td style="text-align:left;">

11909

</td>

<td style="text-align:left;">

DBD050

</td>

<td style="text-align:left;">

Age stopped receiving formula (days)

</td>

</tr>

<tr>

<td style="text-align:left;">

11990

</td>

<td style="text-align:left;">

DBD050

</td>

<td style="text-align:left;">

Age stopped receiving formula(days)

</td>

</tr>

<tr>

<td style="text-align:left;">

12131

</td>

<td style="text-align:left;">

DBD055

</td>

<td style="text-align:left;">

Age started other than breastmilk/fomula

</td>

</tr>

<tr>

<td style="text-align:left;">

12331

</td>

<td style="text-align:left;">

DBD055

</td>

<td style="text-align:left;">

Age started other food/beverage

</td>

</tr>

<tr>

<td style="text-align:left;">

11910

</td>

<td style="text-align:left;">

DBD060

</td>

<td style="text-align:left;">

Age first fed milk daily basis (days)

</td>

</tr>

<tr>

<td style="text-align:left;">

11991

</td>

<td style="text-align:left;">

DBD060

</td>

<td style="text-align:left;">

Age first fed milk daily basis(days)

</td>

</tr>

<tr>

<td style="text-align:left;">

12026

</td>

<td style="text-align:left;">

DBD072A

</td>

<td style="text-align:left;">

Type of milk first fed-whole milk

</td>

</tr>

<tr>

<td style="text-align:left;">

12079

</td>

<td style="text-align:left;">

DBD072A

</td>

<td style="text-align:left;">

Type of milk first fed - whole milk

</td>

</tr>

<tr>

<td style="text-align:left;">

12027

</td>

<td style="text-align:left;">

DBD072B

</td>

<td style="text-align:left;">

Type of milk first fed-2% milk

</td>

</tr>

<tr>

<td style="text-align:left;">

12080

</td>

<td style="text-align:left;">

DBD072B

</td>

<td style="text-align:left;">

Type of milk first fed - 2% milk

</td>

</tr>

<tr>

<td style="text-align:left;">

12028

</td>

<td style="text-align:left;">

DBD072C

</td>

<td style="text-align:left;">

Type of milk first fed-1% milk

</td>

</tr>

<tr>

<td style="text-align:left;">

12081

</td>

<td style="text-align:left;">

DBD072C

</td>

<td style="text-align:left;">

Type of milk first fed - 1% milk

</td>

</tr>

<tr>

<td style="text-align:left;">

12029

</td>

<td style="text-align:left;">

DBD072D

</td>

<td style="text-align:left;">

Type of milk first fed-fat free milk

</td>

</tr>

<tr>

<td style="text-align:left;">

12082

</td>

<td style="text-align:left;">

DBD072D

</td>

<td style="text-align:left;">

Type of milk first fed - fat free milk

</td>

</tr>

<tr>

<td style="text-align:left;">

11916

</td>

<td style="text-align:left;">

DBD080

</td>

<td style="text-align:left;">

Age started eating solid foods (days)

</td>

</tr>

<tr>

<td style="text-align:left;">

11997

</td>

<td style="text-align:left;">

DBD080

</td>

<td style="text-align:left;">

Age started eating solid foods(days)

</td>

</tr>

<tr>

<td style="text-align:left;">

12037

</td>

<td style="text-align:left;">

DBD222D

</td>

<td style="text-align:left;">

You drink fat-free or skim milk

</td>

</tr>

<tr>

<td style="text-align:left;">

12090

</td>

<td style="text-align:left;">

DBD222D

</td>

<td style="text-align:left;">

You drink fat free/skim milk

</td>

</tr>

<tr>

<td style="text-align:left;">

11983

</td>

<td style="text-align:left;">

DBD411

</td>

<td style="text-align:left;">

\#of times/week get school breakfast

</td>

</tr>

<tr>

<td style="text-align:left;">

12016

</td>

<td style="text-align:left;">

DBD411

</td>

<td style="text-align:left;">

\# of times/week get school breakfast

</td>

</tr>

<tr>

<td style="text-align:left;">

11918

</td>

<td style="text-align:left;">

DBQ095

</td>

<td style="text-align:left;">

Type of salt used at table

</td>

</tr>

<tr>

<td style="text-align:left;">

17638

</td>

<td style="text-align:left;">

DBQ095

</td>

<td style="text-align:left;">

Type of salt you use

</td>

</tr>

<tr>

<td style="text-align:left;">

14599

</td>

<td style="text-align:left;">

DBQ095Z

</td>

<td style="text-align:left;">

Type of salt you use

</td>

</tr>

<tr>

<td style="text-align:left;">

14759

</td>

<td style="text-align:left;">

DBQ095Z

</td>

<td style="text-align:left;">

Type of table salt used

</td>

</tr>

<tr>

<td style="text-align:left;">

12005

</td>

<td style="text-align:left;">

DBQ229

</td>

<td style="text-align:left;">

Regular milk drinker

</td>

</tr>

<tr>

<td style="text-align:left;">

12039

</td>

<td style="text-align:left;">

DBQ229

</td>

<td style="text-align:left;">

Regular milk use 5 times per week

</td>

</tr>

<tr>

<td style="text-align:left;">

13207

</td>

<td style="text-align:left;">

DID060Q

</td>

<td style="text-align:left;">

Number of mos/yrs taking insulin

</td>

</tr>

<tr>

<td style="text-align:left;">

13224

</td>

<td style="text-align:left;">

DID060Q

</td>

<td style="text-align:left;">

Number of mons/yrs taking insulin

</td>

</tr>

<tr>

<td style="text-align:left;">

13545

</td>

<td style="text-align:left;">

DLQ040

</td>

<td style="text-align:left;">

Have serious difficulty concentrating ?

</td>

</tr>

<tr>

<td style="text-align:left;">

13552

</td>

<td style="text-align:left;">

DLQ040

</td>

<td style="text-align:left;">

Have serious difficulty concentrating?

</td>

</tr>

<tr>

<td style="text-align:left;">

13546

</td>

<td style="text-align:left;">

DLQ050

</td>

<td style="text-align:left;">

Have serious difficulty walking ?

</td>

</tr>

<tr>

<td style="text-align:left;">

13553

</td>

<td style="text-align:left;">

DLQ050

</td>

<td style="text-align:left;">

Have serious difficulty walking?

</td>

</tr>

<tr>

<td style="text-align:left;">

13548

</td>

<td style="text-align:left;">

DLQ080

</td>

<td style="text-align:left;">

Have difficulty doing errands alone ?

</td>

</tr>

</tbody>

</table>

This is mostly OK. But we need to look into some variables which have
potentially different units of measurement.

``` r
subset(multLabels, endsWith(SasLabel, "g)")) |>
  subset(Variable %in% names(which(table(Variable) > 1))) |>
  sort(by = ~ Variable) |> kable()
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

SasLabel

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

13958

</td>

<td style="text-align:left;">

DR1IFOLA

</td>

<td style="text-align:left;">

Total Folate (mcg)

</td>

</tr>

<tr>

<td style="text-align:left;">

14040

</td>

<td style="text-align:left;">

DR1IFOLA

</td>

<td style="text-align:left;">

Total folate (mcg)

</td>

</tr>

<tr>

<td style="text-align:left;">

14636

</td>

<td style="text-align:left;">

DR1TFOLA

</td>

<td style="text-align:left;">

Total Folate (mcg)

</td>

</tr>

<tr>

<td style="text-align:left;">

14796

</td>

<td style="text-align:left;">

DR1TFOLA

</td>

<td style="text-align:left;">

Total folate (mcg)

</td>

</tr>

<tr>

<td style="text-align:left;">

15950

</td>

<td style="text-align:left;">

DR2IFOLA

</td>

<td style="text-align:left;">

Total Folate (mcg)

</td>

</tr>

<tr>

<td style="text-align:left;">

16032

</td>

<td style="text-align:left;">

DR2IFOLA

</td>

<td style="text-align:left;">

Total folate (mcg)

</td>

</tr>

<tr>

<td style="text-align:left;">

16615

</td>

<td style="text-align:left;">

DR2TFOLA

</td>

<td style="text-align:left;">

Total Folate (mcg)

</td>

</tr>

<tr>

<td style="text-align:left;">

16696

</td>

<td style="text-align:left;">

DR2TFOLA

</td>

<td style="text-align:left;">

Total folate (mcg)

</td>

</tr>

<tr>

<td style="text-align:left;">

41256

</td>

<td style="text-align:left;">

LBC028

</td>

<td style="text-align:left;">

PCB 28 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41490

</td>

<td style="text-align:left;">

LBC028

</td>

<td style="text-align:left;">

PCB 28 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41268

</td>

<td style="text-align:left;">

LBC066

</td>

<td style="text-align:left;">

PCB 66 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41493

</td>

<td style="text-align:left;">

LBC066

</td>

<td style="text-align:left;">

PCB 66 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41271

</td>

<td style="text-align:left;">

LBC074

</td>

<td style="text-align:left;">

PCB 74 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41496

</td>

<td style="text-align:left;">

LBC074

</td>

<td style="text-align:left;">

PCB 74 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41277

</td>

<td style="text-align:left;">

LBC099

</td>

<td style="text-align:left;">

PCB 99 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41499

</td>

<td style="text-align:left;">

LBC099

</td>

<td style="text-align:left;">

PCB 99 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41283

</td>

<td style="text-align:left;">

LBC105

</td>

<td style="text-align:left;">

PCB 105 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41502

</td>

<td style="text-align:left;">

LBC105

</td>

<td style="text-align:left;">

PCB 105 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41289

</td>

<td style="text-align:left;">

LBC114

</td>

<td style="text-align:left;">

PCB 114 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41505

</td>

<td style="text-align:left;">

LBC114

</td>

<td style="text-align:left;">

PCB 114 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41292

</td>

<td style="text-align:left;">

LBC118

</td>

<td style="text-align:left;">

PCB 118 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41508

</td>

<td style="text-align:left;">

LBC118

</td>

<td style="text-align:left;">

PCB 118 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41301

</td>

<td style="text-align:left;">

LBC138

</td>

<td style="text-align:left;">

PCB 138 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41511

</td>

<td style="text-align:left;">

LBC138

</td>

<td style="text-align:left;">

PCB 138 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41304

</td>

<td style="text-align:left;">

LBC146

</td>

<td style="text-align:left;">

PCB 146 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41514

</td>

<td style="text-align:left;">

LBC146

</td>

<td style="text-align:left;">

PCB 146 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41313

</td>

<td style="text-align:left;">

LBC153

</td>

<td style="text-align:left;">

PCB 153 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41517

</td>

<td style="text-align:left;">

LBC153

</td>

<td style="text-align:left;">

PCB 153 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41316

</td>

<td style="text-align:left;">

LBC156

</td>

<td style="text-align:left;">

PCB 156 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41520

</td>

<td style="text-align:left;">

LBC156

</td>

<td style="text-align:left;">

PCB 156 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41319

</td>

<td style="text-align:left;">

LBC157

</td>

<td style="text-align:left;">

PCB 157 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41523

</td>

<td style="text-align:left;">

LBC157

</td>

<td style="text-align:left;">

PCB 157 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41322

</td>

<td style="text-align:left;">

LBC167

</td>

<td style="text-align:left;">

PCB 167 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41526

</td>

<td style="text-align:left;">

LBC167

</td>

<td style="text-align:left;">

PCB 167 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41325

</td>

<td style="text-align:left;">

LBC170

</td>

<td style="text-align:left;">

PCB 170 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41529

</td>

<td style="text-align:left;">

LBC170

</td>

<td style="text-align:left;">

PCB 170 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41334

</td>

<td style="text-align:left;">

LBC178

</td>

<td style="text-align:left;">

PCB 178 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41532

</td>

<td style="text-align:left;">

LBC178

</td>

<td style="text-align:left;">

PCB 178 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41337

</td>

<td style="text-align:left;">

LBC180

</td>

<td style="text-align:left;">

PCB 180 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41535

</td>

<td style="text-align:left;">

LBC180

</td>

<td style="text-align:left;">

PCB 180 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41340

</td>

<td style="text-align:left;">

LBC183

</td>

<td style="text-align:left;">

PCB 183 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41538

</td>

<td style="text-align:left;">

LBC183

</td>

<td style="text-align:left;">

PCB 183 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41343

</td>

<td style="text-align:left;">

LBC187

</td>

<td style="text-align:left;">

PCB 187 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41541

</td>

<td style="text-align:left;">

LBC187

</td>

<td style="text-align:left;">

PCB 187 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41346

</td>

<td style="text-align:left;">

LBC189

</td>

<td style="text-align:left;">

PCB 189 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41544

</td>

<td style="text-align:left;">

LBC189

</td>

<td style="text-align:left;">

PCB 189 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41349

</td>

<td style="text-align:left;">

LBC194

</td>

<td style="text-align:left;">

PCB 194 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41547

</td>

<td style="text-align:left;">

LBC194

</td>

<td style="text-align:left;">

PCB 194 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41355

</td>

<td style="text-align:left;">

LBC196

</td>

<td style="text-align:left;">

PCB 196 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41550

</td>

<td style="text-align:left;">

LBC196

</td>

<td style="text-align:left;">

PCB 196 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41358

</td>

<td style="text-align:left;">

LBC199

</td>

<td style="text-align:left;">

PCB 199 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41553

</td>

<td style="text-align:left;">

LBC199

</td>

<td style="text-align:left;">

PCB 199 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41361

</td>

<td style="text-align:left;">

LBC206

</td>

<td style="text-align:left;">

PCB 206 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41556

</td>

<td style="text-align:left;">

LBC206

</td>

<td style="text-align:left;">

PCB 206 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41364

</td>

<td style="text-align:left;">

LBC209

</td>

<td style="text-align:left;">

PCB 209 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

41559

</td>

<td style="text-align:left;">

LBC209

</td>

<td style="text-align:left;">

PCB 209 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7670

</td>

<td style="text-align:left;">

LBCBB1LA

</td>

<td style="text-align:left;">

22’44’55’-hxbrmbiphl lipd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7754

</td>

<td style="text-align:left;">

LBCBB1LA

</td>

<td style="text-align:left;">

22’44’55’-hxbrmbiphl lpd adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43215

</td>

<td style="text-align:left;">

LBCBHC

</td>

<td style="text-align:left;">

Beta-hexachlorocyclohexane (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43281

</td>

<td style="text-align:left;">

LBCBHC

</td>

<td style="text-align:left;">

Beta-hexachlorocyclohexane (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7675

</td>

<td style="text-align:left;">

LBCBR11

</td>

<td style="text-align:left;">

PBDE 209 (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7759

</td>

<td style="text-align:left;">

LBCBR11

</td>

<td style="text-align:left;">

Decabromodiphenyl ether (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7676

</td>

<td style="text-align:left;">

LBCBR11L

</td>

<td style="text-align:left;">

PBDE 209 lipid adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7760

</td>

<td style="text-align:left;">

LBCBR11L

</td>

<td style="text-align:left;">

Decabromodiphenyl ether lipid adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7673

</td>

<td style="text-align:left;">

LBCBR1LA

</td>

<td style="text-align:left;">

22’4-tribromodiphl ether lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7757

</td>

<td style="text-align:left;">

LBCBR1LA

</td>

<td style="text-align:left;">

22’4-tribrmobiphl ether lpd adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7679

</td>

<td style="text-align:left;">

LBCBR2LA

</td>

<td style="text-align:left;">

244’-tribrmdphenyl ether lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7763

</td>

<td style="text-align:left;">

LBCBR2LA

</td>

<td style="text-align:left;">

244’-tribrmdphenyl ethr lpd adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7681

</td>

<td style="text-align:left;">

LBCBR3

</td>

<td style="text-align:left;">

22’44’-tetrabromodiphenyl ether(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7765

</td>

<td style="text-align:left;">

LBCBR3

</td>

<td style="text-align:left;">

22’44’-tetrabromodiphenyl ethr (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7682

</td>

<td style="text-align:left;">

LBCBR3LA

</td>

<td style="text-align:left;">

22’44’-tetrmdiphnyl ethr lpd ad(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7766

</td>

<td style="text-align:left;">

LBCBR3LA

</td>

<td style="text-align:left;">

22’44’-tebrmdphnyl ethr lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7684

</td>

<td style="text-align:left;">

LBCBR4

</td>

<td style="text-align:left;">

22’344’-pentbromodiphnyl ether(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7768

</td>

<td style="text-align:left;">

LBCBR4

</td>

<td style="text-align:left;">

22’344’-pentbromodiphenyl ethr(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7685

</td>

<td style="text-align:left;">

LBCBR4LA

</td>

<td style="text-align:left;">

22’344’-pentabromphnyl lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7769

</td>

<td style="text-align:left;">

LBCBR4LA

</td>

<td style="text-align:left;">

22’344’-pntabromphnyl lpd adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7688

</td>

<td style="text-align:left;">

LBCBR5LA

</td>

<td style="text-align:left;">

22’44’5-pentabrompheyl lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7772

</td>

<td style="text-align:left;">

LBCBR5LA

</td>

<td style="text-align:left;">

22’44’5-pntabromphenyl lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7697

</td>

<td style="text-align:left;">

LBCBR7LA

</td>

<td style="text-align:left;">

22’44’55’-hxbrompheyl lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7781

</td>

<td style="text-align:left;">

LBCBR7LA

</td>

<td style="text-align:left;">

22’44’55’-hxbrmphenyl lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7699

</td>

<td style="text-align:left;">

LBCBR8

</td>

<td style="text-align:left;">

22’44’56’hexabromodiphyl ethr(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7783

</td>

<td style="text-align:left;">

LBCBR8

</td>

<td style="text-align:left;">

22’44’56’-hxabromodiphyl ethr(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7700

</td>

<td style="text-align:left;">

LBCBR8LA

</td>

<td style="text-align:left;">

22’44’56’-hxabromphyl lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7784

</td>

<td style="text-align:left;">

LBCBR8LA

</td>

<td style="text-align:left;">

22’44’56’-hxbrmphenyl lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7702

</td>

<td style="text-align:left;">

LBCBR9

</td>

<td style="text-align:left;">

22’344’56heptbromdiphyl ethr(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7786

</td>

<td style="text-align:left;">

LBCBR9

</td>

<td style="text-align:left;">

22’344’5’6-hptbrodiphyl ethr(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7703

</td>

<td style="text-align:left;">

LBCBR9LA

</td>

<td style="text-align:left;">

22’344’5’6-heptbrphl lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7787

</td>

<td style="text-align:left;">

LBCBR9LA

</td>

<td style="text-align:left;">

22’344’5’6-hptbrphnl lpd adj(ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13594

</td>

<td style="text-align:left;">

LBCD05LA

</td>

<td style="text-align:left;">

1234678-hpcdd lipid adjusted(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13726

</td>

<td style="text-align:left;">

LBCD05LA

</td>

<td style="text-align:left;">

1234678-hpcdd lipid adjust (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13602

</td>

<td style="text-align:left;">

LBCF02

</td>

<td style="text-align:left;">

12378-Pentachlorofuran(pncdf)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13668

</td>

<td style="text-align:left;">

LBCF02

</td>

<td style="text-align:left;">

12378-Pentachlorofuran (pncdf)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13734

</td>

<td style="text-align:left;">

LBCF02

</td>

<td style="text-align:left;">

12378-Pentachlorofuran(pncdf) (fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13605

</td>

<td style="text-align:left;">

LBCF03

</td>

<td style="text-align:left;">

23478-Pentachlorofuran(pncdf)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13671

</td>

<td style="text-align:left;">

LBCF03

</td>

<td style="text-align:left;">

23478-Pentachlorofuran (pncdf)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13737

</td>

<td style="text-align:left;">

LBCF03

</td>

<td style="text-align:left;">

23478-Pentachlorofuran(pncdf) (fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13606

</td>

<td style="text-align:left;">

LBCF03LA

</td>

<td style="text-align:left;">

23478-pncdf lipid adjusted (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13738

</td>

<td style="text-align:left;">

LBCF03LA

</td>

<td style="text-align:left;">

23478-pncdf lipid adjust (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13608

</td>

<td style="text-align:left;">

LBCF04

</td>

<td style="text-align:left;">

123478-Hexachlorofuran(hcxdf)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13740

</td>

<td style="text-align:left;">

LBCF04

</td>

<td style="text-align:left;">

123478-hcxdf (fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13611

</td>

<td style="text-align:left;">

LBCF05

</td>

<td style="text-align:left;">

123678-Hexachlorofuran(hxcdf)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13743

</td>

<td style="text-align:left;">

LBCF05

</td>

<td style="text-align:left;">

123678-hxcdf (fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13614

</td>

<td style="text-align:left;">

LBCF06

</td>

<td style="text-align:left;">

123789-Hexachlorodifuran (fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13680

</td>

<td style="text-align:left;">

LBCF06

</td>

<td style="text-align:left;">

123789-Hexachlorodifuran(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13621

</td>

<td style="text-align:left;">

LBCF08LA

</td>

<td style="text-align:left;">

1234678-hpcdf lipid adjusted(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13753

</td>

<td style="text-align:left;">

LBCF08LA

</td>

<td style="text-align:left;">

1234678-hpcdf lipid adjust (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13624

</td>

<td style="text-align:left;">

LBCF09LA

</td>

<td style="text-align:left;">

1234789-hpcdf lipid adjusted(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13756

</td>

<td style="text-align:left;">

LBCF09LA

</td>

<td style="text-align:left;">

1234789-hpcdf lipid adjust (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43218

</td>

<td style="text-align:left;">

LBCGHC

</td>

<td style="text-align:left;">

Gamma-hexachlorocyclohexane (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43284

</td>

<td style="text-align:left;">

LBCGHC

</td>

<td style="text-align:left;">

Gamma-hexachlorocyclohexane (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43221

</td>

<td style="text-align:left;">

LBCHCB

</td>

<td style="text-align:left;">

Hexachlorobenzene (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43287

</td>

<td style="text-align:left;">

LBCHCB

</td>

<td style="text-align:left;">

Hexachlorobenzene (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13629

</td>

<td style="text-align:left;">

LBCHXC

</td>

<td style="text-align:left;">

33’44’55’-hexachlorobiphenyl(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13695

</td>

<td style="text-align:left;">

LBCHXC

</td>

<td style="text-align:left;">

33’44’55’-hexachlorobiphenyl (fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13630

</td>

<td style="text-align:left;">

LBCHXCLA

</td>

<td style="text-align:left;">

33’44’55’-hxcb Lipid adjusted(pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13762

</td>

<td style="text-align:left;">

LBCHXCLA

</td>

<td style="text-align:left;">

33’44’55’-hxcb lipid adjust (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43224

</td>

<td style="text-align:left;">

LBCMIR

</td>

<td style="text-align:left;">

Mirex (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43290

</td>

<td style="text-align:left;">

LBCMIR

</td>

<td style="text-align:left;">

Mirex (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43230

</td>

<td style="text-align:left;">

LBCOXY

</td>

<td style="text-align:left;">

Oxychlordane (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43293

</td>

<td style="text-align:left;">

LBCOXY

</td>

<td style="text-align:left;">

Oxychlordane (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43233

</td>

<td style="text-align:left;">

LBCPDE

</td>

<td style="text-align:left;">

pp’-DDE (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43296

</td>

<td style="text-align:left;">

LBCPDE

</td>

<td style="text-align:left;">

pp’-DDE (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43236

</td>

<td style="text-align:left;">

LBCPDT

</td>

<td style="text-align:left;">

pp’-DDT (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43299

</td>

<td style="text-align:left;">

LBCPDT

</td>

<td style="text-align:left;">

pp’-DDT (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13635

</td>

<td style="text-align:left;">

LBCTC2

</td>

<td style="text-align:left;">

344’5-Tetrachlorobiphenyl(tcb)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13701

</td>

<td style="text-align:left;">

LBCTC2

</td>

<td style="text-align:left;">

344’5-Tetrachlorobiphenyl (tcb)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13767

</td>

<td style="text-align:left;">

LBCTC2

</td>

<td style="text-align:left;">

344’5-Tetrachlorobiphenyl(tcb) (fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13638

</td>

<td style="text-align:left;">

LBCTCD

</td>

<td style="text-align:left;">

2378-Tetrachloro-p-dioxn(tcdd)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13704

</td>

<td style="text-align:left;">

LBCTCD

</td>

<td style="text-align:left;">

2378-Tetrachloro-p-dioxin(tcdd)(fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

13770

</td>

<td style="text-align:left;">

LBCTCD

</td>

<td style="text-align:left;">

2378-Tetrachloro-p-dioxn(tcdd) (fg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43239

</td>

<td style="text-align:left;">

LBCTNA

</td>

<td style="text-align:left;">

trans-Nonachlor (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

43302

</td>

<td style="text-align:left;">

LBCTNA

</td>

<td style="text-align:left;">

trans-Nonachlor (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28182

</td>

<td style="text-align:left;">

LBX138

</td>

<td style="text-align:left;">

PCB138 & 158 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28345

</td>

<td style="text-align:left;">

LBX138

</td>

<td style="text-align:left;">

PCB138 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28183

</td>

<td style="text-align:left;">

LBX138LA

</td>

<td style="text-align:left;">

PCB138 & 158 Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28346

</td>

<td style="text-align:left;">

LBX138LA

</td>

<td style="text-align:left;">

PCB138 Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28224

</td>

<td style="text-align:left;">

LBX196

</td>

<td style="text-align:left;">

PCB196 & 203 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28399

</td>

<td style="text-align:left;">

LBX196

</td>

<td style="text-align:left;">

PCB196 (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28225

</td>

<td style="text-align:left;">

LBX196LA

</td>

<td style="text-align:left;">

PCB196 & 203 Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28400

</td>

<td style="text-align:left;">

LBX196LA

</td>

<td style="text-align:left;">

PCB196 Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28136

</td>

<td style="text-align:left;">

LBXF08LA

</td>

<td style="text-align:left;">

1234678-hpcdf Lipid Adj (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28448

</td>

<td style="text-align:left;">

LBXF08LA

</td>

<td style="text-align:left;">

1234678-hxcdf Lipid Adj (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28254

</td>

<td style="text-align:left;">

LBXODTLA

</td>

<td style="text-align:left;">

opDDT Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28484

</td>

<td style="text-align:left;">

LBXODTLA

</td>

<td style="text-align:left;">

op’-DDT Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28145

</td>

<td style="text-align:left;">

LBXPCBLA

</td>

<td style="text-align:left;">

33’44’5-pncb Lipid Adj (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28457

</td>

<td style="text-align:left;">

LBXPCBLA

</td>

<td style="text-align:left;">

33’44’5-pcnb Lipid Adj (pg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28248

</td>

<td style="text-align:left;">

LBXPDELA

</td>

<td style="text-align:left;">

ppDDE Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28490

</td>

<td style="text-align:left;">

LBXPDELA

</td>

<td style="text-align:left;">

pp’-DDE Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28251

</td>

<td style="text-align:left;">

LBXPDTLA

</td>

<td style="text-align:left;">

ppDDT Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

28493

</td>

<td style="text-align:left;">

LBXPDTLA

</td>

<td style="text-align:left;">

pp’-DDT Lipid Adj (ng/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

7975

</td>

<td style="text-align:left;">

LBXSOSSI

</td>

<td style="text-align:left;">

Osmolality (mmol/Kg)

</td>

</tr>

<tr>

<td style="text-align:left;">

28806

</td>

<td style="text-align:left;">

LBXSOSSI

</td>

<td style="text-align:left;">

Osmolality: SI (mmol/Kg)

</td>

</tr>

<tr>

<td style="text-align:left;">

29166

</td>

<td style="text-align:left;">

LBXSOSSI

</td>

<td style="text-align:left;">

Osmolality (mOsm/kg)

</td>

</tr>

<tr>

<td style="text-align:left;">

181

</td>

<td style="text-align:left;">

URDACT

</td>

<td style="text-align:left;">

First albumin creatinine ratio (mg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

192

</td>

<td style="text-align:left;">

URDACT

</td>

<td style="text-align:left;">

Albumin creatinine ratio (mg/g)

</td>

</tr>

<tr>

<td style="text-align:left;">

48756

</td>

<td style="text-align:left;">

VIXKLCG

</td>

<td style="text-align:left;">

Left keratometry axis average (deg)

</td>

</tr>

<tr>

<td style="text-align:left;">

48870

</td>

<td style="text-align:left;">

VIXKLCG

</td>

<td style="text-align:left;">

Left keratometry axis (deg)

</td>

</tr>

<tr>

<td style="text-align:left;">

48746

</td>

<td style="text-align:left;">

VIXKRCG

</td>

<td style="text-align:left;">

Right keratometry axis average (deg)

</td>

</tr>

<tr>

<td style="text-align:left;">

48860

</td>

<td style="text-align:left;">

VIXKRCG

</td>

<td style="text-align:left;">

Right keratometry axis (deg)

</td>

</tr>

</tbody>

</table>

Similarly those with multiple descriptions.

``` r
multDesc <- subset(unique(variableDesc[c("Variable", "Description")]),
                   Variable %in% names(which(table(Variable) > 1)))
sort(multDesc, by = ~ Variable) |> head(100) |> kable()
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

Description

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

35

</td>

<td style="text-align:left;">

ACD040

</td>

<td style="text-align:left;">

What language(s) {do you/does SP} usually speak at home? Would you say…

</td>

</tr>

<tr>

<td style="text-align:left;">

66

</td>

<td style="text-align:left;">

ACD040

</td>

<td style="text-align:left;">

Now I’m going to ask you about language use. What language(s) {do
you/does SP} usually speak at home?

</td>

</tr>

<tr>

<td style="text-align:left;">

81

</td>

<td style="text-align:left;">

ACD040

</td>

<td style="text-align:left;">

Now I’m going to ask you about language use. What language(s) {do
you/does SP} usually speak at home? {Do you/Does he/Does she} speak only
Spanish more Spanish than English both equally more English than Spanish
or only English?

</td>

</tr>

<tr>

<td style="text-align:left;">

34

</td>

<td style="text-align:left;">

ACQ030

</td>

<td style="text-align:left;">

What was the language(s) {you/SP} used as a child? Would you say …

</td>

</tr>

<tr>

<td style="text-align:left;">

45

</td>

<td style="text-align:left;">

ACQ030

</td>

<td style="text-align:left;">

What was the language(s) {you/SP} used as a child? Would you say GÇª

</td>

</tr>

<tr>

<td style="text-align:left;">

56

</td>

<td style="text-align:left;">

ACQ030

</td>

<td style="text-align:left;">

What was the language(s) {you/SP} used as a child? Would you say…

</td>

</tr>

<tr>

<td style="text-align:left;">

339

</td>

<td style="text-align:left;">

ALQ101

</td>

<td style="text-align:left;">

The next questions are about drinking alcoholic beverages. Included are
liquor (such as whiskey or gin) beer wine wine coolers and any other
type of alcoholic beverage. In any one year {have you/has SP} had at
least 12 drinks of any type of alcoholic beverage? By a drink I mean a
12 oz. beer a 4 oz. glass of wine or an ounce of liquor.

</td>

</tr>

<tr>

<td style="text-align:left;">

348

</td>

<td style="text-align:left;">

ALQ101

</td>

<td style="text-align:left;">

The next questions are about drinking alcoholic beverages. Included are
liquor (such as whiskey or gin) beer wine wine coolers and any other
type of alcoholic beverage.In any one year {have you/has SP} had at
least 12 drinks of any type of alcoholic beverage? By a drink I mean a
12 oz. beer a 5 oz. glass of wine or one and half ounces of liquor.

</td>

</tr>

<tr>

<td style="text-align:left;">

395

</td>

<td style="text-align:left;">

ALQ101

</td>

<td style="text-align:left;">

In any one year {have you/has SP} had at least 12 drinks of any type of
alcoholic beverage? By a drink I mean a 12 oz. beer a 5 oz. glass of
wine or a one and a half ounces of liquor.

</td>

</tr>

<tr>

<td style="text-align:left;">

322

</td>

<td style="text-align:left;">

ALQ110

</td>

<td style="text-align:left;">

In {your/SP’s} entire life {have you/has he/ has she} had at least 12
drinks of any type of alcoholic beverage?

</td>

</tr>

<tr>

<td style="text-align:left;">

396

</td>

<td style="text-align:left;">

ALQ110

</td>

<td style="text-align:left;">

In {your/SP’s} entire life {have you/has he/has she} had at least 12
drinks of any type of alcoholic beverage?

</td>

</tr>

<tr>

<td style="text-align:left;">

325

</td>

<td style="text-align:left;">

ALQ130

</td>

<td style="text-align:left;">

In the past 12 months on those days that {you/SP} drank alcoholic
beverages on the average how many drinks did {you/he/she} have?

</td>

</tr>

<tr>

<td style="text-align:left;">

399

</td>

<td style="text-align:left;">

ALQ130

</td>

<td style="text-align:left;">

In the past 12 months on those days that {you/SP} drank alcoholic
beverages on the average how many drinks did {you/he/she} have? By a
drink I mean a 12 oz. beer a 5 oz. glass of wine or one and a half
ounces of liquor.)

</td>

</tr>

<tr>

<td style="text-align:left;">

407

</td>

<td style="text-align:left;">

ALQ130

</td>

<td style="text-align:left;">

During the past 12 months on those days that {you/SP} drank alcoholic
beverages on the average how many drinks did {you/he/she} have? By a
drink I mean a 12 oz. beer a 5 oz. glass of wine or one and a half
ounces of liquor.)

</td>

</tr>

<tr>

<td style="text-align:left;">

380

</td>

<td style="text-align:left;">

ALQ141Q

</td>

<td style="text-align:left;">

In the past 12 months on how many days did {you/SP} have {DISPLAY
NUMBER} or more drinks of any alcoholic beverage? PROBE: How many days
per week per month or per year did {you/SP} have {DISPLAY NUMBER} or
more drinks in a single day?

</td>

</tr>

<tr>

<td style="text-align:left;">

400

</td>

<td style="text-align:left;">

ALQ141Q

</td>

<td style="text-align:left;">

In the past 12 months on how many days did {you/SP} have {Display
number} or more drinks of any alcoholic beverage? PROBE: How many days
per week per month or per year did {you/SP} have {DISPLAY NUMBER} or
more drinks in a single day?

</td>

</tr>

<tr>

<td style="text-align:left;">

907

</td>

<td style="text-align:left;">

AUALEQC

</td>

<td style="text-align:left;">

Left Ear Quality Code

</td>

</tr>

<tr>

<td style="text-align:left;">

1051

</td>

<td style="text-align:left;">

AUALEQC

</td>

<td style="text-align:left;">

Quality Code for Tympanogram of Left Ear

</td>

</tr>

<tr>

<td style="text-align:left;">

908

</td>

<td style="text-align:left;">

AUAREQC

</td>

<td style="text-align:left;">

Right Ear Quality Code

</td>

</tr>

<tr>

<td style="text-align:left;">

1050

</td>

<td style="text-align:left;">

AUAREQC

</td>

<td style="text-align:left;">

Quality Code for Tympanogram of Right Ear

</td>

</tr>

<tr>

<td style="text-align:left;">

844

</td>

<td style="text-align:left;">

AUQ020B

</td>

<td style="text-align:left;">

Have you had a sinus problem in the last 24 hours

</td>

</tr>

<tr>

<td style="text-align:left;">

1359

</td>

<td style="text-align:left;">

AUQ020B

</td>

<td style="text-align:left;">

Have you had a sinus problem in the last 24 hours?

</td>

</tr>

<tr>

<td style="text-align:left;">

719

</td>

<td style="text-align:left;">

AUQ054

</td>

<td style="text-align:left;">

These next questions are about {your/SP’s} hearing. Which statement best
describes {your/SP’s} hearing (without a hearing aid or other listening
devices)? Would you say {your/his/her} hearing is excellent good that
{you have/s/he has} a little trouble moderate trouble a lot of trouble
or {are you/is s/he} deaf?

</td>

</tr>

<tr>

<td style="text-align:left;">

779

</td>

<td style="text-align:left;">

AUQ054

</td>

<td style="text-align:left;">

These next questions are about {your/SP’s} hearing. Which statement best
describes {your/SP’s} hearing (without a hearing aid personal sound
amplifier or other listening devices)? Would you say {your/his/her}
hearing is excellent good that {you have/s/he has} a little trouble
moderate trouble a lot of trouble or {are you/is s/he} deaf?

</td>

</tr>

<tr>

<td style="text-align:left;">

723

</td>

<td style="text-align:left;">

AUQ090

</td>

<td style="text-align:left;">

Can {you/SP} usually hear and understand what a person says without
seeing his or her face if that person speaks loudly into {your/his/her}
better ear?

</td>

</tr>

<tr>

<td style="text-align:left;">

783

</td>

<td style="text-align:left;">

AUQ090

</td>

<td style="text-align:left;">

Can{you/SP} usually hear and understand what a person says without
seeing his or her face if that person speaks loudly into {your/his/her}
better ear?

</td>

</tr>

<tr>

<td style="text-align:left;">

669

</td>

<td style="text-align:left;">

AUQ136

</td>

<td style="text-align:left;">

{Have you/Has SP} ever had 3 or more ear infections?

</td>

</tr>

<tr>

<td style="text-align:left;">

726

</td>

<td style="text-align:left;">

AUQ136

</td>

<td style="text-align:left;">

{Have you/Has SP} ever had 3 or more ear infections? Please include ear
infections {you/he/she} may have had when {you were/he was/she was} a
child.

</td>

</tr>

<tr>

<td style="text-align:left;">

728

</td>

<td style="text-align:left;">

AUQ144

</td>

<td style="text-align:left;">

A hearing test by a specialist is one that is done in a sound proof
booth or room or with headphones. Hearing specialists include
audiologists ear nose and throat doctors and trained technicians or
occupational nurses. When was the last time {you had/SP had}
{your/his/her} hearing tested by a hearing specialist?

</td>

</tr>

<tr>

<td style="text-align:left;">

799

</td>

<td style="text-align:left;">

AUQ144

</td>

<td style="text-align:left;">

A hearing test by a specialist is one that is done in a sound proof
booth or room or with headphones. Hearing specialists include
audiologists ear nose and throat doctors and trained technicians or
occupational nurses. When was the last time {you /SP} had {your/his/her}
hearing tested by a hearing specialist?

</td>

</tr>

<tr>

<td style="text-align:left;">

679

</td>

<td style="text-align:left;">

AUQ280

</td>

<td style="text-align:left;">

How much of a problem is this ringing roaring or buzzing in
{your/his/her} ears or head?

</td>

</tr>

<tr>

<td style="text-align:left;">

768

</td>

<td style="text-align:left;">

AUQ280

</td>

<td style="text-align:left;">

How much of a problem is this ringing roaring or buzzing in
{your/his/her} ears or head? Would you say…

</td>

</tr>

<tr>

<td style="text-align:left;">

742

</td>

<td style="text-align:left;">

AUQ330

</td>

<td style="text-align:left;">

These next questions are about noise exposure {you/SP} may have had at
work. {Have you/Has SP} ever had a job or combination of jobs where {you
were/s/he was} exposed to loud sounds or noise for 4 or more hours a day
several days a week? Loud means so loud that {you/s/he} must speak in a
raised voice to be heard.

</td>

</tr>

<tr>

<td style="text-align:left;">

829

</td>

<td style="text-align:left;">

AUQ330

</td>

<td style="text-align:left;">

These next questions are about noise exposure {you/SP} may have had at
work. {Have you/Has SP} ever had a job or combination of jobs where {you
were/s/he was} exposed to loud sounds or noise for 4 or more hours a day
several days a week? (Loud means so loud that {you/s/he} must speak in a
raised voice to be heard.)

</td>

</tr>

<tr>

<td style="text-align:left;">

744

</td>

<td style="text-align:left;">

AUQ350

</td>

<td style="text-align:left;">

In {your/SP’s} work {were you/was he/was she} exposed to very loud
noise? Very loud noise is noise that is so loud {you have/he has/she
has} to shout in order to be understood by someone standing 3 feet away
from {you/him/her}.

</td>

</tr>

<tr>

<td style="text-align:left;">

774

</td>

<td style="text-align:left;">

AUQ350

</td>

<td style="text-align:left;">

In {your/SP’s} work {were you/was he/was she} exposed to very loud
noise? (Very loud noise is noise that is so loud {you have/he has/she
has} to shout in order to be understood by someone standing 3 feet away
from {you/him/her}.)

</td>

</tr>

<tr>

<td style="text-align:left;">

747

</td>

<td style="text-align:left;">

AUQ380

</td>

<td style="text-align:left;">

In the past 12 months how often {did you/did SP} wear hearing protection
devices (ear plugs ear muffs) when exposed to very loud sounds or noise?
Please include both on the job and off the job exposures.

</td>

</tr>

<tr>

<td style="text-align:left;">

835

</td>

<td style="text-align:left;">

AUQ380

</td>

<td style="text-align:left;">

In the past 12 months how often did {you/SP} wear hearing protection
devices (ear plugs ear muffs) when exposed to very loud sounds or noise?

</td>

</tr>

<tr>

<td style="text-align:left;">

901

</td>

<td style="text-align:left;">

AUXR1K2L

</td>

<td style="text-align:left;">

Left retest threshold @ 1000Hz second reading in decibels (Hearing
Level)

</td>

</tr>

<tr>

<td style="text-align:left;">

1044

</td>

<td style="text-align:left;">

AUXR1K2L

</td>

<td style="text-align:left;">

Left retest threshold @ 1000Hz (second reading) in decibels (Hearing
Level)

</td>

</tr>

<tr>

<td style="text-align:left;">

893

</td>

<td style="text-align:left;">

AUXR1K2R

</td>

<td style="text-align:left;">

Right retest threshold @ 1000Hz second reading (db)

</td>

</tr>

<tr>

<td style="text-align:left;">

1036

</td>

<td style="text-align:left;">

AUXR1K2R

</td>

<td style="text-align:left;">

Right retest threshold @ 1000Hz (second reading) in decibels (Hearing
Level)

</td>

</tr>

<tr>

<td style="text-align:left;">

906

</td>

<td style="text-align:left;">

AUXR8KL

</td>

<td style="text-align:left;">

Left retest threshold @ 8000Hzin decibels (Hearing Level)

</td>

</tr>

<tr>

<td style="text-align:left;">

1049

</td>

<td style="text-align:left;">

AUXR8KL

</td>

<td style="text-align:left;">

Left retest threshold @ 8000Hz in decibels (Hearing Level)

</td>

</tr>

<tr>

<td style="text-align:left;">

867

</td>

<td style="text-align:left;">

AUXTMEPL

</td>

<td style="text-align:left;">

Middle ear pressure (tympanometry) left ear

</td>

</tr>

<tr>

<td style="text-align:left;">

1081

</td>

<td style="text-align:left;">

AUXTMEPL

</td>

<td style="text-align:left;">

Middle ear pressure (tympanometry) left ear in daPa (dekaPascals)

</td>

</tr>

<tr>

<td style="text-align:left;">

863

</td>

<td style="text-align:left;">

AUXTMEPR

</td>

<td style="text-align:left;">

Middle ear pressure (tympanometry) right ear

</td>

</tr>

<tr>

<td style="text-align:left;">

1077

</td>

<td style="text-align:left;">

AUXTMEPR

</td>

<td style="text-align:left;">

Middle ear pressure (tympanometry) right ear in daPa (dekaPascals)

</td>

</tr>

<tr>

<td style="text-align:left;">

868

</td>

<td style="text-align:left;">

AUXTPVL

</td>

<td style="text-align:left;">

Physical volume (tympanometry) left ear

</td>

</tr>

<tr>

<td style="text-align:left;">

1082

</td>

<td style="text-align:left;">

AUXTPVL

</td>

<td style="text-align:left;">

Physical volume (tympanometry) left ear in cc

</td>

</tr>

<tr>

<td style="text-align:left;">

864

</td>

<td style="text-align:left;">

AUXTPVR

</td>

<td style="text-align:left;">

Physical volume (tympanometry) right ear

</td>

</tr>

<tr>

<td style="text-align:left;">

1078

</td>

<td style="text-align:left;">

AUXTPVR

</td>

<td style="text-align:left;">

Physical volume (tympanometry) right ear in cc

</td>

</tr>

<tr>

<td style="text-align:left;">

885

</td>

<td style="text-align:left;">

AUXU1K2L

</td>

<td style="text-align:left;">

Left threshold @ 1000Hz (second reading)in decibels (Hearing Level)

</td>

</tr>

<tr>

<td style="text-align:left;">

1028

</td>

<td style="text-align:left;">

AUXU1K2L

</td>

<td style="text-align:left;">

Left threshold @ 1000Hz (second reading) in decibels (Hearing Level)

</td>

</tr>

<tr>

<td style="text-align:left;">

877

</td>

<td style="text-align:left;">

AUXU1K2R

</td>

<td style="text-align:left;">

Right threshold @ 1000Hz (second reading)in decibels (Hearing Level)

</td>

</tr>

<tr>

<td style="text-align:left;">

1020

</td>

<td style="text-align:left;">

AUXU1K2R

</td>

<td style="text-align:left;">

Right threshold @ 1000Hz (second reading) in decibels (Hearing Level)

</td>

</tr>

<tr>

<td style="text-align:left;">

8746

</td>

<td style="text-align:left;">

BMDAVSAD

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

8772

</td>

<td style="text-align:left;">

BMDAVSAD

</td>

<td style="text-align:left;">

Average Sagittal Abdominal Diameter (cm)

</td>

</tr>

<tr>

<td style="text-align:left;">

8733

</td>

<td style="text-align:left;">

BMDBMIC

</td>

<td style="text-align:left;">

BMI Category - Children/Adolescents

</td>

</tr>

<tr>

<td style="text-align:left;">

8759

</td>

<td style="text-align:left;">

BMDBMIC

</td>

<td style="text-align:left;">

BMI Category - Children/Youth

</td>

</tr>

<tr>

<td style="text-align:left;">

8835

</td>

<td style="text-align:left;">

BPQ050A

</td>

<td style="text-align:left;">

HELP AVAILABLE (Are you/Is SP) now taking prescribed medicine

</td>

</tr>

<tr>

<td style="text-align:left;">

9030

</td>

<td style="text-align:left;">

BPQ050A

</td>

<td style="text-align:left;">

{Are you/Is SP} now taking prescribed medicine?

</td>

</tr>

<tr>

<td style="text-align:left;">

9065

</td>

<td style="text-align:left;">

BPXDAR

</td>

<td style="text-align:left;">

Diastolic blood pressure average:

</td>

</tr>

<tr>

<td style="text-align:left;">

9125

</td>

<td style="text-align:left;">

BPXDAR

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

9047

</td>

<td style="text-align:left;">

BPXPLS

</td>

<td style="text-align:left;">

60 sec. pulse (30 sec. pulse \* 2):

</td>

</tr>

<tr>

<td style="text-align:left;">

9219

</td>

<td style="text-align:left;">

BPXPLS

</td>

<td style="text-align:left;">

60 sec. pulse (30 sec. pulse \* 2)

</td>

</tr>

<tr>

<td style="text-align:left;">

9050

</td>

<td style="text-align:left;">

BPXPTY

</td>

<td style="text-align:left;">

Pulse type:

</td>

</tr>

<tr>

<td style="text-align:left;">

9221

</td>

<td style="text-align:left;">

BPXPTY

</td>

<td style="text-align:left;">

Pulse type

</td>

</tr>

<tr>

<td style="text-align:left;">

9064

</td>

<td style="text-align:left;">

BPXSAR

</td>

<td style="text-align:left;">

Systolic blood pressure average:

</td>

</tr>

<tr>

<td style="text-align:left;">

9124

</td>

<td style="text-align:left;">

BPXSAR

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

9702

</td>

<td style="text-align:left;">

CBD740

</td>

<td style="text-align:left;">

{Now please look at the examples on hand card 10} In the past 30 days
did you buy any food that was labeled ‘organic’?

</td>

</tr>

<tr>

<td style="text-align:left;">

9782

</td>

<td style="text-align:left;">

CBD740

</td>

<td style="text-align:left;">

In the past 30 days did you buy any food that had the word ‘organic’ on
the package?

</td>

</tr>

<tr>

<td style="text-align:left;">

9649

</td>

<td style="text-align:left;">

CBQ502

</td>

<td style="text-align:left;">

You will need the green hand card booklet that is in the same bag as the
food measuring guides we used for your dietary phone interview. I’ll
wait while you locate it. Do you have it?

</td>

</tr>

<tr>

<td style="text-align:left;">

9794

</td>

<td style="text-align:left;">

CBQ502

</td>

<td style="text-align:left;">

Do you have the green hand card booklet? {It is in the same bag as the
food measuring guides \[you used for your/we used for SPGÇÖs\] dietary
phone interview. I’ll wait while you locate it. Do you have it?}

</td>

</tr>

<tr>

<td style="text-align:left;">

9651

</td>

<td style="text-align:left;">

CBQ505

</td>

<td style="text-align:left;">

{Great. I’ll tell you when you will need it.} For the first few
questions please answer yes or no. In the past 12 months did you buy
food from fast food or pizza places?

</td>

</tr>

<tr>

<td style="text-align:left;">

12266

</td>

<td style="text-align:left;">

CBQ505

</td>

<td style="text-align:left;">

{I’ll tell you when you will need it.} For the first few questions
please answer yes or no. In the past 12 months did you buy food from
fast food or pizza places? SP interview version: In the past 12 months
did {you/SP} buy food from fast food or pizza places?

</td>

</tr>

<tr>

<td style="text-align:left;">

12317

</td>

<td style="text-align:left;">

CBQ505

</td>

<td style="text-align:left;">

{I’ll tell you when you will need it.} For the first few questions
please answer yes or no. In the past 12 months did you buy food from
fast food or pizza places? SP interview version: In the past 12 months
did {you/SP} buy food from fast food or pizza places?

</td>

</tr>

<tr>

<td style="text-align:left;">

9657

</td>

<td style="text-align:left;">

CBQ535

</td>

<td style="text-align:left;">

The last time when you ate out or bought food at a fast-food or pizza
place did you see nutrition or health information about any foods on the
menu?

</td>

</tr>

<tr>

<td style="text-align:left;">

12267

</td>

<td style="text-align:left;">

CBQ535

</td>

<td style="text-align:left;">

The last time when you ate out or bought food at a fast-food or pizza
place did you see nutrition or health information about any foods on the
menu? SP interview version: The last time when {you/SP} ate out or
bought food at a fast-food or pizza place did {you/he/she} see nutrition
or health information about any foods on the menu?

</td>

</tr>

<tr>

<td style="text-align:left;">

12318

</td>

<td style="text-align:left;">

CBQ535

</td>

<td style="text-align:left;">

The last time when you ate out or bought food at a fast-food or pizza
place did you see nutrition or health information about any foods on the
menu? SP interview version: The last time when {you/SP} ate out or
bought food at a fast-food or pizza place did {you/he/she} see nutrition
or health information about any foods on the menu?

</td>

</tr>

<tr>

<td style="text-align:left;">

9658

</td>

<td style="text-align:left;">

CBQ540

</td>

<td style="text-align:left;">

Did you use the information in deciding which foods to buy?

</td>

</tr>

<tr>

<td style="text-align:left;">

12268

</td>

<td style="text-align:left;">

CBQ540

</td>

<td style="text-align:left;">

Did you use the information in deciding which foods to buy? SP interview
version: Did {you/SP} use the information in deciding which foods to
buy?

</td>

</tr>

<tr>

<td style="text-align:left;">

12319

</td>

<td style="text-align:left;">

CBQ540

</td>

<td style="text-align:left;">

Did you use the information in deciding which foods to buy? SP interview
version: Did {you/SP} use the information in deciding which foods to
buy?

</td>

</tr>

<tr>

<td style="text-align:left;">

9659

</td>

<td style="text-align:left;">

CBQ545

</td>

<td style="text-align:left;">

{Please open your hand card booklet and turn to hand card 1 to answer
the next question.} If nutrition or health information were readily
available in fast food or pizza places would you use it often sometimes
rarely or never in deciding what to order?

</td>

</tr>

<tr>

<td style="text-align:left;">

12269

</td>

<td style="text-align:left;">

CBQ545

</td>

<td style="text-align:left;">

{Please open your hand card booklet and turn to hand card 1 to answer
the next question.} If nutrition or health information were readily
available in fast food or pizza places would you use it often sometimes
rarely or never in deciding what to order? SP interview version: If
nutrition or health information were readily available in fast food or
pizza places would {you/SP} use it often sometimes rarely or never in
deciding what to order?

</td>

</tr>

<tr>

<td style="text-align:left;">

12320

</td>

<td style="text-align:left;">

CBQ545

</td>

<td style="text-align:left;">

{Please open your hand card booklet and turn to hand card 1 to answer
the next question.} If nutrition or health information were readily
available in fast food or pizza places would you use it often sometimes
rarely or never in deciding what to order? SP interview version: If
nutrition or health information were readily available in fast food or
pizza places would {you/SP} use it often sometimes rarely or never in
deciding what to order?

</td>

</tr>

<tr>

<td style="text-align:left;">

9660

</td>

<td style="text-align:left;">

CBQ550

</td>

<td style="text-align:left;">

\[For the following questions please answer yes or no.\] In the past 12
months did you eat at a restaurant with waiter or waitress service?

</td>

</tr>

<tr>

<td style="text-align:left;">

12270

</td>

<td style="text-align:left;">

CBQ550

</td>

<td style="text-align:left;">

\[For the following questions please answer yes or no.\] In the past 12
months did you eat at a restaurant with waiter or waitress service? SP
interview version: In the past 12 months did {you/SP} eat at a
restaurant with waiter or waitress service?

</td>

</tr>

<tr>

<td style="text-align:left;">

12321

</td>

<td style="text-align:left;">

CBQ550

</td>

<td style="text-align:left;">

\[For the following questions please answer yes or no.\] In the past 12
months did you eat at a restaurant with waiter or waitress service? SP
interview version: In the past 12 months did {you/SP} eat at a
restaurant with waiter or waitress service?

</td>

</tr>

<tr>

<td style="text-align:left;">

12271

</td>

<td style="text-align:left;">

CBQ552

</td>

<td style="text-align:left;">

Think about the last time {you/SP} ate at a restaurant with a waiter or
waitress. Is it a chain-restaurant?

</td>

</tr>

<tr>

<td style="text-align:left;">

12322

</td>

<td style="text-align:left;">

CBQ552

</td>

<td style="text-align:left;">

Think about the last time {you/SP} ate at a restaurant with a waiter or
waitress. Is it a chain-restaurant?

</td>

</tr>

<tr>

<td style="text-align:left;">

9666

</td>

<td style="text-align:left;">

CBQ580

</td>

<td style="text-align:left;">

The last time you ate at a restaurant with a waiter or waitress did you
see nutrition or health information about any foods on the menu?

</td>

</tr>

<tr>

<td style="text-align:left;">

12272

</td>

<td style="text-align:left;">

CBQ580

</td>

<td style="text-align:left;">

The last time you ate at a restaurant with a waiter or waitress did you
see nutrition or health information about any foods on the menu? SP
interview version: Did {you/SP} see nutrition or health information
about any foods on the menu?

</td>

</tr>

<tr>

<td style="text-align:left;">

12323

</td>

<td style="text-align:left;">

CBQ580

</td>

<td style="text-align:left;">

The last time you ate at a restaurant with a waiter or waitress did you
see nutrition or health information about any foods on the menu? SP
interview version: Did {you/SP} see nutrition or health information
about any foods on the menu?

</td>

</tr>

<tr>

<td style="text-align:left;">

9667

</td>

<td style="text-align:left;">

CBQ585

</td>

<td style="text-align:left;">

Did you use the information in deciding which foods to buy?

</td>

</tr>

<tr>

<td style="text-align:left;">

12273

</td>

<td style="text-align:left;">

CBQ585

</td>

<td style="text-align:left;">

Did you use the information in deciding which foods to buy? SP interview
version: Did {you/SP} use the information in deciding which foods to
buy?

</td>

</tr>

<tr>

<td style="text-align:left;">

12324

</td>

<td style="text-align:left;">

CBQ585

</td>

<td style="text-align:left;">

Did you use the information in deciding which foods to buy? SP interview
version: Did {you/SP} use the information in deciding which foods to
buy?

</td>

</tr>

<tr>

<td style="text-align:left;">

9668

</td>

<td style="text-align:left;">

CBQ590

</td>

<td style="text-align:left;">

{Please look at hand card 1 \[again\].} If nutrition information were
readily available in restaurants with a waiter or waitress would you use
it often sometimes rarely or never in deciding what to order?

</td>

</tr>

<tr>

<td style="text-align:left;">

12274

</td>

<td style="text-align:left;">

CBQ590

</td>

<td style="text-align:left;">

{Please look at hand card 1 \[again\].} If nutrition information were
readily available in restaurants with a waiter or waitress would you use
it often sometimes rarely or never in deciding what to order? SP
interview version: If nutrition or health information were readily
available in restaurants with a waiter or waitress would {you/SP} use it
often sometimes rarely or never in deciding what to order?

</td>

</tr>

<tr>

<td style="text-align:left;">

12325

</td>

<td style="text-align:left;">

CBQ590

</td>

<td style="text-align:left;">

{Please look at hand card 1 \[again\].} If nutrition information were
readily available in restaurants with a waiter or waitress would you use
it often sometimes rarely or never in deciding what to order? SP
interview version: If nutrition or health information were readily
available in restaurants with a waiter or waitress would {you/SP} use it
often sometimes rarely or never in deciding what to order?

</td>

</tr>

</tbody>

</table>

# Summary

Subject to some caveats (consistency in units, potentially conflicting
data in different tables for same participant), a variable centric
workflow seems feasible, once we have a good way to select relevant
variables and deal with missing data.

The following exports the unique combinations of variable names, labels,
and descriptions for exploration using other tools.

``` r
write.csv(unique(variableDesc[c("Variable", "Description", "SasLabel")]) |> 
            sort(by = ~ Variable),
          file = "nhanes-variables.csv", row.names = FALSE)
```
