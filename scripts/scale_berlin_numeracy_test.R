# Packages
if (!require('pacman')) install.packages('pacman'); library('pacman')
p_load(tidyverse, magrittr)

# get this scale info
this_scale <- 
  scale_names %>% filter(long_name == "berlin_numeracy_test")

# Names
long_name <- this_scale$long_name
short_name <- this_scale$short_name

# Template reading and handling
numeracy_scale <-
  paste0("materials/Scales/input/", long_name,".txt") %>%
  readChar(., file.size(.)) %>% # Read text file
  str_split(., "\n__QSEP__\n") %>% # Separate questions
  unlist() %>% as.list() %>% # Flatten questions list
  str_replace_all(string = ., 
                  pattern = "replaceID", 
                  replacement = c(paste0(short_name, "_ins"), paste0(short_name, "_", sprintf("%02d", seq(length(.)-1))))) %>% 
  gsub("Q_FONT_SIZE", question_size, .) %>% # Change Questions Font size
  gsub("C_FONT_SIZE", choice_size, .) # Change Choices Font size

# Output dir
output_dir <- 
  paste0("materials/qualtrics/output/plain_text/scales/", long_name) %T>% 
  dir.create(., FALSE, TRUE)

# Export

numeracy_scale %>%
  paste(., collapse = paste0('\n', qualtrics_codes$pagebreak, '\n')) %>% 
  cat(qualtrics_codes$advanced_format, 
      qualtrics_codes$block_start %>% gsub("block_name", long_name, .),
      ., sep = "\n", 
      file = file.path(output_dir, paste0(long_name, ".txt")))

