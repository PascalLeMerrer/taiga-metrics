import os
import sys

from time import sleep

from flask import Flask, jsonify, request, send_from_directory

from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS


INTERVAL_BETWEEN_CONNECTION_ATTEMPTS = 5 # seconds

app = Flask(__name__, static_folder='public', static_url_path='/public')
CORS(app)

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

DATABASE_URI = "postgresql+psycopg2://{}:{}@{}/{}".format (
    os.environ['POSTGRES_USER'],
    os.environ['POSTGRES_PASSWORD'],
    os.environ['POSTGRES_HOST'],
    os.environ['POSTGRES_DB'])

app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URI

db = SQLAlchemy(app)


from models import ProjectConfig

db_is_not_connected = True

while db_is_not_connected:
    try:
        # TODO replace print with logs
        print("Checking connection to db...")
        db.create_all()
        print("Connection to db is OK.")
        db_is_not_connected = False

    except Exception as e:

        print("Connection to db failed: {}".format (e))
        sys.stdout.flush()
        sleep(INTERVAL_BETWEEN_CONNECTION_ATTEMPTS)

migrate = Migrate(app, db)

@app.route('/')
def index():
    return send_from_directory(app.static_folder, "index.html")


@app.route('/isalive', methods = ['GET'])
def is_alive():
    """ server healthcheck endpoint """
    return 'OK'

import connection_endpoints
import project_endpoints

if __name__ == '__main__':
    print(f'serving static content from {app.static_folder}')
    # activate hot reloading
    app.debug = True
    app.run()