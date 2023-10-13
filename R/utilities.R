


drop_table_suffix <- function(x) 
{
  gsub("_[ABCDEFGHIJ]$", "", x)
}

get_table_names <- function(name, db)
{
  table_names <- db$TableName
  possible_matches <- c(name, sprintf("%s_%s", name, LETTERS[1:10]))
  possible_matches[possible_matches %in% table_names]
}

get_common_vars <- function(tables)
{
  varlist <- lapply(tables, function(x) names(nhanesCodebook(x)))
  Reduce(intersect, varlist)
}

merge_tables <- function(tables, vars = get_common_vars(tables))
{
  stopifnot(is.character(tables))
  tablist <- lapply(tables, nhanes, includelabels = FALSE, translated = TRUE)
  names(tablist) <- tables
  ok <- sapply(tablist, function(x) all(vars %in% names(x)))
  if (!all(ok)) stop("Not all 'vars' [", 
                     paste(vars, collapse = ", "),
                     "] present in the following tables: ", 
                     paste(tables[!ok], collapse = ", "))
  tablist <- lapply(tablist, "[", vars)
  do.call(rbind, tablist)
}

