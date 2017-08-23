library(e1071, quietly = TRUE)
library(jsonlite, quietly = TRUE)
source("machine_learning_lib.R") # loads function "generate_tuples(price_list)"

# load the bill (needs argument via command line like 296mm2mqrPTJMsB4J.csv)
args <- commandArgs(trailingOnly = TRUE)
price_list <- read.csv(args, header = TRUE)

# gnerate tuples and add attributes
data_for_bill_type <- generate_bill_type_att(price_list)
data_for_classification <- generate_tuples(price_list)


# determine typ of bill
bill_typ_classifier <- readRDS("modelfile_bill_typ_classifyer.rds")
predicted_type <- predict(bill_typ_lassifier,
                          data_for_bill_type,
                          type = "C-classification")

# load correct model
classification_model <- switch(predicted_type,
                               "a4" = readRDS("modelfile_a4.rds"),
                               "sales_check" = readRDS("modelfile_sales_check.rds"))

# predict 
p <- predict(classification_model, data_for_classification, type = "C-classification")

# Output
tmp <- data_for_classification[p == 1, ]
output <- data.frame("price_id" = tmp$total_id,
                    "vat_id" = tmp$vat_id,
                    "total_price" = tmp$total_price,
                    "vat_price" = tmp$vat_price,
                    "vat_rate" = tmp$vat_price / tmp$total_price * 100)


toJSON(output, pretty = TRUE) # nice  formatted output
#toJSON(output) # in one line