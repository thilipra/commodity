



#' getSummary
#' 
#' @description
#' Get the summary value of the commodity in the certain based on the user input
#' summary details minimum value , 1st quarter ,median ,mean , 3rd quarter and maximum value
#' 
#' @param commodity commodity name one of the following Gold,Sliver,Platinum,Palladium
#' @param startDate format YYYY-MM-DD  if no value provide assign the default value that is 1 years from current date 
#' @param endDate   format YYYY-MM-DD  default value current date
#' @return Data table 
#' @author Thilini Dasanayaka
#' 
#'@examples
#'commoditySummary("gold")
#'
#'commoditySummary("gold","2020-01-01","2021-01-01")
#'  
#' 
#' @export

library(Quandl)

commoditySummary <- function(commodity,startDate=Sys.Date()-lubridate::years(1),
                              endDate=Sys.Date())
{
  Quandl.api_key('dsZGE2bdQS6oKGoYLjdt')
  
  
  # Trim and lower case the input
  commodity <- str_trim(commodity)
  commodity <- tolower(commodity)
  
  if(commodity =="gold"){
    codes <- c("LBMA/GOLD.1", "LBMA/GOLD.3", "LBMA/GOLD.5")
  }
  else if (commodity =="sliver"){
    codes <- c("LBMA/SILVER.1", "LBMA/SILVER.2", "LBMA/SILVER.3")
  }
  else if (commodity =="platinum"){
    codes <- c("LPPM/PLAT.1", "LPPM/PLAT.2", "LPPM/PLAT.3")
  }
  else if (commodity =="palladium"){
    codes <- c("LPPM/PALL.1", "LPPM/PALL.2", "LPPM/PALL.3")
  }
  else{
    stop("Please enter valid commodity name : Gold,Sliver,Platinum,Palladium")
  }
  
  #check the validity of the date and time period
  validateDays(startDate,endDate)
  
  commodity_sum <- Quandl(codes, 
                          type = "xts", 
                          collapse = "daily",
                          start_date =startDate, 
                          end_date = endDate)
  
  colnames(commodity_sum) <- c("USD", "EURO" ,"GBP")
  
  return (summary(commodity_sum))
}


#' Validate days
#'
#' @description
#' Function that checks the format  date and validity 
#' @param startDate a string value that represent the date
#' @param endDate  a string value that represent the date
#' @return TRUE if valid else terminates the process
#' @export

validateDays <- function(startDate,endDate)
{
  #Checks date format
  if(!IsDate(startDate)|!IsDate(endDate))  
  {
    stop("Error in Date Format")
  }
  
  if((startDate)>=(endDate)|
     (endDate)>Sys.Date())  
  {
    stop("Check the validity of the time period")
  }
}


#' Check Date
#'
#' @description
#' Function to check date in YYYY-MM-DD format 
#' @param dateString a sting that represent the date
#' @return boolean value based on the validity
#' @export

IsDate <- function(dateString)
{
  tryCatch(!is.na(as.Date(dateString, "%Y-%m-%d")), error = function(err) {FALSE})
}

