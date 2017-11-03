from app import APP

@APP.route('/projects', methods = ['GET'])
def get_projects():
    """ returns project list """
    response = jsonify(projects = [
        { name : "project1",
          id : 1,
          work_start_status_id : 1,
          work_end_status_id : 4
        },
        { name : "project2",
          id : 2,
          work_start_status_id : 1,
          work_end_status_id : 3
        },
        { name : "project3",
          id : 3
        }
      ]
    )
    response.status_code = 200
    return response