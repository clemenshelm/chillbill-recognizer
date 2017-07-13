
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





## Distribution of heights ##
##############################

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
# -->  If the height is greater than the height of 0.75 quartil, we will give the attribute a 1




### Printing all errors ###
###########################
# We  need this only if we want to consider / output different types of error

# 
# cat("------------------------------------------------------------\n")
# cat("1: Overall recognition:", mean(p == answer_test), "\n")
# cat("2: Recognition rate of right values:", mean(p[answer_test == 1] == 1), "\n")
# cat("3: Recognition rate of the wrong values:", mean(p[answer_test == 0] == 0), "\n")
# cat("4: False Positive:", mean(answer_test[p == 1] == 0), " <-- \n")
# cat("5: Right Positive:", mean(answer_test[p == 1] == 1), "\n")
# cat("6. False Negative:", mean(answer_test[p == 0] == 1), "\n")
# cat("7: Right Negative:", mean(answer_test[p == 0] == 0), "\n")
# cat("------------------------------------------------------------\n\n")

# Description
# 1: How many of the overall predictions are right, higher is better
# 2: How many of the positive values are recognized correct, higher is better
# 3: How many of the negative values are recognized correct, higher is better
# 4: How many of the positive predictions are wrong, lower is better
# 5: How many of the positive predictions are real positive, higher is better
# 6: How many of the negative predictoins are wrong negative, lower is better 
# 7: How many of the negative predictoins are real negative, higher is better

# cat("Output of the false-positive Combinations:\n")
# # data_test[ , "valid_amount"] = answer_test
# print(data_test[answer_test == 0 & p == 1, ])

##################################

#### plot the character width in percentage of the bill width ####
prices_several_bills <- read.csv("csv/prices.csv", header = TRUE)
correct_price_tuples <- read.csv("csv/correct_price_tuples.csv", header = TRUE)

to_string_nchar <- function(x){
  nchar(toString(x))
}

price_list2 <- prices_several_bills %>%
  mutate(char_width = (right - left) / sapply(price_list$text, to_string_nchar))

# scale for plot (divide by max char_width per bill)
price_list2 <- price_list2 %>% group_by(bill_id) %>%
  mutate(char_width_s = char_width/ max(char_width), max_width = max(char_width))
price_list2[, "valid_amount"] <- 0
price_list2[price_list2$price_id %in% correct_price_tuples$total_id,  "valid_amount"] <-  1

ggplot(price_list2, aes(x = char_width_s)) + geom_dotplot(aes(color = factor(valid_amount))) + facet_wrap(~ bill_id)




# not done yet
# colour the true brutto values different to the other ones



#### plot page ratio of bill
prices_several_bills <- read.csv("csv/prices.csv", header = TRUE)
one_element_per_bill <- prices_several_bills %>%
  group_by(bill_id) %>%
  slice(1) %>%
  ungroup

one_element_per_bill <- one_element_per_bill %>% mutate(bill_ratio = bill_height / bill_width) %>% filter(bill_ratio > 1) 
ggplot(data = one_element_per_bill, aes(x = bill_ratio)) +
  geom_histogram() +
  geom_density(kernel = "gaussian") +
  geom_segment(aes(x = 297/210, y = 0, xend = 297/210, yend = 20))
