#!/bin/bash

# Must have installed nvidia-docker runtime as follows:
#    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
#    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
#    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
#    sudo apt-get update
#    sudo apt install nvidia-docker2
# 
# then, restart docker:
#    sudo systemctl restart docker

docker run -e NVIDIA_DRIVER_CAPABILITIES=all --runtime=nvidia --gpus all -it ffmpeg /bin/bash

