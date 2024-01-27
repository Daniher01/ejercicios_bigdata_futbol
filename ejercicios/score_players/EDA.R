### TABLA SEGUN MODELO DE JUEGO
# ARQUERO
arquero <- list(c("arquero", "xG en contra", 0.4),
                c("arquero", "% duelos aereos ganados", 0.3),
                c("arquero", "% pases cortos correctos", 0.2),
                c("arquero", "% pases largos correctos", 0.1))


# DEFENSA CENTRAL
defensa_central <- list(c("defensa central", "% duelos aereos ganados", 0.4),
                        c("defensa central", "% duelos aereos defensivos ganados", 0.3),
                        c("defensa central", "% pases cortos correctos", 0.1),
                        c("defensa central", "% pases largos correctos", 0.1),
                        c("defensa central", "faltas cometidas", 0.1))

# LATERALES
laterales <- list(c("laterales", "% centro correctos", 0.4),
                  c("laterales", "% duelos defensivos ganados", 0.3),
                  c("laterales", "% duelos ofensivos ganados", 0.2),
                  c("laterales", "% duelos aereos defensivos ganados", 0.1))

# VOLANTE CENTRAL
volante_central <- list(c("volante central", "% pases hacia adelante", 0.35),
                        c("volante central", "% Duelos defensivos ganados", 0.25),
                        c("volante central", "% balones largos correctos", 0.2),
                        c("volante central", "intercepciones", 0.1),
                        c("volante central", "xG", 0.1))

# VOLANTE INTERIOR
voalante_interior <- list(c("volante interior", "% pases hacia adelante", 0.3),
                        c("volante interior", "intercepciones", 0.2),
                        c("volante interior", "asistencias", 0.2),
                        c("volante interior", "% duelos defensivos ganados", 0.15),
                        c("volante interior", "xG", 0.15))

# VOLANTE OFENSIVO
volante_ofensivo <- list(c("volante ofensivo", "asistencias", 0.3),
                         c("volante ofensivo", "xG", 0.3),
                         c("volante ofensivo", "goles", 0.2),
                         c("volante ofensivo", "% duelos ofensivos ganados", 0.2))

# EXTREMO
extremo <- list(c("extremo", "% duelos ofensivos ganados", 0.3),
                c("extremo", "% centros correctos", 0.3),
                c("extremo", "xG", 0.15),
                c("extremo", "asistencias", 0.15),
                c("extremo", "% duelos defenvios ganados", 0.05),
                c("extremo", "intercepciones", 0.05))

# DELANTERO CENTRO
delantero_centro <- list(c("delantero centro", "diferencia goles - xG", 0.25),
                         c("delantero centro", "% remates al arco", 0.25),
                         c("delantero centro", "% duelos aereos ganados", 0.25),
                         c("delantero centro", "asistencias", 0.15),
                         c("delantero centro", "% duelos defenvios ganados", 0.05),
                         c("delantero centro", "intercepciones", 0.05))



modelo_juego <- data.frame(posicion = c(sapply(arquero, "[[", 1), sapply(defensa_central, "[[", 1), sapply(laterales, "[[", 1), sapply(volante_central, "[[", 1), sapply(voalante_interior, "[[", 1), sapply(volante_ofensivo, "[[", 1), sapply(extremo, "[[", 1), sapply(delantero_centro, "[[", 1)),
                 metrica = c(sapply(arquero, "[[", 2), sapply(defensa_central, "[[", 2), sapply(laterales, "[[", 2), sapply(volante_central, "[[", 2), sapply(voalante_interior, "[[", 2), sapply(volante_ofensivo, "[[", 2), sapply(extremo, "[[", 2), sapply(delantero_centro, "[[", 2)),
                 valor = c(sapply(arquero, "[[", 3), sapply(defensa_central, "[[", 3), sapply(laterales, "[[", 3), sapply(volante_central, "[[", 3), sapply(voalante_interior, "[[", 3), sapply(volante_ofensivo, "[[", 3), sapply(extremo, "[[", 3), sapply(delantero_centro, "[[", 3)))

# verificar que la suma de los valores por poscision los valores no sean mayores a 1
modelo_juego$posicion = as.factor(modelo_juego$posicion)
modelo_juego$valor = as.numeric(modelo_juego$valor)

library(dplyr)
modelo_juego %>% group_by(posicion) %>% summarise(valor = sum(valor))


library(readxl)
library(janitor)
events_premier = read.csv('data/statsbomb_premier_15_16_events.csv') %>% clean_names()


events_premier %>% group_by(player_name, position_name) %>%
  summarise(n = n())
