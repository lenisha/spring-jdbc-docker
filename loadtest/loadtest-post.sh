#!/bin/bash

echo "***************************************************************************************"
echo "*---------------------------------BEGIN LOAD TEST-------------------------------------*"
echo "***************************************************************************************"


if [ -z "$1" ]
then
  echo "No SERVICE_ENDPOINT was passed as a parameter, assuming it is passed as environment variable"
else
  echo "SERVICE_ENDPOINT was passed as a parameter"
  export SERVICE_ENDPOINT=$1
fi

export CONTENT_TYPE="Content-Type: application/x-www-form-urlencoded"
export ENDPOINT=$SERVICE_ENDPOINT

echo "POST $ENDPOINT"
echo $CONTENT_TYPE


for i in {1..100000}
do
    export GUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    export PAYLOAD='name=LoadeTestUser-'$i-$GUID
    echo $PAYLOAD
  ./hey  -n 1 -t 2 -c 1 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m POST "$ENDPOINT"
done

echo "***************************************************************************************"
echo "*----------------------------------END LOAD TEST--------------------------------------*"
echo "***************************************************************************************"