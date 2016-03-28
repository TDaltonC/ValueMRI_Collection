# -*- coding: utf-8 -*-
"""
Created on Fri Feb 12 15:14:24 2016

@author: Calvin

MRI prep script. This script should be run before anything else is done, preferably before the subject arrives
It will create the excel file into which the elicited preference ranks are enter.
"""

import pandas as pd
import numpy as np
import os
import xlwt

check1 = 'no' #initialize while loop variables
check2 = 'no'

print('Current directory is: ' + os.getcwd())
while check1!='yes': #check if path is okay
    check1 = input("Is this path correct? Enter yes if correct: \n")

while check2 != 'yes': #request SID and prompt for okay
    SID = input('Enter subject ID: ')
    check2 = input('Is '+ SID+  ' correct?\nEnter yes if correct:\n')

num_range = np.arange(2,62).astype('str') #this creates the excel formula for bundle type
logic_vec = [xlwt.Formula('IF(B'+x+'=C'+x+',2,IF(C'+x+'=0,1,3))') for x in num_range]

empty_frame = pd.DataFrame(columns = ['rank', 'item1', 'item2', 'type']) #creates data frame
empty_frame['rank'] = range(60) #populates dataframe
empty_frame['type']=logic_vec
empty_frame.to_excel('rank'+SID+'.xls', index = False) #saves dataframe
SID = [int(SID)]
np.savetxt('options_to_edit.txt', SID, fmt='%1.0f')