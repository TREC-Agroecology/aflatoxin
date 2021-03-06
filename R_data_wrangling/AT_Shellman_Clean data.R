############# AT data modelling #######################
#############   data wrangling  #######################


### Packages

library(dplyr)
library(tidyr)

### Clean data set for Shellman data provided by Georgia Peanut Institute

## Load data
# This data set was manually put together from several separate PDFs and Excel files (2001-2011)
dat <- read.csv("AT_Shellman_Data_mod.csv", header = TRUE, 
                check.names = FALSE,
                fileEncoding="UTF-8-BOM") # Used to be able to read special signs in csv file (i.e. ^TM)
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

## Create single columns for year, planting day, planting month, harvest day, harvest month. Remove "Analysis_day"
## from data set, because it does not provide us with meaningful information
dat_mod <- tidyr::separate(dat_mod, Planting_Date, c("Planting_day","Planting_month","Year"), by = "-")
dat_mod <- tidyr::separate(dat_mod, Harvest_Date, c("Harvest_day","Harvest_month","H_Year"), by = "-")
dat_mod <- subset(dat_mod, select = -c(H_Year,Analysis_Date))

# Write full year, instead of 01, 02, 03,...
dat_mod$Year <- as.factor(dat_mod$Year) 
levels(dat_mod$Year) <- c("2001","2002","2003","2010", "2011")

# reorder columns
dat_mod <- dat_mod[,c(1,4,2,3,5,6,11,7,8,9,10,12:21)] 


## Seave the data set as a table
write.table(dat_mod, "AT_Shellman_final.csv", row.names = FALSE, sep = ",")


### Create separate data set for rotation

# Subset Shellman data set
dat_rot <- dplyr::select(dat_mod, Sample_no, Rotation)

# Translate the code for "Rotation" according to the provided key in "peanut yields for UF_edit Shannon"
dat_rot$Rotation_code <- dat_rot$Rotation
dat_rot$Rotation <- as.factor(dat_rot$Rotation) 
levels(dat_rot$Rotation) <- c("0.c.p.c.p.c", "0.m.p.m.p.m", "m.m.p.m.m.p", "c.m.p.c.m.p", "c.c.p.c.c.p", "p.p.p.p.p.p", "NA")

# extract the most recent planted crop before peanut experiment
dat_rot$prev_crop <- dat_rot$Rotation
dat_rot <- tidyr::separate(dat_rot, prev_crop, c("a","b","c","d","e","Prev_crop"), by = ".")
dat_rot <- subset(dat_rot, select = -c(a,b,c,d,e))

# save data set as a table
write.table(dat_rot, "AT_Shellman_Rotation.csv", row.names = FALSE, sep = ",")
