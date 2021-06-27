#!/bin/bash -l
# parameters: $1 package, $2 branch, $3 configuration file with path from package root
#             $4 GlobalTag $ GitHub organization/owner
sudo chown $USER /mnt/vol
pwd
#cd ~/CMSSW_5_3_32/src/
#source /opt/cms/cmsset_default.sh
source /opt/cms/entrypoint.sh

which git
git --version

ls /cvmfs/cms-opendata-conddb.cern.ch
