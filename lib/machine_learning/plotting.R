
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
