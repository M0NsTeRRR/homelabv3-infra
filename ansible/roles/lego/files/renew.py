#!/usr/bin/env python3
import shutil
import subprocess
import argparse
import os
import sys
import json

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--config", action="store", help="Config file.", required=True)
    return parser.parse_args()


def get_lego_params(config, lego_json_file):
    additionnal_params = []

    for san in config["certificate"]["san"]:
        additionnal_params.append("-d")
        additionnal_params.append(san)
    if config["general"]["webserver_proxified"]:
        additionnal_params.append("--http.port")
        additionnal_params.append(f"localhost:{config['general']['webroot_port']}")
    if os.path.isfile(lego_json_file):
        additionnal_params.append("renew")
        additionnal_params.append("--days")
        additionnal_params.append(config["general"]["days"])
    else:
        additionnal_params.append("run")

    return additionnal_params

def run_lego(config, base_folder, lego_json_file):
    return subprocess.run(
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
        *get_lego_params(config, lego_json_file)
    ], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

def main():
    args = get_args()

    renewed = False
    created = False
    timestamp_lego_json_file = -1

    with open(args.config, "r") as f:
        config = json.load(f)

    base_folder = os.path.join(config["general"]["lego_config_folder"], config["certificate"]["domain"])
    lego_json_file = os.path.join(base_folder, "certificates", f"{config['certificate']['domain']}.json")

    if os.path.isfile(lego_json_file):
        # get file timestamp to check if certificate were renewed
        timestamp_lego_json_file = os.path.getmtime(lego_json_file)
    else:
        created = True

    if not config["general"]["webserver_proxified"]:
        p_http = subprocess.run(["ufw", "allow", "http", "comment", "lego (script)"], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        if p_http.returncode != 0:
            print(p_http.stderr)
            sys.exit(p_http.returncode)

    p_lego = run_lego(config, base_folder, lego_json_file)

    # if ACME account is invalid retry one time (in case of ACME unregistration)
    if p_lego.returncode != 0 and "Use 'run' to register a new account" in p_lego.stderr:
        print("Delete lego json file and retry renew")
        p_delete = subprocess.run(["rm", "-f", lego_json_file], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        if p_delete.returncode != 0:
            print(p_delete.stderr)
            sys.exit(p_delete.returncode)
        p_lego = run_lego(config, base_folder, lego_json_file)

    if not config["general"]["webserver_proxified"]:
        p_http = subprocess.run(["ufw", "delete", "allow", "http"], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        if p_http.returncode != 0:
            print(p_http.stderr)
            sys.exit(p_http.returncode)

    if p_lego.returncode != 0:
        print(p_lego.stderr)
        sys.exit(p_lego.returncode)

    if os.path.getmtime(lego_json_file) > timestamp_lego_json_file:
        renewed = True

    if created:
        print(f"certificate {config['certificate']['domain']} created")
    elif renewed:
        print(f"certificate {config['certificate']['domain']} renewed")
    else:
        print(f"Certificate {config['certificate']['domain']} is still valid")

    need_systemd_service_update = False

    for destination in config["destinations"]:
        for cert_type in [("crt", 0o640,), ("key", 0o600,)]:
            dest_cert = os.path.join(destination["path"], f"{destination['filename']}{'-fullchain' if cert_type[0] == 'crt' else ''}.{cert_type[0]}")
            dest_cert_exists = os.path.isfile(dest_cert)
            if not dest_cert_exists or created or renewed:
                need_systemd_service_update = True
                shutil.copy2(
                    os.path.join(base_folder, "certificates", f"{config['certificate']['domain']}.{cert_type[0]}"),
                    dest_cert
                )
                shutil.chown(dest_cert, destination["owner"], destination["group"])
                os.chmod(dest_cert, cert_type[1])
                print(f"certificate copied to {dest_cert}")

    if need_systemd_service_update or created or renewed:
        # need to rework this part properly to restart affected service only
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


if __name__ == "__main__":
    main()