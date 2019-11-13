# INSTRUCCIONES GENERALES PARA SUBIR DESDE 0 

# Full upload:

1. DELETE EVERYHING
  Remove all blocks: qualtrics_remove_blocks.R
  Remove all Embedded data (anidar a Random y borrar random): qualtrics_move_ED_blocks.R
  
2. UPLOAD EVERYTHING

  A) Build bookdown [Cntl + Shift + B]
  B) IMAGENES
    a) 01-prepare-and-show-items.Rmd (correr lineas 1 a 30)
    b) Abrir y correr manualmente upload_imgs_qualtrics.R [ERROR AL COPIAR CLIPBOARD DE DOCKER???]
    
  C) Rebuild bookdown: necesario para que los enlaces de B) b) se integren en el sistema (?). [Cntl + Shift + B]

  D) SUBIR TODAS LAS COSAS! import_survey_qualtrics.R
    a) Import Embedded data blocks: UBER_IMPORT2QUALTRICS_miro()
    b) DELETE UNNECESARY BLOCKS: qualtrics_remove_blocks()
    c) Move ED blocks: qualtrics_move_ED_blocks()
    d) SUBIR resto de cosas: import_survey_qualtrics.R (lineas 71 a fin. Desde seccion: Experiment description)

  E) Checklist: 03-checklist_manual_changes.Rmd
  