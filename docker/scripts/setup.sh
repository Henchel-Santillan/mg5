#!/bin/bash

# Setup libcamera and ROS2 base (Humble)
./setup_libcamera.sh /tmp
./setup_ros2.sh /tmp


# Setup the ROS workspace 
# TODO: is this the best way to handle this? May need to mount Docker volumes to preserve the workspace
mkdir -p ~/ros2_ws/src && cd ~/ros2_ws/src
git clone https://github.com/PX4/px4_msgs.git
git clone https://github.com/PX4/px4_ros_com.git
git clone git@github.com:Henchel-Santillan/mg5x.git
cd ..

apt-get install python3-rosdep
rosdep init && rosdep update
rosdep install -i --from-path src --rosdistro humble -y
colcon build
