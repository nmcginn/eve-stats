library(httr)
library(jsonlite)
library(dplyr)

ships <- "Sin|Panther|Redeemer|Widow"
response <- GET(paste0("https://www.fuzzwork.co.uk/api/typeid2.php?typename=", ships))
type_id <- fromJSON(content(response, "text", encoding = "utf-8"))
type_ids <- paste(sort(type_id$typeID), collapse = ",")

dead_ships <- data.frame(row.names = FALSE)
for (page in 1:1000) {
  top_losses_api <- paste0("https://zkillboard.com/api/losses/shipID/", type_ids, "/page/", page, "/")
  response <- GET(top_losses_api, httr::add_headers(`Accept` = "gzip", `User-Agent` = "Derek Kanjus"))
  killmails <- fromJSON(content(response, "text", encoding = "utf-8"), flatten = TRUE)
  if (nrow(killmails) == 0) {
    break()
  }
  killmails <- killmails %>% select(killID, killTime, victim.shipTypeID, victim.characterID, victim.characterName, victim.corporationName, victim.allianceName, zkb.totalValue)

  dead_ships <- rbind(dead_ships, killmails)
  Sys.sleep(1) # look how nice I'm being
}
