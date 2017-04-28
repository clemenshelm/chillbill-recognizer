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
