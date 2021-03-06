menuList <- list(
  menuItem("General QC",
           # id="generalQCID",
    tabName = "generalQC", startExpanded = FALSE,
    menuSubItem("UMI histogram", tabName = "gQC_umiHist"),
    menuSubItem("Sample histogram", tabName = "gQC_sampleHist"),
    menuSubItem("PC variance", tabName = "gQC_variancePC"),
    menuSubItem("TSNE plot", tabName = "gQC_tsnePlot"),
    menuSubItem("Umap", tabName = "gQC_umapPlot")
  )
)

tabList <- list(
  tabItem(
    "gQC_umiHist",
    tags$h3("Histogram of UMI counts"),
    fluidRow(column(
      10,
      offset = 1,
      plotOutput("gQC_plotUmiHist") %>% withSpinner()
    ))
  ),

  tabItem(
    "gQC_sampleHist",
    tags$h3("Histogram of cells per sample"),
    fluidRow(column(
      10,
      offset = 1,
      plotOutput("gQC_plotSampleHist") %>% withSpinner()
    ))
  ),

  tabItem(
    "gQC_variancePC",
    tags$h3("Variance of PCs"),
    fluidRow(column(
      10,
      offset = 1,
      plotOutput("gQC_variancePCA") %>% withSpinner()
    ))
  ),
  tsnePlotTab = tabItem(
    tabName = "gQC_tsnePlot",
    fluidRow(div(h3("TSNE Plot"), align = "center")),
    br(),
    fluidRow(
      column(
        3,
        numericInput("gQC_tsneDim", "Tsne dimensions", 3, min = 3, max = 3)
      ),
      column(
        3,
        numericInput("gQC_tsnePerplexity", "Tsne gQC_tsnePerplexity", 30, min = 1, max = 100)
      ),
      column(
        3,
        numericInput("gQC_tsneTheta", "Tsne gQC_tsneTheta", 0.5, min = 0.0, max = 1, step = 0.1)
      ),
      column(
        3,
        numericInput("gQC_tsneSeed", "Tsne gQC_tsneSeed", 1, min = 1, max = 10000)
      )
    ),
    fluidRow(
      column(3, selectInput(
        "gQC_dim3D_x",
        label = "X",
        choices = c("tsne1", "tsne2", "tsne3"),
        selected = "tsne1"
      )),
      column(
        3,
        selectInput(
          "gQC_dim3D_y",
          label = "Y",
          choices = c("tsne1", "tsne2", "tsne3"),
          selected = "tsne2"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_dim3D_z",
          label = "Z",
          choices = c("tsne1", "tsne2", "tsne3"),
          selected = "tsne3"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_col3D",
          label = "colored by",
          choices = c("sampleNames"),
          selected = "sampleNames"
        )
      )
    ),
    fluidRow(column(
      12,
      jqui_resizable(plotlyOutput("gQC_tsne_main"))
    )),

    fluidRow(column(
      10,
      offset = 1,
      tableSelectionUi("gQC_projectionTableMod")
    ))
  ),
  umapTab <- tabItem(

    tabName = "gQC_umapPlot",
    fluidRow(checkboxInput("activateUMAP", "activate Umap projection", FALSE)),
    fluidRow(
      column(
        3,
        selectInput(
          "gQC_um_randSeed",
          label = "random seed",
          choices = c(1:100), selected = "1"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_um_n_neighbors",
          label = "N Neighbors",
          choices = c(2:100), selected = "15"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_um_n_components",
          label = "N components",
          choices = c(2:20), selected = "2"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_um_negative_sample_rate",
          label = "negative_sample_rate",
          choices = c(1:50), selected = "5"
        )
      )
    ),
    fluidRow(
      column(
        3,
        selectInput(
          "gQC_um_metric",
          label = "metric",
          choices = c("euclidean", "manhattan", "cosine", "hamming"),
          selected = "euclidean"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_um_n_epochs",
          label = "n_epochs",
          choices = c(1:1000), selected = "200"
        )
      ),
      # selectInput(
      #   "um_alpha", label = "alpha",
      #   choices = seq(0.1,10,0.1), selected = "1.0"
      # ),
      column(
        3,
        selectInput(
          "gQC_um_init",
          label = "init",
          choices = c("spectral", "random"), selected = "spectral"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_um_spread",
          label = "spread",
          choices = c(1:10), selected = "1"
        )
      )
    ),
    fluidRow(
      column(
        3,
        selectInput(
          "gQC_um_min_dist",
          label = "min_dist",
          choices = seq(0.05, 0.5, 0.01), selected = "0.01"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_um_set_op_mix_ratio",
          label = "set_op_mix_ratio",
          choices = seq(0, 1, 0.1), selected = "1"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_um_local_connectivity",
          label = "local_connectivity",
          choices = 1:20, selected = "1"
        )
      ),
      column(
        3,
        selectInput(
          "gQC_um_bandwidth",
          label = "bandwidth",
          choices = c(1:20), selected = "1"
        )
      )
    ),
    fluidRow(column(
      12,
      clusterUI("gQC_umap_main")
    ))
  )
)
