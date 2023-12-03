Variables that are both numeric and categorical
================

Some variables are currently interpreted as both numeric and categorical
in different cycles. This happens because numeric variables are
identified by the presence of the phrase `"Range of Values"` in the
variables possible values. An example is available in

<https://github.com/cjendres1/nhanes/issues/21>

This is an initial attempt to find all such variables, and explore
possible ways forward.

# Demonstrate the problem

Known example:

``` r
library(nhanesA)
```

Vanilla nhanes:

``` r
nhanesOptions(use.db = FALSE)
str(nhanes("DEMO_G")$DMDHHSIZ)
```

     num [1:9756] 5 6 5 5 5 6 7 5 5 4 ...

``` r
str(nhanes("DEMO_H")$DMDHHSIZ)
```

     Factor w/ 7 levels "1","2","3","4",..: 3 4 2 4 2 1 3 1 4 7 ...

Database version:

``` r
nhanesOptions(use.db = TRUE)
str(nhanes("DEMO_G")$DMDHHSIZ)
```

     num [1:9756] 4 3 6 2 4 2 1 2 1 4 ...

``` r
str(nhanes("DEMO_H")$DMDHHSIZ)
```

     chr [1:10175] "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" "1" ...

FromURL version:

``` r
str(nhanesFromURL("/Nchs/Nhanes/2011-2012/DEMO_G.XPT")$DMDHHSIZ)
```

     num [1:9756] 5 6 5 5 5 6 7 5 5 4 ...

``` r
str(nhanesFromURL("/Nchs/Nhanes/2013-2014/DEMO_H.XPT")$DMDHHSIZ)
```

     chr [1:10175] "3" "4" "2" "4" "2" "1" "3" "1" "4" "7 or more people in the Household" "1" "3" ...

# How often does this happen?

Possible options to find out are:

- Do a variable summary of everything and find variables which are
  categorical in some but not all cycles.

- Use the codebooks stored in the database. Let’s try the second one
  first because it will be faster.

``` r
sql <- nhanesA:::.nhanesQuery
all_cb <- sql("select * from Metadata.VariableCodebook")
subset(all_cb, Variable == "DMDHHSIZ", select = 1:5)
```

           Variable TableName CodeOrValue                  ValueDescription Count
    51     DMDHHSIZ      DEMO      1 to 6                   Range of Values  8818
    52     DMDHHSIZ      DEMO           7 7 or more people in the Household  1147
    53     DMDHHSIZ      DEMO           .                           Missing     0
    15623  DMDHHSIZ    DEMO_B      1 to 6                   Range of Values  9799
    15624  DMDHHSIZ    DEMO_B           7 7 or more people in the Household  1240
    15625  DMDHHSIZ    DEMO_B           .                           Missing     0
    30445  DMDHHSIZ    DEMO_C      1 to 6                   Range of Values  9134
    30446  DMDHHSIZ    DEMO_C           7 7 or more people in the Household   988
    30447  DMDHHSIZ    DEMO_C           .                           Missing     0
    50658  DMDHHSIZ    DEMO_D      1 to 6                   Range of Values  9394
    50659  DMDHHSIZ    DEMO_D           7 7 or more people in the Household   954
    50660  DMDHHSIZ    DEMO_D           .                           Missing     0
    67616  DMDHHSIZ    DEMO_E      1 to 6                   Range of Values  9214
    67617  DMDHHSIZ    DEMO_E           7 7 or more people in the Household   935
    67618  DMDHHSIZ    DEMO_E           .                           Missing     0
    83799  DMDHHSIZ    DEMO_F      1 to 6                   Range of Values  9458
    83800  DMDHHSIZ    DEMO_F           7 7 or more people in the Household  1079
    83801  DMDHHSIZ    DEMO_F           .                           Missing     0
    100305 DMDHHSIZ    DEMO_G      1 to 6                   Range of Values  8936
    100306 DMDHHSIZ    DEMO_G           7 7 or more people in the Household   820
    100307 DMDHHSIZ    DEMO_G           .                           Missing     0
    117415 DMDHHSIZ    DEMO_H           1                                 1   817
    117416 DMDHHSIZ    DEMO_H           2                                 2  1787
    117417 DMDHHSIZ    DEMO_H           3                                 3  1779
    117418 DMDHHSIZ    DEMO_H           4                                 4  2100
    117419 DMDHHSIZ    DEMO_H           5                                 5  1781
    117420 DMDHHSIZ    DEMO_H           6                                 6   985
    117421 DMDHHSIZ    DEMO_H           7 7 or more people in the Household   926
    117422 DMDHHSIZ    DEMO_H           .                           Missing     0
    144013 DMDHHSIZ    DEMO_I           1                                 1   828
    144014 DMDHHSIZ    DEMO_I           2                                 2  1723
    144015 DMDHHSIZ    DEMO_I           3                                 3  1719
    144016 DMDHHSIZ    DEMO_I           4                                 4  2061
    144017 DMDHHSIZ    DEMO_I           5                                 5  1672
    144018 DMDHHSIZ    DEMO_I           6                                 6   994
    144019 DMDHHSIZ    DEMO_I           7 7 or more people in the Household   974
    144020 DMDHHSIZ    DEMO_I           .                           Missing     0
    161138 DMDHHSIZ    DEMO_J           1                                 1   807
    161139 DMDHHSIZ    DEMO_J           2                                 2  1922
    161140 DMDHHSIZ    DEMO_J           3                                 3  1629
    161141 DMDHHSIZ    DEMO_J           4                                 4  1886
    161142 DMDHHSIZ    DEMO_J           5                                 5  1474
    161143 DMDHHSIZ    DEMO_J           6                                 6   803
    161144 DMDHHSIZ    DEMO_J           7 7 or more people in the Household   733
    161145 DMDHHSIZ    DEMO_J           .                           Missing     0

So this ‘finds’ our known culprit.

Let’s first restrict our attention to variables that are ‘numeric’ in at
least one table. There may be others, but we have very little hope of
finding them unless we inspect each manually (but see last section
below).

``` r
numeric_vars <- with(all_cb, unique(Variable[ValueDescription == "Range of Values"]))
numeric_cb <- subset(all_cb, Variable %in% numeric_vars, select = 1:5)
## quick check: which 'ValueDescription'-s look like numeric? Should be very few
maybe_numeric <- is.finite(as.numeric(numeric_cb$ValueDescription))
table(maybe_numeric)
```

    maybe_numeric
    FALSE  TRUE 
    68980   490 

We will focus on these variables.

``` r
problem_vars <- unique(numeric_cb[maybe_numeric, ]$Variable)
str(problem_vars)
```

     chr [1:235] "AUXR1K2L" "AUXR1K2R" "AUXR3KR" "BAXFTC12" "WTSPH01" "WTSPH02" "WTSPH03" "WTSPH04" ...

``` r
num_cb_byVar <- numeric_cb |> subset(Variable %in% problem_vars) |> split(~ Variable)
length(num_cb_byVar)
```

    [1] 235

Let’s start by summarizing these to keep only the unique (CodeOrValue,
ValueDescription) combinations, and then prioritize them by the number
of numeric-like values that remain.

``` r
summary_byVar <-
    lapply(num_cb_byVar,
           function(d) unique(d[c("Variable", "CodeOrValue", "ValueDescription")]))
numNumeric <- function(d) suppressWarnings(sum(is.finite(as.numeric(d$ValueDescription))))
(nnum <- sapply(summary_byVar, numNumeric) |> sort())
```

    AUXR1K2R  AUXR2KR  AUXR3KR  AUXR8KR BAXFTC12 CVDR3TIM  DR2LANG DRD370JQ  DUQ350Q   DUQ390   DXXSPY 
           1        1        1        1        1        1        1        1        1        1        1 
     LBDBANO  LBDEONO   LBDRPI   LBXV2P   LBXVDX   LBXVTP  MCQ240D MCQ240dk MCQ240DK  MCQ240H  MCQ240K 
           1        1        1        1        1        1        1        1        1        1        1 
     MCQ240l  MCQ240L  MCQ240m  MCQ240q  MCQ240v  MCQ240y OSD030cc OSD030cd  OSD110h  PFD069L   SSDBZP 
           1        1        1        1        1        1        1        1        1        1        1 
      SXQ267   SXQ410   SXQ550   SXQ836   SXQ841   URX1DC   URXMTO   URXOMO   URXP09   URXPTU   URXTCV 
           1        1        1        1        1        1        1        1        1        1        1 
      URXUBE WTSAF2YR WTSAF4YR  WTSHM01  WTSHM02  WTSHM03  WTSHM04  WTSHM05  WTSHM06  WTSHM07  WTSHM08 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSHM09  WTSHM10  WTSHM11  WTSHM12  WTSHM13  WTSHM14  WTSHM15  WTSHM16  WTSHM17  WTSHM18  WTSHM19 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSHM20  WTSHM21  WTSHM22  WTSHM23  WTSHM24  WTSHM25  WTSHM26  WTSHM27  WTSHM28  WTSHM29  WTSHM30 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSHM31  WTSHM32  WTSHM33  WTSHM34  WTSHM35  WTSHM36  WTSHM37  WTSHM38  WTSHM39  WTSHM40  WTSHM41 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSHM42  WTSHM43  WTSHM44  WTSHM45  WTSHM46  WTSHM47  WTSHM48  WTSHM49  WTSHM50  WTSHM51  WTSHM52 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPH01  WTSPH02  WTSPH03  WTSPH04  WTSPH05  WTSPH06  WTSPH07  WTSPH08  WTSPH09  WTSPH10  WTSPH11 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPH12  WTSPH13  WTSPH14  WTSPH15  WTSPH16  WTSPH17  WTSPH18  WTSPH19  WTSPH20  WTSPH21  WTSPH22 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPH23  WTSPH24  WTSPH25  WTSPH26  WTSPH27  WTSPH28  WTSPH29  WTSPH30  WTSPH31  WTSPH32  WTSPH33 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPH34  WTSPH35  WTSPH36  WTSPH37  WTSPH38  WTSPH39  WTSPH40  WTSPH41  WTSPH42  WTSPH43  WTSPH44 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPH45  WTSPH46  WTSPH47  WTSPH48  WTSPH49  WTSPH50  WTSPH51  WTSPH52  WTSPO01  WTSPO02  WTSPO03 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPO04  WTSPO05  WTSPO06  WTSPO07  WTSPO08  WTSPO09  WTSPO10  WTSPO11  WTSPO12  WTSPO13  WTSPO14 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPO15  WTSPO16  WTSPO17  WTSPO18  WTSPO19  WTSPO20  WTSPO21  WTSPO22  WTSPO23  WTSPO24  WTSPO25 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPO26  WTSPO27  WTSPO28  WTSPO29  WTSPO30  WTSPO31  WTSPO32  WTSPO33  WTSPO34  WTSPO35  WTSPO36 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPO37  WTSPO38  WTSPO39  WTSPO40  WTSPO41  WTSPO42  WTSPO43  WTSPO44  WTSPO45  WTSPO46  WTSPO47 
           1        1        1        1        1        1        1        1        1        1        1 
     WTSPO48  WTSPO49  WTSPO50  WTSPO51  WTSPO52 AUXR1K2L DRD370PQ   DUQ340   DUQ360  DUQ400Q MCQ240AA 
           1        1        1        1        1        2        2        2        2        2        2 
     MCQ240b  MCQ240T OSD030bf OSD030bg  OSD110f   SMD415  SMD415A   URX2DC DMDHHSZA DMDHHSZE  MCQ240Y 
           2        2        2        2        2        2        2        2        3        3        3 
    OSD030ce  OSQ020a  RHQ602Q DMDHHSZB  MCQ240B OSD030ac  OSQ020c DMDFMSIZ DMDHHSIZ   HUD080  OSQ020b 
           3        3        3        4        4        4        5        6        6        6        7 
     ECD070A   HOD050   HSQ580   KID221 
          12       12       12       24 

The number of variables with 2 or more numeric variables seem like a
manageable number, so let’s look at all of them.

