# Possible contexts 
possible_contexts <- 
  textual_formats %>% 
  map(~dir(paste0("materials/Presentation_format/", .x, "/input")) %>% 
        gsub("([a-z]{2}).*", "\\1", .)) %>% 
  unlist %>% 
  unique()

# Pictoric presentation formats -------------------------------------------

# read csv with number
numbers_item <-
  readxl::read_xls("materials/Numbers/numbers_bayes.xls")

# Convert svg templates to png templates ----------------------------------

# path to factboxs templates
newparadigm_template_dir <- "materials/Presentation_format/nppi/input/template/svg/"

# factboxs templates files
newparadigm_templates <- dir(newparadigm_template_dir, pattern = ".svg")

# svg to png parameters (to feed svg2png)
template_width <- 689 # pixels
template_height <- template_width*1.38897 # pixels

# input/output dir
input_dir <- newparadigm_template_dir
output_dir <- "materials/Presentation_format/nppi/input/template/png/"

# If Folder does not exist, create it
dir.create(file.path(output_dir), showWarnings = FALSE, recursive = TRUE)

# convert svg to png
# parameters
width <- template_width
height <- template_height
# convert
walk(newparadigm_templates, svg2png)

# newparadigm png dir
newparadigm_dir <- output_dir

# factbox png files
newparadigm_files <- dir(newparadigm_dir, pattern = ".png")

# read factbox imgs to a list
nppi_items <- map(newparadigm_files, ~magick::image_read(paste0(newparadigm_dir, .x)))

# name imgs
names(nppi_items) <- 
  gsub(".png", "", newparadigm_files)

rm(height,width,input_dir,newparadigm_dir,newparadigm_files,newparadigm_template_dir,newparadigm_templates,output_dir)

# Create ppv graphs -------------------------------------------------------

# Read csv with prevalences by age
age_prevalence <- 
  readxl::read_xls("materials/Numbers/numbers_bayes.xls", sheet = 2)
# keep tens
age_prevalence <- 
  age_prevalence %>% 
  filter(grepl("[1-9]0", age))

# Test parameters (Two different tests)
numbers_nppi <-
  readxl::read_xls("materials/Numbers/numbers_bayes.xls") %>%
  filter(format == "nppi")

# Check number of contexts. It must be the same number of graphs
problem_contexts <- 
  dir("materials/Problem_context/input/", pattern = ".txt") %>% 
  grep("txt_", ., value = TRUE)

# Graph parameters
# Ages to plot: this points will have a number with a percentage above
age_ppv_to_plot <-  
  c(20, 30, 40, 50, 60)
# axis labels: indicating age of mother/women
x_axis_label <- 
  read_csv("materials/Problem_context/problem_context_info.csv", col_types = cols()) %>% 
  filter(code_name == "person_02")
# y axis label
y_axis_label <-
  "Positive result reliability"

# These are results of 650/690, 390/1169
graph_widht_percentage <- .94202
graph_height_percentage <- .345

graph_width_absolute  <- 
  template_width * graph_widht_percentage
graph_height_absolute <- 
  template_height * graph_height_percentage

# output folder
graph_output_folder <- "materials/Presentation_format/nppi/input/graphs/png/"

# If Folder does not exist, create it
dir.create(file.path(graph_output_folder), showWarnings = FALSE, recursive = TRUE)

# PPV graph name
graph_png_file_name <- 
  paste0("nppi_ppv_", 
         gsub(paste0(".*(", paste(possible_contexts, collapse = "|"), ").*"), "\\1", problem_contexts),
         "_graph")

# Path to folder to save graph
png_file_pathname <-
  paste0(graph_output_folder, graph_png_file_name, ".png") # path and name to new png file

# Get ppv in a scale between 0 and 100
age_prevalence <- mutate(age_prevalence, PPV_100 = PPV*100)

# UNCOMMENT TO select ages to plot on ppv graph
# age_prevalence_plot <-
#   age_prevalence %>% 
#   filter(age %in% age_ppv_to_plot)

