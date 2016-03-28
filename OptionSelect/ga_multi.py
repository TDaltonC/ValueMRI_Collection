# -*- coding: utf-8 -*-
"""
Created on Thu Aug 13 13:01:21 2015
@author: Calvin Leather

This script uses the item rankings given by participants to determine a well balanaced set of decision options.
It takes as input the excel file used to 
"""

#%%==========imports and constants=================%%#
import numpy as np
import pandas as pd
from deap import base, creator, tools
from scipy.stats import kstest, ks_2samp
import random, operator
import multiprocessing as mp
import json
import os
import matplotlib.pyplot as plt
import seaborn as sns

# Define the location of the csv file with modeled preferences, should make relative
# Three col CSV (Item-Code, Option-Type, Value)
try:
    option_text = np.loadtxt('options_to_edit.txt')
    inputSID = int(option_text)
except:
    raise ValueError('Something is wrong w options_to_edit.txt. Please edit this file with the correct SID and rerun')
csv_filepath=r'rank' + str(inputSID)+ '.xls'


#%% Magic Numbers
#nepochs-number of epochs, ngen-number of generations in an epoch
#cxpb- probability of a cross over occuring in one chromosome of a mating pair
#mutpb- probability of at each nucleotide of a mutation
#number of individuals to put in HOF in each epoc
nepochs, ngen, npop, cxpb, mutpb =2,50,250, 0.1, 0.05
n_proc = 2
    
HOFsize=1

HallOfFame=[]

n_single=20 #1 number of possibilities for singleton
n_hetero=15 #2 number of possibilities for the heterogenous bundle
n_homo=22 #3 number of possibilities for the homogeneous scaling
n_genome=n_single+n_hetero+n_homo #total number of possibilities for all cases
n_target=10 #Desired number in each chromosome


chromosomeDict={0:n_single, 1:n_hetero, 2:n_homo}

#Define the seed for the random number generator for replication purposes
#random.seed(1)
#np.random.seed(1)

#%%===========define fitness and functions=================%%#
#uni=np.random.uniform(0,60,500)

def evalFit(individual): 
    """ A weighted total of fitness scores to be maximized
    RangeCost-maximum to minimum
    SimilarityCost - number of items in both singleton and homogenous scaling
    UniformCost- Uses KS divergence to indicate distance of distribution of values from uniform distribution
    DistanceCost- Uses KS divergence to indicate differences between distributions
    Cost currently is a simple weightable summation, might be changed to F score"""
    #indiv=genoToPheno(individual)
    indiv = individual[0]
    indiv = [np.sort(indiv[0]), np.sort(indiv[1]), np.sort(indiv[2])] 
    rangeCost=3*(np.ptp(indiv[0])+np.ptp(indiv[1])+np.ptp(indiv[2]))
    diffCost = -2*np.var((np.mean(indiv[0]),np.mean(indiv[1]), np.mean(indiv[2])))
    spacingCost = 5*(np.mean(np.diff(np.hstack((0,indiv[0],60))))+np.mean(np.diff(np.hstack((0,indiv[1],60))))+np.mean(np.diff(np.hstack((0,indiv[2],60)))))
    varCost = -10*(np.power(np.var(np.diff(np.hstack((0,indiv[0],60)))),3)+np.power(np.var(np.diff(np.hstack((0,indiv[1],60)))),3)+np.power(np.var(np.diff(np.hstack((0,indiv[2],60)))),3))
    adjCost = -15*(np.sum(np.diff(indiv[0])==1)+ np.sum(np.diff(indiv[1])==1)+ np.sum(np.diff(indiv[2])==1))
    cost=rangeCost+spacingCost+varCost+rangeCost+diffCost+adjCost
    return (cost,)

def getSims(individual):
    similarityCost=np.sum(np.in1d([singletonLookup[k] for k in individual[0][0]],[ bundleLookup[k] for k in individual[0][1] ]))
    similarity2=np.sum([np.sum(c)>1 for c in [np.in1d(p,[singletonLookup[k] for k in individual[0][0]]) for p in [ bundleLookup2[w] for w in individual[0][2] ]]])
    print(similarityCost)
    print(similarity2)
    

