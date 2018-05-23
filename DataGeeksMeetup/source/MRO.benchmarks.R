### Import dependencies ----
if (!require("parallel")) install.packages("parallel")
if (!require("microbenchmark")) install.packages("microbenchmark")


### MRO vs R CRAN benchmarks ----
library(microbenchmark)

## compute vector mean
microbenchmark({
  foo <- rnorm(1e6) # 1M length vector
  mean(foo)
}, 
times = 100)

#> Unit: milliseconds
#> runtime      min       lq        mean      median       uq      max neval
#> R 3.4.1      77.6294   78.93106  95.42761  81.30831 129.623 133.3101    10
#> MRO 3.4.1    76.51009  76.67314  77.77524  77.24796 78.40054 81.42056    10


## compute matrix cross product
microbenchmark({
  m <- matrix(runif(1e4), nrow = 100) # 100x100 matrix
  crossprod(m)
}, 
times = 100)

#> Unit: microseconds
#> runtime      min       lq        mean      median      uq     max neval
#> R 3.4.1      825.108   828.259   864.5716  848.542 876.702 1007.459    10
#> MRO 3.4.1    419.841   422.598   430.5139  424.37 430.868 461.982    10




### Parallel execution benchmarks ----
## classic loop
system.time(
  x <- for(i in 1:2) {
    Sys.sleep(1)
    i
  }
)

x # x IS NULL


## foreach loop
library(foreach)

system.time(
  s <- foreach(i = 1:10) %do% {
    Sys.sleep(1)
    i
  }
)

s # sequentially execution result


## parallel foreach loop
library(doParallel)

registerDoParallel(cores = 10)

system.time(
  p <- foreach(i = 1:10) %dopar% {
    Sys.sleep(1)
    i
  }
)

p # parallel execution result



