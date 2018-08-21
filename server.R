## --------
## server.R
## --------

library("shiny")
library("ggplot2")
source("R/word_count.R")

server <- function(input, output) {
    count <- reactive({
        infile <- input$infile
        if (is.null(infile)) {
            return(NULL)
        }
        word_count(infile$datapath,
                   pages = if (is.null(input$pages)) NULL else eval(parse(text = paste0("c(", input$pages, ")"))),
                   count_numbers = input$count_numbers,
                   count_captions = input$count_captions,
                   count_equations = input$count_equations,
                   split_hyphenated = input$split_hyphenated,
                   split_urls = input$split_urls,
                   verbose = FALSE)
    })
    
    # total word count
    output$grand_total <- renderText({
        counts <- count()
        if (is.null(counts)) {
            return("")
        }
        paste("Word Count:", sum(counts$words, na.rm = TRUE))
    })
    
    # graph of word counts by page
    output$barplot <- renderPlot({
        counts <- count()
        if (is.null(counts)) {
            return(NULL)
        }
        ggplot(counts, aes(x = page, y = words)) +
          xlab("Page") +
          ylab("Words per page") +
          scale_x_reverse() + 
          geom_col() +
          coord_flip() +
          theme_minimal()
    })
}
