import os
from behave_http.environment import before_scenario

default_env = {
    'SERVER': 'http://server:5000',
    'FRONT_END': 'http://frontend:8080',
    'USERNAME': 'test-user',
    'PASSWORD': 'test-password'
}

def before_all(context):
    for k, v in default_env.items():
        os.environ[k] = v

