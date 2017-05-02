# Diese Funktion erhält eine Preisliste und generiert daraus mögliche Tupel
# Außerdem werden die zusätzlichen Attribute generiert und hinzugefügt
generate_tuples <- function(price_list){

  combinations = expand.grid(c(1:nrow(price_list)), c(1:nrow(price_list)))
  
  part1 = price_list[ combinations$Var1, ]
  part2 = price_list[ combinations$Var2, c("id", "text", "amount", "left","right","top", "bottom")]
  
  # Nochmal kontrollieren ob die Umbenennungen richtig sind
  colnames(part1)<- c("bill_id","total_id", "total_text", "total_price","total_left", "total_right", "total_top","total_bottom")
  colnames(part2)<- c("vat_id", "vat_text", "vat_price","vat_left", "vat_right", "vat_top","vat_bottom")
  
  
  tuples = data.frame(part1,part2)
  
  # Es werden nur Tuples weiter verarbeitet die bestimmte Bedingungen erfüllen
  data = tuples[tuples[,"vat_price"] <= 0.3 * tuples[,"total_price"] &  tuples[,"total_price"] > 0 ,  ]

  # scaling prices
  max_price = max(price_list$amount)
  data[ , "total_price"] <- data[ , "total_price"] / max_price
  data[ , "vat_price"] <- data[ , "vat_price"] / max_price
  
  
  
  # creates "rel_p"
  data[ , "rel_p"] <- data$vat_price / data$total_price 
  
  
  
  ###################  AB Hier Muss noch angepasst werden
  
  # adding "price_order" and "price_uq"
  for(i in 1:length(tab)){
    
    # all_prices ..  list of ALL prices in ONE bill 
    prices = data[data$id == names(tab)[i],"total_price"]
    all_prices = c(data[data$id == names(tab)[i],"total_price"] , data[data$id == names(tab)[i],"vat_price"])
    prices_red = unique(sort(all_prices))  # sorted prices reduced (deleted all repeated elements)
    
    # creating "price_order"
    data[data$id == names(tab)[i],"price_order"] <- match(data[data$id == names(tab)[i], "total_price"], sort(prices_red)) / length(prices_red)
    
    # creating "price_uq"
    quantil_limit = quantile(all_prices, 0.75)
    data[data$id == names(tab)[i],"price_uq"] <- as.numeric(prices > quantil_limit)
  }
  
  
  # adding common width
  data[ ,"common_width"] <- 
    apply(data[ ,c("total_left", "total_right", "vat_left", "vat_right")], 1, max) -
    apply(data[ ,c("total_left", "total_right", "vat_left", "vat_right")], 1, min)
  
  
  # adding common height
  data[ ,"common_height"] <- 
    apply(data[ ,c("total_top", "total_bottom", "vat_top", "vat_bottom")], 1, max) -
    apply(data[ ,c("total_top", "total_bottom", "vat_top", "vat_bottom")], 1, min)
  
  
  
  
  
  
  
  
  
  
  
  
  
    
  return(data)
}

# reconstruct Price list from Tupel
# a = data_orig
# tmp1 = data.frame("bill_id" = a$id, "id" = 123, "text" = "text", "amount" = a$total_price, "left" = a$total_left, "right" = a$total_right, "top" = a$total_top, "bottom" = a$total_bottom)
# tmp2 = data.frame("bill_id" = a$id, "id" = 123, "text" = "text", "amount" = a$vat_price, "left" = a$vat_left, "right" = a$vat_right, "top" = a$vat_top, "bottom" = a$vat_bottom)
# tmp3 = rbind(tmp1, tmp2)
# tmp4 = unique(tmp3)
# 
# write.csv(tmp4, "price_list_1.csv")

