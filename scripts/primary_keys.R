
## check whether reported primary key is unique for all tables

stopifnot(require(nhanesA))
stopifnot(isTRUE(nhanesOptions("use.db")))
stopifnot(require(phonto))

tables <- nhanesQuery("select TableName from metadata.QuestionnaireDescriptions")[[1]]

## tables <- nhanesSearchTableNames("PAQ")

for (x in tables)
{
    cat("\r", x, "         ")
    pk <- primary_keys(x, require_unique = FALSE)
    if (is.null(pk)) cat("unspecified\n")
    if (anyDuplicated(nhanes(x, translated = FALSE)[pk]))
        cat("not unique: (", paste(pk, collapse = ", "), ")\n")
}

