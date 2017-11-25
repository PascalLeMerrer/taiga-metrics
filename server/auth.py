from flask import jsonify, request
from functools import wraps


AUTH_HEADER = "Authorization"

def are_valid_credentials(data):
    #TODO query taiga login API https://taigaio.github.io/taiga-doc/dist/api.html#auth-normal-login
    return data is not None \
        and 'email' in data \
        and data['email'] == 'test@user.com' \
        and 'password' in data \
        and data['password'] == 'test-password'


def authenticate():
    response = jsonify(message ="Unauthorized")
    response.status_code = 401
    return response


def requires_authentication(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        """ Verifies the Authorisation header contains a valid token """
        if AUTH_HEADER not in request.headers:
            return authenticate()
        token = request.headers[AUTH_HEADER]
        if _is_valid_token(token):
            return f(*args, **kwargs)
        else:
            return authenticate()

    return decorated


def _is_valid_token(token):
    # TODO verify token is in DB and is not expired
    return True
