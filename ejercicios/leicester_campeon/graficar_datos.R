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
MIN_AXIS = round(min(team_stats$x_g, team_stats$goles), 2)
MAX_AXIS = round(max(team_stats$x_g, team_stats$goles), 2)
MEAN_XG = round(mean(team_stats$x_g), 2)
MEAN_GOLES = round(mean(team_stats$goles), 2)
DELTA = 1
COL_TEXT_LINES = "grey90"

xg_goles = ggplot(data = team_stats, 
            aes(x = x_g, y = goles)) +
  
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
       caption = "Twitter: @dhernandez_dev") +
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

xg_goles <- ggdraw() +
  draw_plot(xg_goles) +
  draw_image("images/statsbomb.jpg",  x = -0.34, y = -0.45, scale = 0.15)

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
       caption = "Twitter: @dhernandez_dev") +
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

xg_goles_contra <- ggdraw() +
  draw_plot(xg_goles_contra) +
  draw_image("images/statsbomb.jpg",  x = -0.34, y = -0.45, scale = 0.15)

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
       caption = "Ratio: Comparacion entre 2 grupos, en este caso xG y Goles tanto a favor como en contra \nTwitter: @dhernandez_dev") +
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

ratio_xg_goles <- ggdraw() +
  draw_plot(ratio_xg_goles) +
  draw_image("images/statsbomb.jpg",  x = -0.34, y = -0.45, scale = 0.15)

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
        legend.margin = margin(b = 0.1, l = 1, unit = "cm"),
        legend.box = "vertical",
        legend.box.just = "left",
        plot.background = element_rect(fill = "#252525", colour = "transparent"),
        text = element_text(family = 'firasans', colour = COL_TEXT_LINES, size = 30),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm"),
        plot.caption = element_text(margin = margin(5, 0, 0, 0))) +
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

# ----------------- zona de pases del arquero premier ----------------------------------

pass_zone_gk = read_csv('data/gk_passes_premier_15_16.csv') %>% clean_names() %>%
  mutate(zone = paste0(zone_x_pass_end,'-',zone_y_pass_end)) %>%
  left_join(gird_zones(), by = c("zone" = "zone"))


d <- get_pitch(gp = ggplot(data = pass_zone_gk), margin = 0.6, pitch_col = "grey50", pitch_fill = "white") +
  geom_rect(aes(xmin = x1, xmax = x2, ymin = y1, ymax = y2, fill = percent_pass_per_zone), col = "grey50", alpha = 0.7) +
  geom_text(aes(x = (x1 + x2) / 2, y = (y1 + y2) / 2, label = percent_pass_per_zone), size = 10, colour = "black") +
  scale_fill_gradient2(high = "red", low = "blue") +
  facet_wrap(~team_name, ncol = 4) +
  theme(legend.position = "bottom",
        legend.margin = margin(t = 0.4, unit = "cm"),
        plot.background = element_rect(fill = "white", colour = "transparent"),
        text = element_text(family = 'firasans', colour = "black", size = 30),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm"),
        plot.caption = element_text(margin = margin(2, 0, 0, 0)),
        plot.title = element_text(margin = margin(b = 0.2, unit = "cm")),
        plot.subtitle = element_text(margin = margin(b = 1, unit = "cm"))) +
  labs(fill = "% de pases en cada zona",
       title = "Porcentaje (%) de pases de porteros a cada zona (por equipo) ",
       subtitle = "Premier 2015/2016")

d <- ggdraw() +
  draw_plot(d) +
  draw_image("images/statsbomb.jpg",  x = -0.34, y = -0.45, scale = 0.15)

d

ggsave('ejercicios/leicester_campeon/graficos/zona_pases_gk_premier.png',  width = 15, height = 12)

# ---------------- zona de pases del arquero del leicester
pass_zone_gk_team = read_csv('data/gk_passes_leicester_15_16.csv') %>% clean_names() %>%
  mutate(preciso = ifelse(is.na(pass_outcome_name), 'Si', 'No'))

cant_success = sum(ifelse(pass_zone_gk_team$preciso == 'Si', 1, 0))

