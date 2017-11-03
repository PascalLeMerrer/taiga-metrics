@wip
Feature: user
  As a Taiga user
  I can active metrics on my Taiga projects

  Background: Set target server address and headers
    Given I am using server "$SERVER"

  @wip
  Scenario: User can list its Taiga projects
    Given I authenticate as test user
    When I make a GET request to "/projects"
    Then the response status should be 200
    And the JSON should be
    """{
      projects: [
        { name: "project1",
          id: 1,
          work_start_status: 1,
          work_end_status: 4
        },
        { name: "project2",
          id: 2,
          work_start_status: 1,
          work_end_status: 3
        }
      ]
    }
    """

  @wip
  Scenario: User can get a given Taiga project's properties
    Given I authenticate as test user
    When I make a GET request to "/projects/2"
    Then the response status should be 200
    And the JSON should be
    """{
      projects: [
        { name: "project2",
          id: 2,
          work_start_status: 1,
          work_end_status: 3,
          statuses: ["specifiy, build, deploy, done"]
        }
      ]
    }
    """

  @wip
  Scenario: User can update a Taiga project preferences
    Given I authenticate as test user
    When I make a PUT request to "/projects/1"
    """
        { name: "project1",
          work_start_status: 1
          work_end_status: 4
        }
    """
    When I make a GET request to "/projects"
    Then the response status should be 200
    And the JSON should be
    """{
      projects: [
        { name: "project1",
          id: 1,
          work_start_status: 1,
          work_end_status: 4
        },
        { name: "project2",
          id: 2,
          work_start_status: 1
          work_end_status: 3
        }
      ]
    }
    """
