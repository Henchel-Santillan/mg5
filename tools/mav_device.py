from pymavlink import mavutil

from abc import ABC, abstractmethod
from typing import List

import argparse
import json
import pathlib
import queue
import sys

DEFAULT_HEARTBEAT_TIMEOUT_SEC = 60
DEFAULT_MAX_QUEUE_SIZE = 100
DEFAULT_BAUD_RATE = 9600
DEFAULT_BLOCKING_SEND_TIMEOUT_SEC = 2
EXIT_FAILURE = -1

class MessageParser(ABC):
    def __init__(self):
        self.parsed = False

    @abstractmethod
    def parse(self, template: str) -> bool:
        pass

    @abstractmethod
    def build(self) -> List[Message] | None:
        pass

class JsonMessageParser(MessageParser):
    """
    The structure of a MAVLink message in the JSON file is as follows:
    {
        message1: {
            system: <system id>,
            component: <component id>,
            command: <command id>,
            parameters: {
                param1: value1,
                param2: value2,
                ...
                paramN: valueN
            }
        }

        message2 : {...}
        ...
    }
    An example is given in messages.json
    """
    def __init__(self):
        super().__init__()
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
            print(f"Failed to parse .json file at {template}.\nSee line {e.lineno}, column {e.colno}\n{e.msg}\n.")
            return False
        
        self.parsed = True
        return True
    
    def build(self) -> List[Message] | None:
        if not self.parsed:
            print("Failed to build message: template file not parsed.")
            return None
        
        messages = []
        for key, value in self.message.items():
            print("")

        # Reset value of parsed
        self.parsed = False
        return messages
    
class CmdMessageParser(MessageParser):
    def __init__(self):
        super().__init__()

    def parse(self, template: str) -> bool:
        pass

    def build(self) -> List[Message] | None:
        pass

class SerialMessenger:
    def __init__(self, port, baud=DEFAULT_BAUD_RATE):
        self.serial_port = mavutil.MavlinkSerialPort(port, baud)
        self.q = queue.Queue(maxsize=DEFAULT_MAX_QUEUE_SIZE)

    def load(self, message) -> None:
        self.q.put_nowait(message)

    def load_all(self, messages) -> None:
        for message in messages:
            self.load(message)

    def send_blocking(self, timeout_sec=DEFAULT_BLOCKING_SEND_TIMEOUT_SEC):
        # Send all queued MAVLink messages
        while not self.q.empty():
            message = self.q.get_nowait()
            print("Sending message")
        
def usage_string() -> str:
    return "python3 mav_device.py port [-t|--template <path_to_template>] [-m|--message <parameters ...>]"

def main():
    parser = argparse.ArgumentParser(description="Simulates an FCU or equivalent MAVLink message source over a serial link", usage=usage_string())
    parser.add_argument("port", default=None, help="The name of the serial port device to read from and write to")
    parser.add_argument("-t", "--template", default=None, required=False, help="The .json template messages file")
    parser.add_argument("-m", "--message", default=None, required=False, help="Space-separated parameters for a single MAVLink message")
    args = parser.parse_args()

    if args.port is None:
        print("A serial port must be provided")
        sys.exit(EXIT_FAILURE)

    messenger = SerialMessenger(args.port)
    
    if args.template is not None:
        json_parser = JsonMessageParser()
        if not json_parser.parse(args.template):
            sys.exit(EXIT_FAILURE)

        messages = json_parser.build()
        if messages is None:
            sys.exit(EXIT_FAILURE)

        messenger.load_all(messages)
        messenger.send_blocking()

    else:
        if args.message is None:
            print("Please provide either a JSON template file or space-separated parameters for a single MAVLink message.")
            sys.exit(EXIT_FAILURE)

        cmd_parser = CmdMessageParser()
        if not cmd_parser.parse(args.message):
            sys.exit(EXIT_FAILURE)
        
        

        

if __name__ == "__main__":
    main()
