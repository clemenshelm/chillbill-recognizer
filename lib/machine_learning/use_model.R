library(e1071)

#
price_list = read.csv("price_list_1.csv", header=TRUE)
price_list = price_list[price_list$bill_id == "296mm2mqrPTJMsB4J", ]  # Lade nur eine Rechnung!
price_list = price_list[price_list$bill_id == "296mm2mqrPTJMsB4J", !names(price_list) %in% c("X")] # ohne X Spalte


source("generate_tuples.R")
data_for_classification = generate_tuples(price_list)


svmfit = load('svm_model.rda')



