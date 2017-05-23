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


## Some important commands for the R-Code

### Save and load model (R)
save(mymodel, file='mymodel.rda')
load('mymodel.rda') # do not use some_name = load(..), load(..) uses the original name of the model 


### Save and load model (R) second (better) way:
saveRDS(model, 'modelfile.rds')
M <- readRDS('modelfile.rds')


**Set Working Directory**
setwd("~/Dokumente/ChillBill/r-chillbill")


**Load different R file** 
source("adding_attriutes.R")
Just runs this script. It has no extra workspace!!
It will run every time - not like require.


**Magick in R**
library(magick)
Needs two extra-installations apart from the installation in R:
apt-get install libcurl4-openssl-dev libmagick++-dev


**Use an RScript over the Command-line**
Command: 
Rscript --vanilla Name_of_the_RScript.R Inputparameter1 Inputparameter2

Example:
Rscript --vanilla use_model.R 24PC5D5oeL6fb8a5n.csv
Rscript --vanilla use_model.R 24PC5D5oeL6fb8a5n.csv


**Use Inputparameters in R:**
args = commandArgs(trailingOnly=TRUE)
numbers = as.numeric(args)  # Convert to numerical

**Measure time in R**
```r
start.time <- Sys.time()

# Some code

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
```




