
if (interactive()) source("R/utilities.R")

## We want to make two tables, linked to NHANES website and possibly to each 
## other (eventually):

## 1. All data tables in the database: with 
## - TableBaseName, 
## - Description (which may be duplicated, in which separate entry for each combination), 
## - list of cycle-wise subtables indicating number of distinct participants / samples (for pooled)


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
    |> subset(Freq > 0, select = -Freq)
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
  rownames(tableSummary) <- as.character(seq_len(nrow(tableSummary)))
  tableSummary
}




## 2. All variables in the database: with 
## - Variable, 
## - Description (which may be duplicated, in which separate entry for each combination), 
## - Number of non-missing obs
## - list of all tables where the Variable appears (with links).



summarizeVariables <- function(varSummary, vardb = variableDesc, tabledb = tableDesc)
{
  subtableLinks <- function(i) {
    ## all tables where varSummary$Variable[i] appears
    match_tabs <- 
      subset(vardb, 
             Variable == varSummary$Variable[i] & 
               SasLabel == varSummary$SasLabel[i])$TableName
    dmatch <- tabledb[match(match_tabs, tabledb$TableName), 
                      c("TableName", "Description", "DataGroup")]
    dmatch$URL <- sapply(dmatch$TableName, nhanes_url) # instead of from DB
    dsplit <- split(dmatch, ~ interaction(Description, DataGroup))
    tab_links <- 
      lapply(dsplit,
             function(d)
             {
               d <- na.omit(d)
               if (nrow(d) == 0) NULL
               else 
                 with(d, 
                      {
                        links <- 
                          sprintf("<a href='%s#%s' target='_nhanes'>%s</a>", 
                                  URL, varSummary$Variable[i], TableName)
                        paste0(sprintf("<span style='color: #888;'>[%s]</span> %s: ", 
                                       DataGroup[1], Description[1]),
                               paste(links, collapse = ", "))
                      })
             })
    tab_links <- tab_links[sapply(tab_links, length) > 0]
    paste(unlist(tab_links), collapse = "<br>")
  }
  varSummary[["Tables"]] <- sapply(seq_len(nrow(varSummary)),
                                   subtableLinks)
  rownames(varSummary) <- as.character(seq_len(nrow(varSummary)))
  varSummary
}



variableDesc <- ( # for more details that we want to merge
  nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireVariables")
  |> subset(!startsWith(TableName, "P_"))
)

if (file.exists("tableDesc.rda")) load("tableDesc.rda") else {
  tableDesc <- nhanesA:::.nhanesQuery("select * from Metadata.QuestionnaireDescriptions")
  tableDesc <- within(tableDesc, { # FIXME: takes a while, so save
    TableBase <- drop_table_suffix(TableName)
    ShortDesc <- sapply(TableName, shortDesc)
  })
  save(tableDesc, file = "tableDesc.rda")
}


## loads pre-computed 'varSummary' - expensive to compute number of NA-s. 
## (see variable-extraction.R)

load("varSummary.rda") # only containts (Variable, SasLabel, NumObs)
varSummary <- subset(varSummary, !is.na(SasLabel))

tab_summary <- summarizeTables(tableDesc)

var_summary <- summarizeVariables(varSummary)

  
library(toHTML)

show_html(tab_summary, file = "questionnares-table.html")

show_html(var_summary, file = "variables-table.html",
          dtopts = "{ paging: true, pageLength: 15, lengthChange: false, 
          columns: [ {searchable:false},null,null,{searchable:false},{searchable:false} ]
          }")





