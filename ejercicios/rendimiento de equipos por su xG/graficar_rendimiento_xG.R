library(stringr)
library(ggplot2)
library(janitor)
library(readr)
library(dplyr)

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
team_stats = read_csv('ejercicios/rendimiento de equipos por su xG/liga_2015_2016.csv') %>% clean_names()

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
                          team == "Atlético Madrid" ~ "atletico_madrid",
                          
                          team == "Athletic Club" ~ "athletic_bilbao",
                          team == "Real Sociedad" ~ "real_sociedad",
                          
                          team == "Málaga" ~ "Malaga",
                          team == "Celta Vigo" ~ "Celta_vigo",
                          
                          team == "RC Deportivo La Coruña" ~ "La_coruña",
                          team == "Rayo Vallecano" ~ "Rayo_vallecano",
                          
                          team == "Sporting Gijón" ~ "Sporting_gijon",
                          team == "Levante UD" ~ "Levante",
                          
                          team == "Real Betis" ~ "Betis",
                          team == "Las Palmas" ~ "Las_palmas",
                          
                          TRUE ~ team),
         logo = paste0("ejercicios/rendimiento de equipos por su xG/images/", 
                       tolower(str_replace_all(team, " ", "")), ".png"))


# graficar 
p1 = ggplot(data = team_stats_with_logos, 
            aes(x = avg_xg_for_per_game, y = avg_xg_against_per_game)) +
  # diagonal
geom_abline(slope = MEAN_XG_AGAINST/MEAN_XG_FOR, intercept = 0, 
            linetype = 2, col = "#fff7bc", linewidth = 0.5, alpha = 0.7) +
# promedio xG a favor
geom_hline(yintercept = MEAN_XG_AGAINST, linetype = 2, 
           linewidth = 0.8, col = "#fe9929") +
annotate("text", x = MIN_AXIS + DELTA, y = MEAN_XG_AGAINST + DELTA, size = 10,
         label = "Avg. NPxG en contra por juego", col = "#fe9929", hjust = 0,
         family ='firasans') +
# promedio xG en contra
geom_vline(xintercept = MEAN_XG_FOR, linetype = 2, 
           linewidth = 0.8, col = "#41b6c4") +
annotate("text", x = MEAN_XG_FOR + DELTA, y = MIN_AXIS + DELTA + DELTA, size = 10,
         label = "Avg. NPxG a favor por juego", col = "#41b6c4", hjust = 0,
         family ='firasans') +  
# temas, etiquetas y axis
theme_minimal() +
scale_y_continuous(limits = c(MIN_AXIS - DELTA, MAX_AXIS + DELTA), 
                   breaks = seq(MIN_AXIS, MAX_AXIS, 0.1), expand = c(0,0)) +
scale_x_continuous(limits = c(MIN_AXIS - DELTA, MAX_AXIS + DELTA), 
                   breaks = seq(MIN_AXIS, MAX_AXIS, 0.1), expand = c(0,0)) +
labs(x = "\nAvg. NPxG a favor por juego", y = "Avg. NPxG en contra por juego\n", 
     title = "Avg. NPxG a favor y en contra por juego",
     subtitle = "Liga Española 2015-2016\n",
     caption = "@dhernandez_dev  |  Data: StatsBomb") +
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
ggsave("ejercicios/rendimiento de equipos por su xG/scatterplot_liga_2015_2016.png", width = 12, height = 10)