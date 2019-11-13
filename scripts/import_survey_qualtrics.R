# TODO (?)

# COG SCALES RANDOMIZER N20
# PER SCALES RANDOMIZER N27


# Libraries ---------------------------------------------------------------


  if (!require('pacman')) install.packages('pacman'); library('pacman')
  # devtools::install_github("datawookie/emayili")
  p_load(beepr, emayili)

  source(here::here("R/qualtrics_start_docker.R"), local = TRUE)
  source("R/qualtrics_remove_blocks.R")
  source("functions/remove_surveyflow_elements.R")
  source("functions/UBER_IMPORT2QUALTRICS_miro.R")
  source(here::here("R/qualtrics_move_ED_blocks.R"), local = TRUE)
  source("functions/send_email.R", local = TRUE)

  
  options(error = beep(sound = 7))
  
  
# Start docker ------------------------------------------------------------

  qualtrics_start_docker()

# Import Embedded data blocks --------------------------------------------------
  
  # Dir with ED blocks
  full_path <- "materials/qualtrics/output/plain_text/embedded_data_blocks"
  
  file_paths <- full_path %>% dir(., ".txt") %>% file.path(selenium_path, full_path, .)
  
  # Iteration counter
  Q_counter <- 0
  
  # UPLOAD!
  UBER_IMPORT2QUALTRICS_miro(file_paths)
  time_embedded = tictoc::tic.log()
  mean(as.numeric(gsub(" sec elapsed", "", time_embedded %>% unlist())))
  

# DELETE UNNECESARY BLOCKS ------------------------------------------------

  # Aun Falla algunas veces (1/75). 
  qualtrics_remove_blocks(start_on = 1, survey_type = "miro", debug_it = TRUE)
  remDr$refresh()
    
  
# Move ED blocks ---------------------------------------------------------

  # ZOOM TO MINIMUM in FIREFOX (Not needed any more?)
  # Very heavy on RAM. Try with other browser (Chrome too slow)? START A NEW DOCKER
  # qualtrics_start_docker()
  
  qualtrics_move_ED_blocks(start_on = 0)
  XXX = tictoc::tic.log()
  DF_XXX = as.numeric(gsub(" sec elapsed", "", XXX %>% unlist())) %>% as_tibble()
  mean(as.numeric(gsub(" sec elapsed", "", XXX %>% unlist())))
  
  # source("R/qualtrics_move_ED_blocks_OLD.R")
  # qualtrics_move_ED_blocks_OLD(start_on = 0)
  # XXX_OLD = tictoc::tic.log()
  mean(as.numeric(gsub(" sec elapsed", "", XXX_OLD %>% unlist())))

  

# Experiment description  ------------------------------------------------------------

file_paths <- 
  file.path(selenium_path, "materials/qualtrics/output/plain_text/exp_design/experiment_design.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)


# Pilot warning ------------------------------------------------------------

file_paths <- 
  file.path(selenium_path, "materials/qualtrics/output/plain_text/pilot_warning/pilot_warning.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)

# Consent form ------------------------------------------------------------

file_paths <- 
  paste0(selenium_path, "/materials/qualtrics/output/plain_text/consent_form/consent_form.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)

# Sociodemographics -----------------------------------------------------------

file_paths <- 
  file.path(selenium_path, "/materials/qualtrics/output/plain_text/scales/sociodemographic_scale/sociodemographic_scale.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)

# A priori screening belief -----------------------------------------------------------

file_paths <- 
  file.path(selenium_path, "materials/qualtrics/output/plain_text/scales/a_priori_screening_belief/a_priori_screening_belief.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(5)


# Severity emotional reaction scale -----------------------------------------------------------

file_paths <- 
  file.path(selenium_path, "materials/qualtrics/output/plain_text/scales/severity_emotion_scale/severity_emotion_scale.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(5)


# Screening block -----------------------------------------------------------

file_paths <- 
  file.path(selenium_path, "/materials/qualtrics/output/plain_text/screening_blocks/complete/screenings_blocks.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(10)


# Cognitive scales INSTRUCTIONS --------------------------------------------------

file_paths <- 
  file.path(selenium_path, "/materials/qualtrics/output/plain_text/scales_instructions/cog_scales_ins.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(10)



# Import COGNITIVE scales --------------------------------------------------

# Cognitive scales 
cog_scales <- 
  read_csv("materials/Scales/scale_names.csv") %>% 
  filter(per_cog == "cog") %>% select(long_name) %>% 
  pull() %>% paste0("materials/qualtrics/output/plain_text/scales/", .)

cog_scales_path <- 
  cog_scales %>% 
  map(~dir(.x, pattern = ".txt", full.names = TRUE)) %>% 
  unlist()

file_paths <- cog_scales_path

# full absolute paths
file_paths <- file.path(selenium_path, file_paths)

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(10)


# Personality scales INSTRUCTIONS --------------------------------------------------

file_paths <- 
  file.path(selenium_path, "/materials/qualtrics/output/plain_text/scales_instructions/per_scales_ins.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(10)


# Personality scales -------------------------------------------------------------- 

per_scales <- 
  read_csv("materials/Scales/scale_names.csv") %>% 
  filter(per_cog == "per") %>% select(long_name) %>% 
  pull() %>% paste0("materials/qualtrics/output/plain_text/scales/", .)

per_scales_path <- 
  per_scales %>% 
  map(~dir(.x, pattern = ".txt", full.names = TRUE)) %>% 
  unlist()

file_paths <- per_scales_path

# full absolute paths
file_paths <- file.path(selenium_path, file_paths)

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(10)

# Previous experience -----------------------------------------------------------

file_paths <- 
  file.path(selenium_path, "materials/qualtrics/output/plain_text/previous_experience/previous_experience.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(10)


# Comments -----------------------------------------------------------

file_paths <- 
  file.path(selenium_path, "materials/qualtrics/output/plain_text/comments/comments.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(10)


# survey effort -----------------------------------------------------------

file_paths <- 
  file.path(selenium_path, "materials/qualtrics/output/plain_text/survey_effort/survey_effort.txt")

# Iteration counter
Q_counter <- 0

# UPLOAD!
UBER_IMPORT2QUALTRICS_miro(file_paths)
Sys.sleep(10)





# FINISH ------------------------------------------------------------------

  # send_email(to_email = "gorka.navarrete@uai.cl",
  #            type = "end",
  #            password_mail)
