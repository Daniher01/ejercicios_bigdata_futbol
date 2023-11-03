library(readr)
library(janitor)
library(dplyr)

# leer los datos
liga_15_16 = read_csv('data/statsbomb_ liga_15_16 _events.csv') %>% clean_names()

liga_15_16_games = read_csv('data/statsbomb_ liga_15_16 _games.csv') %>% clean_names()


# filtrar los tiros no bloqueados y que no sean de penalti, con las columnas seleccionadas
target_shots = liga_15_16 %>%
              filter(type_name == 'Shot' &
                     shot_outcome_name != 'Blocked' &
                     shot_type_name != 'Penalty')  %>% 
              select(match_id, team = team_name, type_name, shot_type_name, 
                     outcome = shot_outcome_name, xg = shot_statsbomb_xg)

# obtener el xG total por juego
xg_game = target_shots %>% 
          group_by(match_id) %>% 
          summarise(total_xg = sum(xg, na.rm = T))

# obtener el xG de cada equipo por juego
xg_team_game = target_shots %>% 
              group_by(match_id, team) %>% 
              summarise(xg_for = sum(xg, na.rm = T),
                      games_played = length(unique(match_id)))

# obtener el xG en contra de cada equipo por juego uniendo las tablas y calculando
# el xG total menos el xG a favor
all_stats_team_game = xg_game %>% 
                      left_join(xg_team_game, by = "match_id") %>% 
                      mutate(xg_against = total_xg - xg_for)

# obtener los valores finales por equipo
team_stats = all_stats_team_game %>% 
              group_by(team) %>% 
              summarise(across(c(games_played, xg_for, xg_against), ~sum(.x))) %>% 
              mutate(xg_dif = xg_for - xg_against,
                     avg_xg_for_per_game = round(xg_for/games_played, 2),
                     avg_xg_against_per_game = round(xg_against/games_played, 2)) %>% 
              arrange(desc(xg_dif))

# guardar datos calculados
write_csv(team_stats, 'ejercicios/rendimiento de equipos por su xG/liga_2015_2016.csv') 
