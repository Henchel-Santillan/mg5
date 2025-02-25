#include <gst/gst.h>

#ifdef __APPLE__
#include <TargetConditionals.h>
#endif

int app(int argc, char *argv[]) {
  gst_init (&argc, &argv);

  // Build a static pipeline
  constexpr auto pipeline_str = "v4l2src device=/dev/video0 ! videoconvert ! x264enc speed-preset=ultrafast "
    "tune=zerolatency bitrate=1000 ! h264parse ! rtph264pay config-interval=1 pt=96 ! udpsink host=10.100.125.5 port=5600";

  auto pipeline = gst_parse_launch (pipeline_str, NULL);

  gst_element_set_state(pipeline, GST_STATE_PLAYING);

  auto bus = gst_element_get_bus(pipeline);
  auto msg = gst_bus_timed_pop_filtered (bus, GST_CLOCK_TIME_NONE, 
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
#if defined(__APPLE__) && TARGET_OS_MAC && !TARGET_OS_IPHONE
  return gst_macos_main((GstMainFunc) app, argc, argv, NULL);
#else
  return app(argc, argv);
#endif
}
