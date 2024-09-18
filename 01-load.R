library(tidyverse)
library(haven)
library(sjmisc)

Sys.setenv(LANGUAGE = "en")

my_path <- "/Users/remek/Code/UKDA-6614-spss/spss/spss25/ukhls/"

# select variables ####
# pidp goes into read_spss() because it has no wave prefix

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
  "fimnlabgrs_dv"
)

# nsssec_to_select <- # it's separated to remind that I add it doing 04-make-wide
#   c("jbnssec8_dv",
#     "jlnssec8_dv",
#     "j2nssec8_dv",
#     "j1nssec8_dv", # time invariant
#     "manssec8_dv", # same
#     "panssec8_dv") # same 


# ukhls_wave_2_onwards_select <- c(
#   "notempchk", #https://www.understandingsociety.ac.uk/documentation/mainstage/dataset-documentation/variable/notempchk
#   "empchk", #https://www.understandingsociety.ac.uk/documentation/mainstage/dataset-documentation/variable/empchk
#   "movy13", # Employer related reasons of moving to different address - see Rmd notes_CNBY
#   "empstendm",
#   "empstendy4",
#   "jbendm",
#   "jbendy4",
#   "ff_ivlolw", # fed forward ever interviewed 
#   "nnmpsp_dv", # No. non-employment spells since last interview
#   "nmpsp_dv",	# No. employment spells since last interview
#   "nunmpsp_dv",	# No. unemployment spells since last interview
#   "nqfhigh_dv" #https://www.understandingsociety.ac.uk/documentation/mainstage/dataset-documentation/variable/nqfhigh_dv) # vars regarding end of job / other status end date - to do

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
  wave_data <- read_spss(paste0(my_path,
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
count(longfile, wave)
qplot(as.factor(wave), data = longfile)

# random exploration ####

# table(longfile$age_dv < 36)
# prop.table(table(longfile$age_dv < 36))
# 
# table(longfile$birthy > 2018 - 35) 
# 
# table(longfile$birthy)
# 
# select(longfile, qfhigh_dv, pidp, wave) %>% 
#   filter(qfhigh_dv > 0) %>% 
#   group_by(pidp) %>%
#   count(qfhigh_dv) %>% 
#   filter(n() > 4) %>% 
#   arrange(-pidp) %>% 
#   print(n = 40)
#   
# longfile %>% 
#   select(qfhigh_dv, pidp, wave) %>% 
#   filter(pidp == 68155063)
# 
# sjmisc::frq(longfile$marstat)
# 
# longfile %>% select(pidp, marstat, wave) %>%
#   filter(marstat > 0) %>% arrange(pidp) %>% 
#   print(n = 40)
# 
# binoculaR::binoculaR(longfile)
# 
# table(longfile$empstendy4, longfile$wave)

## to do: does everybody at wave 1 have start date of their job? ####

# filter longfile on birth year: from 1983 to 1997 (not 1998), excluding missings etc. ####

# data <- longfile %>% filter(dplyr::between(x = birthy, left = 1983, right = 1997))
# 
# # data %>% select(birthy) %>% sjmisc::frq()
# 
# # load and join xwavedat ####
# 
# xwave_select <- c(
#   "pidp",
#   "school_dv", # Never went to/still at school, categorical variable
#   "feend_dv", # Further education leaving age, mean age 21.7
#   "scend_dv", # School leaving age, mean age 16.2
#   "maedqf", 
#   "paedqf",
#   "bornuk_dv", # whether born in the UK 
#   "plbornc", # country of birth, excluding UK
#   "doby_dv", # year of birth, derived, UKHLS only 
#   "pasoc90_cc", # 1. 
#   "masoc90_cc",# 2.
#   "j1soc90_cc" #3. those three to join from xwave because of -8s in indresp
# )
# 
# crosswave <- read_spss(file = paste0(my_path, "ukhls_wx/xwavedat.sav")) %>%
#   select(all_of(xwave_select))
# 
# data <- left_join(data, crosswave, by = "pidp")
# 
# data <- data %>% mutate(pidp = as.numeric(pidp))
# 
# # I leave the "data" object for previous markdown report
# # but the proper data for TIY need to be filtered on doby_dv
# 
# # make tyi_data object: join xwave and filter on doby_dv #### 
# 
# tyi_data <- left_join(longfile, crosswave, by = "pidp") %>% 
#   filter(dplyr::between(x = doby_dv, left = 1983, right = 1997)) %>% 
#   mutate(pidp = as.numeric(pidp))
# 
# # clean up and save data as .Rdata #### 
# rm(wave_data, ukhls_variables_to_select, ukhls_wave_2_onwards_select,
#    wave_letter, wave_number, xwave_select)
# save.image()
# 
# # BHPS? no! ####
# 
# # # change one variable name to match bhps name
# # variables_to_select[1] <- "age"
# 
# # read BHPS waves 10 - 18 and bind to longfile
# # for (wave_number in 10:18) {
# #   wave_letter <- paste0(letters[wave_number],"_")
# #   wave_data <- read_spss(paste0(my_path, "bhps_w",
# #                                 wave_number, "/b", wave_letter,
# #                                 "indresp.sav")) %>%
# #     select(all_of(paste("b", wave_letter, variables_to_select, sep = "")),
# #            pidp) %>% 
# #     rename_at(vars(starts_with(paste0("b", wave_letter))),
# #               ~str_replace(., paste0("b", wave_letter), "")) %>%
# #     rename(age_dv = age) %>% 
# #     mutate(wave = wave_number, study = "BHPS")
# #   longfile <- bind_rows(longfile, wave_data)
# # }
# # 
# # # create increasing wave indicator
# # longfile <- longfile %>%
# #   mutate(wave_from10_to28 = if_else(study == "UKHLS", wave + 18, wave))
# # ## the longfile is our main working file 
# # 
# # # see number of responses for each wave
# # longfile %>% count(wave_from10_to28, study) %>% 
# #   ggplot(aes(x = as.factor(wave_from10_to28), y = n, fill = study)) +
# #   geom_col()
# # 
# # ## clean up and save data as .Rdata if you want
# # # rm(wave_data, variables_to_select, wave_letter, wave_number)
# # # 

# save.image("longfile_1109.RData")
