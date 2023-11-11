

## This assumes that "nhanesVarSummary.rda" has already been created
## and available in the working directory.

library(nhanesA)
library(lattice)

load("nhanesVarSummary.rda")

## Goal: make a data frame with one row per participant, with data
## from the DEMO* tables only.

demo_vars <- subset(nhanesVarSummary, startsWith(table, "DEMO"))

## which are common variables? The first cycle (DEMO) had many more
## variables, which were presumably moved to other tables
## subsequently.

xtabs(~ varname + table, demo_vars) |> colSums()

## Let's remove variables that appear only once

to_skip <- names(which(rowSums(xtabs(~ varname + table, demo_vars)) == 1))

demo_vars <- subset(demo_vars, !(varname %in% to_skip))
demo_vars$label <- tolower(demo_vars$label)

xtabs(~ varname + table, demo_vars) |> lattice::levelplot(scales = list(x = list(rot = 90)))
udemo_vars <- unique(demo_vars[order(demo_vars$varname) , c("varname", "label")])

## Even for this one table there are many variations. For now, we will
## try to get all variables from all tables, setting NA for missing

getValues <- function(df, varname, seqn = sort(df$SEQN))
{
    values <- df[[varname]]
    if (is.null(values)) rep(NA, nrow(df))
    else structure(values, names = as.character(df[["SEQN"]]))[as.character(seqn)]
}

## construct one table at a time

utables <- sort(unique(demo_vars$table))
uvars <- unique(udemo_vars$varname)
uvars <- c("SEQN", sort(uvars[uvars != "SEQN"]))

getTableData <- function(table, vars)
{
    cat(table, fill = TRUE)
    df <- nhanes(table)
    varData <- lapply(vars, getValues, df = df)
    names(varData) <- vars
    do.call(data.frame, c(list(table = table), varData))
}

utables_data <- lapply(utables, getTableData, vars = uvars)

participantSummary <- do.call(rbind, utables_data)

## these sets are mutually exclusive, but their level sets differ. We will merge them for convenience

xtabs( ~ AIALANG + AIALANGA, participantSummary, addNA = TRUE)
xtabs( ~ DMDBORN + DMDBORN2 + DMDBORN4, participantSummary, addNA = TRUE)


participantSummary <- within(participantSummary,
{
    AIALANG[is.na(AIALANG)] <- AIALANGA[is.na(AIALANG)]; rm(AIALANGA)
    DMDBORN[is.na(DMDBORN)] <- DMDBORN2[is.na(DMDBORN)]; rm(DMDBORN2)
    DMDBORN[is.na(DMDBORN)] <- DMDBORN4[is.na(DMDBORN)]; rm(DMDBORN4)
})


## these are mutually exclusive - possibly depending on participant age? But lots of case mimatches

xtabs( ~ DMDEDUC2 + DMDEDUC3, participantSummary, addNA = TRUE) |> as.data.frame.table() |> subset(Freq > 0)

participantSummary <- within(participantSummary,
{
    DMDEDUC2 <- tolower(DMDEDUC2)
    DMDEDUC3 <- tolower(DMDEDUC3)
})


bwplot(participantSummary, factor(is.na(DMDEDUC2)) ~ RIDAGEYR, subset = !(is.na(DMDEDUC2) & is.na(DMDEDUC3)))

subset(participantSummary, !is.na(DMDEDUC2))$RIDAGEYR |> summary()
subset(participantSummary, !is.na(DMDEDUC3))$RIDAGEYR |> summary()

## So might as well combine.  What is DMDEDUC? Coarser classification,
## also collected only in first 3 cycles. Drop.

participantSummary <- within(participantSummary,
{
    DMDEDUC2[is.na(DMDEDUC2)] <- DMDEDUC3[is.na(DMDEDUC2)]; rm(DMDEDUC3)
    rm(DMDEDUC)
})

## 5545  RIDRETH1                  Race/Ethnicity - Recode
## 5732  RIDRETH1                     Race/Hispanic origin
## 5546  RIDRETH2       Linked NH3 Race/Ethnicity - Recode
## 5733  RIDRETH3         Race/Hispanic origin w/ NH Asian


xtabs( ~ RIDRETH1 + RIDRETH2 + RIDRETH3, participantSummary, addNA = TRUE) |> as.data.frame.table() |> subset(Freq > 0)

## RIDRETH2 and RIDRETH3 seem to be mutually exclusive, so lets combine them first

participantSummary <- within(participantSummary,
{
    RIDRETH2[is.na(RIDRETH2)] <- RIDRETH2[is.na(RIDRETH2)]; rm(RIDRETH3)
})

xtabs( ~ RIDRETH1 + RIDRETH2, participantSummary, addNA = TRUE) |> as.data.frame.table() |> subset(Freq > 0)

## So RIDRETH1 seems to be more complete, but we will keep both

## OK, now let's see descriptions of the remaining variables along with non-missing counts

udemo_vars <- subset(udemo_vars, varname %in% names(participantSummary))
udemo_vars$count <- sapply(udemo_vars$varname, function(v) sum(!is.na(participantSummary[[v]])))

qqmath(udemo_vars, ~ count, grid = TRUE)


subset(udemo_vars, count < 20000)

save(participantSummary, file = "participantSummary.rda")




