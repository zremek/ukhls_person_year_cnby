# This script runs all other scripts to produce ukhls_CNBformat.sav and .dta
# files in your working directory. 

##### setup start #### 

# please note which data release version you want to use, as the directory
# structure and file paths differ between older and newer versions.
# until wave 1-11 release (10.5255/UKDA-SN-6614-17)
# data files were structured in wave specific sub-folders.
# from wave 1-12 release (10.5255/UKDA-SN-6614-18)
# data files are organised in study specific sub-folders.
#
# you need to manually set the path variable!
#
## for older versions, use:
# my_path_old <- "/a_directory_on_my_machine/UKDA-6614-spss/spss/spss24/"
#
# if you downloaded stata version,
# change path to ".../UKDA-6614-stata/stata/stata11_se/"
#
## for newer versions, use:
# my_path_new <- "/a_directory_on_my_machine/UKDA-6614-spss/spss/spss25/ukhls/"
#
# if you downloaded stata version,
# change path to ".../UKDA-6614-stata/stata/stata13_se/ukhls/"
# and use haven::read_stata() instead of haven::read_spss()


# Check and print the paths with error messages
if (!is.null(my_path_old) && !is.null(my_path_new)) {
  cat("Please provide only one path.\n")
} else if (is.null(my_path_old) && is.null(my_path_new)) {
  cat("You have not set the path.\n")
} else if (!is.null(my_path_old)) {
  cat("Your path to data is:", my_path_old, "\n")
} else if (!is.null(my_path_new)) {
  cat("Your path to data is:", my_path_new, "\n")
}

# Please supplement the first part '/a_directory_on_my_machine/'
# with an actual path to the folder. 
# There is no need to change the former part of the path. 

# additionally, you need to specify the maximum wave number included
# in the data release you are using. if you are using a data release
# that includes waves 1-11, enter the number 11 and assign it to the
# variable w_max. if you are using a data release that includes waves
# 1-13, enter the number 13. if you are not interested in certain waves
# included in the data release, filter them out after completing all
# the procedures needed to generate the harmonized cnb-y dataset. do
# not use the w_max variable as a filter at an early stage.

# w_max <- 'my_max_wave_in_the_data_release_i_use'

##### setup end ####

# If you provided the path to the folder containing UKHLS data
# and do not want to run scripts manually, 
# you may skip the rest of the reading and source this script. 

##

print(paste(Sys.time(), "[00 start]"))

# This script requires a couple of packages to run. 
# You can manually install them or otherwise run the commands: 

packages = c("tidyverse", "haven", "sjmisc", "sjlabelled", "devtools")

package_check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
    }
  }
)

not_on_cran <- "DIGCLASS"

if (!require(not_on_cran, character.only = TRUE)) {
  devtools::install_git("https://code.europa.eu/digclass/digclass.git")
}

print(paste(Sys.time(), "[00 done]"))

# The commands below run all other scripts in order to produce
# the output data file for you: 

source("01-load.R")
source("02-preparation.R")
source("03-save.R")


