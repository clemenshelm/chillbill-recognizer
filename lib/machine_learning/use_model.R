library(e1071, quietly = TRUE)
library(jsonlite, quietly = TRUE)
source('machine_learning_lib.R') # loads function "generate_tuples(price_list)"

# load the bill (needs argument via command line like 296mm2mqrPTJMsB4J.csv)
args = commandArgs(trailingOnly=TRUE)
price_list = read.csv(args, header=TRUE)

# gnerate tuples and add attributes
data_for_classification = generate_tuples(price_list)





# load model
M <- readRDS('modelfile.rds')


# predict 
p <- predict(M, data_for_classification , type = "C-classification")

# Output
tmp = data_for_classification[p == 1,]
output = data.frame("price_id" = tmp$total_id, 
                    "vat_id" = tmp$vat_id, 
                    "total_price" = tmp$total_price, 
                    "vat_price" = tmp$vat_price,
                    "vat_rate" = tmp$vat_price / tmp$total_price * 100)


toJSON(output, pretty=TRUE) # nice  formatted output
#toJSON(output) # in one line