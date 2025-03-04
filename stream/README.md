# mg5-stream

A GStreamer application for UVC-compliant IMX219 USB camera streaming over UDP to QGroundControl.

## Building
Prerequisites: `cmake >= 3.21` and `ninja-build`.

Use the convenience script `build.sh` in the root of the `stream/` directory to build and install the executable `mg5-stream-app` into `stream/bin`. To build with YUYV used as the raw format (default, and tested):

```
./build.sh YUYV
```

To build with MJPG used as the raw format,

```
./build.sh MJPG
```

To test the executable locally:

```
chmod +x bin/mg5-stream-app
export GST_DEBUG=*:WARN && ./bin/mg5-stream-app [HOST IP] [PORT]
```

See the **Provisioning the mg5-stream Service** section in the [Services README](../services/README.md) for instructions on how to set up the live feed service.
