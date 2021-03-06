# SUMMARY STATS ----------------------------------------------------------------
source ("moduleServer.R", local = TRUE)
source ("reactives.R", local = TRUE)


# normalizationRadioButtonValue -------------------------------- 
# Parameters / normalization
output$normalizationRadioButtonValue <- renderPrint({
  input$normalizationRadioButton
})

normaliztionParameters <- list(raw = "no Parameters needed")
parFiles <- dir(path = "contributions", pattern = "parameters.R", full.names = TRUE, recursive = TRUE)
for (fp in parFiles) {
  myNormalizationParameters <- list()
  source(fp, local = TRUE)
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/normalizationsParameters.RData", list = c("normaliztionParameters", ls(), ls(envir = globalenv())))
  }
  # load(file = '~/scShinyHubDebug/normalizationsParameters.RData')
  if (length(myNormalizationParameters) > 0) {
    for (li in 1:length(myNormalizationParameters)) {
      lVal <- myNormalizationParameters[[li]]
      if (length(lVal) > 0) {
        if (DEBUG) {
          cat(file = stderr(), paste("normalization Choice: ", names(myNormalizationParameters)[li], " ", lVal, "\n"))
          cat(file = stderr(), paste("class: ", class(myNormalizationParameters[[li]]), " ", lVal, "\n"))
        }
        oldNames <- names(normaliztionParameters)
        normaliztionParameters[[length(normaliztionParameters) + 1]] <- lVal
        names(normaliztionParameters) <- c(oldNames, names(myNormalizationParameters)[li])
      }
    }
  }
}

# normalizationsParametersDynamic -------------------------
output$normalizationsParametersDynamic <- renderUI({
  if (is.null(input$normalizationRadioButton)) {
    return(NULL)
  }
  selectedChoice <- input$normalizationRadioButton
  
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/normalizationsParametersDynamic.RData", list = c("normaliztionParameters", ls(), ls(envir = globalenv())))
  }
  # load(file = '~/scShinyHubDebug/normalizationsParametersDynamic.RData')
  do.call("switch", args = c(selectedChoice, normaliztionParameters, h3("no parameters provided")))
})


# summaryStatsSideBar -----------------------------
output$summaryStatsSideBar <- renderUI({
  if (DEBUG) {
    cat(file = stderr(), "output$summaryStatsSideBar\n")
  }
  scEx <- scEx()
  if (is.null(scEx)) {
    if (DEBUG) {
      cat(file = stderr(), "output$summaryStatsSideBar:NULL\n")
    }
    return(NULL)
  }
  if (input$noStats) {
    if (DEBUG) {
      cat(file = stderr(), "output$summaryStatsSideBar:off\n")
    }
    return(NULL)
  }
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/summaryStatsSideBar.RData", list = c("normaliztionParameters", ls(), ls(envir = globalenv())))
  }
  # load("~/scShinyHubDebug/summaryStatsSideBar.RData")
  line0 <- paste(input$file1$name)
  line1 <- paste("No. of cells: ", dim(scEx)[2], sep = "\t")
  line2 <- paste("No. of genes: ", dim(scEx)[1], sep = "\t")
  line3 <- paste("Median UMIs per cell: ", medianUMI(), sep = "\t")
  line4 <- paste("Median Genes with min 1 UMI: ", medianENSG(), sep = "\t")
  line5 <- paste("Total number of reads: ", sum(assays(scEx)[["counts"]]))
  line6 <- paste("Memory used:", getMemoryUsed())
  line7 <- paste("Normalization used:", input$normalizationRadioButton)
  htmlOut <- paste0(
    "Summary statistics of this dataset:", "<br/>", "<br/>", line0, "<br/>",  line1, "<br/>", line2, "<br/>", line3, "<br/>", line4, "<br/>",
    line5, "<br/>", line6, "<br/>", line7
  )
  exportTestValues(summaryStatsSideBar = { htmlOut })
  
  HTML(htmlOut)
})


# Select Genes ----
# this is part of the basic functionality from this
# tools and thus, can stay in this file.
output$geneListSelection <- renderTree({
  geneLists
})

