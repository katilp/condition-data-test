#!/bin/bash -l
# parameters: $1 package, $2 branch, $3 configuration file with path from package root
#             $4 GlobalTag $ GitHub organization/owner
sudo chown $USER /mnt/vol
pwd
#cd ~/CMSSW_5_3_32/src/
#source /opt/cms/cmsset_default.sh
#source /opt/cms/entrypoint.sh
which git
git --version
echo Update paths:
echo $UPDATE_PATH
echo $LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${UPDATE_PATH}/lib:${LD_LIBRARY_PATH}
export PATH=${UPDATE_PATH}/bin:${PATH}
echo PATH updated to $PATH
which git
git --version

ls /cvmfs/cms-opendata-conddb.cern.ch
