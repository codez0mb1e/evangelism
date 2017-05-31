packages <- c("dplyr", "microbenchmark", "data.table", "reshape2", "ROCR",
              "devtools", "shiny", "mlbench", "caret", "ggplot2")
packages.missing <- packages[!(packages %in% installed.packages()[, 1])]


## install packages 
# from cran repository
if (length(packages.missing) != 0) {
  install.packages(packages.missing)
}
# from github
#devtools::install_github("ropensci/plotly")
#devtools::install_github('hadley/ggplot2')
devtools::install_github('hadley/ggplot2')
#GC
rm(packages)
rm(packages.missing)

