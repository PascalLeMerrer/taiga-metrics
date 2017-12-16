from flask import request, jsonify
from app import app
from auth import requires_authentication, authenticate, logout, AUTH_HEADER

@app.route('/sessions', methods = ['POST'])
def login():
    user_profile = authenticate(request.get_json())
    if user_profile is False:
        response = jsonify(message ="Unauthorized")
        response.status_code = 401
        return response
    response = jsonify(user_profile)
    return response, 201

@app.route('/sessions', methods = ['DELETE'])
@requires_authentication
def kill_session():
    token = request.headers[AUTH_HEADER]
    logout(token)
    return "", 204