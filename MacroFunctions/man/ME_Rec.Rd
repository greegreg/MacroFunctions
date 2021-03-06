% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Week4Project.R
\name{ME_Rec}
\alias{ME_Rec}
\title{Recession markers}
\usage{
ME_Rec(B, level = TRUE)
}
\arguments{
\item{B}{is a dataframe of macroeconomic data with a column titled date and one titled  with a "macro variable"}

\item{level}{is a logical variable TRUE means the data in B is measured in levels, FALSE means the data
in B is measured in growth rates.}
}
\value{
A dataframe of recession markers is returned and is ready to be plotted next to macroeconomic
time series data.
}
\description{
Most macroeconomic data when put into a picture is more informative if a recession marker is placed
in the graphic. This function extracts the recession markers and grooms them into a format for easy plotting.
}
\examples{
ME_Rec(X)

}
