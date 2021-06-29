#!/bin/bash -l
# parameters: $1 package, $2 branch, $3 configuration file with path from package root
#             $4 GlobalTag 
# echo pwd `pwd`: /home/cmsusr/CMSSW_5_3_32/src
# to be run in a container with /cvmfs/cms-opendata-conddb.cern.ch mounted
# on host:
# sudo mount -t cvmfs cms-opendata-conddb.cern.ch /cvmfs/cms-opendata-conddb.cern.ch
# docker run -it --name my_cvmfs --volume "/cvmfs/cms-opendata-conddb.cern.ch:/cvmfs/cms-opendata-conddb.cern.ch" -P -p 5901:5901 cmsopendata/cmssw_5_3_32_vnc:latest /bin/bash
# Set up with prepare.sh

cd ~/CMSSW_5_3_32/src/
source /opt/cms/cmsset_default.sh

if [ -z "$1" ]; then package=TriggerInfoTool; else package=$1; fi
if [ -z "$2" ]; then branch=2011; else branch=$2; fi
if [ -z "$3" ]; then config=GeneralInfoAnalyzer/python/triggerinfoanalyzer_cfg.py; else config=$3; fi
if [ -z "$4" ]; then globaltag=FT_53_LV5_AN1; else globaltag=$4; fi
dbfile="$globaltag".db

cd $package
exception=start
i=0
echo In $(pwd)
echo Going to run $config
cat $config

while [ $exception != no ]
do
    i=$((i+1))
    n=$((2*i+1))

    cmsRun $config > full.log 2>&1 

    # find the exception from the cmsRun output
    exceptionmessage="$(awk '/Exception Message:/{flag=1;next}/----- End Fatal Exception /{flag=0}flag' full.log)"
    echo $exceptionmessage
    exception="$(echo $exceptionmessage | awk -F\" '{print $2}' | tr -d "\n")" 

    # use quotes to avoid an error message because of spaces in the string
    if [ -z "$exceptionmessage" ]
    then
        echo Hooray, no exception!
        exception=no
    else
        echo Exception is $exception
        # check if the exception name is the db file name in the listing and count how many times
        missingdbline="$(grep $exception original.txt | grep db)"
        nmatches="$(echo $missingdbline | grep -o .db | wc -l)"
        # check if the exception itself has the .db file extension
        if [ "$(echo $exception | awk -F. '{print $(NF)}')" = db ]
        then
            missingdb="$(echo $exception | awk -F \/ '{print $(NF)}')"
            echo Found $missingdb from the execption message
        # check that only one match in the db listing with the db name corresponding to the exception  
        elif [ $nmatches = 1 ]
        then
            missingdb="$(echo $missingdbline |  awk -F\' '{print $(NF-3)}' | awk -F\/ '{print $(NF)}' | grep db)"
            echo Found $missingdb from the original db list  
        else
            echo Multiple db lines corresponding to the exception message
            echo $missindbline
            # need to handle it properly, for the moment stop the loop
            missingdb=notfound
            exception=no
        fi
        
        # check if missing db has been found
        if [ $missingdb != notfound ]
        then
        # copy the missing db file from cvmfs to the local directory
        cp /cvmfs/cms-opendata-conddb.cern.ch/$globaltag/$missingdb $globaltag

        # find the db number
        dbnumber="$(echo $missingdbline  | awk -F\, '{print $(NF-2)}')"
        echo dbnumber $dbnumber

        # find the name in the tag tree corresponding to this db number
        tagtreename="$(grep \',$dbnumber, original.txt  | grep TAGTREE | awk -F\, '{print $(NF-4)}')"

        # get text file
        sqlite3  $dbfile .dump > file_dump.txt

        # add the missing line and substitute the db number with i
        newdbline="$(echo "${missingdbline/$dbnumber,/$i,}")"
        sed -i "/CREATE TABLE coral_sqlite_fk(id TEXT NOT NULL, name TEXT, tablename TEXT NOT NULL);/i $newdbline" file_dump.txt
        echo Adding line $newdbline

        # change the two numbers for lines All and Calibration to 2*i+2 and 2*i+1
        val1line="$(grep "VALUES(1," file_dump.txt)"
        echo Modifying line $val1line
        sed -i "s/$val1line/INSERT INTO TAGTREE_TABLE_"$globaltag" VALUES(1,4294967295,$((n+2)),'All',0,0,1,0);/g" file_dump.txt
        val2line="$(grep "VALUES(2," file_dump.txt)"
        sed -i "s/$val2line/INSERT INTO TAGTREE_TABLE_"$globaltag" VALUES(2,0,$((n+1)),'Calibration',0,1,2,0);/g" file_dump.txt
        echo Modifying line $val2line

        # get tag inventory total line and change it to 
        taginventory="$(grep '"TAGINVENTORY_IDS" VALUES' file_dump.txt)"
        sed -i "s/$taginventory/INSERT INTO \"TAGINVENTORY_IDS\" VALUES($i);/g" file_dump.txt
        echo Modifying line $taginventory


        # add tagtree line
        newdbfileline="INSERT INTO "TAGTREE_TABLE_"$globaltag"" VALUES($n,0,$((n+1)),$tagtreename,$i,2,$((i+2)),0);"
        sed -i "/CREATE TABLE \"TAGTREE_"$globaltag"/i $newdbfileline" file_dump.txt
        echo Adding line $newdbfileline

        # get total values 
        tagtree="$(grep 'INSERT INTO "TAGTREE_'$globaltag'' file_dump.txt)"
        sed -i "s/$tagtree/INSERT INTO TAGTREE_"$globaltag"_IDS VALUES($((i+2)));/g" file_dump.txt
        echo Modifying line 'INSERT INTO TAGTREE_'$globaltag'_IDS VALUES('$((i+2))');'

        rm $dbfile
        cat file_dump.txt | sqlite3 $dbfile
        fi
    fi

done    

echo These db files have been copied:
ls $globaltag

echo The main db file is:
cat file_dump.txt
