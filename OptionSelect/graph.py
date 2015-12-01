# -*- coding: utf-8 -*-
"""
Created on Thu Nov 05 18:42:47 2015

@author: Calvin
"""
import numpy as np
import pandas as pd
from deap import base, creator, tools
import matplotlib.pyplot as plt
from scipy.stats import kstest, ks_2samp
import random, operator, seaborn
import multiprocessing as mp
import json
import os
import seaborn as sns

plt.hold(True)
sns.set_context(rc={"figure.figsize": (8, 4)})
plt.bar(np.asarray(bestIndividual[0]),np.ones((1,len(bestIndividual[0])))[0], color = 'blue')
plt.bar(np.asarray(bestIndividual[1]),np.ones((1,len(bestIndividual[1])))[0], color = 'red')
plt.bar(np.asarray(bestIndividual[2]),np.ones((1,len(bestIndividual[2])))[0], color = 'green')
