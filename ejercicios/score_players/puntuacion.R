### CARGAR LOS DATOS
library(readxl)
library(janitor)
library(stringr)
library(tidyr)
stats_premier = read_xlsx('data/players_stats_season_21_22_england_premier_league.xlsx') %>% clean_names()

columnas_de_texto = c("player_num", "player_name", "position", "nationality", "team", "national_team", 
                      "foot", "national_team_last_match_date_mm_yy", "youth_national_team_last_match_date_mm_yy")

otras_columnas = c("minutes_played", "age", "weight", "height", "matches_played", "in_stat_index",
                             "starting_lineup_appearances", "substitute_out", "substitutes_in")
## EDA
# limpiar los datos
premier_clean =  stats_premier %>%
  mutate(across(everything(), ~replace_na(.x, 0))) %>%
  mutate(across(c(ends_with("percent"), "chances_percent_of_conversion"), ~as.numeric(str_replace(.x, "%", "")))) %>%
  mutate(across(-columnas_de_texto, ~as.numeric(str_replace(.x, "-", "0")))) %>%
  # agregar metricas que hagan falta
  mutate(xg_diff = round(goals-x_g_expected_goals,2),
         defensive_challenges_won_percent = (defensive_challenges_won/defensive_challenges)*100)

# pasar los datos a p90
stats_p90 = premier_clean %>%
  mutate(across(-c(columnas_de_texto, otras_columnas),~(as.numeric(.x)/minutes_played*90), .names = "{.col}_p90")) %>%
  select(columnas_de_texto, otras_columnas, ends_with("p90"))

# minimo de minutos jugados
MIN_MINUTOS = max(stats_premier$minutes_played)*0.3

# obtener el percetil de los datos
stats_percentil = stats_p90 %>%
  filter(minutes_played > MIN_MINUTOS) %>%
  group_by(position) %>%
  mutate(across(ends_with("p90"), ~round(percent_rank(.x),2), .names = "{col}_percentil"),
         # las metricas "negativas" defensivas se cambian a 1-variable
         fouls_p90_percentil = 1-fouls_p90_percentil)

names(stats_percentil)

### TABLA CON METRICAS SEGUN MODELO DE JUEGO
# DEFENSA CENTRAL
defensa_central <- list(c("CD", "air_challenges_won_percent_p90_p90_percentil", 0.4),
                        c("CD", "defensive_challenges_won_percent_p90_percentil", 0.3),
                        c("CD", "accurate_passes_percent_p90_percentil", 0.1),
                        c("CD", "accurate_crosses_percent_p90_percentil", 0.1),
                        c("CD", "fouls_p90_percentil", 0.1))

# LATERALES
laterales <- list(c("RD", "accurate_crosses_percent_p90_percentil", 0.4),
                  c("RD", "defensive_challenges_won_percent_p90_percentil", 0.3),
                  c("RD", "challenges_in_attack_won_percent_p90", 0.2),
                  c("RD", "expected_assists_p90_percentil", 0.1),
                  c("LD", "accurate_crosses_percent_p90_percentil", 0.4),
                  c("LD", "defensive_challenges_won_percent_p90_percentil", 0.3),
                  c("LD", "challenges_in_attack_won_percent_p90", 0.2),
                  c("LD", "expected_assists_p90_percentil", 0.1))

# VOLANTE CENTRAL
volante_central <- list(c("DM", "key_passes_accurate_p90_percentil", 0.35),
                        c("DM", "defensive_challenges_won_p90_percentil", 0.25),
                        c("DM", "accurate_crosses_percent_p90_percentil", 0.2),
                        c("DM", "ball_interceptions_p90_percentil", 0.1),
                        c("DM", "x_g_expected_goals_p90_percentil", 0.1))

# VOLANTE INTERIOR
voalante_interior <- list(c("CM", "key_passes_accurate_p90_percentil", 0.3),
                          c("CM", "ball_interceptions_p90_percentil", 0.2),
                          c("CM", "expected_assists_p90_percentil", 0.2),
                          c("CM", "defensive_challenges_won_p90_percentil", 0.15),
                          c("CM", "x_g_expected_goals_p90_percentil", 0.15))

# EXTREMO
extremo <- list(c("LM", "challenges_won_percent_p90_percentil", 0.3),
                c("LM", "accurate_crosses_percent_p90_percentil", 0.3),
                c("LM", "x_g_expected_goals_p90_percentil", 0.15),
                c("LM", "expected_assists_p90_percentil", 0.15),
                c("LM", "defensive_challenges_won_p90_percentil", 0.05),
                c("LM", "ball_interceptions_p90_percentil", 0.05),
                c("RM", "challenges_won_percent_p90_percentil", 0.3),
                c("RM", "accurate_crosses_percent_p90_percentil", 0.3),
                c("RM", "x_g_expected_goals_p90_percentil", 0.15),
                c("RM", "expected_assists_p90_percentil", 0.15),
                c("RM", "defensive_challenges_won_p90_percentil", 0.05),
                c("RM", "ball_interceptions_p90_percentil", 0.05))

# DELANTERO CENTRO
delantero_centro <- list(c("F", "xg_diff_p90_percentil", 0.25),
                         c("F", "shots_on_target_percent_p90_percentil", 0.25),
                         c("F", "air_challenges_won_percent_p90_percentil", 0.25),
                         c("F", "expected_assists_p90_percentil", 0.15),
                         c("F", "defensive_challenges_won_p90_percentil", 0.05),
                         c("F", "ball_interceptions_p90_percentil", 0.05))

modelo_juego <- data.frame(posicion = c(sapply(defensa_central, "[[", 1), sapply(laterales, "[[", 1), sapply(volante_central, "[[", 1), sapply(voalante_interior, "[[", 1), sapply(extremo, "[[", 1), sapply(delantero_centro, "[[", 1)),
                           metrica = c(sapply(defensa_central, "[[", 2), sapply(laterales, "[[", 2), sapply(volante_central, "[[", 2), sapply(voalante_interior, "[[", 2), sapply(extremo, "[[", 2), sapply(delantero_centro, "[[", 2)),
                           valor = c(sapply(defensa_central, "[[", 3), sapply(laterales, "[[", 3), sapply(volante_central, "[[", 3), sapply(voalante_interior, "[[", 3), sapply(extremo, "[[", 3), sapply(delantero_centro, "[[", 3)))

### AGREGAR PUNTAJE A CADA JUGADOR SEUGN LAS METRICAS DE SU POSICION
## BUSCAR PUNTAJE PARA DELANTERO
posicion_target = "F"

metricas_score = modelo_juego %>% filter(posicion == posicion_target)

metricas_score_rebind = pivot_wider(metricas_score, names_from = metrica, names_glue = "{metrica}_valor", values_from = valor)

score_delantero = stats_percentil %>% 
  filter(position == posicion_target) %>% 
  select(player_name, metricas_score$metrica)

metrica_with_valor <- merge(score_delantero, metricas_score_rebind, all = TRUE)

metrica_with_valor = metrica_with_valor %>%
  select(ends_with("_percentil"), ends_with("_valor")) %>%
  # Cree una nueva columna que contenga el resultado de la multiplicación
  mutate(across(ends_with("_percentil"), ~ as.numeric(.x) * as.numeric(get(paste0(cur_column(), "_valor"))), .names = "{.col}_x_{str_replace(.col, '_percentil', '_ponderada')}"))




