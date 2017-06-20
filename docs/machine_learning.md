# Machine Learning Documentation

## Description of the procedure
In the long run there are several possibilities to optimize the result:

- Choose which attributes to use
- Choose optimal Parameters for C and gamma (via grid search)
- Choose different weights for the tuples (correct tuples should get a higher weight, otherwise they are underrepresented), this can also be seen as an optimization problem, the variable(s) to minimize are the errors
- With all the above given we generate the model - this is also an optimization problem but R takes care of this
- For some attributes (`total_height_uq`, `price_uq` ) we use the top 25% as a marker, this number must not be perfect, so we could also tune it looking at the error-distribution


## "ceteris paribus" vs. "all at once"
We have different possibilities to optimize the result. I assume that the calculation will become very heavy if we try to optimize all at once. So my recommendation is to optimize "ceteris paribus" only one at the time. 

Because of my observations, I assume that the grid search will not have a huge impact on the error distribution if we run it for every random sample again, because the distribution of the cost and the gamma have a very strong tendency. So to generate the error distribution from several given environments I recommend to generate the distribution of the costs and gamma for the H0 hypothesis and use one cost-gamma-combination for all the following investigation. This will speed up the process immense.
 

In the Future it is easy to merge all optimization into one big problem that runs a long time and give us the best result.



## Grid search
The build in function `tune` for finding the best "hyper-parameters" (in our case C and gamma) needs some adaptations to suits our needs. By default it uses "cross validation" and produces for each combination 10 error outputs. The error is measured by the total fit but we need the "wrong-positive". Via `tune.control` we can change the error function so that it returns the "wrong-positive"-error, but there is the possibility (the higher the less data we use) of "NaN" results (see "Measuring the error" for more details). So for each cost-gamma combination `tune` produces 10 (standard) evaluations of errors. From each of these sets, we need only two numbers, the average standard deviation. The problem is, that only one "NaN" entry destroys the whole set for the combination of C and gamma, because `mean` and `sd` can not handle `NaN`. So we have to adapt these function. Therefore we use `na_omit_mean` and `na_omit_sd` in `tune.control`.


## Interpretation of the hyperparameters "cost" and "gamma"
https://chrisalbon.com/machine-learning/svc_parameters_using_rbf_kernel.html



## Error of first kind vs. error of second kind
The error we try to minimize in the first place is the "wrong-positive" error. The problem is that we often get zero positive prediction. So from all possible combinations (hyperparameters and attributes) with a low "wrong-positive" error, we should choose the one with a high rate of positive predictions. 


## Description of the attributes 
We generate the attributes via the function `generate_tuples`.

- `rel_p`           proportion of `vat_price` to `total_price`
- `price_order`     position of price entry compared to all prices in the bill
- `price_uq`        1 if price is in the upper quartil (25%), 0 if not
- `total_price_s`   Scaled total_price
- `vat_price_s`     Scaled `vat_price`
- `common_width`    The common width of the possible `total_price` and the possible `vat_price`
- `common_height`   The common height of the possible `total_price` and the possible `vat_price`
- `group`           colors for plots
- `total_height_uq` 1 if the height of the total_price is in the upper quartil (25%), 0 if not


## Measuring the error
There are several possibilities to measure errors.


1. Overall recognition - How many of the overall predictions are right, higher is better
2. Recognition rate of right values - How many of the positive values are recognized correct, higher is better
3. Recognition rate of the wrong values - How many of the negative values are recognized correct, higher is better
4. False Positive - How many of the positive predictions are wrong, lower is better
5. Right Positive - How many of the positive predictions are real positive, higher is better
6. False Negative - How many of the negative predictions are wrong negative, lower is better 
7. Right Negative - How many of the negative predictions are real negative, higher is better

Of course some of them are unnecessary because we could calculate them from an other error but to give a better understanding we wrote them down anyway.

**Most important error: wrong positives**

It is possible to get NaN entries here!
When there is no positive prediction (all of the predictions are 0) then our measurements fails and we get a "NaN". The best solution is not to take them into consideration.




## Some important commands for the R-Code
**Show all manually installed packages in R**
ip <- as.data.frame(installed.packages()[,c(1,3:4)])
rownames(ip) <- NULL
ip <- ip[is.na(ip$Priority),1:2,drop=FALSE]
print(ip, row.names=FALSE)


**Install R in Debian 8 (Jessie)**
https://cran.r-project.org/bin/linux/debian/
http://www.jason-french.com/blog/2013/03/11/installing-r-in-linux/

I was not able to use the GPG key. Therefore I just used:
```shell
sh -c 'echo "deb http://cran.rstudio.com/bin/linux/debian jessie-cran34/" >> /etc/apt/sources.list'
apt-get update
apt-get install r-base r-base-dev
```

**Linter in R**

IMPORTANT: before installing the package within R via `install.packages("lintr")` in *Ubuntu* you need to install the following packages:
```shell
sudo apt-get install libcurl4-openssl-dev libssl-dev
```
To use the linter, you have to load the package within the R-console via `library(lintr)` and then use `lint("Name_of_R_file_to_lint.R")`. 


**Save and load model (R)**
```r
save(mymodel, file='mymodel.rda')
load('mymodel.rda') # do not use some_name = load(..), load(..) uses the original name of the model 
```

**Save and load model (R) second (better) way:**
```r
saveRDS(model, 'modelfile.rds')
M = readRDS('modelfile.rds')
```

**Set Working Directory**
```r
setwd("~/Dokumente/ChillBill/r-chillbill")
``` 

**Load different R file** 
```r
source("adding_attributes.R")
# Just runs this script. It has no extra workspace!!
# It will run every time - not like require.
``` 
**Magick in R**
```r
library(magick)
``` 

Needs two extra-installations apart from the installation in R:

```sh
apt-get install libcurl4-openssl-dev libmagick++-dev
```

**Use an RScript over the Command-line**

*Command:*
```bash
Rscript --vanilla Name_of_the_RScript.R Inputparameter1 Inputparameter2
```

*Example:*
```bash
Rscript --vanilla use_model.R 24PC5D5oeL6fb8a5n.csv
Rscript --vanilla use_model.R 24PC5D5oeL6fb8a5n.csv
```

**Use Inputparameters in R:**
```r
args = commandArgs(trailingOnly=TRUE)
numbers = as.numeric(args)  # Convert to numerical
```

**Measure time in R**
```r
start.time = Sys.time()

# Some code

end.time = Sys.time()
time.taken = end.time - start.time
time.taken
```


**choose which arguments are for the SVM**
```r
col = c("total_price_s", "vat_price_s", "rel_p", "price_order", "price_uq", "common_width", "common_height", "height_uq")
#col = names(calibration_data) # all
#col = names(calibration_data)[!names(calibration_data) %in% c("id","valid_amount")] # all but..
```

**Save all attributes into one string**
```r
name_of_model = paste(col, sep="", collapse="/")
```


**tune**

The `tune` function already calculates the distribution (sort of) of the error and decides because of this.

For 8 x 3 = 24 possible combinations it calculated 240 times the error, so 10 times per combination. With the object `tune.control` we are able to specify the error to decide on (we want the wrong-positives to be minimized).

For the cross-validation the `tune` function takes 10% of the data to validate the error by default.






