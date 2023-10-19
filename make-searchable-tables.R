
## We want to make two tables, linked to NHANES website and possibly to each 
## other (eventually):

## 1. All data tables in the database: with 
## - TableBaseName, 
## - Description (which may be duplicated, in which separate entry for each combination), 
## - list of cycle-wise subtables indicating number of distinct participants / samples (for pooled)
## 

if (FALSE) { # slow - does not use DB
shortDesc <- function(nh_table) {
  cat("\r", nh_table, "   ")
  with(nhanesAttr(nh_table), 
       sprintf("[%d x %d] (%g %% NA)", nrow, ncol, round(100*(na / (nrow*ncol)), 1)))
}
}

shortDesc <- function(nh_table) {
  cat("\r", nh_table, "   ")
  cb <- nhanesCodebook(nh_table)
  nvars <- length(cb) - 1 # exclude 1st variable, which is usually ID
  ## ncases should be same regardless of which variable we pick, but not checking here.
  ## Maybe something a reimplementation of nhanesAttr() should check
  ncases <- try(tail(cb[[2]][[length(cb[[2]])]]$Cumulative, 1), silent = TRUE)
  if (inherits(ncases, "try-error")) ncases <- NA_integer_
  nmissing <- function(comp) {
    ## info not always available, so try
    e <- try({
      varInfoTable <- comp[[length(comp)]]
      n <- subset(varInfoTable, Value.Description == "Missing")$Count
      if (length(n) != 1L) stop("Missing values in ", nh_table, ": ", nmissing)
      n
    }, silent = TRUE)
    if (inherits(e, "try-error")) NA_integer_ else e
  }
  nmissing_by_var <- sapply(cb[-1], nmissing)
  sprintf("[%d x %d] (%g %% NA)", ncases, nvars, 
          round(100 * (sum(nmissing_by_var, na.rm = TRUE) / 
                         (ncases * sum(!is.na(nmissing_by_var)))), 1))
}


summarizeTables <- function(tableDesc)
{
  tableSummary <- (
    xtabs(~ TableBase + Description + DataGroup, tableDesc) 
    |> as.data.frame.table() 
    |> subset(Freq > 0)
  )
  subtableLinks <- function(i) {
    ## all tables matching i-th row of tableSummary
    dmatch <- 
      subset(tableDesc, 
             TableBase == tableSummary$TableBase[i] & 
               Description == tableSummary$Description[i])
    tab_links <- 
      with(dmatch, 
           {
             links <- sprintf("<a href='%s' target='_nhanes'>%s</a> %s", 
                              DocFile, TableName, ShortDesc)
             ## some have DocFile == ""
             bad_doc <- trimws(dmatch$DocFile) == ""
             links[bad_doc] <-
               sprintf("<span style='color: red;'>%s</span> %s", 
                       TableName[bad_doc], ShortDesc[bad_doc])
             paste(links, collapse = ", ")
           })
  }
  tableSummary[["Tables"]] <- sapply(seq_len(nrow(tableSummary)),
                                     subtableLinks)
  rownames(tableSummary) <- NULL
  tableSummary
}


summarizeVariables <- function()
{
  
  
}

tableDesc <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")
tableDesc <- within(tableDesc, { # FIXME: takes a while, so save
  TableBase <- drop_table_suffix(TableName)
  ShortDesc <- sapply(TableName, shortDesc)
})

tab_summary <- summarizeTables(tableDesc)

library(toHTML)

show_html(tab_summary)





