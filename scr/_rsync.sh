#!/bin/bash

TODAY=`date +%Y%m%d-%H%M`


DURATION1="30m"
DURATION2="10h"

cd
while true
do
        HOST="localhost"
        PORT="${NCPORT}0"
        DURATION=$DURATION1
        USR=$USER
        SSHKEY="/home/gaeste/m../.ssh/me.."
        REMOTEUSR="mkl"

        nc -zv 127.0.0.1 ${PORT}
        RET=$?
        echo "RET: ${RET}" 
        if [[ "${RET}" == "0" ]]
        then


                TODAY=`date +%Y%m%d-%H%M`
                echo "$TODAY"
                echo "rsync from $USR"
                # neu mit delete

                COMMAND="rsync -rltvz -e 'ssh -p $PORT -i ${SSHKEY}' --bwlimit=20 --exclude-from=exclude_$USR  $REMOTEUSR@localhost:/home/$REMOTEUSR/  /mnt/temp/backup_${USR}/backup_pc/backup/home/${REMOTEUSR}/ --backup --backup-dir=/mnt/temp/backup_${USR}/backup_pc/deleted/home/${REMOTEUSR}/ --delete"
                echo "$COMMAND"
                eval $COMMAND

                TODAY=`date +%Y%m%d-%H%M`
                echo "$TODAY -- rsync has stopped"
                DURATION=$DURATION2
        else
                echo "not reached"
        fi
        echo "sleep ${DURATION}"
        TODAY=`date +%Y%m%d-%H%M`
        echo "$TODAY -- wait"
        sleep ${DURATION}
done




