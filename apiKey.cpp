#include <Rcpp.h>
#include <string>
using namespace Rcpp;



// static variable to store key
static String apiKey;

//' Get and Set Quandl API Key
//'
//' @description
//' Get the Quandl API Key which is required to get data
//' if API key is not found then set the default api key 
//' using setkey function
//' @author Thilini Dasanayaka
//' @return Quandl API key
// [[Rcpp::export]]
bool setApiKey(String key="dsZGE2bdQS6oKGoYLjdt"){
  std::string s =key;
  if(s.size() ==20)
  apiKey=key;
  else
    return false;
  return true;
  }


//' Set API key 
//' @description
//' Store the Quandl API Key in global option 
//' if API key is not valid then rise the error message
//' 
//' @param  key if user input null or invalid set the default
//' @return TRUE is key is valid error msg in otherwise
//' @example setApiKey("dsZGE2bdQS6oKGoYLjdt")
//' @export
// [[Rcpp::export]]
String  getApiKey() {
  std::string s =apiKey;
  if(s.size() ==0)
    setApiKey();
  return apiKey;
}
