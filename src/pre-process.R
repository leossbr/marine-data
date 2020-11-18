
# libs used to pre process the data
library(data.table)
library(magrittr)
library(lubridate)
library(geosphere)

options(scipen = 999)

# reading the database
ships <- fread("./data/ships.csv")

# there are some possible duplications in the dataset, so we`re taking only the unique observations
ships <- unique(ships)

# working on the dataset columns
ships[, DATETIME := ymd_hms(DATETIME)]
ships <- ships[order(SHIP_ID, DATETIME)]
ships[, LAT_LAG := shift(LAT, 1, type = "lag"), SHIP_ID]
ships[, LON_LAG := shift(LON, 1, type = "lag"), SHIP_ID]

# removing the first observation since we have no previous location
ships <- ships[complete.cases(ships)]

# creating a unique row identifier to apply the haversine function
ships[, idx := .I]
ships[, distance := distHaversine(p1 = c(LON_LAG, LAT_LAG), p2 = c(LON, LAT)), .(SHIP_ID, idx)]

# selecting the max distance for each ship
ships_db <- ships[order(-distance, -DATETIME), .SD[1], SHIP_ID]

# keeping necessary columns
ships_db <- ships_db[
  j = .(
    ship_type, 
    ship_id = SHIP_ID,
    flag = FLAG, 
    ship_name = SHIPNAME, 
    distance,
    port = PORT,
    destination = DESTINATION,
    lon = LON,
    lat = LAT,
    lon_lag = LON_LAG,
    lat_lag = LAT_LAG
    )
]

# treating the chr columns
str_cols <- c("ship_type", "ship_name", "port", "destination")
ships_db[, (str_cols) := lapply(.SD, stringr::str_to_title), .SDcols = (str_cols)]

# if the ship name is not unique, add the flag to its name
non_unique_ships <- unique(ships_db[, .I[.N > 1], ship_name]$ship_name)
ships_db[ship_name %in% non_unique_ships, ship_name := paste(ship_name, flag, sep = "-")]

# testing
testthat::expect_true(ships_db[, uniqueN(ship_name) == .N])

# saving the pre processed database
saveRDS(ships_db, "./data/ships-db.rds")





