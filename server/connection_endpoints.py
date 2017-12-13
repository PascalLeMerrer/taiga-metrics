from flask import request, jsonify
from app import app
from auth import are_valid_credentials, authenticate

@app.route('/sessions', methods = ['POST'])
def login():
    user_profile = authenticate(request.get_json())
    if user_profile is False:
        response = jsonify(message ="Unauthorized")
        response.status_code = 401
        return response
    response = jsonify(user_profile)
    return response, 201