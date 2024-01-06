#install.packages("tidyverse")

library(dplyr)
library(readr)
library(janitor)
library(stringr)
library(tidyverse)

games = read_csv("data/statsbomb_premier_15_16_games.csv") %>% clean_names()

events = read_csv("data/statsbomb_premier_15_16_events.csv") %>% clean_names()  

events = events %>%
  mutate(zone_x = case_when(pos_x_meter < 110/6 ~ 1,
                          pos_x_meter >= 110/6 & pos_x_meter < 110/6*2 ~ 2,
                          pos_x_meter >= 110/6*2 & pos_x_meter < 110/6*3 ~ 3,
                          pos_x_meter >= 110/6*3 & pos_x_meter < 110/6*4 ~ 4,
                          pos_x_meter >= 110/6*4 & pos_x_meter < 110/6*5 ~ 5,
                          pos_x_meter >= 110/6*5 ~ 6),
         zone_y = case_when(pos_y_meter < 73/3 ~ 1,
                            pos_y_meter >= 73/3 & pos_y_meter < 73/3*2 ~ 2,
                            pos_y_meter >= 73/3*2 & pos_y_meter < 73/3*3 ~ 3),
         zone_x_pass_end = ifelse(!is.na(pass_end_pos_x_meter),
                                  case_when(pass_end_pos_x_meter < 110/6 ~ 1,
                                            pass_end_pos_x_meter >= 110/6 & pass_end_pos_x_meter < 110/6*2 ~ 2,
                                            pass_end_pos_x_meter >= 110/6*2 & pass_end_pos_x_meter < 110/6*3 ~ 3,
                                            pass_end_pos_x_meter >= 110/6*3 & pass_end_pos_x_meter < 110/6*4 ~ 4,
                                            pass_end_pos_x_meter >= 110/6*4 & pass_end_pos_x_meter < 110/6*5 ~ 5,
                                            pass_end_pos_x_meter >= 110/6*5 ~ 6), 
                                  0),
         zone_y_pass_end = ifelse(!is.na(pass_end_pos_y_meter),
                                  case_when(pass_end_pos_y_meter < 73/3 ~ 1,
                                            pass_end_pos_y_meter >= 73/3 & pass_end_pos_y_meter < 73/3*2 ~ 2,
                                            pass_end_pos_y_meter >= 73/3*2 & pass_end_pos_y_meter < 73/3*3 ~ 3),
                                   0))

premier_events_goals = events %>%
  mutate(is_goal = ifelse(is.na(shot_outcome_name) | shot_outcome_name != "Goal", 0, 1),
         is_own_goal_for = ifelse(type_name == "Own Goal For", 1, 0))

goles_stats = premier_events_goals %>%
  left_join(games %>% select(match_id, home_team = home_team_home_team_name, away_team = away_team_away_team_name),
            by = "match_id") %>%
  group_by(match_id) %>% 
  mutate(home_team_score = cumsum(ifelse(team_name == home_team & (is_goal == 1 | is_own_goal_for == 1), 1, 0)),
         away_team_score = cumsum(ifelse(team_name == away_team & (is_goal == 1 | is_own_goal_for == 1), 1, 0)))

events = goles_stats %>%
  mutate(contexto = case_when((team_name == home_team & home_team_score > away_team_score) |
                                              (team_name == away_team & home_team_score < away_team_score) ~ "ganando",
                                            
                                            (team_name == home_team & home_team_score < away_team_score) |
                                              (team_name == away_team & home_team_score > away_team_score) ~ "perdiendo",
                                            
                                            T ~ "empatando"))

# minutos jugados por jugador
minutos_jugados <- events %>%
  filter(!is.na(player_name)) %>%
  group_by(match_id, player_name) %>%
  summarise(max_time = max(elapsed_time, na.rm = T)) %>%
  group_by(player_name) %>%
  summarise(minutos_totales = as.numeric(round(sum(max_time)/60, 1))) 

TEAM = "Leicester City"

# relacion xG - goles

xG = events %>%
  filter(!is.na(shot_statsbomb_xg)) %>%
  group_by(team_name) %>%
  summarise(xg = round(sum(shot_statsbomb_xg), 2))

goles = events %>%
  filter(shot_outcome_name == "Goal") %>%
  group_by(team_name) %>%
  summarise(goles = n())


# ---------- Calcular el xA
xGA_process = events %>%
  filter(type_name=="Shot") %>% #1
  select(shot_key_pass_id, xA = shot_statsbomb_xg) #2

xA = inner_join(events, xGA_process, by = c("id" = "shot_key_pass_id")) %>% #3
  filter(pass_shot_assist==TRUE | pass_goal_assist==TRUE) %>%
  mutate(across(pass_goal_assist, ~replace(.x, is.na(.x), FALSE)),
         across(pass_shot_assist, ~replace(.x, is.na(.x), FALSE))) %>% 
  group_by(team_name) %>%
  summarise(xA = round(sum(xA), 2))


