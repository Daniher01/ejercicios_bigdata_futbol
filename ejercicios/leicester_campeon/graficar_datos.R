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
       title = "Rendimiento xG - Goles ",
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