# Creates the initial generation      
def createIndividual():
    """Creates a random individual with 11 singleton, 10 het. bundle, 10 hom. scale"""    
    return [random.sample(valueDictionary[1].keys(),n_target+1),
               random.sample(valueDictionary[2].keys(),n_target),
                random.sample(valueDictionary[3].keys(),n_target)]


# Crossover algorithm          
def nonReplicatingCross(ind1, ind2):
    """Performs a crossover in-place"""
    """Highly in need of new documentation"""
    chromosomeNumber = random.randint(0,2)
    indLength = len(ind1[chromosomeNumber])
    cxpoint = random.randint(1,indLength-1)
    child1 = np.zeros(indLength) #create a child array to use
    child2 = np.zeros(indLength)
    child1[0:cxpoint]=ind1[chromosomeNumber][0:cxpoint] #do the first half of the crossover
    child2[0:cxpoint]=ind2[chromosomeNumber][0:cxpoint]
    try:
        child1[child1==0]=[x for x in ind2[chromosomeNumber] if x not in child1][0:len(child1[child1==0])]
    except ValueError:
        pass
    if (child1[child1==0]!=[]) or (child1[child1==0]==[0]):
        child1[child1==0]=random.sample([x for x in valueDictionary[chromosomeNumber+1].keys() if x not in child1], np.sum(np.where(child1==0, 1, 0)))
    try:
        child2[child2==0]=[x for x in ind1[chromosomeNumber] if x not in child2][0:len(child2[child2==0])]
    except ValueError:
        pass
    if (child2[child2==0]!=[]) or (child2[child2==0]==[0]):
        child2[child2==0]=random.sample([x for x in valueDictionary[chromosomeNumber+1].keys() if x not in child2], np.sum(np.where(child2==0, 1, 0)))
    ind1[chromosomeNumber]=child1  #copy the child array onto the parent array (in place modification)
    ind2[chromosomeNumber]=child2
    
    return ind1, ind2
  
#Mutation algorithm      
def nonReplicatingMutate(ind,indpb):
    """Mutates an individual in place"""
    ind=np.asarray(ind) #copy indiviudal into numpy array
    for chro in range(0,3):
        for i in range(1,len(ind[chro])):
                if random.random() < indpb: #for each nucleotide, use roulette to see if there is a mutation
                            ind[chro][i]=(random.sample([x for x in valueDictionary[chro+1].keys() if x not in ind[chro]],1))[0]                                
    return ind
    del ind
    
#Maps genotype onto phenotype (item number onto value)    
def genoToPheno(individual):
    #print individual
    indiv=[np.zeros(n_target+1), np.zeros(n_target), np.zeros(n_target)]
    for chro in range(0,3):
        for i in range(len(individual[0][chro])):
            indiv[chro][i]=valueDictionary[chro+1][int(individual[0][chro][i])]
    return indiv

#checks for human error in value entry
def inputErrorCheck(raw_data):
    if not raw_data[['item1', 'item2']].applymap(np.isreal).all().all():
        raise ValueError('Custom error, ask CL : Some item value is not a number')
    if (raw_data.index>=60).any():
        raise ValueError("Custom error, ask CL : An item index is > 60")
    if raw_data.duplicated(subset=['item1', 'item2']).any():
        print(raw_data[raw_data.duplicated(subset=['item1', 'item2'])])
        raise ValueError('Custom error, ask CL : Some item value is duplicated')
    if raw_data[['item1', 'item2']].applymap(lambda x: x>30).any().any():
        raise ValueError('Item number is greater than 30')
        
def getRank(item):
    if type(item)==tuple:
        return raw_choice_dataset.loc[(raw_choice_dataset['item1']==item[0]) & (raw_choice_dataset['item2']==item[1]),'rank'].values[0] 
    else:
        raise ValueError('Custom error: Some item is not a tuple in rank ordering')

