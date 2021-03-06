# PREVALENCES #################################
# Create pictorial prevalences
source("scripts/create_pictorial_prevalences.R")
###############################################

# Read prevalences
prevalences <- 
  "materials/qualtrics/output/plain_text/prevalences" %>% 
  dir(., ".txt", full.names = TRUE) %>% 
  map_chr(~readChar(.x, file.size(.x)))

# example of possible answers to put on follow up display (Probably a good idea to check is this answers make any sense)
example_answer <- c("20", "11%")
# get a prevalence randomly
random_prevalence <- prevalences[round(runif(1, 1, length(prevalences)))] %>% gsub("\\*{2}.*?\\*{2}", "", .)
# get example answer according to selected prevalence (check if probability format or natural frequencies)
random_answer <- case_when(!grepl("_pr[a-z]{2}_", random_prevalence) ~ example_answer[1],
                           grepl("_pr[a-z]{2}_", random_prevalence) ~ example_answer[2])

# To fill ED data fields
fillers <- read_csv("materials/fillers.csv", col_types = "cccc") %>% 
  mutate(ca_pr = paste(ca, pr, sep = "/"))

fu_risk <- readxl::read_xls("materials/Numbers/numbers_bayes.xls") %>% 
  filter(format == "fu") %>% pull(fu_risk) %>% paste(., collapse = "/")

"materials/qualtrics/output/plain_text/followup/fu_unified.txt" %>% 
  readChar(., file.size(.)) %>% gsub("\\[{2}ID\\:([a-zA-Z_0-9]*)\\]{2}", "**\\1**", .) %>% 
  
  # Remove and replace
  gsub("<br>" ,"\n", .) %>%          # replace html linebreak with generic linebreak (R linebreak?)
  gsub("\n<ul>" ,"  \n", .) %>%       # replace list html tag
  gsub("<.?ul>" ,"", .) %>%       # replace list html tag
  gsub("<li>" ,"", .) %>%   # replace between list elements with linebreaks
  gsub("</li>" ,"  \n", .) %>%    # replace between list elements with linebreaks
  
  gsub('<span style="font-size\\:[0-9]{1,2}px;">', "", .) %>%  # remove html font size formating
  gsub('</span>', "", .) %>%                # remove html format end
  gsub("\\[{2}.*?\\]{2}\\n", "", .) %>% # remove choices placeholder
  # gsub("\\[{2}Choices\\]{2}\\n", "", .) %>% # remove choices placeholder
  # gsub("\\[{2}PageBreak\\]{2}\\n", "", .) %>% # remove pagebreak placeholder 
  # gsub("\\[{2}Question.*?\\]{2}\\n", "", .) %>% # remove question placeholder
  gsub("DELETE_THIS", "", .) %>% # remove DELETE_THIS placeholder
  
  # Fill ED data fields
  gsub("\\$\\{e\\://Field/fu_risk_num_0\\}", fu_risk, .) %>% 
  gsub("\\$\\{e\\://Field/medical_condition_0\\}",    fillers$ca_pr[fillers$field_name == "medical_condition"], .) %>% 
  gsub("\\$\\{e\\://Field/medical_consequence_0\\}",  fillers$ca_pr[fillers$field_name == "medical_consequence"], .) %>% 
  gsub("\\$\\{e\\://Field/positive_test_result_0\\}", fillers$ca_pr[fillers$field_name == "positive_test_result"], .) %>%
  gsub("\\$\\{e\\://Field/doctor_offers_0\\}",        fillers$ca_pr[fillers$field_name == "doctor_offers"], .) %>% 
  gsub("\\$\\{e\\://Field/fluid_test_0\\}",           fillers$ca_pr[fillers$field_name == "fluid_test"], .) %>% 
  gsub("\\$\\{e\\://Field/test_name_0\\}",            fillers$ca_pr[fillers$field_name == "test_name"], .) %>%
  gsub("\\$\\{e\\://Field/should_she_0\\}",            "[[NOT]]", .) %>%
  gsub("\\$\\{e\\://Field/medical_test_0\\}",            fillers$ca_pr[fillers$field_name == "medical_test"], .) %>% 
  gsub("\\$\\{e\\://Field/followup_bad_0\\}",            fillers$ca_pr[fillers$field_name == "followup_bad"], .) %>% 
  
  gsub("\\$\\{e\\://Field/prevalence_0\\}",           random_prevalence, .) %>%  # Prevalence
  gsub("\\$\\{e\\://Field/ppv_response_0\\}",         random_answer, .) %>%  # Example answer
  
  gsub("\\$\\{e\\://Field/shoShe_fu_0\\}",         "[[NOT]]", .) %>%  # Should she take the followup test?
  
  
  # Double linebreaks because bookdown displaying is weird (one linebreak doesn't work, two linebreaks actually creates two linebreaks)
  gsub("\\n", "\n\n", .) %>% 
  cat(., "  \n  \n ______________________  \n")

# Print prevalences
prevalences %>% 
  gsub("([a-z]\\*{2})", "\\1: ", .) %>% cat("**PREVALENCES**:  \n", ., sep = "  \n")

