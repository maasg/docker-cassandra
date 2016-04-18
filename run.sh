#!/bin/bash
IMAGE=`docker images | grep "maasg/dse" |  tr -s " " | cut -d" " -f3`
echo "Going to run $IMAGE"
mkdir -p /tmp/spark/logs
docker run -v /media/maasg/ssd/playground/datastax/pipeline/datasets/:/opt/data -v /tmp/spark/logs:/opt/spark/logs $IMAGE
