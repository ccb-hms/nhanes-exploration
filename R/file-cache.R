
library(BiocFileCache)
library(nhanesA)

nhanesOptions(use.db = FALSE)

mf <- nhanesManifest()


## Let's try to cache the first 10 doc and data URLS

(doc_paths <- paste0('https://wwwn.cdc.gov/', mf$DocURL[1:30]))
(data_paths <- paste0('https://wwwn.cdc.gov/', mf$DataURL[1:30]))
paths <- c(doc_paths, data_paths)

tbl <- data.frame(rtype = "web",
                  rpath = NA_character_,
                  fpath = paths,
                  keywords = basename(paths))

tbl

newbfc <-
    makeBiocFileCacheFromDataFramew(tbl,
                                   cache = normalizePath("~/nhanes-fc", mustWork = FALSE),
                                   actionWeb = "copy",
                                   actionLocal = "copy",
                                   metadataName = "resourceMetadata")



newbfc <- BiocFileCache(normalizePath("~/nhanes-fc", mustWork = FALSE))
bfcinfo(newbfc)


bfcdownload(newbfc, rid = "BFC2")


(p1 <- bfcrpath(newbfc, "https://wwwn.cdc.gov//Nchs/Nhanes/2015-2016/ALB_CR_I.htm"))
(p2 <- bfcrpath(newbfc, "https://wwwn.cdc.gov//Nchs/Nhanes/2015-2016/ALB_CR_I.XPT"))

h <- readLines(p1)


## Summary : makeBiocFileCacheFromDataFramew() doesn't actually
## download anything, and it's not very clear how to download
## everything in one go. So it's probably simpler to (1) create an
## empty cache, and (2) download and fill the cache on demand. For
## local use in creating the DB, we could simply run an external
## function that runs through the manifest and tries to access each
## URL, which should [?] automatically download everything.


