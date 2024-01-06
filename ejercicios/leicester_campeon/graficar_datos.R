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

source("ejercicios/leicester_campeon/graficos_cancha.R")

# -------------- relacion xG - Goles

team_stats = read_csv('data/teams_data_premier_15_16.csv') %>% clean_names()

# definir constantes
MIN_AXIS = round(min(team_stats$xg, team_stats$goles), 2)
MAX_AXIS = round(max(team_stats$xg, team_stats$goles), 2)
MEAN_XG = round(mean(team_stats$xg), 2)
MEAN_GOLES = round(mean(team_stats$goles), 2)
DELTA = 1
COL_TEXT_LINES = "grey90"

xg_goles = ggplot(data = team_stats, 
            aes(x = xg, y = goles)) +
  
  # linea promedio 
  geom_abline(intercept = 0, slope = 1, linetype = 2, 
              linewidth = 0.8, col = "grey90") +
  # textos complementarios
  annotate("text", x = 25 , y = 69, size = 10,
           label = "Convritió más de lo esperado", col = "grey90", hjust = 0,
           family ='firasans') +
  annotate("text", x = 65 , y = 26, size = 10,
           label = "Pudo convertir más goles", col = "grey90", hjust = 0,
           family ='firasans') +
  
  # temas, etiquetas y axis
  theme_minimal() +
  scale_y_continuous(limits = c(MIN_AXIS - DELTA*3, MAX_AXIS + DELTA*3), 
                     breaks = seq(MIN_AXIS, MAX_AXIS, 5), expand = c(0,0)) +
  scale_x_continuous(limits = c(MIN_AXIS - DELTA*3, MAX_AXIS + DELTA* 3), 
                     breaks = seq(MIN_AXIS, MAX_AXIS, 5), expand = c(0,0)) +
  labs(x = "\nxG durante todo el torneo", y = "Goles durante todo el torneo\n", 
       title = "Rendimiento Ofensivo xG - Goles ",
       subtitle = "Permier League 2015/2016\n",
       caption = "@dhernandez_dev  |  Data: statsbomb") +
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

xg_goles

# guardar la imagen
ggsave("ejercicios/leicester_campeon/graficos/relacion_goles_xg_premier_15_16.png", width = 12, height = 10)

# --------------- relacion xGA - Goles concebidos
# definir constantes
MIN_AXIS = round(min(team_stats$xg_contra, team_stats$goles_contra), 2)
MAX_AXIS = round(max(team_stats$xg_contra, team_stats$goles_contra), 2)
MEAN_XG_CONTRA = round(mean(team_stats$xg_contra), 2)
MEAN_GOLES_CONTRA = round(mean(team_stats$goles_contra), 2)
DELTA = 1
COL_TEXT_LINES = "grey90"

xg_goles_contra = ggplot(data = team_stats, 
                  aes(x = xg_contra, y = goles_contra)) +
  
  # linea promedio 
  geom_abline(intercept = 0, slope = 1, linetype = 2, 
               col = "grey90") +
  # textos complementarios
  annotate("text", x = 33 , y = 69, size = 10,
           label = "Recibió más de lo esperado", col = "grey90", hjust = 0,
           family ='firasans') +
  annotate("text", x = 65 , y = 33, size = 10,
           label = "Pudo recibir más goles", col = "grey90", hjust = 0,
           family ='firasans') +
  
  # temas, etiquetas y axis
  theme_minimal() +
  scale_y_continuous(limits = c(MIN_AXIS - DELTA*3, MAX_AXIS + DELTA*3), 
                     breaks = seq(MIN_AXIS, MAX_AXIS, 5), expand = c(0,0)) +
  scale_x_continuous(limits = c(MIN_AXIS - DELTA*3, MAX_AXIS + DELTA* 3), 
                     breaks = seq(MIN_AXIS, MAX_AXIS, 5), expand = c(0,0)) +
  labs(x = "\nxG en contra durante todo el torneo", y = "Goles en contra durante todo el torneo\n", 
       title = "Rendimiento Defensivo xG en contra - Goles en contra ",
       subtitle = "Permier League 2015/2016\n",
       caption = "@dhernandez_dev  |  Data: statsbomb") +
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

xg_goles_contra

ggsave("ejercicios/leicester_campeon/graficos/relacion_goles_xg_en_contra_premier_15_16.png", width = 12, height = 10)

# -------------- ratio xG - Goles a favor y en contra

# definir constantes
MIN_AXIS = round(min(team_stats$ratio_of, team_stats$ratio_def), 2)
MAX_AXIS = round(max(team_stats$ratio_of, team_stats$ratio_def), 2)
MEAN_RATIO_OF = round(mean(team_stats$ratio_of), 2)
MEAN_RATIO_DEF = round(mean(team_stats$ratio_def), 2)
DELTA = 0.05
COL_TEXT_LINES = "grey90"