#%%==============import data from csv======================%%#
raw_choice_dataset = pd.read_excel(csv_filepath, sep=',', header=0)

inputErrorCheck(raw_choice_dataset)

valueDictionary={}
for x in range(1,4):
  #Create a dictionary/hashtable associating the unique ID assigned to each singleton or bundle to its modeled value
    placeholderValueDictionary={}
    for rows in raw_choice_dataset[raw_choice_dataset['type'].astype(int)==x].iterrows():
        #rows[1][6]=rows[1][2] # change this once modeling is done
        placeholderValueDictionary[int(rows[1]['rank'])] =float(rows[1]['rank'])
    valueDictionary[x]=placeholderValueDictionary
    
singletonLookup={}
for x in raw_choice_dataset[raw_choice_dataset['type'].astype(int)==1].iterrows():
    singletonLookup[int(x[1]['rank'])]=int(x[1]['item1'])

bundleLookup={}
for x in raw_choice_dataset[raw_choice_dataset['type'].astype(int)==2].iterrows():
 #create a dictionary/hastable that gives constituent item in homogeneous bundles
    bundleLookup[int(x[1]['rank'])]=int(x[1]['item1'])
    
bundleLookup2={}
for x in raw_choice_dataset[raw_choice_dataset['type'].astype(int)==3].iterrows():
    bundleLookup2[int(x[1]['rank'])]=(int(x[1]['item1']),int(x[1]['item2']))
#%%===============initialize toolbox=======================%%#
creator.create("FitnessMax", base.Fitness, weights=(1.0,))
creator.create("Individual", list, typecode="d", fitness=creator.FitnessMax)

stats = tools.Statistics(key=operator.attrgetter("fitness.values"))
stats.register("max", np.max)
stats.register("mean", np.mean)
stats.register("min", np.min)

toolbox = base.Toolbox()

toolbox.register("HOF", tools.HallOfFame, maxsize = 5)
toolbox.register("create_individual", createIndividual)
toolbox.register("individuals", tools.initRepeat, creator.Individual,
                 toolbox.create_individual, n=1) 
toolbox.register("population", tools.initRepeat, list, toolbox.individuals)

toolbox.register("evaluate", evalFit)

toolbox.register("mate", nonReplicatingCross)
toolbox.register("mutate", nonReplicatingMutate, indpb=.1)
toolbox.register("select", tools.selTournament, tournsize=3)


#toolbox.register('map', futures.map)

s= tools.Statistics()
s.register("max", np.max)
s.register("mean", np.mean)

log=tools.Logbook()

def main_program(pop):    
    HOF = []
    fitnesses = toolbox.map(toolbox.evaluate, pop) # eval. fitness of pop
    for ind, fit in zip(pop, fitnesses):
        ind.fitness.values = fit
    
    for g in range(ngen):  
        if g%5==0:
            print(str(g) + ' of ' + str(ngen))       
        offspring = toolbox.select(pop, len(pop)) #select which individuals to mate
        offspring = list(map(toolbox.clone, offspring))
        
        for child1, child2 in zip(offspring[::2], offspring[1::2]): #determine whether to have a cross over
            if random.random() < cxpb:
                toolbox.mate(child1[0], child2[0])
                del child1.fitness.values, child2.fitness.values
    
        for mutant in offspring: #determine whether to mutate
            if random.random() < mutpb:
                toolbox.mutate(mutant[0])
                del mutant.fitness.values      
        
        invalids = [ind for ind in offspring if not ind.fitness.valid] #assign fitness scores to new offspring
        fitnesses = toolbox.map(toolbox.evaluate, invalids)
        for ind, fit in zip(invalids, fitnesses):
            ind.fitness.values = fit  
        
        pop[:] = offspring #update population with offspring
        log.record(gen=g,**stats.compile(pop))
    return tools.selBest(pop,k=1)[0][0], log, HOF

