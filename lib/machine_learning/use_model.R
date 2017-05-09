library(e1071, quietly = TRUE)
library(jsonlite, quietly = TRUE)
source('generate_tuples.R') # loads function "generate_tuples(price_list)"

# load the bill (needs argument via command line)
args = commandArgs(trailingOnly=TRUE)
price_list = read.csv(args, header=TRUE)



# load one bill
# price_list_orig = read.csv("prices.csv", header=TRUE)
# price_list = price_list_orig[price_list_orig$bill_id == "296mm2mqrPTJMsB4J", ]  # Lade nur eine Rechnung!
# price_list = price_list_orig[price_list_orig$bill_id == "25KA7rWWmhStXDEsb", ]
# price_list = price_list_orig[price_list_orig$bill_id == "26joYiARG5L5SmfxM", ]
# price_list = price_list_orig[price_list_orig$bill_id == "28RetYi6SMMvTApqi", ]


data_for_classification = generate_tuples(price_list)
# data_for_classification[ , "valid_amount"] <- as.factor(0)

# Attributs for the svm model -  MUST BE THE SAME AS IN "generate_model.R"
col <- c("total_price_s", "vat_price_s", "rel_p", "price_order", "price_uq", "common_width", "common_height")

data = data_for_classification[ , col]



# load model
M <- readRDS('modelfile.rds')


# predict 
p <- predict(M, data , type = "C-classification")

tmp = data_for_classification[p == 1,]
output = data.frame("price_id" = tmp$total_id, 
                    "vat_id" = tmp$vat_id, 
                    "total_price" = tmp$total_price, 
                    "vat_price" = tmp$vat_price,
                    "vat_rate" = tmp$vat_price / tmp$total_price * 100)


#toJSON(output, pretty=TRUE) # nice  formatted output
toJSON(output)