FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y build-essential git cmake ninja-build \
    python3 python3-pip 

# Install Qt6 for Python, used for display interface
RUN python3 -m pip install pyside6

# Install and build libcamera (+ dependencies), and update PATH env var for meson
RUN apt update && python3 -m pip install --user meson && apt install -y pkg-config libyaml-dev python3-yaml \
    python3-ply python3-jinja2 libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libssl-dev

ENV PATH = "$PATH:~/.local/bin"
RUN scripts/build_libcamera.sh /opt