#%%======================main==============================%%#
if __name__ == '__main__':  
    print('GA algorithm starting with the following settings:')
    print('nepochs = ' + str(nepochs) + ' ngen = ' + str(ngen) + ' npop = ' + str(npop))
    print('cxpb = ' + str(cxpb) + ' mutpb = ' + str(mutpb) + ' SID = ' + str(inputSID))
    answer = input('Are the following settings okay? (0/1)  ')
    if answer == 0:
        raise ValueError('Custom Error: Please change settings in script file')    
    
    print('initializing processing pool')
    return_var= []
    processes = []
    pool = mp.Pool(processes = n_proc)
    pop_pool = [toolbox.population(n=npop) for x in range(n_proc)]
    results = pool.map(main_program,pop_pool)
    pool.close()
    print('pool finished, outputing to JSON')    
    
    best_inds = [x[0] for x in results]
    stats = [x[1] for x in results]
    HOF_best = [x[2] for x in results]
    #plt.plot([x['min'] for x in stats[0]])
    results = best_inds
    results = [[np.sort(x[0]),np.sort(x[1]),np.sort(x[2])] for x in results]
    
    resultsFit = [evalFit([x]) for x in results]
    maxIndex = np.argmax(resultsFit)
    
    bestIndividual = results[maxIndex]
    
    singletonTransed = [singletonLookup[item] for item in bestIndividual[0]]
    median = singletonTransed[5]
    medianUntransed = bestIndividual[0][5]
    singletonTransed = np.delete(singletonTransed, 5).tolist()
    homoTransed = [bundleLookup[item] for item in bestIndividual[1]]
    heteroTransed = [bundleLookup2[item] for item in bestIndividual[2]]
    
    outputData = { 'singleton' : singletonTransed, 'homo' : homoTransed, 'hetero' : heteroTransed, 'median' : median }
    outputData = json.dumps(outputData)
    with open('jsonOut.txt', 'w') as outfile:
        outfile.write(str(outputData))

    extended = np.unique(np.hstack((np.ravel([bundleLookup[x] for x in bestIndividual[1]]), np.ravel([bundleLookup2[x] for x in bestIndividual[2]]), [singletonLookup[x] for x in bestIndividual[0]]))).tolist()
    homoTransed = [(x,x) for x in homoTransed]
    extended= [(x,0) for x in extended]
    outputDataFull  = extended+homoTransed+heteroTransed #median is in bestIndividual, so is included
    outputDataFull=sorted(outputDataFull, key = getRank)
    outputDataFull = [item[0] if item[1]==0 else item for item in outputDataFull]
    outputData = { 'options' : outputDataFull }
    outputData = json.dumps(outputData)
    with open('..\\BehavioralValueMeasurements\\jsonOutExtended.txt', 'w') as outfile:
        outfile.write(str(outputData))
    #outputDataFull=sorted(outputDataFull, key = getRank)
    #outputDataFull=sorted(outputDataFull) 
    #plt.hold(True)
    #plt.title(csv_filepath)
    #sns.set_context(rc={"figure.figsize": (8, 4)})
    #plt.bar(np.asarray(bestIndividual[0]),np.ones((1,len(bestIndividual[0])))[0], color = 'blue')
    #plt.bar(np.asarray(bestIndividual[1]),np.ones((1,len(bestIndividual[1])))[0], color = 'red')
    #plt.bar(np.asarray(bestIndividual[2]),np.ones((1,len(bestIndividual[2])))[0], color = 'green')
    #individual=[bestIndividual]
    #similarityCost=np.sum(np.in1d([singletonLookup[k] for k in individual[0][0]],[ bundleLookup[k] for k in individual[0][1] ]))
    #similarity2=np.sum([np.sum(c)>1 for c in [np.in1d(p,[singletonLookup[k] for k in individual[0][0]]) for p in [ bundleLookup2[w] for w in individual[0][2] ]]])