from app import DB

class ProjectConfig(DB.Model):
    """Database model for project preferences about metrics."""

    __tablename__ = 'project_config'
    project_id = DB.Column(DB.Integer, primary_key=True)
    work_start_status = DB.Column(DB.String(30))
    finish_status = DB.Column(DB.String(30))

    def __init__(self, project_id=None, work_start_status=None, finish_status=None):
        self.project_id = project_id
        self.work_start_status = work_start_status
        self.finish_status = finish_status

