setwd("C:/Users/dayoung.kim/OneDrive - University of Florida/PEANUT PROJECT/AustraliaModelData/DY_GAdata")

## PeanutFarm (Dr.Zurweller's first excel sheet Irrigation_Model)


#___________________________________________
# Set some functions
#___________________________________________
# environment

# Days after planting (column B)

dap.f <- function(day_after_planting){
  
  dap <- c(0:day_after_planting)
  return(dap)

}

# DailyGDD (column G) 

GDD <- function(tmx,tmn,tb=13.33){ #function default value for tb
  
  tmean <- (tmx + tmn) / 2
  
  DailyGDD <- tmean - tb 
              # peanut tbase 56.0 (?F), 13.33333 (?C) 
              # resource https://edis.ifas.ufl.edu/publication/AE428
  return(round(DailyGDD,1))

}


# CorrectedGDD (column H)

correctedGDD <- function(tmx,tmn,tb){
  
  tmean <- (tmx+tmn)/2
  
  DailyGDD <- tmean - tb  
  correctedGDD <- ifelse(tmean >= tb, DailyGDD, 0)
  return(round(correctedGDD,1))

}

# Cum.GDD (column I)

cumGDD <- function(tmx,tmn,tb){
  
  cor_GDD <- correctedGDD(tmx,tmn,tb) ## changed to correctedGDD()
  cumGDD = cumsum(cor_GDD)
  return(cumGDD) 
  
}

# RootDepth (column J)

rd <- function(c_gdd,f_gdd){ #c_gdd = cumGDDs, f_gdd = first_day_GDD
  
  rootdepth <- ifelse(c_gdd < 750, 12+(36-12)*(c_gdd-f_gdd)/(750-f_gdd),36)
  return(round(rootdepth,2))
  
}

# PAW (Potential Available Water,column K)

AWC <- 0.1
 # Available Water Capacity
 # Sandy Soil -> 0.1

PAW.f <- function(c_gdd,f_gdd,AWC){ 
  
  root <- rd(c_gdd,f_gdd)
  paw <- AWC * root
  return(round(paw,2))
  
}

# KcCurve (column L)
Kc.f <- function(c_gdd){
  
  kc <- ifelse(c_gdd > 0 & c_gdd < 325, 0.3,
        ifelse(c_gdd > 325 & c_gdd < 800, 0.3+((c_gdd-325)/475)*(1-0.3),
        ifelse(c_gdd > 800 & c_gdd < 1350, 1,
        ifelse(c_gdd > 1350 & c_gdd < 1650, 1+((c_gdd-1350)/300)*(0.6-1),
        ifelse(c_gdd > 1650 & c_gdd < 1700, 0.6+((c_gdd-1650)/50)*(0.2-0.4),
        ifelse(c_gdd > 1700, 0.2,0))))))      # need to check 'no' return values  
  return(round(kc,2))
  
}


# Irrigation Recommendation (column O)

irrigation_recommendation <- function(fswb,paw){
  
  rec <- ifelse(fswb < (0.51*paw), "irrigate",
         ifelse(fswb < (0.6*paw), "check field","adequate soil moisture"))
  return(rec)
  
}

