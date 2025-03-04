#include <gst/gst.h>

#ifdef __APPLE__
#include <TargetConditionals.h>
#endif

#include <iostream>
#include <sstream>

int app(int argc, char *argv[]) {
  gst_init (&argc, &argv);

  // Build a static pipeline
  const auto host = argv[1];
  const auto port = std::stoi(argv[2]);

  // Obtain using ls -l /dev/v4l/by-id
  constexpr auto persistent_device_path = "/dev/v4l/by-id/usb-Arducam_Technology_Co.__Ltd._Arducam_8mp_SN0001-video-index0";

  // NOTE: for Arducam 8MP, this defaults to YUYV @1280x720 (10 FPS), although testing shows 15 FPS
  // can be achieved with good connectivity.
  std::ostringstream pipeline_stream;
  pipeline_stream << "v4l2src device="
                  << persistent_device_path;

#ifdef USE_MJPG
  pipeline_stream << " image/jpeg,framerate=30/1 ! rtpjpegpay !";
#else
  pipeline_stream << " ! videoconvert ! x264enc speed-preset=ultrafast "
                  << "tune=zerolatency bitrate=1000 ! h264parse ! rtph264pay config-interval=1 pt=96 !";
#endif

  pipeline_stream << " udpsink host=" << host
                  << " port=" << port;

  // Lazily create pipeline
  auto pipeline = gst_parse_launch(pipeline_stream.str().c_str(), NULL);

  gst_element_set_state(pipeline, GST_STATE_PLAYING);

  auto bus = gst_element_get_bus(pipeline);
  auto msg = gst_bus_timed_pop_filtered(bus, GST_CLOCK_TIME_NONE, 
            static_cast<GstMessageType>(GST_MESSAGE_ERROR | GST_MESSAGE_EOS));

  if (GST_MESSAGE_TYPE(msg) == GST_MESSAGE_ERROR) {
    g_printerr ("An error occurred! Re-run with the GST_DEBUG=*:WARN "
        "environment variable set for more details.\n");
  }

  gst_message_unref(msg);
  gst_object_unref(bus);
  gst_element_set_state(pipeline, GST_STATE_NULL);
  gst_object_unref(pipeline);
  return 0;
}

int main(int argc, char *argv[]) {
  constexpr auto NUM_APP_ARGS = 2;
  if (argc != 1 + NUM_APP_ARGS) {
    std::cerr << "Usage: ./mg5-stream-app [host IP] [port]" << std::endl;
    return -1;
  }

#if defined(__APPLE__) && TARGET_OS_MAC && !TARGET_OS_IPHONE
  return gst_macos_main((GstMainFunc) app, argc, argv, NULL);
#else
  return app(argc, argv);
#endif
}
