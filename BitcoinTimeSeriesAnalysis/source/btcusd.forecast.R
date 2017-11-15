### Import dependencies ----
if (!require("Quandl")) install.packages("Quandl")
if (!require("dplyr")) install.packages("dplyr")
if (!require("forecast")) install.packages("forecast")
if (!require("lubridate")) install.packages("lubridate")
if (!require("microbenchmark")) install.packages("microbenchmark")



## Prepare 
library(Quandl)
library(dplyr)

Quandl.api_key("zL7BE8_cbDvuN1iAmg-w")
BtcUsd.symbol <- "BITSTAMP/USD"



## load financial data
BtcUsd <- Quandl(BtcUsd.symbol) %>% 
            filter(Date >= Sys.Date() - years(1)) %>% 
            #filter(Date >= Sys.Date() - years(2) & Date < Sys.Date() - days(180)) %>% 
            arrange(Date)

ts.plot(BtcUsd$Last)




#' Get Forecast 
#'
#' @param dt 
#' @param f 
#' @param forecastingPeriod 
#' @param frequency 
getForecast <- function(dt, f, forecastingPeriod, frequency = 1) {
  require(dplyr)
  require(forecast)
  require(lubridate)
  
  stopifnot(
    is.data.frame(dt),
    is.numeric(forecastingPeriod) && forecastingPeriod > 0,
    is.numeric(frequency) && frequency > 0
  )
  
  dt.train <- dt %>% filter(Date < max(Date) - days(forecastingPeriod))
  dt.test <- dt %>% filter(Date >= max(Date) - days(forecastingPeriod))
  
  
  dt.timeseries <- ts(dt.train$Last, frequency = frequency)
  model <- f(dt.timeseries)
  
  dt.forecast <- forecast(model, h = forecastingPeriod)
  print(dt.forecast)
  
  dt.test$PredictedValue <- as.numeric(dt.forecast$mean)
  
  dt.test
}


## forecast
forecastPeriod <- 30
forecastFrequency <- 12
forecastData <- BtcUsd %>% select(Date, Last)

forecast.ArimaNonSeasonal  <- getForecast(forecastData, auto.arima, forecastPeriod) # ARIMA Non Seasonal
forecast.ArimaSeasonal <- getForecast(forecastData, auto.arima, forecastPeriod, forecastFrequency) # ARIMA Seasonal
forecast.EtsNonSeasonal <- getForecast(forecastData, ets, forecastPeriod) # ETS Non Seasonal
forecast.EtsSeasonal <- getForecast(forecastData, ets, forecastPeriod, forecastFrequency) # ETS Seasonal


plot(forecastData$Date, forecastData$Last, type = "l", col = "darkgrey", xlab = "Date", ylab = "Last", lwd = 1.5)
lines(forecast.ArimaNonSeasonal$Date, forecast.ArimaNonSeasonal$PredictedValue, col = "red", lwd = 1.5)
lines(forecast.ArimaSeasonal$Date, forecast.ArimaSeasonal$PredictedValue, col = "orange", lwd = 1.5)
lines(forecast.EtsNonSeasonal$Date, forecast.EtsNonSeasonal$PredictedValue, col = "darkblue", lwd = 1.5)
lines(forecast.EtsSeasonal$Date, forecast.EtsSeasonal$PredictedValue, col = "darkgreen", lwd = 1.5)

legend("topleft", legend = c("Original Data", "ARIMA Non Seasonal", "ARIMA Seasonal", "ETS Non Seasonal", "ETS Seasonal"), 
       bty = c("n","n"), 
       lty = c(1,1), 
       pch = 16, 
       col = c("darkgrey", "red", "orange", "darkblue", "darkgreen"))












