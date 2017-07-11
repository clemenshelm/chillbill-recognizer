# The function "generate_tuples" gets prices and returns possible combinations of tuples. 
# It also adds attributes and erases NaN entries


# Load example bill for debugging / creating new attributes:
# price_list = read.csv("csv/25KA7rWWmhStXDEsb.csv", header=TRUE)
# price_list = read.csv("csv/26joYiARG5L5SmfxM.csv", header=TRUE)
# price_list = read.csv("csv/24PC5D5oeL6fb8a5n.csv", header=TRUE)
# 
# testdata for grid search
# calibration_data = read.csv("calibration_data.csv", header = TRUE)[ , -1]
# data_train = read.csv("data_train.csv", header = TRUE)[ , -1]
# answer_train = read.csv("answer_train.csv", header = TRUE)[ , -1]
# cost_range = 10^(-1:6); gamma_range = 10^(-1:1); detailed.output = TRUE; nruns = 10

# options(scipen = -10)
library(e1071)
library(dplyr)
library(data.table)

generate_tuples <- function(price_list){
  combinations <- expand.grid(total = c(1:nrow(price_list)),
                              vat = c(1:nrow(price_list)))

  data <- cbind(
    price_list %>% slice(combinations$total) %>% select("bill_id" = bill_id,
                                                        "total_id" = price_id,
                                                        "total_text" = text,
                                                        "total_price" = price_cents,
                                                        "total_left" = left,
                                                        "total_right" = right,
                                                        "total_top" = top,
                                                        "total_bottom" = bottom),

    price_list %>% slice(combinations$vat) %>% select("vat_id" = price_id,
                                                      "vat_text" = text,
                                                      "vat_price" = price_cents,
                                                      "vat_left" = left,
                                                      "vat_right" = right,
                                                      "vat_top" = top,
                                                      "vat_bottom" = bottom)
  )

  # only use specific combinations
  data <- data %>% filter(vat_price <= 0.3 * total_price, total_price > 0)

  # scaling prices -> add "total_price_s" and "vat_price_s", creating "rel_p"
  max_price <- max(price_list$price_cents)
  data <- data %>% mutate(total_price_s = total_price / max_price,
                          vat_price_s = vat_price / max_price,
                          rel_p = vat_price / total_price)

  # adding common width and common height
  data <- data %>% rowwise() %>%
    mutate(common_width = max(total_left, total_right, vat_left, vat_right) -
                          min(total_left, total_right, vat_left, vat_right),
           common_height = max(total_top, total_bottom, vat_top, vat_bottom) -
                           min(total_top, total_bottom, vat_top, vat_bottom))

  # creating "price_order"
  # It is very likely that "price_order" do not contain low values, because we
  # do not use all possible tuples
  prices_red_sort <- unique(sort(price_list$price_cents))  # deleted all repeated elements
  data <- data %>%
    mutate(price_order = match(total_price, prices_red_sort) / length(prices_red_sort))

  # creating "price_uq"
  quantil_limit <- quantile(price_list$price_cents, 0.75)
  data <- data %>%
    mutate(price_uq = as.numeric(total_price > quantil_limit))

  # creating "total_height_uq"
  height_uq <- quantile(price_list$bottom - price_list$top, 0.75)
  data <- data %>%
    mutate(height_uq = as.numeric( (total_bottom - total_top)  >= height_uq))

  # creating "avg_height"

  # Checking of NaN entries
  tmp <- sum(is.na(data))
  # cat("After adding Attributes there are", tmp , "NaN entries\n" )
  if (tmp != 0){
    data[is.na(data)] <- 0
  }

  return(data)
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
                wrong_negative = matrix_wrong_negative))
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
