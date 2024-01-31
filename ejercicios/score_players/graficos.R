# cargar las librerias
library(janitor)


players_score = read.csv("ejercicios/score_players/score_F.csv", colClasses = c("position" = "character")) %>% clean_names()

# para metricas p90
metricas_p90 = players_score %>% select(ends_with("p90")) %>% names()

players_p90_long = players_score %>% 
  pivot_longer(cols = metricas_p90, names_to = "metric", values_to = "p90")

# para metricas percentiles 
metricas_percentil = players_score %>% select(ends_with("percentil")) %>% names()

players_percentil_long = players_score %>% 
  pivot_longer(cols = metricas_percentil, names_to = "metric", values_to = "percentil")
