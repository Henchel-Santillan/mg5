# mg5

For the X Quad airframe camera and flight ROS2 package, see [mg5x](https://github.com/Henchel-Santillan/mg5x).

## Using the PX4 Simulator (Software-In-The-Loop)
Start the Micro XRCE-DDS agent.

```
MicroXRCEAgent udp4 -p 8888
make px4_sitl gz_x500
```
