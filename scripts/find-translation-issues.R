

## Identify codebook issues in translation

stopifnot(require(nhanesA))
stopifnot(isTRUE(nhanesOptions("use.db")))
stopifnot(require(phonto))

options(warn = -1)

translate <- function(x)
    nhanesA:::raw2translated(nhanes(x, translated = FALSE),
                             nhanesCodebook(x),
                             cleanse_numeric = FALSE)

translationWarnings <- function(x)
{
    withCallingHandlers(translate(x),
                        warning = function(w) cat(x, "::",
                                                  conditionMessage(w),
                                                  "\n", sep = ""),
                        error = function(e) cat(x, "::ERROR::",
                                                conditionMessage(e),
                                                "\n", sep = ""))
    
    invisible()
}

mf <- nhanesManifest()

for (tab in sort(mf$Table)) try(translationWarnings(tab), silent = TRUE)

### These have some but not all variables missing from codebook

## BPX_C	Missing codebook table, skipping translation for variable: BPXSAR
## BPX_C	Missing codebook table, skipping translation for variable: BPXDAR
## HPVSWR_F	Missing codebook table, skipping translation for variable: LBDRPI
## OHXPRL_B	Missing codebook table, skipping translation for variable: OHASCST5
## OHXPRU_B	Missing codebook table, skipping translation for variable: OHASCST5
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030AA
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030AB
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030AC
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030BA
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030BB
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030BC
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030BD
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030BE
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030CA
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030CB
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030CC
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030CD
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030CE
## OSQ_B	Missing codebook table, skipping translation for variable: OSD030CF

## The rest have no codebook information for any variable (and some are false positives)

## ALB_CR_G	Missing codebook table, skipping translation for variable: URXUMA
## ALB_CR_G	Missing codebook table, skipping translation for variable: URXUMS
## ALB_CR_G	Missing codebook table, skipping translation for variable: URXUCR
## ALB_CR_G	Missing codebook table, skipping translation for variable: URXCRS
## ALB_CR_G	Missing codebook table, skipping translation for variable: URDACT
## DEMO		Variable not found in codebook, skipping translation for variable: years
## DRXFCD_I	Missing codebook table, skipping translation for variable: DRXFDCD
## DRXFCD_I	Missing codebook table, skipping translation for variable: DRXFCSD
## DRXFCD_I	Missing codebook table, skipping translation for variable: DRXFCLD
## DRXFCD_J	Missing codebook table, skipping translation for variable: DRXFDCD
## DRXFCD_J	Missing codebook table, skipping translation for variable: DRXFCSD
## DRXFCD_J	Missing codebook table, skipping translation for variable: DRXFCLD
## DRXFMT	Missing codebook table, skipping translation for variable: FMTNAME
## DRXFMT	Missing codebook table, skipping translation for variable: START
## DRXFMT	Missing codebook table, skipping translation for variable: LABEL
## DRXFMT_B	Missing codebook table, skipping translation for variable: FMTNAME
## DRXFMT_B	Missing codebook table, skipping translation for variable: START
## DRXFMT_B	Missing codebook table, skipping translation for variable: LABEL
## FOODLK_C	Missing codebook table, skipping translation for variable: FFQ_FOOD
## FOODLK_C	Missing codebook table, skipping translation for variable: VALUE
## FOODLK_D	Missing codebook table, skipping translation for variable: FFQ_FOOD
## FOODLK_D	Missing codebook table, skipping translation for variable: VALUE
## OCQ_I	ERROR	Table(s) OCQ_I missing from database
## P_DRXFCD	Missing codebook table, skipping translation for variable: DRXFDCD
## P_DRXFCD	Missing codebook table, skipping translation for variable: DRXFCSD
## P_DRXFCD	Missing codebook table, skipping translation for variable: DRXFCLD
## P_DRXFCD	Missing codebook table, skipping translation for variable: DRXFFCSD
## P_DRXFCD	Missing codebook table, skipping translation for variable: DRXFFDLD
## P_SSFR	Missing codebook table, skipping translation for variable: WTSSBPP
## P_SSFR	Missing codebook table, skipping translation for variable: SSIPPP
## P_SSFR	Missing codebook table, skipping translation for variable: SSIPPPL
## P_SSFR	Missing codebook table, skipping translation for variable: SSBPPP
## P_SSFR	Missing codebook table, skipping translation for variable: SSBPPPL
## PAHS_G	ERROR	Table(s) PAHS_G missing from database
## PAHS_I	ERROR	Table(s) PAHS_I missing from database
## PAXMIN_G	ERROR	Table(s) PAXMIN_G missing from database
## PAXMIN_H	ERROR	Table(s) PAXMIN_H missing from database
## POOLTF_D	Missing codebook table, skipping translation for variable: WTSC2YRA
## POOLTF_E	Missing codebook table, skipping translation for variable: WTSA2YRA
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDRGID
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDRUG
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDINGFL
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI1A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI1B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI1C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI2A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI2B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI2C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI3A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI3B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI3C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI4A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI4B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCI4C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI1A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI1B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI1C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI2A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI2B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI2C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI3A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI3B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI3C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI4A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI4B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI4C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI5A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI5B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI5C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI6A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI6B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICI6C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN1A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN1B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN1C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN2A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN2B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN2C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN3A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN3B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN3C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN4A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN4B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDDCN4C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN1A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN1B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN1C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN2A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN2B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN2C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN3A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN3B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN3C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN4A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN4B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN4C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN5A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN5B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN5C
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN6A
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN6B
## RXQ_DRUG	Missing codebook table, skipping translation for variable: RXDICN6C
## VARLK_C	Missing codebook table, skipping translation for variable: FFQ_VAR
## VARLK_C	Missing codebook table, skipping translation for variable: VALUE
## VARLK_D	Missing codebook table, skipping translation for variable: FFQ_VAR
## VARLK_D	Missing codebook table, skipping translation for variable: VALUE



for (x in c("ALB_CR_G", "BPX_C", "DRXFCD_I", "DRXFCD_J", "DRXFMT",
            "DRXFMT_B", "FOODLK_C", "FOODLK_D", "HPVSWR_F",
            "OHXPRL_B", "OHXPRU_B", "OSQ_B", "P_DRXFCD", "P_SSFR",
            "POOLTF_D", "POOLTF_E", "RXQ_DRUG", "VARLK_C", "VARLK_D"))
{
    browseNHANES(nh_table = x)
    Sys.sleep(runif(1, 1, 2))
}
