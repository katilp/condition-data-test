#!/usr/bin/env python
# find the filename in the full db line of type:
# INSERT INTO TAGINVENTORY_TABLE VALUES('JetCorrectorParametersCollection_Legacy11_V1_DATA_AK7JPT',
#   'JetCorrectorParametersCollection','JetCorrectionsRecord',16,
#   'sqlite_file:./FT_53_LV5_AN1/JetCorrectorParametersCollection_Legacy11_V1_DATA_AK7JPT.db','AK7JPT')
#
# run with: python2 dbname.py "$missingdbline"
import sys
from re import search
   
#print 'Number of arguments:', len(sys.argv), 'arguments.'
#print 'Argument List:', str(sys.argv)

var1 = sys.argv[1]
all_lines=var1.split(';')

substring = ".db"

for n in all_lines:
    split_line=n.split("'")
    for i in split_line:
        if search(substring, i):
            filepath=i.split("/")
            print filepath[2]
