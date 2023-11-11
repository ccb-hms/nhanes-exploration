

## This assumes that "nhanesVarSummary.rda" has already been created
## and available in the working directory.

library(nhanesA)
library(lattice)

load("nhanesVarSummary.rda")

## Goal: make a data frame with one row per variable, giving a
## description of the variable, the tables where it appears, and the
## number of participants for which it has non-missing values (the
## last step requires looking up the variable in all tables, which can
## be slow).

nhanesVarSummary$label <- tolower(nhanesVarSummary$label)

## only keep tables with unique SEQN

ok_tables <- subset(nhanesVarSummary, varname == "SEQN" & unique)$table
nhanesVarSummary <- subset(nhanesVarSummary, table %in% ok_tables)



## borrowing code from ../variable-search-table.rmd

sort_by <- function(x, by = NULL, ...)
{
    if (!inherits(by, "formula")) stop("'by' must be a formula")
    f <- .formula2varlist(by, x)
    o <- do.call(order, c(unname(f), list(...)))
    x[o, , drop = FALSE]
}


summarizeTable <- function(d) { # tables where variable appears
    with(d, sprintf("%s", paste(sort(table), collapse = ", ")))
}
summarizeNobs <- function(d) { # aggregate non-missing (ignoring possible dups)
    with(d, sum(nobs_data - na_data))
}
summarizeType <- function(d) { # whether numeric or categorical
    with(d, if (all(num)) "numeric"
            else if (all(cat)) sprintf("categorical [%s]",
                                       paste(unique(nlevels), collapse = ", "))
            else "ambiguous")
}

aggTable <- unique(nhanesVarSummary[c("varname", "label")]) |>
    subset(varname != "SEQN") |> sort_by(~ varname + label)

aggTable$tables <- ""
aggTable$nobs <- NA_real_
aggTable$type <- NA_character_

for (i in seq_len(nrow(aggTable))) {
    if (interactive() && i %% 100 == 0) cat("\r", i, " / ", nrow(aggTable), "      ")
    dsub <- subset(nhanesVarSummary,
                   varname == aggTable$varname[[i]] &
                   label == aggTable$label[[i]])
    aggTable$tables[[i]] <- summarizeTable(dsub)
    aggTable$nobs[[i]] <- summarizeNobs(dsub)
    aggTable$type[[i]] <- summarizeType(dsub)
}



## save those with count > 20000 (to make size manageable)

library(DT)

dt <- datatable(subset(aggTable, nobs > 20000),
                rownames = FALSE,
                colnames = c("Variable", "Description", "Source", "Non-missing", "Type"),
                escape = FALSE, editable = FALSE,
                options = list(columnDefs = list(
                                   list("searchable" = FALSE,
                                        "targets" = c(2, 3))
                               )))

saveWidget(dt, file = "nhanes-variable-summary.html", selfcontained = TRUE)



