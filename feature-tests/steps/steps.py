import os
from behave import *
from behave_http.steps import *
from datadiff.tools import assert_equal

import psycopg2

# By default TestCase limits diff length to 640 characters.
# Setting maxDiff to None allows unlimited diffs.
from unittest import TestCase
TestCase.maxDiff = None


db_host = os.getenv('POSTGRES_HOST')
db_name = os.getenv('POSTGRES_DB')
db_user = os.getenv('POSTGRES_USER')
db_password = os.getenv('POSTGRES_PASSWORD')
connection_parameters = "host={} dbname={} user={} password={}".format(db_host,
    db_name, db_user, db_password)
connection = psycopg2.connect(connection_parameters)
cursor = connection.cursor()


@behave.given('I set BasicAuth to test user credentials')
@dereference_step_parameters_and_data
def set_basic_auth_to_test_user(context):
    context.execute_steps('''
        Given I set BasicAuth username to "{}" and password to "{}"
        '''.format(*context.test_user_credentials))

@behave.given('I set BasicAuth to wrong credentials')
@dereference_step_parameters_and_data
def set_basic_auth_to_wrong_credentials(context):
    context.execute_steps('''
        Given I set BasicAuth username to "{}" and password to "{}"
        '''.format(context.test_user_credentials[0], 'WRONG PASSWORD'))


@behave.given('I reset the database content')
def reset_db(context):
    cursor.execute("DELETE FROM project_config WHERE 1=1")
    connection.commit()