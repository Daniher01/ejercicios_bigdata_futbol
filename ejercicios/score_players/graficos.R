# cargar las librerias
library(janitor)
library(ggplot2)
library(forcats)
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

# para metricas p90
metricas_p90 = players_score_delantero %>% select(ends_with("p90")) %>% names()

players_p90_long = players_score_delantero %>% 
  pivot_longer(cols = metricas_p90, names_to = "metric", values_to = "p90")

# para metricas percentiles 
metricas_percentil = players_score_delantero %>% select(ends_with("percentil")) %>% names()

players_percentil_long = players_score_delantero %>% 
  pivot_longer(cols = metricas_percentil, names_to = "metric", values_to = "percentil")
