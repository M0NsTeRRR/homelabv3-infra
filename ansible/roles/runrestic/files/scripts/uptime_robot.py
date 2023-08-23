#!/usr/bin/env python3
import argparse

import requests

parser = argparse.ArgumentParser()
parser.add_argument("--api-key", action="store", help="API Key", required=True)
parser.add_argument("--monitor-id", action="store", help="Monitor ID", required=True)
parser.add_argument("--status", action="store", help="Monitor status", required=True)
args = parser.parse_args()

API_BASE_URL = "https://api.uptimerobot.com/v2"

requests.post(
    f"{API_BASE_URL}/editMonitor",
    headers={
        'cache-control': "no-cache",
        'content-type': "application/x-www-form-urlencoded"
    },
    data={
        "api_key": args.api_key,
        "format": "json",
        "id": args.monitor_id,
        "status": args.status,
    }
)

print(f"Uptime robot monitor {args.monitor_id} {'resumed' if args.status == '1' else 'paused'}")