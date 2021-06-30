#!/usr/bin/env python
# Find a single line from the listing missing db lines:
# INSERT INTO TAGINVENTORY_TABLE VALUES('JetCorrectorParametersCollection_Legacy11_V1_DATA_AK7JPT',
#   'JetCorrectorParametersCollection','JetCorrectionsRecord',16,
#   'sqlite_file:./FT_53_LV5_AN1/JetCorrectorParametersCollection_Legacy11_V1_DATA_AK7JPT.db','AK7JPT')
#
# run with: python2 dbnumber.py "$missingdblines" index
import sys
from re import search
   
#print 'Number of arguments:', len(sys.argv), 'arguments.'
#print 'Argument List:', str(sys.argv)

var1 = sys.argv[1]
var2 = int(sys.argv[2])
all_lines=var1.split(';')

index = 0
for n in all_lines:
    var=n
    var+=';'
    if index == var2:
        print  var
    index += 1
