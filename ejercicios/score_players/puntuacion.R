### CARGAR LOS DATOS
library(readxl)
library(janitor)
library(stringr)
library(tidyr)
library(dplyr)

# ------------------------------------------------------------------------------

### TABLA CON METRICAS SEGUN MODELO DE JUEGO
# DEFENSA CENTRAL
defensa_central <- list(c("CD", "air_challenges_won_percent", 0.4),
                        c("CD", "defensive_challenges_won_percent", 0.3),
                        c("CD", "accurate_passes_percent", 0.1),
                        c("CD", "accurate_crosses_percent", 0.1),
                        c("CD", "fouls", 0.1))

# LATERALES
laterales <- list(c("RD", "accurate_crosses_percent", 0.4),
                  c("RD", "defensive_challenges_won_percent", 0.3),
                  c("RD", "challenges_in_attack_won_percent", 0.2),
                  c("RD", "expected_assists", 0.1),
                  c("LD", "accurate_crosses_percent", 0.4),
                  c("LD", "defensive_challenges_won_percent", 0.3),
                  c("LD", "challenges_in_attack_won_percent", 0.2),
                  c("LD", "expected_assists", 0.1))

# VOLANTE CENTRAL
volante_central <- list(c("DM", "key_passes_accurate", 0.35),
                        c("DM", "defensive_challenges_won", 0.25),
                        c("DM", "accurate_crosses_percent", 0.2),
                        c("DM", "ball_interceptions", 0.1),
                        c("DM", "x_g_expected_goals", 0.1))

# VOLANTE INTERIOR
voalante_interior <- list(c("CM", "key_passes_accurate", 0.3),
                          c("CM", "ball_interceptions", 0.2),
                          c("CM", "expected_assists", 0.2),
                          c("CM", "defensive_challenges_won", 0.15),
                          c("CM", "x_g_expected_goals", 0.15))

# EXTREMO
extremo <- list(c("LM", "challenges_won_percent", 0.3),
                c("LM", "accurate_crosses_percent", 0.3),
                c("LM", "x_g_expected_goals", 0.15),
                c("LM", "expected_assists", 0.15),
                c("LM", "defensive_challenges_won", 0.05),
                c("LM", "ball_interceptions", 0.05),
                c("RM", "challenges_won_percent", 0.3),
                c("RM", "accurate_crosses_percent", 0.3),
                c("RM", "x_g_expected_goals", 0.15),
                c("RM", "expected_assists", 0.15),
                c("RM", "defensive_challenges_won", 0.05),
                c("RM", "ball_interceptions", 0.05))

# DELANTERO CENTRO
delantero_centro <- list(c("F", "xg_diff", 0.25),
                         c("F", "shots_on_target_percent", 0.25),
                         c("F", "air_challenges_won_percent", 0.25),
                         c("F", "expected_assists", 0.15),
                         c("F", "defensive_challenges_won", 0.05),
                         c("F", "ball_interceptions", 0.05))

modelo_juego <- data.frame(position = c(sapply(defensa_central, "[[", 1), sapply(laterales, "[[", 1), sapply(volante_central, "[[", 1), sapply(voalante_interior, "[[", 1), sapply(extremo, "[[", 1), sapply(delantero_centro, "[[", 1)),
                           metrica = c(sapply(defensa_central, "[[", 2), sapply(laterales, "[[", 2), sapply(volante_central, "[[", 2), sapply(voalante_interior, "[[", 2), sapply(extremo, "[[", 2), sapply(delantero_centro, "[[", 2)),
                           valor = c(sapply(defensa_central, "[[", 3), sapply(laterales, "[[", 3), sapply(volante_central, "[[", 3), sapply(voalante_interior, "[[", 3), sapply(extremo, "[[", 3), sapply(delantero_centro, "[[", 3)))


# ------------------------------------------------------------------------------

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
  mutate(across(-c(columnas_de_texto, otras_columnas),~round(as.numeric(.x)/minutes_played*90, 2), .names = "{.col}_p90")) %>%
  select(columnas_de_texto, otras_columnas, ends_with("p90"))


### APLICAR FILTROS de busqueda
MIN_MINUTOS = max(stats_premier$minutes_played)*0.3

### OBTENER PERCENTILES
stats_percentil = stats_p90 %>%
  filter(minutes_played > MIN_MINUTOS) %>% # aqui se aplican los filtros
  group_by(position) %>%
  mutate(across(ends_with("p90"), ~round(percent_rank(.x),2), .names = "{col}_percentil"),
         # las metricas "negativas" defensivas se cambian a 1-variable
         fouls_p90_percentil = 1-fouls_p90_percentil)



### AGREGAR PUNTAJE A CADA JUGADOR SEUGN LAS METRICAS DE SU POSICION

# buscar el valor de cada metrica
posicion_target = c("F")
metricas_valor = modelo_juego %>% filter(position %in% posicion_target)

metricas_valor_rbind <- pivot_wider(metricas_valor, names_from = metrica, names_glue = "{metrica}_valor", values_from = valor)
# buscar las metricas de cada delantero
score_player = stats_percentil %>% 
  filter(position %in% posicion_target) %>% 
  select(player_name, paste0(metricas_valor$metrica, "_p90_percentil"))

# unir las metricas con el valor de cada metrica
score_valor <- merge(score_player, metricas_valor_rbind, by = "position", all = TRUE)

### Formula para obtener el score
### elevar al cuadrado cada metrica
### sumar cada metrica ya elevada al cuadrado
### sacar la raiz cuadrada de esa suma total
### sqrt(listado_metricas^2)

### PONDERAR LAS METRICAS
metrica_ponderada = score_valor %>%
  mutate(across(ends_with("_percentil"), ~ round(as.numeric(.x) * as.numeric(get(str_replace(cur_column(),"_p90_percentil$", "_valor"))), 2), .names = "{.col}_x_{str_replace(.col, '_p90_percentil', '_ponderada')}"), # se agregan los valores de cada metrica
         across(ends_with("_ponderada"), ~ .x^2, .names = "{.col}_cuadrado")) %>% # se pondera cada metrica segun su valor
  mutate(score = round(sqrt(rowSums(select(., ends_with("_cuadrado")))), 2)) # se obtiene el score segun la metrica y su ponderacion
  
stats_score = stats_percentil %>%
  filter(position %in% posicion_target) %>%
  inner_join(metrica_ponderada %>% select(player_name, score), by = "player_name") %>%
  select(player_name, position, nationality, team, foot, age, weight, height, paste0(metricas_valor$metrica, "_p90"), paste0(metricas_valor$metrica, "_p90_percentil"), score) %>%
  arrange(desc(score))

