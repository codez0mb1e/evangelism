
#' 
#' Train a convolution network on the MNIST dataset using...
#' Keras (Tensorflow backend) and GPU
#' 
#' References:
#'   * https://tensorflow.rstudio.com/keras/articles/examples/index.html
#' 


library(keras)
install_keras(tensorflow = "gpu")



# 1. Load an preprocessing data ----
mnist <- dataset_mnist()

# split dataset
reshapeArray <- function(dt) {
  img_resolution <- c(28, 28)
  names(img_resolution) <- c("width", "height")
  
  # redefine dimension of inputs
  r <- array_reshape(dt, c(nrow(dt), img_resolution[["width"]], img_resolution[["height"]], 1))
  
  r/255 # transform RGB values into [0,1] range
}

# prepare train and test datasets
x_train <- reshapeArray(mnist$train$x)
x_test <- reshapeArray(mnist$test$x)

y_train <- mnist$train$y
y_test <- mnist$test$y



# 2.1. Set training params ----
batch_size <- 128
num_classes <- 10
epochsN <- 12 # 99.25% test accuracy after 12 epochs

# convert class vectors to binary class matrices
y_train <- to_categorical(y_train, num_classes)
y_test <- to_categorical(y_test, num_classes)

input_shape <- c(dim(x_train)[2], 
                 dim(x_train)[3],
                 dim(x_train)[4])



# 2.2. Define model -----
model <- keras_model_sequential() %>%
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = "relu", input_shape = input_shape) %>% 
  layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = "relu") %>% 
  layer_max_pooling_2d(pool_size = c(2, 2)) %>% 
  layer_dropout(rate = .25) %>% 
  layer_flatten() %>% 
  layer_dense(units = 128, activation = "relu") %>% 
  layer_dropout(rate = .25) %>% 
  layer_dense(units = num_classes, activation = "softmax")



# 2.3. Compile model ----
model %>% compile(
  loss = loss_categorical_crossentropy,
  optimizer = optimizer_adadelta(),
  metrics = c("accuracy")
)

summary(model)



# 2.4. Train model ----
model %>% fit(
  x_train, y_train,
  batch_size = batch_size,
  epochs = epochsN,
  validation_split = .2
)

# Look what's going on:
#    $ htop
#    $ watch -n 0.5 nvidia-smi



# 2.5. Evaluate model
scores <- model %>% evaluate(
  x_test, y_test, verbose = 1
)

sprintf("Test loss: %s", scores[[1]])
sprintf("Test accuracy: %s", scores[[2]])



