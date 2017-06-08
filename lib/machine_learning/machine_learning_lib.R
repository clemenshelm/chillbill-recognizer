# The function "generate_tuples" gets prices and returns possible combinations of tuples. It also adds attributes and erases NaN entries


# Load example bill for debugging / creating new attributes:
# price_list = read.csv("25KA7rWWmhStXDEsb.csv", header=TRUE)
# price_list = read.csv("26joYiARG5L5SmfxM.csv", header=TRUE)
# price_list = read.csv("24PC5D5oeL6fb8a5n.csv", header=TRUE)

# calibration_data = read.csv("calibration_data.csv", header = TRUE)[ , -1]
# data_train = read.csv("data_train.csv", header = TRUE)[ , -1]
# answer_train = read.csv("answer_train.csv", header = TRUE)[ , -1]




generate_tuples <- function(price_list){
  combinations = expand.grid(c(1:nrow(price_list)), c(1:nrow(price_list)))
  part1 = price_list[ combinations$Var1, c("bill_id", "price_id", "text", "price_cents", "left", "right", "top", "bottom")]
  part2 = price_list[ combinations$Var2, c("price_id", "text", "price_cents", "left", "right", "top", "bottom")]
  
  # rename columns
  colnames(part1)<- c("bill_id", "total_id", "total_text", "total_price", "total_left", "total_right", "total_top", "total_bottom")
  colnames(part2)<- c("vat_id", "vat_text", "vat_price", "vat_left", "vat_right", "vat_top", "vat_bottom")
  tuples = data.frame(part1,part2)
  
  # only use specific combinations
  data = tuples[tuples[ , "vat_price"] <= 0.3 * tuples[ , "total_price"] & tuples[ , "total_price"] > 0,  ]
  
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
  data[ ,"price_uq"] = as.numeric(data$total_price > quantil_limit)
  
  # creating "total_height_uq"
  total_height = price_list$bottom - price_list$top
  height_uq = quantile(total_height, 0.75)
  data[ ,"height_uq"] =  as.numeric((data$total_bottom - data$total_top)  >= height_uq)
  
  # Checking of NaN entries
  tmp = sum(is.na(data))
  # cat("After adding Attributes there are", tmp , "NaN entries\n" )
  if(tmp != 0){data[is.na(data)] = 0 }  # sets NaN values to 0
  
  return(data)
}




# Error function for the tune function, we want to minimize the wrong positive error
# Consider that this function can return NaN entries. See the documentation for further information.
error_function = function(true_values, predictions){
  return(mean(true_values[predictions == 1] == 0))
}



# Grid-search for the best paramters, kernel="radial" ... RBF, returns a data.frame which includes the parameters
parameters_grid_search = function(data_train, answer_train){
  
  tune_control = tune.control(error.fun = error_function)
  
  tuned = tune( svm, 
                train.x = data_train, 
                train.y = answer_train,
                kernel = "radial",
                type   = "C-classification",
                scale  = FALSE,
                ranges = list(
                  cost = 10^(-1:6),
                  gamma = 10^(-1:1)
                ),
                tunecontrol = tune_control
  )
  
  # #246
  # We must rethink the search for the optimal hyperparameters (cost, gamma) because the tune function already calculates the distribution.
  # Now we calculate the distribution of the optimal parameter searched through the distribution of the error?? 
  # The standard tund function calculates the "wrong" error, but I fixed that already but this needs further attention.
  # There are NaN entries in the output of tune!! , if for a combination some of the Bootstraps are NaN the the mean / median is also NaN ??


  
  return(tuned$best.parameters)
}



generate_parameters_distribution = function(number_of_runs = 20, col, calibration_data ){
  output = data.frame()
  
  number_of_tuples = nrow(calibration_data)
  
  for(iteration in 1:number_of_runs){
    # Bootstrapping the data (and answer)
    selection = sample(number_of_tuples, number_of_tuples, replace = TRUE)
    data_train = calibration_data[selection,col] # there is NO data_test
    answer_train = as.factor(calibration_data[selection,"valid_amount"])
    
    best_parameters = parameters_grid_search(data_train, answer_train)
    
    output = rbind(output, best_parameters)
    cat("Progress: ", iteration/number_of_runs, "\n")
  }
  
  return(output)
}





#To get a distribution of the error we run each combination several times (number_of_runs times)
generate_error_distribution = function(number_of_runs, col, calibration_data, cost = NULL, gamma = NULL){
  
  output_error4 = numeric(number_of_runs)
  output_cost = numeric(number_of_runs)
  output_gamma = numeric(number_of_runs)
  
  number_of_tuples = nrow(calibration_data)
  
  
  for(iteration in 1:number_of_runs){
    
    selection = sample(number_of_tuples, round(number_of_tuples * 0.7)) 
    # pulls approx. 70% random tuples for training, the remaining 30% are for testing the model
    
    # build training values and answers (converted to factor)
    data_train = calibration_data[selection,col]
    data_test = calibration_data[-selection,col]
    answer_train = as.factor(calibration_data[selection,"valid_amount"])
    answer_test = as.factor(calibration_data[-selection,"valid_amount"])
    
    # Gridsearch for the best parameters
    best_parameters = parameters_grid_search(data_train, answer_train)
    
    # create the model with the best cost and gamma parameters
    svmfit = svm( x = data_train, 
                  y = answer_train, 
                  kernel ="radial", 
                  cost = best_parameters$cost, 
                  gamma= best_parameters$gamma, 
                  scale = FALSE, 
                  type = "C-classification")
    
    # prediction
    p = predict(svmfit, data_test, type = "C-classification")
    
    
    # Save to output-vectors
    output_error4[iteration] = mean(answer_test[p == 1] == 0)
    output_cost[iteration] = best_parameters$cost
    output_gamma[iteration] = best_parameters$gamma
    
    cat("Progress: ", iteration/number_of_runs, "\n")
  }
  
  return(list(error4 = output_error4, 
              cost = output_cost, 
              gamma = output_gamma  )
         )
}





