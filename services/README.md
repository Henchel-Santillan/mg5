# Services

To start mg5-specific applications on boot, three user services managed by [systemd](https://www.man7.org/linux/man-pages/man1/systemd.1.html) are to be created as part of the provisioning process:

1. `mg5-stream.service`: Starts the `mg5-stream-app` executable, which streams USB camera feed over UDP to QGroundControl using GStreamer
2. `mg5x.service`: Runs the `mg5x-main` target of the `mg5x` ROS2 package
3. `uxrce-dds.service`: Starts the PX4 uXRCE-DDS Agent

## Provisioning
All service files (files with extension `.service`) are to be copied from `mg5/service` to `/etc/systemd/system` with no world writability, no execute permissions (`a+rwx,u-x,g-x,o-wx or octal 664`) permissions.

### Copying the Service Files to the Correct Location
```
sudo cp ~/mg5/services/<service>.service /etc/systemd/system/<service>.service
sudo chmod 664 /etc/systemd/system/<service>.service
```

Then, follow the instructions specific to each service below.

### Service: mg5-stream
1. Build the `mg5-stream-app` executable using the `build.sh` script from within the `mg5/stream` directory. Pass YUYV to `build.sh`.
2. Copy `bin/mg5-stream-app` to `~` and give it execute permissions (+x).
3. Create the path `/etc/mg5-stream` and copy `mg5/stream/var_file` to `/etc/mg5-stream/var_file`.

Note: ensure YUYV is passed to the `build.sh` script, since MJPG streaming is currently untested and unstable. With decent connectivity, the default stream gives ~15 FPS @1280x720.

The host and port for the `udpsink` element in [main.cpp](https://github.com/Henchel-Santillan/mg5/blob/158ea87fe12e544f13f97186dd89ce8e33a9a57e/stream/src/main.cpp#L32) may change depending on test location, network settings, etc. Simply modify `/etc/mg5-stream/var_file` with the correct `MG5_STREAM_HOST` and `MG5_STREAM_PORT` and restart `mg5-stream`.

### Service: mg5x
1. Copy `mg5/scripts/exec_mg5x.sh` to `~`, as this is where the service file expects the executable to be. Give it execute permissions.

### Enabling the Services
Enable all services (and check if each is enabled), replacing `<SERVICE NAME>` with the service name:

```
sudo systemctl daemon-reload
sudo systemctl enable <SERVICE NAME>
sudo systemctl is-enabled <SERVICE NAME>
```

## Manual Teting Notes
Services can be:
* Stopped via `sudo systemctl stop <SERVICE NAME>`
* Disabled via `sudo systemctl disable <SERVICE NAME>` 
* Restarted via `sudo systemctl restart <SERVICE NAME>`

Recompiled binaries (such as `mg5-stream-app`) can be retested by simply restarting the appropriate systemd service.
