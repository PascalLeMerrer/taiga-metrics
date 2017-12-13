from flask import jsonify, request
from functools import wraps

import requests
import os
import json
import sys

AUTH_HEADER = "Authorization"
API_URL = os.getenv("TAIGA_API_URL", 'https://api.taiga.io/api/v1')
print(f"API_URL: {API_URL}")
sys.stdout.flush()

def are_valid_credentials(data):
    return False


def authenticate(data):
    print(f'authenticate called with data {data}\n\n')
    sys.stdout.flush()
    if data is None:
        return False
    if 'username' not in data:
        return False
    if 'password' not in data:
        return False

    payload = json.dumps({
        'type': 'normal',
        'username': data['username'],
        'password': data['password']
    })
    headers = {'Content-Type': 'application/json'}

    print(f'Ready to send POST to {API_URL + "/auth"} with payload {payload} and headers {headers}')
    sys.stdout.flush()


    login_response = requests.post(API_URL + "/auth", data=payload, headers=headers)
    print(f'login_response: {login_response}')
    sys.stdout.flush()
    if login_response.status_code != 200:
        return False

    # TODO catch decoding exception
    decoded_response = login_response.json()
    return {
          "username": decoded_response['username'],
          "full_display_name": decoded_response['full_name_display'],
          "auth_token": decoded_response['auth_token']
    }


def requires_authentication(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        """ Verifies the Authorisation header contains a valid token """
        if AUTH_HEADER not in request.headers:
            return 'Unauthorized', 401

        token = request.headers[AUTH_HEADER]
        if _is_valid_token(token):
            return f(*args, **kwargs)
        else:
            return 'Unauthorized', 401

    return decorated


def _is_valid_token(token):
    # TODO verify token is in DB and is not expired
    return True
