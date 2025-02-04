#!/bin/bash

apt install build-essential git python3 python3-pip

TMP_DIR=/tmp
mkdir -p ${TMP_DIR}

#####>>>>> LIBCAMERA <<<<<#####
# libcamera core, IPA module signing, GStreamer
apt install ninja-build pkg-config libyaml-dev python3-yaml python3-ply python3-jinja2 libssl-dev openssl \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

# Add user meson installation to PATH (install without --user, libcamera issues)
pip install meson
export PATH=$HOME/.local/bin:$PATH
git clone https://git.libcamera.org/libcamera/libcamera.git ${TMP_DIR}/libcamera
cd libcamera
meson setup build && ninja -C build install
rm -rf /tmp/libcamera

#####>>>>> ROS2 <<<<<#####
apt update && apt install locales
locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
apt install software-properties-common && add-apt-repository universe
apt update -y && apt install -y curl && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
apt update && apt upgrade -y
apt install ros-humble-ros-base ros-dev-tools
source /opt/ros/humble/setup.bash && echo "source /opt/ros/humble/setup.bash" >> .bashrc

#####>>>>> Micro XRCE-DDS Agent (PX4-ROS2 Bridge) <<<<<#####
git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git ${TMP_DIR}/Micro-XRCE-DDS-Agent
cd Micro-XRCE-DDS-Agent
mkdir build && cd build
cmake ..
make
make install
ldconfig /usr/local/lib/

echo "Provisioning the SBC has succeeded. The system will now reboot."
reboot
