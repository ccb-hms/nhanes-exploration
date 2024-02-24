
## 1. Translate all tables in R and compare timings with direct DB access.
## 2. Check whether result matches DB

stopifnot(require(nhanesA))
stopifnot(isTRUE(nhanesOptions("use.db")))
stopifnot(require(phonto))

if (file.exists("dups.rda"))
    load("dups.rda") else source("test-seqn-uniqueness.R", echo = TRUE)


compare_tables <- function(d1, d2)
{
    if (ncol(d1) != ncol(d2)) return("column number mismatch")
    if (nrow(d1) != nrow(d2)) return("row number mismatch")
    d1 <- d1[order(d1$SEQN), ]
    nm <- names(d1)
    d2 <- d2[order(d2$SEQN), nm]
    for (i in nm)
    {
        if (!isTRUE(all.equal(d1[[i]], d2[[i]])))
            return(sprintf("Mismatch in %s", i))
    }
    return ("OK")
}




check_table <- function(x, verbose = getOption("verbose"))
{
    if (verbose) cat("\r", x)
    t1 <- system.time(
        d1 <- nhanesA:::raw2translated(nhanes(x, translated = FALSE),
                                       nhanesCodebook(x),
                                       cleanse_numeric = FALSE)
    )
    t2 <- system.time(
        d2 <- nhanes(x, translated = TRUE)
    )
    data.frame(table = x,
               t1 = t1[["elapsed"]], t2 = t2[["elapsed"]],
               status = compare_tables(d1, d2))
}

reslist <- lapply(sort(seqn_tables), check_table, verbose = TRUE)

resdf <- do.call(rbind, reslist)
resdf$DUP_SEQN <- resdf$table %in% dup_tables

subset(resdf, DUP_SEQN)

subset(resdf, !DUP_SEQN & status != "OK")

plot(t2 ~ t1, resdf, col = DUP_SEQN + 1, log = "xy"); abline(0, 1)

## Summary: most tables with duplicate SEQN have mismatches. A few
## others also have mismatches. Let's try to figure them out first.

nodup_mismatch_tables <- subset(resdf, !DUP_SEQN & status != "OK")$table

## Variables missing from codebook: BPX_C HPVSWR_F OHXPRL_B OHXPRU_B ...

##

subset(resdf, table == "P_DEMO")

x <- "P_DEMO"; var <- "DMDBORN4"
d1 <- nhanesA:::raw2translated(nhanes(x, translated = FALSE),
                               nhanesCodebook(x),
                               cleanse_numeric = FALSE)
nm <- names(d1)
d2 <- nhanes(x, translated = TRUE)[nm]
d1 <- d1[order(d1$SEQN), ]
d2 <- d2[order(d2$SEQN), ]

data.frame(SEQ1 = d1$SEQN, SEQ2 = d2$SEQN,
           VAR1 = d1[[var]], VAR2 = d2[[var]]) |> head()


phonto::nhanesQuery("select * from MetaData.VariableCodebook where Variable = 'DMDBORN4' and CodeOrValue = '1'")

## Hmm, the DB version of nhanesCodebook() is doing something weird:

nhanesOptions(log.access = TRUE)
nhanesA:::.nhanesCodebookDB("P_DEMO", "DMDBORN4") |> str()

## This needs to be fixed first. All info should be contained in

nhanesQuery("SELECT * FROM Metadata.QuestionnaireVariables WHERE TableName = 'P_DEMO'") |> str()

nhanesQuery("SELECT * FROM Metadata.VariableCodebook WHERE TableName = 'P_DEMO'") |> str()


nhanesQuery("select SEQN, DMDBORN4 from Translated.P_DEMO order by SEQN") |> str()


