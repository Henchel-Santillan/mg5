#!/bin/bash

python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install pyside6 pyinstaller pymavlink

# Setup libcamera and ROS2 base (Humble)
./setup_libcamera.sh /tmp
./setup_ros2.sh
