Creating a Searchable Table of Variables in NHANES
================
Deepayan Sarkar

# Summary of available variables

The NHANES data consist of multiple tables over multiple cycles, each
with a set of recorded variables. The variable names themselves are
fairly cryptic, and not useful as search terms. Fortunately, the NHANES
website also provides descriptions of these variables in comprehensive
tables (grouped by components such as
[Demographics](https://wwwn.cdc.gov/nchs/nhanes/search/variablelist.aspx?Component=Demographics),
[Laboratory](https://wwwn.cdc.gov/nchs/nhanes/search/variablelist.aspx?Component=Laboratory),
etc.), along with a search interface.

The nhanesA package can download these tables and make the information
contained in them available as a data frame using the `nhanesManifest()`
function.

``` r
library(nhanesA)
varmf <- nhanesManifest("variables")
```

This downloads and combined several large web pages, so it may take a
little time to run. Add `verbose = TRUE` to see some indication of what
is happening.

The first few rows of the resulting data frame are given by

``` r
head(varmf)
#>    VarName
#> 1  AIALANG
#> 2  DMDBORN
#> 3 DMDCITZN
#> 4 DMDEDUC2
#> 5 DMDEDUC3
#> 6 DMDFMSIZ
#>                                                                                                                                                                                                                                                                                                                                                            VarDesc
#> 1                                                                                                                                                                                                                                                                                                                   Language of the MEC ACASI Interview Instrument
#> 2                                                                                                                                                                                                                                                                                                                          In what country {were you/was SP} born?
#> 3 {Are you/Is SP} a citizen of the United States? [Information about citizenship is being collected by the U.S. Public Health Service to perform health related research. Providing this information is voluntary and is collected under the authority of the Public Health Service Act. There will be no effect on pending immigration or citizenship petitions.]
#> 4                                                                                                                                                                                                              (SP Interview Version) What is the highest grade or level of school {you have/SP has} completed or the highest degree {you have/s/he has} received?
#> 5                                                                                                                                                                                                              (SP Interview Version) What is the highest grade or level of school {you have/SP has} completed or the highest degree {you have/s/he has} received?
#> 6                                                                                                                                                                                                                                                                                                                             Total number of people in the Family
#>    Table                              TableDesc BeginYear EndYear    Component UseConstraints
#> 1 DEMO_D Demographic Variables & Sample Weights      2005    2006 Demographics           None
#> 2 DEMO_D Demographic Variables & Sample Weights      2005    2006 Demographics           None
#> 3 DEMO_D Demographic Variables & Sample Weights      2005    2006 Demographics           None
#> 4 DEMO_D Demographic Variables & Sample Weights      2005    2006 Demographics           None
#> 5 DEMO_D Demographic Variables & Sample Weights      2005    2006 Demographics           None
#> 6 DEMO_D Demographic Variables & Sample Weights      2005    2006 Demographics           None
```

and it dimensions are

``` r
dim(varmf)
#> [1] 70102     8
```

If we drop the pandemic (`P_*`) tables and limited access tables, we get

``` r
varmf <- subset(varmf, !startsWith(Table, "P_") & UseConstraints == "None")
dim(varmf)
#> [1] 48026     8
```

There are not actually these many distinct variables, because every
occurrence in every table is recorded separately.

``` r
length(unique(varmf$VarName))
#> [1] 12718
```

We may be more interested in variables that are recorded in most (if not
all) cycles. Let’s see how frequently variables appear.

``` r
table(varmf$VarName) |> sort(decreasing = TRUE) |> table()
#> 
#>    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   22   23   25   26 
#> 2826 3445 2302  641  466  752  843  519  247  332   49   30  229    5    1    1    4    1    3    1 
#>   28   29   30   31   32   33   35   56   58   66   73  112 1402 
#>    8    1    1    1    2    1    1    1    1    1    1    1    1
```

What does it mean for a variable to appear in more than 10 tables? This
makes sense for `SEQN`:

``` r
sum(varmf$VarName == "SEQN")
#> [1] 1402
```

The other ones are typically variables that are recorded in multiple
tables; for example,

``` r
subset(varmf, VarName == "PHAFSTMN", select = c(Table, TableDesc, BeginYear, EndYear)) |> kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:left;">
Table
</th>
<th style="text-align:left;">
TableDesc
</th>
<th style="text-align:right;">
BeginYear
</th>
<th style="text-align:right;">
EndYear
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
28154
</td>
<td style="text-align:left;">
GLU_E
</td>
<td style="text-align:left;">
Plasma Fasting Glucose & Insulin
</td>
<td style="text-align:right;">
2007
</td>
<td style="text-align:right;">
2008
</td>
</tr>
<tr>
<td style="text-align:left;">
28166
</td>
<td style="text-align:left;">
FASTQX_E
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
2007
</td>
<td style="text-align:right;">
2008
</td>
</tr>
<tr>
<td style="text-align:left;">
28471
</td>
<td style="text-align:left;">
OGTT_E
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:right;">
2007
</td>
<td style="text-align:right;">
2008
</td>
</tr>
<tr>
<td style="text-align:left;">
28599
</td>
<td style="text-align:left;">
PH
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
1999
</td>
<td style="text-align:right;">
2000
</td>
</tr>
<tr>
<td style="text-align:left;">
29930
</td>
<td style="text-align:left;">
FASTQX_D
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
2005
</td>
<td style="text-align:right;">
2006
</td>
</tr>
<tr>
<td style="text-align:left;">
29947
</td>
<td style="text-align:left;">
GLU_D
</td>
<td style="text-align:left;">
Plasma Fasting Glucose & Insulin
</td>
<td style="text-align:right;">
2005
</td>
<td style="text-align:right;">
2006
</td>
</tr>
<tr>
<td style="text-align:left;">
30066
</td>
<td style="text-align:left;">
OGTT_D
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:right;">
2005
</td>
<td style="text-align:right;">
2006
</td>
</tr>
<tr>
<td style="text-align:left;">
30941
</td>
<td style="text-align:left;">
PH_C
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
2003
</td>
<td style="text-align:right;">
2004
</td>
</tr>
<tr>
<td style="text-align:left;">
31015
</td>
<td style="text-align:left;">
PH_B
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
2001
</td>
<td style="text-align:right;">
2002
</td>
</tr>
<tr>
<td style="text-align:left;">
32366
</td>
<td style="text-align:left;">
FASTQX_F
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
2009
</td>
<td style="text-align:right;">
2010
</td>
</tr>
<tr>
<td style="text-align:left;">
32383
</td>
<td style="text-align:left;">
GLU_F
</td>
<td style="text-align:left;">
Plasma Fasting Glucose & Insulin
</td>
<td style="text-align:right;">
2009
</td>
<td style="text-align:right;">
2010
</td>
</tr>
<tr>
<td style="text-align:left;">
32443
</td>
<td style="text-align:left;">
OGTT_F
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:right;">
2009
</td>
<td style="text-align:right;">
2010
</td>
</tr>
<tr>
<td style="text-align:left;">
34152
</td>
<td style="text-align:left;">
FASTQX_G
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
2011
</td>
<td style="text-align:right;">
2012
</td>
</tr>
<tr>
<td style="text-align:left;">
34374
</td>
<td style="text-align:left;">
GLU_G
</td>
<td style="text-align:left;">
Plasma Fasting Glucose & Insulin
</td>
<td style="text-align:right;">
2011
</td>
<td style="text-align:right;">
2012
</td>
</tr>
<tr>
<td style="text-align:left;">
34386
</td>
<td style="text-align:left;">
OGTT_G
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:right;">
2011
</td>
<td style="text-align:right;">
2012
</td>
</tr>
<tr>
<td style="text-align:left;">
34989
</td>
<td style="text-align:left;">
OGTT_H
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:right;">
2013
</td>
<td style="text-align:right;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
35088
</td>
<td style="text-align:left;">
GLU_H
</td>
<td style="text-align:left;">
Plasma Fasting Glucose
</td>
<td style="text-align:right;">
2013
</td>
<td style="text-align:right;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
35813
</td>
<td style="text-align:left;">
FASTQX_H
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
2013
</td>
<td style="text-align:right;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
36305
</td>
<td style="text-align:left;">
INS_H
</td>
<td style="text-align:left;">
Insulin
</td>
<td style="text-align:right;">
2013
</td>
<td style="text-align:right;">
2014
</td>
</tr>
<tr>
<td style="text-align:left;">
37488
</td>
<td style="text-align:left;">
FASTQX_I
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
2015
</td>
<td style="text-align:right;">
2016
</td>
</tr>
<tr>
<td style="text-align:left;">
37731
</td>
<td style="text-align:left;">
INS_I
</td>
<td style="text-align:left;">
Insulin
</td>
<td style="text-align:right;">
2015
</td>
<td style="text-align:right;">
2016
</td>
</tr>
<tr>
<td style="text-align:left;">
39797
</td>
<td style="text-align:left;">
FASTQX_J
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:right;">
2017
</td>
<td style="text-align:right;">
2018
</td>
</tr>
</tbody>
</table>

It is not immediately obvious whether these are these measuring the same
thing. If we include the variable descriptions in the above table, we
see that they are sometimes different.

``` r
subset(varmf, VarName == "PHAFSTMN", select = c(Table, TableDesc, VarDesc)) |>
    sort(by = ~ Table) |> kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:left;">
Table
</th>
<th style="text-align:left;">
TableDesc
</th>
<th style="text-align:left;">
VarDesc
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
29930
</td>
<td style="text-align:left;">
FASTQX_D
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
28166
</td>
<td style="text-align:left;">
FASTQX_E
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
32366
</td>
<td style="text-align:left;">
FASTQX_F
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
34152
</td>
<td style="text-align:left;">
FASTQX_G
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
35813
</td>
<td style="text-align:left;">
FASTQX_H
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
37488
</td>
<td style="text-align:left;">
FASTQX_I
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
39797
</td>
<td style="text-align:left;">
FASTQX_J
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
29947
</td>
<td style="text-align:left;">
GLU_D
</td>
<td style="text-align:left;">
Plasma Fasting Glucose & Insulin
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
28154
</td>
<td style="text-align:left;">
GLU_E
</td>
<td style="text-align:left;">
Plasma Fasting Glucose & Insulin
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
32383
</td>
<td style="text-align:left;">
GLU_F
</td>
<td style="text-align:left;">
Plasma Fasting Glucose & Insulin
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
34374
</td>
<td style="text-align:left;">
GLU_G
</td>
<td style="text-align:left;">
Plasma Fasting Glucose & Insulin
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
35088
</td>
<td style="text-align:left;">
GLU_H
</td>
<td style="text-align:left;">
Plasma Fasting Glucose
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
36305
</td>
<td style="text-align:left;">
INS_H
</td>
<td style="text-align:left;">
Insulin
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
37731
</td>
<td style="text-align:left;">
INS_I
</td>
<td style="text-align:left;">
Insulin
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
30066
</td>
<td style="text-align:left;">
OGTT_D
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
28471
</td>
<td style="text-align:left;">
OGTT_E
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
32443
</td>
<td style="text-align:left;">
OGTT_F
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
34386
</td>
<td style="text-align:left;">
OGTT_G
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
34989
</td>
<td style="text-align:left;">
OGTT_H
</td>
<td style="text-align:left;">
Oral Glucose Tolerance Test
</td>
<td style="text-align:left;">
Total length of ‘food fast’, minutes
</td>
</tr>
<tr>
<td style="text-align:left;">
28599
</td>
<td style="text-align:left;">
PH
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
31015
</td>
<td style="text-align:left;">
PH_B
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
<tr>
<td style="text-align:left;">
30941
</td>
<td style="text-align:left;">
PH_C
</td>
<td style="text-align:left;">
Fasting Questionnaire
</td>
<td style="text-align:left;">
The time (in minutes) between when the examinee last ate or drank
anything other than water and the time of the venipuncture.
</td>
</tr>
</tbody>
</table>

# Aggregation strategy

To make a searchable table that is more concise that the full table but
retains potentially different interpretations of the same variable name,
we will create a table with one row for each distinct combination of
`VarName` and `VarDesc`, and alongside them, list all tables where this
combination appears.

``` r

summarizeTable <- function(d) {
    with(d, sprintf("[%s]<br>(%s)",
                    paste(sort(Table), collapse = ", "),
                    paste(sort(unique(TableDesc)), collapse = "<br> ")))
}
aggTable <- unique(varmf[c("VarName", "VarDesc", "Component")]) |>
    sort(by = ~ Component + VarName + VarDesc)
aggTable$Details <- ""
aggTable <- subset(aggTable, VarName != "SEQN") # not useful
for (i in seq_len(nrow(aggTable))) {
    if (interactive() && i %% 100 == 0) cat("\r", i, " / ", nrow(aggTable), "      ")
    aggTable$Details[[i]] <-
        summarizeTable(subset(varmf,
                              VarName == aggTable$VarName[[i]] &
                              VarDesc == aggTable$VarDesc[[i]]))
}
```

We can now either save this is a CSV file for further processing, e.g.,

``` r
write.csv(aggTable, file = "nhanes-variables.csv", row.names = FALSE)
```

or use the `DT` package to create a searchable HTML table using the
DataTables Javascript library.

``` r
library(DT)
dt <- datatable(aggTable,
                rownames = FALSE,
                colnames = c("Variable", "Description", "Component", "Source"),
                escape = FALSE, editable = FALSE,
                options = list(columnDefs = list(
                                   list("searchable" = FALSE,
                                        "targets" = c(2, 3))
                               )))
saveWidget(dt, file = "nhanes-variables.html", selfcontained = TRUE)
#> Warning in instance$preRenderHook(instance): It seems your data is too big for client-side
#> DataTables. You may consider server-side processing: https://rstudio.github.io/DT/server.html
```

Both of these will create fairly large files, so they are not actually
created here. For demonstration the following gives the table only for
the Demographics component, which is the smallest.

``` r
demo <-
    DT::datatable(subset(aggTable, Component == "Demographics"),
                  rownames = FALSE,
                  colnames = c("Variable", "Description", "Component", "Source"),
                  escape = FALSE, editable = FALSE,
                  options = list(columnDefs = list(
                                     list("searchable" = FALSE,
                                          "targets" = c(2, 3))
                                 )))
saveWidget(demo, file = "nhanes-variables-demographic.html", selfcontained = TRUE)
```

The result is available [here](nhanes-variables-demographic.html).

# Enhancements

Though useful, the information available in the variable manifest is
limited. More useful information is available in the per-table codebooks
(which can be accessed using the `nhanesCodebook()` function), including
a usually shorter description of each variable referred to as the “SAS
Label”, along with information about possible response values and their
counts, including the number of missing values.

Such information can be easily incorporated into the aggregate table
created above, but requires processing the codebooks for all available
tables, which involves downloading a large number of files. Even more
useful information (such as how many unique non-missing values are
actually available for a given variable) involves inspecting the actual
data files, which again involves downloading and processing a large
number of files. These steps are less time-consuming if one uses the
dockerized version of the package where both the codebooks and datasets
are available through a local database.
