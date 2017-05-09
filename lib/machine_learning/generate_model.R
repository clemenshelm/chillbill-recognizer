# Set Working Directory to Source file loaction (only necessary in RStudio)
# RScript uses automatically the right directionary


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



# Print some informations
cat("Amount of false and right combinations:", table(calibration_data$valid_amount), 
 "<=>", table(calibration_data$valid_amount)[2]/ nrow(calibration_data) * 100, "% right combinations%\n")



#######################
######    SVM    ######
#######################

n = nrow(calibration_data)
s = sample(n, round(n * 0.7))


# choose which arguments are for the SVM
col = c("total_price_s", "vat_price_s", "rel_p", "price_order", "price_uq", "common_width", "common_height")
#col = names(calibration_data) # all
#col = names(calibration_data)[!names(calibration_data) %in% c("id","valid_amount")] # all but..


# build training values and answers (converted to factor)
data_train = calibration_data[s,col]
data_test = calibration_data[-s,col]
answer_train = as.factor(calibration_data[s,"valid_amount"])
answer_test = as.factor(calibration_data[-s,"valid_amount"])

#data_train$valid_amount = as.factor(data_train$valid_amount)
#data_test$valid_amount = as.factor(data_test$valid_amount)



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


svmfit = svm(x = data_train, 
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
cat("Wie viel wird generell richtig erkannt:", mean(p == answer_test), "\n")
cat("False Positive", mean(answer_test[p == 1] == 0), "\n\n")



# needs adaptaion, the name is incorrect
# cat("Wie viele von echten Werten werden als solche erkannt:", mean(p[data_test$valid_amount == 1] == 1),"\n" )
# cat("Wie viele von den erkannten Werten sind tatsächliich welche:", mean(data_test$valid_amount[p == 1] == 1),"\n")
# cat("Wie viele von den falschen Werten werden als soche erkannt:", mean(p[data_test$valid_amount == 0] == 0),"\n")
# cat("Wie viele von den als falsch erkannten Werten sind tatsächlich falsch:", mean(data_test$valid_amount[p == 0] == 0),"\n")
# cat("------------------------------------------------------------\n\n")


#cat("Ausgabe der false-positive:\n")
#print(data_test[data_test$valid_amount[p == 1] == 0,])



