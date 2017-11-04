  Feature: user
  As a Taiga user
  I can get metrics on my Taiga projects

  Background: Set target server address and headers
    Given I am using server "$SERVER"

  @wip
  @metrics
  Scenario: Non authenticated used cannot access metrics
    When I make a GET request to "/project/1/metrics"
    Then the response status should be 401