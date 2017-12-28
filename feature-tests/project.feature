  Feature: project
  As a Taiga user
  I can configure my Taiga projects for getting metrics

  Background: Set target server address and headers
    Given I am using server "$SERVER"
    Then I reset the database content

  @project
  Scenario: Non authenticated used cannot access projects
    When I make a GET request to "/projects"
    Then the response status should be 401

  @project
  Scenario: Non authenticated used cannot access project
    When I make a GET request to "/projects/2"
    Then the response status should be 401

  @project
  Scenario: User can list its Taiga projects
    Given I authenticate as test user
    When I make a GET request to "/projects"
    Then the response status should be 200
    And the JSON should be
    """
    {
      "projects": [
        { "name": "project1",
          "id": 1,
          "work_start_status_id": 1,
          "work_end_status_id": 4
        },
        { "name": "project2",
          "id": 2,
          "work_start_status_id": 1,
          "work_end_status_id": 3
        },
        { "name": "project3",
          "id": 3
        }
      ]
    }
    """

  @project
  Scenario: User can get a given Taiga project's properties
    Given I authenticate as test user
    When I make a GET request to "/projects/2"
    Then the response status should be 200
    And the JSON should be
    """
    {
      "project":
        { "name": "project2",
          "id": 2,
          "work_start_status_id": 1,
          "work_end_status_id": 3,
          "statuses": [
            { "id": 1, "name": "specifiy" },
            { "id": 2, "name": "build"    },
            { "id": 3, "name": "deploy"   },
            { "id": 4, "name": "done"     }
          ]
        }
    }
    """

  @wip
  @project
  Scenario: User can update a Taiga project preferences
    Given I authenticate as test user
    When I make a PATCH request to "/projects/1"
    """
        { "work_start_status_id": 1
          "work_end_status_id": 4
        }
    """
    When I make a GET request to "/projects"
    Then the response status should be 200
    And the JSON should be
    """{
      "projects": [
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

  @project
  Scenario: User can activate metrics on a Taiga project
    Given I authenticate as test user
    When I make a GET request to "/projects/3"
    Then the response status should be 200
    And the JSON should be
    """
        { "project" :
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
        }
    """
    When I make a PATCH request to "/projects/3"
    """
        { "work_start_status_id": 2,
          "work_end_status_id": 3
        }
    """
    Then the response status should be 200
    And the JSON should be
    """
        { "project" :
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
        }
    """
