#####################################
######    ADDING ATTRIBUTES    ######
#####################################

# noch nicht als Funktion!! 
# Es wird einfach dieser Teil des Skriptes ausgeführt
# Wenn als Funktion / Modul --> muss Name "data" nicht mehr ident sein
# laden über source("adding_attriutes.R") (wird jedes mal ausgeführt nicht wie require)
# In Zukunft wird addding_attributes() als Funktion für jede einzelne Rechnung aufgerufen
# --> dadurch wird nur noch EINE for Schleife über alle Rechnungen benötigt


data$valid_amount <- as.factor(data$valid_amount)

tab = table(data$id) # includes the name of the bills and the amount of price combinations

# scaling prices
for(i in 1:length(tab)){
  max_price = max(subset(data, id == names(tab)[i], select = c(total_price, vat_price)))
  data[data$id == names(tab)[i],"total_price"]  <-  data[data$id == names(tab)[i],"total_price"] / max_price
  data[data$id == names(tab)[i],"vat_price"]  <-  data[data$id == names(tab)[i],"vat_price"] / max_price
}

# creates "rel_p"
data[ , "rel_p"] <- data$vat_price / data$total_price 


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



