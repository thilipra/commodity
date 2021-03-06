#' Get and Set Quandl API Key
#'
#' @description
#' Get the Quandl API Key which is required to get data
#' if API key is not found then set the default api key 
#' using setkey function
#' @author Thilini Dasanayaka
#' @return Quandl API key
#' 
getApiKey <- function(){
  key = getOption("Quandl.key")
  if(is.null(key)){
    setApiKey()
    key = getOption("Quandl.key")
  }
    return(key)
}

#' Set API key 
#' @description
#' Store the Quandl API Key in global option 
#' if API key is not valid then rise the error message
#' 
#' @param  key if user input null or invalid set the default
#' @return TRUE is key is valid error msg in otherwise
#' @example setApiKey("dsZGE2bdQS6oKGoYLjdt")
#' @export
setApiKey <- function(key ='dsZGE2bdQS6oKGoYLjdt'){
  
    if(nchar(key) != 20)  
      stop("Api key is not valid")
    options(Quandl.key=key)
    return(TRUE)
}
