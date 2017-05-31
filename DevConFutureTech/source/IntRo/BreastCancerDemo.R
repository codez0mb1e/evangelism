library(mlbench)
library(caret)
library(dplyr)
library(MicrosoftML)

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


model.LR <- rxLogisticRegression(formula = Label ~ ., data = dt.train, type = "binary")
model.FT <- rxFastTrees(formula = Label ~ ., data = dt.train, type = "binary")
model.NN <- rxNeuralNet(formula = Label ~ ., data = dt.train, type = "binary")

score <- rxPredict(model.NN, data = dt.test, extraVarsToWrite = "Label")
head(score)


rxRocCurve(actualVarName = "Label", predVarNames = "Probability.1", data = score)

