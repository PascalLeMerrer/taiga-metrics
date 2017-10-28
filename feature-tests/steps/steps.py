import os
from behave import *
from behave_http.steps import *
from datadiff.tools import assert_equal

# By default TestCase limits diff length to 640 characters.
# Setting maxDiff to None allows unlimited diffs.
from unittest import TestCase
TestCase.maxDiff = None


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
        '''.format(context.test_user_credentials[0], 'wrong password'))
