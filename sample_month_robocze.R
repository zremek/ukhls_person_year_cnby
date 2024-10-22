library(tidyverse)
library(haven)


# potrzebujemy miesiąc w którym miał być wywiad dokleić do danych 
# w celu ustalenia jak wyjść na dane roczne 

my_path <- "/Users/remek/Code/UKDA-6614-spss/spss/spss25/ukhls/"


variables_to_select <- "month"

# read indresp data ####

# read wave 1 UKHLS
smth_longfile <- haven::read_spss(file = paste0(my_path, "a_indresp.sav")) %>%
  select(all_of(paste0("a_",
                       c(variables_to_select), 
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
  smth_longfile <- bind_rows(longfile, wave_data)
}

# dane cnby 

ukhls_CNBformat <- haven::read_spss("ukhls_CNBformat.sav")

ukhls_CNBformat_sample_month <- left_join(
  x = ukhls_CNBformat, 
  y = smth_longfile %>% 
    select(-study) %>% 
    rename(
      sample_month = month, 
      Respid = pidp,
      CURWAVE = wave) %>% 
    mutate(Respid = as.character(Respid))
)


sjPlot::view_df(ukhls_CNBformat_sample_month)

haven::write_sav(data = ukhls_CNBformat_sample_month, path = "ukhls_CNBformat_sample_month.sav")


