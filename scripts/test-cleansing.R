
## Sys.setenv(NHANES_TABLE_BASE = "http://127.0.0.1:8080/cdc")

library(nhanesA)

nhanesOptions(use.db = FALSE, log.access = TRUE)

## check that we are cleansing numeric values

whq_1 <- nhanes("WHQ")
whq_2 <- nhanes("WHQ", cleanse_numeric = TRUE)
whq_3 <- nhanesFromURL("/Nchs/Nhanes/1999-2000/WHQ.XPT") # cleanse_numeric = TRUE by default

data.frame(before = whq_1$WHD020, after = whq_2$WHD020) |>
    subset(!is.na(before) & is.na(after)) |>
    unique()

data.frame(before = whq_1$WHD020, after = whq_3$WHD020) |>
    subset(!is.na(before) & is.na(after)) |>
    unique()




