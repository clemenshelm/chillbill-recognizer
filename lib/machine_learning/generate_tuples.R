# Diese Funktion erhält eine Preisliste und generiert daraus mögliche Tupel
# Außerdem werden die zusätzlichen Attribute generiert und hinzugefügt
# Zum Schluss werden eventuelle NaN Einträge zu 0 gemacht

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
  if(tmp != 0){data[is.na(data)] = 0 }  # Setze NaN auf 0
    
  return(data)
}





# Höhe des Preises > als median aller Höhen 
# Hat derzeit noch keinen Sinn, erst weitermachen wenn ich die Liste aller Preise übergeben bekomme

# 
# for(i in 1:length(tab)){
#   height_real_prices = (data$total_bottom - data$total_top)[data$id ==  names(tab)[i] & data$valid_amount == 1]
#   height_false_prices = (data$total_bottom - data$total_top)[data$id ==  names(tab)[i] & data$valid_amount == 0]
#   
#   a = c(numeric(length(height_false_prices)), numeric(length(height_real_prices)) + 1)
#   b = c(height_false_prices, height_real_prices)
#   plot(cbind(a,b))
#   
# }

# Plotte alle Preise  (keine Unterscheidung zwischen den einzelnen Rechnungen)
# hist(height_real_prices,xlim=c(0, 0.03), ylim=c(0,30),breaks=10,col=rgb(1,1,0,0.7),main="",xlab="number")
# par(new=TRUE)
# hist(height_false_prices,xlim=c(0, 0.03), ylim=c(0,30),breaks=10,col=rgb(0,1,1,0.4),main="",xlab="",ylab="")













# reconstruct Price list from Tupel
# a = data_orig
# tmp1 = data.frame("bill_id" = a$id, "id" = 123, "text" = "text", "amount" = a$total_price, "left" = a$total_left, "right" = a$total_right, "top" = a$total_top, "bottom" = a$total_bottom)
# tmp2 = data.frame("bill_id" = a$id, "id" = 123, "text" = "text", "amount" = a$vat_price, "left" = a$vat_left, "right" = a$vat_right, "top" = a$vat_top, "bottom" = a$vat_bottom)
# tmp3 = rbind(tmp1, tmp2)
# tmp4 = unique(tmp3)
# 
# write.csv(tmp4, "price_list_1.csv")

