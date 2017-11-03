from flask import jsonify
from app import APP


@APP.route('/projects', methods = ['GET'])
def get_projects():
    """ returns project list """
    # TODO replace fake implementation
    response = jsonify(projects = [
        { "name" : "project1",
          "id" : 1,
          "work_start_status_id" : 1,
          "work_end_status_id" : 4
        },
        { "name" : "project2",
          "id" : 2,
          "work_start_status_id" : 1,
          "work_end_status_id" : 3
        },
        { "name" : "project3",
          "id" : 3
        }
      ]
    )
    response.status_code = 200
    return response

@APP.route('/projects/<id>', methods = ['GET'])
def get_project(id):
    """ returns project details """
    # TODO replace fake implementation
    if id == '2':
        response = _get_fake_project2()
    else:
        response = _get_fake_project3()

    response.status_code = 200
    return response


def _get_fake_project2():
    # TODO remove after implementation of get_project()
    return jsonify(project =
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
        )

def _get_fake_project3():
    # TODO remove after implementation of get_project()
    return jsonify(project =
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
        )