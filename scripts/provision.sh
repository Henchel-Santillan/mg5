#!/bin/bash

SETUP_DIR=~/setup
mkdir -p ${SETUP_DIR}

sudo apt install -y build-essential gdb python3 python3-pip git

#####>>>>> libcamera, rpicam-apps <<<<<#####
sudo apt install -y ninja-build pkg-config libyaml-dev python3-yaml python3-ply python3-jinja2 libssl-dev openssl \
    libgnutls28-dev libglib2.0-dev qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev pybind11-dev libepoxy-dev libjpeg-dev libtiff5-dev libpng-dev

# Build Raspberry Pi's fork of libcamera
sudo pip install --force-reinstall 'meson>=0.63'
git clone https://github.com/raspberrypi/libcamera.git ${SETUP_DIR}/libcamera
cd ${SETUP_DIR}/libcamera
meson setup build --buildtype=release -Dpipelines=rpi/vc4,rpi/pisp -Dipas=rpi/vc4,rpi/pisp -Dv4l2=true -Dgstreamer=enabled \
    -Dtest=false -Dlc-compliance=disabled -Dcam=disabled -Dqcam=disabled -Ddocumentation=disabled -Dpycamera=enabled
ninja -C build && sudo ninja -C build install
cd

# Build rpicam-apps
sudo apt install -y libboost-program-options-dev libdrm-dev libexif-dev
git clone https://github.com/raspberrypi/rpicam-apps.git ${SETUP_DIR}/rpicam-apps
cd ${SETUP_DIR}/rpicam-apps
meson setup build -Denable_libav=disabled -Denable_drm=enabled -Denable_egl=disabled -Denable_qt=disabled -Denable_opencv=disabled \
    -Denable_tflite=disabled -Denable_hailo=disabled
meson compile -C build && sudo meson install -C build
sudo ldconfig

#####>>>>> Install GStreamer <<<<<#####
cd
list=$(apt-cache --names-only search ^gstreamer1.0-* | awk '{ print $1 }' | sed -e /-doc/d | grep -v gstreamer1.0-hybris)
sudo apt install -y $list libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-tools \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad v4l-utils

#####>>>>> Install ROS2 Humble Base and ROS2 Dev Tools <<<<<#####
sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

sudo apt install software-properties-common
sudo add-apt-repository universe

sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt upgrade
sudo apt install ros-humble-ros-base ros-dev-tools
echo "source /opt/ros/humble/setup.bash" >> .bashrc

#####>>>>> Install PX4 Tools <<<<<#####
git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git ${SETUP_DIR}/Micro-XRCE-DDS-Agent
cd ${SETUP_DIR}/Micro-XRCE-DDS-Agent
mkdir build && cd build
cmake ..
make -j4
sudo make -j4 install
sudo ldconfig /usr/local/lib/
