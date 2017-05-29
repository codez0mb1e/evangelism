# import libraries
library(ggplot2)
library(reshape2)
library(ROCR)
library(httr)

setwd("C:/Apps/evangelism/DevConFutureTech/source/IntRo")



## Read data

# from local file system
library(data.table)
trans.raw <- fread("data/transactions.csv", sep = ",", stringsAsFactors = F, header = T, colClasses = list(character = 6))

# from Web
mcc.raw <- fread("https://raw.githubusercontent.com/greggles/mcc-codes/master/mcc_codes.csv")

# from Azure Blob Storage
library(AzureSMR)

sc <- createAzureContext(tenantID = "{TID}", clientID = "{CID}", authKey = "{KEY}")
sc

azureGetBlob(sc,
    storageAccount = "datainstinct",
    container = "sberbank",
    blob = "sdsj/tr_mcc_codes.2.csv",
    type = "text")


# from MS SQL Server
library(RODBC) # Provides database connectivity

trans.connectionString <- "Driver={ODBC Driver 13 for SQL Server};Server=tcp:msdevcon.database.windows.net,1433;Database=TransDb;Uid=dp@msdevcon;Pwd=<pwd>;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"

trans.conn <- odbcDriverConnect(trans.connectionString) # open RODBC connection

sqlSave(trans.conn, mcc.raw, "MCC2", addPK = T) # save data to table
mccFromDb <- sqlQuery(trans.conn, "SELECT * FROM MCC2 WHERE edited_description LIKE '%For Visa Only%'") # get data
close(trans.conn)

head(mccFromDb)

# * Excel, HDFS, Amazon S3, REST-services as data sources 


## Transform data
library(dplyr)

# { "0 10:23:26" "1 10:19:29" "1 10:20:56" } > { 0, 1, 1 }
getDay <- function(x) {
    strsplit(x, split = " ")[[1]][1]
}

trans <- trans.raw %>%
  #sample_n(100000, replace = T) %>%
  # remove invalid rows
  filter( 
    !is.na(amount) | amount != 0
    ) %>% 
  # transform data 
  mutate(
    OperationType = factor(ifelse(amount > 0, "income", "withdraw")),
    TransDay = as.numeric(sapply(tr_datetime, getDay)),
    Amount = abs(amount)
    ) %>% 
  # remove redundant columns
  select(
    -c(tr_datetime, amount, term_id)
    ) %>%
  # set column names
  rename(
    CustomerId = customer_id, MCC = mcc_code, TransType = tr_type
  ) %>%
  # sort
  arrange(
    TransDay, Amount
  )

View(trans)


mcc <- mcc.raw %>%
  rename(Code = mcc, Description = irs_description) %>%
  select(Code, Description)
  

trans <- trans %>%
  left_join(mcc, by = c("MCC" = "Code")) %>%
  mutate(Description = factor(Description))



## Analyze
trans.byMCC <- trans %>%
  group_by(
    Description, OperationType
    ) %>%
  summarise(
    Count = n(), 
    Min = min(Amount), 
    Max = max(Amount), 
    Median = median(Amount), 
    Total = sum(Amount),
    StandDev = sd(Amount)
  ) %>%
  ungroup() %>%
  arrange(desc(Count))
  
View(trans.byMCC)
  
  
  
ggplot(trans.byMCC, aes(log(abs(Median) + 1), fill = Description)) +
  geom_histogram() +
  facet_wrap(~Description)