# selectedGenesTable ----
# ONOFF TAB RENDER TABLE ALL CELLS 
# TODO module for DT this is part
# of the basic functionality from this tools and thus, can stay in this file.
output$selectedGenesTable <- DT::renderDataTable({
  if (DEBUG) {
    cat(file = stderr(), "output$selectedGenesTable\n")
  }
  dataTables <- inputData()
  useGenes <- useGenes()
  useCells <- useCells()
  if (is.null(dataTables) | is.null(useGenes) | is.null(useCells)) {
    return(NULL)
  }
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/selectedGenesTable.RData", list = c("normaliztionParameters", ls(), ls(envir = globalenv())))
  }
  # load("~/scShinyHubDebug/selectedGenesTable.RData")
  
  scEx <- assays(dataTables$scEx)[[1]]
  fd <- rowData(dataTables$scEx)
  dt <- fd[useGenes, c("symbol", "Gene.Biotype", "Description")]
  dt$rowSums <- Matrix::rowSums(scEx[useGenes, useCells])
  dt$rowSamples <- Matrix::rowSums(scEx[useGenes, useCells] > 0)
  exportTestValues(selectedGenesTable = { as.data.frame(dt) })
  DT::datatable(as.data.frame(dt))
})

# removedGenesTable -------------------------- 
# TODO module for DT TODO move to were it belongs
output$removedGenesTable <- DT::renderDataTable({
  if (DEBUG) {
    cat(file = stderr(), "output$removedGenesTable\n")
  }
  dataTables <- inputData()
  useGenes <- useGenes()
  useCells <- useCells()
  if (is.null(dataTables) | is.null(useGenes) | is.null(useCells)) {
    return(NULL)
  }
  useGenes <- !useGenes
  
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/removedGenesTable.RData", list = c("normaliztionParameters", ls(), ls(envir = globalenv())))
  }
  # load("~/scShinyHubDebug/removedGenesTable.RData")
  scEx <- assays(dataTables$scEx)[[1]]
  fd <- rowData(dataTables$scEx)
  dt <- fd[useGenes, c("symbol", "Gene.Biotype", "Description")]
  dt$rowSums <- Matrix::rowSums(scEx[useGenes, useCells])
  dt$rowSamples <- Matrix::rowSums(scEx[useGenes, useCells] > 0)
  exportTestValues(removedGenesTable = { as.data.frame(dt) })
  DT::datatable(as.data.frame(dt))
})

# gsSelectedGenes --------------------------- 
# TODO module of DT with selected names above Print names of selected genes for gene
# selection above table
output$gsSelectedGenes <- renderText({
  if (DEBUG) {
    cat(file = stderr(), "gsSelectedGenes\n")
  }
  dataTables <- inputData()
  useGenes <- useGenes()
  useCells <- useCells()
  selectedGenesTable_rows_selected <- input$selectedGenesTable_rows_selected
  if (is.null(dataTables) | is.null(useGenes) | is.null(useCells)) {
    return(NULL)
  }
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/gsSelectedGenes.RData", list = c("normaliztionParameters", ls(), ls(envir = globalenv())))
  }
  # load("~/scShinyHubDebug/gsSelectedGenes.RData")
  
  # scEx <- as.matrix(exprs(dataTables$scEx))
  fd <- rowData(dataTables$scEx)
  dt <- fd[useGenes, c("symbol", "Gene.Biotype", "Description")]
  retVal <- paste0(dt$symbol[selectedGenesTable_rows_selected], ",")
  exportTestValues(gsSelectedGenes = { retVal })
  return(retVal)
})

# gsrmGenes ----------------- 
# Print names of removed genes for gene selection
output$gsrmGenes <- renderText({
  if (DEBUG) {
    cat(file = stderr(), "gsrmGenes\n")
  }
  dataTables <- inputData()
  useGenes <- useGenes()
  useCells <- useCells()
  removedGenesTable_rows_selected <- input$removedGenesTable_rows_selected
  if (is.null(dataTables) | is.null(useGenes) | is.null(useCells)) {
    return(NULL)
  }
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/gsrmGenes.RData", list = c("normaliztionParameters", ls(), ls(envir = globalenv())))
  }
  # load("~/scShinyHubDebug/gsrmGenes.RData")
  useGenes = !useGenes
  # scEx <- as.matrix(exprs(dataTables$scEx))
  fd <- rowData(dataTables$scEx)
  dt <- fd[useGenes, c("symbol", "Gene.Biotype", "Description")]
  if (DEBUG) {
    cat(file = stderr(), "gsrmGenes: done\n")
  }
  retVal <-  paste0(dt$symbol[removedGenesTable_rows_selected], ",")
  exportTestValues(gsrmGenes = { retVal })
  return(retVal)
})

