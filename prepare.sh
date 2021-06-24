#!/bin/bash -l
# parameters: $1 package, $2 branch, $3 configuration file with path from package root
#             $4 GlobalTag $ GitHub orgaization/owner

cd ~/CMSSW_5_3_32/src/
source /opt/cms/cmsset_default.sh

if [ -z "$1" ]; then package=TriggerInfoTool; else package=$1; fi
if [ -z "$2" ]; then branch=2011; else branch=$2; fi
if [ -z "$3" ]; then config=GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py; else config=$3; fi
if [ -z "$4" ]; then globaltag=FT_53_LV5_AN1; else globaltag=$4; fi
if [ -z "$5" ]; then gitdir=cms-opendata-analyses; else gitdir=$4; fi

dbfile="$globaltag"_stripped.db

git clone -b $2 https://github.com/$gitdir/$package.git
cd $package/
scram b
mkdir $globaltag

curl https://raw.githubusercontent.com/katilp/condition-data-test/main/base_dump.txt > base_dump.txt
sed -i 's/replacethis/$globaltag/g' base_dump.txt
cat base_dump.txt | sqlite3 $dbfile
sqlite3 /cvmfs/cms-opendata-conddb.cern.ch/$globaltag.db .dump > original.txt

curl https://raw.githubusercontent.com/katilp/condition-data-test/main/find_db.sh > find_db.sh
