
# Save and load model (R)
save(mymodel, file='mymodel.rda')
load('mymodel.rda') # do not use some_name = load(..), load(..) uses the original name of the model 


# Save and load model (R) second (better) way:
saveRDS(model, 'modelfile.rds')
M <- readRDS('modelfile.rds')


# Set Working Directory
setwd("~/Dokumente/ChillBill/r-chillbill")


# Load different R file 
source("adding_attriutes.R")
Just runs this script. It has no extra workspace!!
It will run every time - not like require.


# Magick in R
library(magick)
Needs two extra-installations apart from the installation in R:
apt-get install libcurl4-openssl-dev libmagick++-dev


# Use an RScript over the Command-line
Command: 
Rscript --vanilla Name_of_the_RScript.R Inputparameter1 Inputparameter2

Example:
Rscript --vanilla use_model.R 24PC5D5oeL6fb8a5n.csv
Rscript --vanilla use_model.R 24PC5D5oeL6fb8a5n.csv


## Use Inputparameters in R:
args = commandArgs(trailingOnly=TRUE)
numbers = as.numeric(args)  # Convert to numerical



