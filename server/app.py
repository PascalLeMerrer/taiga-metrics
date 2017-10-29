import os

from flask import Flask

from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy

#from models import *

APP = Flask(__name__)
APP.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

APP.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql+psycopg2://%s:%s@%s/%s' % (
    os.environ['POSTGRES_USER'],
    os.environ['POSTGRES_PASSWORD'],
    os.environ['POSTGRES_HOST'],
    os.environ['POSTGRES_DB']
)

# activate hot reloading
APP.debug = True

# initialize the database connection
DB = SQLAlchemy(APP)

from models import ProjectConfig


# initialize database migration management
MIGRATE = Migrate(APP, DB)

DB.create_all()

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

if __name__ == '__main__':
     app.run()