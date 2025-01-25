from pymavlink import mavutil
from typing import Dict, TypedDict

import argparse
import json
import pathlib
import queue
import sys

DEFAULT_HEARTBEAT_TIMEOUT_SEC = 60
DEFAULT_MAX_QUEUE_SIZE = 100
DEFAULT_BAUD_RATE = 9600
EXIT_FAILURE = -1

class JsonMessageParser:
    """
    The structure of a MAVLink message in the JSON file is as follows:
    {

    }
    """
    def __init__(self):
        self.message = {}

    def parse(self, template: str) -> bool:
        path = pathlib.Path(template)
        if not path.exists() and not path.stem == ".json":
            print(f"Path {template} could not be found.")
            return False

        try:
            with open(template, mode="r") as file:
                self.message = json.loads(file)
        except json.JSONDecodeError as e:
            print(f"Failed to parse .json file at {template}\n{e.msg}\n.See line {e.lineno}, column {e.colno}\n")
            return False
        return True
    
    def build_message(self):
        pass

class SerialMessenger:
    def __init__(self, port, baud=DEFAULT_BAUD_RATE):
        self.conn = mavutil.MavlinkSerialPort(port, baud)
        self.q = queue.Queue(maxsize=DEFAULT_MAX_QUEUE_SIZE)

    def load(self, message):
        self.q.put_nowait(message)

    def send(self):
        while not self.q.empty():
            message = self.q.get_nowait()
            print("Sending message")
        
def usage_string() -> str:
    return "mav_device.py [] []"

def parse_message_params(message: str):
    pass

def main():
    parser = argparse.ArgumentParser(description="Simulates an FCU or equivalent MAVLink message source", usage=usage_string())
    parser.add_argument("port", help="The name of the serial port device to read from and write to")
    parser.add_argument("-t", "--template", default=None, required=False, help="The .json template messages file")
    parser.add_argument("-m", "--message", default=None, required=False, help="Space-separated parameters for a single MAVLink message")
    args = parser.parse_args()

    # conn = mavutil.mavlink_connection()
    # conn.wait_heartbeat()
    # print(f"Received heartbeat from system {conn.target_system}, component {conn.target_component}")

    messenger = SerialMessenger()
    
    if args.template is not None:
        json_parser = JsonMessageParser()
        if not json_parser.parse(args.template):
            sys.exit(EXIT_FAILURE)
        message = json_parser.build_message()
        messenger.load(message)
        messenger.send()        

if __name__ == "__main__":
    main()
