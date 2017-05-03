library(httr)
library(jsonlite)

response <- GET("https://zkillboard.com/intel/supers/")
supers <- fromJSON(content(response, "text", encoding = "utf-8"))

character_ids <- as.list(supers$titans$data$characterID)
corporations_titans <- lapply(character_ids, function(character_id) {
	response <- GET(paste0("https://crest-tq.eveonline.com/characters/", character_id, "/"))
	character <- fromJSON(content(response, "text", encoding = "utf-8"))
	return(character$corporation$name)
})

character_ids <- as.list(supers$supercarriers$data$characterID)
corporations_supers <- lapply(character_ids, function(character_id) {
	response <- GET(paste0("https://crest-tq.eveonline.com/characters/", character_id, "/"))
	character <- fromJSON(content(response, "text", encoding = "utf-8"))
	return(character$corporation$name)
})

# TODO: some rudimentary analysis
