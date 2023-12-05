
## Set up cachehttp <https://github.com/ccb-hms/cachehttp> to serve
## NHANES files at localhist:8080

if (!require("cachehttp")) {
    message("Install 'cachehttp' and try again: Run\n\n",
            'BiocManager::install("BiocFileCache")\n',
            'remotes::install_github("ccb-hms/cachehttp")')
    stop("'cachehttp' not installed.")
}

add_cache("cdc", "https://wwwn.cdc.gov",
          fun = function(x) {
              x <- tolower(x)
              endsWith(x, ".htm") || endsWith(x, ".xpt")
          })
s <- start_cache(host = "0.0.0.0", port = 8080,
                 static_path = BiocFileCache::bfccache(BiocFileCache::BiocFileCache()))

