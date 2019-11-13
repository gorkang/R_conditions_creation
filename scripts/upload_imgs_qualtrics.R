# Upload images

# sudo apt install phantomjs
# binman::rm_platform("phantomjs")
# wdman::selenium(retcommand = TRUE)

# Packages -------------------------------------------------------------
if (!require('pacman')) install.packages('pacman'); library('pacman')
p_load(RSelenium, tidyverse, clipr) #naptime

# Re-sources --------------------------------------------------------------
source("functions/get2survey.R")
source("functions/UBER_IMPORT2QUALTRICS_miro.R")
# source(here::here("R/qualtrics_start_docker.R"), local = TRUE)
# qualtrics_start_docker()


# Start docker session ----------------------------------------------------

# Check docker containers
system('docker ps -q') 
# Kill all containers
system('docker stop $(docker ps -q)') # MATALOS todos
# Get chrome image (to use VNC use debug)
system('docker pull selenium/standalone-chrome-debug') 
# Run docker session. Map home directory to download docker container
# system('docker run -d -v /home:/home/seluser/Downloads -P selenium/standalone-chrome-debug')
system('docker run -t -d --shm-size=2g -e SCREEN_WIDTH=2560 -e SCREEN_HEIGHT=1440 -e SCREEN_DEPTH=24 --name rqualtrics_images -v /home/emrys/:/home/seluser/Downloads -P selenium/standalone-chrome-debug') #standalone-firefox 

# Get important data about ports
system('docker ps')

# This is the path to materials folder within docker container
# selenium_path <- "/home/seluser/Downloads/nicolas/asgard/fondecyt/gorka/2017 - Gorka - Fondecyt/Experimentos/Experimento 1/R_condition_creation_GITHUB/R_conditions_creation"
selenium_path <<- "/home/seluser/Downloads/gorkang@gmail.com/RESEARCH/PROYECTOS/2017 - Gorka - Fondecyt_NO_SHARED/Experimentos/Experimento 1/R_conditions_creation/"

# To remove blocks
# remove_blocks_qualtrics(start_on = 1, survey_type = "miro")
# remDr$refresh()
# To remove survey flow elements
# remove_surveyflow_elements(start_on = 3)
# remDr$refresh()

# Selenium ----------------------------------------------------------------

container_port_raw <- system(('docker port rqualtrics_images'), intern = TRUE)
container_port <<- container_port_raw %>% gsub('.*([0-9]{5}).*', '\\1', .) %>% as.integer()
container_port[2]
# Create browser instance. This should be reflected in the VNC session
remDr <- remoteDriver(remoteServerAddr = "localhost", port = container_port[1], browserName = "chrome")
remDr$open()

# Survey link (why did the url change?)
survey_link <- "https://qsharingeu.eu.qualtrics.com/ControlPanel/?ClientAction=ChangePage&Section=GraphicsSection"

# Qualtrics password
pass   <- .rs.askForPassword("Please enter Qualtrics password")

# Get to survey (twice: first to get into qualtrics, then to get into survey)
get2survey(survey_link)
get2survey(survey_link)

# Get to folder (no permanent name to folder?)
webElem <- remDr$findElement(using = 'css selector', value = "#Folder_17 .folder-name")
webElem$clickElement()

Sys.sleep(3) # give it time

# Delete old images -------------------------------------------------------

# Get elements (cog button). For some reason the second half are the actual buttons.
elements <- remDr$findElements("class name", "icon-gear")

for (i in seq(1+length(elements)/2, length(elements))) {
  
  webElem <- elements[[i]]
  webElem$clickElement()
  
  webElem <- remDr$findElement(using = 'css selector', value = "#QMenu > div > div > ul > li.Delete > a")
  webElem$clickElement()
  
  
  webElem <- remDr$findElement(using = 'css selector', value = "#body > div.modal.ng-scope.top.am-fade > div > div > div.modal-footer > button.btn.btn-danger")
  webElem$clickElement()
  
}

Sys.sleep(3) # give it time

# Refresh for sanity -----------------------------------------------------
remDr$refresh()

# Get to folder (no permanent name to folder?)
webElem <- remDr$findElement(using = 'css selector', value = "#Folder_17 .folder-name")
webElem$clickElement()

Sys.sleep(3) # give it time

# Upload new images -------------------------------------------------------

# Get to folder (no permanent name to folder?)
webElem <- remDr$findElement(using = 'css selector', value = "#Folder_17 .folder-name")
webElem$clickElement()

# img to upload
file <- file.path(selenium_path, 
                  c(dir("materials/Presentation_format/fbpi/output", full.names = TRUE), 
                    dir("materials/Presentation_format/nppi/output", full.names = TRUE)))

