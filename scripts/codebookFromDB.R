
## Construct codebook from information in database

.dbqTableVars <- paste0(
    "SELECT ",
    "Variable AS 'Variable Name:', ",
    "SasLabel AS 'SAS Label:', ",
    "Description AS 'English Text:', ",
    "Target AS 'Target:' ",
    "FROM Metadata.QuestionnaireVariables ",
    "WHERE TableName = '%s'"
)

.dbqTableCodebook <- paste0(
    "SELECT ",
    "Variable, ",
    "CodeOrValue AS 'Code.or.Value', ",
    "ValueDescription AS 'Value.Description', ",
    "Count, ",
    "Cumulative, ",
    "SkipToItem AS 'Skip.to.Item' ",
    "FROM Metadata.VariableCodebook ",
    "WHERE TableName = '%s'"
)

.dbqTableVars1 <- paste0(.dbqTableVars, " AND Variable = '%s'")
.dbqTableCodebook1 <- paste0(.dbqTableCodebook, " AND Variable = '%s'")

.nhanesQuery <- nhanesA:::.nhanesQuery

.codebookFromDB <- function(table)
{
    tvars <- .nhanesQuery(sprintf(.dbqTableVars, table))
    tcb <- .nhanesQuery(sprintf(.dbqTableCodebook, table))
    tcb_list <- split(tcb[-1], tcb$Variable)
    cb <- split(tvars, ~ `Variable Name:`) |> lapply(as.list)
    vnames <- names(cb)
    for (i in seq_along(cb)) {
        iname <- vnames[[i]]
        cb[[i]][[iname]] <- tcb_list[[iname]]
    }
    cb
}

.codebookFromDB1 <- function(table, column)
{
    ## .codebookFromDB(table)[column] # is probably good enough, but for less DB traffic:
    tvars <- .nhanesQuery(sprintf(.dbqTableVars1, table, column))
    tcb <- .nhanesQuery(sprintf(.dbqTableCodebook1, table, column))
    if (nrow(tcb)) { ## usually yes, except SEQN
        cb <- list(c(as.list(tvars),
                     list(tcb[-1])))
        names(cb) <- column
        names(cb[[1]])[[5]] <- column
        cb
    }
    else {
        structure(list(as.list(tvars)), names = column)
    }
}

## Eventually make this part of nhanesCodebook(), replacing the current .nhanesCodebookDB()

nhCodebook <- function(nh_table, colname = NULL)
{
    if (is.null(colname)) .codebookFromDB(nh_table)
    else .codebookFromDB1(nh_table, column)
}


