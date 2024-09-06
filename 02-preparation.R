library(tidyverse)
library(haven)
library(sjmisc)

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




