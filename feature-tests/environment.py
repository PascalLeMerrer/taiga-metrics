import os
from behave_http.environment import before_scenario

default_env = {
    'SERVER': 'http://server:5000',
    'USERNAME': 'user',
    'PASSWORD': 'pass'
}

def before_all(context):
    for k, v in default_env.items():
        os.environ[k] = v

