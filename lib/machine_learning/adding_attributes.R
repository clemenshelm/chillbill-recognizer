#####################################
######    ADDING ATTRIBUTES    ######
#####################################

# noch nicht als Funktion!! 
# Es wird einfach dieser Teil des Skriptes ausgeführt
# Wenn als Funktion / Modul --> muss Name "data" nicht mehr ident sein
# laden über source("adding_attriutes.R") (wird jedes mal ausgeführt nicht wie require)



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

# adding common height


# Höhe des Preises > als median aller Höhen



