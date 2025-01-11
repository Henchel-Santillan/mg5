#!/bin/bash

python3 -m pip install pyinstaller
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install pyside6
