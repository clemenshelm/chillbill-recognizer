# The function "generate_tuples_prices" gets prices and returns possible combinations of tuples. 
# It also adds attributes and erases NaN entries


# Load example bill for debugging / creating new attributes:
# price_list = read.csv("csv/2D7BuHc3f8wAmb4y8.csv", header=TRUE)
# price_list = read.csv("csv/5RRtGNwYGPvBsLzZj.csv", header=TRUE)
# price_list = read.csv("csv/8Rn375famrhC6b3x7.csv", header=TRUE)
# price_list = read.csv("csv/a8kRyPYTHrov5nTGC.csv", header=TRUE) # added text_box_attributes
# price_list = read.csv("csv/9DeNzw5KD2bCFCis9.csv", header=TRUE) # problem
# price_list = read.csv("csv/2CfCKenByph4Ht8EE.csv", header=TRUE) # problem with total_width_s

# add fake text_box dimensions to all bills
# prices_several_bills$text_box_left <- min(prices_several_bills$left)
# prices_several_bills$text_box_right <- max(prices_several_bills$right)
# prices_several_bills$text_box_top <- min(prices_several_bills$top)
# prices_several_bills$text_box_bottom <- max(prices_several_bills$bottom)

# add fake bill_format to all bills
# correct_price_tuples$bill_format <- "a4"
# correct_price_tuples[c(1, 5, 6, 8, 30), "bill_format"] <- "sales_check"



# testdata for grid search
# calibration_data = read.csv("calibration_data.csv", header = TRUE)[ , -1]
# data_train = read.csv("data_train.csv", header = TRUE)[ , -1]
# answer_train = read.csv("answer_train.csv", header = TRUE)[ , -1]
# cost_range = 10^(-1:6); gamma_range = 10^(-1:1); detailed.output = TRUE; nruns = 10

# options(scipen = -10)
library(e1071)
library(dplyr)
library(data.table)

recalculate_positions <- function(price_list){
  horizontal_scaling <- price_list %>%
    slice(1) %>%
    transmute( ( 1 - text_box_left ) / (text_box_right - text_box_left) ) %>%
    as.numeric()

  vertical_scaling <- price_list %>%
    slice(1) %>%
    transmute( ( 1 - text_box_top ) / (text_box_bottom - text_box_top) ) %>%
    as.numeric()

  return(
    price_list %>% mutate(left = ( left - text_box_left ) * horizontal_scaling, 
                          right = ( right - text_box_left ) * horizontal_scaling, 
                          top = ( top - text_box_top ) * vertical_scaling, 
                          bottom = ( bottom - text_box_top ) * vertical_scaling)
  )
}


generate_tuples_prices <- function(price_list){
  # price_list <- recalculate_positions(price_list)
  
  # Checking of NaN entries in price_list
  if (sum(is.na(price_list)) != 0){
    cat("There are NaN entries in the price list of bill ", toString(price_list$bill_id[1]), "\n")
    return(NULL)
  }

  combinations <- expand.grid(total = c(1:nrow(price_list)),
                              vat = c(1:nrow(price_list)))

  data <- cbind(
    price_list %>%
      slice(combinations$total) %>%
      select("bill_id" = bill_id,
             "bill_width" = bill_width,
             "bill_height" = bill_height,
             "total_id" = price_id,
             "total_text" = text,
             "total_price" = price_cents,
             "total_left" = left,
             "total_right" = right,
             "total_top" = top,
             "total_bottom" = bottom),

    price_list %>%
      slice(combinations$vat) %>%
      select("vat_id" = price_id,
             "vat_text" = text,
             "vat_price" = price_cents,
             "vat_left" = left,
             "vat_right" = right,
             "vat_top" = top,
             "vat_bottom" = bottom)
  )

  # only use specific combinations
  data <- data %>%
    filter(vat_price <= 0.3 * total_price, total_price > 0, vat_price >= 0)

  # creating "total_price_s" and "vat_price_s", creating "rel_p"
  max_price <- max(price_list$price_cents)
  data <- data %>%
    mutate(total_price_s = total_price / max_price,
                          vat_price_s = vat_price / max_price,
                          rel_p = vat_price / total_price)

  # creating "common_width", "common_height", "common_width_s", "common_height_s"
  data <- data %>%
    rowwise() %>%
    mutate(common_width = max(total_left, total_right, vat_left, vat_right) -
                          min(total_left, total_right, vat_left, vat_right),
           common_height = max(total_top, total_bottom, vat_top, vat_bottom) -
                           min(total_top, total_bottom, vat_top, vat_bottom))

  common_width_max <- max(data$common_width)
  common_height_max <- max(data$common_height)

  data <- data %>%
    mutate(common_width_s = common_width / common_width_max,
           common_height_s = common_height / common_height_max)

  # creating "total_price_order"
  # It is very likely that "price_order" do not contain low values, because we
  # do not use all possible tuples
  prices_red_sort <- unique(sort(price_list$price_cents))  # deleted all repeated elements
  data <- data %>%
    mutate(total_price_order = match(total_price, prices_red_sort) / length(prices_red_sort))

  # creating "total_price_uq"
  quantil_limit <- quantile(price_list$price_cents, 0.75)
  data <- data %>%
    mutate(total_price_uq = as.numeric(total_price >= quantil_limit))

  # creating "total_height", "total_height_s", "total_height_uq"
  height_max <- max(price_list$bottom - price_list$top)
  height_uq <- quantile(price_list$bottom - price_list$top, 0.75)
  data <- data %>%
    mutate(total_height = total_bottom - total_top,
           total_height_s = (total_bottom - total_top) / height_max,
           total_height_uq = as.numeric( (total_bottom - total_top)  >= height_uq))

  # creating "total_char_counter", "total_char_width", "total_char_width_s", "total_char_width_uq"
  prices_widths <- price_list %>%
    rowwise() %>%
    mutate(char_width = (right - left) / nchar(toString(text))) %>%
    select(char_width)

  width_max <- max(prices_widths$char_width)
  width_uq <- quantile(prices_widths$char_width, 0.75)

  data <- data %>%
    rowwise() %>%
    mutate(total_char_counter = nchar(toString(total_text)),
           total_char_width = (total_right - total_left) / total_char_counter,
           total_char_width_s = total_char_width / width_max,
           total_char_width_uq = as.numeric(total_char_width >= width_uq))

  # Checking of NaN entries
  tmp <- sum(is.na(data))
  # cat("After adding Attributes there are", tmp , "NaN entries\n" )
  if (tmp != 0){
    data[is.na(data)] <- 0
  }

  return(data)
}


