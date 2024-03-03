#!/usr/bin/env python3

import shutil
import subprocess
import argparse
import os
import sys
import json

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--config", action="store", help="Config file.", required=True)
args = parser.parse_args()

with open(args.config, "r") as f:
  config = json.load(f)

base_folder = os.path.join(config["general"]["lego_config_folder"], config["certificate"]["domain"])
lego_json_file = os.path.join(base_folder, f"{config['certificate']['domain']}.json")

additionnal_params = []
for san in config["certificate"]["san"]:
    additionnal_params.append("-d")
    additionnal_params.append(san)
if "webroot" in config["general"]:
    additionnal_params.append("--http.webroot")
    additionnal_params.append(config["general"]["webroot"])
if os.path.isfile(os.path.join(base_folder, "accounts", lego_json_file)):
    additionnal_params.append("--days")
    additionnal_params.append(config["general"]["days"])
    additionnal_params.append("renew")
else:
    additionnal_params.append("run")

if "webroot" in config["general"]:
    p_http = subprocess.run(["ufw", "allow", "http"], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    if p_http.returncode != 0:
        print(p_http.stderr)
        sys.exit(p_http.returncode)

p_lego = subprocess.run(
    [
        "lego",
        "--server",
        config["general"]["server"],
        "--email",
        config["general"]["account_email"],
        "--accept-tos",
        "--http",
        "-d",
        config["certificate"]["domain"],
        "--path",
        base_folder,
        *additionnal_params
    ], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

if "webroot" in config["general"]:
    p_http = subprocess.run(["ufw", "delete", "allow", "http"], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    if p_http.returncode != 0:
        print(p_http.stderr)
        sys.exit(p_http.returncode)

if p_lego.returncode != 0:
    print(p_lego.stderr)
    sys.exit(p_lego.returncode)
else:
    print(f"certificate {config['certificate']['domain']} renewed")


for destination in config["destinations"]:
    for cert_type in [("crt", 0o640,), ("key", 0o600,)]:
        dest_cert = os.path.join(destination["path"], f"{destination['filename']}{'-fullchain' if cert_type[0] == 'crt' else ''}.{cert_type[0]}")
        shutil.copy2(
            os.path.join(base_folder, "certificates", f"{config['certificate']['domain']}.{cert_type[0]}"),
            dest_cert
        )
        shutil.chown(dest_cert, destination["owner"], destination["group"])
        os.chmod(dest_cert, cert_type[1])
    print(f"certificate copied to {destination['path']}")


for systemd_service in config["systemd_services"]:
    if systemd_service["state"] == "started":
        state = "start"
    elif systemd_service["state"] == "stopped":
        state = "stop"
    else:
        state = "restart"
    p_service = subprocess.run(["systemctl", state, systemd_service["name"]], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    if p_service.returncode != 0:
        print(p_service.stderr)
    else:
        print(f"service {systemd_service['name']} {systemd_service['state']}")
