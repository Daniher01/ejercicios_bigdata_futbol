library(readr)
library(janitor)
library(dplyr)
library(jsonlite)


# leer los datos
liga_23_24 = read_delim('data/understat_liga_23_24_games.csv', delim = ';') %>% clean_names()
liga_23_24 <- rename(liga_23_24, team = title)

# REAJUSTAR PPDA

# Reemplazar comillas simples con comillas dobles
liga_23_24$ppda <- gsub("'", '"', liga_23_24$ppda)
liga_23_24$ppda_allowed <- gsub("'", '"', liga_23_24$ppda_allowed)

# Convertir cadenas JSON a listas
ppda_lista <- lapply(liga_23_24$ppda, fromJSON)
ppda_allowed_lista <- lapply(liga_23_24$ppda_allowed, fromJSON)

# Extraer valores de "PPDA"
att_ppda <- sapply(ppda_lista, function(x) x$att)
def_ppda <- sapply(ppda_lista, function(x) x$def)

att_ppda_allowed <- sapply(ppda_allowed_lista, function(x) x$att)
def_ppda_allowed <- sapply(ppda_allowed_lista, function(x) x$def)

liga_23_24 = liga_23_24 %>%
              mutate(ppda = att_ppda/def_ppda,
                     ppda_allowed = att_ppda_allowed/def_ppda_allowed)

# GRAFICA xG a favor y xG en contra
team_stats_liga = liga_23_24 %>%
          group_by(team) %>%
          summarise(total_xg = sum(npx_g),
                    total_xg_a = sum(npx_ga),
                    goals = sum(scored),
                    goals_againts = sum(missed),
                    ppda_mean = mean(ppda),
                    ppda_allowed_mean = mean(ppda_allowed),
                    ocasiones_gol = mean(deep),
                    ocaciones_gol_against = mean(deep_allowed),
                    wins = sum(wins),
                    draws = sum(draws),
                    loses = sum(loses),
                    avg_goals_for_per_game = mean(scored),
                    avg_xg_for_per_game = mean(npx_g),
                    avg_xg_against_per_game = mean(npx_ga))

write_csv(team_stats_liga, 'ejercicios/rendimiento Girona liga 23 24/stats_teams.csv') 


            