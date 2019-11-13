qualtrics_remove_blocks <- function(start_on = 1, survey_type = "gorka", debug_it = FALSE) {

  # DEBUG -------------------------------------------------------------------
  # start_on <- 1
  # survey_type = "miro"
  # debug_it = TRUE
  
  tictoc::tic.clearlog()
  
  remDr$setTimeout(type = "page load", milliseconds = 10000) # Wait for page to load
  remDr$setTimeout(type = "implicit", milliseconds = 10000)
  
  # get blocks selectors 
  selectors <- remDr$findElements("class", "caret")
  length(selectors)
  
  for (i in seq(selectors)) {
    # i = 1
    
    # TIEMPO
    time_mean = mean(as.numeric(gsub(" sec elapsed", "", tictoc::tic.log() %>% unlist())))
    message("Promedio_bloque: ",  time_mean, ". Estimado: ", time_mean * (length(selectors) - i))
    
    tictoc::tic()
    message(paste0("Deleting block no. ", i, "/", length(selectors)))
    beep(sound = 10)
    


    # 1. Block options --------------------------------------------------------

      if (debug_it == TRUE) message("1. Block options")
    
      Sys.sleep(1) # give it time
        
      # SISTEMA ANTIGUO: Funciona ok... mas o menos?
      # .GlobalEnv$webElem = ""
      
      # DELETE: Si falla, dale un par de segundos extra y vuelve a intentar
      # tryCatch({
      #   .GlobalEnv$webElem <- remDr$findElement(
      #     using = 'xpath', 
      #     value = "/html/body/form[2]/div[4]/div/div[1]/div[2]/div[1]/div/div[3]/div[3]/div[4]/div[1]/div/div[1]/div/div[2]/span[2]")
      # }, 
      # # ERROR
      # error = function(e) {
      #   Sys.sleep(5) # give it time
      #   .GlobalEnv$webElem <- remDr$findElement(
      #     using = 'xpath', 
      #     value = "/html/body/form[2]/div[4]/div/div[1]/div[2]/div[1]/div/div[3]/div[3]/div[4]/div[1]/div/div[1]/div/div[2]/span[2]")
      #   
      # })
      # 

      # NUEVO SISTEMA: Aun no muy bien testeado
      .GlobalEnv$webElem <-NULL
      .GlobalEnv$iteracion = 1
      while(is.null(.GlobalEnv$webElem)){
        tryCatch({
          Sys.sleep(1)
          
          .GlobalEnv$iteracion = .GlobalEnv$iteracion + 1
          message(.GlobalEnv$iteracion)
          if (.GlobalEnv$iteracion >= 15) {
            break()
            stop()
          }
          .GlobalEnv$webElem = remDr$findElement(
            # using = 'xpath', value = "/html/body/form[2]/div[4]/div/div[1]/div[2]/div[1]/div/div[3]/div[3]/div[4]/div[1]/div/div[1]/div/div[2]/span[2]"
            using = 'class name', "block-options-button")
          
          
          },
          error = function(e){NULL})
        #loop until element with name <value> is found in <webpage url>
      }
      
      
      .GlobalEnv$webElem$highlightElement() # Selecciona el elemento
      .GlobalEnv$webElem$clickElement()
      Sys.sleep(.5) # give it time


  # 2. Delete clock ---------------------------------------------------------

    if (debug_it == TRUE) message("2. Delete block")    
      Sys.sleep(1)
        if (survey_type == "gorka") {
            child <- "17"
          } else if (survey_type == "miro") {
            child <- "18"
          }
      
      # Select "Delete Block...". Si falla, dale un par de segundos y reintenta
      tryCatch({
        .GlobalEnv$webElem <- remDr$findElement(
          using = 'css selector', 
          value = paste0("#QMenu > div > div > ul > li:nth-child(", child, ") > a"))
      }, 
      # ERROR
      error = function(e) {
        Sys.sleep(5) # give it time
        .GlobalEnv$webElem <- remDr$findElement(
          using = 'css selector', 
          value = paste0("#QMenu > div > div > ul > li:nth-child(", child, ") > a"))
      })
      .GlobalEnv$webElem$highlightElement() # Selecciona el elemento
      .GlobalEnv$webElem$clickElement()
      
      Sys.sleep(.5) # give it time
    
      

  # 3. Confirm delete -------------------------------------------------------

      
    if (debug_it == TRUE) message("3. CONFIRM - Delete")    
    
    # Confirm. Select "Delete"
    repeat {
    webElem <- remDr$findElement(using = 'css selector', value = "#ConfirmDeleteButton > span:nth-child(2)")
    webElem$clickElement()
    done <- 1
    if (done == 1) break
    }
    
    Sys.sleep(3) # give it time
    tictoc::toc(log = TRUE)

    
  }
  
  beep(sound = 4)
  
}

# remove_blocks_qualtrics(start_on = 1,
#                         survey_type = "miro")
