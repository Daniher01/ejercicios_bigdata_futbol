# cargar las librerias
library(janitor)
library(ggplot2)
library(forcats)
library(glue)
library(ggtext)
library(gt)
# paquete para personalizar fuentes
library(showtext)
font_add_google('Fira Sans', 'firasans')
showtext_auto()


# CARGAR DATOS
players_score_delantero = read.csv("ejercicios/score_players/data_score/score_F.csv", colClasses = c("position" = "character")) %>% clean_names()

#### GRAFICO DE BARRAS

g_barras = ggplot(data = players_score_delantero %>% head(10), aes(x = fct_reorder(player_name, score), y = score)) +
  geom_bar(stat = "identity", fill = "grey90", col = "white", alpha = 0.7, width = 0.8) +
  coord_flip() +
  theme_bw() +
  # textos
  labs(x = "\nJugador", y = "Score",
       title = "Top 10 Delanteros con mejor puntaje",
       subtitle = "Rendimiento según el estilo de juego solicitado") +
  # escalar el grafico  
  scale_y_continuous(breaks = seq(0, 0.36, 0.05), labels = seq(0, 0.36, 0.05), limits = c(0, 0.36)) +
  # tema
  theme(panel.background = element_rect(fill = "#252525", colour = "grey90"),
        plot.background = element_rect(fill = "#252525", colour = "transparent"),
        panel.grid.minor.x = element_blank(),
        panel.grid = element_line(colour = "grey50", size = 0.1),
        axis.ticks = element_line(colour = "grey90"),
        axis.text = element_text(colour = "grey90"),
        title = element_text(colour = "grey90"),
        text = element_text(family = 'firasans', colour = "grey90", size = 40),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm"),
        legend.position = "none") +
  # label
  geom_text(aes(label = score),  hjust = 1.5, col = "grey10", size = 10)
  
  
g_barras

# guardar la imagen
ggsave("ejercicios/score_players/graficos/top10_score.png", width = 12, height = 10)


#### GRAFICO DE RADARES

# jugadores target
players_selected = c('Patson Daka', 'Romelu Lukaku', 'Kai Lukas Havertz', 'Jean-Philippe Mateta', 'E. Dennis')

# para metricas p90
metricas_p90 = players_score_delantero %>% select(ends_with("p90")) %>% names()

players_p90_long = players_score_delantero %>% 
  pivot_longer(cols = metricas_p90, names_to = "metric", values_to = "p90")

# para metricas percentiles 
metricas_percentil = players_score_delantero %>% select(ends_with("percentil")) %>% names()

players_percentil_long = players_score_delantero %>% 
  pivot_longer(cols = metricas_percentil, names_to = "metric", values_to = "percentil")

# dar formato a las métricas
df_selected = players_p90_long %>%
  bind_cols(players_percentil_long %>% select(percentil)) %>%
  mutate(metric = case_when(metric == "xg_diff_p90" ~ "Goles vs XG (25%)",
                            metric == "shots_on_target_percent_p90" ~ "% tiros a puerta (25%)",
                            metric == "air_challenges_won_percent_p90" ~ "% duelos aéreos ganados (25%)",
                            metric == "expected_assists_p90" ~ "xA (15%)",
                            metric == "defensive_challenges_won_percent_p90" ~ "% duelos defenvios ganados (5%)",
                            metric == "ball_interceptions_p90" ~ "Intercepciones (5%)")) %>%
  select(player_name, team, score, metric, p90, percentil)

df_selected = na.omit(df_selected)

df_selected$metric = factor(df_selected$metric, 
                            levels = c("% tiros a puerta (25%)", "Goles vs XG (25%)", "% duelos aéreos ganados (25%)", 
                                       "xA (15%)", "Intercepciones (5%)", "% duelos defenvios ganados (5%)"))

# selecionar a los jugadores
player_1 = df_selected %>% filter(player_name == players_selected[1])
color_player_1 = "#023e8a"
player_2 = df_selected %>% filter(player_name == players_selected[2])
color_player_2 = "#d95f0e"
player_3 = df_selected %>% filter(player_name == players_selected[3])
color_player_3 = "#31a354"
player_4 = df_selected %>% filter(player_name == players_selected[4])
color_player_4 = "#de2d26"
player_5 = df_selected %>% filter(player_name == players_selected[5])
color_player_5 = "#8856a7"


