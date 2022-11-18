# Extract database files from conditions database

Script to extract condition database files needed in a CMSSW analysis job from `/cvmfs/cms-opendata-conddb.cern.ch`. 

Runs on a CMSSW open data container with cvmfs mounted on host, e.g

```
docker run -it --name my_cvmfs --volume "/cvmfs/cms-opendata-conddb.cern.ch:/cvmfs/cms-opendata-conddb.cern.ch" cmsopendata/cmssw_5_3_32-slc6_amd64_gcc472:latest /bin/bash
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

POET with PAT jets has the advantage of requiring all trigger and jet/btag related condition dbs. It is not guaranteed that they cover all usecases.

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

The output contains the database index for the selected files (with the database file path as `/cvmfs/cms-opendata-conddb.cern.ch`) and the selected database files under a folder with the GT name. 

The selected databases extracted with this tool have now been copied to `/eos/opendata/cms/conddb/selection-for-containers/cmssw_5_3_32/`.

The output contains a text dump of the index file. It is only for information and not needed for database access. It can be written in the sql format with:

```
cat file_dump.txt | sqlite3 tagname.db
```

