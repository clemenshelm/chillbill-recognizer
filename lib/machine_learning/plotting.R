
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


heights_all = prices_several_bills$bottom - prices_several_bills$top
# answer =  numeric(length(heights_all))
answer = rnorm(n = length(heights_all),mean =0, sd = .1) # wrong 
answer[prices_several_bills$price_id %in% correct_price_tuples$total_id] = 1 #correct 
m = data.frame("bill_id" = prices_several_bills$bill_id, "heights" = heights_all, "answer" = answer)

for(i in 1:length(tab)){
  x = m[m$bill_id ==  names(tab)[i], "answer"]
  y = m[m$bill_id ==  names(tab)[i], "heights"]
  
  
  plot(main = names(tab)[i], x,y)
}

# If the height is 
################################
