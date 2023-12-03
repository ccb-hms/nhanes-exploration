
## Usage: R CMD BATCH --vanilla test-nhanesFromURL.R 

## See start-cache-server.R to use local cache

Sys.setenv(NHANES_TABLE_BASE = "http://127.0.0.1:8080/cdc")

library(nhanesA)
options(warn = 1) # show warning immediately

mp <- nhanesManifest("public")

## skip 2 large files
subset(mp, grepl("PAXMIN", DataURL))
mp <- subset(mp, !grepl("PAXMIN", DataURL))

for (f in mp$DataURL) {
    cat(f, ": ")
    try({d <- nhanesFromURL(f); cat(nrow(d), "\n") })
}