# generar gráfico de radar
grafico_radar <- function(df = df_selected, player, color_player){
  
  ggplot(df, aes(x = metric, y = percentil)) +
    
    geom_bar(aes(y = 1), fill = color_player, stat = "identity", 
             width = 1, colour = "white", alpha = 0.3, linetype = "dashed") +                                                                          
    geom_bar(data = player, fill = color_player, stat = "identity", width = 1,  alpha = 0.8) +
    
    geom_hline(yintercept = 0.25, colour = "white", linetype = "longdash", alpha = 0.5) +
    geom_hline(yintercept = 0.50, colour = "white", linetype = "longdash", alpha = 0.5) +
    geom_hline(yintercept = 0.75, colour = "white", linetype = "longdash", alpha = 0.5) + 
    geom_hline(yintercept = 1,    colour = "white", alpha = 0.5) +
    scale_y_continuous(limits = c(-0.1, 1)) +    
    coord_polar() +
    
    geom_label(data = player, aes(label = round(p90, 2)), fill = "#e9d8a6", size = 8,color= "black", show.legend = FALSE) +
    
    labs(fill = "",
         title = glue("{player$player_name[1]} ({player$team[1]})"),
         subtitle = glue("Puntaje: {player$score}")) +
    theme_minimal() +                                                                     
    theme(plot.background = element_rect(fill = "white", color = "white"),
          panel.background = element_rect(fill = "white", color = "white"),
          legend.position = "top",
          axis.title.y = element_blank(),
          axis.title.x = element_blank(),
          axis.text.y = element_blank(),
          axis.text.x = element_text(size = 20),
          plot.title = element_markdown(hjust = 0.5, size = 40),
          plot.subtitle = element_text(hjust = 0.5, size = 38),
          plot.caption = element_text(size = 10),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          plot.margin = margin(5, 2, 2, 2))
}


player_1_plot = grafico_radar(player = player_1, color_player = color_player_1)
player_2_plot = grafico_radar(player = player_2, color_player = color_player_2)
player_3_plot = grafico_radar(player = player_3, color_player = color_player_3)
player_4_plot = grafico_radar(player = player_4, color_player = color_player_4)
player_5_plot = grafico_radar(player = player_5, color_player = color_player_5)
ggsave(glue("ejercicios/score_players/graficos/radar__{player_1$player_name[1]}.png"), plot = player_1_plot, height = 10, width = 10)
ggsave(glue("ejercicios/score_players/graficos/radar__{player_2$player_name[2]}.png"), plot = player_2_plot, height = 10, width = 10)
ggsave(glue("ejercicios/score_players/graficos/radar__{player_3$player_name[3]}.png"), plot = player_3_plot, height = 10, width = 10)
ggsave(glue("ejercicios/score_players/graficos/radar__{player_4$player_name[4]}.png"), plot = player_4_plot, height = 10, width = 10)
ggsave(glue("ejercicios/score_players/graficos/radar__{player_5$player_name[5]}.png"), plot = player_5_plot, height = 10, width = 10)

names(players_score_delantero)

# tabla de top5 jugadores
delanteros_info = players_score_delantero %>% head(5) %>% 
  select(player_name, position, minutes_played, national_team, foot, age, height, ends_with("p90"), score) %>%
  mutate(across(ends_with("_percent_p90"), ~paste0(.x*100, "%")),
         position = "Delantero") %>%
  rename(
    "Nombre del jugador" = player_name,
    "Posición" = position,
    "Minutos jugados" = minutes_played,
    "Selección nacional" = national_team,
    "Pie hábil" = foot,
    "Edad" = age,
    "Altura" = height,
    "Diferencia Goles vs xG" = xg_diff_p90,
    "Tiros a puerta" = shots_on_target_percent_p90,
    "Duelos aéreos ganados" = air_challenges_won_percent_p90,
    "xA" = expected_assists_p90,
    "Duelos defensivos ganados" = defensive_challenges_won_percent_p90,
    "Intercepciones" = ball_interceptions_p90
  ) %>% 
  gt() %>%
  tab_header(
    title = md("Top 5 delanteros con mejor puntaje"),
    subtitle = md("estadísticas cada 90 minutos")
  ) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels(columns = everything())
  )

gtsave(data = delanteros_info, file = "ejercicios/score_players/graficos/tabla_top5_delanteros.png")
