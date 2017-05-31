## 1. Read data
container <- "https://datainstinct.blob.core.windows.net/sberbank"
queryString <- "?sv=2015-12-11&si=msdev-bot&sr=c&sig=o7rB0rZOcnngYdly2pkN7KZGX9hqhpJZmHArog%2BzbeM%3D"


# from local file system
library(data.table)

trans.blobName <- "sdsj/transactions.csv"
trans.raw <- fread(paste0(container, "/", trans.blobName, queryString), 
                   sep = ",", stringsAsFactors = F, header = T, colClasses = list(character = 6))

customers.gender.blobName <- "sdsj/customers_gender_train.csv"
customers.gender <- fread(paste0(container, "/", customers.gender.blobName, queryString), 
                    sep = ",", stringsAsFactors = F, header = T)

mcc.raw <- fread("https://raw.githubusercontent.com/greggles/mcc-codes/master/mcc_codes.csv")



## 2. Preproccessing data
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

View(trans[1:1000, ])


mcc <- mcc.raw %>%
  rename(Code = mcc, Description = irs_description) %>%
  select(Code, Description)
View(mcc)


trans.x <- trans %>%
  left_join(mcc, by = c("MCC" = "Code")) %>%
  left_join(customers.gender, by = c("CustomerId" = "customer_id")) %>%
  mutate(
    Description = factor(Description),
    Gender = factor(gender)
    ) %>%
  select(-gender)



## 3. Feature engineering
# calculate stats
customers.stats <- trans.x %>%
  mutate(LogAmount = log(Amount)) %>%
  group_by(CustomerId, OperationType, Gender) %>%
  filter(n() > 30) %>%
  summarize(
    Min = min(LogAmount),
    P1 = quantile(LogAmount, probs = c(.01)),
    Q1 = quantile(LogAmount, probs = c(.25)),
    Mean = mean(LogAmount),
    Q3 = quantile(LogAmount, probs = c(.75)),
    P99 = quantile(LogAmount, probs = c(.99)),
    Max = max(LogAmount),
    Total = sum(Amount),
    Count = n(),
    StandDev = sd(LogAmount)
  ) %>%
  ungroup() 
  

# shape from long to wide table form
library(reshape2)
x <- dcast(customers.stats, CustomerId + Gender ~ OperationType, value.var = "Mean", fun.aggregate = mean) %>%
  mutate(
    income = ifelse(is.na(income), 0, income),
    withdraw = ifelse(is.na(withdraw), 0, withdraw)
  ) %>%
  filter(!is.na(Gender))


# vizualize
library(ggplot2)
ggplot(x, aes(x = income, y = withdraw)) +
  geom_point(alpha = 0.25) +
  xlab("Income, rub") + 
  ylab("Withdraw, rub") +
  facet_grid(. ~ Gender)
