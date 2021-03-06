# This function take a prevalence "string", a directory with text files (in this case with the follow-up items),
# an output directory to print the follow-up items with prevalence, and a logic value to set if placeholder removal
# remove_placeholders()

prev2followUp <- function(prevalence_string, follow_up_dir, outputdir, rmv_placeholders) {
  
  # BUILD POSSIBLE CONTEXTS, PRESENTATION FORMATS, AND PPV PROBS
  # presentation formats
  possible_presentation_formats <- paste0(dir("materials/Presentation_format/"), collapse = "|")
  # problem contexts
  possible_contexts <- read_csv("materials/Problem_context/problem_context_info.csv", col_types = cols()) %>% select(-code_name) %>% names
  # possible probabilities
  possible_probs <- unique(readxl::read_xls("materials/Numbers/numbers_bayes.xls")$prob)[!is.na(unique(readxl::read_xls("materials/Numbers/numbers_bayes.xls")$prob))]
  # ppv probabilities
  possible_probs <- 
    readxl::read_xls("materials/Numbers/numbers_bayes.xls")$prob %>% 
    unique()
  possible_probs <- 
    possible_probs[!is.na(possible_probs)]
  
  # this_prev <- unique_prevalences[[2]]
  this_prev <- prevalence_string
  this_prev_nameless <- gsub("\\*\\*.*\\*\\*(.*)", "\\1", this_prev)
  this_prev_name <- gsub("\\*\\*(.*)\\*\\*.*", "\\1", this_prev)
  this_prev_context <- gsub(paste0("\\*\\*(", possible_contexts,").*", collapse = "|"), "\\1\\2", this_prev)
  this_prev_ppvProb <- gsub(paste0(".*(ppv", possible_probs, ").*", collapse = "|"), "\\1\\2", this_prev)
  this_prev_format <- gsub(paste0(".*(", possible_presentation_formats, ").*"), "\\1", this_prev)
  
  # sumsample follow-up items by context
  # followUp_dir <- "materials/Question/Follow_up/output/"
  followUp_dir <- follow_up_dir
  followUp_files <- paste0(followUp_dir,dir(followUp_dir, pattern = ".txt"))
  followUps_paths <- grep(this_prev_context, followUp_files, value = TRUE)
  followUps_items <- followUps_paths %>% map(~readChar(.x, nchars = file.info(.x)$size))
  
  # replace prevalence placeholder with this prevalence
  followUps_items_prev <- 
    followUps_items %>% 
    gsub("prevalence_and_context", this_prev_nameless, .) %>% # insert prevalence within follow-up item
    gsub("(\\*\\*\\*.*)(\\*\\*\\*)(.*)", # update name
         paste0("\\1_", 
                this_prev_ppvProb, "_", # ppv low or high
                this_prev_format, "\\2\\3"), .) # presentation format
  
  # export follow-up items
  dir.create(outputdir, showWarnings = FALSE, recursive = TRUE)
  
  if (rmv_placeholders == TRUE) {
    followUps_items_prev %>% 
      remove_placeholders(., "followup") %>% 
      map(~cat(
        gsub("\\*\\*\\*.*\\*\\*\\*\\n\\n(.*)", "\\1", .x), # follow-up item without name
        file = paste0(outputdir, # path to output dir (probably qualtrics folder)
                      gsub("\\*\\*\\*(.*)\\*\\*\\*.*", "\\1", .x), ".txt"))) %>% # follow-up item name
      invisible()
  } else if (rmv_placeholders == FALSE) {
    followUps_items_prev %>% 
      map(~cat(
        gsub("\\*\\*\\*.*\\*\\*\\*\\n(.*)", "\\1", .x), # follow-up item without name
        file = paste0(outputdir, # path to output dir (probably qualtrics folder)
                      gsub("\\*\\*\\*(.*)\\*\\*\\*.*", "\\1", .x), ".txt"))) %>% # follow-up item name
      invisible()
  }
}