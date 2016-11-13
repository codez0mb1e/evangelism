# import libraries
if(!require("ggplot2")) install.packages("ggplot2")
if(!require("data.table")) install.packages("data.table")
if(!require("dplyr")) install.packages("dplyr")
if(!require("reshape2")) install.packages("reshape2")
if(!require("ROCR")) install.packages("ROCR")

# dependecies
library(data.table)
library(dplyr)
library(ggplot2)
library(reshape2)
library(ROCR)


## load datasets
# set path
trans.path <- "C:/Applications/SberHack2016/data/transactions.csv"
customers.gender.path <- "https://contest.sdsj.ru/upload/customers_gender_train.csv"

# load trans dataset
trans.raw <- fread(trans.path, stringsAsFactors = F, header = T)
str(trans.raw)
summary(trans.raw)

# load customers gender from web
customers.gender <- fread(customers.gender.path, stringsAsFactors = F, header = T, sep = ",")
View(customers.gender)


# megre datasets and calculate stats
trans.data <- trans.raw %>%
  left_join(customers.gender) %>% # join with customers.gender
  mutate(
    oper_type = ifelse(amount > 0, "income", "withdraw"),
    gender = factor(gender)) %>% # add oper_type
  filter(oper_type == "withdraw") %>% # filter only withdraw operations
  group_by(gender, mcc_code, oper_type) %>% # group by gender & mcc
  summarize( # calculate stats
    Count = n(), 
    Min = min(amount), 
    Max = max(amount), 
    Median = median(amount), 
    Total = sum(amount)
    ) %>% 
  ungroup()


# draw
ggplot(trans.data, aes(log(abs(Median) + 1), fill = gender)) + 
  geom_histogram() + 
  facet_wrap(~ gender)

ggplot(trans.data, aes(x = gender, y = log(abs(Median) + 1), color = gender)) + 
  geom_boxplot()


# get top MCCs and draw
trans.data.top <- trans.data %>% 
  filter(oper_type == "withdraw") %>%
  arrange(desc(Count)) %>% 
  top_n(16, Count)

trans.data.x <- trans.raw %>%
  inner_join(trans.data.top, by = c("mcc_code" = "mcc_code")) %>%
  mutate(
    mcc_code = factor(mcc_code),
    gender = factor(gender)
    )

unique(trans.data.x$mcc_code)

ggplot(trans.data.x, aes(x = gender, y = log(abs(amount) + 1), color = gender)) + 
  geom_boxplot() + 
  facet_wrap(~ mcc_code)

rm(trans.data.x)


# train model
getDay <- function(x) {
  strsplit(x, split = " ")[[1]][1]
}

trans.stats <- trans.raw %>% 
  mutate(trans_day = as.numeric(sapply(tr_datetime, getDay))) 

trans.stats.x <- trans.stats %>% 
  mutate(week_num = floor(trans_day / 7) + 1,
         week_day = (trans_day %% 7) + 1,
         month_num = floor(trans_day / 30) + 1,
         month_day = (trans_day %% 30) + 1
  ) %>% 
  group_by(customer_id, mcc_code) %>% 
  summarize(
    Duration = max(trans_day) - min(trans_day),
    Count = n(),
    Avg = ifelse(Duration == 0, 0, n()/Duration)
  ) %>%
  ungroup()

d <- dcast(trans.stats.x, customer_id ~ mcc_code, value.var = 'Avg', fill = 0)
colnames(d)[2:length(colnames(d))] <- paste('mcc', colnames(d)[2:length(colnames(d))], sep = '')
str(d)

d <- d %>% inner_join(customers.gender) %>% mutate(gender = factor(gender))
d.train <- d[1:10000, ]
d.test <- d %>% anti_join(d.train, by = c("customer_id" = "customer_id"))


model <- glm(formula = gender ~ ., family = binomial(link = "logit"),  data = d.train)

# score model
p <- predict(model, newdata = d.test, type="response")
pr <- prediction(p, d.test$gender)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

# evaluate model
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc


