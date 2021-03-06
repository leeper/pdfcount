% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/word_count.R
\name{word_count}
\alias{word_count}
\title{Word Count a PDF}
\usage{
word_count(document, pages = NULL, count_numbers = TRUE,
  count_captions = FALSE, count_equations = FALSE,
  split_hyphenated = FALSE, split_urls = FALSE,
  verbose = getOption("verbose", FALSE))
}
\arguments{
\item{document}{A file path specifying a PDF document.}

\item{pages}{Optionally, an integer vector specifying a subset of pages to count from. Negative values serve as negative subsets.}

\item{count_numbers}{A logical specifying whether to count numbers as words.}

\item{count_captions}{A logical specifying whether to count lines beginning with \dQuote{Table} or \dQuote{Figure} in word count.}

\item{count_equations}{A logical specifying whether to count lines ending with \dQuote{([Number])} in word count.}

\item{split_hyphenated}{A logical specifying whether to split hyphenated words or expressions as separate words.}

\item{split_urls}{A logical specifying whether to split URLs into multiple words when counting.}

\item{verbose}{A logical specifying whether to be verbose. If \code{TRUE}, the page and word counts are printed to the console and the result is is returned invisibly. If \code{FALSE}, the result is visible.}
}
\value{
A data frame with two columns, one specifying page and the other specifying word count for that page.
}
\description{
Obtain a Word Count from a PDF
}
\details{
This is useful for obtaining a word count for a LaTeX-compiled PDF. Counting words in the tex source is a likely undercount (due to missing citations, cross-references, and parenthetical citations). Counting words from the PDF is likely over count (due to hyphenation issues, URLs, ligatures, tables and figures, and various other things). This function tries to obtain a word from the PDF while accounting for some of the sources of overcounting.

It is often desirable to have word counts excluding tables and figures. A solution on TeX StackExchange (\url{https://tex.stackexchange.com/a/352394/30039}) provides guidance on how to exclude tables and figures (or any arbitrary LaTeX environment) from a compiled document, which may be useful before attempting to word count the PDF.
}
\examples{
\dontrun{
# "R-intro.pdf" manual
rintro <- file.path(Sys.getenv("R_HOME"), "doc", "manual", "R-intro.pdf")

# Online service at http://www.montereylanguages.com/pdf-word-count-online-free-tool.html
# claims the word count to be 36,530 words

# Microsoft Word (PDF conversion) word count is 36,869 words

word_count(rintro)      # all pages (105 pages, 37870 words)
word_count(rintro, 1:3) # pages 1-3
word_count(rintro, -1)  # skip first page
}
}
\author{
Thomas J. Leeper <thosjleeper@gmail.com>
}
