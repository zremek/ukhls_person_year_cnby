library(tidyverse)
library(haven)

d <- haven::read_spss("ukhls_CNBformat_sample_month.sav")

d %>% count(Respid) %>% dim()

summary(d$YRBIRTH)

summary(d$YEAR - d$YRBIRTH)
