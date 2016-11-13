### set dependecies
if(!require("ggplot2")) install.packages("ggplot2")
if(!require("data.table")) install.packages("data.table")


### set context
context <- RxSpark(consoleOutput = T)
#context <- rxSetComputeContext("localpar")
#context <- RxHadoopMR()

rxSetComputeContext(context)


### read data set
# from internet
library(data.table)
trans.raw <- fread("https://contest.sdsj.ru/upload/transactions.csv", stringsAsFactors = F, header = T)
rm(trans.raw)

# from HDFS 
nameNode <- "wasbs://<container_name>@<storage_account>.blob.core.windows.net" # replace storage account and container name with appropriate values

dataDirRoot <- "/data/devcon"
dataOutputDir <- paste0(dataDirRoot, "/output")
dataTempDir <- paste0(dataDirRoot, "/temp")

rxHadoopListFiles(dataDirRoot)


hdfsFS <- RxHdfsFileSystem(hostName = nameNode, port = 0)


# trans data set
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
                        rowsPerRead = 500000,
                        colInfo = colInfo, 
                        fileSystem = hdfsFS)

rxGetInfo(trans.raw, getVarInfo = TRUE, numRows = 5)


# customes data set
customers.path <- file.path(dataDirRoot, "customers_gender_train.csv")
customers.raw <- RxTextData(customers.path, fileSystem = hdfsFS)

rxGetInfo(customers.raw, getVarInfo = TRUE, numRows = 5)


# merge datasets
#! command will be failed: there is no distributed merge
trans.data <- RxXdfData(dataTempDir, fileSystem = hdfsFS)
rxMerge(trans.raw, 
        customers.raw, 
        outFile = trans.data,
        type = "inner",
        overwrite = T)

rxGetVarInfo(trans.data)


# remove old datasets
rm(trans.raw)
rm(customers.raw)

# read ready
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
                        rowsPerRead = 500000,
                        colInfo = colInfo, 
                        fileSystem = hdfsFS)

rxGetInfo(trans.raw, getVarInfo = T, numRows = 5)



### insight data
rxSummary(formula = ~ amount:F(week_day), data = trans.raw)


trans.stats.byMcc <- rxCrossTabs(amount ~ F(customer_id):F(mcc_code), trans.raw, means = T)

### fiter data
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


### train model
trans.subsets <- RxXdfData(dataTempDir, fileSystem = hdfsFS)
# command will be failed: there is no distributed version of split 
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


# logistic regression
formula <- gender ~ mcc_code + tr_type + amount

lrModule <- rxLogit(formula = formula, data = trans.subsets, rowSelection = (subset_type == "Train"))
summary(lrModule)


# decision tree
regTreeOut <- rxDTree(formula,
                      trans.subsets, 
                      rowSelection = (subset_type == "Train"),
                      maxdepth = 5)
print(regTreeOut)


# predict values
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

