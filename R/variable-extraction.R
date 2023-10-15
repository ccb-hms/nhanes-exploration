
## For a variable-centric workflow, we need 
## (a) a function to get data for a particular variable in all available tables
## (b) a function to combine or merge multiple such variable-specific datasets 

## handling multiple occurrences of a participant for the same variable, or 
## matching pooled samples to participants, etc., are potentially complicated.
## To keep this function simple, it will collect all occurrences of a variable,
## and report (id=SEQN|SAMPLEID, value, source table name)

## The following tables are 'long-format' tables with the SEQN variable being 
## repeated, and additional key variables needed to identify what is being 
## recorded. These need special handling (and are also slow to load),  so we 
## will skip them when trying to load a specific variable.

## The list can be generated using

if (FALSE)
{
  all_tables_in_metadata <- 
    nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")$TableName
  id_repeated <- 
    sapply(sort(all_tables_in_metadata),
           function(tab) {
             cat("\r", tab, ".......")
             d <- nhanes(tab)
             !is.null(d[["SEQN"]]) && !(anyDuplicated(d[["SEQN"]]) == 0)
           })
  tables_with_repeated_id <- names(id_repeated)[id_repeated]
}

tables_with_repeated_id <- 
  c("AUXAR_I", "AUXAR_J", "AUXTYM_I", "AUXTYM_J", "AUXWBR_I", "AUXWBR_J", 
    "DR1IFF_C", "DR1IFF_D", "DR1IFF_E", "DR1IFF_F", "DR1IFF_G", "DR1IFF_H", 
    "DR1IFF_I", "DR1IFF_J", "DR2IFF_C", "DR2IFF_D", "DR2IFF_E", "DR2IFF_F", 
    "DR2IFF_G", "DR2IFF_H", "DR2IFF_I", "DR2IFF_J", "DRXIFF", "DRXIFF_B", 
    "DS1IDS_E", "DS1IDS_F", "DS1IDS_G", "DS1IDS_H", "DS1IDS_I", "DS1IDS_J", 
    "DS2IDS_E", "DS2IDS_F", "DS2IDS_G", "DS2IDS_H", "DS2IDS_I", "DS2IDS_J", 
    "DSQ2_B", "DSQ2_C", "DSQ2_D", "DSQFILE2", "DSQIDS_E", "DSQIDS_F", 
    "DSQIDS_G", "DSQIDS_H", "DSQIDS_I", "DSQIDS_J", "FFQDC_C", "FFQDC_D", 
    "PAQIAF", "PAQIAF_B", "PAQIAF_C", "PAQIAF_D", "PAXDAY_G", "PAXDAY_H", 
    "PAXHR_G", "PAXHR_H", "RXQ_ANA", "RXQ_RX", "RXQ_RX_B", "RXQ_RX_C", 
    "RXQ_RX_D", "RXQ_RX_E", "RXQ_RX_F", "RXQ_RX_G", "RXQ_RX_H", "RXQ_RX_I", 
    "RXQ_RX_J", "RXQANA_B", "RXQANA_C", "SSHPV_F")


get_variable_data <- function(x, db = NULL, 
                              idvar = c("SEQN", "SAMPLEID", "POOLID"),
                              verbose = TRUE)
{
  idvar <- match.arg(idvar)
  if (is.null(db)) db <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireVariables")
  db <- subset(db, !startsWith(TableName, "P_"))
  db <- subset(db, !(TableName %in% tables_with_repeated_id))
  dbsub <- subset(db, Variable == x)
  if (nrow(dbsub) == 0) return(NULL)
  ## get corresponding tables, making sure table names are not repeated
  if (any(duplicated(dbsub$TableName))) stop("TableName duplicated in for variable ", x)
  ## check whether 'idvar' is present in each of these tables; otherwise error
  ## which of these tables have 'idvar'
  ok_tables <- subset(db, Variable == idvar & TableName %in% dbsub$TableName)$TableName
  if (length(setdiff(dbsub$TableName, ok_tables)))
    stop("The ", idvar, " variable is missing from the following tables: ", 
         paste(setdiff(dbsub$TableName, ok_tables), collapse = ", "))
  ans_list <- 
    sapply(dbsub$TableName, 
         function(tabname) {
           if (verbose) {
             cat("\r", tabname, ".....")
             flush.console()
           }
           nhanes(tabname)[c(idvar, x)]
         }, 
         simplify = FALSE)
  cat("\r                                   \r")
  cbind(do.call(rbind, ans_list),
        TABLE = rep(names(ans_list), sapply(ans_list, nrow)))
}

## Examples

if (FALSE)
{
  db <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireVariables")
  foo <- get_variable_data("LBC028", db, idvar = "SAMPLEID")
  foo <- get_variable_data("DR2ICHOL", db) # empty - only in long-format dietary tables
  foo <- get_variable_data("LBDLDL", db)
} 
  
## Useful summary: For each variable, how many unique participants have 
## non-missing values?

if (FALSE)
{
  ## these are mostly large tables with pooled data; not useful for this exercise
  pooled_tables <- 
    c("BFRPOL_E", "BFRPOL_F", "BFRPOL_G", "BFRPOL_H", "DRXFCD_C", "DRXFCD_D", "DRXFCD_F", 
      "DRXFCD_G", "DRXFCD_H", "DRXMCD_C", "DRXMCD_D", "DRXMCD_E", "DRXMCD_F", 
      "PCBPOL_D", "PCBPOL_E", "PCBPOL_G", "PCBPOL_I", "SSPCB_B", "SSPST_B", 
      "PSTPOL_E", "PSTPOL_F", "PSTPOL_I", "PSTPOL_H", "DOXPOL_E", "POOLTF_G", 
      "POOLTF_H", "POOLTF_I", "BFRPOL_D", "BFRPOL_I", "SSBFR_B", "DRXFCD_E", 
      "DRXMCD_G", "PCBPOL_F", "PCBPOL_H", "PSTPOL_D", "PSTPOL_G", "DOXPOL_D", 
      "DOXPOL_F", "DOXPOL_G", "POOLTF_F")
  db <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireVariables")
  db <- subset(db, !startsWith(TableName, "P_"))
  db <- subset(db, !(TableName %in% tables_with_repeated_id))
  db <- subset(db, !(TableName %in% pooled_tables))
  varSummary <- unique(db[c("Variable", "SasLabel")]) |>
    subset(!(Variable %in% c("SEQN", "SAMPLEID", "POOLID")))
  numObs <- 
    sapply(sort(unique(varSummary$Variable)),
           function(var) {
             dvar <- try(get_variable_data(var, db, verbose = FALSE), silent = TRUE)
             if (inherits(dvar, "try-error")) NA_integer_
             else {
               okrows <- !is.na(dvar[[var]]) # don't count missing data
               ## count unique SEQN, regardless of whether duplicates are 
               ## consistent (but that's something we could check easily 
               ## by counting unique combinations - which should ideally be 
               ## same as number of unique SEQN)
               ans <- length(unique(dvar[okrows, "SEQN"]))
               cat("\r", var, " : ", ans, "        ")
               ans
             }
           })
  saveRDS(numObs, file = "nobs-nonmissing-per-variable.rds")
  varSummary$NumObs <- numObs[varSummary$Variable]
  save(varSummary, file = "varSummary.rda")
  saveWidget(DT::datatable(varSummary),
             file = "variable-summary.html",
             selfcontained = TRUE)
}


