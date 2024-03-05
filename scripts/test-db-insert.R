
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
    ## sanity check and testing

    dbCreateTable(con, "iris", iris)
    dbAppendTable(con, "iris", iris)
    ## dbReadTable(con, "iris")
    dbGetQuery(con, "select * from iris")
    dbRemoveTable(con, "iris")

    iris$ID <- 1:150
    iris <- iris[c(6, 1:5)]

    dt = dbDataType(con, iris)
    dt[["ID"]] = paste0(dt[["ID"]], " NOT NULL") # does this work?
    dbCreateTable(con, "iris", fields = dt)

    dbCreateTable(con, "iris", iris)

}

if (file.exists("dups.rda"))
    load("dups.rda") else source("test-seqn-uniqueness.R", echo = TRUE)


addPrimaryKey <- function(con, x, columns)
{
    qcol <- DBI::dbQuoteIdentifier(con, columns)
    sql <- sprintf("ALTER TABLE %s ADD PRIMARY KEY (%s);",
                   x,
                   paste0(qcol, collapse = ", "))
    query <- DBI::SQL(sql)
    dbExecute(con, query)
}

insert_table <- function(x, verbose = interactive(), pkey = "SEQN")
{
    if (verbose) cat("\r", x)
    t1 <- system.time({
        qx <- DBI::dbQuoteIdentifier(con, x)
        d1 <- nhanesA:::raw2translated(nhanes(x, translated = FALSE),
                                       nhCodebook(x),
                                       cleanse_numeric = FALSE)
        stopifnot(all(pkey %in% names(d1)))
        dt <- dbDataType(con, d1)
        ## for a non-composite pkey, can just add PRIMARY KEY in next step
        dt[pkey] <- paste0(dt[pkey], " NOT NULL")
        dbCreateTable(con, x, dt)
        addPrimaryKey(con, qx, columns = pkey)
        dbAppendTable(con, x, d1)
    })
    t1[["elapsed"]]
}

useqn_tables <- setdiff(seqn_tables, dup_tables)

str(seqn_tables) # 1448
str(useqn_tables) # 1369

tstart <- proc.time()
res <- sapply(sort(useqn_tables), insert_table, verbose = TRUE)
save(res, file = "db-insertion-time.rda")
tend <- proc.time()

cat("Time taken (insert): ")
print(tend - tstart)


## test whether it worked

if (FALSE)
{

    str(phonto::nhanesQuery("select * from Raw.DEMO_C")) |> str()
    str(phonto::nhanesQuery("select * from DEMO_C")) |> str()
    str(phonto::nhanesQuery("select * from Translated.DEMO_C")) |> str()

}