for (i in seq(file)) {
  # i <- 1
  # Upload graphic button
  webElem <- remDr$findElement(using = 'css selector', value = "#SectionContainer > div > div > div.toolbar > div.Right > div > span.upload-text.ng-binding")
  webElem$clickElement()
  
  # send img path to button
  upload_btn <- remDr$findElement(using = 'xpath', value = '//*[@id="upload-graphic_modal"]/div/div/div[2]/div[2]/div[1]/div/input')
  upload_btn$sendKeysToElement(list(file[[i]])) # has to be a list for some reason
  
  # upload graphic
  webElem <- remDr$findElement(using = 'css selector', value = "#upload-graphic_modal > div > div > div.modal-footer > div.btn.btn-success > ng-pluralize")
  webElem$clickElement()
  
}


Sys.sleep(3) # give it time

# Scrap images url --------------------------------------------------------

# Get elements (cog button). For some reason the second half are the actual buttons.
elements <- remDr$findElements("class name", "icon-gear")

# list to store urls
imgs <- rep(list(vector("character", 2)), length(elements)/2)

# Listado manual. 
# imgs = list(
#   c("ca_fbpi_ppvhigh", "https://qsharingeu.eu.qualtrics.com/ControlPanel/Graphic.php?IM=IM_5u3XaT7Q8iLUuXz"),
#   c("ca_fbpi_ppvlow","https://qsharingeu.eu.qualtrics.com/ControlPanel/Graphic.php?IM=IM_8kpUpGvi69Km74N"),
#   c("ca_nppi_ppvhigh","https://qsharingeu.eu.qualtrics.com/ControlPanel/Graphic.php?IM=IM_9ZUNAyKy59u7tDD"),
#   c("ca_nppi_ppvlow", "https://qsharingeu.eu.qualtrics.com/ControlPanel/Graphic.php?IM=IM_81u6HHoaiaQAr4h"),
#   c("pr_fbpi_ppvhigh","https://qsharingeu.eu.qualtrics.com/ControlPanel/Graphic.php?IM=IM_6JQX662i8hMInB3"),
#   c("pr_fbpi_ppvlow","https://qsharingeu.eu.qualtrics.com/ControlPanel/Graphic.php?IM=IM_57oC3XtEQ7d2ZZX"),
#   c("pr_nppi_ppvhigh", "https://qsharingeu.eu.qualtrics.com/ControlPanel/Graphic.php?IM=IM_3r4YvxM4NXVKLFH"),
#   c("pr_nppi_ppvlow","https://qsharingeu.eu.qualtrics.com/ControlPanel/Graphic.php?IM=IM_6QXycdkzI4jb1Rz")
# )


# Scraping
for (i in seq(1+length(elements)/2, length(elements))) {
  # i = 1
  
  # Cog button
  webElem <- elements[[i]]
  webElem$highlightElement(1) # Selecciona el elemento
  webElem$clickElement() # click cog button
  
  # "Edit Graphic"
  webElem <- remDr$findElement(using = 'css selector', value = "#QMenu > div > div > ul > li.Edit > a")
  webElem$clickElement()
  
  Sys.sleep(1) # give it time

  # Get image name (condition)
  webElem <- remDr$findElement(using = 'css selector', value = "#preview-graphic_modal > div > div > div.modal-header > h4")
  .GlobalEnv$imgs[[i-length(elements)/2]][1] <- webElem$getElementText()[[1]]
  
  # Get image url (copied to clipboard)
  webElem <- remDr$findElement(using = 'css selector', value = "#preview-graphic_modal > div > div > div.modal-header > div > div.btn.ng-scope")
  webElem$clickElement()
  # get url from clipboard
  .GlobalEnv$imgs[[i-length(elements)/2]][2] <- clipr::read_clip()
  
  # Close "Edit Graphic" window
  webElem <- remDr$findElement(using = 'css selector', value = "#preview-graphic_modal > div > div > div.modal-body > div > div.form.edit-options > div:nth-child(2) > div.footer > div.btn.btn-hover > span")
  webElem$clickElement()
  
}

# close client/server
remDr$close()
rD$server$stop()

# Export URLs -------------------------------------------------------------

# Convert list to table
igms_url <- 
  matrix(unlist(imgs), nrow = length(imgs), byrow = TRUE) %>%  # list to table
  as.tibble() %>% 
  setNames(., c("condition", "url")) %>% 
  mutate(condition = gsub("(high|low).png", "ppv\\1", condition))

# export table
write_csv(igms_url, "materials/img_url.csv")
