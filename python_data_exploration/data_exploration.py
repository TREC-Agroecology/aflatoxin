"""
Created on Fri Apr  3 14:22:38 2020

@author: Xiaolei
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt 


# laoding data
df_all = pd.read_csv('AT_Shellman_final.csv')

# spliting data by years
year = np.unique(df_all.Year)
df_year = []
for y in year:
    df_year.append(df_all[df_all.Year == y])
    
for df in df_year:
    irrigation = np.unique(df.Irrigation)
    for irr in irrigation:
        af = df.AFTotal[df.Irrigation == irr]
        y = np.unique(df.Year)
        # number of samples
        data_length = np.shape(af)[0]
        # percentage of samples that containes low aflatoxin
        zero_perct = float(f'{np.size(af[af<3])/data_length:.2f}')
        fig = plt.figure(figsize=(10,10),dpi=72)
        plt.hist(af)
        plt.title(str(y)+' irr:'+str(irr)+' #samples:'+str(data_length)+' Low AF percentage: '+str(zero_perct),fontsize = 15)
        plt.show()
        fig.savefig(str(y)+str(irr)+'_'+'AFTotal'+'.png')
