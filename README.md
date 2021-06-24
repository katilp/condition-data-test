# Extract database files from conditions database

Script to extract condition database files from /cvmfs/cms-opendata-conddb.cern.ch

Runs on a CMSSW open data container with cvmfs mounted on host, e.g

```
docker run -it --name my_cvmfs --volume "/cvmfs/cms-opendata-conddb.cern.ch:/cvmfs/cms-opendata-conddb.cern.ch" cmsopendata/cmssw_5_3_32_vnc:latest /bin/bash
```

Runs a CMSSW job with the condition database area locally. Reads the missing database file from the exception message and copies it to the local area. Adds the file information to a main db file. Loops until all needed files dowloaded.

Parameters and defaults:

```
- $1 package - TriggerInfoTool
- $2 branch - 2011 (note that for TriggerInfoTool there no separate 2012 branch, 2011 is used also for 2012 
- $3 configuration file - GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py
- $4 GlobalTag - FT_53_LV5_AN1
- $5 GitHub orgaization/owner - cms-opendata-analyses
```

## prepare.sh

```
curl https://raw.githubusercontent.com/katilp/condition-data-test/main/prepare.sh > prepare.sh
chmod +x prepare.sh
./prepare.sh
```

The default is 2011 trigger test, for 2012 use

```
./prepare.sh TriggerInfoTool 2011 GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py FT53_V21A_AN6_FULL
```

2011 as a parameter is not a mistake, it is the branch name.

Change the input file and the GlobalTag if needed in the config file and check that the GlobalTag commands are of form

```
process.GlobalTag.connect = cms.string('sqlite_file:<global-tag-name>.db')
process.GlobalTag.globaltag = '<global-tag-name>::All'
```

and that the number of events is small.

Alternatively, curl the  already modified config files

```
curl https://raw.githubusercontent.com/katilp/condition-data-test/main/trigger_2011_cfg.py > TriggerInfoTool/GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py
```

or 

```
curl https://raw.githubusercontent.com/katilp/condition-data-test/main/trigger_2012_cfg.py >  TriggerInfoTool/GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py
```




## find_db.sh

```
curl https://raw.githubusercontent.com/katilp/condition-data-test/main/find_db.sh > find_db.sh
chmod +x find_db.sh
./find_db.sh
```
The default is 2011 trigger test, for 2012 use

```
./find_db.sh TriggerInfoTool 2011 GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py FT53_V21A_AN6_FULL
```

Again, 2011 is not a mistake (and has no effect).

Tested for trigger examples, modifications needed for JEC.

## Output

For the trigger info test, the following database files are needed in order to run the job without external database access:

```
L1GtPrescaleFactorsAlgoTrig_CRAFT09v2_hlt.db
L1GtPrescaleFactorsTechTrig_CRAFT09v2_hlt.db
L1GtStableParameters_CRAFT09_hlt.db
L1GtTriggerMaskAlgoTrig_CRAFT09v2_hlt.db
L1GtTriggerMaskTechTrig_CRAFT09v2_hlt.db
L1GtTriggerMaskVetoAlgoTrig_CRAFT09_hlt.db
L1GtTriggerMaskVetoTechTrig_CRAFT09v2_hlt.db
L1GtTriggerMenu_CRAFT09_hlt.db
```
The file names are identical for the two years, but the files are not the same:

2011:

```
$ ls -l FT_53_LV5_AN1
total 1908
-rw-r--r-- 1 cmsusr cmsusr 598016 Jun 24 21:28 L1GtPrescaleFactorsAlgoTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr 266240 Jun 24 21:29 L1GtPrescaleFactorsTechTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr  38912 Jun 24 21:27 L1GtStableParameters_CRAFT09_hlt.db
-rw-r--r-- 1 cmsusr cmsusr 236544 Jun 24 21:30 L1GtTriggerMaskAlgoTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr 219136 Jun 24 21:31 L1GtTriggerMaskTechTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr  34816 Jun 24 21:31 L1GtTriggerMaskVetoAlgoTrig_CRAFT09_hlt.db
-rw-r--r-- 1 cmsusr cmsusr 128000 Jun 24 21:32 L1GtTriggerMaskVetoTechTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr 419840 Jun 24 21:33 L1GtTriggerMenu_CRAFT09_hlt.db
```


2012:

```
$ ls -l FT53_V21A_AN6_FULL
total 4452
-rw-r--r-- 1 cmsusr cmsusr 1369088 Jun 24 21:04 L1GtPrescaleFactorsAlgoTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr  670720 Jun 24 21:05 L1GtPrescaleFactorsTechTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr   38912 Jun 24 21:03 L1GtStableParameters_CRAFT09_hlt.db
-rw-r--r-- 1 cmsusr cmsusr  627712 Jun 24 21:05 L1GtTriggerMaskAlgoTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr  522240 Jun 24 21:06 L1GtTriggerMaskTechTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr   34816 Jun 24 21:07 L1GtTriggerMaskVetoAlgoTrig_CRAFT09_hlt.db
-rw-r--r-- 1 cmsusr cmsusr  277504 Jun 24 21:07 L1GtTriggerMaskVetoTechTrig_CRAFT09v2_hlt.db
-rw-r--r-- 1 cmsusr cmsusr 1002496 Jun 24 21:08 L1GtTriggerMenu_CRAFT09_hlt.db
```

The corresponding database dumps are in
- [output/trigger_2012_dbfile_dump.txt]
- [output/trigger_2011_dbfile_dump.txt]

The database files can be generated with 

```
cat file_dump.txt | sqlite3 tagname.db
```

