#!/bin/bash

source /opt/sap/SYBASE.sh
sh /opt/sap/SYBASE.sh \
  && /opt/sap/ASE-16_0/install/RUN_LMSYBASE \
  &

#waiting for sybase to start
export STATUS=0
i=1
echo ===============  WAITING FOR master.dat SPACE ALLOCATION ==========================
while (( $i < 30 )); do
	sleep 1
	i=$((i+1))
	STATUS=$(grep "Performing space allocation for device '/opt/sap/data/master.dat'" /opt/sap/ASE-16_0/install/LMSYBASE.log | wc -c)
	if (( $STATUS > 300 )); then
	  break
	fi
done

echo ===============  WAITING FOR INITIALIZATION ==========================
export STATUS2=0
j=1
while (( $j < 30 )); do
  sleep 1
  j=$((j+1))
  STATUS2=$(grep "Finished initialization." /opt/sap/ASE-16_0/install/LMSYBASE.log | wc -c)
  if (( $STATUS2 > 350 )); then
    break
  fi
done

isql -U sa -P iH@t3Syb@s3 -S LMSYBASE -i "/change-password.sql"

rm /change-password.*

#trap 
while [ "$END" == '' ]; do
			sleep 60
			trap "END=1" INT TERM
done