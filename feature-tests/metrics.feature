@wip
  Feature: user
  As a Taiga user
  I can get metrics on my Taiga projects

  Background: Set target server address and headers
    Given I am using server "$SERVER"

  @wip
  Scenario: User can list its Taiga projects
    # TODO review auth
    Given I set BasicAuth to test user credentials
    When I make a POST request to "/sessions"
    Then the response status should be 200
    And the JSON at path "sessionId" should match "\w"
    When I make a GET request to "/projects"
    Then the response status should be 200
    And the JSON should be
    """{
      projects: [
        { name: "project1",
          id: 1,
          work_start_status_id: 1,
          work_end_status_id: 4
        },
        { name: "project2",
          id: 2,
          work_start_status_id: 1,
          work_end_status_id: 3
        },
        { name: "project3",
          id: 3
        }
      ]
    }
    """

  @wip
  Scenario: User can get a given Taiga project's properties
    # TODO review auth
    Given I set BasicAuth to test user credentials
    When I make a POST request to "/sessions"
    Then the response status should be 200
    And the JSON at path "sessionId" should match "\w"
    When I make a GET request to "/projects/2"
    Then the response status should be 200
    And the JSON should be
    """{
      projects: [
        { name: "project2",
          id: 2,
          work_start_status_id: 1,
          work_end_status_id: 3,
          statuses: [
            { "id": 1, name: "specifiy" },
            { "id": 2, name: "build"    },
            { "id": 3, name: "deploy"   },
            { "id": 4, name: "done"     }
          ]
        }
      ]
    }
    """

  @wip
  Scenario: User can update a Taiga project preferences
    # TODO review auth
    Given I set BasicAuth to test user credentials
    When I make a POST request to "/sessions"
    Then the response status should be 200
    And the JSON at path "sessionId" should match "\w"
    When I make a PUT request to "/projects/1"
    """
        { "name": "project1",
          "work_start_status_id": 1
          "work_end_status_id": 4
        }
    """
    When I make a GET request to "/projects"
    Then the response status should be 200
    And the JSON should be
    """{
      projects: [
        { "name": "project1",
          "id": 1,
          "work_start_status_id": 1,
          "work_end_status_id": 4
        },
        { "name": "project2",
          "id": 2,
          "work_start_status_id": 1
          "work_end_status_id": 3
        }
      ]
    }
    """

  @wip
  Scenario: User can activate metrics on a Taiga project
    # TODO review auth
    Given I set BasicAuth to test user credentials
    When I make a POST request to "/sessions"
    Then the response status should be 200
    When I make a GET request to "/projects/3"
    Then the response status should be 200
    And the JSON should be
    """
        { "name": "project3",
          "id": 3,
          "statuses": [
            { "id": 1, "name": "Idea"  },
            { "id": 2, "name": "Think" },
            { "id": 3, "name": "Build" },
            { "id": 4, "name": "Run"   },
            { "id": 5, "name": "Done"  }
          ]
        }
    """
    And the JSON at path "sessionId" should match "\w"
    When I make a PUT request to "/projects/3"
    """
        { "name": "project3",
          "work_start_status_id": 2
          "work_end_status_id": 3
        }
    """
    When I make a GET request to "/projects/3"
    Then the response status should be 200
    And the JSON should be
    """
        { "name": "project3",
          "id": 3,
          "work_start_status_id": 2,
          "work_end_status_id": 3,
          "statuses": [
            { "id": 1, "name": "Idea"  },
            { "id": 2, "name": "Think" },
            { "id": 3, "name": "Build" },
            { "id": 4, "name": "Run"   },
            { "id": 5, "name": "Done"  }
          ]
        }
    """