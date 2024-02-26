
## 1. Translate all tables in R and compare timings with direct DB access.
## 2. Check whether result matches DB

stopifnot(require(nhanesA))
stopifnot(isTRUE(nhanesOptions("use.db")))
stopifnot(require(phonto))

source("codebookFromDB.R")

if (file.exists("dups.rda"))
    load("dups.rda") else source("test-seqn-uniqueness.R", echo = TRUE)


compare_tables <- function(d1, d2)
{
    if (ncol(d1) != ncol(d2)) return("column number mismatch")
    if (nrow(d1) != nrow(d2)) return("row number mismatch")
    nm <- names(d1)
    d2 <- d2[nm]
    if (anyDuplicated(d1$SEQN)) {
        d1 <- d1[do.call(order, as.list(d1)), ]
        d2 <- d2[do.call(order, as.list(d2)), ]
    }
    else {
        d1 <- d1[order(d1$SEQN), ]
        d2 <- d2[order(d2$SEQN), ]
    }
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
                                       nhCodebook(x),
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
resdf <- within(resdf, {
    dup_SEQN <- table %in% dup_tables
    t1 <- round(t1, 5)
    t2 <- round(t2, 5)
})

write.csv(resdf, "translation-test.csv")

subset(resdf, DUP_SEQN)

subset(resdf, !DUP_SEQN & status != "OK")

plot(t2 ~ t1, resdf, col = DUP_SEQN + 1, log = "xy"); abline(0, 1)

## Summary: most tables with duplicate SEQN have mismatches. A few
## others also have mismatches. The rest of the code is very ad hoc,
## trying to figure out the differences. Probably best to come back to
## these after a couple of issues have been settled.

## https://github.com/ccb-hms/NHANES/issues/171
## https://github.com/ccb-hms/NHANES/issues/172


nodup_mismatch_tables <- subset(resdf, !DUP_SEQN & status != "OK")$table

## Variables missing from codebook: BPX_C HPVSWR_F OHXPRL_B OHXPRU_B ...

##

subset(resdf, table == "P_DEMO")

x <- "P_DEMO"; var <- "DMDBORN4"


phonto::nhanesQuery("select * from MetaData.VariableCodebook where Variable = 'DMDBORN4' and CodeOrValue = '1'")

## Hmm, the DB version of nhanesCodebook() is doing something weird:

nhanesOptions(log.access = TRUE)
nhanesA:::.nhanesCodebookDB("P_DEMO", "DMDBORN4") |> str()

## But fine for, say, DEMO_C
nhanesA:::.nhanesCodebookDB("DEMO_C", "DMDBORN") |> str()



## For now, let's focus on the ones with duplicate SEQNs. 

## - AUXAR_J - duplicate SEQN but not flagged by DB check
## - DSQ2_B - duplicate SEQN and flagged

subset(resdf, table %in% c("AUXAR_J", "DSQ2_B"))

x <- "DSQ2_B" # "AUXAR_J"

d0 <- nhanes(x, translated = FALSE)
d1 <- nhanesA:::raw2translated(d0,
                               nhCodebook(x),
                               cleanse_numeric = FALSE)
nm <- names(d1)
d2 <- nhanes(x, translated = TRUE)[nm]

## update row order to hopefully match
d0 <- d0[do.call(order, as.list(d1)), ]
d1 <- d1[do.call(order, as.list(d1)), ]
d2 <- d2[do.call(order, as.list(d2)), ]

subset(d0, SEQN == 93706, select = 1:5)
subset(d1, SEQN == 93706, select = 1:5)
subset(d2, SEQN == 93706, select = 1:5)

subset(d0, SEQN == 9969, select = -3)
subset(d1, SEQN == 9966, select = -3)
subset(d2, SEQN == 9966, select = -3)


## Se DSQ2_B is complicated by character strings - need to figure out what to do. For AUXAR_J, simple DEMO

phonto::nhanesQuery("SELECT SEQN, RFXSEAR FROM Raw.AUXAR_J where SEQN = '93706'")
phonto::nhanesQuery("SELECT SEQN, RFXSEAR FROM Translated.AUXAR_J where SEQN = '93706'")