# DEBUGSAVEstring ----
output$DEBUGSAVEstring <- renderText({
  if (DEBUG){
    DEBUGSAVE <<- input$DEBUGSAVE
  } else {
    NULL
  }
})

# cellSelectionMod ----
callModule(tableSelectionServer, "cellSelectionMod", inputSample)

# normalizationResult ----
callModule(tableSelectionServer, "normalizationResult", scExLogMatrixDisplay)

# descriptionOfWork ----
output$descriptOfWorkOutput <- renderPrint({
  input$descriptionOfWork
})

# sampleColorSelection ----
output$sampleColorSelection <- renderUI({ 
  scEx <- scEx()
  sampCol = sampleCols$colPal
  
  if (is.null(scEx) ) {
    return(NULL)
  }
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/sampleColorSelection.RData", list = c("normaliztionParameters", ls(), ls(envir = globalenv())))
  }
  # load("~/scShinyHubDebug/sampleColorSelection.RData")
  
  lev <- levels(colData(scEx)$sampleNames)
  # cols <- gg_fill_hue(length(lev))
  
  # New IDs "colX1" so that it partly coincide with input$select...
  lapply(seq_along(lev), function(i) {
    colourpicker::colourInput(inputId = paste0("sampleNamecol", lev[i]),
                              label = paste0("Choose colour for sample ","\"", lev[i],"\""), 
                              # value = "#762A83"
                              # ,
                              value = sampCol[i],
                              allowedCols = allowedColors,
                              palette = "limited"
    )        
  })
})

# clusterColorSelection ----
output$clusterColorSelection <- renderUI({ 
  scEx <- scEx()
  projections = projections()
  clusterCol = clusterCols$colPal
  
  if (is.null(scEx) || is.null(projections)) {
    return(NULL)
  }
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/clusterColorSelection.RData", list = c("normaliztionParameters", ls(), ls(envir = globalenv())))
  }
  # load("~/scShinyHubDebug/clusterColorSelection.RData")
  
  lev <- levels(projections$dbCluster)
  # cols <- gg_fill_hue(length(lev))
  
  # New IDs "colX1" so that it partly coincide with input$select...
  lapply(seq_along(lev), function(i) {
    colourpicker::colourInput(inputId = paste0("clusterNamecol", lev[i]),
                              label = paste0("Choose colour for cluster ","\"", lev[i],"\""), 
                              # value = "#762A83"
                              # ,
                              value = clusterCol[i],
                              allowedCols = allowedColors,
                              palette = "limited"
    )        
  })
})


# observe: input$updateColors ----
observeEvent(input$updateColors, {
  cat(file = stderr(), paste0("observeEvent input$updateColors\n"))
  scExx <- scEx()
  projections <- projections()
  
  if (is.null(scExx) || is.null(projections)) {
    return(NULL)
  }
  #sample colors
  scols = sampleCols$colPal
  
  inCols = list()
  lev <- levels(colData(scExx)$sampleNames)
  
  inCols <- lapply(seq_along(lev), function(i){
    input[[paste0("sampleNamecol", lev[i])]]
  })
  names(inCols) = lev
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/updateColors.RData", list = c(ls(), ls(envir = globalenv())))
    cat(file = stderr(), paste0("observeEvent save done\n"))
  }
  # load(file="~/scShinyHubDebug/updateColors.RData")
  
  # isolate({
  sampleCols$colPal = unlist(inCols)
  # })
  
  #cluster colors
  ccols <- clusterCols$colPal
  
  inCols = list()
  lev <- levels(projections$dbCluster)
  
  inCols <- lapply(seq_along(lev), function(i){
    input[[paste0("clusterNamecol", lev[i])]]
  })
  names(inCols) = lev
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/updateColors2.RData", list = c(ls(), ls(envir = globalenv())))
    cat(file = stderr(), paste0("observeEvent 2 save done\n"))
  }
  # load(file="~/scShinyHubDebug/updateColors2.RData")
  
  # isolate({
  clusterCols$colPal = unlist(inCols)
  # })
})

# Nclusters ----
output$Nclusters <- renderText({
  scran_Cluster = scran_Cluster()
  if (is.null(scran_Cluster)) {
    return(NULL)
  }
  if (DEBUGSAVE) {
    save(file = "~/scShinyHubDebug/Nclusters.RData", list = c(ls(), ls(envir = globalenv())))
    cat(file = stderr(), paste0("observeEvent save done\n"))
  }
  # load(file="~/scShinyHubDebug/Nclusters.RData")
  retVal <- paste(levels(scran_Cluster$Cluster))
  exportTestValues(Nclusters = { retVal })
  return(retVal)
})

