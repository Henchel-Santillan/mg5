#!/bin/bash

TARGET_DIRECTORY=$1

python3 -m pip install --user meson
git clone https://git.libcamera.org/libcamera/libcamera.git ${TARGET_DIRECTORY}/libcamera
cd ${TARGET_DIRECTORY}/libcamera
meson setup build
ninja -C build install
cd ..
rm -rf ${TARGET_DIRECTORY}/libcamera
