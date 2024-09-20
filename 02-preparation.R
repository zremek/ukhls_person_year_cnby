library(tidyverse)
library(haven)
library(sjmisc)
library(sjlabelled)

# DIGCLASS package is not on CRAN
# install.packages("devtools")
# devtools::install_git("https://code.europa.eu/digclass/digclass.git")

library(DIGCLASS)

# age filter #### 

# find birth year inconsistencies
birthy_consistent_id <- longfile %>% 
  group_by(pidp) %>% 
  summarise(min_birthy = min(doby_dv),
            max_birthy = max(doby_dv)) %>%
  filter(min_birthy == max_birthy) %>% 
  pull(pidp)

longfile <- longfile %>% 
  filter(pidp %in% birthy_consistent_id) %>% # filter off inconsistent
  filter(between(x = doby_dv, left = 1983, right = 2003)) # only born from 83 to 03



# dates of next and previous interview #### 
# Nxtwave_Yr Date of first interview after this year: year
# Nxtwave_Mth Date of first interview after this year: month
# Nxtwave_Day Date of first interview after this year: day

# Prevwave_Yr Date of last interview after this year: year
# Prevwave_Mth Date of last interview after this year: month
# Prevwave_Day Date of last interview after this year: day

longfile <- 
  longfile %>% 
  arrange(pidp, wave) %>% 
  mutate(Prevwave_Yr = lag(intdaty_dv), 
         Prevwave_Mth = lag(intdatm_dv), 
         Prevwave_Day = lag(intdatd_dv), 
         Nxtwave_Yr = lead(intdaty_dv), 
         Nxtwave_Mth = lead(intdatm_dv), 
         Nxtwave_Day = lead(intdatd_dv))


# gross usual pay paygu_dv, self-employment pay seearngrs_dv
# JOB01_IncomeGrs
# [Job 01] Monthly earnings, gross
# at the end of the spell (current earnings for censored spells); in UKHLS for current job at the time of interview
# paynu_dv, seearnnet_dv
# JOB01_IncomeNet
# [Job 01] Monthly earnings, net





# clean income data from special missing categories from -9 to -1 #### 

longfile <- 
  longfile %>% 
  mutate(seearngrs_dv_na = sjlabelled::set_na(seearngrs_dv, na = -9:-1,
                                              drop.levels = TRUE), 
         paygu_dv_na = sjlabelled::set_na(paygu_dv, na = -9:-1,
                                          drop.levels = TRUE),
         seearnnet_dv_na = sjlabelled::set_na(seearnnet_dv, na = -9:-1,
                                              drop.levels = TRUE), 
         paynu_dv_na = sjlabelled::set_na(paynu_dv, na = -9:-1,
                                          drop.levels = TRUE), 
         fimnlabgrs_dv_na = sjlabelled::set_na(fimnlabgrs_dv, na = -9:-1,
                                               drop.levels = TRUE))

# labelled::drop_unused_value_labels for all variables

longfile <- longfile %>% labelled::drop_unused_value_labels()

# create income vars

longfile <- longfile %>% 
    mutate(JOB01_IncomeGrs = if_else(!is.na(seearngrs_dv_na), 
                              true = seearngrs_dv_na, 
                              false = paygu_dv_na),
           JOB01_IncomeNet = if_else(!is.na(seearnnet_dv_na), 
                              true = seearnnet_dv_na, 
                              false = paynu_dv_na), 
           Y_Workincome = fimnlabgrs_dv_na, 
           CY_Workincome = NA, 
           JOB01_IncomeGrs_CV = paygu_if == 1 | seearngrs_if == 1,
           JOB01_IncomeNet_CV = paynu_if == 1
           )

# recode isco88 to 08 #### 

longfile <- longfile %>% 
  mutate(
    jbisco88_cc_na = sjlabelled::set_na(jbisco88_cc, na = -9:-1,
                                        drop.levels = TRUE) %>% 
      as.character(),
    jbisco88_cc_na_4 = paste0(jbisco88_cc_na, "0"),
    jbisco88_cc_na_4 = sjlabelled::set_na(jbisco88_cc_na_4, na = "NA0"),
    jbisco88_cc_na_4 = if_else(nchar(jbisco88_cc_na_4) == 3, 
                               paste0(jbisco88_cc_na_4, "0"), 
                               jbisco88_cc_na_4),
    JOB01_ISCO08 = isco88_to_isco08(jbisco88_cc_na_4)
  )

