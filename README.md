# Sample Slam

This repo contains scripts to make sampling SLAM GRPC servers which implement to the [Viam SLAM proto](https://github.com/viamrobotics/api/blob/main/proto/viam/service/slam/v1/slam.proto).

It is intended to be used the Viam SLAM team to make sampling SLAM GRPC servers more ergonomic.

## Usage:
1. Start `watch -n ./sample.sh` within the root directory of [api](https://github.com/viamrobotics/api). This script will begin making requests to the slam algo and save the data to a directory called `sample` in the same directory as the script. You may need to modify the code to point to the correct hostname & port of the SLAM GRPC server. 
2. Start [RDK](https://github.com/viamrobotics/rdk) configured with a non fake SLAM service.
3. Once you have collected all the data you want, kill the script started at step 1.
4. If you would like to format the sample output in the format used by fake SLAM in RDK, run `./format.py <NAME_OF_INPUT_SAMPLE_DIRECTORY> <NAME_OF_OUTPUT_FORMATTED_DIRECTORY>` for example `./format.py sample formated_output`