# download handler countscsv ----
output$countscsv <- downloadHandler(
  filename = paste0("counts.", Sys.Date(), ".csv"),
  content = function(file) {
    if (DEBUG) cat(file = stderr(), paste("countcsv: \n"))
    scEx_log <- scEx_log()
    if (is.null(scEx_log)) {
      return(NULL)
    }
    write.csv(as.matrix(assays(scEx_log)[[1]]), file)
  }
)

# download RDS ----
output$RDSsave <- downloadHandler(
  filename = paste0("project.", Sys.Date(), ".Rds"),
  content = function(file) {
    if (DEBUG) cat(file = stderr(), paste("RDSsave: \n"))
    
    scEx <- scEx()
    projections <- projections()
    scEx_log <- scEx_log()
    pca <- pca()
    tsne <- tsne()
    
    if (is.null(scEx)) {
      return(NULL)
    }
    if (DEBUGSAVE) {
      save(file = "~/scShinyHubDebug/RDSsave.RData", list = c(ls(), ls(envir = globalenv())))
    }
    # load(file='~/scShinyHubDebug/RDSsave.RData')
    
    reducedDims(scEx) <- SimpleList(PCA = pca$x, TSNE = tsne)
    assays(scEx)[["logcounts"]] = assays(scEx_log)[[1]]
    colData(scEx)[["before.Filter"]] = projections$before.filter
    colData(scEx)[["dbCluster"]] = projections$dbCluster
    colData(scEx)[["UmiCountPerGenes"]] = projections$UmiCountPerGenes
    colData(scEx)[["UmiCountPerGenes2"]] = projections$UmiCountPerGenes2
    
    save(file = file, list = c("scEx"))
    if (DEBUG) cat(file = stderr(), paste("RDSsave:done \n"))
    
    # write.csv(as.matrix(exprs(scEx)), file)
  }
)

# Report creation ------------------------------------------------------------------
output$report <- downloadHandler(
  filename = "report.zip",
  
  content = function(outZipFile) {
    outrepFile = reacativeReport()
    file.copy(from = outrepFile, to = outZipFile)
  }
)

# dummy function to return NULL
returnNull <- function() {
  return(NULL)
}

# forceCalc -----# handling expensive calcualtions
forceCalc <- shiny::observe({
  cat(file = stderr(), paste0("observe: goCalc\n"))
  go <- input$goCalc
  start.time <- base::Sys.time()
  if (go) {
    isolate({
      if (DEBUG) base::cat(file = stderr(), "forceCalc\n")
      # list of output variable and function name
      
      withProgress(message = "Performing heavy calculations", value = 0, {
        n <- length(heavyCalculations)
        for (calc in heavyCalculations) {
          shiny::incProgress(1 / n, detail = base::paste("Creating ", calc[1]))
          if (DEBUG) cat(file = stderr(), base::paste("forceCalc ", calc[1], "\n"))
          assign(calc[1], eval(parse(text = base::paste0(calc[2], "()"))))
        }
      })
    })
    
    printTimeEnd(start.time, "forceCalc")
  }
})

scranWarning <- function() {
  cat(file = stderr(), paste0("scranWarning\n"))
  modalDialog(
    span('The parameters clusterSource=normData and/or clusterMethod=hclust can ',
         'can result in very long wait times (>6hrs). Do you really want to do this?'),
    
    footer = tagList(
      actionButton("scranWarning_cancel", "Cancel"),
      actionButton("scranWarning_ok", "OK")
    )
  )
}

# handle long executions ----
observeEvent(input$clusterMethod ,
             {
               cat(file = stderr(), paste0("observe: input$clusterMethod\n"))
               if (input$clusterMethod == "hclust")
                 showModal(scranWarning())
             })
observeEvent(input$clusterSource,
             {
               cat(file = stderr(), paste0("observe: input$clusterSource\n"))
               if (input$clusterSource == "normData")
                 showModal(scranWarning())
             })
observeEvent(input$scranWarning_cancel, {
  updateSelectInput(session, "clusterMethod",
                    selected = "igraph"
  )
  updateSelectInput(session, "clusterSource",
                    selected = "PCA"
  )
  removeModal()
})
observeEvent(input$scranWarning_ok, {
  removeModal()
})



if (DEBUG) {
  cat(file = stderr(), paste("end: outputs.R\n"))
}

