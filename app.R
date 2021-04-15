#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(Quandl)
library(forecast)
library(dygraphs)
sourceCpp("apiKey.cpp")


dataChoices <- c("Gold" = "Gold",
                 "Sliver" = "Sliver", 
                 "Platinum" = "Platinum",
                 "Palladium" = "Palladium" 
); 



frequencyChoices <- c("days" = "daily",
                      "weeks" = "weekly", 
                      "months" = "monthly");

currencyChoices <- c("USD" = 1,
                     "EURO" = 2, 
                     "GBP" = 3);

today <- Sys.Date()


# Define UI for application 
ui <- fluidPage(
    
    # Application title
    titlePanel("Commidity Data"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            
            
            selectInput("dataSet",
                        "Commodity",
                        choices = dataChoices,
                        selected = "Gold"),
            
            selectInput("frequency",
                        "Frequency",
                        choices = frequencyChoices, 
                        selected = "monthly"),
            
            
            sliderInput('dateRange', 'Dates', min = as.Date('2015-01-01', '%Y-%m-%d'), today,
                        dragRange = TRUE, value = c(today - 365, today),
                        timeFormat = '%Y-%m-%d'),
            
            
            sliderInput('periods', 'Time to Forecast', 
                        min = 1, max = 30,
                        value = 5),
            
            selectInput("currency",
                        "Forecast Currency",
                        choices = currencyChoices
            )
            
            
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            dygraphOutput("commodity"),
            #  plotlyOutput('plot'),
            dygraphOutput("forecasted")
        )
    )
)


# Define server logic
server <- function(input, output) {
    
    
    #required library to run the app
    require(Quandl)
    require (forecast)
    require (dygraphs)
    
    #set the api key to Quandl which is required to access api to get data
    Quandl.api_key(getApiKey())
    
    
    #get the data
    commodity <- reactive({
        
        #to speed up the data retrieval select the columns that are needed
        if(input$dataSet =="Gold"){
            codes <- c("LBMA/GOLD.1", "LBMA/GOLD.3", "LBMA/GOLD.5")
        }
        else if (input$dataSet =="Sliver"){
            codes <- c("LBMA/SILVER.1", "LBMA/SILVER.2", "LBMA/SILVER.3")
        }
        else if (input$dataSet =="Platinum"){
            codes <- c("LPPM/PLAT.1", "LPPM/PLAT.2", "LPPM/PLAT.3")
        }
        else{
            codes <- c("LPPM/PALL.1", "LPPM/PALL.2", "LPPM/PALL.3")
        }
        
        
        commodityData <- Quandl(codes,
                                start_date = format(input$dateRange[1]),
                                end_date = format(input$dateRange[2]),
                                order = "asc",
                                type = "xts",
                                collapse = as.character(input$frequency)
        )
        # set meaningful names to columns
        colnames(commodityData) <- c("USD", "EURO" ,"GBP")
        
        commodity<-commodityData
    })
    
    
    #combined actual and forecast data
    combined_xts <- reactive({
        
        forecasted <- forecast(commodity()[, as.numeric(input$currency)], h = input$periods)
        
        forecast_dataframe <- data.frame(
            date = seq(input$dateRange[2], 
                       by = names(frequencyChoices[frequencyChoices == input$frequency]),
                       length.out = input$periods),
            Forecast = forecasted$mean,
            Hi_95 = forecasted$upper[,2],
            Lo_95 = forecasted$lower[,2])
        
        forecast_xts <- xts(forecast_dataframe[,-1], order.by = forecast_dataframe[,1])
        
        combined_xts <- cbind(commodity()[, as.numeric(input$currency)], forecast_xts)
        
        # change  first column name 
        colnames(combined_xts)[1] <- "Actual"
        
        # combined data with history and forecast
        combined_xts
    })
    
    
    
    
    output$commodity <- renderDygraph({
        dygraph(commodity(),
                main = paste("Price history of", names(dataChoices[dataChoices==input$dataSet]))) %>%
            dyAxis("y", label = "Price") %>%
            dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, drawGrid = TRUE)
    })
    
    
    
    output$forecasted <- renderDygraph({
        
        # Change graph a start date and an end date according to forecast time. 
        start_date <- tail(seq(input$dateRange[2], by = "-1 months", length = 6), 1)
        end_date <- tail(seq(input$dateRange[2], 
                             by = names(frequencyChoices[frequencyChoices == input$frequency]), 
                             length = input$periods), 1)
        
        dygraph(combined_xts(),
                main = paste(names(dataChoices[dataChoices==input$dataSet]), 
                             ": Historical and Forecast")) %>%
            
            # Add the actual series.
            dySeries("Actual", label = "Actual") %>%
            # Add the three forecasted series.
            dySeries(c("Lo_95", "Forecast", "Hi_95")) %>% 
            # A range selector to select forecast time 
            dyRangeSelector(dateWindow = c(start_date, end_date))
        
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
