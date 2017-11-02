import os
import re

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


@behave.given('I set template variable "{variable}" to "{value}"')
@dereference_step_parameters_and_data
def store_for_template(context, value, variable):
    context.template_data[variable] = value

@behave.then('the JSON at path "{jsonpath}" should match "{pattern}"')
@dereference_step_parameters_and_data
def eval_at_path(context, jsonpath, pattern):
    value = jpath.get(jsonpath, context.response.json())
    match = re.match(pattern, value)
    return match is not None

@behave.then('the JSON should contain')
@dereference_step_parameters_and_data
def eval_body(context):

    expected = json.loads(context.data.decode('utf-8'))
    real = context.response.json()

    if not equal(expected, real):
        # Display the diff
        assert_equal(expected, real)

@behave.given('I reset the database content')
def reset_db(context):
    cursor.execute("DELETE FROM project_config WHERE 1=1")
    connection.commit()

def equal(expected, real):
    """
    Compares two JSON objects
    Returns true when the real object contains all the values in the expected one
    Properties figuring in the real object and not in the expected one are ignored
    It allows to compare server responses with time dependent or random values,
    like IDs or timestamps
    """
    if type(expected) is list and type(real) is list:
        for element in expected:
            if all(not equal(element, real_element) for real_element in real):
                return False
        return True

    if type(expected) is dict and type(real) is dict:
        for key in expected:
            if not key in real:
                return False
            if not equal(expected[key], real[key]):
                return False
        return True

    return expected == real

