library(tidyverse)
library(here)

data.path <- here('security-data_swarmtaxis')

setwd(data.path)

csv.files <- list.files(path = data.path, pattern="*.csv")

csv.files %>%
  setNames(make.names(gsub("*.csv$", "", csv.files))) %>% 
  lapply(read.csv) %>% 
  list2env(envir = .GlobalEnv)

all.data <- data.frame()

for (i in gsub('*.csv$', '', csv.files)) {
  all.data <- all.data %>% rbind(get(i))
}


all.data$swarmsize <- factor(all.data$swarmsize, levels = sort(unique(all.data$swarmsize)))

ggplot(data = all.data) + geom_boxplot(aes(y = ticks, x=swarmsize))
