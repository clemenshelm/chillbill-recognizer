# Set Working Directory to Source file location (only necessary in RStudio)
# RScript uses automatically the right directory


library(e1071)
source('generate_tuples.R') # loads function "generate_tuples(price_list)"


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

number_of_tuples = nrow(calibration_data)
selection = sample(number_of_tuples, round(number_of_tuples * 0.7)) 
# pulls approx. 70% random tuples for training, the remaining 30% are for testing the model


# choose which arguments are for the SVM
col = c("total_price_s", "vat_price_s", "rel_p", "price_order", "price_uq", "common_width", "common_height")
#col = names(calibration_data) # all
#col = names(calibration_data)[!names(calibration_data) %in% c("id","valid_amount")] # all but..


# build training values and answers (converted to factor)
data_train = calibration_data[selection,col]
data_test = calibration_data[-selection,col]

answer_train = as.factor(calibration_data[selection,"valid_amount"])
answer_test = as.factor(calibration_data[-selection,"valid_amount"])


# Grid-search for the best paramters, kernel="radial" ... RBF
tuned = tune(svm, 
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

cat("Best parameters:\n")
print(tuned$best.parameters)


svmfit = svm( x = data_train, 
              y = answer_train, 
              kernel ="radial", 
              cost = tuned$best.parameters$cost, 
              gamma= tuned$best.parameters$gamma, 
              scale = FALSE, 
              type = "C-classification")



# save Model 
saveRDS(svmfit, 'modelfile.rds')
cat("Saved model to svm_model.svm\n")

# prediction
p = predict(svmfit, data_test, type = "C-classification")



cat("------------------------------------------------------------\n")
cat("1: Overall recognition:", mean(p == answer_test), "\n")
cat("2: Recognition rate of right values:", mean(p[answer_test == 1] == 1), "\n")
cat("3: Recognition rate of the wrong values:", mean(p[answer_test == 0] == 0), "\n")
cat("4: False Positive:", mean(answer_test[p == 1] == 0), " <-- \n")
cat("5: Right Positive:", mean(answer_test[p == 1] == 1), "\n")
cat("6. False Negative:", mean(answer_test[p == 0] == 1), "\n")
cat("7: Right Negative:", mean(answer_test[p == 0] == 0), "\n")
cat("------------------------------------------------------------\n\n")

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