ratio_xg_goles = ggplot(data = team_stats, 
                         aes(x = ratio_of, y = ratio_def)) +
  
  # promedio xG a favor
  geom_hline(yintercept = 1, linetype = 2,
             linewidth = 0.8, col = "#fe9929") +
  annotate("text", x = 0.7 + DELTA, y = 1 + DELTA/2, size = 10,
           label = "Ratio Defensivo", col = "#fe9929", hjust = 0,
           family ='firasans') +
  # promedio xG en contra
  geom_vline(xintercept = 1, linetype = 2,
             linewidth = 0.8, col = "#41b6c4") +
  annotate("text", x = 1 + DELTA/2, y = 0.7 + DELTA + DELTA, size = 10,
           label = "Ratio Ofensivo", col = "#41b6c4", hjust = 0,
           family ='firasans') +
  # textos complementarios
  annotate("text", x = 1.3 , y = 0.8, size = 10,
           label = "Excelente Rendimiento", col = "grey90", hjust = 0,
           family ='firasans') +
  annotate("text", x = 1.25 , y = 1.4, size = 10,
           label = "Mejor rendimiento Ofensivo que Defensivo", col = "grey90", hjust = 0,
           family ='firasans') +
  annotate("text", x = 0.8 , y = 1.4, size = 10,
           label = "Mal Rendimiento", col = "grey90", hjust = 0,
           family ='firasans') +
  annotate("text", x = 0.75 , y = 0.8, size = 10,
           label = "Mejor rendimiento Defensivo que ofensivo", col = "grey90", hjust = 0,
           family ='firasans') +
  
  # temas, etiquetas y axis
  theme_minimal() +
  scale_y_continuous(limits = c(MIN_AXIS - DELTA, MAX_AXIS + DELTA), 
                     breaks = seq(MIN_AXIS, MAX_AXIS, 0.1), expand = c(0,0)) +
  scale_x_continuous(limits = c(MIN_AXIS - DELTA, MAX_AXIS + DELTA), 
                     breaks = seq(MIN_AXIS, MAX_AXIS, 0.1), expand = c(0,0)) +
  labs(x = "\nRatio xG - Goles", y = "Ratio xG en contra - Goles en contra\n", 
       title = "Rendimiento en base el Ratio xG - Goles (a favor y en contra) ",
       subtitle = "Permier League 2015/2016\n",
       caption = "Ratio: Comparacion entre 2 grupos, en este caso xG y Goles tanto a favor como en contra \n@dhernandez_dev  |  Data: statsbomb") +
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

ratio_xg_goles

ggsave("ejercicios/leicester_campeon/graficos/ratio_xg_goles_premier_15_16.png", width = 12, height = 10)

# -------------- mapa de tiros del equipo

shotmap_team = read_csv('data/shots_leicester.csv') %>% clean_names()
tiros_totales = nrow(shotmap_team)
goles = nrow(shotmap_team %>% filter(shot_outcome_name == "Goal"))
precision = round(goles/tiros_totales*100)

COL_TEXT_LINES = "grey90"

shotmap <- get_half_pitch(gp = ggplot(data = shotmap_team),pitch_fill = "#252525", 
                          pitch_col = "grey90", background_fill = "#252525",  margin = 0.1) +
  # capa de variables
  geom_point(aes(x = pos_x_meter, y = pos_y_meter, 
                 size = shot_statsbomb_xg, fill = shot_outcome_name, shape = shot_body_part_name), alpha = 0.8) +
  # capa de estética
  scale_size_continuous(range = c(3, 6), breaks = seq(0, 1, 0.2)) +
  scale_fill_manual(values = c("blue", "#67a9cf", "#67a9cf", "#67a9cf", "#67a9cf")) +
  scale_shape_manual(values = c(23, 22, 21)) +
  # capa de leyendas y textos
  theme(legend.position = "bottom",
        legend.margin = margin( l = 2, unit = "cm"),
        legend.box = "vertical",
        legend.justification = "center",
        plot.background = element_rect(fill = "#252525", colour = "transparent"),
        text = element_text(family = 'firasans', colour = COL_TEXT_LINES, size = 30),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm")) +
  # capa que permite sobreescribir la parte estetica a la leyenda de los datos
  guides(fill = guide_legend(override.aes = list(shape = 21, size = 8, stroke = 1, alpha = 0.7)),
         shape = guide_legend(override.aes = list(size = 8, fill = COL_TEXT_LINES))) +
  # permite personalizar la leyenda y los textos
  labs(fill = "Resultado del tiro:",
       size = "xG:",
       shape = "Parte del cuerpo:",
       title = "Shotmap Leicester Premier 2015/2016",
       subtitle = paste0(tiros_totales, " Tiros (", precision, "% de conversión de goles)"))

shotmap <- ggdraw() +
  draw_plot(shotmap) +
  draw_image("images/statsbomb.jpg",  x = -0.35, y = -0.24, scale = 0.15)

shotmap

ggsave('ejercicios/leicester_campeon/graficos/shotmap_leicester.png',  width = 12, height = 10)
