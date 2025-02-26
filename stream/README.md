# mg5-stream

A GStreamer application for UVC-compliant IMX219 USB camera streaming over UDP to QGroundControl.

## Building
Prerequisites: `cmake >= 3.21` and `ninja-build`.

A convenience script `build.sh` in the root of the `stream/` directory builds and installs the executable `mg5-stream-app`. To test the executable:

```
chmod +x bin/mg5-stream-app
export GST_DEBUG=*:WARN && ./bin/mg5-stream-app [HOST IP] [PORT]
```
