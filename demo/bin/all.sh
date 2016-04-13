#!/bin/bash

# --------------------------------------------------------------------------
# Copyright 2015 by Richard Albrecht
# richard.albrecht@rleofield.de
# www.rleofield.de
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------


RSNAPSHOTS="demotestdaten"

TODAY=`date +%Y%m%d-%H%M`


WORKINGDIR="/home/rleo/demo/bin"
LOGFILE="${WORKINGDIR}/rs_all.log"


function log {
  echo "$1" | tee -a $LOGFILE
}


cd  ${WORKINGDIR}
 

log "===="
log "$TODAY"

testmode=0
hostexists=1

if [ "$1" = "--test" ]; then
        testmode=1
	log " ==> is test  <=="
        shift
fi


INTERVAL=$(basename "$0" .sh)

CONFFOLDER="${WORKINGDIR}/conf"
#echo "$CONFFOLDER"



for RSNAPSHOT_CFG in ${RSNAPSHOTS}
do
	RSNAPSHOT_CONFIG=rsnapshot_${RSNAPSHOT_CFG}.conf
#	log "$RSNAPSHOT_CONFIG"
	RSNAPSHOT_ROOT=$(cat $CONFFOLDER/${RSNAPSHOT_CONFIG} | grep ^snapshot_root | awk '{print $2}')
	log "interval: ${INTERVAL}"
	log "root folder: $RSNAPSHOT_ROOT"

	if [ ! -d $RSNAPSHOT_ROOT ]
	then
        	log "snapshot root folder '$RSNAPSHOT_ROOT' doesn't exist" 
	        log "give up, also don't do remaining rsnapshots"
		exit 
		
	fi
	RSNAPSHOT_PRE=pre_${RSNAPSHOT_CFG}.sh
	if [  -f $RSNAPSHOT_PRE ]
	then
	
		(./$RSNAPSHOT_PRE)
               	PRE=$?
#	       	echo "pre: $PRE"
               	if [ "$PRE"  != 0 ]
               	then
                      log "'$RSNAPSHOT_PRE' failed, host 'v$RSNAPSHOT_CFG' doesn't exist"
#			log "give up
#			log "give up set hostexists to 0"
			hostexists=0
                      
	      	else
		      log "'$RSNAPSHOT_PRE' ok"
               	fi
       	else
        	log "'$RSNAPSHOT_PRE' doesn't exist, assume ok"
	fi	


#	log "/usr/bin/rsnapshot -c $CONFFOLDER/${RSNAPSHOT_CONFIG} $INTERVAL"
	if [ $testmode  = 0 ]
	then
		
		if [ $hostexists = 1 ]
		then
#			echo "cat $CONFFOLDER/${RSNAPSHOT_CONFIG} | grep ^retain | grep $INTERVAL"
			WC=$(cat $CONFFOLDER/${RSNAPSHOT_CONFIG} | grep ^retain | grep $INTERVAL | wc -l)
			if [ $WC = 1 ]
			then
		
				log "WC: $WC"
				log "==> execute -->: /usr/bin/rsnapshot -c $CONFFOLDER/${RSNAPSHOT_CONFIG} ${INTERVAL}"
				TODAY=`date +%Y%m%d-%H%M`
				log "$TODAY" 

				FIRST_INTERVAL=$(cat $CONFFOLDER/${RSNAPSHOT_CONFIG} | grep ^retain | awk 'NR==1'| awk '{print $2}')
				log "first retain value: ${FIRST_INTERVAL}" 

				log "cat $CONFFOLDER/${RSNAPSHOT_CONFIG} | grep ^sync_first |  wc -l"
				WC=$(cat $CONFFOLDER/${RSNAPSHOT_CONFIG} | grep ^sync_first |  wc -l)
				RET=0

                                TODAY=`date +%Y%m%d-%H%M`
				RLOG="${WORKINGDIR}/${RSNAPSHOT_CFG}_${INTERVAL}.log"
				if [  $WC = 1 ] && [  "${FIRST_INTERVAL}" =  "$INTERVAL" ]
				then
					log "run sync: /usr/bin/rsnapshot -c $CONFFOLDER/${RSNAPSHOT_CONFIG} sync"
					TODAY=`date +%Y%m%d-%H%M`
					#RLOG="log/${RSNAPSHOT_CFG}_${INTERVAL}_${TODAY}.log"
					echo ¨$RLOG¨ 
					echo "start sync -- $TODAY" >> ${RLOG}
 					/usr/bin/rsnapshot -c $CONFFOLDER/${RSNAPSHOT_CONFIG} sync >> ${RLOG}
					TODAY=`date +%Y%m%d-%H%M`
					echo "end   sync -- $TODAY" >> ${RLOG}
					echo "created at: ${TODAY}" > $RSNAPSHOT_ROOT/.sync/created_at_${TODAY}.txt

					RET=$?
				fi
				if [ $RET = 0 ] 
				then
					## write file date in name to sync disk

					
					echo "run    : /usr/bin/rsnapshot -c $CONFFOLDER/${RSNAPSHOT_CONFIG} ${INTERVAL}"
					echo "RLOG: $RLOG "
					TODAY=`date +%Y%m%d-%H%M`
					echo "start ${INTERVAL} -- $TODAY" >> ${RLOG}
					/usr/bin/rsnapshot -c $CONFFOLDER/${RSNAPSHOT_CONFIG} ${INTERVAL} >> ${RLOG}
					RET=$?
					log "RET: $RET" 
					TODAY=`date +%Y%m%d-%H%M`
					echo "end   ${INTERVAL} -- $TODAY" >> ${RLOG}
					if [ $RET != 0 ]
					then
						log "==> Error in rsnapshop, in '$CONFFOLDER/${RSNAPSHOT_CONFIG}' "
					fi
				else
						log "==> RET bei .sync war nicht 0, ......... Error in rsnapshop  sync, in '$CONFFOLDER/${RSNAPSHOT_CONFIG}' "
						log "==> Error in rsnapshop  sync, in '$CONFFOLDER/${RSNAPSHOT_CONFIG}' "
				fi
				RET=0
			else
				log "==> don't execute -->: '${RSNAPSHOT_CFG}', interval '$INTERVAL' not in '$CONFFOLDER/${RSNAPSHOT_CONFIG}' "
			fi
		else
			log "hostexists = false"
			log "==> don't execute rsnapshot -->: source host '${RSNAPSHOT_CFG}' doesn't exist "
		fi
	fi
		

	hostexists=1
