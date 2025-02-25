#!/bin/bash

rm -rf bin
cmake -B bin -G Ninja -S .
cmake --build bin
cmake --install bin
