# SBC Provisioning Guide

## Formatting the SD Card and Mounting Ubuntu

On Windows:

1. This guide will use the [Raspberry Pi Imager](https://www.raspberrypi.com/documentation/computers/getting-started.html#raspberry-pi-imager). Download the [latest](https://downloads.raspberrypi.org/imager/imager_latest.exe) and run setup.  
2. You will need a USB microSD card reader (Type-A or Type-C). Insert the SD card into the card reader, and plug the card reader into your PC.  
3. Open up the Raspberry Pi Imager. For **Raspberry Pi Device**, choose **Raspberry Pi 4**. For Operating System, choose **Other general-purpose OS.** In the menu that follows, choose **Ubuntu Server 22.04.5 LTS (64-bit**).

![Ubuntu Server Option](resources/provisioning/ubuntu_server_option.png)

4. Click **Choose Storage** and find the USB microSD card reader (will typically be a D: drive; check that the storage matches up with the storage of the SD card you inserted).

![Mass Storage Device](resources/provisioning/mass_storage.png)

![Raspberry Pi Imager Main Page](resources/provisioning/rpi_imager_main.png)

5. Hit **Next.**  
6. A dialog named “Use OS customisation” will appear. Click **Edit Settings.**

![OS Customization Dialog](resources/provisioning/os_customization.png)

7. Under **General**, leave hostname as `raspberrypi`. Set username to \*\*\*\****mg5-ubuntu***\*\*\*\* (IMPORTANT\! The image says `mg5`, which is outdated) and set a password (ask @Henchel-Santillan for what the default is). You must configure wireless LAN (doing this later is possible, but why not do it now?). Locale settings are optional (you will see locale settings if you scroll down).

![OS Customization, General Settings](resources/provisioning/os_cust_general.png)

8. Under **Services**, check **Enable SSH**, and check **Use password authentication**. Hit **Save** on the dialog to save your changes. When you return to the “Use OS customisation” dialog, select **Yes** to apply your settings.  
9. Hit **Yes** again to reformat the SD card and mount Ubuntu. Write operation will take 5 to 10 minutes. Once finished, you may exit the imager and remove the mass storage device.

![SSH Configuration](resources/provisioning/password_auth.png)  

Once completed, you may proceed to the [Provisioning Guide](#provisioning-guide).


## Provisioning Guide

### Summary of System Information

* Username: `mg5-ubuntu`  
* Hostname: `raspberrypi`  
* Password: **Default**  
* IP Address: **Network-dependent**

SSH uses **password authentication**; when prompted, enter the Password used during setup.

### First Time Setup

First-time setup is best done with a monitor and keyboard. Boot the system and wait until initialization is finished. The first time is always the longest. Once in, log in using the configured username and password. The next step is to upgrade and then install essential tools. First, run

`sudo apt update && sudo apt upgrade -y`  
`reboot`

Once the system finishes reboot, install the following:

`sudo apt update && sudo apt install -y net-tools procinfo`

If necessary, find the MAC address of the Raspberry Pi using `ifconfig -a`, and add it to the list of supported devices on your network settings page depending on the network interface being used. To find the IP address of the Raspberry Pi:

```
hostname -I
```

Ensure your PC is on the same network (and interface) as the Raspberry Pi (e.g. if WLAN is configured, connect your PC to WiFi and not ethernet). Try to ping the Raspberry Pi from your PC.

```
ping <RPI_IP_ADDR>
```

You can SSH into the device from your PC using the username and hostname if you are able to ping it:  
`ssh mg5-ubuntu@raspberrypi`

Alternatively, you can supply the IP address:

`ssh mg5-ubuntu@<RPI_IP_ADDR>`

If using Windows, it is strongly recommended to create a `config` file in the `.ssh` directory in your user root for SSH to define a keep-alive interval *n*. Configuring this will mean a keep-alive packet is sent every *n* seconds, preventing random (and untimely) client disconnects. On Windows, the OpenSSH client may have trouble locating the `config` file. You may need to pass the absolute path to the config file with the `-F` option. The full command now becomes (with `-v` for verbosity):

`ssh -v mg5-ubuntu@<RPI_IP_ADDR> -F C:\Users\user.ssh\config`

You can also use remote desktop applications like VNC or XRDP.

### Installing Dependencies Using the Provisioning Script 
The provisioning script is an all-in-one shell script that installs and builds the major dependencies (libcamera, ROS2, PX4 agent), located [here](https://github.com/Henchel-Santillan/mg5/blob/main/scripts/provision.sh). It is the recommended (and most convenient) way to install the dependencies on a new system. There are two primary methods to execute the provisioning script.

Cloning `mg5` directly on the SBC is recommended, as it will make the rest of the provisioning steps easier. First, you must set up SSH keys.

**Setting Up SSH Keys**
Generate a new ssh key in the `~/.ssh` directory.

`ssh-keygen -t ed25519 -C "your_email@example.com"`

You may choose to rename the key and enter a passphrase if desired. Follow [Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) to add the new SSH key to your GitHub account. To clone anything mg5-related, **you must first be a collaborator** and have correctly configured permissions for the repositories of interest. If you need to know the default passphrase / password for the primary SSH development key on an already provisioned `mg5-ubuntu` headless system, ask @Henchel-Santillan.

To make things easier for the rest of the provisioning process, clone `mg5` into `~`. Now, run the provisioning script and then reboot.

```
chmod +x scripts && ./scripts/provision.sh 
sudo reboot
```


## Configuring `/boot/firwmare/config.txt` for the CSI Camera

Use the `raspi-config` utility to ensure support for the Legacy Camera Hardware is **disabled**. You can do this by first running `raspi-config` in the terminal, navigating to `Interface Options`, hitting **Enter** on the **Legacy Hardware** option, and selecting “No”.

`/boot/firmware/config.txt` also needs to be configured to use the Raspberry Pi HQ M12 camera. To do this, you may simply overwrite `/boot/firmware/config.txt` with the [config.txt](https://github.com/Henchel-Santillan/mg5/blob/main/config.txt) file from the root of the `mg5` repository, and then reboot.

An important note is that the required overlay for the image sensor (`IMX477` in this case) was added (see the line containing `dtoverlay=imx477`). To see if the HQ camera was correctly setup, you can test using  

```
rpicam-hello --list-cameras
```

If you see the message `No cameras available!`, recheck the connection to the CSI port. Ensure that the cable is facing away from the RJ45 ethernet port, and that the black connector is fully down. The cable should be snug. Otherwise, if you get an output with `IMX477` in it, this means you have set everything up correctly. Example output is given below:

```
Available cameras
-----------------
0 : imx477 [4056x3040 12-bit RGGB] (/base/soc/i2c0mux/i2c@1/imx477@1a)
	Modes: 'SRGGB10_CSI2P' : 1332x990 [120.05 fps - (696, 528)/2664x1980 crop]
	       'SRGGB12_CSI2P' : 2028x1080 [50.03 fps - (0, 440)/4056x2160 crop]
			                 2028x1520 [40.01 fps - (0, 0)/4056x3040 crop]
							 4056x3040 [10.00 fps - (0, 0)/4056x3040 crop]
```

Copy the `imx477.json` file from the root of `mg5` to `~`. This file is a tuning file for the main camera. For more information about the contents of the tuning file, see [this datasheet](https://datasheets.raspberrypi.com/camera/raspberry-pi-camera-guide.pdf#:~:text=We%20have%20already%20seen%20the%20%EE%80%80camera%EE%80%81%20board%20connected).

Note that the images may be blurry. To fix this, try adjusting the position of the lens using the lock ring. The lens position in the mount depends on where it best focuses - experiment with `rpicam-still -n --tuning-file imx477.json --immediate`.


## Creating the ROS2 Workspace
The ROS2 workspace contains ROS2 packages. The necessary ROS2 dependencies should have been installed through the provisioning script. Create the workspace as follows:

```
mkdir -p ~/ros2ws/src
```

### Fetching the Required Packages
1. [mg5x](https://github.com/Henchel-Santillan/mg5x) (package with a ROS2 node that subscribes to PX4 VehicleCommands and captures images when requested)  
2. [px4_msgs](https://github.com/PX4/px4_msgs) (contains PX4 message definitions for ROS2)

Add your key to the SSH agent (if not done already) and clone the required packages into `~/ros2ws/src`.

`eval "$(ssh-agent -s)"`  
`ssh-add ~/.ssh/<your SSH key name>`  
`git clone git@github.com:Henchel-Santillan/mg5x.git ~/ros2ws/src/mg5x --recursive`  
`git clone git@github.com:PX4/px4_msgs.git ~/ros2ws/src/mg5x`

### Building the Packages

Use `colcon` to build the ROS2 packages in the workspace. It is recommended to build the packages individually, as `mg5x` has CMake arguments that need to be passed. Note that you must build `px4_msgs` first since `mg5x` depends on `px4_msgs`.

1. First build `px4_msgs`:

```
colcon build --packages-select px4_msgs
```

2. Then, build `mg5x`:

```
colcon build --packages-select mg5x --cmake-args -DTESTING=OFF
```

## Setting Up Serial Connection for Pixhawk

1. Open the raspi-config tool. 

```
sudo raspi-config
```

Navigate to Interface Options, and then click Serial Port. 
Select No to disable serial login shell.
Select Yes to enable the serial interface

Click Finish to apply the changes, and then reboot the SBC.

2. Open /boot/firmware/config.txt and append the following text to the end of the file (after the last line):

```
enable_uart=1
dtoverlay=disable-bt
```

Note that the `enable_uart=1` line might already exist. The `dtoverlay=disable-dt` lines disables the Bluetooth device, and makes UART0 the primary UART. Verify that the serial port is indeed available:

```
ls -l /dev/serial0
```

On the SBC, this points to either `/dev/ttyS0` or `/dev/ttyAMA0`. The agent is started as follows in the system-wide uxrce-dds.service file; the uxrce-dds service should have been enabled as part of the SBC provisioning process.

```
MicroXRCEAgent serial --dev /dev/serial0 -b 921600
```

## Setting Up the Raspberry Pi as an Access Point (AP)

### Prerequisites

The Raspberry Pi 4B should support AP mode configuration. To double check, run:

```  
iw list | grep -A 10 “Supported interface modes”  
```

“AP” should appear under the list. Proceed by installing `hostapd` and `dnsmasq`:

```  
sudo apt update  
sudo apt install -y hostapd dnsmasq  
```

You may get an error upon `dnsmasq` being installed:

```  
Mar 09 11:05:29 raspberrypi dnsmasq[1937]: failed to create listening socket for port 53: Address already in use  
Mar 09 11:05:29 raspberrypi dnsmasq[1937]: FAILED to start up

…

Mar 09 11:05:29 raspberrypi systemd[1]: Failed to start dnsmasq - A lightweight DHCP and caching DNS server.  
```

**You may safely ignore these errors; they will be resolved in a later step**.

### Configuration File for `hostapd`

Create and edit `/etc/hostapd/hostapd.conf`. This file will set up the access point interface, as well as the network SSID and passphrase, among other settings.

```  
sudo nano /etc/hostapd/hostapd.conf  
```

Populate the file with the following:

```  
interface=wlan0  
driver=nl80211  
ssid=mg5x-ap  
hw_mode=g  
channel=7  
wmm_enabled=0  
macaddr_acl=0  
auth_algs=1  
ignore_broadcast_ssid=0  
wpa=2  
wpa_passphrase=<PASSPHRASE>  
wpa_key_mgmt=WPA-PSK  
wpa_pairwise=CCMP  
rsn_pairwise=CCMP  
wmm_enabled=1  
```

Some important notes:

* `macraddr_acl` set to 0 means no MAC address-based access control is applied, allowing any device to connect, provided that device provides the correct credentials  
* `channel` is set to 7 and `hw_mode` is set to `g`, which  
  * sets the wireless HW mode to IEEE 802.11g (2.4 GHz frequency band)  
  * specifies the 2.4 GHz channel on which the AP will operate  
* `ignore_broadcast_ssid=0` means the SSID will be visible to devices scanning for networks  
* `wmm_enabled=1` is intended to support QoS features for video traffic  
* WPA2 (`wpa=2`) is the security protocol

For the `wpa_passphrase`, ask @Henchel-Santillan.  
Once added and saved, edit `/etc/default/hostapd`, uncommenting and modifying the following line

```  
DAEMON_CONF=“/etc/hostapd/hostapd.conf”  
```

This will tell `hostapd` to use this configuration file. Start `hostapd`:

```  
sudo systemctl unmask hostapd  
sudo systemctl enable hostapd  
sudo systemctl start hostapd  
```

### Setting Up `dnsmasq`

This step enables devices that connect to the Raspberry Pi to be assigned an IP address.

1. Backup the original `/etc/dnsmasq.conf`:

```  
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.old  
```

2. Add the following to the original `/etc/dnsmasq.conf` file:

```  
interface=wlan0  
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h  
port=5353  
```

This assigns addresses between 192.168.4.2 and 192.168.4.20 with a least time of **24 hours**. Note that the `port=5353` line will resolve the error from the installation step (this line may already be present in the file and may just have to be uncommented).

On startup, dnsmasq will not wait for wlan0 to initialize. Modify `/lib/systemd/system/dnsmasq.service` to tell `systemd` to only launch the `dnsmasq` service after the network is ready. This can be done by setting the `After=` and `Wants=` fields under the `[Unit]` section of the file.

```  
sudo nano /lib/systemd/system/dnsmasq.service  
``` 

and change or add

```  
[Unit]  
…  
After=network-online.target  
Wants=network-online.target  
```

Then, reload dnsmasq config:

```  
sudo systemctl daemon-reload  
sudo systemctl restart dnsmasq  
```

### Configuring Static IP

**Writer’s Note: Putting the following configuration under “wifis” results in no IP address being assigned to the connecting device. Running `sudo netplan apply` will fail since no `access-points` are specified. Putting it under “ethernets” is what worked …**

1. Backup the original `netplan` yaml file:

```  
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.old  
```

2. Under `network:` and `ethernets:` comment out the wlan information added during the SD card formatting and mounting process and add instead:

```  
wlan0:  
  dhcp4: false  
  addresses:  
    - 192.168.4.1/24  
```

A minimal `50-cloud-init.yaml` file looks like the following:

```  
network:  
  version: 2  
  ethernets:  
    wlan0:  
      dhcp4: false  
      addresses:

- 192.168.4.1/24

```

Reboot the system. Try connecting to the Raspberry Pi via Wi-Fi. On the Windows PC, it should say `No Internet, Secured` under the `mg5x-ap` SSID.

Some ways to check on the Raspberry Pi if your device is connected:

1. `iw dev wlan0 station dump`

You can compare the outputs before and after connecting.

2. Check the `dnsmasq` lease file:

```  
cat /var/lib/misc/dnsmasq.leases  
```

You should see your device connected, along with the assigned IP address (e.g. `192.168.4.7`).

## Setting Up the Live Feed Camera
The live feed camera is the Arducam 8MP USB Camera Module (see [Arducam 8MP 1080P USB Camera Module](https://www.arducam.com/product/b0196arducam-8mp-1080p-usb-camera-module-1-4-cmos-imx219-mini-uvc-usb2-0-webcam-board-with-1-64ft-0-5m-usb-cable-for-windows-linux-android-and-mac-os/)). It is based on the IMX219 sensor. It is also a UVC-compliant camera, and so it is not (and likely never will be) compatible with `libcamera`.

Plug the USB camera in. Make sure you plug it into one of the USB 3.0 ports (the blue ones) as they provide more current draw. Running `lsusb`, you should see something like the following:

```
Bus 001 Device 004: ID 0c45:6366 Microdia Webcam Vitade AF
```

Running `v4l2-ctl --list-devices` should have `Arducam_8mp` in the output:

```
Arducam_8mp: USB Camera (usb-0000:01:00.0-1.3):  
	/dev/video0  
	/dev/video1  
	/dev/media2
```

Then, build the `mg5-stream-app` from `mg5/stream` by following the instructions [here](https://github.com/Henchel-Santillan/mg5/blob/main/stream/README.md). 

### QGroundControl Notes
Note that QGroundControl **does not** support direct MJPG video streams (they must first be converted to H.264). [VLC Media Player](https://www.videolan.org/vlc/download-windows.html) will likely need to be used instead. Presently, MJPG streams have not been tested, and so it is recommended to build with the pipeline that uses YUYV. The `mg5-stream-app` executable will be used when setting up the live feed service in the next section.

In QGroundControl, click on the “Q” icon > Application Settings. This is what you should configure based on what stream. Captured below are the default settings, which should work right out of the box with the default stream settings (the "YUYV" build).

![Video Settings, QGroundControl](resources/provisioning/video_settings.png)

To record a video, press the red record button on the homepage. Videos are saved by default, on Windows, at `%USERPROFILE%\Documents\QGroundControl\Videos`.


## Adding System-Wide Services

To start the live camera feed, the ROS2 `image_capture_node` from the `mg5x` package, and the PX4 uXRCE-DDS Agent, three `systemd` services need to be enabled and started:

1. `mg5-stream.service`  
2. `mg5x.service`  
3. `uxrce-dds.service`

Follow the instructions [here](https://github.com/Henchel-Santillan/mg5/blob/main/services/README.md) for provisioning the services. Doing so should complete the provisioning process. The following sections offer additional setup information for different use cases.

# Extracting Files from the SBC

There are 2 main ways to extract files from the SBC. The first method is the most user-friendly method (for both developers and users alike).

## Method 1: scp over SSH
You need to be able to ping your Raspberry Pi for this first method. This is the fastest method for file transfer, and requires a network connection to the SBC.

```
scp -r mg5-ubuntu@<RPI_IP_ADDR>:<path/to/folder> <destination on host>
```

## Method 2: Use a Physical USB Drive  
Connect a USB drive to any of the USB ports, USB 3.0 preferred (blue ports).

1. Identify the USB device using `lsblk`.  
2. Once identified, create a mount point. An example is given below:

`sudo mkdir /media/usb`

3. Mount: `sudo mount /dev/sdb1 /media/usb`, where `/dev/sdb1` is an example of an identified USB device from Step 1.  
4. Move or copy files using `mv` or `cp`  
5. Unmount the device: `sudo umount /media/usb`.  
6. Unplug the USB device, plug into your PC, and retrieve the files.

Note that this method works well if you have an external monitor and keyboard. Otherwise, if you are using SSH to run these commands, just use Method 1.
