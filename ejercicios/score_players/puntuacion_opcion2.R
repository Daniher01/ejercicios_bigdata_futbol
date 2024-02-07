"
Este es otro proceso de prueba para obtene el score, en lugar de normalizar los datos p90 con percentiles
se van a normalizar de 0,1 obteniendo sus maximos
"
# ponderaciones de las metricas
delantero_centro = data.frame(metrica = c("xg_diff", "shots_on_target_percent", "air_challenges_won_percent", "expected_assists",
                                          "defensive_challenges_won_percent", "ball_interceptions"),
                              ponderacion = c(0.25, 0.25, 0.25 ,0.15, 0.05, 0.05))

defensa_central <- list(c("CD", "air_challenges_won_percent", 0.4),
                        c("CD", "defensive_challenges_won_percent", 0.3),
                        c("CD", "accurate_passes_percent", 0.1),
                        c("CD", "key_passes_accurate", 0.1),
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
                        c("DM", "defensive_challenges_won_percent", 0.25),
                        c("DM", "accurate_crosses_percent", 0.2),
                        c("DM", "ball_interceptions", 0.1),
                        c("DM", "expected_assists", 0.1))

# VOLANTE INTERIOR
voalante_interior <- list(c("CM", "key_passes_accurate", 0.3),
                          c("CM", "ball_interceptions", 0.2),
                          c("CM", "expected_assists", 0.2),
                          c("CM", "defensive_challenges_won_percent", 0.15),
                          c("CM", "x_g_expected_goals", 0.15))

# EXTREMO
extremo <- list(c("LM", "challenges_won_percent", 0.3),
                c("LM", "accurate_crosses_percent", 0.3),
                c("LM", "x_g_expected_goals", 0.15),
                c("LM", "expected_assists", 0.15),
                c("LM", "defensive_challenges_won_percent", 0.05),
                c("LM", "ball_interceptions", 0.05),
                c("RM", "challenges_won_percent", 0.3),
                c("RM", "accurate_crosses_percent", 0.3),
                c("RM", "x_g_expected_goals", 0.15),
                c("RM", "expected_assists", 0.15),
                c("RM", "defensive_challenges_won_percent", 0.05),
                c("RM", "ball_interceptions", 0.05))

# DELANTERO CENTRO
delantero_centro <- list(c("F", "xg_diff", 0.25),
                         c("F", "shots_on_target_percent", 0.25),
                         c("F", "air_challenges_won_percent", 0.25),
                         c("F", "expected_assists", 0.15),
                         c("F", "defensive_challenges_won_percent", 0.05),
                         c("F", "ball_interceptions", 0.05))

modelo_juego <- data.frame(position = c(sapply(defensa_central, "[[", 1), sapply(laterales, "[[", 1), sapply(volante_central, "[[", 1), sapply(voalante_interior, "[[", 1), sapply(extremo, "[[", 1), sapply(delantero_centro, "[[", 1)),
                           metrica = c(sapply(defensa_central, "[[", 2), sapply(laterales, "[[", 2), sapply(volante_central, "[[", 2), sapply(voalante_interior, "[[", 2), sapply(extremo, "[[", 2), sapply(delantero_centro, "[[", 2)),
                           valor = c(sapply(defensa_central, "[[", 3), sapply(laterales, "[[", 3), sapply(volante_central, "[[", 3), sapply(voalante_interior, "[[", 3), sapply(extremo, "[[", 3), sapply(delantero_centro, "[[", 3)))


# ------------------------------------------------------------------------------
### EXTRAER DATOS
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
  mutate(across(-columnas_de_texto, ~replace_na(.x, 0))) %>%
  # agregar metricas que hagan falta
  mutate(xg_diff = round(goals-x_g_expected_goals,2),
         defensive_challenges_won_percent = (defensive_challenges_won/defensive_challenges)*100,
         # ajustar metricas defensivas a 1-metrica
         fouls = 1-fouls)

### APLICAR FILTROS de busqueda
MIN_MINUTOS = max(stats_premier$minutes_played)*0.3
EDAD_MAX = 29


# pasar los datos a p90
stats_p90 = premier_clean %>%
  filter(minutes_played > MIN_MINUTOS, age <= EDAD_MAX) %>%
  mutate(across(-c(columnas_de_texto, otras_columnas, ends_with("percent")),~round(as.numeric(.x)/minutes_played*90, 2), .names = "{.col}_p90")) %>%
  mutate(across(ends_with("percent"), ~ifelse(.x > 1, round(as.numeric(.x)/100, 2), .x), .names = "{.col}_p90")) %>%
  select(columnas_de_texto, otras_columnas, ends_with("percent"), ends_with("p90"))

stats_percentil = stats_p90 %>%
  group_by(position) %>%
  mutate(across(ends_with("p90"), ~round(percent_rank(.x),2), .names = "{col}_percentil")) %>%
  # las metricas "negativas" defensivas se cambian a 1-variable
  mutate(fouls_p90_percentil = 1-fouls_p90_percentil)


generar_score_csv <- function(position_target, modelo_df = modelo_juego, stats_df, url_file = 'ejercicios/score_players/data_score/modelo2/'){

  # obtener las metricas del modelo de juego
  metricas_target = modelo_juego %>% filter(position %in% position_target)
  
  # normalizar las metricas p90
  stats_normalizadas = stats_df %>%
    filter(position %in% position_target) %>%
    mutate(across(ends_with("p90") & !ends_with("percent_p90"), ~(.x - min(.x)) / (max(.x) - min(.x)), .names = "{.col}_norm"),
           across(ends_with("percent_p90"), .names = "{.col}_norm"))
  
  # Ponderar y generar el score
  stats_ponderadas = stats_normalizadas %>%
    select(paste0(metricas_target$metrica, "_p90_norm")) %>%
    rowwise() %>%
    mutate(score = round(sum(c_across(everything()) * as.numeric(metricas_target$valor)) %>% sqrt(), 2))
  
  # obtener solo los datos relevantes
  data_score = stats_normalizadas %>%
    inner_join(stats_ponderadas) %>%
    select(player_name, position, minutes_played, national_team, team, foot, age, weight, height, starts_with(metricas_target$metrica), score) %>%
    arrange(desc(score))
  
  # guardar el dataframe
  if(length(position_target) > 1){
    name_position <- paste(position_target, collapse = "_")
  }else{
    name_position <- position_target
  }
  
  filename <- paste0(url_file,"score_", name_position, ".csv")
  write.csv(data_score, file = filename, row.names = FALSE)
    
}

generar_score_csv(position_target = c("CD"), stats_df = stats_percentil)
generar_score_csv(position_target = c("RD", "LD"), stats_df = stats_percentil)
generar_score_csv(position_target = c("DM"), stats_df = stats_percentil)
generar_score_csv(position_target = c("CM"), stats_df = stats_percentil)
generar_score_csv(position_target = c("RM", "LM"), stats_df = stats_percentil)
generar_score_csv(position_target = c("F"), stats_df = stats_percentil)

