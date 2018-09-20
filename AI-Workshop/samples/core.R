
#'
#' Core functions
#'



#' Get split index for dataset
#'
#' @param dt Dataset 
#' @param .frac Split fraction (left dataset)
#'
getSplitter <- function(dt, .frac = .7) {
  require(dplyr)
  stopifnot(
    is.data.frame(dt),
    is.double(.frac) && (.frac > 0 & .frac <= 1)
  )
  
  
  left <- sample(
    seq(1:nrow(dt)),
    round(nrow(dt) * .frac),
    replace = F
  )
  
  right <- setdiff(
    seq(1:nrow(dt)),
    left
  )
  
  list(L = left, R = right)
}



#' Apply splitter for dataset
#'
#' @param dt Dataset (last column must be Label)
#' @param .splitter Splitter
#'
applySplitter <- function(dt, .splitter, .asMatrix = F) {
  require(dplyr)
  stopifnot(
    is.data.frame(dt),
    is.list(.splitter) && length(.splitter) == 2
  )
  
  
  list(
    Train = list(
      X = dt[.splitter$L, -ncol(dt)],
      Y = dt[.splitter$L, ncol(dt)]
    ),
    Valid = list(
      X = dt[.splitter$R, -ncol(dt)],
      Y = dt[.splitter$R, ncol(dt)]
    )
  )
}


