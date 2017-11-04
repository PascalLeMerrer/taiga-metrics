import os
import sys

from time import sleep

from flask import Flask, jsonify, request, send_from_directory

from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy

from auth import are_valid_credentials, authenticate, requires_authentication

INTERVAL_BETWEEN_CONNECTION_ATTEMPTS = 5 # seconds

APP = Flask(__name__, static_folder='static', static_url_path='')

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


# example of insertion in DB - MUST be removed
@APP.route('/insert', methods = ['POST'])
@requires_authentication
def insert():
    project_config = ProjectConfig(666, 1, 3)
    DB.session.add(project_config)
    DB.session.commit()
    return "{ \"msg\" : \"ProjectConfig inserted!\" }"


@APP.route('/')
def index():
    return send_from_directory(APP.static_folder, "index.html")


@APP.route('/isalive', methods = ['GET'])
def is_alive():
    """ server healthcheck endpoint """
    return 'OK'

import connection_endpoints
import project_endpoints

if __name__ == '__main__':
    # activate hot reloading
    APP.debug = True
    APP.run()