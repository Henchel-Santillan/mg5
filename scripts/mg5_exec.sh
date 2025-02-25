#!/bin/bash

# Start the uXRCE-DDS agent, the ROS2 image_capture_node, and GStreamer live camera feed
MicroXRCEAgent udp4 -p 8888
ros2 run mg5x mg5x-main # TODO: Adjust paths?
python3 live_feed.py --port 14550
