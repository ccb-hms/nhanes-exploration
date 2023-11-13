

## Leaving aside a few special tables (pooled data, food details),
## NHANES data are generally structured as follows: each table has a
## SEQN variable which (uniquely) identifies a participant, along with
## other variables which measure some specific attribute of the
## participant. The variables in a table are usually related; for
## example, tables with name 'DEMO' have demographic details such as
## age, gender, and ethnicity.

## Variable names are cryptic, and to know what they represent, one
## must look up a table-specific codebook. There are at least 1500
## public tables, as reported by 

## dim(tabmf <- nhanesManifest("public"))

## with more than 12000 unique variable names, as found using

## dim(varmf <- nhanesManifest("variables"))

## It would be useful to get useful information about variables in
## advance Specifically:

## - What they measure (best bet: SAS label, but need not be consistent)
##
## - Whether they are numeric / categorical
##
## - How many non-missing (the actual number may not be same as what
## - is reported nominally in the codebook, because many 'special'
## - kinds of missingness are coded separately.

## Some oddities to consider: the same variable is sometimes recorded
##
## - in different tables in different cycles
## - in multiple tables within the same cycle
## - they may or may not measure the same thing (at least in one case, units are different)

## Details of these issues may be explored elsewhere. For now, we want
## to write some code to achieve the following naively, by cycling
## through all tables that have unique SEQN values (to avoid special
## tables):

## (1) Collect a per (table, variable) summary of variable codebooks,
## We could do this by simply cycling through all available tables,
## either looking at just the codebook, or the actual data. Let's do
## this first.

getTableInfo <- function(nh_table)
{
    nhanesTableSummary(nh_table, use = "both")
}

## We now want to cycle through all tables and collect this
## information. There is no well-defined "master list" of tables, but
## as this exercise is fairly pointless without a local database, we
## will just use the list of tables available there.

dbTableDesc <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")

all_table_info <- vector(mode = "list", length = nrow(dbTableDesc))
names(all_table_info) <- dbTableDesc$TableName

system.time(
    for (v in sort(dbTableDesc$TableName)) {
        if (is.null(all_table_info[[v]])) {
            cat("\r", v)
            all_table_info[[v]] <-
                try(getTableInfo(v), silent = TRUE)
        }
    }
)


## Timing on first run (with local db) ~ 12 mins
##    user  system elapsed 
## 254.357  35.697 725.928 

notok <- which(sapply(all_table_info, inherits, "try-error")) # 49

if (FALSE)
{
    ## to try again after making changes to fix 'errors' 
    all_table_info[notok] <- list(NULL)
    ## and re-run for loop above
}

## Errors:

sapply(all_table_info[notok], as.character)

## These are mainly from pooled sample tables without a SEQN, which trips up nhanes(), e.g.,
##
## nhanes("PSTPOL_H")

## Some other checks also originally gave errors. Trying to identify
## the sources of these errors led to identifying several oddities in
## NHANES tables, some of which are legitimate errors, mainly:

## https://wwwn.cdc.gov/nchs/nhanes/2003-2004/OHXDEN_C.htm#OHXIMP

## Other examples (which now produce a warning) are:

## No 'Missing' category
## https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/CSX_H.htm#CSXTSEQ
## https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/FFQRAW_D.htm#FFQ0014

## Duplicate rows in codebook table 
## https://wwwn.cdc.gov/Nchs/Nhanes/2003-2004/KIQ_U_C.htm
## https://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/DXX_H.htm
## https://wwwn.cdc.gov/nchs/nhanes/2003-2004/L06MH_C.htm


## save for future use
saveRDS(all_table_info, file = "all_table_info.rds")


## Next: make a table summarizing all table-variable combinations. But
## before that, some useful summaries.

ok <- !(sapply(all_table_info, inherits, "try-error"))

## TODO Skip pandemic tables because they duplicate individuals [?] -
## none currently in DB anyway:

names(all_table_info) |> startsWith("P_") |> table()

nhanesVarSummary <- do.call(rbind, all_table_info[ok])
rownames(nhanesVarSummary) <- NULL

dim(nhanesVarSummary) # 45219 x 14

save(nhanesVarSummary, file = "nhanesVarSummary.rda")
file.size("nhanesVarSummary.rda") / (1024) # in KB


## DESCRIPTION of COLUMNS

## - table       Table Name
## - varname     Variable Name
## - label       SAS Label
## - nobs_cb     Number of obs according to codebook
## - na_cb       Number of missing values according to codebook
## - has_range   Whether "Range of Values" is a possible value (indicates numeric measurement)
## - nlevels     Number of possible categories according to codebook (incl. "Range of Values", if present)
## - skip        Whether any of the possible responses can lead to skipping subsequent questions
## - nobs_data   Number of obs according to actual data
## - na_data     Number of missing values in data
## - size        Size of the column as reported by object.size()
## - num         Whether stored as a numeric variable
## - cat         Whether stored as a factor / character variable
## - unique      Whether values are unique (usually FALSE except for SEQN)



## Number of unique participants

## Let's use the DEMO tables

subset(nhanesVarSummary, varname == "SEQN" & startsWith(table, "DEMO"),
       select = -c(label, nobs_cb, na_cb, has_range, nlevels))

## total - ~100k
subset(nhanesVarSummary, varname == "SEQN" & startsWith(table, "DEMO"),
       select = -c(label, nobs_cb, na_cb, has_range, nlevels))$nobs_data |> sum()


## Number of unique variables

length(unique(nhanesVarSummary$varname)) # 12022

## Number of unique (varname, label) combinations

nrow(unique(nhanesVarSummary[c("varname", "label")])) # 13333


## Which tables have non-unique SEQN? (suggesting longitudinal measurements)

long_tables <- subset(nhanesVarSummary, varname == "SEQN" & !unique)$table

## descriptions
subset(dbTableDesc, TableName %in% long_tables) |>
    with(structure(Description, names = TableName))

## These are interesting as data analysis problems, but will often
## have lots of variables representing functional data, so we might
## want to skip them in a searchable table (or do one separately for
## them)

nhanesVarSummaryUniq <-
    subset(nhanesVarSummary, !(table %in% long_tables))

dim(nhanesVarSummaryUniq) # ~40k
dim(unique(nhanesVarSummaryUniq[c("varname", "label")])) # ~11.6k
dim(unique(nhanesVarSummaryUniq["varname"])) # ~10.3k






## (2) Another potentially useful object is a (sparse?) matrix of
## {participants} x {variables} with
##
## - entries 0 / 1 / 2 / 3, where
## -    0=absent / 1=present but missing /
## -    2=non-missing but 'special value' (this is tricky so can be done gradually)
## -    3=OK
## -
## - 0 / 1 / {2,3} should be simple from raw data, converting some
## - tentative 3 to 2 needs more work.

## It is not clear if this is really worth constructing: It will be roughly 100k x 10k

## There are possibly better ways to proceed. Per-variable summaries
## that could be particularly useful are

## - number of unique participants that have non-missing values across
## - cycles (note that a variable can be recorded in multiple tables
## - within the same cycle, in which case they should be checked for
## - consistency)

## Can't think of anything else at the moment




