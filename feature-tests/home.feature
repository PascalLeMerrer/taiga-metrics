Feature: server responses
  As an HTTP API client
  I want to make sure the API responds to requests

  Background: Set target server address and headers
    Given I am using server "$SERVER"
    And I reset the database content

  Scenario: Test get default hello
    When I make a GET request to "/"
    Then the response status should be 200

  Scenario: Test inserting in DB
    When I make a GET request to "/insert"
    Then the response status should be 200
    And the JSON should be
    """
        { "msg" : "ProjectConfig inserted!" }
    """

