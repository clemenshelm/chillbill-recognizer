# Set Working Directory to Source file location (only necessary in RStudio)
# RScript uses automatically the right directory
{
library(e1071)
source('machine_learning_lib.R') # loads function "generate_tuples(price_list)"


######################################
######    GENERATION OF DATA    ######
######################################
# This section will go to machine_learning_lib.R

# load data from several bills
prices_several_bills = read.csv("prices.csv", header = TRUE)
correct_price_tuples = read.csv("correct_price_tuples.csv", header = TRUE)

# generate tuples and add attributes
tab = table(prices_several_bills$bill_id)
calibration_data = generate_tuples(prices_several_bills[prices_several_bills$bill_id == names(tab)[1], ])
for(i in 2:length(tab)){
  # cat("Bill #", i, "; \n")
  calibration_data = rbind( calibration_data, 
                            generate_tuples(prices_several_bills[prices_several_bills$bill_id == names(tab)[i], ]))
}

# adding correct answer in "valid_amount"
calibration_data[ , "valid_amount"] = 0
calibration_data[   calibration_data$total_id %in% correct_price_tuples$total_id &
                    calibration_data$vat_id %in% correct_price_tuples$vat_id ,  "valid_amount"] =  1
#calibration_data$valid_amount = as.factor(calibration_data$valid_amount) #convert to factor

# Change Row namesto 1, 2, 3, ...
rownames(calibration_data) <- NULL

# Print percentage of right combinations
cat("Amount of false and right combinations:", table(calibration_data$valid_amount), 
 "<=>", table(calibration_data$valid_amount)[2]/ nrow(calibration_data) * 100, "% right combinations%\n")

}




######################################
######           SVM            ######
######################################

# For now we just consider the wrong-positive error
# number_of_runs = 20
#error_matrix = data.frame()


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


# choose which arguments are for the SVM
col = c("total_price_s", "vat_price_s", "rel_p", "price_order", "price_uq", "common_width", "common_height", "height_uq")






######       GRID-SEARCH FOR COL       ######
{
  cost_range = 10^(-3:7)
  gamma_range = 10^(-3:3)
  
  
  # Grid search for the hyperparameters using ALL data
  data_train = calibration_data[ ,col]
  answer_train = as.factor(calibration_data[ ,"valid_amount"])
  
  # normal output
  # best_hyperparameters <- hyperparameters_grid_search(data_train = data_train, answer_train = answer_train, cost_range = cost_range, gamma_range = gamma_range, detailed.output = FALSE)
  

  # Detaild output
  hyperparameters_detailed <- hyperparameters_grid_search(data_train = data_train, answer_train = answer_train, cost_range = cost_range, gamma_range = gamma_range, detailed.output = TRUE, nruns = 10)
  
  
  # plotting 
  x11()
  boxplot(hyperparameters_detailed[[2]], las=2, 
          main = paste("Best Hyperp.: Cost = ", hyperparameters_detailed$tuned$best.parameters$cost, ", gamma = ", hyperparameters_detailed$tuned$best.parameters$gamma ), 
          ylab = "Wrong Positive", par(mar = c(12, 5, 4, 2)+ 0.1))
  
  
  lapply(hyperparameters_detailed[[2]], function(x) x[!is.na(x)])
  
  dev.new()
  require(geoR)
  z <- matrix(hyperparameters_detailed$tuned$performances$error, ncol = length(gamma_range))
  dev.new()
  image.plot(log10(cost_range), log10(gamma_range), z,
        xlab = "log(cost)", ylab = "log(gamma)",
        main = "Mean wrong-positive error")
  box()
  
  dev.new()
  contour(log10(cost_range), log10(gamma_range), z)
  
  # compute key figures out of "hyperparameters_detailed"
  matrix(as.numeric(sapply(hyperparameters_detailed[[2]], na_omit_mean)), nrow = length(cost_range))
}


graphics.off()


# Distribution of the parameters (cost and gamma)
# parameter_run1 =  generate_parameters_distribution(number_of_runs = 100, col = col, calibration_data = calibration_data)


######       ERROR DISTRIBUTION FOR COL        ######
cost = 1000
gamma =  0.01

error_run1 = generate_error_distribution(number_of_runs = 1000, col = col, calibration_data = calibration_data, cost = cost, gamma = gamma)


#print error distributions
hist(error_run1$error4)

cat("Percentage of NaN results: ", sum(is.na(error_run1$error4))/ length(error_run1$error4) * 100, "%")

table(error_run1$error4)
hist(error_run1$cost)
hist(error_run1$gamma)


# save Model 
# This will go to a new file "create_model.R"
# saveRDS(svmfit, 'modelfile.rds')
# cat("Saved model to svm_model.svm\n")
