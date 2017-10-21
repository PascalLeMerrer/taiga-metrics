import os
from behave import *
from behave_http.steps import *
from datadiff.tools import assert_equal


default_env = {
    'SERVER': 'http://web:5000'
}

def before_all(context):
    for k, v in default_env.items():
        os.environ[k] = v