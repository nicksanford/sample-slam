#!/bin/bash

DATE=$(date +"%Y-%m-%dT%H:%M:%S")
echo "Run ${DATE}"
GRPC_SERVER="localhost:8083"
# GRPC_SERVER=$(sudo lsof -i -n -P | grep carto | awk '{ print $9 }' | head -n 1)
SLAM_DIR="${HOME}/Development/viam-cartographer"
API_DIR="${HOME}/Development/api"
cd ${API_DIR}
PROTOS=<(~/Development/viam-cartographer/grpc/bin/buf build -o -)
cd -

mkdir -p ./sample
mkdir -p ./sample/internal_state
mkdir -p ./sample/position
mkdir -p ./sample/map

grpcurl -max-msg-sz 100000000000000 -d '{"name": "slam"}' \
  -plaintext -protoset <(~/Development/viam-cartographer/grpc/bin/buf build -o -) $GRPC_SERVER  viam.service.slam.v1.SLAMService/GetInternalState \
  | jq -r '.internalStateChunk' \
  | ./base64_decode_lines.py > ./sample/internal_state/${DATE}.pbstream 

grpcurl -max-msg-sz 100000000000000 -d '{"name": "slam"}' \
  -plaintext -protoset <(~/Development/viam-cartographer/grpc/bin/buf build -o -)  $GRPC_SERVER  viam.service.slam.v1.SLAMService/GetPosition > \
  ./sample/position/${DATE}.json 

grpcurl -max-msg-sz 100000000000000 -d '{"name": "slam"}' \
  -plaintext -protoset <(~/Development/viam-cartographer/grpc/bin/buf build -o -) $GRPC_SERVER  viam.service.slam.v1.SLAMService.GetPointCloudMap \
  | jq -r '.pointCloudPcdChunk' \
  | ./base64_decode_lines.py > ./sample/map/${DATE}.pcd  