for (cCntxt in seq(length(problem_contexts))) {
  # cCntxt <- 1
  
  # context of current problem context 
  current_context <- 
    gsub(paste0(".*(", paste(possible_contexts, collapse = "|"), ").*"), "\\1", problem_contexts[[cCntxt]])
  
  # labels corresponding to current problem context
  current_axis_label <- pull(x_axis_label[, current_context])
  
  # Filter ages (if cancer 20-60, if pregnant 20-50)
  if (current_context == "pr") {
    # labels over points o histogrm
    curr_age_ppv_to_plot <- 
      age_ppv_to_plot %>% grep("[2-5]0", ., value = TRUE)
    # x scale limits
    age_prevalence_plot <-
      age_prevalence %>%
      filter(age < 60)
  } else if (current_context == "ca") {
    # labels over points o histogrm
    curr_age_ppv_to_plot <- 
      age_ppv_to_plot
    # x scale limits
    age_prevalence_plot <-
      age_prevalence
  }
  
  
  
  # Begin graph creation
  
  ## Create canvas to save image
  ppv_graph <- 
    image_graph(width = round(graph_width_absolute, 0), height = round(graph_height_absolute, 0))
  
  ## Plot graph
  print( # to send the plot to the viewer from within a for loop use print
    
    ggplot(age_prevalence_plot, aes(x=age, y=PPV_100)) +      # plot canvas
      scale_y_continuous(labels=function(x) paste0(x,"%"), # append % to y-axis value
                         limits = c(0,100)) +              # set y-axis limits
      geom_point(size = 5.5, color = "#009999", shape = 19) + # insert points with ppv value
      geom_line(aes(x=age, y=PPV_100), color = "#009999", size = 2) +
      theme_minimal() + # insert line bridging PPV-value points
      xlab(paste0("Age of the ", current_axis_label)) + ylab(y_axis_label) + # set axis labels
      theme(axis.text = element_text(size = 25),                             # axis-numerbs size
            axis.title = element_text(size = 25)) +                          # axis-labels size
      geom_text(aes(label =
                      case_when(age %in% curr_age_ppv_to_plot ~ paste0(round(PPV_100, 0), "%"), TRUE ~ paste0("")), # keep only ages previously set to be ploted
                    hjust = .4, vjust = 2.5), size = 6) # (position) plot ppv-values above points set in "age_ppv_to_plot"
  )
  # Close canvas
  dev.off()
  # Write image as png
  image_write(image = ppv_graph, path = grep(current_context, png_file_pathname, value = TRUE))
  
}

rm(graph_png_file_name,png_file_pathname)
rm(age_ppv_to_plot,graph_output_folder,x_axis_label,y_axis_label)

##### Compose new-paradigm brochure ###################################################
# graphs dir
graph_dir <- "materials/Presentation_format/nppi/input/graphs/png/"

# get graphs file names
nppi_graphs_files_names <- grep("ppv.*png", dir(graph_dir), value = TRUE)

# Read graphs into list
nppi_graphs <- map(nppi_graphs_files_names, ~magick::image_read(paste0(graph_dir, .x)))

# Name graphs
names(nppi_graphs) <- gsub(".png", "", nppi_graphs_files_names)

# Template dimensions
img_width  <- magick::image_info(nppi_items[[1]])$width
img_height <- magick::image_info(nppi_items[[1]])$height

# Prevalence position in template (%)
# relateive
prev_ca_x   <- 0.05852174 # cancer prevalence sentence position (relative to brochure size).
# On the pregnant condition the prevalence is splitted in two senteces. Therefore, there are two x axis positions
prev_pr_x_1 <- 0.13352174 # pregnant prevalence sentence (01) position (relative to brochure size). 
prev_pr_x_2 <- 0.05852174 # pregnant prevalence sentence (02) position (relative to brochure size).
prev_y_1    <- .344 # both prevalence sentences (01) posiion on y axis (relative to brochure size).
prev_y_2    <- prev_y_1+.027 # if any, both prevalence sentences (02) posiion on y axis (relative to brochure size).

