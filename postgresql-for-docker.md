---
title: PostgreSQL experiments for Epiconductor
author: Deepayan Sarkar
---

# Plan


To test DB table insertion via phonto into a PostgreSQL database, I
will start with experimenting on my desktop directly. The basic plan
is to:

- Install postgres

- Create user 'sa' with password 'yourStrong(!)Password'

- Create database `NhanesLandingZone`

- Run `create schema Metadata; create schema Raw; create schema Translated;`

- Fill in `Metadata.QuestionnaireVariables`,
  `Metadata.VariableCodebook`, possibly using `insertTableDB()`. These
  are required to create the codebook for translations (unless we want
  to download on the fly). Do we need support functions for these?

- Fill in `Raw.*` and `Translated.*` tables in a loop

We can start by doing just the `Raw.*` tables, which will not require
codebook processing.

To avoid download lags, we will use a local mirror as described
[here](https://ccb-hms.github.io/phonto/vignettes/nhanes-local.html).


# Install and confiugure PostgreSQL

We follow instructions for
[Debian](https://wiki.debian.org/PostgreSql), assuming it will work
for Ubuntu / rocker as well.

```sh
apt install postgresql postgresql-client
```

Both the default database user and default database are called
`postgres`. To create a new user, 

```
sudo -u postgres -s
createuser --pwprompt sa # type/paste password twice: yourStrong(!)Password
createdb -O sa NhanesLandingZone
```

NOTES: 

- I couldn't figure out how to specify 

- A password may be pointless; we may instead make the database
  read-only to avoid tampering.
  
- If necessary, undo the previous steps using

```sh
dropdb NhanesLandingZone
dropuser sa
```

For future password-less connections, add (as the user who is going to log in):

```
echo 'localhost:5432:NhanesLandingZone:sa:yourStrong(!)Password' >> ~/.pgpass
chmod 600 ~/.pgpass
```

Test: connect as user 'sa' to new database

```
psql -d NhanesLandingZone -h localhost -U sa
```

The password will not need to be provided if the logged in user has a
correctly set up `~/.pgpass` file.


# Create schemas

It may be possible (and simpler) to do this from R. After connecting
to the DB, execute:

```
create schema Metadata; 
create schema Raw; 
create schema Translated;
```

# Test connecting from R

There are two options: The newer
[RPostgres](https://cran.r-project.org/package=RPostgres) (Posit) and
[RPostgreSQL](https://cran.r-project.org/package=RPostgreSQL) (Dirk et
al). Can compare performance later; for now, just pick one.



```r
library(DBI)
library(RPostgres)
con <- 
    DBI::dbConnect(
             RPostgres::Postgres(),
             dbname = Sys.getenv("EPICONDUCTOR_DB_DATABASE", unset = "NhanesLandingZone"),
             host = Sys.getenv("EPICONDUCTOR_DB_SERVER", unset = "localhost"),
             port = as.integer(Sys.getenv("EPICONDUCTOR_DB_PORT", unset = "5432")),
             password = Sys.getenv("SA_PASSWORD", unset = "yourStrong(!)Password"),
             user = Sys.getenv("EPICONDUCTOR_DB_UID", unset = "sa"))

library(nhanesA)
library(phonto)
nhanesOptions(use.db = FALSE, log.access = TRUE)

tables <- paste0("DEMO_", LETTERS[2:5])

for (t in tables) {
    message(t)
    target <- phonto:::dbTableNameFromNHANES(t, "raw")
    if (DBI::dbExistsTable(con, target)) {
        message("Removing existing table first")
        DBI::dbRemoveTable(con, target)
    }
    ## FIXME: eventually want to use nhanesManifest() and
    ## nhanes*FromURL() to download data first.
    dbInsertNhanesTable(con, t, type = "raw")
}
```

Sanity check:

```r
DBI::dbReadTable(con, "Raw.DEMO_C") |> str()
```


# TODO

Do this more systematically, after setting up a local mirror, and
doing the codebooks first.





