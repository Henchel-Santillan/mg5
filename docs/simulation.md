# Simulation
 
## Prerequisites
### PX4 and ROS2 Development Environment, and Simulation Tools
Follow the [ROS2 User Guide](https://docs.px4.io/main/en/ros2/user_guide) to setup
* the PX4 development environment and toolchain
* ROS2 Humble **Desktop** and Gazebo Harmonic
* Micro XRCE-DDS Client
on a local machine. Ensure that all the steps in the [SBC Provisioning Guide](provision.md) have been performed without error on the Raspberry Pi.

### QGroundControl (QGC) and Gamepad Setup
This tutorial uses a wired Xbox Series X controller, and VMWare running Ubuntu 22.04 (Jammy Jellyfish). USB passthrough must be configured for VMs 
(VMWare instructions below):

With the VM powered off, click through `Edit virtual machine settings > Hardware Tab > Add Button > USB Controller`. 
If "USB Controller" is already present under the “Devices” column, click on it and set USB compatibility to 2.0 in the menu on the right.
Check the box that says “Show all USB input devices”.

Power on the VM. Plug in the Xbox controller. On the VMWare toolbar, go to VM > Removable Devices and check that “Microsoft Controller” is checked. 
To verify the USB device, open a terminal and run `lsusb`. You should see something like the following in the output:

```
Bus 001 Device 004: ID 045e:0b12 Microsoft Corp. Xbox Wireless Controller (model 1914)
```

Proceed by [installing and starting up QGroundControl](https://docs.qgroundcontrol.com/master/en/qgc-user-guide/getting_started/download_and_install.html#ubuntu).
Note that a joystick can only be setup if you are connected to a vehicle, so you must have the simulation running first before configuring the Xbox controller.

Note: for sanity testing of the gamepad connection, you can install `jstest-gtk`:

```
sudo apt install -y jstest-gtk
jstest-gtk
```

## Starting the Simulation
**On the Raspberry Pi**, start the Micro-XRCE-DDS-Agent.

```
MicroXRCEAgent udp4 -p 8888
```

In a terminal window **on your local setup**, start up Gazebo with the x500 multicopter:

```
cd ~/PX4-AutoPilot
make px4_sitl gz_x500
```

This will also automatically start the Micro-XRCE-DDS client, connecting to UDP port 8888 on localhost to the agent.
<br><br>
**NOTE**: If you are getting an error where the Gazebo Simulation window closes with a segmentation fault, and with terminal output related to OpenGL 3.3:

TODO: Edit below
=== BEGIN below
If Ubuntu is running inside a VM (or if you’re using remote desktop sessions), hardware acceleration might be disabled or not properly configured:

Enable 3D Acceleration:
In your VM settings (for VirtualBox, VMware, etc.), ensure that 3D acceleration is enabled.
Guest Additions/Tools:
Install the appropriate guest additions (e.g., VirtualBox Guest Additions or VMware Tools) so that the VM can use the host’s GPU properly.
=== END below

This example runs the `minimal_controller_node`, a simple ROS2 node that subscribes to <TODO: figure out what it subscribes to>, and prints out the button that
was just pressed on the gamepad. It is provided as a ROS2 package in the root of this repository. As part of the SBC Provisioning Guide, you should have 
set up an SSH key to clone `mg5`, and should have cloned `mg5`.

 **On the Raspberry Pi**:

```
cd path/to/your/ros2/workspace
cp -r mg5/clone/path/minimal-controller .
colcon build --packages-select minimal-controller
```

A ROS2 package named "minimal-controller" is provided in the root of this repository. It is composed of a single ROS2 node that prints out the button assignments
and their functions (if any), listening for user input. Copy it into an existing ROS2 workspace (or create a new ROS2 workspace) and build the package using colcon. No additional dependencies
are required.

### Gamepad Configuration
With the simulation running, you may now [configure the Xbox controller](https://docs.qgroundcontrol.com/master/en/qgc-user-guide/setup_view/joystick.html).

Some notes:
* To get to the menu, click the QGC icon on the top-left corner, click "Vehicle Setup", and on the left menu find "Joystick".
* Make sure "Enable joystick input" under the "General" tab in QGC is checked, confirm that the "Active joystick" is the "Xbox Series X Controller", and ensure RC mode is "2".
* For this tutorial, the minimal configuration is sufficient. However, you may also choose to configure button assignments under the "Button Assignment" tab.
