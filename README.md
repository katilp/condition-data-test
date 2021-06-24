# Extract database files from conditions database

Script to extract condition database files from /cvmfs/cms-opendata-conddb.cern.ch

Runs on a CMSS open data container with cvmfs mounted.

Runs a CMSSW job with the condition database area locally. Reads the missing database file from the exception message and copies it to the local area. Adds the file information to a main db file. Loops until all needed files dowloaded.

Parameters and defaults:

- $1 package - TriggerInfoTool
- $2 branch - 2011 
- $3 configuration file - GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py
- $4 GlobalTag - FT_53_LV5_AN1
- $5 GitHub orgaization/owner - cms-opendata-analyses

## prepare.sh

```
curl https://raw.githubusercontent.com/katilp/condition-data-test/main/prepare.sh > prepare.sh
chmod +x prepare.sh
./prepare.sh
```

Change the input file and the GlobalTag if needed in the config file and check that the GlobalTag commands are of form

```
process.GlobalTag.connect = cms.string('sqlite_file:<global-tag-name>_stripped.db')
process.GlobalTag.globaltag = '<global-tag-name>::All'
```

and that the number of events is small.

## find_db.sh

```
curl https://raw.githubusercontent.com/katilp/condition-data-test/main/find_db.sh > find_db.sh
chmod +x find_db.sh
./find_db.sh
```

Tested for trigger examples, modifications needed for JEC.

