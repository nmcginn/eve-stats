library(httr)
library(jsonlite)
library(dplyr)

# get type ids
ships <- "Avatar|Erebus|Leviathan|Molok|Ragnarok|Vanquisher"
response <- GET(paste0("https://www.fuzzwork.co.uk/api/typeid2.php?typename=", ships))
type_ids <- fromJSON(content(response, "text", encoding = "utf-8"))
type_ids <- sort(as.numeric(type_ids$typeID))

kill_api <- paste0("https://zkillboard.com/api/kills/shipID/", paste(type_ids, collapse = ","))
i <- 1
all_attackers <- data.frame()
while(!any(grepl("2016", kills_by_titans$killTime))) {
  WHAT_yEAR_IS_IT <- paste0(paste(kill_api, "page", i, sep = "/"), "/")
  response <- GET(WHAT_yEAR_IS_IT)
  kills_by_titans <- fromJSON(content(response, "text", encoding = "utf-8"))
  attackers <- data.table::rbindlist(kills_by_titans$attackers) %>% filter(shipTypeID %in% type_ids) %>% distinct()
  all_attackers <- rbind(all_attackers, attackers)
  print(paste0("Fetching titan kills. i=", i))
  i <- i + 1
  Sys.sleep(1)
}
all_attackers <- all_attackers %>% distinct()
save(all_attackers, file = "titan_attackers.Rda")

titan_pilots <- all_attackers %>% select(characterName, corporationName, allianceName, shipTypeID) %>% distinct()
titan_pilots$coalition <- NA
titan_pilots[which(titan_pilots$allianceName %in% c("Goonswarm Federation","Tactical Narcotics Team","The Bastion","Get Off My Lawn","The Initiative.","Brothers in Arms Alliance")),]$coalition <- "Imperium"
titan_pilots[which(titan_pilots$allianceName %in% c("Circle-Of-Two","Test Alliance Please Ignore","Brave Collective")),]$coalition <- "Legacy"
titan_pilots[which(titan_pilots$allianceName %in% c("Pandemic Legion","Northern Coalition.","WAFFLES.","Pandemic Horde","PURPLE HELMETED WARRIORS")),]$coalition <- "PanFam"
titan_pilots[which(titan_pilots$allianceName %in% c("Project.Mayhem.","Snuffed Out")),]$coalition <- "ProjectBox"
titan_pilots[which(titan_pilots$allianceName %in% c("The-Culture")),]$coalition <- "The-Culture"

titan_pilots[which(is.na(titan_pilots$coalition)),]$coalition <- "Unaffiliated"

titan_pilot_count <- titan_pilots %>% group_by(coalition) %>% summarise(titan_count = n()) %>% arrange(desc(titan_count))
titan_pilots_by_corp <- titan_pilots %>% group_by(corporationName,allianceName) %>% summarise(titan_count = n()) %>% arrange(desc(titan_count))

