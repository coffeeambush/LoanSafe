#//R_Snyder LoanSafe Model
#//Install Packages & Open Library
install.packages("tree")
install.packages("randomForest")
install.packages("ROCR")
install.packages("caret")
install.packages("ROSE")
install.packages("dply")
install.packages("psych")
install.packages("neuralnet")
install.packages("plotly")
install.packages("tidyverse")
install.packages("Metrics")
library(plotly)
library(ROSE)
library(caret)
library(ROCR)
library(tree)
library(randomForest)
library(e1071)
library(dplyr)
library(ggplot2)
library(psych)
library(neuralnet)
library(tidyverse)
library(Metrics)

#//loading train and verify files
creditData <- read.csv("C:\\Users\\Coffee\\Desktop\\Homework\\DAT690\\Project Files\\CreditAmount_Data.csv")
creditVerify <- read.csv("C:\\Users\\Coffee\\Desktop\\Homework\\DAT690\\Project Files\\CreditAmount_Verify.csv")

#//descriptive statistics & data exploration
summary(creditData)
str(creditData)
str(creditVerify)
#more data exploration, from psych package for additional descriptive statistics
describe(creditData)
#more data exploration, looking at skew after placing in bins
ggplot(creditData, aes(x = funded_amnt)) +
  geom_histogram(binwidth = 5000, fill = "blue", color = "black") +
  scale_x_continuous(labels = scales::comma) +
  labs(title = "Histogram of Amounts with Bins in Thousands",
       x = "Amount",
       y = "Frequency") +
  theme_minimal()

#//***pre-processing section
#after checking structure using str, updates value from character to number
creditData$revol_util_pct <- as.numeric(creditData$revol_util_pct)
#Checking missing values, and seeing how many there are per variable.
missing_creditAmount <- is.na(creditData)
missing_per_column <- colSums(is.na(creditData))
print(missing_per_column)
missing_creditverify <- is.na(creditVerify)
missing_per_column_verify <- colSums(is.na(creditVerify))
print(missing_per_column_verify)
#fix missing values, using median value to replace N/As in this instance
preProcess_missingdata <- preProcess(creditData, method = 'medianImpute')
creditData <- predict(preProcess_missingdata, newdata = creditData)
preProcess_missingdata_verify <- preProcess(creditVerify, method = 'medianImpute')
creditVerify <- predict(preProcess_missingdata_verify, newdata = creditVerify)
#//Remove ID column as it is just an observation number, also removing installment as it is derived from target.
creditData <- creditData[, -c(1,5)]
creditVerify <- creditVerify[, -c(1,5)]
# normalization of the data
preProcess_Data <- preProcess(creditData, method = c("center", "scale"))
preProcess_Verify<- preProcess(creditVerify, method = c("center", "scale"))
# Apply normalization
creditData_norm <- predict(preProcess_Data, creditData)
creditData_norm <- as.data.frame(creditData_norm)
creditVerify_norm <- predict(preProcess_Verify, creditVerify)
creditVerify_norm <- as.data.frame(creditVerify_norm)

#//correlation analysis
corr<-round(cor(creditData), digits = 2)
corr_norm<-round(cor(creditData_norm), digits = 2)

#//Prep for Decision Tree and Random Forest
splitCredit <- createDataPartition(creditData$funded_amnt, p = .8, list = FALSE)
creditTrainer <- creditData_norm[splitCredit,]
creditTest <- creditData_norm[-splitCredit,]

#//Simple Regression Tree
treeOne <- tree(funded_amnt ~ ., data=creditTrainer)
plot(treeOne)
text(treeOne)
summary(treeOne)

#//Random forest
set.seed(47)
rfCredit <- randomForest(funded_amnt ~., data = creditData_norm)
predictTestOne <- predict(rfCredit, creditTest)

impOne <-importance(rfCredit)

#//Neural Network
nn <- neuralnet(funded_amnt ~ term_60mon + int_rate_pct + annual_inc + revol_bal + max_bal_bc + total_rev_hi_lim  + 
                total_bc_limit + dti + total_bal_ex_mort + tot_hi_cred_lim + 
                revol_util_pct + tot_cur_bal + bc_util + mo_sin_old_rev_tl_op + 
                avg_cur_bal + bc_open_to_buy + mo_sin_old_il_acct + 
                total_il_high_credit_limit + il_util + mths_since_recent_bc + 
                mths_since_rcnt_il + all_util + total_bal_il + earliest_cr_line + 
                total_acc, data = creditTrainer, hidden = c(3), linear.output = TRUE)
#footnote: reference this site for parameter adjustments https://www.datacamp.com/tutorial/neural-network-models-r
plot(nn)

#//predict on test data
predictions <- compute(nn, creditVerify_norm[, c("term_60mon","int_rate_pct", "annual_inc", "revol_bal", "max_bal_bc", "total_rev_hi_lim",
"total_bc_limit", "dti", "total_bal_ex_mort", "tot_hi_cred_lim", "revol_util_pct", 
"tot_cur_bal", "bc_util", "mo_sin_old_rev_tl_op", "avg_cur_bal", "bc_open_to_buy", 
"mo_sin_old_il_acct", "total_il_high_credit_limit", "il_util", "mths_since_recent_bc", 
"mths_since_rcnt_il", "all_util", "total_bal_il", "earliest_cr_line", "total_acc")])$net.result
actual <-creditVerify_norm$funded_amnt
results = data.frame(Actual = actual, Predicted = predictions)
print(results)
#footnote: https://www.spsanderson.com/steveondata/posts/2023-09-20/index.html

#//testing results
# total sum of squares (TSS)
tss <- sum((creditVerify_norm$funded_amnt - mean(creditTest$funded_amnt))^2)
#residual sum of squares (RSS)
rss <- sum((creditVerify_norm$funded_amnt - predictions)^2)
# Calculate R-squared
rsquared <- 1 - (rss / tss)
#mean squared error
mse <- mean((creditVerify_norm$funded_amnt - predictions)^2)
#footnote: reference for this site for parameter adjustment: https://rpubs.com/sinangok/r_vs_R2

#//plot to show results
plot(actual, predictions, col = "red", 
       main = 'Actual vs Predicted', 
       xlab = 'Actual', ylab = 'Predicted')
abline(0, 1, lwd = 2)
plot(actual, predictions, col = "red", 
     main = 'Actual vs Predicted', 
     xlab = 'Actual', ylab = 'Predicted')
abline(0, 1.3, lwd = 2)

# Convert the matrix to a data frame
impOne_df <- as.data.frame(impOne)

# Rename the columns appropriately
names(impOne_df) <- c("IncNodePurity")

# Convert row names to a column
impOne_df$Variable <- rownames(impOne_df)

# Reorder the columns to have 'Variable' first
impOne_df <- impOne_df[, c("Variable", "IncNodePurity")]

# Convert the scientific notation to standard numeric format
impOne_df$IncNodePurity <- as.numeric(impOne_df$IncNodePurity)

# Optionally, round the numbers to 3 decimal places
impOne_df$IncNodePurity <- round(impOne_df$IncNodePurity, 3)

# Print the updated data frame
print(impOne_df)


