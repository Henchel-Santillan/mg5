# Services

To start mg5-specific applications on boot, three user services managed by the system and service manager [systemd](https://www.man7.org/linux/man-pages/man1/systemd.1.html) are to be created as part of the provisioning process:

1. `mg5-stream.service`: Starts the `mg5-stream-app` executable, which streams USB camera feed over UDP to QGroundControl using GStreamer
2. `mg5x.service`: Runs the `mg5x-main` target of the `mg5x` ROS2 package
3. `uxrce-dds.service`: Starts the PX4 uXRCE-DDS Agent

## Provisioning
1. Copy the service files to `/etc/systemd/system/`. All of the services are to be configured as system-wide services. Apply `chmod 664` to each service file (no world writability, no execute permissions).
2. Copy `exec_mg5.sh` into `~`, and give it execute permissions.
3. From within `mg5/stream/`, build the `mg5-stream-app` executable, give it execute permissions, and copy it to `~`.
4. Copy the `var_file` to `/etc/mg5-stream/` (create first if path does not exist). 
5. Enable both services (and check if each is enabled), replacing `<SERVICE_PATH>` with the path to the service name:

```
sudo systemctl daemon-reload
sudo systemctl enable <SERVICE_PATH>
sudo systemctl is-enabled <SERVICE_PATH>
```

## Notes
### mg5-stream-app
The host and port for the `udpsink` element are dynamic, and may change depending on test location, network settings, etc. With this in mind, simply modify the var_file to point to the new host IP and port number, and reboot the SBC for the changes to take effect.
