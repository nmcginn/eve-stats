library(httr)
library(jsonlite)
library(dplyr)

# get type ids
ships <- "Sin|Panther|Redeemer|Widow"
response <- GET(paste0("https://www.fuzzwork.co.uk/api/typeid2.php?typename=", ships))
type_ids <- fromJSON(content(response, "text", encoding = "utf-8"))

# zkill data pull
dead_ships <- data.frame(row.names = FALSE)
for (type_id in type_ids$typeID) {
  for (page in 1:1000) {
    top_losses_api <- paste0("https://zkillboard.com/api/losses/shipID/", type_id, "/page/", page, "/")
    response <- GET(top_losses_api, httr::add_headers(`Accept` = "gzip", `User-Agent` = "Derek Kanjus"))
    killmails <- fromJSON(content(response, "text", encoding = "utf-8"), flatten = TRUE)
    if (length(killmails) == 0) {
      break()
    }
    killmails <- killmails %>% select(killID, killTime, victim.shipTypeID, victim.characterID, victim.characterName, victim.corporationName, victim.allianceName, zkb.totalValue)

    dead_ships <- rbind(dead_ships, killmails)
    Sys.sleep(1) # look how nice I'm being
  }
}

# data shaping junk
dead_ships$victim.shipTypeID <- as.character(dead_ships$victim.shipTypeID)
dead_ships <- inner_join(dead_ships, type_ids, by = c("victim.shipTypeID" = "typeID"))
save(dead_ships, file = "dead_ships.RData")

#lol_pl <- dead_ships %>% filter(victim.allianceName == "Pandemic Legion")
#waffe <- dead_ships %>% filter(victim.corporationName == "SniggWaffe")
