library(lubridate)
library(dplyr)
library(ggplot2)
library(tidyverse)

# Loading data
ariByCounty <- read.csv("his_cor.csv", stringsAsFactors = F,header = T)
aflatoxindata <- read.csv("Log_transformed_At.csv", stringsAsFactors = F,header = T)

# convert this factor to the character class
class(aflatoxindata$year)
aflatoxindata$year <- as.character(aflatoxindata$year) # integer to character 

# change names
names(ariByCounty) <- c('plantingdate', 'county', 'aGDDs', 'ARI', 'DAP')
ariByCounty$plantingdate <- as.Date(ariByCounty$plantingdate, "%m/%d/%Y")
ariByCounty$date <- format(as.Date(ariByCounty$plantingdate, "%Y-%m-%d"),"%m/%d")
ariByCounty$year <- format(as.Date(ariByCounty$plantingdate, "%Y-%m-%d"),"%Y")

# summarise 
ari<-ariByCounty %>%
  group_by(county,year,DAP) %>% 
  summarise(mean_ari = mean(ARI), mean_gdd = mean(aGDDs)) 
View(ari)  

# combine two data frames 
a<- inner_join(ari, aflatoxindata, by=c("county","year"))


# graph
ggplot(a) +
  geom_col(aes(x=county,y=mean_ari,group=county,color=county,fill=county),position = 'dodge') +
  facet_grid(cols =  vars(factor(DAP)),rows =  vars(factor(year))) +
  geom_line(aes(x=county,y=mean_aflatoxin,group=factor(year)),size=1) +
  ggtitle("ARI by county") +
  xlab("County") + 
  ylab("Aflatoxin Risk Index") + 
  theme(axis.text.x=element_blank())

