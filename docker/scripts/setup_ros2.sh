#!/bin/bash

# Setup PX4 development environment
cd
git clone https://github.com/PX4/PX4-Autopilot.git --recursive
./PX4-Autopilot/Tools/setup/ubuntu.sh
cd PX4-Autopilot/ && make px4_sitl
cd && rm -rf PX4-Autopilot/

apt install locales
locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
apt install software-properties-common && add-apt-repository universe
apt update -y && apt install -y curl && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
apt install -y ros-humble-ros-desktop
source /opt/ros/humble/setup.bash && echo "source /opt/ros/humble/setup.bash" >> .bashrc

# Needed to allow ROS2 to communicate with PX4
cd
pip install --user -U empy==3.3.4 pyros-genmsg setuptools
git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
cd Micro-XRCE-DDS-Agent
mkdir build && cd build
cmake .. && make && make install
ldconfig /usr/local/lib/
cd && rm -rf Micro-XRCE-DDS-Agent
