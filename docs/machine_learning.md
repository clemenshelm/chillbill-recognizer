# preselection of data
I think we should again include the preselection so that we use only data where vat-price <= 0.3*price or at least vat-price <= price


# Save and load model (R)
save(mymodel, file='mymodel.rda')
load('mymodel.rda')


# Set Working Directory
setwd("~/Dokumente/ChillBill/r-chillbill")


# Load different R file 
source("adding_attriutes.R")
Es wird einfach dieser Teil des Skriptes ausgeführt
Wenn als Funktion / Modul --> muss Name "data" nicht mehr ident sein
laden über source("adding_attriutes.R") (wird jedes mal ausgeführt nicht wie require)


# Magick in R
library(magick)
Ich musste 2 pakete installieren (apt-get install libcurl4-openssl-dev libmagick++-dev) 

# Aufruf eines R-Scripts über die Command-line
in R:
args = commandArgs(trailingOnly=TRUE)
numbers = as.numeric(args)  # Convertierung in numerische Zahlen

Aufruf: 
Rscript --vanilla Name_des_R_Scripts.R Inputparameter1 Inputparameter2
