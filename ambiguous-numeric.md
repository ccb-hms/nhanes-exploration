Ambiguity in numeric variables
================
Deepayan Sarkar

Goal: identify tables where conversion to numeric may have problems.

``` r
> find_conversion_problems <- function(nh_table)
+ {
+     cb <- nhanesCodebook(nh_table)
+     var_status <- function(v) {
+         x <- cb[[v]][[v]]
+         if (is.null(x)) return(NA) # no info, usually for SEQN
+         probablyNumeric <- "Range of Values" %in% x$Value.Description
+         if (!probablyNumeric) return(TRUE) # OK - at least for now
+         ok <- all(x$Value.Description %in% c(acceptable, agelimits))
+         ok
+     }
+     cb_status <- vapply(names(cb), var_status, logical(1))
+     if (all(is.na(cb_status))) "INVALID CODEBOOK" # the whole table is problematic ?
+     else lapply(cb[ !is.na(cb_status) & !cb_status ],
+                 function(x) x[[length(x)]][1:3])
+ }
```

``` r
> ## mpub <- nhanesManifest("public", sizes = FALSE)
> ## tables <- mpub$Table
> tables <- nhanesA:::.nhanesQuery("select TableName from Metadata.QuestionnaireDescriptions")
> tables <- tables$TableName
```

Go through all tables in the manifest and check for ambiguities, as
reported by `nhanesA:::checkAmbiguous()`.

``` r
> status <- lapply(tables, 
+                  function(tab) try(find_conversion_problems(tab), silent = TRUE))
> names(status) <- tables
```

``` r
> keep <- sapply(status, length) > 0
> status <- status[keep]
> tables <- tables[keep]
> exec_error <- sapply(status, inherits, "try-error")
> no_codebook <- sapply(status, identical, "INVALID CODEBOOK")
```

## Tables with no useful codebook in the database

``` r
> cat(format(tables[no_codebook]), fill = TRUE)
ALB_CR_G SSSAL_D  TELO_A   TELO_B  
```

For example,

``` r
> str(nhanesCodebook("SSSAL_D"))
List of 7
 $ SEQN    :List of 4
  ..$ Variable Name:: chr "SEQN"
  ..$ SAS Label:    : chr "Respondent sequence number"
  ..$ English Text: : chr "Respondent sequence number"
  ..$ Target:       : chr "Both males and females 20 YEARS - 64 YEARS"
 $ SSSALIGA:List of 4
  ..$ Variable Name:: chr "SSSALIGA"
  ..$ SAS Label:    : chr "Salmonella IgA"
  ..$ English Text: : chr "Salmonella IgA"
  ..$ Target:       : chr "Both males and females 20 YEARS - 64 YEARS"
 $ SSSALIGG:List of 4
  ..$ Variable Name:: chr "SSSALIGG"
  ..$ SAS Label:    : chr "Salmonella IgG"
  ..$ English Text: : chr "Salmonella IgG"
  ..$ Target:       : chr "Both males and females 20 YEARS - 64 YEARS"
 $ SSSALIGM:List of 4
  ..$ Variable Name:: chr "SSSALIGM"
  ..$ SAS Label:    : chr "Salmonella IgM"
  ..$ English Text: : chr "Salmonella IgM"
  ..$ Target:       : chr "Both males and females 20 YEARS - 64 YEARS"
 $ SSCAMIGA:List of 4
  ..$ Variable Name:: chr "SSCAMIGA"
  ..$ SAS Label:    : chr "Campylobacter IgA"
  ..$ English Text: : chr "Campylobacter IgA"
  ..$ Target:       : chr "Both males and females 20 YEARS - 64 YEARS"
 $ SSCAMIGG:List of 4
  ..$ Variable Name:: chr "SSCAMIGG"
  ..$ SAS Label:    : chr "Campylobacter IgG"
  ..$ English Text: : chr "Campylobacter IgG"
  ..$ Target:       : chr "Both males and females 20 YEARS - 64 YEARS"
 $ SSCAMIGM:List of 4
  ..$ Variable Name:: chr "SSCAMIGM"
  ..$ SAS Label:    : chr "Campylobacter IgM"
  ..$ English Text: : chr "Campylobacter IgM"
  ..$ Target:       : chr "Both males and females 20 YEARS - 64 YEARS"
```

## Tables with errors in computing status

