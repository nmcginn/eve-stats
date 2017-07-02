library(httr)
library(jsonlite)
library(dplyr)

# get type ids
ships <- "Aeon|Hel|Nyx|Revenant|Vendetta|Wyvern"
response <- GET(paste0("https://www.fuzzwork.co.uk/api/typeid2.php?typename=", ships))
type_ids <- fromJSON(content(response, "text", encoding = "utf-8"))
type_ids <- sort(as.numeric(type_ids$typeID))

kill_api <- paste0("https://zkillboard.com/api/kills/shipID/", paste(type_ids, collapse = ","))
i <- 1
all_attackers <- data.frame()
while(!any(grepl("2016", kills_by_supers$killTime))) {
  WHAT_yEAR_IS_IT <- paste0(paste(kill_api, "page", i, sep = "/"), "/")
  response <- GET(WHAT_yEAR_IS_IT)
  kills_by_supers <- fromJSON(content(response, "text", encoding = "utf-8"))
  attackers <- data.table::rbindlist(kills_by_supers$attackers) %>% filter(shipTypeID %in% type_ids) %>% distinct()
  all_attackers <- rbind(all_attackers, attackers)
  print(paste0("Fetching supercarrier kills. i=", i))
  i <- i + 1
  Sys.sleep(1)
}
all_attackers <- all_attackers %>% distinct()
save(all_attackers, file = "super_attackers.Rda")

super_pilots <- all_attackers %>% select(characterName, corporationName, allianceName, shipTypeID) %>% distinct()
super_pilots$coalition <- NA
super_pilots[which(super_pilots$allianceName %in% c("Goonswarm Federation","Tactical Narcotics Team","The Bastion","Get Off My Lawn","The Initiative.","Brothers in Arms Alliance")),]$coalition <- "Imperium"
super_pilots[which(super_pilots$allianceName %in% c("Circle-Of-Two","Test Alliance Please Ignore","Brave Collective")),]$coalition <- "Legacy"
super_pilots[which(super_pilots$allianceName %in% c("Pandemic Legion","Northern Coalition.","WAFFLES.","Pandemic Horde","PURPLE HELMETED WARRIORS")),]$coalition <- "PanFam"
super_pilots[which(super_pilots$allianceName %in% c("Project.Mayhem.","Snuffed Out")),]$coalition <- "ProjectBox"
super_pilots[which(super_pilots$allianceName %in% c("The-Culture")),]$coalition <- "The-Culture"

super_pilots[which(is.na(super_pilots$coalition)),]$coalition <- "Unaffiliated"

super_pilot_count <- super_pilots %>% group_by(coalition) %>% summarise(super_count = n()) %>% arrange(desc(super_count))
super_pilots_by_corp <- super_pilots %>% group_by(corporationName,allianceName) %>% summarise(super_count = n()) %>% arrange(desc(super_count))

