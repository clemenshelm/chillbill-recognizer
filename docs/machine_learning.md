# Machine Learning Documentation

## Description of the attributes
We generate the attributes (tuples) via the function `generate_tuples`.

|attribute | description |
| --- | --- |
| `bill_width`| bill width in px|
| `bill_height`| bill height in px|
| `total_id`|unique id of the total price|
| `total_text` |original text |
| `total_price`| total price in cents|
| `total_left` | location of the total price  in percentage|
| `total_right` | location of the total price  in percentage|
| `total_top` | location of the total price  in percentage|
| `total_bottom`| location of the total price  in percentage|
| `vat_id` |unique id of the vat |
| `vat_text` |original text |
| `vat_price`| vat price in cents |
| `vat_left` | location of the vat price  in percentage |
| `vat_right` | location of the vat price  in percentage |
| `vat_top` | location of the vat price  in percentage |
| `vat_bottom` | location of the vat price  in percentage |
| `total_price_s`| scaled total price = price divided by the highesst price on the bill |
| `vat_price_s` | scaled vat price = price divided by the highesst price on the bill |
| `rel_p` | proportion of `vat_price` to `total_price` |
| `common_width` | The common width of the possible `total_price` and the possible `vat_price`|
| `common_height`| The common height of the possible `total_price` and the possible `vat_price`|
| `common_width_s` | scaled common width = `common_width` divided by the largest `common_width` in this bill |
| `common_height_s` | scaled common height = `common_height` divided by the largest `common_height` in this bill |
| `total_price_order`| position of price entry compared to all prices in the bill |
| `total_price_uq`| 1 if price is in the upper quartil (25%) of all prices, 0 if not |
| `total_height`| height of the total price in percentage |
| `total_height_s`| scaled `total_height` |
| `total_height_uq` | 1 if the height of the total_price is in the upper quartil (25%) of all heights of that bill, 0 if not|
| `total_char_counter` | amount of characters in `total_text` |
| `total_char_width`| average width per character  |
| `total_char_width_s`| scaled `total_char_width` |
| `total_char_width_uq` | 1 if `total_char_width`  is in the upper quartil (25%) of all widths of all numbers, 0 if not |
|`valid_amount`| only needed for training the model. 1 if the combination is correct, 0 if not |


## Determine type of bill (format)
To improve the performance, we specify the type (format) of each bill, wheater
it is A4 or sales_check. For each type, we run a specific ML-model to find the
correct price combination.

Because of graphically analysis I came to the following conclusion about the
best features.

- The most important one is most likely the median of the char width,
  this is a representation of the font size.

- The text_box_width is only only important if the scan is a4 but the bill is
  a sales check and therefore the text_box_width is much smaller. We need to
  adjust the threshold for the boolean variable. For this we need more data.

- The text_box_ratio will most likely only be important if the bill height is
  very big (compared to the bill width). I will also create a boolean variable
  for this, but to calibrate the threshold we also need more data.




## Description of the procedure
In the long run there are several possibilities to optimize the result:

- Choose which attributes to use
- Choose optimal Parameters for C and gamma (via grid search)
- Choose different weights for the tuples (correct tuples should get a higher
  weight, otherwise they are underrepresented), this can also be seen as an
  optimization problem, the variable(s) to minimize are the errors
- With all the above given we generate the model - this is also an optimization
  problem but R takes care of this
- For some attributes (`total_height_uq`, `price_uq` ) we use the top 25% as
  a marker, this number must not be perfect, so we could also tune it looking
  at the error-distribution


## "ceteris paribus" vs. "all at once"
We have different possibilities to optimize the result. I assume that the
calculation will become very heavy if we try to optimize all at once. So my
recommendation is to optimize "ceteris paribus" only one at the time.

Because of my observations, I assume that the grid search will not have a huge
impact on the error distribution if we run it for every random sample again,
because the distribution of the cost and the gamma have a very strong tendency.
So to generate the error distribution from several given environments I
recommend to generate the distribution of the costs and gamma for the
H0 hypothesis and use one cost-gamma-combination for all the following
investigation. This will speed up the process immense.


