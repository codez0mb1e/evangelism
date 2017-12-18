library(mlbench)
library(caret)
library(dplyr)

# load and preproccesing data
data(BreastCancer)
View(BreastCancer)

dt <- BreastCancer %>%
    mutate(
        Label = ifelse(Class == "benign", 0, 1)
        ) %>%
    select(-c(Id, Class))


dt.train.IDs <- createDataPartition(y = dt$Label, p = .8, list = FALSE)
dt.train <- dt[dt.train.IDs, ]
dt.test <- dt[-dt.train.IDs,]


# train and score models
library(MicrosoftML)

model.LR <- rxLogisticRegression(formula = Label ~ ., data = dt.train, type = "binary")
model.FT <- rxFastTrees(formula = Label ~ ., data = dt.train, type = "binary")
model.NN <- rxNeuralNet(formula = Label ~ ., data = dt.train, type = "binary")

score <- rxPredict(model.LR, data = dt.test, extraVarsToWrite = "Label")
head(score)

roc <- rxRoc(actualVarName = "Label", predVarNames = "Probability.1", data = score)
auc <- rxAuc(roc)

auc
plot(roc)