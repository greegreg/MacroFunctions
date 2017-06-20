################################################################
#########         This package extracts and cleans #############
#########    Macroeconomic data.                   #############
################################################################



#' Series test
#'
#' This package has only four Macroeconomic data series currently being extracted. This functions checks if the chosen
#' series is available by this function.
#'
#' @references This data is pulled from the Federal Reserve Bank of St. Louis (FRED).
#'
#' @param series This is the name of the macroeconomic data series to extract from FRED.
#' At this point series can take one of four sereis as an argument, RGDP (real Gross domestic product),
#' CPI (consumer price index), Unemploymentrate, (historical unemployment rates), Population,
#' this includes children and US service personel overseas, and Recession NBER dates for recessions.
#'
#' @return A data frame is returned with a macroeconomic series that is ready to plot.

ME_series<-function(series){
        avseries<-toupper(c("RGDP", "CPI", "Unemploymentrate", "Population","Recession"))
        test<-series %in% avseries
        if(test==FALSE){
                stop("This data series is not available to this function")
        }else{
                xout<-TRUE
                return(xout)
        }
}

#' create a file index
#'
#' This function assigns an index number to the series entered in the main function. This index number
#' is used serveral places to extract data for the call to FRED.
#'
#' @param series. This input is controlled by other functions that call this function. It will be one of
#' three macroeconomic data series, RGDP, CPI, Unempmloyment rate, or Populaton.
#'
#' @return an integer is returned and is used to extract data in several other function calls.

fleindex<-function(series){                          #The output of this function tells r how to construct
        tst<-toupper(series)                         #a file sequence and a skip variable
        if(tst=="RGDP"){
                xout<-1
        }else if(tst=="CPI"){
                xout<-2
        }else if(tst=="UNEMPLOYMENTRATE"){
                xout<-3
        }else if(tst=="POPULATION"){
                xout<-4
        }else{
                xout<-5
        }
        return(xout)                                   #Returning an index for extracting data
}

#' Create an on line file extension
#'
#' This function is fed information from the main function and the fleindex function. The function
#' creates a url where macroeconomic data can be extracted from.
#'
#' @param series. Series is a reference to a macroeconomic data series. At this point one of the
#' series RGDP, CPI, Unemployment rate, or population.
#'
#' @param indx. This is a number used to extract information about a call to the FRED. indx is determined
#' by the function fleindex.
#'
#' @return a url is returned that is used as the file extension to extract data from FRED.

fleext<-function(series, indx){                     #This function returns a file extension
        baseprefix<-"https://fred.stlouisfed.org/data"
        tfleext<-c("GDPC1.txt", "CPIAUCSL.txt", "UNRATE.txt", "POP.txt", "USREC.txt")
        xout<-file.path(baseprefix, tfleext[indx])
        return(xout)
}

#' Extract Macroeconomic data
#'
#' This function is given a single argument. The argement is a data macroeconomic data series
#' that is pulled from the federal reserve bank of St. Louis (FRED).
#'
#' @source St. Louis Federal Reserve Bank data (FRED)
#'
#' @param series At this point series can be only one of four character strings, RGDP, Real Gross
#' domestic product, CPI, consumer price index, uneploymentrate, the US civilian unemployment rate,
#' and population, Total Population: All ages including Armed Forces Overseas.
#'
#' @return A dataframe is returned with a time-series for the given argument placed within the function.
#' This data frame is ready to be plotted and shown to a macroeconomic class, for example.
#'
#' @examples ME_dtaextract("RGDP")
#' @examples ME_dtaextract("Unemploymentrate")
#' @examples ME_dtaextract("Population")
#'
#'
#' @export



ME_dtaextract<-function(series){                     #This is the main function
        srs<-toupper(series)
        tst<-ME_series(srs)
        if(tst==TRUE){
                indx<-fleindex(srs)               #Returns the extraction index for the vector index
                flenm<-fleext(srs, indx)
                fskip<-c(19, 54, 24, 30, 71)
                units<-c("millions", "Index", "percent", "thousands", "unit")
                skp<-fskip[indx]
                unt<-units[indx]
                dfout<-read_table(flenm, col_names=TRUE, skip=skp, col_types="Dd") %>%
                        mutate(units=unt)
                colnames(dfout)<-c("date", tolower(srs), "units")
        }
        return(dfout)                                 #Returns a data frame with the chosen series
}

#' Calculate a growth rate
#'
#' This function calculates a growth rate from an existing data series.
#'
#' @param X is a data frame containing a time series of macroeconomic data.
#'
#' @return This functions returs a data frame containing the growth rates calculated from X

grth<-function(X){
        n<-nrow(X)
        v<-X[,2][[1]]
        dv<-diff(v)
        gr<-dv/v[1:(n-1)]
        gr<-data.frame(Growth=c(NA,gr))
        return(gr)
}

