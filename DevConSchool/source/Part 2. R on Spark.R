
### Set distributed (Spark) context ----
context <- RxSpark(consoleOutput = T)
rxSetComputeContext(context)


### Read dataset ----
# from internet
library(data.table)
trans.raw <- fread("https://contest.sdsj.ru/upload/transactions.csv", stringsAsFactors = F, header = T)
rm(trans.raw)

# or from HDFS (if exists)
nameNode <- "wasbs://<container_name>@<storage_account>.blob.core.windows.net" # replace storage account and container name with appropriate values

dataDirRoot <- "/data/devcon"
dataOutputDir <- paste0(dataDirRoot, "/output")
dataTempDir <- paste0(dataDirRoot, "/temp")

rxHadoopListFiles(dataDirRoot)

hdfsFS <- RxHdfsFileSystem(hostName = nameNode, port = 0)


# read transactions dataset
trans.path <- file.path(dataDirRoot, "transactions.csv")
colInfo <- list(
  customer_id = list(type = "factor"),
  tr_datetime = list(type = "character"),
  mcc_code = list(type = "factor"),
  tr_type = list(type = "factor"),
  amount = list(type = "numeric")
)

trans.raw <- RxTextData(file = trans.path, 
                        stringsAsFactors = F,
                        missingValueString = "", 
                        rowsPerRead = 5e5,
                        colInfo = colInfo, 
                        fileSystem = hdfsFS)

rxGetInfo(trans.raw, getVarInfo = TRUE, numRows = 5)


# read customers dataset
customers.path <- file.path(dataDirRoot, "customers_gender_train.csv")
customers.raw <- RxTextData(customers.path, fileSystem = hdfsFS)

rxGetInfo(customers.raw, getVarInfo = TRUE, numRows = 5)


# join datasets
trans.data <- RxXdfData(dataTempDir, fileSystem = hdfsFS)
#! there is no distributed merge (yet) - use already merged data instead
rxMerge(trans.raw, 
        customers.raw, 
        outFile = trans.data,
        type = "inner",
        overwrite = T)

# read already joined dataset
trans.path <- file.path(dataDirRoot, "trans_with_customers-2.csv")
colInfo <- list(
  customer_id = list(type = "factor"),
  tr_datetime = list(type = "character"),
  mcc_code = list(type = "factor"),
  tr_type = list(type = "factor"),
  amount = list(type = "numeric"),
  gender = list(type = "factor")
)

trans.raw <- RxTextData(file = trans.path, 
                        stringsAsFactors = F,
                        missingValueString = "", 
                        rowsPerRead = 5e5,
                        colInfo = colInfo, 
                        fileSystem = hdfsFS)

rxGetInfo(trans.raw, getVarInfo = T, numRows = 5)


### Data preprocessing ----

rxSummary(formula = ~ amount:F(week_day), data = trans.raw)
trans.stats.byMcc <- rxCrossTabs(amount ~ F(customer_id):F(mcc_code), trans.raw, means = T)

trans.xdf <- RxXdfData(dataTempDir, fileSystem = hdfsFS)

rxDataStep(inData = trans.raw, 
          outFile = trans.xdf,
          varsToDrop = c("term_id"),
          transforms = list(
            oper_type = factor(ifelse(amount > 0, "income", "withdraw")),
            amount_log = log(abs(amount) + 1)
          ), 
          overwrite = T)

rxHistogram(~ amount_log | F(week_day), trans.xdf)


### Train model ----
trans.subsets <- RxXdfData(dataTempDir, fileSystem = hdfsFS)

#! there is no distributed version of split (yet) - use next command (rxDataStep) instead
rxSplit(inData = trans.xdf,
        outFilesBase = trans.subsets,
        splitByFactor = "subset_type",
        transforms = list(
          subset_type = factor(sample(0:1, size = .rxNumRows, replace = T, prob = c(.10, .9)),
                               levels = 0:1, labels = c("Test", "Train"))
        )
)

rxDataStep(inData = trans.raw, 
           outFile = trans.subsets,
           transforms = list(
             subset_type = factor(sample(0:1, size = .rxNumRows, replace = T, prob = c(.10, .9)),
                                  levels = 0:1, labels = c("Test", "Train"))
           ), 
           overwrite = T)


## logistic regression
formula <- gender ~ mcc_code + tr_type + amount

lrModule <- rxLogit(formula = formula, data = trans.subsets, rowSelection = (subset_type == "Train"))
summary(lrModule)


## decision tree
regTreeOut <- rxDTree(formula,
                      trans.subsets, 
                      rowSelection = (subset_type == "Train"),
                      maxdepth = 5)
print(regTreeOut)


### Predict and eval result ----
data.test <- RxXdfData(file = file.path(dataTempDir, "testdata"), fileSystem = hdfsFS)
rxDataStep(inData = trans.subsets,
           outFile = data.test,
           rowSelection = (subset_type == "Test"),
           varsToKeep = c("gender", "mcc_code", "tr_type", "amount"),
           overwrite = T)


trans.predicted = RxXdfData(file = file.path(dataTempDir, "predicted"), fileSystem = hdfsFS)
rxPredict(lrModule,
          data = data.test,
          outData = trans.predicted,
          overwrite = T)

rxGetVarInfo(trans.predicted)

# visualize ROC curve
rxSetComputeContext("local") # switch context

rxRocCurve(actualVarName = "gender",
           predVarNames = "gender_pred",
           data = trans.predicted)

