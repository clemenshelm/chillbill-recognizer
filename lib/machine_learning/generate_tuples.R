# The function "generate_tuples" gets prices and returns possible combinations of tuples.
# It also adds attributes and erases NaN entries

###############################################
######    Description of the data set    ######
# rel_p         proportion of vat_price to total_price
# price_order   position of price entry compared to all prices in the bill
# price_uq      1 if price is in the upper quartil (25%), 0 if not
# total_price_s Scaled total_price
# vat_price_s   Scaled vat_price
# common_width  The common width of the possible total_price and the possible vat_price
# common_height The common height of the possible total_price and the possible vat_price
# group         colors for plots
###############################################

# Load example bill for debugging / creating new attributes:
#price_list = read.csv("25KA7rWWmhStXDEsb.csv", header=TRUE)



generate_tuples <- function(price_list){
  
  combinations = expand.grid(c(1:nrow(price_list)), c(1:nrow(price_list)))
  part1 = price_list[ combinations$Var1, c("bill_id", "price_id",  "text", "price_cents", "left","right","top", "bottom")]
  part2 = price_list[ combinations$Var2, c("price_id",  "text", "price_cents", "left","right","top", "bottom")]
  
  # rename columns
  colnames(part1)<- c("bill_id","total_id", "total_text", "total_price","total_left", "total_right", "total_top","total_bottom")
  colnames(part2)<- c("vat_id", "vat_text", "vat_price","vat_left", "vat_right", "vat_top","vat_bottom")
  tuples = data.frame(part1,part2)
  
  # only use specific combinations
  data = tuples[tuples[,"vat_price"] <= 0.3 * tuples[,"total_price"] &  tuples[,"total_price"] > 0 ,  ]
  
  # delete unused variables
  rm(combinations, part1, part2, tuples)
  
  # scaling prices
  max_price = max(price_list$price_cents)
  data[ , "total_price_s"] <- data[ , "total_price"] / max_price
  data[ , "vat_price_s"] <- data[ , "vat_price"] / max_price
  
  
  
  # creates "rel_p"
  data[ , "rel_p"] <- data$vat_price / data$total_price 
  
  
  
  # adding common width
  data[ ,"common_width"] <- 
    apply(data[ ,c("total_left", "total_right", "vat_left", "vat_right")], 1, max) -
    apply(data[ ,c("total_left", "total_right", "vat_left", "vat_right")], 1, min)
  
  
  # adding common height
  data[ ,"common_height"] <- 
    apply(data[ ,c("total_top", "total_bottom", "vat_top", "vat_bottom")], 1, max) -
    apply(data[ ,c("total_top", "total_bottom", "vat_top", "vat_bottom")], 1, min)
  
    
  # creating "price_order"
  # It is very likely that "price_order" do not contain low values because we do not use all possible tuples
  prices_red = unique(sort(price_list$price_cents))  # sorted prices reduced (deleted all repeated elements)
  data[ ,"price_order"] <- match(data[ , "total_price"], sort(prices_red)) / length(prices_red)
  
  
  # creating "price_uq"
  quantil_limit = quantile(price_list$price_cents, 0.75)
  data[ ,"price_uq"] <- as.numeric(data$total_price > quantil_limit)
  
  
  # Checking of NaN entries
  tmp = sum(is.na(data))
  # cat("After adding Attributes there are", tmp , "NaN entries\n" )
  if(tmp != 0){data[is.na(data)] = 0 }  # sets NaN values to 0
  
  
  
  # height of total_price > median of all heights?
  
  
    
  return(data)
  
}




