
# libs
library(data.table)
library(shiny.semantic)
library(shiny)
library(leaflet)
library(geosphere)

# loading the data
ships <- readRDS("./data/ships-db.rds")
desc <- fread("./data/ships.csv")

# loading the modules
source("./src/utils.R")

