#!/bin/bash

TARGET_DIRECTORY=$1

git clone https://git.libcamera.org/libcamera/libcamera.git ${TARGET_DIRECTORY}/libcamera
cd ${TARGET_DIRECTORY}/libcamera
meson setup build
ninja -C build install
