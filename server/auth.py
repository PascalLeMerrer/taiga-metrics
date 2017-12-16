from flask import jsonify, request
from functools import wraps

import requests
import os
import logging
import json
import sys

logger = logging.getLogger('auth')

AUTH_HEADER = "Authorization"
API_URL = os.getenv("TAIGA_API_URL", 'https://api.taiga.io/api/v1')

def are_valid_credentials(data):
    return False


def authenticate(data):

    if data is None or 'username' not in data or 'password' not in data:
        return False

    user_profile = _delegate_authentication(data['username'], data['password'])
    if not user_profile:
        return False

    return {
          "username": user_profile['username'],
          "full_display_name": user_profile['full_name_display'],
          "auth_token": user_profile['auth_token']
    }


def _delegate_authentication(username, password):
    """ makes a request to Taiga to authenticate the user with the provided credentials"""
    payload = json.dumps({
        'type': 'normal',
        'username': username,
        'password': password
    })
    headers = {'Content-Type': 'application/json'}
    login_response = requests.post(API_URL + "/auth", data=payload, headers=headers)
    if login_response.status_code != 200:
        return False

    try:
        decoded_response = login_response.json()
    except ValueError as error:
        logger.error(f'Cannot decode Taiga auth response: {error}. Response was: {login_response}')
        return False
    return decoded_response


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
