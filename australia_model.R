library(dplyr)
library(tibble)
library(tidyverse)
library(data.table)

data <-read.csv("C:\\Users\\da94_\\OneDrive - University of Florida\\PEANUT PROJECT\\irrigation_Model_DK.csv", header = T)
names(data) <-c('Date', 'Day', 'MinT', 'MaxT', 'Water', 'ET')
AWC <- 0.1

data <- data %>% 
  mutate(data, DailyGDD = (data$MinT + data$MaxT) / 2 - 13.3,
         CorrectedGDD = {ifelse(DailyGDD >= 0, DailyGDD, 0)},
         cumGDDs = cumsum(CorrectedGDD),
         RootDepth = {ifelse(cumGDDs < 750, 12+(36-12)*(cumGDDs-data$cumGDDs[data$Day == 0 ])/(750-data$cumGDDs[data$Day == 0 ]), 36)})


data <- data %>% 
  mutate(data,PAW = AWC * RootDepth, 
         KcCurve = if(cumGDDs>0 && cumGDDs<325){
           0.3
         } else if (cumGDDs>325 && cumGDDs<800){
           0.3+((cumGDDs-325)/475)*(1-0.3)
         } else if (cumGDDs>800 && cumGDDs<1350){
           1
         } else if (cumGDDs>1350 && cumGDDs<1650){
           1+((cumGDDs-1350)/300)*(0.6-1)
         } else if (cumGDDs>1650 && cumGDDs<1700){
           0.6+((cumGDDs-1650)/50)*(0.2-0.4)
         } else if (cumGDDs>1700){
           0.2 
         })
head(data)
