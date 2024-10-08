# This script runs all other scripts to produce ukhls_CNBformat.sav file
# in your working directory. 

# This version requires UKHLS data from UKDA-6614-spss repository,
# waves from 1 to 13.

# Provide the path to the folder containing UKHLS data.
# For current version of the data release it looks like that:

# /a_directory_on_my_machine/UKDA-6614-spss/spss/spss25/ukhls/

# set it in the line below, and un-comment it: 

# my_path <- "/Users/remek/Code/UKDA-6614-spss/spss/spss25/ukhls/"

# Please supplement the first part '/a_directory_on_my_machine/'
# with an actual path to the folder. 
# There is no need to change the former part of the path. 

# If you provided the path to the folder containing UKHLS data
# in line 14 above and do not want to run scripts manually, 
# you may skip the rest of the reading and source this script. 

# This script requires a couple of packages to run. 
# You can manually install them or otherwise run the command: 

packages = c("tidyverse", "haven", "sjmisc", "sjlabelled")

package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
    }
  }
)

# The commands below run all other scripts in order to produce
# the output datafile for you: 

source("01-load.R")
source("02-preparation.R")
source("03-save.R")



