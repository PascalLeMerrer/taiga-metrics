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

class ProjectConfig(DB.Model):
    """Database model for project preferences about metrics."""

    __tablename__ = 'project_config'
    project_id = DB.Column(DB.Integer, primary_key=True)
    work_start_status = DB.Column(DB.Integer, default=0)
    finish_status = DB.Column(DB.Integer, default=0)

    def __repr__(self):
        return "<ProjectConfig {}: start status= {}, end status={}".format(
            self.project_id, self.work_start_status, self.finish_status)

    def __init__(self, project_id=None,
                 work_start_status=None,
                finish_status=None):
        self.project_id = project_id
        self.work_start_status = work_start_status
        self.finish_status = finish_status


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