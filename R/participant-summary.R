

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

participantDemographics <- do.call(rbind, utables_data)

## these sets are mutually exclusive, but their level sets differ. We will merge them for convenience

xtabs( ~ AIALANG + AIALANGA, participantDemographics, addNA = TRUE)
xtabs( ~ DMDBORN + DMDBORN2 + DMDBORN4, participantDemographics, addNA = TRUE)
xtabs( ~ DMQMILIT + DMQMILIZ, participantDemographics, addNA = TRUE)


participantDemographics <- within(participantDemographics,
{
    AIALANG[is.na(AIALANG)] <- AIALANGA[is.na(AIALANG)]; rm(AIALANGA)
    DMDBORN[is.na(DMDBORN)] <- DMDBORN2[is.na(DMDBORN)]; rm(DMDBORN2)
    DMDBORN[is.na(DMDBORN)] <- DMDBORN4[is.na(DMDBORN)]; rm(DMDBORN4)
    DMQMILIT[is.na(DMQMILIT)] <- DMQMILIZ[is.na(DMQMILIT)]; rm(DMQMILIZ)
})


## these are mutually exclusive - possibly depending on participant age? But lots of case mimatches

xtabs( ~ DMDEDUC2 + DMDEDUC3, participantDemographics, addNA = TRUE) |> as.data.frame.table() |> subset(Freq > 0)

participantDemographics <- within(participantDemographics,
{
    DMDEDUC2 <- tolower(DMDEDUC2)
    DMDEDUC3 <- tolower(DMDEDUC3)
})


bwplot(participantDemographics, factor(is.na(DMDEDUC2)) ~ RIDAGEYR, subset = !(is.na(DMDEDUC2) & is.na(DMDEDUC3)))

subset(participantDemographics, !is.na(DMDEDUC2))$RIDAGEYR |> summary()
subset(participantDemographics, !is.na(DMDEDUC3))$RIDAGEYR |> summary()

## So might as well combine.  What is DMDEDUC? Coarser classification,
## also collected only in first 3 cycles. Drop.

participantDemographics <- within(participantDemographics,
{
    DMDEDUC2[is.na(DMDEDUC2)] <- DMDEDUC3[is.na(DMDEDUC2)]; rm(DMDEDUC3)
    rm(DMDEDUC)
})

## 5545  RIDRETH1                  Race/Ethnicity - Recode
## 5732  RIDRETH1                     Race/Hispanic origin
## 5546  RIDRETH2       Linked NH3 Race/Ethnicity - Recode
## 5733  RIDRETH3         Race/Hispanic origin w/ NH Asian


xtabs( ~ RIDRETH1 + RIDRETH2 + RIDRETH3, participantDemographics, addNA = TRUE) |> as.data.frame.table() |> subset(Freq > 0)

## RIDRETH2 and RIDRETH3 seem to be mutually exclusive, so lets combine them first

participantDemographics <- within(participantDemographics,
{
    RIDRETH2[is.na(RIDRETH2)] <- RIDRETH2[is.na(RIDRETH2)]; rm(RIDRETH3)
})

xtabs( ~ RIDRETH1 + RIDRETH2, participantDemographics, addNA = TRUE) |> as.data.frame.table() |> subset(Freq > 0)

## So RIDRETH1 seems to be more complete, but we will keep both

## OK, now let's see descriptions of the remaining variables along with non-missing counts

udemo_vars <- subset(udemo_vars, varname %in% names(participantDemographics))
udemo_vars$count <- sapply(udemo_vars$varname, function(v) sum(!is.na(participantDemographics[[v]])))

qqmath(udemo_vars, ~ count, grid = TRUE)


subset(udemo_vars, count < 20000)

save(participantDemographics, file = "participantDemographics.rda")


## Finally, make a version with human-readable names which only keep
## broad information

participantSummary <-
    with(participantDemographics,
         data.frame(SEQN = SEQN,
                    cycle = SDDSRVYR,
                    status = RIDSTATR,
                    gender = RIAGENDR,
                    race = RIDRETH1,
                    age = RIDAGEYR,
                    birth_country = DMDBORN,
                    interview_lang = FIALANG, # actually only family interview
                    poverty = INDFMPIR, # poverty income ratio, skip incomes
                    marital = DMDMARTL,
                    preg_exam = RIDEXPRG,
                    citizenship = DMDCITZN,
                    us_years = DMDYRSUS,
                    school_attendance = DMDSCHOL,
                    education = DMDEDUC2,
                    military = DMQMILIT,
                    wt_interview = WTINT2YR,
                    wt_mec = WTMEC2YR,
                    SDMVPSU = SDMVPSU,   # Masked Variance Pseudo-PSU
                    SDMVSTRA = SDMVSTRA) # Masked Variance Pseudo-Stratum
         )

save(participantSummary, file = "participantSummary.rda")
         
xtabs(~ status, participantSummary) # summarize to: Interview only / Interview + MEC

xtabs(~ gender, participantSummary)
xtabs(~ race, participantSummary)
xtabs(~ interview_lang, participantSummary)

xtabs(~ birth_country, participantSummary) # USA / Mexico / Elsewhere
                                           # / Other-Spanish / Other-Non-Spanish / ...
xtabs(~ citizenship, participantSummary) # yes / no / don't know / refused

xtabs(~ marital + gender, participantSummary, addNA = TRUE) # combine "Don't know" and "Don't Know"
xtabs(~ preg_exam + gender, participantSummary, addNA = TRUE)

xtabs(~ school_attendance, participantSummary) # yes = {school, vacation} / no / don't know
xtabs(~ education, participantSummary)
xtabs(~ military, participantSummary)


densityplot(~ poverty | race, participantSummary, groups = gender, plot.points = FALSE)


d <- xtabs(~ gender + race + cycle, participantSummary) |> array2DF()

xyplot(Value ~ as.numeric(factor(cycle)) | reorder(race, Value), d, groups = gender,
       grid = TRUE, type = "o", auto.key = list(columns = 2), layout = c(NA, 1))








