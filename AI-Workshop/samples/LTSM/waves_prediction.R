
#' 
#' Waves prediction using
#' Keras (Tensorflow backend) and GPU
#' 


# 0. Import Dependecies ----
suppressPackageStartupMessages({
  library(keras)
  install_keras(tensorflow = "gpu") # if nessary
  
  library(dplyr)
  library(tidyr)
  
  library(ggplot2)
})
source("prediction_funs.R")



# 1. Set parameters ----
epochs <- 20
timeStemps <- 10
predictingPeriod <- timeStemps * 4e2



# 2. Load and preprocessing data ----
data <- getWave(1e4) # or getWaves(1e4)
ts.plot(data)


mData <- data %>%
  as.vector %>% 
  get2DTensor(., timeStemps)

sprintf(
  "We are in the Matrix: %s", 
  paste(dim(mData), collapse = ", ")
)



# 3. Split on train/test datasets ----
splitBy <- dim(mData)[1] - predictingPeriod

x.train <- get3DTensor(mData[1:splitBy, ])
x.test <- get3DTensor(mData[(splitBy + 1):dim(mData)[1], ])

y.train <- mData[2:splitBy, timeStemps]
y.test <- mData[(splitBy + 2):dim(mData)[1], timeStemps]

stopifnot(
  length(y.train) > 0, length(y.test) > 0,
  dim(x.train)[1] == length(y.train),
  dim(x.test)[1] == length(y.test)
)

sprintf(
  "We are in the 3D Matrix (Tensor): %s", 
  paste(dim(x.train), collapse = ", ")
)



# 4. Define model  ----
inputShape <- c(dim(x.train)[[2]], dim(x.train)[[3]]) # number of time steps and features

model <- keras_model_sequential() %>% 
  layer_lstm(
    units = inputShape[1],
    input_shape = inputShape, 
    dropout = .2, recurrent_dropout = .2, 
    return_sequences = T
  ) %>% 
  layer_lstm(
    units = inputShape[1]*2,
    dropout = .2, recurrent_dropout = .2, 
    return_sequences = F
  ) %>% 
  layer_dense(
    units = 1, 
    activation = "linear"
  )


model %>% compile(
  optimizer = optimizer_rmsprop(), # or "adam"
  loss = "mse" # mean squared error, or mean absolute error (mae)
)

summary(model)



# 5. Train model  ----
model %>% fit(
  x.train, y.train,
  batch_size = 32,
  epochs = epochs,
  validation_data = list(x.test, y.test),
  verbose = 1
)

# Look what's going on:
#    $ htop
#    $ watch -n 0.5 nvidia-smi


# 6. Score model  ----
predict.test <- predict(model, x.test)


# 7. Eval model ----
results <- combineResults(y.test, predict.test[, 1])

ggplot(results, aes(x = Id, y = Value, color = Type)) +
  geom_line() +
  theme_bw()
  

