# -*- coding: utf-8 -*-
"""
Created on Mon Feb  9 15:44:06 2015

@author: Dalton
"""
#%% Imports
import numpy as np
import pandas as pd
from joblib import Parallel, delayed

#%% Functions

def isX(string,test):
    if string == test:
        return 1
    else:
        return 0
findX = np.vectorize(isX)

#finds, for each element is array, the nearest X and it's distance
def MinDistancetoX(array,index,X):
    targets = array.index[array==X]
    distance = np.abs(targets - index)
    winners = np.where(distance == distance.min())
    winnerindex = targets[np.random.choice(winners[0])]
    return  winnerindex, distance.min()
MinDistancetoX_VEC = np.vectorize(MinDistancetoX,excluded =['array'])

def midwayYForRangeofX(array,X,Y):
    Xtargets = array.index[array==X]
    Ytargets = array.index[array==Y]
    low = Xtargets.min()
    high= Xtargets.max()
    midway = (float(high)+float(low))/2
    distance = np.abs(Ytargets.astype(float) - midway)
    winners = np.where(distance == distance.min())
    midwayY = Ytargets[np.random.choice(winners[0])]
    return low, high, midwayY

#%% Create a random ordering if none is provided

if __name__ == "__main__":
    singleton = np.chararray(20)
    singleton[:] = 'a'
    
    scaled = np.chararray(14)
    scaled[:] = 'b'
    
    bundled = np.chararray(14)
    bundled[:] = 'c'
    
    orderedItems = np.concatenate((singleton,scaled,bundled))
    np.random.shuffle(orderedItems)

#%% Create DataFrames
FinalDF = pd.DataFrame( data = {'orderedItems':orderedItems})
#dropingDF = pd.DataFrame( data = {'orderedItems':orderedItems})
    

#%% Find the distance to every element type
#
#dropingDF['closestA'], dropingDF['distancetoA'] = MinDistancetoX_VEC(array = dropingDF.orderedItems,
#                                                  index = dropingDF.index,
#                                                  X = 'a')
#                                                  
#dropingDF['closestB'], dropingDF['distancetoB'] = MinDistancetoX_VEC(array = dropingDF.orderedItems,
#                                                  index = dropingDF.index,
#                                                  X = 'b') 
#
#dropingDF['closestC'], dropingDF['distancetoC'] = MinDistancetoX_VEC(array = dropingDF.orderedItems,
#                                                  index = dropingDF.index,
#                                                  X = 'c')
#                                                  
#dropingDF['tripletSize'] = dropingDF['distancetoA'] + dropingDF['distancetoB']

#%%select out 'X'-centered tripplets tightest to loosest

parralellAttepts = 100
desiredNumberOfTriplets = 10

for attempt in range(0,parralellAttepts): # This loop creates 1 set of candidate options
    dropingDF = pd.DataFrame( data = {'orderedItems':orderedItems})
    minC, maxC, controlOption = midwayYForRangeofX(dropingDF.orderedItems,'c','a')
    dropingDF.drop(controlOption,inplace = True) 
    optionsToUse = np.array([controlOption])
    for triplet in range(0,desiredNumberOfTriplets): # This loop pulls one triplet 
#           Remove the midpoint 'a' to make it a control option
            while 0==0: 
                
                dropingDF['closestA'], dropingDF['distancetoA'] = MinDistancetoX_VEC(array = dropingDF.orderedItems,
                                                      index = dropingDF.index,
                                                      X = 'a')
                                                      
                dropingDF['closestB'], dropingDF['distancetoB'] = MinDistancetoX_VEC(array = dropingDF.orderedItems,
                                                      index = dropingDF.index,
                                                      X = 'b') 
    
                dropingDF['closestC'], dropingDF['distancetoC'] = MinDistancetoX_VEC(array = dropingDF.orderedItems,
                                                      index = dropingDF.index,
                                                      X = 'c')
                                                      
                dropingDF['tripletSize'] = dropingDF['distancetoA'] + dropingDF['distancetoB']
                Ccentered = dropingDF[dropingDF['distancetoC']==0]
                
                setofSmallestTrpilets= Ccentered.index[Ccentered['tripletSize'] == Ccentered['tripletSize'].min()]
                winningTripletCenter = np.random.choice(setofSmallestTrpilets)
                winningItems = np.array((winningTripletCenter,
                                        dropingDF.closestA[dropingDF.index == winningTripletCenter],
                                        dropingDF.closestB[dropingDF.index == winningTripletCenter]))
            
                # Compare the new winners to the old winners.
                overlap = np.intersect1d(optionsToUse,winningItems)
                if len(overlap)==0:
                     # Add the index of the new winners to a list of all winners including the contol option
                    optionsToUse = np.append(optionsToUse,winningItems)
                    # Remove the winners from dateFrame
                    dropingDF.drop(winningItems,inplace = True)
                    break
                else:
                    print "oops"
                
                
            # Add the index of the new winners to a list of all winners including the contol option
            
            
        
    # Return the complete list of winners.
        
    optionsToUse = np.sort(optionsToUse)
    using = pd.DataFrame(data = {'using'+str(attempt):np.ones(len(optionsToUse))},index = optionsToUse)
    FinalDF = FinalDF.join(using)

