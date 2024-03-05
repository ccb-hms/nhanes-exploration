
## Go through all tables and check whether SEQN is duplicated (and
## hence not a viable primary key)

stopifnot(require(nhanesA))
stopifnot(isTRUE(nhanesOptions("use.db")))
stopifnot(require(phonto))

no_seqn <- function(table) !("SEQN" %in% names(nhanes(table, translated = FALSE)))

seqn_dup <- function(table, verbose = getOption("verbose"))
{
    if (verbose) cat("\r", table)
    anyDuplicated(nhanes(table, translated = FALSE)$SEQN)
}

tables <- nhanesQuery("select TableName from metadata.QuestionnaireDescriptions")[[1]]

## which tables have no SEQN variable

system.time(no_seqn_tables <- Filter(no_seqn, sort(tables))) ## ~ 50 seconds

cat(no_seqn_tables, fill = TRUE)

## BFRPOL_D BFRPOL_E BFRPOL_F BFRPOL_G BFRPOL_H BFRPOL_I DOXPOL_D
## DOXPOL_E DOXPOL_F DOXPOL_G DRXFCD_C DRXFCD_D DRXFCD_E DRXFCD_F
## DRXFCD_G DRXFCD_H DRXFCD_I DRXFCD_J DRXFMT DRXFMT_B DRXMCD_C
## DRXMCD_D DRXMCD_E DRXMCD_F DRXMCD_G DSBI DSII DSPI FOODLK_C
## FOODLK_D P_DRXFCD PCBPOL_D PCBPOL_E PCBPOL_F PCBPOL_G PCBPOL_H
## PCBPOL_I PFC_POOL PSTPOL_D PSTPOL_E PSTPOL_F PSTPOL_G PSTPOL_H
## PSTPOL_I RXQ_DRUG SSBFR_B SSPCB_B SSPST_B VARLK_C VARLK_D

## Some of these are pooled tables and should have SAMPLEID

no_sampleid <- function(table) !("SAMPLEID" %in% names(nhanes(table, translated = FALSE)))
no_sampleid_tables <- Filter(no_sampleid, no_seqn_tables)

cat(no_sampleid_tables, fill = TRUE)

## DRXFCD_C DRXFCD_D DRXFCD_E DRXFCD_F DRXFCD_G DRXFCD_H DRXFCD_I
## DRXFCD_J DRXFMT DRXFMT_B DRXMCD_C DRXMCD_D DRXMCD_E DRXMCD_F
## DRXMCD_G DSBI DSII DSPI
## FOODLK_C FOODLK_D ()
## P_DRXFCD PFC_POOL
## RXQ_DRUG SSBFR_B SSPCB_B SSPST_B
## VARLK_C VARLK_D (FFQ_VAR)


## Will come back to these later. First, check for duplicate SEQN in
## those that have it

seqn_tables <- sort(setdiff(tables, no_seqn_tables))
system.time(dup_tables <- Filter(seqn_dup, sort(tables))) ## ~ 60 seconds

cat(dup_tables, fill = TRUE)

## AUXAR_I AUXAR_J (SEQN, RFXSEAR, RFXLEVEL)
## AUXTYM_I AUXTYM_J (SEQN, TYXPEAR)
## AUXWBR_I AUXWBR_J (SEQN, WBXFEAR)
## DR1IFF_C DR1IFF_D DR1IFF_E DR1IFF_F DR1IFF_G DR1IFF_H DR1IFF_I DR1IFF_J (SEQN, DR1ILINE)
## DR2IFF_C DR2IFF_D DR2IFF_E DR2IFF_F DR2IFF_G DR2IFF_H DR2IFF_I DR2IFF_J (SEQN, DR2ILINE)
## DRXIFF DRXIFF_B (SEQN, DRXILINE)
## DS1IDS_E DS1IDS_F DS1IDS_G DS1IDS_H DS1IDS_I DS1IDS_J (SEQN, DSDSUPID)
## DS2IDS_E DS2IDS_F DS2IDS_G DS2IDS_H DS2IDS_I DS2IDS_J (SEQN, DSDSUPID)
## DSQ2_B DSQ2_C DSQ2_D (SEQN, DSDSUPID)
## DSQFILE2 (SEQN, DSDSUPID)
## DSQIDS_E DSQIDS_F DSQIDS_G DSQIDS_H DSQIDS_I DSQIDS_J (SEQN, DSDSUPID) - actually none
## FFQDC_C FFQDC_D (SEQN, FFQ_VAR, FFQ_FOOD)
## PAQIAF PAQIAF_B PAQIAF_C PAQIAF_D (SEQN, PADACTIV)
## PAXDAY_G PAXDAY_H (SEQN, PAXSSNDP)
## PAXHR_G PAXHR_H (SEQN, PAXSSNHP)
## RXQ_RX RXQ_RX_B RXQ_RX_C RXQ_RX_D RXQ_RX_E RXQ_RX_F RXQ_RX_G RXQ_RX_H RXQ_RX_I RXQ_RX_J (SEQN, NHCODE)
## RXQ_ANA RXQANA_B RXQANA_C (SEQN, RXD310)
## SSHPV_F (SEQN, SSHPTYPE)

## P_AUXAR P_AUXTYM P_AUXWBR P_DR1IFF P_DR2IFF P_DS1IDS P_DS2IDS P_DSQIDS P_RXQ_RX



## Compare with tables flagged by DB check

flagged_tables <-
    strsplit("DR1IFF_C DR1IFF_D DR1IFF_E DR1IFF_F DR1IFF_G DR1IFF_H DR1IFF_I DR1IFF_J DR2IFF_C DR2IFF_D DR2IFF_E DR2IFF_F DR2IFF_G DR2IFF_H DR2IFF_I DR2IFF_J DRXIFF_B DS2IDS_E DSQ2_B DSQ2_C DSQ2_D DSQFILE2 DSQIDS_E DSQIDS_F DSQIDS_G DSQIDS_H DSQIDS_I DSQIDS_J L06_2_B OSQ_B P_DR1IFF P_DR2IFF P_DSQIDS P_RXQ_RX RXQ_ANA RXQ_RX RXQ_RX_B RXQ_RX_C RXQ_RX_D RXQ_RX_E RXQ_RX_F RXQ_RX_G RXQ_RX_H RXQ_RX_I RXQ_RX_J RXQANA_B RXQANA_C",
             " ")[[1]]

## Differences

setdiff(flagged_tables, dup_tables) |> cat(sep = "\n")

## SEQN is unique, so there is probably some other problem

## L06_2_B
## OSQ_B

setdiff(dup_tables, flagged_tables) |> cat(sep = "\n")

## Need to check why these are not flagged

## AUXAR_I
## AUXAR_J
## AUXTYM_I
## AUXTYM_J
## AUXWBR_I
## AUXWBR_J
## DRXIFF
## DS1IDS_E
## DS1IDS_F
## DS1IDS_G
## DS1IDS_H
## DS1IDS_I
## DS1IDS_J
## DS2IDS_F
## DS2IDS_G
## DS2IDS_H
## DS2IDS_I
## DS2IDS_J
## FFQDC_C
## FFQDC_D
## P_AUXAR
## P_AUXTYM
## P_AUXWBR
## P_DS1IDS
## P_DS2IDS
## PAQIAF
## PAQIAF_B
## PAQIAF_C
## PAQIAF_D
## PAXDAY_G
## PAXDAY_H
## PAXHR_G
## PAXHR_H
## SSHPV_F


save(tables, seqn_tables, dup_tables, no_seqn_tables, no_sampleid_tables, file = "dups.rda")


