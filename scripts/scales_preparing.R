# Packages
if (!require('pacman')) install.packages('pacman'); library('pacman')
p_load(tidyverse, magrittr, mgsub)

# Qualtrics and html resources
source("scripts/html_qualtrics_codes.R")

# Font sizes
question_size = "22"
choice_size = "16"

# Scales names
scale_names <- 
  read_csv("materials/Scales/scale_names.csv", col_types = "cccic")

# a_priori_screening_belief ##################################
source("scripts/scale_a_priori_screening_belief.R")
# beck_anxiety_inventory #####################################
source("scripts/scale_beck_anxiety_inventory.R")
# big_five_inventory #########################################
source("scripts/scale_big_five_inventory.R")
# cognitive_reflection_test_7 ################################
source("scripts/scale_cognitive_reflection_test_7.R")
# crt_verbal #################################################
source("scripts/scale_crt_verbal.R")
# general_decision_making_style ##############################
source("scripts/scale_general_decision_making_style.R")
# abbreviated_math_anxiety_rating_scale ######################
source("scripts/scale_abbreviated_math_anxiety_rating_scale.R")
# multiple_stim_types_ambiguity_tolerance_scale ##############
source("scripts/scale_multiple_stim_types_ambiguity_tolerance_scale.R")
# need_for_cognition #########################################
source("scripts/scale_need_for_cognition.R")
# lipkus_numeracy_scale ######################################
source("scripts/scale_lipkus_numeracy_scale.R")
# probabilistic_reasoning_scale ##############################
source("scripts/scale_probabilistic_reasoning_scale.R")
# risk_avoidance_scale #######################################
source("scripts/scale_risk_avoidance_scale.R")
# risk_propensity_scale ######################################
source("scripts/scale_risk_propensity_scale.R")
# shared_decision_making #####################################
source("scripts/scale_shared_decision_making.R")
# severity_emotional_reaction_scale ##########################
source("scripts/scale_severity_emotional_reaction.R")
# sociodemographic_scale #####################################
source("scripts/scale_sociodemographic_scale.R")
# subjective_numeracy_scale ##################################
source("scripts/scale_subjective_numeracy_scale.R")
# tolerance_of_ambiguity #####################################
source("scripts/scale_tolerance_of_ambiguity.R")
# previous_experience
source("scripts/previous_experience.R")

# PRINT SCALES (BOOK)
# this vector with paths set the scales to be printed

# Scales
scales2print <- 
  "materials/qualtrics/output/plain_text/scales/" %>% dir(., full.names = TRUE)

source("scripts/print_scales.R")
