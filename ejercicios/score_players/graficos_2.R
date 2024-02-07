library(fmsb)
library(dplyr)
library(janitor)

data_players = read.csv("ejercicios/score_players/data_score/modelo2/score_F.csv") %>% clean_names() %>% head(3)


# Agregar una fila con todos los valores 1
fila_1 <- rep(1, ncol(data_players))

# Agregar una fila con todos los valores 0
fila_2 <- rep(0, ncol(data_players))

# Agregar las filas al inicio del dataframe
data_players <- rbind(fila_1, fila_2, data_players)

# Colores de las áreas
areas <- c(rgb(1, 0, 0, 0.25),
           rgb(0, 1, 0, 0.25),
           rgb(0, 0, 1, 0.25))

# Establecer el tamaño del gráfico
par(mar = c(5, 5, 2, 2))  # Ajusta los márgenes superior, derecho, inferior e izquierdo

radarchart(data_players %>% select(ends_with("percentil")), 
           title = "Score",
           axistype = 1,
           vlcex = 0.8,
           cglty = 1,       # Tipo de línea del grid
           cglcol = "gray", # Color líneas grid
           pcol = 2:4,      # Color para cada línea
           plwd = 2,        # Ancho para cada línea
           plty = 1,        # Tipos de línea
           pfcol = areas)   # Color de las áreas


leyenda_data = data_players %>% slice(-c(1, 2))
# Agregar leyenda con los nombres de los jugadores
legend("topright", legend = paste(leyenda_data$player_name, leyenda_data$score), fill = areas, title = "Players", cex = 1, bty = "n")

