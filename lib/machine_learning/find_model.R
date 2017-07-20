# Set Working Directory to Source file location (only necessary in RStudio)
# RScript uses automatically the right directory
{

source("machine_learning_lib.R") # loads function "generate_tuples(price_list)"
library(fields) # for scatterplot
library(ggplot2)

######################################
######    GENERATION OF DATA    ######
######################################
# This section will go to machine_learning_lib.R

# load data from several bills
prices_several_bills <- read.csv("csv/prices.csv", header = TRUE)
correct_price_tuples <- read.csv("csv/correct_price_tuples.csv", header = TRUE)

# generate tuples and add attributes
tab <- table(prices_several_bills$bill_id)
calibration_data <-
  generate_tuples(prices_several_bills[prices_several_bills$bill_id == names(tab)[1], ])
for (i in 2:length(tab)){
  # cat("Bill #", i, "; Bill id:", names(tab)[i],"\n")
  calibration_data <-
    rbind(calibration_data,
          generate_tuples(prices_several_bills[prices_several_bills$bill_id == names(tab)[i], ]))
}

# adding correct answer in "valid_amount"
calibration_data[, "valid_amount"] <- 0
calibration_data[calibration_data$total_id %in% correct_price_tuples$total_id &
                 calibration_data$vat_id %in% correct_price_tuples$vat_id,  "valid_amount"] <-  1
# calibration_data$valid_amount = as.factor(calibration_data$valid_amount) #convert to factor

# Change Row namesto 1, 2, 3, ...
rownames(calibration_data) <- NULL

# Print percentage of right combinations
cat("Amount of false and right combinations:",
    table(calibration_data$valid_amount),
    "<=>", table(calibration_data$valid_amount)[2] / nrow(calibration_data) * 100,
    "% right combinations%\n")

}


######################################
######           SVM            ######
######################################


##### ALL POSSIBLE COMBINATIONS OF ATTRIBUTES ##########
# 
# col_all = c("total_price_s", "vat_price_s", "rel_p", "price_order", "price_uq", "common_width", "common_height")
# 
# list_of_col = list()
# for( i in 1:length(col_all)){
#   list_of_col = append(list_of_col, as.list(as.data.frame(combn(col_all,i))))
# }
# #names(list_of_col) = NULL
# 
# # change "col" to EVERY possible combination
# for( i in 1:length(list_of_col)){
#   col = as.character(list_of_col[[i]])
# }
# 


# choose which arguments to use in the SVM
col <- c("total_price_s",
         "vat_price_s",
         "rel_p",
         "common_width_s",
         "common_height_s",
         "total_price_order",
         "total_price_uq",
         "total_height_s",
         "total_height_uq",
         "total_char_width_s",
         "total_char_width_uq")




######       GRID-SEARCH FOR A COL       ######
cost_range <- 10 ^ (-2:2)
gamma_range <- 10 ^ (-1:1)

# cost_range <- 10 ^ (-3:7)
# gamma_range <- 10 ^ (-3:3)


# Grid search for the hyperparameters using ALL data
data_train <- calibration_data[, col]
answer_train <- calibration_data[, "valid_amount"]

# Detaild output
hyperparameters_detailed <-
  hyperparameters_grid_search(data_train = data_train,
                              answer_train = answer_train,
                              cost_range = cost_range,
                              gamma_range = gamma_range,
                              detailed.output = TRUE,
                              nruns = 10)

{
  # plotting wrong positive
  #x11()
  dev.new()
  dev.new()
  par(mar = c(12, 5, 4, 2) + 0.1)
  boxplot(t(hyperparameters_detailed$wrong_positive), las = 2,
          main = paste("Wrong-Positive - Best Hyperp.: Cost = ",
                       hyperparameters_detailed$tuned$best.parameters$cost,
                       ", gamma = ",
                       hyperparameters_detailed$tuned$best.parameters$gamma ),
          ylab = "Wrong Positive")



  # ggplot2
  # We need the standard format for data
  # as.data.frame(t(hyperparameters_detailed$wrong_positive))
  # ggplot(as.data.frame(t(hyperparameters_detailed$wrong_positive)),
  #        aes(factor(Year), Value))
  # str(hyperparameters_detailed$wrong_positive)

  # mean of wrong-positives as matrix for 2d plot
  z1 <- matrix(apply(hyperparameters_detailed$wrong_positive,
                     1,
                     na_omit_mean),
               byrow = FALSE,
               ncol = length(gamma_range))
  # z <- matrix(hyperparameters_detailed$tuned$performances$error, ncol = length(gamma_range))
  dev.new()
  image.plot(log10(cost_range), log10(gamma_range), z1,
        xlab = "log(cost)", ylab = "log(gamma)",
        main = "Mean wrong-positive error")
  box()
  contour(log10(cost_range), log10(gamma_range), z1, main = "Mean wrong-positive error", add = TRUE)


  # plotting wrong negative
  dev.new()
  par(mar = c(12, 5, 4, 2) + 0.1)
  boxplot(t(hyperparameters_detailed$wrong_negative), las = 2,
          main = paste("Wrong-Negative"),
          ylab = "Wrong Negative")


  # mean of wrong-negatives as matrix for 2d plot
  z2 <- matrix(apply(hyperparameters_detailed$wrong_negative,
                     1,
                     na_omit_mean),
               byrow = FALSE,
               ncol = length(gamma_range))
  dev.new()
  image.plot(log10(cost_range), log10(gamma_range), z2,
             xlab = "log(cost)", ylab = "log(gamma)",
             main = "Mean wrong-negative error")
  box()
  contour(log10(cost_range), log10(gamma_range), z2, main = "Mean wrong-negative error", add = TRUE)
}
  
#graphics.off()



######       ERROR DISTRIBUTION FOR COL        ######
# Define the hyperparameters
cost <- 1000
gamma <-  0.01

error_run1 <-
  generate_error_distribution(number_of_runs = 100,
                              col = col,
                              calibration_data = calibration_data,
                              cost = cost,
                              gamma = gamma)


#print error distributions
cat("Percentage of NaN results: ",
    sum(is.na(error_run1$error4)) / length(error_run1$error4) * 100, "%")
hist(error_run1$error4)
hist(error_run1$cost)
hist(error_run1$gamma)


# save Model 
# This will go to a new file "create_model.R"
# saveRDS(svmfit, 'modelfile.rds')
# cat("Saved model to svm_model.svm\n")