# ----------- obtener goles y xG en contra
events_and_games = events %>%
  select(match_id, team_name, type_name, shot_outcome_name, shot_statsbomb_xg) %>%
  filter(!is.na(shot_statsbomb_xg)) %>%
  left_join(games, select(match_id,  home_team_home_team_name, away_team_away_team_name, home_score, away_score), by = "match_id") %>%
  mutate(opposition_team = ifelse(team_name == home_team_home_team_name, away_team_away_team_name, home_team_home_team_name))
  
goles_en_contra = events_and_games %>%
  filter(shot_outcome_name == "Goal") %>%
  group_by(team_name = opposition_team) %>%
  summarise(goles_contra = n())

xg_contra = events_and_games %>%
  group_by(team_name = opposition_team) %>%
  summarise(xg_contra = round(sum(shot_statsbomb_xg), 2))

# -------------- unir la data de cada equipo
team_data = games %>% 
  select(team =  home_team_home_team_name, logo = logo_team_home) 
team_data = unique(team_data)

team_data = team_data %>% 
  left_join(goles, by = c("team" = "team_name")) %>%
  left_join(xG, by = c("team" = "team_name")) %>%
  left_join(xA, by = c("team" = "team_name")) %>%
  left_join(goles_en_contra, by = c("team" = "team_name")) %>%
  left_join(xg_contra, by = c("team" = "team_name")) %>%
  mutate(ratio_of = round(goles/xg, 2),
         ratio_def = round(goles_contra/xg_contra, 2))


write_csv(team_data, "data/teams_data_premier_15_16.csv")

# ------------- shotmap equipo
shots = events %>%
  filter(team_name == TEAM, type_name == "Shot") %>%
  select(team_name, player_name, shot_statsbomb_xg, play_pattern_name, shot_outcome_name, shot_body_part_name, pos_x_meter, pos_y_meter) %>%
  mutate(shot_statsbomb_xg = round(shot_statsbomb_xg, 2))

write_csv(shots, "data/shots_leicester.csv")

# ---------- mapa de xA de jugador con mayot xA
xA_team = inner_join(events, xGA_process, by = c("id" = "shot_key_pass_id")) %>% #3
  filter(pass_shot_assist==TRUE | pass_goal_assist==TRUE, team_name == TEAM) %>%
  mutate(across(pass_goal_assist, ~replace(.x, is.na(.x), FALSE)),
         across(pass_shot_assist, ~replace(.x, is.na(.x), FALSE)))

xA_player = xA_team  %>% 
  left_join(minutos_jugados, by = "player_name") %>%
  mutate(xa_p90 = round(xA/minutos_totales*90, 2)) %>%
  group_by(player_name) %>%
  summarise(xa_p90 = round(sum(xa_p90), 2)) %>%
  arrange(desc(xa_p90))

xa_player_events = xA_team %>%
  left_join(xA_player, by = "player_name") %>%
  filter(player_name == "Riyad Mahrez") %>%
  select(player_name, xa_p90, xA,  pos_x_meter, pos_y_meter, pass_end_pos_x_meter, pass_end_pos_y_meter, pass_shot_assist, pass_goal_assist)


write_csv(xa_player_events, "data/key_passes_mahrez_15_16.csv")

# ------------------ pases del arqueros premier
pases_gk = events %>%
  filter(type_name == "Pass", position_name == "Goalkeeper") %>%
  mutate(pass_complete = ifelse(is.na(pass_outcome_name), TRUE, FALSE),
         pass_complete_count = ifelse(pass_complete == TRUE, 1, 0)) %>%
  group_by(team_name, zone_x_pass_end, zone_y_pass_end) %>%
  summarise(cantidad = n(),
            pass_complete = sum(pass_complete_count),
            percent_complete_zone = round((pass_complete/cantidad)*100, 2))


write_csv(pases_gk, "data/gk_passes_premier_15_16.csv")
  
  
# ------------ tiros de corner premier
  
corner = inner_join(events, xGA_process, by = c("id" = "shot_key_pass_id")) %>% #3
  filter(play_pattern_name == "From Corner", type_name == "Pass") %>%
  mutate(across(pass_goal_assist, ~replace(.x, is.na(.x), FALSE)),
         across(pass_shot_assist, ~replace(.x, is.na(.x), FALSE)),
         assists_count = ifelse(pass_goal_assist == TRUE, 1, 0)) %>% 
  group_by(team_name, zone_y_pass_end) %>%
  summarise(frecuencia = n(),
            xA = round(mean(xA), 2),
            assists = sum(assists_count))

write_csv(corner, "data/corners_premier_15_16.csv")

# -------------- zonas de presión 

# Calcular el total de presiones de presión por equipo y  zona
pressures = events %>%
  filter(type_name == "Pressure") %>%
  group_by(team_name, zone_x, zone_y ) %>%
  summarise(presion = n())

write_csv(pressures, "data/pressures_premier_15_16.csv")

pressures_context_team = events %>%
  filter(type_name == "Pressure", team_name == TEAM) %>%
  group_by(team_name, zone_x, contexto ) %>%
  summarise(presion = n())

write_csv(pressures_context_team, "data/pressures_licester_context_premier_15_16.csv")


