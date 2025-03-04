#!/bin/bash

# FORMAT: specify raw image format output (MJPG or YUYV)
print_usage() {
    echo "Usage: ./build.sh [-f] FORMAT"
}

build_mg5_stream_app() {
    if [ $3 != "MJPG" ] && [ $3 != "YUYV" ]; then
        echo "Invalid raw format '$3' specified."
        exit 1
    fi

    build_dir=$1
    source_dir=$2
    rm -rf ${build_dir}

    if [ $3 == "MJPG" ]; then
        cmake -B ${build_dir} -G Ninja -S ${source_dir} -DUSE_MJPG=ON
    else
        cmake -B ${build_dir} -G Ninja -S ${source_dir}
    fi
    cmake --build ${build_dir} -j $(nproc)
    cmake --install ${build_dir}
}

while getopts 'm:' flag; do
    case "${flag}" in
        m) build_mg5_stream_app bin . ${OPTARG} ;;
        *) print_usage
        exit 1 ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    print_usage
    exit 1
fi
