CNN on MNIST dataset
================

***Train a convolution neural network on the MNIST dataset using Keras
(Tensorflow backend)***

## Load keras

``` r
library(keras)
install_keras(tensorflow = "gpu") # WARN: uncomment if you want to train model with GPU
```

    ## Creating virtualenv for TensorFlow at  ~/.virtualenvs/r-tensorflow 
    ## Installing TensorFlow ...
    ## 
    ## Installation complete.

## Load and preprocessing MNIST dataset

``` r
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
```

### Set training params

``` r
batch_size <- 128
num_classes <- 10
epochsN <- 4 # 99.25% test accuracy after 12 epochs

# convert class vectors to binary class matrices
y_train <- to_categorical(y_train, num_classes)
y_test <- to_categorical(y_test, num_classes)

input_shape <- c(dim(x_train)[2], 
                 dim(x_train)[3],
                 dim(x_train)[4])
```

### Define CNN arhitecture

``` r
model <- keras_model_sequential() %>%
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = "relu", input_shape = input_shape) %>% 
  layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = "relu") %>% 
  layer_max_pooling_2d(pool_size = c(2, 2)) %>% 
  layer_dropout(rate = .25) %>% 
  layer_flatten() %>% 
  layer_dense(units = 128, activation = "relu") %>% 
  layer_dropout(rate = .25) %>% 
  layer_dense(units = num_classes, activation = "softmax")
```

### Compile model

``` r
model %>% compile(
  loss = loss_categorical_crossentropy,
  optimizer = optimizer_adadelta(),
  metrics = c("accuracy")
)

summary(model)
```

    ## ___________________________________________________________________________
    ## Layer (type)                     Output Shape                  Param #     
    ## ===========================================================================
    ## conv2d (Conv2D)                  (None, 26, 26, 64)            640         
    ## ___________________________________________________________________________
    ## conv2d_1 (Conv2D)                (None, 24, 24, 128)           73856       
    ## ___________________________________________________________________________
    ## max_pooling2d (MaxPooling2D)     (None, 12, 12, 128)           0           
    ## ___________________________________________________________________________
    ## dropout (Dropout)                (None, 12, 12, 128)           0           
    ## ___________________________________________________________________________
    ## flatten (Flatten)                (None, 18432)                 0           
    ## ___________________________________________________________________________
    ## dense (Dense)                    (None, 128)                   2359424     
    ## ___________________________________________________________________________
    ## dropout_1 (Dropout)              (None, 128)                   0           
    ## ___________________________________________________________________________
    ## dense_1 (Dense)                  (None, 10)                    1290        
    ## ===========================================================================
    ## Total params: 2,435,210
    ## Trainable params: 2,435,210
    ## Non-trainable params: 0
    ## ___________________________________________________________________________

### Train model

``` r
model %>% fit(
  x_train, y_train,
  batch_size = batch_size,
  epochs = epochsN,
  validation_split = .2
)
```

Look what’s going on terminal:

    $ htop
    $ watch -n 0.5 nvidia-smi

### Evaluate model

``` r
scores <- model %>% evaluate(
  x_test, y_test, verbose = 1
)

print(sprintf("Test loss: %s", scores[[1]]))
```

    ## [1] "Test loss: 0.0302271256409877"

``` r
print(sprintf("Test accuracy: %s", scores[[2]]))
```

    ## [1] "Test accuracy: 0.990299999713898"
