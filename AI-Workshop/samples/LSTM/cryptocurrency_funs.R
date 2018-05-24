
#'
#' Source: https://github.com/codez0mb1e/Minotaur/blob/master/source/Persephone/cryptocurrency.functions.R
#'

#' Load Bitcoin/Currency pair trades
#'
#' @param market Market
#' @param symbol Symbol (support only BTCUSD)
#' @param .from From time (inclusive bound)
#' @param .to To time (exclusive bound)
#' @param dataSource Trades source (support only bitcoincharts API) 
#' @param apiKey API key
#' 
#' @return Dataframe w/ Bitcoin/Currency pair trades
#' 
#' @example cryptocurrency.getTrades("ITBIT", "BTCUSD", fromTime, toTime)
#' @dtails http://api.bitcoincharts.com/v1/csv
#' 
cryptocurrency.loadTrades <- function(market, symbol, .from, .to, dataSource = "api.bitcoincharts.com/v1", apiKey = NULL) {
  require(dplyr)
  require(xts)
  stopifnot(
    is.character(market),
    is.character(dataSource) && dataSource == "api.bitcoincharts.com/v1",
    is.POSIXt(.from),
    is.POSIXt(.to) && .to > .from,
    is.null(apiKey) || is.character(apiKey)
  )
  
  
  dt <- data.frame()
  
  temp <- tempfile()
  url <- sprintf("http://%s/csv/%sUSD.csv.gz", dataSource, tolower(market))
  try({
    # set_config(config(ssl_verifypeer = 0L)) # note: if SSL cert verification failed
    download.file(url, temp)
    dt <- read.table(temp, sep = ",", header = F, stringsAsFactors = F)
  })
  unlink(temp)
  
  
  if (nrow(dt) == 0) {
    stop("Empty dataset")
  } else {
    dt <- dt %>% 
      transmute(
        Time = as.POSIXct(V1, origin = "1970-01-01"),
        Price = V2, 
        Volume = V3
      ) %>% 
      filter(
        Time >= .from & Time < .to
      )
  }
  
  
  merge.xts(
    Price = xts(dt$Price, order.by = dt$Time),
    Volume = xts(dt$Volume, order.by = dt$Time),
    join = "inner"
  )
}


