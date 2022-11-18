# Extract database files from conditions database

Script to extract condition database files needed in a CMSSW analysis job from `/cvmfs/cms-opendata-conddb.cern.ch`. 

Runs on a CMSSW open data container with cvmfs mounted on host, e.g

```
docker run -it --name my_cvmfs --volume "/cvmfs/cms-opendata-conddb.cern.ch:/cvmfs/cms-opendata-conddb.cern.ch" cmsopendata/cmssw_5_3_32_vnc:latest /bin/bash
```

Runs a CMSSW job with the condition database area locally. Reads the missing database file from the exception message and copies it to the local area. Adds the file information to a main db file. Loops until all needed files dowloaded.

## Parameters and defaults:

```
- $1 package - TriggerInfoTool
- $2 branch - 2011 (note that for TriggerInfoTool there no separate 2012 branch, 2011 is used also for 2012 
- $3 configuration file - GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py
- $4 GlobalTag - FT_53_LV5_AN1
- $5 GitHub orgainzation/owner - cms-opendata-analyses
```

If TriggerInfoTool or PhysObjectExtractor are given as package, a local config with the needed modification for GT settings is used. For POET, configs are taken from a fork with hardcoded data or MC option, the Global Tag connect settings for this test and the PAT option (poet_cfg_data.py and poet_cfg_mc.py) respectively.

For 2011 branch, b-discrimininators defined in PhysicsTools/PatAlgos/python/producersLayer1/jetProducer_cfi.py are changed to those available in data.



## Scripts

The script is in two parts: `test_workflow.sh` which set ups the working area and `find_db.sh` which runs the job. It runs from a GitHib workflow where a GitHub repository and a GT (one of those available on `/cvmfs/cms-opendata-conddb.cern.ch/`) can be used as input.

Change the input file and the GlobalTag if needed in the config file and check that the GlobalTag commands are of form

```
process.GlobalTag.connect = cms.string('sqlite_file:<global-tag-name>.db')
process.GlobalTag.globaltag = '<global-tag-name>::All'
```

and that the number of events is small.

## GitHub action output

The GitHub action workflow writes he db files (copied from `/cvmfs/cms-opendata-conddb.cern.ch/<global-tag-name>`), updated stripped main db file `<global-tag-name>.db` and the text dump of it are in the artifact.

Due to some instability (input/output errors for reading from `/cvmfs`), the db files are now read from `/eos/opendata/cms/conddb/`. This area contains all OD condition data.


## Output directory

An example output from TriggerInfoTool is in the output directory. For the trigger info test, the following database files are needed in order to run the job without external database access:

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
- [trigger_2012_dbfile_dump.txt](output/trigger_2012_dbfile_dump.txt)
- [trigger_2011_dbfile_dump.txt](output/trigger_2011_dbfile_dump.txt)

The database files can be generated with 

```
cat file_dump.txt | sqlite3 tagname.db
```

