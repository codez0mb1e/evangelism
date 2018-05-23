
#' 
#' Inference VGG-16 Pre-trained Model (ImageNet Challenge) using Keras
#' 
#' References:
#'   * https://arxiv.org/abs/1409.1556
#' 


library(keras)
library(purrr)


# 1. Get files
files <- dir("<images_dir>", pattern = ".jpg", full.names = T) 
print(files)


# 2. Load model
model <- application_vgg16(weights = "imagenet")
summary(model)


# 3. Predict and evaluate
output <- map(files,
              function(.f) {
                
                # convert image to numeric vector
                img <- image_load(.f, target_size = c(224, 224))
                x <- image_to_array(img)
                x <- array_reshape(x, dim = c(1, 224, 224, 3))
                x <- imagenet_preprocess_input(x)
                
                # predict
                pred <- model %>% predict(x)
                
                # evaluate
                imagenet_decode_predictions(pred, top = 3)[[1]]
              })


