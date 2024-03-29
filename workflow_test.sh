# parameters: $1 package, $2 branch, $3 configuration file with path from package root
#             $4 GlobalTag $ GitHub organization/owner

sudo chown $USER /mnt/vol
#sudo mkdir /cvmfs
sudo chown $USER /cvmfs
sudo rm -rf /cvmfs/cms-opendata-conddb.cern.ch
sudo chown $USER /opt

#echo Update paths:
#echo $UPDATE_PATH
#echo $LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=${UPDATE_PATH}/lib:${LD_LIBRARY_PATH}
#export PATH=${UPDATE_PATH}/bin:${PATH}
# echo PATH updated to $PATH
echo git versions:
which git
git --version

# ls /mountedcvmfs/cms-opendata-conddb.cern.ch

if [ -z "$1" ]; then package=TriggerInfoTool; else package=$1; fi
if [ -z "$2" ]; then branch=2011; else branch=$2; fi
if [ -z "$3" ]; then config=GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py; else config=$3; fi
if [ -z "$4" ]; then globaltag=FT_53_LV5_AN1; else globaltag=$4; fi
if [ -z "$5" ]; then gitdir=cms-opendata-analyses; else gitdir=$5; fi

dbfile="$globaltag".db

# Set up area 
echo Cloning with the https protocol
git clone -b $branch https://github.com/$gitdir/$package.git
#git clone -b $branch git://github.com/$gitdir/$package.git
cd $package/
scram b
mkdir -p /cvmfs/cms-opendata-conddb.cern.ch/$globaltag
ls -l /cvmfs/cms-opendata-conddb.cern.ch
mkdir /mnt/vol/products
ls -l /mnt/vol

# Prepare the initial main db file and the full dump

cp /mnt/vol/base_dump.txt .
sed -i 's/replacethis/'$globaltag'/g' base_dump.txt
cat base_dump.txt | sqlite3 $dbfile
xrdcp root://eospublic.cern.ch//eos/opendata/cms/conddb/$globaltag.db original.db
sqlite3 original.db .dump > original.txt
#sqlite3 /mountedcvmfs/cms-opendata-conddb.cern.ch/$globaltag.db .dump > original.txt

cp /mnt/vol/find_db.sh .
chmod +x find_db.sh
cp /mnt/vol/dbname.py .
chmod +x dbname.py
cp /mnt/vol/dbnumber.py .
chmod +x dbnumber.py
cp /mnt/vol/dbline.py .
chmod +x dbline.py
#curl https://raw.githubusercontent.com/katilp/condition-data-test/main/find_db.sh > find_db.sh

#comment the label that is missing in 2011 data
if [ $branch = 2011 ]
then
  sudo sed -i 's/softElectronByPtBJetTags/softPFElectronBJetTags/g' /cvmfs/cms.cern.ch/slc6_amd64_gcc472/cms/cmssw/CMSSW_5_3_32/src/PhysicsTools/PatAlgos/python/producersLayer1/jetProducer_cfi.py
  # sudo sed -i '/softElectronByPtBJetTags/d' /cvmfs/cms.cern.ch/slc6_amd64_gcc472/cms/cmssw/CMSSW_5_3_32/src/PhysicsTools/PatAlgos/python/producersLayer1/jetProducer_cfi.py 
  sudo sed -i '/softElectronByIP3dBJetTags/d' /cvmfs/cms.cern.ch/slc6_amd64_gcc472/cms/cmssw/CMSSW_5_3_32/src/PhysicsTools/PatAlgos/python/producersLayer1/jetProducer_cfi.py
  sudo sed -i '/softMuonByPtBJetTags/d' /cvmfs/cms.cern.ch/slc6_amd64_gcc472/cms/cmssw/CMSSW_5_3_32/src/PhysicsTools/PatAlgos/python/producersLayer1/jetProducer_cfi.py 
  sudo sed -i '/softMuonByIP3dBJetTags/d' /cvmfs/cms.cern.ch/slc6_amd64_gcc472/cms/cmssw/CMSSW_5_3_32/src/PhysicsTools/PatAlgos/python/producersLayer1/jetProducer_cfi.py
  sudo sed -i 's/softMuonBJetTags/softPFMuonBJetTags/g' /cvmfs/cms.cern.ch/slc6_amd64_gcc472/cms/cmssw/CMSSW_5_3_32/src/PhysicsTools/PatAlgos/python/producersLayer1/jetProducer_cfi.py 
fi

# FIXME: make this configurable, if cloning from the original repo's, take a local config with the needed modifications
if [ $package = TriggerInfoTool ]  && [ $gitdir = cms-opendata-analyses ]; then cp /mnt/vol/trigger_2011_cfg.py $config; fi
if [ $package = PhysObjectExtractorTool ] && [ $gitdir = cms-legacydata-analyses ]; then config=/mnt/vol/jec_cfg.py; fi

ls -l

# test run, add the second command to avoid exit on failure
# cmsRun $config || echo ignore
# cmsRun /mnt/vol/jec_cfg.py || echo ignore

./find_db.sh $package $branch $config $globaltag
