#!/bin/bash

set -euo pipefail

./run_linux_alpine_docker.sh
./run_linux_centos_docker.sh
./run_linux_ubuntu_docker.sh
