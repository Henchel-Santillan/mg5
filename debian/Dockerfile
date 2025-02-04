FROM ros:humble-ros-base
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y build-essential python3 python3-pip git cmake
COPY scripts/ scripts/
RUN chmod -R +x scripts && ./scripts/setup.sh
