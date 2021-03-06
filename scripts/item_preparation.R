# Items preparation


# Packages and functions  --------------------------------------------------------------

  # Packages
  if (!require('pacman')) install.packages('pacman'); library('pacman')
  p_load(tidyverse, magick, png, grid, magrittr)
  
  # Functions
  source("functions/numbers2problems.R")
  source("functions/svg2png.R")
  source("functions/textItem2list.R")
  source("functions/ppv_calculator.R")

# Prepare items -----------------------------------------------------------

  # text-only
  source("scripts/textonly_item_prep.R")
  
  # fact-box
  source("scripts/fbpi_item_prep.R")
  
  # new-paradigm
  source("scripts/nppi_item_prep.R")
