library(tidyverse)
library(haven)
library(sjmisc)

# if you manually run script by script,
# and have not set your path to data folder
# in script 00-run-all.R
# do it below

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

my_path_old <-
  "/Users/remek/Code/ukhls-bhps-career-outline-working-paper/UKDA-6614-spss/spss/spss25/" # 1-10
my_path_new <-
  "/Users/remek/Code/UKDA-6614-spss/spss/spss25/ukhls/"    # 1-13

# additionally, you need to specify the maximum wave number included
# in the data release you are using. if you are using a data release
# that includes waves 1-11, enter the number 11 and assign it to the
# variable w_max. if you are using a data release that includes waves
# 1-13, enter the number 13. if you are not interested in certain waves
# included in the data release, filter them out after completing all
# the procedures needed to generate the harmonized cnb-y dataset. do
# not use the w_max variable as a filter at an early stage.

w_max <- 13




# select variables ####

ukhls_variables_to_select <- c(
  "age_dv",
  "doby_dv",
  "sex_dv",
  "urban_dv",
  "gor_dv",
  "country",
  "marstat_dv",
  "mastat_dv",
  "nchild_dv",
  "ndepchl_dv",
  "intdaty_dv",
  "intdatm_dv",
  "intdatd_dv", 
  "paygu_dv",
  "seearngrs_dv",
  "paynu_dv",
  "seearnnet_dv",
  "paygu_if",
  "paynu_if",
  "seearngrs_if",
  "fimnlabgrs_dv",
  "jbisco88_cc"
)

# load wave data #### 

if (w_max < 12) {
  # read wave 1 UKHLS
  longfile <-
    haven::read_spss(file = paste0(my_path_old, "ukhls_w1/a_indresp.sav")) %>%
    select(all_of(paste0(
      "a_",
      c(ukhls_variables_to_select),
      sep = ""
    )),
    pidp) %>%
    rename_at(vars(starts_with("a_")), ~ str_replace(., "a_", "")) %>%
    mutate(wave = 1, study = "UKHLS")
  
  # read all waves up to 10 in a loop
  for (wave_number in 2:w_max) {
    wave_letter <- paste0(letters[wave_number], "_")
    wave_data <- read_spss(paste0(
      my_path_old,
      "ukhls_w",
      wave_number,
      "/",
      wave_letter,
      "indresp.sav"
    )) %>%
      select(all_of(paste(
        wave_letter, c(ukhls_variables_to_select), sep = ""
      )),
      pidp) %>%
      rename_at(vars(starts_with(wave_letter)),
                ~ str_replace(., wave_letter, "")) %>%
      mutate(wave = wave_number, study = "UKHLS")
    longfile <- bind_rows(longfile, wave_data)
  }
  
} else {
  # read wave 1 UKHLS
  longfile <-
    haven::read_spss(file = paste0(my_path_new, "a_indresp.sav")) %>%
    select(all_of(paste0(
      "a_",
      c(ukhls_variables_to_select),
      sep = ""
    )),
    pidp) %>%
    rename_at(vars(starts_with("a_")), ~ str_replace(., "a_", "")) %>%
    mutate(wave = 1, study = "UKHLS")
  
  # read all waves in a loop
  for (wave_number in 2:w_max) {
    wave_letter <- paste0(letters[wave_number], "_")
    wave_data <- haven::read_spss(paste0(my_path_new,
                                         "/",
                                         wave_letter,
                                         "indresp.sav")) %>%
      select(all_of(paste(
        wave_letter,
        c(ukhls_variables_to_select),
        sep = ""
      )),
      pidp) %>%
      rename_at(vars(starts_with(wave_letter)),
                ~ str_replace(., wave_letter, "")) %>%
      mutate(wave = wave_number, study = "UKHLS")
    longfile <- bind_rows(longfile, wave_data)
  }
  
  # all UKHLS waves are now binded into longfile data object
  
}



# remove unneeded objects #### 
rm(
  packages,
  not_on_cran,
  package_check,
  wave_data,
  ukhls_variables_to_select,
  wave_letter,
  wave_number
)

print(paste(Sys.time(), "[01 done]"))


# if you want to save this step run:
# save.image("longfile.RData")
