library(tidyverse)
library(haven)
library(sjmisc)

# if you manually run script by script,
# and have not set your path to data folder
# in script 00-run-all.R
# do it in the line below, un-comment and run:

# my_path <- "/a_directory_on_my_machine/UKDA-6614-spss/spss/spss25/ukhls/"


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

# read indresp data ####

# read wave 1 UKHLS
longfile <- haven::read_spss(file = paste0(my_path, "a_indresp.sav")) %>%
  select(all_of(paste0("a_",
                       c(ukhls_variables_to_select), 
                       sep = "")),
         pidp) %>%
  rename_at(vars(starts_with("a_")), ~str_replace(.,"a_", "")) %>%
  mutate(wave = 1, study = "UKHLS")

# read all waves up to 13 in a loop
for (wave_number in 2:13) {
  wave_letter <- paste0(letters[wave_number],"_")
  wave_data <- haven::read_spss(paste0(my_path,
                                "/",
                                wave_letter,
                                "indresp.sav")) %>%
    select(all_of(paste(wave_letter,
                        c(ukhls_variables_to_select),
                        sep = "")),
           pidp) %>% 
    rename_at(vars(starts_with(wave_letter)),
              ~str_replace(., wave_letter, "")) %>%
    mutate(wave = wave_number, study = "UKHLS")
  longfile <- bind_rows(longfile, wave_data)
}

# all UKHLS waves are now binded into longfile data object

# remove unneeded objects 
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
