
library(nhanesA)

(con <- nhanesA:::cn())

if (!is(con, "DBIConnection")) stop("Not connected to DB")


(tdemo <- setdiff(nhanesSearchTableNames("DEMO"), "P_DEMO"))

system.time(dlist0 <- lapply(tdemo, nhanes, translated = FALSE))
system.time(dlist0 <- lapply(tdemo, nhanes, translated = FALSE))
system.time(dlist1 <- lapply(tdemo, nhanes, translated = TRUE))
system.time(dlist1 <- lapply(tdemo, nhanes, translated = TRUE))

common_vars0 <- lapply(dlist0, names) |> Reduce(f = intersect)
common_vars1 <- lapply(dlist1, names) |> Reduce(f = intersect)

identical(sort(common_vars0), sort(common_vars1))
common_vars0 == common_vars1

lapply(dlist0, `[`, common_vars0) |> do.call(what = rbind) |> str()
lapply(dlist1, `[`, common_vars1) |> do.call(what = rbind) |> str()


