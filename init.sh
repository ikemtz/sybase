#!/bin/bash

#set password


  #waiting for sybase to start
export STATUS=0
i=1
echo ===============  WAITING FOR master.dat SPACE ALLOCATION ==========================
while (( $i < 15 )); do
  i=$((i+1))
  STATUS=$(grep "Performing space allocation for device '/opt/sap/data/master.dat'" /opt/sap/ASE-16_0/install/LMSYBASE.log | wc -c)
  if (( $STATUS > 150 )); then
    break
  else
    sleep 5s
  fi
done

echo ===============  WAITING FOR INITIALIZATION ==========================
export STATUS2=0
j=1
while (( $j < 15 )); do
  j=$((j+1))
  STATUS2=$(grep "Finished initialization." /opt/sap/ASE-16_0/install/LMSYBASE.log | wc -c)
  if (( $STATUS2 > 300 )); then
    break
  else
    sleep 5s
  fi
done
if test -z "$SA_PASSWORD"
then
  echo -e "sp_password S@_P@55w0rd, $SA_PASSWORD \nGO" > /opt/sap/change-password.sql
  isql -U sa -P S@_P@55w0rd -S LMSYBASE -i "/opt/sap/change-password.sql"

  rm /opt/sap/change-password.sql
  export SA_PASSWORD="**************"
else
  echo *** Skipping password change ***
fi