### Import dependencies ----
if (!require("Quandl")) install.packages("Quandl")
if (!require("dplyr")) install.packages("dplyr")
if (!require("forecast")) install.packages("forecast")
if (!require("lubridate")) install.packages("lubridate")
if (!require("microbenchmark")) install.packages("microbenchmark")



### Load data ----
## Prepare 
library(dplyr)
library(lubridate)
library(Quandl)

Quandl.api_key("<your_quandl_key>") # replace to your key from Quandl.com
symbol <- "BITSTAMP/USD"



## load financial data
quote <- Quandl(symbol) %>% arrange(Date)

# investigate data
ts.plot(quote$Last)
tsdisplay(quote$Last)
tsdisplay(diff(quote$Last, lag = 1))
tsdisplay(diff(log(quote$Last), lag = 7))



### Predict ----

#' Get forecast 
#'
#' @param dt 
#' @param forecastFun
#' @param forecastingPeriod 
#' @param frequency 
getForecast <- function(dt, forecastFun, fromDate, toDate, frequency = 1) {
  require(dplyr)
  require(forecast)
  require(lubridate)
  
  stopifnot(
    is.data.frame(dt),
    is.function(forecastFun),
    is.Date(fromDate) && is.Date(toDate) && toDate > fromDate,
    is.numeric(frequency) && frequency > 0
  )
  
  dt.train <- dt %>% filter(Date > fromDate - years(1) & Date <= fromDate)
  dt.test <- dt %>% filter(Date > fromDate & Date <= toDate)
  
  
  dt.timeseries <- ts(dt.train$Last, frequency = frequency)
  model <- forecastFun(dt.timeseries)
  
  forecastingPeriod <- as.numeric(max(dt.test$Date)) - as.numeric(max(dt.train$Date)) - 1
  dt.forecast <- forecast(model, h = forecastingPeriod)
  
  print(dt.forecast)
  plot(dt.forecast)
  
  dt.test$PredictedValue <- as.numeric(dt.forecast$mean)
  
  
  return(dt.test)
}


## forecast
forecastTo <- Sys.Date() # as.Date("2017-02-01", "%Y-%m-%d")
forecastFrom <- forecastTo - days(30) 

forecastData <- quote %>% filter(Date > forecastFrom - years(1)) %>% select(Date, Last)
forecastFrequency <- 12

forecast.ArimaNonSeasonal <- getForecast(forecastData, auto.arima, forecastFrom, forecastTo) # ARIMA Non Seasonal
forecast.ArimaSeasonal <- getForecast(forecastData, auto.arima, forecastFrom, forecastTo, forecastFrequency) # ARIMA Seasonal
forecast.EtsNonSeasonal <- getForecast(forecastData, ets, forecastFrom, forecastTo) # ETS Non Seasonal
forecast.EtsSeasonal <- getForecast(forecastData, ets, forecastFrom, forecastTo, forecastFrequency) # ETS Seasonal


## visualize
plot(forecastData$Date, forecastData$Last, type = "l", col = "darkgrey", xlab = "Date", ylab = "Last Price", lwd = 1.5)

lines(forecast.ArimaNonSeasonal$Date, forecast.ArimaNonSeasonal$PredictedValue, col = "red", lwd = 2)
lines(forecast.ArimaSeasonal$Date, forecast.ArimaSeasonal$PredictedValue, col = "orange", lwd = 2)
lines(forecast.EtsNonSeasonal$Date, forecast.EtsNonSeasonal$PredictedValue, col = "darkblue", lwd = 2)
lines(forecast.EtsSeasonal$Date, forecast.EtsSeasonal$PredictedValue, col = "darkgreen", lwd = 2)

legend("topleft", legend = c("Original Data", "ARIMA Non Seasonal", "ARIMA Seasonal", "ETS Non Seasonal", "ETS Seasonal"), 
       bty = c("n","n"), 
       lty = c(1,1), 
       pch = 16, 
       col = c("darkgrey", "red", "orange", "darkblue", "darkgreen"))