#___________________________________________
# Simple model
#___________________________________________
IrrigationModel <- function(localEnvironment,localManagement1,localManagement2){
  
  #Describe the system
  
  #Environment
  env <- localEnvironment
  names(env) <- c('date', 'tmn', 'tmx', 'water', 'ET')
  
  #Management
  dap <- localManagement1          #Days After Planting
  AWC <- localManagement2          #Available Water Capacity
  
  tb <- 13.33

  #round off the value 
  env$tmx <- round(env$tmx,1)
  env$tmn <- round(env$tmn,1)
  

  #daily values

  DayAfterPlanting <- dap.f(dap)
  dailyGDD <- GDD(env$tmx,env$tmn,tb)
  correctedGDD <- correctedGDD(env$tmx,env$tmn,tb)
  cumGDDs <- cumGDD(env$tmx,env$tmn,tb)
  
  env <- cbind(env,DayAfterPlanting,dailyGDD,correctedGDD,cumGDDs) #record values
  
  #Initialize variables
  f_gdd <- env$correctedGDD[env$DayAfterPlanting==0]

  
  #daily values
  RootDepth <- rd(env$cumGDDs,f_gdd)
  PAW <- PAW.f(env$cumGDDs,f_gdd,AWC)
  KcCurve <- Kc.f(env$cumGDDs)

  #Final Soil Water Balance (column M) & Soil Water Balance (column N)
  fswb <- NA
  swb <- NA 
  env <- cbind(env,RootDepth,PAW,KcCurve,fswb,swb) #record values
  
  
  #Initialize variables for calculating
  paw1 <- env$PAW[env$DayAfterPlanting==0]
  et1 <- env$ET[env$DayAfterPlanting==0]
  kc1 <- env$KcCurve[env$DayAfterPlanting==0]
  water1 <- env$water[env$DayAfterPlanting==0]
  
  #Define start (planting) date's value
  env$fswb[env$DayAfterPlanting==0] <- paw1-(et1*kc1)+water1
  f1 <- env$fswb[env$DayAfterPlanting==0]
  env$swb[env$DayAfterPlanting==0] <- ifelse(f1>paw1, paw1, f1)
  s1 <- env$swb[env$DayAfterPlanting==0]

  #for loop
  for (i in seq_len(nrow(env))) {
    env$fswb[env$DayAfterPlanting==i] <- max(0,env$swb[env$DayAfterPlanting==i-1]-(env$ET[env$DayAfterPlanting==i]*env$KcCurve[env$DayAfterPlanting==i])+env$water[env$DayAfterPlanting==i])
    new_fswb <- env$fswb[env$DayAfterPlanting==i]
    env$swb[env$DayAfterPlanting==i] <- ifelse(new_fswb>env$PAW[env$DayAfterPlanting==i],env$PAW[env$DayAfterPlanting==i],new_fswb)

  }
  
  #round off the value 
  env$fswb <- round(env$fswb,2)
  env$swb <- round(env$swb,2)
  
  #daily values
  IR <- irrigation_recommendation(env$fswb,env$PAW)
  
  output <- cbind(env,IR) #record values
  print(output[localManagement1+1,"cumGDDs"])
  return(output)

}





# Aflatoxin Risk Model (Dr.Zurweller's second excel sheet Aflatoxin Risk _Model)

library(dplyr)


#___________________________________________
# Set some functions
#___________________________________________

# mean soil temperature (column C)

stmean.f <- function(tmx,tmn){
  
  tmean <- (tmx+tmn)/2
  
  stmean <- 0.2842*tmean^1.358
  return(round(stmean,2))
  
}

# Aflatoxin Drought Threshold (column F)

adt.f <- function(paw){
  
  AflatoxinDroughtThreshold <- paw*0.2
  return(round(AflatoxinDroughtThreshold,2))
  
}

# Aflatoxin Temp Factor (ATF) (column G)

ATF <- function(stmean){
  
  AflatoxinTempFactor <- ifelse(stmean < 22 | stmean > 35 , 0 ,
                                ifelse(stmean > 21 & stmean < 31, (stmean-22)/(30-22),
                                       ifelse(stmean > 29 & stmean < 36, (35-stmean)/(35-30),0)))
  
  atf <- AflatoxinTempFactor*3
  return(round(atf,2))
}

# ATF<20% (column H)

ATF20 <- function(fswb,adt,atf){
  
  atf20 <- ifelse(fswb<adt,atf,0)
  return(atf20)
  
}
# Aflatoxin Risk Index

ARI <- function(atf20,c_gdd){
  
  ari <- ifelse(sum(atf20[c_gdd > 1350])>100, 100, sum(atf20[c_gdd > 1350]))
  return(ari)
  
}

#___________________________________________
# Simple model
#___________________________________________

AflatoxinRiskModel <- function(IrrigationModelData){
  data <- IrrigationModelData
  MeanSoilTemp <- stmean.f(data$tmx,data$tmn)
  AflatoxinDroughtThreshold <- adt.f(data$PAW)
  
  ATF <- ATF(MeanSoilTemp)
  ATF20 <- ATF20(data$fswb,AflatoxinDroughtThreshold,ATF)
  data <- cbind(data,MeanSoilTemp,AflatoxinDroughtThreshold,ATF,ATF20)
  ARI <- ARI(data$ATF20,data$cumGDDs)
  print(ARI)
  newdata <- select(data,date,DayAfterPlanting,MeanSoilTemp,cumGDDs,fswb,AflatoxinDroughtThreshold,ATF,ATF20)
  return(newdata)
}




# Loading the Weather data (Yellow part in excel)
rawdata <- read.csv("irrigation_Model.csv", stringsAsFactors = F,header = T)
str(rawdata)


#___________________________________________
# Run the model one time
#___________________________________________
weather <- rawdata          #localEnvironment
day_after_planting <- 199   #localManagement1
AWC <- 0.1                  #localManagement2

IrrigationModel(weather,day_after_planting,AWC)
output <- IrrigationModel(weather,day_after_planting,AWC)

output2 <- AflatoxinRiskModel(output)
View(AflatoxinRiskModel(output))

#save .csv file
write.csv(output2, "output2.csv", row.names = F,)