# absolute
prev_xca_pos  <- prev_ca_x*img_width # cancer prevalence sentence position (absolute position).
# On the pregnant condition the prevalence is splitted in two senteces. Therefore, there are two x axis positions
prev_xpr1_pos <- prev_pr_x_1*img_width # pregnant prevalence sentence (01) position (absolute position). 
prev_xpr2_pos <- prev_pr_x_2*img_width # pregnant prevalence sentence (02) position (absolute position).
prev_y1_pos   <- prev_y_1*img_height # both prevalence sentences (01) posiion on y axis (absolute position). 
prev_y2_pos   <- prev_y_2*img_height # if any, both prevalence sentences (02) posiion on y axis (absolute position).

# Graph position in template
# relateive
graph_x <- 0.02898551
graph_y <- 0.59
# absolute
graph_x_pos <- graph_x*img_width
graph_y_pos <- graph_y*img_height

# medical conditions to fill graph
medical_conditions <- 
  read_csv("materials/Problem_context/problem_context_info.csv", col_types = cols()) %>% 
  filter(code_name == "medical_condition")

# person to undergo test to fill graph (women/births)
who_undergo_test <- 
  read_csv("materials/Problem_context/problem_context_info.csv", col_types = cols()) %>% 
  filter(code_name == "prevalence_class")

for (i in seq(length(nppi_items))){
  # i=1
  
  # repeat template as many times as the number of graphs
  nppi_img_list <- rep(as.list(nppi_items[i]), nrow(numbers_nppi))
  
  for (j in seq(nrow(numbers_nppi))) {
    # j=1
    
    # problem context of current template 
    current_context <-
      gsub(paste0(".*(", paste(possible_contexts, collapse = "|"), ").*"), "\\1", names(nppi_items[i]))
    
    # ppv graph of current template
    current_graph <- 
      nppi_graphs[[gsub(".png", "", grep(paste0("_", current_context,"_"), nppi_graphs_files_names, value = TRUE))]]
    
    # medical condition of current template
    current_medical_condition <- 
      pull(medical_conditions[, current_context])
    
    # who's got a disease in current template
    current_who_undergo_test <- 
      pull(who_undergo_test[,current_context])
    
    
    nppi_img_list[[j]] <- 
      magick::image_annotate(
        
        magick::image_annotate(
          
          magick::image_composite(nppi_img_list[[i]], current_graph, offset = paste0("+", graph_x_pos, "+", graph_y_pos)),
          
          paste0("At age ", numbers_nppi[[j, "age"]], ", it is estimated that ", current_medical_condition," is present in ", numbers_nppi[[j, "prev_01"]], " out " ),
          font = "arial", size = 20, color = "black", boxcolor = "",
          degrees = 0, location = paste0("+", prev_xca_pos, "+", prev_y1_pos)),
        
        text = paste0("of every ", numbers_nppi[[j, "prev_02"]], " ", current_who_undergo_test, "."),
        font = "arial", size = 20, color = "black", boxcolor = "",
        degrees = 0, location = paste0("+", prev_xca_pos, "+", prev_y2_pos))
  }
  
  ppv_prob <- as.character(numbers_nppi[["prob"]])
  
  names(nppi_img_list) <- paste0(names(nppi_img_list), "_", ppv_prob)
  
  nppi_items[[i]] <- nppi_img_list
  
  if (i == length(nppi_items)) {
    rm(i,j, nppi_img_list)
  }
}

# Write images
nppi_output_folder <- "materials/Presentation_format/nppi/output/"

# If Folder does not exist, create it
dir.create(file.path(nppi_output_folder), showWarnings = FALSE, recursive = TRUE)

for (q in seq(length(nppi_items))) {
  for (x in seq(length(nppi_items[[q]]))) {
    magick::image_write(nppi_items[[q]][[x]], paste0(nppi_output_folder, names(nppi_items[[q]][x]), ".png"))
  }
  if (q == length(nppi_items)) {
    rm(q,x)
  }
}

rm(list = c(grep("graph_", ls(), value = TRUE),
            grep("prev_", ls(), value = TRUE)))
