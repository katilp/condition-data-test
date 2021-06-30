#!/usr/bin/env python
# find the db number in the full db line of type:
# INSERT INTO TAGINVENTORY_TABLE VALUES('JetCorrectorParametersCollection_Legacy11_V1_DATA_AK7JPT',
#   'JetCorrectorParametersCollection','JetCorrectionsRecord',16,
#   'sqlite_file:./FT_53_LV5_AN1/JetCorrectorParametersCollection_Legacy11_V1_DATA_AK7JPT.db','AK7JPT')
#
# run with: python2 dbnumber.py "$missingdbline"
import sys
from re import search
   
#print 'Number of arguments:', len(sys.argv), 'arguments.'
#print 'Argument List:', str(sys.argv)

var1 = sys.argv[1]
all_lines=var1.split(';')

for n in all_lines:
    index = 0
    split_line=n.split("'")
    for i in split_line:
        if index == 6:
             dbn=i.split(",")
             print dbn[1]
        index += 1
