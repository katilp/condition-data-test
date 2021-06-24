# Extract database files from conditions database

Script to extract condition database files from /cvmfs/cms-opendata-conddb.cern.ch

Runs on a CMSS open data container with cvmfs mounted.

Runs a CMSSW job with the condition database area locally. Reads the missing database file from the exception message and copies it to the local area. Adds the file information to a main db file. Loops until all needed files dowloaded.

prepare.sh

find_db.sh

Tested for trigger examples, modifications needed for JEC.

