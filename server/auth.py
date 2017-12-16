from flask import jsonify, request
from functools import wraps

from datetime import datetime, timedelta
import requests
import os
import logging
import json

from app import db
from models import UserSession

logger = logging.getLogger('auth')

SESSION_DURATION = timedelta(days=1)
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

    _save_token(user_profile)

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


def _save_token(user_profile):
    user_session = UserSession(user_profile['id'],
        user_profile['auth_token'],
        datetime.utcnow() + SESSION_DURATION)
    db.session.add(user_session)
    db.session.commit()


def requires_authentication(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        """ Verifies the Authorisation header contains a valid token
            and updates its duration
        """
        if AUTH_HEADER not in request.headers:
            return 'Unauthorized', 401

        token = request.headers[AUTH_HEADER]
        if _is_valid_token(token):
            return f(*args, **kwargs)
        else:
            return 'Unauthorized', 401

    return decorated


def _is_valid_token(token):
    """verifies token is in DB and is not expired
       and updates its expiration date if required
    """
    user_session = UserSession.query.get(token)
    if user_session is None:
        return False
    if user_session.expiration_date < datetime.utcnow():
        return False
    user_session.expiration_date = datetime.utcnow() + SESSION_DURATION
    db.session.commit()
    return True


def logout(token):
    UserSession.query.filter(UserSession.token == token).delete()
    db.session.commit()