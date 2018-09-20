

#' 
#' This script demonstrates how to build a autoencoder with Keras.
#' 


library(keras)
library(dplyr)
K <- keras::backend()


### 0. Parameters ----
batch_size <- 100L

original_dim <- 784L
encoding_dim <- 2L # small number of encoding dimension only for visualization purposes
latent_dim <- 784L

n_epochs <- 100L



### 1. Model definition ----
## 1.1. Layers definition
x <- layer_input(shape = c(original_dim)) # input placeholder

h <- layer_dense(x, encoding_dim , activation = "relu") # encoded representation of the input

decoded_h <- layer_dense(h, latent_dim, activation = "sigmoid") # lossy reconstruction of the input


## 1.2. Model maps
# model maps an input to its reconstruction
autoencoder <- keras_model(x, decoded_h)

# model maps an input to its encoded representation
encoder <- keras_model(x, h)

# create a placeholder for an encoded (32-dimensional) input
encoded_input <- layer_input(shape = c(encoding_dim))
# retrieve the last layer of the autoencoder model
decoder_layer <- get_layer(autoencoder, index = -1)
# create the decoder model
decoder <- keras_model(encoded_input, decoder_layer(encoded_input))


## 1.3. Compile model
autoencoder %>%
  compile(optimizer = "adadelta", loss = "binary_crossentropy")


summary(autoencoder)


### 2. Get data and fit model ----
mnist <- dataset_mnist()

x_train <- mnist$train$x / 255
x_test <- mnist$test$x / 255
x_train <- x_train %>% apply(1, as.numeric) %>% t()
x_test <- x_test %>% apply(1, as.numeric) %>% t()


history <- autoencoder %>% fit(
  x_train, x_train,
  epochs = n_epochs,
  batch_size = batch_size,
  shuffle = T,
  validation_data = list(x_test, x_test),
  callbacks = callback_early_stopping(monitor = "val_loss", patience = n_epochs/10),
  verbose = 1)



### 3. Visualizations ----
library(ggplot2)

x_test_encoded <- predict(encoder, x_test, batch_size = batch_size)

x_test_encoded %>%
  as_data_frame %>% 
  mutate(Class = factor(mnist$test$y)) %>%
  ggplot(aes(x = V1, y = V2, color = Class)) + 
  geom_point(alpha = .75) + 
  theme_minimal()


