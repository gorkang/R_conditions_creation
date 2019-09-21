# Packages
if (!require('pacman')) install.packages('pacman'); library('pacman')
p_load(tidyverse, magrittr)

short_name <- "com"
# Qualtrics and html resources
source("scripts/html_qualtrics_codes.R")

# Qualtrics tags template to wrapp around
# Instructions
ins_wrapper <- 
  '[[Question:Text]]\n[[ID:replaceID]]\n<span style="font-size:Q_FONT_SIZEpx;">ITEM</span>'
# items
item_wrapper <- 
  '[[Question:MC:SingleAnswer:Horizontal]]
[[ID:replaceID]]
<span style="font-size:Q_FONT_SIZEpx;">ITEM</span>
[[Choices]]
<span style="font-size:0px;">delete_this</span>'

item_wrapper_last <- 
  '[[Question:Text]]
[[ID:replaceID]]
<span style="font-size:Q_FONT_SIZEpx;">ITEM</span>'


# see what's going on.
# item_wrapper %>% cat()

# read items
comprehension <- 
  paste0("materials/Question/Comprehension/input/comprehension.txt") %>%
  readChar(., file.size(.)) %>% 
  gsub("\\n$", "", .) %>% 
  str_split(., "\\n") %>% 
  unlist()

# Wrapping -----------------------------------------------------------


# instructions
comprehension <-
  c("Please, read the description of the test one last time.<br><br>",
    gsub("ITEM", comprehension[1], ins_wrapper),                   # instructions
    str_replace_all(item_wrapper, "ITEM", comprehension[c(-1,-length(comprehension))]),  # items
    str_replace_all(item_wrapper_last, "ITEM", comprehension[length(comprehension)])) %>%  # items
  
  str_replace_all(string = ., pattern = "replaceID",  # put question IDs
                  replacement = c(paste0(short_name, "_ins"), paste0(short_name, "_Q", sprintf("%02d", seq(length(.)-1)), "_0"))) %>% 
  
  gsub("Q_FONT_SIZE", 22, .) %>% # Change Questions Font size
  gsub("C_FONT_SIZE", 16, .)       # Change choice Font size


last_quest_num <- sprintf('%02d', as.integer(gsub('.*com_Q([0-9]{2}).*', '\\1', comprehension[length(comprehension)])) + 1)

# Create 3 empty text entry questions for "__ out of __" and "__%"
question_type_extra <-
  paste(qualtrics_codes$question_textentry, 
        questioIDme(sprintf("com_Q%s_01_0", last_quest_num)), 
        " ", 
        qualtrics_codes$question_textentry, 
        questioIDme(sprintf("com_Q%s_02_0", last_quest_num)), 
        " ", 
        qualtrics_codes$question_textentry, 
        questioIDme(sprintf("com_Q%s_03_0", last_quest_num)), 
        " ", 
        sep = "\n")

# # manual modification to question 8
# comprehension[10] <- 
#   comprehension[10] %>% 
#   gsub("MC.*?tal", "Text", .) %>% 
#   gsub("\n\\[{2}Choi.*span>", "", .)

# Export ---------------------------------------------------------------

# Output dir
output_dir <- 
  paste0("materials/qualtrics/output/plain_text/comprehension") %T>% 
  dir.create(., FALSE, TRUE)

# print text file
comprehension %>% 
  paste(., collapse = "\n") %>%
  paste(., question_type_extra, sep = "\n") %>% 
  cat(., file = file.path(output_dir, "comprehension.txt"))
