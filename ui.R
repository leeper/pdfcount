## -----
## ui.R
## -----

library("shiny")
library("markdown")

ui <- fluidPage(
  mainPanel(
    headerPanel("Count Words in a PDF Document"),
    p(""),
    p("Upload your file here:"),
    fileInput("infile", label = NULL, accept = "application/pdf"),
    p(""),
    textOutput("grand_total")
  )
)
