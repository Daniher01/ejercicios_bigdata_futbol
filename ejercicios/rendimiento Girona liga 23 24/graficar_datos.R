library(stringr)
library(ggplot2)
library(janitor)
library(readr)
library(dplyr)
library(forcats)

# paquete para unir graficos
library(cowplot)

# paquete para agregar imagenes
library(magick)
library(ggimage)

# paquete para personalizar fuentes
library(showtext)
font_add_google('Fira Sans', 'firasans')
showtext_auto()

# leer los datos
team_stats = read_csv('ejercicios/rendimiento Girona liga 23 24/stats_teams.csv') %>% clean_names()

# definir constantes
MIN_AXIS = round(min(team_stats$avg_xg_for_per_game, team_stats$avg_xg_against_per_game), 2)
MAX_AXIS = round(max(team_stats$avg_xg_for_per_game, team_stats$avg_xg_against_per_game), 2)
MEAN_XG_FOR = round(mean(team_stats$avg_xg_for_per_game), 2)
MEAN_XG_AGAINST = round(mean(team_stats$avg_xg_against_per_game), 2)
DELTA = 0.03
COL_TEXT_LINES = "grey90"

# buscar algunos logos de equipo reordenando su nombre
team_stats_with_logos = team_stats %>% 
  mutate(team = case_when(team == "Real Madrid" ~ "real_madrid",
                          team == "Atletico Madrid" ~ "atletico_madrid",
                          
                          team == "Athletic Club" ~ "athletic_bilbao",
                          team == "Real Sociedad" ~ "real_sociedad",
                          
                          team == "Celta Vigo" ~ "Celta_vigo",
                          
                          team == "Rayo Vallecano" ~ "Rayo_vallecano",
                          
                          
                          team == "Real Betis" ~ "Real_betis",
                          team == "Las Palmas" ~ "Las_palmas",
                          
                          TRUE ~ team),
         logo = paste0("images/la liga/", 
                       tolower(str_replace_all(team, " ", "")), ".png"))



# ------------------------------------------------- GRAFICAR COORDENADAS DE xG Y xGA -------------------------------------------
p1 = ggplot(data = team_stats_with_logos, 
            aes(x = avg_xg_for_per_game, y = avg_xg_against_per_game)) +

# promedio xG a favor
geom_hline(yintercept = MEAN_XG_AGAINST, linetype = 2, 
           linewidth = 0.8, col = "#fe9929") +
annotate("text", x = MIN_AXIS + DELTA, y = MEAN_XG_AGAINST + DELTA, size = 10,
         label = "Promedio NPxG en contra por juego", col = "#fe9929", hjust = 0,
         family ='firasans') +
# promedio xG en contra
geom_vline(xintercept = MEAN_XG_FOR, linetype = 2, 
           linewidth = 0.8, col = "#41b6c4") +
annotate("text", x = MEAN_XG_FOR + DELTA, y = MIN_AXIS + DELTA + DELTA, size = 10,
         label = "Promedio NPxG a favor por juego", col = "#41b6c4", hjust = 0,
         family ='firasans') + 
