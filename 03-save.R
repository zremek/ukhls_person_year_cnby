library(haven)

# if you manually run script by script,
# you saved data from 02-preparation.R and restarted R session, now run:
# load("ukhls_CNBformat.RData") 

haven::write_sav(data = ukhls_CNBformat, path = "ukhls_CNBformat.sav")
haven::write_dta(data = ukhls_CNBformat, path = "ukhls_CNBformat.dta") # przetestować dla Kasi 

print(paste(Sys.time(), "[03 done and data saved]"))
