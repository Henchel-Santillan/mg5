#!/bin/bash

TMP_DIR=/tmp
mkdir -p ${TMP_DIR}

#####>>>>> libcamera, rpicam-apps <<<<<#####
sudo apt-get install -y ninja-build pkg-config libyaml-dev python3-yaml python3-ply python3-jinja2 libssl-dev openssl \
    libgnutls28-dev libglib2.0-dev qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev pybind11-dev libepoxy-dev libjpeg-dev libtiff5-dev libpng-dev

# Build Raspberry Pi's fork of libcamera
sudo pip install meson
git clone https://github.com/raspberrypi/libcamera.git ${TMP_DIR}/libcamera
cd ${TMP_DIR}/libcamera
meson setup build --buildtype=release -Dpipelines=rpi/vc4,rpi/pisp -Dipas=rpi/vc4,rpi/pisp -Dv4l2=true -Dgstreamer=enabled \
    -Dtest=false -Dlc-compliance=disabled -Dcam=disabled -Dqcam=disabled -Ddocumentation=disabled -Dpycamera=enabled
ninja -C build && sudo ninja -C build install
cd

# Build rpicam-apps
sudo apt-get install -y libboost-program-options-dev libdrm-dev libexif-dev
git clone https://github.com/raspberrypi/rpicam-apps.git ${TMP_DIR}/rpicam-apps
cd ${TMP_DIR}/rpicam-apps
meson setup build -Denable_libav=disabled -Denable_drm=enabled -Denable_egl=disabled -Denable_qt=disabled -Denable_opencv=disabled \
    -Denable_tflite=disabled -Denable_hailo=disabled
meson compile -C build && sudo meson install -C build
sudo ldconfig

#####>>>>> Install GStreamer <<<<<#####
list=$(apt-cache --names-only search ^gstreamer1.0-* | awk '{ print $1 }' | sed -e /-doc/d | grep -v gstreamer1.0-hybris)
sudo apt-get install -y $list libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev 
