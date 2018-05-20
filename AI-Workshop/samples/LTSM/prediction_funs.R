

### Datasets funs ----

#' 
#'
#' @param .length 
#'
getWave <- function(.length = 10e3) {
  stopifnot(
    is.numeric(.length) && .length > 0 
  )

  x <- seq(-2*pi, 2*pi, length.out = .length)
  sin(20*x)
}


#' 
#'
#' @param .length 
#'
getWaves <- function(.length = 10e3) {
  stopifnot(
    is.numeric(.length) && .length > 0 
  )
  
  x <- sin(seq(-2*pi, 2*pi, length.out = .length))
  sin(3*x) + .5*sin(10*x)
}


#' 
#'
#'
getBtcTrades <- function() {
  require(zoo)
  require(xts)
  require(dplyr)
  
  trades <- readRDS("data/btcusd.trades.rds")
  
  dt <- to.hourly(trades$KRAKEN["2016-04/"]) %>% 
    as.data.frame %>% 
    rename(Close = `trades$KRAKEN[\"2016-04/\"].Close`) %>% 
    transmute(
      Close,
      Diff = c(NA_real_, diff(Close)),
      Lag = lag(Close),
      Return = Diff/Lag,
      LogReturn = c(NA_real_, diff(log(Close)))
    ) %>% 
    filter(
      !is.na(LogReturn)
    ) %>% 
    mutate(
      Id = row_number()
    )
  
 
  dt
}


#' 
#'
getBtc1H <- function() {
  require(zoo)
  require(xts)
  require(dplyr)
  require(lubridate)
  
  trades <- readRDS("data/btcusd.rds") %>% 
    filter(Time > Sys.Date() - years(2))
  
  as.xts(trades[, -1], order.by = trades[, 1]) %>% 
    to.hourly %>% 
    as.data.frame %>% 
    transmute(
      Close = `..Close`,
      Diff = c(NA_real_, diff(Close)),
      Lag = lag(Close),
      Return = Diff/Lag,
      LogReturn = c(NA_real_, diff(log(Close)))
    ) %>% 
    na.omit %>% 
    mutate(
      Id = row_number()
    )
}



### Tensor funs ----
#' 
#'
get2DTensor <- function(v, .timeSteps, na.rm = T) {
  stopifnot(
    is.vector(v) && length(v) > 1,
    is.numeric(.timeSteps) && .timeSteps > 0
  )
  
  if (na.rm) v <- na.omit(v)
  
  r <- t(
    sapply(
      1:(length(v) - .timeSteps),
      function(.x) v[.x:(.x + .timeSteps - 1)]
    )
  )
  
  stopifnot(
    !anyNA(r),
    dim(r)[1] == length(v) - .timeSteps,
    dim(r)[2] == .timeSteps
  )
  
  
  r
}


#' Get 3D Tensor
#'
#' @param m Matrix
#'
#' @return 3D array (tensor) w/ dimensions: [samples, timesteps, features]
get3DTensor <- function(m) {
  require(reticulate)
  stopifnot(
    is.matrix(m) && length(dim(m)) == 2
  )
  
  m <- m[-dim(m)[1], ] # one step lag
  array_reshape(m, c(dim(m)[1], dim(m)[2], 1))
}



### Model funs ----

#' 
#'
#' @param actual 
#' @param predicted 
#' 
combineResults <- function(actual, predicted) {
  require(dplyr)
  require(tidyr)
  stopifnot(
    is.vector(actual), is.vector(predicted),
    length(predicted) > 0, length(predicted) == length(actual)
  )
  
  
  dt <- data.frame(Id = 1:length(actual), Predicted = predicted, Actual = actual) %>% 
    gather(Id, Predicted:Actual)
  names(dt) <- c("Id", "Type", "Value")
  
  dt
}


#' 
#'
getScoredResult <- function() {
  require(data.table)
  require(dplyr)
  require(tidyr)
  require(purrr)
  require(lubridate)
  require(TTR)
  
  dt.files <- paste0("http://static.0xcode.in/data/btcusd/", c("BDT.csv", "LR.csv", "NN.csv"))
  
  dt.files %>% 
    map(~ fread(.x) %>% transmute(Score = `Scored Labels`)) %>% 
    flatten %>% 
    as.data.frame %>% 
    cbind(fread(dt.files[[1]]) %>% select(Close, Time)) %>% 
    transmute(
      BDT = Score, LR = `Score.1`, NN = `Score.2`, 
      SMA = SMA(Close, n = 6), 
      EMA = EMA(Close, n = 6), 
      Prev = lag(Close), 
      Close,
      Time = mdy_hms(Time)
    ) %>% 
    mutate_if(
      is.numeric, funs("diff" = . - Close)
    ) %>% 
    select(-Close_diff) %>% 
    filter(!is.na(EMA))
}


#' 
#'
#' @param actual 
#' @param predicted 
#' 
combineResultsX <- function(actual, predicted) {
  require(dplyr)
  require(lubridate)
  require(TTR)
  stopifnot(
    is.vector(actual), is.vector(predicted),
    length(predicted) > 0, length(predicted) == length(actual)
  )
  
  
  data.frame(
      Id = (splitBy + 2):dim(mData)[1], 
      Predicted = predicted, 
      Actual = actual
    ) %>% 
    left_join(
      data %>% mutate(Id = Id - timeStemps + 1), by = "Id"
    ) %>% 
    transmute(
      Close,
      # naive (baseline)
      Prev = lag(Close),
      # classis statistics
      SMA = SMA(Close, n = 3), 
      EMA = EMA(Close, n = 6),
      # Predicted
      Predict = Predicted * Lag + Prev,
      # Time
      Time = Id # todo
    ) %>% 
    mutate_if(
      is.numeric, funs("residuals" = . - Close)
    ) %>% 
    na.omit
}


