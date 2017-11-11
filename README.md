
# Overview

Taiga Metrics is a companion app for [Taiga](https://taiga.io/)

It provides some simple Kanban metrics and diagrams for Taiga projects:

* **Lead Time**: the number of days between the moment you created a new User Story
and the moment it went live
* **Cycle Time**: the number of days between the moment you started working on a given User Story
 and the moment it went live
* **Cumulated Flow Diagram**: a chart representing the number of cards in each column
of the Kanban Board every day. Here is an example of CFD by Paul Klipp:

![](http://www.paulklipp.com/images/cfd.png)

# Configuration

Taiga Metrics must be deployed on your own servers.
To get metrics and CFD for a given project, you have to activate and configure them in Taiga Project.
It just requires:

* to select the project
* to select the User Story status matching the begining of the work
* to select the User Story status matching the end of the work

You will be provided with an URL and a secret key to [declare a webhook](https://tree.taiga.io/support/integrations/webhooks/)
in your Taiga project.

# Authentication

To activate Taiga Metrics on one of your project, you need to sign-in using your Taiga Credentials.
The authenticated is delegated to Taiga, so your credentials won't be stored in Taiga Metrics.

# Deployment

Taiga Metrics requires a Postgres 9.2+ database and Python 3.3+ to run.

# Internals

## General principle

Taiga Metrics uses the [Taiga Rest API](https://taigaio.github.io/taiga-doc/dist/api.html)
in order to get the status of the Users Stories in the projects on which it was
activated.

When you active Taiga Metrics (TM for short) for a project, a first HTTP request to Taiga is made
 to get the current number of User Stories
in each of the columns of the Kanban board. The result is stored in TM's database.

Then, every time a User Story is created, or its status changes, the webhook URL is invoked.
It allows TM to update the info in its database for the affected User Story: creation date,
work start date, work end date. The invocation of the webhook also triggers
a request from TM to Taiga in order to update the whole User Stories' status too.
So the CFD is always built upon up-to-date data.


## Data model

The database model contains the following tables:

* project table: the projects for which Metrics ar activated.
Columns:
    * project_id (Primary Key): the ID of the project in Taiga
    * work_start_status: the ID of the first status of the work phase in the project's process
    * finish_status: the ID of the last status of the work phase in the project's process
    * secret_key: the secret key to be used by the webhook to encode payload

* user_stories table: user story specific data used to calculate metrics.
Columns:
    * projet_id(PK): the Taiga ID of the project this User Story belongs to
    * user_story_id (PK): the Taiga ID of the User Story
    * creation_date: the date the User Story was created
    * work_start_date: the date the User Story reached the first column of the work phase
    * finish_Date: the date the User Story reached the first column of the work phase

* story_statuses table: the number of User Stories in each column of the Kanban Board for a given project and date.
Columns:
    * project_id (PK): the Taiga ID of the project
    * date (PK)
    * statuses -> JSON object { status_id: count, status_id: count, status_id: count... }


# Improvements

Allow to select a group of status corresponding to the work phase, and not only the first one.
It would be more robust as it would support skipping a column.