pgt = get_pitch(gp = ggplot(data = pass_zone_gk_team), margin = 0.6, pitch_fill = "#252525", 
                pitch_col = "grey90", background_fill = "#252525") +
  geom_rect(data = gird_zones() ,aes(xmin = x1, xmax = x2, ymin = y1, ymax = y2,), fill = NA, col = "grey50", alpha = 0.7) +
  geom_point(aes(x = pass_end_pos_x_meter, y = pass_end_pos_y_meter, col = preciso), alpha = 0.8) +
  scale_color_brewer(palette = "Set1") +
  scale_shape_manual(values = c(15, 16)) +
  # capa de leyendas y textos
  theme(legend.position = "bottom",
        legend.margin = margin(t = 0.4, unit = "cm"),
        plot.background = element_rect(fill = "#252525", colour = "transparent"),
        text = element_text(family = 'firasans', colour = "grey90", size = 30),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm"),
        plot.caption = element_text(margin = margin(5, 0, 0, 0))) +
  # capa que permite sobreescribir la parte estetica a la leyenda de los datos
  guides(col = guide_legend(override.aes = list(size = 8))) +
  labs(col = "¿Pase preciso?",
       title = "Pases de Kasper Schmeichel (GK) - Leicester",
       subtitle = paste0(nrow(pass_zone_gk_team), " total de pases (", round(cant_success/nrow(pass_zone_gk_team)*100, 2), "% de precisión)"))

pgt <- ggdraw() +
  draw_plot(pgt) +
  draw_image("images/statsbomb.jpg",  x = -0.34, y = -0.45, scale = 0.15)

pgt

ggsave('ejercicios/leicester_campeon/graficos/zona_pases_gk_leicester.png',  width = 18, height = 12)

# ---------------------- zona de tiros de corner premier
zonas_corner = read_csv('data/corners_premier_15_16.csv') %>% clean_names() %>%
  left_join(gird_zones_hp(), by = c("zone_y_pass_end" = "zone")) %>%
  group_by(team_name) %>%
  mutate(total = sum(frecuencia)) %>%
  group_by(team_name, zone_y_pass_end) %>%
  mutate(percent_zone = round(frecuencia/total*100, 2))

corner <- get_half_pitch(gp = ggplot(data = zonas_corner)) +
  geom_rect(aes(xmin = x1, xmax = x2, ymin = y1, ymax = y2, fill = x_a),  col = "grey50", alpha = 0.7) +
  geom_text(aes(x = (x1 + x2) / 2, y = (y1 + y2) / 2, label = paste0(percent_zone, "%")), size = 10, colour = "black") +
  geom_text(aes(x = ((x1 + x2) / 2) - 12, y = (y1 + y2) / 2, label = paste0(assists)), size = 8, colour = "black") +
  scale_fill_gradient2(high = "red", low = "blue") +
  facet_wrap(~team_name, ncol = 4) +
  theme(legend.position = "bottom",
        legend.margin = margin(t = 0.4, unit = "cm"),
        plot.background = element_rect(fill = "white", colour = "transparent"),
        text = element_text(family = 'firasans', colour = "black", size = 30),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm"),
        plot.caption = element_text(margin = margin(5, 0, 0, 0)),
        plot.title = element_text(margin = margin(b = 0.2, unit = "cm")),
        plot.subtitle = element_text(margin = margin(b = 1, unit = "cm"))) +
  labs(fill = "xA",
       title = "Frecuencia de centros desde tiro de esquina",
       subtitle = "Premier 2015/2016")

corner <- ggdraw() +
  draw_plot(corner) +
  draw_image("images/statsbomb.jpg",  x = -0.34, y = -0.45, scale = 0.15)

corner

ggsave('ejercicios/leicester_campeon/graficos/zona_corner_premier_15_16.png', width = 12, height = 10)

# ------------- zonas de presión por equipo ------------------------
zonas_presion = read_csv('data/pressures_premier_15_16.csv') %>% clean_names() %>%
  group_by(zone_x, zone_y) %>%
  mutate(avg_team = round(mean(presion)),
         value_compared_avg = presion-avg_team,
         zone = paste0(zone_x,'-',zone_y)) %>%
  left_join(gird_zones(), by = c("zone" = "zone"))

presion <- get_pitch(gp = ggplot(data = zonas_presion)) +
  geom_rect(aes(xmin = x1, xmax = x2, ymin = y1, ymax = y2,fill = value_compared_avg), col = "grey50", alpha = 0.7) +
  scale_fill_gradient2(high = "red", low = "blue") +
  facet_wrap(~team_name, ncol = 4) +
  theme(legend.position = "bottom",
        legend.margin = margin(t = 0.4, unit = "cm"),
        plot.background = element_rect(fill = "white", colour = "transparent"),
        text = element_text(family = 'firasans', colour = "black", size = 30),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm"),
        plot.caption = element_text(margin = margin(5, 0, 0, 0)),
        plot.title = element_text(margin = margin(b = 0.2, unit = "cm")),
        plot.subtitle = element_text(margin = margin(b = 1, unit = "cm"))) +
  labs(fill = "Frecuencia en las zonas de presión",
       title = "Presiones más altas/más bajas que el promedio de los equipos en cada zona",
       subtitle = "Premier 2015/2016")

