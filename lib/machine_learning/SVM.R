###############################################
######    Description of the data set    ######
# rel_p       Verhältnis von Preis zu vat_price über alle daten wird hinzugefügt
# price_order position of price entry compared to all prices in the bill
# price_uq    1 if price is in the upper quartil (25%), 0 if not
# group       colors for the plots
###############################################

#install.packages("e1071")
library(e1071)

data_orig = read.csv("price_tuples.csv", header = TRUE)
data = data_orig[data_orig[,"vat_price"] <= 0.3 * data_orig[,"total_price"],  c("id", "total_price", "vat_price", "valid_amount")]


# Amount of right data vs. wrong ones
tmp = table(data$valid_amount)
cat("Prozent richtiger Einträge: ", tmp[2]/(sum(tmp)) * 100, "%\n")


# ADDING_ATTRIBUTES
source("adding_attributes.R")



############################
######    PLOTTING    ######
############################

# R plots for colorselection (1,0) the awsome colors black and WHITE?!
# adding "group" = valid_amount but with strings (for nice colors in R)
#data[data$"valid_amount" == 1, "group"] <- "red"
#data[data$"valid_amount" == 0, "group"] <- "green"

# 
# # Select the data we want to plot
# data_selection1 = data[ ,c("total_price", "vat_price", "rel_p")]
# data_selection2 = data[, !names(data) %in% c("id","valid_amount", "group")]
# 
# # Plot
# plot(data_selection1, col=data$group)
# #plot(data_selection2, col=data$group)
# 






#######################
######    SVM    ######
#######################

n = nrow(data)
s <- sample(n, round(n * 0.7))
data$valid_amount <- as.factor(data$valid_amount)  # Konvert to factor

# choose which arguments are for the SVM
col <- c("total_price", "vat_price", "rel_p", "price_order", "price_uq", "valid_amount")  # group darf nicht dabei sein!



data_train <- data[s,col]
data_test <- data[-s,col]


  
# Grid-search nach den besten Parametern 
# kernel="radial" ... RBF
tuned <- tune(svm, valid_amount ~ ., 
              data   = data_train, 
              kernel = "radial", 
              type   = "C-classification", 
              scale  = FALSE, 
              ranges = list(
                              cost = 10^(-1:6), 
                              gamma = 10^(-1:1)
                            ) 
        )

#summary(tuned)

print(tuned$best.parameters)




svmfit <- svm(valid_amount ~., data=data_train, kernel ="radial", cost = tuned$best.parameters$cost, gamma= tuned$best.parameters$gamma, scale = FALSE, type = "C-classification")
#print(svmfit)
#plot(svmfit, data_train[,"rel_p"])


# Save Model 
# save(svmfit, file='mymodel.rda')



p <- predict(svmfit, data_test, type = "C-classification")
#plot(p)
# table(data_train$valid_amount)
# table(data_test$valid_amount)

cat("Wie viel wird generell richtig erkannt:", mean(p == data_test[,"valid_amount"]), "\n")
cat("Wie viele von echten Werten werden als solche erkannt:", mean(p[data_test$valid_amount == 1] == 1),"\n" )
cat("Wie viele von den erkannten Werten sind tatsächliich welche:", mean(data_test$valid_amount[p == 1] == 1),"\n")
cat("Wie viele von den falschen Werten werden als soche erkannt:", mean(p[data_test$valid_amount == 0] == 0),"\n")
cat("Wie viele von den als falsch erkannten Werten sind tatsächlich falsch:", mean(data_test$valid_amount[p == 0] == 0),"\n")





