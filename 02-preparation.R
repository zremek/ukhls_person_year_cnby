library(tidyverse)
library(haven)
library(sjmisc)
library(sjlabelled)

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
  filter(between(x = doby_dv, left = 1983, right = 1998)) # only born from 83 to 98




# TODO FSTWAVE First wave R participated - survey year #### 
# waiting for help https://iserredex.essex.ac.uk/support/issues/2144  



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
                                          drop.levels = TRUE))

# labelled::drop_unused_value_labels for all variables

longfile <- longfile %>% labelled::drop_unused_value_labels()

# create 

longfile <- longfile %>% 
    mutate(JOB01_IncomeGrs = if_else(!is.na(seearngrs_dv_na), 
                              true = seearngrs_dv_na, 
                              false = paygu_dv_na),
           JOB01_IncomeNet = if_else(!is.na(seearnnet_dv_na), 
                              true = seearnnet_dv_na, 
                              false = paynu_dv_na))