presion <- ggdraw() +
  draw_plot(presion) +
  draw_image("images/statsbomb.jpg",  x = 0.34, y = 0.45, scale = 0.15)

presion

ggsave('ejercicios/leicester_campeon/graficos/zona_presion_premier_15_16.png', width = 12, height = 10)

# ---------------- zonas de presion segun el contexto ------------------------
zonas_presion_context = read_csv('data/pressures_licester_context_premier_15_16.csv') %>% clean_names()

gird_zone_x = gird_zones() %>%
  mutate(zone_x = as.double(str_remove( zone, "-.*")))

zonas_presion_context = left_join(zonas_presion_context, gird_zone_x, by = "zone_x") %>%
  group_by(zone_x) %>%
  mutate(agv_zone = round(mean(presion)),
         avg_context = presion-agv_zone)

zpc <- get_pitch(gp = ggplot(data = zonas_presion_context)) +
  geom_rect(aes(xmin = x1, xmax = x2, ymin = y1, ymax = y2, fill = avg_context), col = "grey50", alpha = 0.7) +
  scale_fill_gradient2(high = "red", low = "blue") +
  facet_wrap(~contexto, ncol = 3) +
  theme(legend.position = "bottom",
        legend.margin = margin(t = 0.4, unit = "cm"),
        plot.background = element_rect(fill = "white", colour = "transparent"),
        text = element_text(family = 'firasans', colour = "black", size = 40),
        plot.margin = margin(0.7, 1, 0.5, 0.5, "cm"),
        plot.caption = element_text(margin = margin(5, 0, 0, 0)),
        plot.title = element_text(margin = margin(b = 0.2, unit = "cm")),
        plot.subtitle = element_text(margin = margin(b = 1, unit = "cm"))) +
  labs(fill = "Frecuencia en las zonas de presión",
       title = "Presiones más altas/más bajas del Leicester según el contexto del partido en cada zona",
       subtitle = "Premier 2015/2016") 
  
  
  zpc <- ggdraw() +
  draw_plot(zpc) +
  draw_image("images/statsbomb.jpg",  x = 0.34, y = 0.45, scale = 0.15)

zpc

ggsave('ejercicios/leicester_campeon/graficos/zona_presion_context_leicester.png', width = 18, height = 8)
  
# ------------------------ tiempo de posesión segun contexto ----------------
posesion_context = read_csv('data/tiempo_posesion_contexto_licester_context_premier_15_16.csv') %>% clean_names()
COL_TEXT_LINES = "grey90"

# Gráfico de barras agrupadas
posesion <- ggplot(data = posesion_context, aes(x = fct_reorder(team, poss_percent), y = poss_percent, fill = contexto)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9), col = "transparent" , alpha = 0.7, width = 0.8) + 
  coord_flip() +
  theme_bw() +
  scale_fill_brewer(palette = "Set1") +
  # textos
  labs(x = "\nEquipos", y = "Porcentaje (%) de posesión según contexto\n",
       title = "Porcentajes de posesión de los equipos según contexto (Ganando, Perdiendo, Empatando)",
       subtitle = "Premier 2015/2016\n",
       caption = "@dhernandez_dev  |  Data: understat") +
  # escalar el grafico  
  scale_y_continuous(breaks = seq(0, 70, 10), labels = seq(0, 70, 10), limits = c(0, 70)) +
  # tema
  theme(panel.background = element_rect(fill = "#252525", colour = COL_TEXT_LINES),
        plot.background = element_rect(fill = "#252525", colour = "transparent"),
        panel.grid.minor.x = element_blank(),
        panel.grid = element_line(colour = "grey50", size = 0.1),
        axis.ticks = element_line(colour = COL_TEXT_LINES),
        axis.text = element_text(colour = COL_TEXT_LINES),
        title = element_text(colour = COL_TEXT_LINES),
        text = element_text(family = 'firasans', colour = COL_TEXT_LINES, size = 45),
        plot.margin = margin(1, 1, 1, 0.5, "cm"),
        legend.position = "bottom",
        legend.text = element_text(size = 45),
        legend.title = element_text(size = 55),
        legend.background = element_rect(fill = "#252525"))

posesion

ggsave('ejercicios/leicester_campeon/graficos/posesion_context_premier.png', width = 15, height = 18)


