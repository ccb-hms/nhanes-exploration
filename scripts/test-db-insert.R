
## Try inserting tables into the database, and time

stopifnot(require(nhanesA))
stopifnot(isTRUE(nhanesOptions("use.db")))
stopifnot(require(phonto))

source("codebookFromDB.R")

con <- nhanesA:::cn()

library(DBI)
library(odbc)

if (FALSE)
{
    ## sanity check

    dbCreateTable(con, "iris", iris)
    dbAppendTable(con, "iris", iris)
    ## dbReadTable(con, "iris")
    dbGetQuery(con, "select * from iris")

}

if (file.exists("dups.rda"))
    load("dups.rda") else source("test-seqn-uniqueness.R", echo = TRUE)

insert_table <- function(x, verbose = getOption("verbose"))
{
    if (verbose) cat("\r", x)
    t1 <- system.time(
        d1 <- nhanesA:::raw2translated(nhanes(x, translated = FALSE),
                                       nhCodebook(x),
                                       cleanse_numeric = FALSE)
    )
    dbCreateTable(con, x, d1)
    dbAppendTable(con, x, d1)
    t1[["elapsed"]]
}

str(seqn_tables) # 1448

proc.time()
res <- sapply(sort(seqn_tables), insert_table, verbose = TRUE)
save(res, file = "db-insertion-time.rda")
proc.time()

## test whether it worked

if (FALSE)
{

    str(phonto::nhanesQuery("select * from Raw.DEMO_C")) |> str()
    str(phonto::nhanesQuery("select * from DEMO_C")) |> str()
    str(phonto::nhanesQuery("select * from Translated.DEMO_C")) |> str()

}


