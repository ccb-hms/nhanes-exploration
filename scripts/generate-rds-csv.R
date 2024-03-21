

## First, set up a local caching mirror, by running the following in
## ANOTHER session. Keep an eye on the session to see if anything
## unexpected is happening.

if (FALSE)
{
    require(cachehttp)
    add_cache("cdc", "https://wwwn.cdc.gov",
              fun = function(x) {
                  x <- tolower(x)
                  endsWith(x, ".htm") || endsWith(x, ".xpt")
              })
    s <- start_cache(host = "0.0.0.0", port = 8080,
                     static_path = BiocFileCache::bfccache(BiocFileCache::BiocFileCache()))

    ## httpuv::stopServer(s) # to stop the httpuv server

}

Sys.setenv(NHANES_TABLE_BASE = "http://127.0.0.1:8080/cdc")

library(nhanesA)
nhanesOptions(use.db = FALSE, log.access = TRUE)
mf <- nhanesManifest()

## Remove the tables we will not download (usually because they are
## large; some others have already been removed by nhanesManifest())

mf <- subset(mf, !startsWith(Table, "PAXMIN"))

FILEROOT <- "~/nhanes-data" # should already contain folders raw and translated


## 1. create RDS files equivalent to XPT files

for (x in sort(mf$Table)) {
    rawrds <- sprintf("%s/raw/%s.rds", FILEROOT, x)
    if (!file.exists(rawrds)) {
        cat(x, " -> ", rawrds, fill = TRUE)
        d <- nhanes(x, translated = FALSE)
        if (is.data.frame(d))
            saveRDS(d, file = rawrds)
    }
}

## 2. create raw CSV files (from RDS)

for (x in sort(mf$Table)) {
    rawrds <- sprintf("%s/raw/%s.rds", FILEROOT, x)
    rawcsv <- sprintf("%s/raw/%s.csv", FILEROOT, x)
    if (!file.exists(rawcsv)) {
        cat(rawrds, " -> ", rawcsv, fill = TRUE)
        d <- readRDS(rawrds)
        if (is.data.frame(d))
            write.csv(d, file = rawcsv, row.names = FALSE)
    }
}

## 3. create translated CSV files (from RDS and codebooks)

## these give error such as 'Error in firstDash - 1 : non-numeric argument'.
## Postpone for now, come back later

mf <- subset(mf, !startsWith(Table, "DRX")) 
mf <- subset(mf, !startsWith(Table, "DXX"))
mf <- subset(mf, !startsWith(Table, "FOOD"))


for (x in sort(mf$Table)) {
    rawrds <- sprintf("%s/raw/%s.rds", FILEROOT, x)
    tracsv <- sprintf("%s/translated/%s.csv", FILEROOT, x)
    if (!file.exists(tracsv)) {
        cat(rawrds, " -> ", tracsv, fill = TRUE)
        d <- readRDS(rawrds)
        cb <- nhanesCodebook(x)
        t <- nhanesA:::raw2translated(d, cb, cleanse_numeric = TRUE)
        if (is.data.frame(t))
            write.csv(t, file = tracsv, row.names = FALSE)
    }
}




