
## Load packages
library(ggplot2)
library(gridExtra)
library(Hmisc)
library(cowplot)
library(plyr)
library(dplyr)
library(plotrix)


## Load cleaned data set
atdat <- read.csv("AT_Shellman_final.csv", 
                  header = TRUE) 

## Subset data to include irrigation, Acceptance and AT concentrations
vdat <- select(atdat, 11,14,17:21)
vdatm <- vdat %>% group_by(Irrigation, Acceptance) %>% summarise_all(funs(mean, sd, se=std.error), na.rm = TRUE)

# Add missing irrigation treatments (value = 0)
nr100a <- data.frame(Acceptance = "accept", Irrigation=100, stringsAsFactors=F)

# Bind rows and set fixed variables as factors
at <- rbind.fill(vdatm, nr100a)
at$Acceptance <- as.factor(at$Acceptance)
at$Irrigation <- as.factor(at$Irrigation)
at[is.na(at)] <- 0

# Change sequence of Acceptance rate
at$Acceptance <- factor(at$Acceptance,levels = c("premium", "accept", "reject"))

## Plot and save
bar <- ggplot(at, aes(x = Acceptance , y = AFTotal_mean, fill = Irrigation)) +
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin = AFTotal_mean - AFTotal_se, 
                    ymax = AFTotal_mean + AFTotal_se,), 
                width=.2, position=position_dodge(.9)) +
  labs(x = "Acceptance rate", y = "Total Aflatoxin [ppm]") +
  #scale_fill_brewer() +
  theme_minimal_grid()

ggsave("AT_acceptance-irrigation.tiff", plot = bar, path = "Figures", width = 10, height = 7)

## Summarise data according to Irrigation, Rotation and Acceptance

vdat <- select(atdat, 8,11,14,17:21)
vdatm <- vdat %>% group_by(Rotation, Irrigation, Acceptance) %>% 
  summarise_all(funs(mean, sd, se=std.error), na.rm = TRUE)

vdatm$Acceptance <- as.factor(vdatm$Acceptance)
vdatm$Irrigation <- as.factor(vdatm$Irrigation)
vdatm$Rotation <- as.factor(vdatm$Rotation)
vdatm[is.na(at)] <- 0


write.csv(vdatm,'Output/AT_Shellman_SumStat.csv', row.names = FALSE)

## Plot and save
barRot <- ggplot(vdatm, aes(x = Acceptance , y = AFTotal_mean, fill = Irrigation)) +
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin = AFTotal_mean - AFTotal_se, 
                    ymax = AFTotal_mean + AFTotal_se,), 
                width=.2, position=position_dodge(.9)) +
  labs(x = "Acceptance rate", y = "Total Aflatoxin [ppm]") +
  #scale_fill_brewer() +
  theme_minimal_grid() +
  facet_wrap(~Rotation)

ggsave("ATTotal_Rot_acceptance-irrigation.tiff", plot = barRot, path = "Figures", width = 10, height = 7)

## Take a closer look at the different Aflatoxins
barRot <- ggplot(vdatm, aes(x = Acceptance , y = AFG2_mean, fill = Irrigation)) +
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin = AFG2_mean - AFG2_se, 
                    ymax = AFG2_mean + AFG2_se,), 
                width=.2, position=position_dodge(.9)) +
  labs(x = "Acceptance rate", y = "Aflatoxin G2 [ppm]") +
  #scale_fill_brewer() +
  theme_minimal_grid() +
  facet_wrap(~Rotation)

ggsave("ATG2_Rot_acceptance-irrigation.tiff", plot = barRot, path = "Figures", width = 10, height = 7)