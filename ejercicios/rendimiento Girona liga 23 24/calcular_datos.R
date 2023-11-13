library(readr)
library(janitor)
library(dplyr)
library(jsonlite)


# leer los datos
liga_23_24 = read_delim('data/understat_liga_23_24_games.csv', delim = ';') %>% clean_names()

# REAJUSTAR PPDA

# Reemplazar comillas simples con comillas dobles
liga_23_24$ppda <- gsub("'", '"', liga_23_24$ppda)
liga_23_24$ppda_allowed <- gsub("'", '"', liga_23_24$ppda_allowed)

# Convertir cadenas JSON a listas
ppda_lista <- lapply(liga_23_24$ppda, fromJSON)
ppda_allowed_lista <- lapply(liga_23_24$ppda_allowed, fromJSON)

# Extraer valores de "att"
att_ppda <- sapply(ppda_lista, function(x) x$att)
def_ppda <- sapply(ppda_lista, function(x) x$def)

att_ppda_allowed <- sapply(ppda_allowed_lista, function(x) x$att)
def_ppda_allowed <- sapply(ppda_allowed_lista, function(x) x$def)

liga_23_24 = liga_23_24 %>%
              mutate(ppda_att = att_ppda,
                     ppda_def = def_ppda,
                     ppda_allowed_att = att_ppda_allowed,
                     ppda_allowed_def = def_ppda_allowed)

# GRAFICA xG a favor y xG en contra
data_teams = liga_23_24 %>%
          group_by(title) %>%
          summarise(total_xg = sum(x_g),
                    total_xg_a = sum(x_ga),
                    goals = sum(scored),
                    goals_againts = sum(missed),
                    ppda = att_ppda/def_ppda,
                    ppda_allowed = att_ppda_allowed/def_ppda_allowed)
            