In the Future it is easy to merge all optimization into one big problem that
runs a long time and give us the best result.


## Possible ways to speed up the process
- At the moment, we also generate some "useless" attributes, this just
  gives us the possibillity to easily recalculate some other attribtutes.
  They are:
  - `common_width`
  - `common_height`
  - `total_height`
  - `total_char_counter`
  - `total_char_width`
- group the code better
- we should generate `total_height_s` and `total_char_width_s` at the
  beginning, before making the possible combinations
- parallelize the calculations


## Grid search
The build in function `tune` for finding the best "hyper-parameters" (in our
case C and gamma) needs some adaptations to suits our needs. By default it
uses "cross validation" and produces for each combination 10 error outputs.
The error is measured by the total fit but we need the "wrong-positive".
Via `tune.control` we can change the error function so that it returns the
"wrong-positive"-error, but there is the possibility (the higher the less
data we use) of "NaN" results (see "Measuring the error" for more details).
So for each cost-gamma combination `tune` produces 10 (standard)
evaluations of errors. From each of these sets, we need only two numbers,
the average standard deviation. The problem is, that only one "NaN" entry
destroys the whole set for the combination of C and gamma, because `mean`
and `sd` can not handle `NaN`. So we have to adapt these function.
Therefore we use `na_omit_mean` and `na_omit_sd` in `tune.control`.


## Interpretation of the hyperparameters "cost" and "gamma"
https://chrisalbon.com/machine-learning/svc_parameters_using_rbf_kernel.html

## Use overfitting to our advantage
Because there are often similar bills we could use overfitting (specially a
high gamma) to our advantage. A high gamma creates some sort of "islands"
around the data points. If the data-tuples (of a bill) we want to classify
have the same structure as some data-tuples we used  to create the model, the
"island" around that specific point will likely contain the new data. This
gives us the possibility to make a very likely classification.

If these process do not return any true combination for a bill, we use another
model (with hyperparameters that do not overfitt).

Overall, we can create several steps (models) from "total overfit" to
"none overfitt".


## Error of first kind vs. error of second kind
The error we try to minimize in the first place is the "wrong-positive"
error. The problem is that we often get zero positive prediction. So from
all possible combinations (hyperparameters and attributes) with a low
"wrong-positive" error, we should choose the one with a high rate of
positive predictions.



## Measuring the error
There are several possibilities to measure errors.


1. Overall recognition - How many of the overall predictions are right,
   higher is better
2. Recognition rate of right values - How many of the positive values are
   recognized correct, higher is better
3. Recognition rate of the wrong values - How many of the negative values are
   recognized correct, higher is better
4. False Positive - How many of the positive predictions are wrong,
   lower is better
5. Right Positive - How many of the positive predictions are real positive, higher is better
6. False Negative - How many of the negative predictions are wrong negative, lower is better
7. Right Negative - How many of the negative predictions are real negative, higher is better

Of course some of them are unnecessary because we could calculate them from an other error but to give a better understanding we wrote them down anyway.

**Most important error: wrong positives**

It is possible to get NaN entries here!
When there is no positive prediction (all of the predictions are 0) then our measurements fails and we get a "NaN". The best solution is not to take them into consideration.




## Some important commands for the R-Code
**Show all manually installed packages in R**
```r
ip <- as.data.frame(installed.packages()[,c(1,3:4)])
rownames(ip) <- NULL
ip <- ip[is.na(ip$Priority),1:2,drop=FALSE]
print(ip, row.names=FALSE)
```

**Install R in Debian 8 (Jessie)**
```link
https://cran.r-project.org/bin/linux/debian/
http://www.jason-french.com/blog/2013/03/11/installing-r-in-linux/
```

add the cran link to sources.list to get R 3.4
```shell
RUN sh -c 'echo "deb http://cran.rstudio.com/bin/linux/debian jessie-cran34/" >> /etc/apt/sources.list'
```

add key, this is important to verify the new R version
```shell
RUN apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF'

RUN apt-get update && apt-get install -y \
  r-base \
  r-recommended
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
