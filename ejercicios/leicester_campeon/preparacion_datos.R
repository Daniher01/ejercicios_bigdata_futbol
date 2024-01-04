if(!require(StatsBombR)) devtools::install_github("statsbomb/StatsBombR")
library(StatsBombR)
library(dplyr)

competitions <- FreeCompetitions()

premier <- competitions %>% 
  filter(competition_id == 2 & season_name == "2015/2016")

premier_games = FreeMatches(premier)

premier_events <- free_allevents(MatchesDF = premier_games)

premier_events_cleaned <- allclean(premier_events)


# Se agregan las medidas en metros de las coordenadas de la cancha

max_x_source <- 120
max_y_source <- 80
max_x_final <- 110 # 120 yardas equivalen aprox. 110 metros
max_y_final <- 73 # 80 yardas equivalen aprox. 73 metros

premier_events_cleaned <- premier_events_cleaned %>%
  mutate(pos_x_meter = location.x/max_x_source*max_x_final,
         pos_y_meter = location.y/max_y_source*max_y_final,
         pos_y_meter = 73 - pos_y_meter,
         pass_end_pos_x_meter = pass.end_location.x/max_x_source*max_x_final,
         pass_end_pos_y_meter = pass.end_location.y/max_y_source*max_y_final,
         pass_end_pos_y_meter = 73 - pass_end_pos_y_meter,
         carry_end_pos_x_meter = carry.end_location.x/max_x_source*max_x_final,
         carry_end_pos_y_meter = carry.end_location.y/max_y_source*max_y_final,
         carry_end_pos_y_meter = 73 - carry_end_pos_y_meter)

url = "images/escudos_premier/"

premier_games = premier_games %>% mutate(logo_team_home = case_when(
  home_team.home_team_name == "AFC Bournemouth" ~ paste0(url, "bournemouth.png"),
  home_team.home_team_name == "Arsenal" ~ paste0(url, "arsenal.png"),
  home_team.home_team_name == "Aston Villa" ~ paste0(url, "astonvilla.png"),
  home_team.home_team_name == "Chelsea" ~ paste0(url, "chelsea.png"),
  home_team.home_team_name == "Crystal Palace" ~ paste0(url, "crystalpalace.png"),
  home_team.home_team_name == "Everton" ~ paste0(url, "everton.png"),
  home_team.home_team_name == "Leicester City" ~ paste0(url, "leicester.png"),
  home_team.home_team_name == "Liverpool" ~ paste0(url, "liverpool.png"),
  home_team.home_team_name == "Manchester City" ~ paste0(url, "manchestercity.png"),
  home_team.home_team_name == "Manchester United" ~ paste0(url, "manchesterunited.png"),
  home_team.home_team_name == "Newcastle United" ~ paste0(url, "newcastle.png"),
  home_team.home_team_name == "Norwich City" ~ paste0(url, "norwich.png"),
  home_team.home_team_name == "Southampton" ~ paste0(url, "southampton.png"),
  home_team.home_team_name == "Stoke City" ~ paste0(url, "stoke_city.png"),
  home_team.home_team_name == "Sunderland" ~ paste0(url, "sunderland.png"),
  home_team.home_team_name == "Swansea City" ~ paste0(url, "swansea_city.png"),
  home_team.home_team_name == "Tottenham Hotspur" ~ paste0(url, "tottenham.png"),
  home_team.home_team_name == "Watford" ~ paste0(url, "watford.png"),
  home_team.home_team_name == "West Bromwich Albion" ~ paste0(url, "westbrownwichalbion.png"),
  home_team.home_team_name == "West Ham United" ~ paste0(url, "westham.png")
))
  


# Exportar/Guardar datos en CSV
library(readr)
write_csv(premier_events_cleaned, "data/statsbomb_premier_15_16_events.csv")
write_csv(premier_games, "data/statsbomb_premier_15_16_games.csv")


