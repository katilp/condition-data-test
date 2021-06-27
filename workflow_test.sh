#!/bin/bash -l
# parameters: $1 package, $2 branch, $3 configuration file with path from package root
#             $4 GlobalTag $ GitHub organization/owner
sudo chown $USER /mnt/vol

echo Update paths:
echo $UPDATE_PATH
echo $LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${UPDATE_PATH}/lib:${LD_LIBRARY_PATH}
export PATH=${UPDATE_PATH}/bin:${PATH}
echo PATH updated to $PATH
echo git versions:
which git
git --version
echo openssl versions:
which openssl
openssl version
echo Checking /usr/local/bin/git and openssl
ls -l /usr/local/bin/git*
ls -l /usr/local/bin/open*
echo Checking /usr/local/libexec
ls -l /usr/local/libexec
echo Checking CMS env
which cmsRun



ls /cvmfs/cms-opendata-conddb.cern.ch

if [ -z "$1" ]; then package=TriggerInfoTool; else package=$1; fi
if [ -z "$2" ]; then branch=2011; else branch=$2; fi
if [ -z "$3" ]; then config=GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py; else config=$3; fi
if [ -z "$4" ]; then globaltag=FT_53_LV5_AN1; else globaltag=$4; fi
if [ -z "$5" ]; then gitdir=cms-opendata-analyses; else gitdir=$5; fi

dbfile="$globaltag".db

# Set up area 
echo Cloning with the git protocol for now
#git clone -b $branch https://github.com/$gitdir/$package.git
git clone -b $branch git://github.com/$gitdir/$package.git
cd $package/
scram b
mkdir $globaltag

# Prepare the initial main db file and the full dump

cp /mnt/vol/base_dump.txt .
sed -i 's/replacethis/'$globaltag'/g' base_dump.txt
cat base_dump.txt | sqlite3 $dbfile
sqlite3 /cvmfs/cms-opendata-conddb.cern.ch/$globaltag.db .dump > original.txt

cp /mnt/vol/find_db.sh .
#curl https://raw.githubusercontent.com/katilp/condition-data-test/main/find_db.sh > find_db.sh

# FIXME: make this configurable
cp /mnt/vol/trigger_2011_cfg.py $package/$config

ls -l
