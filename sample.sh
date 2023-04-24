#!/bin/bash

DATE=$(date +"%Y-%m-%dT%H:%M%:%SZ")
echo "Run ${DATE}"
GRPC_SERVER="localhost:8083"
# GRPC_SERVER=$(sudo lsof -i -n -P | grep carto | awk '{ print $9 }' | head -n 1)
SLAM_DIR="${HOME}/viam-cartographer"
API_DIR="${HOME}/api"
cd ${API_DIR}
PROTOS=<(~/viam-cartographer/grpc/bin/buf build -o -)
cd -

mkdir -p ./sample
mkdir -p ./sample/internal_state
mkdir -p ./sample/position
mkdir -p ./sample/map

grpcurl -max-msg-sz 100000000000000 -d '{"name": "slam"}' \
  -plaintext -protoset <(~/viam-cartographer/grpc/bin/buf build -o -) $GRPC_SERVER  viam.service.slam.v1.SLAMService/GetInternalState \
  | jq -r '.internalState' \
  | base64 -d > ./sample/internal_state/${DATE}.pbstream 

grpcurl -max-msg-sz 100000000000000 -d '{"name": "slam"}' \
  -plaintext -protoset <(~/viam-cartographer/grpc/bin/buf build -o -)  $GRPC_SERVER  viam.service.slam.v1.SLAMService/GetPosition > \
  ./sample/position/${DATE}.json 

grpcurl -max-msg-sz 100000000000000 -d '{"name": "slam"}' \
  -plaintext -protoset <(~/viam-cartographer/grpc/bin/buf build -o -) $GRPC_SERVER  viam.service.slam.v1.SLAMService.GetPointCloudMap \
  | jq -r '.pointCloudPcd' \
  | base64 -d > ./sample/map/${DATE}.pcd  