#' Detect the frequency of the data
#'
#' This function will detect the frequency of collection in the data of a time series data frame. This allows data to be marked by its frequency and for growth rates to ge adjusted to annual rates if necessary.
#'
#'  @param X is a data frame containing time series data. Including a column of dates.
#'
#'  @return This function returns a list with two elements. First is the frequency of the time series.
#'  Second, is a conversion factor used to convert data to annual data.

TM_detect<-function(X){
        dt1<-as.numeric(X[1,1][[1]])
        dt2<-as.numeric(X[2,1][[1]])
        dt<-abs(dt1-dt2)
        if(dt<=1){
                xout<-list("Daily",365)
        }else if(dt<=31){
                xout<-list("Monthly", 12)
        }else if(dt<=3*31){
                xout<-list("Quarterly",4)
        }else{
                xout<-list("Annual",1)
        }
        return(xout)
}

#' Calculate a growth rate
#'
#' Time series data is frequently converted to growth rate data. In the conversion to growth rates
#' a data point within the data series is lost.
#'
#' @param X is a time series data frame. There should be a column containing a date class variable and a column
#' containing a macroeconomic variable.
#'
#' @param mindate is a date in character fomat, in the form YYYY-mm-dd specifying the minimum date in the date set
#'
#' @param maxdate is a date in character fomrate, in the form YYYY-mm-dd specifying the maximum date in the date set
#'
#' @return a dataframe is returned by this function containing two different growth rates, a growth
#'  rate per unit of time in the data and an annual growth rate.
#'
#'
#'  @examples ME_growth(X)
#'  @examples ME_growth(X, "1970-01-01")
#'  @examples ME_growth(X, "1965-09-07", "2010-01-01")
#'
#'
#'  @export



ME_growth<-function(X, mindate=NULL, maxdate=NULL){
        nms<-names(X)
        if(!("Growth" %in% nms)){
                xout<-cbind(X, grth(X))
                xout<-xout[-1,]
                TME<-TM_detect(xout)
                xout<-xout %>% mutate(Measure=TME[[1]][[1]],
                                             Annual_Growth=Growth*TME[[2]][[1]], Measured="Annual")
        }else{
                        xout<-X
                }
        if(!is.null(mindate) | !is.null(maxdate)){
                xout<-dt_trim(xout,mindate=mindate, maxdate=maxdate)
        }
        return(xout)
}

#' Trim a data frame
#'
#' The data frame X is a time series data set with dates reaching back as far as the 1860s. This function
#' will trim that data set to the desired duration of time
#'
#' @param X is a time series containing a macroeconomic time series
#' @param mindate is a character variable representing the date the user wants the time series to start, if the data
#' allows this start date.
#' @param maxdate is a character variable representing the date the user wants the time series to end, if the data allows this end date.
#'
#' @return A dataframe is returned containing only data between the specified dates.
#'


dt_trim<-function(X, mindate=NULL, maxdate=NULL){
        if(!is.null(mindate)){
                tmindate<-as.Date(mindate)
        }else{
                tmindate<-min(X$date)
        }
        if(!is.null(maxdate)){
                tmaxdate<-as.Date(maxdate)
        }else{
                tmaxdate<-max(X$date)
        }
        xout<-X %>% filter(date>=tmindate & date<=tmaxdate)
        return(xout)
}

#' Create recession markers
#'
#' This function requires two dataframes as input. With the input this function trims the B dataframe to the same
#' start date as the A dataframe.
#'
#' @param A is a dataframe of macroeconomic data created by the ME_dtaextract function and has be trimmed
#' using the ME_growth function (or not).
#' @param B is a dataframe created by the ME_Rec function.
#' @param level is a logical variable specifying if the level data should be matched to the recession data or if the
#' growth rate data should be matched to the recession data.
#'
#' @return A data frame of recession markers the same length as the input dataframe A is returned. This dataframe
#' is now ready to be plotted in the same.
#'


groomdata<-function(A, B, level){
        if(level==TRUE){
                XOUT<-A %>%  mutate(Cyc=max(B[,2])*recession) %>% filter(date>=min(B$date))
        }else{
                XOUT<-A %>%  mutate(Cyc=max(B[,6])*recession) %>% filter(date>=min(B$date))
        }

}

#' Recession markers
#'
#' Most macroeconomic data when put into a picture is more informative if a recession marker is placed
#' in the graphic. This function extracts the recession markers and grooms them into a format for easy plotting.
#'
#' @param B is a dataframe of macroeconomic data with a column titled date and one titled  with a "macro variable"
#' @param level is a logical variable TRUE means the data in B is measured in levels, FALSE means the data
#' in B is measured in growth rates.
#'
#' @return A dataframe of recession markers is returned and is ready to be plotted next to macroeconomic
#' time series data.
#'
#' @examples ME_Rec(X)
#'
#' @export

ME_Rec<-function(B, level=TRUE){
        A<-ME_dtaextract("Recession")                #Extract the recession data
        XOUT<-groomdata(A,B, level)
        return(XOUT)
}

