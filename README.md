Aflatoxin (AT) modelling project

The repository contains these folders:

Raw_data: here are the raw data files stored that where sent to me from Shannon McAmis
R_data_wrangling: This folder contains an R project to clean the data provided by Shannon

# PeanutAflatoxinProject

***
There are three different models to assess aflatoxin level in peanut. 
***
## Bowen (Auburn)
### Objective
  - To develop a model to predict aflatoxin contamination in peanut in order to better manage a peanut crop to minimize this problem
  - To determine specific periods of temperature and moisture conditions prior to harvest that would define environments with high risk for aflatoxin contamination in peanuts 

### Details
- Total aflatoxin concentrations (parts per billion, ppb) were averaged over these 16 samples and natural log-transformed (TPPB): ln(ppb + 1 ) to normalize the data prior to analyses.
- The proportion of samples with greater than 20 ppb aflatoxins = PGT20
- PGT20 = -328.5 + 3.34*d3d.4wk + 9.136*MaxT.6wk
- PGT20 = 1.15 * d3d.4wk - 13.34, (MaxT.6wk <= 31.5) 
- PGT20 = 14.03 * d3d.4wk - 209.48 (MaxT.6wk > 31.5)
- `d3d.4wk` : the cumulative number of 3 consecutive dry (,2.54 cm rain) days over the 4 wk period ending the day of inversion.
- `MaxT.6wk` : the maximum daily temperature averaged over 6 wk prior to inversion. 
- `PGT20` : the proportion of samples with ppb > 20 and is used to reflect risk for aflatoxin contamination. 
- At least 16 samples from each site-inversion date were assayed for aflatoxinscumulative number of 3-d-dry periods over 4 wk prior to harvest

   - `no risk` : TPPB = 0 and PGT20 = 0, 
   - `low` : TPPB > 0 and PGT20 = 0, 
   - `moderate` : TPPB > 0 and PGT20 > 0,
   - `high` : had PGT20 >= 30%. 
 
***
## APSIM (Australia)
### Objective
- the development of a new model, which uses a novel crop simulation approach to assess the risk of contamination, its validation and application in aflatoxin research and as a decision-support tool by peanut growers.
### Columns
- `Date` : Year-Month-Day
- `Days after planting` : the date to start accumulating degree days, starting with the planting date, start date of the period = 0
- `Min Temp. (°C)` : Minimum daily temperatures in degree Celsius.
- `Max Temp. (°C)` : Maximum daily temperatures in degree Celsius.
- `Precip. & Irrigation (in)` : the amount of daily rainfall and irrigation in inches  
- `Weather Station ET (in)` : to schedule irrigation system. The weather station calculate potential evapotranspiration, which is the amount of water lost from the soil due to evaporation and plant transpiration.
- `Daily GDD`	: (Max Temp.+ Min Temp.)/2 - Tbase, Tbase=13.3 in peanut [Reference](https://edis.ifas.ufl.edu/publication/AE428)
- `Corrected GDD`	: If Daily GDD <= 0, Corrected GDD is 0. Otherwise, Corrected GDD = Daily GDD. 
- `Cum. GDDs`	: a cumulative sum of Corrected GDD since yesterday + Corrected GDD today, Forecasting GDD accumulation helps growers in scheduling. 
- `Root Depth (in)` :	= If Cum. GDDs <750, Root Depth = 12+(36-12)*((Cum.GDDs - starting day's Cum.GDDs)/(750-starting day's Cum.GDDs)). Otherwise, Root Depth is 36. Estimating soil water content in the root zone.
- `PAW (in)` : Potential available Water = Available Water Capacity * Root Depth	
- `Kc Curve`	: Crop coefficients (KC) are the ratio of the evapotranspiration of the crop to a reference crop, estimating crop irrigation requirements using meteorological data
 
   - **0.3** for 0<x<325, 
   - **0.3 +((x-325)/475)*(1-0.3)** for 325<x<800,
   - **1** for 800<x<1350,
   - **1+((x-1350)/300)*(0.6-1)** for 1350<x<1650, 
   - **0.6+((x-1650)/50)*(0.2-0.4)** for 1650<x<1700, 
   - **0.2** for x>1650 
   - `**x = Cum.GDDs)**`

- `Available Water Capacity`

   - **Less than 0.10** : Sands, and loamy sands and sandy loams in which the sand is not dominated by very fine sand			  
   - **0.10 - 0.15** : Loamy sands and sandy loams in which very fine sand is the dominant sand fraction, and loams, clay loam, sandy clay loam, and sandy clay
   - **0.10 - 0.20** : Silty clay, and clay
   - **0.15 - 0.25** : Silt, silt loam, and silty clay loam

- `Final Soil Water Balance` : Beginning soil water balance -(Weather Station ET * Kc Curve)+ Precip. Irrigation  
- `Soil Water Balance` : PAW for Final Soil Water Balance > PAW, and Final Soil Water Balance for Paw >= Final Soil Water Balance. 	
- `Irrigation Recommendation` 

   - `"IRRIGATE"` for Final Soil Water Balance<(0.51*PAW),
   - `"CHECK FIELD"` for Final Soil Water Balance<(0.6*PAW),
   - otherwise, `"ADEQUATE SOIL MOISTURE "`.

- `Afltoxin Drought Threshold` : `PAW` * 0.2
- `Aflatoxin Temp Factor(ATF)` 
   - For daily mean soil temperature (STemp) <22 °C or >35 °C, ATF=0
   - For 22°C <= daily mean soil temperature < 30°C, ATF=(STemp-22)/(30-22)
   - For 30°C <= daily mean soil temperature < 35°C, ATF=(35-STemp)/(35-30)
 
     - __ATF*3__

- `ATF < 20%` : ATF for Final Water Balance < Aflatoxin Drought Threshold, otherwise 0.
- `Aflatoxin Risk Index` : =IF(SUMIFS(H2:H201,D2:D201,">1350")>100,100,SUMIFS(H2:H201,D2:D201,">1350"))

## DSSAT-CROPGRO (Shannon McAmis)
```
Equation 1 
AFINFE(NPP)=AFINFE(NPP)+(SHELN(NPP)-AFINFE(NPP))*R_1*(1.0-SWBAR)*(1.0-SWFAC)*CURV('QDR^',22,33,35,45,ST(1))
```

- Where:
  - `AFINFE(NPP)` : the number of aspergillus infected pods in a specific cohort
  - `SHELN(NPP)` : the number of shells in a specific cohort
  - `R1` : a rate constant
  - `SWBAR` : soil water status of the first 15cm
  - `SWFAC` : an index of plant water stress and represents root water uptake divided by transpiration demand
  - `CURV` : temperature function dependent on base optimal and max temperatures of aspergillus infection
  - `ST(1)` : soil temperature of the first layer




```
Equation 2
AFMASS(NPP=AFMASS(NPP)+AFINFE(NPP)*R_3*(1.0-SWFAC)  *(CURV('QDR^',26,28,29,32,ST(1)))
```


- Where:
  - `AFMASS(NPP)` : the aflatoxin mass of a specific cohort
  - `AFINFE(NPP)` : the number of aspergillus infected pods in a specific cohort
  - `R3` : a rate constant
  - `SWFAC` : an index of plant water stress and represents root water uptake divided by transpiration demand
  - `CURV` : temperature function dependent on base optimal and max temperatures of aflatoxin production
  - `ST(1)` : soil temperature at 2.5 cm
