# nhanes-exploration

Exploring NHANES data through the nhanesA package.

The `nhanesA` package can be used via Docker; see instructions at

<https://github.com/ccb-hms/NHANES>

It can be also used locally _with_ the DB by setting suitable environment variables, e.g., 

```
export EPICONDUCTOR_CONTAINER_VERSION=v0.1.0
export EPICONDUCTOR_COLLECTION_DATE=2023-10-02
export EPICONDUCTOR_DB_DRIVER=FreeTDS # default is MS SQL Driver
export EPICONDUCTOR_DB_SERVER=localhost
export EPICONDUCTOR_DB_PORT=1433
```

It can also use the Bioconductor package `BiocFileCache` to cache
downloaded files locally (set `nhanesOptions(use.cache = TRUE)`). 



# R code for specific tasks

- `R/variable-metadata.R` : extract and save per-(table,variable)
  metadata using `nhanesTableSummary()`. Comments here document what
  that function returns, which should eventually be incorporated in
  the man page.

- `R/variable-summary-table.R` : create a per-variable summary that
  can be used to search variables (using their SAS labels)
  
- `R/participant-summary.R` : combine the demographic datasets to
  create a basic per-participant summary.


# TODO

- There are many capitalization inconsistencies, e.g. "Don't know" and
  "Don't Know". Could we 'fix' this in the database codebooks somehow
  (before translation)?

```
> mdb <- nhanesA:::.nhanesQuery("SELECT * FROM Metadata.VariableCodebook")
> length(unique(mdb$ValueDescription))
[1] 3731
> length(unique(tolower(mdb$ValueDescription)))
[1] 3546
```
  

- Make searchable HTML table available somewhere. May be worth
  exploring if we can load JSON files separately. 
  
- It may be useful to segregate by 'component' or other kinds of
  grouping just to make tables of manageable size.
  
- Using GitHub pages is one option --- see
  <https://deepayan.github.io/nhanes/> for a sample.

- In general, we may consider if the `ccb-hms/NHANES` repo would be a
  good place to host a browseable website that shows examples of
  analyses that we can do.

- As part of an analysis, once we decide on a list of variables to
  look at, there should be a function that combines them. This is
  already done to some extent in the `jointQuery()` function in the
  `phonto` package. This can
  
    - combine tables within same cycle, specifying variables:
  
```r
df = jointQuery( list(BPQ_J=c("BPQ020", "BPQ050A"), DEMO_J=c("RIDAGEYR","RIAGENDR")))
```

    - combine tables across cycles:
	
```r
df <- jointQuery(
    list(BPQ_C  = c("BPQ020", "BPQ050A"),   BPQ_J  = c("BPQ020", "BPQ050A"),
         DEMO_C = c("RIDAGEYR","RIAGENDR"), DEMO_J = c("RIDAGEYR","RIAGENDR"))
)
```

- The other variant I can think of is to specify just the list of
  variables, for the code to automatically find them from suitable
  tables. 
  
- Optionally some `SEQN` values could be specified as well. These are
  sequential over cycles, so could be in principle used to find which
  table each data point comes from.

```r
load("participantSummary.rda")
tapply(participantSummary, ~ table, with, range(SEQN), simplify = FALSE) |>
    array2DF(allowLong = FALSE)
```

```
    table Value1 Value2
1    DEMO      1   9965
2  DEMO_B   9966  21004
3  DEMO_C  21005  31126
4  DEMO_D  31127  41474
5  DEMO_E  41475  51623
6  DEMO_F  51624  62160
7  DEMO_G  62161  71916
8  DEMO_H  73557  83731
9  DEMO_I  83732  93702
10 DEMO_J  93703 102956
```

- To start with, it should be easy to write a function that takes a
  list of variables, and using the variable manifest to create a list
  that is suitable as input for `jointQuery()`. This should check if a
  variable appears in multiple tables in the _same_ cycle --- and do
  _something_ useful.
  
- To help decide what to do when a variable appears in multiple
  tables, we should write a helper function that finds all occurrences
  of a variable across tables, and looks for duplicate `SEQN`
  values. In case there are duplicate `SEQN` values, it should first
  check that the values are consistent for each such `SEQN`. If not,
  it should summarize _how_ they differ. Details will depend on what
  kinds of differences we actually observe.
  
- Once these are done, we should be ready to do actual analysis; e.g.,
  follow up on the asthma subtypes, ENWAS (details?)
  
  

  
  


  



