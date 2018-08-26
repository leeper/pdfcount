#' @title Word Count a PDF
#' @description Obtain a Word Count from a PDF
#' @param document A file path specifying a PDF document.
#' @param pages Optionally, an integer vector specifying a subset of pages to count from. Negative values serve as negative subsets.
#' @param count_numbers A logical specifying whether to count numbers as words.
#' @param count_captions A logical specifying whether to count lines beginning with \dQuote{Table} or \dQuote{Figure} in word count.
#' @param count_equations A logical specifying whether to count lines ending with \dQuote{([Number])} in word count.
#' @param split_hyphenated A logical specifying whether to split hyphenated words or expressions as separate words.
#' @param split_urls A logical specifying whether to split URLs into multiple words when counting.
#' @param verbose A logical specifying whether to be verbose. If \code{TRUE}, the page and word counts are printed to the console and the result is is returned invisibly. If \code{FALSE}, the result is visible.
#' @return A data frame with two columns, one specifying page and the other specifying word count for that page.
#' @details This is useful for obtaining a word count for a LaTeX-compiled PDF. Counting words in the tex source is a likely undercount (due to missing citations, cross-references, and parenthetical citations). Counting words from the PDF is likely over count (due to hyphenation issues, URLs, ligatures, tables and figures, and various other things). This function tries to obtain a word from the PDF while accounting for some of the sources of overcounting.
#' 
#' It is often desirable to have word counts excluding tables and figures. A solution on TeX StackExchange (\url{https://tex.stackexchange.com/a/352394/30039}) provides guidance on how to exclude tables and figures (or any arbitrary LaTeX environment) from a compiled document, which may be useful before attempting to word count the PDF.
#' 
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' # "R-intro.pdf" manual
#' rintro <- file.path(Sys.getenv("R_HOME"), "doc", "manual", "R-intro.pdf")
#' 
#' # Online service at http://www.montereylanguages.com/pdf-word-count-online-free-tool.html
#' # claims the word count to be 36,530 words
#' 
#' # Microsoft Word (PDF conversion) word count is 36,869 words
#' 
#' word_count(rintro)      # all pages (105 pages, 37870 words)
#' word_count(rintro, 1:3) # pages 1-3
#' word_count(rintro, -1)  # skip first page
#'
#' @import pdftools
#' @import dplyr
#' @import tidytext
#' @export
word_count <-
function(
  document,
  pages = NULL,
  count_numbers = TRUE,
  count_captions = FALSE,
  count_equations = FALSE,
  split_hyphenated = FALSE,
  split_urls = FALSE,
  verbose = getOption("verbose", FALSE)
) {
    
    # import
    char <- pdftools::pdf_text(document)
    
    # handle URLs
    ## unnest_tokens() splits URLs by default into multiple tokens
    if (!isTRUE(split_urls)) {
        # borrowed from: https://stackoverflow.com/a/8234912/2338862
        url_regex <- "((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[-;:&=+$,\\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=+$,\\w]+@)[A-Za-z0-9.-]+)((?:\\/[\\+~%\\/.\\w-_]*)?\\??(?:[-\\\\+=&;%@.\\w_]*)#?(?:[\\w]*))?)"
        char <- gsub(url_regex, "URL", char, perl = TRUE)
    }
    
    # cleanup hypenations across line breaks
    char <- gsub("-\n", "", char)
    
    # handle hyphenated words
    ## unnest_tokens() splits URLs by default into multiple tokens
    if (!isTRUE(split_hyphenated)) {
        char <- gsub("(?<=.)-(?=.)", "", char, perl = TRUE)
    }
    
    # subset pages
    all_pages <- seq_len(length(char))
    if (!is.null(pages)) {
        to_count <- rep(FALSE, length(char))
        ## inclusions
        pos <- pages[pages > 0]
        if (length(pos)) {
            to_count[pos] <- TRUE
        } else {
            to_count[] <- TRUE
        }
        ## exclusions
        neg <- pages[pages < 0]
        if (length(neg)) {
            to_count[abs(neg)] <- FALSE
        }
        ## subset
        char <- char[to_count]
        pages <- all_pages[to_count]
    } else {
        pages <- all_pages
    }
    
    # tidy lines
    txt_df <- data.frame(page = pages, text = char, stringsAsFactors = FALSE)
    tidy_lines <- tidytext::unnest_tokens(txt_df, line, text, token = "lines")
    
    # remove likely figure/title captions
    if (!isTRUE(count_captions)) {
        tidy_lines <- tidy_lines[!grepl("^([Ff]igure)|([Tt]able) [[:digit:]]+ ?[.:,] ?", tidy_lines$line), ]
    }
    
    # remove likely equations
    if (!isTRUE(count_equations)) {
        tidy_lines <- tidy_lines[!grepl(" +\\([[:digit:]]+\\)$", tidy_lines$line), ]
    }
    
    # tidy words
    tidy_words <- tidytext::unnest_tokens(tidy_lines, word, line, drop = FALSE)
    
    # handle numbers
    if (!isTRUE(count_numbers)) {
        suppressWarnings(tidy_words$number <- as.numeric(tidy_words$word))
        tidy_words <- tidy_words[is.na(tidy_words$number), ]
        tidy_words$number <- NULL
    }
    
    # count and, if verbose, message() the count
    if (isTRUE(verbose)) {
        message(sprintf("Document with %d %s and %d %s",
                        nrow(txt_df),
                        ngettext(nrow(txt_df), "page", "pages"),
                        nrow(tidy_words),
                        ngettext(nrow(tidy_words), "word", "words")))
    }
    
    # construct page-level data frame of counts to return
    out <- dplyr::ungroup(dplyr::summarize(dplyr::group_by(tidy_words, page), words = n()))
    
    if (isTRUE(verbose)) {
        invisible(out)
    } else {
        out
    }
}
