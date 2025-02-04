FROM arm64v8/ros:humble-ros-base
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y build-essential python3 python3-pip git cmake
COPY scripts/ scripts/
RUN chmod -R +x scripts && ./scripts/setup.sh
