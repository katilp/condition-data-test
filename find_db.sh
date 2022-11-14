#!/bin/bash -l
# parameters: $1 package, $2 branch, $3 configuration file with path from package root
#             $4 GlobalTag 
# echo pwd `pwd`: /home/cmsusr/CMSSW_5_3_32/src
# to be run in a container with /cvmfs/cms-opendata-conddb.cern.ch mounted to /mountedcvmfs
# on host:
# sudo mount -t cvmfs cms-opendata-conddb.cern.ch /cvmfs/cms-opendata-conddb.cern.ch
# docker run -it --name my_cvmfs --volume "/cvmfs/cms-opendata-conddb.cern.ch:/mountedcvmfs/cms-opendata-conddb.cern.ch" -P -p 5901:5901 cmsopendata/cmssw_5_3_32_vnc:latest /bin/bash
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

while [ $exception != no ]
do
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
        missingdblines="$(grep $exception original.txt | grep db)"
        
        nchar=1
        while [ -z "$missingdblines" ]
        do
            var=${exception::${#exception}-$nchar}
            missingdblines="$(grep $var original.txt | grep db)"
            nchar=$((nchar+1))
        done
        
        filelist=$( ./dbname.py "$missingdblines" )
        echo Found these dbs:
        echo $filelist
        dbnlist=$( ./dbnumber.py "$missingdblines" )
        echo $dbnlist
        
        names=( $filelist )
        numbers=( $dbnlist )
        
        for index in ${!names[*]}; do
        
            i=$((i+1))
            n=$((2*i+1))
            
            missingdb=${names[$index]}
            dbnumber=${numbers[$index]}
            missingdbline=$( ./dbline.py "$missingdblines" $index )
            echo The db line is $missingdbline
        
            echo Value of missingdb is $missingdb
            echo Value of dbnumber is $dbnumber
        
            # copy the missing db file from cvmfs to the local directory
            # add a protection for large files, if they are over ~GB the GitHub workflow won't be able to handle them, set to 100M here
            filesize="$(echo "$(ls -Ssr /mountedcvmfs/cms-opendata-conddb.cern.ch/$globaltag/$missingdb)" | awk -F/ '{print $1}' )"
            if (( $filesize > 200000 ))
            then
               echo WARNING: the file $missingdb is large $filesize and not copied. The job may fail if it is really needed.
               cat /mnt/vol/db_dummy.txt | sqlite3 $missingdb
               cp $missingdb /cvmfs/cms-opendata-conddb/$globaltag/
            else   
               cp /mountedcvmfs/cms-opendata-conddb.cern.ch/$globaltag/$missingdb /cvmfs/cms-opendata-conddb/$globaltag/
            fi

            # find the name in the tag tree corresponding to this db number
            tagtreename="$(grep \',$dbnumber, original.txt  | grep TAGTREE | awk -F\, '{print $(NF-4)}')"

            # get text file
            sqlite3  $dbfile .dump > file_dump.txt

            # add the missing line and substitute the db number with i (the second substitution is to avoid error sed: -e expression #1, char 34: unknown command: `I')
            newdbline="$(echo "${missingdbline/$dbnumber,/$i,}")"
            newline="$(echo $newdbline)"
            newpath="$(echo "${newline/sqlite_file:./sqlite_file:/cvmfs/cms-opendata-conddb}")"
            newpathline="$(echo $newpath)"
            sed -i "/CREATE TABLE coral_sqlite_fk/i $newpathline" file_dump.txt
            echo Adding line $newpathline

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

            #echo The updated db file is:
            #cat file_dump.txt
            #echo These db files have been copied:
            #ls $globaltag

            rm $dbfile
            cat file_dump.txt | sqlite3 $dbfile
            cp $dbfile /cvmfs/cms-opendata-conddb/
            #else
            #  echo The file of size $filesize was not copied. The workflow may remain in a loop if it it was really needed. 
            #fi
        done
    fi

done    

if [ $i = 0 ] 
then
    echo "No condition db files needed. Are you sure? Here's the job output again:"
else  
    echo These db files have been copied:
    ls /cvmfs/cms-opendata-conddb/$globaltag

    sudo cp -r /cvmfs/cms-opendata-conddb/$globaltag /mnt/vol/outputs

    echo The main db file is:
    cat file_dump.txt

    sudo cp file_dump.txt /mnt/vol/outputs
    sudo cp $dbfile /mnt/vol/outputs
    
    echo The output of the last job:
fi

cat full.log
