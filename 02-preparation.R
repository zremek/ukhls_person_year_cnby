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


