source("machine_learning_lib.R") # loads function "generate_tuples(price_list)"
library(ggplot2)

# load data from several bills
prices_several_bills <- read.csv("csv/prices.csv", header = TRUE)
correct_price_tuples <- read.csv("csv/correct_price_tuples.csv", header = TRUE)

######################################
######    SVM - TYPE OF BILL    ######
######################################

calibration_data_format <-
  generate_calibration_data_format(prices_several_bills, correct_price_tuples)

# in this case we do not need to specify the tune function via tune.control
tuned <- tune( svm,
               train.x = calibration_data_format[ , c("char_width_med",
                                                      "char_width_med_b",
                                                      "text_box_width",
                                                      "text_box_width_b",
                                                      "text_box_ratio")],
               train.y = as.factor(calibration_data_format[ , "bill_format"]),
               kernel = "radial",
               type   = "C-classification",
               scale  = FALSE,
               ranges = list(
                 cost = 10 ^ (-2:2),
                 gamma = 10 ^ (-1:1)
               ),
               best.model = TRUE
)


# save model
saveRDS(tuned$best.model, 'svm-format-search.rds')


######################################
######           SVM            ######
######################################

calibration_data <- genearte_calibration_data_prices(prices_several_bills, correct_price_tuples)

# Print percentage of right combinations
cat("Amount of false and right combinations:",
    table(calibration_data$valid_amount),
    "<=>", table(calibration_data$valid_amount)[2] / nrow(calibration_data) * 100,
    "% right combinations%\n")


##### ALL POSSIBLE COMBINATIONS OF ATTRIBUTES #######
# 
# col_all = c("total_price_s", "vat_price_s", "rel_p", "price_order", "price_uq", "common_width", "common_height")
# 
# list_of_col = list()
# for( i in 1:length(col_all)){
#   list_of_col = append(list_of_col, as.list(as.data.frame(combn(col_all,i))))
# }
# #names(list_of_col) = NULL
# 
# # change "col" to EVERY possible combination
# for( i in 1:length(list_of_col)){
#   col = as.character(list_of_col[[i]])
# }
# 


#### choose which arguments to use in the SVM ####
col <- c("total_price_s",
         "vat_price_s",
         "rel_p",
         "common_width_s",
         "common_height_s",
         "total_price_order",
         "total_price_uq",
         "total_height_s",
         "total_height_uq",
         "total_char_width_s",
         "total_char_width_uq")




######       GRID-SEARCH FOR HYPERPARAMETERS (cost, gamma)       ######
cost_range <- 10 ^ (-2:2)
gamma_range <- 10 ^ (-1:1)
# cost_range <- 10 ^ (-3:7)
# gamma_range <- 10 ^ (-3:3)


# Grid search for the hyperparameters using ALL data
data_train <- calibration_data[, col]
answer_train <- calibration_data[, "valid_amount"]

# Detaild output
hyperparameters_detailed <-
  hyperparameters_grid_search(data_train = data_train,
                              answer_train = answer_train,
                              cost_range = cost_range,
                              gamma_range = gamma_range,
                              detailed.output = TRUE,
                              nruns = 10)

### GRAPHICAL ANALYSIS - HYPERPARAMETERS (cost, gamma) ###

# summarizes for each cost - gamma combination
cost_gamma_plot <- hyperparameters_detailed$standard_format %>%
  group_by(cost,gamma) %>%
  summarise(mean_wrong_positive = mean(wrong_positive, na.rm = TRUE),
            mean_wrong_negative = mean(wrong_negative, na.rm = TRUE),
            mean_w_p_n = mean_wrong_positive + mean_wrong_negative)


# plotting wrong positive as boxplots
dev.new()
hyperparameters_detailed$standard_format %>%
  mutate(cost_gamma = interaction(cost, gamma, sep = "-")) %>%
  ggplot(aes(y = wrong_positive, x = cost_gamma)) +
  geom_boxplot() +
  ggtitle(paste("Wrong-Positive - Best Hyperp.: Cost = ",
                hyperparameters_detailed$tuned$best.parameters$cost,
                ", gamma = ",
                hyperparameters_detailed$tuned$best.parameters$gamma ))

# plotting wrong negatives as boxplots
dev.new()
hyperparameters_detailed$standard_format %>%
  mutate(cost_gamma = interaction(cost, gamma, sep = "-")) %>%
  ggplot(aes(y = wrong_negative, x = cost_gamma)) +
  geom_boxplot() +
  ggtitle(paste("Wrong-Positive - Best Hyperp.: Cost = ",
                hyperparameters_detailed$tuned$best.parameters$cost,
                ", gamma = ",
                hyperparameters_detailed$tuned$best.parameters$gamma ))

# plot mean of wrong positive as raster-plot with contour
dev.new()
cost_gamma_plot %>%
  ggplot(aes(x = log10(cost), y = log10(gamma))) +
  geom_raster(aes(fill = mean_wrong_positive)) +
  geom_contour(aes(z = mean_wrong_positive))

# plot mean of wrong negative as raster-plot with contour
dev.new()
cost_gamma_plot %>%
  ggplot(aes(x = log10(cost), y = log10(gamma))) +
  geom_raster(aes(fill = mean_wrong_negative)) +
  geom_contour(aes(z = mean_wrong_negative))

#graphics.off()


######       ERROR DISTRIBUTION FOR COL        ######
# Define the hyperparameters
cost <- 1000
gamma <-  0.01

error_run1 <-
  generate_error_distribution(number_of_runs = 100,
                              col = col,
                              calibration_data = calibration_data,
                              cost = cost,
                              gamma = gamma)


#print error distributions
cat("Percentage of NaN results: ",
    sum(is.na(error_run1$error4)) / length(error_run1$error4) * 100, "%")
hist(error_run1$error4)
hist(error_run1$cost)
hist(error_run1$gamma)


# save Model 
# This will go to a new file "create_model.R"
# saveRDS(svmfit, 'modelfile.rds')
# cat("Saved model to svm_model.svm\n")
