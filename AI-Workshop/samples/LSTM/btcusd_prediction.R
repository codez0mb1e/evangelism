
#' 
#' BTC/USD prediction using
#' Keras (Tensorflow backend) and GPU
#' 


### 0. Import Dependecies ----
suppressPackageStartupMessages({
  # DL framework
  library(keras)
  # if nessary: install_keras(tensorflow = "gpu")
  # data processing 
  library(dplyr)
  library(tidyr)
  library(purrr)
  # vizualize
  library(ggplot2)
})
source("LSTM/prediction_funs.R")



### 1. Set parameters ----
epochsN <- 20
timeStemps <- 10
predictingPeriod <- timeStemps * 4e2


### 2. Load and preprocessing data ----
data <- getBtc1H()

ts.plot(data$Close)
ts.plot(data$LogReturn)


mData <- data$LogReturn %>% 
  as_vector %>% 
  get2DTensor(., timeStemps)

sprintf("Working in the Matrix: %s", paste(dim(mData), collapse = ", "))



### 3. Split on train/test datasets ----
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

sprintf("Working in the 3D Matrix: %s", paste(dim(x.train), collapse = ", "))



### 4. Define model  ----
inputShape <- c(dim(x.train)[[2]], # number of time steps
                dim(x.train)[[3]]) # number of features

model <- keras_model_sequential() %>% 
  layer_lstm(
    units = inputShape[1],
    input_shape = inputShape, 
    dropout = .2, recurrent_dropout = .2, 
    return_sequences = T
  ) %>% 
  layer_lstm(
    units = inputShape[1] * 2,
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



### 5. Train model  ----
model %>% fit(
  x.train, y.train,
  batch_size = 32,
  epochs = epochsN,
  validation_data = list(x.test, y.test),
  verbose = 1
)

# Look what's going on:
#    $ htop
#    $ watch -n 0.5 nvidia-smi



### 6. Score model  ----
predict.test <- predict(model, x.test)


### 7. Eval and visualize result ----
results <- combineResultsX(y.test, predict.test[, 1])


ggplot(results %>% filter(Time > 17300) %>% gather(., "Model", "Price", Prev:Predict, factor_key = T), aes(x = Time)) +
  geom_line(aes(y = Price, color = Model)) +
  geom_line(aes(y = Close), color = "red", linetype = "dotted") +
  facet_grid(Model ~ .) +
  labs(title = "BTC/USD Stock Price", subtitle = "#DeepLearning + #Azure on #AzureDay", 
       x = "Date", y = "Close Price", 
       caption = "(c) 2018, Dmitry Petukhov [ http://0xCode.in ]") +
  theme_bw()


ggplot(results %>% filter(Time > 17300) %>% gather(., "Model", "Residuals", SMA_residuals:Predict_residuals, factor_key = T), aes(x = Time)) +
  geom_line(aes(y = Residuals, color = Model)) +
  geom_line(aes(y = Prev_residuals), color = "red", linetype = "dashed") +
  facet_grid(Model ~ .) +
  labs(title = "BTC/USD Stock Price", subtitle = "#DeepLearning + #Azure on #AzureDay", 
       x = "Date", y = "Close Price", 
       caption = "(c) 2018, Dmitry Petukhov [ http://0xCode.in ]") +
  theme_bw()


View(
  results %>% 
    gather(., "Model", "Residuals", Prev_residuals:Predict_residuals, factor_key = T) %>% 
    group_by(Model) %>% 
    summarise(
      TotalLoss = sum(abs(Residuals))
    ) %>% 
    arrange(TotalLoss)
)


### 8. Human vs AI competition ----
View(
  data.frame(
    Close = c(tail(results, 12)[1:10, ]$Close, "?", "?")
  )
)

View(
  data.frame(
    Close = tail(results, 12)$Close,
    Predict = tail(results, 12)$Predict
  ) %>% 
  mutate(
    #Diff = c(NA,  diff(Close)),
    Residuals = Close - Predict
  ) 
)




