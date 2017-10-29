@wip
Feature: user
  As a Taiga user
  I can connect to Taiga metrics

  Background: Set target server address and headers
    Given I am using server "$SERVER"

  @wip
  Scenario: Non authenticated used cannot access metrics
    When I make a GET request to "/project/1/metrics"
    Then the response status should be 401

  @wip
  Scenario: Test Login With Wrong Password should fail
    Given I set BasicAuth to wrong credentials
    When I make a POST request to "sessions"
    Then the response status should be 401

  @wip
  Scenario: User can authenticate using its Taiga credentials
    Given I set BasicAuth to test user credentials
    When I make a POST request to "/sessions"
    Then the response status should be 200
    And the JSON at path "sessionId" should match "\w"