``` r
> cat(format(tables[exec_error]), fill = TRUE)
```

(None at the moment)

## Tables with unexpected value descriptions

``` r
> sum(!exec_error & !no_codebook)
[1] 403
```

These are too many tables to list (many with multiple variables), though
we could do so as follows:

``` r
for (t in tables[!exec_error & !no_codebook]) {
    cat("-----Table:", t, "----------\n")
    print(status[[t]])
}
```

Instead, we will just list the labels that will need to be handled.

``` r
> labels_df <- status[!exec_error & !no_codebook] |>
+     do.call(what = c) |> do.call(what = rbind)
> ## keep only value and description
> labels_df <- labels_df[1:2]
```

Next, we count the number of variables each description occurs in, and
sort by frequency.

``` r
> labels_df <- subset(labels_df, Value.Description != "Range of Values")
> labels_split <- split(labels_df, ~ Value.Description)
> labels_summary <-
+     lapply(labels_split,
+            function(d) with(d,
+                             data.frame(Desc = substring(as.character(Value.Description)[[1]],
+                                                         1, 45),
+                                        Count = length(Value.Description),
+                                        Codes = sort(unique(Code.or.Value))
+                                        |> paste(collapse = "/")
+                                        |> substring(1, 30)))) |>
+     do.call(what = rbind)
```

