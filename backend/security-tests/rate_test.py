#!/usr/bin/env python3
import argparse
import json
import requests
import concurrent.futures
import urllib3

# Disable insecure request warnings (like InsecureRequestWarning)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def send_post(url, data, headers, is_raw=False):
    try:
        # If is_raw is True, send the payload using the data parameter (as plain text)
        if is_raw:
            response = requests.post(url, data=data, headers=headers, verify=False)
        else:
            response = requests.post(url, json=data, headers=headers, verify=False)
        print(f"Status: {response.status_code}, Body: {response.text}")
        print("Response Headers:", response.headers)
    except Exception as e:
        print("Error:", e)

def main():
    parser = argparse.ArgumentParser(
        description="Dynamic rate testing tool for POST requests with multiple test cases."
    )
    parser.add_argument(
        "--url", required=True, help="Target URL for the POST request"
    )
    parser.add_argument(
        "--data", required=True, help="JSON data payload (as a JSON string)"
    )
    parser.add_argument(
        "--headers", required=True, help="JSON headers (as a JSON string)"
    )
    parser.add_argument(
        "--test-type",
        choices=["valid", "malformed", "missing-api", "injection", "rate-limit"],
        default="valid",
        help="Type of test to run"
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=10,
        help="Number of concurrent workers (default: 10)"
    )
    parser.add_argument(
        "--requests",
        type=int,
        default=100,
        help="Total number of requests to send (default: 100)"
    )
    args = parser.parse_args()

    # Attempt to load the payload and headers from the provided JSON strings
    try:
        payload = json.loads(args.data)
    except json.JSONDecodeError:
        print("Invalid JSON data provided.")
        return

    try:
        headers = json.loads(args.headers)
    except json.JSONDecodeError:
        print("Invalid JSON headers provided.")
        return

    # Modify the payload based on the test type
    is_raw = False
    if args.test_type == "malformed":
        # Remove last character to break JSON formatting
        payload = args.data[:-1]
        is_raw = True
    elif args.test_type == "missing-api":
        # Remove API key if present
        payload.pop("api_key", None)
    elif args.test_type == "injection":
        # Insert a common SQL injection payload into the API key field
        payload["api_key"] = "' OR '1'='1"
    # "valid" and "rate-limit" will use the provided payload unchanged

    # Send the requests concurrently
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = [
            executor.submit(send_post, args.url, payload, headers, is_raw)
            for _ in range(args.requests)
        ]
        concurrent.futures.wait(futures)

if __name__ == "__main__":
    main()