# TODO FSTWAVE First wave R participated - survey year #### 
# FSTWAVE
# LSTWAVE
# CURWAVE
# Curwave_Yr
# Curwave_Mth
# Curwave_Day
# NXTWAVE
# PREVWAVE

longfile <- longfile %>% 
  arrange(pidp, wave) %>% 
  mutate(
    YEAR = intdaty_dv, 
    CURWAVE = wave,
    Curwave_Yr = intdaty_dv, 
    Curwave_Mth = intdatm_dv,
    Curwave_Day = intdatd_dv, 
    NXTWAVE = lead(wave), 
    PREVWAVE = lag(wave), 
    STUDY = study
  )


longfile <- longfile %>%
  group_by(pidp) %>%
  mutate(FSTWAVE = min(CURWAVE),
         LSTWAVE = max(CURWAVE)) %>%
  ungroup()

# TODO 

# doby_dv
# YRBIRTH
# Year of birth

# NA: Special Licence
# MTBIRTH
# Month of birth

# NA: Special Licence
# DYBIRTH
# Day of birth

# sex_dv
# GENDER
# Gender

# urban_dv
# RESIDSIZEa
# Urban / rural

longfile <- longfile %>%
  mutate(
    Respid = pidp, 
    YRBIRTH = doby_dv,
    MTBIRTH = NA,
    DYBIRTH = NA,
    GENDER = sex_dv,
    RESIDSIZE = urban_dv,
    RESIDREG = gor_dv,
    MARITSTAT = marstat_dv,
    CHILDREN = case_when(ndepchl_dv == -8 ~ 0,
                         .default = ndepchl_dv)
  ) %>%
  labelled::drop_unused_value_labels()

# set variable labels #### 

ukhls_CNBformat <-
  longfile %>%
  select(starts_with(LETTERS, ignore.case = FALSE)) %>%
  var_labels(
    Respid = 'ID',
    YEAR = 'Calendar year',
    YRBIRTH = 'Year of birth',
    MTBIRTH = 'Month of birth',
    DYBIRTH = 'Day of birth',
    GENDER = 'Gender',
    RESIDSIZE = 'Urban / rural',
    RESIDREG = 'Region of residence',
    MARITSTAT = 'Marital / partnership status',
    CHILDREN = 'Number of children',
    FSTWAVE = 'First wave R participated - survey year',
    LSTWAVE = 'Last wave R participated - survey year',
    CURWAVE = 'First interview this year - survey year',
    Curwave_Yr = 'Date of first interview this year: year',
    Curwave_Mth = 'Date of first interview this year: month',
    Curwave_Day = 'Date of first interview this year: day',
    NXTWAVE = 'First interview after this year - survey year',
    Nxtwave_Yr = 'Date of first interview after this year: year',
    Nxtwave_Mth = 'Date of first interview after this year: month',
    Nxtwave_Day = 'Date of first interview after this year: day',
    PREVWAVE = 'Last interview before this year - survey year',
    Prevwave_Yr = 'Date of last interview before this year: year',
    Prevwave_Mth = 'Date of last interview before this year: month',
    Prevwave_Day = 'Date of last interview before this year: day',
    JOB01_ISCO08 = '[Job 01] ISCO-08 Code',
    JOB01_IncomeGrs = '[Job 01] Monthly earnings, gross',
    JOB01_IncomeNet = '[Job 01] Monthly earnings, net',
    JOB01_IncomeGrs_CV = '[Job 01] Monthly earnings, gross: methodological information',
    JOB01_IncomeNet_CV = '[Job 01] Monthly earnings, net: methodological information',
    Y_Workincome = '[Income] Total income from work',
    CY_Workincome = '[Derived income] Total income from work',
    STUDY = 'Name of the panel study'
  )
