#!/bin/bash
if [ -z "$1" ]
  then
    echo "Usage: run.sh <datasets location>"
    exit 1
fi
echo "Using pipeline dir: $1"
IMAGE=`docker images | grep "maasg/dse" |  tr -s " " | cut -d" " -f3`
echo "Going to run $IMAGE"
mkdir -p /tmp/spark/logs
mkdir -p /tmp/pipeline/data
CONTAINER_ID=`docker run -d -v $1:/opt/data -v /tmp/spark/logs:/opt/spark/logs -v /tmp/pipeline/data:/opt/pipeline/data $IMAGE`
IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER_ID`
echo "Attempting to start the notebook launcher in your browser..."
if which xgd-open > /dev/null
then
  echo "Attempting to start the notebook launcher in your browser..."
  sleep 20
  xdg-open $IP:9000
elif which gnome-open > /dev/null
then
  echo "Attempting to start the notebook launcher in your browser..."
  sleep 20
  gnome-open "http://$IP:9000"
else  echo "Access the Spark Notebook from your browser: http://$IP:9000"
fi