genearte_calibration_data_prices <- function(prices_several_bills, correct_price_tuples){
  # generate tuples and add attributes for several bills
  tab <- table(prices_several_bills$bill_id)
  calibration_data <-
    generate_tuples_prices(prices_several_bills[prices_several_bills$bill_id == names(tab)[1], ])
  for (i in 2:length(tab)){
    # cat("Bill #", i, "; Bill id:", names(tab)[i],"\n")
    calibration_data <-
      rbind(calibration_data,
            generate_tuples_prices(
              prices_several_bills[prices_several_bills$bill_id == names(tab)[i], ]))
  }

  # adding correct answer in "valid_amount"
  calibration_data[, "valid_amount"] <- 0
  calibration_data[calibration_data$total_id %in% correct_price_tuples$total_id &
                     calibration_data$vat_id %in% correct_price_tuples$vat_id,  "valid_amount"] <- 1
  # calibration_data$valid_amount = as.factor(calibration_data$valid_amount) #convert to factor

  # Change Row names to 1, 2, 3, ...
  rownames(calibration_data) <- NULL

  return(calibration_data)
}


generate_tuples_format <- function(price_list){
  # returns one line of attributes
  char_width_med <- price_list %>%
    group_by(price_id) %>%
    mutate(tmp_r_l = right - left,
           tmp_nchar = nchar(toString(text)),
           char_width = (right - left) /
             ( nchar(toString(text)) * (text_box_right - text_box_left) ) ) %>%
    ungroup() %>%
    summarise(char_width_med = median(char_width))

  text_box_width <- price_list %>%
    slice(1) %>%
    transmute(text_box_width = text_box_right - text_box_left)

  text_box_ratio <- price_list %>%
    slice(1) %>%
    transmute(text_box_ratio = ( (text_box_right - text_box_left) * bill_width ) /
                ( (text_box_bottom - text_box_top) * bill_height) )

  return(
    data.frame(bill_id =  toString(price_list[1, "bill_id"]),
               char_width_med = char_width_med,
               char_width_med_b = as.numeric(char_width_med > 0.018), # analyse graphically
               text_box_width = text_box_width,
               text_box_width_b = as.numeric(text_box_width < 0.5), # analyse graphically
               text_box_ratio = text_box_ratio,
               text_box_ratio_b = as.numeric(text_box_ratio < 0.4)) # analyse graphically
  )
}


generate_calibration_data_format <- function(prices_several_bills, correct_price_tuples){
  bill_ids <- prices_several_bills %>% select(bill_id) %>% distinct() %>% lapply(as.character)

  calibration_data <- NULL
  for( i in bill_ids$bill_id){
    calibration_data <- rbind(calibration_data,
                              cbind(prices_several_bills %>%
                                      filter(bill_id == i) %>%
                                      generate_tuples_format(),
                                    correct_tye = correct_price_tuples %>%
                                      filter(bill_id == i) %>%
                                      select(bill_format)
                                    )
                              )
  }

  return(calibration_data)
}


# Consider that this function can return NaN entries (see  documentation)
error_wrong_positive <- function(true_values, predictions)
  mean(true_values[predictions == 1] == 0)

