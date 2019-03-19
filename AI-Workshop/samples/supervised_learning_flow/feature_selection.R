
### Feature Selection Lab

#! install.packages(c("doSNOW", "nloptr", "lme4", "pbkrtest", "randomForest", "caret", "mlbench", "mRMRe"))
library(plyr)
library(dplyr)
library(mlbench)
library(caret)


# args
dt <- PimaIndiansDiabetes %>% 
  mutate(age = as.ordered(age))
dt.features <- PimaIndiansDiabetes %>% select(-diabetes)
dt.label <- dt$diabetes

set.seed(7)
foldsNumber <- 8
repeatsNumber <- 5


#--- 
## Rank Features By Importance
# prepare training scheme 
rfImpCntrl <- trainControl(method = "repeatedcv", 
                           number = foldsNumber, 
                           repeats = repeatsNumber)
# train the model
rfImpModel <- train(diabetes ~ ., data = dt, method = "lvq", preProcess = c("scale", "center"), trControl = rfImpCntrl)
# view results
rfImportance <- varImp(rfImpModel, scale = F)
print(rfImportance)
plot(rfImportance)



#---- 
## Recursive Feature Elimination 
# define the control using a random forest selection function
rfeCntrl <- rfeControl(functions = rfFuncs, method = "cv", number = foldsNumber)
# run the RFE algorithm
rfeModel <- rfe(dt.features, dt.label, sizes = c(1:8), rfeControl = rfeCntrl)
# view result
print(rfeModel)
predictors(rfeModel)
rfeModel$fit
plot(rfeModel, type = c("g", "o"))




#----- 
## Genetic Algorithm (GA)
gaCntrl <- gafsControl(functions = rfGA, # Assess fitness with RF
                       method = "cv",    # 10 fold cross validation
                       genParallel = T,
                       allowParallel = T)

gaModel <- gafs(dt.features, dt.label, 
                iters = foldsNumber, # generations of algorithm
                popSize = 5, # population size for each generation
                 #levels = lev,
                 gafsControl = gaCntrl)

plot(gaModel)
gaModel$ga$final




#---- 
# Simulated Annealing Features Selection
safsCntrl <- safsControl(functions = rfSA, method = "repeatedcv", repeats = 5, improve = 50)
safsModel <- safs(dt.features, dt.label,
                  iters = 50,
                  safsControl = safsCntrl)
plot(safsModel)


#----  
##  Mutual Information Matrices Feature Selection
library(mRMRe)
data <- data.frame(target = cgps.ic50, cgps.ge)
mRMR.classic(dt, 9, 8)