``` r
> rownames(labels_summary) <- NULL
> labels_summary[order(labels_summary$Count, decreasing = TRUE), ]
                                             Desc Count                          Codes
95                                        Missing  1221                              .
74                                     Don't know   586 99/999/9999/99999/999999/99999
145                                       Refused   582 77/777/7777/77777/777777/77777
1                                               0   162                              0
120                                 No Lab Result    71                              0
149                                   Since birth    67                          66666
143                                        Refuse    63                    77/777/7777
82               Fill Value of Limit of Detection    62 -0.22/0.0025/0.0028/0.0031/0.0
130                                          None    52                              0
107                                         Never    51                              0
124                               No lab specimen    37                              0
68                              Compliance <= 0.2    32                            555
69                               Could not obtain    32                            888
59                                          900 +    27                            900
86                              Less than 1 month    26                          0/666
71       Day 1 dietary recall not done/incomplete    24                              0
72       Day 2 dietary recall not done/incomplete    24                              0
60                          95 cigarettes or more    21                             95
66                       Below Limit of Detection    21 0.01/0.011/0.021/0.035/0.04/0.
142                 Provider did not specify goal    18                           6666
27                                   2000 or more    17                           2000
3                             1 cigarette or less    15                              1
111                        Never on a daily basis    15                              0
139    Participants 6+ years with no lab specimen    13                              0
29                                      3 or More    12                              3
75                                     Don't Know    12                       999/9999
158           Value greater than or equal to 5.00    12                              5
45                                      7 or more    11                              7
53                              80 years or older    11                             80
6                                    1-14 minutes    10                             14
49                                     70 or more    10                             70
54                                  8400 and over    10                           8400
83         First Below Detection Limit Fill Value    10             0.01/0.18/0.25/1.4
114             Never smoked cigarettes regularly    10                              0
126                               No modification    10                              0
127                        No time spent outdoors    10                              0
129                                Non-Respondent    10                              0
147       Second Below Detection Limit Fill Value    10           0.009/0.21/0.28/1.25
153                           Still breastfeeding    10                              0
154                        Still drinking formula    10                              0
9                                     100 or more     9                            100
64               Below Detection Limit Fill Value     9                  0.14/1.25/2/4
101                   More than 21 meals per week     9                           5555
125                               No Lab Specimen     9                              0
28                                      3 or more     8                              3
76                                     DON'T KNOW     8                             99
87                               Less than 1 year     8                            666
91                             Less than one hour     8                              0
4                                 1 month or less     7                              1
18                              13 pounds or more     7                             13
24                               20 or more times     7                             20
39                                6 years or less     7                              6
47              7 or more people in the Household     7                              7
57                              85 years or older     7                             85
78                            Don't know/not sure     7                           9999
84         First Fill Value of Limit of Detection     7 -0.001/-0.01/-0.02/-0.03/-0.07
148       Second Fill Value of Limit of Detection     7 -0.004/-0.02/-0.04/-0.05/-0.23
8                                           100 +     6                            100
10                                     11 or more     6                             11
13                              11 years or under     6                             11
21                              19 years or under     6                             19
43                              60 years or older     6                             60
62         At or below detection limit fill value     6       0.01/0.04/0.07/0.21/6.36
79                                      Dont Know     6                           9999
98               More than 1095 days (3-year) old     6                         666666
108                    Never had cholesterol test     6                           6666
110                            Never heard of LDL     6                           5555
113                Never smoked a whole cigarette     6                             55
134   Participants 12+ years with no lab specimen     6                              0
14                               12 hours or more     5                             12
23                                     20 or more     5                             20
38                                6 times or more     5                              6
40                               6 years or under     5                              6
63  At work or at school 9 to 5 seven days a week     5                           3333
73                  Does not work or go to school     5                           3333
85                             Hasn't started yet     5                              0
146                                       REFUSED     5                             77
15                            12 years or younger     4                             12
16                                     13 or more     4                             13
32                                     40 or more     4                             40
46                 7 or more people in the Family     4                              7
70  Current HH FS benefits recipient last receive     4                          55555
93                               Less than weekly     4                           6666
106                 More than 90 times in 30 days     4                           6666
128 Non-current HH FS benefits recipient last rec     4                          66666
141       PIR value greater than or equal to 5.00     4                              5
150                                   Since Birth     4                          66666
157                                    Ungradable     4                              2
11                                     11 or More     3                             11
33                                     40 or More     3                             40
36                               50 years or more     3                          66666
56                                    85 or older     3                             85
61                                     95 or more     3                             95
80                                        English     3                              1
81                            English and Spanish     3                              3
92                             Less than one year     3                            666
97                   More than 1 year unspecified     3                            555
112                 Never smoked a pipe regularly     3                              0
115                 Never smoked cigars regularly     3                              0
116          Never used chewing tobacco regularly     3                              0
117                    Never used snuff regularly     3                              0
121 No Lab Result or Not Fasting for 8 to <24 hou     3                              0
122                                No lab samples     3                              0
131                              Not MEC Examined     3                              0
133                                         Other     3                              4
152                                       Spanish     3                              2
156                 Unable to do activity (blind)     3                            666
12                              11 pounds or more     2                             11
17                                     13 or More     2                             13
19                               14 hours or more     2                             14
20                              15 drinks or more     2                             15
26                              20 years or older     2                             20
30                               3 pounds or less     2                              3
35                             480 Months or more     2                            480
37                               500 mg or higher     2                            500
41                             60 minutes or more     2                             60
44                             600 Months or more     2                            600
50                                      70 to 150     2                             70
51                               80 Hours or more     2                             80
55                            85 or greater years     2                             85
65                 Below First Limit of Detection     2                        0.1/0.5
67                Below Second Limit of Detection     2                       0.14/0.7
77               Don't know what is 'whole grain'     2                       66666666
89                              Less than monthly     2                          66666
94                              Less then 3 hours     2                              2
96                                More than $1000     2                          55555
100                                  More than 21     2                           5555
103                            More than 300 days     2                          55555
104               More than 365 days (1-year) old     2                         666666
105               More than 730 days (2-year) old     2                         666666
109                       Never heard of A1C test     2                            666
123                                No Lab samples     2                              0
132                  Not tested in last 12 months     2                              0
136    Participants 3+ years with no lab specimen     2                              0
144                                       refused     2                       77777777
151                          Single person family     2                            666
2                                      0-5 Months     1                              5
5                                  1 year or less     1                              1
7                                       1-5 Hours     1                              5
22                                20 days or more     1                             20
25                                      20 to 150     1                             20
31                                      4 or more     1                              4
34                                   400 and over     1                            400
42                              60 or more months     1                            666
48                                7 years or less     1                              7
52                            80 or greater years     1                             80
58                                     9 or fewer     1                              9
88                      Less than 10 years of age     1                              1
90                              Less than one day     1                              0
99                     More than 20 times a month     1                             30
102                   More than 21 times per week     1                           5555
118                                 No lab result     1                              0
119                                 No lab Result     1                              0
135      Participants 3+ years with no Lab Result     1                              0
137 Participants 3+ years with no surplus lab spe     1                              0
138      Participants 6+ years with no Lab Result     1                              0
140   Participants 6+ years with no lab specimen.     1                              0
155        Third Fill Value of Limit of Detection     1                          -0.03
```
