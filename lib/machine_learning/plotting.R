
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


##############################
## Distribution of heights ##

# load data from several bills
prices_several_bills = read.csv("prices.csv", header = TRUE)
correct_price_tuples = read.csv("correct_price_tuples.csv", header = TRUE)
tab = table(prices_several_bills$bill_id)


# not working ... needs a little bit of work
for(i in 1:length(tab)){
  
  height_real_prices = (prices_several_bills$total_bottom - prices_several_bills$total_top)[prices_several_bills$id ==  names(tab)[i] & prices_several_bills$valid_amount == 1]
  height_false_prices = (prices_several_bills$total_bottom - prices_several_bills$total_top)[prices_several_bills$id ==  names(tab)[i] & prices_several_bills$valid_amount == 0]

  a = c(numeric(length(height_false_prices)), numeric(length(height_real_prices)) + 1)
  b = c(height_false_prices, height_real_prices)
  plot(cbind(a,b))

}


# Plotte alle Preise  (keine Unterscheidung zwischen den einzelnen Rechnungen)
# hist(height_real_prices,xlim=c(0, 0.03), ylim=c(0,30),breaks=10,col=rgb(1,1,0,0.7),main="",xlab="number")
# par(new=TRUE)
# hist(height_false_prices,xlim=c(0, 0.03), ylim=c(0,30),breaks=10,col=rgb(0,1,1,0.4),main="",xlab="",ylab="")


