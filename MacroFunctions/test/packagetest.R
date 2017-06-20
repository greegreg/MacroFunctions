library(testthat)
library(dplyr)

test_that("DataExtraction",{
        REC<-ME_dtaextract("RECession")            #Extract the recession data
        expect_that(REC, is_a("data.frame"))
        REC<-REC %>% filter(date<="2010-01-01") %>%
                summarise(total=sum(recession))
        expect_that(REC[[1]][[1]], equals(576))
        X<-ME_dtaextract("rgdp")
        expect_that(X, is_a("data.frame"))
        X<-ME_growth(X)
        expect_that(X, is_a("data.frame"))
})
