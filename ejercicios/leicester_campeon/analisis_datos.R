library(dplyr)
library(readr)
library(janitor)
library(stringr)

games = read_csv("data/statsbomb_premier_15_16_games.csv") %>% clean_names()

events = read_csv("data/statsbomb_premier_15_16_events.csv") %>% clean_names()  

TEAM = "Leicester City"

# relacion xG - goles

xG = events %>%
  filter(!is.na(shot_statsbomb_xg)) %>%
  group_by(team_name) %>%
  summarise(xG = round(sum(shot_statsbomb_xg), 2))

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
  left_join(xg_contra, by = c("team" = "team_name"))


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
  group_by(player_name) %>%
  summarise(xA = round(sum(xA), 2)) %>%
  arrange(desc(xA))

xa_player_events = xA_team %>%
  filter(player_name == "Riyad Mahrez") %>%
  select(player_name, xA,  pos_x_meter, pos_y_meter, pass_end_pos_x_meter, pass_end_pos_y_meter, pass_shot_assist, pass_goal_assist)

write_csv(xa_player_events, "data/key_passes_mahrez_15_16.csv")

# ------------------ pases del arqueros premier
pases_gk = events %>%
  filter(type_name == "Pass", position_name == "Goalkeeper") %>%
  select(player_name, team_name,  pos_x_meter, pos_y_meter, pass_end_pos_x_meter, pass_end_pos_y_meter, pass_outcome_name) %>%
  arrange(team_name)

write_csv(pases_gk, "data/gk_passes_premier_15_16.csv")
  
  
# ------------ tiros de corner premier

corner = events %>%
  filter(play_pattern_name == "From Corner")
  