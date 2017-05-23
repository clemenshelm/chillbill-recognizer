# Set Working Directory to Source file location (only necessary in RStudio)
# RScript uses automatically the right directory

library(e1071)
source('generate_tuples.R') # loads function "generate_tuples(price_list)"

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

# Change Row names
rownames(calibration_data) <- NULL

# Print some informations
cat("Amount of false and right combinations:", table(calibration_data$valid_amount), 
 "<=>", table(calibration_data$valid_amount)[2]/ nrow(calibration_data) * 100, "% right combinations%\n")



#######################
######    SVM    ######
#######################

# For now we just consider the wrong-positive error
number_of_runs = 50
error_matrix = data.frame()


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
#col = names(calibration_data) # all
#col = names(calibration_data)[!names(calibration_data) %in% c("id","valid_amount")] # all but..

# name_of_model = paste(col, sep="", collapse="/") # the name of the error matrix



#####   To get a distribution of the error we run each combination several times (number_of_runs times)  #####

output_error4 = numeric(number_of_runs)
output_cost = numeric(number_of_runs)
output_gamma = numeric(number_of_runs)



for(iteration in 1:number_of_runs){
  number_of_tuples = nrow(calibration_data)
  selection = sample(number_of_tuples, round(number_of_tuples * 0.7)) 
  # pulls approx. 70% random tuples for training, the remaining 30% are for testing the model
  
  # build training values and answers (converted to factor)
  data_train = calibration_data[selection,col]
  data_test = calibration_data[-selection,col]
  
  answer_train = as.factor(calibration_data[selection,"valid_amount"])
  answer_test = as.factor(calibration_data[-selection,"valid_amount"])
  
  # Grid-search for the best paramters, kernel="radial" ... RBF
  tuned = tune( svm, 
                train.x = data_train, 
                train.y = answer_train,
                kernel = "radial",
                type   = "C-classification",
                scale  = FALSE,
                ranges = list(
                                cost = 10^(-1:6),
                                gamma = 10^(-1:1)
                              )
          )
  
  # create the model with the best cost and gamma parameters
  svmfit = svm( x = data_train, 
                y = answer_train, 
                kernel ="radial", 
                cost = tuned$best.parameters$cost, 
                gamma= tuned$best.parameters$gamma, 
                scale = FALSE, 
                type = "C-classification")
  
  # prediction
  p = predict(svmfit, data_test, type = "C-classification")
  
  
  
  
  # Save to output-vectors
  output_error4[iteration] = mean(answer_test[p == 1] == 0)
  output_cost[iteration] = tuned$best.parameters$cost
  output_gamma[iteration] = tuned$best.parameters$gamma
  
  cat("Progress: ", iteration/number_of_runs, "\n")
  
  #error_matrix[iteration, name_of_model] = mean(answer_test[p == 1] == 0)
  
}

# Save the output_data to list of lists (needs to be done)

hist(output_error4)
hist(output_cost)
hist(output_gamma)

cat("Best parameters:\n")
print(tuned$best.parameters)

cat("------------------------------------------------------------\n")
cat("1: Overall recognition:", mean(p == answer_test), "\n")
cat("2: Recognition rate of right values:", mean(p[answer_test == 1] == 1), "\n")
cat("3: Recognition rate of the wrong values:", mean(p[answer_test == 0] == 0), "\n")
cat("4: False Positive:", mean(answer_test[p == 1] == 0), " <-- \n")
cat("5: Right Positive:", mean(answer_test[p == 1] == 1), "\n")
cat("6. False Negative:", mean(answer_test[p == 0] == 1), "\n")
cat("7: Right Negative:", mean(answer_test[p == 0] == 0), "\n")
cat("------------------------------------------------------------\n\n")

# Description
# 1: How many of the overall predictions are right, higher is better
# 2: How many of the positive values are recognized correct, higher is better
# 3: How many of the negative values are recognized correct, higher is better
# 4: How many of the positive predictions are wrong, lower is better
# 5: How many of the positive predictions are real positive, higher is better
# 6: How many of the negative predictoins are wrong negative, lower is better 
# 7: How many of the negative predictoins are real negative, higher is better



cat("Output of the false-positive Combinations:\n")
# data_test[ , "valid_amount"] = answer_test
print(data_test[answer_test == 0 & p == 1, ])

# save Model 
saveRDS(svmfit, 'modelfile.rds')
cat("Saved model to svm_model.svm\n")



