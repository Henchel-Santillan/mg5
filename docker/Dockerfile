FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y build-essential git cmake ninja-build \
    python3 python3-pip python3-venv pkg-config libyaml-dev python3-yaml \
    python3-ply python3-jinja2 libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libssl-dev

ENV PATH="$PATH:~/.local/bin"
COPY scripts/ scripts/
RUN chmod -R +x scripts && ./scripts/build_libcamera.sh /tmp && ./scripts/install_pyside.sh