# ---------- zonas de pases 
pases_recepciones_precisas_team = events %>%
  filter((type_name == "Pass" & is.na(pass_outcome_name) | 
                              (type_name == "Ball Receipt*" & is.na(ball_receipt_outcome_name)))) %>%
  mutate(time_in_poss = ifelse(time_in_poss > 200, 200, time_in_poss)) %>%  # corrige errores en los datos
  group_by(team = possession_team_name, possession, match_id, contexto) %>%
  summarise(n_pass = n(),
            poss_time = max(time_in_poss))

poss_stats_state = pases_recepciones_precisas_team %>%
  group_by(team, match_id, contexto) %>%
  summarise(n_poss = n(),
            total_pass = sum(n_pass),
            total_poss_time_min = sum(poss_time)/60)

poss_stats_state_full = poss_stats_state %>% 
  left_join(poss_stats_state %>% 
              select(match_id, opp_team = team, opp_total_poss_time_min = total_poss_time_min, 
                     opp_score_state = contexto), 
            by = c("match_id")) %>% 
  filter(team != opp_team &
           ((opp_score_state == "empatando" & contexto  == "empatando") | 
              (opp_score_state == "ganando" & contexto  == "perdiendo") | 
              (opp_score_state == "perdiendo" & contexto  == "ganando"))) %>%
  mutate(tiempo_efectivo_juego = total_poss_time_min + opp_total_poss_time_min,
         poss_percent = total_poss_time_min/tiempo_efectivo_juego*100)

average_poss_time_state = poss_stats_state_full %>% 
  group_by(team, contexto) %>% 
  summarise(tiempo_efectivo_juego = sum(tiempo_efectivo_juego),
            total_poss_time_min = sum(total_poss_time_min),
            poss_percent = total_poss_time_min/tiempo_efectivo_juego*100) %>% 
  arrange(team, desc(poss_percent))

  
write_csv(average_poss_time_state, "data/tiempo_posesion_contexto_licester_context_premier_15_16.csv")

# ---------------- jugadores con jugadas que tuvieron al menos un tiro

sequences_with_shots = events %>%
  group_by(team_name, match_id, possession) %>% 
  summarise(actions = list(type_name),
            players = list(unique(player_name)),
            xg = sum(shot_statsbomb_xg, na.rm = T)) %>%
  ungroup() %>%   
  filter(str_detect(actions, "Shot")) %>%  # opción 1
  filter(xg > 0)   

player_seqs_shot = sequences_with_shots %>% 
  select(players) %>% 
  unlist() %>% 
  table() %>% 
  as_data_frame() %>% 
  rename("player_name" = ".", "n_seqs_shot" = "n") %>% 
  arrange(desc(n_seqs_shot))

player_team = events %>%
  group_by(player_name , player_id) %>%
  summarise(team = unique(team_name))

player_team_stats = player_seqs_shot %>%
  left_join(player_team, by = "player_name") %>%
  filter(team == TEAM) %>%
  arrange(desc(n_seqs_shot))

write_csv(player_team_stats, "data/sequencia_jugadas_tiros_licester_premier_15_16.csv")

# ---------------- jugador con mas pases progresivos

pases_progresivos <- events %>%
  mutate(progressive_pass = ifelse(type_name == "Pass" & 
                                     (110 - pass_end_pos_x_meter)/(110 - pos_x_meter) <= 0.75, "Yes", "No"),
         complete_prog_pass = ifelse(is.na(pass_outcome_name), "Yes", "No")) %>%
  filter(progressive_pass == "Yes") %>%
  group_by(player_name) %>%
  summarise(n = n(),
            n_complete = sum(ifelse(complete_prog_pass == "Yes", 1, 0)),
            n_incomplete = n - n_complete,
            accuracy = round(n_complete/n*100, 1)) %>%
  arrange(desc(accuracy)) %>%
  filter(n >= 50)

pases_progresivos_team = pases_progresivos %>%
  left_join(player_team, by = "player_name") %>%
  filter(team == TEAM)

pases_progresivos_player = events %>%
  mutate(progressive_pass = ifelse(type_name == "Pass" & 
                                     (110 - pass_end_pos_x_meter)/(110 - pos_x_meter)  <= 0.75, 
                                   "Yes", "No"),
         complete_prog_pass = ifelse(is.na(pass_outcome_name), "Sí", "No")) %>%
  filter(progressive_pass == "Yes" & player_name == "Shinji Okazaki")

write_csv(pases_progresivos_player, "data/pases_progresivos_player_licester_premier_15_16.csv")

# ------------ jugador con más xG y de quien recibio asistencias

shot_map_team = events %>%
  filter(type_name == "Shot", shot_outcome_name != "Blocked", team_name == TEAM) %>%
  group_by(player_name) %>%
  summarise(xG = sum(shot_statsbomb_xg)) %>%
  arrange(desc(xG))

shot_map_player = events %>%
  filter(type_name == "Shot", shot_outcome_name != "Blocked", player_name == "Jamie Vardy") %>%
  select(player_name, shot_outcome_name, shot_technique_name, shot_body_part_name, shot_statsbomb_xg, pos_x_meter, pos_y_meter)

write_csv(shot_map_player, "data/shotmap_vardy_licester_premier_15_16.csv")
  

