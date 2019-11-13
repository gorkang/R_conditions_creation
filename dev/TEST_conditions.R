library(tidyverse)
XXX = list.files("/home/emrys/gorkang@gmail.com/RESEARCH/PROYECTOS/2017 - Gorka - Fondecyt_NO_SHARED/Experimentos/Experimento 1/R_conditions_creation/materials/qualtrics/output/plain_text/embedded_data_blocks")

DF = XXX %>% enframe() %>% 
  separate(
    sep = "_",
    col = value,
    into = c(
      "format",
      "response",
      "problem1",
      "high_low1",
      "problem2",
      "high_low2",
      "risk1",
      "risk2"
    )
  )


DF %>% 
  group_by(format, response, problem1, high_low1, problem2, high_low2, risk1, risk2) %>%
  summarise(n = n()) %>% View
