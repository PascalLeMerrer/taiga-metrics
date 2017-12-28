from app import db
from datetime import datetime

class ProjectConfig(db.Model):
    """Database model for project preferences about metrics."""

    __tablename__ = 'project_config'
    project_id = db.Column(db.Integer, primary_key=True)
    work_start_status = db.Column(db.Integer, default=0)
    finish_status = db.Column(db.Integer, default=0)

    def __repr__(self):
        return "<ProjectConfig {}: start status= {}, end status={}".format(
            self.project_id, self.work_start_status, self.finish_status)

    def __init__(self, project_id=None,
                 work_start_status=None,
                finish_status=None):
        self.project_id = project_id
        self.work_start_status = work_start_status
        self.finish_status = finish_status


class UserSession(db.Model):
    """Database model for user session"""

    __tablename__ = 'user_sessions'
    user_id = db.Column(db.Integer)
    token = db.Column(db.String(80), primary_key=True)
    expiration_date = db.Column(db.DateTime, nullable=False,
        default=datetime.utcnow)

    def __repr__(self):
        return f"<Session for user {self.user_id}: token= {self.token}, expiration={self.expiration_date}"

    def __init__(self, user_id=None,
                 token=None,
                 expiration_date=None):
        self.user_id = user_id
        self.token = token
        self.expiration_date = expiration_date

