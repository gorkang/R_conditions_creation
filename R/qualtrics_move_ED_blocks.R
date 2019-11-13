qualtrics_move_ED_blocks <- function(start_on = 0, debug_it = FALSE) {

  # start_on = 0
  debug_it = TRUE
  remDr$setImplicitWaitTimeout(milliseconds = 10000)
  remDr$setTimeout(type = "implicit", milliseconds = 2000)
  tictoc::tic.clearlog()
  
  # Get to Survey Flow
  remDr$refresh()
  webElem <- remDr$findElement("css selector", "#surveyflow")
  webElem$clickElement()
  Sys.sleep(5) # give it time
  
  # Get blocks
  .GlobalEnv$ed_blocks <- remDr$findElements("class name", "Move")
  # Si esta vacio, esperar unos segundos y reintentar
  if (length(.GlobalEnv$ed_blocks) == 0 ) {
    Sys.sleep(5) # give it time
    .GlobalEnv$ed_blocks <- remDr$findElements("class name", "Move")
  }
  
  # Remove first element (first element is not any of the survey flow elements)
  .GlobalEnv$ed_blocks <- .GlobalEnv$ed_blocks[-1]
  message(length(.GlobalEnv$ed_blocks))
  
  # Set counter to 0. This keeps track of the last block moved.
  .GlobalEnv$safe_counter <- start_on
  
  while (.GlobalEnv$safe_counter != length(.GlobalEnv$ed_blocks)) {
    # if(debug_it == TRUE) message("While1: ", .GlobalEnv$safe_counter, " ", length(.GlobalEnv$ed_blocks))
    # # remDr$refresh()
    # if(debug_it == TRUE) message("While2: ", .GlobalEnv$safe_counter, " ", length(.GlobalEnv$ed_blocks))
    
    # Get to Survey Flow (if is not possible continue running the code)
    try(expr = {
      webElem <- remDr$findElement("css selector", "#surveyflow")
      webElem$clickElement()
    }, silent = TRUE)

    # Get survey flow elements
    .GlobalEnv$blocks <- remDr$findElements("class name", "Move")
    Sys.sleep(5) # give it time
    
    # .GlobalEnv$safe_counter = 1
    for (i in seq(from = .GlobalEnv$safe_counter, to = length(.GlobalEnv$blocks))) {
      
      beep(sound = 10)
      
      tictoc::tic()
      
      # TIME
      time_mean = mean(as.numeric(gsub(" sec elapsed", "", tictoc::tic.log() %>% unlist())))
      message("Promedio_bloque: ",  time_mean, ". Estimado: ", time_mean * (length(.GlobalEnv$ed_blocks) - i))
      
      # Progress message
      message(paste0("Moving block ", i, " / ", length(.GlobalEnv$ed_blocks) - 3))
      
      .GlobalEnv$webElem1 <-
        remDr$findElement(using = 'css selector',
                          value = "div.FlowElement:nth-child(1) > div:nth-child(1) > div:nth-child(7) > div:nth-child(1) > div:nth-child(1)")
      # value = "/html/body/div[5]/div/div[2]/div/div/div/div/div[1]/div/div/div[7]/div/div[1]/div/div[1]/div[3]/a[2]")

      .GlobalEnv$webElem1$getElementLocationInView()
      remDr$mouseMoveToLocation(webElement = .GlobalEnv$webElem1)
      remDr$click(buttonId = 1)
      webElem <- remDr$findElement("css", "body")
      webElem$sendKeysToElement(list(key = "up_arrow"))
      tictoc::toc(log = TRUE)
      
      if(debug_it == TRUE) message("Before if: ", i, " - ", .GlobalEnv$safe_counter, " ", length(.GlobalEnv$ed_blocks))
      
      
      # Grupos de 50. El uso de memoria RAM aumenta mucho con firefox
      if (i == 50 + .GlobalEnv$safe_counter | i == length(.GlobalEnv$ed_blocks)) {
        beep(sound = 1)
        
        Sys.sleep(1)
        webElem <- remDr$findElement("class name", "RightButtons")
        # .GlobalEnv$webElem$getElementLocationInView()
        webElem$clickElement()
        .GlobalEnv$safe_counter <- i
          message(paste0("*********************\nCounter updated to ", .GlobalEnv$safe_counter))
          
        Sys.sleep(5)
        break
      }
      
      if(debug_it == TRUE) message("After if: ", i, " - ", .GlobalEnv$safe_counter, " ", length(.GlobalEnv$ed_blocks))
      
    }
    
  }
  
  beep(sound = 4)
  
}