rm(img_height, img_width,
   nppi_graphs_files_names, nppi_output_folder,
   nppi_graphs, age_prevalence, ppv_prob, cCntxt, problem_contexts)
# Problem contexts --------------------------------------------------------

# Read problem contexts ####
# path to responses folder
context_dir <- "materials/Problem_context/input/"

# responses files
context_files <- dir(context_dir, pattern = ".txt") %>% grep("txt_", ., value = TRUE)

# paths to each response file
context_files_path <- paste0(context_dir, context_files)

# list with responses as char strings
nppi_context <- map(context_files_path, ~readChar(con = .x, nchars = file.info(.x)$size)) %>% # read files
  map2(gsub("txt_(.*).txt", "***\\1***", context_files), ., paste0) # put names

rm(context_dir,context_files,context_files_path)

# high/low prob filling ####

# put prevalences on contexts using number bayes

for (c_context in seq(nppi_context)) {
  # c_context <- 1
  current_context <- 
    as.list(rep(nppi_context[[c_context]], nrow(numbers_nppi)))
  
  for (c_prob in seq(nrow(numbers_nppi))) {
    # c_prob <- 1
    
    # put age and prevalence using numbers table
    current_context[[c_prob]] <- 
      gsub("age_variable", numbers_nppi[["age"]][c_prob], 
           gsub("prevalence_02_variable", numbers_nppi[["prev_02"]][c_prob], 
                current_context[[c_prob]]))
  }
  
  # add ppv prob to name
  current_context <- 
    map2(numbers_nppi[["prob"]], current_context, function(x,y) {
      gsub("(\\*\\*\\*.*_)(.*\\*\\*\\*.*)", paste0("\\1", x, "_\\2"), y)  
    })
  
  nppi_context[[c_context]] <- 
    current_context
  
  # trash remove
  if (c_context == length(nppi_context)) {
    rm(c_context,c_prob, current_context)
  }
}

nppi_context <-
  as.list(unlist(nppi_context))

# Responses type pictorial ------------------------------------------------

# path to responses folder
response_types_dir <- "materials/Response_type/"

# responses files
response_type_files <- dir(response_types_dir, pattern = "*.txt")

# paths to each response file
response_type_files_path <- paste0(response_types_dir, response_type_files)

# list with responses as char strings
responses_pic <- 
  map(response_type_files_path, ~readChar(con = .x, nchars = file.info(.x)$size))
# assing name to each response type
names(responses_pic) <- gsub(".txt", "", response_type_files)

## sequential guided question fillers
textual_formats <- 
  dir("materials/Presentation_format/") %>% grep("[a-z]{2}pi", ., invert = TRUE, value = TRUE)
## Get possible problem context
problem_contexts <-
  textual_formats %>% 
  map(~dir(paste0(presentation_format_dir, .x, "/input")) %>% 
        gsub("([a-z]{2}).*", "\\1", .)) %>% 
  unlist %>% 
  unique

# fillers
context_info <- 
  read_csv("materials/Problem_context/problem_context_info.csv", col_types = "ccc")

# fields to loop through (obtained from sg_fillers column names)
tobefilled <-
  read_csv("materials/Numbers/fields2fill.csv", col_types = cols()) %>% 
  select(sg_response) %>% drop_na() %>% pull()
# tofill     <- grep("[A-Z]", names(sg_fillers), value = TRUE)

# sg template to fill (as many as contexts)
temp_sg          <- responses_pic$sg
responses_pic$sg <- rep(responses_pic$sg, ncol(context_info)-1)

# filled sg according to each problem context
for (cC in seq(problem_contexts)) {
  # cC = 2
  temp_sg <- responses_pic$sg[cC]
  
  for (fC in seq(length(tobefilled))) {
    # fC = 1
    temp_sg <- 
      gsub(tobefilled[fC], 
           filter(context_info, code_name == tobefilled[fC]) %>% select(problem_contexts[cC]), 
           temp_sg)
  }
  responses_pic$sg[cC] <- temp_sg
}

rm(response_type_files,response_type_files_path,response_types_dir, numbers_item)    