error_wrong_negative <- function(true_values, predictions)
  mean(predictions[true_values == 1] == 0)

na_omit_mean <- function(x)
  mean(na.omit(x))

na_omit_sd <- function(x)
  sd(na.omit(x))

custom_error_function <- function(true_values, predictions)
  error_wrong_positive(true_values, predictions)

# Grid-search for the best hyperparamters, kernel="radial" ... RBF, 
# returns a data.frame which includes the parameters or a list including every error evaluation
hyperparameters_grid_search <- function(data_train, answer_train, cost_range = 10 ^ (-1:6),
                            gamma_range = 10 ^ (-1:1), detailed.output = FALSE, nruns = 10) {
  if (detailed.output) {
    # global variables to get the errors from each iteration and not just the mean
    glob_counter <- 1
    glob_wrong_positive <- numeric(length(cost_range) * length(gamma_range) * nruns)
    glob_wrong_negative <- numeric(length(cost_range) * length(gamma_range) * nruns)

    custom_error_function <- function(true_values, predictions){
      glob_wrong_positive[glob_counter] <<- error_wrong_positive(true_values, predictions)
      glob_wrong_negative[glob_counter] <<- error_wrong_negative(true_values, predictions)
      glob_counter <<- glob_counter + 1
      return(error_wrong_positive(true_values, predictions))
    }
  }

  # special settings for tune
  tune_control <- tune.control(error.fun = custom_error_function,
                              performances = TRUE,
                              sampling.aggregate = na_omit_mean,
                              sampling.dispersion = na_omit_sd,
                              cross = nruns)

  tuned <- tune( svm,
                train.x = data_train,
                train.y = answer_train,
                kernel = "radial",
                type   = "C-classification",
                scale  = FALSE,
                ranges = list(
                  cost = cost_range,
                  gamma = gamma_range
                ),
                tunecontrol = tune_control
  )

  if (detailed.output){
    names_c_g <- apply(tuned$performances[, 1:2], 1,
        function(x) paste("c = ", x[1], ", g = ", x[2]))
    matrix_wrong_positive <- matrix(data = glob_wrong_positive,
        nrow = length(cost_range) * length(gamma_range), byrow = TRUE)
    matrix_wrong_negative <- matrix(data = glob_wrong_negative,
        nrow = length(cost_range) * length(gamma_range), byrow = TRUE)
    row.names(matrix_wrong_positive) <- names_c_g
    row.names(matrix_wrong_negative) <- names_c_g

    return(list(tuned = tuned,
                wrong_positive = matrix_wrong_positive,
                wrong_negative = matrix_wrong_negative,
                standard_format = data.frame(cost = rep(tuned$performances$cost, each = nruns),
                                             gamma = rep(tuned$performances$gamma, each = nruns),
                                             wrong_positive = glob_wrong_positive,
                                             wrong_negative = glob_wrong_negative)))
    }   else {
    return(tuned$best.parameters)
  }
}





# To get a distribution of the error for a specific combination of attributes
# we run each combination several times (number_of_runs times)
generate_error_distribution <-
  function(number_of_runs, col, calibration_data, cost = NULL, gamma = NULL){
  output_error4 <- numeric(number_of_runs)
  output_cost <- numeric(number_of_runs)
  output_gamma <- numeric(number_of_runs)
  number_of_tuples <- nrow(calibration_data)

  for (iteration in 1:number_of_runs){
    selection <- sample(number_of_tuples, round(number_of_tuples * 0.7))
    # pulls approx. 70% random tuples for training, the remaining 30% are for testing the model

    # build training values and answers (converted to factor)
    data_train <- calibration_data[selection, col]
    data_test <- calibration_data[-selection, col]
    answer_train <- as.factor(calibration_data[selection, "valid_amount"])
    answer_test <- as.factor(calibration_data[-selection, "valid_amount"])

    # Gridsearch for the best parameters if not specified
    if (is.null(cost) | is.null(gamma)){
      best_parameters <- hyperparameters_grid_search(data_train, answer_train)
      cost <- best_parameters$cost
      gamma <- best_parameters$gamma
    }

    # create the model with the best cost and gamma parameters
    svmfit <- svm( x = data_train,
                  y = answer_train,
                  kernel = "radial",
                  cost = cost,
                  gamma = gamma,
                  scale = FALSE,
                  type = "C-classification")

    # prediction
    p <- predict(svmfit, data_test, type = "C-classification")

    # Save to output-vectors
    output_error4[iteration] <- mean(answer_test[p == 1] == 0)
    output_cost[iteration] <- cost
    output_gamma[iteration] <- gamma
    #cat("Progress: ", iteration/number_of_runs, "\n")
  }

  return(list(error4 = output_error4,
              cost = output_cost,
              gamma = output_gamma  )
         )
  }
