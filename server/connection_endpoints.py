from flask import request, jsonify
from app import APP
from auth import are_valid_credentials

@APP.route('/sessions', methods = ['POST'])
def login():
    """ authenticates a given user """
    data = request.get_json()

    # fake implementation
    # TODO query Taiga API
    # and put Token in DB, with an expiration timestamp
    if not are_valid_credentials(data):
        return authenticate()

    response = jsonify(
        username="test-user",
        full_display_name="TEST USER",
        auth_token="TEST_AUTH_TOKEN"
    )
    return response