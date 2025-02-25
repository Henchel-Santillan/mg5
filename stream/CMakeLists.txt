cmake_minimum_required(VERSION 3.21)
project(mg5-stream
        DESCRIPTION "GStreamer application for UVC-compliant IMX219 USB camera streaming over UDP to QGroundControl"
        VERSION 1.0.0
        LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
find_package(Threads REQUIRED)

pkg_check_modules(GSTREAMER REQUIRED gstreamer-1.0)

set(MG5_STREAM_TARGET mg5-stream-app)
list(APPEND MG5_STREAM_SOURCES
        "src/main.cpp")

add_executable(${MG5_STREAM_TARGET} ${MG5_STREAM_SOURCES})

target_include_directories(${MG5_STREAM_TARGET} PRIVATE "${GSTREAMER_INCLUDE_DIRS}")
target_link_libraries(${MG5_STREAM_TARGET} PRIVATE "${GSTREAMER_LIBRARIES}" Threads::Threads)
target_compile_options(${MG5_STREAM_TARGET} PRIVATE -Wall -Werror -Wextra)

set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}")

# Define install locations
install(TARGETS ${MG5_STREAM_TARGET}
    RUNTIME DESTINATION bin)