``` r
num_cb_byVar[ names(which(nnum > 2)) ]
```

    $DMDHHSZA
           Variable TableName CodeOrValue ValueDescription Count
    100308 DMDHHSZA    DEMO_G      0 to 2  Range of Values  9484
    100309 DMDHHSZA    DEMO_G           3        3 or more   272
    100310 DMDHHSZA    DEMO_G           .          Missing     0
    117423 DMDHHSZA    DEMO_H           0                0  6417
    117424 DMDHHSZA    DEMO_H           1                1  2341
    117425 DMDHHSZA    DEMO_H           2                2  1068
    117426 DMDHHSZA    DEMO_H           3        3 or more   349
    117427 DMDHHSZA    DEMO_H           .          Missing     0
    144021 DMDHHSZA    DEMO_I           0                0  6298
    144022 DMDHHSZA    DEMO_I           1                1  2147
    144023 DMDHHSZA    DEMO_I           2                2  1199
    144024 DMDHHSZA    DEMO_I           3        3 or more   327
    144025 DMDHHSZA    DEMO_I           .          Missing     0
    161146 DMDHHSZA    DEMO_J           0                0  6183
    161147 DMDHHSZA    DEMO_J           1                1  1826
    161148 DMDHHSZA    DEMO_J           2                2   951
    161149 DMDHHSZA    DEMO_J           3        3 or more   294
    161150 DMDHHSZA    DEMO_J           .          Missing     0

    $DMDHHSZE
           Variable TableName CodeOrValue ValueDescription Count
    100314 DMDHHSZE    DEMO_G      0 to 2  Range of Values  9700
    100315 DMDHHSZE    DEMO_G           3        3 or more    56
    100316 DMDHHSZE    DEMO_G           .          Missing     0
    117434 DMDHHSZE    DEMO_H           0                0  7384
    117435 DMDHHSZE    DEMO_H           1                1  1612
    117436 DMDHHSZE    DEMO_H           2                2  1114
    117437 DMDHHSZE    DEMO_H           3        3 or more    65
    117438 DMDHHSZE    DEMO_H           .          Missing     0
    144032 DMDHHSZE    DEMO_I           0                0  7151
    144033 DMDHHSZE    DEMO_I           1                1  1663
    144034 DMDHHSZE    DEMO_I           2                2  1099
    144035 DMDHHSZE    DEMO_I           3        3 or more    58
    144036 DMDHHSZE    DEMO_I           .          Missing     0
    161156 DMDHHSZE    DEMO_J           0                0  6125
    161157 DMDHHSZE    DEMO_J           1                1  1788
    161158 DMDHHSZE    DEMO_J           2                2  1270
    161159 DMDHHSZE    DEMO_J           3        3 or more    71
    161160 DMDHHSZE    DEMO_J           .          Missing     0

    $MCQ240Y
          Variable TableName CodeOrValue  ValueDescription Count
    12466  MCQ240Y       MCQ    63 to 71   Range of Values     2
    12467  MCQ240Y       MCQ          85 85 years or older     0
    12468  MCQ240Y       MCQ       77777           Refused     0
    12469  MCQ240Y       MCQ       99999        Don't know     0
    12470  MCQ240Y       MCQ           .           Missing  9491
    26074  MCQ240Y     MCQ_B    37 to 52   Range of Values     3
    26075  MCQ240Y     MCQ_B          85 85 years or older     0
    26076  MCQ240Y     MCQ_B       77777           Refused     0
    26077  MCQ240Y     MCQ_B       99999        Don't know     0
    26078  MCQ240Y     MCQ_B           .           Missing 10467
    45824  MCQ240Y     MCQ_C          32                32     1
    45825  MCQ240Y     MCQ_C          85 85 years or older     0
    45826  MCQ240Y     MCQ_C       77777           Refused     0
    45827  MCQ240Y     MCQ_C       99999        Don't know     0
    45828  MCQ240Y     MCQ_C           .           Missing  9644
    64081  MCQ240Y     MCQ_D          35                35     1
    64082  MCQ240Y     MCQ_D          85 85 years or older     0
    64083  MCQ240Y     MCQ_D       77777           Refused     0
    64084  MCQ240Y     MCQ_D       99999        Don't know     0
    64085  MCQ240Y     MCQ_D           .           Missing  9821
    77610  MCQ240Y     MCQ_E          30                30     1
    77611  MCQ240Y     MCQ_E          80 80 years or older     0
    77612  MCQ240Y     MCQ_E       77777           Refused     0
    77613  MCQ240Y     MCQ_E       99999        Don't know     0
    77614  MCQ240Y     MCQ_E           .           Missing  9665
    94127  MCQ240Y     MCQ_F          80 80 years or older     0
    94128  MCQ240Y     MCQ_F       77777           Refused     0
    94129  MCQ240Y     MCQ_F       99999        Don't know     0
    94130  MCQ240Y     MCQ_F           .           Missing 10109

    $OSD030ce
           Variable TableName CodeOrValue ValueDescription Count
    13157  OSD030ce       OSQ          85      85 or older     0
    13158  OSD030ce       OSQ       77777          Refused     0
    13159  OSD030ce       OSQ       99999       Don't know     1
    13160  OSD030ce       OSQ           .          Missing  4879
    46524  OSD030ce     OSQ_C    24 to 68  Range of Values     2
    46525  OSD030ce     OSQ_C          85      85 or older     0
    46526  OSD030ce     OSQ_C       77777          Refused     0
    46527  OSD030ce     OSQ_C       99999       Don't know     1
    46528  OSD030ce     OSQ_C           .          Missing  5038
    64282  OSD030ce     OSQ_D          44               44     1
    64283  OSD030ce     OSQ_D          85      85 or older     0
    64284  OSD030ce     OSQ_D       77777          Refused     0
    64285  OSD030ce     OSQ_D       99999       Don't know     2
    64286  OSD030ce     OSQ_D           .          Missing  4976
    78933  OSD030ce     OSQ_E          65               65     1
    78934  OSD030ce     OSQ_E          80      80 or older     0
    78935  OSD030ce     OSQ_E       77777          Refused     0
    78936  OSD030ce     OSQ_E       99999       Don't know     0
    78937  OSD030ce     OSQ_E           .          Missing  5934
    173994 OSD030ce     OSQ_J          58               58     1
    173995 OSD030ce     OSQ_J          80      80 or older     0
    173996 OSD030ce     OSQ_J       77777          Refused     0
    173997 OSD030ce     OSQ_J       99999       Don't know     0
    173998 OSD030ce     OSQ_J           .          Missing  3068

    $OSQ020a
           Variable TableName CodeOrValue ValueDescription Count
    13176   OSQ020a       OSQ      1 to 3  Range of Values    79
    13177   OSQ020a       OSQ        7777          Refused     0
    13178   OSQ020a       OSQ        9999       Don't know     2
    13179   OSQ020a       OSQ           .          Missing  4799
    26617   OSQ020a     OSQ_B      1 to 3  Range of Values    86
    26618   OSQ020a     OSQ_B        7777          Refused     0
    26619   OSQ020a     OSQ_B        9999       Don't know     2
    26620   OSQ020a     OSQ_B           .          Missing  5323
    46631   OSQ020a     OSQ_C      1 to 2  Range of Values    88
    46632   OSQ020a     OSQ_C        7777          Refused     0
    46633   OSQ020a     OSQ_C        9999       Don't know     2
    46634   OSQ020a     OSQ_C           .          Missing  4951
    64473   OSQ020a     OSQ_D      1 to 3  Range of Values    73
    64474   OSQ020a     OSQ_D        7777          Refused     0
    64475   OSQ020a     OSQ_D        9999       Don't know     0
    64476   OSQ020a     OSQ_D           .          Missing  4906
    79071   OSQ020a     OSQ_E      1 to 5  Range of Values    72
    79072   OSQ020a     OSQ_E        7777          Refused     0
    79073   OSQ020a     OSQ_E        9999       Don't know     0
    79074   OSQ020a     OSQ_E           .          Missing  5863
    96785   OSQ020a     OSQ_F      1 to 2  Range of Values    90
    96786   OSQ020a     OSQ_F        7777          Refused     0
    96787   OSQ020a     OSQ_F        9999       Don't know     0
    96788   OSQ020a     OSQ_F           .          Missing  6128
    137972  OSQ020a     OSQ_H           1                1    71
    137973  OSQ020a     OSQ_H           2                2     9
    137974  OSQ020a     OSQ_H           3                3     2
    137975  OSQ020a     OSQ_H        7777          Refused     0
    137976  OSQ020a     OSQ_H        9999       Don't know     1
    137977  OSQ020a     OSQ_H           .          Missing  3732
    174126  OSQ020a     OSQ_J           1                1    68
    174127  OSQ020a     OSQ_J           2                2     7
    174128  OSQ020a     OSQ_J           3                3     2
    174129  OSQ020a     OSQ_J        7777          Refused     0
    174130  OSQ020a     OSQ_J        9999       Don't know     0
    174131  OSQ020a     OSQ_J           .          Missing  2992

    $RHQ602Q
           Variable TableName CodeOrValue ValueDescription Count
    14569   RHQ602Q       RHQ     1 to 11  Range of Values     4
    14570   RHQ602Q       RHQ          77          Refused     0
    14571   RHQ602Q       RHQ          99       Don't know     0
    14572   RHQ602Q       RHQ           .          Missing  3513
    27812   RHQ602Q     RHQ_B     1 to 17  Range of Values     7
    27813   RHQ602Q     RHQ_B          77          Refused     0
    27814   RHQ602Q     RHQ_B          99       Don't know     0
    27815   RHQ602Q     RHQ_B           .          Missing  3858
    48084   RHQ602Q     RHQ_C     2 to 10  Range of Values     8
    48085   RHQ602Q     RHQ_C          77          Refused     0
    48086   RHQ602Q     RHQ_C          99       Don't know     0
    48087   RHQ602Q     RHQ_C           .          Missing  3556
    66268   RHQ602Q     RHQ_D     1 to 14  Range of Values    12
    66269   RHQ602Q     RHQ_D          77          Refused     0
    66270   RHQ602Q     RHQ_D          99       Don't know     0
    66271   RHQ602Q     RHQ_D           .          Missing  3585
    81275   RHQ602Q     RHQ_E     1 to 30  Range of Values     7
    81276   RHQ602Q     RHQ_E          77          Refused     0
    81277   RHQ602Q     RHQ_E          99       Don't know     0
    81278   RHQ602Q     RHQ_E           .          Missing  3477
    81565   RHQ602Q   RHQ_E_R     1 to 30  Range of Values     7
    81566   RHQ602Q   RHQ_E_R          77          Refused     0
    81567   RHQ602Q   RHQ_E_R          99       Don't know     0
    81568   RHQ602Q   RHQ_E_R           .          Missing  3477
    94527   RHQ602Q     RHQ_F      1 to 6  Range of Values     9
    94528   RHQ602Q     RHQ_F          77          Refused     0
    94529   RHQ602Q     RHQ_F          99       Don't know     1
    94530   RHQ602Q     RHQ_F           .          Missing  3735
    95626   RHQ602Q   RHQ_F_R      1 to 6  Range of Values     9
    95627   RHQ602Q   RHQ_F_R          77          Refused     0
    95628   RHQ602Q   RHQ_F_R          99       Don't know     1
    95629   RHQ602Q   RHQ_F_R           .          Missing  3735
    115304  RHQ602Q     RHQ_G      1 to 5  Range of Values     5
    115305  RHQ602Q     RHQ_G          77          Refused     0
    115306  RHQ602Q     RHQ_G          99       Don't know     0
    115307  RHQ602Q     RHQ_G           .          Missing  3293
    115575  RHQ602Q   RHQ_G_R      1 to 5  Range of Values     5
    115576  RHQ602Q   RHQ_G_R          77          Refused     0
    115577  RHQ602Q   RHQ_G_R          99       Don't know     0
    115578  RHQ602Q   RHQ_G_R           .          Missing  3293
    142602  RHQ602Q     RHQ_H     1 to 15  Range of Values    12
    142603  RHQ602Q     RHQ_H          77          Refused     0
    142604  RHQ602Q     RHQ_H          99       Don't know     0
    142605  RHQ602Q     RHQ_H           .          Missing  3606
    142813  RHQ602Q   RHQ_H_R     1 to 15  Range of Values    12
    142814  RHQ602Q   RHQ_H_R          77          Refused     0
    142815  RHQ602Q   RHQ_H_R          99       Don't know     0
    142816  RHQ602Q   RHQ_H_R           .          Missing  3606
    158973  RHQ602Q     RHQ_I           1                1     1
    158974  RHQ602Q     RHQ_I           2                2     3
    158975  RHQ602Q     RHQ_I           3                3     1
    158976  RHQ602Q     RHQ_I          77          Refused     0
    158977  RHQ602Q     RHQ_I          99       Don't know     0
    158978  RHQ602Q     RHQ_I           .          Missing  3466
    159730  RHQ602Q   RHQ_I_R      1 to 3  Range of Values     5
    159731  RHQ602Q   RHQ_I_R          77          Refused     0
    159732  RHQ602Q   RHQ_I_R          99       Don't know     0
    159733  RHQ602Q   RHQ_I_R           .          Missing  3466
    173000  RHQ602Q     RHQ_J      1 to 5  Range of Values     5
    173001  RHQ602Q     RHQ_J          77          Refused     0
    173002  RHQ602Q     RHQ_J          99       Don't know     0
    173003  RHQ602Q     RHQ_J           .          Missing  3281
    173215  RHQ602Q   RHQ_J_R      1 to 5  Range of Values     5
    173216  RHQ602Q   RHQ_J_R          77          Refused     0
    173217  RHQ602Q   RHQ_J_R          99       Don't know     0
    173218  RHQ602Q   RHQ_J_R           .          Missing  3281

    $DMDHHSZB
           Variable TableName CodeOrValue ValueDescription Count
    100311 DMDHHSZB    DEMO_G      0 to 3  Range of Values  9434
    100312 DMDHHSZB    DEMO_G           4        4 or more   322
    100313 DMDHHSZB    DEMO_G           .          Missing     0
    117428 DMDHHSZB    DEMO_H           0                0  4907
    117429 DMDHHSZB    DEMO_H           1                1  2099
    117430 DMDHHSZB    DEMO_H           2                2  1814
    117431 DMDHHSZB    DEMO_H           3                3   887
    117432 DMDHHSZB    DEMO_H           4        4 or more   468
    117433 DMDHHSZB    DEMO_H           .          Missing     0
    144026 DMDHHSZB    DEMO_I           0                0  4715
    144027 DMDHHSZB    DEMO_I           1                1  1990
    144028 DMDHHSZB    DEMO_I           2                2  1833
    144029 DMDHHSZB    DEMO_I           3                3   822
    144030 DMDHHSZB    DEMO_I           4        4 or more   611
    144031 DMDHHSZB    DEMO_I           .          Missing     0
    161151 DMDHHSZB    DEMO_J           0                0  4772
    161152 DMDHHSZB    DEMO_J           1                1  1902
    161153 DMDHHSZB    DEMO_J           2                2  1511
    161154 DMDHHSZB    DEMO_J           3        3 or more  1069
    161155 DMDHHSZB    DEMO_J           .          Missing     0

    $MCQ240B
          Variable TableName CodeOrValue  ValueDescription Count
    12340  MCQ240B       MCQ           1                 1     1
    12341  MCQ240B       MCQ          85 85 years or older     0
    12342  MCQ240B       MCQ       77777           Refused     0
    12343  MCQ240B       MCQ       99999        Don't know     0
    12344  MCQ240B       MCQ           .           Missing  9492
    25946  MCQ240B     MCQ_B          57                57     1
    25947  MCQ240B     MCQ_B          85 85 years or older     0
    25948  MCQ240B     MCQ_B       77777           Refused     0
    25949  MCQ240B     MCQ_B       99999        Don't know     0
    25950  MCQ240B     MCQ_B           .           Missing 10469
    45698  MCQ240B     MCQ_C          85 85 years or older     0
    45699  MCQ240B     MCQ_C       77777           Refused     0
    45700  MCQ240B     MCQ_C       99999        Don't know     0
    45701  MCQ240B     MCQ_C           .           Missing  9645
    63949  MCQ240B     MCQ_D    63 to 66   Range of Values     2
    63950  MCQ240B     MCQ_D          85 85 years or older     0
    63951  MCQ240B     MCQ_D       77777           Refused     0
    63952  MCQ240B     MCQ_D       99999        Don't know     0
    63953  MCQ240B     MCQ_D           .           Missing  9820
    77476  MCQ240B     MCQ_E          62                62     1
    77477  MCQ240B     MCQ_E          80 80 years or older     0
    77478  MCQ240B     MCQ_E       77777           Refused     0
    77479  MCQ240B     MCQ_E       99999        Don't know     0
    77480  MCQ240B     MCQ_E           .           Missing  9665
    93994  MCQ240B     MCQ_F          60                60     1
    93995  MCQ240B     MCQ_F          80 80 years or older     0
    93996  MCQ240B     MCQ_F       77777           Refused     0
    93997  MCQ240B     MCQ_F       99999        Don't know     0
    93998  MCQ240B     MCQ_F           .           Missing 10108

    $OSD030ac
           Variable TableName CodeOrValue ValueDescription Count
    13083  OSD030ac       OSQ          21               21     1
    13084  OSD030ac       OSQ          85      85 or older     0
    13085  OSD030ac       OSQ       77777          Refused     0
    13086  OSD030ac       OSQ       99999       Don't know     0
    13087  OSD030ac       OSQ           .          Missing  4879
    64222  OSD030ac     OSQ_D          82               82     1
    64223  OSD030ac     OSQ_D          85      85 or older     0
    64224  OSD030ac     OSQ_D       77777          Refused     0
    64225  OSD030ac     OSQ_D       99999       Don't know     0
    64226  OSD030ac     OSQ_D           .          Missing  4978
    78863  OSD030ac     OSQ_E          73               73     1
    78864  OSD030ac     OSQ_E          80      80 or older     0
    78865  OSD030ac     OSQ_E       77777          Refused     0
    78866  OSD030ac     OSQ_E       99999       Don't know     0
    78867  OSD030ac     OSQ_E           .          Missing  5934
    137803 OSD030ac     OSQ_H    71 to 78  Range of Values     2
    137804 OSD030ac     OSQ_H          80      80 or older     0
    137805 OSD030ac     OSQ_H       77777          Refused     0
    137806 OSD030ac     OSQ_H       99999       Don't know     0
    137807 OSD030ac     OSQ_H           .          Missing  3813
    173944 OSD030ac     OSQ_J          65               65     1
    173945 OSD030ac     OSQ_J          80      80 or older     0
    173946 OSD030ac     OSQ_J       77777          Refused     0
    173947 OSD030ac     OSQ_J       99999       Don't know     1
    173948 OSD030ac     OSQ_J           .          Missing  3067

    $OSQ020c
           Variable TableName CodeOrValue ValueDescription Count
    13184   OSQ020c       OSQ      1 to 5  Range of Values    91
    13185   OSQ020c       OSQ        7777          Refused     0
    13186   OSQ020c       OSQ        9999       Don't know     1
    13187   OSQ020c       OSQ           .          Missing  4788
    26625   OSQ020c     OSQ_B      1 to 6  Range of Values   116
    26626   OSQ020c     OSQ_B        7777          Refused     0
    26627   OSQ020c     OSQ_B        9999       Don't know     3
    26628   OSQ020c     OSQ_B           .          Missing  5292
    46639   OSQ020c     OSQ_C     1 to 10  Range of Values   101
    46640   OSQ020c     OSQ_C        7777          Refused     0
    46641   OSQ020c     OSQ_C        9999       Don't know     2
    46642   OSQ020c     OSQ_C           .          Missing  4938
    64481   OSQ020c     OSQ_D     1 to 10  Range of Values   125
    64482   OSQ020c     OSQ_D        7777          Refused     0
    64483   OSQ020c     OSQ_D        9999       Don't know     2
    64484   OSQ020c     OSQ_D           .          Missing  4852
    79079   OSQ020c     OSQ_E      1 to 5  Range of Values   151
    79080   OSQ020c     OSQ_E        7777          Refused     0
    79081   OSQ020c     OSQ_E        9999       Don't know     2
    79082   OSQ020c     OSQ_E           .          Missing  5782
    96793   OSQ020c     OSQ_F      1 to 3  Range of Values   111
    96794   OSQ020c     OSQ_F        7777          Refused     0
    96795   OSQ020c     OSQ_F        9999       Don't know     0
    96796   OSQ020c     OSQ_F           .          Missing  6107
    137987  OSQ020c     OSQ_H           1                1    67
    137988  OSQ020c     OSQ_H           2                2     8
    137989  OSQ020c     OSQ_H           3                3     2
    137990  OSQ020c     OSQ_H        7777          Refused     0
    137991  OSQ020c     OSQ_H        9999       Don't know     0
    137992  OSQ020c     OSQ_H           .          Missing  3738
    174140  OSQ020c     OSQ_J           1                1    94
    174141  OSQ020c     OSQ_J           2                2    15
    174142  OSQ020c     OSQ_J           3                3     4
    174143  OSQ020c     OSQ_J           4                4     1
    174144  OSQ020c     OSQ_J           5                5     1
    174145  OSQ020c     OSQ_J        7777          Refused     0
    174146  OSQ020c     OSQ_J        9999       Don't know     1
    174147  OSQ020c     OSQ_J           .          Missing  2953

    $DMDFMSIZ
           Variable TableName CodeOrValue               ValueDescription Count
    50655  DMDFMSIZ    DEMO_D      1 to 6                Range of Values  9506
    50656  DMDFMSIZ    DEMO_D           7 7 or more people in the Family   842
    50657  DMDFMSIZ    DEMO_D           .                        Missing     0
    67613  DMDFMSIZ    DEMO_E      1 to 6                Range of Values  9302
    67614  DMDFMSIZ    DEMO_E           7 7 or more people in the Family   847
    67615  DMDFMSIZ    DEMO_E           .                        Missing     0
    83796  DMDFMSIZ    DEMO_F      1 to 6                Range of Values  9561
    83797  DMDFMSIZ    DEMO_F           7 7 or more people in the Family   976
    83798  DMDFMSIZ    DEMO_F           .                        Missing     0
    100302 DMDFMSIZ    DEMO_G      1 to 6                Range of Values  9019
    100303 DMDFMSIZ    DEMO_G           7 7 or more people in the Family   737
    100304 DMDFMSIZ    DEMO_G           .                        Missing     0
    117407 DMDFMSIZ    DEMO_H           1                              1  1297
    117408 DMDFMSIZ    DEMO_H           2                              2  1610
    117409 DMDFMSIZ    DEMO_H           3                              3  1737
    117410 DMDFMSIZ    DEMO_H           4                              4  2027
    117411 DMDFMSIZ    DEMO_H           5                              5  1723
    117412 DMDFMSIZ    DEMO_H           6                              6   961
    117413 DMDFMSIZ    DEMO_H           7 7 or more people in the Family   820
    117414 DMDFMSIZ    DEMO_H           .                        Missing     0
    144005 DMDFMSIZ    DEMO_I           1                              1  1305
    144006 DMDFMSIZ    DEMO_I           2                              2  1510
    144007 DMDFMSIZ    DEMO_I           3                              3  1634
    144008 DMDFMSIZ    DEMO_I           4                              4  2011
    144009 DMDFMSIZ    DEMO_I           5                              5  1635
    144010 DMDFMSIZ    DEMO_I           6                              6   961
    144011 DMDFMSIZ    DEMO_I           7 7 or more people in the Family   915
    144012 DMDFMSIZ    DEMO_I           .                        Missing     0
    161130 DMDFMSIZ    DEMO_J           1                              1  1250
    161131 DMDFMSIZ    DEMO_J           2                              2  1717
    161132 DMDFMSIZ    DEMO_J           3                              3  1556
    161133 DMDFMSIZ    DEMO_J           4                              4  1861
    161134 DMDFMSIZ    DEMO_J           5                              5  1423
    161135 DMDFMSIZ    DEMO_J           6                              6   794
    161136 DMDFMSIZ    DEMO_J           7 7 or more people in the Family   653
    161137 DMDFMSIZ    DEMO_J           .                        Missing     0

    $DMDHHSIZ
           Variable TableName CodeOrValue                  ValueDescription Count
    51     DMDHHSIZ      DEMO      1 to 6                   Range of Values  8818
    52     DMDHHSIZ      DEMO           7 7 or more people in the Household  1147
    53     DMDHHSIZ      DEMO           .                           Missing     0
    15623  DMDHHSIZ    DEMO_B      1 to 6                   Range of Values  9799
    15624  DMDHHSIZ    DEMO_B           7 7 or more people in the Household  1240
    15625  DMDHHSIZ    DEMO_B           .                           Missing     0
    30445  DMDHHSIZ    DEMO_C      1 to 6                   Range of Values  9134
    30446  DMDHHSIZ    DEMO_C           7 7 or more people in the Household   988
    30447  DMDHHSIZ    DEMO_C           .                           Missing     0
    50658  DMDHHSIZ    DEMO_D      1 to 6                   Range of Values  9394
    50659  DMDHHSIZ    DEMO_D           7 7 or more people in the Household   954
    50660  DMDHHSIZ    DEMO_D           .                           Missing     0
    67616  DMDHHSIZ    DEMO_E      1 to 6                   Range of Values  9214
    67617  DMDHHSIZ    DEMO_E           7 7 or more people in the Household   935
    67618  DMDHHSIZ    DEMO_E           .                           Missing     0
    83799  DMDHHSIZ    DEMO_F      1 to 6                   Range of Values  9458
    83800  DMDHHSIZ    DEMO_F           7 7 or more people in the Household  1079
    83801  DMDHHSIZ    DEMO_F           .                           Missing     0
    100305 DMDHHSIZ    DEMO_G      1 to 6                   Range of Values  8936
    100306 DMDHHSIZ    DEMO_G           7 7 or more people in the Household   820
    100307 DMDHHSIZ    DEMO_G           .                           Missing     0
    117415 DMDHHSIZ    DEMO_H           1                                 1   817
    117416 DMDHHSIZ    DEMO_H           2                                 2  1787
    117417 DMDHHSIZ    DEMO_H           3                                 3  1779
    117418 DMDHHSIZ    DEMO_H           4                                 4  2100
    117419 DMDHHSIZ    DEMO_H           5                                 5  1781
    117420 DMDHHSIZ    DEMO_H           6                                 6   985
    117421 DMDHHSIZ    DEMO_H           7 7 or more people in the Household   926
    117422 DMDHHSIZ    DEMO_H           .                           Missing     0
    144013 DMDHHSIZ    DEMO_I           1                                 1   828
    144014 DMDHHSIZ    DEMO_I           2                                 2  1723
    144015 DMDHHSIZ    DEMO_I           3                                 3  1719
    144016 DMDHHSIZ    DEMO_I           4                                 4  2061
    144017 DMDHHSIZ    DEMO_I           5                                 5  1672
    144018 DMDHHSIZ    DEMO_I           6                                 6   994
    144019 DMDHHSIZ    DEMO_I           7 7 or more people in the Household   974
    144020 DMDHHSIZ    DEMO_I           .                           Missing     0
    161138 DMDHHSIZ    DEMO_J           1                                 1   807
    161139 DMDHHSIZ    DEMO_J           2                                 2  1922
    161140 DMDHHSIZ    DEMO_J           3                                 3  1629
    161141 DMDHHSIZ    DEMO_J           4                                 4  1886
    161142 DMDHHSIZ    DEMO_J           5                                 5  1474
    161143 DMDHHSIZ    DEMO_J           6                                 6   803
    161144 DMDHHSIZ    DEMO_J           7 7 or more people in the Household   733
    161145 DMDHHSIZ    DEMO_J           .                           Missing     0

    $HUD080
           Variable TableName CodeOrValue ValueDescription Count
    11634    HUD080       HUQ           1                1   763
    11635    HUD080       HUQ           2                2   133
    11636    HUD080       HUQ           3                3    45
    11637    HUD080       HUQ           4                4    19
    11638    HUD080       HUQ           5                5    10
    11639    HUD080       HUQ           6                6    13
    11640    HUD080       HUQ          77          Refused     0
    11641    HUD080       HUQ          99       Don't know     4
    11642    HUD080       HUQ           .          Missing  8978
    45083    HUD080     HUQ_C      1 to 5  Range of Values   978
    45084    HUD080     HUQ_C           6  6 times or more    21
    45085    HUD080     HUQ_C       77777          Refused     0
    45086    HUD080     HUQ_C       99999       Don't know     0
    45087    HUD080     HUQ_C           .          Missing  9123
    63358    HUD080     HUQ_D      1 to 5  Range of Values   965
    63359    HUD080     HUQ_D           6  6 times or more    18
    63360    HUD080     HUQ_D       77777          Refused     0
    63361    HUD080     HUQ_D       99999       Don't know     1
    63362    HUD080     HUQ_D           .          Missing  9364
    80006    HUD080     HUQ_E      1 to 5  Range of Values  1025
    80007    HUD080     HUQ_E           6  6 times or more    13
    80008    HUD080     HUQ_E       77777          Refused     0
    80009    HUD080     HUQ_E       99999       Don't know     2
    80010    HUD080     HUQ_E           .          Missing  9109
    96007    HUD080     HUQ_F      1 to 5  Range of Values  1070
    96008    HUD080     HUQ_F           6  6 times or more    18
    96009    HUD080     HUQ_F       77777          Refused     0
    96010    HUD080     HUQ_F       99999       Don't know     0
    96011    HUD080     HUQ_F           .          Missing  9449
    112590   HUD080     HUQ_G      1 to 5  Range of Values   932
    112591   HUD080     HUQ_G           6  6 times or more    17
    112592   HUD080     HUQ_G       77777          Refused     0
    112593   HUD080     HUQ_G       99999       Don't know     0
    112594   HUD080     HUQ_G           .          Missing  8807
    139612   HUD080     HUQ_H           1                1   706
    139613   HUD080     HUQ_H           2                2   126
    139614   HUD080     HUQ_H           3                3    55
    139615   HUD080     HUQ_H           4                4    15
    139616   HUD080     HUQ_H           5                5     9
    139617   HUD080     HUQ_H           6  6 times or more    16
    139618   HUD080     HUQ_H       77777          Refused     0
    139619   HUD080     HUQ_H       99999       Don't know     0
    139620   HUD080     HUQ_H           .          Missing  9248
    156715   HUD080     HUQ_I           1                1   630
    156716   HUD080     HUQ_I           2                2   141
    156717   HUD080     HUQ_I           3                3    55
    156718   HUD080     HUQ_I           4                4    18
    156719   HUD080     HUQ_I           5                5    14
    156720   HUD080     HUQ_I           6  6 times or more    10
    156721   HUD080     HUQ_I       77777          Refused     0
    156722   HUD080     HUQ_I       99999       Don't know     1
    156723   HUD080     HUQ_I           .          Missing  9102
    170430   HUD080     HUQ_J           1                1   564
    170431   HUD080     HUQ_J           2                2   150
    170432   HUD080     HUQ_J           3                3    50
    170433   HUD080     HUQ_J           4                4    21
    170434   HUD080     HUQ_J           5                5    10
    170435   HUD080     HUQ_J           6  6 times or more    17
    170436   HUD080     HUQ_J       77777          Refused     0
    170437   HUD080     HUQ_J       99999       Don't know     5
    170438   HUD080     HUQ_J           .          Missing  8437

    $OSQ020b
           Variable TableName CodeOrValue ValueDescription Count
    13180   OSQ020b       OSQ     1 to 10  Range of Values   387
    13181   OSQ020b       OSQ        7777          Refused     0
    13182   OSQ020b       OSQ        9999       Don't know     2
    13183   OSQ020b       OSQ           .          Missing  4491
    26621   OSQ020b     OSQ_B      1 to 5  Range of Values   528
    26622   OSQ020b     OSQ_B        7777          Refused     0
    26623   OSQ020b     OSQ_B        9999       Don't know     2
    26624   OSQ020b     OSQ_B           .          Missing  4881
    46635   OSQ020b     OSQ_C      1 to 6  Range of Values   445
    46636   OSQ020b     OSQ_C        7777          Refused     0
    46637   OSQ020b     OSQ_C        9999       Don't know     0
    46638   OSQ020b     OSQ_C           .          Missing  4596
    64477   OSQ020b     OSQ_D      1 to 7  Range of Values   471
    64478   OSQ020b     OSQ_D        7777          Refused     0
    64479   OSQ020b     OSQ_D        9999       Don't know     1
    64480   OSQ020b     OSQ_D           .          Missing  4507
    79075   OSQ020b     OSQ_E      1 to 7  Range of Values   548
    79076   OSQ020b     OSQ_E        7777          Refused     0
    79077   OSQ020b     OSQ_E        9999       Don't know     1
    79078   OSQ020b     OSQ_E           .          Missing  5386
    96789   OSQ020b     OSQ_F     1 to 14  Range of Values   506
    96790   OSQ020b     OSQ_F        7777          Refused     0
    96791   OSQ020b     OSQ_F        9999       Don't know     1
    96792   OSQ020b     OSQ_F           .          Missing  5711
    137978  OSQ020b     OSQ_H           1                1   267
    137979  OSQ020b     OSQ_H           2                2    35
    137980  OSQ020b     OSQ_H           3                3     9
    137981  OSQ020b     OSQ_H           4                4     3
    137982  OSQ020b     OSQ_H           6                6     1
    137983  OSQ020b     OSQ_H          10               10     1
    137984  OSQ020b     OSQ_H        7777          Refused     0
    137985  OSQ020b     OSQ_H        9999       Don't know     0
    137986  OSQ020b     OSQ_H           .          Missing  3499
    174132  OSQ020b     OSQ_J           1                1   252
    174133  OSQ020b     OSQ_J           2                2    46
    174134  OSQ020b     OSQ_J           3                3    10
    174135  OSQ020b     OSQ_J           4                4     3
    174136  OSQ020b     OSQ_J           5                5     2
    174137  OSQ020b     OSQ_J        7777          Refused     0
    174138  OSQ020b     OSQ_J        9999       Don't know     2
    174139  OSQ020b     OSQ_J           .          Missing  2754

    $ECD070A
           Variable TableName CodeOrValue  ValueDescription Count
    11426   ECD070A       ECQ           1                 1    36
    11427   ECD070A       ECQ           2                 2    19
    11428   ECD070A       ECQ           3                 3    39
    11429   ECD070A       ECQ           4                 4    89
    11430   ECD070A       ECQ           5                 5   264
    11431   ECD070A       ECQ           6                 6   869
    11432   ECD070A       ECQ           7                 7  1317
    11433   ECD070A       ECQ           8                 8   805
    11434   ECD070A       ECQ           9                 9   237
    11435   ECD070A       ECQ          10                10    87
    11436   ECD070A       ECQ          11                11    15
    11437   ECD070A       ECQ          12                12     1
    11438   ECD070A       ECQ          13 13 pounds or more     3
    11439   ECD070A       ECQ          77           Refused     2
    11440   ECD070A       ECQ          99        Don't know   133
    11441   ECD070A       ECQ           .           Missing     5
    24935   ECD070A     ECQ_B     1 to 12   Range of Values  4257
    24936   ECD070A     ECQ_B          13 13 pounds or more     6
    24937   ECD070A     ECQ_B        7777           Refused     0
    24938   ECD070A     ECQ_B        9999        Don't know   141
    24939   ECD070A     ECQ_B           .           Missing     1
    44406   ECD070A     ECQ_C     1 to 12   Range of Values  3791
    44407   ECD070A     ECQ_C          13 13 pounds or more     2
    44408   ECD070A     ECQ_C        7777           Refused     1
    44409   ECD070A     ECQ_C        9999        Don't know   113
    44410   ECD070A     ECQ_C           .           Missing     2
    62850   ECD070A     ECQ_D     1 to 12   Range of Values  4071
    62851   ECD070A     ECQ_D          13 13 pounds or more     4
    62852   ECD070A     ECQ_D        7777           Refused     1
    62853   ECD070A     ECQ_D        9999        Don't know   131
    62854   ECD070A     ECQ_D           .           Missing     2
    76836   ECD070A     ECQ_E     1 to 12   Range of Values  3538
    76837   ECD070A     ECQ_E          13 13 pounds or more     4
    76838   ECD070A     ECQ_E        7777           Refused     0
    76839   ECD070A     ECQ_E        9999        Don't know    60
    76840   ECD070A     ECQ_E           .           Missing     1
    96383   ECD070A     ECQ_F     1 to 12   Range of Values  3578
    96384   ECD070A     ECQ_F          13 13 pounds or more     8
    96385   ECD070A     ECQ_F        7777           Refused     0
    96386   ECD070A     ECQ_F        9999        Don't know    62
    96387   ECD070A     ECQ_F           .           Missing     0
    112807  ECD070A     ECQ_G     1 to 12   Range of Values  3505
    112808  ECD070A     ECQ_G          13 13 pounds or more     3
    112809  ECD070A     ECQ_G        7777           Refused     1
    112810  ECD070A     ECQ_G        9999        Don't know    72
    112811  ECD070A     ECQ_G           .           Missing     0
    140370  ECD070A     ECQ_H     1 to 12   Range of Values  3622
    140371  ECD070A     ECQ_H          13 13 pounds or more     0
    140372  ECD070A     ECQ_H        7777           Refused     0
    140373  ECD070A     ECQ_H        9999        Don't know    88
    140374  ECD070A     ECQ_H           .           Missing     1
    158622  ECD070A     ECQ_I     4 to 10   Range of Values  3436
    158623  ECD070A     ECQ_I           3  3 pounds or less    80
    158624  ECD070A     ECQ_I          11 11 pounds or more    10
    158625  ECD070A     ECQ_I        7777           Refused     2
    158626  ECD070A     ECQ_I        9999        Don't know   116
    158627  ECD070A     ECQ_I           .           Missing     0
    173893  ECD070A     ECQ_J     4 to 10   Range of Values  2926
    173894  ECD070A     ECQ_J           3  3 pounds or less    66
    173895  ECD070A     ECQ_J          11 11 pounds or more    15
    173896  ECD070A     ECQ_J        7777           Refused     0
    173897  ECD070A     ECQ_J        9999        Don't know    85
    173898  ECD070A     ECQ_J           .           Missing     1

    $HOD050
           Variable TableName CodeOrValue ValueDescription Count
    11725    HOD050       HOQ     1 to 12  Range of Values  9709
    11726    HOD050       HOQ          13       13 or More    70
    11727    HOD050       HOQ         777          Refused    12
    11728    HOD050       HOQ         999       Don't know    13
    11729    HOD050       HOQ           .          Missing   161
    25473    HOD050     HOQ_B     1 to 12  Range of Values 10725
    25474    HOD050     HOQ_B          13       13 or More    93
    25475    HOD050     HOQ_B         777          Refused    19
    25476    HOD050     HOQ_B         999       Don't know    28
    25477    HOD050     HOQ_B           .          Missing   174
    44820    HOD050     HOQ_C     1 to 12  Range of Values  9944
    44821    HOD050     HOQ_C          13       13 or more    27
    44822    HOD050     HOQ_C         777          Refused    10
    44823    HOD050     HOQ_C         999       Don't know     8
    44824    HOD050     HOQ_C           .          Missing   133
    63427    HOD050     HOQ_D     1 to 12  Range of Values 10150
    63428    HOD050     HOQ_D          13       13 or more    69
    63429    HOD050     HOQ_D         777          Refused     5
    63430    HOD050     HOQ_D         999       Don't know    15
    63431    HOD050     HOQ_D           .          Missing   109
    80551    HOD050     HOQ_E     1 to 12  Range of Values  9977
    80552    HOD050     HOQ_E          13       13 or more    62
    80553    HOD050     HOQ_E         777          Refused     4
    80554    HOD050     HOQ_E         999       Don't know    12
    80555    HOD050     HOQ_E           .          Missing    94
    98759    HOD050     HOQ_F     1 to 12  Range of Values 10348
    98760    HOD050     HOQ_F          13       13 or more    97
    98761    HOD050     HOQ_F         777          Refused    13
    98762    HOD050     HOQ_F         999       Don't know    11
    98763    HOD050     HOQ_F           .          Missing    68
    113746   HOD050     HOQ_G           1                1    63
    113747   HOD050     HOQ_G           2                2   241
    113748   HOD050     HOQ_G           3                3   924
    113749   HOD050     HOQ_G           4                4  1863
    113750   HOD050     HOQ_G           5                5  1972
    113751   HOD050     HOQ_G           6                6  1709
    113752   HOD050     HOQ_G           7                7  1117
    113753   HOD050     HOQ_G           8                8   776
    113754   HOD050     HOQ_G           9                9   410
    113755   HOD050     HOQ_G          10               10   309
    113756   HOD050     HOQ_G          11               11   162
    113757   HOD050     HOQ_G          12               12    67
    113758   HOD050     HOQ_G          13       13 or more    90
    113759   HOD050     HOQ_G         777          Refused     4
    113760   HOD050     HOQ_G         999       Don't know     0
    113761   HOD050     HOQ_G           .          Missing    49
    140914   HOD050     HOQ_H           1                1    88
    140915   HOD050     HOQ_H           2                2   202
    140916   HOD050     HOQ_H           3                3   683
    140917   HOD050     HOQ_H           4                4  1613
    140918   HOD050     HOQ_H           5                5  2093
    140919   HOD050     HOQ_H           6                6  1922
    140920   HOD050     HOQ_H           7                7  1272
    140921   HOD050     HOQ_H           8                8   853
    140922   HOD050     HOQ_H           9                9   574
    140923   HOD050     HOQ_H          10               10   343
    140924   HOD050     HOQ_H          11               11   197
    140925   HOD050     HOQ_H          12               12   108
    140926   HOD050     HOQ_H          13       13 or more    85
    140927   HOD050     HOQ_H         777          Refused    16
    140928   HOD050     HOQ_H         999       Don't know     5
    140929   HOD050     HOQ_H           .          Missing   121
    157813   HOD050     HOQ_I           1                1    49
    157814   HOD050     HOQ_I           2                2   204
    157815   HOD050     HOQ_I           3                3   831
    157816   HOD050     HOQ_I           4                4  1810
    157817   HOD050     HOQ_I           5                5  2071
    157818   HOD050     HOQ_I           6                6  1728
    157819   HOD050     HOQ_I           7                7  1130
    157820   HOD050     HOQ_I           8                8   773
    157821   HOD050     HOQ_I           9                9   434
    157822   HOD050     HOQ_I          10               10   323
    157823   HOD050     HOQ_I          11               11   133
    157824   HOD050     HOQ_I          12               12    71
    157825   HOD050     HOQ_I          13       13 or more    51
    157826   HOD050     HOQ_I         777          Refused    34
    157827   HOD050     HOQ_I         999       Don't know     0
    157828   HOD050     HOQ_I           .          Missing   329
    172577   HOD050     HOQ_J           1                1    78
    172578   HOD050     HOQ_J           2                2   198
    172579   HOD050     HOQ_J           3                3   713
    172580   HOD050     HOQ_J           4                4  1693
    172581   HOD050     HOQ_J           5                5  1848
    172582   HOD050     HOQ_J           6                6  1562
    172583   HOD050     HOQ_J           7                7  1115
    172584   HOD050     HOQ_J           8                8   670
    172585   HOD050     HOQ_J           9                9   415
    172586   HOD050     HOQ_J          10               10   276
    172587   HOD050     HOQ_J          11               11    79
    172588   HOD050     HOQ_J          12               12    51
    172589   HOD050     HOQ_J          13       13 or more    47
    172590   HOD050     HOQ_J         777          Refused     8
    172591   HOD050     HOQ_J         999       Don't know    27
    172592   HOD050     HOQ_J           .          Missing   474

    $HSQ580
           Variable TableName CodeOrValue ValueDescription Count
    11007    HSQ580       HSQ     1 to 12  Range of Values   238
    11008    HSQ580       HSQ          77          Refused     0
    11009    HSQ580       HSQ          99       Don't know     8
    11010    HSQ580       HSQ           .          Missing  8586
    24589    HSQ580     HSQ_B     1 to 12  Range of Values   272
    24590    HSQ580     HSQ_B          77          Refused     0
    24591    HSQ580     HSQ_B          99       Don't know     2
    24592    HSQ580     HSQ_B           .          Missing 10108
    44001    HSQ580     HSQ_C     1 to 12  Range of Values   233
    44002    HSQ580     HSQ_C          77          Refused     0
    44003    HSQ580     HSQ_C          99       Don't know     3
    44004    HSQ580     HSQ_C           .          Missing  9299
    61746    HSQ580     HSQ_D     1 to 12  Range of Values   235
    61747    HSQ580     HSQ_D          77          Refused     0
    61748    HSQ580     HSQ_D          99       Don't know     4
    61749    HSQ580     HSQ_D           .          Missing  9201
    76954    HSQ580     HSQ_E     1 to 12  Range of Values   242
    76955    HSQ580     HSQ_E          77          Refused     0
    76956    HSQ580     HSQ_E          99       Don't know     5
    76957    HSQ580     HSQ_E           .          Missing  9060
    98461    HSQ580     HSQ_F     1 to 12  Range of Values   338
    98462    HSQ580     HSQ_F          77          Refused     0
    98463    HSQ580     HSQ_F          99       Don't know     3
    98464    HSQ580     HSQ_F           .          Missing  9494
    114444   HSQ580     HSQ_G     1 to 12  Range of Values   261
    114445   HSQ580     HSQ_G          77          Refused     0
    114446   HSQ580     HSQ_G          99       Don't know     0
    114447   HSQ580     HSQ_G           .          Missing  8695
    141559   HSQ580     HSQ_H           1                1    39
    141560   HSQ580     HSQ_H           2                2    38
    141561   HSQ580     HSQ_H           3                3    28
    141562   HSQ580     HSQ_H           4                4    20
    141563   HSQ580     HSQ_H           5                5    13
    141564   HSQ580     HSQ_H           6                6    29
    141565   HSQ580     HSQ_H           7                7    19
    141566   HSQ580     HSQ_H           8                8    11
    141567   HSQ580     HSQ_H           9                9    11
    141568   HSQ580     HSQ_H          10               10    13
    141569   HSQ580     HSQ_H          11               11    17
    141570   HSQ580     HSQ_H          12               12    18
    141571   HSQ580     HSQ_H          77          Refused     0
    141572   HSQ580     HSQ_H          99       Don't know     4
    141573   HSQ580     HSQ_H           .          Missing  9162
    158006   HSQ580     HSQ_I           1                1    42
    158007   HSQ580     HSQ_I           2                2    34
    158008   HSQ580     HSQ_I           3                3    22
    158009   HSQ580     HSQ_I           4                4    29
    158010   HSQ580     HSQ_I           5                5    15
    158011   HSQ580     HSQ_I           6                6    29
    158012   HSQ580     HSQ_I           7                7    13
    158013   HSQ580     HSQ_I           8                8    12
    158014   HSQ580     HSQ_I           9                9     7
    158015   HSQ580     HSQ_I          10               10    10
    158016   HSQ580     HSQ_I          11               11     5
    158017   HSQ580     HSQ_I          12               12    10
    158018   HSQ580     HSQ_I          77          Refused     0
    158019   HSQ580     HSQ_I          99       Don't know     2
    158020   HSQ580     HSQ_I           .          Missing  8935
    172557   HSQ580     HSQ_J           1                1    53
    172558   HSQ580     HSQ_J           2                2    35
    172559   HSQ580     HSQ_J           3                3    23
    172560   HSQ580     HSQ_J           4                4    33
    172561   HSQ580     HSQ_J           5                5    11
    172562   HSQ580     HSQ_J           6                6    40
    172563   HSQ580     HSQ_J           7                7    15
    172564   HSQ580     HSQ_J           8                8    16
    172565   HSQ580     HSQ_J           9                9     7
    172566   HSQ580     HSQ_J          10               10    12
    172567   HSQ580     HSQ_J          11               11    18
    172568   HSQ580     HSQ_J          12               12     6
    172569   HSQ580     HSQ_J          77          Refused     0
    172570   HSQ580     HSQ_J          99       Don't know     5
    172571   HSQ580     HSQ_J           .          Missing  8092

    $KID221
          Variable TableName                         CodeOrValue   ValueDescription Count
    40971   KID221  L11PSA_C Age at diagnosis of prostate cancer Value was recorded    56
    40972   KID221  L11PSA_C                                 777            Refused     0
    40973   KID221  L11PSA_C                                 999         Don't know     0
    40974   KID221  L11PSA_C                           < blank >            Missing  1451
    59151   KID221     PSA_D                                   .                  .     0
    59152   KID221     PSA_D                                  54                 54     0
    59153   KID221     PSA_D                                  58                 58     0
    59154   KID221     PSA_D                                  59                 59     0
    59155   KID221     PSA_D                                  60                 60     0
    59156   KID221     PSA_D                                  61                 61     0
    59157   KID221     PSA_D                                  62                 62     0
    59158   KID221     PSA_D                                  63                 63     0
    59159   KID221     PSA_D                                  64                 64     0
    59160   KID221     PSA_D                                  65                 65     0
    59161   KID221     PSA_D                                  66                 66     0
    59162   KID221     PSA_D                                  67                 67     0
    59163   KID221     PSA_D                                  68                 68     0
    59164   KID221     PSA_D                                  69                 69     0
    59165   KID221     PSA_D                                  70                 70     0
    59166   KID221     PSA_D                                  71                 71     0
    59167   KID221     PSA_D                                  72                 72     0
    59168   KID221     PSA_D                                  73                 73     0
    59169   KID221     PSA_D                                  75                 75     0
    59170   KID221     PSA_D                                  76                 76     0
    59171   KID221     PSA_D                                  77                 77     0
    59172   KID221     PSA_D                                  78                 78     0
    59173   KID221     PSA_D                                  79                 79     0
    59174   KID221     PSA_D                                  80                 80     0
    59175   KID221     PSA_D                                  81                 81     0
    59176   KID221     PSA_D                       85 or greater      85 or greater     3
    59177   KID221     PSA_D                           < blank >            Missing     0
    90484   KID221     PSA_F                             8 to 85    Range of Values    95
    90485   KID221     PSA_F                                 777            Refused     0
    90486   KID221     PSA_F                                 999         Don't know     0
    90487   KID221     PSA_F                                   .            Missing  1881

