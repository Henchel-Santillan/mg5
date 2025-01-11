# This script builds and packages the display interface into a single executable file
# https://stackoverflow.com/questions/58035550/pyinstaller-and-qml-files

import argparse
import pathlib
import subprocess
import sys

import xml.etree.ElementTree as ET

from typing import List

DEFAULT_QML_QRC_FNAME = "qml"
DEFAULT_PYINSTALLER_CMD = ["pyinstaller", "main.py", "--onefile"]

def run_command(cmd: List[str]) -> bool:
    result = subprocess.run(cmd)
    if result:
        print(f"[Error {result.returncode}]: {cmd[0]} failed.\n{result.stdout}")
        return False
    return True

def generate_qrc_file(root_path_str, qml_files: List[str]) -> str:
    root = ET.Element("RCC")
    qresource = ET.SubElement(root, "qresource", {"prefix": "/"})
    
    for qml_file in qml_files:
        file = ET.SubElement(qresource, "file")
        file.text = qml_file.name

    tree = ET.ElementTree(root)

    qrc_file_path = f"{root_path_str}/{DEFAULT_QML_QRC_FNAME}.qrc"
    tree.write(qrc_file_path, encoding="utf-8", xml_declaration=True)
    return qrc_file_path

def bundle(qrc_str_path: str) -> bool:
    RCC_COMMAND = ["pyside6-rcc", qrc_str_path, "-o", f"{qrc_str_path.stem}_{qrc_str_path.suffix}.py"]

    for cmd in [RCC_COMMAND, DEFAULT_PYINSTALLER_CMD]:
        if not run_command(cmd):
            return False
    return True

def recurse_and_bundle(root_path_str: str) -> bool:
    root_path = pathlib.Path(root_path_str)
    if not root_path.exists():
        print(f"Error: {root_path} does not exist")
        return False

    qml_file_paths = list(root_path.rglob("*.qml"))

    # Generate the .qrc file in the root directory provided
    qrc_str_path = generate_qrc_file(root_path_str, qml_file_paths)
    return bundle(qrc_str_path)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--collect", action="store_false", help="Flag specifying whether QML files will be collected")
    parser.add_argument("-r", "--root", required=False, default=None, help="Root directory to start recursively searching for .qml files")
    parser.add_argument("--qrc", help="Path to .qrc file specifying QML files to bundle")

    args = parser.parse_args()
    if args.collect and args.root is not None:
        if not recurse_and_bundle(args.root):
            print("Failed to create executable from provided root directory.")
            sys.exit(-1)
    else:
        if not bundle(args.qrc):
            print("Failed to create executable from provided .qrc file path.")
            sys.exit(1)

if __name__ == "__main__":
    main()
