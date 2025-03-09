#!/usr/bin/env python3
import argparse
import json
import requests
import concurrent.futures
import urllib3

# Disable insecure request warnings (like InsecureRequestWarning)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def send_post(url, data, headers):
    try:
        response = requests.post(url, json=data, headers=headers, verify=False)
        print(response.status_code, response.text)
    except Exception as e:
        print("Error:", e)

def main():
    parser = argparse.ArgumentParser(
        description="Dynamic rate testing tool for POST requests."
    )
    parser.add_argument(
        "--url", required=True, help="Target URL for the POST request"
    )
    parser.add_argument(
        "--data", required=True, help="JSON data payload (as a JSON string)"
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=10,
        help="Number of concurrent workers (default: 10)",
    )
    parser.add_argument(
        "--requests",
        type=int,
        default=100,
        help="Total number of requests to send (default: 100)",
    )
    parser.add_argument(
        "--header",
        type=str,
        default='{"Content-Type": "application/json"}',
        help='HTTP headers as JSON (default: {"Content-Type": "application/json"})',
    )
    args = parser.parse_args()

    try:
        payload = json.loads(args.data)
    except json.JSONDecodeError:
        print("Invalid JSON data provided.")
        return

    try:
        headers = json.loads(args.header)
    except json.JSONDecodeError:
        print("Invalid JSON header provided.")
        return

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = [
            executor.submit(send_post, args.url, payload, headers)
            for _ in range(args.requests)
        ]
        concurrent.futures.wait(futures)

if __name__ == "__main__":
    main()