``` r
num_cb_byVar[ names(which(nnum == 2)) ]
```

    $AUXR1K2L
           Variable TableName CodeOrValue ValueDescription Count
    1538   AUXR1K2L      AUX1           0                0     1
    1539   AUXR1K2L      AUX1         666      No response     0
    1540   AUXR1K2L      AUX1         888 Could not obtain     0
    1541   AUXR1K2L      AUX1           .          Missing  1806
    16794  AUXR1K2L     AUX_B    20 to 70  Range of Values     3
    16795  AUXR1K2L     AUX_B         666      No response     1
    16796  AUXR1K2L     AUX_B         888 Could not obtain     0
    16797  AUXR1K2L     AUX_B           .          Missing  2042
    34361  AUXR1K2L     AUX_C          50               50     1
    34362  AUXR1K2L     AUX_C         666      No response     0
    34363  AUXR1K2L     AUX_C         888 Could not obtain     0
    34364  AUXR1K2L     AUX_C           .          Missing  1888
    54731  AUXR1K2L     AUX_D    15 to 40  Range of Values     4
    54732  AUXR1K2L     AUX_D         666      No response     1
    54733  AUXR1K2L     AUX_D         888 Could not obtain     0
    54734  AUXR1K2L     AUX_D           .          Missing  3029
    71240  AUXR1K2L     AUX_E     5 to 85  Range of Values     2
    71241  AUXR1K2L     AUX_E         666      No response     0
    71242  AUXR1K2L     AUX_E         888 Could not obtain     0
    71243  AUXR1K2L     AUX_E           .          Missing  1208
    88630  AUXR1K2L     AUX_F    20 to 80  Range of Values     3
    88631  AUXR1K2L     AUX_F         666      No response     0
    88632  AUXR1K2L     AUX_F         888 Could not obtain     0
    88633  AUXR1K2L     AUX_F           .          Missing  2365
    104941 AUXR1K2L     AUX_G         666      No response     0
    104942 AUXR1K2L     AUX_G         888 Could not obtain     0
    104943 AUXR1K2L     AUX_G           .          Missing  4500
    148630 AUXR1K2L     AUX_I    30 to 60  Range of Values     3
    148631 AUXR1K2L     AUX_I         666      No response     0
    148632 AUXR1K2L     AUX_I         888 Could not obtain     0
    148633 AUXR1K2L     AUX_I           .          Missing  4579
    166079 AUXR1K2L     AUX_J    30 to 75  Range of Values     2
    166080 AUXR1K2L     AUX_J         666      No response     0
    166081 AUXR1K2L     AUX_J         888 Could not obtain     0
    166082 AUXR1K2L     AUX_J           .          Missing  3129

    $DRD370PQ
           Variable TableName CodeOrValue ValueDescription Count
    15950  DRD370PQ  DRXTOT_B           1                1     6
    15951  DRD370PQ  DRXTOT_B           .          Missing 10471
    33388  DRD370PQ  DR1TOT_C           2                2     1
    33389  DRD370PQ  DR1TOT_C           .          Missing  9642
    53914  DRD370PQ  DR1TOT_D      1 to 4  Range of Values    18
    53915  DRD370PQ  DR1TOT_D           .          Missing  9932
    69452  DRD370PQ  DR1TOT_E      1 to 5  Range of Values    26
    69453  DRD370PQ  DR1TOT_E           .          Missing  9736
    85913  DRD370PQ  DR1TOT_F      1 to 3  Range of Values    18
    85914  DRD370PQ  DR1TOT_F           .          Missing 10235
    100858 DRD370PQ  DR1TOT_G      1 to 5  Range of Values    17
    100859 DRD370PQ  DR1TOT_G           .          Missing  9321
    117989 DRD370PQ  DR1TOT_H      1 to 3  Range of Values    10
    117990 DRD370PQ  DR1TOT_H           .          Missing  9803
    144580 DRD370PQ  DR1TOT_I      1 to 4  Range of Values    13
    144581 DRD370PQ  DR1TOT_I           .          Missing  9531
    161692 DRD370PQ  DR1TOT_J      1 to 8  Range of Values     6
    161693 DRD370PQ  DR1TOT_J           .          Missing  8698

    $DUQ340
           Variable TableName CodeOrValue  ValueDescription Count
    62763    DUQ340     DUQ_D    12 to 45   Range of Values   227
    62764    DUQ340     DUQ_D          77           Refused     0
    62765    DUQ340     DUQ_D          99        Don't know     0
    62766    DUQ340     DUQ_D           .           Missing  3058
    80755    DUQ340     DUQ_E     7 to 50   Range of Values   240
    80756    DUQ340     DUQ_E          77           Refused     0
    80757    DUQ340     DUQ_E          99        Don't know     0
    80758    DUQ340     DUQ_E           .           Missing  4385
    80929    DUQ340  DUQYTH_E    13 to 17   Range of Values    10
    80930    DUQ340  DUQYTH_E          77           Refused     0
    80931    DUQ340  DUQYTH_E          99        Don't know     0
    80932    DUQ340  DUQYTH_E           .           Missing  1200
    97719    DUQ340     DUQ_F     8 to 52   Range of Values   239
    97720    DUQ340     DUQ_F         777           Refused     0
    97721    DUQ340     DUQ_F         999        Don't know     0
    97722    DUQ340     DUQ_F           .           Missing  5063
    97924    DUQ340  DUQY_F_R          13                13     2
    97925    DUQ340  DUQY_F_R         777           Refused     0
    97926    DUQ340  DUQY_F_R         999        Don't know     0
    97927    DUQ340  DUQY_F_R           .           Missing  1007
    114579   DUQ340     DUQ_G    10 to 58   Range of Values   224
    114580   DUQ340     DUQ_G         777           Refused     0
    114581   DUQ340     DUQ_G         999        Don't know     0
    114582   DUQ340     DUQ_G           .           Missing  4572
    114785   DUQ340  DUQY_G_R     5 to 15   Range of Values     4
    114786   DUQ340  DUQY_G_R          77           Refused     0
    114787   DUQ340  DUQY_G_R          99        Don't know     0
    114788   DUQ340  DUQY_G_R           .           Missing   930
    141750   DUQ340     DUQ_H    10 to 50   Range of Values   246
    141751   DUQ340     DUQ_H         777           Refused     0
    141752   DUQ340     DUQ_H         999        Don't know     0
    141753   DUQ340     DUQ_H           .           Missing  4811
    141953   DUQ340  DUQY_H_R          77           Refused     0
    141954   DUQ340  DUQY_H_R          99        Don't know     0
    141955   DUQ340  DUQY_H_R           .           Missing  1055
    159868   DUQ340     DUQ_I    12 to 53   Range of Values   199
    159869   DUQ340     DUQ_I           6  6 years or under     0
    159870   DUQ340     DUQ_I         777           Refused     0
    159871   DUQ340     DUQ_I         999        Don't know     1
    159872   DUQ340     DUQ_I           .           Missing  4643
    160075   DUQ340  DUQY_I_R    13 to 16   Range of Values     2
    160076   DUQ340  DUQY_I_R         777           Refused     0
    160077   DUQ340  DUQY_I_R         999        Don't know     0
    160078   DUQ340  DUQY_I_R           .           Missing  1007
    173610   DUQ340     DUQ_J    12 to 55   Range of Values   231
    173611   DUQ340     DUQ_J          11 11 years or under     0
    173612   DUQ340     DUQ_J         777           Refused     0
    173613   DUQ340     DUQ_J         999        Don't know     0
    173614   DUQ340     DUQ_J           .           Missing  4341
    173812   DUQ340  DUQY_J_R          14                14     1
    173813   DUQ340  DUQY_J_R         777           Refused     0
    173814   DUQ340  DUQY_J_R         999        Don't know     0
    173815   DUQ340  DUQY_J_R           .           Missing   867

    $DUQ360
           Variable TableName CodeOrValue ValueDescription Count
    62787    DUQ360     DUQ_D     1 to 30  Range of Values    18
    62788    DUQ360     DUQ_D          77          Refused     1
    62789    DUQ360     DUQ_D          99       Don't know     1
    62790    DUQ360     DUQ_D           .          Missing  3265
    80779    DUQ360     DUQ_E     1 to 20  Range of Values    15
    80780    DUQ360     DUQ_E          77          Refused     0
    80781    DUQ360     DUQ_E          99       Don't know     0
    80782    DUQ360     DUQ_E           .          Missing  4610
    80953    DUQ360  DUQYTH_E           1                1     1
    80954    DUQ360  DUQYTH_E          77          Refused     0
    80955    DUQ360  DUQYTH_E          99       Don't know     1
    80956    DUQ360  DUQYTH_E           .          Missing  1208
    97743    DUQ360     DUQ_F     1 to 15  Range of Values     8
    97744    DUQ360     DUQ_F          77          Refused     0
    97745    DUQ360     DUQ_F          99       Don't know     0
    97746    DUQ360     DUQ_F           .          Missing  5294
    97948    DUQ360  DUQY_F_R          24               24     1
    97949    DUQ360  DUQY_F_R          77          Refused     0
    97950    DUQ360  DUQY_F_R          99       Don't know     0
    97951    DUQ360  DUQY_F_R           .          Missing  1008
    114603   DUQ360     DUQ_G     1 to 20  Range of Values    22
    114604   DUQ360     DUQ_G          77          Refused     0
    114605   DUQ360     DUQ_G          99       Don't know     0
    114606   DUQ360     DUQ_G           .          Missing  4774
    114809   DUQ360  DUQY_G_R    15 to 30  Range of Values     2
    114810   DUQ360  DUQY_G_R          77          Refused     0
    114811   DUQ360  DUQY_G_R          99       Don't know     0
    114812   DUQ360  DUQY_G_R           .          Missing   932
    141774   DUQ360     DUQ_H     1 to 30  Range of Values    30
    141775   DUQ360     DUQ_H          77          Refused     0
    141776   DUQ360     DUQ_H          99       Don't know     0
    141777   DUQ360     DUQ_H           .          Missing  5027
    141975   DUQ360  DUQY_H_R          77          Refused     0
    141976   DUQ360  DUQY_H_R          99       Don't know     0
    141977   DUQ360  DUQY_H_R           .          Missing  1055
    159893   DUQ360     DUQ_I     1 to 20  Range of Values    22
    159894   DUQ360     DUQ_I          77          Refused     0
    159895   DUQ360     DUQ_I          99       Don't know     0
    159896   DUQ360     DUQ_I           .          Missing  4821
    160099   DUQ360  DUQY_I_R           1                1     1
    160100   DUQ360  DUQY_I_R          77          Refused     0
    160101   DUQ360  DUQY_I_R          99       Don't know     0
    160102   DUQ360  DUQY_I_R           .          Missing  1008
    173635   DUQ360     DUQ_J     1 to 30  Range of Values    34
    173636   DUQ360     DUQ_J          77          Refused     0
    173637   DUQ360     DUQ_J          99       Don't know     0
    173638   DUQ360     DUQ_J           .          Missing  4538
    173836   DUQ360  DUQY_J_R          77          Refused     0
    173837   DUQ360  DUQY_J_R          99       Don't know     0
    173838   DUQ360  DUQY_J_R           .          Missing   868

    $DUQ400Q
           Variable TableName CodeOrValue ValueDescription Count
    62812   DUQ400Q     DUQ_D     0 to 35  Range of Values    69
    62813   DUQ400Q     DUQ_D        7777          Refused     0
    62814   DUQ400Q     DUQ_D        9999       Don't know     4
    62815   DUQ400Q     DUQ_D           .          Missing  3212
    80804   DUQ400Q     DUQ_E    1 to 251  Range of Values   109
    80805   DUQ400Q     DUQ_E        7777          Refused     2
    80806   DUQ400Q     DUQ_E        9999       Don't know     2
    80807   DUQ400Q     DUQ_E           .          Missing  4512
    80977   DUQ400Q  DUQYTH_E        7777          Refused     0
    80978   DUQ400Q  DUQYTH_E        9999       Don't know     0
    80979   DUQ400Q  DUQYTH_E           .          Missing  1210
    97768   DUQ400Q     DUQ_F     1 to 50  Range of Values    88
    97769   DUQ400Q     DUQ_F        7777          Refused     0
    97770   DUQ400Q     DUQ_F        9999       Don't know     0
    97771   DUQ400Q     DUQ_F           .          Missing  5214
    97973   DUQ400Q  DUQY_F_R           2                2     2
    97974   DUQ400Q  DUQY_F_R        7777          Refused     0
    97975   DUQ400Q  DUQY_F_R        9999       Don't know     0
    97976   DUQ400Q  DUQY_F_R           .          Missing  1007
    114628  DUQ400Q     DUQ_G     0 to 41  Range of Values    82
    114629  DUQ400Q     DUQ_G        7777          Refused     0
    114630  DUQ400Q     DUQ_G        9999       Don't know     0
    114631  DUQ400Q     DUQ_G           .          Missing  4714
    114834  DUQ400Q  DUQY_G_R           0                0     1
    114835  DUQ400Q  DUQY_G_R        7777          Refused     0
    114836  DUQ400Q  DUQY_G_R        9999       Don't know     0
    114837  DUQ400Q  DUQY_G_R           .          Missing   933
    141799  DUQ400Q     DUQ_H     0 to 48  Range of Values   105
    141800  DUQ400Q     DUQ_H        7777          Refused     0
    141801  DUQ400Q     DUQ_H        9999       Don't know     0
    141802  DUQ400Q     DUQ_H           .          Missing  4952
    141998  DUQ400Q  DUQY_H_R        7777          Refused     0
    141999  DUQ400Q  DUQY_H_R        9999       Don't know     0
    142000  DUQ400Q  DUQY_H_R           .          Missing  1055
    159919  DUQ400Q     DUQ_I    0 to 630  Range of Values    91
    159920  DUQ400Q     DUQ_I        7777          Refused     0
    159921  DUQ400Q     DUQ_I        9999       Don't know     0
    159922  DUQ400Q     DUQ_I           .          Missing  4752
    160123  DUQ400Q  DUQY_I_R        7777          Refused     0
    160124  DUQ400Q  DUQY_I_R        9999       Don't know     0
    160125  DUQ400Q  DUQY_I_R           .          Missing  1009
    173657  DUQ400Q     DUQ_J     0 to 65  Range of Values   104
    173658  DUQ400Q     DUQ_J        7777          Refused     2
    173659  DUQ400Q     DUQ_J        9999       Don't know     0
    173660  DUQ400Q     DUQ_J           .          Missing  4466
    173855  DUQ400Q  DUQY_J_R        7777          Refused     0
    173856  DUQ400Q  DUQY_J_R        9999       Don't know     0
    173857  DUQ400Q  DUQY_J_R           .          Missing   868

    $MCQ240AA
          Variable TableName CodeOrValue  ValueDescription Count
    12335 MCQ240AA       MCQ    42 to 75   Range of Values     3
    12336 MCQ240AA       MCQ          85 85 years or older     0
    12337 MCQ240AA       MCQ       77777           Refused     0
    12338 MCQ240AA       MCQ       99999        Don't know     0
    12339 MCQ240AA       MCQ           .           Missing  9490
    25941 MCQ240AA     MCQ_B    31 to 38   Range of Values     4
    25942 MCQ240AA     MCQ_B          85 85 years or older     0
    25943 MCQ240AA     MCQ_B       77777           Refused     0
    25944 MCQ240AA     MCQ_B       99999        Don't know     0
    25945 MCQ240AA     MCQ_B           .           Missing 10466
    45693 MCQ240AA     MCQ_C    27 to 60   Range of Values     5
    45694 MCQ240AA     MCQ_C          85 85 years or older     0
    45695 MCQ240AA     MCQ_C       77777           Refused     0
    45696 MCQ240AA     MCQ_C       99999        Don't know     0
    45697 MCQ240AA     MCQ_C           .           Missing  9640
    63944 MCQ240AA     MCQ_D          18                18     1
    63945 MCQ240AA     MCQ_D          85 85 years or older     0
    63946 MCQ240AA     MCQ_D       77777           Refused     0
    63947 MCQ240AA     MCQ_D       99999        Don't know     0
    63948 MCQ240AA     MCQ_D           .           Missing  9821
    77471 MCQ240AA     MCQ_E          67                67     1
    77472 MCQ240AA     MCQ_E          80 80 years or older     0
    77473 MCQ240AA     MCQ_E       77777           Refused     0
    77474 MCQ240AA     MCQ_E       99999        Don't know     0
    77475 MCQ240AA     MCQ_E           .           Missing  9665
    93989 MCQ240AA     MCQ_F    18 to 55   Range of Values     3
    93990 MCQ240AA     MCQ_F          80 80 years or older     0
    93991 MCQ240AA     MCQ_F       77777           Refused     0
    93992 MCQ240AA     MCQ_F       99999        Don't know     0
    93993 MCQ240AA     MCQ_F           .           Missing 10106

    $MCQ240b
           Variable TableName CodeOrValue  ValueDescription Count
    114149  MCQ240b     MCQ_G          40                40     1
    114150  MCQ240b     MCQ_G          80 80 years or older     0
    114151  MCQ240b     MCQ_G       77777           Refused     0
    114152  MCQ240b     MCQ_G       99999        Don't know     0
    114153  MCQ240b     MCQ_G           .           Missing  9363
    139359  MCQ240b     MCQ_H    10 to 63   Range of Values     4
    139360  MCQ240b     MCQ_H          80 80 years or older     0
    139361  MCQ240b     MCQ_H       77777           Refused     0
    139362  MCQ240b     MCQ_H       99999        Don't know     0
    139363  MCQ240b     MCQ_H           .           Missing  9766
    155990  MCQ240b     MCQ_I          70                70     1
    155991  MCQ240b     MCQ_I          80 80 years or older     0
    155992  MCQ240b     MCQ_I       77777           Refused     0
    155993  MCQ240b     MCQ_I       99999        Don't know     1
    155994  MCQ240b     MCQ_I           .           Missing  9573

    $MCQ240T
          Variable TableName CodeOrValue  ValueDescription Count
    12442  MCQ240T       MCQ          85 85 years or older     0
    12443  MCQ240T       MCQ       77777           Refused     0
    12444  MCQ240T       MCQ       99999        Don't know     0
    12445  MCQ240T       MCQ           .           Missing  9493
    26049  MCQ240T     MCQ_B          40                40     1
    26050  MCQ240T     MCQ_B          85 85 years or older     0
    26051  MCQ240T     MCQ_B       77777           Refused     0
    26052  MCQ240T     MCQ_B       99999        Don't know     0
    26053  MCQ240T     MCQ_B           .           Missing 10469
    45800  MCQ240T     MCQ_C          85 85 years or older     0
    45801  MCQ240T     MCQ_C       77777           Refused     0
    45802  MCQ240T     MCQ_C       99999        Don't know     0
    45803  MCQ240T     MCQ_C           .           Missing  9645
    64057  MCQ240T     MCQ_D          85 85 years or older     0
    64058  MCQ240T     MCQ_D       77777           Refused     0
    64059  MCQ240T     MCQ_D       99999        Don't know     0
    64060  MCQ240T     MCQ_D           .           Missing  9822
    77586  MCQ240T     MCQ_E    64 to 77   Range of Values     2
    77587  MCQ240T     MCQ_E          80 80 years or older     0
    77588  MCQ240T     MCQ_E       77777           Refused     0
    77589  MCQ240T     MCQ_E       99999        Don't know     0
    77590  MCQ240T     MCQ_E           .           Missing  9664
    94102  MCQ240T     MCQ_F          55                55     1
    94103  MCQ240T     MCQ_F          80 80 years or older     0
    94104  MCQ240T     MCQ_F       77777           Refused     0
    94105  MCQ240T     MCQ_F       99999        Don't know     0
    94106  MCQ240T     MCQ_F           .           Missing 10108

    $OSD030bf
           Variable TableName CodeOrValue ValueDescription Count
    13113  OSD030bf       OSQ    16 to 23  Range of Values     2
    13114  OSD030bf       OSQ          85      85 or older     0
    13115  OSD030bf       OSQ       77777          Refused     0
    13116  OSD030bf       OSQ       99999       Don't know     1
    13117  OSD030bf       OSQ           .          Missing  4877
    46499  OSD030bf     OSQ_C          18               18     1
    46500  OSD030bf     OSQ_C          85      85 or older     0
    46501  OSD030bf     OSQ_C       77777          Refused     0
    46502  OSD030bf     OSQ_C       99999       Don't know     0
    46503  OSD030bf     OSQ_C           .          Missing  5040
    64252  OSD030bf     OSQ_D    15 to 70  Range of Values     4
    64253  OSD030bf     OSQ_D          85      85 or older     0
    64254  OSD030bf     OSQ_D       77777          Refused     0
    64255  OSD030bf     OSQ_D       99999       Don't know     0
    64256  OSD030bf     OSQ_D           .          Missing  4975
    78903  OSD030bf     OSQ_E    16 to 29  Range of Values     2
    78904  OSD030bf     OSQ_E          80      80 or older     0
    78905  OSD030bf     OSQ_E       77777          Refused     0
    78906  OSD030bf     OSQ_E       99999       Don't know     0
    78907  OSD030bf     OSQ_E           .          Missing  5933
    96646  OSD030bf     OSQ_F           8                8     1
    96647  OSD030bf     OSQ_F          80      80 or older     0
    96648  OSD030bf     OSQ_F       77777          Refused     0
    96649  OSD030bf     OSQ_F       99999       Don't know     0
    96650  OSD030bf     OSQ_F           .          Missing  6217
    137833 OSD030bf     OSQ_H    16 to 23  Range of Values     2
    137834 OSD030bf     OSQ_H          80      80 or older     0
    137835 OSD030bf     OSQ_H       77777          Refused     0
    137836 OSD030bf     OSQ_H       99999       Don't know     0
    137837 OSD030bf     OSQ_H           .          Missing  3813

    $OSD030bg
           Variable TableName CodeOrValue ValueDescription Count
    13118  OSD030bg       OSQ    17 to 34  Range of Values     2
    13119  OSD030bg       OSQ          85      85 or older     0
    13120  OSD030bg       OSQ       77777          Refused     0
    13121  OSD030bg       OSQ       99999       Don't know     0
    13122  OSD030bg       OSQ           .          Missing  4878
    64257  OSD030bg     OSQ_D    24 to 75  Range of Values     2
    64258  OSD030bg     OSQ_D          85      85 or older     0
    64259  OSD030bg     OSQ_D       77777          Refused     0
    64260  OSD030bg     OSQ_D       99999       Don't know     0
    64261  OSD030bg     OSQ_D           .          Missing  4977
    78908  OSD030bg     OSQ_E    21 to 31  Range of Values     2
    78909  OSD030bg     OSQ_E          80      80 or older     0
    78910  OSD030bg     OSQ_E       77777          Refused     0
    78911  OSD030bg     OSQ_E       99999       Don't know     0
    78912  OSD030bg     OSQ_E           .          Missing  5933
    96651  OSD030bg     OSQ_F           9                9     1
    96652  OSD030bg     OSQ_F          80      80 or older     0
    96653  OSD030bg     OSQ_F       77777          Refused     0
    96654  OSD030bg     OSQ_F       99999       Don't know     0
    96655  OSD030bg     OSQ_F           .          Missing  6217
    137838 OSD030bg     OSQ_H          18               18     1
    137839 OSD030bg     OSQ_H          80      80 or older     0
    137840 OSD030bg     OSQ_H       77777          Refused     0
    137841 OSD030bg     OSQ_H       99999       Don't know     0
    137842 OSD030bg     OSQ_H           .          Missing  3814

    $OSD110f
           Variable TableName CodeOrValue ValueDescription Count
    64433   OSD110f     OSQ_D          29               29     1
    64434   OSD110f     OSQ_D          85      85 or older     0
    64435   OSD110f     OSQ_D         777          Refused     0
    64436   OSD110f     OSQ_D         999       Don't know     0
    64437   OSD110f     OSQ_D           .          Missing  4978
    79041   OSD110f     OSQ_E    29 to 33  Range of Values     2
    79042   OSD110f     OSQ_E          80       80or older     0
    79043   OSD110f     OSQ_E         777          Refused     0
    79044   OSD110f     OSQ_E         999       Don't know     0
    79045   OSD110f     OSQ_E           .          Missing  5933
    96765   OSD110f     OSQ_F          36               36     1
    96766   OSD110f     OSQ_F          80       80or older     0
    96767   OSD110f     OSQ_F         777          Refused     0
    96768   OSD110f     OSQ_F         999       Don't know     0
    96769   OSD110f     OSQ_F           .          Missing  6217
    174102  OSD110f     OSQ_J    28 to 55  Range of Values     3
    174103  OSD110f     OSQ_J          80      80 or older     0
    174104  OSD110f     OSQ_J         777          Refused     0
    174105  OSD110f     OSQ_J         999       Don't know     0
    174106  OSD110f     OSQ_J           .          Missing  3066

    $SMD415
           Variable TableName CodeOrValue ValueDescription Count
    15471    SMD415    SMQFAM      1 to 2  Range of Values  1921
    15472    SMD415    SMQFAM           3        3 or More   147
    15473    SMD415    SMQFAM           .          Missing  7897
    25001    SMD415  SMQFAM_B      1 to 2  Range of Values  1976
    25002    SMD415  SMQFAM_B           3        3 or More   196
    25003    SMD415  SMQFAM_B           .          Missing  8867
    44472    SMD415  SMQFAM_C      1 to 2  Range of Values  1917
    44473    SMD415  SMQFAM_C           3        3 or More   179
    44474    SMD415  SMQFAM_C           .          Missing  8026
    66877    SMD415  SMQFAM_D      1 to 2  Range of Values  1621
    66878    SMD415  SMQFAM_D           3        3 or more   138
    66879    SMD415  SMQFAM_D           .          Missing  8589
    78268    SMD415  SMQFAM_E      1 to 2  Range of Values  1635
    78269    SMD415  SMQFAM_E           3        3 or more   205
    78270    SMD415  SMQFAM_E           .          Missing  8309
    92756    SMD415  SMQFAM_F      1 to 2  Range of Values  1380
    92757    SMD415  SMQFAM_F           3        3 or more   137
    92758    SMD415  SMQFAM_F           .          Missing  9020
    113548   SMD415  SMQFAM_G           1                1   738
    113549   SMD415  SMQFAM_G           2                2   386
    113550   SMD415  SMQFAM_G           3        3 or more   105
    113551   SMD415  SMQFAM_G           .          Missing  8527

    $SMD415A
           Variable TableName CodeOrValue ValueDescription Count
    15474   SMD415A    SMQFAM      1 to 2  Range of Values  1873
    15475   SMD415A    SMQFAM           3        3 or More   143
    15476   SMD415A    SMQFAM           .          Missing  7949
    25004   SMD415A  SMQFAM_B      1 to 2  Range of Values  1925
    25005   SMD415A  SMQFAM_B           3        3 or More   185
    25006   SMD415A  SMQFAM_B           .          Missing  8929
    44475   SMD415A  SMQFAM_C      1 to 2  Range of Values  1862
    44476   SMD415A  SMQFAM_C           3        3 or More   173
    44477   SMD415A  SMQFAM_C           .          Missing  8087
    66880   SMD415A  SMQFAM_D      1 to 2  Range of Values  1545
    66881   SMD415A  SMQFAM_D           3        3 or more   135
    66882   SMD415A  SMQFAM_D           .          Missing  8668
    78271   SMD415A  SMQFAM_E      1 to 2  Range of Values  1546
    78272   SMD415A  SMQFAM_E           3        3 or more   191
    78273   SMD415A  SMQFAM_E           .          Missing  8412
    92759   SMD415A  SMQFAM_F      1 to 2  Range of Values  1315
    92760   SMD415A  SMQFAM_F           3        3 or more   126
    92761   SMD415A  SMQFAM_F           .          Missing  9096
    113552  SMD415A  SMQFAM_G           1                1   710
    113553  SMD415A  SMQFAM_G           2                2   368
    113554  SMD415A  SMQFAM_G           3        3 or more    92
    113555  SMD415A  SMQFAM_G           .          Missing  8586

    $URX2DC
           Variable TableName  CodeOrValue ValueDescription Count
    60879    URX2DC  SSUVOC_D 3.32 to 28.1  Range of Values  3169
    60880    URX2DC  SSUVOC_D            .          Missing   148
    109316   URX2DC    UVOC_G 3.32 to 19.4  Range of Values  2466
    109317   URX2DC    UVOC_G            .          Missing    85
    109456   URX2DC   UVOCS_G 3.32 to 19.4  Range of Values  2240
    109457   URX2DC   UVOCS_G            .          Missing   109
    135275   URX2DC    UVOC_H         3.32             3.32  2551
    135276   URX2DC    UVOC_H            .          Missing   204
    135415   URX2DC   UVOCS_H 3.32 to 8.97  Range of Values  2420
    135416   URX2DC   UVOCS_H            .          Missing   185
    153267   URX2DC    UVOC_I          9.8              9.8  2831
    153268   URX2DC    UVOC_I            .          Missing   448
    153415   URX2DC   UVOCS_I          9.8              9.8  2202
    153416   URX2DC   UVOCS_I            .          Missing   260

