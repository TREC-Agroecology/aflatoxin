############# AT data modelling #######################
#############   data wrangling  #######################

library(dplyr)
library(tidyr)

## Load data
dat <- read.csv("AT_Shellman_Data_mod.csv", header = TRUE)
head(dat)


## Separate the column "Treatment_Code_mod" into four different columns

dat_mod <- tidyr::extract(dat, Treatment_Code_mod, into = c("Rotation", "Rep", "Variety", "Irrigation"),
                          "(.{1})(.{1})(.{1})(.{1})")

## Replace the coding numbers of the newly built columns with treatments/variety names from the key
dat_mod$Rep <- as.numeric(dat_mod$Rep) 
dat_mod$Variety <- as.factor(dat_mod$Variety) 
dat_mod$Irrigation <- as.factor(dat_mod$Irrigation) 

levels(dat_mod$Irrigation) <- c("100","75","50","0")
levels(dat_mod$Variety) <- c("NA","GA Green twin","GA Green diamond","GA 982508", "AT 201")

## Seave the data set as a table
write.table(dat_mod, "AT_Shellman_final.csv", row.names = FALSE, sep = ",")
