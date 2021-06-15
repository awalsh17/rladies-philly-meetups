# Assembled for June 2021 R-Ladies lightning talk

library(janitor)
library(dplyr)
library(stringr)
library(ggplot2)
theme_set(theme_light())

# So initial cleaning of messing data: ------

data_link <- 'http://data.phl.opendata.arcgis.com/datasets/0707c1f31e2446e881d680b0a5ee54bc_0.csv'
dirty <- read.csv(data_link)

# Free text
dirty %>% count(NEIGHBORHOOD, sort=T)

# stringr is your friend
dirty <- dirty %>% 
  clean_names() %>% 
  mutate(neighborhood = stringr::str_to_sentence(neighborhood),
         neighborhood = stringr::str_trim(neighborhood))

dirty %>% count(NEIGHBORHOOD, sort=T)

# Here is a challenge for another day
dirty %>% count(MONTHS, sort =T) %>% head()

# Using forcats (just a couple of examples):

# OK
dirty %>% 
  count(neighborhood) %>% 
  ggplot(aes(x=neighborhood, y = n)) + 
  geom_col()

# Better
dirty %>% 
  mutate(neighborhood = forcats::fct_lump(neighborhood, n = 5),
         neighborhood = forcats::fct_infreq(neighborhood)) %>% 
  count(neighborhood) %>% 
  ggplot(aes(x=neighborhood, y = n)) + 
  geom_col()

# Tools to quickly help you explore your data: -----
library(DataExplorer)
library(dataReporter)

DataExplorer::create_report(dirty)

dataReporter::makeDataReport(dirty)


# Now dealing with excel data: -----

excel_file <- here::here('fake_excel_data.xlsx')

# Uh oh
excel <- openxlsx::read.xlsx(excel_file)
head(excel)

# Better
excel <- openxlsx::read.xlsx(excel_file, 
                             startRow = 4, 
                             check.names = T,
                             na.strings = c("NA",".","<NA>"),
                             fillMergedCells = T)
head(excel)

# Even better
excel %>% 
  janitor::clean_names() %>% 
  mutate(dates = janitor::excel_numeric_to_date(dates)) %>% 
  head()

excel <- excel %>% 
  janitor::clean_names() %>% 
  filter(!is.na(first_column_1)) %>% 
  mutate(dates = janitor::excel_numeric_to_date(dates),
         comments = as.factor(comments))

excel %>% count(comments)

# Try forcats::fct_explicit_na() again
excel %>% 
  ggplot(aes(y=values, x = first_column, color = comments)) + 
  geom_point()

excel %>% 
  mutate(comments = forcats::fct_explicit_na(comments)) %>% 
  ggplot(aes(y=values, x = first_column, color = comments)) + 
  geom_point()

# Try to get excel formatting: 
library(tidyxl)

# This is still difficult to parse - not easy to do
excel_w_format <- tidyxl::xlsx_formats(excel_file) 

# Alice Walsh, 2021
