# Set Working Directory to Source file location (only necessary in RStudio)
# RScript uses automatically the right directory

library(e1071)
source('machine_learning_lib.R') # loads function "generate_tuples(price_list)"


######################################
######    GENERATION OF DATA    ######
######################################

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

# Print some informations
cat("Amount of false and right combinations:", table(calibration_data$valid_amount), 
 "<=>", table(calibration_data$valid_amount)[2]/ nrow(calibration_data) * 100, "% right combinations%\n")




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


# We must rethink the search for the optimal hyperparameters (cost, gamma) because the tune function already calculates the distribution.
# So now we calculate the distribution of the optimal parameter searched through the distribution of the error?? 
# The standard tund function calculates the wrong error, but I fixed that already


# Distribution of the parameters (cost and gamma)
# parameter_run1 =  generate_parameters_distribution(number_of_runs = 100, col = col, calibration_data = calibration_data)



error_run1 = generate_error_distribution(number_of_runs = 20, col = col, calibration_data = calibration_data, cost = NULL, gamma = NULL)


#print error distributions
hist(run1$error4)
hist(run1$cost)
hist(run1$gamma)






# save Model 
# saveRDS(svmfit, 'modelfile.rds')
# cat("Saved model to svm_model.svm\n")



