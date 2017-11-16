### ConnectR ----
library(RevoScaleR)

# get data from DB
connectionString <- "SERVER=hostname;DATABASE=GataGeeksDemoDb;UID=GataGeek;PWD=***;"
sqlQuery <- "SELECT Id, Name, any FROM foo"

# SQL Server table
sqlServerDataset <- RxSqlServerData(sqlQuery, connectionString)
# Teradata
teradataDataset <- RxTeradata(sqlQuery, connectionString)

# or use:
#   RxOdbcData	Creates an ODBC data source object.
#   RxXdfData	Creates an efficient XDF data source object.
#   RxTextData	Creates a comma-delimited text data source object.
#   RxSasData	Creates a SAS data source object.
#   RxSpssData	Creates an SPSS data source object.

# hint: define explicitly 
#   rowBuffering = TRUE
#   rowsPerRead = 50000
#   stringsAsFactors = FALSE
#   colInfo = c(...)
#   verbose = 0 

# see also: free and open-source odbc R-package


### MicrosoftML ----
library(RevoScaleR)
library(MicrosoftML)

## 1. read data
kyphosis <- rxDataStep(inData = file.path(rxGetOption("sampleDataDir"), "Kyphosis.xdf"))
rxSummary(~ Kyphosis + Age + Number + Start, data = Kyphosis)

## 2. train model
formula <- "Kyphosis ~ Age + Number + Start"

# Fast Forest algorithm
model.FF <- MicrosoftML::rxFastForest(formula, kyphosis, type = "binary", randomSeed = 101)

# Neural Network algorithm
model.NN <- MicrosoftML::rxNeuralNet(formula, kyphosis, type = "binary", randomSeed = 101)

# also you can use Logic Regression, Fast Tree algo, one class SVM, etc. 

# 3. score model 
score <- rxPredict(model.FF, data = kyphosis, writeModelVars = T) 
# note: you need to split dataset on train and train part in real life

score$Label <- ifelse(score$Kyphosis == "present", 1, 0)
rxRocCurve(actualVarName = "Label", predVarNames = "Probability.present", data = score)



### DeployR ----
library(mrsdeploy)

# login to ML Server
remoteLogin("http://<host>.westeurope.cloudapp.azure.com:12800", 
            username = "admin", 
            password = "***")

# publish service
serviceName <- "KyphosisPredictionService"
serviceVersion = "v0.1"

service <- publishService(
  serviceName, v = serviceVersion,
  code = NULL,
  model = model.NN,
  serviceType = "Realtime"
)

# consume service
client <- getService(serviceName, v = serviceVersion)
client$consume(kyphosis)