# What to do about these?

These all look like legitimate issues. Possible work-arounds are:

- Maintain an explicit list of such variables and handle them while
  creating the codebook. The least intrusive way would be to just insert
  a row with value description `"Range of   Values"`. Additionally, we
  could drop the value descriptions which can be coerced to numeric.

- Maintain an explicit list of such variables and handle them in
  `nhanesTranslate()`

The advantage of doing this at the codebook level is that the database
will have the ‘fixed’ values.

# More aggressive conversion

A more aggressive strategy would be to do this whenever there is a value
description that can be coerced to a numeric value. This will not
require retaining a list of variables to fix, but will mean that we may
end up converting some variables to numeric even though it didn’t have
`"Range of Values"` in any cycle.

To see the effect of this:

``` r
categorical_cb <- subset(all_cb, !(Variable %in% numeric_vars), select = 1:5)
cat_num_combinations <- 
    unique(subset(categorical_cb, is.finite(as.numeric(ValueDescription)), select = 1:2))
```

    Warning in eval(e, x, parent.frame()): NAs introduced by coercion

``` r
for (i in 1:nrow(cat_num_combinations)) {
    v <- cat_num_combinations$Variable[[i]]
    t <- cat_num_combinations$TableName[[i]]
    try(cat(sprintf("---------\n%s > %s (%s)\n", t, v, nhanesCodebook(t)[[v]]$`SAS Label:` )))
    print(subset(categorical_cb, TableName == t & Variable == v))
}
```

    ---------
    AUXTYM > AUDTYL84 (Tympanometry-Left Ear Measurement 84)
         Variable TableName CodeOrValue ValueDescription Count
    1983 AUDTYL84    AUXTYM           0                0  1672
    1984 AUDTYL84    AUXTYM           .          Missing   135
    ---------
    AUXTYM > AUDTYR84 (Tympanometry-Right Ear Measurement 84)
         Variable TableName CodeOrValue ValueDescription Count
    2151 AUDTYR84    AUXTYM           0                0  1682
    2152 AUDTYR84    AUXTYM           .          Missing   125
    ---------
    SSOL_A > SSIS (Flag:Insufficient sample)
         Variable TableName CodeOrValue ValueDescription Count
    8298     SSIS    SSOL_A           1                1    26
    8299     SSIS    SSOL_A   < blank >          Missing  1691
    ---------
    CIQPANIC > CIQP18 (Exact age when attack occurred)
          Variable TableName CodeOrValue ValueDescription Count
    10008   CIQP18  CIQPANIC          33               33     1
    10009   CIQP18  CIQPANIC        7777          Refused     0
    10010   CIQP18  CIQPANIC        9999       Don't know     0
    10011   CIQP18  CIQPANIC           .          Missing   777
    ---------
    CDQ > CDQ070 (Sleep on 2+ pillows to help breathe)
          Variable TableName CodeOrValue ValueDescription Count
    10948   CDQ070       CDQ           1                1   380
    10949   CDQ070       CDQ           2               No  2797
    10950   CDQ070       CDQ           7          Refused     3
    10951   CDQ070       CDQ           9       Don't know     4
    10952   CDQ070       CDQ           .          Missing     1
    ---------
    HUQ > HUQ050 (#Times received healthcare over past yr)
          Variable TableName CodeOrValue ValueDescription Count
    11671   HUQ050       HUQ           0             None  1619
    11672   HUQ050       HUQ           1                1  2006
    11673   HUQ050       HUQ           2           2 to 3  2876
    11674   HUQ050       HUQ           3           4 to 9  2262
    11675   HUQ050       HUQ           4         10 to 12   628
    11676   HUQ050       HUQ           5       13 or more   556
    11677   HUQ050       HUQ          77          Refused     0
    11678   HUQ050       HUQ          99       Don't know    13
    11679   HUQ050       HUQ           .          Missing     5
          Variable TableName CodeOrValue ValueDescription Count
    13123 OSD030bh       OSQ          17               17     1
    13124 OSD030bh       OSQ          85      85 or older     0
    13125 OSD030bh       OSQ       77777          Refused     0
    13126 OSD030bh       OSQ       99999       Don't know     0
    13127 OSD030bh       OSQ           .          Missing  4879
          Variable TableName CodeOrValue ValueDescription Count
    13128 OSD030bi       OSQ          18               18     1
    13129 OSD030bi       OSQ          85      85 or older     0
    13130 OSD030bi       OSQ       77777          Refused     0
    13131 OSD030bi       OSQ       99999       Don't know     0
    13132 OSD030bi       OSQ           .          Missing  4879
          Variable TableName CodeOrValue ValueDescription Count
    13133 OSD030bj       OSQ          18               18     1
    13134 OSD030bj       OSQ          85      85 or older     0
    13135 OSD030bj       OSQ       77777          Refused     0
    13136 OSD030bj       OSQ       99999       Don't know     0
    13137 OSD030bj       OSQ           .          Missing  4879
    ---------
    SMQFAM > SMD415B (Total # of cigar smokers in home)
          Variable TableName CodeOrValue ValueDescription Count
    15477  SMD415B    SMQFAM           1                1   292
    15478  SMD415B    SMQFAM           2        2 or More    50
    15479  SMD415B    SMQFAM           .          Missing  9623
    ---------
    SMQFAM > SMD415C (Total # of pipe smokers in home)
          Variable TableName CodeOrValue ValueDescription Count
    15480  SMD415C    SMQFAM           1                1   142
    15481  SMD415C    SMQFAM           2        2 or More    28
    15482  SMD415C    SMQFAM           .          Missing  9795
    ---------
    AUXTYM_B > AUDTYL84 (Tympanometry-Left Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    17135 AUDTYL84  AUXTYM_B           0                0  1893
    17136 AUDTYL84  AUXTYM_B           .          Missing   153
    ---------
    AUXTYM_B > AUDTYR84 (Tympanometry-Right Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    17303 AUDTYR84  AUXTYM_B           0                0  1890
    17304 AUDTYR84  AUXTYM_B           .          Missing   156
    ---------
    OHXPRU_B > OHX14BPM (BOP: midfacial #14)
          Variable TableName CodeOrValue                              ValueDescription Count
    20621 OHX14BPM  OHXPRU_B           1    Bleeding is detected following the probing   212
    20622 OHX14BPM  OHXPRU_B           2 No evidence of bleeding following the probing  2040
    20623 OHX14BPM  OHXPRU_B           3                            Cannot be assessed     0
    20624 OHX14BPM  OHXPRU_B           9                                             9   541
    20625 OHX14BPM  OHXPRU_B           .                                       Missing  4337
    ---------
    SSOL_B > SSIS (Flag:Insufficient sample)
          Variable TableName CodeOrValue ValueDescription Count
    23630     SSIS    SSOL_B           1                1    14
    23631     SSIS    SSOL_B   < blank >          Missing  2027
    ---------
    SSOL_B > SSSPIKE2 (Size of 2nd peak if available)
          Variable TableName CodeOrValue ValueDescription Count
    23657 SSSPIKE2    SSOL_B         0.5              0.5     1
    23658 SSSPIKE2    SSOL_B         0.6              0.6     1
    23659 SSSPIKE2    SSOL_B         0.7              0.7     1
    23660 SSSPIKE2    SSOL_B   < blank >          Missing  2038
    ---------
    CDQ_B > CDQ009A (Pain in right arm)
          Variable TableName CodeOrValue ValueDescription Count
    24502  CDQ009A     CDQ_B           1                1    14
    24503  CDQ009A     CDQ_B          77          Refused     0
    24504  CDQ009A     CDQ_B          99       Don't know     1
    24505  CDQ009A     CDQ_B           .          Missing  3471
    ---------
    CDQ_B > CDQ009B (Pain in right chest)
          Variable TableName CodeOrValue ValueDescription Count
    24506  CDQ009B     CDQ_B           2                2    27
    24507  CDQ009B     CDQ_B           .          Missing  3459
    ---------
    CDQ_B > CDQ009C (Pain in neck)
          Variable TableName CodeOrValue ValueDescription Count
    24508  CDQ009C     CDQ_B           3                3    21
    24509  CDQ009C     CDQ_B           .          Missing  3465
    ---------
    CDQ_B > CDQ009D (Pain in upper sternum)
          Variable TableName CodeOrValue ValueDescription Count
    24510  CDQ009D     CDQ_B           4                4   111
    24511  CDQ009D     CDQ_B           .          Missing  3375
    ---------
    CDQ_B > CDQ009E (Pain in lower sternum)
          Variable TableName CodeOrValue ValueDescription Count
    24512  CDQ009E     CDQ_B           5                5    29
    24513  CDQ009E     CDQ_B           .          Missing  3457
    ---------
    CDQ_B > CDQ009F (Pain in left chest)
          Variable TableName CodeOrValue ValueDescription Count
    24514  CDQ009F     CDQ_B           6                6    63
    24515  CDQ009F     CDQ_B           .          Missing  3423
    ---------
    CDQ_B > CDQ009G (Pain in left arm)
          Variable TableName CodeOrValue ValueDescription Count
    24516  CDQ009G     CDQ_B           7                7    19
    24517  CDQ009G     CDQ_B           .          Missing  3467
    ---------
    CDQ_B > CDQ009H (Pain in epigastric area)
          Variable TableName CodeOrValue ValueDescription Count
    24518  CDQ009H     CDQ_B           8                8     6
    24519  CDQ009H     CDQ_B           .          Missing  3480
    ---------
    SMQFAM_B > SMD415B (Total # of cigar smokers in home)
          Variable TableName CodeOrValue ValueDescription Count
    25007  SMD415B  SMQFAM_B           1                1   144
    25008  SMD415B  SMQFAM_B           2        2 or More    25
    25009  SMD415B  SMQFAM_B           .          Missing 10870
    ---------
    SMQFAM_B > SMD415C (Total # of pipe smokers in home)
          Variable TableName CodeOrValue ValueDescription Count
    25010  SMD415C  SMQFAM_B           1                1    61
    25011  SMD415C  SMQFAM_B           2        2 or More     9
    25012  SMD415C  SMQFAM_B           .          Missing 10969
    ---------
    HUQ_B > HUQ050 (#Times receive healthcare over past year)
          Variable TableName CodeOrValue ValueDescription Count
    25398   HUQ050     HUQ_B           0             None  1641
    25399   HUQ050     HUQ_B           1                1  2346
    25400   HUQ050     HUQ_B           2           2 to 3  3259
    25401   HUQ050     HUQ_B           3           4 to 9  2589
    25402   HUQ050     HUQ_B           4         10 to 12   578
    25403   HUQ050     HUQ_B           5       13 or more   618
    25404   HUQ050     HUQ_B          77          Refused     0
    25405   HUQ050     HUQ_B          99       Don't know     8
    25406   HUQ050     HUQ_B           .          Missing     0
          Variable TableName CodeOrValue ValueDescription Count
    26669 OSQ030cc     OSQ_B          71               71     1
    26670 OSQ030cc     OSQ_B       77777          Refused     0
    26671 OSQ030cc     OSQ_B       99999       Don't know     0
    26672 OSQ030cc     OSQ_B           .          Missing  5410
          Variable TableName CodeOrValue ValueDescription Count
    26673 OSQ030cd     OSQ_B          72               72     1
    26674 OSQ030cd     OSQ_B       77777          Refused     0
    26675 OSQ030cd     OSQ_B       99999       Don't know     0
    26676 OSQ030cd     OSQ_B           .          Missing  5410
          Variable TableName CodeOrValue ValueDescription Count
    26677 OSQ030ce     OSQ_B          74               74     1
    26678 OSQ030ce     OSQ_B       77777          Refused     0
    26679 OSQ030ce     OSQ_B       99999       Don't know     0
    26680 OSQ030ce     OSQ_B           .          Missing  5410
          Variable TableName CodeOrValue ValueDescription Count
    26681 OSQ030cf     OSQ_B          76               76     1
    26682 OSQ030cf     OSQ_B       77777          Refused     0
    26683 OSQ030cf     OSQ_B       99999       Don't know     0
    26684 OSQ030cf     OSQ_B           .          Missing  5410
    ---------
    AUXTYM_C > AUDTYL84 (Tympanometry-Left Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    34700 AUDTYL84  AUXTYM_C           0                0  1774
    34701 AUDTYL84  AUXTYM_C           .          Missing   115
    ---------
    AUXTYM_C > AUDTYR84 (Tympanometry-Right Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    34868 AUDTYR84  AUXTYM_C           0                0  1774
    34869 AUDTYR84  AUXTYM_C           .          Missing   115
    ---------
    DEX_C > DEA6RTYP (Reader 6 code)
          Variable TableName CodeOrValue ValueDescription Count
    35513 DEA6RTYP     DEX_C           6                6   260
    35514 DEA6RTYP     DEX_C           .          Missing  2732
    ---------
    OHXDEN_C > OHXEDEN (Edentulous-yes)
          Variable TableName CodeOrValue ValueDescription Count
    37914  OHXEDEN  OHXDEN_C           1              Yes   482
    37915  OHXEDEN  OHXDEN_C           2                2    12
    37916  OHXEDEN  OHXDEN_C           .          Missing  8353
    ---------
    OHXPRU_C > OHX14BPM (BOP: midfacial #14)
          Variable TableName CodeOrValue                              ValueDescription Count
    39016 OHX14BPM  OHXPRU_C           1    Bleeding is detected following the probing   143
    39017 OHX14BPM  OHXPRU_C           2 No evidence of bleeding following the probing  1909
    39018 OHX14BPM  OHXPRU_C           3                            Cannot be assessed     0
    39019 OHX14BPM  OHXPRU_C           9                                             9   503
    39020 OHX14BPM  OHXPRU_C           .                                       Missing  4163
    ---------
    L26UPP_C > URXSSF (Sulfosulfuron (ug/L))
          Variable TableName CodeOrValue ValueDescription Count
    40302   URXSSF  L26UPP_C       0.035            0.035  2389
    40303   URXSSF  L26UPP_C        0.07             0.07     1
    40304   URXSSF  L26UPP_C        0.09             0.09     1
    40305   URXSSF  L26UPP_C           .          Missing   221
    ---------
    SSOL_C > SSIS (Flag:Insufficient sample)
          Variable TableName CodeOrValue ValueDescription Count
    43250     SSIS    SSOL_C           1                1    13
    43251     SSIS    SSOL_C   < blank >          Missing  2076
    ---------
    SSOL_C > SSSPIKE2 (Size of 2nd peak if available)
          Variable TableName CodeOrValue ValueDescription Count
    43279 SSSPIKE2    SSOL_C         0.5              0.5     1
    43280 SSSPIKE2    SSOL_C         0.7              0.7     1
    43281 SSSPIKE2    SSOL_C           2                2     1
    43282 SSSPIKE2    SSOL_C   < blank >          Missing  2086
    ---------
    SMQFAM_C > SMD415B (Total # of cigar smokers in home)
          Variable TableName CodeOrValue ValueDescription Count
    44478  SMD415B  SMQFAM_C           1                1   194
    44479  SMD415B  SMQFAM_C           2        2 or More    19
    44480  SMD415B  SMQFAM_C           .          Missing  9909
    ---------
    SMQFAM_C > SMD415C (Total # of pipe smokers in home)
          Variable TableName CodeOrValue ValueDescription Count
    44481  SMD415C  SMQFAM_C           1                1    90
    44482  SMD415C  SMQFAM_C           2        2 or More    10
    44483  SMD415C  SMQFAM_C           .          Missing 10022
    ---------
    HUQ_C > HUQ050 (#Times receive healthcare over past year)
          Variable TableName CodeOrValue ValueDescription Count
    45116   HUQ050     HUQ_C           0             None  1250
    45117   HUQ050     HUQ_C           1                1  2082
    45118   HUQ050     HUQ_C           2           2 to 3  2987
    45119   HUQ050     HUQ_C           3           4 to 9  2551
    45120   HUQ050     HUQ_C           4         10 to 12   615
    45121   HUQ050     HUQ_C           5       13 or more   630
    45122   HUQ050     HUQ_C          77          Refused     0
    45123   HUQ050     HUQ_C          99       Don't know     7
    45124   HUQ050     HUQ_C           .          Missing     0
          Variable TableName CodeOrValue ValueDescription Count
    46529 OSD030cf     OSQ_C          24               24     1
    46530 OSD030cf     OSQ_C          85      85 or older     0
    46531 OSD030cf     OSQ_C       77777          Refused     0
    46532 OSD030cf     OSQ_C       99999       Don't know     1
    46533 OSD030cf     OSQ_C           .          Missing  5039
    ---------
    AUXTYM_D > AUDTYL84 (Tympanometry-Left Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    55068 AUDTYL84  AUXTYM_D           0                0  2756
    55069 AUDTYL84  AUXTYM_D           .          Missing   278
    ---------
    AUXTYM_D > AUDTYR84 (Tympanometry-Right Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    55236 AUDTYR84  AUXTYM_D           0                0  2754
    55237 AUDTYR84  AUXTYM_D           .          Missing   280
    ---------
    UPP_D > URXSSF (Sulfosulfuron (ug/L))
          Variable TableName CodeOrValue ValueDescription Count
    58680   URXSSF     UPP_D      0.0354           0.0354  2593
    58681   URXSSF     UPP_D           .          Missing   163
    ---------
    HUQ_D > HUQ050 (#times receive healthcare over past year)
          Variable TableName CodeOrValue ValueDescription Count
    63391   HUQ050     HUQ_D           0             None  1526
    63392   HUQ050     HUQ_D           1                1  2117
    63393   HUQ050     HUQ_D           2           2 to 3  3066
    63394   HUQ050     HUQ_D           3           4 to 9  2433
    63395   HUQ050     HUQ_D           4         10 to 12   595
    63396   HUQ050     HUQ_D           5       13 or more   602
    63397   HUQ050     HUQ_D          77          Refused     0
    63398   HUQ050     HUQ_D          99       Don't know     9
    63399   HUQ050     HUQ_D           .          Missing     0
    ---------
    KIQ_U_D > KIQ480 (How many times urinate in night?)
          Variable TableName CodeOrValue ValueDescription Count
    63598   KIQ480   KIQ_U_D           0                0  1519
    63599   KIQ480   KIQ_U_D           1                1  1448
    63600   KIQ480   KIQ_U_D           2                2   804
    63601   KIQ480   KIQ_U_D           3                3   336
    63602   KIQ480   KIQ_U_D           4                4   115
    63603   KIQ480   KIQ_U_D           5       5 or more?   105
    63604   KIQ480   KIQ_U_D           7          Refused     0
    63605   KIQ480   KIQ_U_D           9       Don't know    17
    63606   KIQ480   KIQ_U_D           .          Missing   635
    ---------
    MCQ_D > MCQ230A (What kind of cancer)
          Variable TableName CodeOrValue            ValueDescription Count
    63802  MCQ230A     MCQ_D           9                           9     1
    63803  MCQ230A     MCQ_D          10                     Bladder     6
    63804  MCQ230A     MCQ_D          11                       Blood     1
    63805  MCQ230A     MCQ_D          12                        Bone     1
    63806  MCQ230A     MCQ_D          13                       Brain     2
    63807  MCQ230A     MCQ_D          14                      Breast    76
    63808  MCQ230A     MCQ_D          15           Cervix (cervical)    41
    63809  MCQ230A     MCQ_D          16                       Colon    22
    63810  MCQ230A     MCQ_D          17      Esophagus (esophageal)     1
    63811  MCQ230A     MCQ_D          18                 Gallbladder     0
    63812  MCQ230A     MCQ_D          19                      Kidney     4
    63813  MCQ230A     MCQ_D          20            Larynx/ windpipe     2
    63814  MCQ230A     MCQ_D          21                    Leukemia     0
    63815  MCQ230A     MCQ_D          22                       Liver     1
    63816  MCQ230A     MCQ_D          23                        Lung    11
    63817  MCQ230A     MCQ_D          24  Lymphoma/Hodgkin's disease     9
    63818  MCQ230A     MCQ_D          25                    Melanoma    24
    63819  MCQ230A     MCQ_D          26            Mouth/tongue/lip     3
    63820  MCQ230A     MCQ_D          27              Nervous system     0
    63821  MCQ230A     MCQ_D          28             Ovary (ovarian)     4
    63822  MCQ230A     MCQ_D          29       Pancreas (pancreatic)     0
    63823  MCQ230A     MCQ_D          30                    Prostate    54
    63824  MCQ230A     MCQ_D          31             Rectum (rectal)     2
    63825  MCQ230A     MCQ_D          32         Skin (non-melanoma)    73
    63826  MCQ230A     MCQ_D          33 Skin (don't know what kind)    30
    63827  MCQ230A     MCQ_D          34 Soft tissue (muscle or fat)     1
    63828  MCQ230A     MCQ_D          35                     Stomach     3
    63829  MCQ230A     MCQ_D          36         Testis (testicular)     1
    63830  MCQ230A     MCQ_D          37                     Thyroid     8
    63831  MCQ230A     MCQ_D          38            Uterus (uterine)    17
    63832  MCQ230A     MCQ_D          39                       Other    12
    63833  MCQ230A     MCQ_D          66           More than 3 kinds     0
    63834  MCQ230A     MCQ_D          77                     Refused     0
    63835  MCQ230A     MCQ_D          99                  Don't know     4
    63836  MCQ230A     MCQ_D           .                     Missing  9408
          Variable TableName CodeOrValue ValueDescription Count
    64287 OSD030cf     OSQ_D          44               44     1
    64288 OSD030cf     OSQ_D          85      85 or older     0
    64289 OSD030cf     OSQ_D       77777          Refused     0
    64290 OSD030cf     OSQ_D       99999       Don't know     1
    64291 OSD030cf     OSQ_D           .          Missing  4977
          Variable TableName CodeOrValue ValueDescription Count
    64292 OSD030cg     OSQ_D          45               45     1
    64293 OSD030cg     OSQ_D          85      85 or older     0
    64294 OSD030cg     OSQ_D       77777          Refused     0
    64295 OSD030cg     OSQ_D       99999       Don't know     0
    64296 OSD030cg     OSQ_D           .          Missing  4978
          Variable TableName CodeOrValue ValueDescription Count
    64297 OSD030ch     OSQ_D          46               46     1
    64298 OSD030ch     OSQ_D          85      85 or older     0
    64299 OSD030ch     OSQ_D       77777          Refused     0
    64300 OSD030ch     OSQ_D       99999       Don't know     0
    64301 OSD030ch     OSQ_D           .          Missing  4978
          Variable TableName CodeOrValue ValueDescription Count
    64302 OSD030ci     OSQ_D          47               47     1
    64303 OSD030ci     OSQ_D          85      85 or older     0
    64304 OSD030ci     OSQ_D       77777          Refused     0
    64305 OSD030ci     OSQ_D       99999       Don't know     0
    64306 OSD030ci     OSQ_D           .          Missing  4978
          Variable TableName CodeOrValue ValueDescription Count
    64307 OSD030cj     OSQ_D          48               48     1
    64308 OSD030cj     OSQ_D          85      85 or older     0
    64309 OSD030cj     OSQ_D       77777          Refused     0
    64310 OSD030cj     OSQ_D       99999       Don't know     0
    64311 OSD030cj     OSQ_D           .          Missing  4978
    ---------
    AUXTYM_E > AUDTYL84 (Tympanometry-Left Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    71574 AUDTYL84  AUXTYM_E           0                0  1139
    71575 AUDTYL84  AUXTYM_E           .          Missing    71
    ---------
    AUXTYM_E > AUDTYR84 (Tympanometry-Right Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    71742 AUDTYR84  AUXTYM_E           0                0  1140
    71743 AUDTYR84  AUXTYM_E           .          Missing    70
    ---------
    UPP_E > URXSSF (Sulfosulfuron (ug/L))
          Variable TableName CodeOrValue ValueDescription Count
    74841   URXSSF     UPP_E      0.0354           0.0354  2529
    74842   URXSSF     UPP_E        0.07             0.07     1
    74843   URXSSF     UPP_E           .          Missing   164
    ---------
    UAM_E > URXAAZ (Atrazine result (ug/L))
          Variable TableName CodeOrValue ValueDescription Count
    75952   URXAAZ     UAM_E      0.3536           0.3536  2588
    75953   URXAAZ     UAM_E           .          Missing   106
    ---------
    VOCWB_E > LBX4CE (Blood 1112-tetrachloroethane (ng/mL))
          Variable TableName CodeOrValue ValueDescription Count
    76122   LBX4CE   VOCWB_E      0.0283           0.0283  2750
    76123   LBX4CE   VOCWB_E           .          Missing   665
    ---------
    VOCWB_E > LBXVDE (Blood 12-dibromoethane (ng/ml))
          Variable TableName CodeOrValue ValueDescription Count
    76154   LBXVDE   VOCWB_E      0.0106           0.0106  2577
    76155   LBXVDE   VOCWB_E           .          Missing   838
    ---------
    KIQ_U_E > KIQ480 (How many times urinate in night?)
          Variable TableName CodeOrValue ValueDescription Count
    77111   KIQ480   KIQ_U_E           0                0  1765
    77112   KIQ480   KIQ_U_E           1                1  1774
    77113   KIQ480   KIQ_U_E           2                2   995
    77114   KIQ480   KIQ_U_E           3                3   445
    77115   KIQ480   KIQ_U_E           4                4   133
    77116   KIQ480   KIQ_U_E           5       5 or more?    95
    77117   KIQ480   KIQ_U_E           7          Refused     2
    77118   KIQ480   KIQ_U_E           9       Don't know    16
    77119   KIQ480   KIQ_U_E           .          Missing   710
    ---------
    MCQ_E > MCQ240I (Age gallbladder cancer first diagnosed)
          Variable TableName CodeOrValue  ValueDescription Count
    77531  MCQ240I     MCQ_E          52                52     1
    77532  MCQ240I     MCQ_E          80 80 years or older     0
    77533  MCQ240I     MCQ_E       77777           Refused     0
    77534  MCQ240I     MCQ_E       99999        Don't know     0
    77535  MCQ240I     MCQ_E           .           Missing  9665
    ---------
    MCQ_E > MCQ240R (Age nervous system cancer diagnosed)
          Variable TableName CodeOrValue  ValueDescription Count
    77576  MCQ240R     MCQ_E          23                23     1
    77577  MCQ240R     MCQ_E          80 80 years or older     0
    77578  MCQ240R     MCQ_E       77777           Refused     0
    77579  MCQ240R     MCQ_E       99999        Don't know     0
    77580  MCQ240R     MCQ_E           .           Missing  9665
          Variable TableName CodeOrValue ValueDescription Count
    78868 OSD030ad     OSQ_E          73               73     1
    78869 OSD030ad     OSQ_E          80      80 or older     0
    78870 OSD030ad     OSQ_E       77777          Refused     0
    78871 OSD030ad     OSQ_E       99999       Don't know     0
    78872 OSD030ad     OSQ_E           .          Missing  5934
          Variable TableName CodeOrValue ValueDescription Count
    78873 OSD030ae     OSQ_E          74               74     1
    78874 OSD030ae     OSQ_E          80      80 or older     0
    78875 OSD030ae     OSQ_E       77777          Refused     0
    78876 OSD030ae     OSQ_E       99999       Don't know     0
    78877 OSD030ae     OSQ_E           .          Missing  5934
    ---------
    HUQ_E > HUQ050 (#times receive healthcare over past year)
          Variable TableName CodeOrValue ValueDescription Count
    80039   HUQ050     HUQ_E           0             None  1449
    80040   HUQ050     HUQ_E           1                1  1957
    80041   HUQ050     HUQ_E           2           2 to 3  2946
    80042   HUQ050     HUQ_E           3           4 to 9  2638
    80043   HUQ050     HUQ_E           4         10 to 12   604
    80044   HUQ050     HUQ_E           5       13 or more   546
    80045   HUQ050     HUQ_E          77          Refused     1
    80046   HUQ050     HUQ_E          99       Don't know     8
    80047   HUQ050     HUQ_E           .          Missing     0
    ---------
    DSQIDS_F > DSD128JJ (To build muscle/weight gain)
          Variable TableName CodeOrValue ValueDescription Count
    84671 DSD128JJ  DSQIDS_F          44               44    30
    84672 DSD128JJ  DSQIDS_F           .          Missing  8370
          Variable TableName CodeOrValue  ValueDescription Count
    86780  SPQ070b     SPX_F           2 a collapsed lung?    59
    86781  SPQ070b     SPX_F          99                99     4
    86782  SPQ070b     SPX_F           .           Missing  8132
    ---------
    AUXTYM_F > AUDTYL84 (Tympanometry-Left Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    88967 AUDTYL84  AUXTYM_F           0                0  2154
    88968 AUDTYL84  AUXTYM_F           .          Missing   214
    ---------
    AUXTYM_F > AUDTYR84 (Tympanometry-Right Ear Measurement 84)
          Variable TableName CodeOrValue ValueDescription Count
    89135 AUDTYR84  AUXTYM_F           0                0  2160
    89136 AUDTYR84  AUXTYM_F           .          Missing   208
    ---------
    PHTHTE_F > URDMHPLC (Mono-(2-ethyl)-hexyl phthalate comment)
          Variable TableName CodeOrValue                ValueDescription Count
    91413 URDMHPLC  PHTHTE_F           0 At or above the detection limit  2128
    91414 URDMHPLC  PHTHTE_F           1     Below lower detection limit   620
    91415 URDMHPLC  PHTHTE_F          37                              37     1
    91416 URDMHPLC  PHTHTE_F           .                         Missing    70
    ---------
    VOCWB_F > LBX4CE (Blood 1112-Tetrachloroethane (ng/mL))
          Variable TableName CodeOrValue ValueDescription Count
    92218   LBX4CE   VOCWB_F      0.0283           0.0283  3280
    92219   LBX4CE   VOCWB_F           .          Missing   465
    ---------
    VOCWB_F > LBXVDE (Blood 12-Dibromoethane (ng/mL))
          Variable TableName CodeOrValue ValueDescription Count
    92252   LBXVDE   VOCWB_F      0.0106           0.0106  3212
    92253   LBXVDE   VOCWB_F           .          Missing   533
    ---------
    HUQ_F > HUQ050 (#times receive healthcare over past year)
          Variable TableName CodeOrValue ValueDescription Count
    96040   HUQ050     HUQ_F           0             None  1398
    96041   HUQ050     HUQ_F           1                1  2039
    96042   HUQ050     HUQ_F           2           2 to 3  3237
    96043   HUQ050     HUQ_F           3           4 to 9  2626
    96044   HUQ050     HUQ_F           4         10 to 12   635
    96045   HUQ050     HUQ_F           5       13 or more   587
    96046   HUQ050     HUQ_F          77          Refused     1
    96047   HUQ050     HUQ_F          99       Don't know    14
    96048   HUQ050     HUQ_F           .          Missing     0
          Variable TableName CodeOrValue ValueDescription Count
    96656 OSD030bh     OSQ_F          10               10     1
    96657 OSD030bh     OSQ_F          80      80 or older     0
    96658 OSD030bh     OSQ_F       77777          Refused     0
    96659 OSD030bh     OSQ_F       99999       Don't know     0
    96660 OSD030bh     OSQ_F           .          Missing  6217
          Variable TableName CodeOrValue ValueDescription Count
    96661 OSD030bi     OSQ_F          11               11     1
    96662 OSD030bi     OSQ_F          80      80 or older     0
    96663 OSD030bi     OSQ_F       77777          Refused     0
    96664 OSD030bi     OSQ_F       99999       Don't know     0
    96665 OSD030bi     OSQ_F           .          Missing  6217
          Variable TableName CodeOrValue ValueDescription Count
    96666 OSD030bj     OSQ_F          11               11     1
    96667 OSD030bj     OSQ_F          80      80 or older     0
    96668 OSD030bj     OSQ_F       77777          Refused     0
    96669 OSD030bj     OSQ_F       99999       Don't know     0
    96670 OSD030bj     OSQ_F           .          Missing  6217
    ---------
    KIQ_U_F > KIQ480 (How many times urinate in night?)
          Variable TableName CodeOrValue ValueDescription Count
    97246   KIQ480   KIQ_U_F           0                0  1665
    97247   KIQ480   KIQ_U_F           1                1  2020
    97248   KIQ480   KIQ_U_F           2                2   916
    97249   KIQ480   KIQ_U_F           3                3   445
    97250   KIQ480   KIQ_U_F           4                4   152
    97251   KIQ480   KIQ_U_F           5       5 or more?   104
    97252   KIQ480   KIQ_U_F           7          Refused     1
    97253   KIQ480   KIQ_U_F           9       Don't know    12
    97254   KIQ480   KIQ_U_F           .          Missing   903
    ---------
    AUXTYM_G > AUDTYL84 (Tympanometry-Left Ear Measurement 84)
           Variable TableName CodeOrValue ValueDescription Count
    105949 AUDTYL84  AUXTYM_G           0                0  3834
    105950 AUDTYL84  AUXTYM_G           .          Missing   666
    ---------
    AUXTYM_G > AUDTYR84 (Tympanometry-Right Ear Measurement 84)
           Variable TableName CodeOrValue ValueDescription Count
    106117 AUDTYR84  AUXTYM_G           0                0  3840
    106118 AUDTYR84  AUXTYM_G           .          Missing   660
    ---------
    VOCWB_G > LBX4CE (Blood 1112-Tetrachloroethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    110289   LBX4CE   VOCWB_G      0.0283           0.0283  2789
    110290   LBX4CE   VOCWB_G           .          Missing   505
    ---------
    VOCWB_G > LBXVDE (Blood 12-Dibromoethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    110321   LBXVDE   VOCWB_G      0.0106           0.0106  2788
    110322   LBXVDE   VOCWB_G           .          Missing   506
    ---------
    SSANA2_G > SSCENPOS (nucleus CEN-F-like positive)
           Variable TableName CodeOrValue ValueDescription Count
    111065 SSCENPOS  SSANA2_G           0                0  4265
    111066 SSCENPOS  SSANA2_G           .          Missing     0
    ---------
    SSANA2_G > SSCENSIG (nucleus CEC-F like signal)
           Variable TableName CodeOrValue ValueDescription Count
    111067 SSCENSIG  SSANA2_G           0                0  4265
    111068 SSCENSIG  SSANA2_G           .          Missing     0
    ---------
    HUQ_G > HUQ050 (#times receive healthcare over past year)
           Variable TableName CodeOrValue ValueDescription Count
    112623   HUQ050     HUQ_G           0             None  1297
    112624   HUQ050     HUQ_G           1                1  2017
    112625   HUQ050     HUQ_G           2           2 to 3  2969
    112626   HUQ050     HUQ_G           3           4 to 9  2397
    112627   HUQ050     HUQ_G           4         10 to 12   529
    112628   HUQ050     HUQ_G           5       13 or more   537
    112629   HUQ050     HUQ_G          77          Refused     1
    112630   HUQ050     HUQ_G          99       Don't know     9
    112631   HUQ050     HUQ_G           .          Missing     0
    ---------
    KIQ_U_G > KIQ480 (How many times urinate in night?)
           Variable TableName CodeOrValue ValueDescription Count
    116489   KIQ480   KIQ_U_G           0                0  1480
    116490   KIQ480   KIQ_U_G           1                1  1733
    116491   KIQ480   KIQ_U_G           2                2   844
    116492   KIQ480   KIQ_U_G           3                3   386
    116493   KIQ480   KIQ_U_G           4                4   149
    116494   KIQ480   KIQ_U_G           5       5 or more?    83
    116495   KIQ480   KIQ_U_G           7          Refused     0
    116496   KIQ480   KIQ_U_G           9       Don't know     4
    116497   KIQ480   KIQ_U_G           .          Missing   881
    ---------
    DXXT4_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    124009 DXXANIDX   DXXT4_H           0                0  2995
    124010 DXXANIDX   DXXT4_H           .          Missing   713
    ---------
    DXXT5_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    124454 DXXANIDX   DXXT5_H           1                1  3110
    124455 DXXANIDX   DXXT5_H           .          Missing   598
    ---------
    DXXT6_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    124899 DXXANIDX   DXXT6_H           2                2  3195
    124900 DXXANIDX   DXXT6_H           .          Missing   513
    ---------
    DXXT7_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    125344 DXXANIDX   DXXT7_H           3                3  3242
    125345 DXXANIDX   DXXT7_H           .          Missing   466
    ---------
    DXXT8_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    125789 DXXANIDX   DXXT8_H           4                4  3276
    125790 DXXANIDX   DXXT8_H           .          Missing   432
    ---------
    DXXT9_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    126234 DXXANIDX   DXXT9_H           5                5  3293
    126235 DXXANIDX   DXXT9_H           .          Missing   415
    ---------
    DXXT10_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    126679 DXXANIDX  DXXT10_H           6                6  3302
    126680 DXXANIDX  DXXT10_H           .          Missing   406
    ---------
    DXXT11_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    127124 DXXANIDX  DXXT11_H           7                7  3300
    127125 DXXANIDX  DXXT11_H           .          Missing   408
    ---------
    DXXT12_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    127569 DXXANIDX  DXXT12_H           8                8  3295
    127570 DXXANIDX  DXXT12_H           .          Missing   413
    ---------
    DXXL1_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    128014 DXXANIDX   DXXL1_H           9                9  3294
    128015 DXXANIDX   DXXL1_H           .          Missing   414
    ---------
    DXXL2_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    128459 DXXANIDX   DXXL2_H          10               10  3286
    128460 DXXANIDX   DXXL2_H           .          Missing   422
    ---------
    DXXL3_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    128904 DXXANIDX   DXXL3_H          11               11  3274
    128905 DXXANIDX   DXXL3_H           .          Missing   434
    ---------
    DXXL4_H > DXXANIDX (Number of vertebra)
           Variable TableName CodeOrValue ValueDescription Count
    129349 DXXANIDX   DXXL4_H          12               12  3251
    129350 DXXANIDX   DXXL4_H           .          Missing   457
    Error in .checkTableNames(nh_table) : 
      Table(s) UR1_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    131694   UR1010   UR1_H_R         120              120     1
    131695   UR1010   UR1_H_R      777777          Refused     0
    131696   UR1010   UR1_H_R      999999       Don't know     0
    131697   UR1010   UR1_H_R           .          Missing  1102
    Error in .checkTableNames(nh_table) : 
      Table(s) UR1_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    131764    VSTRA   UR1_H_R           1                1  1103
    131765    VSTRA   UR1_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) UR1_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    131766 VSTRABRR   UR1_H_R           1                1  1103
    131767 VSTRABRR   UR1_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1LT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    131893    VSTRA  U1LT_H_R           1                1  1103
    131894    VSTRA  U1LT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1LT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    131895 VSTRABRR  U1LT_H_R           1                1  1103
    131896 VSTRABRR  U1LT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1KM_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132022    VSTRA  U1KM_H_R           1                1  1103
    132023    VSTRA  U1KM_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1KM_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132024 VSTRABRR  U1KM_H_R           1                1  1103
    132025 VSTRABRR  U1KM_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) HUKM_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132201    VSTRA  HUKM_H_R           1                1   827
    132202    VSTRA  HUKM_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) HUKM_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132203 VSTRABRR  HUKM_H_R           1                1   827
    132204 VSTRABRR  HUKM_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) HULT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132380    VSTRA  HULT_H_R           1                1   827
    132381    VSTRA  HULT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) HULT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132382 VSTRABRR  HULT_H_R           1                1   827
    132383 VSTRABRR  HULT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1IO_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132493    VSTRA  U1IO_H_R           1                1  1103
    132494    VSTRA  U1IO_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1IO_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132495 VSTRABRR  U1IO_H_R           1                1  1103
    132496 VSTRABRR  U1IO_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2LT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132779    VSTRA  U2LT_H_R           1                1  1103
    132780    VSTRA  U2LT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2LT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132781 VSTRABRR  U2LT_H_R           1                1  1103
    132782 VSTRABRR  U2LT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2IO_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132894    VSTRA  U2IO_H_R           1                1  1103
    132895    VSTRA  U2IO_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2IO_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    132896 VSTRABRR  U2IO_H_R           1                1  1103
    132897 VSTRABRR  U2IO_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2KM_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    133025    VSTRA  U2KM_H_R           1                1  1103
    133026    VSTRA  U2KM_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2KM_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    133027 VSTRABRR  U2KM_H_R           1                1  1103
    133028 VSTRABRR  U2KM_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) UR2_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    133201    VSTRA   UR2_H_R           1                1  1103
    133202    VSTRA   UR2_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) UR2_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    133203 VSTRABRR   UR2_H_R           1                1  1103
    133204 VSTRABRR   UR2_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) SSLT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    133672    VSTRA  SSLT_H_R           1                1   719
    133673    VSTRA  SSLT_H_R           .          Missing     0
    ---------
    VOCWB_H > LBX4CE (Blood 1112-Tetrachloroethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    134275   LBX4CE   VOCWB_H      0.0283           0.0283  3148
    134276   LBX4CE   VOCWB_H           .          Missing   341
    ---------
    VOCWB_H > LBXVDE (Blood 12-Dibromoethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    134309   LBXVDE   VOCWB_H      0.0106           0.0106  3203
    134310   LBXVDE   VOCWB_H           .          Missing   286
    ---------
    VOCWBS_H > LBX4CE (Blood 1112-Tetrachloroethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    134586   LBX4CE  VOCWBS_H      0.0283           0.0283  3129
    134587   LBX4CE  VOCWBS_H           .          Missing   318
    ---------
    VOCWBS_H > LBXVDE (Blood 12-Dibromoethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    134620   LBXVDE  VOCWBS_H      0.0106           0.0106  3188
    134621   LBXVDE  VOCWBS_H           .          Missing   259
    Error in .checkTableNames(nh_table) : 
      Table(s) U1PT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    136236    VSTRA  U1PT_H_R           1                1  1103
    136237    VSTRA  U1PT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1PT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    136238 VSTRABRR  U1PT_H_R           1                1  1103
    136239 VSTRABRR  U1PT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2PT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    136381    VSTRA  U2PT_H_R           1                1  1103
    136382    VSTRA  U2PT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2PT_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    136383 VSTRABRR  U2PT_H_R           1                1  1103
    136384 VSTRABRR  U2PT_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1CF_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    136739    VSTRA  U1CF_H_R           1                1  1103
    136740    VSTRA  U1CF_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1CF_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    136741 VSTRABRR  U1CF_H_R           1                1  1103
    136742 VSTRABRR  U1CF_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1PN_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    137019    VSTRA  U1PN_H_R           1                1  1103
    137020    VSTRA  U1PN_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1PN_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    137021 VSTRABRR  U1PN_H_R           1                1  1103
    137022 VSTRABRR  U1PN_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2PN_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    137141    VSTRA  U2PN_H_R           1                1  1103
    137142    VSTRA  U2PN_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2PN_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    137143 VSTRABRR  U2PN_H_R           1                1  1103
    137144 VSTRABRR  U2PN_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1FL_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    137316    VSTRA  U1FL_H_R           1                1  1103
    137317    VSTRA  U1FL_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U1FL_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    137318 VSTRABRR  U1FL_H_R           1                1  1103
    137319 VSTRABRR  U1FL_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2FL_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    137434    VSTRA  U2FL_H_R           1                1  1103
    137435    VSTRA  U2FL_H_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) U2FL_H_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    137436 VSTRABRR  U2FL_H_R           1                1  1103
    137437 VSTRABRR  U2FL_H_R           .          Missing     0
           Variable TableName CodeOrValue ValueDescription Count
    137843 OSD030bh     OSQ_H          20               20     1
    137844 OSD030bh     OSQ_H          80      80 or older     0
    137845 OSD030bh     OSQ_H       77777          Refused     0
    137846 OSD030bh     OSQ_H       99999       Don't know     0
    137847 OSD030bh     OSQ_H           .          Missing  3814
           Variable TableName CodeOrValue ValueDescription Count
    137848 OSD030bi     OSQ_H          23               23     1
    137849 OSD030bi     OSQ_H          80      80 or older     0
    137850 OSD030bi     OSQ_H       77777          Refused     0
    137851 OSD030bi     OSQ_H       99999       Don't know     0
    137852 OSD030bi     OSQ_H           .          Missing  3814
           Variable TableName CodeOrValue ValueDescription Count
    137853 OSD030bj     OSQ_H          30               30     1
    137854 OSD030bj     OSQ_H          80      80 or older     0
    137855 OSD030bj     OSQ_H       77777          Refused     0
    137856 OSD030bj     OSQ_H       99999       Don't know     0
    137857 OSD030bj     OSQ_H           .          Missing  3814
    ---------
    HUQ_H > HUQ051 (#times receive healthcare over past year)
           Variable TableName CodeOrValue ValueDescription Count
    139650   HUQ051     HUQ_H           0             None  1287
    139651   HUQ051     HUQ_H           1                1  2167
    139652   HUQ051     HUQ_H           2           2 to 3  3206
    139653   HUQ051     HUQ_H           3           4 to 5  1518
    139654   HUQ051     HUQ_H           4           6 to 7   705
    139655   HUQ051     HUQ_H           5           8 to 9   289
    139656   HUQ051     HUQ_H           6         10 to 12   460
    139657   HUQ051     HUQ_H           7         13 to 15   171
    139658   HUQ051     HUQ_H           8       16 or more   361
    139659   HUQ051     HUQ_H          77          Refused     0
    139660   HUQ051     HUQ_H          99       Don't know    11
    139661   HUQ051     HUQ_H           .          Missing     0
    ---------
    SMQFAM_H > SMD480 (In past week # days person smoked inside)
           Variable TableName CodeOrValue ValueDescription Count
    140627   SMD480  SMQFAM_H           0                0    98
    140628   SMD480  SMQFAM_H           1                1   179
    140629   SMD480  SMQFAM_H           2                2   230
    140630   SMD480  SMQFAM_H           3                3    49
    140631   SMD480  SMQFAM_H           4                4    35
    140632   SMD480  SMQFAM_H           5                5    27
    140633   SMD480  SMQFAM_H           6                6     7
    140634   SMD480  SMQFAM_H           7                7   679
    140635   SMD480  SMQFAM_H          77          Refused     0
    140636   SMD480  SMQFAM_H          99       Don't know     3
    140637   SMD480  SMQFAM_H           .          Missing  8868
    ---------
    OHQ_H > OHQ848Q (# times you brush your teeth in 1 day?)
           Variable TableName CodeOrValue ValueDescription Count
    143201  OHQ848Q     OHQ_H           1           1 time  1102
    143202  OHQ848Q     OHQ_H           0                0     2
    143203  OHQ848Q     OHQ_H           2          2 times  2046
    143204  OHQ848Q     OHQ_H           3          3 times   197
    143205  OHQ848Q     OHQ_H           4          4 times    17
    143206  OHQ848Q     OHQ_H           5          5 times     7
    143207  OHQ848Q     OHQ_H           6          6 times     1
    143208  OHQ848Q     OHQ_H           7          7 times     0
    143209  OHQ848Q     OHQ_H           8          8 times     0
    143210  OHQ848Q     OHQ_H           9  9 or more times     0
    143211  OHQ848Q     OHQ_H          77          Refused     0
    143212  OHQ848Q     OHQ_H          99       Don't know     0
    143213  OHQ848Q     OHQ_H           .          Missing  6398
    ---------
    KIQ_U_H > KIQ480 (How many times urinate in night?)
           Variable TableName CodeOrValue ValueDescription Count
    143741   KIQ480   KIQ_U_H           0                0  1544
    143742   KIQ480   KIQ_U_H           1                1  1941
    143743   KIQ480   KIQ_U_H           2                2   947
    143744   KIQ480   KIQ_U_H           3                3   431
    143745   KIQ480   KIQ_U_H           4                4   123
    143746   KIQ480   KIQ_U_H           5       5 or more?   106
    143747   KIQ480   KIQ_U_H           7          Refused     0
    143748   KIQ480   KIQ_U_H           9       Don't know     3
    143749   KIQ480   KIQ_U_H           .          Missing   674
    Error in .checkTableNames(nh_table) : 
      Table(s) SSHC_I_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    151479    VSTRA  SSHC_I_R           1                1  4133
    151480    VSTRA  SSHC_I_R           .          Missing     0
    Error in .checkTableNames(nh_table) : 
      Table(s) HEPC_I_R missing from database
           Variable TableName CodeOrValue ValueDescription Count
    151822    VSTRA  HEPC_I_R           1                1  3888
    151823    VSTRA  HEPC_I_R           .          Missing     0
    ---------
    INS_I > LBDINLC (Insulin Comment Code)
           Variable TableName CodeOrValue ValueDescription Count
    152074  LBDINLC     INS_I           0                0  2920
    152075  LBDINLC     INS_I           1                1     1
    152076  LBDINLC     INS_I           .          Missing   270
    ---------
    VOCWB_I > LBX4CE (Blood 1112-Tetrachloroethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    152764   LBX4CE   VOCWB_I       0.028            0.028  3082
    152765   LBX4CE   VOCWB_I           .          Missing   312
    ---------
    VOCWB_I > LBXVDE (Blood 12-Dibromoethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    152800   LBXVDE   VOCWB_I       0.011            0.011  2986
    152801   LBXVDE   VOCWB_I           .          Missing   408
    ---------
    VOCWBS_I > LBX4CE (Blood 1112-Tetrachloroethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    153012   LBX4CE  VOCWBS_I       0.028            0.028  3009
    153013   LBX4CE  VOCWBS_I           .          Missing   257
    ---------
    VOCWBS_I > LBXVDE (Blood 12-Dibromoethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    153048   LBXVDE  VOCWBS_I       0.011            0.011  2906
    153049   LBXVDE  VOCWBS_I           .          Missing   360
    ---------
    HUQ_I > HUQ051 (#times receive healthcare over past year)
           Variable TableName CodeOrValue ValueDescription Count
    156753   HUQ051     HUQ_I           0             None  1421
    156754   HUQ051     HUQ_I           1                1  2049
    156755   HUQ051     HUQ_I           2           2 to 3  3140
    156756   HUQ051     HUQ_I           3           4 to 5  1487
    156757   HUQ051     HUQ_I           4           6 to 7   699
    156758   HUQ051     HUQ_I           5           8 to 9   271
    156759   HUQ051     HUQ_I           6         10 to 12   437
    156760   HUQ051     HUQ_I           7         13 to 15   133
    156761   HUQ051     HUQ_I           8       16 or more   304
    156762   HUQ051     HUQ_I          77          Refused     2
    156763   HUQ051     HUQ_I          99       Don't know    28
    156764   HUQ051     HUQ_I           .          Missing     0
    ---------
    SMQRTU_I > SMQ861 (# days used dissolvable over last 5 days)
           Variable TableName CodeOrValue ValueDescription Count
    156979   SMQ861  SMQRTU_I           1                1     1
    156980   SMQ861  SMQRTU_I           7          Refused     0
    156981   SMQ861  SMQRTU_I           9       Don't know     0
    156982   SMQ861  SMQRTU_I           .          Missing  6743
    ---------
    SMQFAM_I > SMD480 (In past week # days person smoked inside)
           Variable TableName CodeOrValue ValueDescription Count
    157002   SMD480  SMQFAM_I           0                0    99
    157003   SMD480  SMQFAM_I           1                1   100
    157004   SMD480  SMQFAM_I           2                2   100
    157005   SMD480  SMQFAM_I           3                3    56
    157006   SMD480  SMQFAM_I           4                4    15
    157007   SMD480  SMQFAM_I           5                5    25
    157008   SMD480  SMQFAM_I           6                6    12
    157009   SMD480  SMQFAM_I           7                7   530
    157010   SMD480  SMQFAM_I          77          Refused     0
    157011   SMD480  SMQFAM_I          99       Don't know     7
    157012   SMD480  SMQFAM_I           .          Missing  9027
    ---------
    KIQ_U_I > KIQ480 (How many times urinate in night?)
           Variable TableName CodeOrValue ValueDescription Count
    159519   KIQ480   KIQ_U_I           0                0  1407
    159520   KIQ480   KIQ_U_I           1                1  1850
    159521   KIQ480   KIQ_U_I           2                2   928
    159522   KIQ480   KIQ_U_I           3                3   486
    159523   KIQ480   KIQ_U_I           4                4   165
    159524   KIQ480   KIQ_U_I           5        5 or more   108
    159525   KIQ480   KIQ_U_I           7          Refused     2
    159526   KIQ480   KIQ_U_I           9       Don't know     5
    159527   KIQ480   KIQ_U_I           .          Missing   768
    ---------
    LUX_J > LUANMTGP (Count:measures attempted with final wand)
           Variable TableName CodeOrValue ValueDescription Count
    165677 LUANMTGP     LUX_J           0         Not done   415
    165678 LUANMTGP     LUX_J           1                1     1
    165679 LUANMTGP     LUX_J           3                3     1
    165680 LUANMTGP     LUX_J           4                4     1
    165681 LUANMTGP     LUX_J           5                5     2
    165682 LUANMTGP     LUX_J           6                6     1
    165683 LUANMTGP     LUX_J           9                9     2
    165684 LUANMTGP     LUX_J          10               10  1442
    165685 LUANMTGP     LUX_J          11               11   778
    165686 LUANMTGP     LUX_J          12               12   551
    165687 LUANMTGP     LUX_J          13               13   495
    165688 LUANMTGP     LUX_J          14               14   378
    165689 LUANMTGP     LUX_J          15               15   347
    165690 LUANMTGP     LUX_J          16               16   249
    165691 LUANMTGP     LUX_J          17               17   189
    165692 LUANMTGP     LUX_J          18               18   178
    165693 LUANMTGP     LUX_J          19               19   149
    165694 LUANMTGP     LUX_J          20         20 to 29   682
    165695 LUANMTGP     LUX_J          30       30 or more   540
    165696 LUANMTGP     LUX_J           .          Missing     0
    ---------
    LUX_J > LUANMVGP (Count:complete measures from final wand)
           Variable TableName CodeOrValue ValueDescription Count
    165697 LUANMVGP     LUX_J           1                1    11
    165698 LUANMVGP     LUX_J           2                2    10
    165699 LUANMVGP     LUX_J           3                3    11
    165700 LUANMVGP     LUX_J           4                4    15
    165701 LUANMVGP     LUX_J           5                5     7
    165702 LUANMVGP     LUX_J           6                6     8
    165703 LUANMVGP     LUX_J           7                7     9
    165704 LUANMVGP     LUX_J           8                8     8
    165705 LUANMVGP     LUX_J           9                9    12
    165706 LUANMVGP     LUX_J          10               10  3170
    165707 LUANMVGP     LUX_J          11               11   823
    165708 LUANMVGP     LUX_J          12               12   547
    165709 LUANMVGP     LUX_J          13               13   374
    165710 LUANMVGP     LUX_J          14               14   274
    165711 LUANMVGP     LUX_J          15               15   219
    165712 LUANMVGP     LUX_J          16               16   134
    165713 LUANMVGP     LUX_J          17               17    92
    165714 LUANMVGP     LUX_J          18               18    74
    165715 LUANMVGP     LUX_J          19               19    34
    165716 LUANMVGP     LUX_J          20         20 to 29    98
    165717 LUANMVGP     LUX_J          30       30 or more    20
    165718 LUANMVGP     LUX_J           .          Missing   451
    ---------
    VOCWB_J > LBX4CE (Blood 1112-Tetrachloroethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    169349   LBX4CE   VOCWB_J       0.028            0.028  2866
    169350   LBX4CE   VOCWB_J           .          Missing   306
    ---------
    VOCWB_J > LBXVDE (Blood 12-Dibromoethane (ng/mL))
           Variable TableName CodeOrValue ValueDescription Count
    169385   LBXVDE   VOCWB_J       0.011            0.011  2866
    169386   LBXVDE   VOCWB_J           .          Missing   306
    ---------
    HUQ_J > HUQ051 (#times receive healthcare over past year)
           Variable TableName CodeOrValue ValueDescription Count
    170468   HUQ051     HUQ_J           0             None  1276
    170469   HUQ051     HUQ_J           1                1  1945
    170470   HUQ051     HUQ_J           2           2 to 3  2932
    170471   HUQ051     HUQ_J           3           4 to 5  1421
    170472   HUQ051     HUQ_J           4           6 to 7   587
    170473   HUQ051     HUQ_J           5           8 to 9   266
    170474   HUQ051     HUQ_J           6         10 to 12   396
    170475   HUQ051     HUQ_J           7         13 to 15   128
    170476   HUQ051     HUQ_J           8       16 or more   278
    170477   HUQ051     HUQ_J          77          Refused     0
    170478   HUQ051     HUQ_J          99       Don't know    25
    170479   HUQ051     HUQ_J           .          Missing     0
    ---------
    SMQFAM_J > SMD480 (In past week # days person smoked inside)
           Variable TableName CodeOrValue ValueDescription Count
    171466   SMD480  SMQFAM_J           0                0    81
    171467   SMD480  SMQFAM_J           1                1    80
    171468   SMD480  SMQFAM_J           2                2    96
    171469   SMD480  SMQFAM_J           3                3    43
    171470   SMD480  SMQFAM_J           4                4    16
    171471   SMD480  SMQFAM_J           5                5    30
    171472   SMD480  SMQFAM_J           6                6     7
    171473   SMD480  SMQFAM_J           7                7   615
    171474   SMD480  SMQFAM_J          77          Refused     2
    171475   SMD480  SMQFAM_J          99       Don't know     0
    171476   SMD480  SMQFAM_J           .          Missing  8284
    ---------
    KIQ_U_J > KIQ480 (How many times urinate in night?)
           Variable TableName CodeOrValue ValueDescription Count
    174614   KIQ480   KIQ_U_J           0                0  1288
    174615   KIQ480   KIQ_U_J           1                1  1869
    174616   KIQ480   KIQ_U_J           2                2   941
    174617   KIQ480   KIQ_U_J           3                3   480
    174618   KIQ480   KIQ_U_J           4                4   155
    174619   KIQ480   KIQ_U_J           5        5 or more   133
    174620   KIQ480   KIQ_U_J           7          Refused     1
    174621   KIQ480   KIQ_U_J           9       Don't know     9
    174622   KIQ480   KIQ_U_J           .          Missing   693

The list, while fascinating in variety, does include definite false
positives, such as:

- `CDQ > CDQ070 (Sleep on 2+ pillows to help breathe)`
- `HUQ > HUQ050 (#Times received healthcare over past yr)`
- `OHXPRU_B > OHX14BPM (BOP: midfacial #14)`

Some of these could be added to our list, but detecting them
automatically seems problematic.
