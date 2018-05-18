context("test-genesids.R")
### Tests for function genesIds and the SnpSeek call ###


## Tests of input 
test_that("Input must be a data.frame",{
	testthat::expect_error( genesIds(1,148907,248907))
    testthat::expect_error( genesIds("1 148907 248907"))
    testthat::expect_error( genesIds( list(c=1, 148907, 248907)))
})

test_that("Input is empty",{
	testthat::expect_error( genesIds( data.frame()))
})

test_that("Input contains erroned or missing data",{
	testthat::expect_error( genesIds( data.frame(ch = c(1), start = c(148907), end = c())))
	testthat::expect_error( genesIds( data.frame(ch = c("chr1"), start = c(148907), end = c(248907))))
})

test_that("Chromosone number must be between 1 and 12",{
	testthat::expect_error( genesIds( data.frame(ch = c(-1), start = c(148907), end = c(248907))))
	testthat::expect_error( genesIds( data.frame(ch = c(15), start = c(148907), end = c(248907))))
	testthat::expect_error( genesIds( data.frame(ch = c(0), start = c(148907), end = c(248907))))
})

test_that("Locus is not a good range",{
	testthat::expect_error( genesIds( data.frame(ch = c(1), start = c(-148907), end = c(248907))))
	testthat::expect_error( genesIds( data.frame(ch = c(1), start = c(148907), end = c(-248907))))
	testthat::expect_error( genesIds( data.frame(ch = c(1), start = c(248907), end = c(148907))))
})

test_that("Input must have 3 columns",{
	testthat::expect_length(locus, 3)
	testthat::expect_length(locusList, 3)
})


## Tests of output 
locus <- data.frame(ch = c(1), start = c(148907), end = c(248907))
locusList <-  data.frame( ch = c(1,4,8,11),
						 start = c(148907,15994428,365144,6612124), 
						 end = c(248907,16674635,465144,7387831))

test_that("Output is on a good format",{
    testthat::expect_is( genesIds(locus), "data.frame")
    testthat::expect_is( genesIds(locusList), "data.frame")
    testthat::expect_length(locus, 3)
})

test_that("Output is not empty",{
	testthat::expect_gt( nrow( genesIds(locus)), 0)
	testthat::expect_gt( nrow( genesIds(locusList)), 0)
})
