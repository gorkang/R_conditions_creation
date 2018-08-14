# Upload images

# sudo apt install phantomjs
# binman::rm_platform("phantomjs")
# wdman::selenium(retcommand = TRUE)

# Packages -------------------------------------------------------------
if (!require('pacman')) install.packages('pacman'); library('pacman')
p_load(RSelenium, tidyverse, naptime)

# Re-sources --------------------------------------------------------------
source("functions/get2survey.R")
source("functions/UBER_IMPORT2QUALTRICS.R")

# Get to survey -------------------------------------------------------------------

# Create browser instance
rD = RSelenium::rsDriver(browser = "chrome")
remDr <- rD[["client"]]

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

# Upload new images -------------------------------------------------------

# Get to folder (no permanent name to folder?)
webElem <- remDr$findElement(using = 'css selector', value = "#Folder_17 .folder-name")
webElem$clickElement()

# img to upload
file <- file.path(getwd(), 
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

# Scraping
for (i in seq(1+length(elements)/2, length(elements))) {
  # i = 9
  
  # Cog button
  webElem <- elements[[i]]
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