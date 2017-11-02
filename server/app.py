import os
import sys

from time import sleep

from flask import Flask, jsonify, request

from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy

INTERVAL_BETWEEN_CONNECTION_ATTEMPTS = 5 # seconds

APP = Flask(__name__)

APP.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

DATABASE_URI = "postgresql+psycopg2://{}:{}@{}/{}".format (
    os.environ['POSTGRES_USER'],
    os.environ['POSTGRES_PASSWORD'],
    os.environ['POSTGRES_HOST'],
    os.environ['POSTGRES_DB'])

APP.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URI

DB = SQLAlchemy(APP)

from models import ProjectConfig

db_is_not_connected = True

while db_is_not_connected:
    try:
        print("Checking connection to DB...")
        DB.create_all()
        print("Connection to DB is OK.")
        db_is_not_connected = False

    except Exception as e:

        print("Connection to DB failed: {}".format (e))
        sys.stdout.flush()
        sleep(INTERVAL_BETWEEN_CONNECTION_ATTEMPTS)

migrate = Migrate(APP, DB)



@APP.route('/')
def index():
    return 'Hello, World!'

@APP.route('/insert')
def insert():
    project_config = ProjectConfig(666, 1, 3)
    DB.session.add(project_config)
    DB.session.commit()
    return "{ \"msg\" : \"ProjectConfig inserted!\" }"


@APP.route('/isalive')
def is_alive():
    return 'OK'


@APP.route('/sessions', methods = ['POST'])
def login():
    data = request.get_json()
    print("login query parameters {}".format(data) )
    sys.stdout.flush()
    # fake implementation
    # TODO query Taiga API
    if ('username' not in data
        or data['username'] != 'test-user'
        or 'password' not in data
        or data['password'] != 'test-password'):
        response = jsonify(message ="BAD CREDENTIALS")
        response.status_code = 401
        return response

    response = jsonify(
        username="test-user",
        full_display_name="TEST USER",
        auth_token="TEST_AUTH_TOKEN"
    )
    return response

if __name__ == '__main__':
    # activate hot reloading
    APP.debug = True
    APP.run()