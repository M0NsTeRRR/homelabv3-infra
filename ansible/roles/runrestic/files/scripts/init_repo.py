#!/usr/bin/env python3
import subprocess
import argparse

import toml

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--config", action="store", help="Config file path", required=True)
args = parser.parse_args()

parsed_cfg = toml.load(args.config)

for repository in parsed_cfg["repositories"]:
    p = subprocess.run(["restic", "-r", repository, "-p", parsed_cfg["environment"]["RESTIC_PASSWORD_FILE"], "cat", "config", ">/dev/null", "2>&1"], stdout=subprocess.DEVNULL)
    if p.returncode == 0:
        print("repo is already initialized")
    else:
        subprocess.run(["/opt/runrestic/venv/bin/runrestic", "-c", args.config, "init"])
