## -----
## ui.R
## -----

library("shiny")

ui <- fluidPage(
  titlePanel("Count Words in a PDF Document"),
  sidebarLayout(
    sidebarPanel(
      strong(p("Upload your file here:")),
      fileInput("infile", label = NULL, accept = "application/pdf"),
      textInput("pages", "Page numbers to count:", "", width = "70%"),
      strong(p("Additional options:")),
      checkboxInput("count_numbers", "Count numbers?", TRUE),
      checkboxInput("count_captions", "Count table/figure captions?", FALSE),
      checkboxInput("count_equations", "Count equation lines?", FALSE),
      checkboxInput("split_hyphenated", "Split hyphenated words?", FALSE),
      checkboxInput("split_urls", "Tokenize URLs?", FALSE)
    ),
    mainPanel(
      strong(textOutput("grand_total")),
      p(""),
      plotOutput("barplot", width = "100%", height = "600px")
    )
  )
)