# textos complementarios
  annotate("text", x = 1.4 , y = 1.3, size = 10,
           label = "Excelente Rendimiento", col = "grey90", hjust = 0,
           family ='firasans') +
  annotate("text", x = 1.18 , y = 1.3, size = 10,
           label = "Rendimiento Aceptable", col = "grey90", hjust = 0,
           family ='firasans') +
  annotate("text", x = 1.2 , y = 1.43, size = 10,
           label = "Mal Rendimiento", col = "grey90", hjust = 0,
           family ='firasans') +
  annotate("text", x = 1.4 , y = 1.43, size = 10,
           label = "Buen Rendimiento", col = "grey90", hjust = 0,
           family ='firasans') +
  # temas, etiquetas y axis
  theme_minimal() +
  scale_y_continuous(limits = c(MIN_AXIS - DELTA, MAX_AXIS + DELTA), 
                     breaks = seq(MIN_AXIS, MAX_AXIS, 0.1), expand = c(0,0)) +
  scale_x_continuous(limits = c(MIN_AXIS - DELTA, MAX_AXIS + DELTA), 
                     breaks = seq(MIN_AXIS, MAX_AXIS, 0.1), expand = c(0,0)) +
  labs(x = "\nPromedio NPxG a favor por juego", y = "Promedio NPxG en contra por juego\n", 
       title = "Avg. NPxG a favor y en contra por juego",
       subtitle = "Liga Española 20123-2024 (Hasta la Jornada 13)\n",
       caption = "@dhernandez_dev  |  Data: understat") +
  theme(legend.position = "none",
        panel.background = element_rect(fill = "#252525", colour = COL_TEXT_LINES),
        plot.background = element_rect(fill = "#252525", colour = "transparent"),
        panel.grid.minor.x = element_blank(),
        panel.grid = element_line(colour = "grey50", size = 0.1),
        text = element_text(family = 'firasans', colour = COL_TEXT_LINES, size = 30),
        axis.ticks = element_line(colour = COL_TEXT_LINES),
        axis.text = element_text(colour = COL_TEXT_LINES),
        axis.title = element_text(colour = COL_TEXT_LINES),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm")) +
  # agregar imagenes
  geom_image(aes(image = logo), size = 0.05, by = "width", asp = 1.3)

# join graph with the premier league logo
p2 = ggdraw() +
  draw_plot(p1) +
  draw_image("ejercicios/rendimiento de equipos por su xG/images/liga.png",  
             x = 0.4, y = 0.45, scale = 0.1)

p2

# guardar la imagen
ggsave("ejercicios/rendimiento Girona liga 23 24/scatterplot_liga_23_24.png", width = 12, height = 10)

# ------------------------------------------------- GRAFICAR BARRAS DE PPDA -------------------------------------------
# DEFINIR CONSTANTES
MEAN_PPDA = round(mean(team_stats$ppda_mean), 2)
COLOR_GIRONA = "#e31a1c"


g1 = ggplot(data = team_stats, 
       aes(x = fct_reorder(team, ppda_mean), y = ppda_mean, fill=(team=="Girona"))) +
  # linea horizontal
  geom_hline(yintercept = MEAN_PPDA, linetype = 2, 
             linewidth = 0.8, col = COL_TEXT_LINES) +

  # barra
  geom_bar(stat = "identity", col = COL_TEXT_LINES, alpha = 0.7, width = 0.8) + 
  coord_flip() +
  theme_bw() +
  # textos
  labs(x = "\nEquipos", y = "PPDA promedio por juego\n",
       title = "Pases Permitidos por Acción Defensiva",
       subtitle = "Liga Española 2023-2024 (Hasta la Jornada 13)\n",
       caption = "@dhernandez_dev  |  Data: understat") +
  annotate("text", x = 7, y = MEAN_PPDA + DELTA, size = 10,
           label = "PPDA promedio de la liga", col = COL_TEXT_LINES, hjust = 0,
           family ='firasans') +
  # escalar el grafico  
  scale_y_continuous(breaks = seq(0, 18, 2), labels = seq(0, 18, 2), limits = c(0, 18)) +
  # tema
  theme(panel.background = element_rect(fill = "#252525", colour = COL_TEXT_LINES),
        plot.background = element_rect(fill = "#252525", colour = "transparent"),
        panel.grid.minor.x = element_blank(),
        panel.grid = element_line(colour = "grey50", size = 0.1),
        axis.ticks = element_line(colour = COL_TEXT_LINES),
        axis.text = element_text(colour = COL_TEXT_LINES),
        title = element_text(colour = COL_TEXT_LINES),
        text = element_text(family = 'firasans', colour = COL_TEXT_LINES, size = 40),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm"),
        legend.position = "none") +
  # label
  geom_text(aes(label = round(ppda_mean, 0)),  hjust = 1.5, col = COL_TEXT_LINES, size = 10) +
  # colores
  scale_fill_manual(values=c("TRUE"= COLOR_GIRONA, "FALSE"="gray"))


g2 = ggdraw() +
  draw_plot(g1) +
  draw_image("ejercicios/rendimiento de equipos por su xG/images/liga.png",  
             x = 0.4, y = 0.45, scale = 0.1)

g2

# guardar la imagen
ggsave("ejercicios/rendimiento Girona liga 23 24/ppda_girona_23_24.png", width = 12, height = 10)




