# Modelo de recomendacion de jugadores

-   explicar un poco de que trata el modelo de recomendación de jugadores
-   explicar modelo de juego del equipo de fantasia y que tipo de jugadores (delanteros) necesita
-   explicar los pasos
    -   obtener estadisticas de los jugadores
    -   pasar esas estadisticas a p90 (excepto valores porcentuales)
    -   obtener percentiles de esas metricas segun filtros del club
    -   generar el score
    -   comparar top5 jugadores y explicar por que elegir esos top5
-   explicar futuros crecimientos de este modelo y como puede aportar al equipo y a los analistas

### consideraciones:

-   la calidad de estos analisis van a depender en gran medida de los datos disponibles, mientras mas informacion util se tenga, mas potencial se puede tener en cada analisis
-   este modelo de recomendacion o cualquier otro modelo no busca saltar ni omitir ningun rol dentro del scouting sino optimizar recursos junto con mejorar y generar una mayor confianza en la busqueda de jugadores según lo que el club necesite
-   el modelo está basado en el proyecto data azul (y ahi explicar y hacer referencia al proyecto)

------------------------------------------------------------------------

El objetivo del modelo, es entregar una lista de jugadores que cumplan con ciertos criterios para cada posicion previamente definidos por la secretaría técnica y el club, tales como superar un umbral de minutos jugados y tengan un rendimiento sobresaliente. Para esto, a cada jugador se le asignará un puntaje segun su posicion y el rendimiento que tenga esos criterios.

## Necesidades del club

Para fines didáticos tenemos a Melodia FC (club de fantasía) que necesita para mejorar su plantilla un delantero centro que no pase de 30 años y se adapte al estilo de juego del club. Para esto se va a aplicar el modelo de recomendación de jugadores para recomendarle al scout al menos 5 jugadores que puedan en cajar en el club y así facilitar el proceso de busqueda y fichaje de ese delantero. Hay que tener en cuenta que se va a buscar este jugador en la Premier League, debe haber jugador al menos el 30% de los minutos posibles y no se va a tener un límite de presupuesto.

| **Defensa Central**                | **Laterales**                      | Volante Central                    | **Volante Interior**               | **Extremo**                       | **Delantero Centro**              |
|---------|---------|---------|---------|---------|---------|
| \% duelos aéreos ganados (40%)     | \% centros precisos (40%)          | pases claves precisos (35%)        | pases claves precisos (30%)        | \% duelos ganados (30%)           | diferencia Goles - xG (25%)       |
| \% duelos defensivos ganados (30%) | \% duelos defensivos ganados (30%) | \% duelos defensivos ganados (25%) | intercepciones (20%)               | \% centros precisos (30%)         | \% tiros al arco (25%)            |
| \% pases precisos (10%)            | \% duelos ofensivos ganados (20%)  | \% centros precisos (20%)          | xA (20%)                           | xG (15%)                          | \% duelos aéreos ganados (25%)    |
| pases claves precisos (10%)        | xA (10%)                           | intercepciones (10%)               | \% duelos defensivos ganados (15%) | xA (15%)                          | xA (15%)                          |
| faltas cometidas (10%)             |                                    | xA (10%)                           | xA (15%)                           | \% duelos defensivos ganados (5%) | \% duelos defensivos ganados (5%) |
|                                    |                                    |                                    |                                    | intercepciones (5%)               | intercepciones (5%)               |
