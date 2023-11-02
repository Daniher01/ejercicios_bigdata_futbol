# Usar este archivo como carga de datos de statsbomb

devtools::install_github("statsbomb/SDMTools") # si no estan los datos de statsbombs

library(devtools)
library(StatsBombR)
library(readr)

# Obtención de datos
competitions <- FreeCompetitions()

# funcion para obtener los datos de la competicion
process_and_save_data <- function(competition_id_input, season_name_input, data = competitions) {

  # extraer y transformar los datos
  competition <- data %>% 
    filter(competition_id == competition_id_input & season_name == season_name_input)
  
  competition_games <- FreeMatches(competition)
  
  competition_events <- free_allevents(MatchesDF = competition_games)
  
  competition_events_cleaned <- allclean(competition_events)
  
  # guardar los datos
  competition_name = gsub(" ", "_",competition$competition_name)
  competition_season = gsub(" ", "",competition$season_name)
  
  nombre_archivo_1 <- paste("data/statsbomb_",tolower(competition_name),"_",competition_season,"_events.csv")
  write_csv(competition_events_cleaned, nombre_archivo_1)
  
  nombre_archivo_2 <- paste("data/statsbomb_",tolower(competition_name),"_",competition_season,"_games.csv")
  write_csv(competition_games, nombre_archivo_2)  
}


# AGREGAR COMPETICIONES A OBTENER
process_and_save_data(43, 2022)
