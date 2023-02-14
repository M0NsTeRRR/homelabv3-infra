#!/usr/bin/env python3

import argparse
import base64
import hashlib
import json
import socket
import sys

import paramiko

parser = argparse.ArgumentParser()
parser.add_argument("host", action="store", help="host to connect to")
parser.add_argument(
    "-p", "--port", action="store", dest="port", default="22", help="port to connect to"
)
args = parser.parse_args()

host = args.host
address = args.host + ":" + args.port

try:
    transport = paramiko.Transport(address)
    transport.connect()
    key = transport.get_remote_server_key()
    transport.close()
except socket.gaierror:
    print("Name or service not known")
    sys.exit(1)

if "rsa" in key.get_name():
    algorithm = 1
elif "dsa" in key.get_name():
    algorithm = 2
elif "ecdsa" in key.get_name():
    algorithm = 3
elif "ed25519" in key.get_name():
    algorithm = 4
else:
    print(f"{key.get_name()} algorithm not handled")
    sys.exit(1)

fingerprint = hashlib.sha256(base64.b64decode(key.get_base64())).hexdigest()


print(json.dumps({"sshfp": f"{algorithm} 2 {fingerprint}"}))
