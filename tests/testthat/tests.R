context("Test word_count()")

tools::texi2pdf("test.tex")

if ("test.pdf" %in% dir()) {

    # count all words, including numbers
    wc <- word_count("test.pdf")
    
    # count all words, excluding numbers
    wc_no_numbers <- word_count("test.pdf", count_numbers = FALSE)

    test_that("Test word_count()", {
        
        # class
        expect_true(inherits(wc, "data.frame"), label = "word_count() returns PDF")
        
        # nrow()
        expect_true(nrow(wc) == 6L, label = "word_count() returns correct rows")
        
        # ncol() & names()
        expect_true(ncol(wc) == 2L, label = "word_count() returns correct columns")
        expect_true(identical(names(wc), c("page", "words")), label = "word_count() returns correct column names")
        
        # correct counts
        expect_true(all.equal(wc$words, c(8, 6, 6, 21, 12, 6), tolerance = 1L),
                    label = "word_count() returns correct word counts, with numbers")
        expect_true(all.equal(wc_no_numbers$words, c(7, 6, 5, 16, 9, 5), tolerance = 1L),
                    label = "word_count() returns correct word counts, without numbers")

    })

}
