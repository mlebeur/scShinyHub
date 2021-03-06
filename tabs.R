require(shinyMCE)
require(shiny)
source("modulesUI.R")
# this is where the general tabs are defined:
if (file.exists("defaultValues.R")) {
  source("defaultValues.R")
} else {
  defaultValueSingleGene <- ""
  defaultValueMultiGenes <- ""
  defaultValueRegExGene <- ""
}

# inputTab ----
inputTab <- tabItem(
  tabName = "input",
  fluidRow(div(h3("scShinyHub Input"), align = "center")),
  br(),
  fluidRow(div(
    h5(
      "This app is designed for exploratory data analysis of processed RNA-Seq data of single cell experiments. 
      Multiple files can be selected using certain browsers (E.g. chrome). This is not working when running in RStudio as a window.
      Rds files are R data files generated using base::save(). They contain two objects, scEx that hold raw counts in a sparse matrix
      and annotation in a data frame."
    ),
    align = "center"
  )),
  br(),
  br(),
  fluidRow(column(
    5,
    offset = 4,
    fileInput(
      "file1",
      "Choose .Rds file to upload",
      accept = c(
        ".Rds",".RData"
      ),
      multiple = TRUE
    )
  )),
  fluidRow(column(6,
                  textInput("beforeFilterRegEx", "regular expression to count genes/cell", value = "^MT-|^RP|^MRP")
  )),
  fluidRow(column(6,
                  tags$div(
                    
                    tags$p("This regular expression will be used before filtering out genes. 
               It is meant to keep track of genes that were removed from gene filtering. This will generate a projection
                           called 'before.filter'.")
                  )
  ))
)

# geneSelectionTab ----
geneSelectionTab <- tabItem(
  tabName = "geneSelection",
  fluidRow(div(h3("Gene selection"), align = "center")),
  br(),
  fluidRow(div(
    h4(
      "Here we filter out genes"
    ),
    align = "center"
  )),
  fluidRow(
    column(3,
           offset = 1,
           textInput("selectIds", "regular expression for selection of genes to be removed", value = "^MT-|^RP|^MRP")
    ),
    column(
      5,
      h4("GeneList Selection"),
      shinyTree("geneListSelection", checkbox = TRUE)
    ),
    column(
      2,
      h4("Minoverall expression"),
      numericInput("minGenesGS", "Min # of UMIs over all cells", 2, min = 2, max = 1000000)
    )
  ),
  fluidRow(
    column(6,
           offset = 1,
           textInput("genesKeep", "genes to keep")
    )
  ),
  br(),
  fluidRow(
    h3("Genes kept, with mean Expression, and number of cells expressing min 1", align = "center"),
    br(),
    h4("Selected genes"),
    column(12,
           offset = 0,
           textOutput("gsSelectedGenes", inline = FALSE)
    ),
    br(),
    column(10,
           offset = 1,
           DT::dataTableOutput("selectedGenesTable")
    )
  ),
  br(),
  fluidRow(
    h3("Genes removed, with mean Expression, and number of cells expressing min 1", align = "center"),
    h4("Selected genes"),
    br(),
    textOutput("gsrmGenes", inline = FALSE)
  ), br(),
  fluidRow(
    column(10,
           offset = 1,
           DT::dataTableOutput("removedGenesTable")
    )
  )
)

# generalParametersTab ----
generalParametersTab <- tabItem(
  "generalParameters",
  fluidRow(div(h2("General parameters"), align = "center")),
  br(),
  fluidRow(div(h3("Parameters for clustering"), align = "left")),
  fluidRow(
    # column(2,
    #        offset = 1,
    #        numericInput("kNr", "Number of clusters", 10, min = 2, max = 30)
    # ),
    column(2, offset = 0,
           selectInput("clusterSource", "use PCA or normalized data?", choices = c("PCA", "normData"), selected = "PCA")),
    column(2, offset = 0,
           numericInput("minClusterSize", "minimum size of each cluster.", 2, min = 2)),
    column(2, offset = 0,
           selectInput("clusterMethod", "clustering method to use", choices = c("hclust", "igraph"), selected = "igraph"))
  ),
  fluidRow(
    column(10, offset = 1,
    textInput("geneSelectionClustering", "Genes to be used for clustering")
    )
  ),
  br(),
  fluidRow(
    column(10, offset = 1,
           textOutput("Nclusters"))
  ),
  br(),
  fluidRow(div(h3("Comments"), align = "left")),
  fluidRow(
    tinyMCE(
      "descriptionOfWork",
      "Please describe your work. This will be included in the report."
    )
  ),
  br(),
  fluidRow(div(h3("Colors"), align = "left")),
  fluidRow(
    actionButton("updateColors", "Update colours", icon = icon("update"))
  ),
  fluidRow(column(4,offset = 1,
    uiOutput('sampleColorSelection')
  ),
  column(4,offset = 1,
           uiOutput('clusterColorSelection')
  )
  )
  # ,
  # fluidRow(
  #   column(11,offset = 1,
  #          textOutput("descriptOfWorkOutput", inline = TRUE))
  # )
)

# cellSelectionTab ----
cellSelectionTab <- tabItem(
  tabName = "cellSelection",
  fluidRow(div(h3("Cell selection"), align = "center")),
  br(),
  fluidRow(div(
    h4(
      "Here we filter out cells"
    ),
    align = "center"
  )), fluidRow(
    column(6,
           offset = 1,
           tipify(textInput("minExpGenes", "List of genes with minimal expression", value = defaultValueRegExGene),
                  title = "<h3>Cells must have one or more</h3> <ul><li>These cells must have at least one of those genes expressed</li> </ul> ",
                  options = list(
                    "width" = "300px", "placement" = "right", "max-width" = "350px",
                    "data-container" = "body", container = "body"
                  )
           ) # tool tip: '^CD7$|^KIT$
    )
  ),
  fluidRow(
    column(5,
           offset = 1,
           numericInput("minGenes", "Min # of UMIs", 2, min = 2, max = 1000000)
    ),
    column(
      5,
      numericInput("maxGenes", "Max # of UMIs", 1000000, min = 10, max = 1000000)
    )
  ), br(),
  fluidRow(
    column(6,
           offset = 1,
           textInput("cellSelectionComment", "Comment for selection of cells")
    )
  ),
  fluidRow(
    column(6,
           offset = 1,
           tipify(textInput("cellPatternRM", "cells to be filtered out by pattern"),
                  title = "regular expression for cells to be removed (e.g. -1 will remove all cells from sample 1"
           )
    )
  ),
  fluidRow(
    column(6,
           offset = 1,
           tipify(textInput("cellKeep", "cells to keep"),
                  title = "comma separated list of cells (with min expression) that should be kept"
           )
    )
  ), fluidRow(
    column(6,
           offset = 1,
           tipify(textInput("cellKeepOnly", "cells to keep; remove others"),
                  title = "comma separated list of cells (with min expression) that should be kept and anything else removed"
           )
    )
  ),
  fluidRow(
    column(10,
           offset = 1,
           tipify(textInput("cellsFiltersOut", "Cells to be removed", width = "100%"),
                  title = "comma separted list of cell names to be explicitly removed"
           )
    )
  ), br(),
  fluidRow(column(
    11,
    offset = 1,
    tableSelectionUi("cellSelectionMod")
  )), br()
)


# parse all parameters.R files under contributions to include in application
# allTabs holds all tabs regardsless of their location in the GUI
parameterContributions <- list()
parFiles <- dir(path = "contributions", pattern = "parameters.R", full.names = TRUE, recursive = TRUE)
for (fp in parFiles) {
  myPparameters <- list()
  source(fp, local = TRUE)
  if (length(myPparameters) > 0) {
    for (li in myPparameters) {
      if (length(li) > 0) {
        if (DEBUG) cat(file = stderr(), paste(li$children[[1]], "\n"))
        parameterContributions[[length(parameterContributions) + 1]] <- li
      }
    }
  }
}

# submenu items for the paramters main tab
parameterItems <- list(
  menuSubItem("Normalization", tabName = "normalizations"),
  parameterContributions,
  menuSubItem("General Parameters", tabName = "generalParameters")
)




# # link to the content of the
# parametersTab  = tabItem(tabName = "normalizations",
#                             fluidRow(div(h3('Cell selection'), align = 'center')),
#                             br()
# )
if (DEBUG) {
  cat(file = stderr(), paste("end: tabs.R\n"))
}
