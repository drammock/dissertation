#!/usr/bin/python
""" 
# BATCH RUN PRAAT PROSODIC REPLACEMENT
# This script takes as input a tab-delimited file with two columns of file basenames (segmental donor and prosodic donor) and runs those row by row through a praat script that maps the pitch, duration, and intensity from the prosodic donor onto the segmental donor.  The praat script outputs a manipulation object and resynthesized wav file (both to the same folder). 
#
# ARGUMENTS TO THE PYTHON SCRIPT:
# fileList (tab-delimited file of basename pairs. column1: segmental donor; column 2: prosodic donor)
# manipDir, tgridDir (directories of the manipulation files and TextGrid files, respectively)
# outputDir (directory to write resynthesized files to)
# segTierNum, proTierNum (integers, tier number of TextGrids to use for duration mapping)
#
# ORDER OF ARGUMENTS TO THE PRAAT SCRIPT:
# segmentalDonor.Manipulation (file)
# segmentalDonor.TextGrid (file)
# segmentalDonorTierNumber (integer)
# prosodicDonor.Manipulation (file)
# prosodicDonor.TextGrid (file)
# prosodicDonorTierNumber (integer)
# outputDirectory (folder)
"""

import os
import csv
import sys
from subprocess import call

basenamePairs = sys.argv[1]
manipDir = sys.argv[2]
tgridDir = sys.argv[3]
outputDir = sys.argv[4]
segTierNum = sys.argv[5]
proTierNum = sys.argv[6]
segBaseList = []
proBaseList = []

with open(basenamePairs,'r') as b:
#	next(b) # skip header row
	basenamePairList = csv.reader(b,delimiter='\t')
	for seg, pro in basenamePairList:
		segBaseList.append(seg)
		proBaseList.append(pro)

segManipList = [os.path.join(manipDir, s + '.Manipulation') for s in segBaseList]
segTgridList = [os.path.join(tgridDir, s + '.TextGrid') for s in segBaseList]
proManipList = [os.path.join(manipDir, s + '.Manipulation') for s in proBaseList]
proTgridList = [os.path.join(tgridDir, s + '.TextGrid') for s in proBaseList]

for i,sml in enumerate(segManipList):	
	call(['praat', '/home/dan/Documents/academics/research/dissertation/scripts/ReplaceProsodyPSOLA.praat', segManipList[i], segTgridList[i], segTierNum, proManipList[i], proTgridList[i], proTierNum, outputDir])

