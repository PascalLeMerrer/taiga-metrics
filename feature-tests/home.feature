Feature: server responses
  As an HTTP API client
  I want to make sure the API responds to requests

  Background: Set target server address and headers
    Given I am using server "$SERVER"
    And I reset the database content

  Scenario: Test verify healthcheck
    When I make a GET request to "/isalive"
    Then the response status should be 200

  Scenario: Test homepage is accessible
    Given I set "Accept" header to "text/html"
    When I make a GET request to "/"
    Then the response status should be 200
    And the response should contain
    """
    <title>Taiga Metrics</title>
    """

  # TODO remove
  @wip
  Scenario: Test inserting in DB
    Given I authenticate as test user
    When I make a POST request to "/insert"
    """
    """
    Then the response status should be 200
    And the JSON should be
    """
        { "msg" : "ProjectConfig inserted!" }
    """

