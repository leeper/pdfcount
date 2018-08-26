## --------
## server.R
## --------

library("shiny")
library("ggplot2")
library("plotly")
source("R/word_count.R")

server <- function(input, output) {
    count <- reactive({
        infile <- input$infile
        if (is.null(infile)) {
            return(NULL)
        }
        pages <- if (is.null(input$pages)) {
            NULL
        } else {
            # try to parse pages
            try_pages <- try(eval(parse(text = paste0("c(", input$pages, ")"))), silent = TRUE)
            if (!inherits(try_pages, "try-error")) {
                pages <- try_pages
            } else {
                pages <- NULL
            }
        }
        
        # count words
        word_count(infile$datapath,
                   pages = pages,
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
        paste("Total Word Count:", sum(counts$words, na.rm = TRUE))
    })
    
    # text to display when showing per-page word counts
    output$page_counts <- renderText({
        counts <- count()
        if (is.null(counts)) {
            return("")
        }
        paste("Word Count by Page:")
    })
    
    # graph of word counts by page
    output$barplot <- renderPlotly({
        counts <- count()
        if (is.null(counts)) {
            return(NULL)
        }
        
        # plot
        ggplot(counts, aes(x = page, y = words)) +
          xlab("Page") +
          ylab("Words per page") +
          scale_x_reverse(breaks = seq_len(max(counts$page, na.rm = TRUE))) + 
          geom_col(na.rm = TRUE) +
          coord_flip() +
          theme_minimal()
    })
}
