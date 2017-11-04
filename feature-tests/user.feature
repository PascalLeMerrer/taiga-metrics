Feature: user
  As a Taiga user
  I can connect to Taiga metrics

  Background: Set target server address and headers
    Given I am using server "$SERVER"
    And I set "Accept" header to "application/json"
    And I set "Content-Type" header to "application/json"
    And I set template variable "USERNAME" to "$USERNAME"
    And I set template variable "PASSWORD" to "$PASSWORD"

  @user
  Scenario: Test Login With Wrong Password should fail
    When I make a POST request to "/sessions"
    """
    {
      "username": "{{USERNAME}}",
      "password": "BAD_PASSWORD"
    }
    """
    Then the response status should be 401

  @user
  Scenario: Test Login With Wrong Username should fail
    When I make a POST request to "/sessions"
    """
    {
      "username": "BAD_USER",
      "password": "{{PASSWORD}}"
    }
    """
    Then the response status should be 401

  @user
  Scenario: User can authenticate using its Taiga credentials
    When I make a POST request to "/sessions"
    """
    {
      "username": "{{USERNAME}}",
      "password": "{{PASSWORD}}"
    }
    """
    Then the response status should be 200
    And the JSON at path "auth_token" should match "\w"
    And the JSON should contain
    """
    {
      "username": "{{USERNAME}}",
      "full_display_name": "TEST USER"
    }
    """

  @user
  Scenario: User can authenticate using its Taiga credentials
    When I make a POST request to "/sessions"
    """
    {
      "username": "test-user",
      "password": "test-password"
    }
    """
    Then the response status should be 200
    And the JSON at path "auth_token" should match "\w"
    And the JSON should contain
    """
    {
      "username": "test-user",
      "full_display_name": "TEST USER"
    }
    """
    Then I set the header "Authorization" to the JSON value at path "auth_token"
