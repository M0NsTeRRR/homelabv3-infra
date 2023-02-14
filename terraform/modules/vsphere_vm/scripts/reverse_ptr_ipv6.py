#!/usr/bin/env python3

import argparse
import ipaddress
import json
import sys

parser = argparse.ArgumentParser()
parser.add_argument("ipv6", action="store", help="IPv6 to reverse")
args = parser.parse_args()

try:
    ipv6 = ipaddress.IPv6Address(args.ipv6)
    print(json.dumps({"reversed": f"{ipv6.reverse_pointer}."}))
except ipaddress.AddressValueError:
    print(f"{args.ipv6} is not a valid IPv6 address")
    sys.exit(1)