done


#exit	

#INTERVAL="daily"


TODAY7=`date +%Y%m%d-%H%M`
log ""
log "first done"
log "$TODAY7"
log "===="
if [ "$INTERVAL" != "daily" ]
then
	log "don't copy snapshot to extern disk, period is not daily"
	if [ $testmode  = 0 ]
	then
		log 'finish'
		exit
	else
		log 'finish, no exit, is testmode'
	fi
fi


# compare with diff --no-dereference
# diff --no-dereference -r /home/rleo/demo/rs/ /home/rleo/demo/rs2/


log "copy snapshot to extern disk, period is 'daily'"

RSNAPSHOTS="demotestdaten"


# final copy
 
SOURCE=/home/rleo/demo
TARGET=/home/rleo/demo

MARKER_SOURCE="${SOURCE}"
MARKER_TARGET="${TARGET}"

SOURCE=${SOURCE}/rs
TARGET=${TARGET}/rs2

if [ ! -d $MARKER_SOURCE ]
then
	log "source marker folder: '$MARKER_SOURCE' doesn't exist"
        log "give up"
   	exit
fi
if [ ! -d $MARKER_TARGET ]
then
	log "marker folder '$MARKER_TARGET' doesn't exist"
        log "give up"
        exit
fi



log ""
log "--- start rsnapshot-copy $TODAY7 ---"
 
for RSNAPSHOT1 in $RSNAPSHOTS
do

        TODAY_RSYNC_FINAL_START=`date +%Y%m%d-%H%M`
        log "$TODAY_RSYNC_FINAL_START  start -- ./rsnapshot-copy' '$RSNAPSHOT1'"
        log "./rsnapshot-copy -avSAX --delete  $SOURCE/$RSNAPSHOT1 $TARGET/$RSNAPSHOT1"

        #./rsnapshot-copy -avSAX --delete  $SOURCE/$RSNAPSHOT1/ $TARGET/$RSNAPSHOT1/
	   #echo "rsync -avSAXH  $SOURCE/$L/ /media/red/rs2/rss/$L/ "

	   # use rsync directly, clearer as the script ./rsnapshot-copy
	   log "rsync -avSAXH  $SOURCE/$RSNAPSHOT1/ $TARGET/$RSNAPSHOT1/ --delete"
	   rsync -avSAXH  $SOURCE/$RSNAPSHOT1/ $TARGET/$RSNAPSHOT1/ --delete

        TODAY_RSYNC_FINAL_END=`date +%Y%m%d-%H%M`
        log "$TODAY_RSYNC_FINAL_END  end   -- ./rsnapshot-copy '$RSNAPSHOT1'"

done


sync
sleep 2

echo "diff --no-dereference -r /home/rleo/demo/rs/ /home/rleo/demo/rs2/"
diff --no-dereference -r /home/rleo/demo/rs/ /home/rleo/demo/rs2/


TODAY=`date +%Y%m%d-%H%M`
log "done"
log "$TODAY"
log "===="






